"""Run every production component through one Terraform root and GCS state."""
import argparse
import json
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
PROD = ROOT / "workloads" / "prod"


def execute(*args, **kwargs):
    env = os.environ.copy()
    env["TF_IN_AUTOMATION"] = "1"
    # Do not let an inherited workspace silently select a different state.
    env["TF_WORKSPACE"] = "default"
    return subprocess.run(["terraform", f"-chdir={PROD}", *args],
                          cwd=ROOT, env=env, check=True, **kwargs)


def run_tests():
    from check_network_security import verify_network_security
    # Inspect the real root plans in addition to Terraform assertions.
    try:
        result = execute("test", "-json", "-verbose", "-no-color",
                         capture_output=True, text=True, encoding="utf-8")
    except subprocess.CalledProcessError as exc:
        print(exc.stdout or "")
        print(exc.stderr or "")
        raise
    plans = {}
    for line in result.stdout.splitlines():
        event = json.loads(line)
        if event.get("type") == "test_plan":
            plans[event["@testrun"]] = event["test_plan"]
        elif event.get("type") in {"test_run", "test_summary"}:
            print(event.get("@message", ""))
        elif event.get("type") == "diagnostic" and event.get("diagnostic", {}).get("severity") == "warning":
            print(event.get("@message", ""))
    verify_network_security(plans)


def run(args):
    if args.command == "validate":
        subprocess.run(["terraform", "fmt", "-check", "-recursive"],
                       cwd=ROOT, check=True)
        execute("init", "-backend=false", "-input=false")
        execute("validate", "-no-color")
        run_tests()
        return
    plan = Path(args.plan).resolve()
    init = ["init", "-input=false"]
    backend = getattr(args, "backend_config", None)
    if backend:
        backend = Path(backend).resolve()
        if not backend.is_file():
            raise ValueError(f"Backend configuration does not exist: {backend}")
        init.extend(["-reconfigure", f"-backend-config={backend}"])
    if args.command == "plan":
        variables = Path(args.var_file).resolve()
        if not variables.is_file():
            raise ValueError(f"Variable file does not exist: {variables}")
        plan.parent.mkdir(parents=True, exist_ok=True)
        execute(*init)
        execute("validate", "-no-color")
        execute("plan", "-input=false", "-lock-timeout=5m",
                f"-var-file={variables}", f"-out={plan}")
        execute("show", "-no-color", str(plan))
    else:
        if not plan.is_file():
            raise ValueError(f"Saved plan does not exist: {plan}")
        execute(*init, "-lockfile=readonly")
        execute("apply", "-input=false", "-lock-timeout=5m", str(plan))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("validate")
    plan = commands.add_parser("plan")
    plan.add_argument("--var-file", required=True,
                      help="Path relative to your current directory, or absolute")
    plan.add_argument("--plan", default=str(ROOT / "artifacts" / "prod.tfplan"))
    plan.add_argument("--backend-config", help="Optional backend HCL file; selects the existing state without migrating it")
    apply = commands.add_parser("apply")
    apply.add_argument("--plan", default=str(ROOT / "artifacts" / "prod.tfplan"))
    apply.add_argument("--backend-config", help="Use the same backend HCL file used when planning")
    args = parser.parse_args()
    try:
        run(args)
    except (OSError, ValueError, subprocess.CalledProcessError) as exc:
        parser.exit(1, f"FAILED: {exc}\n")


if __name__ == "__main__":
    main()
