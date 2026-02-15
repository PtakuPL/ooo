import tempfile
import unittest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from i18n_string_extractor import StringExtractor


class StringExtractorPlaceholderTests(unittest.TestCase):
    def test_message_starting_with_placeholder_is_extracted_with_key(self):
        extractor = StringExtractor(min_length=1)
        with tempfile.NamedTemporaryFile("w", suffix=".lua", delete=False) as handle:
            handle.write('npcHandler:say("{playerName}, welcome back!")\n')
            temp_path = Path(handle.name)
        try:
            extracted = extractor.extract_from_file(temp_path)
            self.assertEqual(len(extracted), 1)
            self.assertTrue(extracted[0].suggested_key)
            self.assertIn("{playerName}", extracted[0].placeholders)
        finally:
            temp_path.unlink(missing_ok=True)

    def test_placeholder_detection_keeps_full_tokens(self):
        extractor = StringExtractor(min_length=1)
        placeholders = extractor._find_placeholders(
            "Hello {playerName}, take [item name] and %s from |PLAYERNAME|."
        )
        self.assertEqual(
            placeholders,
            ["{playerName}", "%s", "|PLAYERNAME|", "[item name]"],
        )


if __name__ == "__main__":
    unittest.main()
