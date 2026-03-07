<?php
/**
 * Launcher -> WWW account sync login.
 *
 * URL:
 *   /account/sync-login?syncToken=...&redirect=/account/manage
 *   /account/sync-login?token=...&redirect=/account/manage
 */
defined('MYAAC') or die('Direct access not allowed!');

$title = 'Account Sync Login';

function syncLoginNormalizeRedirectPath(string $redirect): string
{
	$redirect = trim($redirect);
	if ($redirect === '') {
		return '/account/manage';
	}

	if (!str_starts_with($redirect, '/')) {
		return '/account/manage';
	}

	if (str_starts_with($redirect, '//')) {
		return '/account/manage';
	}

	return $redirect;
}

function syncLoginExtractModeFromRedirectPath(string $redirectPath): string
{
	$query = parse_url($redirectPath, PHP_URL_QUERY);
	if (!is_string($query) || $query === '') {
		return '';
	}

	parse_str($query, $params);
	$mode = strtolower(trim((string)($params['mode'] ?? '')));
	if (in_array($mode, ['classic74', 'modern'], true)) {
		return $mode;
	}

	return '';
}

function syncLoginResolveModeHint(string $redirectPath): string
{
	$mode = strtolower(trim((string)($_GET['mode'] ?? $_POST['mode'] ?? '')));
	if (!in_array($mode, ['classic74', 'modern'], true)) {
		$mode = syncLoginExtractModeFromRedirectPath($redirectPath);
	}

	return $mode;
}

function syncLoginBuildLoginFallbackUrl(string $redirectPath, string $syncError, string $modeHint): string
{
	$params = [
		'redirect' => $redirectPath,
		'sync_error' => $syncError,
		'source' => 'launcher',
	];

	if ($modeHint !== '') {
		$params['mode'] = $modeHint;
	}

	return '/account/login?' . http_build_query($params);
}

function syncLoginFail(string $errorCode, string $redirectPath, string $modeHint): void
{
	header('Location: ' . syncLoginBuildLoginFallbackUrl($redirectPath, $errorCode, $modeHint), true, 302);
	exit;
}

$redirectPath = syncLoginNormalizeRedirectPath((string)($_GET['redirect'] ?? $_POST['redirect'] ?? '/account/manage'));
$modeHint = syncLoginResolveModeHint($redirectPath);

if ($logged) {
	header('Location: ' . $redirectPath, true, 302);
	exit;
}

$syncToken = trim((string)($_GET['syncToken'] ?? $_GET['token'] ?? $_POST['syncToken'] ?? $_POST['token'] ?? ''));
if ($syncToken === '') {
	syncLoginFail('missing_sync_token', $redirectPath, $modeHint);
}

if (!preg_match('/^[a-f0-9]{64}$/i', $syncToken)) {
	syncLoginFail('invalid_sync_token', $redirectPath, $modeHint);
}

if (!$db->hasTable('account_sync_tokens')) {
	syncLoginFail('sync_schema_not_ready', $redirectPath, $modeHint);
}

$now = time();
$errorCode = '';
$accountRow = null;
$inTransaction = false;

try {
	$db->beginTransaction();
	$inTransaction = true;

	$syncQuery = $db->query(
		'SELECT `token`, `account_id`, `source`, `target`, `expires_at`, `used_at`
		 FROM `account_sync_tokens`
		 WHERE `token` = ' . $db->quote($syncToken) . '
		 LIMIT 1
		 FOR UPDATE'
	);

	if (!$syncQuery) {
		$errorCode = 'sync_consume_failed';
		throw new RuntimeException('sync query failed');
	}

	$syncRow = $syncQuery->fetch();
	if (!$syncRow) {
		$errorCode = 'invalid_sync_token';
		throw new RuntimeException('sync token not found');
	}

	if (!empty($syncRow['used_at'])) {
		$errorCode = 'sync_token_already_used';
		throw new RuntimeException('sync token already used');
	}

	if ((int)$syncRow['expires_at'] < $now) {
		$db->query('DELETE FROM `account_sync_tokens` WHERE `token` = ' . $db->quote($syncToken) . ' LIMIT 1');
		$errorCode = 'sync_token_expired';
		throw new RuntimeException('sync token expired');
	}

	if ((string)$syncRow['target'] !== 'www') {
		$errorCode = 'target_mismatch';
		throw new RuntimeException('sync token target mismatch');
	}

	if ((string)$syncRow['source'] !== 'launcher') {
		$errorCode = 'source_mismatch';
		throw new RuntimeException('sync token source mismatch');
	}

	$accountId = (int)$syncRow['account_id'];
	if ($accountId <= 0) {
		$errorCode = 'account_not_found';
		throw new RuntimeException('invalid account id');
	}

	$db->query(
		'UPDATE `account_sync_tokens`
		 SET `used_at` = NOW()
		 WHERE `token` = ' . $db->quote($syncToken) . '
		 LIMIT 1'
	);

	$accountQuery = $db->query(
		'SELECT `id`, `name`, `email`, `password`
		 FROM `accounts`
		 WHERE `id` = ' . $accountId . '
		 LIMIT 1'
	);

	if (!$accountQuery) {
		$errorCode = 'sync_consume_failed';
		throw new RuntimeException('account query failed');
	}

	$accountRow = $accountQuery->fetch();
	if (!$accountRow) {
		$errorCode = 'account_not_found';
		throw new RuntimeException('account not found');
	}

	$db->commit();
	$inTransaction = false;
} catch (Throwable $e) {
	if ($inTransaction) {
		$db->rollBack();
	}
}

if (!is_array($accountRow)) {
	if ($errorCode === '') {
		$errorCode = 'sync_consume_failed';
	}

	syncLoginFail($errorCode, $redirectPath, $modeHint);
}

session_regenerate_id();
setSession('account', (int)$accountRow['id']);
setSession('password', (string)$accountRow['password']);
setSession('last_visit', time());
setSession('global_profile_mode', 'all');

try {
	$accountLogged = new OTS_Account();
	$accountLogged->load((int)$accountRow['id']);
	if ($accountLogged->isLoaded()) {
		$accountLogged->setCustomField('web_lastlogin', time());
	}
} catch (Throwable $e) {
	// best effort; do not block login
}

$sessionPrefix = (string)setting('core.session_prefix');
if ($sessionPrefix !== '') {
	$_SESSION['account']['user'] = [
		'id' => (int)$accountRow['id'],
		'name' => (string)$accountRow['name'],
		'email' => (string)$accountRow['email'],
	];
	$_SESSION['login_timeout'] = time();
}

header('Location: ' . $redirectPath, true, 302);
exit;
