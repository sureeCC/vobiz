import importlib.util
from datetime import datetime, timedelta, timezone
import json
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location("plan_manifest", Path(__file__).parents[1] / "plan_manifest.py")
manifest = importlib.util.module_from_spec(spec)
spec.loader.exec_module(manifest)


class PlanManifestTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for name in manifest.FILES:
            (self.root / name).write_bytes(b"test content")
        self.plan = {"variables": {"project_id": {"value": "test-project"}}, "resource_changes": [{
            "mode": "managed", "provider_name": "registry.terraform.io/hashicorp/google",
            "change": {"before": None, "after": {"project": "test-project"}, "after_unknown": {}}}]}
        (self.root / "plan.json").write_text(json.dumps(self.plan), encoding="utf-8")
        manifest.create(self.root, "registry", "commit-a", "test-project")

    def test_accepts_original_plan(self):
        manifest.verify(self.root, "registry", "commit-a", "test-project")

    def test_rejects_each_changed_file(self):
        for name in manifest.FILES:
            with self.subTest(name=name):
                (self.root / name).write_bytes(b"changed")
                with self.assertRaises(ValueError):
                    manifest.verify(self.root, "registry", "commit-a", "test-project")
                (self.root / name).write_bytes(b"test content")

    def test_rejects_wrong_commit_and_layer(self):
        for layer, commit in [("cache", "commit-a"), ("registry", "commit-b")]:
            with self.subTest(layer=layer, commit=commit), self.assertRaises(ValueError):
                manifest.verify(self.root, layer, commit, "test-project")

    def test_rejects_expired_plan(self):
        with self.assertRaises(ValueError):
            manifest.verify(self.root, "registry", "commit-a", "test-project", datetime.now(timezone.utc) + timedelta(days=2))

    def test_rejects_future_timestamp(self):
        with self.assertRaises(ValueError):
            manifest.verify(self.root, "registry", "commit-a", "test-project", datetime.now(timezone.utc) - timedelta(hours=1))

    def test_rejects_missing_file(self):
        (self.root / "deployment.tfplan").unlink()
        with self.assertRaises(ValueError):
            manifest.verify(self.root, "registry", "commit-a", "test-project")


    def test_rejects_changed_environment_project(self):
        with self.assertRaises(ValueError):
            manifest.verify(self.root, "registry", "commit-a", "different-project")

    def test_rejects_wrong_plan_project(self):
        self.plan["variables"]["project_id"]["value"] = "different-project"
        with self.assertRaises(ValueError):
            manifest.check_project(self.plan, "test-project")

    def test_rejects_missing_project(self):
        self.plan["variables"] = {}
        with self.assertRaises(ValueError):
            manifest.check_project(self.plan, "test-project")

    def test_rejects_wrong_resource_project(self):
        self.plan["resource_changes"][0]["change"]["after"]["project"] = "different-project"
        with self.assertRaises(ValueError):
            manifest.check_project(self.plan, "test-project")

    def test_rejects_deletion_in_another_project(self):
        self.plan["resource_changes"][0]["change"].update(before={"project": "different-project"}, after=None)
        with self.assertRaises(ValueError):
            manifest.check_project(self.plan, "test-project")

    def test_rejects_unknown_resource_project(self):
        self.plan["resource_changes"][0]["change"]["after_unknown"] = {"project": True}
        with self.assertRaises(ValueError):
            manifest.check_project(self.plan, "test-project")


if __name__ == "__main__":
    unittest.main()
