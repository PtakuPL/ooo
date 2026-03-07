<?php
/**
 * RedDAXE.pl — landing page (H1: IA portalu).
 * Punkt wejscia: download, konto, WWW gry, forum, wiki, linki zewnetrzne.
 */
declare(strict_types=1);
require_once __DIR__ . '/config.php';
?>
<!DOCTYPE html>
<html lang="<?= htmlspecialchars(portalCurrentLang()) ?>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars(portalT('common.site_title')) ?></title>
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
    <div class="hero">
        <h1><?= htmlspecialchars(portalT('index.hero.title', ['brand' => PORTAL_SITE_NAME])) ?></h1>
        <p><?= htmlspecialchars(portalT('index.hero.subtitle')) ?></p>
    </div>

    <div class="cards">
        <div class="card">
            <h3>&#128229; <?= htmlspecialchars(portalT('index.card.download.title')) ?></h3>
            <p><?= htmlspecialchars(portalT('index.card.download.text')) ?></p>
            <a href="/portal/download.php" class="card-action"><?= htmlspecialchars(portalT('index.card.download.action')) ?></a>
        </div>

        <div class="card">
            <h3>&#128100; <?= htmlspecialchars(portalT('index.card.account.title')) ?></h3>
            <p><?= htmlspecialchars(portalT('index.card.account.text')) ?></p>
            <a href="/portal/account_create.php" class="card-action"><?= htmlspecialchars(portalT('index.card.account.action')) ?></a>
        </div>

        <div class="card">
            <h3>&#127760; <?= htmlspecialchars(portalT('index.card.www.title')) ?></h3>
            <p><?= htmlspecialchars(portalT('index.card.www.text')) ?></p>
            <a href="/portal/go/redirect.php?target=www" class="card-action"><?= htmlspecialchars(portalT('index.card.www.action')) ?></a>
        </div>

        <div class="card">
            <h3>&#128172; <?= htmlspecialchars(portalT('index.card.forum.title')) ?></h3>
            <p><?= htmlspecialchars(portalT('index.card.forum.text')) ?></p>
            <a href="/portal/go/redirect.php?target=forum" class="card-action"><?= htmlspecialchars(portalT('index.card.forum.action')) ?></a>
        </div>

        <div class="card">
            <h3>&#128214; <?= htmlspecialchars(portalT('index.card.wiki.title')) ?></h3>
            <p><?= htmlspecialchars(portalT('index.card.wiki.text')) ?></p>
            <a href="/portal/go/redirect.php?target=wiki" class="card-action"><?= htmlspecialchars(portalT('index.card.wiki.action')) ?></a>
        </div>

        <div class="card">
            <h3>&#128279; <?= htmlspecialchars(portalT('index.card.external.title')) ?></h3>
            <p><?= htmlspecialchars(portalT('index.card.external.text')) ?></p>
            <?php foreach (EXTERNAL_LINKS as $slug => $info): ?>
            <a href="/portal/go/redirect.php?target=external&slug=<?= htmlspecialchars($slug) ?>" class="card-action"><?= htmlspecialchars($info['label']) ?></a><br>
            <?php endforeach; ?>
        </div>
    </div>
</main>

<footer>
    <?= portalT('common.footer', ['year' => date('Y'), 'brand' => PORTAL_SITE_NAME, 'version' => PORTAL_VERSION]) ?>
</footer>
</body>
</html>
