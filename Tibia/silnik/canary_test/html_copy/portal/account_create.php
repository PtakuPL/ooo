<?php
/**
 * RedDAXE.pl — rejestracja konta (H3).
 * Uzywa tego samego backendu co API launchera (register-account.php).
 */
declare(strict_types=1);
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/../apik/v1/register-account-lib.php';

$error   = '';
$success = '';
$accountName = '';
$email = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!portalCsrfCheck()) {
        $error = portalT('account_create.error.csrf');
    } else {
        $accountName     = trim((string)($_POST['accountName'] ?? ''));
        $email           = strtolower(trim((string)($_POST['email'] ?? '')));
        $password        = $_POST['password'] ?? '';
        $passwordConfirm = $_POST['passwordConfirm'] ?? '';

        // walidacja front
        if (!preg_match('/^[A-Za-z0-9_]{3,32}$/', $accountName)) {
            $error = portalT('account_create.error.invalid_account_name');
        } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $error = portalT('account_create.error.invalid_email');
        } elseif (strlen($password) < 6 || strlen($password) > 72) {
            $error = portalT('account_create.error.invalid_password_length');
        } elseif ($password !== $passwordConfirm) {
            $error = portalT('account_create.error.password_mismatch');
        }

        if ($error === '') {
            $result = register_account_shared([
                'accountName' => $accountName,
                'email' => $email,
                'password' => $password,
                'passwordConfirm' => $passwordConfirm,
            ]);

            if (!($result['ok'] ?? false)) {
                $errorCode = (string)($result['error'] ?? '');
                if ($errorCode === 'account_exists') {
                    $error = portalT('account_create.error.account_exists');
                } elseif ($errorCode === 'email_exists') {
                    $error = portalT('account_create.error.email_exists');
                } elseif ($errorCode === 'password_mismatch') {
                    $error = portalT('account_create.error.password_mismatch');
                } elseif ($errorCode === 'invalid_account_name') {
                    $error = portalT('account_create.error.invalid_account_name');
                } elseif ($errorCode === 'invalid_email') {
                    $error = portalT('account_create.error.invalid_email');
                } elseif ($errorCode === 'invalid_password_length') {
                    $error = portalT('account_create.error.invalid_password_length');
                } else {
                    error_log('Portal register-account-lib error: ' . $errorCode);
                    $error = portalT('account_create.error.server');
                }
            } else {
                $success = portalT('account_create.success.created');
            }
        }
    }
}

$csrf = portalCsrfToken();
?>
<!DOCTYPE html>
<html lang="<?= htmlspecialchars(portalCurrentLang()) ?>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars(portalT('account_create.title')) ?> &mdash; <?= htmlspecialchars(PORTAL_SITE_NAME) ?></title>
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
    <h2 style="margin-bottom:1rem;"><?= htmlspecialchars(portalT('account_create.heading')) ?></h2>

    <?php if ($error): ?>
        <div class="alert alert-error"><?= htmlspecialchars($error) ?></div>
    <?php endif; ?>
    <?php if ($success): ?>
        <div class="alert alert-success"><?= htmlspecialchars($success) ?> <a href="/portal/account_login.php"><?= htmlspecialchars(portalT('account_create.action.login')) ?> &rarr;</a></div>
    <?php else: ?>

    <form method="POST" action="" style="max-width:400px;">
        <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($csrf) ?>">
        <p style="margin-bottom:0.75rem; color:var(--text-muted);">
            <?= htmlspecialchars(portalT('account_create.shared_hint')) ?>
        </p>
        <div class="form-group">
            <label for="accountName"><?= htmlspecialchars(portalT('account_create.label.account_name')) ?></label>
            <input id="accountName" name="accountName" type="text" required minlength="3" maxlength="32"
                   pattern="[A-Za-z0-9_]{3,32}" value="<?= htmlspecialchars($accountName ?? '') ?>"
                   autocomplete="username">
        </div>
        <div class="form-group">
            <label for="email"><?= htmlspecialchars(portalT('account_create.label.email')) ?></label>
            <input id="email" name="email" type="email" required value="<?= htmlspecialchars($email ?? '') ?>"
                   autocomplete="email">
        </div>
        <div class="form-group">
            <label for="password"><?= htmlspecialchars(portalT('account_create.label.password')) ?></label>
            <input id="password" name="password" type="password" required minlength="6" maxlength="72"
                   autocomplete="new-password">
        </div>
        <div class="form-group">
            <label for="passwordConfirm"><?= htmlspecialchars(portalT('account_create.label.password_confirm')) ?></label>
            <input id="passwordConfirm" name="passwordConfirm" type="password" required minlength="6" maxlength="72"
                   autocomplete="new-password">
        </div>
        <button type="submit" class="btn"><?= htmlspecialchars(portalT('account_create.action.submit')) ?></button>
    </form>

    <p style="margin-top:1rem; color:var(--text-muted);"><?= htmlspecialchars(portalT('account_create.prompt.have_account')) ?> <a href="/portal/account_login.php"><?= htmlspecialchars(portalT('account_create.action.login')) ?></a></p>
    <?php endif; ?>
</main>

<footer>
    <?= portalT('common.footer', ['year' => date('Y'), 'brand' => PORTAL_SITE_NAME, 'version' => PORTAL_VERSION]) ?>
</footer>
</body>
</html>
