/**
 * RedDaxe.pl Launcher — Frontend Application
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
          launcherVersion: "1.0.0-dev",
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
const elServerNameClassic = $("#server-name-classic");
const elServerNameModern = $("#server-name-modern");
const elLauncherAccountName = $("#launcher-account-name");
const elLauncherAccountEmail = $("#launcher-account-email");
const elLauncherAccountPassword = $("#launcher-account-password");
const elLauncherAccountPasswordConfirm = $("#launcher-account-password-confirm");
const elLauncherAccountLoginStatus = $("#launcher-account-login-status");
const btnLauncherAccountLogin = $("#btn-launcher-account-login");
const btnLauncherAccountRegister = $("#btn-launcher-account-register");
const elLauncherSessionKey = $("#launcher-session-key");
const btnPlay = $("#btn-play");
const btnCheck = $("#btn-check");
const btnCreateCharClassic = $("#btn-create-char-classic");
const btnCreateCharModern = $("#btn-create-char-modern");
const btnRulesAll = $("#btn-rules-all");
const btnRulesClassic = $("#btn-rules-classic");
const btnRulesModern = $("#btn-rules-modern");
const elLoggedUserEmail = $("#logged-user-email");
const btnLogout = $("#btn-logout");
const elLaunchModeSelect = $("#launch-mode-select");
const elCtxSessionMode = $("#ctx-session-mode");
const elCtxCountAll = $("#ctx-count-all");
const elCtxCountClassic = $("#ctx-count-classic");
const elCtxCountModern = $("#ctx-count-modern");
const elAccountContextHint = $("#account-context-hint");
const btnRefreshAccountContext = $("#btn-refresh-account-context");
const btnCreateCharacter = $("#btn-create-character");

// Login screen
const elLoginEmail = $("#login-email");
const elLoginPassword = $("#login-password");
const btnLoginSubmit = $("#btn-login-submit");
const elLoginStatus = $("#login-status");
const btnLoginShowRegister = $("#btn-login-show-register");
const elRegisterForm = $("#register-form");
const elRegisterName = $("#register-name");
const elRegisterEmail = $("#register-email");
const elRegisterPassword = $("#register-password");
const elRegisterPasswordConfirm = $("#register-password-confirm");
const btnRegisterSubmit = $("#btn-register-submit");
const btnRegisterBack = $("#btn-register-back");
const elRegisterStatus = $("#register-status");
const btnOAuthGoogle = $("#btn-oauth-google");
const btnOAuthFacebook = $("#btn-oauth-facebook");
const btnOAuthSteam = $("#btn-oauth-steam");
const elFooter = $("#footer");

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
const btnUninstallGame = $("#btn-uninstall-game");
const btnUninstallLauncher = $("#btn-uninstall-launcher");

// Nav
const btnExportLogs = $("#btn-export-logs");

// ─────────────────────────────────────────────
// Frontend i18n (PL/EN, runtime switch)
// ─────────────────────────────────────────────

const LANGUAGE_STORAGE_KEY = "launcher.locale";
const ACCOUNT_EMAIL_STORAGE_KEY = "launcher.accountEmail";
const ACCOUNT_SESSION_KEY_STORAGE_KEY = "launcher.accountSessionKey";
const LAUNCH_MODE_STORAGE_KEY = "launcher.launchMode";
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
let launcherAccountContext = null;
let selectedLaunchMode = "";

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

// Map bootstrap language codes (de, es, pt-br etc.) to supported launcher locales
function mapBootstrapLocale(code) {
  if (!code) return null;
  const normalized = code.trim().toLowerCase();
  // Direct match
  if (SUPPORTED_LOCALES.includes(normalized)) return normalized;
  // Bootstrap uses these codes for languages we don't have full translations yet
  const BOOTSTRAP_FALLBACK = { "de": "en", "es": "en", "pt-br": "en", "pt_br": "en" };
  return BOOTSTRAP_FALLBACK[normalized] || null;
}

async function getPreferredLocaleAsync() {
  // 1. Already stored in localStorage — use it
  const stored = localStorage.getItem(LANGUAGE_STORAGE_KEY);
  const storedNormalized = normalizeLocale(stored);
  if (SUPPORTED_LOCALES.includes(storedNormalized)) return storedNormalized;

  // 2. Try bootstrap language.conf via Tauri command
  try {
    const bootstrapLang = await window.__TAURI__.core.invoke("get_bootstrap_language");
    const mapped = mapBootstrapLocale(bootstrapLang);
    if (mapped) {
      localStorage.setItem(LANGUAGE_STORAGE_KEY, mapped);
      return mapped;
    }
  } catch (_) { /* Tauri not available or command failed */ }

  // 3. Browser language
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

function extractKnownErrorCode(rawValue) {
  const raw = String(rawValue || "");
  const lchMatch = raw.match(/LCH_[A-Z_]+/);
  if (lchMatch) return lchMatch[0];
  return null;
}

function resolveOnboardingErrorMessage(rawValue, genericAlertKey) {
  const code = extractKnownErrorCode(rawValue);
  if (code) {
    const backendKey = `errors.backend.${code}`;
    const translated = t(backendKey);
    if (translated !== backendKey) {
      return translated;
    }
  }
  return t(genericAlertKey);
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
  ["tibia-classic", "tibia-modern"].forEach((serverId) => {
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

  // Login screen
  setText("#login-title", t("login.title"));
  setText("#login-subtitle", t("login.subtitle"));
  setText("#label-login-email", t("login.email"));
  setText("#label-login-password", t("login.password"));
  setText("#btn-login-submit", t("login.submit"));
  setText("#login-register-hint", t("login.noAccountHint"));
  setText("#btn-login-show-register", t("login.showRegister"));
  setText("#label-register-name", t("login.registerName"));
  setText("#label-register-email", t("login.registerEmail"));
  setText("#label-register-password", t("login.registerPassword"));
  setText("#label-register-password-confirm", t("login.registerPasswordConfirm"));
  setText("#btn-register-submit", t("login.registerSubmit"));
  setText("#btn-register-back", t("login.registerBack"));
  setText("#login-oauth-hint", t("login.oauthHint"));
  setText("#btn-logout", t("login.logout"));
  if (elLoginEmail) elLoginEmail.placeholder = t("login.emailPlaceholder");
  if (elLoginPassword) elLoginPassword.placeholder = t("login.passwordPlaceholder");
  if (elRegisterName) elRegisterName.placeholder = t("login.registerNamePlaceholder");
  if (elRegisterEmail) elRegisterEmail.placeholder = t("login.registerEmailPlaceholder");
  if (elRegisterPassword) elRegisterPassword.placeholder = t("login.registerPasswordPlaceholder");
  if (elRegisterPasswordConfirm) elRegisterPasswordConfirm.placeholder = t("login.registerPasswordConfirmPlaceholder");

  // Status screen
  setText("#label-launcher", t("labels.launcher"));
  setText("#label-client", t("labels.client"));
  setText("#label-channel", t("labels.channel"));
  setText("#label-status", t("labels.status"));
  setText("#servers-title", t("labels.servers"));
  if (elServerNameMain) elServerNameMain.textContent = t("labels.serverMainName");
  if (elServerNameRetro) elServerNameRetro.textContent = t("labels.serverRetroName");
  if (elServerNameClassic) elServerNameClassic.textContent = t("labels.serverClassicName");
  if (elServerNameModern) elServerNameModern.textContent = t("labels.serverModernName");
  setText("#label-launch-mode", t("labels.launchMode"));
  setText("#label-session-mode", t("labels.sessionMode"));
  setText("#label-characters-all", t("labels.charactersAll"));
  setText("#label-characters-classic", t("labels.charactersClassic"));
  setText("#label-characters-modern", t("labels.charactersModern"));
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
  setText("#btn-launcher-account-login", t("buttons.loginAccount"));
  setText("#btn-launcher-account-register", t("buttons.registerAccount"));
  setText("#btn-create-char-classic", t("buttons.createCharacterClassic"));
  setText("#btn-create-char-modern", t("buttons.createCharacterModern"));
  setText("#btn-create-character", t("buttons.createCharacter"));
  setText("#btn-refresh-account-context", t("buttons.refreshAccountContext"));
  setText("#btn-rules-all", t("buttons.rulesAll"));
  setText("#btn-rules-classic", t("buttons.rulesClassic"));
  setText("#btn-rules-modern", t("buttons.rulesModern"));
  setText("#btn-website", t("buttons.website"));
  setText("#btn-retry", t("buttons.retry"));
  setText("#btn-back", t("buttons.back"));
  setText("#btn-repair-start", t("buttons.repair"));
  setText("#btn-repair-back", t("buttons.back"));
  setText("#btn-save-settings", t("buttons.save"));
  setText("#btn-settings-back", t("buttons.back"));
  setText("#setting-uninstall-label", t("labels.settingUninstall"));
  setText("#btn-uninstall-game", t("buttons.uninstallGame"));
  setText("#btn-uninstall-launcher", t("buttons.uninstallLauncher"));
  setText("#btn-downloads-refresh", t("buttons.refresh"));
  setText("#btn-downloads-back", t("buttons.back"));
  setText("#btn-selfupdate-start", t("buttons.updateLauncher"));
  setText("#btn-selfupdate-back", t("buttons.back"));
  setText("#btn-nav-login", t("nav.login"));
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

  if (elLaunchModeSelect) {
    Array.from(elLaunchModeSelect.options).forEach((option) => {
      if (option.value === "classic74") option.textContent = t("status.modeClassic");
      else if (option.value === "modern") option.textContent = t("status.modeModern");
      else option.textContent = t("status.modeSelectPlaceholder");
    });
  }

  if (launcherAccountContext) {
    renderLauncherAccountContext(launcherAccountContext, { preserveHint: true });
  } else {
    updatePlayGateState();
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
  const loginPicker = $("#login-language-picker");
  if (loginPicker) loginPicker.value = normalized;
  applyStaticTranslations();
  if (lastStatus) renderStatus(lastStatus);
  if (lastProgress) updateProgress(lastProgress);
  if ($("#screen-settings")?.classList.contains("active")) {
    loadLanguagePacksPanel();
  }
}

// ─────────────────────────────────────────────
// Auth gate — login-first flow (E1+E2)
// ─────────────────────────────────────────────

let isAuthenticated = false;

function isUserLoggedIn() {
  return Boolean(getStoredSessionKey());
}

function showLoginScreen() {
  isAuthenticated = false;
  screens.forEach((s) => s.classList.remove("active"));
  const loginScreen = $("#screen-login");
  if (loginScreen) loginScreen.classList.add("active");
  // Footer stays visible so user can access Repair/Settings/Logs before login
  if (elFooter) elFooter.style.display = "";
  // Show login nav button, highlight it
  const btnNavLogin = $("#btn-nav-login");
  if (btnNavLogin) btnNavLogin.style.display = "";
  getNavButtons().forEach((b) => b.classList.toggle("active", b.dataset.screen === "login"));
}

function enterAuthenticatedMode() {
  isAuthenticated = true;
  if (elFooter) elFooter.style.display = "";
  // Hide login nav button when authenticated
  const btnNavLogin = $("#btn-nav-login");
  if (btnNavLogin) btnNavLogin.style.display = "none";
  const email = getStoredAccountEmail();
  if (elLoggedUserEmail) elLoggedUserEmail.textContent = email || "---";
  showScreen("status");
  loadStatus();
  void refreshLauncherAccountContext("auth");
  // Self-update now runs at startup (before login), no need to re-check here
}

function handleLogout() {
  // Clear session
  saveSessionKey("");
  void invoke("clear_launcher_session").catch((err) => {
    console.warn("clear_launcher_session failed:", err);
  });
  launcherSessionKey = "";
  launcherAccountPassword = "";
  launcherAccountContext = null;
  persistSelectedLaunchMode("");
  renderLauncherAccountContext(null);
  setAccountContextHint("");
  if (elLoginEmail) elLoginEmail.value = "";
  if (elLoginPassword) elLoginPassword.value = "";
  if (elLoginStatus) { elLoginStatus.style.display = "none"; elLoginStatus.textContent = ""; }
  if (elLaunchModeSelect) elLaunchModeSelect.value = "";
  showLoginScreen();
}

function setLoginStatus(el, message, isError = false) {
  if (!el) return;
  const text = String(message || "").trim();
  if (!text) { el.style.display = "none"; el.textContent = ""; return; }
  el.style.display = "block";
  el.textContent = text;
  el.classList.remove("login-status-ok", "login-status-error");
  el.classList.add(isError ? "login-status-error" : "login-status-ok");
}

async function handleLoginSubmit() {
  const email = (elLoginEmail ? elLoginEmail.value : "").trim();
  const password = elLoginPassword ? elLoginPassword.value : "";

  if (!email || !password) {
    setLoginStatus(elLoginStatus, t("alerts.accountLoginMissingCredentials"), true);
    return;
  }

  if (btnLoginSubmit) { btnLoginSubmit.disabled = true; btnLoginSubmit.textContent = t("buttons.loggingInAccount"); }
  setLoginStatus(elLoginStatus, t("alerts.accountLoginInProgress"), false);

  try {
    const result = await invoke("login_launcher_account", { email, password });
    const sessionKey = sanitizeSessionKey(result?.sessionKey || "");
    if (!sessionKey) throw new Error("missing_session_key");

    saveAccountEmail(String(result?.email || email));
    saveSessionKey(sessionKey);
    launcherAccountPassword = password;

    if (elLoginPassword) elLoginPassword.value = "";
    setLoginStatus(elLoginStatus, "", false);
    enterAuthenticatedMode();
  } catch (err) {
    const message = String(err || "unknown_error");
    reportError("frontend.account_login_failed", message, { email });
    setLoginStatus(elLoginStatus, resolveOnboardingErrorMessage(message, "alerts.accountLoginErrorGeneric"), true);
  } finally {
    if (btnLoginSubmit) { btnLoginSubmit.disabled = false; btnLoginSubmit.textContent = t("buttons.loginAccount"); }
  }
}

async function handleRegisterSubmit() {
  const accountName = (elRegisterName ? elRegisterName.value : "").trim();
  const email = (elRegisterEmail ? elRegisterEmail.value : "").trim();
  const password = elRegisterPassword ? elRegisterPassword.value : "";
  const passwordConfirm = elRegisterPasswordConfirm ? elRegisterPasswordConfirm.value : "";

  if (!accountName || !email || !password || !passwordConfirm) {
    setLoginStatus(elRegisterStatus, t("alerts.accountRegisterMissingFields"), true);
    return;
  }

  if (btnRegisterSubmit) { btnRegisterSubmit.disabled = true; btnRegisterSubmit.textContent = t("buttons.registeringAccount"); }
  setLoginStatus(elRegisterStatus, t("alerts.accountRegisterInProgress"), false);

  try {
    const result = await invoke("register_launcher_account", { accountName, email, password, passwordConfirm });
    saveAccountEmail(String(result?.email || email));

    const autoLogin = Boolean(result?.autoLogin);
    const sessionKey = sanitizeSessionKey(result?.sessionKey || "");
    if (autoLogin && sessionKey) {
      saveSessionKey(sessionKey);
      enterAuthenticatedMode();
    } else {
      setLoginStatus(elRegisterStatus, t("alerts.accountRegisterSuccessNoAutoLogin"), false);
      // Show login form
      if (elRegisterForm) elRegisterForm.style.display = "none";
    }
  } catch (err) {
    const message = String(err || "unknown_error");
    reportError("frontend.account_register_failed", message, { email, accountName });
    setLoginStatus(elRegisterStatus, resolveOnboardingErrorMessage(message, "alerts.accountRegisterErrorGeneric"), true);
  } finally {
    if (btnRegisterSubmit) { btnRegisterSubmit.disabled = false; btnRegisterSubmit.textContent = t("buttons.registerAccount"); }
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
    // Screens that require authentication — redirect to login if not logged in
    const authRequired = ["status", "downloads"];
    if (!isAuthenticated && authRequired.includes(screen)) {
      showLoginScreen();
      return;
    }
    if (screen === "login") {
      showLoginScreen();
      return;
    }
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
  if (btnPlay.textContent !== t("buttons.playChecking")
    && btnPlay.textContent !== t("buttons.playLaunching")) {
    btnPlay.textContent = t("buttons.play");
  }
  updatePlayGateState({ preserveHint: true });
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
  { id: "tibia-classic", name: "RedDaxe.pl \u2014 Classic 7.4", host: null },
  { id: "tibia-modern", name: "RedDaxe.pl \u2014 Modern", host: null },
];

function mapServerId(rawId) {
  const id = String(rawId || "").trim().toLowerCase();
  if (id === "classic74" || id === "classic" || id === "tibia-retro") return "tibia-classic";
  if (id === "modern" || id === "tibia-main") return "tibia-modern";
  return id;
}

function updateServerStatus(serverId, status, players, ping) {
  const uiServerId = mapServerId(serverId);
  const dot = document.querySelector(`.server-card[data-server="${uiServerId}"] .server-status-dot`);
  const badge = $(`#srv-${uiServerId}-status`);
  const playersEl = $(`#srv-${uiServerId}-players`);
  const pingEl = $(`#srv-${uiServerId}-ping`);

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
const WEBSITE_BASE_URL = "https://127.0.0.1";
let launcherSessionKey = "";
let launcherAccountPassword = "";  // In-memory only — passed to launch_game, never persisted

let pendingAccountContextRefreshUntil = 0;
let accountContextRefreshInFlight = false;
let accountSyncConsumeInFlight = false;

function getStoredAccountEmail() {
  return String(localStorage.getItem(ACCOUNT_EMAIL_STORAGE_KEY) || "").trim();
}

function saveAccountEmail(value) {
  const clean = String(value || "").trim();
  if (clean) localStorage.setItem(ACCOUNT_EMAIL_STORAGE_KEY, clean);
  else localStorage.removeItem(ACCOUNT_EMAIL_STORAGE_KEY);
  if (elLauncherAccountEmail && elLauncherAccountEmail.value !== clean) {
    elLauncherAccountEmail.value = clean;
  }
  return clean;
}

function sanitizeSessionKey(value) {
  const str = typeof value === "string" ? value.trim() : "";
  return str.length > 256 ? str.slice(0, 256) : str;
}

function getStoredSessionKey() {
  return sanitizeSessionKey(localStorage.getItem(ACCOUNT_SESSION_KEY_STORAGE_KEY) || "");
}

function saveSessionKey(value) {
  const clean = sanitizeSessionKey(value);
  launcherSessionKey = clean;
  if (clean) localStorage.setItem(ACCOUNT_SESSION_KEY_STORAGE_KEY, clean);
  else localStorage.removeItem(ACCOUNT_SESSION_KEY_STORAGE_KEY);
  if (elLauncherSessionKey && elLauncherSessionKey.value !== clean) {
    elLauncherSessionKey.value = clean;
  }
  return clean;
}

function normalizeGameMode(mode) {
  const normalized = String(mode || "").trim().toLowerCase();
  if (normalized === "all" || normalized === "classic74" || normalized === "modern") {
    return normalized;
  }
  return "";
}

function normalizeSelectableLaunchMode(mode) {
  const normalized = normalizeGameMode(mode);
  return normalized === "classic74" || normalized === "modern" ? normalized : "";
}

function getModeLabel(mode) {
  const normalized = normalizeGameMode(mode);
  if (normalized === "classic74") return t("status.modeClassic");
  if (normalized === "modern") return t("status.modeModern");
  return t("status.modeAll");
}

function loadSelectedLaunchMode() {
  return normalizeSelectableLaunchMode(localStorage.getItem(LAUNCH_MODE_STORAGE_KEY) || "");
}

function persistSelectedLaunchMode(mode) {
  const clean = normalizeSelectableLaunchMode(mode);
  selectedLaunchMode = clean;
  if (clean) localStorage.setItem(LAUNCH_MODE_STORAGE_KEY, clean);
  else localStorage.removeItem(LAUNCH_MODE_STORAGE_KEY);
  if (elLaunchModeSelect && elLaunchModeSelect.value !== clean) {
    elLaunchModeSelect.value = clean;
  }
  return clean;
}

function setAccountContextHint(message, kind = "") {
  if (!elAccountContextHint) return;
  const text = String(message || "").trim();
  if (!text) {
    elAccountContextHint.textContent = "";
    elAccountContextHint.classList.remove("hint-error", "hint-ok");
    return;
  }
  elAccountContextHint.textContent = text;
  elAccountContextHint.classList.remove("hint-error", "hint-ok");
  if (kind === "error") elAccountContextHint.classList.add("hint-error");
  if (kind === "ok") elAccountContextHint.classList.add("hint-ok");
}

function getCharacterCountForMode(mode, context = launcherAccountContext) {
  const normalized = normalizeSelectableLaunchMode(mode);
  const counts = context && typeof context === "object" ? context.counts : null;
  if (!counts || typeof counts !== "object") return 0;
  const value = counts[normalized];
  return Number.isFinite(value) ? Number(value) : 0;
}

function getTotalCharacterCount(context = launcherAccountContext) {
  const counts = context && typeof context === "object" ? context.counts : null;
  if (!counts || typeof counts !== "object") return 0;
  const value = counts.all;
  return Number.isFinite(value) ? Number(value) : 0;
}

function getEffectiveLaunchMode() {
  const selected = normalizeSelectableLaunchMode(selectedLaunchMode);
  if (selected) return selected;
  const sessionMode = normalizeSelectableLaunchMode(launcherAccountContext?.gameMode);
  if (sessionMode) return sessionMode;
  return "";
}

function updatePlayGateState(options = {}) {
  const preserveHint = Boolean(options.preserveHint);
  if (!btnPlay) return;

  if (!lastStatus || lastStatus.phase !== "ready") {
    btnPlay.disabled = true;
    return;
  }

  if (!launcherAccountContext) {
    btnPlay.disabled = true;
    if (!preserveHint && isAuthenticated) {
      setAccountContextHint(t("alerts.accountContextLoading"));
    }
    return;
  }

  const totalCount = getTotalCharacterCount(launcherAccountContext);
  if (totalCount <= 0) {
    btnPlay.disabled = true;
    if (!preserveHint) {
      setAccountContextHint(t("alerts.playBlockedNoCharacters"), "error");
    }
    return;
  }

  btnPlay.disabled = false;
  if (!preserveHint) {
    setAccountContextHint(t("alerts.playReadyClientMode", [totalCount]), "ok");
  }
}

function renderLauncherAccountContext(context, options = {}) {
  const preserveHint = Boolean(options.preserveHint);
  launcherAccountContext = context && typeof context === "object" ? context : null;

  const sessionMode = normalizeGameMode(launcherAccountContext?.gameMode) || "all";
  const counts = launcherAccountContext?.counts && typeof launcherAccountContext.counts === "object"
    ? launcherAccountContext.counts
    : {};

  if (!selectedLaunchMode) {
    selectedLaunchMode = loadSelectedLaunchMode();
  }

  if (sessionMode === "classic74" || sessionMode === "modern") {
    persistSelectedLaunchMode(sessionMode);
  } else if (!normalizeSelectableLaunchMode(selectedLaunchMode)) {
    persistSelectedLaunchMode("");
  }

  if (elCtxSessionMode) {
    elCtxSessionMode.textContent = getModeLabel(sessionMode);
    elCtxSessionMode.className = "badge";
    if (sessionMode === "all") elCtxSessionMode.classList.add("badge-warn");
    else elCtxSessionMode.classList.add("badge-ok");
  }
  if (elCtxCountAll) elCtxCountAll.textContent = String(Number.isFinite(counts.all) ? counts.all : 0);
  if (elCtxCountClassic) {
    elCtxCountClassic.textContent = String(Number.isFinite(counts.classic74) ? counts.classic74 : 0);
  }
  if (elCtxCountModern) {
    elCtxCountModern.textContent = String(Number.isFinite(counts.modern) ? counts.modern : 0);
  }

  if (elLaunchModeSelect) {
    const value = normalizeSelectableLaunchMode(selectedLaunchMode);
    if (elLaunchModeSelect.value !== value) {
      elLaunchModeSelect.value = value;
    }
  }

  updatePlayGateState({ preserveHint });
}

function isSessionInvalidError(error) {
  const lower = String(error || "").toLowerCase();
  return lower.includes("invalid_session")
    || lower.includes("expired_session")
    || lower.includes("invalid or expired session")
    || lower.includes("session_invalid")
    || lower.includes("session_expired")
    || lower.includes("missing sessionkey")
    || lower.includes("missing_session_key")
    || lower.includes("account_context_refresh_failed: 401")
    || lower.includes("account_context_refresh_failed: 403")
    || lower.includes("session expired");
}

function isSyncTokenExpiredError(error) {
  const lower = String(error || "").toLowerCase();
  return lower.includes("sync_token_expired")
    || lower.includes("invalid_sync_token")
    || lower.includes("sync_token_already_used");
}

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

function buildRulesUrl(mode) {
  const safeMode = ["all", "classic74", "modern"].includes(mode) ? mode : "all";
  return `${WEBSITE_BASE_URL}/?subtopic=rules&mode=${encodeURIComponent(safeMode)}&source=launcher`;
}

function setAccountLoginStatus(message, isError = false) {
  if (!elLauncherAccountLoginStatus) return;
  const text = String(message || "").trim();
  if (!text) {
    elLauncherAccountLoginStatus.style.display = "none";
    elLauncherAccountLoginStatus.textContent = "";
    elLauncherAccountLoginStatus.classList.remove("login-status-ok", "login-status-error");
    return;
  }
  elLauncherAccountLoginStatus.style.display = "block";
  elLauncherAccountLoginStatus.textContent = text;
  elLauncherAccountLoginStatus.classList.remove("login-status-ok", "login-status-error");
  elLauncherAccountLoginStatus.classList.add(isError ? "login-status-error" : "login-status-ok");
}

async function consumePendingWebsiteSync(trigger = "startup") {
  if (accountSyncConsumeInFlight) {
    return false;
  }

  accountSyncConsumeInFlight = true;
  try {
    const result = await invoke("consume_pending_account_sync");
    if (!result?.pending) {
      return false;
    }

    const sessionKey = sanitizeSessionKey(result?.sessionKey || "");
    if (!result?.ok || !sessionKey) {
      return false;
    }

    saveAccountEmail(String(result?.email || ""));
    saveSessionKey(sessionKey);

    if (elLoginPassword) {
      elLoginPassword.value = "";
    }
    if (elLauncherAccountPassword) {
      elLauncherAccountPassword.value = "";
    }
    if (elLauncherAccountPasswordConfirm) {
      elLauncherAccountPasswordConfirm.value = "";
    }

    setLoginStatus(elLoginStatus, t("alerts.websiteLauncherSyncSuccess"), false);
    setAccountLoginStatus(t("alerts.websiteLauncherSyncSuccess"), false);
    enterAuthenticatedMode();
    return true;
  } catch (err) {
    const message = String(err || "unknown_error");
    reportError("frontend.website_launcher_sync_failed", message, { trigger });
    const userMessage = isSyncTokenExpiredError(message)
      ? t("alerts.websiteLauncherSyncExpiredRetry")
      : resolveOnboardingErrorMessage(
        message,
        "alerts.websiteLauncherSyncErrorGeneric"
      );
    setLoginStatus(elLoginStatus, userMessage, true);
    setAccountLoginStatus(userMessage, true);
    setAccountContextHint(userMessage, "error");
    return false;
  } finally {
    accountSyncConsumeInFlight = false;
  }
}

function setAccountAuthButtonsBusy(isBusy, activeAction = "") {
  if (btnLauncherAccountLogin) {
    btnLauncherAccountLogin.disabled = isBusy;
    btnLauncherAccountLogin.textContent =
      isBusy && activeAction === "login"
        ? t("buttons.loggingInAccount")
        : t("buttons.loginAccount");
  }

  if (btnLauncherAccountRegister) {
    btnLauncherAccountRegister.disabled = isBusy;
    btnLauncherAccountRegister.textContent =
      isBusy && activeAction === "register"
        ? t("buttons.registeringAccount")
        : t("buttons.registerAccount");
  }
}

async function loginLauncherAccount() {
  const email = (elLauncherAccountEmail ? elLauncherAccountEmail.value : "").trim();
  const password = elLauncherAccountPassword ? elLauncherAccountPassword.value : "";

  if (!email || !password) {
    setAccountLoginStatus(t("alerts.accountLoginMissingCredentials"), true);
    return;
  }

  setAccountAuthButtonsBusy(true, "login");
  setAccountLoginStatus(t("alerts.accountLoginInProgress"), false);

  try {
    const result = await invoke("login_launcher_account", { email, password });
    const sessionKey = sanitizeSessionKey(result?.sessionKey || "");
    if (!sessionKey) {
      throw new Error("missing_session_key");
    }

    saveAccountEmail(String(result?.email || email));
    saveSessionKey(sessionKey);
    launcherAccountPassword = password;  // Keep in-memory for launch_game

    if (elLauncherAccountPassword) {
      elLauncherAccountPassword.value = "";
    }

    setAccountLoginStatus(t("alerts.accountLoginSuccess"), false);
  } catch (err) {
    const message = String(err || "unknown_error");
    reportError("frontend.account_login_failed", message, { email: email || null });
    setAccountLoginStatus(
      resolveOnboardingErrorMessage(message, "alerts.accountLoginErrorGeneric"),
      true
    );
  } finally {
    setAccountAuthButtonsBusy(false);
  }
}

async function registerLauncherAccount() {
  const accountName = (elLauncherAccountName ? elLauncherAccountName.value : "").trim();
  const email = (elLauncherAccountEmail ? elLauncherAccountEmail.value : "").trim();
  const password = elLauncherAccountPassword ? elLauncherAccountPassword.value : "";
  const passwordConfirm = elLauncherAccountPasswordConfirm
    ? elLauncherAccountPasswordConfirm.value
    : "";

  if (!accountName || !email || !password || !passwordConfirm) {
    setAccountLoginStatus(t("alerts.accountRegisterMissingFields"), true);
    return;
  }

  setAccountAuthButtonsBusy(true, "register");
  setAccountLoginStatus(t("alerts.accountRegisterInProgress"), false);

  try {
    const result = await invoke("register_launcher_account", {
      accountName,
      email,
      password,
      passwordConfirm,
    });

    saveAccountEmail(String(result?.email || email));
    if (elLauncherAccountName) {
      elLauncherAccountName.value = String(result?.accountName || accountName);
    }

    if (elLauncherAccountPassword) {
      elLauncherAccountPassword.value = "";
    }
    if (elLauncherAccountPasswordConfirm) {
      elLauncherAccountPasswordConfirm.value = "";
    }

    const autoLogin = Boolean(result?.autoLogin);
    const sessionKey = sanitizeSessionKey(result?.sessionKey || "");
    if (autoLogin && sessionKey) {
      saveSessionKey(sessionKey);
      setAccountLoginStatus(t("alerts.accountRegisterSuccessAutoLogin"), false);
    } else {
      setAccountLoginStatus(t("alerts.accountRegisterSuccessNoAutoLogin"), false);
    }
  } catch (err) {
    const message = String(err || "unknown_error");
    reportError("frontend.account_register_failed", message, {
      email: email || null,
      accountName: accountName || null,
    });
    setAccountLoginStatus(
      resolveOnboardingErrorMessage(message, "alerts.accountRegisterErrorGeneric"),
      true
    );
  } finally {
    setAccountAuthButtonsBusy(false);
  }
}

async function buildSyncedCreateCharacterUrl(mode) {
  const safeMode = mode === "classic74" ? "classic74" : "modern";
  const sessionKey = saveSessionKey(
    (elLauncherSessionKey && elLauncherSessionKey.value) || launcherSessionKey
  );

  if (!sessionKey) {
    return {
      url: buildCreateCharacterUrl(safeMode),
      fallback: true,
      reason: "missing_session_key",
    };
  }

  try {
    const response = await invoke("build_create_character_url", { mode: safeMode });

    if (response && typeof response.url === "string" && response.url.length > 0) {
      return {
        url: response.url,
        fallback: false,
      };
    }
  } catch (err) {
    console.warn("build_create_character_url failed:", err);
    reportError("frontend.sync_url_failed", String(err), { mode: safeMode });
    return {
      url: buildCreateCharacterUrl(safeMode),
      fallback: true,
      reason: String(err),
    };
  }

  return {
    url: buildCreateCharacterUrl(safeMode),
    fallback: true,
    reason: "empty_sync_response",
  };
}

async function refreshLauncherAccountContext(trigger = "manual") {
  if (accountContextRefreshInFlight) {
    return false;
  }

  const sessionKey = saveSessionKey(
    (elLauncherSessionKey && elLauncherSessionKey.value) || launcherSessionKey
  );
  if (!sessionKey) {
    launcherAccountContext = null;
    renderLauncherAccountContext(null);
    return false;
  }

  const silentTrigger = trigger === "focus" || trigger === "auth";
  accountContextRefreshInFlight = true;
  try {
    const result = await invoke("refresh_launcher_account_context");

    if (result?.email) {
      saveAccountEmail(String(result.email));
    }
    if (elLauncherAccountName && result?.accountName) {
      elLauncherAccountName.value = String(result.accountName);
    }
    renderLauncherAccountContext(result);
    if (!silentTrigger) {
      setAccountLoginStatus(t("alerts.accountContextRefreshed"), false);
    }

    return true;
  } catch (err) {
    const message = String(err || "unknown_error");
    const sessionInvalid = isSessionInvalidError(message);
    if (sessionInvalid) {
      saveSessionKey("");
      launcherSessionKey = "";
      launcherAccountContext = null;
      renderLauncherAccountContext(null);
    }

    if (!silentTrigger) {
      reportError("frontend.account_context_refresh_failed", message, { trigger });
      const userMessage = sessionInvalid
        ? t("alerts.sessionExpiredRelogin")
        : resolveOnboardingErrorMessage(message, "alerts.accountContextRefreshErrorGeneric");
      setAccountLoginStatus(userMessage, true);
      setAccountContextHint(userMessage, "error");
    }

    if (sessionInvalid && isAuthenticated) {
      showLoginScreen();
    }

    return false;
  } finally {
    accountContextRefreshInFlight = false;
  }
}

async function switchLauncherAccountProfile(mode, trigger = "manual") {
  const safeMode = normalizeSelectableLaunchMode(mode);
  if (!safeMode) return false;

  try {
    const result = await invoke("switch_launcher_account_profile", { gameMode: safeMode });
    renderLauncherAccountContext(result);
    if (trigger === "mode-change") {
      setAccountContextHint(t("alerts.profileSwitched", [getModeLabel(safeMode)]), "ok");
    }
    return true;
  } catch (err) {
    const message = String(err || "unknown_error");
    const sessionInvalid = isSessionInvalidError(message);
    reportError("frontend.account_profile_switch_failed", message, { trigger, mode: safeMode });

    if (sessionInvalid) {
      saveSessionKey("");
      launcherSessionKey = "";
      launcherAccountContext = null;
      renderLauncherAccountContext(null);
      if (isAuthenticated) showLoginScreen();
    }

    const userMessage = sessionInvalid
      ? t("alerts.sessionExpiredRelogin")
      : resolveOnboardingErrorMessage(message, "alerts.accountContextRefreshErrorGeneric");
    setAccountLoginStatus(userMessage, true);
    setAccountContextHint(userMessage, "error");
    return false;
  }
}

async function buildSyncedWebsiteUrl(redirectPath = "/") {
  const sessionKey = getStoredSessionKey();
  if (!sessionKey) {
    return {
      url: `${WEBSITE_BASE_URL}${redirectPath}`,
      fallback: true,
      error: "missing_session_key",
    };
  }

  try {
    const response = await invoke("build_website_sync_url", { redirectPath });
    if (response && typeof response.url === "string" && response.url.length > 0) {
      return {
        url: response.url,
        fallback: false,
      };
    }
  } catch (err) {
    return {
      url: `${WEBSITE_BASE_URL}${redirectPath}`,
      fallback: true,
      error: String(err || "sync_url_failed"),
    };
  }

  return {
    url: `${WEBSITE_BASE_URL}${redirectPath}`,
    fallback: true,
    error: "sync_url_empty",
  };
}

async function openCreateCharacterForSelectedMode() {
  const launchMode = getEffectiveLaunchMode();
  if (!launchMode) {
    const msg = t("alerts.createCharacterModeRequired");
    setAccountContextHint(msg, "error");
    setAccountLoginStatus(msg, true);
    return false;
  }

  if (isAuthenticated && getStoredSessionKey()) {
    await switchLauncherAccountProfile(launchMode, "create-character");
  }
  await openCreateCharacterFlow(launchMode);
  return true;
}

async function openCreateCharacterFlow(mode) {
  const result = await buildSyncedCreateCharacterUrl(mode);
  openExternalUrl(result.url);

  if (!result.fallback) {
    pendingAccountContextRefreshUntil = Date.now() + 10 * 60 * 1000;
    setAccountLoginStatus(t("alerts.accountContextRefreshPending"), false);
    setAccountContextHint(t("alerts.accountContextRefreshPending"));
  }

  if (result.fallback) {
    const reason = result.reason === "missing_session_key"
      ? t("alerts.createCharacterFallbackMissingSession")
      : isSyncTokenExpiredError(result.reason)
        ? t("alerts.websiteLauncherSyncExpiredRetry")
        : t("alerts.createCharacterFallbackErrorGeneric");
    setAccountContextHint(reason, "error");
    alert(reason);
  }
}

if (btnWebsite) {
  btnWebsite.addEventListener("click", async () => {
    const result = await buildSyncedWebsiteUrl("/");
    openExternalUrl(result.url);
    if (result.fallback && result.error && isSyncTokenExpiredError(result.error)) {
      const msg = t("alerts.websiteLauncherSyncExpiredRetry");
      setAccountLoginStatus(msg, true);
      setAccountContextHint(msg, "error");
    }
  });
}

if (btnCreateCharClassic) {
  btnCreateCharClassic.addEventListener("click", async () => {
    await openCreateCharacterFlow("classic74");
  });
}

if (btnCreateCharModern) {
  btnCreateCharModern.addEventListener("click", async () => {
    await openCreateCharacterFlow("modern");
  });
}

if (elLaunchModeSelect) {
  elLaunchModeSelect.addEventListener("change", async () => {
    const pickedMode = normalizeSelectableLaunchMode(elLaunchModeSelect.value);
    persistSelectedLaunchMode(pickedMode);

    if (!pickedMode) {
      updatePlayGateState();
      return;
    }

    if (isAuthenticated && getStoredSessionKey()) {
      await switchLauncherAccountProfile(pickedMode, "mode-change");
      return;
    }

    updatePlayGateState();
  });
}

if (btnRefreshAccountContext) {
  btnRefreshAccountContext.addEventListener("click", async () => {
    btnRefreshAccountContext.disabled = true;
    const ok = await refreshLauncherAccountContext("manual");
    if (ok) {
      setAccountContextHint(t("alerts.accountContextRefreshed"), "ok");
    }
    btnRefreshAccountContext.disabled = false;
  });
}

if (btnCreateCharacter) {
  btnCreateCharacter.addEventListener("click", async () => {
    await openCreateCharacterForSelectedMode();
  });
}

if (btnRulesAll) {
  btnRulesAll.addEventListener("click", async () => {
    const result = await buildSyncedWebsiteUrl("/?subtopic=rules&mode=all&source=launcher");
    openExternalUrl(result.url);
    if (result.fallback && result.error && isSyncTokenExpiredError(result.error)) {
      setAccountContextHint(t("alerts.websiteLauncherSyncExpiredRetry"), "error");
    }
  });
}

if (btnRulesClassic) {
  btnRulesClassic.addEventListener("click", async () => {
    const result = await buildSyncedWebsiteUrl("/?subtopic=rules&mode=classic74&source=launcher");
    openExternalUrl(result.url);
    if (result.fallback && result.error && isSyncTokenExpiredError(result.error)) {
      setAccountContextHint(t("alerts.websiteLauncherSyncExpiredRetry"), "error");
    }
  });
}

if (btnRulesModern) {
  btnRulesModern.addEventListener("click", async () => {
    const result = await buildSyncedWebsiteUrl("/?subtopic=rules&mode=modern&source=launcher");
    openExternalUrl(result.url);
    if (result.fallback && result.error && isSyncTokenExpiredError(result.error)) {
      setAccountContextHint(t("alerts.websiteLauncherSyncExpiredRetry"), "error");
    }
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
      btnPlay.textContent = t("buttons.play");
      updatePlayGateState();
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
  const charCount = getTotalCharacterCount(launcherAccountContext);
  if (charCount <= 0) {
    const msg = t("alerts.playBlockedNoCharacters");
    setAccountContextHint(msg, "error");
    setAccountLoginStatus(msg, true);
    btnPlay.textContent = t("buttons.play");
    btnPlay.disabled = true;
    return;
  }

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

      // K105: tampered critical files -> quarantine + redownload via backend.
      showScreen("update");
      updateProgress({
        stage: "verifying",
        currentFile: null,
        filesDone: 0,
        filesTotal: 0,
        bytesDone: 0,
        bytesTotal: 0,
        percent: 0,
        etaSeconds: null,
      });

      try {
        const repairResult = await invoke("repair_tampered_critical_files");
        updateProgress(repairResult);

        setTimeout(() => {
          showScreen("status");
          loadStatus();
        }, 800);
      } catch (repairErr) {
        showError(
          `${t("errors.integrityFailed")}\n\n${problems.join("\n")}\n\n${t("alerts.antiTamperRepairFailed")}`,
          "LCH_ANTI_TAMPER_REPAIR_FAILED",
          true
        );
      }

      btnPlay.textContent = t("buttons.play");
      updatePlayGateState();
      return;
    }
  } catch (err) {
    // Jeśli integrity check zawiedzie (np. brak sieci) — loguj ale pozwól grać
    console.warn("Pre-launch check failed:", err);
  }

  btnPlay.textContent = t("buttons.playLaunching");

  try {
    const email = getStoredAccountEmail();
    await invoke("launch_game", {
      email: email || null,
      characterHint: null,
      gameMode: null,
    });
    launcherAccountPassword = "";
    setAccountContextHint(t("alerts.playReadyClientMode", [charCount]), "ok");
    btnPlay.textContent = t("buttons.playLaunched");
    setTimeout(() => {
      btnPlay.textContent = t("buttons.play");
      updatePlayGateState();
    }, 3000);
  } catch (err) {
    const errMsg = String(err);
    if (isSessionInvalidError(errMsg)) {
      saveSessionKey("");
      launcherSessionKey = "";
      launcherAccountContext = null;
      renderLauncherAccountContext(null);
      const msg = t("alerts.sessionExpiredRelogin");
      setAccountLoginStatus(msg, true);
      setAccountContextHint(msg, "error");
      showLoginScreen();
    } else {
      showFrontendError("LAUNCH_ERROR", true, errMsg);
    }
    btnPlay.textContent = t("buttons.play");
    updatePlayGateState();
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

// ── Uninstall buttons ──

if (btnUninstallGame) {
  btnUninstallGame.addEventListener("click", async () => {
    if (!confirm(t("settings.uninstallGameConfirm"))) return;
    try {
      await invoke("uninstall_game_files");
      alert(t("settings.uninstallGameDone"));
    } catch (err) {
      alert(t("settings.uninstallGameError") + "\n" + String(err));
    }
  });
}

if (btnUninstallLauncher) {
  btnUninstallLauncher.addEventListener("click", async () => {
    if (!confirm(t("settings.uninstallLauncherConfirm"))) return;
    try {
      await invoke("uninstall_launcher");
    } catch (err) {
      alert(t("settings.uninstallLauncherError") + "\n" + String(err));
    }
  });
}

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
  const numeric = Number(bytes);
  if (!Number.isFinite(numeric) || numeric < 0) return "n/a";
  if (numeric === 0) return "0 B";
  const units = ["B", "KB", "MB", "GB"];
  const i = Math.min(Math.floor(Math.log(numeric) / Math.log(1024)), units.length - 1);
  const val = (numeric / Math.pow(1024, i)).toFixed(i === 0 ? 0 : 1);
  return `${val} ${units[i]}`;
}

function isSha256Hex(value) {
  return /^[a-f0-9]{64}$/i.test(String(value || "").trim());
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
      const size = Number(art.size);
      const canDownload = Boolean(art.url && art.filename && isSha256Hex(art.sha256) && Number.isFinite(size) && size > 0);
      card.innerHTML = `
        <div class="download-info">
          <div class="filename">${escapeHtml(art.filename)}</div>
          <div class="meta">
            <span class="platform-badge ${platformClass}">${escapeHtml(art.platform)}</span>
            <span>${escapeHtml(art.arch)}</span> · 
            <span>${formatBytes(art.size)}</span> · 
            <span class="mono">${escapeHtml(String(art.sha256 || "").substring(0, 12))}…</span>
          </div>
        </div>
        <button class="btn-download" data-url="${escapeHtml(art.url)}" data-filename="${escapeHtml(art.filename)}" data-sha256="${escapeHtml(art.sha256)}" data-size="${Number.isFinite(size) ? size : ""}" ${canDownload ? "" : "disabled"}>
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

  if (!isSha256Hex(sha256) || !Number.isFinite(size) || size <= 0) {
    showError("Artefakt nie ma poprawnego SHA-256 albo rozmiaru w katalogu.", "DOWNLOAD_METADATA_INVALID", true);
    return;
  }

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
  const preferredLocale = await getPreferredLocaleAsync();
  setLocale(preferredLocale, false);

  // Restore stored values to hidden fields (backward compat)
  saveAccountEmail(getStoredAccountEmail());
  saveSessionKey(getStoredSessionKey());
  persistSelectedLaunchMode(loadSelectedLaunchMode());
  renderLauncherAccountContext(null, { preserveHint: true });

  if (elSettingLanguage) {
    elSettingLanguage.addEventListener("change", () => {
      setLocale(elSettingLanguage.value);
    });
  }

  const loginPicker = $("#login-language-picker");
  if (loginPicker) {
    loginPicker.value = currentLocale;
    loginPicker.addEventListener("change", () => {
      setLocale(loginPicker.value);
    });
  }

  // --- Login screen handlers ---
  if (btnLoginSubmit) {
    btnLoginSubmit.addEventListener("click", () => handleLoginSubmit());
  }
  if (elLoginPassword) {
    elLoginPassword.addEventListener("keydown", (e) => {
      if (e.key === "Enter") { e.preventDefault(); handleLoginSubmit(); }
    });
  }
  if (btnLoginShowRegister) {
    btnLoginShowRegister.addEventListener("click", () => {
      if (elRegisterForm) elRegisterForm.style.display = elRegisterForm.style.display === "none" ? "" : "none";
    });
  }
  if (btnRegisterSubmit) {
    btnRegisterSubmit.addEventListener("click", () => handleRegisterSubmit());
  }
  if (elRegisterPasswordConfirm) {
    elRegisterPasswordConfirm.addEventListener("keydown", (e) => {
      if (e.key === "Enter") { e.preventDefault(); handleRegisterSubmit(); }
    });
  }
  if (btnRegisterBack) {
    btnRegisterBack.addEventListener("click", () => {
      if (elRegisterForm) elRegisterForm.style.display = "none";
    });
  }

  // OAuth buttons — open provider auth URL in the browser
  function handleOAuth(provider) {
    const apiBase = WEBSITE_BASE_URL;
    const oauthUrl = `${apiBase}/apik/v1/oauth-start.php?provider=${encodeURIComponent(provider)}&mode=login&source=launcher`;
    openExternalUrl(oauthUrl);
    setLoginStatus(elLoginStatus, t("login.oauthRedirected"), false);
  }
  if (btnOAuthGoogle) btnOAuthGoogle.addEventListener("click", () => handleOAuth("google"));
  if (btnOAuthFacebook) btnOAuthFacebook.addEventListener("click", () => handleOAuth("facebook"));
  if (btnOAuthSteam) btnOAuthSteam.addEventListener("click", () => handleOAuth("steam"));

  // --- Logout handler ---
  if (btnLogout) {
    btnLogout.addEventListener("click", () => handleLogout());
  }

  // --- Legacy login form (hidden fields, kept for backward compat) ---
  if (elLauncherSessionKey) {
    elLauncherSessionKey.addEventListener("change", () => { saveSessionKey(elLauncherSessionKey.value); });
    elLauncherSessionKey.addEventListener("blur", () => { saveSessionKey(elLauncherSessionKey.value); });
  }
  if (elLauncherAccountEmail) {
    elLauncherAccountEmail.addEventListener("blur", () => { saveAccountEmail(elLauncherAccountEmail.value); });
  }

  // Keep legacy handlers wired (their buttons are now hidden/removed but keep for safety)
  if (btnLauncherAccountLogin) {
    btnLauncherAccountLogin.addEventListener("click", () => loginLauncherAccount());
  }
  if (btnLauncherAccountRegister) {
    btnLauncherAccountRegister.addEventListener("click", () => registerLauncherAccount());
  }

  window.addEventListener("focus", () => {
    void consumePendingWebsiteSync("focus");
    if (!isAuthenticated) return;
    if (Date.now() > pendingAccountContextRefreshUntil) {
      return;
    }
    void refreshLauncherAccountContext("focus").then((ok) => {
      if (ok) {
        pendingAccountContextRefreshUntil = 0;
      }
    });
  });

  setInterval(() => {
    void consumePendingWebsiteSync("poll");
  }, 3000);

  // --- Self-update check BEFORE auth gate ---
  // This ensures even unauthenticated launchers can update themselves
  try {
    await checkSelfUpdate();
    if (selfUpdateInfo?.updateRequired) {
      // Required update — show self-update screen, block login
      return;
    }
  } catch (err) {
    console.warn("Pre-auth self-update check failed:", err);
  }

  if (await consumePendingWebsiteSync("startup")) {
    return;
  }

  // --- Auth gate: check stored session ---
  if (isUserLoggedIn()) {
    // Try to validate the stored session
    try {
      const result = await invoke("refresh_launcher_account_context");
      if (result?.email) saveAccountEmail(String(result.email));
      renderLauncherAccountContext(result);
      enterAuthenticatedMode();
    } catch (err) {
      // Stored session expired/invalid → show login
      console.warn("Stored session invalid:", err);
      saveSessionKey("");
      launcherSessionKey = "";
      launcherAccountContext = null;
      renderLauncherAccountContext(null);
      showLoginScreen();
    }
  } else {
    showLoginScreen();
  }
});
