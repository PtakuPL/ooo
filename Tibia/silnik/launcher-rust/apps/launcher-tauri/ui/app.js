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
    // Graceful: pokaż co mamy, nie crashuj
    elPhase.textContent = "brak po\u0142\u0105czenia";
    elPhase.className = "badge badge-phase badge-warn";
  }
}

// ─────────────────────────────────────────────
// Server list — toggle + status
// ─────────────────────────────────────────────

const serversToggle = $("#servers-toggle");
const serversList = $("#servers-list");
const serversArrow = $("#servers-arrow");

if (serversToggle) {
  serversToggle.addEventListener("click", () => {
    serversList.classList.toggle("collapsed");
    serversArrow.classList.toggle("collapsed");
  });
}

// Hardcoded servers (p\u00f3\u017aniej: fetch z API)
const SERVERS = [
  { id: "tibia-main", name: "SerwerCanary \u2014 Tibia 14.20+", host: null },
  { id: "tibia-retro", name: "SerwerCanary \u2014 Retro 7.4", host: null },
];

function updateServerStatus(serverId, status, players, ping) {
  const dot = document.querySelector(`.server-card[data-server="${serverId}"] .server-status-dot`);
  const badge = $(`#srv-${serverId}-status`);
  const playersEl = $(`#srv-${serverId}-players`);
  const pingEl = $(`#srv-${serverId}-ping`);

  if (dot) {
    dot.className = "server-status-dot";
    if (status === "online") dot.classList.add("dot-online");
    else if (status === "maintenance") dot.classList.add("dot-maintenance");
    else dot.classList.add("dot-offline");
  }
  if (badge) {
    badge.textContent = status;
    badge.className = "server-status-badge badge";
    if (status === "online") badge.classList.add("badge-ok");
    else if (status === "maintenance") badge.classList.add("badge-warn");
  }
  if (playersEl) playersEl.textContent = players != null ? players : "---";
  if (pingEl) pingEl.textContent = ping != null ? `${ping}ms` : "---";
}

// Placeholder: serwery offline (zostan\u0105 podmienione gdy API b\u0119dzie gotowe)
SERVERS.forEach(s => updateServerStatus(s.id, "offline", null, null));

// ─────────────────────────────────────────────
// Website button
// ─────────────────────────────────────────────

const btnWebsite = $("#btn-website");
if (btnWebsite) {
  btnWebsite.addEventListener("click", () => {
    // Tauri v2: open URL in default browser
    if (window.__TAURI__ && window.__TAURI__.shell) {
      window.__TAURI__.shell.open("https://serwercanary.pl");
    } else {
      window.open("https://serwercanary.pl", "_blank");
    }
  });
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
    // Graceful: nie crashuj na ekran b\u0142\u0119du, poka\u017c info w miejscu
    elRepairOk.textContent = "---";
    elRepairCorrupted.textContent = "---";
    elRepairMissing.textContent = "---";
    elRepairBytes.textContent = "Nie uda\u0142o si\u0119 po\u0142\u0105czy\u0107 z API";
    console.warn("Repair diagnostics failed:", err);
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
// Download Center (LR-044)
// ─────────────────────────────────────────────

const elDownloadsLoading = $("#downloads-loading");
const elDownloadsList = $("#downloads-list");
const elDownloadsError = $("#downloads-error");
const btnDownloadsRefresh = $("#btn-downloads-refresh");
const btnDownloadsBack = $("#btn-downloads-back");

async function loadDownloadCenter() {
  elDownloadsLoading.style.display = "block";
  elDownloadsList.style.display = "none";
  elDownloadsError.style.display = "none";

  try {
    const catalog = await invoke("get_installer_catalog");
    elDownloadsList.innerHTML = "";

    if (!catalog.artifacts || catalog.artifacts.length === 0) {
      elDownloadsError.textContent = "Brak dostępnych artefaktów.";
      elDownloadsError.style.display = "block";
      return;
    }

    catalog.artifacts.forEach((art) => {
      const card = document.createElement("div");
      card.className = "download-card";

      const platformClass = art.platform.toLowerCase();
      card.innerHTML = `
        <div class="download-info">
          <div class="filename">${escapeHtml(art.filename)}</div>
          <div class="meta">
            <span class="platform-badge ${platformClass}">${escapeHtml(art.platform)}</span>
            <span>${escapeHtml(art.arch)}</span> · 
            <span>${formatBytes(art.size)}</span> · 
            <span class="mono">${escapeHtml(art.sha256.substring(0, 12))}…</span>
          </div>
        </div>
        <button class="btn-download" data-url="${escapeHtml(art.url)}" data-filename="${escapeHtml(art.filename)}" data-sha256="${escapeHtml(art.sha256)}" data-size="${art.size}">
          ⬇ Pobierz
        </button>
      `;

      elDownloadsList.appendChild(card);
    });

    // Obsługa przycisków pobierania
    elDownloadsList.querySelectorAll(".btn-download").forEach((btn) => {
      btn.addEventListener("click", () => downloadArtifact(btn));
    });

    elDownloadsList.style.display = "flex";
  } catch (err) {
    const errorMsg = $("#downloads-error-msg");
    if (errorMsg) errorMsg.textContent = `Błąd pobierania katalogu: ${err}`;
    elDownloadsError.style.display = "block";
  } finally {
    elDownloadsLoading.style.display = "none";
  }
}

async function downloadArtifact(btn) {
  const url = btn.dataset.url;
  const filename = btn.dataset.filename;
  const sha256 = btn.dataset.sha256;
  const size = parseInt(btn.dataset.size, 10);

  btn.disabled = true;
  btn.textContent = "⏳ Pobieram…";

  try {
    const result = await invoke("download_and_verify_artifact", {
      url,
      filename,
      expectedSha256: sha256,
      expectedSize: size,
    });
    btn.textContent = "✅ Pobrano";
    if (result.savedTo) {
      alert(`Pobrano: ${result.savedTo}`);
    }
  } catch (err) {
    btn.textContent = "❌ Błąd";
    showError(`Pobieranie ${filename}: ${err}`, "DOWNLOAD_ERROR", true);
  } finally {
    setTimeout(() => {
      btn.disabled = false;
      btn.textContent = "⬇ Pobierz";
    }, 3000);
  }
}

function escapeHtml(str) {
  const div = document.createElement("div");
  div.textContent = str;
  return div.innerHTML;
}

if (btnDownloadsRefresh) {
  btnDownloadsRefresh.addEventListener("click", () => loadDownloadCenter());
}
if (btnDownloadsBack) {
  btnDownloadsBack.addEventListener("click", () => showScreen("status"));
}

// ─────────────────────────────────────────────
// Self-update UI (LR-048..050)
// ─────────────────────────────────────────────

const elSelfUpdateCurrent = $("#selfupdate-current");
const elSelfUpdateLatest = $("#selfupdate-latest");
const elSelfUpdateStatus = $("#selfupdate-status");
const elSelfUpdateNotes = $("#selfupdate-notes");
const btnSelfUpdateStart = $("#btn-selfupdate-start");
const btnSelfUpdateBack = $("#btn-selfupdate-back");

let selfUpdateInfo = null;

async function checkSelfUpdate() {
  try {
    const check = await invoke("check_launcher_update");
    selfUpdateInfo = check;

    if (check.updateAvailable || check.updateRequired) {
      if (elSelfUpdateCurrent) elSelfUpdateCurrent.textContent = check.currentVersion;
      if (elSelfUpdateLatest) elSelfUpdateLatest.textContent = check.latestVersion;
      if (elSelfUpdateStatus) {
        elSelfUpdateStatus.textContent = check.updateRequired
          ? "⚠ Wymagana aktualizacja"
          : "Dostępna aktualizacja";
        elSelfUpdateStatus.className = check.updateRequired
          ? "badge badge-phase badge-error"
          : "badge badge-phase badge-warn";
      }
      if (check.notes && elSelfUpdateNotes) {
        elSelfUpdateNotes.textContent = check.notes;
        elSelfUpdateNotes.style.display = "block";
      }

      // Jeśli update wymagany — automatycznie pokaż ekran
      if (check.updateRequired) {
        showScreen("self-update");
      }
    }
  } catch (err) {
    console.warn("Self-update check failed:", err);
  }
}

if (btnSelfUpdateStart) {
  btnSelfUpdateStart.addEventListener("click", async () => {
    if (!selfUpdateInfo) return;
    btnSelfUpdateStart.disabled = true;
    btnSelfUpdateStart.textContent = "⏳ Aktualizuję…";
    if (elSelfUpdateStatus) elSelfUpdateStatus.textContent = "Pobieranie…";

    try {
      await invoke("perform_self_update");
      if (elSelfUpdateStatus) elSelfUpdateStatus.textContent = "Restart…";
      // Launcher się zamknie + helper podmieni binarkę
    } catch (err) {
      showError(`Self-update: ${err}`, "SELF_UPDATE_ERROR", false);
      btnSelfUpdateStart.disabled = false;
      btnSelfUpdateStart.textContent = "⬇ Aktualizuj launcher";
    }
  });
}

if (btnSelfUpdateBack) {
  btnSelfUpdateBack.addEventListener("click", () => showScreen("status"));
}

// ─────────────────────────────────────────────
// Navigation — update for new screens
// ─────────────────────────────────────────────

// Extend nav click handler for download center
navBtns.forEach((btn) => {
  // Remove old listeners (override)
  const clone = btn.cloneNode(true);
  btn.parentNode.replaceChild(clone, btn);
});

// Re-bind nav buttons (after clone)
document.querySelectorAll(".nav-btn[data-screen]").forEach((btn) => {
  btn.addEventListener("click", () => {
    const screen = btn.dataset.screen;
    showScreen(screen);
    if (screen === "repair") loadRepairDiagnostics();
    if (screen === "downloads") loadDownloadCenter();
  });
});

// ─────────────────────────────────────────────
// Init
// ─────────────────────────────────────────────

document.addEventListener("DOMContentLoaded", () => {
  showScreen("status");
  loadStatus();
  // Sprawdź self-update w tle
  checkSelfUpdate();
});
