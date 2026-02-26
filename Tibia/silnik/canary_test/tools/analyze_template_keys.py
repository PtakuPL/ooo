#!/usr/bin/env python3
"""Analyze template keys in html.json"""
import json, re, sys, os

os.chdir(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

with open("i18n/en/html.json") as f:
    en = json.load(f)

pure_count = 0
mixed_count = 0
pure_examples = []
mixed_examples = []

for k, v in sorted(en.items()):
    val = str(v)
    has_template = "{{" in val or "{%" in val
    if not has_template:
        continue
    stripped = re.sub(r"\{\{.*?\}\}", "", val)
    stripped = re.sub(r"\{%.*?%\}", "", stripped)
    stripped = stripped.strip()
    if len(stripped) < 3:
        pure_count += 1
        if len(pure_examples) < 15:
            pure_examples.append(f"  {k}: {val[:80]}")
    else:
        mixed_count += 1
        if len(mixed_examples) < 10:
            mixed_examples.append(f"  {k}: {val[:100]}")

print(f"PURE TEMPLATE (no translatable text): {pure_count}")
for ex in pure_examples:
    print(ex)
print(f"  ... and {pure_count - 15} more\n")
print(f"MIXED (template + translatable text): {mixed_count}")
for ex in mixed_examples:
    print(ex)
print(f"  ... and {mixed_count - 10} more\n")

# Check how many pure template keys are being "wasted" in translation cycles
print("=== IMPACT ON WORKER ===")
total_keys = len(en)
template_keys = pure_count + mixed_count 
non_template = total_keys - template_keys
print(f"Total html.json: {total_keys}")
print(f"Template keys (never need translation): {pure_count} ({pure_count*100//total_keys}%)")
print(f"Mixed keys (need careful translation): {mixed_count}")
print(f"Normal keys (full translation): {non_template}")

# Check across languages if pure template keys are properly = EN
print("\n=== PURE TEMPLATE KEY STATUS ACROSS LANGUAGES ===")
pure_keys = set()
for k, v in en.items():
    val = str(v)
    if "{{" not in val and "{%" not in val:
        continue
    stripped = re.sub(r"\{\{.*?\}\}", "", val)
    stripped = re.sub(r"\{%.*?%\}", "", stripped)
    if len(stripped.strip()) < 3:
        pure_keys.add(k)

for lang in ["pl", "es", "de", "fr", "ru", "it", "pt", "nl", "cs", "ro", "tr"]:
    try:
        with open(f"i18n/{lang}/html.json") as f:
            tr = json.load(f)
        wrong = 0
        missing = 0
        ok = 0
        for k in pure_keys:
            en_val = en[k]
            tr_val = tr.get(k)
            if tr_val is None:
                missing += 1
            elif tr_val != en_val:
                wrong += 1
            else:
                ok += 1
        status = "OK" if wrong == 0 and missing == 0 else f"WRONG={wrong} MISSING={missing}"
        print(f"  {lang}: ok={ok} {status}")
    except Exception as e:
        print(f"  {lang}: ERROR {e}")
