#!/usr/bin/env python3
import argparse
import json
import re
from pathlib import Path
from datetime import datetime


def read_json(path: Path):
    try:
        with path.open("r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {}


def list_lang_dirs(i18n_dir: Path):
    langs = []
    for child in sorted(i18n_dir.iterdir() if i18n_dir.exists() else []):
        if not child.is_dir():
            continue
        name = child.name
        if name == "en" or name.startswith(".") or name in {"status", "reports", "tools", "docs", "backup"}:
            continue
        if re.fullmatch(r"[a-z]{2}(?:_[A-Z]{2})?", name):
            langs.append(name)
    return langs


def main():
    parser = argparse.ArgumentParser(description="Prepare worker command queue for language-by-language testing.")
    parser.add_argument("--i18n-dir", default="i18n", help="Path to i18n directory")
    parser.add_argument("--summary", default="i18n/status/validation/summary.json", help="Validation summary.json path")
    parser.add_argument("--output", default="worker_commands.txt", help="Where to write queue commands")
    parser.add_argument("--mode", choices=["all", "not-ready"], default="not-ready", help="Select all languages or only not-ready from gates")
    parser.add_argument("--json", default="npc.json", help="JSON file to prioritize for SWITCH")
    parser.add_argument("--limit", type=int, default=1, help="Switch limit per cycle")
    parser.add_argument("--min-score", type=float, default=95.0)
    parser.add_argument("--max-critical", type=int, default=20)
    parser.add_argument("--max-high", type=int, default=500)
    parser.add_argument("--max-crossref", type=int, default=600)
    parser.add_argument("--spotcheck", type=int, default=20, help="Sample size for SPOTCHECK command")
    parser.add_argument("--clear", action="store_true", help="Overwrite output file instead of append")
    args = parser.parse_args()

    i18n_dir = Path(args.i18n_dir)
    summary_path = Path(args.summary)
    out_path = Path(args.output)

    langs = list_lang_dirs(i18n_dir)
    by_score = read_json(summary_path).get("by_score", {})

    def is_ready(lang):
        info = by_score.get(lang, {}) if isinstance(by_score, dict) else {}
        score = float(info.get("score", 0.0) or 0.0)
        critical = int(info.get("critical", 0) or 0)
        high = int(info.get("high", 0) or 0)
        crossref = int(info.get("crossref_issues", 0) or 0)
        return score >= args.min_score and critical <= args.max_critical and high <= args.max_high and crossref <= args.max_crossref

    if args.mode == "not-ready":
        selected = [lang for lang in langs if not is_ready(lang)]
    else:
        selected = langs

    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    lines = [
        f"# i18n queue generated {ts}",
        f"NOTE:LANG_QUEUE_START mode={args.mode} langs={len(selected)} json={args.json} limit={args.limit}",
    ]

    for lang in selected:
        lines.append(f"SWITCH:{lang}:{args.json}:{args.limit}")
        lines.append(f"LANGVAL:{lang}")
        lines.append(f"SPOTCHECK:{lang}:{max(5, args.spotcheck)}")

    lines.append("UNSWITCH")
    lines.append("LANGVAL:all")
    lines.append("NOTE:LANG_QUEUE_DONE")

    out_path.parent.mkdir(parents=True, exist_ok=True)
    mode = "w" if args.clear else "a"
    with out_path.open(mode, encoding="utf-8") as f:
        if mode == "a" and out_path.stat().st_size > 0:
            f.write("\n")
        for line in lines:
            f.write(line + "\n")

    print(f"QUEUE_FILE={out_path}")
    print(f"LANGS_SELECTED={len(selected)}")
    if selected:
        print("LANGS=" + ",".join(selected))


if __name__ == "__main__":
    main()
