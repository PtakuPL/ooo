#!/usr/bin/env python3
"""
I18N Translation Tool - przygotowuje klucze do tłumaczenia przez agenta AI.

Użycie:
    python3 tools/i18n_translate.py --category npc --target pl --batch 50
    python3 tools/i18n_translate.py --category npc --target pl,es,de --batch 100
    python3 tools/i18n_translate.py --apply translations_batch.json

Workflow:
1. Skrypt generuje plik z kluczami do tłumaczenia
2. Agent AI tłumaczy i zwraca JSON
3. Skrypt aplikuje tłumaczenia do plików i18n
"""

import json
import os
import sys
import argparse
import re
from pathlib import Path
from datetime import datetime

I18N_DIR = Path("i18n")
BATCH_DIR = Path("i18n/translation_batches")
SOUND_TEXT_RE = re.compile(
    r'^(grr|hiss|rawr|roar|growl|snarl|howl|woof|arf|meow|miau|moo|baa|oink|snort|chirp|tweet|croak|ribbit)$',
    re.IGNORECASE,
)


def is_non_translatable_sound(text: str) -> bool:
    """Heurystyka: odgłosy potworów/zwierząt pomijamy w normalnym tłumaczeniu."""
    normalized = re.sub(r"[^a-zA-Z]", "", str(text or "")).lower()
    if not normalized:
        return False
    if SOUND_TEXT_RE.fullmatch(normalized):
        return True
    # 5+ znaków, <=3 unikalne litery i potrójne powtórzenia zwykle oznaczają odgłos (np. "grrrraaa")
    if len(normalized) >= 5 and len(set(normalized)) <= 3 and re.search(r'(.)\1{2,}', normalized):
        return True
    vowels = sum(1 for ch in normalized if ch in "aeiouy")
    if vowels == 0 and len(normalized) >= 3:
        return True
    return False

def get_untranslated_keys(category: str, target_lang: str, limit: int = 50) -> list:
    """Znajdź klucze które nie mają tłumaczenia w danym języku."""
    
    en_file = I18N_DIR / "en" / f"{category}.json"
    target_file = I18N_DIR / target_lang / f"{category}.json"
    
    if not en_file.exists():
        print(f"❌ Brak pliku: {en_file}")
        return []
    
    with open(en_file, 'r', encoding='utf-8') as f:
        en_data = json.load(f)
    
    # Wczytaj istniejące tłumaczenia
    target_data = {}
    if target_file.exists():
        with open(target_file, 'r', encoding='utf-8') as f:
            target_data = json.load(f)
    
    # Znajdź nieprzetłumaczone
    untranslated = []
    for key, en_text in en_data.items():
        # Pomiń jeśli już przetłumaczone (i różne od EN)
        if key in target_data:
            target_text = target_data[key]
            if target_text and target_text.strip() and target_text != en_text:
                continue
        
        # Pomiń odgłosy potworów/zwierząt - nie są normalnie tłumaczone
        if is_non_translatable_sound(en_text):
            continue
        # Dopuszczamy krótsze frazy (3-4 znaki), bo część z nich jest tłumaczalna ("yes", "run")
        # i wcześniej nie trafiała do batcha.
        if len(en_text) < 3:
            continue
            
        untranslated.append({
            "key": key,
            "en": en_text
        })
        
        if len(untranslated) >= limit:
            break
    
    return untranslated


def _collect_rejected_keys(target_lang: str, validation_dir: Path) -> list:
    """Collect keys rejected by the automatic worker from validation reports."""
    keys = []
    report_path = validation_dir / f"{target_lang}_report.json"
    if report_path.exists():
        try:
            report_data = json.loads(report_path.read_text(encoding="utf-8"))
            for item in report_data.get("worst_keys", []):
                key = item.get("key")
                if key:
                    keys.append({"key": key, "issue_type": item.get("type", "report_issue")})
        except Exception:
            pass

    for gf_path in validation_dir.glob(f"{target_lang}_*_grammarfix.json"):
        try:
            gf_data = json.loads(gf_path.read_text(encoding="utf-8"))
            for item in gf_data.get("details", []):
                if item.get("status") in {"skipped_guard", "translate_error", "skipped_no_translator"} and item.get("key"):
                    keys.append({"key": item["key"], "issue_type": item.get("status", "grammarfix_issue")})
        except Exception:
            continue
    return keys


def generate_rejected_batch(targets: list, batch_size: int, validation_dir: Path) -> dict:
    """Generate a batch from worker-rejected entries for manual translation."""
    BATCH_DIR.mkdir(parents=True, exist_ok=True)
    batch = {
        "generated": datetime.now().isoformat(),
        "category": "rejected_by_worker",
        "target_languages": targets,
        "batch_size": batch_size,
        "keys": [],
        "instructions": f"Translate worker-rejected entries into: {', '.join(targets)}. Keep placeholders and tokens unchanged.",
    }

    en_cache = {}
    keys_map = {}
    for lang in targets:
        for item in _collect_rejected_keys(lang, validation_dir):
            key = item["key"]
            category = key.split(".")[0]
            if category not in en_cache:
                en_file = I18N_DIR / "en" / f"{category}.json"
                if en_file.exists():
                    try:
                        en_cache[category] = json.loads(en_file.read_text(encoding="utf-8"))
                    except Exception:
                        en_cache[category] = {}
                else:
                    en_cache[category] = {}
            en_text = str(en_cache[category].get(key, "") or "")
            if not en_text:
                continue
            entry = keys_map.setdefault(
                key,
                {"key": key, "en": en_text, "missing_in": [], "source": "worker_rejected", "issues": []},
            )
            if lang not in entry["missing_in"]:
                entry["missing_in"].append(lang)
            issue = item.get("issue_type", "worker_rejected")
            if issue not in entry["issues"]:
                entry["issues"].append(issue)

    batch["keys"] = list(keys_map.values())[:batch_size]
    batch["total_keys"] = len(batch["keys"])

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    batch_file = BATCH_DIR / f"batch_rejected_{timestamp}.json"
    with open(batch_file, "w", encoding="utf-8") as f:
        json.dump(batch, f, indent=2, ensure_ascii=False)
    print(f"✅ Rejected batch generated: {batch_file}")
    print(f"📊 Keys for manual translation: {batch['total_keys']}")
    return batch


def generate_batch(category: str, targets: list, batch_size: int) -> dict:
    """Generuj batch do tłumaczenia."""
    
    BATCH_DIR.mkdir(parents=True, exist_ok=True)
    
    batch = {
        "generated": datetime.now().isoformat(),
        "category": category,
        "target_languages": targets,
        "batch_size": batch_size,
        "keys": [],
        "instructions": f"""
=== INSTRUKCJE DLA AGENTA AI ===

Przetłumacz poniższe klucze z angielskiego na: {', '.join(targets)}

ZASADY:
1. Zachowaj zmienne w klamrach: {{name}}, {{count}}, {{item}}
2. Zachowaj formatowanie: |PLAYERNAME|, {{trade}}, itp.
3. Dla gier RPG użyj klimatycznego języka fantasy
4. Nie tłumacz nazw własnych (Thais, Carlin, Tibia)
5. Komendy gry (trade, buy, sell) zostaw po angielsku

FORMAT ODPOWIEDZI (JSON):
{{
    "translations": {{
        "klucz1": {{"pl": "tłumaczenie PL", "es": "tłumaczenie ES", ...}},
        "klucz2": {{"pl": "...", "es": "...", ...}}
    }}
}}
"""
    }
    
    # Zbierz klucze brakujące w dowolnym języku docelowym (np. PL i ES)
    keys_map = {}
    scan_limit = batch_size * len(targets)
    for lang in targets:
        for item in get_untranslated_keys(category, lang, scan_limit):
            entry = keys_map.setdefault(item["key"], {"key": item["key"], "en": item["en"], "missing_in": []})
            if lang not in entry["missing_in"]:
                entry["missing_in"].append(lang)
    keys = list(keys_map.values())[:batch_size]
    batch["keys"] = keys
    batch["total_keys"] = len(keys)
    
    # Zapisz batch
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    batch_file = BATCH_DIR / f"batch_{category}_{timestamp}.json"
    
    with open(batch_file, 'w', encoding='utf-8') as f:
        json.dump(batch, f, indent=2, ensure_ascii=False)
    
    print(f"✅ Batch wygenerowany: {batch_file}")
    print(f"📊 Kluczy do tłumaczenia: {len(keys)}")
    
    return batch


def apply_translations(translations_file: str) -> int:
    """Aplikuj tłumaczenia z pliku JSON."""
    
    with open(translations_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    translations = data.get("translations", {})
    category = data.get("category", "unknown")
    
    applied = 0
    
    for key, lang_translations in translations.items():
        for lang, text in lang_translations.items():
            if not text or not text.strip():
                continue
            
            # Znajdź kategorię z klucza jeśli nie podana
            if category == "unknown":
                parts = key.split(".")
                if len(parts) > 0:
                    category = parts[0]
            
            lang_file = I18N_DIR / lang / f"{category}.json"
            
            # Wczytaj istniejące
            lang_data = {}
            if lang_file.exists():
                with open(lang_file, 'r', encoding='utf-8') as f:
                    lang_data = json.load(f)
            
            # Dodaj tłumaczenie
            lang_data[key] = text
            
            # Zapisz
            lang_file.parent.mkdir(parents=True, exist_ok=True)
            with open(lang_file, 'w', encoding='utf-8') as f:
                json.dump(lang_data, f, indent=2, ensure_ascii=False)
            
            applied += 1
    
    print(f"✅ Zastosowano {applied} tłumaczeń")
    return applied


def show_sample(category: str, count: int = 10):
    """Pokaż przykładowe klucze do tłumaczenia."""
    
    keys = get_untranslated_keys(category, "pl", count)
    
    print(f"\n📝 Przykładowe klucze z kategorii '{category}' do tłumaczenia:\n")
    print("-" * 60)
    
    for item in keys:
        print(f"🔑 {item['key']}")
        print(f"   EN: {item['en'][:100]}{'...' if len(item['en']) > 100 else ''}")
        print()
    
    print("-" * 60)
    print(f"Łącznie nieprzetłumaczonych: {len(get_untranslated_keys(category, 'pl', 10000))}")


def main():
    parser = argparse.ArgumentParser(description="I18N Translation Tool")
    parser.add_argument("--category", default="npc", help="Kategoria do tłumaczenia")
    parser.add_argument("--target", default="pl", help="Języki docelowe (oddzielone przecinkiem)")
    parser.add_argument("--batch", type=int, default=50, help="Rozmiar batcha")
    parser.add_argument("--apply", help="Plik JSON z tłumaczeniami do zastosowania")
    parser.add_argument("--sample", action="store_true", help="Pokaż przykładowe klucze")
    parser.add_argument("--count", type=int, default=10, help="Ile przykładów pokazać")
    parser.add_argument("--rejected-only", action="store_true", help="Generuj batch tylko z wpisów odrzuconych przez worker")
    parser.add_argument("--validation-dir", default="i18n/status/validation", help="Katalog z raportami walidacji")
    
    args = parser.parse_args()
    
    if args.apply:
        apply_translations(args.apply)
    elif args.sample:
        show_sample(args.category, args.count)
    elif args.rejected_only:
        targets = [t.strip() for t in args.target.split(",") if t.strip()]
        generate_rejected_batch(targets, args.batch, Path(args.validation_dir))
    else:
        targets = [t.strip() for t in args.target.split(",")]
        generate_batch(args.category, targets, args.batch)


if __name__ == "__main__":
    main()
