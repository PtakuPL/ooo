# 🌍 I18N Internationalization System - Live Dashboard

> **Aktualizacja:** 2025-12-10 06:09:31 UTC  
> **Worker:** v1.1 Simple | **Guardian:** v2.0 | **Języki:** 8

---

## 🤖 AI Agent Integration

```
┌─────────────────────────────────────────────────────────────────┐
│  Status zoptymalizowany dla AI agentów (Codex/Copilot/Claude)  │
│  JSON data: i18n_file_status.json                              │
│  Worker: i18n_worker_simple.sh                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 Globalny Postęp

| Metryka | Wartość | Trend |
|---------|---------|-------|
| 📁 Plików przetworzonych | **763** | ↑ |
| ✅ Plików ukończonych | **4** | ↑ |
| 🔄 W trakcie | **0** | - |
| 🔑 Kluczy i18n | **93** | ↑ |
| 🌍 Języków z danymi | **8** | ✓ |

---

## 🧙 NPC Migration Status

| Metryka | Wartość |
|---------|---------|
| 📁 Plików NPC ogółem | 1026 |
| ✅ Zmigrowanych | 11 |
| 🔄 Do migracji | 286 |
| 📊 Postęp | 1.1% |

---

## 🔑 Klucze per kategoria

| Kategoria | Klucze EN |
|-----------|-----------|
| 🧙 NPC | 93 |
| 📜 Scripts | 0 |
| 🎒 Items | 0 |
| 👹 Monsters | 0 |
| ⚙️ Server | 0 |
| ✨ Spells | 0 |
| **RAZEM** | **93** |

---

## 🌍 Języki z tłumaczeniami

de, en, es, fr, it, pl, pt, ru

---

## 📋 Ostatnio zmigrowane NPC

| Plik | Czas | Klucze | Status |
|------|------|--------|--------|
| `alkestios.lua` | 05:57:18 | 6 | ✅ |
| `alia.lua` | 05:57:17 | 24 | ✅ |
| `al_dee.lua` | 05:57:16 | 61 | ✅ |
| `alexander.lua` | 05:51:53 | 2 | ✅ |

---

## 🚀 Jak uruchomić

```bash
# Pojedynczy plik
./i18n_worker_simple.sh --file data-otservbr-global/npc/nazwa.lua

# Status
./i18n_worker_simple.sh --status

# Auto migracja (5 plików)
./i18n_worker_simple.sh --auto 5

# Auto migracja (wszystkie)
./i18n_worker_simple.sh --auto
```

---

*Wygenerowano automatycznie przez i18n_worker_simple.sh*
