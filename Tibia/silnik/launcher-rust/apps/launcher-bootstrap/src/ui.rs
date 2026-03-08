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

    extern "system" {
        fn MessageBoxW(hwnd: *mut u8, text: *const u16, caption: *const u16, utype: u32) -> i32;
    }

    fn to_wide(s: &str) -> Vec<u16> {
        OsStr::new(s).encode_wide().chain(std::iter::once(0)).collect()
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
