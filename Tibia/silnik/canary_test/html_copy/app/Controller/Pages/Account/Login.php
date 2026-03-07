<?php
/**
 * Login Class
 *
 * @package   CanaryAAC
 * @author    Lucas Giovanni <lucasgiovannidesigner@gmail.com>
 * @copyright 2022 CanaryAAC
 */

namespace App\Controller\Pages\Account;

use App\Utils\Argon;
use App\Utils\View;
use App\Http\Request;
use App\Controller\Pages\Base;
use App\Model\Entity\Login as EntityLogin;
use App\Session\Admin\Login as SessionAdminLogin;
use App\Controller\Admin\Alert;
use App\Model\Entity\Account;
use PragmaRX\Google2FA\Google2FA;

class Login extends Base{

    private static function normalizeRedirectPath(string $path): string
    {
        $path = trim($path);
        if ($path === '') {
            return '/account';
        }
        if (!str_starts_with($path, '/')) {
            return '/account';
        }
        if (str_starts_with($path, '//')) {
            return '/account';
        }
        if (preg_match('/[\r\n]/', $path)) {
            return '/account';
        }
        return $path;
    }

    private static function resolveRedirectPath(Request $request, array $postVars = []): string
    {
        $queryParams = $request->getQueryParams();
        $raw = '';
        if (isset($postVars['redirect']) && is_string($postVars['redirect'])) {
            $raw = $postVars['redirect'];
        } elseif (isset($queryParams['redirect']) && is_string($queryParams['redirect'])) {
            $raw = $queryParams['redirect'];
        }
        return self::normalizeRedirectPath($raw);
    }

    private static function normalizeSyncError(string $error): string
    {
        $error = trim($error);
        $allowed = [
            'missing_sync_token',
            'invalid_sync_token',
            'sync_token_already_used',
            'sync_token_expired',
            'target_mismatch',
            'source_mismatch',
            'sync_consume_failed',
            'db_connect_failed',
            'sync_schema_not_ready',
            'account_not_found',
        ];
        return in_array($error, $allowed, true) ? $error : '';
    }

    private static function normalizeModeHint(string $mode): string
    {
        $mode = strtolower(trim($mode));
        if ($mode === 'classic74') {
            return 'classic74';
        }
        if ($mode === 'modern') {
            return 'modern';
        }
        return '';
    }

    /**
     * Method responsible for returning the login page rendering
     *
     * @param Request $request
     * @param string|null $errorMessage
     * @return string
     */
    public static function getLogin(Request $request, string $errorMessage = null, ?string $redirectPath = null): string
    {
        // Login status
        $status = !is_null($errorMessage) ? Alert::getError(__('error_wrong_credentials')) : '';
        if ($redirectPath === null) {
            $redirectPath = self::resolveRedirectPath($request);
        }
        $queryParams = $request->getQueryParams();
        $postVars = $request->getPostVars();
        if (!is_array($postVars)) {
            $postVars = [];
        }
        $syncErrorRaw = isset($postVars['sync_error']) ? (string)$postVars['sync_error'] : (string)($queryParams['sync_error'] ?? '');
        $sourceRaw = isset($postVars['source']) ? (string)$postVars['source'] : (string)($queryParams['source'] ?? '');
        $modeRaw = isset($postVars['mode']) ? (string)$postVars['mode'] : (string)($queryParams['mode'] ?? '');

        $syncError = self::normalizeSyncError($syncErrorRaw);
        $launcherSource = strtolower($sourceRaw) === 'launcher' ? 'launcher' : '';
        $launcherMode = self::normalizeModeHint($modeRaw);

        // Render login page and $status
        $content = View::render('pages/account/login', [
            'status' => $status,
            'redirect_path' => $redirectPath,
            'sync_error' => $syncError,
            'launcher_source' => $launcherSource,
            'launcher_mode' => $launcherMode,
            't_error_title' => __('error_title'),
            't_error_wrong_credentials' => __('error_wrong_credentials'),
            't_account_login' => __('account_login'),
            't_email_address' => __('email_address'),
            't_tibia_password' => __('tibia_password'),
            't_authenticator' => __('authenticator'),
            't_login' => __('login'),
            't_lost_account' => __('lost_account'),
            't_use_authenticator' => __('use_authenticator'),
            't_no_authenticator' => __('no_authenticator'),
            't_new_to_tibia' => __('new_to_tibia'),
            't_new_player' => __('new_player'),
            't_create_account' => __('create_account'),
        ]);

        return parent::getBase(__('account_management'), $content, 'account');
    }

    /**
     * Method responsible for setting user login
     *
     * @param Request $request
     */
    public static function setLogin(Request $request)
    {
        $postVars = $request->getPostVars();
        $login = trim((string)($postVars['loginemail'] ?? ''));
        $pass  = (string)($postVars['loginpassword'] ?? '');
        $redirectPath = self::resolveRedirectPath($request, $postVars);

        if ($login === '' || $pass === '') {
            return self::getLogin($request, 'true', $redirectPath);
        }

        // 1) Resolve by email OR by account name
        if (filter_var($login, FILTER_VALIDATE_EMAIL)) {
            $obAccount = EntityLogin::getLoginbyEmail($login);
        } else {
            $obAccount = EntityLogin::getLoginbyName($login);
        }
        if (!$obAccount instanceof EntityLogin) {
            return self::getLogin($request, 'true', $redirectPath);
        }

        // 2) Password verification: first our universal helper (argon2/bcrypt/sha1), then fallback to Argon::checkPassword
        $hash = (string)$obAccount->password;
        $ok = false;

        if (function_exists('\\App\\Utils\\verify_password_any')) {
            $ok = \App\Utils\verify_password_any($pass, $hash);
        } elseif (function_exists('verify_password_any')) {
            $ok = verify_password_any($pass, $hash);
        }
        if (!$ok) {
            $ok = Argon::checkPassword($pass, $hash, (int)$obAccount->id);
        }
        if (!$ok && preg_match('/^[A-Fa-f0-9]{40}$/', $hash) === 1) {
            // Fallback dla kont tworzonych przez register-account.php (SHA1 hex).
            $ok = hash_equals(strtoupper($hash), strtoupper(sha1($pass)));
        }
        if (!$ok) {
            return self::getLogin($request, 'true', $redirectPath);
        }

        // 3) Login and redirect (rest unchanged)
        SessionAdminLogin::login($obAccount);
        return $request->getRouter()->redirect($redirectPath);
    }


    public static function setLogout($request): string
    {
        SessionAdminLogin::logout();
        $content = View::render('pages/account/logout', []);
        return parent::getBase(__('logout_successful'), $content, 'account');
    }

}
