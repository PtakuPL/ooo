# SerwerCanary — Fresh Install Runbook

> Od zera do działającego launchera + serwera Canary.
> Ostatnia aktualizacja: 2026-03-05

## Spis treści

1. [Wymagania](#1-wymagania)
2. [Architektura](#2-architektura)
3. [Diagram sieciowy](#3-diagram-sieciowy)
4. [Krok po kroku: Serwer Canary](#4-krok-po-kroku-serwer-canary)
5. [Krok po kroku: API (PHP + nginx)](#5-krok-po-kroku-api-php--nginx)
6. [Krok po kroku: Launcher (Rust + Tauri)](#6-krok-po-kroku-launcher-rust--tauri)
7. [Krok po kroku: OTClient](#7-krok-po-kroku-otclient)
8. [Testowanie update/repair](#8-testowanie-updaterepair)
9. [Troubleshooting](#9-troubleshooting)
10. [Konfiguracja portów](#10-konfiguracja-portów)

---

## 1. Wymagania

### Software (serwer)
- Ubuntu 22.04+ lub 24.04 (x64)
- MySQL 8.0+ (lub MariaDB 10.6+)
- PHP 8.1+ z: `mysqli`, `json`, `mbstring`, `openssl`
- nginx (lub Apache z mod_rewrite)
- Certyfikat SSL (self-signed dla dev, Let's Encrypt dla prod)

### Software (build)
- Rust 1.75+ (launcher)
- Node.js 18+ (Tauri frontend)
- CMake 3.22+ + vcpkg (OTClient)
- GitHub Actions (CI/CD)

### Hardware (minimum)
- 2 vCPU, 4 GB RAM, 20 GB SSD (serwer)
- 4 vCPU, 8 GB RAM (build OTClient)

---

## 2. Architektura

```
┌─────────────────────────────────────────────────────────┐
│                       GRACZ                              │
│  ┌──────────┐    ┌──────────┐    ┌──────────────────┐   │
│  │ Launcher  │───▶│  API     │───▶│  Serwer Canary   │   │
│  │ (Tauri)   │    │  (PHP)   │    │  (login+game)    │   │
│  └──────────┘    └──────────┘    └──────────────────┘   │
│       │                │                    │            │
│       ▼                ▼                    ▼            │
│  OTClient         MySQL DB            Canary binary     │
│  (pobierany)      (canaryaac)         (data-otservbr)   │
└─────────────────────────────────────────────────────────┘
```

---

## 3. Diagram sieciowy

```
┌─────────────────────────────────────────────────────┐
│                    SERWER                             │
│                                                       │
│  ┌───────────┐  :443 (HTTPS)                         │
│  │   nginx   │◄─────────── Launcher / Przeglądarka    │
│  └─────┬─────┘                                       │
│        │  fastcgi_pass :9000                          │
│        ▼                                              │
│  ┌───────────┐                                       │
│  │  PHP-FPM  │  Endpointy:                           │
│  │           │  /apik/v1/update.php     (manifest)    │
│  │           │  /apik/v1/server-status.php            │
│  │           │  /apik/v1/launcher-token.php           │
│  │           │  /apik/v1/challenge.php                │
│  │           │  /apik/v1/error-report.php             │
│  │           │  /apik/v1/generate_manifest.php (CLI)  │
│  │           │  /apik/v1/dashboard-errors.php         │
│  └─────┬─────┘                                       │
│        │  :3306                                       │
│        ▼                                              │
│  ┌───────────┐                                       │
│  │   MySQL   │  DB: canaryaac                         │
│  │           │  Tabele: 105 (48 canary + 41 myaac     │
│  │           │          + 6 arena + 6 ext + 4 lnchr)  │
│  │           │  EVENT_SCHEDULER: ON                    │
│  └───────────┘                                       │
│                                                       │
│  ┌───────────┐  :7171 (login protocol)               │
│  │  Canary   │◄─────────── OTClient (login)           │
│  │  Server   │  :7172 (game protocol)                │
│  │           │◄─────────── OTClient (gra)             │
│  └───────────┘                                       │
│                                                       │
│  Pliki klienta: /var/www/html/apik/v1/files/          │
│  Logi security: /var/log/serwercanary/                │
└─────────────────────────────────────────────────────┘
```

**Porty:**
| Port  | Protokół | Usługa                    |
|-------|----------|---------------------------|
| 443   | TCP/TLS  | nginx → PHP API           |
| 7171  | TCP      | Canary login protocol     |
| 7172  | TCP      | Canary game protocol      |
| 3306  | TCP      | MySQL (tylko localhost)    |
| 9000  | TCP      | PHP-FPM (tylko localhost)  |

---

## 4. Krok po kroku: Serwer Canary

### 4.1. Klonowanie repo i build
```bash
cd /home/ptaku/serweryt/Tibia/silnik/canary
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
```

### 4.2. Baza danych
```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS canaryaac"
mysql -u root -p canaryaac < schema.sql
```

### 4.3. Konfiguracja
```bash
cp config.lua.dist config.lua
# Edytuj config.lua:
#   ip = "127.0.0.1"
#   loginProtocolPort = 7171
#   gameProtocolPort = 7172
#   mysqlHost = "127.0.0.1"
#   mysqlUser = "..."
#   mysqlPass = "..."
#   mysqlDatabase = "canaryaac"
```

### 4.4. Uruchomienie
```bash
./canary &
# Lub przez screen/tmux:
screen -dmS canary ./canary
```

### 4.5. Weryfikacja
```bash
# Sprawdź czy nasłuchuje:
ss -tlnp | grep -E '7171|7172'
# Oczekiwany output:
# LISTEN  0  128  0.0.0.0:7171  ... canary
# LISTEN  0  128  0.0.0.0:7172  ... canary
```

---

## 5. Krok po kroku: API (PHP + nginx)

### 5.1. Struktura plików
```
/var/www/html/apik/v1/
├── .env                     # konfiguracja (DB, porty, sekrety)
├── common.php               # shared utilities
├── update.php               # manifest endpoint (→ manifests/)
├── server-status.php        # status serwerów
├── launcher-token.php       # launch token (ticket gate)
├── challenge.php            # nonce challenge
├── error-report.php         # error reporting
├── dashboard-errors.php     # log viewer
├── generate_manifest.php    # CLI: generacja manifestu
├── login.php                # legacy login
├── manifests/               # wygenerowane manifesty
│   └── stable/
│       └── 1.0.2.json
├── files/                   # pliki klienta do pobrania
│   └── stable/
│       └── 1.0.2/
│           ├── otclient.exe
│           ├── data/
│           └── modules/
└── migrations/              # migracje SQL
    ├── migrate.php
    ├── 001_ticket_gate_rollout.sql
    ├── 002_launcher_tables_rollout.sql
    └── 003_cleanup_events_rollout.sql
```

### 5.2. Konfiguracja .env
```bash
cat > /var/www/html/apik/v1/.env << 'EOF'
DB_HOST='127.0.0.1'
DB_NAME='canaryaac'
DB_USER='ptaku'
DB_PASS='<hasło>'
DB_PORT=3306

TICKET_SECRET='<losowy-32+-znakowy-sekret>'

WORLD_IP='127.0.0.1'
WORLD_PORT=7172
WORLD_LOGIN_PORT=7171
EOF
chmod 600 /var/www/html/apik/v1/.env
chown www-data:www-data /var/www/html/apik/v1/.env
```

### 5.3. Migracje SQL
```bash
cd /var/www/html/apik/v1/migrations
php migrate.php status   # pokaże stan migracji
php migrate.php rollout  # zastosuje brakujące
```

### 5.4. Generacja manifestu (pierwsza wersja klienta)
```bash
# Skopiuj pliki klienta (z GHA build lub ręcznie):
mkdir -p /var/www/html/apik/v1/files/stable/1.0.0
# ... skopiuj pliki OTClient ...

# Wygeneruj manifest:
php /var/www/html/apik/v1/generate_manifest.php \
  /var/www/html/apik/v1/files/stable/1.0.0 1.0.0 stable
```

### 5.5. nginx config
```nginx
server {
    listen 443 ssl;
    server_name serwercanary.pl;

    ssl_certificate     /etc/ssl/certs/serwercanary.pem;
    ssl_certificate_key /etc/ssl/private/serwercanary.key;

    root /var/www/html;
    index index.php index.html;

    # API
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    # Pliki klienta — duże pliki, długie timeouty
    location /apik/v1/files/ {
        sendfile on;
        tcp_nopush on;
        client_max_body_size 500M;
    }
}
```

### 5.6. Katalog logów
```bash
sudo mkdir -p /var/log/serwercanary
sudo chown www-data:www-data /var/log/serwercanary

# Logrotate:
sudo cp /path/to/repo/canary_test/html_copy/apik/v1/logrotate-serwercanary \
  /etc/logrotate.d/serwercanary
```

### 5.7. Weryfikacja
```bash
# Test API:
curl -sk https://localhost/apik/v1/server-status.php | python3 -m json.tool
# Oczekiwany: {"ts":...,"servers":[{"id":"tibia-main",...}]}

# Test manifest:
curl -sk "https://localhost/apik/v1/update.php?channel=stable" | python3 -m json.tool
```

---

## 6. Krok po kroku: Launcher (Rust + Tauri)

### 6.1. Build (lokalny dev)
```bash
cd launcher-rust
cargo build --workspace
# Lub na CI (GHA):
# Push → workflow build-launcher.yml → artefakt ZIP
```

### 6.2. Konfiguracja launchera
Stwórz `launcher_config.json` obok binarki:
```json
{
  "apiBaseUrl": "https://serwercanary.pl/apik/v1",
  "channel": "stable",
  "language": "pl",
  "devMode": false
}
```

Dla developmentu z self-signed cert:
```json
{
  "apiBaseUrl": "https://172.29.76.234/apik/v1",
  "channel": "stable",
  "language": "pl",
  "devMode": true
}
```

### 6.3. Pierwsze uruchomienie
1. Launcher uruchamia się → pobiera status z API
2. Sprawdza manifest → widzi brak plików klienta
3. Wyświetla "Instalacja" → pobiera pliki
4. Po instalacji: "Gotowe do gry" → przycisk "Graj"

### 6.4. Struktura danych launchera
```
~/.serwercanary-launcher/
├── launcher_config.json     # konfiguracja
├── installed_state.json     # stan instalacji (wersja, pliki)
├── client/                  # pobrane pliki OTClient
│   ├── otclient.exe
│   ├── data/
│   ├── modules/
│   └── ...
└── logs/                    # logi launchera
```

---

## 7. Krok po kroku: OTClient

### 7.1. Build na GHA
Workflow: `.github/workflows/build-client-package.yml`
- Trigger: `workflow_dispatch` (ręczny) lub tag `v*-client`
- Output: ZIP (Windows) + tar.gz (Linux) + package-manifest JSON
- Customizacje: `customizations/` overlay (moduły, init.lua)

### 7.2. Deploy nowej wersji
```bash
# Po pobraniu artefaktu z GHA:
./tools/deploy-client.sh otclient-windows-x64-1.0.3.zip 1.0.3 stable
# Skrypt:
#  1. Rozpakuje do /var/www/html/apik/v1/files/stable/1.0.3/
#  2. Właściciel: www-data
#  3. Regeneruje manifest
#  4. Symlink latest → 1.0.3
#  5. Czyści stare wersje (zachowuje 5)
```

---

## 8. Testowanie update/repair

### 8.1. Test aktualizacji
```bash
# 1. Sprawdź aktualną wersję w launcherze (np. 1.0.2)
# 2. Zbuduj nową wersję klienta (1.0.3) na GHA
# 3. Deploy:
./tools/deploy-client.sh otclient-windows-x64-1.0.3.zip 1.0.3 stable

# 4. W launcherze: kliknij "Sprawdź aktualizacje"
# 5. Oczekiwany: "Dostępna aktualizacja 1.0.3" → pobieranie → "Gotowe"
```

### 8.2. Test naprawy (repair)
```bash
# 1. Ręcznie usuń plik z katalogu klienta:
rm ~/.serwercanary-launcher/client/data/things/items.otb

# 2. W launcherze: idź do "Naprawa"
# 3. Oczekiwany: "Brakujące pliki: 1" → "Napraw" → plik pobrany ponownie
```

### 8.3. Test integralności plików krytycznych
```bash
# 1. Zmodyfikuj plik krytyczny (init.lua):
echo "-- hacked" >> ~/.serwercanary-launcher/client/init.lua

# 2. Kliknij "Graj" w launcherze
# 3. Oczekiwany: "Wykryto zmodyfikowane pliki krytyczne" → blokada startu
# 4. Kliknij "Napraw" → pliki przywrócone → można grać
```

### 8.4. Test launch tokena
```bash
# 1. Kliknij "Graj" (pliki OK)
# 2. Launcher pobiera launch-token z API
# 3. Token przekazany do OTClient → OTClient łączy się z serwerem
# 4. Jeśli token wygasł/nieprawidłowy → "Sesja wygasła, spróbuj ponownie"
```

---

## 9. Troubleshooting

### 9.1. Launcher nie łączy się z API
**Objawy:** "Nie można połączyć z serwerem" / timeout  
**Sprawdź:**
```bash
# Czy nginx działa:
systemctl status nginx

# Czy PHP-FPM działa:
systemctl status php*-fpm

# Czy certyfikat SSL jest OK:
curl -v https://localhost/apik/v1/server-status.php 2>&1 | grep -E "SSL|HTTP"

# Dla self-signed cert: upewnij się że devMode=true w launcher_config.json
```

### 9.2. MySQL connection refused
**Objawy:** "Database error" w API  
**Sprawdź:**
```bash
# Czy MySQL działa:
systemctl status mysql

# Czy dane w .env są OK:
cat /var/www/html/apik/v1/.env | grep DB_

# Test połączenia:
mysql -u ptaku -p -h 127.0.0.1 canaryaac -e "SELECT 1"
```

### 9.3. Manifest 404 / puste pliki
**Objawy:** Launcher mówi "brak aktualizacji" mimo że pliki istnieją  
**Sprawdź:**
```bash
# Czy manifest istnieje:
ls -la /var/www/html/apik/v1/manifests/stable/

# Regeneruj:
php /var/www/html/apik/v1/generate_manifest.php /var/www/html/apik/v1/files/stable/1.0.2 1.0.2 stable
```

### 9.4. Serwer gry offline w launcherze
**Objawy:** server-status.php → "offline"  
**Sprawdź:**
```bash
# Czy Canary nasłuchuje:
ss -tlnp | grep -E '7171|7172'

# Czy IP w .env jest prawidłowe:
grep WORLD_IP /var/www/html/apik/v1/.env
```

### 9.5. Download klienta wolny / timeout
**Objawy:** "Timeout downloading file" w launcherze  
**Sprawdź:**
```bash
# nginx config — duże pliki:
grep client_max_body_size /etc/nginx/sites-enabled/*
# Powinno być: client_max_body_size 500M;

# Test ręczny:
curl -sk -o /dev/null -w "%{speed_download}" https://localhost/apik/v1/files/stable/1.0.2/otclient.exe
```

### 9.6. Token rejected / session expired
**Objawy:** "Sesja wygasła" po kliknięciu Graj  
**Sprawdź:**
```bash
# Logi security:
tail -5 /var/log/serwercanary/security-events.log | python3 -m json.tool

# Czy TICKET_SECRET w .env zgadza się z tym w launcherze
# Czy event_scheduler jest ON (automatyczne czyszczenie):
mysql -e "SHOW VARIABLES LIKE 'event_scheduler'"
```

### 9.7. Launch token — files_hash_mismatch
**Objawy:** "Launch rejected: files_hash_mismatch"  
**Przyczyna:** Launcher wysyła hash plików, ale nie zgadza się z serwerem  
**Rozwiązanie:** Uruchom "Sprawdź aktualizacje" → pobierz brakujące pliki

### 9.8. Logi nie zapisują się
**Objawy:** Pusty /var/log/serwercanary/  
**Sprawdź:**
```bash
ls -la /var/log/serwercanary/
# Właściciel powinien być www-data:
sudo chown -R www-data:www-data /var/log/serwercanary
```

### 9.9. Dashboard-errors.php → 403
**Objawy:** "forbidden" przy otwieraniu dashboardu  
**Rozwiązanie:** Dostęp tylko z local IP lub z tokenem:
```bash
# Dodaj token do .env:
echo "DASHBOARD_TOKEN='tajny-token-123'" >> /var/www/html/apik/v1/.env
# Otwórz: https://..../dashboard-errors.php?token=tajny-token-123
```

### 9.10. OTClient crash po starcie
**Objawy:** OTClient zamyka się natychmiast  
**Sprawdź:**
```bash
# Czy init.lua istnieje i nie jest uszkodzony:
head -5 ~/.serwercanary-launcher/client/init.lua

# Czy wymagane DLL są obecne:
ls ~/.serwercanary-launcher/client/*.dll

# Uruchom z konsoli:
cd ~/.serwercanary-launcher/client && ./otclient.exe --debug
```

### 9.11. Event scheduler wyłączony
**Objawy:** Tabele ticket_nonces/launch_tokens nie są czyszczone  
**Sprawdź:**
```bash
mysql -e "SHOW VARIABLES LIKE 'event_scheduler'"
# Jeśli OFF:
mysql -e "SET GLOBAL event_scheduler = ON"
# Lub uruchom ponownie migracje:
cd /var/www/html/apik/v1/migrations && php migrate.php rollout
```

### 9.12. Zły port w kliencie
**Objawy:** OTClient łączy się na zły port  
**Sprawdź:**
```bash
# Port w manifeście:
curl -sk "https://localhost/apik/v1/update.php?channel=stable" | python3 -c "import sys,json; m=json.load(sys.stdin); [print(f'{s[\"name\"]}: login={s.get(\"loginPort\",\"?\")}, game={s.get(\"gamePort\",\"?\")}') for s in m.get('servers',[])]"

# Port w config.lua:
grep -E "loginProtocolPort|gameProtocolPort" config.lua

# Port w .env:
grep WORLD_ /var/www/html/apik/v1/.env
```

---

## 10. Konfiguracja portów

Porty muszą być spójne w 4 miejscach:

| Położenie | loginPort | gamePort | Klucz |
|-----------|-----------|----------|-------|
| config.lua | `loginProtocolPort = 7171` | `gameProtocolPort = 7172` | Canary server |
| .env | `WORLD_LOGIN_PORT=7171` | `WORLD_PORT=7172` | API endpoints |
| server-status.php | z .env | z .env | Status endpoint |
| generate_manifest.php | z .env | z .env | Manifest servers[] |
| Rust ServerEntryRaw | `login_port` | `game_port` | Launcher parsing |

**Zmiana portu** wymaga edycji we wszystkich 4 miejscach + restart serwera Canary.
