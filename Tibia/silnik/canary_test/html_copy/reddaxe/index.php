<?php
declare(strict_types=1);

require_once __DIR__ . '/bootstrap.php';

$cfg = reddaxe_build_config();

$apiEnv = reddaxe_env(__DIR__ . '/../apik/v1/.env');

// Check session state for logged-in user display
reddaxe_start_shared_session();
$sessionAccount = $_SESSION['account']['user'] ?? null;
$isLoggedIn = is_array($sessionAccount) && (int)($sessionAccount['id'] ?? 0) > 0;
$loggedUserName = $isLoggedIn ? trim((string)($sessionAccount['name'] ?? '')) : '';
$loggedUserEmail = $isLoggedIn ? trim((string)($sessionAccount['email'] ?? '')) : '';
session_write_close();

$artifact = [
    'version' => '-',
    'releaseDate' => '-',
    'sha256' => '',
    'url' => $cfg['downloadPageUrl'],
    'fallbackUrl' => $cfg['downloadPageUrl'],
];

$catalogErrorKey = '';
$artifact['version'] = (string)($apiEnv['LAUNCHER_VERSION'] ?? $artifact['version']);
$artifact['releaseDate'] = (string)($apiEnv['LAUNCHER_RELEASE_DATE'] ?? $artifact['releaseDate']);
$artifact['sha256'] = strtolower(trim((string)($apiEnv['LAUNCHER_SHA256'] ?? '')));
$artifact['url'] = (string)($apiEnv['LAUNCHER_DOWNLOAD_URL'] ?? $artifact['url']);
$artifact['fallbackUrl'] = (string)($apiEnv['REDDAXE_LAUNCHER_FALLBACK_URL'] ?? $artifact['fallbackUrl']);

if ($artifact['url'] === '') {
    $artifact['url'] = $cfg['downloadPageUrl'];
}
if ($artifact['fallbackUrl'] === '') {
    $artifact['fallbackUrl'] = $cfg['downloadPageUrl'];
}
if ($artifact['sha256'] !== '' && !preg_match('/^[a-f0-9]{64}$/', $artifact['sha256'])) {
    $artifact['sha256'] = '';
    $catalogErrorKey = 'index.warn.invalid_sha';
}
if (($apiEnv['LAUNCHER_VERSION'] ?? '') === '') {
    $catalogErrorKey = 'index.warn.missing_version';
}

// Bootstrap launcher data from .env
$bootstrap = [
    'version' => (string)($apiEnv['BOOTSTRAP_VERSION'] ?? ''),
    'url' => (string)($apiEnv['BOOTSTRAP_DOWNLOAD_URL_WIN'] ?? ''),
    'sha256' => strtolower(trim((string)($apiEnv['BOOTSTRAP_SHA256_WIN'] ?? ''))),
    'releaseDate' => (string)($apiEnv['BOOTSTRAP_RELEASE_DATE'] ?? ''),
];
if ($bootstrap['sha256'] !== '' && !preg_match('/^[a-f0-9]{64}$/', $bootstrap['sha256'])) {
    $bootstrap['sha256'] = '';
}
$hasBootstrap = ($bootstrap['url'] !== '');

header('Content-Type: text/html; charset=utf-8');
?>
<!doctype html>
<html lang="<?php echo reddaxe_e(reddaxe_current_lang()); ?>">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?php echo reddaxe_e(reddaxe_t('index.page_title', ['brand' => $cfg['brand']])); ?></title>
    <style>
        :root {
            --bg: #11151c;
            --card: #1b2430;
            --text: #ecf2ff;
            --muted: #b9c6dd;
            --accent: #f28f3b;
            --accent-2: #e84855;
            --ok: #4caf50;
            --border: #2f3f57;
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: "Trebuchet MS", "Segoe UI", sans-serif;
            color: var(--text);
            background: radial-gradient(circle at 20% 20%, #26364b, var(--bg) 56%);
        }
        .wrap {
            max-width: 1040px;
            margin: 0 auto;
            padding: 24px 16px 42px;
        }
        h1 {
            margin: 0 0 8px;
            font-size: 2rem;
            letter-spacing: .02em;
        }
        .lang-switch {
            display: inline-flex;
            gap: 0.4rem;
            margin: 0 0 14px;
        }
        .lang-switch a {
            color: #e6edff;
            text-decoration: none;
            font-size: 0.82rem;
            padding: 0.14rem 0.42rem;
            border-radius: 4px;
            border: 1px solid var(--border);
        }
        .lang-switch a.active {
            border-color: var(--accent);
            color: var(--accent);
        }
        p.lead {
            margin: 0 0 22px;
            color: var(--muted);
        }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 14px;
        }
        .card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 16px;
        }
        .card h2 {
            margin: 0 0 8px;
            font-size: 1.1rem;
        }
        .muted {
            color: var(--muted);
            font-size: .92rem;
        }
        .button-row {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 12px;
        }
        a.btn {
            display: inline-block;
            text-decoration: none;
            color: #111;
            background: var(--accent);
            border-radius: 8px;
            padding: 9px 12px;
            font-weight: 700;
        }
        a.btn.secondary {
            background: #c6d4eb;
        }
        a.btn.alert {
            background: var(--accent-2);
            color: #fff;
        }
        code.hash {
            display: block;
            margin-top: 8px;
            padding: 8px;
            border-radius: 8px;
            background: #0f1722;
            border: 1px solid var(--border);
            font-size: .78rem;
            overflow-wrap: anywhere;
        }
        .pill {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 999px;
            background: rgba(76, 175, 80, .15);
            border: 1px solid rgba(76, 175, 80, .5);
            color: #b6f5bf;
            font-size: .8rem;
            margin-left: 8px;
        }
        .warn {
            margin-top: 12px;
            padding: 9px 12px;
            border-radius: 8px;
            border: 1px solid #8f6738;
            background: #3a2c19;
            color: #ffd9a6;
            font-size: .88rem;
        }
        footer {
            margin-top: 26px;
            color: var(--muted);
            font-size: .85rem;
        }
    </style>
</head>
<body>
<div class="wrap">
    <div class="lang-switch">
        <?php foreach (reddaxe_supported_langs() as $lang): ?>
            <a class="<?php echo reddaxe_current_lang() === $lang ? 'active' : ''; ?>" href="<?php echo reddaxe_e(reddaxe_lang_switch_url($lang)); ?>">
                <?php echo reddaxe_e(reddaxe_t('common.lang.' . $lang)); ?>
            </a>
        <?php endforeach; ?>
    </div>

    <h1><?php echo reddaxe_e($cfg['brand']); ?> <span class="pill"><?php echo reddaxe_e(reddaxe_t('common.badge.precompile')); ?></span></h1>
    <p class="lead"><?php echo reddaxe_e(reddaxe_t('index.lead')); ?></p>

    <div class="grid">
        <section class="card">
            <h2><?php echo reddaxe_e(reddaxe_t('index.section.account.title')); ?></h2>
            <?php if ($isLoggedIn): ?>
                <p class="muted"><?php echo reddaxe_e(reddaxe_t('index.section.account.logged_as', ['name' => $loggedUserName, 'email' => $loggedUserEmail])); ?></p>
                <div class="button-row">
                    <a class="btn" href="/reddaxe/post-login.php"><?php echo reddaxe_e(reddaxe_t('index.section.account.dashboard')); ?></a>
                    <a class="btn secondary" href="/reddaxe/account-manage.php"><?php echo reddaxe_e(reddaxe_t('index.section.account.manage')); ?></a>
                    <a class="btn alert" href="/reddaxe/logout.php"><?php echo reddaxe_e(reddaxe_t('common.nav.logout')); ?></a>
                </div>
            <?php else: ?>
                <p class="muted"><?php echo reddaxe_e(reddaxe_t('index.section.account.text')); ?></p>
                <div class="button-row">
                    <a class="btn" href="<?php echo reddaxe_e($cfg['accountCreateUrl']); ?>"><?php echo reddaxe_e(reddaxe_t('index.section.account.create')); ?></a>
                    <a class="btn secondary" href="<?php echo reddaxe_e($cfg['accountLoginUrl']); ?>"><?php echo reddaxe_e(reddaxe_t('index.section.account.login')); ?></a>
                </div>
            <?php endif; ?>
        </section>

        <section class="card">
            <h2><?php echo reddaxe_e(reddaxe_t('index.section.launcher.title')); ?></h2>
            <p class="muted">
                <?php echo reddaxe_e(reddaxe_t('index.section.launcher.version')); ?>: <strong><?php echo reddaxe_e($artifact['version']); ?></strong><br>
                <?php echo reddaxe_e(reddaxe_t('index.section.launcher.date')); ?>: <strong><?php echo reddaxe_e($artifact['releaseDate']); ?></strong>
            </p>
            <?php if ($hasBootstrap): ?>
                <p class="muted" style="margin-top:8px; font-size:.85rem;">
                    <?php echo reddaxe_e(reddaxe_t('index.section.launcher.bootstrap_info')); ?>
                </p>
                <div class="button-row">
                    <a class="btn" href="<?php echo reddaxe_e($bootstrap['url']); ?>"><?php echo reddaxe_e(reddaxe_t('index.section.launcher.download_bootstrap')); ?></a>
                    <a class="btn secondary" href="<?php echo reddaxe_e($artifact['url']); ?>"><?php echo reddaxe_e(reddaxe_t('index.section.launcher.portable')); ?></a>
                </div>
                <?php if ($bootstrap['sha256'] !== ''): ?>
                    <code class="hash">sha256 (bootstrap): <?php echo reddaxe_e($bootstrap['sha256']); ?></code>
                <?php endif; ?>
            <?php else: ?>
                <div class="button-row">
                    <a class="btn" href="<?php echo reddaxe_e($artifact['url']); ?>"><?php echo reddaxe_e(reddaxe_t('index.section.launcher.download')); ?></a>
                    <a class="btn secondary" href="<?php echo reddaxe_e($artifact['fallbackUrl']); ?>"><?php echo reddaxe_e(reddaxe_t('index.section.launcher.fallback')); ?></a>
                </div>
            <?php endif; ?>
            <?php if ($artifact['sha256'] !== ''): ?>
                <code class="hash">sha256: <?php echo reddaxe_e($artifact['sha256']); ?></code>
            <?php endif; ?>
        </section>

        <section class="card">
            <h2><?php echo reddaxe_e(reddaxe_t('index.section.nav.title')); ?></h2>
            <p class="muted"><?php echo reddaxe_e(reddaxe_t('index.section.nav.text')); ?></p>
            <div class="button-row">
                <a class="btn secondary" href="go.php?to=www"><?php echo reddaxe_e(reddaxe_t('index.section.nav.www')); ?></a>
                <a class="btn secondary" href="go.php?to=forum"><?php echo reddaxe_e(reddaxe_t('index.section.nav.forum')); ?></a>
                <a class="btn secondary" href="go.php?to=wiki"><?php echo reddaxe_e(reddaxe_t('index.section.nav.wiki')); ?></a>
                <a class="btn alert" href="go.php?to=external-discord"><?php echo reddaxe_e(reddaxe_t('index.section.nav.discord')); ?></a>
            </div>
        </section>
    </div>

    <?php if ($catalogErrorKey !== ''): ?>
        <div class="warn"><?php echo reddaxe_e(reddaxe_t($catalogErrorKey)); ?></div>
    <?php endif; ?>

    <footer>
        <?php echo reddaxe_e(reddaxe_t('index.footer.catalog_api')); ?>: <code><?php echo reddaxe_e($cfg['installerCatalogApiUrl']); ?></code>
    </footer>
</div>
</body>
</html>
