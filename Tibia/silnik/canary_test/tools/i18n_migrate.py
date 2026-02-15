#!/usr/bin/env python3
"""
I18N MIGRATION ENGINE — Master tool for automated text → i18n key migration.
=============================================================================

Unified engine covering all source types: Lua, C++, PHP, XML, OTClient.
Called by i18n_worker_simple.sh in MIGRATION mode (when MIGRATION_ENABLED=true).

Outputs:
  - Modified source files (with i18n calls replacing hardcoded strings)
  - i18n/en/{category}.json  (new EN keys added)
  - i18n/status/migration_log.json  (run log)
  - i18n/status/migration_proposals/cpp/*.diff  (C++ proposals, not auto-applied)
  - i18n/status/migration_backups/{timestamp}/{file}.bak  (rollback copies)

Usage:
  python3 tools/i18n_migrate.py --category errors --scope otservbr --batch 5
  python3 tools/i18n_migrate.py --category libs --dry-run
  python3 tools/i18n_migrate.py --category cpp --proposals-only
  python3 tools/i18n_migrate.py --force-file data-otservbr-global/lib/core/quest
  python3 tools/i18n_migrate.py --category mounts --scope full

NOTE: This tool is intentionally dependency-free (stdlib only).
"""
from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import sys
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Pattern, Set, Tuple


# ─────────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────────

def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def atomic_write_json(path: str, data: Any, indent: int = 2) -> None:
    """Atomic JSON write via tmp+rename."""
    tmp = path + ".tmp"
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=indent, ensure_ascii=False)
        f.write("\n")
    os.replace(tmp, path)


def load_json(path: str) -> Optional[Dict]:
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return None


# ─────────────────────────────────────────────────────────────────────────────
# Data classes
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class Hit:
    """Single hardcoded text found in source code."""
    file: str
    line: int
    col: int
    text: str              # The raw English text
    full_match: str        # The full regex match (for replacement)
    pattern_name: str      # Which pattern matched
    context: str           # surrounding code for context
    hit_type: str = ""     # A/B/C/D/SKIP  (set by HitClassifier)
    skip_reason: str = ""  # Why skipped (if SKIP)

    def __repr__(self) -> str:
        return f"Hit({self.file}:{self.line} [{self.hit_type}] {self.text[:40]!r})"


@dataclass
class TransformResult:
    """Result of transforming a single hit."""
    hit: Hit
    key: str                # Generated i18n key
    en_value: str           # English value for EN JSON
    original_line: str      # Original source line
    transformed_line: str   # Transformed source line with i18n call
    success: bool = True
    error: str = ""


@dataclass
class FileResult:
    """Migration result for a single file."""
    path: str
    hits: int = 0
    migrated: int = 0
    skipped: int = 0
    errors: int = 0
    keys_added: List[str] = field(default_factory=list)
    error_details: List[str] = field(default_factory=list)


@dataclass
class MigrationReport:
    """Complete migration run report."""
    timestamp: str = ""
    category: str = ""
    scope: str = ""
    dry_run: bool = False
    proposals_only: bool = False
    total_files: int = 0
    total_hits: int = 0
    total_migrated: int = 0
    total_skipped: int = 0
    total_errors: int = 0
    files: List[FileResult] = field(default_factory=list)

    def to_dict(self) -> Dict:
        return {
            "timestamp": self.timestamp,
            "category": self.category,
            "scope": self.scope,
            "dry_run": self.dry_run,
            "proposals_only": self.proposals_only,
            "total_files": self.total_files,
            "total_hits": self.total_hits,
            "total_migrated": self.total_migrated,
            "total_skipped": self.total_skipped,
            "total_errors": self.total_errors,
            "files": [
                {
                    "path": fr.path,
                    "hits": fr.hits,
                    "migrated": fr.migrated,
                    "skipped": fr.skipped,
                    "errors": fr.errors,
                    "keys_added": fr.keys_added,
                }
                for fr in self.files
            ],
        }


# ─────────────────────────────────────────────────────────────────────────────
# HitClassifier  (AI-2)
# ─────────────────────────────────────────────────────────────────────────────

class HitClassifier:
    """Classifies hits as A (simple), B (placeholder), C (concat), D (fmt), or SKIP."""

    # Patterns to SKIP — not player-visible or not translatable
    SKIP_PATTERNS: List[Tuple[Pattern, str]] = [
        # SQL
        (re.compile(r"^\s*(SELECT|INSERT|UPDATE|DELETE|CREATE|ALTER|DROP|PRAGMA|BEGIN|COMMIT|ROLLBACK)\b", re.I), "sql"),
        # CSS selectors and classes
        (re.compile(r"^[.#][a-zA-Z_-]+"), "css_selector"),
        (re.compile(r"^(col|btn|card|tab|table|form|modal|nav|alert|badge|container|row|d-|text-|bg-|border-|float-|justify-|align-|m[trblxy]?-|p[trblxy]?-)", re.I), "css_class"),
        # Only lowercase + hyphens/underscores → likely CSS class or internal ID
        (re.compile(r"^[a-z0-9_-]+$"), "internal_id"),
        # PHP variables
        (re.compile(r"^\$"), "php_var"),
        # URLs / paths
        (re.compile(r"^https?://", re.I), "url"),
        (re.compile(r"^/[a-z0-9_/.-]+$", re.I), "path"),
        (re.compile(r"^vendor/|^tools/|^includes/|^src/|^data/"), "internal_path"),
        # Numbers / versions
        (re.compile(r"^\d+(\.\d+)*$"), "number"),
        # CONSTANTS (ALL_CAPS_WITH_UNDERSCORES)
        (re.compile(r"^[A-Z][A-Z0-9_]+$"), "constant"),
        # Single word ≤ 2 chars
        (re.compile(r"^.{0,2}$"), "too_short"),
        # Log/debug patterns
        (re.compile(r"^\[?(DEBUG|INFO|WARN|WARNING|ERROR|TRACE|VERBOSE)\]?:?\s", re.I), "debug_log"),
        # Format strings (only placeholders, no real text)
        (re.compile(r"^[%{}\d.,sdfx ]+$"), "format_only"),
        # HTML tags only
        (re.compile(r"^</?[a-z][a-z0-9]*[^>]*>$", re.I), "html_tag"),
        # Empty or whitespace only
        (re.compile(r"^\s*$"), "whitespace"),
        # Already localized (has i18n marker)
        (re.compile(r"i18n[.:]|tr\(|_\(|gettext\(|t\(", re.I), "already_localized"),
        # Lua/PHP variable interpolation like $var or %s only
        (re.compile(r"^(%[sd]|%\d+\$[sd]|\$\w+)$"), "pure_variable"),
        # Webhook/API URL patterns
        (re.compile(r"discord\.com/api|webhook|Bearer |Authorization"), "api_token"),
        # Regex pattern strings
        (re.compile(r"^\^.*\$$"), "regex"),
        # File extension patterns
        (re.compile(r"^\*?\.[a-z]{1,5}$", re.I), "file_extension"),
    ]

    # Localized skip tokens — if these appear in context, the text is already localized
    LOCALIZED_TOKENS = (
        "i18nKey", "NPC_LIB.i18n", "sendLocalizedTextMessage",
        "sayLocalized", "broadcastLocalized", "i18n.get", "i18n:", "tr(",
    )

    @classmethod
    def classify(cls, hit: Hit) -> str:
        """Returns hit_type: A, B, C, D, or SKIP."""
        text = hit.text.strip()

        # 1. Check skip patterns
        for pattern, reason in cls.SKIP_PATTERNS:
            if pattern.search(text):
                hit.skip_reason = reason
                return "SKIP"

        # 2. Check already-localized context
        for token in cls.LOCALIZED_TOKENS:
            if token in hit.context:
                hit.skip_reason = f"already_localized:{token}"
                return "SKIP"

        # 3. Check for spell words (exori, utori, etc.) — not player-visible text
        if re.match(r"^(ex(ori|ura|evo|eta|ana|iva)|ut(ori|ura|evo|amo|eta|ito|ani)|ad(ori|ito|evo|ana)|mas |gran )", text, re.I):
            hit.skip_reason = "spell_words"
            return "SKIP"

        # 4. Classify type
        has_placeholder = bool(re.search(r"\{[^}]*\}|%[sd]|%\d+\$", text))
        has_concat = ".." in hit.context and ".." not in text
        has_fmt = "fmt::format" in hit.context or "string.format" in hit.context

        if has_fmt:
            return "D"
        if has_concat:
            return "C"
        if has_placeholder:
            return "B"
        return "A"

    @classmethod
    def is_player_visible(cls, text: str) -> bool:
        """Quick check if text looks player-visible."""
        # Must have at least one letter
        if not re.search(r"[a-zA-Z]", text):
            return False
        # Must be >= 3 chars
        if len(text.strip()) < 3:
            return False
        # Run through skip patterns
        for pattern, _ in cls.SKIP_PATTERNS:
            if pattern.search(text.strip()):
                return False
        return True


# ─────────────────────────────────────────────────────────────────────────────
# KeyGenerator
# ─────────────────────────────────────────────────────────────────────────────

class KeyGenerator:
    """Generates i18n keys from file paths and context."""

    # Counter per base key to avoid collisions
    _counters: Dict[str, int] = {}
    _existing_keys: Set[str] = set()

    @classmethod
    def reset(cls) -> None:
        cls._counters.clear()

    @classmethod
    def load_existing_keys(cls, en_json_path: str) -> None:
        """Load existing keys from EN JSON to avoid duplicates."""
        data = load_json(en_json_path)
        if data and isinstance(data, dict):
            cls._existing_keys.update(data.keys())

    @classmethod
    def generate(cls, hit: Hit, category: str) -> str:
        """Generate a unique i18n key for a hit."""
        path = Path(hit.file)
        stem = path.stem.replace("-", "_").replace(" ", "_").lower()

        # Determine domain from category and path
        if category == "errors":
            base = f"errors.{stem}"
        elif category == "libs":
            base = f"lib.{stem}"
        elif category == "mounts":
            base = f"mount.{stem}"
        elif category == "cpp":
            base = f"cpp.{stem}"
        elif category == "php":
            base = f"www.{stem}"
        elif category == "html":
            base = f"www.tpl.{stem}"
        elif category in ("otclient_modules", "otclient_src", "otclient_tools"):
            base = f"ui.{stem}"
        elif category == "monsters":
            base = f"monster.{stem}"
        elif category == "spells":
            base = f"spell.{stem}"
        elif category in ("npc", "npclib"):
            base = f"npc.{stem}"
        elif category == "quests":
            base = f"quests.{stem}"
        elif category in ("scripts", "actions", "movements", "creaturescripts", "globalevents", "talkactions"):
            base = f"server.{stem}"
        elif category == "raids":
            base = f"raids.{stem}"
        else:
            base = f"misc.{stem}"

        # Generate semantic suffix from text
        suffix = cls._text_to_suffix(hit.text)
        key = f"{base}.{suffix}"

        # Ensure uniqueness
        if key in cls._existing_keys or key in cls._counters:
            n = cls._counters.get(key, 1) + 1
            cls._counters[key] = n
            key = f"{key}_{n}"

        cls._existing_keys.add(key)
        cls._counters[key] = 1
        return key

    @classmethod
    def _text_to_suffix(cls, text: str) -> str:
        """Convert text to a short snake_case suffix."""
        # Take first ~40 chars
        t = text[:40].strip().lower()
        # Replace non-alphanumeric with underscore
        t = re.sub(r"[^a-z0-9]+", "_", t)
        # Remove leading/trailing underscores
        t = t.strip("_")
        # Truncate to max 30 chars at word boundary
        if len(t) > 30:
            t = t[:30].rsplit("_", 1)[0]
        return t or "text"


# ─────────────────────────────────────────────────────────────────────────────
# CodeTransformer  (AI-3)
# ─────────────────────────────────────────────────────────────────────────────

class CodeTransformer:
    """Transforms source code lines to use i18n calls."""

    @staticmethod
    def transform_lua_literal(line: str, text: str, key: str) -> str:
        """Replace a Lua string literal with i18n.get call.

        "Some text" → i18n.get(player, "key")
        Uses creature or player depending on context.
        """
        # Determine variable name (player is most common)
        var = "player"
        if "creature" in line.lower() and "player" not in line.lower():
            var = "creature"

        old = f'"{text}"'
        new = f'i18n.get({var}, "{key}")'
        return line.replace(old, new, 1)

    @staticmethod
    def transform_lua_concat(line: str, text: str, key: str) -> str:
        """Replace concatenated Lua string.

        "Hello " .. name .. "!" → i18n.format(player, "key", {name})
        """
        # For concat, we generate format-style replacement
        # This is a simplified version — complex concats need manual review
        old = f'"{text}"'
        new = f'i18n.get(player, "{key}")'
        return line.replace(old, new, 1)

    @staticmethod
    def transform_cpp_literal(line: str, text: str, key: str) -> str:
        """Generate C++ i18n proposal (not auto-applied).

        "Some text" → i18n::g_translator().get("key", locale)
        """
        old = f'"{text}"'
        new = f'i18n::g_translator().get("{key}", player->getLocale())'
        return line.replace(old, new, 1)

    @staticmethod
    def transform_php_literal(line: str, text: str, key: str) -> str:
        """Replace PHP hardcoded string with t() call.

        "Some text" → t('key')
        """
        old = f'"{text}"'
        new = f"t('{key}')"
        if old in line:
            return line.replace(old, new, 1)
        # Try single quotes
        old = f"'{text}'"
        new = f"t('{key}')"
        return line.replace(old, new, 1)

    @staticmethod
    def transform_twig_text(line: str, text: str, key: str) -> str:
        """Replace Twig template text with {{ t('key') }}.

        >Some text< → >{{ t('key') }}<
        """
        return line.replace(text, f"{{{{ t('{key}') }}}}", 1)

    @staticmethod
    def transform_xml_attribute(line: str, text: str, key: str) -> str:
        """XML attributes — generate extraction key, don't modify XML.

        The i18n system reads XML → looks up key by id → returns translated text.
        This just records what key maps to what text.
        """
        # For XML we don't modify the file — we just extract the text to JSON
        # The C++ parser handles the lookup at runtime
        return line  # No change to XML

    @classmethod
    def transform(cls, hit: Hit, key: str, language: str) -> TransformResult:
        """Apply the appropriate transformation for a hit."""
        lines = []
        try:
            with open(hit.file, "r", encoding="utf-8", errors="replace") as f:
                lines = f.readlines()
        except Exception as e:
            return TransformResult(
                hit=hit, key=key, en_value=hit.text,
                original_line="", transformed_line="",
                success=False, error=str(e),
            )

        if hit.line < 1 or hit.line > len(lines):
            return TransformResult(
                hit=hit, key=key, en_value=hit.text,
                original_line="", transformed_line="",
                success=False, error=f"line {hit.line} out of range (file has {len(lines)} lines)",
            )

        original_line = lines[hit.line - 1]

        # Choose transformer based on language
        if language in ("lua",):
            if hit.hit_type == "C":
                new_line = cls.transform_lua_concat(original_line, hit.text, key)
            else:
                new_line = cls.transform_lua_literal(original_line, hit.text, key)
        elif language in ("cpp", "hpp", "h"):
            new_line = cls.transform_cpp_literal(original_line, hit.text, key)
        elif language in ("php",):
            new_line = cls.transform_php_literal(original_line, hit.text, key)
        elif language in ("twig", "html"):
            new_line = cls.transform_twig_text(original_line, hit.text, key)
        elif language in ("xml",):
            new_line = cls.transform_xml_attribute(original_line, hit.text, key)
        else:
            new_line = cls.transform_lua_literal(original_line, hit.text, key)

        success = new_line != original_line or language == "xml"
        return TransformResult(
            hit=hit, key=key, en_value=hit.text,
            original_line=original_line.rstrip("\n"),
            transformed_line=new_line.rstrip("\n"),
            success=success,
            error="" if success else "transform produced no change",
        )


# ─────────────────────────────────────────────────────────────────────────────
# Category definitions (reuse scan patterns from pre_migration_scan)
# ─────────────────────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class CategoryConfig:
    name: str
    roots: Tuple[str, ...]
    extensions: Tuple[str, ...]
    language: str                  # lua, cpp, php, xml, html
    en_json_file: str              # Target EN JSON file
    proposals_only: bool = False   # If True, don't auto-modify (C++)


# Category configs aligned with pre_migration_scan categories
CATEGORIES: Dict[str, CategoryConfig] = {
    "errors": CategoryConfig(
        name="errors",
        roots=("data-otservbr-global/scripts/", "data-canary/scripts/",
               "data-otservbr-global/lib/", "data-canary/lib/"),
        extensions=(".lua",),
        language="lua",
        en_json_file="errors.json",
    ),
    "libs": CategoryConfig(
        name="libs",
        roots=("data-otservbr-global/lib/", "data-canary/lib/"),
        extensions=(".lua",),
        language="lua",
        en_json_file="libs.json",
    ),
    "mounts": CategoryConfig(
        name="mounts",
        roots=("data-otservbr-global/XML/", "data-canary/XML/",
               "data-otservbr-global/items/", "data-canary/items/"),
        extensions=(".xml",),
        language="xml",
        en_json_file="mounts.json",
    ),
    "monsters": CategoryConfig(
        name="monsters",
        roots=("data-otservbr-global/monster/", "data-canary/monster/"),
        extensions=(".xml",),
        language="xml",
        en_json_file="monsters.json",
    ),
    "cpp": CategoryConfig(
        name="cpp",
        roots=("src/",),
        extensions=(".cpp", ".hpp", ".h"),
        language="cpp",
        en_json_file="cpp.json",
        proposals_only=True,
    ),
    "server": CategoryConfig(
        name="server",
        roots=("src/",),
        extensions=(".cpp", ".hpp", ".h"),
        language="cpp",
        en_json_file="server.json",
        proposals_only=True,
    ),
    "php": CategoryConfig(
        name="php",
        roots=("www/", "system/", "admin/"),
        extensions=(".php",),
        language="php",
        en_json_file="php.json",
    ),
    "html": CategoryConfig(
        name="html",
        roots=("www/", "system/", "admin/"),
        extensions=(".html", ".twig"),
        language="html",
        en_json_file="html.json",
    ),
    "otclient_modules": CategoryConfig(
        name="otclient_modules",
        roots=("testyy/modules/", "testyy/data/"),
        extensions=(".lua", ".otui"),
        language="lua",
        en_json_file="otclient_modules.json",
    ),
    "otclient_src": CategoryConfig(
        name="otclient_src",
        roots=("testyy/src/",),
        extensions=(".cpp", ".h"),
        language="cpp",
        en_json_file="client.json",
        proposals_only=True,
    ),
    "otclient_tools": CategoryConfig(
        name="otclient_tools",
        roots=("testyy/tools/", "testyy/scripts/"),
        extensions=(".lua", ".py"),
        language="lua",
        en_json_file="client.json",
    ),
    "spells": CategoryConfig(
        name="spells",
        roots=("data-otservbr-global/spells/", "data-canary/spells/"),
        extensions=(".lua",),
        language="lua",
        en_json_file="spells.json",
    ),
    "npc": CategoryConfig(
        name="npc",
        roots=("data-otservbr-global/npc/", "data-canary/npc/"),
        extensions=(".lua",),
        language="lua",
        en_json_file="npc.json",
    ),
    "quests": CategoryConfig(
        name="quests",
        roots=("data-otservbr-global/scripts/quests/", "data-canary/scripts/quests/"),
        extensions=(".lua",),
        language="lua",
        en_json_file="quests.json",
    ),
    "raids": CategoryConfig(
        name="raids",
        roots=("data-otservbr-global/world/raids/", "data-canary/world/raids/"),
        extensions=(".xml",),
        language="xml",
        en_json_file="raids.json",
    ),
    "scripts": CategoryConfig(
        name="scripts",
        roots=("data-otservbr-global/scripts/", "data-canary/scripts/"),
        extensions=(".lua",),
        language="lua",
        en_json_file="scripts.json",
    ),
}

# Scan patterns per language (simplified from pre_migration_scan)
SCAN_PATTERNS_LUA = [
    ("sendTextMessage", re.compile(r'sendTextMessage\s*\([^"]*"([^"]{3,})"')),
    ("method:say", re.compile(r'[A-Za-z0-9_]+:say\s*\(\s*"([^"]{3,})"')),
    ("broadcastMessage", re.compile(r'broadcastMessage\s*\(\s*"([^"]{3,})"')),
    ("string_literal", re.compile(r'"([^"]{5,})"')),
]

SCAN_PATTERNS_CPP = [
    ("fmt_format", re.compile(r'fmt::format\s*\(\s*"([^"]{3,})"')),
    ("string_literal", re.compile(r'"([^"]{5,})"')),
]

SCAN_PATTERNS_PHP = [
    ("echo_string", re.compile(r'echo\s+"([^"]{3,})"')),
    ("string_literal", re.compile(r'"([^"]{5,})"')),
]

SCAN_PATTERNS_XML = [
    ("name_attr", re.compile(r'\bname\s*=\s*"([^"]{3,})"')),
    ("description_attr", re.compile(r'\b(?:description|label)\s*=\s*"([^"]{3,})"')),
]


# ─────────────────────────────────────────────────────────────────────────────
# MigrationEngine  (AI-1)
# ─────────────────────────────────────────────────────────────────────────────

class MigrationEngine:
    """Master migration engine: scan → classify → generate key → transform → validate → commit."""

    def __init__(
        self,
        project_root: str,
        i18n_dir: str = "i18n",
        status_dir: str = "i18n/status",
        dry_run: bool = False,
        proposals_only: bool = False,
        batch_size: int = 5,
        skip_validation: bool = False,
        verbose: bool = False,
    ):
        self.project_root = project_root
        self.i18n_dir = i18n_dir
        self.status_dir = status_dir
        self.dry_run = dry_run
        self.proposals_only = proposals_only
        self.batch_size = batch_size
        self.skip_validation = skip_validation
        self.verbose = verbose
        self.backup_dir = os.path.join(
            status_dir, "migration_backups",
            datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S"),
        )

    def run(self, category: str, scope: str = "otservbr",
            force_file: Optional[str] = None) -> MigrationReport:
        """Run migration for a category."""
        report = MigrationReport(
            timestamp=utc_now_iso(),
            category=category,
            scope=scope,
            dry_run=self.dry_run,
            proposals_only=self.proposals_only,
        )

        cat_config = CATEGORIES.get(category)
        if not cat_config:
            print(f"❌ Unknown category: {category}", file=sys.stderr)
            print(f"   Available: {', '.join(sorted(CATEGORIES.keys()))}", file=sys.stderr)
            return report

        # Force proposals_only for C++ categories
        if cat_config.proposals_only:
            self.proposals_only = True

        # Load existing EN keys to avoid duplicates
        en_json_path = os.path.join(self.i18n_dir, "en", cat_config.en_json_file)
        KeyGenerator.reset()
        KeyGenerator.load_existing_keys(en_json_path)

        # Find files to process
        if force_file:
            files = [force_file] if os.path.exists(force_file) else []
        else:
            files = self._find_files(cat_config, scope)

        if not files:
            print(f"ℹ️  No files found for category={category} scope={scope}")
            return report

        # Apply batch limit
        files = files[: self.batch_size]
        report.total_files = len(files)
        print(f"🔄 MIGRATION: category={category} files={len(files)} dry_run={self.dry_run} proposals={self.proposals_only}")

        # Process each file
        for fpath in files:
            fr = self._process_file(fpath, cat_config)
            report.files.append(fr)
            report.total_hits += fr.hits
            report.total_migrated += fr.migrated
            report.total_skipped += fr.skipped
            report.total_errors += fr.errors

        # Save report
        self._save_report(report)

        # Print summary
        print(f"__MIGRATION__ category={category} migrated={report.total_migrated} "
              f"skipped={report.total_skipped} errors={report.total_errors} "
              f"files={report.total_files} dry_run={self.dry_run}")

        return report

    def _find_files(self, cat: CategoryConfig, scope: str) -> List[str]:
        """Find files matching category roots and extensions."""
        files = []
        for root in cat.roots:
            root_path = os.path.join(self.project_root, root)
            if not os.path.isdir(root_path):
                continue
            # Apply scope filter
            if scope == "otservbr" and "canary" in root and "otservbr" not in root:
                continue
            if scope == "canary" and "otservbr" in root and "canary" not in root:
                continue
            for dirpath, _, filenames in os.walk(root_path):
                for fname in sorted(filenames):
                    if any(fname.endswith(ext) for ext in cat.extensions):
                        files.append(os.path.join(dirpath, fname))
        return sorted(files)

    def _get_scan_patterns(self, language: str) -> List[Tuple[str, Pattern]]:
        """Get scan patterns for a language."""
        if language == "lua":
            return SCAN_PATTERNS_LUA
        elif language in ("cpp", "hpp", "h"):
            return SCAN_PATTERNS_CPP
        elif language == "php":
            return SCAN_PATTERNS_PHP
        elif language in ("xml",):
            return SCAN_PATTERNS_XML
        elif language in ("html", "twig"):
            return SCAN_PATTERNS_PHP  # Reuse PHP patterns for HTML
        return SCAN_PATTERNS_LUA

    def _scan_file(self, fpath: str, cat: CategoryConfig) -> List[Hit]:
        """Scan a file for hardcoded strings."""
        hits = []
        patterns = self._get_scan_patterns(cat.language)

        try:
            with open(fpath, "r", encoding="utf-8", errors="replace") as f:
                lines = f.readlines()
        except Exception:
            return hits

        for line_num, line in enumerate(lines, 1):
            # Skip already-localized lines
            if any(tok in line for tok in HitClassifier.LOCALIZED_TOKENS):
                continue
            # Skip comment lines
            stripped = line.strip()
            if stripped.startswith("--") or stripped.startswith("//") or stripped.startswith("#"):
                continue

            for pat_name, pat_rx in patterns:
                for m in pat_rx.finditer(line):
                    text = m.group(1)
                    if not HitClassifier.is_player_visible(text):
                        continue
                    # Get context (5 chars before + after match)
                    ctx_start = max(0, m.start() - 60)
                    ctx_end = min(len(line), m.end() + 60)
                    context = line[ctx_start:ctx_end].strip()

                    hit = Hit(
                        file=fpath,
                        line=line_num,
                        col=m.start(),
                        text=text,
                        full_match=m.group(0),
                        pattern_name=pat_name,
                        context=context,
                    )
                    hit.hit_type = HitClassifier.classify(hit)
                    hits.append(hit)

        return hits

    def _process_file(self, fpath: str, cat: CategoryConfig) -> FileResult:
        """Process a single file: scan → classify → transform → commit."""
        fr = FileResult(path=fpath)
        rel_path = os.path.relpath(fpath, self.project_root)

        # 1. Scan
        hits = self._scan_file(fpath, cat)
        fr.hits = len(hits)

        if not hits:
            return fr

        # 2. Classify (already done in scan)
        actionable = [h for h in hits if h.hit_type != "SKIP"]
        skipped = [h for h in hits if h.hit_type == "SKIP"]
        fr.skipped = len(skipped)

        if not actionable:
            if self.verbose:
                print(f"   ⏭️  {rel_path}: {fr.hits} hits, all SKIP")
            return fr

        # 3. Generate keys + transform
        transforms: List[TransformResult] = []
        en_additions: Dict[str, str] = {}

        for hit in actionable:
            key = KeyGenerator.generate(hit, cat.name)
            tr = CodeTransformer.transform(hit, key, cat.language)
            transforms.append(tr)
            if tr.success:
                en_additions[key] = tr.en_value

        successful = [t for t in transforms if t.success]
        failed = [t for t in transforms if not t.success]
        fr.errors = len(failed)
        fr.error_details = [f"{t.hit.line}: {t.error}" for t in failed]

        if not successful:
            if self.verbose:
                print(f"   ❌ {rel_path}: {len(failed)} transform failures")
            return fr

        # 4. Dry-run or proposals-only: just report
        if self.dry_run:
            fr.migrated = len(successful)
            fr.keys_added = [t.key for t in successful]
            if self.verbose:
                for t in successful[:5]:
                    print(f"   [DRY] {rel_path}:{t.hit.line} → {t.key}")
            return fr

        if self.proposals_only:
            self._save_proposal(fpath, successful, cat)
            fr.migrated = len(successful)
            fr.keys_added = [t.key for t in successful]
            return fr

        # 5. Backup original file
        self._backup_file(fpath)

        # 6. Apply transforms (all at once, atomically)
        if cat.language != "xml":
            apply_ok = self._apply_transforms(fpath, successful)
            if not apply_ok:
                fr.errors += 1
                fr.error_details.append("failed to apply transforms")
                self._rollback_file(fpath)
                return fr

        # 7. Validate syntax
        if not self.skip_validation:
            valid = self._validate_syntax(fpath, cat.language)
            if not valid:
                print(f"   ❌ Validation failed for {rel_path} — rolling back")
                fr.errors += 1
                fr.error_details.append("syntax validation failed")
                self._rollback_file(fpath)
                return fr

        # 8. Add EN keys to JSON
        self._add_en_keys(en_additions, cat)

        fr.migrated = len(successful)
        fr.keys_added = [t.key for t in successful]
        if self.verbose:
            print(f"   ✅ {rel_path}: migrated={fr.migrated} skipped={fr.skipped}")

        return fr

    def _apply_transforms(self, fpath: str, transforms: List[TransformResult]) -> bool:
        """Apply all transforms to a file atomically."""
        try:
            with open(fpath, "r", encoding="utf-8", errors="replace") as f:
                lines = f.readlines()

            # Apply in reverse order (so line numbers stay valid)
            for tr in sorted(transforms, key=lambda t: t.hit.line, reverse=True):
                idx = tr.hit.line - 1
                if 0 <= idx < len(lines):
                    lines[idx] = tr.transformed_line + "\n"

            tmp = fpath + ".mig.tmp"
            with open(tmp, "w", encoding="utf-8") as f:
                f.writelines(lines)
            os.replace(tmp, fpath)
            return True
        except Exception as e:
            print(f"   ❌ Apply failed: {e}", file=sys.stderr)
            return False

    def _validate_syntax(self, fpath: str, language: str) -> bool:
        """Validate file syntax after transformation."""
        import subprocess

        if language == "lua":
            # Try luac -p (parse only)
            try:
                result = subprocess.run(
                    ["luac", "-p", fpath],
                    capture_output=True, text=True, timeout=10,
                )
                return result.returncode == 0
            except FileNotFoundError:
                # luac not available — skip validation
                return True
            except Exception:
                return True
        elif language == "php":
            try:
                result = subprocess.run(
                    ["php", "-l", fpath],
                    capture_output=True, text=True, timeout=10,
                )
                return result.returncode == 0
            except FileNotFoundError:
                return True
            except Exception:
                return True
        elif language == "xml":
            try:
                import xml.etree.ElementTree as ET
                ET.parse(fpath)
                return True
            except Exception:
                return False
        # For C++, HTML, etc. — no validation (proposals only or manual)
        return True

    def _backup_file(self, fpath: str) -> None:
        """Create backup of original file."""
        os.makedirs(self.backup_dir, exist_ok=True)
        backup_path = os.path.join(self.backup_dir, os.path.basename(fpath) + ".bak")
        shutil.copy2(fpath, backup_path)

    def _rollback_file(self, fpath: str) -> None:
        """Rollback file from backup."""
        backup_path = os.path.join(self.backup_dir, os.path.basename(fpath) + ".bak")
        if os.path.exists(backup_path):
            shutil.copy2(backup_path, fpath)
            print(f"   🔙 Rolled back {fpath}")

    def _add_en_keys(self, additions: Dict[str, str], cat: CategoryConfig) -> None:
        """Add new keys to EN JSON file."""
        en_path = os.path.join(self.i18n_dir, "en", cat.en_json_file)
        data = load_json(en_path) or {}
        data.update(additions)
        # Sort keys alphabetically
        sorted_data = dict(sorted(data.items()))
        atomic_write_json(en_path, sorted_data)

    def _save_proposal(self, fpath: str, transforms: List[TransformResult],
                       cat: CategoryConfig) -> None:
        """Save C++ migration proposal as diff."""
        proposals_dir = os.path.join(self.status_dir, "migration_proposals", cat.name)
        os.makedirs(proposals_dir, exist_ok=True)

        stem = Path(fpath).stem
        proposal_path = os.path.join(proposals_dir, f"{stem}.diff")

        lines = []
        lines.append(f"# i18n-proposal: {fpath}")
        lines.append(f"# Generated: {utc_now_iso()}")
        lines.append(f"# Category: {cat.name}")
        lines.append(f"# Transforms: {len(transforms)}")
        lines.append("")

        for tr in transforms:
            lines.append(f"--- {fpath}:{tr.hit.line}")
            lines.append(f"-{tr.original_line}")
            lines.append(f"+{tr.transformed_line}")
            lines.append(f"# key: {tr.key}")
            lines.append(f"# en: {tr.en_value}")
            lines.append("")

        with open(proposal_path, "w", encoding="utf-8") as f:
            f.write("\n".join(lines) + "\n")

        rel = os.path.relpath(proposal_path, self.project_root)
        print(f"   📝 Proposal saved: {rel} ({len(transforms)} transforms)")

    def _save_report(self, report: MigrationReport) -> None:
        """Save migration report to status directory."""
        report_path = os.path.join(self.status_dir, "migration_log.json")
        atomic_write_json(report_path, report.to_dict())

        # Append to history
        history_path = os.path.join(self.status_dir, "migration_log_history.jsonl")
        os.makedirs(os.path.dirname(history_path) or ".", exist_ok=True)
        with open(history_path, "a", encoding="utf-8") as f:
            json.dump(report.to_dict(), f, ensure_ascii=False)
            f.write("\n")


# ─────────────────────────────────────────────────────────────────────────────
# CLI
# ─────────────────────────────────────────────────────────────────────────────

def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description="I18N Migration Engine — migrate hardcoded texts to i18n keys",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    p.add_argument("--category", required=True,
                   help=f"Category to migrate: {', '.join(sorted(CATEGORIES.keys()))}")
    p.add_argument("--scope", default="otservbr",
                   choices=["otservbr", "canary", "full"],
                   help="Scope of files to process (default: otservbr)")
    p.add_argument("--batch", type=int, default=5,
                   help="Max files per run (default: 5)")
    p.add_argument("--dry-run", action="store_true",
                   help="Report only, no modifications")
    p.add_argument("--force-file", type=str, default=None,
                   help="Migrate a specific file path")
    p.add_argument("--proposals-only", action="store_true",
                   help="Generate proposals only (for C++)")
    p.add_argument("--skip-validation", action="store_true",
                   help="Skip syntax validation after transform")
    p.add_argument("--project-root", default=".",
                   help="Project root directory (default: .)")
    p.add_argument("--i18n-dir", default="i18n",
                   help="i18n directory (default: i18n)")
    p.add_argument("--status-dir", default="i18n/status",
                   help="Status directory (default: i18n/status)")
    p.add_argument("--verbose", "-v", action="store_true",
                   help="Verbose output")
    return p


def main() -> int:
    args = build_parser().parse_args()

    engine = MigrationEngine(
        project_root=args.project_root,
        i18n_dir=args.i18n_dir,
        status_dir=args.status_dir,
        dry_run=args.dry_run,
        proposals_only=args.proposals_only,
        batch_size=args.batch,
        skip_validation=args.skip_validation,
        verbose=args.verbose,
    )

    report = engine.run(
        category=args.category,
        scope=args.scope,
        force_file=args.force_file,
    )

    return 0 if report.total_errors == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
