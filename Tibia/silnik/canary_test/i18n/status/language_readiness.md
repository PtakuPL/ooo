# I18N Language Readiness Report

- Generated: `2026-02-12T23:04:55.563823Z`
- Input: `i18n/status/validation/summary.json`
- Gate: score>=95.0, critical<=20, high<=500, crossref<=600
- Result: ready=49/52, not_ready=3

| Lang | Ready | Score | Coverage | Critical | High | Crossref | Script |
|------|-------|-------|----------|----------|------|----------|--------|
| bg | ✅ | 98.8 | 57.3% | 8 | 11 | 481 | cyrillic |
| el | ✅ | 98.8 | 57.3% | 8 | 11 | 481 | exotic |
| mk | ✅ | 98.8 | 57.3% | 8 | 11 | 481 | cyrillic |
| sr | ✅ | 98.8 | 57.3% | 8 | 11 | 481 | cyrillic |
| uk | ✅ | 98.8 | 57.3% | 8 | 11 | 481 | cyrillic |
| az | ✅ | 98.9 | 57.3% | 8 | 0 | 481 | latin |
| bs | ✅ | 98.9 | 57.3% | 8 | 0 | 481 | latin |
| cs | ✅ | 98.9 | 57.3% | 8 | 0 | 481 | latin |
| da | ✅ | 98.9 | 57.3% | 8 | 0 | 481 | latin |
| de | ✅ | 98.9 | 57.4% | 8 | 0 | 481 | latin |
| et | ✅ | 98.9 | 57.3% | 8 | 0 | 481 | latin |
| fi | ✅ | 98.9 | 57.3% | 8 | 0 | 481 | latin |
| fr | ✅ | 98.9 | 57.3% | 8 | 0 | 481 | latin |
| hr | ✅ | 98.9 | 57.3% | 8 | 0 | 481 | latin |
| hu | ✅ | 98.9 | 57.3% | 8 | 0 | 481 | latin |
| it | ✅ | 98.9 | 57.3% | 8 | 0 | 481 | latin |
| kk | ✅ | 98.9 | 57.3% | 8 | 0 | 481 | latin |
| lt | ✅ | 98.9 | 57.3% | 8 | 0 | 481 | latin |
| lv | ✅ | 98.9 | 57.3% | 8 | 0 | 481 | latin |
| nl | ✅ | 98.9 | 57.3% | 8 | 0 | 481 | latin |
| no | ✅ | 98.9 | 57.3% | 8 | 0 | 481 | latin |
| ro | ✅ | 98.9 | 57.3% | 8 | 0 | 481 | latin |
| sk | ✅ | 98.9 | 57.3% | 8 | 0 | 481 | latin |
| sl | ✅ | 98.9 | 57.3% | 8 | 0 | 481 | latin |
| sq | ✅ | 98.9 | 57.3% | 8 | 0 | 481 | latin |
| sv | ✅ | 98.9 | 57.3% | 8 | 0 | 481 | latin |
| tr | ✅ | 98.9 | 57.8% | 5 | 0 | 486 | latin |
| uz | ✅ | 98.9 | 57.3% | 8 | 0 | 481 | latin |
| ar | ✅ | 99.0 | 66.4% | 8 | 11 | 481 | rtl |
| bn | ✅ | 99.0 | 66.4% | 8 | 11 | 481 | exotic |
| fa | ✅ | 99.0 | 66.4% | 8 | 0 | 481 | latin |
| he | ✅ | 99.0 | 66.4% | 8 | 11 | 481 | rtl |
| hi | ✅ | 99.0 | 66.4% | 8 | 11 | 481 | exotic |
| hy | ✅ | 99.0 | 66.4% | 8 | 11 | 481 | exotic |
| id | ✅ | 99.0 | 66.4% | 8 | 0 | 481 | latin |
| ja | ✅ | 99.0 | 66.4% | 8 | 0 | 481 | cjk |
| ka | ✅ | 99.0 | 66.4% | 8 | 11 | 481 | exotic |
| ko | ✅ | 99.0 | 66.4% | 8 | 0 | 481 | cjk |
| ml | ✅ | 99.0 | 66.4% | 8 | 11 | 481 | exotic |
| ms | ✅ | 99.0 | 66.4% | 8 | 0 | 481 | latin |
| sw | ✅ | 99.0 | 66.4% | 8 | 0 | 481 | latin |
| ta | ✅ | 99.0 | 66.4% | 8 | 11 | 481 | exotic |
| te | ✅ | 99.0 | 66.4% | 8 | 11 | 481 | exotic |
| th | ✅ | 99.0 | 66.4% | 8 | 11 | 481 | exotic |
| tl | ✅ | 99.0 | 66.4% | 8 | 0 | 481 | latin |
| vi | ✅ | 99.0 | 66.4% | 8 | 0 | 481 | latin |
| zh | ✅ | 99.0 | 66.4% | 8 | 0 | 481 | cjk |
| zh_TW | ✅ | 99.0 | 66.4% | 8 | 0 | 481 | cjk |
| pl | ✅ | 99.7 | 60.2% | 2 | 13 | 0 | latin |
| ru | ❌ | 93.3 | 59.3% | 85 | 1045 | 482 | cyrillic |
| pt | ❌ | 98.2 | 59.4% | 85 | 0 | 482 | latin |
| es | ❌ | 98.9 | 93.7% | 84 | 4 | 553 | latin |

## Not Ready (top 15 by score)

- ru: score=93.3, crit=85, high=1045, crossref=482, coverage=59.3%
- pt: score=98.2, crit=85, high=0, crossref=482, coverage=59.4%
- es: score=98.9, crit=84, high=4, crossref=553, coverage=93.7%
