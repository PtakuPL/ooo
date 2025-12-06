# 🚀 Raport Warstwy 6 - Installer/Launcher Multi-Language Audit

**Data generowania:** 2025-12-06

---

## 1. Analiza modułu client_entergame

**Pliki w module:** 8

- entergame.lua
- createAccount.lua
- characterlist.otui
- waitinglist.otui
- characterlist.lua
- entergame.otmod
- createAccount.otui
- entergame.otui

### Użycia tr() (66 znalezionych)

| Plik | Linia | Klucz tłumaczenia |
|------|-------|-------------------|
| entergame.lua | 23 | `Login Error` |
| entergame.lua | 85 | `Message of the day` |
| entergame.lua | 108 | `Update needed` |
| entergame.lua | 117 | `Journey Onwards` |
| entergame.lua | 118 | `Email:` |
| entergame.lua | 119 | `Remember Email:` |
| entergame.lua | 121 | `Enter Game` |
| entergame.lua | 122 | `Acc Name:` |
| entergame.lua | 123 | `Remember password:` |
| entergame.lua | 588 | `Login Error` |
| entergame.lua | 614 | `Please wait` |
| entergame.lua | 616 | `Please wait` |
| entergame.lua | 720 | `Login Error` |
| entergame.lua | 741 | `Please wait` |
| entergame.lua | 762 | `Login Error` |
| entergame.lua | 773 | `Message of the day` |
| characterlist.otui | 153 | `Character List` |
| characterlist.otui | 195 | `Character` |
| characterlist.otui | 206 | `Status` |
| characterlist.otui | 217 | `Level` |

### Hardcoded teksty (66 znalezionych)

| Plik | Linia | Tekst |
|------|-------|-------|
| characterlist.otui | 153 | `tr('Character List')` |
| characterlist.otui | 195 | `tr('Character') .. ''` |
| characterlist.otui | 206 | `tr('Status') .. ''` |
| characterlist.otui | 217 | `tr('Level') .. ''` |
| characterlist.otui | 228 | `tr('Vocation') .. ''` |
| characterlist.otui | 239 | `tr('World') .. ''` |
| characterlist.otui | 296 | `tr('Account Status') .. ':'` |
| characterlist.otui | 321 | `tr('Free Account')` |
| characterlist.otui | 364 | `tr('Ok')` |
| characterlist.otui | 373 | `tr('Cancel')` |
| waitinglist.otui | 3 | `tr('Waiting List')` |
| waitinglist.otui | 41 | `tr('Cancel')` |
| createAccount.otui | 57 | `"Start Your Journey"` |
| createAccount.otui | 103 | `"Create Your Account"` |
| createAccount.otui | 116 | `tr('Email:')` |
| createAccount.otui | 129 | `tr('Password:')` |
| createAccount.otui | 140 | `tr('Repeat Password:')` |
| createAccount.otui | 155 | `"I agree to the Tibia Service Agreement,\n Tibia R` |
| createAccount.otui | 171 | `"Create Your Character"` |
| createAccount.otui | 193 | `tr('Character Name:')` |
| createAccount.otui | 210 | `"Suggest Name"` |
| createAccount.otui | 226 | `Character Sex:` |
| createAccount.otui | 230 | `tr("male")` |
| createAccount.otui | 236 | `tr("female")` |
| createAccount.otui | 259 | `Recommended World:` |
| createAccount.otui | 263 | `tr("Canary (America)")` |
| createAccount.otui | 273 | `"Change World"` |
| createAccount.otui | 284 | `"Already Registered"` |
| createAccount.otui | 294 | `"Start Playing"` |
| createAccount.otui | 320 | `"This site is protected by ReCAPTCHA and  the goog` |

## 2. Pliki launchera

**Znaleziono 14 plików powiązanych z launcherem:**

- android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
- android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml
- android/app/src/main/res/mipmap-mdpi/ic_launcher.webp
- android/app/src/main/res/mipmap-mdpi/ic_launcher_round.webp
- android/app/src/main/res/mipmap-hdpi/ic_launcher.webp
- android/app/src/main/res/mipmap-hdpi/ic_launcher_round.webp
- android/app/src/main/res/drawable-v24/ic_launcher_foreground.xml
- android/app/src/main/res/mipmap-xhdpi/ic_launcher.webp
- android/app/src/main/res/mipmap-xhdpi/ic_launcher_round.webp
- android/app/src/main/res/mipmap-xxhdpi/ic_launcher.webp
- android/app/src/main/res/mipmap-xxhdpi/ic_launcher_round.webp
- android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.webp
- android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.webp
- android/app/src/main/res/drawable/ic_launcher_background.xml

## 3. Analiza modułu updater

**Pliki w module updater:** 3

- updater.otui
- updater.otmod
- updater.lua

## 4. Pliki zasobów lokalizacji (.resx)

⚠️ Nie znaleziono plików .resx

Uwaga: Pliki .resx są używane przez .NET/C# aplikacje do lokalizacji.

Jeśli launcher jest napisany w innej technologii, może używać innego systemu.


## 5. Pliki XAML (WPF/UWP)

✅ Brak plików XAML w projekcie.

Uwaga: Launcher może być osobną aplikacją lub używać innej technologii UI.


## 6. Podsumowanie

### Stan lokalizacji ekranu logowania (client_entergame):

- **Plików:** 2
- **Użyć tr():** 66
- **Hardcoded tekstów:** 66

⚠️ Wiele hardcoded tekstów - wymaga lokalizacji.

### Rekomendacje:

1. **Zamienić hardcoded teksty na tr() calls** w plikach .otui
2. **Dodać brakujące klucze do locale files** w data/locales/
3. **Jeśli launcher jest osobną aplikacją:**
   - Utworzyć pliki .resx dla każdego języka
   - Lub zintegrować z systemem tr() klienta
4. **Przetestować ekran logowania** we wszystkich obsługiwanych językach

## 7. Teksty wymagające lokalizacji

| Tekst | Wystąpienia |
|-------|-------------|
| `"Already Registered"` | 1 |
| `"Change World"` | 1 |
| `"Create Your Account"` | 1 |
| `"Create Your Character"` | 1 |
| `"I agree to the Tibia Service Agreement,` | 1 |
| `"Ok"` | 1 |
| `"Reset"` | 1 |
| `"Select a Game World to Play On"` | 1 |
| `"Start Playing"` | 1 |
| `"Start Your Journey"` | 1 |
| `"Suggest Name"` | 1 |
| `"This site is protected by ReCAPTCHA and` | 1 |
| `"back"` | 1 |
| `10 - 29 Characters` | 1 |
| `7171` | 1 |
| `At least one lower case letter (a-z)` | 1 |
| `At least one number(0-9)` | 1 |
| `At least one upper case letter (A-Z)` | 1 |
| `BattleEye Status:` | 1 |
| `Character Sex:` | 1 |
| `Creation Date` | 1 |
| `Information` | 1 |
| `No invalid Character` | 1 |
| `Password Requirements` | 1 |
| `Player Online:` | 1 |
| `Premium Only:` | 1 |
| `PvP Type:` | 1 |
| `Pvp Type:` | 1 |
| `Recommended World:` | 1 |
| `Transfer Type:` | 1 |

---

*Raport wygenerowany automatycznie przez Installer/Launcher Multi-Language Auditor*