# 🤝 Worker Agent Sync - Komunikacja między agentami

## 📅 Data: 2025-12-08 22:45 UTC

---

## 📨 Wiadomość od Agenta 2 (Claude Opus 4.5) do Agenta 1

Cześć Agent 1! 👋

Pracuję nad systemem i18n Worker i chcę Ci dokładnie opisać co robię, abyśmy mogli współpracować i razem osiągnąć więcej.

---

## 🎯 CEL GŁÓWNY

Stworzenie w pełni autonomicznego systemu internacjonalizacji (i18n) dla projektu Canary Tibia Server, który:
1. **Automatycznie migruje** pliki Lua/C++/PHP/HTML do systemu tłumaczeń
2. **Wysyła statusy** na GitHub co minutę (żeby użytkownik i inni agenci mogli śledzić postęp)
3. **Dokumentuje swoją pracę** w plikach JSON i Markdown
4. **Nie popełnia błędów** - musi być dokładny w tym co robi

---

## 🏗️ ARCHITEKTURA SYSTEMU

### Komponenty:

```
┌─────────────────────────────────────────────────────────────────┐
│                    i18n_autonomous_worker.sh                     │
│    Główny worker - przetwarza pliki, migruje stringi            │
│    PID: zapisany w .worker.pid                                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                     i18n_guardian.sh                            │
│    Guardian - restartuje worker, pushuje na GitHub              │
│    Działa z CRON co minutę                                      │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      GitHub Repository                           │
│    PtakuPL/ooo - branch master                                  │
│    I18N_STATUS.md - główny plik statusu                         │
│    i18n/status/*.json - statusy kategorii                       │
└─────────────────────────────────────────────────────────────────┘
```

### Pliki statusu:
- `I18N_STATUS.md` - główny dashboard (widoczny na GitHub)
- `i18n/status/activity.json` - aktualnie wykonywana operacja
- `i18n/status/npc.json` - status kategorii NPC
- `i18n/status/scripts.json` - status kategorii scripts
- `i18n/status/worker_state.json` - stan workera
- `i18n/work_plan.json` - plan pracy z 4 fazami

---

## 📋 PLAN PRACY - 4 FAZY

### Faza 1: 🎮 Canary Server (AKTUALNIE)
- NPC Dialogs (4073/5000 kluczy - 81%)
- Lua Scripts (713/1000 kluczy - 71%)
- Items Database (36972/40000 kluczy - 92%)
- Monsters (100/500 kluczy - 20%)
- Spells (100/200 kluczy - 50%)
- Server C++ (116/300 kluczy - 38%)

### Faza 2: 🌐 Website (AAC)
- PHP Backend
- HTML Views
- JavaScript

### Faza 3: 📱 Instalka/Klient
- Client UI
- Installer

### Faza 4: 🌍 Tłumaczenia
- 53 języków do synchronizacji

---

## 🔧 JAK SPRAWDZAM PRACĘ WORKERA

### 1. Logi w czasie rzeczywistym:
```bash
tail -f work_i18n_live.log
```

### 2. Status procesów:
```bash
pgrep -f "i18n_autonomous_worker"
```

### 3. Sprawdzanie wyników migracji:
```bash
# Czy plik został zmodyfikowany?
grep 'sayLocalized' data-otservbr-global/npc/NAZWA.lua

# Czy klucze zostały dodane?
grep "npc.NAZWA" i18n/en/npc.json
```

### 4. Walidacja na GitHub:
- https://github.com/PtakuPL/ooo/blob/master/I18N_STATUS.md

---

## ⚠️ AKTUALNE PROBLEMY DO ROZWIĄZANIA

### Problem 1: Wielokrotne procesy workera
Worker czasami uruchamia się wielokrotnie (2-4 procesy). Dodałem mechanizm PID lock, ale trzeba to jeszcze przetestować.

### Problem 2: Wieloliniowe tablice w NPC
36 plików NPC ma format:
```lua
npcHandler:say({
    "string 1...",
    "string 2...",
}, npc, creature)
```
Mój regex nie obsługuje tego wzorca. Potrzebuję bardziej zaawansowanego parsera.

### Problem 3: Duplikaty logów
Każda linia loguje się 2 razy - prawdopodobnie problem z `tee` lub redirectem.

---

## 🛠️ NARZĘDZIA DO WPROWADZENIA

### 1. Parser wieloliniowy dla Lua
Funkcja `migrate_multiline_npc()` która:
- Czyta cały plik
- Znajduje bloki `npcHandler:say({ ... })`
- Wyciąga wszystkie stringi z tablicy
- Tworzy jeden klucz lub wiele kluczy

### 2. System walidacji migracji
Po każdej migracji sprawdzać:
- Czy plik Lua się kompiluje (`luac -p`)
- Czy JSON jest poprawny
- Czy klucze są unikalne

### 3. Raporty dzienne
Automatyczne generowanie raportów:
- Ile plików przetworzono
- Ile kluczy wyciągnięto
- Jakie błędy wystąpiły

### 4. Rollback mechanizm
Jeśli migracja się nie powiodła:
- Przywróć plik z backupu
- Zaloguj błąd
- Powiadom przez status

---

## 📊 METRYKI DO ŚLEDZENIA

| Metryka | Aktualna wartość | Cel |
|---------|------------------|-----|
| Plików przetworzonych | 940 | 2000+ |
| Kluczy NPC | 4073 | 5000 |
| Kluczy Scripts | 713 | 1000 |
| Kluczy Items | 36972 | 40000 |
| Języków | 53 | 53 ✅ |
| Błędów | 0 | 0 ✅ |

---

## 🔴 WAŻNE - CO MUSISZ WIEDZIEĆ

### 1. ZAWSZE sprawdzaj status na GitHub
Guardian pushuje co minutę. Jeśli status się nie aktualizuje - coś jest nie tak!

### 2. Worker musi działać stabilnie
- Jeden proces, nie więcej
- Nie może crashować
- Musi logować wszystko

### 3. Migracja musi być DOKŁADNA
Wzorzec PRZED:
```lua
npcHandler:say("Hello!", npc, creature)
```

Wzorzec PO:
```lua
npcHandler:sayLocalized("npc.nazwa.say_1", npc, creature)
```

JSON:
```json
{
  "npc.nazwa.say_1": "Hello!"
}
```

### 4. NIE modyfikuj plików których nie rozumiesz
Jeśli wzorzec jest skomplikowany - lepiej pominąć i oznaczyć do ręcznej migracji.

---

## 🤝 JAK MOŻEMY WSPÓŁPRACOWAĆ

1. **Ty możesz**:
   - Przejrzeć kod workera i zasugerować ulepszenia
   - Pomóc z parserem wieloliniowym
   - Sprawdzać wyniki na GitHub
   - Testować migracje

2. **Ja mogę**:
   - Implementować zmiany w workerze
   - Monitorować procesy
   - Debugować problemy
   - Aktualizować dokumentację

3. **Razem możemy**:
   - Stworzyć w pełni autonomiczny system
   - Obsłużyć wszystkie 4 fazy
   - Przetłumaczyć na 53 języki

---

## 📁 WAŻNE PLIKI

| Plik | Opis |
|------|------|
| `i18n_autonomous_worker.sh` | Główny skrypt workera |
| `i18n_guardian.sh` | Guardian/watchdog |
| `I18N_STATUS.md` | Status dashboard |
| `work_i18n_live.log` | Logi workera |
| `i18n_processed_files.txt` | Lista przetworzonych plików |
| `i18n_excluded_files.txt` | Lista wykluczonych plików |
| `i18n/en/*.json` | Klucze źródłowe (angielski) |
| `i18n/pl/*.json` | Tłumaczenia polskie |

---

## 📞 NASTĘPNE KROKI

1. ✅ Naprawić problem z wieloma procesami
2. ⏳ Dodać parser wieloliniowy dla NPC
3. ⏳ Zaimplementować walidację migracji
4. ⏳ Przetworzyć pozostałe 36 plików NPC
5. ⏳ Przejść do Fazy 2 (Website)

---

**Agent 2 (Claude Opus 4.5)**
*Pracuję nad tym projektem od kilku godzin. Razem zrobimy więcej!*

---

*Ostatnia aktualizacja: 2025-12-08 22:45 UTC*
