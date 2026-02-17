#!/usr/bin/env python3
"""
Batch translate missing/EN-copy keys across all languages.
Uses deep_translator (GoogleTranslator) with rate limiting and placeholder preservation.
"""
import json, os, glob, re, time, sys

# ------- CONFIG -------
I18N_DIR = os.path.join(os.path.dirname(__file__), '..', 'i18n')
WHITELIST_PATH = os.path.join(I18N_DIR, 'untranslatable_keys.json')
BATCH_SIZE = 15           # keys per GT batch call
SLEEP_BETWEEN = 0.5       # seconds between batches
MAX_RETRIES = 3
OVERRIDES_DIR = os.path.join(I18N_DIR, 'overrides')

# Language code mapping (our code -> deep_translator code)
LANG_MAP = {
    'zh_TW': 'zh-TW', 'zh': 'zh-CN', 'he': 'iw',
}

# ------- PLACEHOLDER PRESERVATION -------
_PH_RE = re.compile(r'(\{[^}]*\}|%[sdifx%]|%\d+\$[sdifx]|\{\{[^}]+\}\}|<[^>]+>|\[[^\]]*\]|#\w+)')

def _extract_placeholders(text):
    return _PH_RE.findall(text)

def _validate_placeholders(en_text, translated):
    en_ph = sorted(_extract_placeholders(en_text))
    tr_ph = sorted(_extract_placeholders(translated))
    return en_ph == tr_ph

def _fix_placeholder_mismatch(en_text, translated):
    """Try to fix simple placeholder mismatches"""
    en_ph = _extract_placeholders(en_text)
    tr_ph = _extract_placeholders(translated)
    if set(en_ph) == set(tr_ph):
        return translated  # same set, just different order - OK
    missing = [p for p in en_ph if p not in tr_ph]
    if missing:
        return None
    return translated

# ------- MAIN -------
def load_whitelist():
    with open(WHITELIST_PATH) as f:
        return json.load(f)

def load_overrides():
    overrides = {}
    if os.path.isdir(OVERRIDES_DIR):
        for of in glob.glob(os.path.join(OVERRIDES_DIR, '*.json')):
            lang = os.path.basename(of).replace('.json', '')
            with open(of) as f:
                overrides[lang] = json.load(f)
    return overrides

def get_gt_lang_code(lang):
    return LANG_MAP.get(lang, lang)

def batch_translate(texts, dest_lang):
    from deep_translator import GoogleTranslator
    gt_code = get_gt_lang_code(dest_lang)
    translator = GoogleTranslator(source='en', target=gt_code)
    results = []
    
    for i in range(0, len(texts), BATCH_SIZE):
        batch = texts[i:i+BATCH_SIZE]
        for retry in range(MAX_RETRIES):
            try:
                batch_results = translator.translate_batch(batch)
                results.extend(batch_results)
                break
            except Exception as e:
                if retry < MAX_RETRIES - 1:
                    wait = (retry + 1) * 5
                    print(f"  GT error (retry {retry+1}): {e}, waiting {wait}s...", flush=True)
                    time.sleep(wait)
                    translator = GoogleTranslator(source='en', target=gt_code)
                else:
                    print(f"  GT FAILED after {MAX_RETRIES} retries: {e}", flush=True)
                    results.extend([""] * len(batch))
        
        if i + BATCH_SIZE < len(texts):
            time.sleep(SLEEP_BETWEEN)
    
    return results

def translate_language(lang, en_data_cache, whitelist, overrides, dry_run=False):
    """Translate all gaps for a single language. Returns count of translations."""
    lang_overrides = overrides.get(lang, {})
    gt_code = get_gt_lang_code(lang)
    
    # Collect gaps
    gaps = []  # (file, key, en_text)
    for base, en in en_data_cache.items():
        lang_file = os.path.join(I18N_DIR, lang, base)
        if os.path.exists(lang_file):
            with open(lang_file) as f:
                ld = json.load(f)
        else:
            ld = {}
        
        for k, v in en.items():
            if k in whitelist:
                continue
            if k in lang_overrides:
                continue  # has manual override
            lv = ld.get(k, '')
            if not lv or lv == v:  # missing or EN-copy
                gaps.append((base, k, v))
    
    if not gaps:
        return 0
    
    print(f"\n{'='*60}")
    print(f"  {lang}: {len(gaps)} keys to translate")
    print(f"{'='*60}")
    
    if dry_run:
        return len(gaps)
    
    # Get unique EN texts to translate
    unique_texts = list(set(g[2] for g in gaps))
    print(f"  Unique EN texts: {len(unique_texts)}")
    
    # Translate
    translated_map = {}
    print(f"  Translating {len(unique_texts)} texts to {gt_code}...")
    results = batch_translate(unique_texts, lang)
    
    for en_text, tr_text in zip(unique_texts, results):
        if tr_text and tr_text.strip():
            # Validate placeholders
            if _validate_placeholders(en_text, tr_text):
                translated_map[en_text] = tr_text
            else:
                fixed = _fix_placeholder_mismatch(en_text, tr_text)
                if fixed:
                    translated_map[en_text] = fixed
                else:
                    # Placeholder mismatch, skip
                    pass
    
    print(f"  Valid translations: {len(translated_map)}/{len(unique_texts)}")
    
    # Apply to files
    files_to_update = {}
    applied = 0
    for base, k, en_text in gaps:
        if en_text in translated_map:
            tr = translated_map[en_text]
            # Skip if translation is identical to EN (GT returned same text)
            if tr.strip().lower() == en_text.strip().lower():
                continue
            if base not in files_to_update:
                files_to_update[base] = {}
            files_to_update[base][k] = tr
            applied += 1
    
    # Write back
    for base, new_translations in files_to_update.items():
        lang_file = os.path.join(I18N_DIR, lang, base)
        if os.path.exists(lang_file):
            with open(lang_file) as f:
                ld = json.load(f)
        else:
            os.makedirs(os.path.dirname(lang_file), exist_ok=True)
            ld = {}
        
        ld.update(new_translations)
        
        # Sort keys to match EN order
        en_keys = list(en_data_cache[base].keys())
        sorted_ld = {}
        for ek in en_keys:
            if ek in ld:
                sorted_ld[ek] = ld[ek]
        # Add any extra keys not in EN
        for ek in ld:
            if ek not in sorted_ld:
                sorted_ld[ek] = ld[ek]
        
        with open(lang_file, 'w', encoding='utf-8') as f:
            json.dump(sorted_ld, f, indent=2, ensure_ascii=False)
    
    print(f"  Applied: {applied} translations to {len(files_to_update)} files")
    return applied


def main():
    import argparse
    parser = argparse.ArgumentParser(description='Batch translate i18n gaps')
    parser.add_argument('--langs', nargs='*', help='Languages to process (default: all)')
    parser.add_argument('--dry-run', action='store_true', help='Count gaps only')
    parser.add_argument('--max-per-lang', type=int, default=0, help='Max keys per language')
    args = parser.parse_args()
    
    print("Loading whitelist...")
    whitelist = load_whitelist()
    print(f"  {len(whitelist)} untranslatable keys")
    
    print("Loading overrides...")
    overrides = load_overrides()
    for lang, ov in overrides.items():
        if ov:
            print(f"  {lang}: {len(ov)} overrides")
    
    print("Loading EN data...")
    en_data_cache = {}
    for f in sorted(glob.glob(os.path.join(I18N_DIR, 'en', '*.json'))):
        base = os.path.basename(f)
        with open(f) as fh:
            en_data_cache[base] = json.load(fh)
    print(f"  {sum(len(v) for v in en_data_cache.values())} total EN keys in {len(en_data_cache)} files")
    
    # Determine languages
    if args.langs:
        langs = args.langs
    else:
        langs = sorted([d for d in os.listdir(I18N_DIR) 
                       if os.path.isdir(os.path.join(I18N_DIR, d)) 
                       and d not in ('en', 'overrides', 'status', 'tm', 'logs', 'reports')])
    
    print(f"\nProcessing {len(langs)} languages...")
    
    total_applied = 0
    for lang in langs:
        n = translate_language(lang, en_data_cache, whitelist, overrides, args.dry_run)
        total_applied += n
    
    print(f"\n{'='*60}")
    print(f"TOTAL: {total_applied} translations applied")
    print(f"{'='*60}")


if __name__ == '__main__':
    main()
