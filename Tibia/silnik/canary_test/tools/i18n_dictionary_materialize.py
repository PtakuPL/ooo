#!/usr/bin/env python3
import argparse
import json
import os
import re
from collections import Counter, defaultdict
from datetime import datetime, timezone


def load_json(path, default=None):
    if default is None:
        default = {}
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return default


def is_untranslated(value, en_value):
    if value is None:
        return True
    s = str(value)
    if not s.strip():
        return True
    if s.startswith("["):
        return True
    if s == str(en_value):
        return True
    return False


def token_sets(text):
    placeholders = set(re.findall(r"\{[^}]*\}", text or ""))
    commands = set(re.findall(r"'[^']+?'", text or ""))
    pipes = set(re.findall(r"\|[^|]+\|", text or ""))
    return placeholders, commands, pipes


def candidate_shape_ok(en_text, tr_text):
    src = str(en_text or "").strip()
    dst = str(tr_text or "").strip()
    if not src or not dst:
        return False
    en_ph, en_cmd, en_pipe = token_sets(src)
    tr_ph, tr_cmd, tr_pipe = token_sets(dst)
    if en_ph != tr_ph:
        return False
    if en_cmd and en_cmd != tr_cmd:
        return False
    if en_pipe != tr_pipe:
        return False
    ratio = len(dst) / max(len(src), 1)
    if ratio < 0.2 or ratio > 5.0:
        return False
    return True


def iter_en_data(i18n_dir):
    en_dir = os.path.join(i18n_dir, "en")
    for fname in sorted(os.listdir(en_dir)):
        if not fname.endswith(".json"):
            continue
        path = os.path.join(en_dir, fname)
        data = load_json(path, default={})
        if not isinstance(data, dict):
            continue
        yield fname, data


def build_simple(i18n_dir, langs, min_count):
    result = {lang: {} for lang in langs}

    for lang in langs:
        phrase_map = defaultdict(Counter)  # EN -> Counter(TR)
        lang_dir = os.path.join(i18n_dir, lang)
        if not os.path.isdir(lang_dir):
            continue

        for fname, en_data in iter_en_data(i18n_dir):
            lang_file = os.path.join(lang_dir, fname)
            if not os.path.exists(lang_file):
                continue
            tr_data = load_json(lang_file, default={})
            if not isinstance(tr_data, dict):
                continue

            for key, en_val in en_data.items():
                en_text = str(en_val or "").strip()
                if not en_text:
                    continue
                tr_val = tr_data.get(key)
                if is_untranslated(tr_val, en_text):
                    continue
                tr_text = str(tr_val or "").strip()
                if not candidate_shape_ok(en_text, tr_text):
                    continue
                phrase_map[en_text][tr_text] += 1

        for en_text, variants in phrase_map.items():
            best_tr, best_cnt = variants.most_common(1)[0]
            if best_cnt >= min_count:
                result[lang][en_text] = best_tr

    return result


def build_word(i18n_dir, langs, min_count):
    word_re = re.compile(r"^[^\W\d_]{3,}(?:-[^\W\d_]{3,})?$", re.UNICODE)
    token_re = re.compile(r"[^\W\d_]+(?:-[^\W\d_]+)?", re.UNICODE)
    en_stop = {
        "the", "and", "for", "you", "your", "with", "that", "this", "from", "have", "will", "not", "are", "was", "were",
        "has", "had", "his", "her", "its", "our", "their", "but", "some", "now", "about", "into", "over", "under", "then",
        "else", "than", "what", "when", "where", "who", "how", "which", "just", "only", "very", "also", "there", "here",
        "they", "them", "she", "him", "can", "could", "would", "should", "may", "might", "must", "any", "all", "new", "please",
    }
    bad_target_tokens = {
        "unkniewn", "niething", "niene", "adoanie", "adowanie", "ogie", "poka", "tytu"
    }
    allowed_borrowed_fragments = {
        "npc", "boss", "loot", "pvp", "premium", "server", "client", "rookgaard", "market", "temple"
    }

    def looks_hybrid_for_pl(src_word, dst_word):
        src_parts = [part for part in src_word.split("-") if len(part) >= 4]
        dst_lower = dst_word.lower()
        for fragment in src_parts:
            fragment_lower = fragment.lower()
            if fragment_lower in allowed_borrowed_fragments:
                continue
            if fragment_lower in dst_lower and fragment_lower != dst_lower:
                return True
        compact_src = re.sub(r"[^a-z]", "", src_word.lower())
        if len(compact_src) >= 4:
            for i in range(0, len(compact_src) - 3):
                chunk = compact_src[i:i + 4]
                if chunk in allowed_borrowed_fragments:
                    continue
                if chunk in dst_lower and compact_src != dst_lower:
                    return True
        if re.search(r"sniew|pianie|niewn", dst_lower):
            return True
        return False
    result = {lang: {} for lang in langs}

    for lang in langs:
        word_map = defaultdict(Counter)  # en_word -> Counter(tr_word)
        token_align_map = defaultdict(Counter)  # en_word -> Counter(tr_word)
        target_token_freq = Counter()
        lang_dir = os.path.join(i18n_dir, lang)
        if not os.path.isdir(lang_dir):
            continue

        for fname, en_data in iter_en_data(i18n_dir):
            lang_file = os.path.join(lang_dir, fname)
            if not os.path.exists(lang_file):
                continue
            tr_data = load_json(lang_file, default={})
            if not isinstance(tr_data, dict):
                continue

            for key, en_val in en_data.items():
                en_text = str(en_val or "").strip()
                tr_val = tr_data.get(key)
                if is_untranslated(tr_val, en_text):
                    continue
                tr_text = str(tr_val or "").strip()

                en_words = [w.lower() for w in token_re.findall(en_text)]
                tr_words = [w.lower() for w in token_re.findall(tr_text)]

                for token in tr_words:
                    if word_re.match(token):
                        target_token_freq[token] += 1

                if len(en_words) == len(tr_words) and 1 <= len(en_words) <= 6:
                    for src_w, dst_w in zip(en_words, tr_words):
                        if not word_re.match(src_w) or not word_re.match(dst_w):
                            continue
                        if src_w == dst_w:
                            continue
                        if src_w in en_stop:
                            continue
                        if dst_w in bad_target_tokens:
                            continue
                        if lang == "pl" and looks_hybrid_for_pl(src_w, dst_w):
                            continue
                        token_align_map[src_w][dst_w] += 1

                if len(en_words) != 1 or len(tr_words) != 1:
                    continue

                en_w = en_words[0].lower()
                tr_w = tr_words[0].lower()
                if not word_re.match(en_w) or not word_re.match(tr_w):
                    continue
                if en_w == tr_w:
                    continue
                if en_w in en_stop:
                    continue
                if tr_w in bad_target_tokens:
                    continue
                if lang == "pl" and looks_hybrid_for_pl(en_w, tr_w):
                    continue

                word_map[en_w][tr_w] += 1

        merged_map = defaultdict(Counter)
        for en_w, variants in word_map.items():
            merged_map[en_w].update(variants)
        for en_w, variants in token_align_map.items():
            merged_map[en_w].update(variants)

        for en_w, variants in merged_map.items():
            if not variants:
                continue
            total_votes = sum(variants.values())
            best_tr, best_cnt = variants.most_common(1)[0]
            confidence = (best_cnt / total_votes) if total_votes else 0.0
            if lang == "pl" and target_token_freq.get(best_tr, 0) < 2:
                continue
            if best_cnt >= min_count and confidence >= 0.70:
                result[lang][en_w] = best_tr

    return result


def main():
    parser = argparse.ArgumentParser(description="Materialize external dictionaries for point 4")
    parser.add_argument("--i18n-dir", default="i18n")
    parser.add_argument("--status-dir", default="i18n/status")
    parser.add_argument("--langs", default="pl,tr,de,es,pt,ru,fr,it,nl,cs")
    parser.add_argument("--min-simple-count", type=int, default=3)
    parser.add_argument("--min-word-count", type=int, default=2)
    args = parser.parse_args()

    langs = [x.strip() for x in args.langs.split(",") if x.strip()]
    os.makedirs(args.status_dir, exist_ok=True)

    simple_data = build_simple(args.i18n_dir, langs, args.min_simple_count)
    word_data = build_word(args.i18n_dir, langs, args.min_word_count)

    simple_path = os.path.join(args.status_dir, "simple_translations.json")
    word_path = os.path.join(args.status_dir, "word_translations.json")

    with open(simple_path, "w", encoding="utf-8") as f:
        json.dump(simple_data, f, indent=2, ensure_ascii=False)
    with open(word_path, "w", encoding="utf-8") as f:
        json.dump(word_data, f, indent=2, ensure_ascii=False)

    summary = {
        "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "langs": langs,
        "simple_counts": {k: len(v) for k, v in simple_data.items()},
        "word_counts": {k: len(v) for k, v in word_data.items()},
        "outputs": [
            "i18n/status/simple_translations.json",
            "i18n/status/word_translations.json",
        ],
    }

    with open(os.path.join(args.status_dir, "dictionary_materialize_summary.json"), "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2, ensure_ascii=False)

    print(json.dumps(summary, ensure_ascii=False))


if __name__ == "__main__":
    main()
