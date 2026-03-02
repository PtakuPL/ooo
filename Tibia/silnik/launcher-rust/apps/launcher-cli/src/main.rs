//! Launcher CLI — end-to-end flow bez UI (LR-026).
//!
//! Flow:
//! 1. check    — sprawdź wersję launchera
//! 2. update   — pobierz manifest → scan → plan → download → apply
//! 3. hash     — oblicz filesHash
//! 4. token    — pobierz launch-token
//! 5. launch   — uruchom klienta z tokenem
//!
//! Obsługuje też:
//! - repair    — diagnoza i naprawa instalacji
//! - status    — pokaż installed_state.json
//!
//! Użycie:
//!   launcher-cli --base-url https://api.example.com --channel stable --client-dir ./client
//!   launcher-cli repair --client-dir ./client
//!   launcher-cli status --client-dir ./client

mod cli;
mod flow;

use tracing_subscriber::EnvFilter;

#[tokio::main]
async fn main() {
    // Inicjalizuj tracing
    tracing_subscriber::fmt()
        .with_env_filter(
            EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| EnvFilter::new("info")),
        )
        .init();

    let args = cli::parse_args();

    let exit_code = match args.command.as_str() {
        "run" | "launch" => flow::run_full_flow(&args).await,
        "update" => flow::run_update_only(&args).await,
        "repair" => flow::run_repair(&args).await,
        "status" => flow::run_status(&args),
        "check" => flow::run_check_version(&args).await,
        "hash" => flow::run_compute_hash(&args).await,
        _ => {
            eprintln!("Nieznana komenda: {}. Użyj: run, update, repair, status, check, hash", args.command);
            1
        }
    };

    std::process::exit(exit_code);
}
