//! Launcher Core — główna logika launchera.
//!
//! Moduły:
//! - integrity: filesHash, SHA-256
//! - file_index: skan lokalnych plików
//! - planner: UpdatePlan z manifestu vs lokalne pliki
//! - patcher: staging, atomowa podmiana, rollback
//! - state: atomowy zapis installed_state.json
//! - process_runner: uruchamianie klienta z tokenem
//! - serverlist_sync: synchronizacja listy serwerów
//! - repair: tryb naprawy instalacji
//! - artifact_verify: weryfikacja pobranych artefaktów (LR-045)
//! - self_update: logika self-update launchera (LR-048..051)
//! - challenge: challenge-response dla launch-token (LR-052)
//! - manifest_signature: weryfikacja podpisu manifestu Ed25519 (LR-053)
//! - telemetry: metryki techniczne opt-in (LR-054)
//! - hmac_rotation: rotacja kluczy HMAC z kid (LR-056)
//! - font_pack_download: pobieranie i weryfikacja paczek fontów (9.3.5)
//! - language_pack_download: pobieranie i instalacja paczek językowych (9.4.4/9.4.5)

pub mod artifact_verify;
pub mod challenge;
pub mod file_index;
pub mod font_pack_download;
pub mod hmac_rotation;
pub mod integrity;
pub mod language_pack_download;
pub mod manifest_signature;
pub mod patcher;
pub mod planner;
pub mod process_runner;
pub mod repair;
pub mod self_update;
pub mod serverlist_sync;
pub mod state;
pub mod telemetry;
