import argparse
import importlib.util
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

SCRIPT = Path(__file__).resolve().parents[1] / "terraform_pipeline.py"
spec = importlib.util.spec_from_file_location("pipeline", SCRIPT)
pipeline = importlib.util.module_from_spec(spec)
spec.loader.exec_module(pipeline)


class PipelineTests(unittest.TestCase):
    @patch.object(pipeline.subprocess, "run")
    def test_fixed_root_and_workspace(self, run):
        with patch.dict(os.environ, {"TF_WORKSPACE": "other"}):
            pipeline.execute("validate")
        args, kwargs = run.call_args
        self.assertEqual(args[0][:2], ["terraform", f"-chdir={pipeline.PROD}"])
        self.assertEqual(kwargs["env"]["TF_WORKSPACE"], "default")
        self.assertTrue(kwargs["check"])

    @patch.object(pipeline, "execute")
    def test_apply_uses_saved_plan_without_replanning(self, execute):
        with tempfile.TemporaryDirectory() as folder:
            plan = Path(folder) / "review.tfplan"
            plan.write_bytes(b"saved-plan")
            pipeline.run(argparse.Namespace(command="apply", plan=str(plan)))
            calls = [call.args for call in execute.call_args_list]
            self.assertEqual(calls[0], ("init", "-input=false", "-lockfile=readonly"))
            self.assertEqual(calls[1], ("apply", "-input=false", "-lock-timeout=5m", str(plan)))
            self.assertEqual(len(calls), 2)

    @patch.object(pipeline, "execute")
    def test_missing_plan_does_not_initialize_backend(self, execute):
        with tempfile.TemporaryDirectory() as folder:
            with self.assertRaises(ValueError):
                pipeline.run(argparse.Namespace(command="apply", plan=str(Path(folder) / "missing")))
        execute.assert_not_called()

    @patch.object(pipeline, "execute")
    def test_plan_saves_reviewed_binary_and_displays_it(self, execute):
        with tempfile.TemporaryDirectory() as folder:
            variables = Path(folder) / "production.tfvars"
            variables.write_text('project_id = "test-project"')
            plan = Path(folder) / "output" / "production.tfplan"
            pipeline.run(argparse.Namespace(command="plan", var_file=str(variables), plan=str(plan)))
            calls = [call.args for call in execute.call_args_list]
            self.assertEqual(calls[0], ("init", "-input=false"))
            self.assertEqual(calls[2], ("plan", "-input=false", "-lock-timeout=5m",
                                       f"-var-file={variables}", f"-out={plan}"))
            self.assertEqual(calls[3], ("show", "-no-color", str(plan)))
            self.assertTrue(plan.parent.is_dir())

    @patch.object(pipeline, "execute")
    def test_missing_variables_does_not_initialize_backend(self, execute):
        with tempfile.TemporaryDirectory() as folder:
            with self.assertRaises(ValueError):
                pipeline.run(argparse.Namespace(command="plan", var_file=str(Path(folder) / "missing"),
                                                plan=str(Path(folder) / "plan")))
        execute.assert_not_called()

    @patch.object(pipeline, "run_tests")
    @patch.object(pipeline.subprocess, "run")
    @patch.object(pipeline, "execute")
    def test_validation_never_initializes_live_backend(self, execute, run, run_tests):
        pipeline.run(argparse.Namespace(command="validate"))
        self.assertEqual(execute.call_args_list[0].args,
                         ("init", "-backend=false", "-input=false"))
        self.assertEqual(execute.call_args_list[-1].args, ("validate", "-no-color"))
        run_tests.assert_called_once_with()


if __name__ == "__main__":
    unittest.main()
