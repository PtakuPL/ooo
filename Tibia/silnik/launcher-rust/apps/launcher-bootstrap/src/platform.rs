use std::path::PathBuf;

/// Detected platform identifier sent to the API.
pub fn platform_name() -> &'static str {
    if cfg!(target_os = "windows") {
        "windows"
    } else if cfg!(target_os = "linux") {
        "linux"
    } else {
        "unknown"
    }
}

/// CPU architecture string sent to the API.
pub fn arch_name() -> &'static str {
    if cfg!(target_arch = "x86_64") {
        "x86_64"
    } else if cfg!(target_arch = "aarch64") {
        "arm64"
    } else {
        "unknown"
    }
}

/// Default installation directory for the full launcher.
///
/// Windows: `%LOCALAPPDATA%\RedDaxe\`
/// Linux:   `~/Games/RedDaxe/`
pub fn default_install_dir() -> PathBuf {
    #[cfg(target_os = "windows")]
    {
        if let Ok(local) = std::env::var("LOCALAPPDATA") {
            return PathBuf::from(local).join("RedDaxe");
        }
        PathBuf::from(r"C:\RedDaxe")
    }
    #[cfg(not(target_os = "windows"))]
    {
        if let Ok(home) = std::env::var("HOME") {
            return PathBuf::from(home).join("Games").join("RedDaxe");
        }
        PathBuf::from("/tmp/RedDaxe")
    }
}

/// Ask the user where to install. Returns `Some(path)` or `None` if cancelled.
///
/// Windows: shows a "Yes/No" MessageBox with default path. If "No",
///          opens a folder picker dialog (SHBrowseForFolderW).
///          If user cancels the folder picker → returns `None` (abort).
/// Linux:   returns the default path (no GUI available).
pub fn ask_install_dir(prompt_title: &str, prompt_msg: &str, hint_msg: &str) -> Option<PathBuf> {
    let default = default_install_dir();

    #[cfg(target_os = "windows")]
    {
        return win_ask_install_dir(&default, prompt_title, prompt_msg, hint_msg);
    }

    #[cfg(not(target_os = "windows"))]
    {
        let _ = (prompt_title, prompt_msg, hint_msg);
        Some(default)
    }
}

#[cfg(target_os = "windows")]
fn win_ask_install_dir(
    default: &std::path::Path,
    title: &str,
    msg: &str,
    hint: &str,
) -> Option<PathBuf> {
    use std::ffi::OsStr;
    use std::os::windows::ffi::OsStrExt;

    fn to_wide(s: &str) -> Vec<u16> {
        OsStr::new(s)
            .encode_wide()
            .chain(std::iter::once(0))
            .collect()
    }

    #[link(name = "user32")]
    extern "system" {
        fn MessageBoxW(hwnd: *mut u8, text: *const u16, caption: *const u16, utype: u32) -> i32;
    }

    // Ask: "Install to <default>?"  YES=default, NO=pick folder
    let full_msg = format!("{msg}\n\n{}\n\n{hint}", default.display());
    let text_w = to_wide(&full_msg);
    let caption_w = to_wide(title);

    let result = unsafe {
        MessageBoxW(
            std::ptr::null_mut(),
            text_w.as_ptr(),
            caption_w.as_ptr(),
            0x24, // MB_YESNO | MB_ICONQUESTION
        )
    };

    if result == 6 {
        // IDYES
        return Some(default.to_path_buf());
    }

    // User wants to pick a folder — None means user cancelled (abort)
    win_browse_for_folder(title)
}

#[cfg(target_os = "windows")]
fn win_browse_for_folder(title: &str) -> Option<PathBuf> {
    use std::ffi::OsStr;
    use std::os::windows::ffi::OsStrExt;

    fn to_wide(s: &str) -> Vec<u16> {
        OsStr::new(s)
            .encode_wide()
            .chain(std::iter::once(0))
            .collect()
    }

    #[repr(C)]
    #[allow(non_snake_case)]
    struct BROWSEINFOW {
        hwndOwner: *mut u8,
        pidlRoot: *mut u8,
        pszDisplayName: *mut u16,
        lpszTitle: *const u16,
        ulFlags: u32,
        lpfn: *mut u8,
        lParam: isize,
        iImage: i32,
    }

    #[link(name = "ole32")]
    extern "system" {
        fn CoInitializeEx(reserved: *mut u8, co_init: u32) -> i32;
        fn CoTaskMemFree(pv: *mut u8);
    }

    #[link(name = "shell32")]
    extern "system" {
        fn SHBrowseForFolderW(bi: *const BROWSEINFOW) -> *mut u8;
        fn SHGetPathFromIDListW(pidl: *const u8, path: *mut u16) -> i32;
    }

    const BIF_RETURNONLYFSDIRS: u32 = 0x0001;
    const BIF_NEWDIALOGSTYLE: u32 = 0x0040;
    const COINIT_APARTMENTTHREADED: u32 = 0x2;

    unsafe {
        CoInitializeEx(std::ptr::null_mut(), COINIT_APARTMENTTHREADED);
    }

    let title_w = to_wide(title);
    let mut display_name: Vec<u16> = vec![0u16; 260];

    let bi = BROWSEINFOW {
        hwndOwner: std::ptr::null_mut(),
        pidlRoot: std::ptr::null_mut(),
        pszDisplayName: display_name.as_mut_ptr(),
        lpszTitle: title_w.as_ptr(),
        ulFlags: BIF_RETURNONLYFSDIRS | BIF_NEWDIALOGSTYLE,
        lpfn: std::ptr::null_mut(),
        lParam: 0,
        iImage: 0,
    };

    let pidl = unsafe { SHBrowseForFolderW(&bi) };
    if pidl.is_null() {
        return None; // User cancelled
    }

    let mut path_buf: Vec<u16> = vec![0u16; 260];
    let ok = unsafe { SHGetPathFromIDListW(pidl, path_buf.as_mut_ptr()) };
    unsafe {
        CoTaskMemFree(pidl);
    }

    if ok == 0 {
        return None;
    }

    let len = path_buf
        .iter()
        .position(|&c| c == 0)
        .unwrap_or(path_buf.len());
    let path_str = String::from_utf16_lossy(&path_buf[..len]);

    if path_str.is_empty() {
        None
    } else {
        Some(PathBuf::from(path_str).join("RedDaxe"))
    }
}

/// Name of the full launcher executable for the current platform.
pub fn launcher_exe_name() -> &'static str {
    if cfg!(target_os = "windows") {
        "launcher-tauri-windows-x86_64.exe"
    } else {
        "launcher-tauri-linux-x86_64"
    }
}

/// Path to the user's Desktop folder.
#[cfg(target_os = "windows")]
pub fn desktop_path() -> Option<PathBuf> {
    std::env::var("USERPROFILE")
        .ok()
        .map(|p| PathBuf::from(p).join("Desktop"))
}

/// Path to the Start Menu Programs folder (Windows only).
#[cfg(target_os = "windows")]
pub fn start_menu_path() -> Option<PathBuf> {
    std::env::var("APPDATA").ok().map(|p| {
        PathBuf::from(p)
            .join("Microsoft")
            .join("Windows")
            .join("Start Menu")
            .join("Programs")
    })
}

/// Create shortcuts for the launcher.
/// `ask_desktop` — if true, also creates a desktop shortcut.
pub fn create_shortcuts(install_dir: &std::path::Path, ask_desktop: bool) {
    #[cfg(target_os = "windows")]
    {
        let launcher_exe = install_dir.join(launcher_exe_name());

        // Start Menu shortcut (always)
        if let Some(sm_dir) = start_menu_path() {
            let lnk = sm_dir.join("RedDaxe.lnk");
            let _ = create_shortcut_win(&lnk, &launcher_exe, "RedDaxe.pl Launcher");
        }
        // Desktop shortcut (if user agreed)
        if ask_desktop {
            if let Some(desktop) = desktop_path() {
                let lnk = desktop.join("RedDaxe.lnk");
                let _ = create_shortcut_win(&lnk, &launcher_exe, "RedDaxe.pl Launcher");
            }
        }
    }

    #[cfg(target_os = "linux")]
    {
        let _ = ask_desktop;
        create_desktop_entry_linux(install_dir);
    }
}

#[cfg(target_os = "windows")]
fn create_shortcut_win(
    shortcut_path: &std::path::Path,
    target: &std::path::Path,
    description: &str,
) -> Result<(), std::io::Error> {
    // Escape single quotes for PowerShell single-quoted strings
    fn ps_escape(s: &str) -> String {
        s.replace('\'', "''")
    }

    let ps_script = format!(
        "$ws = New-Object -ComObject WScript.Shell; \
         $sc = $ws.CreateShortcut('{}'); \
         $sc.TargetPath = '{}'; \
         $sc.Description = '{}'; \
         $sc.WorkingDirectory = '{}'; \
         $sc.Save()",
        ps_escape(&shortcut_path.display().to_string()),
        ps_escape(&target.display().to_string()),
        ps_escape(description),
        ps_escape(
            &target
                .parent()
                .map(|p| p.display().to_string())
                .unwrap_or_default()
        ),
    );

    std::process::Command::new("powershell")
        .args(["-NoProfile", "-NonInteractive", "-Command", &ps_script])
        .output()
        .map(|_| ())
}

#[cfg(target_os = "linux")]
fn create_desktop_entry_linux(install_dir: &std::path::Path) {
    if let Ok(home) = std::env::var("HOME") {
        let desktop_entry_path = PathBuf::from(&home)
            .join(".local")
            .join("share")
            .join("applications")
            .join("RedDaxe.desktop");

        let launcher_path = install_dir.join(launcher_exe_name());
        let content = format!(
            "[Desktop Entry]\n\
             Type=Application\n\
             Name=RedDaxe.pl\n\
             Comment=RedDaxe.pl Tibia Launcher\n\
             Exec={}\n\
             Path={}\n\
             Icon={}\n\
             Terminal=false\n\
             Categories=Game;\n\
             StartupWMClass=RedDaxe\n",
            launcher_path.display(),
            install_dir.display(),
            install_dir.join("icon.png").display(),
        );

        if let Some(parent) = desktop_entry_path.parent() {
            let _ = std::fs::create_dir_all(parent);
        }
        let _ = std::fs::write(&desktop_entry_path, content);
    }
}

/// Remove all shortcuts created during installation.
pub fn remove_shortcuts() {
    #[cfg(target_os = "windows")]
    {
        if let Some(desktop) = desktop_path() {
            let _ = std::fs::remove_file(desktop.join("RedDaxe.lnk"));
        }
        if let Some(sm_dir) = start_menu_path() {
            let _ = std::fs::remove_file(sm_dir.join("RedDaxe.lnk"));
        }
    }

    #[cfg(target_os = "linux")]
    {
        if let Ok(home) = std::env::var("HOME") {
            let desktop_entry = PathBuf::from(&home)
                .join(".local")
                .join("share")
                .join("applications")
                .join("RedDaxe.desktop");
            let _ = std::fs::remove_file(desktop_entry);
        }
    }
}
