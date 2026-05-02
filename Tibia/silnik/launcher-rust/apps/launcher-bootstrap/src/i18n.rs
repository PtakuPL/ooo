/// Lightweight built-in i18n for the bootstrap launcher.
/// ~25 strings × 5 languages ≈ 5-10 KB compiled.  Zero extra dependencies.
use std::sync::OnceLock;

static CURRENT_LANG: OnceLock<Lang> = OnceLock::new();

/// Initialize the global language.  Call once at startup.
pub fn init(lang: Lang) {
    let _ = CURRENT_LANG.set(lang);
}

/// Get the active translation strings.
pub fn t() -> &'static Strings {
    strings(CURRENT_LANG.get().copied().unwrap_or(Lang::En))
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Lang {
    En,
    Pl,
    PtBr,
    Es,
    De,
}

impl Lang {
    pub const ALL: [Lang; 5] = [Lang::En, Lang::Pl, Lang::PtBr, Lang::Es, Lang::De];

    pub fn label(self) -> &'static str {
        match self {
            Lang::En => "English",
            Lang::Pl => "Polski",
            Lang::PtBr => "Português (Brasil)",
            Lang::Es => "Español",
            Lang::De => "Deutsch",
        }
    }

    pub fn code(self) -> &'static str {
        match self {
            Lang::En => "en",
            Lang::Pl => "pl",
            Lang::PtBr => "pt-br",
            Lang::Es => "es",
            Lang::De => "de",
        }
    }

    /// Try to match a language code string (case-insensitive, prefix).
    pub fn from_code(code: &str) -> Option<Lang> {
        let c = code.to_ascii_lowercase();
        if c.starts_with("pl") {
            return Some(Lang::Pl);
        }
        if c.starts_with("pt") {
            return Some(Lang::PtBr);
        }
        if c.starts_with("es") {
            return Some(Lang::Es);
        }
        if c.starts_with("de") {
            return Some(Lang::De);
        }
        if c.starts_with("en") {
            return Some(Lang::En);
        }
        None
    }
}

#[allow(dead_code)]
pub struct Strings {
    pub bootstrap_title: &'static str,
    pub installing_launcher: &'static str,
    pub existing_installation: &'static str,
    pub updating: &'static str,
    pub fetching_catalog: &'static str,
    pub invalid_api_response: &'static str,
    pub no_artifact: &'static str,
    pub downloading_launcher: &'static str,
    pub download_complete: &'static str,
    pub extracting: &'static str,
    pub saving_config: &'static str,
    pub install_complete: &'static str,
    pub launching: &'static str,
    pub error_http_client: &'static str,
    pub error_download: &'static str,
    pub error_hash_mismatch: &'static str,
    pub error_io: &'static str,
    pub error_unzip: &'static str,
    pub error_launcher_not_found: &'static str,
    pub error_temp_dir: &'static str,
    pub progress_label: &'static str,
    pub retry_message: &'static str,
    pub error_prefix: &'static str,
    pub choose_install_dir: &'static str,
    pub installed_at: &'static str,
    // Uninstall
    pub uninstall_confirm: &'static str,
    pub uninstall_complete: &'static str,
    pub uninstall_bootstrap_hint: &'static str,
    pub uninstall_removing_files: &'static str,
    pub uninstall_removing_registry: &'static str,
    pub uninstall_removing_shortcuts: &'static str,
    pub uninstall_killing_launcher: &'static str,
    pub existing_install_uninstall_prompt: &'static str,
    // Install additions
    pub registering_uninstaller: &'static str,
    pub creating_shortcuts: &'static str,
    pub desktop_shortcut_prompt: &'static str,
    pub copying_uninstaller: &'static str,
    pub install_dir_hint: &'static str,
}

pub fn strings(lang: Lang) -> &'static Strings {
    match lang {
        Lang::En => &EN,
        Lang::Pl => &PL,
        Lang::PtBr => &PT_BR,
        Lang::Es => &ES,
        Lang::De => &DE,
    }
}

static EN: Strings = Strings {
    bootstrap_title: "RedDaxe.pl \u{2014} Installer",
    installing_launcher: "installing launcher",
    existing_installation: "Existing launcher installation detected.",
    updating: "Updating to latest version\u{2026}",
    fetching_catalog: "Fetching artifact catalog\u{2026}",
    invalid_api_response: "Invalid API response",
    no_artifact: "No artifact for platform",
    downloading_launcher: "Downloading full launcher",
    download_complete: "Download complete. SHA-256 verified.",
    extracting: "Extracting launcher\u{2026}",
    saving_config: "Saving configuration\u{2026}",
    install_complete: "Installation complete! Launching\u{2026}",
    launching: "Starting launcher\u{2026}",
    error_http_client: "Cannot create HTTP client",
    error_download: "Download error",
    error_hash_mismatch: "SHA-256 verification failed",
    error_io: "I/O error",
    error_unzip: "Extraction error",
    error_launcher_not_found: "Launcher executable not found in downloaded archive",
    error_temp_dir: "Cannot create temporary directory",
    progress_label: "Progress",
    retry_message: "failed, retrying\u{2026}",
    error_prefix: "ERROR",
    choose_install_dir: "Choose where to install the launcher:",
    installed_at: "Launcher installed in:",
    uninstall_confirm: "Are you sure you want to uninstall RedDaxe.pl?\n\nThis will remove: launcher files, game files, shortcuts, and settings.",
    uninstall_complete: "Uninstallation complete.",
    uninstall_bootstrap_hint: "The installer in your Downloads folder can be deleted manually.",
    uninstall_removing_files: "Removing installed files\u{2026}",
    uninstall_removing_registry: "Removing registry entry\u{2026}",
    uninstall_removing_shortcuts: "Removing shortcuts\u{2026}",
    uninstall_killing_launcher: "Closing running launcher\u{2026}",
    existing_install_uninstall_prompt: "An existing installation was found.\n\nYES = Uninstall everything and exit\nNO = Update (reinstall)\nCANCEL = Abort",
    registering_uninstaller: "Registering uninstaller\u{2026}",
    creating_shortcuts: "Creating shortcuts\u{2026}",
    desktop_shortcut_prompt: "Create a desktop shortcut for RedDaxe.pl?",
    copying_uninstaller: "Setting up uninstaller\u{2026}",
    install_dir_hint: "Click YES to install here, or NO to choose a different folder.",
};

static PL: Strings = Strings {
    bootstrap_title: "RedDaxe.pl \u{2014} Installer",
    installing_launcher: "instalacja launchera",
    existing_installation: "Wykryto istniej\u{0105}c\u{0105} instalacj\u{0119} launchera.",
    updating: "Aktualizuj\u{0119} do najnowszej wersji\u{2026}",
    fetching_catalog: "Pobieranie katalogu artefakt\u{00f3}w\u{2026}",
    invalid_api_response: "Nieprawid\u{0142}owa odpowied\u{017a} API",
    no_artifact: "Brak artefaktu dla platformy",
    downloading_launcher: "Pobieranie pe\u{0142}nego launchera",
    download_complete: "Pobieranie zako\u{0144}czone. Weryfikacja SHA-256 OK.",
    extracting: "Rozpakowywanie launchera\u{2026}",
    saving_config: "Zapisywanie konfiguracji\u{2026}",
    install_complete: "Instalacja zako\u{0144}czona! Uruchamiam launcher\u{2026}",
    launching: "Uruchamianie launchera\u{2026}",
    error_http_client: "Nie mo\u{017c}na utworzy\u{0107} klienta HTTP",
    error_download: "B\u{0142}\u{0105}d pobierania",
    error_hash_mismatch: "Weryfikacja SHA-256 nie powiod\u{0142}a si\u{0119}",
    error_io: "B\u{0142}\u{0105}d I/O",
    error_unzip: "B\u{0142}\u{0105}d rozpakowania",
    error_launcher_not_found: "Nie znaleziono pliku launchera w pobranym archiwum",
    error_temp_dir: "Nie mo\u{017c}na utworzy\u{0107} katalogu tymczasowego",
    progress_label: "Post\u{0119}p",
    retry_message: "nie powiod\u{0142}a si\u{0119}, ponawiam\u{2026}",
    error_prefix: "B\u{0141}\u{0104}D",
    choose_install_dir: "Wybierz folder instalacji launchera:",
    installed_at: "Launcher zainstalowany w:",
    uninstall_confirm: "Na pewno chcesz odinstalowa\u{0107} RedDaxe.pl?\n\nUsuni\u{0119}te zostan\u{0105}: pliki launchera, pliki gry, skr\u{00f3}ty, ustawienia.",
    uninstall_complete: "Deinstalacja zako\u{0144}czona.",
    uninstall_bootstrap_hint: "Plik instalatora w folderze Pobrane mo\u{017c}esz usun\u{0105}\u{0107} r\u{0119}cznie.",
    uninstall_removing_files: "Usuwanie plik\u{00f3}w\u{2026}",
    uninstall_removing_registry: "Usuwanie wpisu z rejestru\u{2026}",
    uninstall_removing_shortcuts: "Usuwanie skr\u{00f3}t\u{00f3}w\u{2026}",
    uninstall_killing_launcher: "Zamykanie dzia\u{0142}aj\u{0105}cego launchera\u{2026}",
    existing_install_uninstall_prompt: "Wykryto istniej\u{0105}c\u{0105} instalacj\u{0119}.\n\nTAK = Odinstaluj wszystko i zako\u{0144}cz\nNIE = Aktualizuj (reinstalacja)\nANULUJ = Przerwij",
    registering_uninstaller: "Rejestrowanie deinstalatora\u{2026}",
    creating_shortcuts: "Tworzenie skr\u{00f3}t\u{00f3}w\u{2026}",
    desktop_shortcut_prompt: "Utworzy\u{0107} skr\u{00f3}t na pulpicie dla RedDaxe.pl?",
    copying_uninstaller: "Przygotowywanie deinstalatora\u{2026}",
    install_dir_hint: "Kliknij TAK aby zainstalowa\u{0107} tutaj, lub NIE aby wybra\u{0107} inny folder.",
};

static PT_BR: Strings = Strings {
    bootstrap_title: "RedDaxe.pl \u{2014} Installer",
    installing_launcher: "instala\u{00e7}\u{00e3}o do launcher",
    existing_installation: "Instala\u{00e7}\u{00e3}o existente do launcher detectada.",
    updating: "Atualizando para a vers\u{00e3}o mais recente\u{2026}",
    fetching_catalog: "Buscando cat\u{00e1}logo de artefatos\u{2026}",
    invalid_api_response: "Resposta inv\u{00e1}lida da API",
    no_artifact: "Nenhum artefato para a plataforma",
    downloading_launcher: "Baixando o launcher completo",
    download_complete: "Download conclu\u{00ed}do. SHA-256 verificado.",
    extracting: "Extraindo launcher\u{2026}",
    saving_config: "Salvando configura\u{00e7}\u{00e3}o\u{2026}",
    install_complete: "Instala\u{00e7}\u{00e3}o conclu\u{00ed}da! Iniciando\u{2026}",
    launching: "Iniciando o launcher\u{2026}",
    error_http_client: "N\u{00e3}o foi poss\u{00ed}vel criar o cliente HTTP",
    error_download: "Erro no download",
    error_hash_mismatch: "Verifica\u{00e7}\u{00e3}o SHA-256 falhou",
    error_io: "Erro de E/S",
    error_unzip: "Erro na extra\u{00e7}\u{00e3}o",
    error_launcher_not_found: "Execut\u{00e1}vel do launcher n\u{00e3}o encontrado no arquivo",
    error_temp_dir: "N\u{00e3}o foi poss\u{00ed}vel criar o diret\u{00f3}rio tempor\u{00e1}rio",
    progress_label: "Progresso",
    retry_message: "falhou, tentando novamente\u{2026}",
    error_prefix: "ERRO",
    choose_install_dir: "Escolha onde instalar o launcher:",
    installed_at: "Launcher instalado em:",
    uninstall_confirm: "Tem certeza que deseja desinstalar o RedDaxe.pl?\n\nSer\u{00e3}o removidos: arquivos do launcher, arquivos do jogo, atalhos e configura\u{00e7}\u{00f5}es.",
    uninstall_complete: "Desinstala\u{00e7}\u{00e3}o conclu\u{00ed}da.",
    uninstall_bootstrap_hint: "O arquivo do instalador na pasta de Downloads pode ser exclu\u{00ed}do manualmente.",
    uninstall_removing_files: "Removendo arquivos\u{2026}",
    uninstall_removing_registry: "Removendo entrada do registro\u{2026}",
    uninstall_removing_shortcuts: "Removendo atalhos\u{2026}",
    uninstall_killing_launcher: "Fechando o launcher em execu\u{00e7}\u{00e3}o\u{2026}",
    existing_install_uninstall_prompt: "Instala\u{00e7}\u{00e3}o existente encontrada.\n\nSIM = Desinstalar tudo e sair\nN\u{00c3}O = Atualizar (reinstalar)\nCANCELAR = Abortar",
    registering_uninstaller: "Registrando desinstalador\u{2026}",
    creating_shortcuts: "Criando atalhos\u{2026}",
    desktop_shortcut_prompt: "Criar um atalho na \u{00e1}rea de trabalho para o RedDaxe.pl?",
    copying_uninstaller: "Configurando desinstalador\u{2026}",
    install_dir_hint: "Clique SIM para instalar aqui, ou N\u{00c3}O para escolher outra pasta.",
};

static ES: Strings = Strings {
    bootstrap_title: "RedDaxe.pl \u{2014} Installer",
    installing_launcher: "instalaci\u{00f3}n del launcher",
    existing_installation: "Se detect\u{00f3} una instalaci\u{00f3}n existente del launcher.",
    updating: "Actualizando a la \u{00fa}ltima versi\u{00f3}n\u{2026}",
    fetching_catalog: "Obteniendo cat\u{00e1}logo de artefactos\u{2026}",
    invalid_api_response: "Respuesta de API inv\u{00e1}lida",
    no_artifact: "No hay artefacto para la plataforma",
    downloading_launcher: "Descargando el launcher completo",
    download_complete: "Descarga completada. SHA-256 verificado.",
    extracting: "Extrayendo launcher\u{2026}",
    saving_config: "Guardando configuraci\u{00f3}n\u{2026}",
    install_complete: "\u{00a1}Instalaci\u{00f3}n completa! Iniciando\u{2026}",
    launching: "Iniciando el launcher\u{2026}",
    error_http_client: "No se pudo crear el cliente HTTP",
    error_download: "Error de descarga",
    error_hash_mismatch: "La verificaci\u{00f3}n SHA-256 fall\u{00f3}",
    error_io: "Error de E/S",
    error_unzip: "Error de extracci\u{00f3}n",
    error_launcher_not_found: "Ejecutable del launcher no encontrado en el archivo",
    error_temp_dir: "No se pudo crear el directorio temporal",
    progress_label: "Progreso",
    retry_message: "fall\u{00f3}, reintentando\u{2026}",
    error_prefix: "ERROR",
    choose_install_dir: "Elige d\u{00f3}nde instalar el launcher:",
    installed_at: "Launcher instalado en:",
    uninstall_confirm: "\u{00bf}Est\u{00e1}s seguro de que quieres desinstalar RedDaxe.pl?\n\nSe eliminar\u{00e1}n: archivos del launcher, archivos del juego, accesos directos y configuraci\u{00f3}n.",
    uninstall_complete: "Desinstalaci\u{00f3}n completada.",
    uninstall_bootstrap_hint: "El archivo del instalador en tu carpeta de Descargas puede eliminarse manualmente.",
    uninstall_removing_files: "Eliminando archivos\u{2026}",
    uninstall_removing_registry: "Eliminando entrada del registro\u{2026}",
    uninstall_removing_shortcuts: "Eliminando accesos directos\u{2026}",
    uninstall_killing_launcher: "Cerrando el launcher en ejecuci\u{00f3}n\u{2026}",
    existing_install_uninstall_prompt: "Se encontr\u{00f3} una instalaci\u{00f3}n existente.\n\nS\u{00cd} = Desinstalar todo y salir\nNO = Actualizar (reinstalar)\nCANCELAR = Abortar",
    registering_uninstaller: "Registrando desinstalador\u{2026}",
    creating_shortcuts: "Creando accesos directos\u{2026}",
    desktop_shortcut_prompt: "\u{00bf}Crear un acceso directo en el escritorio para RedDaxe.pl?",
    copying_uninstaller: "Configurando desinstalador\u{2026}",
    install_dir_hint: "Haz clic en S\u{00cd} para instalar aqu\u{00ed}, o NO para elegir otra carpeta.",
};

static DE: Strings = Strings {
    bootstrap_title: "RedDaxe.pl \u{2014} Installer",
    installing_launcher: "Launcher-Installation",
    existing_installation: "Bestehende Launcher-Installation erkannt.",
    updating: "Aktualisierung auf die neueste Version\u{2026}",
    fetching_catalog: "Artefaktkatalog wird abgerufen\u{2026}",
    invalid_api_response: "Ung\u{00fc}ltige API-Antwort",
    no_artifact: "Kein Artefakt f\u{00fc}r die Plattform",
    downloading_launcher: "Vollst\u{00e4}ndiger Launcher wird heruntergeladen",
    download_complete: "Download abgeschlossen. SHA-256 verifiziert.",
    extracting: "Launcher wird entpackt\u{2026}",
    saving_config: "Konfiguration wird gespeichert\u{2026}",
    install_complete: "Installation abgeschlossen! Starte Launcher\u{2026}",
    launching: "Launcher wird gestartet\u{2026}",
    error_http_client: "HTTP-Client konnte nicht erstellt werden",
    error_download: "Downloadfehler",
    error_hash_mismatch: "SHA-256-Pr\u{00fc}fung fehlgeschlagen",
    error_io: "E/A-Fehler",
    error_unzip: "Entpackfehler",
    error_launcher_not_found: "Launcher-Datei im heruntergeladenen Archiv nicht gefunden",
    error_temp_dir: "Tempor\u{00e4}res Verzeichnis konnte nicht erstellt werden",
    progress_label: "Fortschritt",
    retry_message: "fehlgeschlagen, erneuter Versuch\u{2026}",
    error_prefix: "FEHLER",
    choose_install_dir: "W\u{00e4}hlen Sie den Installationsordner:",
    installed_at: "Launcher installiert in:",
    uninstall_confirm: "M\u{00f6}chten Sie RedDaxe.pl wirklich deinstallieren?\n\nFolgendes wird entfernt: Launcher-Dateien, Spieldateien, Verkn\u{00fc}pfungen und Einstellungen.",
    uninstall_complete: "Deinstallation abgeschlossen.",
    uninstall_bootstrap_hint: "Die Installationsdatei in Ihrem Download-Ordner k\u{00f6}nnen Sie manuell l\u{00f6}schen.",
    uninstall_removing_files: "Dateien werden entfernt\u{2026}",
    uninstall_removing_registry: "Registrierungseintrag wird entfernt\u{2026}",
    uninstall_removing_shortcuts: "Verkn\u{00fc}pfungen werden entfernt\u{2026}",
    uninstall_killing_launcher: "Laufender Launcher wird geschlossen\u{2026}",
    existing_install_uninstall_prompt: "Bestehende Installation gefunden.\n\nJA = Alles deinstallieren und beenden\nNEIN = Aktualisieren (Neuinstallation)\nABBRECHEN = Abbrechen",
    registering_uninstaller: "Deinstallationsprogramm wird registriert\u{2026}",
    creating_shortcuts: "Verkn\u{00fc}pfungen werden erstellt\u{2026}",
    desktop_shortcut_prompt: "Desktop-Verkn\u{00fc}pfung f\u{00fc}r RedDaxe.pl erstellen?",
    copying_uninstaller: "Deinstallationsprogramm wird eingerichtet\u{2026}",
    install_dir_hint: "Klicken Sie JA um hier zu installieren, oder NEIN um einen anderen Ordner zu w\u{00e4}hlen.",
};

// ── Auto-detection ──

/// Detect the user's preferred language from OS settings.
/// Returns None if the language is not in our supported list.
#[allow(dead_code)]
pub fn detect_system_language() -> Option<Lang> {
    #[cfg(target_os = "windows")]
    {
        detect_windows_language()
    }
    #[cfg(not(target_os = "windows"))]
    {
        detect_unix_language()
    }
}

#[cfg(target_os = "windows")]
#[allow(dead_code)]
fn detect_windows_language() -> Option<Lang> {
    extern "system" {
        fn GetUserDefaultUILanguage() -> u16;
    }
    let lcid = unsafe { GetUserDefaultUILanguage() };
    let primary = lcid & 0x3FF; // Primary language ID
    match primary {
        0x15 => Some(Lang::Pl),   // Polish
        0x16 => Some(Lang::PtBr), // Portuguese
        0x0A => Some(Lang::Es),   // Spanish
        0x07 => Some(Lang::De),   // German
        0x09 => Some(Lang::En),   // English
        _ => None,
    }
}

#[cfg(not(target_os = "windows"))]
#[allow(dead_code)]
fn detect_unix_language() -> Option<Lang> {
    let lang_var = std::env::var("LANG")
        .or_else(|_| std::env::var("LC_ALL"))
        .or_else(|_| std::env::var("LC_MESSAGES"))
        .unwrap_or_default();
    Lang::from_code(&lang_var)
}

// ── Language selection dialog ──

/// Show a language selection dialog. Returns the chosen language.
/// On Windows: native Win32 dialog.  On Linux: console prompt.
pub fn choose_language_dialog() -> Lang {
    #[cfg(target_os = "windows")]
    {
        choose_language_win32()
    }
    #[cfg(not(target_os = "windows"))]
    {
        choose_language_console()
    }
}

#[cfg(target_os = "windows")]
fn choose_language_win32() -> Lang {
    use std::ffi::OsStr;
    use std::os::windows::ffi::OsStrExt;

    extern "system" {
        fn MessageBoxW(hwnd: *mut u8, text: *const u16, caption: *const u16, utype: u32) -> i32;
    }

    // Build the message with numbered options
    let mut msg = String::from("Choose your language / Wybierz język:\n\n");
    for (i, lang) in Lang::ALL.iter().enumerate() {
        msg.push_str(&format!("  {}. {}\n", i + 1, lang.label()));
    }
    msg.push_str(
        "\nClick a button:\nYes/Tak = English | No/Nie = Polski | Cancel/Anuluj = more options",
    );

    fn to_wide(s: &str) -> Vec<u16> {
        OsStr::new(s)
            .encode_wide()
            .chain(std::iter::once(0))
            .collect()
    }

    loop {
        let text_w = to_wide(&msg);
        let caption_w = to_wide("RedDaxe.pl \u{2014} Language");

        // MB_YESNOCANCEL | MB_ICONQUESTION = 0x23
        let result = unsafe {
            MessageBoxW(
                std::ptr::null_mut(),
                text_w.as_ptr(),
                caption_w.as_ptr(),
                0x23,
            )
        };

        match result {
            6 => return Lang::En, // IDYES
            7 => return Lang::Pl, // IDNO
            _ => {
                // IDCANCEL → show extended picker; None = user wants to go back
                if let Some(lang) = choose_language_extended_win32() {
                    return lang;
                }
                // None → loop back to main picker
            }
        }
    }
}

#[cfg(target_os = "windows")]
fn choose_language_extended_win32() -> Option<Lang> {
    use std::ffi::OsStr;
    use std::os::windows::ffi::OsStrExt;

    extern "system" {
        fn MessageBoxW(hwnd: *mut u8, text: *const u16, caption: *const u16, utype: u32) -> i32;
    }

    fn to_wide(s: &str) -> Vec<u16> {
        OsStr::new(s)
            .encode_wide()
            .chain(std::iter::once(0))
            .collect()
    }

    // Page 1: PT-BR, ES, more
    let msg1 = "3. Português (Brasil)\n4. Español\n5. Deutsch\n\n\
                Yes/Tak = Português | No/Nie = Español | Cancel/Anuluj = next \u{2192}";
    let text_w = to_wide(msg1);
    let caption_w = to_wide("RedDaxe.pl \u{2014} Language (2/3)");

    let result = unsafe {
        MessageBoxW(
            std::ptr::null_mut(),
            text_w.as_ptr(),
            caption_w.as_ptr(),
            0x23,
        )
    };

    match result {
        6 => return Some(Lang::PtBr), // IDYES
        7 => return Some(Lang::Es),   // IDNO
        _ => {}                       // IDCANCEL → page 2
    }

    // Page 2: DE or back
    let msg2 = "5. Deutsch\n\n\
                Yes/Tak = Deutsch | No/Nie = \u{2190} Wróć / Back";
    let text_w2 = to_wide(msg2);
    let caption_w2 = to_wide("RedDaxe.pl \u{2014} Language (3/3)");

    // MB_YESNO | MB_ICONQUESTION = 0x24
    let result2 = unsafe {
        MessageBoxW(
            std::ptr::null_mut(),
            text_w2.as_ptr(),
            caption_w2.as_ptr(),
            0x24,
        )
    };

    match result2 {
        6 => Some(Lang::De), // IDYES = Deutsch
        _ => None,           // IDNO = back to main picker
    }
}

#[cfg(not(target_os = "windows"))]
fn choose_language_console() -> Lang {
    eprintln!("\nChoose your language / Wybierz język:");
    for (i, lang) in Lang::ALL.iter().enumerate() {
        eprintln!("  {}. {}", i + 1, lang.label());
    }
    eprint!("Enter number [1-5]: ");

    let mut input = String::new();
    if std::io::stdin().read_line(&mut input).is_ok() {
        match input.trim() {
            "1" => return Lang::En,
            "2" => return Lang::Pl,
            "3" => return Lang::PtBr,
            "4" => return Lang::Es,
            "5" => return Lang::De,
            _ => {}
        }
    }
    Lang::En // default
}

// ── Persistence ──

/// Try to load the saved language preference.
pub fn load_saved_language() -> Option<Lang> {
    let path = language_conf_path()?;
    let content = std::fs::read_to_string(path).ok()?;
    Lang::from_code(content.trim())
}

/// Save the language preference to disk.
pub fn save_language(lang: Lang) {
    if let Some(path) = language_conf_path() {
        if let Some(parent) = path.parent() {
            let _ = std::fs::create_dir_all(parent);
        }
        let _ = std::fs::write(path, lang.code());
    }
}

/// Delete the saved language preference (used during full uninstall).
pub fn delete_saved_language() {
    if let Some(path) = language_conf_path() {
        let _ = std::fs::remove_file(&path);
    }
}

fn language_conf_path() -> Option<std::path::PathBuf> {
    #[cfg(target_os = "windows")]
    {
        std::env::var("LOCALAPPDATA").ok().map(|p| {
            std::path::PathBuf::from(p)
                .join("RedDaxe")
                .join("language.conf")
        })
    }
    #[cfg(not(target_os = "windows"))]
    {
        std::env::var("HOME").ok().map(|p| {
            std::path::PathBuf::from(p)
                .join(".config")
                .join("RedDaxe")
                .join("language.conf")
        })
    }
}

/// Resolve the language to use:
/// 1. Saved preference (from previous run) → use directly
/// 2. First run → ALWAYS show dialog (user's decision, even if OS language detected)
pub fn resolve_language() -> Lang {
    // 1. Check saved preference
    if let Some(lang) = load_saved_language() {
        return lang;
    }

    // 2. First run — always show dialog, regardless of OS language
    let lang = choose_language_dialog();
    save_language(lang);
    lang
}
