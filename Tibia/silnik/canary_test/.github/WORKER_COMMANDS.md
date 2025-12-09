# 📡 I18N Worker - GitHub Command Terminal

> **Wersja:** 1.1 | **Aktualizacja:** 2025-12-09

Możesz wysyłać komendy do workera przez GitHub! Worker sprawdza plik `.github/worker_commands.txt` przy każdym auto-push (co 2 minuty).

---

## 🚀 Jak używać

### 1️⃣ Edytuj plik `.github/worker_commands.txt` na GitHub
- Otwórz: https://github.com/PtakuPL/ooo/blob/master/Tibia/silnik/canary_test/.github/worker_commands.txt
- Kliknij ołówek (Edit)
- Wpisz komendę na końcu pliku
- Commit changes

### 2️⃣ Worker wykona komendę
- Przy następnym cyklu (max 2 min) worker pobierze zmiany
- Wykona komendę i zaloguje w `commands_log.txt`
- Wyczyść `worker_commands.txt`
- Wynik zapisze w `.github/` (np. `analysis_report.md`)

---

## 📋 Dostępne komendy

### 🔧 Kontrola workera
| Komenda | Opis | Przykład |
|---------|------|----------|
| `PAUSE` | Zatrzymaj worker (czeka 1h) | `PAUSE` |
| `RESUME` | Wznów pracę | `RESUME` |
| `RESTART` | Restartuj worker | `RESTART` |
| `PUSH` | Wymuś natychmiastowy push | `PUSH` |

### 📊 Statusy i raporty
| Komenda | Opis | Przykład |
|---------|------|----------|
| `STATUS` | Wymuś aktualizację statusu | `STATUS` |
| `INFO` | Szczegółowe info o workerze | `INFO` |
| `ERRORS` | Pokaż ostatnie błędy | `ERRORS` |
| `RECENT: N` | Ostatnie N plików (domyślnie 5) | `RECENT: 10` |

### 🔍 Analiza i skanowanie
| Komenda | Opis | Przykład |
|---------|------|----------|
| `ANALYZE: plik` | Analizuj konkretny plik | `ANALYZE: Sam.lua` |
| `SCAN: katalog` | Skanuj katalog | `SCAN: data-otservbr-global/npc` |
| `KEYS: kategoria` | Pokaż klucze kategorii | `KEYS: npc` |

### 🎯 Nawigacja
| Komenda | Opis | Przykład |
|---------|------|----------|
| `PHASE: N` | Przejdź do fazy N (1-4) | `PHASE: 2` |
| `CATEGORY: xxx` | Zmień kategorię | `CATEGORY: monsters` |

### 🌍 Tłumaczenia
| Komenda | Opis | Przykład |
|---------|------|----------|
| `TRANSLATE: N` | Wygeneruj batch N kluczy | `TRANSLATE: 50` |

### 💬 Interakcja (AI-like)
| Komenda | Opis | Przykład |
|---------|------|----------|
| `PROMPT: tekst` | Zadaj pytanie workerowi | `PROMPT: sprawdź Sam.lua czy ma i18n` |

---

## 🗂️ Gdzie szukać wyników?

Po wykonaniu komendy, wynik znajdziesz w `.github/`:

| Komenda | Plik wyniku |
|---------|-------------|
| `RECENT` | `.github/recent_report.md` |
| `ANALYZE` | `.github/analysis_report.md` |
| `PROMPT` | `.github/prompt_response.md` |
| `INFO` | `.github/worker_info.md` |
| `KEYS` | `.github/keys_{kategoria}.md` |
| `ERRORS` | `.github/errors_report.md` |
| `SCAN` | `.github/scan_report.md` |

---

## 🔄 Fazy i kategorie

### Faza 1: 🎮 Canary Server
- `npc` - Dialogi NPC
- `scripts` - Skrypty Lua  
- `items` - Przedmioty
- `monsters` - Potwory
- `spells` - Zaklęcia
- `server_cpp` - Kod C++

### Faza 2: 🌐 Website (AAC)
- `web_php` - Backend PHP
- `web_views` - Widoki HTML
- `web_js` - JavaScript

### Faza 3: 📱 Instalka/Klient
- `client_ui` - Interfejs klienta
- `installer` - Instalator

### Faza 4: 🌍 Tłumaczenia
- `translate_pl` - Polski
- `translate_de` - Niemiecki
- `translate_es` - Hiszpański
- `translate_other` - Pozostałe

---

## 📜 Przykłady użycia

### Sprawdź konkretny plik NPC:
```
ANALYZE: Sam.lua
```

### Sprawdź czy NPC ma rzeczy do i18n:
```
PROMPT: sprawdź Sam.lua czy nie ma rzeczy do internacjonalizacji
```

### Pokaż ostatnie 10 edytowanych plików:
```
RECENT: 10
```

### Skanuj katalog NPC:
```
SCAN: data-otservbr-global/npc
```

### Wygeneruj batch 100 kluczy do tłumaczenia:
```
TRANSLATE: 100
```

### Zmiana fazy na Website:
```
PHASE: 2
```

---

## 📊 Log komend

Wykonane komendy są zapisywane w `.github/commands_log.txt`:
```
[2025-12-09 05:00:00] STATUS - wykonano
[2025-12-09 05:02:00] ANALYZE Sam.lua - wykonano
[2025-12-09 05:05:00] PROMPT - wykonano
```

---

## ⚠️ Ważne uwagi

1. **Jedna komenda na raz** - Worker przetwarza jedną komendę i czyści plik
2. **Komentarze ignorowane** - Linie zaczynające się od `#` są pomijane
3. **Case-insensitive** - `PAUSE`, `pause`, `Pause` działają tak samo
4. **Max opóźnienie ~2 min** - Worker sprawdza komendy co 2 minuty
5. **Wyniki w .github/** - Raporty zapisywane są w katalogu `.github/`

---

*🔗 Plik komend: `.github/worker_commands.txt`*
*📋 Log: `.github/commands_log.txt`*
*📁 Wyniki: `.github/*.md`*
