"""Prepare configuration and operate ONE Terraform layer at a time.

No action runs by default. prepare/preflight are local-only. init/plan/apply
require an explicit action and layer; apply accepts only an existing saved plan.
"""
import argparse
from pathlib import Path
import re
import shutil
import subprocess
import sys

from layout import ROOT, PROD, LAYOUT
LAYERS = list(LAYOUT)


def directory(layer):
    return LAYOUT[layer]


def prepare():
    examples = [PROD / "common.tfvars.example"]
    for path in LAYOUT.values():
        examples.extend(path.glob("*.hcl.example"))
        examples.extend(path.glob("*.tfvars.example"))
    for example in dict.fromkeys(examples):
        target = example.with_suffix("")
        if target.exists():
            print(f"Kept existing {target.relative_to(ROOT)}")
        else:
            shutil.copyfile(example, target)
            print(f"Created {target.relative_to(ROOT)}; replace example values")
    print("No backend.tf added to bootstrap: create its bucket locally before migrating state.")


def preflight(layer):
    path = directory(layer)
    files = [path / "terraform.tfvars"]
    if layer != "bootstrap":
        files += [PROD / "common.tfvars", path / "backend.hcl"]
    elif (path / "backend.tf").exists():
        files.append(path / "backend.hcl")
    errors = []
    for file in files:
        if not file.exists():
            errors.append(f"Missing {file}; run prepare and configure it")
            continue
        for number, line in enumerate(file.read_text(encoding="utf-8").splitlines(), 1):
            if line.lstrip().startswith("#"):
                continue
            # Conservative guard, not an HCL parser or a substitute for plan review.
            if re.search(r"PROJECT[ _]ID|MOCK|REPLACE_WITH|example\.com|000000|192\.0\.2\.|198\.51\.100\.|203\.0\.113\.", line):
                errors.append(f"Unresolved example at {file.relative_to(ROOT)}:{number}")
    if layer == "platform" and not shutil.which("gke-gcloud-auth-plugin"):
        errors.append("gke-gcloud-auth-plugin is required on the private-network runner")
    for error in errors:
        print(error, file=sys.stderr)
    if not errors:
        print(f"Local preflight passed for {layer}; cloud access, sizing and CIDRs are not verified.")
    return not errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["prepare", "preflight", "init", "plan", "apply"])
    parser.add_argument("--layer", choices=LAYERS)
    parser.add_argument("--terraform", default="terraform")
    parser.add_argument("--plan-file", default="review.tfplan")
    args = parser.parse_args()
    if args.action == "prepare":
        prepare()
        return 0
    if args.layer is None:
        parser.error("--layer is required; recursive deployment is not supported")
    if not preflight(args.layer):
        return 1
    if args.action == "preflight":
        return 0
    path = directory(args.layer)
    command = [args.terraform, f"-chdir={path}"]
    if args.action == "init":
        command += ["init", "-input=false"]
        if args.layer != "bootstrap" or (path / "backend.tf").exists():
            command += ["-backend-config=backend.hcl"]
    else:
        plan = Path(args.plan_file)
        if not plan.is_absolute():
            plan = path / plan
        if args.action == "plan":
            command += ["plan", "-input=false", "-detailed-exitcode", f"-out={plan}"]
            if args.layer != "bootstrap":
                command += [f"-var-file={PROD / 'common.tfvars'}"]
        else:
            if not plan.is_file():
                parser.error(f"Saved plan does not exist: {plan}")
            command += ["apply", str(plan)]
    result = subprocess.run(command).returncode
    return 0 if args.action == "plan" and result == 2 else result


if __name__ == "__main__":
    raise SystemExit(main())
