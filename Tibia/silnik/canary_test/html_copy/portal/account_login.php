<?php
/**
 * RedDAXE.pl — logowanie konta (H4).
 * Po poprawnym logowaniu tworzy sesje portalu.
 * Konto weryfikowane przez te same hasla co API/launcher (argon2/SHA1).
 */
declare(strict_types=1);
require_once __DIR__ . '/config.php';

$error   = '';
$success = '';
$login = '';

// Sprawdz czy juz zalogowany
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$loggedIn = !empty($_SESSION['portal_account_id']);

if ($_SERVER['REQUEST_METHOD'] === 'POST' && !$loggedIn) {
    if (!portalCsrfCheck()) {
        $error = portalT('account_login.error.csrf');
    } else {
        $login    = trim((string)($_POST['login'] ?? ''));
        $password = $_POST['password'] ?? '';
        $lookupBy = '';
        $lookupValue = '';

        if ($login === '') {
            $error = portalT('account_login.error.login_required');
        } elseif (filter_var($login, FILTER_VALIDATE_EMAIL)) {
            $lookupBy = 'email';
            $lookupValue = strtolower($login);
        } elseif (preg_match('/^[A-Za-z0-9_]{3,32}$/', $login)) {
            $lookupBy = 'name';
            $lookupValue = strtolower($login);
        } elseif (strlen($password) < 1) {
            $error = portalT('account_login.error.password_required');
        } else {
            $error = portalT('account_login.error.invalid_login');
        }

        if ($error === '' && strlen($password) < 1) {
            $error = portalT('account_login.error.password_required');
        }

        if ($error === '') {
            $db   = portalDb();
            if ($lookupBy === 'email') {
                $stmt = $db->prepare('SELECT id, name, password, engine_password_sha1 FROM accounts WHERE LOWER(email) = :login LIMIT 1');
            } else {
                $stmt = $db->prepare('SELECT id, name, password, engine_password_sha1 FROM accounts WHERE LOWER(name) = :login LIMIT 1');
            }
            $stmt->execute([':login' => $lookupValue]);
            $account = $stmt->fetch();

            if (!$account) {
                $error = portalT('account_login.error.credentials');
            } else {
                // Sprawdz haslo: argon2 (preferowane) lub SHA1 (kompatybilnosc)
                $valid = false;
                if (!empty($account['password']) && password_verify($password, $account['password'])) {
                    $valid = true;
                } elseif (!empty($account['engine_password_sha1']) && $account['engine_password_sha1'] === sha1($password)) {
                    $valid = true;
                    // upgrade do argon2
                    $newHash = password_hash($password, PASSWORD_ARGON2ID);
                    $upd = $db->prepare('UPDATE accounts SET password = :pw WHERE id = :id');
                    $upd->execute([':pw' => $newHash, ':id' => $account['id']]);
                }

                if (!$valid) {
                    $error = portalT('account_login.error.credentials');
                } else {
                    // Sesja portalu
                    session_regenerate_id(true);
                    $_SESSION['portal_account_id']   = (int)$account['id'];
                    $_SESSION['portal_account_name'] = $account['name'];
                    $_SESSION['portal_login_time']   = time();
                    $loggedIn = true;
                    $success  = portalT('account_login.success.logged_as', ['name' => (string)$account['name']]);
                }
            }
        }
    }
}

// Wylogowanie
if (isset($_GET['logout'])) {
    session_start();
    $_SESSION = [];
    session_destroy();
    header('Location: /portal/account_login.php');
    exit;
}

$csrf = portalCsrfToken();
?>
<!DOCTYPE html>
<html lang="<?= htmlspecialchars(portalCurrentLang()) ?>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars(portalT('account_login.title')) ?> &mdash; <?= htmlspecialchars(PORTAL_SITE_NAME) ?></title>
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
    <?php if ($loggedIn): ?>
        <h2 style="margin-bottom:1rem;"><?= htmlspecialchars(portalT('account_login.heading.panel')) ?></h2>
        <?php if ($success): ?>
            <div class="alert alert-success"><?= htmlspecialchars($success) ?></div>
        <?php endif; ?>
        <p><?= htmlspecialchars(portalT('account_login.logged_as')) ?>: <strong><?= htmlspecialchars($_SESSION['portal_account_name'] ?? '') ?></strong></p>
        <p style="color:var(--text-muted);"><?= htmlspecialchars(portalT('account_login.shared_hint')) ?></p>
        <div class="cards" style="margin-top:1.5rem;">
            <div class="card">
                <h3>&#9876; <?= htmlspecialchars(portalT('account_login.card.classic.title')) ?></h3>
                <p><?= htmlspecialchars(portalT('account_login.card.classic.text')) ?></p>
                <a href="/account/createcharacter?source=portal&mode=classic74" class="card-action"><?= htmlspecialchars(portalT('account_login.action.go')) ?></a>
            </div>
            <div class="card">
                <h3>&#128640; <?= htmlspecialchars(portalT('account_login.card.modern.title')) ?></h3>
                <p><?= htmlspecialchars(portalT('account_login.card.modern.text')) ?></p>
                <a href="/account/createcharacter?source=portal&mode=modern" class="card-action"><?= htmlspecialchars(portalT('account_login.action.go')) ?></a>
            </div>
        </div>
        <p style="margin-top:2rem;"><a href="/portal/account_login.php?logout=1" class="btn btn-outline"><?= htmlspecialchars(portalT('account_login.action.logout')) ?></a></p>
    <?php else: ?>
        <h2 style="margin-bottom:1rem;"><?= htmlspecialchars(portalT('account_login.heading.login')) ?></h2>
        <?php if ($error): ?>
            <div class="alert alert-error"><?= htmlspecialchars($error) ?></div>
        <?php endif; ?>

        <form method="POST" action="" style="max-width:400px;">
            <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($csrf) ?>">
            <div class="form-group">
                <label for="login"><?= htmlspecialchars(portalT('account_login.label.login')) ?></label>
                <input id="login" name="login" type="text" required value="<?= htmlspecialchars($login ?? '') ?>"
                       autocomplete="username">
            </div>
            <div class="form-group">
                <label for="password"><?= htmlspecialchars(portalT('account_login.label.password')) ?></label>
                <input id="password" name="password" type="password" required
                       autocomplete="current-password">
            </div>
            <button type="submit" class="btn"><?= htmlspecialchars(portalT('account_login.action.submit')) ?></button>
        </form>

        <p style="margin-top:1rem; color:var(--text-muted);"><?= htmlspecialchars(portalT('account_login.prompt.no_account')) ?> <a href="/portal/account_create.php"><?= htmlspecialchars(portalT('account_login.action.create')) ?></a></p>
    <?php endif; ?>
</main>

<footer>
    <?= portalT('common.footer', ['year' => date('Y'), 'brand' => PORTAL_SITE_NAME, 'version' => PORTAL_VERSION]) ?>
</footer>
</body>
</html>
