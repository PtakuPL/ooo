#!/usr/bin/env python3
"""
E6-E8: Launcher z auto-update + GUI (tkinter).

Faza E planu zabezpieczenia klienta i serwera.
Launcher:
  1. Sprawdza wersję launchera (self-update)
  2. Pobiera manifest plików klienta
  3. Porównuje lokalne pliki z manifestem, pobiera brakujące/zmienione
  4. Pobiera jednorazowy launch-token z API
  5. Uruchamia klienta z tokenem (env variable)

Technologia: Python 3.10+ / tkinter / requests
Build: PyInstaller → launcher.exe
"""

import hashlib
import json
import logging
import os
import platform
import shutil
import subprocess
import sys
import threading
import time
from pathlib import Path
from typing import Optional

# --- Dependencies ---
try:
    import requests
except ImportError:
    print("BŁĄD: Brak modułu 'requests'. Zainstaluj: pip install requests")
    sys.exit(1)

try:
    import tkinter as tk
    from tkinter import ttk, messagebox
except ImportError:
    print("BŁĄD: Brak modułu 'tkinter'. Na Linux: sudo apt install python3-tk")
    sys.exit(1)

# --- Logging ---
LOG_FILE = "launcher.log"
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler(LOG_FILE, encoding="utf-8"),
        logging.StreamHandler(sys.stdout),
    ],
)
log = logging.getLogger("launcher")

# --- Config ---
CONFIG_FILE = "launcher_config.json"


def load_config() -> dict:
    """Wczytaj konfigurację launchera."""
    config_path = Path(sys.argv[0]).parent / CONFIG_FILE
    if not config_path.exists():
        # Fallback: szukaj w CWD
        config_path = Path(CONFIG_FILE)
    if not config_path.exists():
        log.error(f"Brak pliku konfiguracji: {CONFIG_FILE}")
        messagebox.showerror("Błąd", f"Brak pliku konfiguracji: {CONFIG_FILE}")
        sys.exit(1)
    with open(config_path, "r", encoding="utf-8") as f:
        return json.load(f)


# --- Utility functions ---

def sha256_file(path: Path) -> str:
    """Oblicz SHA-256 pliku."""
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def validate_manifest_path(path: str, client_dir: Path) -> Optional[str]:
    """Walidacja ścieżki z manifestu — ochrona przed path traversal."""
    if "\x00" in path:
        return None
    normalized = os.path.normpath(path)
    if os.path.isabs(normalized):
        return None
    if normalized.startswith(".."):
        return None
    resolved = (client_dir / normalized).resolve()
    if not str(resolved).startswith(str(client_dir.resolve())):
        return None
    return normalized


def get_files_hash(manifest: dict, client_dir: Path) -> str:
    """Hash z FAKTYCZNYCH lokalnych plików (nie z manifestu)."""
    hashes = []
    for file_info in sorted(manifest["files"], key=lambda x: x["path"]):
        safe_path = validate_manifest_path(file_info["path"], client_dir)
        if safe_path is None:
            hashes.append("INVALID")
            continue
        local_path = client_dir / safe_path
        if local_path.exists():
            hashes.append(sha256_file(local_path))
        else:
            hashes.append("MISSING")
    combined = "".join(hashes)
    return hashlib.sha256(combined.encode()).hexdigest()


# --- API client ---

class LauncherAPI:
    """Klient API dla launchera."""

    def __init__(self, config: dict):
        self.api_base = config["apiBaseUrl"].rstrip("/")
        self.files_base = config["filesBaseUrl"].rstrip("/")
        self.channel = config.get("updateChannel", "stable")
        self.launcher_version = config.get("launcherVersion", "1.0.0")
        self.session = requests.Session()
        self.session.headers["User-Agent"] = f"GameLauncher/{self.launcher_version}"
        # TLS hard-fail — NIGDY nie wyłączamy weryfikacji
        self.session.verify = True

    def check_launcher_version(self) -> dict:
        """E9: Sprawdź wersję launchera."""
        url = f"{self.api_base}/launcher-version.php?v={self.launcher_version}"
        resp = self.session.get(url, timeout=10)
        resp.raise_for_status()
        return resp.json()

    def get_manifest(self) -> dict:
        """E2: Pobierz manifest plików."""
        url = f"{self.api_base}/update.php?channel={self.channel}"
        resp = self.session.get(url, timeout=30)
        resp.raise_for_status()
        return resp.json()

    def get_launch_token(self, files_hash: str, manifest_version: str) -> dict:
        """E3: Pobierz jednorazowy launch-token."""
        url = f"{self.api_base}/launcher-token.php"
        payload = {
            "launcherVersion": self.launcher_version,
            "filesHash": files_hash,
            "clientVersion": manifest_version,
            "manifestVersion": manifest_version,
        }
        resp = self.session.post(url, json=payload, timeout=10)
        resp.raise_for_status()
        data = resp.json()
        # FIX51: sendError zwraca {"errorCode":3, "errorMessage":"..."}, nie pole "error"
        if "errorCode" in data:
            raise RuntimeError(data.get("errorMessage", data.get("error", "Unknown API error")))
        return data

    def download_file(self, file_url: str, dest_path: Path, expected_sha256: str,
                      progress_callback=None, max_retries: int = 3) -> bool:
        """Pobierz plik i zweryfikuj hash."""
        download_url = f"{self.files_base}{file_url}"
        dest_path.parent.mkdir(parents=True, exist_ok=True)

        for attempt in range(max_retries):
            try:
                resp = self.session.get(download_url, stream=True, timeout=120)
                resp.raise_for_status()
                total = int(resp.headers.get("content-length", 0))
                downloaded = 0

                with open(dest_path, "wb") as f:
                    for chunk in resp.iter_content(8192):
                        f.write(chunk)
                        downloaded += len(chunk)
                        if progress_callback and total > 0:
                            progress_callback(downloaded, total)

                if sha256_file(dest_path) == expected_sha256:
                    return True
                log.warning(f"Hash mismatch for {file_url} (attempt {attempt + 1})")
            except Exception as e:
                log.warning(f"Download error for {file_url}: {e} (attempt {attempt + 1})")

        return False


# --- Update logic ---

class UpdateManager:
    """Zarządza sprawdzaniem i pobieraniem aktualizacji."""

    def __init__(self, config: dict, api: LauncherAPI):
        self.config = config
        self.api = api
        self.client_dir = Path(config.get("clientDir", "./client")).resolve()
        self.cache_dir = Path("cache/downloads").resolve()

    def check_and_update(self, manifest: dict, status_callback=None, progress_callback=None) -> tuple:
        """
        Porównaj lokalne pliki z manifestem, pobierz brakujące/zmienione.
        Zwraca (downloaded_count, deleted_count, errors).
        """
        manifest_paths = {f["path"] for f in manifest["files"]}
        to_download = []

        # 1. Sprawdź pliki z manifestu
        for file_info in manifest["files"]:
            safe_path = validate_manifest_path(file_info["path"], self.client_dir)
            if safe_path is None:
                log.error(f"Niebezpieczna ścieżka w manifeście: {file_info['path']}")
                continue

            local_path = self.client_dir / safe_path
            if not local_path.exists():
                to_download.append(file_info)
            elif sha256_file(local_path) != file_info["sha256"]:
                to_download.append(file_info)

        errors = []

        if to_download:
            # KROK 1: Pobierz do temp
            self.cache_dir.mkdir(parents=True, exist_ok=True)

            for i, file_info in enumerate(to_download):
                safe_path = validate_manifest_path(file_info["path"], self.client_dir)
                if safe_path is None:
                    continue

                if status_callback:
                    status_callback(f"Pobieranie {i + 1}/{len(to_download)}: {file_info['path']}")
                if progress_callback:
                    progress_callback(i, len(to_download))

                temp_path = self.cache_dir / safe_path
                ok = self.api.download_file(
                    file_info["url"], temp_path, file_info["sha256"]
                )
                if not ok:
                    errors.append(file_info["path"])
                    log.error(f"Nie udało się pobrać: {file_info['path']}")

            # KROK 2: Atomic rename temp → docelowy
            if status_callback:
                status_callback("Instalowanie plików...")

            for file_info in to_download:
                safe_path = validate_manifest_path(file_info["path"], self.client_dir)
                if safe_path is None:
                    continue
                temp_path = self.cache_dir / safe_path
                final_path = self.client_dir / safe_path
                if temp_path.exists():
                    final_path.parent.mkdir(parents=True, exist_ok=True)
                    os.replace(str(temp_path), str(final_path))

        # KROK 3: Usuń nadmiarowe pliki (FIX60: z ochroną plików użytkownika)
        # Pliki pasujące do tych wzorców NIE będą usuwane nawet jeśli nie ma ich w manifeście
        PROTECTED_PATTERNS = [
            '*.log', '*.cfg', '*.otml', 'cacert.pem',
            'cache/**', 'logs/**', 'data/things/**',
        ]
        import fnmatch

        def is_protected(rel: str) -> bool:
            for pat in PROTECTED_PATTERNS:
                if fnmatch.fnmatch(rel, pat):
                    return True
            return False

        to_delete = []
        if self.client_dir.exists():
            for local_file in self.client_dir.rglob("*"):
                if local_file.is_file():
                    rel_path = str(local_file.relative_to(self.client_dir)).replace("\\", "/")
                    if rel_path not in manifest_paths and not is_protected(rel_path):
                        to_delete.append(local_file)

        for old_file in to_delete:
            try:
                old_file.unlink()
            except OSError as e:
                log.warning(f"Nie udało się usunąć: {old_file}: {e}")

        # Cleanup temp
        if self.cache_dir.exists():
            shutil.rmtree(self.cache_dir, ignore_errors=True)

        return len(to_download), len(to_delete), errors


# --- GUI ---

class LauncherGUI:
    """Główne okno launchera z tkinter."""

    def __init__(self, config: dict):
        self.config = config
        self.api = LauncherAPI(config)
        self.update_mgr = UpdateManager(config, self.api)

        self.root = tk.Tk()
        self.root.title(config.get("windowTitle", "Game Launcher"))
        self.root.geometry("500x400")
        self.root.resizable(False, False)

        # Ciemny motyw
        bg_color = "#1a1a2e"
        fg_color = "#eaeaea"
        accent = "#e94560"
        self.root.configure(bg=bg_color)

        style = ttk.Style()
        style.theme_use("clam")
        style.configure("TLabel", background=bg_color, foreground=fg_color, font=("Segoe UI", 10))
        style.configure("Title.TLabel", background=bg_color, foreground=fg_color, font=("Segoe UI", 18, "bold"))
        style.configure("Status.TLabel", background=bg_color, foreground="#aaa", font=("Segoe UI", 9))
        style.configure("Accent.TButton", background=accent, foreground="white", font=("Segoe UI", 12, "bold"),
                         padding=(20, 10))
        style.map("Accent.TButton",
                   background=[("active", "#c0392b"), ("disabled", "#555")])
        style.configure("TProgressbar", troughcolor="#16213e", background=accent, thickness=20)

        # --- Layout ---
        main_frame = tk.Frame(self.root, bg=bg_color, padx=20, pady=20)
        main_frame.pack(fill=tk.BOTH, expand=True)

        # Title
        self.title_label = ttk.Label(main_frame, text=config.get("serverName", "Game Server"),
                                     style="Title.TLabel")
        self.title_label.pack(pady=(10, 5))

        # Version info
        self.version_label = ttk.Label(main_frame,
                                       text=f"Launcher v{config.get('launcherVersion', '?')}",
                                       style="Status.TLabel")
        self.version_label.pack()

        # Separator
        ttk.Separator(main_frame, orient="horizontal").pack(fill=tk.X, pady=15)

        # Status
        self.status_label = ttk.Label(main_frame, text="Gotowy do uruchomienia", style="TLabel")
        self.status_label.pack(pady=(0, 5))

        # Progress bar
        self.progress = ttk.Progressbar(main_frame, mode="determinate", length=400, style="TProgressbar")
        self.progress.pack(pady=(0, 5))
        self.progress["value"] = 0

        # Detail status
        self.detail_label = ttk.Label(main_frame, text="", style="Status.TLabel")
        self.detail_label.pack()

        # Spacer
        tk.Frame(main_frame, bg=bg_color, height=20).pack()

        # Play button
        self.play_button = ttk.Button(main_frame, text="GRAJ", style="Accent.TButton",
                                      command=self.on_play_click)
        self.play_button.pack(pady=10)

        # Footer
        self.footer_label = ttk.Label(main_frame, text="", style="Status.TLabel")
        self.footer_label.pack(side=tk.BOTTOM, pady=(10, 0))

        self._running = False

    def set_status(self, text: str):
        """Update status label (thread-safe)."""
        self.root.after(0, lambda: self.status_label.configure(text=text))

    def set_detail(self, text: str):
        """Update detail label (thread-safe)."""
        self.root.after(0, lambda: self.detail_label.configure(text=text))

    def set_progress(self, value: float):
        """Update progress bar (thread-safe). Value 0.0 - 100.0."""
        self.root.after(0, lambda: self.progress.configure(value=min(100, max(0, value))))

    def set_footer(self, text: str):
        """Update footer text."""
        self.root.after(0, lambda: self.footer_label.configure(text=text))

    def enable_play(self, enabled: bool = True):
        """Enable/disable play button."""
        state = "normal" if enabled else "disabled"
        self.root.after(0, lambda: self.play_button.configure(state=state))

    def on_play_click(self):
        """Kliknięcie 'GRAJ' — uruchom flow w osobnym wątku."""
        if self._running:
            return
        self._running = True
        self.enable_play(False)
        thread = threading.Thread(target=self._launch_flow, daemon=True)
        thread.start()

    def _launch_flow(self):
        """Główny flow launchera (w wątku)."""
        try:
            # 1. Sprawdź wersję launchera
            self.set_status("Sprawdzanie wersji launchera...")
            self.set_progress(5)
            try:
                ver_info = self.api.check_launcher_version()
                if ver_info.get("required"):
                    self.set_status("WYMAGANA aktualizacja launchera!")
                    self.set_detail(f"Nowa wersja: {ver_info.get('version', '?')}")
                    messagebox.showwarning(
                        "Aktualizacja wymagana",
                        f"Dostępna jest nowa wersja launchera ({ver_info.get('version', '?')}).\n"
                        f"Pobierz nową wersję ze strony serwera."
                    )
                    self._running = False
                    self.enable_play(True)
                    return
            except Exception as e:
                log.warning(f"Nie udało się sprawdzić wersji launchera: {e}")
                self.set_detail("Nie można sprawdzić wersji — kontynuuję...")

            # 2. Pobierz manifest
            self.set_status("Pobieranie listy plików...")
            self.set_progress(10)
            try:
                manifest = self.api.get_manifest()
            except Exception as e:
                log.error(f"Nie udało się pobrać manifestu: {e}")
                self.set_status("BŁĄD: Nie można pobrać listy plików")
                self.set_detail(str(e))
                messagebox.showerror("Błąd", f"Nie można pobrać listy plików:\n{e}")
                self._running = False
                self.enable_play(True)
                return

            client_version = manifest.get("version", "?")
            file_count = manifest.get("fileCount", len(manifest.get("files", [])))
            self.set_detail(f"Wersja klienta: {client_version} ({file_count} plików)")

            # 3. Sprawdź i zaktualizuj pliki
            self.set_status("Sprawdzanie plików klienta...")
            self.set_progress(15)

            def status_cb(msg):
                self.set_status(msg)

            def progress_cb(current, total):
                pct = 15 + (current / max(total, 1)) * 60
                self.set_progress(pct)

            downloaded, deleted, errors = self.update_mgr.check_and_update(
                manifest, status_callback=status_cb, progress_callback=progress_cb
            )

            if errors:
                self.set_status(f"BŁĄD: {len(errors)} plików nie pobranych")
                self.set_detail(", ".join(errors[:3]) + ("..." if len(errors) > 3 else ""))
                messagebox.showerror(
                    "Błąd aktualizacji",
                    f"Nie udało się pobrać {len(errors)} plików.\nSpróbuj ponownie."
                )
                self._running = False
                self.enable_play(True)
                return

            if downloaded > 0 or deleted > 0:
                self.set_detail(f"Zaktualizowano {downloaded} plików, usunięto {deleted} starych")
            else:
                self.set_detail("Klient aktualny — nie trzeba pobierać plików")

            self.set_progress(80)

            # 4. Oblicz filesHash i pobierz launch-token
            self.set_status("Przygotowanie do uruchomienia...")
            files_hash = get_files_hash(manifest, self.update_mgr.client_dir)
            log.info(f"Files hash: {files_hash}")

            try:
                token_data = self.api.get_launch_token(files_hash, client_version)
                launch_token = token_data["launchToken"]
                log.info(f"Launch token received, TTL={token_data.get('expiresIn', '?')}s")
            except Exception as e:
                log.error(f"Nie udało się pobrać launch-tokena: {e}")
                self.set_status("BŁĄD: Nie można uzyskać tokena startowego")
                self.set_detail(str(e))
                messagebox.showerror("Błąd", f"Nie można uzyskać tokena startowego:\n{e}")
                self._running = False
                self.enable_play(True)
                return

            self.set_progress(90)

            # 5. Uruchom klienta
            self.set_status("Uruchamianie gry...")
            self._launch_client(launch_token)

            self.set_progress(100)
            self.set_status("Gra uruchomiona!")
            self.set_detail("Możesz zamknąć launcher")
            self.set_footer(f"Sesja: {launch_token[:8]}...")

            # Opcjonalnie: zamknij launcher po 5s
            # time.sleep(5)
            # self.root.after(0, self.root.quit)

        except Exception as e:
            log.exception("Nieoczekiwany błąd w launch flow")
            self.set_status("BŁĄD")
            self.set_detail(str(e))
            messagebox.showerror("Błąd", f"Nieoczekiwany błąd:\n{e}")
        finally:
            self._running = False
            self.enable_play(True)

    def _launch_client(self, token: str):
        """Uruchom klienta z tokenem przez env variable."""
        client_dir = self.update_mgr.client_dir

        # Wybierz exe w zależności od systemu
        if platform.system() == "Windows":
            exe_name = self.config.get("clientExe", "otclient.exe")
        else:
            exe_name = self.config.get("clientExeLinux", "./otclient")

        exe_path = client_dir / exe_name

        if not exe_path.exists():
            raise FileNotFoundError(f"Nie znaleziono klienta: {exe_path}")

        # WAŻNE: Token przez env, NIE przez CLI argument!
        env = os.environ.copy()
        env["OTC_LAUNCH_TOKEN"] = token

        log.info(f"Uruchamianie: {exe_path}")
        subprocess.Popen(
            [str(exe_path)],
            cwd=str(client_dir),
            env=env,
            start_new_session=True,  # odłącz od launchera
        )

    def run(self):
        """Start main loop."""
        self.root.mainloop()


# --- Main ---

def main():
    log.info("=== Launcher start ===")
    config = load_config()
    gui = LauncherGUI(config)
    gui.run()
    log.info("=== Launcher exit ===")


if __name__ == "__main__":
    main()
