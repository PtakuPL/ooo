/**
 * SerwerCanary Launcher — Frontend Application
 *
 * LR-033..040: Ekrany statusu, aktualizacji, startu gry,
 * błędów, naprawy, ustawień, eksportu logów, retry.
 *
 * Komunikacja z Rust backendem wyłącznie przez `window.__TAURI__.core.invoke()`.
 * Frontend NIE zawiera logiki bezpieczeństwa — tylko widok + input.
 */

// ─────────────────────────────────────────────
// Tauri API bridge
// ─────────────────────────────────────────────

const invoke = window.__TAURI__
  ? window.__TAURI__.core.invoke
  : async (cmd, args) => {
      console.warn(`[mock] invoke("${cmd}",`, args, ")");
      // Fallback dla developmentu bez Tauri
      if (cmd === "get_status")
        return {
          phase: "ready",
          launcherVersion: "0.1.0-dev",
          channel: "stable",
          clientVersion: "1.0.0",
          clientUpToDate: true,
          error: null,
          launcherUpdate: null,
        };
      if (cmd === "check_for_updates")
        return {
          upToDate: true,
          targetVersion: "1.0.0",
          filesToDownload: 0,
          filesToDelete: 0,
          filesUnchanged: 10,
          downloadBytes: 0,
        };
      throw new Error("Mock: not implemented");
    };

// ─────────────────────────────────────────────
// DOM References
// ─────────────────────────────────────────────

const $ = (sel) => document.querySelector(sel);
const screens = document.querySelectorAll(".screen");
const navBtns = document.querySelectorAll(".nav-btn[data-screen]");

// Status screen
const elVersionBadge = $("#version-badge");
const elLauncherVer = $("#status-launcher-ver");
const elClientVer = $("#status-client-ver");
const elChannel = $("#status-channel");
const elPhase = $("#status-phase");
const btnPlay = $("#btn-play");
const btnCheck = $("#btn-check");

// Update screen
const elProgressBar = $("#progress-bar");
const elProgressStage = $("#progress-stage");
const elProgressPercent = $("#progress-percent");
const elProgressFile = $("#progress-file");
const elProgressFilesCount = $("#progress-files-count");

// Error screen
const elErrorMessage = $("#error-message");
const elErrorCode = $("#error-code");
const btnRetry = $("#btn-retry");
const btnBack = $("#btn-back");

// Repair screen
const elRepairOk = $("#repair-ok");
const elRepairCorrupted = $("#repair-corrupted");
const elRepairMissing = $("#repair-missing");
const elRepairBytes = $("#repair-bytes");
const btnRepairStart = $("#btn-repair-start");
const btnRepairBack = $("#btn-repair-back");

// Settings
const elSettingChannel = $("#setting-channel");
const btnSaveSettings = $("#btn-save-settings");
const btnSettingsBack = $("#btn-settings-back");

// Nav
const btnExportLogs = $("#btn-export-logs");

// ─────────────────────────────────────────────
// Navigation
// ─────────────────────────────────────────────

function showScreen(name) {
  screens.forEach((s) => s.classList.remove("active"));
  const target = $(`#screen-${name}`);
  if (target) target.classList.add("active");

  navBtns.forEach((b) => {
    b.classList.toggle("active", b.dataset.screen === name);
  });
}

navBtns.forEach((btn) => {
  btn.addEventListener("click", () => {
    const screen = btn.dataset.screen;
    showScreen(screen);
    if (screen === "repair") loadRepairDiagnostics();
  });
});

// ─────────────────────────────────────────────
// Status screen (LR-033)
// ─────────────────────────────────────────────

const PHASE_LABELS = {
  checking: "sprawdzanie…",
  updating: "aktualizacja…",
  ready: "✅ gotowy",
  repairing: "naprawa…",
  error: "⚠ błąd",
  launcher_update_required: "⬆ aktualizacja launchera",
};

async function loadStatus() {
  try {
    const status = await invoke("get_status");

    elVersionBadge.textContent = `v${status.launcherVersion}`;
    elLauncherVer.textContent = status.launcherVersion;
    elClientVer.textContent = status.clientVersion || "---";
    elChannel.textContent = status.channel;
    elPhase.textContent = PHASE_LABELS[status.phase] || status.phase;

    // Kolory badge
    elPhase.className = "badge badge-phase";
    if (status.phase === "ready") elPhase.classList.add("badge-ok");
    else if (status.phase === "error") elPhase.classList.add("badge-error");

    // Przycisk graj
    btnPlay.disabled = status.phase !== "ready";

    // Jeśli błąd — pokaż ekran błędu
    if (status.phase === "error" && status.error) {
      showError(status.error.userMessage, status.error.code, status.error.retryable);
    }

    // Jeśli wymagana aktualizacja launchera
    if (status.phase === "launcher_update_required" && status.launcherUpdate) {
      showError(
        `Wymagana aktualizacja launchera do v${status.launcherUpdate.newVersion}`,
        "LCH_LAUNCHER_UPDATE_REQUIRED",
        false
      );
    }
  } catch (err) {
    console.error("loadStatus error:", err);
  }
}

// ─────────────────────────────────────────────
// Check for updates (LR-034)
// ─────────────────────────────────────────────

btnCheck.addEventListener("click", async () => {
  btnCheck.disabled = true;
  btnCheck.textContent = "🔄 Sprawdzam…";

  try {
    const plan = await invoke("check_for_updates");

    if (plan.upToDate) {
      elPhase.textContent = "✅ aktualny";
      elPhase.className = "badge badge-phase badge-ok";
      btnPlay.disabled = false;
    } else {
      // Pokaż ekran aktualizacji i uruchom update
      showScreen("update");
      startUpdate(plan);
    }
  } catch (err) {
    showError(String(err), "CHECK_ERROR", true);
  } finally {
    btnCheck.disabled = false;
    btnCheck.textContent = "🔄 Sprawdź aktualizacje";
  }
});

// ─────────────────────────────────────────────
// Update flow (LR-034)
// ─────────────────────────────────────────────

async function startUpdate(plan) {
  updateProgress({
    stage: "downloading",
    currentFile: null,
    filesDone: 0,
    filesTotal: plan.filesToDownload,
    bytesDone: 0,
    bytesTotal: plan.downloadBytes,
    percent: 0,
    etaSeconds: null,
  });

  try {
    const result = await invoke("start_update");
    updateProgress(result);

    if (result.stage === "done") {
      // Wróć do statusu
      setTimeout(() => {
        showScreen("status");
        loadStatus();
      }, 1500);
    }
  } catch (err) {
    showError(String(err), "UPDATE_ERROR", true);
  }
}

function updateProgress(dto) {
  const stageLabels = {
    checking_manifest: "Sprawdzanie manifestu…",
    scanning_files: "Skanowanie plików…",
    downloading: "Pobieranie…",
    verifying: "Weryfikacja…",
    applying: "Aplikowanie zmian…",
    finalizing: "Finalizacja…",
    done: "✅ Zakończono!",
  };

  elProgressStage.textContent = stageLabels[dto.stage] || dto.stage;
  elProgressPercent.textContent = `${dto.percent}%`;
  elProgressBar.style.width = `${dto.percent}%`;
  elProgressFile.textContent = dto.currentFile || "---";
  elProgressFilesCount.textContent = `${dto.filesDone} / ${dto.filesTotal} plików`;
}

// ─────────────────────────────────────────────
// Launch game (LR-035)
// ─────────────────────────────────────────────

btnPlay.addEventListener("click", async () => {
  btnPlay.disabled = true;
  btnPlay.textContent = "⏳ Uruchamianie…";

  try {
    await invoke("launch_game");
    btnPlay.textContent = "✅ Uruchomiono";
    setTimeout(() => {
      btnPlay.textContent = "▶ Uruchom grę";
      btnPlay.disabled = false;
    }, 3000);
  } catch (err) {
    showError(String(err), "LAUNCH_ERROR", true);
    btnPlay.textContent = "▶ Uruchom grę";
    btnPlay.disabled = false;
  }
});

// ─────────────────────────────────────────────
// Error screen (LR-036)
// ─────────────────────────────────────────────

function showError(message, code, retryable) {
  showScreen("error");
  elErrorMessage.textContent = message;
  elErrorCode.textContent = code || "";
  btnRetry.style.display = retryable ? "inline-block" : "none";
}

// LR-040: retry po błędzie
btnRetry.addEventListener("click", () => {
  showScreen("status");
  loadStatus();
  // Automatycznie sprawdź aktualizacje po retry
  setTimeout(() => btnCheck.click(), 500);
});

btnBack.addEventListener("click", () => {
  showScreen("status");
  loadStatus();
});

// ─────────────────────────────────────────────
// Repair screen (LR-036)
// ─────────────────────────────────────────────

async function loadRepairDiagnostics() {
  elRepairOk.textContent = "…";
  elRepairCorrupted.textContent = "…";
  elRepairMissing.textContent = "…";
  elRepairBytes.textContent = "…";

  try {
    const diag = await invoke("repair_installation");
    elRepairOk.textContent = diag.okCount;
    elRepairCorrupted.textContent = diag.corruptedCount;
    elRepairMissing.textContent = diag.missingCount;
    elRepairBytes.textContent = formatBytes(diag.repairDownloadBytes);
  } catch (err) {
    showError(String(err), "REPAIR_ERROR", true);
  }
}

btnRepairStart.addEventListener("click", async () => {
  btnRepairStart.disabled = true;
  btnRepairStart.textContent = "🔧 Naprawiam…";
  try {
    // Naprawa = pełna aktualizacja
    showScreen("update");
    const result = await invoke("start_update");
    updateProgress(result);
    if (result.stage === "done") {
      setTimeout(() => {
        showScreen("status");
        loadStatus();
      }, 1500);
    }
  } catch (err) {
    showError(String(err), "REPAIR_ERROR", true);
  } finally {
    btnRepairStart.disabled = false;
    btnRepairStart.textContent = "🔧 Napraw";
  }
});

btnRepairBack.addEventListener("click", () => {
  showScreen("status");
});

// ─────────────────────────────────────────────
// Settings (LR-038)
// ─────────────────────────────────────────────

btnSaveSettings.addEventListener("click", async () => {
  const channel = elSettingChannel.value;
  try {
    const result = await invoke("change_channel", { channel });
    console.log(result);
    showScreen("status");
    loadStatus();
  } catch (err) {
    showError(String(err), "SETTINGS_ERROR", false);
  }
});

btnSettingsBack.addEventListener("click", () => {
  showScreen("status");
});

// ─────────────────────────────────────────────
// Export logs (LR-037)
// ─────────────────────────────────────────────

btnExportLogs.addEventListener("click", async () => {
  try {
    const path = await invoke("export_logs");
    alert(`Logi wyeksportowane do:\n${path}`);
  } catch (err) {
    alert(`Błąd eksportu logów: ${err}`);
  }
});

// ─────────────────────────────────────────────
// Utilities
// ─────────────────────────────────────────────

function formatBytes(bytes) {
  if (bytes === 0) return "0 B";
  const units = ["B", "KB", "MB", "GB"];
  const i = Math.min(Math.floor(Math.log(bytes) / Math.log(1024)), units.length - 1);
  const val = (bytes / Math.pow(1024, i)).toFixed(i === 0 ? 0 : 1);
  return `${val} ${units[i]}`;
}

// ─────────────────────────────────────────────
// Init
// ─────────────────────────────────────────────

document.addEventListener("DOMContentLoaded", () => {
  showScreen("status");
  loadStatus();
});
