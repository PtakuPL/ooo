# Runbook: Rollback & Fallback Procedures

**LR-061** — Etap 6 (Migracja)  
**Data:** 2026-03-03  
**Severity:** P0 — Każdy członek zespołu musi znać te procedury.

---

## 1. Scenariusze wymagające rollbacku

| Scenariusz | Trigger | Priorytet | Czas reakcji |
|------------|---------|-----------|-------------|
| Masowe odrzucenie tokenów | Token rejection rate > 5% | P0 | < 15 min |
| filesHash mismatch | Rust i Python dają różne hashe | P0 | < 15 min |
| Crash launchera | Spike w raportach crashy | P0 | < 30 min |
| Update loop | Launcher powtarza update w kółko | P1 | < 1h |
| Self-update brick | Helper nie podmienia poprawnie | P1 | < 1h |
| Performance degradation | Latency > 5s na update check | P2 | < 4h |

---

## 2. Procedura R1: Rollback kanału do Python launchera

**Kiedy:** Rust launcher powoduje masowe problemy na kanale stable.

### Kroki

1. **SSH do serwera API** lub panel administracyjny.

2. **Zmień konfigurację rollout:**
   ```bash
   # Na serwerze API
   cd /var/www/api
   
   # Backup aktualnej konfiguracji
   cp rollout_config.json rollout_config.json.bak.$(date +%Y%m%d_%H%M%S)
   
   # Zmień launcher stable na python
   jq '.channels.stable.launcher = "python" | .channels.stable.rolloutPercentage = 0' \
     rollout_config.json > rollout_config.tmp && mv rollout_config.tmp rollout_config.json
   ```

3. **Wyczyść cache (jeśli jest):**
   ```bash
   redis-cli DEL rollout_config_cache
   # lub
   rm -f /tmp/rollout_config_cache.json
   ```

4. **Zweryfikuj:**
   ```bash
   curl -s https://tibia.reddaxe.pl/rollout-config.php | jq '.channels.stable.launcher'
   # Powinno zwrócić: "python"
   ```

5. **Monitoruj dashboard** — odrzucenia powinny spaść w ciągu 5-10 minut.

6. **Powiadom zespół:** `@channel Rollback stable→Python executed. Monitoring.`

---

## 3. Procedura R2: Rollback self-update

**Kiedy:** Nowa wersja launchera jest wadliwa po self-update.

### Kroki

1. **Usuń wadliwą wersję z GitHub Releases:**
   ```bash
   # Użyj GitHub CLI
   gh release delete v1.2.3 --yes
   # lub oznacz jako draft
   gh release edit v1.2.3 --draft
   ```

2. **Zaktualizuj `launcher-version.php`:**
   ```bash
   # Cofnij wersję na serwerze API
   # Edytuj plik/DB aby version = poprzednia stabilna
   jq '.version = "1.2.2" | .url = "https://...launcher-v1.2.2..."' \
     launcher_version.json > tmp && mv tmp launcher_version.json
   ```

3. **Użytkownicy z wadliwą wersją:**
   - Launcher-helper automatycznie sprawdza `update_status.json`.
   - Jeśli status = "failed" → helper robi rollback do backupu.
   - Jeśli brak backupu → user musi ręcznie pobrać z Download Center.

4. **Komunikat dla użytkowników:**
   - Na stronie/discordzie: "Wycofano aktualizację v1.2.3. Jeśli masz problemy, pobierz najnowszą wersję z..."

---

## 4. Procedura R3: Rollback update klienta gry

**Kiedy:** Update klienta zawiera wadliwe pliki.

### Kroki

1. Launcher automatycznie wykrywa przerwany update przy starcie.
2. Sprawdza `installed_state.json` → `updateTransaction.status`:
   - `RollbackRequired` → automatyczny rollback staging → production.
3. Jeśli automatyczny rollback nie zadziała:
   ```bash
   # Na maszynie użytkownika — reset do stanu "pełny redownload"
   rm -f installed_state.json
   # Launcher przy następnym starcie pobierze manifest i naprawia
   ```

4. **Na serwerze API — cofnij manifest:**
   ```bash
   # Przywróć poprzednią wersję manifestu
   cp manifest_backup_v2.1.0.json manifest.json
   # Zaktualizuj wersję w DB
   ```

---

## 5. Procedura R4: Emergency — wszystko wyłącz

**Kiedy:** Krytyczny problem, brak pewności co jest źródłem.

### Kroki

1. **Wyłącz Rust launcher na wszystkich kanałach:**
   ```bash
   jq '.channels |= with_entries(.value.launcher = "python" | .value.rolloutPercentage = 0)' \
     rollout_config.json > tmp && mv tmp rollout_config.json
   ```

2. **Wyłącz self-update:**
   ```bash
   jq '.required = false | .version = "0.0.0"' \
     launcher_version.json > tmp && mv tmp launcher_version.json
   ```

3. **Zamroź manifesty:**
   ```bash
   # Nie aktualizuj manifestów do czasu wyjaśnienia
   touch /var/www/api/MANIFEST_FREEZE
   ```

4. **Post-mortem:** Po ustabilizowaniu — analiza logów, identyfikacja root cause.

---

## 6. Kontakty

| Rola | Kto | Kontakt |
|------|-----|---------|
| Lead developer | [TBD] | Discord/telefon |
| Server admin | [TBD] | Discord/telefon |
| API maintainer | [TBD] | Discord/telefon |

---

## 7. Checklist po rollbacku

- [ ] Rollback wykonany i zweryfikowany
- [ ] Dashboard pokazuje spadek błędów
- [ ] Zespół powiadomiony
- [ ] Użytkownicy poinformowani (jeśli publiczny problem)
- [ ] Root cause zidentyfikowany (lub ticket utworzony)
- [ ] Backup konfiguracji zapisany
- [ ] Incident log zaktualizowany (data, co, dlaczego, kto)

---

## 8. Drill schedule

| Częstotliwość | Procedura | Cel |
|---------------|-----------|-----|
| Co miesiąc | R1 (rollback kanału) | Weryfikacja że rollout config działa |
| Co kwartał | R2 (rollback self-update) | Weryfikacja że helper rollback działa |
| Przed każdym major release | R3 (rollback update) | Weryfikacja recovery flow |
