//! Ustandaryzowane kody błędów launchera (LCH_*).
//!
//! Używane w logach, installed_state.json (lastErrorCode) i UI.

/// Kody błędów launchera zgodne z docs/contracts/error-codes.md
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum LauncherErrorCode {
    ManifestFetchFailed,
    ManifestParseFailed,
    ManifestSchemaUnsupported,
    ManifestSignatureInvalid,
    ManifestPathTraversal,
    ManifestDuplicatePath,
    DownloadFailed,
    FileHashMismatch,
    PatchApplyFailed,
    RollbackFailed,
    RollbackSuccess,
    FilesHashComputeFailed,
    TokenRequestFailed,
    TokenRejected,
    TokenRateLimited,
    ClientStartFailed,
    ClientNotFound,
    TlsRequired,
    StateCorrupted,
    LauncherUpdateRequired,
    StagingCleanupFailed,
}

impl LauncherErrorCode {
    /// Zwraca kod w formacie `LCH_*` do zapisu w logach/state.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::ManifestFetchFailed => "LCH_MANIFEST_FETCH_FAILED",
            Self::ManifestParseFailed => "LCH_MANIFEST_PARSE_FAILED",
            Self::ManifestSchemaUnsupported => "LCH_MANIFEST_SCHEMA_UNSUPPORTED",
            Self::ManifestSignatureInvalid => "LCH_MANIFEST_SIGNATURE_INVALID",
            Self::ManifestPathTraversal => "LCH_MANIFEST_PATH_TRAVERSAL",
            Self::ManifestDuplicatePath => "LCH_MANIFEST_DUPLICATE_PATH",
            Self::DownloadFailed => "LCH_DOWNLOAD_FAILED",
            Self::FileHashMismatch => "LCH_FILE_HASH_MISMATCH",
            Self::PatchApplyFailed => "LCH_PATCH_APPLY_FAILED",
            Self::RollbackFailed => "LCH_ROLLBACK_FAILED",
            Self::RollbackSuccess => "LCH_ROLLBACK_SUCCESS",
            Self::FilesHashComputeFailed => "LCH_FILES_HASH_COMPUTE_FAILED",
            Self::TokenRequestFailed => "LCH_TOKEN_REQUEST_FAILED",
            Self::TokenRejected => "LCH_TOKEN_REJECTED",
            Self::TokenRateLimited => "LCH_TOKEN_RATE_LIMITED",
            Self::ClientStartFailed => "LCH_CLIENT_START_FAILED",
            Self::ClientNotFound => "LCH_CLIENT_NOT_FOUND",
            Self::TlsRequired => "LCH_TLS_REQUIRED",
            Self::StateCorrupted => "LCH_STATE_CORRUPTED",
            Self::LauncherUpdateRequired => "LCH_LAUNCHER_UPDATE_REQUIRED",
            Self::StagingCleanupFailed => "LCH_STAGING_CLEANUP_FAILED",
        }
    }

    /// Komunikat user-facing (do UI).
    pub fn user_message(&self) -> &'static str {
        match self {
            Self::ManifestFetchFailed => {
                "Nie można sprawdzić aktualizacji. Sprawdź połączenie internetowe."
            }
            Self::ManifestParseFailed => "Błąd danych aktualizacji. Spróbuj ponownie.",
            Self::ManifestSchemaUnsupported => "Wymagana nowsza wersja launchera.",
            Self::ManifestSignatureInvalid => "Błąd weryfikacji aktualizacji. Zgłoś problem.",
            Self::ManifestPathTraversal => "Wykryto niebezpieczną ścieżkę w aktualizacji.",
            Self::ManifestDuplicatePath => "Błąd danych aktualizacji (duplikat pliku).",
            Self::DownloadFailed => "Nie można pobrać pliku. Sprawdź połączenie.",
            Self::FileHashMismatch => "Pobrany plik jest uszkodzony. Ponów pobieranie.",
            Self::PatchApplyFailed => "Aktualizacja nie powiodła się. Spróbuj naprawić instalację.",
            Self::RollbackFailed => "Przywracanie nie powiodło się. Napraw instalację ręcznie.",
            Self::RollbackSuccess => "Aktualizacja cofnięta do poprzedniej wersji.",
            Self::FilesHashComputeFailed => "Błąd weryfikacji plików. Napraw instalację.",
            Self::TokenRequestFailed => "Nie można uzyskać tokena startu. Spróbuj ponownie.",
            Self::TokenRejected => "Token odrzucony. Sprawdź aktualizacje.",
            Self::TokenRateLimited => "Za dużo prób. Poczekaj chwilę.",
            Self::ClientStartFailed => "Nie można uruchomić gry. Sprawdź instalację.",
            Self::ClientNotFound => "Plik klienta gry nie znaleziony. Napraw instalację.",
            Self::TlsRequired => "Wymagane bezpieczne połączenie (HTTPS).",
            Self::StateCorrupted => "Stan launchera uszkodzony. Uruchamiam naprawę.",
            Self::LauncherUpdateRequired => "Wymagana aktualizacja launchera.",
            Self::StagingCleanupFailed => "Ostrzeżenie: pliki tymczasowe nie zostały wyczyszczone.",
        }
    }
}

impl std::fmt::Display for LauncherErrorCode {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}
