<?php
/**
 * Online
 *
 * @package   MyAAC
 * @author    Gesior <jerzyskalski@wp.pl>
 * @author    Slawkens <slawkens@gmail.com>
 * @copyright 2019 MyAAC
 * @link      https://my-aac.org
 */

use MyAAC\Cache\Cache;
use MyAAC\Models\ServerConfig;
use MyAAC\Models\ServerRecord;

defined('MYAAC') or die('Direct access not allowed!');
require_once SYSTEM . 'database_modern.php';
$title = __('menu_who_online');

if (setting('core.account_country')) {
	require SYSTEM . 'countries.conf.php';
}

function onlineDualBuildSkullHtml(int $skullTime, int $skullType): string
{
	if ($skullTime <= 0) {
		return '';
	}

	if ($skullType === 3) {
		return ' <img style="border: 0;" src="images/white_skull.gif"/>';
	}

	if ($skullType === 4) {
		return ' <img style="border: 0;" src="images/red_skull.gif"/>';
	}

	if ($skullType === 5) {
		return ' <img style="border: 0;" src="images/black_skull.gif"/>';
	}

	return '';
}

function onlineDualHasTable(PDO $pdo, string $table): bool
{
	$stmt = $pdo->prepare(
		'SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?'
	);
	$stmt->execute([$table]);
	return (int)$stmt->fetchColumn() > 0;
}

function onlineDualHasColumn(PDO $pdo, string $table, string $column): bool
{
	$stmt = $pdo->prepare(
		'SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?'
	);
	$stmt->execute([$table, $column]);
	return (int)$stmt->fetchColumn() > 0;
}

function onlineDualBuildRecordLabel(int $record, int $timestamp = 0): string
{
	if ($record <= 0) {
		return '';
	}

	$label = __('online_record_players_count', ['COUNT' => $record]);
	if ($timestamp > 0) {
		$label .= __('online_record_on_date', ['DATE' => date('M d Y, H:i:s', $timestamp)]);
	}

	return $label;
}

function onlineDualFetchClassicRecord(): string
{
	global $db;

	if ($db->hasTable('server_record')) {
		$serverRecordQuery = ServerRecord::query();
		if ($db->hasColumn('server_record', 'world_id')) {
			$serverRecordQuery->where('world_id', configLua('worldId'));
		}

		$row = $serverRecordQuery->orderByDesc('record')->first();
		if ($row) {
			$data = $row->toArray();
			return onlineDualBuildRecordLabel((int)($data['record'] ?? 0), (int)($data['timestamp'] ?? 0));
		}
	}
	elseif ($db->hasTable('server_config')) {
		$row = ServerConfig::where('config', 'players_record')->first();
		if ($row) {
			return onlineDualBuildRecordLabel((int)$row->value);
		}
	}

	return '';
}

function onlineDualFetchModernRecord(?PDO $modernDb): string
{
	if (!$modernDb) {
		return '';
	}

	try {
		if (onlineDualHasTable($modernDb, 'server_record')) {
			$hasTimestamp = onlineDualHasColumn($modernDb, 'server_record', 'timestamp');
			$sql = 'SELECT record' . ($hasTimestamp ? ', `timestamp`' : '') . ' FROM server_record ORDER BY record DESC LIMIT 1';
			$stmt = $modernDb->query($sql);
			$row = $stmt ? $stmt->fetch(PDO::FETCH_ASSOC) : false;
			if (is_array($row)) {
				return onlineDualBuildRecordLabel((int)($row['record'] ?? 0), (int)($row['timestamp'] ?? 0));
			}
		}

		if (onlineDualHasTable($modernDb, 'server_config')) {
			$stmt = $modernDb->prepare("SELECT `value` FROM server_config WHERE `config` = 'players_record' LIMIT 1");
			$stmt->execute();
			$row = $stmt->fetch(PDO::FETCH_ASSOC);
			if (is_array($row)) {
				return onlineDualBuildRecordLabel((int)($row['value'] ?? 0));
			}
		}
	}
	catch (Throwable $e) {
		error_log('online dual record fetch failed: ' . $e->getMessage());
	}

	return '';
}

function onlineDualNormalizePlayer(
	array $player,
	string $serverKey,
	string $serverLabel,
	array $settingVocations,
	int $settingVocationsAmount,
	bool $outfitAddons
): array {
	$nameRaw = (string)($player['name'] ?? '');
	$vocationId = (int)($player['vocation'] ?? 0);
	$promotion = (int)($player['promotion'] ?? 0);

	if ($promotion > 0) {
		$vocationId += ($promotion * $settingVocationsAmount);
	}

	$vocationBaseId = $vocationId > $settingVocationsAmount ? ($vocationId - $settingVocationsAmount) : $vocationId;
	$vocationLabel = (string)($settingVocations[$vocationId] ?? ($settingVocations[$vocationBaseId] ?? $vocationId));

	$nameLink = getPlayerLink($nameRaw);
	if ($nameLink === '(error)' || $nameLink === '') {
		$nameLink = '<a href="' . getLink('characters') . '/' . urlencode($nameRaw) . '">' . htmlspecialchars($nameRaw, ENT_QUOTES, 'UTF-8') . '</a>';
	}

	return [
		'name' => $nameLink,
		'name_raw' => $nameRaw,
		'player' => $player,
		'level' => (int)($player['level'] ?? 0),
		'vocation' => $vocationLabel,
		'vocation_id' => $vocationId,
		'vocation_base_id' => $vocationBaseId,
		'skull' => onlineDualBuildSkullHtml((int)($player['skulltime'] ?? 0), (int)($player['skull'] ?? 0)),
		'country' => strtolower((string)($player['country'] ?? '')),
		'country_image' => getFlagImage((string)($player['country'] ?? '')),
		'outfit' => setting('core.outfit_images_url') . '?id=' . (int)($player['looktype'] ?? 0)
			. ($outfitAddons ? '&addons=' . (int)($player['lookaddons'] ?? 0) : '')
			. '&head=' . (int)($player['lookhead'] ?? 0)
			. '&body=' . (int)($player['lookbody'] ?? 0)
			. '&legs=' . (int)($player['looklegs'] ?? 0)
			. '&feet=' . (int)($player['lookfeet'] ?? 0),
		'server' => $serverKey,
		'server_label' => $serverLabel,
	];
}

function onlineDualSortPlayers(array &$players, string $order): void
{
	[$field, $direction] = explode('_', $order, 2);
	$direction = $direction === 'desc' ? -1 : 1;

	usort($players, static function(array $a, array $b) use ($field, $direction): int {
		$result = 0;
		if ($field === 'country') {
			$result = strcmp((string)($a['country'] ?? ''), (string)($b['country'] ?? ''));
		}
		elseif ($field === 'level') {
			$result = ((int)($a['level'] ?? 0)) <=> ((int)($b['level'] ?? 0));
		}
		elseif ($field === 'vocation') {
			$result = ((int)($a['vocation_id'] ?? 0)) <=> ((int)($b['vocation_id'] ?? 0));
		}
		else {
			$result = strcasecmp((string)($a['name_raw'] ?? ''), (string)($b['name_raw'] ?? ''));
		}

		if ($result === 0) {
			$result = strcasecmp((string)($a['name_raw'] ?? ''), (string)($b['name_raw'] ?? ''));
		}

		return $result * $direction;
	});
}

$order = strtolower(trim((string)($_GET['order'] ?? 'name_asc')));
$validOrders = ['country_asc', 'country_desc', 'name_asc', 'name_desc', 'level_asc', 'level_desc', 'vocation_asc', 'vocation_desc'];
if (!in_array($order, $validOrders, true)) {
	$order = 'name_asc';
}

$hasExplicitMode = isset($_GET['mode']);
$modeSessionFallback = (string)getSession('server_mode');
$globalProfileFallback = (string)getSession('global_profile_mode');
if (!$hasExplicitMode && in_array(strtolower(trim($globalProfileFallback)), ['classic74', 'modern'], true)) {
	$modeSessionFallback = $globalProfileFallback;
}
$modeInput = urldecode($_GET['mode'] ?? $modeSessionFallback);
$mode = strtolower(trim((string)$modeInput));
if (in_array($mode, ['', 'all', 'both', 'global'], true)) {
	$mode = 'all';
}
elseif (in_array($mode, ['classic74', 'classic', 'retro', 'retro74', '7.4', '74'], true)) {
	$mode = 'classic74';
}
elseif (in_array($mode, ['modern', 'main', '14', '14.20', 'latest'], true)) {
	$mode = 'modern';
}
else {
	$mode = 'all';
}
setSession('server_mode', $mode);
if (getSession('account')) {
	setSession('global_profile_mode', $mode);
}

$cacheKey = "online_{$mode}_{$order}";
$cacheTtl = setting('core.online_cache_ttl') * 60;

$cached = Cache::remember($cacheKey, $cacheTtl, function() use($db, $mode, $order) {
	$settingVocations = (array)setting('core.vocations');
	$settingVocationsAmount = (int)setting('core.vocations_amount');

	$vocations = [];
	foreach ($settingVocations as $id => $vocationName) {
		$vocations[(int)$id] = 0;
	}

	$players = [];
	$counts = [
		'classic74' => 0,
		'modern' => 0,
		'total' => 0,
	];

	$skullType = $db->hasColumn('players', 'skull_type') ? 'skull_type' : 'skull';
	$skullTime = $db->hasColumn('players', 'skull_time') ? 'skull_time' : 'skulltime';
	$outfitAddons = $db->hasColumn('players', 'lookaddons');
	$classicPromotion = $db->hasColumn('players', 'promotion') ? ', `players`.`promotion`' : '';
	$outfitColumns = ', `players`.`lookbody`, `players`.`lookfeet`, `players`.`lookhead`, `players`.`looklegs`, `players`.`looktype`';
	if ($outfitAddons) {
		$outfitColumns .= ', `players`.`lookaddons`';
	}

	if ($mode === 'all' || $mode === 'classic74') {
		if ($db->hasTable('players_online')) {
			$sqlClassic = 'SELECT `accounts`.`country`, `players`.`name`, `players`.`level`, `players`.`vocation`' .
				$outfitColumns . $classicPromotion . ', `' . $skullTime . '` AS `skulltime`, `' . $skullType . '` AS `skull`
				FROM `accounts`, `players`, `players_online`
				WHERE `players`.`id` = `players_online`.`player_id`
				AND `accounts`.`id` = `players`.`account_id`';
		}
		else {
			$sqlClassic = 'SELECT `accounts`.`country`, `players`.`name`, `players`.`level`, `players`.`vocation`' .
				$outfitColumns . $classicPromotion . ', `' . $skullTime . '` AS `skulltime`, `' . $skullType . '` AS `skull`
				FROM `accounts`, `players`
				WHERE `players`.`online` > 0
				AND `accounts`.`id` = `players`.`account_id`';
		}

		$playersOnlineClassic = $db->query($sqlClassic);
		foreach ($playersOnlineClassic as $player) {
			$normalized = onlineDualNormalizePlayer(
				(array)$player,
				'classic74',
				__('server_classic74'),
				$settingVocations,
				$settingVocationsAmount,
				$outfitAddons
			);
			$players[] = $normalized;
		}
	}

	$modernDb = getModernDb();
	if (($mode === 'all' || $mode === 'modern') && $modernDb !== null) {
		try {
			$modernOutfitAddons = onlineDualHasColumn($modernDb, 'players', 'lookaddons');
			$modernPromotion = onlineDualHasColumn($modernDb, 'players', 'promotion');
			$modernSkullType = onlineDualHasColumn($modernDb, 'players', 'skull_type') ? 'skull_type' : 'skull';
			$modernSkullTime = onlineDualHasColumn($modernDb, 'players', 'skull_time') ? 'skull_time' : 'skulltime';
			$modernHasOnlineTable = onlineDualHasTable($modernDb, 'players_online');
			$modernHasOnlineColumn = onlineDualHasColumn($modernDb, 'players', 'online');
			$modernDeletionColumn = onlineDualHasColumn($modernDb, 'players', 'deletion') ? 'deletion'
				: (onlineDualHasColumn($modernDb, 'players', 'deleted') ? 'deleted' : '');
			$modernHasAccounts = onlineDualHasTable($modernDb, 'accounts');
			$modernHasCountry = $modernHasAccounts && onlineDualHasColumn($modernDb, 'accounts', 'country');

			$sqlModern = 'SELECT ' . ($modernHasCountry ? 'a.country AS country' : "'' AS country")
				. ', p.name, p.level, p.vocation'
				. ', p.lookbody, p.lookfeet, p.lookhead, p.looklegs, p.looktype'
				. ($modernOutfitAddons ? ', p.lookaddons' : ', 0 AS lookaddons')
				. ($modernPromotion ? ', p.promotion' : ', 0 AS promotion')
				. ', p.`' . $modernSkullTime . '` AS skulltime, p.`' . $modernSkullType . '` AS skull'
				. ' FROM players p';

			if ($modernHasCountry) {
				$sqlModern .= ' LEFT JOIN accounts a ON a.id = p.account_id';
			}
			if ($modernHasOnlineTable) {
				$sqlModern .= ' INNER JOIN players_online po ON po.player_id = p.id';
			}

			$where = [];
			if ($modernDeletionColumn !== '') {
				$where[] = 'p.`' . $modernDeletionColumn . '` = 0';
			}
			if (!$modernHasOnlineTable && $modernHasOnlineColumn) {
				$where[] = 'p.online > 0';
			}

			if (!empty($where)) {
				$sqlModern .= ' WHERE ' . implode(' AND ', $where);
			}

			$stmt = $modernDb->query($sqlModern);
			$playersOnlineModern = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
			foreach ($playersOnlineModern as $player) {
				$normalized = onlineDualNormalizePlayer(
					$player,
					'modern',
					__('server_modern'),
					$settingVocations,
					$settingVocationsAmount,
					$modernOutfitAddons
				);
				$players[] = $normalized;
			}
		}
		catch (Throwable $e) {
			error_log('online dual modern query failed: ' . $e->getMessage());
		}
	}

	onlineDualSortPlayers($players, $order);

	foreach ($players as $player) {
		$server = (string)($player['server'] ?? 'classic74');
		if ($server === 'modern') {
			$counts['modern']++;
		}
		else {
			$counts['classic74']++;
		}

		$baseVocation = (int)($player['vocation_base_id'] ?? 0);
		if (isset($vocations[$baseVocation])) {
			$vocations[$baseVocation]++;
		}
	}
	$counts['total'] = count($players);

	$record = '';
	if (setting('core.online_record') && $counts['total'] > 0) {
		if ($mode === 'classic74') {
			$record = onlineDualFetchClassicRecord();
		}
		elseif ($mode === 'modern') {
			$record = onlineDualFetchModernRecord($modernDb);
		}
		else {
			$classicRecord = onlineDualFetchClassicRecord();
			$modernRecord = onlineDualFetchModernRecord($modernDb);

			if ($classicRecord !== '' && $modernRecord !== '') {
				$record = __('server_classic74') . ': ' . $classicRecord . ' | ' . __('server_modern') . ': ' . $modernRecord;
			}
			elseif ($classicRecord !== '') {
				$record = __('server_classic74') . ': ' . $classicRecord;
			}
			elseif ($modernRecord !== '') {
				$record = __('server_modern') . ': ' . $modernRecord;
			}
		}
	}

	return [
		'players' => $players,
		'record' => $record,
		'vocations' => $vocations,
		'counts' => $counts,
	];
});

$modeQuery = '&mode=' . urlencode($mode);
$modes = [
	[
		'key' => 'all',
		'name' => __('server_all'),
		'link' => getLink('online') . '?order=' . urlencode($order) . '&mode=all',
	],
	[
		'key' => 'classic74',
		'name' => __('server_classic74'),
		'link' => getLink('online') . '?order=' . urlencode($order) . '&mode=classic74',
	],
	[
		'key' => 'modern',
		'name' => __('server_modern'),
		'link' => getLink('online') . '?order=' . urlencode($order) . '&mode=modern',
	],
];

$twig->display('online.html.twig', array(
	'players' => $cached['players'],
	'record' => $cached['record'],
	'vocations' => $cached['vocations'],
	'vocs' => $cached['vocations'], // deprecated, to be removed
	'counts' => $cached['counts'],
	'order' => $order,
	'mode' => $mode,
	'modes' => $modes,
	'modeQuery' => $modeQuery,
));

// search bar
$twig->display('characters.form.html.twig');
