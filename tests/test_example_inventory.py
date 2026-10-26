import unittest
from pathlib import Path

ROOT = Path(__file__).parents[1]
EXAMPLES = ROOT / "examples"
EXPECTED = {
    "01-install",
    "02-ingest",
    "03-search",
    "04-fastapi-deploy",
    "05-titiler-pairing",
    "06-full-workflow",
}


class ExampleInventoryTests(unittest.TestCase):
    def test_all_documented_patterns_are_present(self):
        actual = {path.name for path in EXAMPLES.iterdir() if path.is_dir()}
        self.assertEqual(actual, EXPECTED)

    def test_each_pattern_has_readme_and_shell_or_sql_artifact(self):
        for name in sorted(EXPECTED):
            with self.subTest(pattern=name):
                directory = EXAMPLES / name
                self.assertTrue((directory / "README.md").is_file())
                artifacts = list(directory.glob("*.sh")) + list(directory.glob("*.sql"))
                self.assertTrue(artifacts, f"{name} has no shell or SQL artifact")


if __name__ == "__main__":
    unittest.main()
