# 📡 I18N Worker - Komendy przez GitHub

Możesz wysyłać komendy do workera przez GitHub.

- Komendy wpisujesz w: `Tibia/silnik/canary_test/.github/worker_commands.txt`
- Worker odczytuje je z `origin/master` (bez `git pull`), więc działa nawet gdy lokalnie są niecommitowane zmiany.
- Guardian robi `git fetch` i co ~2 minuty wypycha status + ACK komend na GitHub (żeby było widać na telefonie).

---

## 🚀 Jak używać (telefon / GitHub)

### 1️⃣ Edytuj plik `.github/worker_commands.txt` na GitHub
- Otwórz plik w repo: `Tibia/silnik/canary_test/.github/worker_commands.txt`
- Kliknij ołówek (Edit)
- Wpisz **jedną** komendę jako nową linię (bez `#`)
- Commit changes

### 2️⃣ Worker wykona komendę
- W następnym cyklu (max ~2 min) worker wykona komendę
- Po wykonaniu komenda zostanie zakomentowana jako `#... Wykonano ...` (ACK)

---

## 📋 Dostępne komendy (AKTUALNE)

Worker obsługuje tylko poniższe komendy (reszta z poprzednich wersji jest nieaktualna):

### 🔧 Migracje / sterowanie

- `FORCE:<kategoria>` – wymuś MIGRATION danej kategorii
- `FORCE:<kategoria>:ONCE` – jak wyżej, ale worker kończy po cyklu
- `COMPACT_KEYS` / `COMPACT_KEYS:ONCE` – generuj mapowanie compact keys (serwer)
- `SYNC:<lang>:<json_file>:<missing>` – wymuś TRANSLATION_SYNC (zaawansowane)
- `AUTO:<lang>:<json_file>:<limit>` – wymuś AUTO_TRANSLATE (limit w kluczach)
- `IDLE` / `IDLE:<reason>:<secs>` / `IDLE:ONCE` – przełącz w tryb IDLE
- `RANDOM` – losowa kategoria migracji
- `STATUS` – wypisz status w logu
- `SKIP` – pomiń cykl
- `PAUSE:<cykle>` – pauza (cykle * delay)
- `NOTE:<tekst>` – dopisz notatkę w logu

### Kategorie (przykłady)

- `npc`, `scripts`, `monsters`, `items`, `spells`, `actions`, `quests`, `raids`, `world`, `libs`, `events`, `chatchannels`, `modules`, `startup`, `npclib`, `cpp`
- OTClient: `otclient_modules`, `otclient_data`, `otclient_mods`, `otclient_tools`, `otclient_src`

---

## ⚠️ Ważne uwagi

1. **Jedna komenda na raz** – wpisuj pojedynczą linię bez `#`
2. **Komentarze ignorowane** – linie zaczynające się od `#` są pomijane
3. **Max opóźnienie ~2 min** – zależy od cyklu workera/guardiana

---

*🔗 Plik komend: `.github/worker_commands.txt`*
*📋 Log: `.github/commands_log.txt`*
*📁 Wyniki: `.github/*.md`*
