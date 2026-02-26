#!/usr/bin/env python3
"""Show wrong pure template keys - what got broken"""
import json, re, sys, os

os.chdir(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

with open("i18n/en/html.json") as f:
    en = json.load(f)

# Find pure template keys
pure_keys = {}
for k, v in en.items():
    val = str(v)
    if "{{" not in val and "{%" not in val:
        continue
    stripped = re.sub(r"\{\{.*?\}\}", "", val)
    stripped = re.sub(r"\{%.*?%\}", "", stripped)
    if len(stripped.strip()) < 3:
        pure_keys[k] = val

# Show wrong translations
for lang in ["pl", "de"]:
    with open(f"i18n/{lang}/html.json") as f:
        tr = json.load(f)
    print(f"=== {lang.upper()} - WRONG pure template translations ===")
    count = 0
    for k in sorted(pure_keys):
        en_val = en[k]
        tr_val = tr.get(k, "MISSING")
        if tr_val != en_val:
            count += 1
            if count <= 20:
                print(f"  {k}:")
                print(f"    EN: {en_val[:100]}")
                print(f"    {lang.upper()}: {tr_val[:100]}")
    print(f"  Total WRONG: {count}\n")
