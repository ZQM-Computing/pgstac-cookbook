import unittest
from pathlib import Path

ROOT = Path(__file__).parents[1]
SCRIPT = ROOT / "examples" / "01-install" / "install-and-verify.sh"
README = ROOT / "examples" / "01-install" / "README.md"


class InstallExampleTests(unittest.TestCase):
    def test_script_is_fail_fast_and_pins_default_version(self):
        script = SCRIPT.read_text(encoding="utf-8")
        self.assertIn("set -Eeuo pipefail", script)
        self.assertIn('PGSTAC_VERSION="${PGSTAC_VERSION:-0.10.0}"', script)
        self.assertIn('pgstac-migrate migrate --dsn "$DATABASE_URL" --to "$PGSTAC_VERSION"', script)

    def test_script_verifies_schema_and_core_tables(self):
        script = SCRIPT.read_text(encoding="utf-8")
        for marker in (
            "nspname = 'pgstac'",
            "to_regclass('pgstac.collections')",
            "to_regclass('pgstac.items')",
            "function_count < 1",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, script)

    def test_script_does_not_drop_or_truncate_objects(self):
        script = SCRIPT.read_text(encoding="utf-8").lower()
        self.assertNotIn("drop table", script)
        self.assertNotIn("truncate ", script)
        self.assertNotIn("drop schema", script)

    def test_docs_distinguish_database_from_http_api(self):
        readme = README.read_text(encoding="utf-8")
        self.assertIn("does not install or configure an HTTP API", readme)
        self.assertIn("does not prove", readme.lower())


if __name__ == "__main__":
    unittest.main()
