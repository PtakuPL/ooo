#!/usr/bin/env python3
import argparse
import json
import re
import unicodedata
from pathlib import Path
from datetime import datetime, timezone

PH_RE = re.compile(r'\{[^}]*\}')
PIPE_RE = re.compile(r'\|[^|]+\|')
CMD_RE = re.compile(r"''[^']+?''")
ARTIFACT_RE = re.compile(r'\?\?\?|\[[A-Z]{2,}(?:[-_][A-Z]{2,})?\]|TODO|FIXME')


def map_gt_target(lang_code: str) -> str:
    norm = str(lang_code or '').replace('_', '-').lower()
    if norm == 'he':
        return 'iw'
    if norm == 'zh-tw':
        return 'zh-TW'
    if norm == 'zh-cn':
        return 'zh-CN'
    return norm


def token_protect(text: str):
    src = str(text or '')
    mapping = {}
    idx = 0

    def repl(match):
        nonlocal idx
        token = f"__I18N_TK_{idx}__"
        mapping[token] = match.group(0)
        idx += 1
        return token

    for pattern in (PH_RE, PIPE_RE, CMD_RE):
        src = pattern.sub(repl, src)
    return src, mapping


def token_restore(text: str, mapping: dict):
    out = str(text or '')
    for token, value in mapping.items():
        out = out.replace(token, value)
    return out


def has_cyrillic_latin_mix(text: str) -> bool:
    clean = re.sub(r'[{}\d|%\s]', '', str(text or ''))
    if len(clean) <= 5:
        return False
    latin_c = sum(1 for c in clean if c.isalpha() and ord(c) < 0x0400)
    total_a = sum(1 for c in clean if c.isalpha())
    if total_a <= 3:
        return False
    return (latin_c / total_a) > 0.3


def validate_candidate(en_text: str, translated: str) -> bool:
    en = str(en_text or '')
    tr = str(translated or '')
    if not tr.strip():
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


def fix_for_lang(i18n_dir: Path, lang: str, include_empty: bool, limit: int):
    en_dir = i18n_dir / 'en'
    lang_dir = i18n_dir / lang
    if not en_dir.exists() or not lang_dir.exists():
        raise SystemExit(f"Missing directory: {en_dir} or {lang_dir}")

    try:
        from deep_translator import GoogleTranslator
    except Exception as ex:
        raise SystemExit(f"deep_translator missing: {ex}")

    translator = GoogleTranslator(source='en', target=map_gt_target(lang))

    all_candidates = []
    updated = 0
    skipped_guard = 0
    errors = 0
    files_touched = set()

    for en_file in sorted(en_dir.glob('*.json')):
        cat = en_file.name
        lang_file = lang_dir / cat
        if not lang_file.exists():
            continue

        try:
            en_data = json.loads(en_file.read_text(encoding='utf-8'))
            lang_data = json.loads(lang_file.read_text(encoding='utf-8'))
        except Exception:
            continue

        if not isinstance(en_data, dict) or not isinstance(lang_data, dict):
            continue

        file_candidates = []
        for key, en_val in en_data.items():
            if key not in lang_data:
                continue
            en_text = str(en_val or '')
            tr_text = str(lang_data.get(key, '') or '')

            if tr_text.startswith('[') and ']' in tr_text[:8]:
                continue

            need = False
            reason = []
            if include_empty and not tr_text.strip():
                need = True
                reason.append('empty')
            if set(PH_RE.findall(en_text)) != set(PH_RE.findall(tr_text)):
                need = True
                reason.append('placeholder')
            if set(PIPE_RE.findall(en_text)) != set(PIPE_RE.findall(tr_text)):
                need = True
                reason.append('pipe')
            en_cmd = set(CMD_RE.findall(en_text))
            if en_cmd and en_cmd != set(CMD_RE.findall(tr_text)):
                need = True
                reason.append('command')
            if ARTIFACT_RE.search(tr_text):
                need = True
                reason.append('artifact')
            if lang == 'ru' and has_cyrillic_latin_mix(tr_text):
                need = True
                reason.append('script_mix')

            if need:
                file_candidates.append({
                    'key': key,
                    'en': en_text,
                    'old': tr_text,
                    'reason': ','.join(reason),
                    'cat': cat,
                })

        if not file_candidates:
            continue

        for chunk_start in range(0, len(file_candidates), 30):
            if limit > 0 and len(all_candidates) >= limit:
                break
            chunk = file_candidates[chunk_start:chunk_start + 30]
            if limit > 0:
                left = max(0, limit - len(all_candidates))
                chunk = chunk[:left]
            if not chunk:
                continue

            protected = []
            maps = []
            for item in chunk:
                ptxt, pmap = token_protect(item['en'])
                protected.append(ptxt)
                maps.append(pmap)

            try:
                translated = translator.translate_batch(protected)
            except Exception:
                errors += len(chunk)
                continue

            if isinstance(translated, str):
                translated = [translated]
            if not isinstance(translated, list):
                translated = []
            while len(translated) < len(chunk):
                translated.append('')

            changed = False
            for item, tr_raw, pmap in zip(chunk, translated, maps):
                all_candidates.append(item)
                restored = token_restore(str(tr_raw or ''), pmap).strip()
                if not validate_candidate(item['en'], restored):
                    skipped_guard += 1
                    continue
                if restored == item['old']:
                    continue
                lang_data[item['key']] = restored
                updated += 1
                changed = True

            if changed:
                tmp = lang_file.with_suffix(lang_file.suffix + '.tmp')
                tmp.write_text(json.dumps(lang_data, indent=2, ensure_ascii=False), encoding='utf-8')
                tmp.replace(lang_file)
                files_touched.add(cat)

        if limit > 0 and len(all_candidates) >= limit:
            break

    report = {
        'lang': lang,
        'include_empty': include_empty,
        'limit': limit,
        'checked_candidates': len(all_candidates),
        'updated': updated,
        'skipped_guard': skipped_guard,
        'errors': errors,
        'files_touched': sorted(files_touched),
        'timestamp': datetime.now(timezone.utc).isoformat().replace('+00:00', 'Z')
    }

    out_dir = i18n_dir / 'status' / 'validation'
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / f'{lang}_autofix_report.json'
    out_path.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding='utf-8')

    print(f"AUTOFIX_LANG={lang}")
    print(f"AUTOFIX_CHECKED={report['checked_candidates']}")
    print(f"AUTOFIX_UPDATED={updated}")
    print(f"AUTOFIX_SKIPPED_GUARD={skipped_guard}")
    print(f"AUTOFIX_ERRORS={errors}")
    print(f"AUTOFIX_FILES={len(files_touched)}")
    print(f"AUTOFIX_REPORT={out_path}")


def main():
    parser = argparse.ArgumentParser(description='Auto-fix translation quality issues for one language.')
    parser.add_argument('--i18n-dir', default='i18n')
    parser.add_argument('--lang', required=True)
    parser.add_argument('--include-empty', action='store_true', help='Also fill empty translations')
    parser.add_argument('--limit', type=int, default=0, help='Max candidates to process (0 = unlimited)')
    args = parser.parse_args()

    fix_for_lang(Path(args.i18n_dir), args.lang, args.include_empty, args.limit)


if __name__ == '__main__':
    main()
