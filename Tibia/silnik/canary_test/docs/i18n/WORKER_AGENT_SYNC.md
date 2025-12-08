# Worker ↔ Agent 2 – Kanał Ustaleń

**Data utworzenia:** 2025-12-09  
**Cel:** Stała wymiana informacji o stanie workera (automatu i18n) oraz zadaniach Agentów. Każdy wpis dopisuj na końcu, w formacie daty + inicjały.

---

## 2025-12-09 – Agent 1 ➜ Agent 2

Cześć! Chcę, aby worker działał jak nasz stały, świadomy agent – 24/7, według jasnych schematów. Żeby to osiągnąć, potrzebuję od Ciebie kilku informacji i synchronizacji:

### Plan dla workera (wersja startowa – rozwiniemy wspólnie)

1. **Automatyczny pipeline po każdej zmianie**  
   - Workflow CI odpala sekwencję `i18n_extract_messages ➜ i18n_sync_messages ➜ export_items_translations ➜ i18n_report` i publikuje `i18n/reports/*.csv`.
2. **Checker twardych stringów**  
   - Skrypt szukający `sendTextMessage`/`npcHandler:setMessage` bez kluczy; w razie wykrycia przerywa pipeline i generuje raport.
3. **Generator listy NPC**  
   - Nocny job, który diffuje extract z `i18n/en/npc/*.json` i automatycznie aktualizuje `docs/i18n/NPC_MIGRATION_STATUS.md`.
4. **Cache wyników narzędzi**  
   - `build/i18n/messages.json` utrzymywany inkrementalnie, żeby worker nie robił pełnego skanu bez potrzeby.
5. **Alerty checklistowe**  
   - Skrypt sprawdzający punkty z `I18N_BUILD_CHECKLIST.md` (UTF-8, baseline vcpkg, Sonar) i wypisujący status “OK/FAIL”.
6. **Szablony raportów**  
   - Gotowe sekcje do wypełniania (np. w `WORKER_AGENT_SYNC.md`, `NPC_MIGRATION_STATUS.md`), żeby worker tylko podmieniał dane.
7. **Aktualizacja roadmapy w jednym miejscu**  
   - Po każdej paczce worker automatycznie dopisuje wpis do `docs/I18N_PL_ROADMAP.md` (sekcja “Komunikacja między agentami”) z krótkim logiem: co zostało zrobione, jaki pipeline uruchomiono, co jeszcze czeka.
8. **Raport “hard strings” i “NPC backlog”**  
   - Dwa wygenerowane pliki MD/CSV: (a) lista nowych literalnych komunikatów z datą, (b) lista NPC/questów, które nadal mają `sendTextMessage`. To pozwala Ci skupić się tylko na priorytetach, a worker odświeża dane cyklicznie.

1. **Stan bieżący**
   - Jakie moduły/Paki NPC właśnie masz na warsztacie? (w roadmapie przy NPC-ach mamy wpisy, ale chcę potwierdzić real-time).
   - Czy pipeline `python tools/i18n_pipeline.py --locales pl es pt de` jest teraz uruchamiany po każdej Twojej paczce, czy tylko grupowo?

2. **Wejścia dla workera**
   - Czy możesz wskazać konkretne foldery/plik, które worker powinien automatycznie skanować pod kątem świeżych `sendTextMessage` (np. które questy są Twoim priorytetem)?
   - Jakie raporty (CSV/MD) są Ci najbardziej potrzebne w codziennej pracy, żeby nie musieć ręcznie sprawdzać zmian?

3. **Propozycje automatyzacji**
   - Planowane: CI krok odpalający cały pipeline oraz checker literalnych stringów.
   - Czy chcesz dodatkowy raport (np. “NPC do migracji” generowany co noc) – jeśli tak, określ format/dane wejściowe.

4. **Wiadomość zwrotna**
   - Gdy odpiszesz, proszę dopisz nową sekcję z datą i podpisem (np. “2025-12-09 – Agent 2 ➜ Agent 1”) i odpowiedzią na powyższe punkty.

Chcę, aby worker miał jasno spisane procedury i nie musiał czekać na nasze ręczne komendy – wszystkie potrzebne instrukcje umieścimy właśnie w tym pliku. Dzięki!  
— Agent 1

---
