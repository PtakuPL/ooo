# 🌍 I18N Worker Status

> 🤖 **Autonomiczny worker działa w tle** - migruje NPC do systemu i18n

---

## 🛡️ Status Systemu

| Komponent | Status |
|-----------|--------|
| **Worker** | 🟢 Running (PID: 1719299) |
| **Guardian** | 🟢 Active (sprawdza co 1 min) |
| **Cykl** | #4 |
| **Restarty** | 0 |

## 📊 Aktualny postęp

![NPC Migration](https://img.shields.io/badge/NPC-43.6%25-orange?style=for-the-badge&logo=lua)
![Keys](https://img.shields.io/badge/Keys-43641-blue?style=for-the-badge&logo=json)
![Speed](https://img.shields.io/badge/Speed-1.2_NPC%2Fmin-purple?style=for-the-badge&logo=speedtest)
![Worker](https://img.shields.io/badge/Worker-green-green?style=for-the-badge)

## 📈 Progress Bar

```
[█████████████████░░░░░░░░░░░░░░░░░░░░░░░] 43.6%
 448 / 1027 NPC (594 wykluczonych)
```

## 📋 Szczegóły

| 📌 Metryka | 📊 Wartość |
|------------|------------|
| **NPC Zmigrowanych** | `448` / `1027` |
| **Wykluczonych** | `594` (brak stringów) |
| **Postęp** | **43.6%** |
| **Klucze i18n** | `43641` |
| **Języki** | 5 (🇬🇧 en, 🇵🇱 pl, 🇩🇪 de, 🇪🇸 es, 🇧🇷 pt) |
| **Prędkość** | ~`1.2` NPC/min |
| **Czas pracy** | 337min |
| **Start** | 11:42 |
| **ETA** | ~482 min |
| **Błędy** | 0 |
| **Cykl** | #4 |

## 📁 Ostatnio zmodyfikowane NPC

| Plik |
|------|
| `warbert.lua` |
| `taegen.lua` |
| `stutch.lua` |
| `jean_claude.lua` |
| `harsky.lua` |
| `fenbala.lua` |
| `edron_guardsman.lua` |
| `demonguard.lua` |

## 🔧 Status Workera

```
[2025-12-08 17:19:57] [INFO] 📦 FAZA 1: MIGRACJA NPC
```

## 🛡️ Zabezpieczenia

- ✅ **Guardian** - restartuje workera jeśli padnie (cron co 1 min)
- ✅ **Checkpointing** - zapisuje stan po każdym cyklu
- ✅ **Graceful shutdown** - poprawne zamykanie
- ✅ **Error handling** - kontynuuje mimo błędów
- ✅ **Excluded list** - pomija problematyczne pliki

## 🔄 Ostatnia aktualizacja

| 🕐 Czas | 📅 Data |
|---------|---------|
| **UTC:** | 2025-12-08 16:20:04 UTC |
| **Local:** | 17:20:04 |

---

⏱️ *Status aktualizowany automatycznie co 2 minuty*

🔗 **Link:** [github.com/PtakuPL/ooo](https://github.com/PtakuPL/ooo)
