#!/usr/bin/env python3
import argparse
import json
import random
import re
from pathlib import Path
from datetime import datetime, timezone
from difflib import SequenceMatcher


def read_json(path: Path):
    try:
        with path.open("r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {}


def normalize_text(text: str):
    txt = str(text or "")
    txt = re.sub(r"\{[^}]*\}", " ", txt)
    txt = re.sub(r"\|[^|]+\|", " ", txt)
    txt = re.sub(r"''[^']+?''", " ", txt)
    txt = re.sub(r"\s+", " ", txt).strip().lower()
    return txt


def similarity(a: str, b: str) -> float:
    return SequenceMatcher(None, normalize_text(a), normalize_text(b)).ratio()


def main():
    parser = argparse.ArgumentParser(description="Language quality spotcheck using back-translation similarity.")
    parser.add_argument("--i18n-dir", default="i18n")
    parser.add_argument("--lang", required=True)
    parser.add_argument("--sample", type=int, default=20)
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--min-sim", type=float, default=0.45)
    parser.add_argument("--out", default="")
    args = parser.parse_args()

    i18n_dir = Path(args.i18n_dir)
    en_dir = i18n_dir / "en"
    lang_dir = i18n_dir / args.lang
    if not en_dir.exists() or not lang_dir.exists():
        print("SPOTCHECK_ERROR=missing_lang_or_en")
        raise SystemExit(1)

    items = []
    for en_file in sorted(en_dir.glob("*.json")):
        lang_file = lang_dir / en_file.name
        if not lang_file.exists():
            continue
        en_data = read_json(en_file)
        lang_data = read_json(lang_file)
        if not isinstance(en_data, dict) or not isinstance(lang_data, dict):
            continue
        for key, en_val in en_data.items():
            tr_val = lang_data.get(key)
            if tr_val is None:
                continue
            en_text = str(en_val or "").strip()
            tr_text = str(tr_val or "").strip()
            if not en_text or not tr_text:
                continue
            if tr_text == en_text:
                continue
            if tr_text.startswith("[") and "]" in tr_text[:8]:
                continue
            items.append((en_file.name, key, en_text, tr_text))

    if not items:
        print("SPOTCHECK_ERROR=no_candidates")
        raise SystemExit(1)

    random.seed(args.seed)
    sample = random.sample(items, min(args.sample, len(items)))

    translator = None
    try:
        from deep_translator import GoogleTranslator
        src_lang = args.lang.replace("_", "-").lower()
        if src_lang == "he":
            src_lang = "iw"
        if src_lang == "zh-tw":
            src_lang = "zh-TW"
        translator = GoogleTranslator(source=src_lang, target="en")
    except Exception:
        translator = None

    results = []
    low = 0
    errors = 0

    for json_file, key, en_text, tr_text in sample:
        back = ""
        sim = 0.0
        if translator is None:
            errors += 1
        else:
            try:
                back = str(translator.translate(tr_text) or "")
                sim = similarity(en_text, back)
                if sim < args.min_sim:
                    low += 1
            except Exception:
                errors += 1
        results.append(
            {
                "json": json_file,
                "key": key,
                "en": en_text,
                "lang": tr_text,
                "back_en": back,
                "similarity": round(sim, 3),
            }
        )

    payload = {
        "lang": args.lang,
        "checked_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "sample_size": len(sample),
        "min_similarity": args.min_sim,
        "low_similarity_count": low,
        "translator_errors": errors,
        "results": sorted(results, key=lambda r: r.get("similarity", 0.0))[:50],
    }

    out_path = Path(args.out) if args.out else (i18n_dir / "status" / "validation" / f"{args.lang}_spotcheck.json")
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)

    print(f"SPOTCHECK_LANG={args.lang}")
    print(f"SPOTCHECK_SAMPLE={len(sample)}")
    print(f"SPOTCHECK_LOW_SIM={low}")
    print(f"SPOTCHECK_ERRORS={errors}")
    print(f"SPOTCHECK_REPORT={out_path}")


if __name__ == "__main__":
    main()
