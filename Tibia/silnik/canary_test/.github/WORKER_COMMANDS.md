# 📡 I18N Worker - GitHub Command Terminal

> **Wersja:** 1.0 | **Aktualizacja:** 2025-12-09

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
- Wyczyści `worker_commands.txt`

---

## 📋 Dostępne komendy

| Komenda | Opis | Przykład |
|---------|------|----------|
| `PAUSE` | Zatrzymaj worker (czeka 1h) | `PAUSE` |
| `RESUME` | Wznów pracę | `RESUME` |
| `STATUS` | Wymuś aktualizację statusu | `STATUS` |
| `PUSH` | Wymuś natychmiastowy push | `PUSH` |
| `RESTART` | Restartuj worker | `RESTART` |
| `PHASE: N` | Przejdź do fazy N (1-4) | `PHASE: 2` |
| `CATEGORY: xxx` | Zmień kategorię | `CATEGORY: monsters` |
| `TRANSLATE: N` | Wygeneruj batch N kluczy | `TRANSLATE: 50` |

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

### Zmiana fazy na Website:
```
PHASE: 2
```

### Wygeneruj batch 100 kluczy do tłumaczenia:
```
TRANSLATE: 100
```

### Przejdź do kategorii monsters:
```
CATEGORY: monsters
```

### Zatrzymaj worker na chwilę:
```
PAUSE
```

---

## 📊 Log komend

Wykonane komendy są zapisywane w `.github/commands_log.txt`:
```
[2025-12-09 04:50:00] STATUS - wykonano
[2025-12-09 04:52:00] TRANSLATE 50 - wykonano
[2025-12-09 04:55:00] PHASE 2 - wykonano
```

---

## ⚠️ Ważne uwagi

1. **Tylko jedna komenda na raz** - Worker przetwarza jedną komendę i czyści plik
2. **Komentarze ignorowane** - Linie zaczynające się od `#` są pomijane
3. **Case-insensitive** - `PAUSE`, `pause`, `Pause` działają tak samo
4. **Max opóźnienie ~2 min** - Worker sprawdza komendy co 2 minuty

---

*🔗 Plik komend: `.github/worker_commands.txt`*
*📋 Log: `.github/commands_log.txt`*
