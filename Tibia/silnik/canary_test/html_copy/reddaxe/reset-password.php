<?php
declare(strict_types=1);

require_once __DIR__ . '/bootstrap.php';

$cfg = reddaxe_build_config();

$token = trim((string)($_GET['token'] ?? $_POST['token'] ?? ''));
$errors = [];
$successMessage = '';
$showForm = false;

// Mode A: no token → show "request reset" form
// Mode B: valid token → show "set new password" form
$mode = ($token !== '') ? 'reset' : 'request';

if ($mode === 'request' && $_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action_request'])) {
    $email = strtolower(trim((string)($_POST['email'] ?? '')));
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errors[] = reddaxe_t('reset_password.error.invalid_email');
    }

    if ($errors === []) {
        $httpCode = 0;
        reddaxe_post_json('/apik/v1/request-password-reset.php', [
            'type' => 'request_password_reset',
            'email' => $email,
        ], $httpCode);
        // Always show success to prevent email enumeration
        $successMessage = reddaxe_t('reset_password.success.email_sent');
    }
}

if ($mode === 'reset') {
    if (!preg_match('/^[a-f0-9]{64}$/i', $token)) {
        $errors[] = reddaxe_t('reset_password.error.invalid_token');
    } else {
        $showForm = true;
    }

    if ($showForm && $_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action_reset'])) {
        $newPassword = (string)($_POST['new_password'] ?? '');
        $newPasswordConfirm = (string)($_POST['new_password_confirm'] ?? '');

        if (strlen($newPassword) < 6 || strlen($newPassword) > 72) {
            $errors[] = reddaxe_t('reset_password.error.password_length');
        }
        if (!hash_equals($newPassword, $newPasswordConfirm)) {
            $errors[] = reddaxe_t('reset_password.error.password_mismatch');
        }

        if ($errors === []) {
            $httpCode = 0;
            $result = reddaxe_post_json('/apik/v1/reset-password.php', [
                'type' => 'reset_password',
                'token' => $token,
                'newPassword' => $newPassword,
                'newPasswordConfirm' => $newPasswordConfirm,
            ], $httpCode);

            if (($result['ok'] ?? false) === true) {
                $data = (array)($result['data'] ?? []);
                if (($data['ok'] ?? false) === true) {
                    $successMessage = reddaxe_t('reset_password.success.password_reset');
                    $showForm = false;
                } else {
                    $errors[] = (string)($data['message'] ?? reddaxe_t('reset_password.error.reset_failed'));
                }
            } else {
                $errors[] = reddaxe_t('reset_password.error.api_unreachable');
            }
        }
    }
}

session_write_close();

header('Content-Type: text/html; charset=utf-8');
?>
<!doctype html>
<html lang="<?php echo reddaxe_e(reddaxe_current_lang()); ?>">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?php echo reddaxe_e(reddaxe_t('reset_password.page_title', ['brand' => $cfg['brand']])); ?></title>
    <style>
        body { margin: 0; font-family: "Trebuchet MS", "Segoe UI", sans-serif; background: #11151c; color: #ecf2ff; }
        .wrap { max-width: 480px; margin: 0 auto; padding: 40px 16px; }
        .topnav { display: flex; align-items: center; gap: 12px; margin-bottom: 20px; }
        .topnav a { color: #b9c6dd; text-decoration: none; }
        .topnav a:hover { color: #ecf2ff; }
        .card { background: #1b2430; border: 1px solid #2f3f57; border-radius: 12px; padding: 20px; }
        h2 { margin: 0 0 14px; font-size: 1.4rem; color: #f28f3b; }
        p { margin: 0 0 12px; color: #b9c6dd; }
        label { display: block; margin: 10px 0 6px; font-size: .9rem; color: #d8e1f1; }
        input { width: 100%; border-radius: 8px; border: 1px solid #3d4f6c; background: #0f1722; color: #ecf2ff; padding: 10px; box-sizing: border-box; }
        .btns { display: flex; gap: 10px; margin-top: 14px; flex-wrap: wrap; }
        button { border: 0; border-radius: 8px; padding: 10px 14px; font-weight: 700; background: #f28f3b; color: #111; cursor: pointer; }
        a.btn { border-radius: 8px; padding: 10px 14px; font-weight: 700; text-decoration: none; display: inline-block; background: #2f3f57; color: #ecf2ff; }
        .err { margin: 0 0 10px; padding: 8px 10px; border-radius: 8px; border: 1px solid #8c3b3b; background: #3a1f1f; color: #ffc4c4; }
        .ok { margin: 0 0 10px; padding: 8px 10px; border-radius: 8px; border: 1px solid #2f7a40; background: #1a3b24; color: #b3ffc4; }
    </style>
</head>
<body>
<div class="wrap">
    <div class="topnav">
        <a href="/reddaxe/"><?php echo reddaxe_e(reddaxe_t('common.nav.back_frontdoor')); ?></a>
    </div>

    <?php foreach ($errors as $error): ?>
        <div class="err"><?php echo reddaxe_e($error); ?></div>
    <?php endforeach; ?>
    <?php if ($successMessage !== ''): ?>
        <div class="ok"><?php echo reddaxe_e($successMessage); ?></div>
    <?php endif; ?>

    <?php if ($mode === 'request' && $successMessage === ''): ?>
    <div class="card">
        <h2><?php echo reddaxe_e(reddaxe_t('reset_password.heading_request')); ?></h2>
        <p><?php echo reddaxe_e(reddaxe_t('reset_password.intro_request')); ?></p>
        <form method="post" action="/reddaxe/reset-password.php">
            <input type="hidden" name="action_request" value="1">

            <label for="email"><?php echo reddaxe_e(reddaxe_t('reset_password.form.email')); ?></label>
            <input id="email" name="email" type="email" required>

            <div class="btns">
                <button type="submit"><?php echo reddaxe_e(reddaxe_t('reset_password.form.submit_request')); ?></button>
                <a class="btn" href="/reddaxe/account-login.php"><?php echo reddaxe_e(reddaxe_t('reset_password.btn.back_login')); ?></a>
            </div>
        </form>
    </div>
    <?php endif; ?>

    <?php if ($mode === 'reset' && $showForm): ?>
    <div class="card">
        <h2><?php echo reddaxe_e(reddaxe_t('reset_password.heading_reset')); ?></h2>
        <form method="post" action="/reddaxe/reset-password.php">
            <input type="hidden" name="action_reset" value="1">
            <input type="hidden" name="token" value="<?php echo reddaxe_e($token); ?>">

            <label for="new_password"><?php echo reddaxe_e(reddaxe_t('reset_password.form.new_password')); ?></label>
            <input id="new_password" name="new_password" type="password" required minlength="6" maxlength="72" autocomplete="new-password">

            <label for="new_password_confirm"><?php echo reddaxe_e(reddaxe_t('reset_password.form.confirm_password')); ?></label>
            <input id="new_password_confirm" name="new_password_confirm" type="password" required autocomplete="new-password">

            <div class="btns">
                <button type="submit"><?php echo reddaxe_e(reddaxe_t('reset_password.form.submit_reset')); ?></button>
            </div>
        </form>
    </div>
    <?php endif; ?>

    <?php if ($successMessage !== '' && $mode === 'reset'): ?>
    <div class="btns" style="margin-top:14px">
        <a class="btn" href="/reddaxe/account-login.php"><?php echo reddaxe_e(reddaxe_t('reset_password.btn.go_login')); ?></a>
    </div>
    <?php endif; ?>
</div>
</body>
</html>
