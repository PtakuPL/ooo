<?php
/**
 * Switch active global profile mode for WWW account session.
 */
defined('MYAAC') or die('Direct access not allowed!');

$title = 'Switch Account Profile';
require __DIR__ . '/base.php';
require __DIR__ . '/global-profile.php';

if(!$logged) {
	return;
}

csrfProtect();

$mode = (string)($_POST['mode'] ?? $_GET['mode'] ?? 'all');
$mode = globalProfileSetActiveMode($mode);

$redirect = (string)($_POST['redirect'] ?? $_GET['redirect'] ?? '/account/manage');
$redirect = trim($redirect);
if ($redirect === '' || str_starts_with($redirect, 'http://') || str_starts_with($redirect, 'https://')) {
	$redirect = '/account/manage';
}
if ($redirect[0] !== '/') {
	$redirect = '/account/manage';
}

$joiner = str_contains($redirect, '?') ? '&' : '?';
header('Location: ' . $redirect . $joiner . 'active_mode=' . urlencode($mode), true, 302);
exit;
