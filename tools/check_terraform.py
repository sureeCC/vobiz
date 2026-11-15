"""Check five module/root pairs with credential-free tests and read-only locks."""
import argparse
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LAYERS = {"cache": "redis", "registry": "artifact-registry", "secrets": "secret-manager",
          "identity": "workload-identity", "argocd": "argocd"}
APIS = {"cache": {"redis.googleapis.com"}, "registry": {"artifactregistry.googleapis.com"},
        "secrets": {"secretmanager.googleapis.com"},
        "identity": {"iam.googleapis.com", "iamcredentials.googleapis.com"},
        "argocd": {"container.googleapis.com"}}


def verify_root_plan(layer, plan):
    """Inspect the actual root's resource graph, not an alternate test module."""
    changes = [r for r in plan["resource_changes"] if r["mode"] == "managed"]

    def resources(kind):
        return [r["change"]["after"] for r in changes if r["type"] == kind]

    def require(condition, message):
        if not condition:
            raise ValueError(f"{layer} root contract: {message}")

    apis = resources("google_project_service")
    require({r["service"] for r in apis} == APIS[layer], "required APIs were changed/dropped")
    require(all(r["project"] == "test-project" and not r["disable_on_destroy"] for r in apis),
            "API project/lifecycle was changed")
    if layer == "cache":
        caches = resources("google_redis_instance")
        require(len(caches) == 1, "expected one Redis instance")
        cache = caches[0]
        require(cache["name"] == "test-cache" and cache["project"] == "test-project"
                and cache["region"] == "asia-south1", "cache identity was not forwarded")
        require(cache["authorized_network"] == "projects/test-project/global/networks/test-vpc"
                and cache["memory_size_gb"] == 7, "VPC/capacity input was not forwarded")
        require(cache["tier"] == "STANDARD_HA" and cache["auth_enabled"]
                and cache["transit_encryption_mode"] == "SERVER_AUTHENTICATION"
                and cache["deletion_protection"], "cache security defaults were lost")
        window = cache["maintenance_policy"][0]["weekly_maintenance_window"][0]
        require(window["day"] == "TUESDAY" and window["start_time"][0]["hours"] == 3,
                "maintenance inputs were not forwarded")
    elif layer == "registry":
        repos = resources("google_artifact_registry_repository")
        require(len(repos) == 1 and repos[0]["repository_id"] == "app"
                and repos[0]["location"] == "asia-south1" and repos[0]["project"] == "test-project"
                and repos[0]["format"] == "DOCKER" and repos[0]["docker_config"][0]["immutable_tags"],
                "repository configuration was not forwarded")
        grants = resources("google_artifact_registry_repository_iam_member")
        require({(r["role"], r["member"]) for r in grants} == {
            ("roles/artifactregistry.reader", "serviceAccount:node@test-project.iam.gserviceaccount.com"),
            ("roles/artifactregistry.writer", "serviceAccount:build@test-project.iam.gserviceaccount.com")},
            "repository-scoped IAM was changed/dropped")
    elif layer == "secrets":
        secrets = {r["secret_id"]: r for r in resources("google_secret_manager_secret")}
        require(set(secrets) == {"app", "regional"}, "secret inputs were changed/dropped")
        require(all(r["project"] == "test-project" and r["deletion_protection"] for r in secrets.values()),
                "secret project/protection was changed")
        require(len(secrets["app"]["replication"][0]["auto"]) == 1
                and secrets["regional"]["replication"][0]["user_managed"][0]["replicas"][0]["location"] == "asia-south1",
                "secret replication was not forwarded")
        grants = resources("google_secret_manager_secret_iam_member")
        require(len(grants) == 1 and grants[0]["secret_id"] == "app"
                and grants[0]["role"] == "roles/secretmanager.secretAccessor"
                and grants[0]["member"] == "serviceAccount:app@test-project.iam.gserviceaccount.com",
                "resource-scoped secret access was changed")
        require(not resources("google_secret_manager_secret_version"), "secret payloads must remain outside Terraform")
    elif layer == "identity":
        accounts = resources("google_service_account")
        require(len(accounts) == 1 and accounts[0]["account_id"] == "app-runtime"
                and accounts[0]["project"] == "test-project", "service-account inputs were changed")
        bindings = resources("google_service_account_iam_member")
        require(len(bindings) == 1 and bindings[0]["role"] == "roles/iam.workloadIdentityUser"
                and bindings[0]["member"] == "serviceAccount:cluster-project.svc.id.goog[app/backend]",
                "GKE workload identity subject was changed")
        roles = resources("google_project_iam_member")
        require(len(roles) == 1 and roles[0]["role"] == "roles/logging.logWriter", "explicit role was not forwarded")
        require(not resources("google_service_account_key"), "long-lived keys must not be created")
    else:
        releases = resources("helm_release")
        require(len(releases) == 1, "expected one Helm release")
        release = releases[0]
        require(release["namespace"] == "gitops" and release["chart"] == "argo-cd"
                and release["version"] == "10.18.0", "Argo CD inputs/pin were not forwarded")
        require(release["atomic"] and release["wait"] and release["create_namespace"],
                "Helm lifecycle settings were lost")
        require(release["values"][-1] == "server:\n  replicas: 2\n", "custom Helm values were not forwarded")


def run_tests(root, layer, timeout):
    result = subprocess.run(["terraform", f"-chdir={root}", "test", "-json", "-verbose", "-no-color"],
                            check=False, capture_output=True, text=True, encoding="utf-8", timeout=timeout)
    root_plan = None
    for line in result.stdout.splitlines():
        event = json.loads(line)
        if event.get("type") in {"test_run", "test_summary"}:
            print(event.get("@message", ""), flush=True)
        if event.get("type") == "diagnostic" and (result.returncode or event["diagnostic"]["severity"] == "warning"):
            diagnostic = event["diagnostic"]
            print(f"{diagnostic['severity']}: {diagnostic['summary']}: {diagnostic.get('detail', '')}", flush=True)
        if event.get("type") == "test_plan" and event.get("@testrun") == "root_contract":
            root_plan = event["test_plan"]
    if result.returncode:
        raise RuntimeError(f"{layer}: Terraform tests failed. {result.stderr}")
    if root_plan is None:
        raise RuntimeError(f"{layer}: required root_contract plan is missing")
    verify_root_plan(layer, root_plan)
    print(f"{layer}: deployment resource graph PASS", flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--layer", choices=LAYERS, action="append")
    parser.add_argument("--plugin-dir", help="Optional existing local provider mirror")
    parser.add_argument("--timeout", type=int, default=300, help="Maximum seconds per Terraform command")
    args = parser.parse_args()
    if args.timeout <= 0:
        parser.error("--timeout must be positive")
    for layer in dict.fromkeys(args.layer or LAYERS):
        root = ROOT / "workloads" / "prod" / layer
        module = ROOT / "modules" / LAYERS[layer]
        print(f"Checking {layer}", flush=True)
        if not (root / ".terraform.lock.hcl").is_file():
            raise RuntimeError(f"{layer}: commit a reviewed provider lock file before validation")
        commands = [
            ["terraform", f"-chdir={module}", "fmt", "-check", "-recursive"],
            ["terraform", f"-chdir={root}", "fmt", "-check", "-recursive"],
            ["terraform", f"-chdir={root}", "init", "-backend=false", "-input=false", "-lockfile=readonly", "-no-color"]
            + ([f"-plugin-dir={Path(args.plugin_dir).resolve()}"] if args.plugin_dir else []),
            ["terraform", f"-chdir={root}", "validate", "-no-color"],
        ]
        for command in commands:
            subprocess.run(command, check=True, cwd=ROOT, timeout=args.timeout)
        run_tests(root, layer, args.timeout)
    print("PASS: modules, root wiring and mock resource graphs verified; no live deployment.")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, IndexError, RuntimeError, subprocess.SubprocessError) as exc:
        raise SystemExit(f"FAILED: {exc}")
