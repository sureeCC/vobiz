"""Bind a saved Terraform plan to its layer, commit, backend and provider lock."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path

LAYERS = ("cache", "registry", "secrets", "identity", "argocd")
FILES = ("deployment.tfplan", "backend.hcl", ".terraform.lock.hcl")
MAX_AGE_SECONDS = 24 * 60 * 60


def digest(path):
    if not path.is_file() or path.stat().st_size == 0:
        raise ValueError(f"Missing or empty required file: {path.name}")
    return hashlib.sha256(path.read_bytes()).hexdigest()


def check_project(plan, expected_project):
    if not expected_project or plan.get("variables", {}).get("project_id", {}).get("value") != expected_project:
        raise ValueError("Planned project_id does not match the deployment environment's GCP_PROJECT_ID")
    for resource in plan.get("resource_changes", []):
        if resource.get("mode") != "managed":
            continue
        if resource.get("provider_name") not in {"registry.terraform.io/hashicorp/google", "registry.terraform.io/hashicorp/google-beta"}:
            continue
        change = resource["change"]
        if change.get("after_unknown", {}).get("project"):
            raise ValueError("A Google resource has an unknown target project")
        for values in (change.get("before"), change.get("after")):
            if values and "project" in values and values["project"] != expected_project:
                raise ValueError("A Google resource targets a different project than the deployment environment")


def create(root, layer, commit, project):
    plan = json.loads((root / "plan.json").read_text(encoding="utf-8"))
    check_project(plan, project)
    data = {"schema": 2, "layer": layer, "commit": commit, "project": project,
            "created_at": datetime.now(timezone.utc).isoformat(),
            "sha256": {name: digest(root / name) for name in FILES}}
    (root / "plan-manifest.json").write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def verify(root, layer, commit, project, now=None):
    data = json.loads((root / "plan-manifest.json").read_text(encoding="utf-8"))
    if data.get("schema") != 2 or data.get("layer") != layer or data.get("commit") != commit or data.get("project") != project:
        raise ValueError("Plan layer, commit, project or manifest schema does not match this deployment")
    created = datetime.fromisoformat(data["created_at"])
    if created.tzinfo is None:
        raise ValueError("Manifest timestamp must include a timezone")
    age = ((now or datetime.now(timezone.utc)) - created).total_seconds()
    if age < -300 or age > MAX_AGE_SECONDS:
        raise ValueError("Plan timestamp is invalid or more than 24 hours old; create a fresh plan")
    for name in FILES:
        if data["sha256"].get(name) != digest(root / name):
            raise ValueError(f"Plan/configuration checksum mismatch: {name}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("operation", choices=("create", "verify"))
    parser.add_argument("--layer", choices=LAYERS, required=True)
    parser.add_argument("--commit", required=True)
    parser.add_argument("--project", required=True, help="Expected GCP project from the deployment environment")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1] / "workloads" / "prod" / args.layer
    if args.operation == "create":
        create(root, args.layer, args.commit, args.project)
    else:
        verify(root, args.layer, args.commit, args.project)
    print(f"Plan manifest {args.operation}: PASS")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, TypeError) as exc:
        raise SystemExit(f"FAILED: {exc}")
