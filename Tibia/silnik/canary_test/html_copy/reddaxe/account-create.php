<?php
declare(strict_types=1);

require_once __DIR__ . '/bootstrap.php';

$cfg = reddaxe_build_config();

$errors = [];
$successMessage = '';
$createdAccountName = '';
$createdEmail = '';

$accountName = trim((string)($_POST['accountName'] ?? ''));
$email = strtolower(trim((string)($_POST['email'] ?? '')));
$password = (string)($_POST['password'] ?? '');
$passwordConfirm = (string)($_POST['passwordConfirm'] ?? '');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!preg_match('/^[A-Za-z0-9_]{3,32}$/', $accountName)) {
        $errors[] = reddaxe_t('account_create.error.invalid_account_name');
    }
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errors[] = reddaxe_t('account_create.error.invalid_email');
    }
    if (strlen($password) < 6 || strlen($password) > 72) {
        $errors[] = reddaxe_t('account_create.error.invalid_password_length');
    }
    if (!hash_equals($password, $passwordConfirm)) {
        $errors[] = reddaxe_t('account_create.error.password_mismatch');
    }

    if ($errors === []) {
        $httpCode = 0;
        $apiCall = reddaxe_post_json(
            $cfg['registerApiPath'] ?? '/apik/v1/register-account.php',
            [
                'type' => 'register',
                'accountName' => $accountName,
                'email' => $email,
                'password' => $password,
                'passwordConfirm' => $passwordConfirm,
            ],
            $httpCode
        );

        if (($apiCall['ok'] ?? false) !== true) {
            $errors[] = '[' . reddaxe_t('account_create.error.api_unreachable') . '] ' . (string)($apiCall['message'] ?? 'Cannot contact API.');
        } else {
            $apiResult = (array)($apiCall['data'] ?? []);
        }

        if (($apiCall['ok'] ?? false) === true && ($apiResult['ok'] ?? false) === true) {
            $createdAccountName = (string)($apiResult['accountName'] ?? $accountName);
            $createdEmail = (string)($apiResult['email'] ?? $email);
            $successMessage = reddaxe_t('account_create.success.created');
            if (!empty($apiResult['emailVerificationSent'])) {
                $successMessage .= ' ' . reddaxe_t('account_create.success.check_email');
            }
            $password = '';
            $passwordConfirm = '';
        } elseif (($apiCall['ok'] ?? false) === true) {
            $code = (string)($apiResult['error'] ?? 'register_failed');
            $msg = (string)($apiResult['message'] ?? 'Nie mozna utworzyc konta.');
            $errors[] = '[' . $code . '] ' . $msg . ' (HTTP ' . $httpCode . ')';
        }
    }
}

header('Content-Type: text/html; charset=utf-8');
?>
<!doctype html>
<html lang="<?php echo reddaxe_e(reddaxe_current_lang()); ?>">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?php echo reddaxe_e(reddaxe_t('account_create.page_title', ['brand' => $cfg['brand']])); ?></title>
    <style>
        body { margin: 0; font-family: "Trebuchet MS", "Segoe UI", sans-serif; background: #11151c; color: #ecf2ff; }
        .wrap { max-width: 720px; margin: 0 auto; padding: 24px 16px 40px; }
        .card { background: #1b2430; border: 1px solid #2f3f57; border-radius: 12px; padding: 16px; }
        h1 { margin: 0 0 14px; font-size: 1.7rem; }
        p { margin: 0 0 12px; color: #b9c6dd; }
        label { display: block; margin: 10px 0 6px; font-size: .9rem; color: #d8e1f1; }
        input { width: 100%; border-radius: 8px; border: 1px solid #3d4f6c; background: #0f1722; color: #ecf2ff; padding: 10px; }
        .row { display: grid; gap: 10px; grid-template-columns: 1fr 1fr; }
        .btns { display: flex; gap: 10px; margin-top: 14px; flex-wrap: wrap; }
        button, a.btn { border: 0; border-radius: 8px; padding: 10px 14px; font-weight: 700; text-decoration: none; }
        button { background: #f28f3b; color: #111; cursor: pointer; }
        a.btn { background: #c6d4eb; color: #111; }
        .err { margin: 0 0 10px; padding: 8px 10px; border-radius: 8px; border: 1px solid #8c3b3b; background: #3a1f1f; color: #ffc4c4; }
        .ok { margin: 0 0 10px; padding: 8px 10px; border-radius: 8px; border: 1px solid #2f7b3a; background: #193322; color: #c7ffd2; }
        code { display: block; background: #0f1722; border: 1px solid #2f3f57; border-radius: 8px; padding: 8px; margin-top: 8px; }
        .topnav { margin-bottom: 12px; }
        .topnav a { color: #ffd9a6; text-decoration: none; }
        .lang-switch { display: inline-flex; gap: 0.38rem; margin-left: 0.5rem; }
        .lang-switch a { color: #e6edff; text-decoration: none; font-size: 0.8rem; border: 1px solid #2f3f57; border-radius: 4px; padding: 0.1rem 0.34rem; }
        .lang-switch a.active { border-color: #f28f3b; color: #f28f3b; }
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
        <h1><?php echo reddaxe_e(reddaxe_t('account_create.heading')); ?></h1>
        <p><?php echo reddaxe_e(reddaxe_t('account_create.intro')); ?></p>

        <?php foreach ($errors as $error): ?>
            <div class="err"><?php echo reddaxe_e($error); ?></div>
        <?php endforeach; ?>

        <?php if ($successMessage !== ''): ?>
            <div class="ok"><?php echo reddaxe_e($successMessage); ?></div>
            <code><?php echo reddaxe_e(reddaxe_t('account_create.success.account_prefix')); ?>: <?php echo reddaxe_e($createdAccountName); ?> | <?php echo reddaxe_e(reddaxe_t('account_create.success.email_prefix')); ?>: <?php echo reddaxe_e($createdEmail); ?></code>
            <div class="btns">
                <a class="btn" href="/reddaxe/account-login.php?email=<?php echo urlencode($createdEmail); ?>"><?php echo reddaxe_e(reddaxe_t('account_create.success.go_login')); ?></a>
                <a class="btn" href="/reddaxe/index.php"><?php echo reddaxe_e(reddaxe_t('account_create.success.back_portal')); ?></a>
            </div>
        <?php else: ?>
            <form method="post" action="/reddaxe/account-create.php">
                <label for="accountName"><?php echo reddaxe_e(reddaxe_t('account_create.form.account_name')); ?></label>
                <input id="accountName" name="accountName" value="<?php echo reddaxe_e($accountName); ?>" required minlength="3" maxlength="32" pattern="[A-Za-z0-9_]{3,32}">

                <label for="email"><?php echo reddaxe_e(reddaxe_t('account_create.form.email')); ?></label>
                <input id="email" name="email" type="email" value="<?php echo reddaxe_e($email); ?>" required>

                <div class="row">
                    <div>
                        <label for="password"><?php echo reddaxe_e(reddaxe_t('account_create.form.password')); ?></label>
                        <input id="password" name="password" type="password" required minlength="6" maxlength="72">
                    </div>
                    <div>
                        <label for="passwordConfirm"><?php echo reddaxe_e(reddaxe_t('account_create.form.password_confirm')); ?></label>
                        <input id="passwordConfirm" name="passwordConfirm" type="password" required minlength="6" maxlength="72">
                    </div>
                </div>

                <div class="btns">
                    <button type="submit"><?php echo reddaxe_e(reddaxe_t('account_create.form.submit')); ?></button>
                    <a class="btn" href="/reddaxe/account-login.php"><?php echo reddaxe_e(reddaxe_t('account_create.form.have_account')); ?></a>
                </div>
            </form>
        <?php endif; ?>
    </div>
</div>
</body>
</html>
