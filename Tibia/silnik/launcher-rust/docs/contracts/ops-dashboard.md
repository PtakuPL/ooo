# Ops Dashboard — Token/Ticket Rejection Monitoring

**LR-055** — Hardening (Etap 5)  
**Data:** 2026-03-03  
**Status:** Specyfikacja

---

## 1. Cel

Dashboard operacyjny do monitorowania:
- Odrzuconych launch-tokenów i powodów odrzucenia.
- Odrzuconych ticket-gate ticketów.
- Trendów błędów w czasie.
- Anomalii (np. spike w odrzuceniach = potencjalny atak/bug).

---

## 2. Dane źródłowe

### 2.1 Z telemetrii launchera (opt-in, LR-054)

```json
{
  "events": [
    {"name": "token.rejected", "tags": {"error": "HASH_MISMATCH"}, "timestamp": 1709424000},
    {"name": "update.failure", "tags": {"error_code": "LCH_102"}, "timestamp": 1709424060},
    {"name": "token.latency_ms", "value": 1500, "tags": {"success": "false"}}
  ]
}
```

### 2.2 Z logów serwera API (server-side)

```
[2026-03-03 12:00:00] TOKEN_REJECTED ip=1.2.3.4 reason=HASH_MISMATCH channel=stable
[2026-03-03 12:00:01] TICKET_INVALID ip=1.2.3.5 reason=HMAC_FAILED kid=key-2026-01
```

### 2.3 Z logów Canary (ticket-gate)

```
[2026-03-03 12:00:02] TICKET_GATE_REJECT account=12345 reason=EXPIRED
```

---

## 3. Metryki dashboardu

### 3.1 Panel: Token Requests

| Metryka | Typ | Opis |
|---------|-----|------|
| token.total | counter | Łączna ilość requestów |
| token.success | counter | Udane tokeny |
| token.rejected | counter | Odrzucone tokeny |
| token.rejected_by_reason | counter (grouped) | Podział wg powodu (HASH_MISMATCH, CHANNEL_INVALID, etc.) |
| token.latency_p50 | gauge | Mediana latency |
| token.latency_p99 | gauge | P99 latency |

### 3.2 Panel: Ticket-Gate

| Metryka | Typ | Opis |
|---------|-----|------|
| ticket.total | counter | Łączna ilość ticketów |
| ticket.valid | counter | Poprawne tickety |
| ticket.rejected | counter | Odrzucone tickety |
| ticket.rejected_by_reason | counter (grouped) | HMAC_FAILED, EXPIRED, REUSED, etc. |

### 3.3 Panel: Update Health

| Metryka | Typ | Opis |
|---------|-----|------|
| update.success | counter | Udane aktualizacje |
| update.failure | counter | Nieudane aktualizacje |
| update.failure_by_code | counter (grouped) | Podział wg LCH_* error code |
| update.rollback | counter | Rollbacki |
| update.avg_duration_ms | gauge | Średni czas aktualizacji |

### 3.4 Panel: Anomaly Detection

| Alert | Warunek | Priorytet |
|-------|---------|-----------|
| Token rejection spike | >50% odrzuceń w 5-min window | P1 |
| HMAC failures spike | >10 HMAC_FAILED w minucie | P0 |
| Update failure rate | >30% failure rate w 15 min | P1 |
| Latency degradation | P99 > 5000ms przez 10 min | P2 |

---

## 4. Implementacja

### 4.1 Faza 1: Log-based (minimalna)

1. Logi serwera API → plik/stdout w formacie JSON.
2. Skrypt `analyze_logs.py` do parsowania i raportowania.
3. Cron: generuj raport co godzinę.

### 4.2 Faza 2: Telemetria + prosty dashboard

1. Launcher wysyła metryki → `POST /telemetry.php` (opt-in).
2. API zapisuje do SQLite/PostgreSQL.
3. Prosty PHP dashboard lub static HTML z Chart.js.

### 4.3 Faza 3: Pełny monitoring (opcjonalnie)

1. Prometheus/Grafana stack.
2. API eksportuje metryki w formacie Prometheus.
3. Alerting przez Grafana Alerting lub PagerDuty.

---

## 5. Schema tabeli (Faza 2)

```sql
CREATE TABLE telemetry_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    launcher_version TEXT NOT NULL,
    channel TEXT NOT NULL,
    event_name TEXT NOT NULL,
    event_value REAL NOT NULL DEFAULT 0,
    tags_json TEXT,
    client_timestamp INTEGER NOT NULL,
    server_timestamp INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    client_ip TEXT
);

CREATE INDEX idx_events_name_ts ON telemetry_events(event_name, server_timestamp);
CREATE INDEX idx_events_channel ON telemetry_events(channel, server_timestamp);
```

---

## 6. Endpointy API

### POST /telemetry.php

Przyjmuje `TelemetryPayload` (patrz `telemetry.rs`).

**Rate limit:** Max 1 request/minutę per IP.  
**Autoryzacja:** Brak (dane nie-wrażliwe, anonimizowane).

### GET /ops/dashboard.php

Zwraca HTML dashboardu (auth required — HTTP Basic lub session).

### GET /ops/metrics.json

Zwraca zagregowane metryki jako JSON (auth required).

---

## 7. Prywatność

- **Brak PII** w telemetrii — żadnych nazw kont, loginów, haseł.
- Tylko metryki techniczne: czasy, kody błędów, wersje.
- IP klienta logowane server-side (standardowy log), NIE w telemetrii z launchera.
- Opt-in: domyślnie wyłączone, użytkownik aktywuje w ustawieniach.
