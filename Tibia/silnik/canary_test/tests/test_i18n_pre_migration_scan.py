#!/usr/bin/env python3
import json
import subprocess
import tempfile
import unittest
from pathlib import Path


SCRIPT = (Path(__file__).resolve().parents[1] / "tools" / "i18n_pre_migration_scan.py").resolve()


def run_scan(project_root: Path, category: str = "all", scope: str = "full") -> subprocess.CompletedProcess[str]:
    status_dir = project_root / "i18n" / "status"
    return subprocess.run(
        [
            "python3",
            str(SCRIPT),
            "--project-root",
            str(project_root),
            "--status-dir",
            str(status_dir),
            "--category",
            category,
            "--scope",
            scope,
        ],
        text=True,
        capture_output=True,
        check=False,
    )


class PreMigrationScanTests(unittest.TestCase):
    def test_npc_detects_non_i18n_runtime_text(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            npc_dir = root / "data-otservbr-global" / "npc"
            npc_dir.mkdir(parents=True, exist_ok=True)
            (npc_dir / "sample.lua").write_text(
                '\n'.join(
                    [
                        '-- comment should be ignored',
                        'npcHandler:say("Hello traveler, want trade?", npc, creature)',
                        'NPC_LIB.i18n.npcSay(npc, creature, "npc.sample.greeting")',
                    ]
                ),
                encoding="utf-8",
            )

            result = run_scan(root, category="npc")
            self.assertEqual(result.returncode, 0, msg=result.stderr)
            self.assertIn("__PREMIG__", result.stdout)
            self.assertIn("hits=1", result.stdout)

            todo_json = root / "i18n" / "status" / "pre_migration_todo" / "npc.json"
            self.assertTrue(todo_json.exists())
            payload = json.loads(todo_json.read_text(encoding="utf-8"))
            self.assertEqual(payload["hits"], 1)
            self.assertEqual(payload["files_with_hits"], 1)
            self.assertEqual(payload["entries"][0]["line"], 2)
            self.assertIn("Hello traveler", payload["entries"][0]["text"])

    def test_scripts_ignore_localized_calls(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            scripts_dir = root / "data-otservbr-global" / "scripts"
            scripts_dir.mkdir(parents=True, exist_ok=True)
            (scripts_dir / "localized.lua").write_text(
                '\n'.join(
                    [
                        'player:sendLocalizedTextMessage(MESSAGE_INFO_DESCR, "scripts.foo.bar")',
                        'Game.broadcastLocalizedMessage("scripts.foo.baz")',
                    ]
                ),
                encoding="utf-8",
            )

            result = run_scan(root, category="scripts")
            self.assertEqual(result.returncode, 0, msg=result.stderr)
            self.assertIn("hits=0", result.stdout)
            self.assertIn("files_with_hits=0", result.stdout)

            todo_json = root / "i18n" / "status" / "pre_migration_todo" / "scripts.json"
            payload = json.loads(todo_json.read_text(encoding="utf-8"))
            self.assertEqual(payload["hits"], 0)

    def test_all_generates_combined_csv_and_history(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            npc_dir = root / "data-otservbr-global" / "npc"
            npc_dir.mkdir(parents=True, exist_ok=True)
            (npc_dir / "a.lua").write_text(
                'npcHandler:say("A runtime line", npc, creature)\n',
                encoding="utf-8",
            )

            scripts_dir = root / "data-otservbr-global" / "scripts"
            scripts_dir.mkdir(parents=True, exist_ok=True)
            (scripts_dir / "b.lua").write_text(
                'player:sendTextMessage(MESSAGE_INFO_DESCR, "Quest finished!")\n',
                encoding="utf-8",
            )

            result = run_scan(root, category="all", scope="full")
            self.assertEqual(result.returncode, 0, msg=result.stderr)

            todo_root = root / "i18n" / "status" / "pre_migration_todo"
            self.assertTrue((todo_root / "pre_migration_todo.csv").exists())
            self.assertTrue((todo_root / "pre_migration_todo_latest.json").exists())
            self.assertTrue((todo_root / "pre_migration_todo_history.jsonl").exists())

            latest = json.loads((todo_root / "pre_migration_todo_latest.json").read_text(encoding="utf-8"))
            self.assertGreaterEqual(int(latest.get("hits", 0)), 2)


if __name__ == "__main__":
    unittest.main()

