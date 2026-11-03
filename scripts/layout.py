from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
PROD = ROOT / "workloads" / "prod"
LAYOUT = {
    "bootstrap": ROOT / "landing-zone" / "bootstrap",
    "foundation": ROOT / "landing-zone" / "organization",
    "network": PROD,
    **{name: PROD / name for name in ("gke", "platform", "connectivity", "edge", "voice", "data")},
}
