#!/usr/bin/env python3
import argparse
import json
import re
from pathlib import Path
from datetime import datetime, timezone


PH_RE = re.compile(r"\{[^}]*\}")
PIPE_RE = re.compile(r"\|[^|]+\|")
CMD_RE = re.compile(r"''[^']+?''")
ARTIFACT_RE = re.compile(r"\?\?\?|\[[A-Z]{2,}(?:[-_][A-Z]{2,})?\]|TODO|FIXME")


def map_gt_target(lang_code: str) -> str:
    norm = str(lang_code or "").replace("_", "-").lower()
    if norm == "he":
        return "iw"
    if norm == "zh-tw":
        return "zh-TW"
    if norm == "zh-cn":
        return "zh-CN"
    return norm


def likely_proper_noun(key: str, en_value: str) -> bool:
    prefixes = ("item.", "monster.", "spell.", "mount.", "quest.", "raid.", "achievement.")
    suffixes = (".name", ".words", ".title")
    if any(key.startswith(p) for p in prefixes) and any(key.endswith(s) for s in suffixes):
        return True
    text = str(en_value or "").strip()
    if len(text) <= 3:
        return True
    if text and all(c.isupper() or c.isdigit() or c in ".-_/ " for c in text):
        return True
    return False


def token_protect(text: str):
    src = str(text or "")
    mapping = {}
    idx = 0

    def repl(match):
        nonlocal idx
        token = f"__I18N_TK_{idx}__"
        idx += 1
        mapping[token] = match.group(0)
        return token

    for pattern in (PH_RE, PIPE_RE, CMD_RE):
        src = pattern.sub(repl, src)
    return src, mapping


def token_restore(text: str, mapping: dict):
    out = str(text or "")
    for token, value in mapping.items():
        out = out.replace(token, value)
    return out


def validate_candidate(en_text: str, translated: str) -> bool:
    en = str(en_text or "")
    tr = str(translated or "")
    if not tr.strip():
        return False
    if tr.strip() == en.strip():
        return False
    if set(PH_RE.findall(en)) != set(PH_RE.findall(tr)):
        return False
    if set(PIPE_RE.findall(en)) != set(PIPE_RE.findall(tr)):
        return False
    en_cmd = set(CMD_RE.findall(en))
    if en_cmd and en_cmd != set(CMD_RE.findall(tr)):
        return False
    if ARTIFACT_RE.search(tr):
        return False
    return True


def main():
    parser = argparse.ArgumentParser(description="Refine grammar/quality for one language JSON file.")
    parser.add_argument("--i18n-dir", default="i18n")
    parser.add_argument("--lang", required=True)
    parser.add_argument("--json", default="npc.json")
    parser.add_argument("--limit", type=int, default=20)
    parser.add_argument("--use-gt", action="store_true")
    parser.add_argument("--report", default="")
    args = parser.parse_args()

    i18n_dir = Path(args.i18n_dir)
    en_path = i18n_dir / "en" / args.json
    lang_path = i18n_dir / args.lang / args.json

    if not en_path.exists():
        print("GRAMMARFIX_ERROR=missing_en_file")
        raise SystemExit(1)
    if not lang_path.exists():
        print("GRAMMARFIX_ERROR=missing_lang_file")
        raise SystemExit(1)

    with en_path.open("r", encoding="utf-8") as f:
        en_data = json.load(f)
    with lang_path.open("r", encoding="utf-8") as f:
        lang_data = json.load(f)

    if not isinstance(en_data, dict) or not isinstance(lang_data, dict):
        print("GRAMMARFIX_ERROR=invalid_json")
        raise SystemExit(1)

    candidates = []
    for key, en_val in en_data.items():
        tr_val = lang_data.get(key)
        if tr_val is None:
            continue
        en_text = str(en_val or "")
        tr_text = str(tr_val or "")

        if likely_proper_noun(key, en_text):
            continue

        if tr_text == en_text:
            candidates.append((key, en_text, tr_text, "identical_to_en"))
            continue

        if ARTIFACT_RE.search(tr_text):
            candidates.append((key, en_text, tr_text, "artifact"))
            continue

    limit = max(1, min(int(args.limit or 20), 200))
    candidates = candidates[:limit]

    attempted = 0
    fixed = 0
    skipped_guard = 0
    errors = 0
    details = []

    if not args.use_gt:
        print("GRAMMARFIX_INFO=use_gt_disabled")
    translator = None
    if args.use_gt:
        try:
            from deep_translator import GoogleTranslator
            translator = GoogleTranslator(source="en", target=map_gt_target(args.lang))
        except Exception:
            translator = None
            errors += len(candidates)

    for key, en_text, old_text, reason in candidates:
        attempted += 1
        new_text = ""

        if translator is None:
            details.append({
                "key": key,
                "reason": reason,
                "status": "skipped_no_translator",
            })
            continue

        protected, mapping = token_protect(en_text)
        try:
            tr_raw = translator.translate(protected)
            new_text = token_restore(str(tr_raw or ""), mapping).strip()
        except Exception:
            errors += 1
            details.append({
                "key": key,
                "reason": reason,
                "status": "translate_error",
            })
            continue

        if not validate_candidate(en_text, new_text):
            skipped_guard += 1
            details.append({
                "key": key,
                "reason": reason,
                "status": "skipped_guard",
                "old": old_text,
                "new": new_text,
            })
            continue

        lang_data[key] = new_text
        fixed += 1
        details.append({
            "key": key,
            "reason": reason,
            "status": "fixed",
            "old": old_text,
            "new": new_text,
        })

    if fixed > 0:
        tmp = lang_path.with_suffix(lang_path.suffix + ".tmp")
        with tmp.open("w", encoding="utf-8") as f:
            json.dump(lang_data, f, indent=2, ensure_ascii=False)
        tmp.replace(lang_path)

    report_path = Path(args.report) if args.report else (i18n_dir / "status" / "validation" / f"{args.lang}_{args.json.replace('.json','')}_grammarfix.json")
    report_path.parent.mkdir(parents=True, exist_ok=True)

    report = {
        "lang": args.lang,
        "json_file": args.json,
        "checked_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "candidates": len(candidates),
        "attempted": attempted,
        "fixed": fixed,
        "skipped_guard": skipped_guard,
        "errors": errors,
        "details": details[:200],
    }
    with report_path.open("w", encoding="utf-8") as f:
        json.dump(report, f, indent=2, ensure_ascii=False)

    print(f"GRAMMARFIX_LANG={args.lang}")
    print(f"GRAMMARFIX_JSON={args.json}")
    print(f"GRAMMARFIX_ATTEMPTED={attempted}")
    print(f"GRAMMARFIX_FIXED={fixed}")
    print(f"GRAMMARFIX_SKIPPED_GUARD={skipped_guard}")
    print(f"GRAMMARFIX_ERRORS={errors}")
    print(f"GRAMMARFIX_REPORT={report_path}")


if __name__ == "__main__":
    main()
