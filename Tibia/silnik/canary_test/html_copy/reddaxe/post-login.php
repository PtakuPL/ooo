<?php
declare(strict_types=1);

require_once __DIR__ . '/bootstrap.php';

$cfg = reddaxe_build_config();
$apiEnv = reddaxe_env(__DIR__ . '/../apik/v1/.env');
$siteName = trim((string)($apiEnv['SITE_NAME'] ?? 'CanaryAAC'));
$launcherDownloadUrl = trim((string)($apiEnv['BOOTSTRAP_DOWNLOAD_URL_WIN'] ?? ''));
if ($launcherDownloadUrl === '') {
    $launcherDownloadUrl = trim((string)($apiEnv['LAUNCHER_DOWNLOAD_URL'] ?? ''));
}
if ($launcherDownloadUrl === '') {
    $launcherDownloadUrl = (string)($cfg['downloadPageUrl'] ?? '/downloads');
}
$loginUrl = (string)($cfg['accountLoginUrl'] ?? '/reddaxe/account-login.php');

$syncI18n = [
    'loading' => reddaxe_t('post_login.sync.loading'),
    'ok' => reddaxe_t('post_login.sync.ok'),
    'token' => reddaxe_t('post_login.sync.token'),
    'expires' => reddaxe_t('post_login.sync.expires'),
    'deepLink' => reddaxe_t('post_login.sync.deep_link'),
    'launching' => reddaxe_t('post_login.sync.launching'),
    'fallbackDownload' => reddaxe_t('post_login.sync.fallback_download'),
    'errorMissingDeepLink' => reddaxe_t('post_login.sync.error_missing_deep_link'),
    'errorPrefix' => reddaxe_t('post_login.sync.error_prefix'),
    'errorUnknownCode' => reddaxe_t('post_login.sync.error_unknown_code'),
    'errorUnknownMsg' => reddaxe_t('post_login.sync.error_unknown_msg'),
    'errorHttp' => reddaxe_t('post_login.sync.error_http'),
    'errorHttpFallback' => reddaxe_t('post_login.sync.error_http_fallback'),
];

$errors = [];
$accountUser = [
    'id' => 0,
    'name' => '',
    'email' => '',
];
$sessionKey = '';
$hasActiveSession = false;

reddaxe_start_shared_session();
$sessionAccount = $_SESSION['account']['user'] ?? null;
$sessionKey = trim((string)($_SESSION['account']['sessionKey'] ?? ''));
$loginTimeout = (int)($_SESSION['login_timeout'] ?? 0);

if (!is_array($sessionAccount) || $sessionKey === '') {
    $errors[] = reddaxe_t('post_login.error.no_session');
} elseif ($loginTimeout <= 0 || (time() - $loginTimeout) > 1800) {
    unset($_SESSION['account']['user'], $_SESSION['account']['sessionKey'], $_SESSION['login_timeout']);
    unset($_SESSION['myaac_account'], $_SESSION['myaac_password'], $_SESSION['myaac_last_visit'], $_SESSION['myaac_remember_me']);
    $errors[] = reddaxe_t('post_login.error.session_expired');
} else {
    $hasActiveSession = true;
    $accountUser['id'] = (int)($sessionAccount['id'] ?? 0);
    $accountUser['name'] = trim((string)($sessionAccount['name'] ?? ''));
    $accountUser['email'] = trim((string)($sessionAccount['email'] ?? ''));

    $ctxHttpCode = 0;
    $ctxCall = reddaxe_post_json('/apik/v1/account-context.php', [
        'type' => 'account_context',
        'sessionKey' => $sessionKey,
    ], $ctxHttpCode);

    if (($ctxCall['ok'] ?? false) !== true) {
        $errors[] = reddaxe_t('post_login.error.context_unreachable') . ': ' . (string)($ctxCall['message'] ?? 'request failed');
    } else {
        $ctxData = (array)($ctxCall['data'] ?? []);
        $ctxAccount = isset($ctxData['account']) && is_array($ctxData['account']) ? $ctxData['account'] : [];
        if ((int)($ctxAccount['id'] ?? 0) <= 0) {
            $errors[] = reddaxe_t('post_login.error.context_invalid') . ' (HTTP ' . $ctxHttpCode . ')';
        } else {
            $accountUser['id'] = (int)$ctxAccount['id'];
            $accountUser['name'] = trim((string)($ctxAccount['name'] ?? $accountUser['name']));
            $accountUser['email'] = trim((string)($ctxAccount['email'] ?? $accountUser['email']));
        }
    }

    $_SESSION['login_timeout'] = time();
}
session_write_close();

header('Content-Type: text/html; charset=utf-8');
?>
<!doctype html>
<html lang="<?php echo reddaxe_e(reddaxe_current_lang()); ?>">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?php echo reddaxe_e(reddaxe_t('post_login.page_title', ['brand' => $cfg['brand']])); ?></title>
    <style>
        body { margin: 0; font-family: "Trebuchet MS", "Segoe UI", sans-serif; background: #11151c; color: #ecf2ff; }
        .wrap { max-width: 920px; margin: 0 auto; padding: 24px 16px 40px; }
        .card { background: #1b2430; border: 1px solid #2f3f57; border-radius: 12px; padding: 16px; }
        h1 { margin: 0 0 14px; font-size: 1.7rem; }
        h2 { margin: 0 0 8px; font-size: 1.12rem; }
        p { margin: 0 0 12px; color: #b9c6dd; }
        .btns { display: flex; gap: 10px; margin-top: 14px; flex-wrap: wrap; }
        a.btn { border: 0; border-radius: 8px; padding: 10px 14px; font-weight: 700; text-decoration: none; background: #f28f3b; color: #111; }
        a.btn.secondary { background: #c6d4eb; }
        a.btn.alert { background: #e84855; color: #fff; }
        button.btn { border: 0; border-radius: 8px; padding: 10px 14px; font-weight: 700; background: #6bd8ff; color: #111; cursor: pointer; }
        .syncbox { margin-top: 14px; padding: 10px; border-radius: 8px; border: 1px solid #2f3f57; background: #0f1722; }
        .syncbox pre { margin: 6px 0 0; white-space: pre-wrap; word-break: break-all; color: #d1e8ff; }
        .muted { color: #b9c6dd; }
        .err { margin: 0 0 10px; padding: 8px 10px; border-radius: 8px; border: 1px solid #8c3b3b; background: #3a1f1f; color: #ffc4c4; }
        .ok { margin: 0 0 10px; padding: 8px 10px; border-radius: 8px; border: 1px solid #2f7b3a; background: #193322; color: #c7ffd2; }
        .topnav { margin-bottom: 12px; }
        .topnav a { color: #ffd9a6; text-decoration: none; }
        .lang-switch { display: inline-flex; gap: 0.38rem; margin-left: 0.5rem; }
        .lang-switch a { color: #e6edff; text-decoration: none; font-size: 0.8rem; border: 1px solid #2f3f57; border-radius: 4px; padding: 0.1rem 0.34rem; }
        .lang-switch a.active { border-color: #f28f3b; color: #f28f3b; }
        .servers { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 12px; margin-top: 12px; }
        .srv { border: 1px solid #2f3f57; border-radius: 10px; padding: 12px; background: #0f1722; }
        .chars { margin: 8px 0 0; padding-left: 18px; }
        .chars li { margin: 4px 0; color: #dce7fb; }
    </style>
</head>
<body>
<div class="wrap">
    <div class="topnav">
        <a href="/reddaxe/index.php"><?php echo reddaxe_e(reddaxe_t('common.nav.back_frontdoor')); ?></a>
        <span class="lang-switch">
            <?php foreach (reddaxe_supported_langs() as $lang): ?>
                <a class="<?php echo reddaxe_current_lang() === $lang ? 'active' : ''; ?>" href="<?php echo reddaxe_e(reddaxe_lang_switch_url($lang)); ?>"><?php echo reddaxe_e(reddaxe_t('common.lang.' . $lang)); ?></a>
            <?php endforeach; ?>
        </span>
    </div>
    <div class="card">
        <h1><?php echo reddaxe_e(reddaxe_t('post_login.heading')); ?></h1>
        <p><?php echo reddaxe_e(reddaxe_t('post_login.intro')); ?></p>

        <?php if ($hasActiveSession && $accountUser['name'] !== ''): ?>
            <div class="ok">
                <?php echo reddaxe_e(reddaxe_t('post_login.welcome', ['account' => $accountUser['name'], 'email' => $accountUser['email']])); ?>
            </div>
        <?php endif; ?>

        <?php foreach ($errors as $error): ?>
            <div class="err"><?php echo reddaxe_e($error); ?></div>
        <?php endforeach; ?>

        <?php if ($hasActiveSession): ?>
            <p class="muted"><?php echo reddaxe_e(reddaxe_t('post_login.characters.hidden_hint')); ?></p>
        <?php endif; ?>

        <div class="btns">
            <a class="btn" href="/account/createcharacter?mode=classic74&source=reddaxe"><?php echo reddaxe_e(reddaxe_t('post_login.btn.create_classic')); ?></a>
            <a class="btn secondary" href="/account/createcharacter?mode=modern&source=reddaxe"><?php echo reddaxe_e(reddaxe_t('post_login.btn.create_modern')); ?></a>
            <a class="btn secondary" href="/reddaxe/account-manage.php"><?php echo reddaxe_e(reddaxe_t('index.section.account.manage')); ?></a>
            <a class="btn secondary" href="/account"><?php echo reddaxe_e(reddaxe_t('post_login.btn.account')); ?></a>
            <a class="btn secondary" href="<?php echo reddaxe_e($launcherDownloadUrl); ?>"><?php echo reddaxe_e(reddaxe_t('post_login.btn.download_launcher')); ?></a>
            <a class="btn secondary" href="/reddaxe/index.php"><?php echo reddaxe_e(reddaxe_t('post_login.btn.back')); ?></a>
            <a class="btn alert" href="/reddaxe/logout.php"><?php echo reddaxe_e(reddaxe_t('common.nav.logout')); ?></a>
            <?php if (!$hasActiveSession): ?>
                <a class="btn" href="<?php echo reddaxe_e($loginUrl); ?>"><?php echo reddaxe_e(reddaxe_t('post_login.btn.go_login')); ?></a>
            <?php endif; ?>
        </div>

        <?php if ($hasActiveSession): ?>
            <div class="btns">
                <button id="syncBtn" class="btn" type="button"><?php echo reddaxe_e(reddaxe_t('post_login.btn.open_launcher')); ?></button>
            </div>
            <div class="syncbox">
                <div class="muted"><?php echo reddaxe_e(reddaxe_t('post_login.sync.hint')); ?></div>
                <pre id="syncOut"><?php echo reddaxe_e(reddaxe_t('post_login.sync.initial')); ?></pre>
            </div>
        <?php endif; ?>
    </div>
</div>
<?php if ($hasActiveSession): ?>
<script>
(() => {
    const i18n = <?php echo json_encode($syncI18n, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES); ?>;
    const btn = document.getElementById('syncBtn');
    const out = document.getElementById('syncOut');
    if (!btn || !out) return;
    let fallbackTimer = null;

    btn.addEventListener('click', async () => {
        if (fallbackTimer) {
            clearTimeout(fallbackTimer);
            fallbackTimer = null;
        }
        btn.disabled = true;
        out.textContent = i18n.loading;
        try {
            const resp = await fetch('/apik/v1/account-sync-www-token.php', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                body: JSON.stringify({ type: 'account_sync_www_token', target: 'launcher' }),
                credentials: 'same-origin'
            });
            const data = await resp.json();
            if (data && data.ok && data.launcherDeepLink) {
                const deepLink = String(data.launcherDeepLink || '');
                out.textContent = i18n.launching;
                window.location.href = deepLink;
                fallbackTimer = window.setTimeout(() => {
                    out.textContent =
                        i18n.fallbackDownload + '\n' +
                        i18n.deepLink + ': ' + deepLink;
                    btn.disabled = false;
                    fallbackTimer = null;
                }, 1800);
                return;
            } else if (data && data.ok) {
                out.textContent = i18n.errorPrefix + ': ' + i18n.errorMissingDeepLink;
            } else {
                const code = (data && (data.error || data.errorCode)) ? (data.error || data.errorCode) : i18n.errorUnknownCode;
                const msg = (data && (data.message || data.errorMessage)) ? (data.message || data.errorMessage) : i18n.errorUnknownMsg;
                out.textContent = i18n.errorPrefix + ' [' + code + ']: ' + msg;
            }
        } catch (err) {
            out.textContent = i18n.errorHttp + ': ' + (err && err.message ? err.message : i18n.errorHttpFallback);
        } finally {
            if (!fallbackTimer) {
                btn.disabled = false;
            }
        }
    });
})();
</script>
<?php endif; ?>
</body>
</html>
