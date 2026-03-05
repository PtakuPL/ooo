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
          language: "pl",
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
// Error Reporting (Faza 8)
// ─────────────────────────────────────────────

/**
 * Wysyła raport o błędzie do backendu (fire-and-forget).
 * Nigdy nie rzuca wyjątku — loguje tylko do konsoli.
 */
async function reportError(errorCode, message, context) {
  try {
    await invoke("report_error", {
      errorCode: String(errorCode).slice(0, 100),
      message: String(message).slice(0, 2000),
      context: context || null,
    });
  } catch (e) {
    console.warn("[reportError] failed to send:", e);
  }
}

// Global error handlers — catch unhandled errors and promise rejections
window.addEventListener("error", (event) => {
  const msg = event.message || "Unknown error";
  const ctx = {
    filename: event.filename || null,
    lineno: event.lineno || null,
    colno: event.colno || null,
  };
  console.error("[GlobalError]", msg, ctx);
  reportError("frontend.uncaught_error", msg, ctx);
});

window.addEventListener("unhandledrejection", (event) => {
  const reason = event.reason;
  const msg =
    reason instanceof Error ? reason.message : String(reason || "Unknown rejection");
  console.error("[UnhandledRejection]", msg, reason);
  reportError("frontend.unhandled_rejection", msg, {
    stack: reason instanceof Error ? (reason.stack || "").slice(0, 1000) : null,
  });
});

// ─────────────────────────────────────────────
// DOM References
// ─────────────────────────────────────────────

const $ = (sel) => document.querySelector(sel);
const screens = document.querySelectorAll(".screen");
const getNavButtons = () => document.querySelectorAll(".nav-btn[data-screen]");

// Status screen
const elVersionBadge = $("#version-badge");
const elLauncherVer = $("#status-launcher-ver");
const elClientVer = $("#status-client-ver");
const elChannel = $("#status-channel");
const elPhase = $("#status-phase");
const elServerNameMain = $("#server-name-main");
const elServerNameRetro = $("#server-name-retro");
const btnPlay = $("#btn-play");
const btnCheck = $("#btn-check");
const btnCreateCharClassic = $("#btn-create-char-classic");
const btnCreateCharModern = $("#btn-create-char-modern");

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
const elSettingLanguage = $("#setting-language");
const btnSaveSettings = $("#btn-save-settings");
const btnSettingsBack = $("#btn-settings-back");
const elLanguagePacksList = $("#language-packs-list");
const elLanguagePacksEmpty = $("#language-packs-empty");
const elLanguagePacksError = $("#language-packs-error");
const btnLanguagePacksRefresh = $("#btn-language-packs-refresh");

// Nav
const btnExportLogs = $("#btn-export-logs");

// ─────────────────────────────────────────────
// Frontend i18n (PL/EN, runtime switch)
// ─────────────────────────────────────────────

const LANGUAGE_STORAGE_KEY = "launcher.locale";
const DEFAULT_LOCALE = "pl";
const SUPPORTED_LOCALES = ["pl", "en", "ar", "he", "fa"];
const RTL_LOCALES = ["ar", "he", "fa"];
const LOCALE_DISPLAY_NAMES = {
  pl: "Polski",
  en: "English",
  ar: "Arabic",
  he: "Hebrew",
  fa: "Persian",
};
const I18N = Object.create(null);

async function loadLocaleDictionary(locale) {
  try {
    const response = await fetch(`./i18n/${locale}.json`, { cache: "no-store" });
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    return await response.json();
  } catch (err) {
    console.warn(`Failed to load i18n dictionary for "${locale}":`, err);
    return {};
  }
}

async function loadI18nDictionaries() {
  const loaded = await Promise.all(
    SUPPORTED_LOCALES.map(async (locale) => [locale, await loadLocaleDictionary(locale)])
  );

  loaded.forEach(([locale, dictionary]) => {
    I18N[locale] = dictionary;
  });
}

let currentLocale = DEFAULT_LOCALE;
let lastStatus = null;
let lastProgress = null;

function deepGet(obj, path) {
  return path.split(".").reduce((acc, key) => (acc && Object.prototype.hasOwnProperty.call(acc, key) ? acc[key] : undefined), obj);
}

function interpolate(text, params = []) {
  return params.reduce((acc, value, index) => acc.replaceAll(`{${index}}`, String(value)), text);
}

function t(path, params = []) {
  const fromCurrent = deepGet(I18N[currentLocale], path);
  const fromDefault = deepGet(I18N[DEFAULT_LOCALE], path);
  const fromEn = deepGet(I18N.en, path);
  const value = fromCurrent ?? fromDefault ?? fromEn ?? path;
  if (typeof value !== "string") return path;
  return interpolate(value, params);
}

function getPreferredLocale() {
  const stored = localStorage.getItem(LANGUAGE_STORAGE_KEY);
  const storedNormalized = normalizeLocale(stored);
  if (SUPPORTED_LOCALES.includes(storedNormalized)) return storedNormalized;

  const browser = normalizeLocale(navigator.language || DEFAULT_LOCALE);
  if (SUPPORTED_LOCALES.includes(browser)) return browser;
  return DEFAULT_LOCALE;
}

function getPhaseLabel(phase) {
  const translated = deepGet(I18N[currentLocale], `phase.${phase}`)
    ?? deepGet(I18N[DEFAULT_LOCALE], `phase.${phase}`)
    ?? deepGet(I18N.en, `phase.${phase}`);
  return typeof translated === "string" ? translated : phase;
}

function getProgressStageLabel(stage) {
  const translated = deepGet(I18N[currentLocale], `progress.stage.${stage}`)
    ?? deepGet(I18N[DEFAULT_LOCALE], `progress.stage.${stage}`)
    ?? deepGet(I18N.en, `progress.stage.${stage}`);
  return typeof translated === "string" ? translated : stage;
}

function getServerStatusLabel(status) {
  const translated = deepGet(I18N[currentLocale], `server.${status}`)
    ?? deepGet(I18N[DEFAULT_LOCALE], `server.${status}`)
    ?? deepGet(I18N.en, `server.${status}`);
  return typeof translated === "string" ? translated : status;
}

function resolveBackendErrorMessage(error) {
  if (!error || typeof error !== "object") return "";

  if (typeof error.userMessageKey === "string" && error.userMessageKey.length > 0) {
    const translated = t(error.userMessageKey);
    if (translated !== error.userMessageKey) {
      return translated;
    }
  }

  if (typeof error.userMessage === "string" && error.userMessage.length > 0) {
    return error.userMessage;
  }

  return "";
}

function resolveFrontendErrorMessage(code, fallbackMessage = "") {
  const i18nKey = `errors.frontend.${code}`;
  const translated = t(i18nKey);
  if (translated !== i18nKey) {
    return translated;
  }

  if (typeof fallbackMessage === "string" && fallbackMessage.length > 0) {
    return fallbackMessage;
  }

  return t("errors.frontend.UNKNOWN");
}

function showFrontendError(code, retryable, fallbackMessage = "") {
  showError(resolveFrontendErrorMessage(code, fallbackMessage), code, retryable);
}

function normalizeLocale(locale) {
  if (typeof locale !== "string") return "";
  return locale.toLowerCase().split(/[-_]/)[0];
}

function setText(selector, value) {
  const el = $(selector);
  if (el) el.textContent = value;
}

function applyServerMetaLabels() {
  ["tibia-main", "tibia-retro"].forEach((serverId) => {
    const playersEl = $(`#srv-${serverId}-players`);
    if (playersEl && playersEl.parentElement) {
      const playersValue = playersEl.textContent || "---";
      playersEl.parentElement.innerHTML = `${t("labels.players")}: <strong id="${playersEl.id}">${escapeHtml(playersValue)}</strong>`;
    }
    const pingEl = $(`#srv-${serverId}-ping`);
    if (pingEl && pingEl.parentElement) {
      const pingValue = pingEl.textContent || "---";
      pingEl.parentElement.innerHTML = `${t("labels.ping")}: <span id="${pingEl.id}">${escapeHtml(pingValue)}</span>`;
    }
  });
}

function applyStaticTranslations() {
  const isRtl = RTL_LOCALES.includes(currentLocale);
  document.title = t("app.title");
  document.documentElement.lang = currentLocale;
  document.documentElement.dir = isRtl ? "rtl" : "ltr";
  document.body.classList.toggle("rtl", isRtl);

  setText("#app-title", t("app.heading"));
  setText("#label-launcher", t("labels.launcher"));
  setText("#label-client", t("labels.client"));
  setText("#label-channel", t("labels.channel"));
  setText("#label-status", t("labels.status"));
  setText("#servers-title", t("labels.servers"));
  if (elServerNameMain) elServerNameMain.textContent = t("labels.serverMainName");
  if (elServerNameRetro) elServerNameRetro.textContent = t("labels.serverRetroName");
  setText("#update-title", t("screens.update"));
  setText("#error-title", t("screens.error"));
  setText("#repair-title", t("screens.repair"));
  setText("#settings-title", t("screens.settings"));
  setText("#downloads-title", t("screens.downloads"));
  setText("#selfupdate-title", t("screens.selfUpdate"));
  setText("#repair-label-ok", t("labels.repairOk"));
  setText("#repair-label-corrupted", t("labels.repairCorrupted"));
  setText("#repair-label-missing", t("labels.repairMissing"));
  setText("#repair-label-bytes", t("labels.repairBytes"));
  setText("#setting-channel-label", t("labels.settingChannel"));
  setText("#setting-language-label", t("labels.settingLanguage"));
  setText("#setting-install-path-label", t("labels.settingInstallPath"));
  setText("#language-packs-label", t("labels.languagePacks"));
  setText("#selfupdate-label-current", t("labels.currentVersion"));
  setText("#selfupdate-label-latest", t("labels.latestVersion"));
  setText("#selfupdate-label-status", t("labels.selfUpdateStatus"));
  setText("#downloads-loading", t("downloads.loading"));
  setText("#downloads-error-hint", t("downloads.apiHint"));
  setText("#btn-language-packs-refresh", t("buttons.refresh"));

  setText("#btn-play", t("buttons.play"));
  setText("#btn-check", t("buttons.checkUpdates"));
  setText("#btn-create-char-classic", t("buttons.createCharacterClassic"));
  setText("#btn-create-char-modern", t("buttons.createCharacterModern"));
  setText("#btn-website", t("buttons.website"));
  setText("#btn-retry", t("buttons.retry"));
  setText("#btn-back", t("buttons.back"));
  setText("#btn-repair-start", t("buttons.repair"));
  setText("#btn-repair-back", t("buttons.back"));
  setText("#btn-save-settings", t("buttons.save"));
  setText("#btn-settings-back", t("buttons.back"));
  setText("#btn-downloads-refresh", t("buttons.refresh"));
  setText("#btn-downloads-back", t("buttons.back"));
  setText("#btn-selfupdate-start", t("buttons.updateLauncher"));
  setText("#btn-selfupdate-back", t("buttons.back"));
  setText("#btn-nav-status", t("nav.status"));
  setText("#btn-nav-downloads", t("nav.downloads"));
  setText("#btn-nav-repair", t("nav.repair"));
  setText("#btn-nav-settings", t("nav.settings"));
  setText("#btn-export-logs", t("buttons.exportLogs"));

  if (elProgressStage && (!lastProgress || !lastProgress.stage)) {
    elProgressStage.textContent = t("progress.checking");
  }
  if (elProgressFilesCount && (!lastProgress || typeof lastProgress.filesDone === "undefined")) {
    elProgressFilesCount.textContent = t("progress.filesCount", [0, 0]);
  }
  if (elLanguagePacksEmpty && (!elLanguagePacksList || elLanguagePacksList.children.length === 0)) {
    elLanguagePacksEmpty.textContent = t("languagePacks.loading");
  }
  applyServerMetaLabels();
}

function populateLanguageSelector() {
  if (!elSettingLanguage) return;
  elSettingLanguage.innerHTML = "";
  SUPPORTED_LOCALES.forEach((locale) => {
    const option = document.createElement("option");
    option.value = locale;
    option.textContent = LOCALE_DISPLAY_NAMES[locale] || locale;
    elSettingLanguage.appendChild(option);
  });
}

function setLocale(locale, persist = true) {
  const normalized = normalizeLocale(locale);
  if (!SUPPORTED_LOCALES.includes(normalized)) return;
  currentLocale = normalized;
  if (persist) localStorage.setItem(LANGUAGE_STORAGE_KEY, normalized);
  if (elSettingLanguage) elSettingLanguage.value = normalized;
  applyStaticTranslations();
  if (lastStatus) renderStatus(lastStatus);
  if (lastProgress) updateProgress(lastProgress);
  if ($("#screen-settings")?.classList.contains("active")) {
    loadLanguagePacksPanel();
  }
}

// ─────────────────────────────────────────────
// Navigation
// ─────────────────────────────────────────────

function showScreen(name) {
  screens.forEach((s) => s.classList.remove("active"));
  const target = $(`#screen-${name}`);
  if (target) target.classList.add("active");

  getNavButtons().forEach((b) => {
    b.classList.toggle("active", b.dataset.screen === name);
  });
}

getNavButtons().forEach((btn) => {
  btn.addEventListener("click", () => {
    const screen = btn.dataset.screen;
    showScreen(screen);
    if (screen === "repair") loadRepairDiagnostics();
  });
});

// ─────────────────────────────────────────────
// Status screen (LR-033)
// ─────────────────────────────────────────────

function renderStatus(status) {
  elVersionBadge.textContent = `v${status.launcherVersion}`;
  elLauncherVer.textContent = status.launcherVersion;
  elClientVer.textContent = status.clientVersion || "---";
  elChannel.textContent = status.channel;
  elPhase.textContent = getPhaseLabel(status.phase);

  elPhase.className = "badge badge-phase";
  if (status.phase === "ready") elPhase.classList.add("badge-ok");
  else if (status.phase === "error") elPhase.classList.add("badge-error");

  btnPlay.disabled = status.phase !== "ready";
  if (!btnPlay.disabled) {
    btnPlay.textContent = t("buttons.play");
  }
}

async function loadStatus() {
  try {
    const status = await invoke("get_status");

    if (
      typeof status.language === "string"
      && SUPPORTED_LOCALES.includes(normalizeLocale(status.language))
      && normalizeLocale(status.language) !== currentLocale
    ) {
      setLocale(status.language);
    }

    lastStatus = status;
    renderStatus(status);

    // Jeśli błąd — pokaż ekran błędu
    if (status.phase === "error" && status.error) {
      showError(resolveBackendErrorMessage(status.error), status.error.code, status.error.retryable);
    }

    // Jeśli wymagana aktualizacja launchera
    if (status.phase === "launcher_update_required" && status.launcherUpdate) {
      showError(
        t("errors.launcherUpdateRequired", [status.launcherUpdate.newVersion]),
        "LCH_LAUNCHER_UPDATE_REQUIRED",
        false
      );
    }
  } catch (err) {
    console.error("loadStatus error:", err);
    // Graceful: pokaż co mamy, nie crashuj
    elPhase.textContent = t("phase.offline");
    elPhase.className = "badge badge-phase badge-warn";
    btnPlay.disabled = true;
    btnPlay.textContent = t("buttons.play");
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
    badge.textContent = getServerStatusLabel(status);
    badge.className = "server-status-badge badge";
    if (status === "online") badge.classList.add("badge-ok");
    else if (status === "maintenance") badge.classList.add("badge-warn");
  }
  if (playersEl) playersEl.textContent = players != null ? players : "---";
  if (pingEl) pingEl.textContent = ping != null ? `${ping}ms` : "---";
  applyServerMetaLabels();
}

// Placeholder: serwery offline (zostan\u0105 podmienione gdy API b\u0119dzie gotowe)
SERVERS.forEach(s => updateServerStatus(s.id, "offline", null, null));

// Fetch real server status from backend API
async function loadServerStatus() {
  try {
    const data = await invoke("get_server_status");
    if (data && data.servers) {
      data.servers.forEach(srv => {
        updateServerStatus(srv.id, srv.status, srv.players, srv.ping);
      });
    }
  } catch (err) {
    console.warn("Server status fetch failed:", err);
  }
}

// Refresh server status every 30s
loadServerStatus();
setInterval(loadServerStatus, 30000);

// ─────────────────────────────────────────────
// Website button
// ─────────────────────────────────────────────

const btnWebsite = $("#btn-website");
const WEBSITE_BASE_URL = "https://serwercanary.pl";

function openExternalUrl(url) {
  if (!url) return;
  if (window.__TAURI__ && window.__TAURI__.shell) {
    window.__TAURI__.shell.open(url);
    return;
  }
  window.open(url, "_blank");
}

function buildCreateCharacterUrl(mode) {
  const safeMode = mode === "classic74" ? "classic74" : "modern";
  return `${WEBSITE_BASE_URL}/account/createcharacter?source=launcher&mode=${encodeURIComponent(safeMode)}`;
}

if (btnWebsite) {
  btnWebsite.addEventListener("click", () => {
    openExternalUrl(WEBSITE_BASE_URL);
  });
}

if (btnCreateCharClassic) {
  btnCreateCharClassic.addEventListener("click", () => {
    openExternalUrl(buildCreateCharacterUrl("classic74"));
  });
}

if (btnCreateCharModern) {
  btnCreateCharModern.addEventListener("click", () => {
    openExternalUrl(buildCreateCharacterUrl("modern"));
  });
}

// ─────────────────────────────────────────────
// Check for updates (LR-034)
// ─────────────────────────────────────────────

btnCheck.addEventListener("click", async () => {
  btnCheck.disabled = true;
  btnCheck.textContent = t("buttons.checkingUpdates");

  try {
    const plan = await invoke("check_for_updates");

    if (plan.upToDate) {
      elPhase.textContent = t("phase.upToDate");
      elPhase.className = "badge badge-phase badge-ok";
      btnPlay.disabled = false;
      btnPlay.textContent = t("buttons.play");
    } else {
      // Pokaż ekran aktualizacji i uruchom update
      showScreen("update");
      startUpdate(plan);
    }
  } catch (err) {
    showFrontendError("CHECK_ERROR", true, String(err));
  } finally {
    btnCheck.disabled = false;
    btnCheck.textContent = t("buttons.checkUpdates");
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
    showFrontendError("UPDATE_ERROR", true, String(err));
  }
}

function updateProgress(dto) {
  lastProgress = dto;
  elProgressStage.textContent = getProgressStageLabel(dto.stage);
  elProgressPercent.textContent = `${dto.percent}%`;
  elProgressBar.style.width = `${dto.percent}%`;
  elProgressFile.textContent = dto.currentFile || "---";
  elProgressFilesCount.textContent = t("progress.filesCount", [dto.filesDone, dto.filesTotal]);
}

// ─────────────────────────────────────────────
// Launch game (LR-035 + LR-085 integrity check)
// ─────────────────────────────────────────────

btnPlay.addEventListener("click", async () => {
  btnPlay.disabled = true;
  btnPlay.textContent = t("buttons.playChecking");

  try {
    // LR-085: Pre-launch integrity check
    const check = await invoke("pre_launch_check");

    if (!check.passed) {
      const problems = [];
      if (check.modifiedFiles.length > 0) {
        problems.push(t("errors.modified", [check.modifiedFiles.length, check.modifiedFiles.join(", ")]));
      }
      if (check.missingFiles.length > 0) {
        problems.push(t("errors.missing", [check.missingFiles.length, check.missingFiles.join(", ")]));
      }
      if (check.errorFiles.length > 0) {
        problems.push(t("errors.readErrors", [check.errorFiles.length, check.errorFiles.join(", ")]));
      }
      showError(
        `${t("errors.integrityFailed")}\n\n${problems.join("\n")}`,
        "INTEGRITY_CHECK_FAILED",
        true
      );
      btnPlay.textContent = t("buttons.play");
      btnPlay.disabled = false;
      return;
    }
  } catch (err) {
    // Jeśli integrity check zawiedzie (np. brak sieci) — loguj ale pozwól grać
    console.warn("Pre-launch check failed:", err);
  }

  btnPlay.textContent = t("buttons.playLaunching");

  try {
    await invoke("launch_game");
    btnPlay.textContent = t("buttons.playLaunched");
    setTimeout(() => {
      btnPlay.textContent = t("buttons.play");
      btnPlay.disabled = false;
    }, 3000);
  } catch (err) {
    showFrontendError("LAUNCH_ERROR", true, String(err));
    btnPlay.textContent = t("buttons.play");
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
    elRepairBytes.textContent = t("repair.apiUnavailable");
    console.warn("Repair diagnostics failed:", err);
  }
}

btnRepairStart.addEventListener("click", async () => {
  btnRepairStart.disabled = true;
  btnRepairStart.textContent = t("buttons.repairing");
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
    showFrontendError("REPAIR_ERROR", true, String(err));
  } finally {
    btnRepairStart.disabled = false;
    btnRepairStart.textContent = t("buttons.repair");
  }
});

btnRepairBack.addEventListener("click", () => {
  showScreen("status");
});

// ─────────────────────────────────────────────
// Language packs (Faza 9.4)
// ─────────────────────────────────────────────

function formatLanguagePackMeta(pack) {
  const parts = [];
  parts.push(`${t("languagePacks.version")}: ${pack.version || "-"}`);
  if (typeof pack.tier !== "undefined" && pack.tier !== null) {
    parts.push(`${t("languagePacks.tier")}: ${pack.tier}`);
  }
  return parts.join(" · ");
}

function getLanguagePackName(pack) {
  return pack.nativeName || pack.displayName || pack.locale || "unknown";
}

async function loadLanguagePacksPanel() {
  if (!elLanguagePacksList || !elLanguagePacksEmpty) return;

  elLanguagePacksList.innerHTML = "";
  elLanguagePacksEmpty.style.display = "block";
  elLanguagePacksEmpty.textContent = t("languagePacks.loading");
  if (elLanguagePacksError) {
    elLanguagePacksError.style.display = "none";
    elLanguagePacksError.textContent = "";
  }

  try {
    const [catalog, installed] = await Promise.all([
      invoke("get_language_packs"),
      invoke("list_installed_language_packs"),
    ]);

    const installedMap = new Map();
    if (Array.isArray(installed)) {
      installed.forEach((pack) => {
        const locale = normalizeLocale(pack.locale);
        if (locale) installedMap.set(locale, pack.version || "");
      });
    }

    const available = Array.isArray(catalog?.availablePacks) ? catalog.availablePacks : [];
    if (available.length === 0) {
      elLanguagePacksEmpty.textContent = t("languagePacks.empty");
      return;
    }

    available
      .slice()
      .sort((a, b) => String(a.locale || "").localeCompare(String(b.locale || "")))
      .forEach((pack) => {
        const locale = normalizeLocale(pack.locale || "");
        const installedVersion = installedMap.get(locale);
        const isInstalled = Boolean(installedVersion && installedVersion === pack.version);
        const isBundled = Boolean(pack.bundled);

        const statusLabel = isBundled
          ? t("languagePacks.bundled")
          : isInstalled
            ? t("languagePacks.installed")
            : t("languagePacks.available");

        const actionHtml = (!isBundled && !isInstalled)
          ? `<button class="btn-download btn-install-langpack" data-locale="${escapeHtml(locale)}">${t("buttons.download")}</button>`
          : "";

        const row = document.createElement("div");
        row.className = "language-pack-row";
        row.innerHTML = `
          <div class="language-pack-main">
            <div class="language-pack-locale">${escapeHtml(getLanguagePackName(pack))} <span class="mono">(${escapeHtml(locale)})</span></div>
            <div class="language-pack-meta">${escapeHtml(formatLanguagePackMeta(pack))}</div>
          </div>
          <div class="language-pack-actions">
            <span class="badge-pack">${escapeHtml(statusLabel)}</span>
            ${actionHtml}
          </div>
        `;
        elLanguagePacksList.appendChild(row);
      });

    elLanguagePacksList.querySelectorAll(".btn-install-langpack").forEach((btn) => {
      btn.addEventListener("click", () => installLanguagePack(btn));
    });

    elLanguagePacksEmpty.style.display = "none";
  } catch (err) {
    const message = String(err);
    elLanguagePacksEmpty.textContent = t("languagePacks.empty");
    if (elLanguagePacksError) {
      elLanguagePacksError.style.display = "block";
      elLanguagePacksError.textContent = t("languagePacks.loadError", [message]);
    }
  }
}

async function installLanguagePack(btn) {
  const locale = normalizeLocale(btn.dataset.locale || "");
  if (!locale) return;

  btn.disabled = true;
  btn.textContent = t("languagePacks.installing");
  if (elLanguagePacksError) {
    elLanguagePacksError.style.display = "none";
    elLanguagePacksError.textContent = "";
  }

  try {
    await invoke("download_language_pack", { locale });
    await loadLanguagePacksPanel();
  } catch (err) {
    const message = String(err);
    btn.disabled = false;
    btn.textContent = t("buttons.download");
    if (elLanguagePacksError) {
      elLanguagePacksError.style.display = "block";
      elLanguagePacksError.textContent = t("languagePacks.installError", [message]);
    }
  }
}

if (btnLanguagePacksRefresh) {
  btnLanguagePacksRefresh.addEventListener("click", () => loadLanguagePacksPanel());
}

// ─────────────────────────────────────────────
// Settings (LR-038)
// ─────────────────────────────────────────────

btnSaveSettings.addEventListener("click", async () => {
  const channel = elSettingChannel.value;
  const locale = elSettingLanguage ? elSettingLanguage.value : currentLocale;
  try {
    const result = await invoke("change_channel", { channel, language: locale });
    console.log(result);
    setLocale(locale);
    showScreen("status");
    loadStatus();
  } catch (err) {
    showFrontendError("SETTINGS_ERROR", false, String(err));
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
    alert(t("alerts.logsExported", [path]));
  } catch (err) {
    alert(t("alerts.logsExportError", [String(err)]));
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
  if (elDownloadsLoading) elDownloadsLoading.textContent = t("downloads.loading");
  elDownloadsLoading.style.display = "block";
  elDownloadsList.style.display = "none";
  elDownloadsError.style.display = "none";

  try {
    const catalog = await invoke("get_installer_catalog");
    elDownloadsList.innerHTML = "";

    if (!catalog.artifacts || catalog.artifacts.length === 0) {
      const errorMsg = $("#downloads-error-msg");
      if (errorMsg) errorMsg.textContent = t("downloads.noArtifacts");
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
          ${t("buttons.download")}
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
    if (errorMsg) errorMsg.textContent = t("downloads.catalogError", [String(err)]);
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
  btn.textContent = t("buttons.downloading");

  try {
    const result = await invoke("download_and_verify_artifact", {
      url,
      filename,
      expectedSha256: sha256,
      expectedSize: size,
    });
    btn.textContent = t("buttons.downloaded");
    if (result.savedTo) {
      alert(t("downloads.downloadedTo", [result.savedTo]));
    }
  } catch (err) {
    btn.textContent = t("buttons.downloadError");
    const errorMessage = String(err);
    reportError("frontend.download_artifact_failed", errorMessage, {
      filename: filename || null,
      url: url || null,
      expectedSha256: sha256 || null,
      expectedSize: Number.isFinite(size) ? size : null,
    });
    showError(t("downloads.downloadError", [filename, errorMessage]), "DOWNLOAD_ERROR", true);
  } finally {
    setTimeout(() => {
      btn.disabled = false;
      btn.textContent = t("buttons.download");
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
          ? t("selfUpdate.required")
          : t("selfUpdate.available");
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
    btnSelfUpdateStart.textContent = t("buttons.updatingLauncher");
    if (elSelfUpdateStatus) elSelfUpdateStatus.textContent = t("selfUpdate.downloading");

    try {
      await invoke("perform_self_update");
      if (elSelfUpdateStatus) elSelfUpdateStatus.textContent = t("selfUpdate.restarting");
      // Launcher się zamknie + helper podmieni binarkę
    } catch (err) {
      const errorMessage = String(err);
      reportError("frontend.self_update_failed", errorMessage, {
        currentVersion: selfUpdateInfo?.currentVersion || null,
        latestVersion: selfUpdateInfo?.latestVersion || null,
      });
      showError(t("errors.selfUpdate", [errorMessage]), "SELF_UPDATE_ERROR", false);
      btnSelfUpdateStart.disabled = false;
      btnSelfUpdateStart.textContent = t("buttons.updateLauncher");
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
getNavButtons().forEach((btn) => {
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
    if (screen === "settings") loadLanguagePacksPanel();
  });
});

// ─────────────────────────────────────────────
// Init
// ─────────────────────────────────────────────

document.addEventListener("DOMContentLoaded", async () => {
  await loadI18nDictionaries();
  populateLanguageSelector();
  setLocale(getPreferredLocale(), false);

  if (elSettingLanguage) {
    elSettingLanguage.addEventListener("change", () => {
      setLocale(elSettingLanguage.value);
    });
  }

  showScreen("status");
  loadStatus();
  // Sprawdź self-update w tle
  checkSelfUpdate();
});
