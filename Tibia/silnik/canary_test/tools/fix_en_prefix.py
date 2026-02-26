#!/usr/bin/env python3
"""Fix [EN] prefix on pure template keys across all languages.
These keys should have the exact EN value without any prefix."""
import json, re, os

os.chdir(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

with open("i18n/en/html.json") as f:
    en = json.load(f)

# Find pure template keys (no translatable text)
pure_keys = set()
for k, v in en.items():
    val = str(v)
    if "{{" not in val and "{%" not in val:
        continue
    stripped = re.sub(r"\{\{.*?\}\}", "", val)
    stripped = re.sub(r"\{%.*?%\}", "", stripped)
    if len(stripped.strip()) < 3:
        pure_keys.add(k)

print(f"Pure template keys: {len(pure_keys)}")

# Also check ALL json files for [EN] prefix on nontranslatable content
langs = ["pl", "es", "de", "fr", "ru", "it", "pt", "nl", "cs", "ro", "tr"]
total_fixed = 0

for lang in langs:
    lang_dir = f"i18n/{lang}"
    if not os.path.isdir(lang_dir):
        continue
    
    for fname in sorted(os.listdir(lang_dir)):
        if not fname.endswith(".json"):
            continue
        fpath = os.path.join(lang_dir, fname)
        
        with open(fpath) as f:
            data = json.load(f)
        
        en_fpath = os.path.join("i18n/en", fname)
        if not os.path.exists(en_fpath):
            continue
        with open(en_fpath) as f:
            en_data = json.load(f)
        
        changed = 0
        for k, v in data.items():
            if not isinstance(v, str):
                continue
            en_val = en_data.get(k)
            if en_val is None:
                continue
            
            # Check for [EN] prefix
            if v == f"[EN] {en_val}":
                data[k] = en_val
                changed += 1
            # Check for [LANG] prefix (shouldn't exist after yesterday's fix, but just in case)
            elif v == f"[{lang.upper()}] {en_val}":
                data[k] = en_val
                changed += 1
        
        if changed > 0:
            with open(fpath, "w") as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
                f.write("\n")
            print(f"  {lang}/{fname}: fixed {changed} keys")
            total_fixed += changed

print(f"\nTotal fixed: {total_fixed}")
