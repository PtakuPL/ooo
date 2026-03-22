/// Minimal UI module for the bootstrap launcher.
///
/// Uses MessageBoxW (UTF-16) on Windows for correct Polish/international chars.
/// Console output uses UTF-8 code page.
use std::sync::atomic::{AtomicU8, Ordering};

use crate::i18n;

static LAST_PROGRESS: AtomicU8 = AtomicU8::new(0);

/// Set the Windows console to UTF-8 code page.  No-op on other platforms.
pub fn init_console_utf8() {
    #[cfg(target_os = "windows")]
    {
        #[link(name = "kernel32")]
        extern "system" {
            fn SetConsoleOutputCP(code_page: u32) -> i32;
            fn SetConsoleCP(code_page: u32) -> i32;
        }
        unsafe {
            SetConsoleOutputCP(65001); // CP_UTF8
            SetConsoleCP(65001);
        }
    }
}

/// Display a status message to the user.
pub fn set_status(msg: &str) {
    eprintln!("[bootstrap] {msg}");
}

/// Update the progress indicator (0–100).
/// Prints only when the percentage actually changes.
pub fn set_progress(pct: u8) {
    let pct = pct.min(100);
    let prev = LAST_PROGRESS.swap(pct, Ordering::Relaxed);
    if pct != prev {
        let label = i18n::t().progress_label;
        eprint!("\r[bootstrap] {label}: {pct:>3}%");
        if pct == 100 {
            eprintln!();
        }
    }
}

/// Show a fatal error to the user and wait for acknowledgement.
pub fn show_error(msg: &str) {
    let prefix = i18n::t().error_prefix;
    eprintln!("\n[bootstrap] {prefix}: {msg}");

    #[cfg(target_os = "windows")]
    {
        show_message_box_win(msg);
    }
}

#[cfg(target_os = "windows")]
fn show_message_box_win(msg: &str) {
    use std::ffi::OsStr;
    use std::os::windows::ffi::OsStrExt;

    #[link(name = "user32")]
    extern "system" {
        fn MessageBoxW(hwnd: *mut u8, text: *const u16, caption: *const u16, utype: u32) -> i32;
    }

    fn to_wide(s: &str) -> Vec<u16> {
        OsStr::new(s)
            .encode_wide()
            .chain(std::iter::once(0))
            .collect()
    }

    let title = i18n::t().bootstrap_title;
    let text_w = to_wide(msg);
    let caption_w = to_wide(title);

    unsafe {
        MessageBoxW(
            std::ptr::null_mut(),
            text_w.as_ptr(),
            caption_w.as_ptr(),
            0x10, // MB_ICONERROR
        );
    }
}

/// Reset progress counter (useful between stages).
pub fn reset_progress() {
    LAST_PROGRESS.store(0, Ordering::Relaxed);
}

/// Show a YES/NO confirmation dialog. Returns true if user clicked YES.
pub fn confirm_yes_no(title: &str, msg: &str) -> bool {
    #[cfg(target_os = "windows")]
    {
        return confirm_yes_no_win(title, msg);
    }
    #[cfg(not(target_os = "windows"))]
    {
        confirm_yes_no_console(title, msg)
    }
}

/// Show a YES/NO/CANCEL dialog.
/// Returns `Some(true)` = YES, `Some(false)` = NO, `None` = CANCEL.
pub fn confirm_yes_no_cancel(title: &str, msg: &str) -> Option<bool> {
    #[cfg(target_os = "windows")]
    {
        return confirm_yes_no_cancel_win(title, msg);
    }
    #[cfg(not(target_os = "windows"))]
    {
        confirm_yes_no_cancel_console(title, msg)
    }
}

/// Show an informational message box (OK button, info icon).
pub fn show_info(msg: &str) {
    eprintln!("[bootstrap] {msg}");

    #[cfg(target_os = "windows")]
    {
        show_info_box_win(msg);
    }
}

#[cfg(target_os = "windows")]
fn confirm_yes_no_win(title: &str, msg: &str) -> bool {
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

    let text_w = to_wide(msg);
    let caption_w = to_wide(title);

    let result = unsafe {
        MessageBoxW(
            std::ptr::null_mut(),
            text_w.as_ptr(),
            caption_w.as_ptr(),
            0x24, // MB_YESNO | MB_ICONQUESTION
        )
    };
    result == 6 // IDYES
}

#[cfg(target_os = "windows")]
fn confirm_yes_no_cancel_win(title: &str, msg: &str) -> Option<bool> {
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

    let text_w = to_wide(msg);
    let caption_w = to_wide(title);

    let result = unsafe {
        MessageBoxW(
            std::ptr::null_mut(),
            text_w.as_ptr(),
            caption_w.as_ptr(),
            0x23, // MB_YESNOCANCEL | MB_ICONQUESTION
        )
    };

    match result {
        6 => Some(true),  // IDYES
        7 => Some(false), // IDNO
        _ => None,        // IDCANCEL
    }
}

#[cfg(target_os = "windows")]
fn show_info_box_win(msg: &str) {
    use std::ffi::OsStr;
    use std::os::windows::ffi::OsStrExt;

    #[link(name = "user32")]
    extern "system" {
        fn MessageBoxW(hwnd: *mut u8, text: *const u16, caption: *const u16, utype: u32) -> i32;
    }

    fn to_wide(s: &str) -> Vec<u16> {
        OsStr::new(s)
            .encode_wide()
            .chain(std::iter::once(0))
            .collect()
    }

    let title = i18n::t().bootstrap_title;
    let text_w = to_wide(msg);
    let caption_w = to_wide(title);

    unsafe {
        MessageBoxW(
            std::ptr::null_mut(),
            text_w.as_ptr(),
            caption_w.as_ptr(),
            0x40, // MB_ICONINFORMATION
        );
    }
}

#[cfg(not(target_os = "windows"))]
fn confirm_yes_no_console(title: &str, msg: &str) -> bool {
    eprintln!("\n{title}");
    eprintln!("{msg}");
    eprint!("[y/N]: ");
    let mut input = String::new();
    if std::io::stdin().read_line(&mut input).is_ok() {
        return input.trim().eq_ignore_ascii_case("y");
    }
    false
}

#[cfg(not(target_os = "windows"))]
fn confirm_yes_no_cancel_console(title: &str, msg: &str) -> Option<bool> {
    eprintln!("\n{title}");
    eprintln!("{msg}");
    eprint!("[y/n/c]: ");
    let mut input = String::new();
    if std::io::stdin().read_line(&mut input).is_ok() {
        match input.trim().to_ascii_lowercase().as_str() {
            "y" | "yes" => return Some(true),
            "n" | "no" => return Some(false),
            _ => return None,
        }
    }
    None
}
