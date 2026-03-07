<?php
/**
 * Account management
 *
 * @package   MyAAC
 * @author    Gesior <jerzyskalski@wp.pl>
 * @author    Slawkens <slawkens@gmail.com>
 * @copyright 2019 MyAAC
 * @link      https://my-aac.org
 */
defined('MYAAC') or die('Direct access not allowed!');

$title = 'Account Management';
require __DIR__ . '/login.php';
require __DIR__ . '/base.php';
require __DIR__ . '/global-profile.php';

if(!$logged) {
	return;
}

if(isset($_REQUEST['redirect']))
{
	$redirect = urldecode($_REQUEST['redirect']);

	// should never happen, unless hacker modify the URL
	if (!str_contains($redirect, BASE_URL)) {
		error('Fatal error: Cannot redirect outside the website.');
		return;
	}

	$twig->display('account.redirect.html.twig', array(
		'redirect' => $redirect
	));
	return;
}

csrfProtect();

$groups = new OTS_Groups_List();

$freePremium = isset($config['lua']['freePremium']) && getBoolean($config['lua']['freePremium']) || $account_logged->getPremDays() == OTS_Account::GRATIS_PREMIUM_DAYS;
$dayOrDays = $account_logged->getPremDays() == 1 ? 'day' : 'days';
/**
 * @var OTS_Account $account_logged
 */
if(!$account_logged->isPremium())
	$account_status = '<b><span style="color: red">Free Account</span></b>';
else
	$account_status = '<b><span style="color: green">' . ($freePremium ? 'Gratis Premium Account' : 'Premium Account, ' . $account_logged->getPremDays() . ' '.$dayOrDays.' left') . '</span></b>';

$recovery_key = $account_logged->getCustomField('key');
if(empty($recovery_key))
	$account_registered = '<b><span style="color: red">No</span></b>';
else
{
	if(setting('core.account_generate_new_reckey') && setting('core.mail_enabled'))
		$account_registered = '<b><span style="color: green">Yes ( <a href="' . getLink('account/register-new') . '"> Buy new Recovery Key </a> )</span></b>';
	else
		$account_registered = '<b><span style="color: green">Yes</span></b>';
}

$account_created = $account_logged->getCreated();
$account_email = $account_logged->getEMail();
$email_new_time = $account_logged->getCustomField("email_new_time");
if($email_new_time > 1)
	$email_new = $account_logged->getCustomField("email_new");
$account_rlname = $account_logged->getRLName();
$account_location = $account_logged->getLocation();
if($account_logged->isBanned())
	if($account_logged->getBanTime() > 0)
		$welcome_message = '<span style="color: red">Your account is banished until '.date("j F Y, G:i:s", $account_logged->getBanTime()).'!</span>';
	else
		$welcome_message = '<span style="color: red">Your account is banished FOREVER!</span>';
else
	$welcome_message = 'Welcome to your account!';

$email_change = '';
$email_request = false;
if($email_new_time > 1)
{
	if($email_new_time < time())
		$email_change = '<br>(You can accept <b>'.$email_new.'</b> as a new email.)';
	else
	{
		$email_change = ' <br>You can accept <b>new e-mail after '.date("j F Y", $email_new_time).".</b>";
		$email_request = true;
	}
}

$actions = array();
foreach($account_logged->getActionsLog(0, 1000) as $action) {
	$actions[] = array('action' => $action['action'], 'date' => $action['date'], 'ip' => $action['ip'] != 0 ? long2ip($action['ip']) : inet_ntop($action['ipv6']));
}

$players = array();
/** @var OTS_Players_List $account_players */
$account_players = $account_logged->getPlayersList();
$account_players->orderBy('id');

$worldLabels = [
	'classic74' => 'Classic 7.4',
	'modern' => 'Modern',
	'unknown' => 'Unknown',
];
if (isset($config['worlds'][0])) {
	$worldLabels['classic74'] = (string)$config['worlds'][0];
}
if (isset($config['worlds'][1])) {
	$worldLabels['modern'] = (string)$config['worlds'][1];
}

$charactersByWorld = [
	'classic74' => [],
	'modern' => [],
	'unknown' => [],
];
foreach ($account_players as $player) {
	$worldId = 0;
	try {
		$worldId = (int)$player->getWorldId();
	} catch (\Throwable $e) {
		$worldId = (int)$player->getCustomField('world');
	}
	$entry = [
		'name' => $player->getName(),
		'level' => (int)$player->getLevel(),
		'vocation' => (string)($config['vocations'][$player->getVocation()] ?? $player->getVocation()),
		'online' => $player->isOnline(),
		'deleted' => $player->isDeleted(),
		'editName' => urlencode($player->getName()),
		'worldId' => $worldId,
		'outfit' => setting('core.online_outfit') ? $player->getOutfit() : '',
	];

	if ($worldId === 0) {
		$charactersByWorld['classic74'][] = $entry;
	} elseif ($worldId === 1) {
		$charactersByWorld['modern'][] = $entry;
	} else {
		$charactersByWorld['unknown'][] = $entry;
	}
}

$requestedActiveMode = (string)($_GET['active_mode'] ?? $_POST['active_mode'] ?? '');
if ($requestedActiveMode !== '') {
	globalProfileSetActiveMode($requestedActiveMode);
}
$activeProfileMode = globalProfileGetActiveMode('all');
$activeProfileLabel = globalProfileModeLabel($activeProfileMode, $worldLabels);

$filteredCharacters = $charactersByWorld;
if ($activeProfileMode === 'classic74') {
	$filteredCharacters['modern'] = [];
	$filteredCharacters['unknown'] = [];
} elseif ($activeProfileMode === 'modern') {
	$filteredCharacters['classic74'] = [];
	$filteredCharacters['unknown'] = [];
}

// Server status info for account page
require_once SYSTEM . 'database_modern.php';
$serverStatus = [
	'classic74' => ['online' => false, 'players' => 0],
	'modern' => ['online' => false, 'players' => 0],
];
// Classic server — check players_online table
try {
	$classicOnline = $db->query('SELECT COUNT(*) AS cnt FROM `players_online`')->fetch();
	$serverStatus['classic74']['online'] = true;
	$serverStatus['classic74']['players'] = (int)($classicOnline['cnt'] ?? 0);
} catch (\Throwable $e) {
	$serverStatus['classic74']['online'] = false;
}
// Modern server
$mDb = getModernDb();
if ($mDb) {
	try {
		$stmt = $mDb->query('SELECT COUNT(*) AS cnt FROM `players_online`');
		$serverStatus['modern']['online'] = true;
		$serverStatus['modern']['players'] = (int)($stmt->fetchColumn() ?: 0);
	} catch (\Throwable $e) {
		$serverStatus['modern']['online'] = false;
	}
} else {
	$serverStatus['modern']['online'] = false;
}

$twig->display('account.management.html.twig', array(
	'welcome_message' => $welcome_message,
	'recovery_key' => $recovery_key,
	'email_change' => $email_change,
	'email_request' => $email_request,
	'email_new_time' => $email_new_time,
	'email_new' => isset($email_new) ? $email_new : '',
	'account' => (USE_ACCOUNT_NAME ? $account_logged->getName() : (USE_ACCOUNT_NUMBER ? $account_logged->getNumber() : $account_logged->getId())),
	'account_email' => $account_email,
	'account_created' => $account_created,
	'account_status' => $account_status,
	'account_registered' => $account_registered,
	'account_rlname' => $account_rlname,
	'account_location' => $account_location,
	'actions' => $actions,
	'players' => $account_players,
	'characters_by_world' => $filteredCharacters,
	'characters_by_world_raw' => $charactersByWorld,
	'world_labels' => $worldLabels,
	'active_profile_mode' => $activeProfileMode,
	'active_profile_label' => $activeProfileLabel,
	'server_status' => $serverStatus,
));
