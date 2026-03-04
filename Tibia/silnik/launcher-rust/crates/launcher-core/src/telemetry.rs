//! LR-054: Telemetria techniczna (opt-in).
//!
//! Pipeline zbierania metryk technicznych:
//! - update success/failure count
//! - token request latency
//! - download throughput
//! - error codes distribution
//!
//! WAŻNE: Telemetria jest **opt-in** — domyślnie wyłączona.
//! Żadne dane nie są wysyłane bez wyraźnej zgody użytkownika.

use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use std::time::{Duration, SystemTime, UNIX_EPOCH};

/// Typ metryki.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "snake_case")]
pub enum MetricType {
    /// Licznik (monotoniczny, np. ilość update'ów).
    Counter,
    /// Gauge (wartość chwilowa, np. czas trwania).
    Gauge,
    /// Histogram (dystrybucja wartości).
    Histogram,
}

/// Pojedyncza metryka techniczna.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct TelemetryEvent {
    /// Nazwa metryki (np. "update.success", "token.latency_ms").
    pub name: String,
    /// Typ metryki.
    pub metric_type: MetricType,
    /// Wartość.
    pub value: f64,
    /// Timestamp (Unix epoch seconds).
    pub timestamp: u64,
    /// Tagi/etykiety (np. channel, error_code).
    #[serde(default)]
    pub tags: HashMap<String, String>,
}

/// Konfiguracja telemetrii.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct TelemetryConfig {
    /// Czy telemetria jest włączona (opt-in).
    pub enabled: bool,
    /// URL endpointu do wysyłania metryk.
    pub endpoint_url: Option<String>,
    /// Interwał flush w sekundach.
    pub flush_interval_seconds: u32,
    /// Maksymalna ilość zbuforowanych eventów.
    pub max_buffer_size: usize,
    /// Wersja launchera (tag w metrykach).
    pub launcher_version: String,
    /// Kanał (stable/test/dev).
    pub channel: String,
}

impl Default for TelemetryConfig {
    fn default() -> Self {
        Self {
            enabled: false, // Domyślnie wyłączona!
            endpoint_url: None,
            flush_interval_seconds: 60,
            max_buffer_size: 100,
            launcher_version: String::new(),
            channel: String::new(),
        }
    }
}

/// Kolektor telemetrii — zbiera metryki do późniejszego wysłania.
#[derive(Debug, Clone)]
pub struct TelemetryCollector {
    config: TelemetryConfig,
    buffer: Arc<Mutex<Vec<TelemetryEvent>>>,
}

impl TelemetryCollector {
    /// Tworzy nowy kolektor z podaną konfiguracją.
    pub fn new(config: TelemetryConfig) -> Self {
        Self {
            config,
            buffer: Arc::new(Mutex::new(Vec::new())),
        }
    }

    /// Tworzy wyłączony kolektor (no-op).
    pub fn disabled() -> Self {
        Self::new(TelemetryConfig::default())
    }

    /// Czy telemetria jest włączona.
    pub fn is_enabled(&self) -> bool {
        self.config.enabled
    }

    /// Rejestruje event. Jeśli telemetria wyłączona — no-op.
    pub fn record(&self, event: TelemetryEvent) {
        if !self.config.enabled {
            return;
        }

        let mut buffer = self.buffer.lock().unwrap();
        if buffer.len() < self.config.max_buffer_size {
            buffer.push(event);
        } else {
            tracing::warn!("Telemetry buffer full ({} events), dropping", buffer.len());
        }
    }

    /// Rejestruje counter + tags.
    pub fn record_counter(&self, name: &str, value: f64, tags: HashMap<String, String>) {
        self.record(TelemetryEvent {
            name: name.to_string(),
            metric_type: MetricType::Counter,
            value,
            timestamp: now_epoch(),
            tags,
        });
    }

    /// Rejestruje gauge (np. czas trwania operacji).
    pub fn record_gauge(&self, name: &str, value: f64, tags: HashMap<String, String>) {
        self.record(TelemetryEvent {
            name: name.to_string(),
            metric_type: MetricType::Gauge,
            value,
            timestamp: now_epoch(),
            tags,
        });
    }

    /// Rejestruje czas trwania operacji w ms.
    pub fn record_duration(&self, name: &str, duration: Duration, tags: HashMap<String, String>) {
        self.record_gauge(name, duration.as_millis() as f64, tags);
    }

    /// Rejestruje błąd z kodem LCH_*.
    pub fn record_error(&self, error_code: &str, details: &str) {
        let mut tags = HashMap::new();
        tags.insert("error_code".to_string(), error_code.to_string());
        tags.insert("details".to_string(), details.to_string());
        self.record_counter("error.count", 1.0, tags);
    }

    /// Pobiera i czyści bufor (drain).
    pub fn drain(&self) -> Vec<TelemetryEvent> {
        let mut buffer = self.buffer.lock().unwrap();
        std::mem::take(&mut *buffer)
    }

    /// Ilość zbuforowanych eventów.
    pub fn buffer_size(&self) -> usize {
        self.buffer.lock().unwrap().len()
    }

    /// Serializuje bufor do JSON (do wysyłki lub zapisu).
    pub fn serialize_buffer(&self) -> Result<String, serde_json::Error> {
        let events = self.drain();
        let payload = TelemetryPayload {
            launcher_version: self.config.launcher_version.clone(),
            channel: self.config.channel.clone(),
            events,
        };
        serde_json::to_string_pretty(&payload)
    }
}

/// Payload telemetrii do wysłania na serwer.
#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct TelemetryPayload {
    pub launcher_version: String,
    pub channel: String,
    pub events: Vec<TelemetryEvent>,
}

// ─────────────────────────────────────────────
// Predefiniowane metryki
// ─────────────────────────────────────────────

/// Metryka: update zakończony sukcesem.
pub fn metric_update_success(collector: &TelemetryCollector, channel: &str, duration: Duration) {
    let mut tags = HashMap::new();
    tags.insert("channel".to_string(), channel.to_string());
    collector.record_counter("update.success", 1.0, tags.clone());
    collector.record_duration("update.duration_ms", duration, tags);
}

/// Metryka: update zakończony błędem.
pub fn metric_update_failure(collector: &TelemetryCollector, channel: &str, error_code: &str) {
    let mut tags = HashMap::new();
    tags.insert("channel".to_string(), channel.to_string());
    tags.insert("error_code".to_string(), error_code.to_string());
    collector.record_counter("update.failure", 1.0, tags);
}

/// Metryka: token request latency.
pub fn metric_token_latency(collector: &TelemetryCollector, duration: Duration, success: bool) {
    let mut tags = HashMap::new();
    tags.insert("success".to_string(), success.to_string());
    collector.record_duration("token.latency_ms", duration, tags);
}

/// Metryka: token odrzucony.
pub fn metric_token_rejected(collector: &TelemetryCollector, error: &str) {
    let mut tags = HashMap::new();
    tags.insert("error".to_string(), error.to_string());
    collector.record_counter("token.rejected", 1.0, tags);
}

/// Metryka: download throughput.
pub fn metric_download_throughput(collector: &TelemetryCollector, bytes: u64, duration: Duration) {
    let throughput_kbps = if duration.as_millis() > 0 {
        (bytes as f64 / 1024.0) / (duration.as_millis() as f64 / 1000.0)
    } else {
        0.0
    };
    let tags = HashMap::new();
    collector.record_gauge("download.throughput_kbps", throughput_kbps, tags);
}

/// Metryka: self-update result.
pub fn metric_self_update(
    collector: &TelemetryCollector,
    success: bool,
    from_version: &str,
    to_version: &str,
) {
    let mut tags = HashMap::new();
    tags.insert("success".to_string(), success.to_string());
    tags.insert("from".to_string(), from_version.to_string());
    tags.insert("to".to_string(), to_version.to_string());
    collector.record_counter("self_update.attempt", 1.0, tags);
}

/// Pomocnik: aktualny Unix timestamp.
fn now_epoch() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs()
}

// ─────────────────────────────────────────────
// Testy
// ─────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_disabled_collector_ignores_events() {
        let collector = TelemetryCollector::disabled();
        assert!(!collector.is_enabled());
        collector.record_counter("test", 1.0, HashMap::new());
        assert_eq!(collector.buffer_size(), 0);
    }

    #[test]
    fn test_enabled_collector_records_events() {
        let config = TelemetryConfig {
            enabled: true,
            ..Default::default()
        };
        let collector = TelemetryCollector::new(config);
        collector.record_counter("test.counter", 1.0, HashMap::new());
        assert_eq!(collector.buffer_size(), 1);
    }

    #[test]
    fn test_drain_clears_buffer() {
        let config = TelemetryConfig {
            enabled: true,
            ..Default::default()
        };
        let collector = TelemetryCollector::new(config);
        collector.record_counter("a", 1.0, HashMap::new());
        collector.record_counter("b", 2.0, HashMap::new());
        assert_eq!(collector.buffer_size(), 2);

        let drained = collector.drain();
        assert_eq!(drained.len(), 2);
        assert_eq!(collector.buffer_size(), 0);
    }

    #[test]
    fn test_max_buffer_size() {
        let config = TelemetryConfig {
            enabled: true,
            max_buffer_size: 3,
            ..Default::default()
        };
        let collector = TelemetryCollector::new(config);
        for i in 0..10 {
            collector.record_counter(&format!("m{}", i), 1.0, HashMap::new());
        }
        assert_eq!(collector.buffer_size(), 3);
    }

    #[test]
    fn test_record_error() {
        let config = TelemetryConfig {
            enabled: true,
            ..Default::default()
        };
        let collector = TelemetryCollector::new(config);
        collector.record_error("LCH_101", "test error");
        let events = collector.drain();
        assert_eq!(events.len(), 1);
        assert_eq!(events[0].name, "error.count");
        assert_eq!(events[0].tags.get("error_code").unwrap(), "LCH_101");
    }

    #[test]
    fn test_serialize_buffer() {
        let config = TelemetryConfig {
            enabled: true,
            launcher_version: "0.2.0".to_string(),
            channel: "stable".to_string(),
            ..Default::default()
        };
        let collector = TelemetryCollector::new(config);
        collector.record_counter("test", 42.0, HashMap::new());
        let json = collector.serialize_buffer().unwrap();
        assert!(json.contains("\"launcherVersion\": \"0.2.0\""));
        assert!(json.contains("\"test\""));
    }

    #[test]
    fn test_metric_update_success() {
        let config = TelemetryConfig {
            enabled: true,
            ..Default::default()
        };
        let collector = TelemetryCollector::new(config);
        metric_update_success(&collector, "stable", Duration::from_millis(1500));
        assert_eq!(collector.buffer_size(), 2); // counter + duration
    }

    #[test]
    fn test_metric_download_throughput() {
        let config = TelemetryConfig {
            enabled: true,
            ..Default::default()
        };
        let collector = TelemetryCollector::new(config);
        metric_download_throughput(&collector, 1024 * 1024, Duration::from_secs(1));
        let events = collector.drain();
        assert_eq!(events[0].name, "download.throughput_kbps");
        assert!((events[0].value - 1024.0).abs() < 1.0); // ~1024 KB/s
    }

    #[test]
    fn test_default_config_disabled() {
        let config = TelemetryConfig::default();
        assert!(!config.enabled);
        assert!(config.endpoint_url.is_none());
    }
}
