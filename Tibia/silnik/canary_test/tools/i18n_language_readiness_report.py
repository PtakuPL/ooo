#!/usr/bin/env python3
import argparse
import json
from pathlib import Path
from datetime import datetime, timezone


def read_json(path: Path):
    try:
        with path.open("r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {}


def main():
    parser = argparse.ArgumentParser(description="Generate i18n per-language readiness report.")
    parser.add_argument("--status-dir", default="i18n/status", help="Path to i18n/status directory")
    parser.add_argument("--min-score", type=float, default=95.0, help="Minimum acceptable score")
    parser.add_argument("--max-critical", type=int, default=20, help="Maximum acceptable critical issues")
    parser.add_argument("--max-high", type=int, default=500, help="Maximum acceptable high issues")
    parser.add_argument("--max-crossref", type=int, default=600, help="Maximum acceptable crossref issues")
    parser.add_argument("--out", default="", help="Output markdown path (default: i18n/status/language_readiness.md)")
    args = parser.parse_args()

    status_dir = Path(args.status_dir)
    validation_dir = status_dir / "validation"
    summary_path = validation_dir / "summary.json"

    summary = read_json(summary_path)
    by_score = summary.get("by_score", {}) if isinstance(summary, dict) else {}

    rows = []
    for lang, info in by_score.items():
        score = float(info.get("score", 0.0) or 0.0)
        critical = int(info.get("critical", 0) or 0)
        high = int(info.get("high", 0) or 0)
        crossref = int(info.get("crossref_issues", 0) or 0)
        coverage = float(info.get("coverage_pct", 0.0) or 0.0)
        script_group = str(info.get("script_group", "-") or "-")

        ok = (
            score >= args.min_score
            and critical <= args.max_critical
            and high <= args.max_high
            and crossref <= args.max_crossref
        )

        rows.append({
            "lang": lang,
            "ok": ok,
            "score": score,
            "coverage": coverage,
            "critical": critical,
            "high": high,
            "crossref": crossref,
            "script_group": script_group,
        })

    rows.sort(key=lambda r: (r["ok"] is False, r["score"]))

    total = len(rows)
    ready = sum(1 for r in rows if r["ok"])
    not_ready = total - ready

    timestamp = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

    lines = []
    lines.append("# I18N Language Readiness Report")
    lines.append("")
    lines.append(f"- Generated: `{timestamp}`")
    lines.append(f"- Input: `{summary_path}`")
    lines.append(
        f"- Gate: score>={args.min_score}, critical<={args.max_critical}, high<={args.max_high}, crossref<={args.max_crossref}"
    )
    lines.append(f"- Result: ready={ready}/{total}, not_ready={not_ready}")
    lines.append("")
    lines.append("| Lang | Ready | Score | Coverage | Critical | High | Crossref | Script |")
    lines.append("|------|-------|-------|----------|----------|------|----------|--------|")

    for r in rows:
        ready_mark = "✅" if r["ok"] else "❌"
        lines.append(
            f"| {r['lang']} | {ready_mark} | {r['score']:.1f} | {r['coverage']:.1f}% | {r['critical']} | {r['high']} | {r['crossref']} | {r['script_group']} |"
        )

    lines.append("")
    lines.append("## Not Ready (top 15 by score)")
    lines.append("")
    worst = [r for r in rows if not r["ok"]]
    worst.sort(key=lambda r: r["score"])
    for r in worst[:15]:
        lines.append(
            f"- {r['lang']}: score={r['score']:.1f}, crit={r['critical']}, high={r['high']}, crossref={r['crossref']}, coverage={r['coverage']:.1f}%"
        )

    out_path = Path(args.out) if args.out else (status_dir / "language_readiness.md")
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

    print(f"READY_LANGS={ready}")
    print(f"NOT_READY_LANGS={not_ready}")
    print(f"REPORT={out_path}")


if __name__ == "__main__":
    main()
