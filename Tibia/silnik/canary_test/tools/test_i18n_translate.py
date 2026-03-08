import json
import tempfile
import unittest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import i18n_translate as tr


class I18NTranslateTests(unittest.TestCase):
    def test_sound_heuristic_edge_cases(self):
        self.assertTrue(tr.is_non_translatable_sound("Grrrr"))
        self.assertTrue(tr.is_non_translatable_sound("Zzzzzt"))
        self.assertFalse(tr.is_non_translatable_sound("Quest"))

    def test_get_untranslated_keys_skips_sound_texts(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "en").mkdir(parents=True, exist_ok=True)
            (root / "pl").mkdir(parents=True, exist_ok=True)
            (root / "en" / "npc.json").write_text(
                json.dumps(
                    {
                        "npc.sound": "Grrrraaa!",
                        "npc.hello": "Hello traveler",
                    },
                    ensure_ascii=False,
                ),
                encoding="utf-8",
            )
            (root / "pl" / "npc.json").write_text("{}", encoding="utf-8")

            old_i18n = tr.I18N_DIR
            try:
                tr.I18N_DIR = root
                keys = tr.get_untranslated_keys("npc", "pl", 50)
            finally:
                tr.I18N_DIR = old_i18n

            self.assertEqual([item["key"] for item in keys], ["npc.hello"])

    def test_generate_batch_collects_missing_for_all_targets(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / "i18n"
            (root / "en").mkdir(parents=True, exist_ok=True)
            (root / "pl").mkdir(parents=True, exist_ok=True)
            (root / "es").mkdir(parents=True, exist_ok=True)
            (root / "en" / "npc.json").write_text(
                json.dumps({"npc.k1": "Hello there", "npc.k2": "Farewell"}, ensure_ascii=False),
                encoding="utf-8",
            )
            (root / "pl" / "npc.json").write_text(
                json.dumps({"npc.k1": "Witaj"}, ensure_ascii=False),
                encoding="utf-8",
            )
            (root / "es" / "npc.json").write_text("{}", encoding="utf-8")

            old_i18n = tr.I18N_DIR
            old_batch = tr.BATCH_DIR
            try:
                tr.I18N_DIR = root
                tr.BATCH_DIR = Path(tmp) / "batches"
                batch = tr.generate_batch("npc", ["pl", "es"], 20)
            finally:
                tr.I18N_DIR = old_i18n
                tr.BATCH_DIR = old_batch

            by_key = {item["key"]: item for item in batch["keys"]}
            self.assertIn("npc.k1", by_key)
            self.assertIn("es", by_key["npc.k1"]["missing_in"])
            self.assertIn("npc.k2", by_key)
            self.assertIn("pl", by_key["npc.k2"]["missing_in"])
            self.assertIn("es", by_key["npc.k2"]["missing_in"])

    def test_generate_rejected_batch_uses_validation_reports(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / "i18n"
            validation = root / "status" / "validation"
            (root / "en").mkdir(parents=True, exist_ok=True)
            validation.mkdir(parents=True, exist_ok=True)
            (root / "en" / "npc.json").write_text(
                json.dumps({"npc.k1": "Hello hero", "npc.k2": "Farewell"}, ensure_ascii=False),
                encoding="utf-8",
            )
            (validation / "pl_report.json").write_text(
                json.dumps({"worst_keys": [{"key": "npc.k1", "type": "V4_artifact"}]}, ensure_ascii=False),
                encoding="utf-8",
            )
            (validation / "es_npc_grammarfix.json").write_text(
                json.dumps(
                    {
                        "details": [
                            {"key": "npc.k2", "status": "skipped_guard"},
                            {"key": "npc.ignored", "status": "fixed"},
                        ]
                    },
                    ensure_ascii=False,
                ),
                encoding="utf-8",
            )

            old_i18n = tr.I18N_DIR
            old_batch = tr.BATCH_DIR
            try:
                tr.I18N_DIR = root
                tr.BATCH_DIR = Path(tmp) / "batches"
                batch = tr.generate_rejected_batch(["pl", "es"], 20, validation)
            finally:
                tr.I18N_DIR = old_i18n
                tr.BATCH_DIR = old_batch

            by_key = {item["key"]: item for item in batch["keys"]}
            self.assertIn("npc.k1", by_key)
            self.assertIn("pl", by_key["npc.k1"]["missing_in"])
            self.assertIn("V4_artifact", by_key["npc.k1"]["issues"])
            self.assertIn("npc.k2", by_key)
            self.assertIn("es", by_key["npc.k2"]["missing_in"])
            self.assertIn("skipped_guard", by_key["npc.k2"]["issues"])


if __name__ == "__main__":
    unittest.main()
