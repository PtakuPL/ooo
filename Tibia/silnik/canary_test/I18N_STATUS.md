# 🌍 Status Systemu i18n - Canary Server

## ✏️ Status Workera

**Wersja**: 4.0 - Full Internationalization  
**Status**: 🟢 AKTYWNY  
**Tryb**: Migracja skryptów (scripts/quests)

---

## 🛡️ Zabezpieczenia

- ✅ **Guardian** - restartuje workera jeśli padnie (cron co 1 min)
- ✅ **Auto-push** - synchronizacja z GitHub co 2 min
- ✅ **Checkpointing** - zapisuje stan po każdym cyklu
- ✅ **Graceful shutdown** - poprawne zamykanie
- ✅ **Error handling** - kontynuuje mimo błędów
- ✅ **Excluded list** - pomija problematyczne pliki

---

## 🔄 Ostatnia aktualizacja

| ⏰ Czas | 📅 Data |
|--------|---------|
| UTC: | $(date -u '+%Y-%m-%d %H:%M:%S') UTC |
| Local: | $(date '+%H:%M:%S') |

---

## 📊 Statystyki Migracji

### Przetworzone kategorie:
| Kategoria | Klucze | Status |
|-----------|--------|--------|
| 🗣️ NPC Dialogi | 4,048 | ✅ Ukończone |
| 📦 Items | 36,972 | ✅ Ukończone |
| 📜 Scripts | $(cat i18n/en/scripts.json 2>/dev/null | grep -c '"scripts\.' || echo "0") | 🔄 W trakcie |
| ⚡ Actions | - | ⏳ Oczekuje |
| 🎭 Events | - | ⏳ Oczekuje |
| 🧙 Spells | - | ⏳ Oczekuje |

### Podsumowanie:
- **Łączna liczba kluczy**: ~44,000+
- **Języki**: 53
- **Pliki przetworzone**: $(wc -l < i18n_processed_files.txt 2>/dev/null || echo "0")

---

## 🌐 Obsługiwane języki (53)

\`\`\`
en, pl, de, es, pt, fr, it, nl, ru, uk, cs, sk, hu, ro, bg, 
hr, sl, sr, bs, mk, sq, el, tr, ar, he, fa, hi, bn, ta, te, 
ml, th, vi, id, ms, tl, zh, zh_TW, ja, ko, sv, no, da, fi, 
et, lv, lt, ka, hy, az, kk, uz, sw
\`\`\`

---

## 📁 Skanowane katalogi

- \`data-otservbr-global/npc/\` ✅
- \`data-otservbr-global/scripts/\` 🔄
- \`data-canary/npc/\`
- \`data/scripts/\`
- \`src/\` (C++)
- \`html_copy/\` (PHP/HTML)

---

## 🔗 Linki

- 📂 [Repozytorium](https://github.com/PtakuPL/ooo)
- 📋 [Dokumentacja i18n](./i18n_full_documentation.md)

---

*Status aktualizowany automatycznie co 2 minuty przez Guardian*
