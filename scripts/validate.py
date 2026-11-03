"""Initialize and validate each Terraform root without contacting GCP backends.

Usage: python scripts/validate.py --terraform /path/to/terraform
Downloads pinned public modules/providers. Never runs a cloud plan or apply.
"""

import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--terraform", default="terraform")
    parser.add_argument("--layer", action="append", help="Validate only named layers, e.g. network")
    parser.add_argument("--mock-plan", action="store_true", help="Also run offline plans with all providers mocked")
    args = parser.parse_args()
    from layout import ROOT as root, PROD, LAYOUT
    selected = args.layer or list(LAYOUT)
    if set(selected) - LAYOUT.keys():
        parser.error("Unknown layer name")
    roots = [(name, LAYOUT[name]) for name in selected]

    env = os.environ.copy()
    env["TF_IN_AUTOMATION"] = "1"
    env["TF_INPUT"] = "0"
    env["GIT_CONFIG_COUNT"] = "1"
    env["GIT_CONFIG_KEY_0"] = "core.longpaths"
    env["GIT_CONFIG_VALUE_0"] = "true"
    # Sequential initialization: Terraform's shared plugin cache is not
    # guaranteed concurrency-safe. Do not launch these roots in parallel.
    cache = Path(tempfile.gettempdir()) / "vobiz-tf-provider-cache"
    cache.mkdir(exist_ok=True)
    env.setdefault("TF_PLUGIN_CACHE_DIR", str(cache))

    def run(path, *command):
        result = subprocess.run(
            [args.terraform, f"-chdir={path}", *command],
            env=env, text=True, encoding="utf-8", capture_output=True,
        )
        if result.returncode:
            print(result.stdout)
            print(result.stderr, file=sys.stderr)
        return result

    failures = []
    for name, path in roots:
        print(f"Checking {path.relative_to(root)}", flush=True)
        format_targets = ["."] + (["tests"] if (path / "tests").is_dir() else [])
        if run(path, "fmt", "-check", *format_targets).returncode:
            failures.append(f"{path.name}: formatting")
        if run(path, "init", "-backend=false", "-input=false", "-no-color").returncode:
            failures.append(f"{path.name}: init")
            continue
        result = run(path, "validate", "-json")
        if result.returncode:
            failures.append(f"{path.name}: validate")
        else:
            report = json.loads(result.stdout)
            print(f"  valid; {report['warning_count']} warnings", flush=True)
        if args.mock_plan and result.returncode == 0:
            command = ["test", "-no-color", "-var-file=terraform.tfvars.example"]
            if name != "bootstrap":
                command.append(f"-var-file={PROD / 'common.tfvars.example'}")
            tests = run(path, *command)
            if tests.returncode:
                failures.append(f"{path.name}: mocked plan")
            else:
                print(tests.stdout.strip(), flush=True)

    if failures:
        print("FAILED: " + ", ".join(failures))
        return 1
    print(f"PASS: {len(roots)} Terraform roots validated. No cloud plan/apply performed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
