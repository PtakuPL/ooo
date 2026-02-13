#!/usr/bin/env python3
import argparse
import json
import os
import re
from collections import Counter, defaultdict
from datetime import datetime, timezone


def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def safe_load_json(path):
    try:
        return load_json(path)
    except Exception:
        return {}


def is_untranslated(value, en_value):
    if value is None:
        return True
    txt = str(value)
    if not txt.strip():
        return True
    if txt.startswith("["):
        return True
    if txt == str(en_value):
        return True
    return False


def tokenize_words(text):
    return re.findall(r"[^\W\d_]+(?:-[^\W\d_]+)?", text or "", flags=re.UNICODE)


def load_proper_nouns(status_dir):
    path = os.path.join(status_dir, "tibia_proper_nouns.json")
    data = safe_load_json(path)
    terms = data.get("terms", []) if isinstance(data, dict) else []
    result = set()
    for term in terms:
        if not isinstance(term, str):
            continue
        for tok in tokenize_words(term.lower()):
            result.add(tok)
    return result


def build_stopwords():
    return {
        "the", "a", "an", "and", "or", "to", "of", "in", "on", "for", "at", "by", "with", "as", "is", "are", "was", "were",
        "be", "been", "being", "it", "its", "this", "that", "these", "those", "you", "your", "yours", "me", "my", "mine", "we",
        "our", "ours", "they", "their", "them", "he", "his", "she", "her", "him", "i", "do", "does", "did", "done", "can",
        "could", "should", "would", "will", "shall", "may", "might", "must", "not", "no", "yes", "if", "then", "else", "than",
        "from", "into", "out", "up", "down", "over", "under", "again", "more", "most", "less", "least", "have", "has", "had",
        "here", "there", "what", "when", "where", "who", "whom", "why", "how", "which", "also", "just", "only", "very", "so",
    }


def analyze(i18n_dir, status_dir, top_phrases, top_words, min_pl_pair_count):
    en_dir = os.path.join(i18n_dir, "en")
    pl_dir = os.path.join(i18n_dir, "pl")

    categories = sorted([x for x in os.listdir(en_dir) if x.endswith(".json")])

    phrase_counter = Counter()
    phrase_examples = defaultdict(list)
    word_counter = Counter()

    pl_pair_counter = Counter()
    pl_pair_examples = defaultdict(list)

    stopwords = build_stopwords()
    proper_nouns = load_proper_nouns(status_dir)

    total_keys = 0

    for fname in categories:
        en_path = os.path.join(en_dir, fname)
        en_data = safe_load_json(en_path)
        if not isinstance(en_data, dict):
            continue

        pl_path = os.path.join(pl_dir, fname)
        pl_data = safe_load_json(pl_path)
        if not isinstance(pl_data, dict):
            pl_data = {}

        for key, en_val in en_data.items():
            en_text = str(en_val or "").strip()
            if not en_text:
                continue
            total_keys += 1

            phrase_counter[en_text] += 1
            if len(phrase_examples[en_text]) < 5:
                phrase_examples[en_text].append(f"{fname}:{key}")

            for token in tokenize_words(en_text.lower()):
                if len(token) < 3:
                    continue
                if token in stopwords:
                    continue
                if token in proper_nouns:
                    continue
                word_counter[token] += 1

            pl_text = pl_data.get(key)
            if is_untranslated(pl_text, en_text):
                continue

            pair = (en_text, str(pl_text).strip())
            pl_pair_counter[pair] += 1
            if len(pl_pair_examples[pair]) < 5:
                pl_pair_examples[pair].append(f"{fname}:{key}")

    top_phrases_rows = []
    for text, count in phrase_counter.most_common(top_phrases):
        top_phrases_rows.append({
            "en": text,
            "count": int(count),
            "examples": phrase_examples[text],
        })

    pl_pairs_rows = []
    for (en_text, pl_text), count in pl_pair_counter.most_common():
        if count < min_pl_pair_count:
            continue
        pl_pairs_rows.append({
            "en": en_text,
            "pl": pl_text,
            "count": int(count),
            "examples": pl_pair_examples[(en_text, pl_text)],
        })

    top_words_rows = []
    for word, count in word_counter.most_common(top_words):
        top_words_rows.append({"word": word, "count": int(count)})

    ts = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

    phrases_payload = {
        "timestamp": ts,
        "source": "i18n/en/*.json",
        "total_keys_scanned": int(total_keys),
        "top_n": int(top_phrases),
        "phrases": top_phrases_rows,
    }

    pl_pairs_payload = {
        "timestamp": ts,
        "source": "i18n/en + i18n/pl",
        "min_count": int(min_pl_pair_count),
        "pairs": pl_pairs_rows,
    }

    words_payload = {
        "timestamp": ts,
        "source": "i18n/en/*.json",
        "top_n": int(top_words),
        "stopwords_count": len(stopwords),
        "proper_nouns_filtered_count": len(proper_nouns),
        "words": top_words_rows,
    }

    existing_word_translations = safe_load_json(os.path.join(status_dir, "word_translations.json"))
    existing_pl_words = set()
    if isinstance(existing_word_translations.get("pl", {}), dict):
        existing_pl_words = set(str(k).lower() for k in existing_word_translations.get("pl", {}).keys())

    pl_word_candidates = []
    for row in top_words_rows:
        w = str(row.get("word", "")).lower()
        if not w:
            continue
        if w in existing_pl_words:
            continue
        pl_word_candidates.append({
            "word": w,
            "count": int(row.get("count", 0) or 0),
        })
        if len(pl_word_candidates) >= 350:
            break

    pl_candidates_payload = {
        "timestamp": ts,
        "target_lang": "pl",
        "limit": 350,
        "candidates": pl_word_candidates,
    }

    os.makedirs(status_dir, exist_ok=True)
    with open(os.path.join(status_dir, "top_phrases_en.json"), "w", encoding="utf-8") as f:
        json.dump(phrases_payload, f, indent=2, ensure_ascii=False)
    with open(os.path.join(status_dir, "simple_translations_pl_candidates.json"), "w", encoding="utf-8") as f:
        json.dump(pl_pairs_payload, f, indent=2, ensure_ascii=False)
    with open(os.path.join(status_dir, "top_words_en.json"), "w", encoding="utf-8") as f:
        json.dump(words_payload, f, indent=2, ensure_ascii=False)
    with open(os.path.join(status_dir, "word_translations_pl_candidates.json"), "w", encoding="utf-8") as f:
        json.dump(pl_candidates_payload, f, indent=2, ensure_ascii=False)

    summary = {
        "timestamp": ts,
        "total_keys_scanned": int(total_keys),
        "top_phrases_generated": len(top_phrases_rows),
        "pl_pairs_generated": len(pl_pairs_rows),
        "top_words_generated": len(top_words_rows),
        "outputs": [
            "i18n/status/top_phrases_en.json",
            "i18n/status/simple_translations_pl_candidates.json",
            "i18n/status/top_words_en.json",
            "i18n/status/word_translations_pl_candidates.json",
        ],
    }

    with open(os.path.join(status_dir, "dictionary_expansion_summary.json"), "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2, ensure_ascii=False)

    return summary


def main():
    parser = argparse.ArgumentParser(description="I18N dictionary expansion analysis (plan point 4)")
    parser.add_argument("--i18n-dir", default="i18n")
    parser.add_argument("--status-dir", default="i18n/status")
    parser.add_argument("--top-phrases", type=int, default=500)
    parser.add_argument("--top-words", type=int, default=500)
    parser.add_argument("--min-pl-pair-count", type=int, default=3)
    args = parser.parse_args()

    summary = analyze(
        i18n_dir=args.i18n_dir,
        status_dir=args.status_dir,
        top_phrases=args.top_phrases,
        top_words=args.top_words,
        min_pl_pair_count=args.min_pl_pair_count,
    )

    print(json.dumps(summary, ensure_ascii=False))


if __name__ == "__main__":
    main()
