<?php
declare(strict_types=1);

require_once __DIR__ . '/bootstrap.php';

$cfg = reddaxe_build_config();

// Require active session
reddaxe_start_shared_session();
$sessionAccount = $_SESSION['account']['user'] ?? null;
$sessionKey = trim((string)($_SESSION['account']['sessionKey'] ?? ''));
$isLoggedIn = is_array($sessionAccount) && (int)($sessionAccount['id'] ?? 0) > 0 && $sessionKey !== '';

if (!$isLoggedIn) {
    header('Location: /reddaxe/account-login.php', true, 302);
    exit;
}

$accountName = trim((string)($sessionAccount['name'] ?? ''));
$accountEmail = trim((string)($sessionAccount['email'] ?? ''));

$errors = [];
$successMessage = '';
$activeTab = trim((string)($_GET['tab'] ?? 'overview'));
if (!in_array($activeTab, ['overview', 'password', 'displayname', 'characters'], true)) {
    $activeTab = 'overview';
}

// Fetch characters for the characters tab (also used in overview count)
$characters = ['classic74' => [], 'modern' => []];
$charFetchError = '';
if ($activeTab === 'characters' || $activeTab === 'overview') {
    $httpCode = 0;
    $ctxCall = reddaxe_post_json('/apik/v1/account-context.php', [
        'type' => 'account_context',
        'sessionKey' => $sessionKey,
    ], $httpCode);
    if (($ctxCall['ok'] ?? false) === true && isset($ctxCall['data']['charactersByWorld'])) {
        $characters = $ctxCall['data']['charactersByWorld'];
    } else {
        $charFetchError = reddaxe_t('account_manage.error.characters_fetch_failed');
    }
}
$totalChars = count($characters['classic74'] ?? []) + count($characters['modern'] ?? []);

// Handle password change form
if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($activeTab === 'password' || isset($_POST['action_password']))) {
    $activeTab = 'password';
    $currentPassword = (string)($_POST['current_password'] ?? '');
    $newPassword = (string)($_POST['new_password'] ?? '');
    $newPasswordConfirm = (string)($_POST['new_password_confirm'] ?? '');

    if ($currentPassword === '') {
        $errors[] = reddaxe_t('account_manage.error.current_password_required');
    }
    if (strlen($newPassword) < 6 || strlen($newPassword) > 72) {
        $errors[] = reddaxe_t('account_manage.error.new_password_length');
    }
    if (!hash_equals($newPassword, $newPasswordConfirm)) {
        $errors[] = reddaxe_t('account_manage.error.password_mismatch');
    }

    if ($errors === []) {
        $httpCode = 0;
        $apiCall = reddaxe_post_json('/apik/v1/change-password.php', [
            'type' => 'change_password',
            'sessionKey' => $sessionKey,
            'currentPassword' => $currentPassword,
            'newPassword' => $newPassword,
            'newPasswordConfirm' => $newPasswordConfirm,
        ], $httpCode);

        if (($apiCall['ok'] ?? false) !== true) {
            $errors[] = reddaxe_t('account_manage.error.api_unreachable') . ': ' . (string)($apiCall['message'] ?? 'request failed');
        } else {
            $apiResult = (array)($apiCall['data'] ?? []);
            if (($apiResult['ok'] ?? false) === true) {
                $successMessage = reddaxe_t('account_manage.success.password_changed');
            } else {
                $code = (string)($apiResult['error'] ?? 'change_failed');
                $msg = (string)($apiResult['message'] ?? reddaxe_t('account_manage.error.change_failed'));
                $errors[] = '[' . $code . '] ' . $msg;
            }
        }
    }
}

// Handle display name change
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action_displayname'])) {
    $activeTab = 'displayname';
    $newDisplayName = trim((string)($_POST['new_display_name'] ?? ''));

    if ($newDisplayName === '') {
        $errors[] = reddaxe_t('account_manage.error.display_name_required');
    } elseif (strlen($newDisplayName) < 3 || strlen($newDisplayName) > 32) {
        $errors[] = reddaxe_t('account_manage.error.display_name_length');
    } elseif (!preg_match('/^[A-Za-z0-9_ ]+$/', $newDisplayName)) {
        $errors[] = reddaxe_t('account_manage.error.display_name_chars');
    }

    if ($errors === []) {
        $httpCode = 0;
        $apiCall = reddaxe_post_json('/apik/v1/change-account-name.php', [
            'type' => 'change_account_name',
            'sessionKey' => $sessionKey,
            'newName' => $newDisplayName,
        ], $httpCode);

        if (($apiCall['ok'] ?? false) !== true) {
            $errors[] = reddaxe_t('account_manage.error.api_unreachable') . ': ' . (string)($apiCall['message'] ?? 'request failed');
        } else {
            $apiResult = (array)($apiCall['data'] ?? []);
            if (($apiResult['ok'] ?? false) === true) {
                $successMessage = reddaxe_t('account_manage.success.display_name_changed');
                // Update session data so the page reflects the new name
                reddaxe_start_shared_session();
                $_SESSION['account']['user']['name'] = (string)($apiResult['newName'] ?? $newDisplayName);
                $accountName = (string)($apiResult['newName'] ?? $newDisplayName);
                session_write_close();
            } else {
                $code = (string)($apiResult['error'] ?? 'change_failed');
                $msg = (string)($apiResult['message'] ?? reddaxe_t('account_manage.error.display_name_failed'));
                $errors[] = '[' . $code . '] ' . $msg;
            }
        }
    }
}

// Handle character rename
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action_rename_character'])) {
    $activeTab = 'characters';
    $renamePlayerId = (int)($_POST['player_id'] ?? 0);
    $renameGameMode = trim((string)($_POST['game_mode'] ?? ''));
    $renameNewName = trim((string)($_POST['new_character_name'] ?? ''));

    if ($renamePlayerId <= 0) {
        $errors[] = reddaxe_t('account_manage.error.invalid_character');
    }
    if (!in_array($renameGameMode, ['classic74', 'modern'], true)) {
        $errors[] = reddaxe_t('account_manage.error.invalid_game_mode');
    }
    if ($renameNewName === '' || strlen($renameNewName) < 3 || strlen($renameNewName) > 29) {
        $errors[] = reddaxe_t('account_manage.error.character_name_length');
    } elseif (!preg_match('/^[A-Za-z ]+$/', $renameNewName)) {
        $errors[] = reddaxe_t('account_manage.error.character_name_chars');
    }

    if ($errors === []) {
        $httpCode = 0;
        $apiCall = reddaxe_post_json('/apik/v1/change-character-name.php', [
            'type' => 'change_character_name',
            'sessionKey' => $sessionKey,
            'playerId' => $renamePlayerId,
            'gameMode' => $renameGameMode,
            'newName' => $renameNewName,
        ], $httpCode);

        if (($apiCall['ok'] ?? false) !== true) {
            $errors[] = reddaxe_t('account_manage.error.api_unreachable') . ': ' . (string)($apiCall['message'] ?? 'request failed');
        } else {
            $apiResult = (array)($apiCall['data'] ?? []);
            if (($apiResult['ok'] ?? false) === true) {
                $successMessage = reddaxe_t('account_manage.success.character_renamed', [
                    'old' => (string)($apiResult['oldName'] ?? ''),
                    'new' => (string)($apiResult['newName'] ?? $renameNewName),
                ]);
                // Re-fetch characters to show updated list
                $httpCode2 = 0;
                $ctxCall = reddaxe_post_json('/apik/v1/account-context.php', [
                    'type' => 'account_context',
                    'sessionKey' => $sessionKey,
                ], $httpCode2);
                if (($ctxCall['ok'] ?? false) === true && isset($ctxCall['data']['charactersByWorld'])) {
                    $characters = $ctxCall['data']['charactersByWorld'];
                    $totalChars = count($characters['classic74'] ?? []) + count($characters['modern'] ?? []);
                }
            } else {
                $code = (string)($apiResult['error'] ?? 'rename_failed');
                $msg = (string)($apiResult['message'] ?? reddaxe_t('account_manage.error.character_rename_failed'));
                $errors[] = '[' . $code . '] ' . $msg;
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
    <title><?php echo reddaxe_e(reddaxe_t('account_manage.page_title', ['brand' => $cfg['brand']])); ?></title>
    <style>
        body { margin: 0; font-family: "Trebuchet MS", "Segoe UI", sans-serif; background: #11151c; color: #ecf2ff; }
        .wrap { max-width: 720px; margin: 0 auto; padding: 24px 16px 40px; }
        .topnav { display: flex; align-items: center; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; }
        .topnav a { color: #b9c6dd; text-decoration: none; }
        .topnav a:hover { color: #ecf2ff; }
        .langbadge { padding: 2px 8px; border-radius: 6px; font-size: .75rem; font-weight: 700; cursor: pointer; text-decoration: none; }
        .langbadge.active { background: #f28f3b; color: #111; }
        .langbadge:not(.active) { background: #2f3f57; color: #b9c6dd; }
        .card { background: #1b2430; border: 1px solid #2f3f57; border-radius: 12px; padding: 16px; margin-bottom: 16px; }
        h1 { margin: 0 0 14px; font-size: 1.7rem; }
        h2 { margin: 0 0 12px; font-size: 1.2rem; color: #f28f3b; }
        p, .muted { margin: 0 0 12px; color: #b9c6dd; }
        .info-row { display: flex; gap: 8px; margin-bottom: 8px; }
        .info-label { color: #7a8fac; min-width: 100px; }
        .info-value { color: #ecf2ff; font-weight: 600; }
        label { display: block; margin: 10px 0 6px; font-size: .9rem; color: #d8e1f1; }
        input { width: 100%; border-radius: 8px; border: 1px solid #3d4f6c; background: #0f1722; color: #ecf2ff; padding: 10px; box-sizing: border-box; }
        .btns { display: flex; gap: 10px; margin-top: 14px; flex-wrap: wrap; }
        button, a.btn { border: 0; border-radius: 8px; padding: 10px 14px; font-weight: 700; text-decoration: none; display: inline-block; }
        button { background: #f28f3b; color: #111; cursor: pointer; }
        a.btn { background: #c6d4eb; color: #111; }
        a.btn.secondary { background: #2f3f57; color: #ecf2ff; }
        .err { background: #3b1a1a; border: 1px solid #7a3030; color: #ffb3b3; border-radius: 8px; padding: 10px; margin: 10px 0; }
        .ok { background: #1a3b24; border: 1px solid #2f7a40; color: #b3ffc4; border-radius: 8px; padding: 10px; margin: 10px 0; }
        .tabs { display: flex; gap: 4px; margin-bottom: 16px; }
        .tab { padding: 8px 16px; border-radius: 8px 8px 0 0; text-decoration: none; font-weight: 600; font-size: .9rem; }
        .tab.active { background: #1b2430; color: #f28f3b; border: 1px solid #2f3f57; border-bottom: 1px solid #1b2430; }
        .tab:not(.active) { background: #0f1722; color: #7a8fac; border: 1px solid transparent; }
        .tab:hover:not(.active) { color: #ecf2ff; }
    </style>
</head>
<body>
<div class="wrap">
    <div class="topnav">
        <a href="/reddaxe/"><?php echo reddaxe_e(reddaxe_t('common.nav.back_frontdoor')); ?></a>
        <a href="/reddaxe/logout.php" style="color:#e84855;margin-left:12px"><?php echo reddaxe_e(reddaxe_t('common.nav.logout')); ?></a>
        <span style="flex:1"></span>
        <?php
        $curLang = reddaxe_current_lang();
        foreach (['pl', 'en'] as $lng):
            $cls = ($lng === $curLang) ? 'langbadge active' : 'langbadge';
        ?>
            <a class="<?php echo $cls; ?>" href="?tab=<?php echo reddaxe_e($activeTab); ?>&lang=<?php echo $lng; ?>"><?php echo reddaxe_e(reddaxe_t('common.lang.' . $lng)); ?></a>
        <?php endforeach; ?>
    </div>

    <div class="tabs">
        <a class="tab <?php echo $activeTab === 'overview' ? 'active' : ''; ?>" href="?tab=overview"><?php echo reddaxe_e(reddaxe_t('account_manage.tab.overview')); ?></a>
        <a class="tab <?php echo $activeTab === 'password' ? 'active' : ''; ?>" href="?tab=password"><?php echo reddaxe_e(reddaxe_t('account_manage.tab.password')); ?></a>
        <a class="tab <?php echo $activeTab === 'displayname' ? 'active' : ''; ?>" href="?tab=displayname"><?php echo reddaxe_e(reddaxe_t('account_manage.tab.displayname')); ?></a>
        <a class="tab <?php echo $activeTab === 'characters' ? 'active' : ''; ?>" href="?tab=characters"><?php echo reddaxe_e(reddaxe_t('account_manage.tab.characters')); ?></a>
    </div>

    <?php foreach ($errors as $error): ?>
        <div class="err"><?php echo reddaxe_e($error); ?></div>
    <?php endforeach; ?>
    <?php if ($successMessage !== ''): ?>
        <div class="ok"><?php echo reddaxe_e($successMessage); ?></div>
    <?php endif; ?>

    <?php if ($activeTab === 'overview'): ?>
    <div class="card">
        <h1><?php echo reddaxe_e(reddaxe_t('account_manage.heading')); ?></h1>
        <div class="info-row">
            <span class="info-label"><?php echo reddaxe_e(reddaxe_t('account_manage.label.account_name')); ?></span>
            <span class="info-value"><?php echo reddaxe_e($accountName); ?></span>
        </div>
        <div class="info-row">
            <span class="info-label"><?php echo reddaxe_e(reddaxe_t('account_manage.label.email')); ?></span>
            <span class="info-value"><?php echo reddaxe_e($accountEmail); ?></span>
        </div>
        <div class="btns">
            <a class="btn" href="?tab=password"><?php echo reddaxe_e(reddaxe_t('account_manage.btn.change_password')); ?></a>
            <a class="btn" href="?tab=displayname"><?php echo reddaxe_e(reddaxe_t('account_manage.btn.change_display_name')); ?></a>
            <a class="btn" href="?tab=characters"><?php echo reddaxe_e(reddaxe_t('account_manage.btn.characters')); ?> (<?php echo $totalChars; ?>)</a>
            <a class="btn secondary" href="/account"><?php echo reddaxe_e(reddaxe_t('account_manage.btn.game_account')); ?></a>
            <a class="btn secondary" href="/reddaxe/post-login.php"><?php echo reddaxe_e(reddaxe_t('account_manage.btn.dashboard')); ?></a>
        </div>
    </div>
    <?php endif; ?>

    <?php if ($activeTab === 'password'): ?>
    <div class="card">
        <h2><?php echo reddaxe_e(reddaxe_t('account_manage.password.heading')); ?></h2>
        <form method="post" action="?tab=password">
            <input type="hidden" name="action_password" value="1">

            <label for="current_password"><?php echo reddaxe_e(reddaxe_t('account_manage.password.current')); ?></label>
            <input id="current_password" name="current_password" type="password" required autocomplete="current-password">

            <label for="new_password"><?php echo reddaxe_e(reddaxe_t('account_manage.password.new')); ?></label>
            <input id="new_password" name="new_password" type="password" required autocomplete="new-password" minlength="6" maxlength="72">

            <label for="new_password_confirm"><?php echo reddaxe_e(reddaxe_t('account_manage.password.confirm')); ?></label>
            <input id="new_password_confirm" name="new_password_confirm" type="password" required autocomplete="new-password">

            <div class="btns">
                <button type="submit"><?php echo reddaxe_e(reddaxe_t('account_manage.password.submit')); ?></button>
                <a class="btn" href="?tab=overview"><?php echo reddaxe_e(reddaxe_t('account_manage.btn.back')); ?></a>
            </div>
        </form>
    </div>
    <?php endif; ?>

    <?php if ($activeTab === 'displayname'): ?>
    <div class="card">
        <h2><?php echo reddaxe_e(reddaxe_t('account_manage.displayname.heading')); ?></h2>
        <p class="muted"><?php echo reddaxe_e(reddaxe_t('account_manage.displayname.hint')); ?></p>
        <form method="post" action="?tab=displayname">
            <input type="hidden" name="action_displayname" value="1">

            <label for="current_name"><?php echo reddaxe_e(reddaxe_t('account_manage.displayname.current')); ?></label>
            <input id="current_name" type="text" value="<?php echo reddaxe_e($accountName); ?>" disabled>

            <label for="new_display_name"><?php echo reddaxe_e(reddaxe_t('account_manage.displayname.new')); ?></label>
            <input id="new_display_name" name="new_display_name" type="text" required minlength="3" maxlength="32" pattern="[A-Za-z0-9_ ]+" value="<?php echo reddaxe_e((string)($_POST['new_display_name'] ?? '')); ?>">

            <div class="btns">
                <button type="submit"><?php echo reddaxe_e(reddaxe_t('account_manage.displayname.submit')); ?></button>
                <a class="btn" href="?tab=overview"><?php echo reddaxe_e(reddaxe_t('account_manage.btn.back')); ?></a>
            </div>
        </form>
    </div>
    <?php endif; ?>

    <?php if ($activeTab === 'characters'): ?>
    <div class="card">
        <h2><?php echo reddaxe_e(reddaxe_t('account_manage.characters.heading')); ?></h2>
        <?php if ($charFetchError !== ''): ?>
            <div class="err"><?php echo reddaxe_e($charFetchError); ?></div>
        <?php endif; ?>

        <?php if ($totalChars === 0 && $charFetchError === ''): ?>
            <p class="muted"><?php echo reddaxe_e(reddaxe_t('account_manage.characters.empty')); ?></p>
        <?php endif; ?>

        <?php
        $renameTarget = isset($_GET['rename']) ? (int)$_GET['rename'] : 0;
        $renameGm = trim((string)($_GET['rgm'] ?? ''));

        foreach (['classic74', 'modern'] as $gm):
            $charList = $characters[$gm] ?? [];
            if (empty($charList)) continue;
            $serverLabel = ($gm === 'modern') ? 'Modern' : 'Classic 7.4';
        ?>
        <h3 style="color:#f28f3b;margin:16px 0 8px;font-size:1rem"><?php echo reddaxe_e($serverLabel); ?> (<?php echo count($charList); ?>)</h3>
        <table style="width:100%;border-collapse:collapse;margin-bottom:12px">
            <thead>
                <tr style="border-bottom:1px solid #2f3f57;text-align:left">
                    <th style="padding:6px 8px;color:#7a8fac"><?php echo reddaxe_e(reddaxe_t('account_manage.characters.col_name')); ?></th>
                    <th style="padding:6px 8px;color:#7a8fac"><?php echo reddaxe_e(reddaxe_t('account_manage.characters.col_level')); ?></th>
                    <th style="padding:6px 8px;color:#7a8fac"></th>
                </tr>
            </thead>
            <tbody>
            <?php foreach ($charList as $char):
                $charId = (int)$char['id'];
                $charName = (string)$char['name'];
                $charLevel = (int)$char['level'];
                $showRenameForm = ($renameTarget === $charId && $renameGm === $gm);
            ?>
                <tr style="border-bottom:1px solid #1a2535">
                    <td style="padding:6px 8px;font-weight:600"><?php echo reddaxe_e($charName); ?></td>
                    <td style="padding:6px 8px"><?php echo $charLevel; ?></td>
                    <td style="padding:6px 8px;text-align:right">
                        <?php if (!$showRenameForm): ?>
                            <a href="?tab=characters&rename=<?php echo $charId; ?>&rgm=<?php echo reddaxe_e($gm); ?>" style="color:#f28f3b;text-decoration:none;font-size:.85rem"><?php echo reddaxe_e(reddaxe_t('account_manage.characters.btn_rename')); ?></a>
                        <?php endif; ?>
                    </td>
                </tr>
                <?php if ($showRenameForm): ?>
                <tr>
                    <td colspan="3" style="padding:8px">
                        <form method="post" action="?tab=characters" style="display:flex;gap:8px;align-items:end;flex-wrap:wrap">
                            <input type="hidden" name="action_rename_character" value="1">
                            <input type="hidden" name="player_id" value="<?php echo $charId; ?>">
                            <input type="hidden" name="game_mode" value="<?php echo reddaxe_e($gm); ?>">
                            <div style="flex:1;min-width:180px">
                                <label for="new_char_name_<?php echo $charId; ?>" style="margin:0 0 4px;font-size:.8rem"><?php echo reddaxe_e(reddaxe_t('account_manage.characters.new_name')); ?></label>
                                <input id="new_char_name_<?php echo $charId; ?>" name="new_character_name" type="text" required minlength="3" maxlength="29" pattern="[A-Za-z ]+" value="<?php echo reddaxe_e($charName); ?>">
                            </div>
                            <button type="submit" style="height:40px"><?php echo reddaxe_e(reddaxe_t('account_manage.characters.btn_save')); ?></button>
                            <a class="btn secondary" href="?tab=characters" style="height:40px;line-height:40px;padding:0 12px"><?php echo reddaxe_e(reddaxe_t('account_manage.characters.btn_cancel')); ?></a>
                        </form>
                    </td>
                </tr>
                <?php endif; ?>
            <?php endforeach; ?>
            </tbody>
        </table>
        <?php endforeach; ?>

        <div class="btns" style="margin-top:12px">
            <a class="btn" href="?tab=overview"><?php echo reddaxe_e(reddaxe_t('account_manage.btn.back')); ?></a>
            <a class="btn secondary" href="/account"><?php echo reddaxe_e(reddaxe_t('account_manage.btn.game_account')); ?></a>
        </div>
    </div>
    <?php endif; ?>

</div>
</body>
</html>
