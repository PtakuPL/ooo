# 🚧 WIELKI PLAN MIGRACJI I18N — do realizacji w przyszłości

> **Data:** 2026-02-14  
> **Status:** ❌ ZABLOKOWANA (`MIGRATION_ENABLED=false`)  
> **Commit blokady:** ef7e9620d  
> **Docelowe gry:** Tibia (Canary), CS 1.6, WoW, Minecraft, Metin2

---

## 📋 Dlaczego migracja jest zablokowana?

Migracja kodu źródłowego (zamiana hardcoded stringów na klucze i18n w plikach `.lua`, `.cpp`, `.xml` itd.) **nie działa poprawnie**. Główne problemy:

1. **Uszkodzenie plików Lua** — migracja zmieniała składnię plików w sposób powodujący błędy runtime (złe escapowanie, brakujące nawiasy, ucięte stringi)
2. **Brak rollbacku** — po uszkodzeniu pliku nie ma automatycznego przywracania z backupu jeśli backup nie istnieje
3. **Regex-based parsing** — parsowanie Lua/C++ regexem jest zbyt ograniczone:
   - Nie radzi sobie z wielolinijkowymi stringami  
   - Nie rozróżnia komentarzy od kodu
   - Nie widzi kontekstu (string w tablicy vs jako argument funkcji)
4. **Brak pełnego AST** — potrzebny jest parser składniowy (np. `luaparse` dla Lua, `libclang` dla C++)
5. **Niepełna walidacja** — sprawdzanie czy plik po migracji jest poprawny to tylko `lua -p` (syntax), a nie test runtime
6. **Nakładanie się kategorii** — ten sam plik może pasować do wielu kategorii, co powoduje podwójne przetwarzanie

---

## 🎯 Co powinno powstać (cele przyszłej migracji)

### Ogólna architektura

```
[Skan plików]  →  [AST parsing]  →  [Identyfikacja stringów]  →  [Generowanie kluczy]  →  [Zamiana w kodzie]  →  [Walidacja]  →  [Commit]
   PRE_MIGRATION       PARSE              DETECT                   KEYGEN                REWRITE             VALIDATE        DEPLOY
```

### Wymagania minimalne

| Nr | Wymaganie | Priorytet |
|----|-----------|-----------|
| M1 | Parser AST dla każdego języka (Lua, C++, XML, PHP, HTML, JS) | 🔴 KRYTYCZNY |
| M2 | Rozróżnianie stringów do tłumaczenia vs techniczne (zmienne, komendy, ścieżki) | 🔴 KRYTYCZNY |
| M3 | Automatyczny backup + rollback jeśli walidacja po migracji nie przejdzie | 🔴 KRYTYCZNY |
| M4 | Test runtime (nie tylko syntax) po migracji każdego pliku | 🟡 WAŻNY |
| M5 | Dry-run mode (pokaż co by się zmieniło, bez zmieniania) | 🟡 WAŻNY |
| M6 | Deduplikacja kluczy (ten sam tekst → ten sam klucz, nie duplikaty) | 🟡 WAŻNY |
| M7 | Obsługa kontekstu (ten sam tekst w różnych kontekstach = różne klucze) | 🟢 DODATKOWY |
| M8 | Obsługa pluralizacji (1 sztuka vs 5 sztuk) | 🟢 DODATKOWY |
| M9 | Obsługa zmiennych w stringach (`{player}`, `%s`, `..name..`) | 🔴 KRYTYCZNY |
| M10 | Raport z migracji per plik (co zmieniono, ile kluczy dodano) | 🟡 WAŻNY |

---

## 📂 Kategorie migracji (istniejące ~30)

| Kategoria | Katalog | Typy plików | Status skanowania |
|-----------|---------|-------------|-------------------|
| npc | `data-otservbr-global/npc/` | `.lua` | ✅ 699/1027 zmigrowane (stary system) |
| scripts | `data-otservbr-global/scripts/` | `.lua` | 🔄 częściowo |
| monsters | `data-otservbr-global/monster/` | `.lua` | 🔄 częściowo |
| spells | `data-otservbr-global/scripts/spells/` | `.lua` | 🔄 częściowo |
| items | `data-otservbr-global/items/` | `.xml` | 🔄 częściowo |
| raids | `data-otservbr-global/world/` | `.xml` | ❌ |
| world | `data-otservbr-global/world/` | `.xml` | ❌ |
| libs | `data-otservbr-global/lib/` | `.lua` | 🔄 częściowo |
| events | `data-otservbr-global/scripts/` | `.lua` | ❌ |
| cpp | `src/` | `.cpp/.hpp` | 🔄 częściowo |
| php | `web/` | `.php` | ❌ |
| html | `web/` | `.html` | ❌ |
| otclient_modules | `modules/` | `.lua/.otmod` | ❌ |

---

## 🔧 Plan zadań do wykonania (przyszłość)

### Faza 0: Przygotowanie (przed włączeniem migracji)

| # | Zadanie | Opis | Szacowany czas |
|---|---------|------|----------------|
| F0.1 | Analiza istniejących migracji | Przejrzenie 699 zmigrowanych NPC — ile jest poprawnych, ile uszkodzonych | 2-4h |
| F0.2 | Wybór parsera Lua | Ewaluacja: `luaparse` (JS), `ltokenize` (Python), tree-sitter lua | 4h |
| F0.3 | Wybór parsera C++ | Ewaluacja: `libclang`, tree-sitter cpp | 4h |
| F0.4 | Prototyp parsera Lua | Parser wyciągający wszystkie stringi z jednego pliku NPC z kontekstem | 8h |
| F0.5 | Prototyp parsera C++ | Parser wyciągający literały string z `src/*.cpp` | 8h |

### Faza 1: Nowy silnik migracji

| # | Zadanie | Opis | Szacowany czas |
|---|---------|------|----------------|
| F1.1 | Moduł `i18n_ast_lua.py` | Parser Lua z AST: wyciąga stringi, kontekst, pozycję w pliku | 16h |
| F1.2 | Moduł `i18n_ast_cpp.py` | Parser C++ z AST: wyciąga literały string, makra, kontekst | 16h |
| F1.3 | Moduł `i18n_ast_xml.py` | Parser XML: wyciąga atrybuty i treści elementów | 8h |
| F1.4 | Moduł `i18n_rewriter.py` | Zamiana stringów na wywołania i18n z zachowaniem formatowania | 16h |
| F1.5 | Moduł `i18n_validator.py` | Walidacja: syntax + runtime test + porównanie outputu | 8h |
| F1.6 | Moduł `i18n_rollback.py` | Automatyczny rollback: backup → migracja → walidacja → rollback jeśli fail | 4h |
| F1.7 | Dry-run mode | Raport "co by się zmieniło" bez modyfikacji plików | 4h |

### Faza 2: Integracja z workerem

| # | Zadanie | Opis | Szacowany czas |
|---|---------|------|----------------|
| F2.1 | Zmiana `MIGRATION_ENABLED` na `true` | Podłączenie nowego silnika pod case handler | 4h |
| F2.2 | Nowy case handler `MIGRATION` | Zamiana starego regex na calls do AST modułów | 8h |
| F2.3 | Mini-batch z rollbackiem | Przetwarzanie 5 plików → walidacja → commit lub rollback | 4h |
| F2.4 | Raporter migracji | Status per plik w `pre_migration_scan.json` | 4h |
| F2.5 | Testy E2E | 10 plików testowych: NPC, scripts, monsters, cpp | 8h |

### Faza 3: Uniwersalizacja (inne gry)

| # | Zadanie | Opis | Szacowany czas |
|---|---------|------|----------------|
| F3.1 | Abstrakcja silnika | Interfejs `GameMigrationEngine` z pluginami per gra | 8h |
| F3.2 | Plugin: CS 1.6 | Parser plików `.cfg`, `.res`, AmxModX `.sma` | 16h |
| F3.3 | Plugin: WoW | Parser plików `.lua` (AddOn), `.xml` (FrameXML), `.toc` | 16h |
| F3.4 | Plugin: Minecraft | Parser plików `.json` (lang packs), `.properties`, `.yml` (plugin) | 8h |
| F3.5 | Plugin: Metin2 | Parser plików `.py` (quest), `.locale`, `.txt` | 12h |
| F3.6 | CLI wielogryowe | `i18n_migrate --game tibia|cs16|wow|minecraft|metin2 --dir <path>` | 8h |

---

## 🗒️ Notatki

- **Aktualnie działa:** PRE_MIGRATION (skan plików, zliczanie — zero modyfikacji)
- **PRE_MIGRATION zapisuje do:** `i18n/status/pre_migration_scan.json`
- **Stary kod migracji (286 linii):** usunięty w commicie ef7e9620d
- **Flaga do odblokowania:** `MIGRATION_ENABLED=true` w `i18n_worker_simple.sh` linia ~59
- **Przed włączeniem:** wykonać Fazę 0 i Fazę 1 obowiązkowo

---

*Dokument wygenerowany 2026-02-14. Aktualizować po każdym postępie.*
