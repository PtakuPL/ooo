#!/usr/bin/env python3
"""
Buduje kolejkę tłumaczeń na podstawie braków względem EN.

Użycie:
  python tools/build_translation_queue.py --langs pl de es pt fr it ru \
    --out i18n/translation_queue.json
"""
import argparse
import json
import os
from pathlib import Path
from typing import Dict, List


def load_json(path: Path) -> Dict:
    if not path.exists():
        return {}
    try:
        with path.open(encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {}


def is_placeholder(val: str, lang: str) -> bool:
    return isinstance(val, str) and val.strip().startswith(f"[{lang.upper()}]")


def build_queue(i18n_dir: Path, langs: List[str]) -> List[Dict]:
    queue = []
    en_files = sorted((i18n_dir / "en").glob("*.json"))
    for en_file in en_files:
        en_data = load_json(en_file)
        cat = en_file.stem  # npc, scripts, monsters...
        for lang in langs:
            lang_file = i18n_dir / lang / en_file.name
            lang_data = load_json(lang_file)
            for key, src in en_data.items():
                tgt = lang_data.get(key)
                if tgt is None or is_placeholder(tgt, lang):
                    queue.append(
                        {
                            "lang": lang,
                            "category": cat,
                            "key": key,
                            "source": src,
                            "status": "pending",
                        }
                    )
    return queue


def main():
    parser = argparse.ArgumentParser(description="Buduj translation_queue.json")
    parser.add_argument("--langs", nargs="+", required=True, help="Lista języków")
    parser.add_argument("--out", required=True, help="Ścieżka wyjściowa")
    parser.add_argument("--i18ndir", default="i18n", help="Katalog z i18n/")
    args = parser.parse_args()

    i18n_dir = Path(args.i18ndir)
    queue = build_queue(i18n_dir, args.langs)
    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", encoding="utf-8") as f:
        json.dump(queue, f, indent=2, ensure_ascii=False)
    print(f"Zapisano kolejkę: {len(queue)} wpisów -> {out_path}")


if __name__ == "__main__":
    main()
