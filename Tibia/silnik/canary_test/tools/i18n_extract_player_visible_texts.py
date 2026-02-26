#!/usr/bin/env python3
"""
S2-TOOL-01..12: Plugin-based aggregator for extracting player-visible texts.

Each source type (lua, cpp, otui/otml, html/twig/php, xml) has its own plugin
that returns candidate entries with confidence scoring.

Outputs:
  i18n/status/extraction_catalog_latest.json    — all candidates with confidence
  i18n/status/extraction_catalog_history.jsonl   — history of runs
  i18n/status/extraction_manual_review_queue.json — low-confidence entries
  i18n/status/extraction_parser_health.json       — per-parser metrics
  i18n/status/extraction_crossref.json            — candidate ↔ existing i18n key mapping

Usage:
  python3 tools/i18n_extract_player_visible_texts.py [--scope full|server|all]
         [--confidence-threshold 0.6] [--project-root .] [--status-dir i18n/status]
         [--plugins lua,cpp,otui,html,xml] [--incremental] [--max-files 0]
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
import time
from abc import ABC, abstractmethod
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Pattern, Sequence, Set, Tuple


# ── Utilities ──────────────────────────────────────────────────────────────────

def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def atomic_write_json(path: Path, payload: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    with tmp.open("w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)
    os.replace(tmp, path)


def file_checksum(path: Path) -> str:
    """Fast MD5 checksum for incremental cache."""
    h = hashlib.md5()
    try:
        with path.open("rb") as f:
            for chunk in iter(lambda: f.read(8192), b""):
                h.update(chunk)
    except Exception:
        return ""
    return h.hexdigest()


def is_comment_line(line: str) -> bool:
    s = line.strip()
    return s.startswith("--") or s.startswith("//") or s.startswith("/*") or s.startswith("*") or s.startswith("#")


# ── Localization skip tokens ──────────────────────────────────────────────────

LOCALIZED_SKIP_TOKENS: Tuple[str, ...] = (
    "i18nKey", "NPC_LIB.i18n", "sendLocalizedTextMessage", "sayLocalized",
    "broadcastLocalized", "i18n.get", "i18n:", "tr(", "i18n::",
    "__GT_", "gettext", "ngettext", "_(", "_n(",
)


# ── Data classes ──────────────────────────────────────────────────────────────

@dataclass
class Candidate:
    """A single player-visible text candidate."""
    file: str
    line: int
    text: str
    pattern: str
    plugin: str
    confidence: float = 0.5
    confidence_reasons: List[str] = field(default_factory=list)
    i18n_crossref: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        d = {
            "file": self.file,
            "line": self.line,
            "text": self.text,
            "pattern": self.pattern,
            "plugin": self.plugin,
            "confidence": round(self.confidence, 3),
            "confidence_reasons": self.confidence_reasons,
        }
        if self.i18n_crossref:
            d["i18n_crossref"] = self.i18n_crossref
        return d


@dataclass
class PluginResult:
    """Result returned by each parser plugin."""
    plugin_name: str
    candidates: List[Candidate] = field(default_factory=list)
    files_processed: int = 0
    files_with_hits: int = 0
    parse_failures: int = 0
    parse_failure_files: List[str] = field(default_factory=list)
    elapsed_ms: float = 0.0


# ── Confidence scoring (S2-TOOL-07) ──────────────────────────────────────────

def score_confidence(text: str, pattern: str, line_context: str, file_path: str) -> Tuple[float, List[str]]:
    """Score 0..1 how likely the text is player-visible. Returns (score, reasons)."""
    score = 0.5
    reasons: List[str] = []

    # Strong positive signals
    if re.search(r"(say|send|broadcast|message|chat|dialog|talk|greet)", pattern, re.I):
        score += 0.2
        reasons.append("pattern_is_message_api")

    if re.search(r"[A-Z]", text) and re.search(r"[a-z]", text) and " " in text:
        score += 0.1
        reasons.append("mixed_case_with_spaces")

    if len(text) >= 10 and len(text) <= 200:
        score += 0.05
        reasons.append("good_length")

    if re.search(r"[.!?]$", text):
        score += 0.1
        reasons.append("ends_with_punctuation")

    # Strong negative signals
    if re.fullmatch(r"[A-Z_][A-Z0-9_]*", text):
        score -= 0.3
        reasons.append("all_caps_constant")

    if re.fullmatch(r"[a-z0-9_./-]+", text) and "/" in text:
        score -= 0.3
        reasons.append("looks_like_path")

    if re.search(r"^(debug|log|print|assert|error)\b", line_context.strip(), re.I):
        score -= 0.2
        reasons.append("debug_or_log_context")

    if re.fullmatch(r"\d+", text) or re.fullmatch(r"[0-9._:/-]+", text):
        score -= 0.4
        reasons.append("numeric_only")

    if len(text) < 3:
        score -= 0.3
        reasons.append("too_short")

    if len(text) > 500:
        score -= 0.2
        reasons.append("too_long")

    if re.search(r"https?://", text):
        score -= 0.2
        reasons.append("contains_url")

    if text.lower() in {"true", "false", "nil", "none", "null", "ok"}:
        score -= 0.4
        reasons.append("boolean_or_null")

    # Context-based scoring
    if "npc" in file_path.lower() or "dialog" in file_path.lower():
        score += 0.1
        reasons.append("npc_or_dialog_file")

    if "test" in file_path.lower() or "spec" in file_path.lower():
        score -= 0.15
        reasons.append("test_file")

    if ".otui" in file_path.lower():
        score += 0.05
        reasons.append("otui_ui_file")

    score = max(0.0, min(1.0, score))
    return score, reasons


# ── Base plugin class ─────────────────────────────────────────────────────────

class ExtractorPlugin(ABC):
    """Base class for text extraction plugins."""
    name: str = "base"
    extensions: Tuple[str, ...] = ()
    scan_roots: Tuple[str, ...] = ()
    skip_tokens: Tuple[str, ...] = ()

    @abstractmethod
    def extract_from_file(self, path: Path, rel_path: str, content: str, lines: List[str]) -> List[Candidate]:
        ...

    def iter_files(self, project_root: Path) -> Iterable[Path]:
        for root in self.scan_roots:
            abs_root = project_root / root
            if not abs_root.exists():
                continue
            for dirpath, _, filenames in os.walk(abs_root):
                for name in filenames:
                    if any(name.endswith(ext) for ext in self.extensions):
                        yield Path(dirpath) / name

    def should_skip_line(self, line: str) -> bool:
        if is_comment_line(line):
            return True
        for token in LOCALIZED_SKIP_TOKENS:
            if token in line:
                return True
        for token in self.skip_tokens:
            if token in line:
                return True
        return False


# ── S2-TOOL-02: Lua runtime calls plugin ─────────────────────────────────────

class LuaRuntimeCallsPlugin(ExtractorPlugin):
    name = "lua_runtime_calls"
    extensions = (".lua",)
    scan_roots = (
        "data-otservbr-global/npc", "data-otservbr-global/scripts",
        "data-otservbr-global/lib", "data/scripts", "data/npc",
        "data-canary/scripts", "data-canary/npc",
        "data-otservbr-global/startup",
    )
    skip_tokens = ()

    PATTERNS = [
        ("npcHandler:say", re.compile(r'npcHandler:say\s*\(\s*"([^"]{3,})"')),
        ("NpcHandler:say", re.compile(r'NpcHandler:say\s*\(\s*"([^"]{3,})"')),
        ("method:say", re.compile(r'[A-Za-z0-9_]+:say\s*\(\s*"([^"]{3,})"')),
        ("sendTextMessage", re.compile(r'sendTextMessage\s*\([^"\n]*"([^"]{3,})"')),
        ("broadcastMessage", re.compile(r'broadcastMessage\s*\(\s*"([^"]{3,})"')),
        ("Game.broadcastMessage", re.compile(r'Game\.broadcastMessage\s*\(\s*"([^"]{3,})"')),
        ("StdModule.say.text", re.compile(r'StdModule\.(?:say|promotePlayer).{0,180}text\s*=\s*"([^"]{3,})"')),
        ("keyword.text", re.compile(r'add(?:Greet|Farewell)Keyword.{0,180}text\s*=\s*"([^"]{3,})"')),
        ("voices.text", re.compile(r'text\s*=\s*"([^"]{3,})"')),
        ("player:sendTextMessage", re.compile(r'player:sendTextMessage\s*\([^"\n]*"([^"]{3,})"')),
        ("creature:say", re.compile(r'creature:say\s*\(\s*"([^"]{3,})"')),
        ("addEvent_msg", re.compile(r'addEvent\s*\(.{0,80}"([^"]{5,})"')),
    ]

    def extract_from_file(self, path: Path, rel_path: str, content: str, lines: List[str]) -> List[Candidate]:
        candidates: List[Candidate] = []
        seen: Set[Tuple[int, str]] = set()

        for line_no, line in enumerate(lines, 1):
            if self.should_skip_line(line):
                continue
            for pat_name, pat_re in self.PATTERNS:
                for m in pat_re.finditer(line):
                    text = m.group(1).strip()
                    if not text or len(text) < 3:
                        continue
                    key = (line_no, text)
                    if key in seen:
                        continue
                    seen.add(key)
                    conf, reasons = score_confidence(text, pat_name, line, rel_path)
                    candidates.append(Candidate(
                        file=rel_path, line=line_no, text=text,
                        pattern=pat_name, plugin=self.name,
                        confidence=conf, confidence_reasons=reasons,
                    ))
        return candidates


# ── S2-TOOL-03: C++ runtime strings plugin ───────────────────────────────────

class CppRuntimeStringsPlugin(ExtractorPlugin):
    name = "cpp_runtime_strings"
    extensions = (".cpp", ".hpp", ".h")
    scan_roots = ("src",)
    skip_tokens = ("i18n::",)

    PATTERNS = [
        ("sendTextMessage", re.compile(r'sendTextMessage\s*\([^"]*"([^"]{3,})"')),
        ("addGameTask_msg", re.compile(r'addGameTask\s*\(.{0,60}"([^"]{3,})"')),
        ("fmt::format_msg", re.compile(r'fmt::format\s*\(\s*"([^"]{5,})"')),
        ("console_print", re.compile(r'(?:SPDLOG_|g_logger)\.\w+\s*\(\s*"([^"]{5,})"')),
        ("error_string", re.compile(r'(?:throw|return)\s+(?:std::)?(?:string|runtime_error)\s*\(\s*"([^"]{5,})"')),
        ("ui_label", re.compile(r'(?:setLabel|setText|setTitle|setTooltip)\s*\(\s*"([^"]{3,})"')),
        ("notification", re.compile(r'(?:sendNotification|showNotification)\s*\(\s*"([^"]{3,})"')),
    ]

    def extract_from_file(self, path: Path, rel_path: str, content: str, lines: List[str]) -> List[Candidate]:
        candidates: List[Candidate] = []
        seen: Set[Tuple[int, str]] = set()

        for line_no, line in enumerate(lines, 1):
            if self.should_skip_line(line):
                continue
            for pat_name, pat_re in self.PATTERNS:
                for m in pat_re.finditer(line):
                    text = m.group(1).strip()
                    if not text or len(text) < 3:
                        continue
                    key = (line_no, text)
                    if key in seen:
                        continue
                    seen.add(key)
                    conf, reasons = score_confidence(text, pat_name, line, rel_path)
                    # C++ strings are often technical constants
                    if not re.search(r'[a-z]', text) or not re.search(r'\s', text):
                        conf = max(0.0, conf - 0.15)
                        reasons.append("cpp_no_spaces_or_lowercase")
                    candidates.append(Candidate(
                        file=rel_path, line=line_no, text=text,
                        pattern=pat_name, plugin=self.name,
                        confidence=conf, confidence_reasons=reasons,
                    ))
        return candidates


# ── S2-TOOL-04: OTUI/OTML UI texts plugin ───────────────────────────────────

class OtuiOtmlPlugin(ExtractorPlugin):
    name = "otui_otml_ui_texts"
    extensions = (".otui", ".otml", ".otmod")
    scan_roots = ("testyy/modules", "testyy/mods", "testyy/data")
    skip_tokens = ()

    # key-value patterns for display attributes
    DISPLAY_ATTRS = re.compile(
        r'^\s*(text|tooltip|title|description|placeholder|label)\s*[:=]\s*(.+)$',
        re.IGNORECASE,
    )
    # Skip attributes that are not user-visible
    SKIP_VALUES = re.compile(
        r'^(\d+|true|false|#[0-9a-fA-F]+|[0-9]+x[0-9]+|\$[a-zA-Z]+|@[a-zA-Z]+|\[.*\]|{.*})$'
    )

    def extract_from_file(self, path: Path, rel_path: str, content: str, lines: List[str]) -> List[Candidate]:
        candidates: List[Candidate] = []

        for line_no, line in enumerate(lines, 1):
            if self.should_skip_line(line):
                continue
            m = self.DISPLAY_ATTRS.match(line)
            if not m:
                continue
            attr_name = m.group(1).strip().lower()
            value = m.group(2).strip().strip("'\"")
            if not value or len(value) < 2:
                continue
            if self.SKIP_VALUES.match(value):
                continue
            # Check if it has actual text content (letters + spaces)
            if not re.search(r'[A-Za-z]', value):
                continue

            conf, reasons = score_confidence(value, f"otui.{attr_name}", line, rel_path)
            conf = min(1.0, conf + 0.1)  # OTUI display attrs are very likely player-visible
            reasons.append("otui_display_attribute")

            candidates.append(Candidate(
                file=rel_path, line=line_no, text=value,
                pattern=f"otui.{attr_name}", plugin=self.name,
                confidence=conf, confidence_reasons=reasons,
            ))
        return candidates


# ── S2-TOOL-05: HTML/Twig/PHP visible text plugin ───────────────────────────

class HtmlTwigPhpPlugin(ExtractorPlugin):
    name = "html_twig_php_visible_text"
    extensions = (".html", ".twig", ".php", ".phtml")
    scan_roots = ("html_copy",)
    skip_tokens = ("__(",)

    # Match visible text between HTML tags
    TAG_TEXT_RE = re.compile(r'>([^<]{3,})</')
    # Match PHP echo/print with string literals
    PHP_ECHO_RE = re.compile(r'(?:echo|print)\s+["\']([^"\']{3,})["\']')
    # Match Twig literal text blocks
    TWIG_BLOCK_RE = re.compile(r'{%\s*block\s+\w+\s*%}([^{]{3,}){%')
    # Match alt/title/placeholder attributes
    ATTR_RE = re.compile(r'(?:alt|title|placeholder|aria-label)\s*=\s*["\']([^"\']{3,})["\']')

    def extract_from_file(self, path: Path, rel_path: str, content: str, lines: List[str]) -> List[Candidate]:
        candidates: List[Candidate] = []

        # Skip script and style blocks
        clean_content = re.sub(r'<script[^>]*>.*?</script>', '', content, flags=re.DOTALL | re.I)
        clean_content = re.sub(r'<style[^>]*>.*?</style>', '', clean_content, flags=re.DOTALL | re.I)
        clean_lines = clean_content.splitlines()

        for line_no, line in enumerate(clean_lines, 1):
            if self.should_skip_line(line):
                continue

            for pat_name, pat_re in [
                ("html.tag_text", self.TAG_TEXT_RE),
                ("php.echo", self.PHP_ECHO_RE),
                ("twig.block", self.TWIG_BLOCK_RE),
                ("html.attr", self.ATTR_RE),
            ]:
                for m in pat_re.finditer(line):
                    text = m.group(1).strip()
                    if not text or len(text) < 3:
                        continue
                    if not re.search(r'[A-Za-z]', text):
                        continue
                    # Skip Twig variables and expressions
                    if '{{' in text or '{%' in text:
                        continue

                    conf, reasons = score_confidence(text, pat_name, line, rel_path)
                    candidates.append(Candidate(
                        file=rel_path, line=line_no, text=text,
                        pattern=pat_name, plugin=self.name,
                        confidence=conf, confidence_reasons=reasons,
                    ))
        return candidates


# ── S2-TOOL-06: XML content text plugin ──────────────────────────────────────

class XmlContentTextPlugin(ExtractorPlugin):
    name = "xml_content_text"
    extensions = (".xml",)
    scan_roots = (
        "data-otservbr-global", "data-canary", "data",
        "testyy/data", "testyy/modules",
    )
    skip_tokens = ()

    # Match text between XML tags
    NODE_TEXT_RE = re.compile(r'>([^<]{3,})</')
    # Match display-related attributes
    ATTR_RE = re.compile(
        r'(?:name|text|description|label|title|tooltip|value)\s*=\s*"([^"]{3,})"',
        re.IGNORECASE,
    )

    def extract_from_file(self, path: Path, rel_path: str, content: str, lines: List[str]) -> List[Candidate]:
        candidates: List[Candidate] = []
        seen: Set[Tuple[int, str]] = set()

        for line_no, line in enumerate(lines, 1):
            if self.should_skip_line(line):
                continue

            for pat_name, pat_re in [
                ("xml.node_text", self.NODE_TEXT_RE),
                ("xml.attr", self.ATTR_RE),
            ]:
                for m in pat_re.finditer(line):
                    text = m.group(1).strip()
                    if not text or len(text) < 3:
                        continue
                    if not re.search(r'[A-Za-z]', text):
                        continue
                    key = (line_no, text)
                    if key in seen:
                        continue
                    seen.add(key)

                    conf, reasons = score_confidence(text, pat_name, line, rel_path)
                    # XML name attributes are often identifiers, not player text
                    if pat_name == "xml.attr" and re.fullmatch(r'[A-Za-z0-9_]+', text):
                        conf = max(0.0, conf - 0.2)
                        reasons.append("xml_attr_looks_like_id")

                    candidates.append(Candidate(
                        file=rel_path, line=line_no, text=text,
                        pattern=pat_name, plugin=self.name,
                        confidence=conf, confidence_reasons=reasons,
                    ))
        return candidates


# ── S2-TOOL-09: Crossref with existing i18n keys ─────────────────────────────

class I18nCrossref:
    """Cross-references candidates against existing i18n keys."""

    def __init__(self, i18n_dir: str = "i18n/en"):
        self.key_to_text: Dict[str, str] = {}
        self.text_to_key: Dict[str, str] = {}
        self._load(i18n_dir)

    def _load(self, i18n_dir: str) -> None:
        if not os.path.isdir(i18n_dir):
            return
        for name in os.listdir(i18n_dir):
            if not name.endswith(".json"):
                continue
            try:
                with open(os.path.join(i18n_dir, name), encoding="utf-8") as f:
                    data = json.load(f)
                if isinstance(data, dict):
                    for key, val in data.items():
                        if isinstance(val, str):
                            self.key_to_text[key] = val
                            normalized = val.strip().lower()
                            if normalized:
                                self.text_to_key[normalized] = key
            except Exception:
                continue

    def lookup(self, text: str) -> Optional[str]:
        """Returns the i18n key if this text already exists, else None."""
        normalized = text.strip().lower()
        return self.text_to_key.get(normalized)


# ── Plugin registry ──────────────────────────────────────────────────────────

AVAILABLE_PLUGINS: Dict[str, type] = {
    "lua": LuaRuntimeCallsPlugin,
    "cpp": CppRuntimeStringsPlugin,
    "otui": OtuiOtmlPlugin,
    "html": HtmlTwigPhpPlugin,
    "xml": XmlContentTextPlugin,
}


# ── S2-TOOL-11: Incremental cache ────────────────────────────────────────────

class IncrementalCache:
    """File checksum cache for incremental scanning."""

    def __init__(self, cache_path: Path):
        self.cache_path = cache_path
        self.checksums: Dict[str, str] = {}
        self._load()

    def _load(self) -> None:
        try:
            if self.cache_path.exists():
                with self.cache_path.open("r", encoding="utf-8") as f:
                    self.checksums = json.load(f)
        except Exception:
            self.checksums = {}

    def save(self) -> None:
        atomic_write_json(self.cache_path, self.checksums)

    def needs_scan(self, rel_path: str, checksum: str) -> bool:
        return self.checksums.get(rel_path) != checksum

    def update(self, rel_path: str, checksum: str) -> None:
        self.checksums[rel_path] = checksum


# ── Main pipeline ─────────────────────────────────────────────────────────────

def run_pipeline(
    project_root: Path,
    status_dir: Path,
    plugins: List[ExtractorPlugin],
    crossref: I18nCrossref,
    confidence_threshold: float,
    incremental: bool,
    max_files: int,
) -> Dict[str, Any]:
    """Run all plugins and aggregate results."""

    cache = IncrementalCache(status_dir / "extraction_cache.json") if incremental else None
    all_candidates: List[Candidate] = []
    plugin_health: Dict[str, Dict[str, Any]] = {}
    total_files = 0
    total_skipped_cache = 0

    for plugin in plugins:
        t0 = time.monotonic()
        result = PluginResult(plugin_name=plugin.name)
        files_for_plugin = list(plugin.iter_files(project_root))

        if max_files > 0:
            files_for_plugin = files_for_plugin[:max_files]

        for path in files_for_plugin:
            rel_path = os.path.relpath(path, project_root)

            # S2-TOOL-11: incremental cache check
            if cache:
                cs = file_checksum(path)
                if not cache.needs_scan(rel_path, cs):
                    total_skipped_cache += 1
                    continue

            result.files_processed += 1
            try:
                content = path.read_text(encoding="utf-8", errors="ignore")
                lines = content.splitlines()
                candidates = plugin.extract_from_file(path, rel_path, content, lines)

                if candidates:
                    result.files_with_hits += 1
                    # S2-TOOL-09: crossref with existing i18n keys
                    for c in candidates:
                        existing_key = crossref.lookup(c.text)
                        if existing_key:
                            c.i18n_crossref = existing_key
                            c.confidence = max(0.0, c.confidence - 0.3)
                            c.confidence_reasons.append(f"already_in_i18n:{existing_key}")

                    result.candidates.extend(candidates)

                if cache:
                    cache.update(rel_path, cs)

            except Exception as e:
                result.parse_failures += 1
                if len(result.parse_failure_files) < 50:
                    result.parse_failure_files.append(f"{rel_path}: {str(e)[:80]}")

        elapsed = (time.monotonic() - t0) * 1000
        result.elapsed_ms = round(elapsed, 1)
        total_files += result.files_processed

        all_candidates.extend(result.candidates)

        # S2-TOOL-10: parser health metrics
        plugin_health[plugin.name] = {
            "files_processed": result.files_processed,
            "files_with_hits": result.files_with_hits,
            "candidates_found": len(result.candidates),
            "parse_failures": result.parse_failures,
            "parse_failure_files": result.parse_failure_files[:20],
            "elapsed_ms": result.elapsed_ms,
            "avg_ms_per_file": round(result.elapsed_ms / max(result.files_processed, 1), 2),
        }

    if cache:
        cache.save()

    # Deduplicate by (file, line, text)
    seen: Set[Tuple[str, int, str]] = set()
    unique_candidates: List[Candidate] = []
    for c in all_candidates:
        key = (c.file, c.line, c.text)
        if key not in seen:
            seen.add(key)
            unique_candidates.append(c)

    # Sort by confidence descending
    unique_candidates.sort(key=lambda c: (-c.confidence, c.file, c.line))

    # S2-TOOL-08: manual review queue (low confidence)
    review_queue = [c for c in unique_candidates if c.confidence < confidence_threshold]
    high_confidence = [c for c in unique_candidates if c.confidence >= confidence_threshold]

    # Crossref report
    crossref_entries = [c for c in unique_candidates if c.i18n_crossref]

    return {
        "all_candidates": unique_candidates,
        "high_confidence": high_confidence,
        "review_queue": review_queue,
        "crossref_entries": crossref_entries,
        "plugin_health": plugin_health,
        "total_files": total_files,
        "total_skipped_cache": total_skipped_cache,
    }


def write_outputs(
    status_dir: Path,
    result: Dict[str, Any],
    confidence_threshold: float,
) -> None:
    """Write all output artifacts."""
    generated_at = utc_now_iso()

    all_candidates = result["all_candidates"]
    high_confidence = result["high_confidence"]
    review_queue = result["review_queue"]
    crossref_entries = result["crossref_entries"]
    plugin_health = result["plugin_health"]

    # Catalog latest (S2-TOOL-01 main output)
    catalog = {
        "generated_at_utc": generated_at,
        "confidence_threshold": confidence_threshold,
        "total_candidates": len(all_candidates),
        "high_confidence_count": len(high_confidence),
        "review_queue_count": len(review_queue),
        "crossref_count": len(crossref_entries),
        "total_files_processed": result["total_files"],
        "skipped_by_cache": result["total_skipped_cache"],
        "plugins": list(plugin_health.keys()),
        "candidates_by_plugin": {
            name: h["candidates_found"] for name, h in plugin_health.items()
        },
        "entries": [c.to_dict() for c in all_candidates[:2000]],
    }
    atomic_write_json(status_dir / "extraction_catalog_latest.json", catalog)

    # History (S2-TOOL-01)
    history_entry = {
        "generated_at_utc": generated_at,
        "total_candidates": len(all_candidates),
        "high_confidence": len(high_confidence),
        "review_queue": len(review_queue),
        "crossref": len(crossref_entries),
        "files_processed": result["total_files"],
        "by_plugin": {name: h["candidates_found"] for name, h in plugin_health.items()},
    }
    history_path = status_dir / "extraction_catalog_history.jsonl"
    history_path.parent.mkdir(parents=True, exist_ok=True)
    with history_path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(history_entry, ensure_ascii=False) + "\n")

    # Manual review queue (S2-TOOL-08)
    review_payload = {
        "generated_at_utc": generated_at,
        "confidence_threshold": confidence_threshold,
        "total_entries": len(review_queue),
        "entries": [c.to_dict() for c in review_queue[:500]],
    }
    atomic_write_json(status_dir / "extraction_manual_review_queue.json", review_payload)

    # Parser health (S2-TOOL-10)
    health_payload = {
        "generated_at_utc": generated_at,
        "parsers": plugin_health,
        "total_failures": sum(h["parse_failures"] for h in plugin_health.values()),
        "total_files": result["total_files"],
    }
    atomic_write_json(status_dir / "extraction_parser_health.json", health_payload)

    # Crossref (S2-TOOL-09)
    crossref_payload = {
        "generated_at_utc": generated_at,
        "total_crossref": len(crossref_entries),
        "entries": [c.to_dict() for c in crossref_entries[:500]],
    }
    atomic_write_json(status_dir / "extraction_crossref.json", crossref_payload)


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Extract player-visible texts (plugin-based)")
    p.add_argument("--project-root", default=".", help="Project root")
    p.add_argument("--status-dir", default="i18n/status", help="Status directory")
    p.add_argument("--scope", default="full", help="Scope: server|full|all")
    p.add_argument("--plugins", default="lua,cpp,otui,html,xml", help="Comma-separated plugin names")
    p.add_argument("--confidence-threshold", type=float, default=0.6, help="Min confidence for auto-accept")
    p.add_argument("--incremental", action="store_true", help="Use file checksum cache")
    p.add_argument("--max-files", type=int, default=0, help="Max files per plugin (0=unlimited)")
    p.add_argument("--i18n-dir", default="i18n/en", help="Directory with existing i18n JSON files")
    return p.parse_args()


def main() -> int:
    args = parse_args()
    project_root = Path(args.project_root).resolve()
    status_dir = Path(args.status_dir)
    if not status_dir.is_absolute():
        status_dir = (project_root / status_dir).resolve()

    # Select plugins
    requested = [p.strip() for p in args.plugins.split(",") if p.strip()]
    plugins: List[ExtractorPlugin] = []
    for name in requested:
        cls = AVAILABLE_PLUGINS.get(name)
        if cls:
            plugins.append(cls())
        else:
            print(f"WARNING: unknown plugin '{name}', skipping", file=sys.stderr)

    if not plugins:
        print("ERROR: no valid plugins selected", file=sys.stderr)
        return 1

    # Build crossref
    i18n_dir = args.i18n_dir
    if not os.path.isabs(i18n_dir):
        i18n_dir = str(project_root / i18n_dir)
    crossref = I18nCrossref(i18n_dir)
    print(f"Crossref loaded: {len(crossref.text_to_key)} existing i18n texts")

    # Run pipeline
    print(f"Running {len(plugins)} plugins: {', '.join(p.name for p in plugins)}")
    t0 = time.monotonic()

    result = run_pipeline(
        project_root=project_root,
        status_dir=status_dir,
        plugins=plugins,
        crossref=crossref,
        confidence_threshold=args.confidence_threshold,
        incremental=args.incremental,
        max_files=args.max_files,
    )

    elapsed = time.monotonic() - t0

    # Write outputs
    write_outputs(status_dir, result, args.confidence_threshold)

    # Summary
    total = len(result["all_candidates"])
    high = len(result["high_confidence"])
    review = len(result["review_queue"])
    xref = len(result["crossref_entries"])
    files = result["total_files"]

    print(f"\n=== Extraction complete ({elapsed:.1f}s) ===")
    print(f"Files processed: {files}")
    print(f"Total candidates: {total}")
    print(f"High confidence (>={args.confidence_threshold}): {high}")
    print(f"Manual review queue (<{args.confidence_threshold}): {review}")
    print(f"Already in i18n (crossref): {xref}")

    for name, health in result["plugin_health"].items():
        print(f"  [{name}] files={health['files_processed']} hits={health['files_with_hits']} "
              f"candidates={health['candidates_found']} failures={health['parse_failures']} "
              f"time={health['elapsed_ms']:.0f}ms")

    # Machine-readable summary line for worker parsing
    print(f"\n__EXTRACT__ total={total} high={high} review={review} crossref={xref} "
          f"files={files} elapsed_s={elapsed:.1f}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
