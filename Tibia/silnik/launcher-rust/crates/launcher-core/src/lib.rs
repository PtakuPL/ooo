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

pub mod integrity;
pub mod file_index;
pub mod planner;
pub mod patcher;
pub mod state;
pub mod process_runner;
pub mod serverlist_sync;
pub mod repair;
pub mod artifact_verify;
pub mod self_update;
