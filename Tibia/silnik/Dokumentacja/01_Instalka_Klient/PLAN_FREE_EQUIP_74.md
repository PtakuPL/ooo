# PLAN: Free Equip (serwer 7.4) + Hotkeye (modern)

> **Data:** 2026-03-07  
> **Branch:** feature/ticket-gate  
> **Status:** ZAIMPLEMENTOWANE ✅

---

## 1. Opis problemu

W Tibii 7.4 można było położyć **dowolny item w (prawie) dowolny slot** ekwipunku — np. legsy na slot armor, miecz na slot helmet. Ale item w **złym slocie nie dawał żadnych bonusów** (obrona, atak, skille, speed itd.).

Aktualnie serwer Canary wymusza ścisłą walidację: armor → slot armor, legs → slot legs itd. Trzeba dodać tryb "free equip" dla serwera 7.4.

Dodatkowo: hotkeye na runy (itemy) powinny być **odblokowane na modern**, a **zablokowane na 7.4**.

---

## 2. Status — co JUŻ działa

| Funkcja | Classic 7.4 | Modern | Status |
|---------|:-----------:|:------:|--------|
| Hotkeye na itemy/runy | `hotkeys_items = false` | `hotkeys_items = true` | **JUŻ ZROBIONE** ✅ |
| Smart equip (ctrl+klik) | `smart_equip = false` | `smart_equip = true` | **JUŻ ZROBIONE** ✅ |
| Free equip (dowolny item w slocie) | BRAK | nie dotyczy | **DO ZROBIENIA** ❌ |

**Hotkeye na runy:**
- `init.lua` → `classic74.features.hotkeys_items = false` → blokada działa
- `init.lua` → `modern.features.hotkeys_items = true` → odblokowane
- Kod blokady: `hotkeys_manager.lua` → `executeHotkeyItem()` → sprawdza `isFeatureEnabled("hotkeys_items")`
- **Nic nie trzeba zmieniać.**

---

## 3. Decyzje projektowe

### 3.1. Które sloty stają się "free" w trybie 7.4?

| Slot | Stary behavior | 7.4 Free Equip | Uwagi |
|------|:-------------:|:---------------:|-------|
| Head (1) | tylko hełmy | **WOLNY** — dowolny item | brak bonusów w złym slocie |
| Neck (2) | tylko amulety | **WOLNY** — dowolny item | brak bonusów w złym slocie |
| Back (3) | tylko kontenery | **ZABLOKOWANY** — nadal tylko kontenery | plecak = plecak |
| Armor (4) | tylko zbroje | **WOLNY** — dowolny item | brak bonusów w złym slocie |
| Right (5) | broń/tarcza | **WOLNY** — dowolny item | two-hand rule OBOWIĄZUJE |
| Left (6) | broń/tarcza | **WOLNY** — dowolny item | two-hand rule OBOWIĄZUJE |
| Legs (7) | tylko legginsy | **WOLNY** — dowolny item | brak bonusów w złym slocie |
| Feet (8) | tylko buty | **WOLNY** — dowolny item | brak bonusów w złym slocie |
| Ring (9) | tylko pierścionki | **ZABLOKOWANY** — nadal tylko ringi | pierścionek = pierścionek |
| Ammo (10) | tylko ammo | **WOLNY** — dowolny item | brak bonusów w złym slocie |

### 3.2. Wyjątki

1. **Backpack slot** — ZAWSZE wymaga kontenera (nie zmienia się)
2. **Ring slot** — ZAWSZE wymaga pierścionka (nie zmienia się)
3. **Two-hand rule** — 2H broń nadal blokuje drugą rękę (nie zmienia się)
4. **Item musi być pickupable** — niespełnione = odrzucenie (nie zmienia się)

### 3.3. Kluczowa zasada bonusów

> Gdy `enableFreeEquip = true` i item jest w **złym slocie** (np. legs na slot armor):
> - Item **jest widoczny** w slocie (wizualnie equipped)
> - Item **NIE daje bonusów** (def, atk, skills, speed, regen, imbuements)
> - `player->setItemAbility(slot, false)` — slot nie ma aktywnych zdolności

### 3.4. Zakres serwerów

| Serwer | Folder kodu źródłowego | Config | `enableFreeEquip` |
|--------|----------------------|--------|-------------------|
| Classic 7.4 | `canary_test/src/` | `canary_test/config.lua` | **true** |
| Modern | `canary/src/` (nie modyfikujemy!) | `canary_modern/config.lua` | **false** (default) |

**Modyfikujemy TYLKO `canary_test/src/`** — serwer modern korzysta z binarki z `canary/` i tam domyślna wartość `false` zapewnia standardowe zachowanie.

---

## 4. Zadania implementacyjne

### Z-01: Nowy config `FREE_EQUIP` (C++ serwer)

**Pliki:**
- `canary_test/src/config/config_enums.hpp` — dodać `FREE_EQUIP` do enuma
- `canary_test/src/config/configmanager.cpp` — dodać `loadBoolConfig(L, FREE_EQUIP, "enableFreeEquip", false)`

**Efekt:** Serwer wczytuje opcję z config.lua.

---

### Z-02: Modyfikacja `Player::queryAdd()` — dowolny item w slocie

**Plik:** `canary_test/src/creatures/players/player.cpp` (linia ~4426)

**Logika:**
```cpp
bool enableFreeEquip = g_configManager().getBoolean(FREE_EQUIP);

if (enableFreeEquip && item->isPickupable()) {
    // Free equip: bypass slot validation
    // ALE zachowaj wyjątki:
    switch (index) {
        case CONST_SLOT_BACKPACK:
            // Backpack MUSI być kontenerem
            if (slotPosition & SLOTP_BACKPACK)
                ret = RETURNVALUE_NOERROR;
            // else: ret zostaje CANNOTBEDRESSED
            break;

        case CONST_SLOT_RING:
            // Ring MUSI być pierścionkiem
            if (slotPosition & SLOTP_RING)
                ret = RETURNVALUE_NOERROR;
            break;

        case CONST_SLOT_LEFT:
        case CONST_SLOT_RIGHT:
            // Zachowaj two-hand rule
            // ... (istniejąca logika two-hand)
            ret = RETURNVALUE_NOERROR;
            // ALE sprawdź two-hand conflicts
            break;

        default:
            // Wszystkie inne sloty = wolne
            ret = RETURNVALUE_NOERROR;
            break;
    }
} else {
    // Normalny tryb (modern) — pełna walidacja jak teraz
    // ... istniejący switch(index) bez zmian
}
```

---

### Z-03: Helper `isItemInCorrectSlot()` 

**Plik:** `canary_test/src/creatures/players/player.cpp` (lub player.h)

```cpp
static bool isItemInCorrectSlot(const std::shared_ptr<Item>& item, Slots_t slot) {
    uint32_t slotPos = item->getSlotPosition();
    switch (slot) {
        case CONST_SLOT_HEAD:      return (slotPos & SLOTP_HEAD) != 0;
        case CONST_SLOT_NECKLACE:  return (slotPos & SLOTP_NECKLACE) != 0;
        case CONST_SLOT_BACKPACK:  return (slotPos & SLOTP_BACKPACK) != 0;
        case CONST_SLOT_ARMOR:     return (slotPos & SLOTP_ARMOR) != 0;
        case CONST_SLOT_RIGHT:     return (slotPos & SLOTP_RIGHT) != 0;
        case CONST_SLOT_LEFT:      return (slotPos & SLOTP_LEFT) != 0;
        case CONST_SLOT_LEGS:      return (slotPos & SLOTP_LEGS) != 0;
        case CONST_SLOT_FEET:      return (slotPos & SLOTP_FEET) != 0;
        case CONST_SLOT_RING:      return (slotPos & SLOTP_RING) != 0;
        case CONST_SLOT_AMMO:      return (slotPos & SLOTP_AMMO) != 0;
        default:                   return true;
    }
}
```

---

### Z-04: Modyfikacja `MoveEvent::EquipItem()` — brak bonusów w złym slocie

**Plik:** `canary_test/src/lua/creature/movement.cpp` (~linia 508-628)

**Logika — PRZED aplikowaniem bonusów:**
```cpp
bool freeEquip = g_configManager().getBoolean(FREE_EQUIP);
bool correctSlot = isItemInCorrectSlot(item, slot);

if (freeEquip && !correctSlot) {
    // Item w złym slocie — NIE aplikuj bonusów
    player->setItemAbility(slot, false);
    return 1;  // equip success, ale zero bonusów
}

// ... normalny kod aplikujący bonusy (jak jest teraz)
```

---

### Z-05: Modyfikacja `MoveEvent::DeEquipItem()` — symetryczny fix

**Plik:** `canary_test/src/lua/creature/movement.cpp`

**Logika:**
```cpp
bool freeEquip = g_configManager().getBoolean(FREE_EQUIP);
bool correctSlot = isItemInCorrectSlot(item, slot);

if (freeEquip && !correctSlot) {
    // Item był w złym slocie — nie było bonusów, nie ma co odejmować
    player->setItemAbility(slot, false);
    return 1;
}

// ... normalny kod odejmujący bonusy (jak jest teraz)
```

---

### Z-06: Konfiguracja serwerów (config.lua)

| Plik | Zmiana |
|------|--------|
| `canary_test/config.lua` | dodać `enableFreeEquip = true` |
| `canary_test/config.lua.dist` | dodać `enableFreeEquip = false` (z komentarzem) |
| `canary_modern/config.lua` | dodać `enableFreeEquip = false` (explicit) |

---

### Z-07: Weryfikacja hotkey (nic do zrobienia) ✅

Potwierdzone:
- `classic74.features.hotkeys_items = false` → runy zablokowane
- `modern.features.hotkeys_items = true` → runy odblokowane
- Kod: `executeHotkeyItem()` w `hotkeys_manager.lua`

**Żadne zmiany w kliencie (Lua) nie są potrzebne.**

---

## 5. Pliki do modyfikacji — pełna lista

| # | Plik | Typ |
|---|------|-----|
| 1 | `canary_test/src/config/config_enums.hpp` | +1 enum |
| 2 | `canary_test/src/config/configmanager.cpp` | +1 loadBoolConfig |
| 3 | `canary_test/src/creatures/players/player.cpp` | modyfikacja queryAdd() |
| 4 | `canary_test/src/creatures/players/player.h` | +1 static helper (opcjonalnie) |
| 5 | `canary_test/src/lua/creature/movement.cpp` | modyfikacja EquipItem() + DeEquipItem() |
| 6 | `canary_test/config.lua` | +1 linia |
| 7 | `canary_test/config.lua.dist` | +1 linia z komentarzem |
| 8 | `canary_modern/config.lua` | +1 linia (false) |

**Klient (Lua) — 0 zmian.**  
**Serwer modern (`canary/src/`) — 0 zmian.**

---

## 6. Ryzyko i uwagi

- **Efekt only server-side:** Klient nie wie nic o free equip — to serwer pozwala na ruch itemu. Klient po prostu wysyła `move(item, pos)`.
- **Imbuementy:** Gdy item w złym slocie, imbuementy NIE się aktywują (bo EquipItem wraca wcześniej).
- **Testowanie:** Po kompilacji canary_test trzeba ręcznie przetestować: połóż legs na slot armor → sprawdź czy defense nie wzrasta.
- **Kompatybilność wstecz:** `enableFreeEquip = false` (domyślna) = zachowanie identyczne jak teraz.
