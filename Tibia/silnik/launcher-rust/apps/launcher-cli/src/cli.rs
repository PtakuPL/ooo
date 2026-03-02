//! Prosty parser argumentów CLI (bez zewnętrznych zależności).
//!
//! Nie używamy clap, żeby nie dodawać ciężkiej zależności.
//! Wystarczy ręczny parser dla kilku flag.

/// Argumenty CLI.
#[derive(Debug, Clone)]
pub struct CliArgs {
    /// Komenda: run, update, repair, status, check, hash.
    pub command: String,
    /// URL bazowy API (np. https://api.example.com/v1).
    pub base_url: String,
    /// Kanał aktualizacji (stable, test, dev).
    pub channel: String,
    /// Katalog klienta (gdzie zainstalowane pliki gry).
    pub client_dir: String,
    /// Katalog danych launchera (.launcher/).
    pub launcher_data_dir: String,
    /// Ścieżka do exe klienta (relative to client_dir).
    pub client_exe: String,
    /// Wersja launchera (do przekazania do API).
    pub launcher_version: String,
    /// Pokaż szczegółowe logi.
    pub verbose: bool,
    /// Tryb dry-run (nie aplikuj zmian).
    pub dry_run: bool,
}

impl Default for CliArgs {
    fn default() -> Self {
        Self {
            command: "run".into(),
            base_url: String::new(),
            channel: "stable".into(),
            client_dir: ".".into(),
            launcher_data_dir: ".launcher".into(),
            client_exe: "otclient".into(),
            launcher_version: env!("CARGO_PKG_VERSION").into(),
            verbose: false,
            dry_run: false,
        }
    }
}

/// Parsuje argumenty z std::env::args().
pub fn parse_args() -> CliArgs {
    let args: Vec<String> = std::env::args().collect();
    parse_from_vec(&args[1..])
}

/// Parsuje argumenty z wektora (testowalny).
pub fn parse_from_vec(args: &[String]) -> CliArgs {
    let mut result = CliArgs::default();
    let mut i = 0;

    // Pierwszy argument bez -- to komenda
    if !args.is_empty() && !args[0].starts_with('-') {
        result.command = args[0].clone();
        i = 1;
    }

    while i < args.len() {
        match args[i].as_str() {
            "--base-url" | "-u" => {
                i += 1;
                if i < args.len() {
                    result.base_url = args[i].clone();
                }
            }
            "--channel" | "-c" => {
                i += 1;
                if i < args.len() {
                    result.channel = args[i].clone();
                }
            }
            "--client-dir" | "-d" => {
                i += 1;
                if i < args.len() {
                    result.client_dir = args[i].clone();
                }
            }
            "--launcher-data" | "-l" => {
                i += 1;
                if i < args.len() {
                    result.launcher_data_dir = args[i].clone();
                }
            }
            "--client-exe" | "-e" => {
                i += 1;
                if i < args.len() {
                    result.client_exe = args[i].clone();
                }
            }
            "--launcher-version" => {
                i += 1;
                if i < args.len() {
                    result.launcher_version = args[i].clone();
                }
            }
            "--verbose" | "-v" => {
                result.verbose = true;
            }
            "--dry-run" | "-n" => {
                result.dry_run = true;
            }
            "--help" | "-h" => {
                print_help();
                std::process::exit(0);
            }
            _ => {
                eprintln!("Nieznany argument: {}", args[i]);
            }
        }
        i += 1;
    }

    result
}

fn print_help() {
    eprintln!(
        r#"Launcher CLI — TwojaGra Launcher (Rust)

UŻYCIE:
  launcher-cli <COMMAND> [OPTIONS]

KOMENDY:
  run       Pełny flow: check → update → hash → token → launch (domyślna)
  update    Tylko aktualizacja (bez startu klienta)
  repair    Diagnoza i naprawa instalacji
  status    Pokaż installed_state.json
  check     Sprawdź wersję launchera na serwerze
  hash      Oblicz filesHash z lokalnych plików

OPCJE:
  -u, --base-url <URL>          URL bazowy API (wymagany dla run/update/check)
  -c, --channel <CHANNEL>       Kanał: stable, test, dev (domyślnie: stable)
  -d, --client-dir <DIR>        Katalog klienta (domyślnie: .)
  -l, --launcher-data <DIR>     Katalog danych launchera (domyślnie: .launcher)
  -e, --client-exe <NAME>       Nazwa exe klienta (domyślnie: otclient)
      --launcher-version <VER>  Wersja launchera do raportowania
  -v, --verbose                 Szczegółowe logi
  -n, --dry-run                 Nie aplikuj zmian (tylko pokaż plan)
  -h, --help                    Pokaż tę pomoc

PRZYKŁADY:
  launcher-cli run --base-url https://api.example.com/v1 --channel stable
  launcher-cli update --base-url https://api.example.com/v1 -d ./client
  launcher-cli repair -d ./client
  launcher-cli status -d ./client
"#
    );
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_default() {
        let args = parse_from_vec(&[]);
        assert_eq!(args.command, "run");
        assert_eq!(args.channel, "stable");
        assert!(!args.verbose);
        assert!(!args.dry_run);
    }

    #[test]
    fn test_parse_full() {
        let args = parse_from_vec(&[
            "update".into(),
            "--base-url".into(),
            "https://api.example.com".into(),
            "--channel".into(),
            "test".into(),
            "--client-dir".into(),
            "/opt/game".into(),
            "--verbose".into(),
            "--dry-run".into(),
        ]);
        assert_eq!(args.command, "update");
        assert_eq!(args.base_url, "https://api.example.com");
        assert_eq!(args.channel, "test");
        assert_eq!(args.client_dir, "/opt/game");
        assert!(args.verbose);
        assert!(args.dry_run);
    }

    #[test]
    fn test_parse_short_flags() {
        let args = parse_from_vec(&[
            "run".into(),
            "-u".into(),
            "https://api.test.com".into(),
            "-c".into(),
            "dev".into(),
            "-d".into(),
            "./client".into(),
            "-v".into(),
        ]);
        assert_eq!(args.command, "run");
        assert_eq!(args.base_url, "https://api.test.com");
        assert_eq!(args.channel, "dev");
        assert_eq!(args.client_dir, "./client");
        assert!(args.verbose);
    }
}
