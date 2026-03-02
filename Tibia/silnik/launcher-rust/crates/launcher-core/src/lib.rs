//! Launcher Core — główna logika launchera.
//!
//! Moduły:
//! - integrity: filesHash, SHA-256
//! - planner: UpdatePlan z manifestu vs lokalne pliki
//! - state: atomowy zapis installed_state.json
//!
//! Stubs dla Sprint 2: patcher, downloader, process_runner, serverlist_sync.

pub mod integrity;
pub mod state;
