<?php
/**
 * RedDAXE.pl — strona download launchera (H2).
 * Dane pobierane z installer-catalog.php (ten sam backend).
 */
declare(strict_types=1);
require_once __DIR__ . '/config.php';

// Pobierz dane z installer-catalog bezposrednio (wspolny serwer)
$catalogPath = __DIR__ . '/../apik/v1/installer-catalog.php';
$catalog     = null;
$catalogError = '';

if (is_file($catalogPath)) {
    // Wywolaj przez wewnetrzny HTTP (ten sam serwer) aby uzyskac odpowiedz JSON
    $host = $_SERVER['HTTP_HOST'] ?? '127.0.0.1';
    $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
    $catalogUrl = $scheme . '://' . $host . '/apik/v1/installer-catalog.php?type=all';
    $ctx = stream_context_create([
        'ssl' => ['verify_peer' => false, 'verify_peer_name' => false],
        'http' => ['timeout' => 5],
    ]);
    $json = @file_get_contents($catalogUrl, false, $ctx);
    if ($json !== false) {
        $catalog = json_decode($json, true);
    }
}

// Fallback: odczytaj .env bezposrednio
if ($catalog === null || !is_array($catalog)) {
    $envPath = __DIR__ . '/../apik/v1/.env';
    if (is_file($envPath)) {
        $lines = file($envPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        $e = [];
        foreach ($lines as $ln) {
            $ln = trim($ln);
            if ($ln === '' || $ln[0] === '#') continue;
            $eq = strpos($ln, '=');
            if ($eq === false) continue;
            $k = trim(substr($ln, 0, $eq));
            $v = trim(substr($ln, $eq + 1));
            if ((str_starts_with($v, '"') && str_ends_with($v, '"')) ||
                (str_starts_with($v, "'") && str_ends_with($v, "'"))) {
                $v = substr($v, 1, -1);
            }
            $e[$k] = $v;
        }
        $catalog = [
            'brand'     => $e['REDDAXE_BRAND'] ?? 'RedDAXE.pl',
            'artifacts' => [[
                'name'        => 'Launcher',
                'version'     => $e['LAUNCHER_VERSION'] ?? '1.0.0',
                'url'         => $e['LAUNCHER_DOWNLOAD_URL'] ?? '',
                'sha256'      => $e['LAUNCHER_SHA256'] ?? '',
                'releaseDate' => $e['LAUNCHER_RELEASE_DATE'] ?? date('Y-m-d'),
                'notes'       => $e['LAUNCHER_NOTES'] ?? '',
                'fallbackUrl' => $e['REDDAXE_LAUNCHER_FALLBACK_URL'] ?? '',
            ]],
        ];
        // Bootstrap artifact from .env fallback
        $bsUrl = $e['BOOTSTRAP_DOWNLOAD_URL_WIN'] ?? '';
        if ($bsUrl !== '') {
            $catalog['bootstrap'] = [
                'version'     => $e['BOOTSTRAP_VERSION'] ?? '1.0.0',
                'url'         => $bsUrl,
                'sha256'      => $e['BOOTSTRAP_SHA256_WIN'] ?? '',
                'releaseDate' => $e['BOOTSTRAP_RELEASE_DATE'] ?? date('Y-m-d'),
                'notes'       => $e['BOOTSTRAP_NOTES'] ?? '',
            ];
        }
    }
}

// Try to find bootstrap artifact from catalog response
$bootstrap = $catalog['bootstrap'] ?? null;
if ($bootstrap === null && is_array($catalog['artifacts'] ?? null)) {
    foreach ($catalog['artifacts'] as $a) {
        if (($a['type'] ?? '') === 'bootstrap' && ($a['platform'] ?? '') === 'windows') {
            $bootstrap = $a;
            break;
        }
    }
}

$artifact = $catalog['artifacts'][0] ?? null;
?>
<!DOCTYPE html>
<html lang="<?= htmlspecialchars(portalCurrentLang()) ?>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars(portalT('download.title')) ?> &mdash; <?= htmlspecialchars(PORTAL_SITE_NAME) ?></title>
    <link rel="stylesheet" href="assets/css/portal.css">
</head>
<body>
<header>
    <div class="logo"><?= htmlspecialchars(PORTAL_SITE_NAME) ?></div>
    <nav>
        <a href="/portal/"><?= htmlspecialchars(portalT('common.nav.start')) ?></a>
        <a href="/portal/download.php"><?= htmlspecialchars(portalT('common.nav.download')) ?></a>
        <a href="/portal/account_login.php"><?= htmlspecialchars(portalT('common.nav.login')) ?></a>
        <a href="/portal/account_create.php"><?= htmlspecialchars(portalT('common.nav.register')) ?></a>
        <span class="lang-switch">
            <?php foreach (portalSupportedLangs() as $lang): ?>
                <a class="<?= portalCurrentLang() === $lang ? 'active' : '' ?>" href="<?= htmlspecialchars(portalLangSwitchUrl($lang)) ?>"><?= htmlspecialchars(portalT('common.lang.' . $lang)) ?></a>
            <?php endforeach; ?>
        </span>
    </nav>
</header>

<main>
    <h2 style="margin-bottom:1.5rem;"><?= htmlspecialchars(portalT('download.heading')) ?></h2>

    <?php if ($bootstrap && !empty($bootstrap['url'])): ?>
    <!-- BL-20/BL-23: Bootstrap launcher jako główny przycisk -->
    <div class="download-box">
        <h3><?= htmlspecialchars(portalT('download.action.download_bootstrap')) ?></h3>
        <p style="color:var(--text-muted); margin-top:0.5rem;">
            <?= htmlspecialchars(portalT('download.bootstrap.info')) ?>
        </p>
        <p class="version"><?= htmlspecialchars(portalT('download.version')) ?>: <strong><?= htmlspecialchars($bootstrap['version'] ?? '-') ?></strong>
        &nbsp;&bull;&nbsp; <?= htmlspecialchars(portalT('download.date')) ?>: <?= htmlspecialchars($bootstrap['releaseDate'] ?? '-') ?></p>

        <a href="<?= htmlspecialchars($bootstrap['url']) ?>" class="btn" style="margin-top:1.5rem;">
            &#11015; <?= htmlspecialchars(portalT('download.action.download_bootstrap')) ?>
        </a>

        <?php if (!empty($bootstrap['sha256'])): ?>
            <p class="checksum"><?= htmlspecialchars(portalT('download.sha')) ?>: <code><?= htmlspecialchars($bootstrap['sha256']) ?></code></p>
        <?php endif; ?>
    </div>
    <?php endif; ?>

    <?php if ($artifact): ?>
    <!-- BL-21: Pełny launcher (portable) -->
    <div class="download-box" style="margin-top:1.5rem;<?= $bootstrap ? ' opacity:0.85;' : '' ?>">
        <h3><?= htmlspecialchars($artifact['name'] ?? 'Launcher') ?><?= $bootstrap ? ' — ' . htmlspecialchars(portalT('download.portable.label')) : '' ?></h3>
        <?php if ($bootstrap): ?>
            <p style="color:var(--text-muted); margin-top:0.5rem; font-size:0.9rem;">
                <?= htmlspecialchars(portalT('download.portable.text')) ?>
            </p>
        <?php endif; ?>
        <p class="version"><?= htmlspecialchars(portalT('download.version')) ?>: <strong><?= htmlspecialchars($artifact['version'] ?? '-') ?></strong>
        &nbsp;&bull;&nbsp; <?= htmlspecialchars(portalT('download.date')) ?>: <?= htmlspecialchars($artifact['releaseDate'] ?? '-') ?></p>

        <?php if (!empty($artifact['notes'])): ?>
            <p style="color:var(--text-muted); margin-top:0.5rem;"><?= htmlspecialchars($artifact['notes']) ?></p>
        <?php endif; ?>

        <?php if (!empty($artifact['url']) && $artifact['url'] !== '/downloads'): ?>
            <a href="<?= htmlspecialchars($artifact['url']) ?>" class="btn<?= $bootstrap ? ' secondary' : '' ?>" style="margin-top:1.5rem;">
                &#11015; <?= htmlspecialchars(portalT('download.action.download')) ?>
            </a>
        <?php else: ?>
            <p style="margin-top:1.5rem; color:var(--text-muted);">
                <?= htmlspecialchars(portalT('download.message.unpublished')) ?>
            </p>
        <?php endif; ?>

        <?php if (!empty($artifact['sha256'])): ?>
            <p class="checksum"><?= htmlspecialchars(portalT('download.sha')) ?>: <code><?= htmlspecialchars($artifact['sha256']) ?></code></p>
        <?php endif; ?>

        <?php if (!empty($artifact['fallbackUrl']) && $artifact['fallbackUrl'] !== '/downloads' && $artifact['fallbackUrl'] !== ($artifact['url'] ?? '')): ?>
            <p style="margin-top:0.5rem; font-size:0.85rem; color:var(--text-muted);">
                <?= htmlspecialchars(portalT('download.fallback_prefix')) ?>: <a href="<?= htmlspecialchars($artifact['fallbackUrl']) ?>"><?= htmlspecialchars(portalT('download.fallback_action')) ?></a>
            </p>
        <?php endif; ?>
    </div>
    <?php else: ?>
        <div class="alert alert-error"><?= htmlspecialchars(portalT('download.error.catalog')) ?></div>
    <?php endif; ?>

    <div style="margin-top:2rem; color:var(--text-muted); font-size:0.9rem;">
        <h4><?= htmlspecialchars(portalT('download.how.title')) ?></h4>
        <ol style="padding-left:1.5rem; margin-top:0.5rem;">
            <li><?= htmlspecialchars(portalT('download.how.step1')) ?></li>
            <li><?= htmlspecialchars(portalT('download.how.step2')) ?></li>
            <li><?= htmlspecialchars(portalT('download.how.step3')) ?></li>
            <li><?= htmlspecialchars(portalT('download.how.step4')) ?></li>
        </ol>
    </div>
</main>

<footer>
    <?= portalT('common.footer', ['year' => date('Y'), 'brand' => PORTAL_SITE_NAME, 'version' => PORTAL_VERSION]) ?>
</footer>
</body>
</html>
