<?php
require_once SYSTEM . 'database_modern.php';

$sidebarServerMode = $_SESSION['server_mode'] ?? 'all';
$topPlayers = [];

// Classic players
if ($sidebarServerMode === 'all' || $sidebarServerMode === 'classic74') {
	$classicPlayers = getTopPlayers(5);
	foreach ($classicPlayers as &$p) {
		$p['server'] = 'Classic 7.4';
	}
	$topPlayers = array_merge($topPlayers, $classicPlayers);
}

// Modern players
if ($sidebarServerMode === 'all' || $sidebarServerMode === 'modern') {
	$modernDb = getModernDb();
	if ($modernDb) {
		$stmt = $modernDb->query('SELECT `id`, `name`, `level`, `experience`, `looktype`, `lookhead`, `lookbody`, `looklegs`, `lookfeet`, `lookaddons` FROM `players` WHERE `group_id` < 4 AND `account_id` != 1 AND `deletion` = 0 ORDER BY `experience` DESC LIMIT 5');
		$modernOnline = [];
		$onlineStmt = $modernDb->query('SELECT `player_id` FROM `players_online`');
		if ($onlineStmt) {
			foreach ($onlineStmt->fetchAll(PDO::FETCH_ASSOC) as $o) {
				$modernOnline[$o['player_id']] = true;
			}
		}
		$rank = 1;
		foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $mp) {
			$topPlayers[] = [
				'name' => $mp['name'],
				'level' => (int)$mp['level'],
				'experience' => (int)$mp['experience'],
				'looktype' => $mp['looktype'],
				'lookhead' => $mp['lookhead'],
				'lookbody' => $mp['lookbody'],
				'looklegs' => $mp['looklegs'],
				'lookfeet' => $mp['lookfeet'],
				'lookaddons' => $mp['lookaddons'] ?? 0,
				'online' => isset($modernOnline[$mp['id']]),
				'rank' => $rank++,
				'server' => 'Modern',
			];
		}
	}
}

// Sort by experience descending and re-rank
usort($topPlayers, function($a, $b) { return $b['experience'] - $a['experience']; });
$rank = 1;
foreach ($topPlayers as &$p) {
	$p['rank'] = $rank++;
}
unset($p);

// Limit to 5
$topPlayers = array_slice($topPlayers, 0, 5);

foreach($topPlayers as &$player) {
	$outfit_url = '';
	if (setting('core.online_outfit')) {
		$outfit_url = setting('core.outfit_images_url') . '?id=' . $player['looktype']	. (!empty
			($player['lookaddons']) ? '&addons=' . $player['lookaddons'] : '') . '&head=' . $player['lookhead'] . '&body=' . $player['lookbody'] . '&legs=' . $player['looklegs'] . '&feet=' . $player['lookfeet'];

		$player['outfit'] = $outfit_url;
	}
}

$twig->display('highscores.html.twig', array(
	'topPlayers' => $topPlayers
));
