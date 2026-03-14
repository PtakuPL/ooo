# Rollout produkcyjny - globalne gildie

Status: przygotowany  
Data: 2026-03-08  
Zakres: tylko `global guild registry`, bez globalnych topek

## 1. Cel

Ten runbook opisuje kolejnosc wdrozenia produkcyjnego dla:

- `GLOBAL_GUILDS_API_KEY`
- migracji `008/009/010/011`
- owner mappingu dla `global_accounts`
- testow po rolloutcie

Nie obejmuje:

- zmian w systemie kont poza juz istniejacym kontraktem owner mappingu
- topki globalnej
- frontendow `WWW Tibia` i `RedDaxe.pl`

## 2. Stan backendu przed rolloutem

Na bazie testowej sa juz gotowe i sprawdzone:

- `create` flow gildii przez `WWW Tibia`
- legacy `create` flow gildii
- `delete / disband / cleanup` zsynchronizowane z registry
- twarda blokada adminowego `rename`
- auth endpointow gildii przez `GLOBAL_GUILDS_API_KEY`
- backendowy transfer ownera i delegowanie `local leader`
- CLI guardy i smoke testy

To oznacza, ze rollout produkcyjny dotyczy juz glownie:

- konfiguracji runtime
- migracji `GLOBAL_DB`
- smoke testow po wdrozeniu

## 3. Pre-check lista

Przed rolloutem trzeba potwierdzic:

- `GLOBAL_DB_NAME` wskazuje na docelowe `global_accounts`
- `GLOBAL_GUILDS_API_KEY` jest ustawiony w docelowym runtime
- kontrakt ownera jest rozstrzygniety:
  - tymczasowo `same ids + same email`
  - albo docelowo `account_world_links`
- nikt nie odpalil starej, blednej wersji migracji `008` na tym srodowisku
- backup `GLOBAL_DB` jest wykonany zgodnie z lokalna procedura operacyjna

## 4. Readiness check

Read-only readiness:

```bash
php /var/www/html/apik/v1/migrations/global-guilds-rollout-readiness.php
```

Readiness z pelnym auth smoke:

```bash
php /var/www/html/apik/v1/migrations/global-guilds-rollout-readiness.php --with-auth-smoke
```

Readiness z auth + ownership smoke:

```bash
php /var/www/html/apik/v1/migrations/global-guilds-rollout-readiness.php --with-auth-smoke --with-ownership-smoke
```

Ten check sprawdza:

- obecny status migracji `008/009/010/011`
- `GLOBAL_GUILDS_API_KEY`
- `global-guilds-db-preflight.php`
- `global-guilds-mutation-guard.php`
- opcjonalnie `global-guilds-auth-smoke.php`
- opcjonalnie `global-guilds-ownership-model-smoke.php`

## 5. Kolejnosc wdrozenia

### Krok 1. Status migracji

```bash
php /var/www/html/apik/v1/migrations/migrate-global-guilds.php status
```

### Krok 2. Preflight bazy

```bash
php /var/www/html/apik/v1/migrations/global-guilds-db-preflight.php
```

Jesli preflight zwroci `ok=false`, rollout jest zatrzymany.

### Krok 3. Dry-run owner mappingu

```bash
php /var/www/html/apik/v1/migrations/backfill-global-guild-account-links.php
```

Jesli wynik jest zgodny z oczekiwaniami i `010` jest juz wdrozone, mozna wykonac zapis:

```bash
php /var/www/html/apik/v1/migrations/backfill-global-guild-account-links.php --apply
```

### Krok 4. Rollout migracji

```bash
php /var/www/html/apik/v1/migrations/migrate-global-guilds.php rollout
```

To obejmuje:

- `008_global_guild_registry`
- `009_global_guild_registry_repair_and_events`
- `010_global_guild_account_links`
- `011_global_guild_ownership_and_instance_leaders`

### Krok 5. Post-rollout status

```bash
php /var/www/html/apik/v1/migrations/migrate-global-guilds.php status
php /var/www/html/apik/v1/migrations/global-guilds-db-preflight.php
php /var/www/html/apik/v1/migrations/global-guilds-mutation-guard.php
```

### Krok 6. Smoke testy po HTTPS

```bash
php /var/www/html/apik/v1/migrations/global-guilds-auth-smoke.php
php /var/www/html/apik/v1/migrations/global-guilds-archive-smoke.php
php /var/www/html/apik/v1/migrations/global-guilds-delete-helper-smoke.php
php /var/www/html/apik/v1/migrations/global-guilds-ownership-model-smoke.php
php /var/www/html/apik/v1/migrations/global-guilds-sync-status.php
```

Uwaga:

- `global-guilds-auth-smoke.php` potwierdza juz takze bootstrap pierwszego `local leader` w `reserve-or-attach`,
- `global-guilds-delete-helper-smoke.php` potwierdza dalej, ze delete / archive flow pozostaje spojny po tym bootstrapie.

### Krok 7. Readiness final

```bash
php /var/www/html/apik/v1/migrations/global-guilds-rollout-readiness.php --with-auth-smoke --with-ownership-smoke
```

## 6. Kryteria sukcesu

Rollout mozna uznac za gotowy, gdy:

- `global-guilds-rollout-readiness.php --with-auth-smoke --with-ownership-smoke` zwraca `ok=true`
- brak pending migracji `008/009/010/011`
- preflight nie ma blockerow
- mutation guard nie ma follow-upow
- auth smoke przechodzi z cleanupem
- ownership smoke przechodzi z cleanupem
- `RedDaxe` login/create dalej odpowiada `200`

## 7. Co zostaje po rolloutcie

Po rolloutcie backend globalnych gildii jest gotowy do dalszych etapow:

- `WWW Tibia` frontend dla gildii
- `RedDaxe.pl` minimalny panel gildii i lista czlonkow per serwer
- dalszy kontrakt pod inne gry

Nadal poza zakresem:

- globalne topki
- publiczne widoki `all worlds`
- docelowy UI zarzadzania gildia na `WWW Tibia`
