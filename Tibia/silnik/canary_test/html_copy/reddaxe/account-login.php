<?php
declare(strict_types=1);

require_once __DIR__ . '/bootstrap.php';

function reddaxe_http_get_json(string $pathWithQuery, int &$httpCode = 0): array
{
    $url = rtrim(reddaxe_public_base_url(), '/') . '/' . ltrim($pathWithQuery, '/');
    $skipTlsVerify = function_exists('reddaxe_skip_tls_verify_for_url')
        ? reddaxe_skip_tls_verify_for_url($url)
        : false;

    if (function_exists('curl_init')) {
        $ch = curl_init($url);
        if ($ch === false) {
            $httpCode = 0;
            return [];
        }
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => ['Accept: application/json'],
            CURLOPT_TIMEOUT => 15,
            CURLOPT_SSL_VERIFYPEER => !$skipTlsVerify,
            CURLOPT_SSL_VERIFYHOST => $skipTlsVerify ? 0 : 2,
        ]);
        $raw = curl_exec($ch);
        if ($raw === false) {
            curl_close($ch);
            $httpCode = 0;
            return [];
        }
        $httpCode = (int)curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
        curl_close($ch);
    } else {
        $context = stream_context_create([
            'http' => [
                'method' => 'GET',
                'header' => "Accept: application/json\r\n",
                'timeout' => 15,
                'ignore_errors' => true,
            ],
            'ssl' => [
                'verify_peer' => !$skipTlsVerify,
                'verify_peer_name' => !$skipTlsVerify,
            ],
        ]);
        $raw = @file_get_contents($url, false, $context);
        if ($raw === false) {
            $httpCode = 0;
            return [];
        }
        $httpCode = 0;
        if (isset($http_response_header) && is_array($http_response_header)) {
            foreach ($http_response_header as $line) {
                if (preg_match('#^HTTP/\\d+\\.\\d+\\s+(\\d{3})#', $line, $m)) {
                    $httpCode = (int)$m[1];
                    break;
                }
            }
        }
    }

    $decoded = json_decode((string)$raw, true);
    return is_array($decoded) ? $decoded : [];
}

function reddaxe_issue_launch_token(array $apiEnv): array
{
    $channel = trim((string)($apiEnv['UPDATE_CHANNEL'] ?? 'stable'));
    if ($channel === '') {
        $channel = 'stable';
    }

    $updateHttpCode = 0;
    $manifest = reddaxe_http_get_json('/apik/v1/update.php?channel=' . urlencode($channel), $updateHttpCode);
    $filesHash = trim((string)($manifest['filesHashExpected'] ?? $manifest['filesHash'] ?? ($apiEnv['EXPECTED_FILES_HASH'] ?? '')));
    $manifestVersion = trim((string)($manifest['version'] ?? ''));
    $launcherVersion = trim((string)($apiEnv['LAUNCHER_VERSION'] ?? '1.0.0'));
    if ($launcherVersion === '') {
        $launcherVersion = '1.0.0';
    }

    if ($filesHash === '') {
        return [
            'ok' => false,
            'error' => 'files_hash_missing',
            'message' => 'Cannot determine filesHash for launcher-token request.',
            'httpCode' => $updateHttpCode,
        ];
    }

    $tokenHttpCode = 0;
    $tokenCall = reddaxe_post_json('/apik/v1/launcher-token.php', [
        'launcherVersion' => $launcherVersion,
        'filesHash' => $filesHash,
        'manifestVersion' => $manifestVersion,
        'channel' => $channel,
    ], $tokenHttpCode);

    if (($tokenCall['ok'] ?? false) !== true) {
        return [
            'ok' => false,
            'error' => 'launcher_token_http_failed',
            'message' => (string)($tokenCall['message'] ?? 'Cannot contact launcher-token endpoint.'),
            'httpCode' => $tokenHttpCode,
        ];
    }

    $tokenData = (array)($tokenCall['data'] ?? []);
    $launchToken = trim((string)($tokenData['launchToken'] ?? $tokenData['token'] ?? ''));
    if ($launchToken === '') {
        return [
            'ok' => false,
            'error' => (string)($tokenData['error'] ?? 'launcher_token_missing'),
            'message' => (string)($tokenData['message'] ?? 'launcher-token endpoint did not return launchToken/token.'),
            'httpCode' => $tokenHttpCode,
        ];
    }

    return [
        'ok' => true,
        'launchToken' => $launchToken,
    ];
}

$cfg = reddaxe_build_config();
$apiEnv = reddaxe_env(__DIR__ . '/../apik/v1/.env');
$siteName = trim((string)($apiEnv['SITE_NAME'] ?? 'CanaryAAC'));

$emailHint = strtolower(trim((string)($_GET['email'] ?? '')));
if ($emailHint === '' && isset($_COOKIE['reddaxe_email'])) {
    $emailHint = strtolower(trim((string)$_COOKIE['reddaxe_email']));
}
$emailHint = substr($emailHint, 0, 120);
$password = '';
$source = $_GET['source'] ?? '';
$redirectPath = $source === 'tibiawww'
    ? '/?subtopic=accountmanagement'
    : '/reddaxe/post-login.php?source=reddaxe';
$errors = [];
$infoMessage = '';

// Show message after email verification redirect
if (isset($_GET['verified']) && $_GET['verified'] === '1') {
    $infoMessage = reddaxe_t('account_login.info.email_verified');
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $emailHint = strtolower(trim((string)($_POST['email'] ?? '')));
    $emailHint = substr($emailHint, 0, 120);
    $password = (string)($_POST['password'] ?? '');

    if (!filter_var($emailHint, FILTER_VALIDATE_EMAIL)) {
        $errors[] = reddaxe_t('account_login.error.invalid_email');
    }
    if ($password === '') {
        $errors[] = reddaxe_t('account_login.error.invalid_password');
    }

    if ($errors === []) {
        $launchToken = '';
        $launchTokenError = '';
        $tokenResult = reddaxe_issue_launch_token($apiEnv);
        if (($tokenResult['ok'] ?? false) === true) {
            $launchToken = (string)$tokenResult['launchToken'];
        } else {
            $launchTokenError = '[' . (string)($tokenResult['error'] ?? 'launcher_token_failed') . '] ' .
                (string)($tokenResult['message'] ?? 'Cannot issue launch token.');
        }

        $loginPayload = [
            'type' => 'login',
            'email' => $emailHint,
            'password' => $password,
            'gameMode' => 'all',
        ];
        if ($launchToken !== '') {
            $loginPayload['launchToken'] = $launchToken;
        }

        $loginHttpCode = 0;
        $loginCall = reddaxe_post_json('/apik/v1/login.php', $loginPayload, $loginHttpCode);

        if (($loginCall['ok'] ?? false) !== true) {
            $errors[] = reddaxe_t('account_login.error.api_unreachable') . ': ' . (string)($loginCall['message'] ?? 'request failed');
        } else {
            $loginData = (array)($loginCall['data'] ?? []);
            $sessionKey = trim((string)($loginData['session']['sessionkey'] ?? ''));

            if ($sessionKey === '') {
                $apiCode = (string)($loginData['error'] ?? $loginData['errorCode'] ?? 'login_failed');
                $apiMessage = (string)($loginData['message'] ?? $loginData['errorMessage'] ?? reddaxe_t('account_login.error.invalid_credentials'));
                if ($launchTokenError !== '' && str_contains(strtolower($apiMessage), 'launch token')) {
                    $apiMessage .= ' | ' . $launchTokenError;
                }
                $errors[] = '[' . $apiCode . '] ' . $apiMessage . ' (HTTP ' . $loginHttpCode . ')';
            } else {
                $ctxHttpCode = 0;
                $ctxCall = reddaxe_post_json('/apik/v1/account-context.php', [
                    'type' => 'account_context',
                    'sessionKey' => $sessionKey,
                ], $ctxHttpCode);

                if (($ctxCall['ok'] ?? false) !== true) {
                    $errors[] = reddaxe_t('account_login.error.context_unreachable') . ': ' . (string)($ctxCall['message'] ?? 'request failed');
                } else {
                    $ctxData = (array)($ctxCall['data'] ?? []);
                    $account = isset($ctxData['account']) && is_array($ctxData['account']) ? $ctxData['account'] : [];
                    $accountId = (int)($account['id'] ?? 0);
                    $accountName = trim((string)($account['name'] ?? ''));
                    $accountEmail = trim((string)($account['email'] ?? $emailHint));

                    if ($accountId <= 0 || $accountName === '') {
                        $errors[] = reddaxe_t('account_login.error.context_invalid') . ' (HTTP ' . $ctxHttpCode . ')';
                    } else {
                        reddaxe_start_shared_session();
                        session_regenerate_id(true);

                        // R1: Remember me — extend session cookie to 30 days
                        $rememberMe = !empty($_POST['remember']);
                        if ($rememberMe) {
                            $lifetime = 30 * 24 * 3600; // 30 days
                            $params = session_get_cookie_params();
                            setcookie(session_name(), session_id(), [
                                'expires' => time() + $lifetime,
                                'path' => $params['path'],
                                'domain' => $params['domain'],
                                'secure' => $params['secure'],
                                'httponly' => $params['httponly'],
                                'samesite' => $params['samesite'] ?? 'Lax',
                            ]);
                            ini_set('session.gc_maxlifetime', (string)$lifetime);

                            // Save email in cookie for next login
                            setcookie('reddaxe_email', $accountEmail, [
                                'expires' => time() + $lifetime,
                                'path' => '/',
                                'secure' => $params['secure'],
                                'httponly' => true,
                                'samesite' => 'Lax',
                            ]);
                        }

                        $_SESSION['account']['user'] = [
                            'id' => $accountId,
                            'name' => $accountName,
                            'email' => $accountEmail,
                        ];
                        $_SESSION['account']['sessionKey'] = $sessionKey;
                        $_SESSION['login_timeout'] = time();

                        // Cross-site sync: set MyAAC session keys so the user
                        // is also logged in on the main Tibia website.
                        $_SESSION['myaac_account'] = $accountId;
                        $dbPasswordHash = reddaxe_fetch_myaac_password_hash($accountId);
                        $_SESSION['myaac_password'] = $dbPasswordHash ?? sha1($password);
                        $_SESSION['myaac_last_visit'] = time();
                        $_SESSION['myaac_remember_me'] = $rememberMe;

                        session_write_close();

                        header('Location: ' . $redirectPath, true, 302);
                        exit;
                    }
                }
            }
        }
    }

    $password = '';
}

header('Content-Type: text/html; charset=utf-8');
?>
<!doctype html>
<html lang="<?php echo reddaxe_e(reddaxe_current_lang()); ?>">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?php echo reddaxe_e(reddaxe_t('account_login.page_title', ['brand' => $cfg['brand']])); ?></title>
    <style>
        body { margin: 0; font-family: "Trebuchet MS", "Segoe UI", sans-serif; background: #11151c; color: #ecf2ff; }
        .wrap { max-width: 720px; margin: 0 auto; padding: 24px 16px 40px; }
        .card { background: #1b2430; border: 1px solid #2f3f57; border-radius: 12px; padding: 16px; }
        h1 { margin: 0 0 14px; font-size: 1.7rem; }
        p { margin: 0 0 12px; color: #b9c6dd; }
        label { display: block; margin: 10px 0 6px; font-size: .9rem; color: #d8e1f1; }
        input { width: 100%; border-radius: 8px; border: 1px solid #3d4f6c; background: #0f1722; color: #ecf2ff; padding: 10px; }
        .btns { display: flex; gap: 10px; margin-top: 14px; flex-wrap: wrap; }
        button, a.btn { border: 0; border-radius: 8px; padding: 10px 14px; font-weight: 700; text-decoration: none; }
        button { background: #f28f3b; color: #111; cursor: pointer; }
        a.btn { background: #c6d4eb; color: #111; }
        .checkbox-label { display: flex; align-items: center; gap: 8px; margin: 12px 0 4px; cursor: pointer; font-size: .9rem; }
        .checkbox-label input[type=checkbox] { width: auto; margin: 0; cursor: pointer; }
        .err { margin: 0 0 10px; padding: 8px 10px; border-radius: 8px; border: 1px solid #8c3b3b; background: #3a1f1f; color: #ffc4c4; }
        .ok { margin: 0 0 10px; padding: 8px 10px; border-radius: 8px; border: 1px solid #2f7a40; background: #1a3b24; color: #b3ffc4; }
        .topnav { margin-bottom: 12px; }
        .topnav a { color: #ffd9a6; text-decoration: none; }
        code { display: block; background: #0f1722; border: 1px solid #2f3f57; border-radius: 8px; padding: 8px; margin-top: 8px; }
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
        <h1><?php echo reddaxe_e(reddaxe_t('account_login.heading')); ?></h1>
        <p><?php echo reddaxe_e(reddaxe_t('account_login.intro')); ?></p>
        <code><?php echo reddaxe_e(reddaxe_t('account_login.redirect_prefix')); ?>: <?php echo reddaxe_e($redirectPath); ?></code>

        <?php foreach ($errors as $error): ?>
            <div class="err"><?php echo reddaxe_e($error); ?></div>
        <?php endforeach; ?>
        <?php if ($infoMessage !== ''): ?>
            <div class="ok"><?php echo reddaxe_e($infoMessage); ?></div>
        <?php endif; ?>

        <form method="post" action="/reddaxe/account-login.php">
            <label for="email"><?php echo reddaxe_e(reddaxe_t('account_login.form.email')); ?></label>
            <input id="email" name="email" type="email" value="<?php echo reddaxe_e($emailHint); ?>" required>

            <label for="password"><?php echo reddaxe_e(reddaxe_t('account_login.form.password')); ?></label>
            <input id="password" name="password" type="password" required>

            <label class="checkbox-label">
                <input type="checkbox" name="remember" value="1"<?php echo isset($_COOKIE['reddaxe_email']) ? ' checked' : ''; ?>>
                <?php echo reddaxe_e(reddaxe_t('account_login.form.remember_me')); ?>
            </label>

            <div class="btns">
                <button type="submit"><?php echo reddaxe_e(reddaxe_t('account_login.form.submit')); ?></button>
                <a class="btn" href="/reddaxe/account-create.php"><?php echo reddaxe_e(reddaxe_t('account_login.form.create')); ?></a>
                <a class="btn" href="/reddaxe/reset-password.php"><?php echo reddaxe_e(reddaxe_t('account_login.form.forgot_password')); ?></a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
