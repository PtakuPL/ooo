<?php
/**
 * Highscores
 *
 * @package   MyAAC
 * @author    Gesior <jerzyskalski@wp.pl>
 * @author    Slawkens <slawkens@gmail.com>
 * @copyright 2019 MyAAC
 * @link      https://my-aac.org
 */

use MyAAC\Cache\Cache;
use MyAAC\Models\Player;
use MyAAC\Models\PlayerDeath;
use MyAAC\Models\PlayerKillers;

defined('MYAAC') or die('Direct access not allowed!');
require_once SYSTEM . 'database_modern.php';
$title = __('menu_highscores');

function formatHighscoresOnlineTime(int $seconds): string
{
	if ($seconds < 0) {
		$seconds = 0;
	}

	$days = intdiv($seconds, 86400);
	$hours = intdiv($seconds % 86400, 3600);
	$minutes = intdiv($seconds % 3600, 60);

	$parts = [];
	if ($days > 0) {
		$parts[] = $days . __('highscores_time_days_short');
	}
	if ($hours > 0 || $days > 0) {
		$parts[] = $hours . __('highscores_time_hours_short');
	}
	$parts[] = $minutes . __('highscores_time_minutes_short');

	return implode(' ', $parts);
}

$settingHighscoresCountryBox = setting('core.highscores_country_box');
if(config('account_country') && $settingHighscoresCountryBox) {
	require SYSTEM . 'countries.conf.php';
}

$highscoresTTL = setting('core.highscores_cache_ttl');

$list = urldecode($_GET['list'] ?? 'experience');
$page = $_GET['page'] ?? 1;
$vocation = urldecode($_GET['vocation'] ?? 'all');
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

if(!is_numeric($page) || $page < 1 || $page > PHP_INT_MAX) {
	$page = 1;
}

$query = Player::query();

$configVocations = config('vocations');
$configVocationsAmount = config('vocations_amount');
$localizedVocations = [
	'None' => __('vocation_none'),
	'Sorcerer' => __('vocation_sorcerer'),
	'Druid' => __('vocation_druid'),
	'Paladin' => __('vocation_paladin'),
	'Knight' => __('vocation_knight'),
];
$localizeVocationName = static function(string $name) use ($localizedVocations): string {
	return $localizedVocations[$name] ?? $name;
};

// Canonical English slugs for vocation URLs (always ASCII-safe)
$vocationSlugs = ['none', 'sorcerer', 'druid', 'paladin', 'knight'];
// Reverse map: English slug -> base vocation id
$slugToVocationId = [];
foreach ($vocationSlugs as $idx => $slug) {
	$slugToVocationId[$slug] = $idx;
}

$vocationId = null;
if($vocation !== 'all') {
	// First try matching by English slug
	if (isset($slugToVocationId[strtolower($vocation)])) {
		$id = $slugToVocationId[strtolower($vocation)];
		$vocationId = $id;
		$add_vocs = [$id];
		if ($id !== 0) {
			$i = $id + $configVocationsAmount;
			while (isset($configVocations[$i])) {
				$add_vocs[] = $i;
				$i += $configVocationsAmount;
			}
		}
		$query->whereIn('players.vocation', $add_vocs);
	} else {
	// Fallback: try matching by config vocation name (e.g. Polish)
	foreach($configVocations as $id => $name) {
		if(strtolower($name) == $vocation) {
			$vocationId = $id;
			$add_vocs = [$id];

			if ($id !== 0) {
				$i = $id + $configVocationsAmount;
				while (isset($configVocations[$i])) {
					$add_vocs[] = $i;
					$i += $configVocationsAmount;
				}
			}

			$query->whereIn('players.vocation', $add_vocs);
			break;
		}
	}
	} // end else (fallback)
}

$skill = POT::SKILL__LEVEL;
if(is_numeric($list))
{
	$list = (int) $list;
	if($list >= POT::SKILL_FIRST && $list <= POT::SKILL__LAST)
		$skill = $list;
}
else
{
	switch($list)
	{
		case 'fist':
			$skill = POT::SKILL_FIST;
			break;

		case 'club':
			$skill = POT::SKILL_CLUB;
			break;

		case 'sword':
			$skill = POT::SKILL_SWORD;
			break;

		case 'axe':
			$skill = POT::SKILL_AXE;
			break;

		case 'distance':
			$skill = POT::SKILL_DIST;
			break;

		case 'shield':
			$skill = POT::SKILL_SHIELD;
			break;

		case 'fishing':
			$skill = POT::SKILL_FISH;
			break;

		case 'level':
		case 'experience':
			$skill = POT::SKILL_LEVEL;
			break;

		case 'magic':
			$skill = POT::SKILL__MAGLEVEL;
			break;

		case 'frags':
			if(setting('core.highscores_frags'))
				$skill = SKILL_FRAGS;
			break;

		case 'balance':
			if(setting('core.highscores_balance'))
				$skill = SKILL_BALANCE;
			break;

		case 'onlinetime':
		case 'online-time':
		case 'playtime':
		case 'time':
			$skill = SKILL_ONLINETIME;
			$list = 'onlinetime';
			break;
	}
}

$promotion = '';
if($db->hasColumn('players', 'promotion'))
	$promotion = ',players.promotion';

$outfit_addons = false;
$outfit = ', lookbody, lookfeet, lookhead, looklegs, looktype';
if($db->hasColumn('players', 'lookaddons')) {
	$outfit .= ', lookaddons';
	$outfit_addons = true;
}

$configHighscoresPerPage = setting('core.highscores_per_page');
$limit = $configHighscoresPerPage + 1;

$highscores = [];
$needReCache = true;
$cacheKey = 'highscores_' . $skill . '_' . $vocation . '_' . $mode . '_' . $page . '_' . $configHighscoresPerPage;

$cache = Cache::getInstance();
if ($cache->enabled() && $highscoresTTL > 0) {
	$tmp = '';
	if ($cache->fetch($cacheKey, $tmp)) {
		$data = unserialize($tmp);
		$totalResults = $data['totalResults'];
		$highscores = $data['highscores'];
		$updatedAt = $data['updatedAt'];
		$needReCache = false;
	}
}

$offset = ($page - 1) * $configHighscoresPerPage;
$query->withOnlineStatus()
	->whereNotIn('players.id', setting('core.highscores_ids_hidden'))
	->notDeleted()
	->where('players.group_id', '<', setting('core.highscores_groups_hidden'));

$worldColumn = null;
if ($db->hasColumn('players', 'world')) {
	$worldColumn = 'players.world';
}
elseif ($db->hasColumn('players', 'world_id')) {
	$worldColumn = 'players.world_id';
}

// For mode=modern, we query canary_modern database directly (K50 dual PDO).
// For mode=classic74, we query canaryaac (default, no world filter needed).
// For mode=all, we query canaryaac first, then append modern results.
// The old world-column filter is kept only as fallback for single-DB setups.
$useModernDb = ($mode === 'modern' || $mode === 'all') && getModernDb() !== null;

if ($mode === 'classic74' && $worldColumn !== null) {
	// In single-DB setups, still filter by world column
	// In dual-DB (Option B), no filter needed — canaryaac IS the classic server
}

// If mode is strictly "modern" and we have dual PDO, skip the main Eloquent query
$skipMainQuery = ($mode === 'modern' && $useModernDb);
$mergeLimit = $offset + $limit;
$classicLimit = ($mode === 'all' && $useModernDb) ? $mergeLimit : $limit;
$classicOffset = ($mode === 'all' && $useModernDb) ? 0 : $offset;

$totalResultsQuery = clone $query;

$query
	->join('accounts', 'accounts.id', '=', 'players.account_id')
	->limit($classicLimit)
	->offset($classicOffset)
	->selectRaw('accounts.country, players.id, players.name, players.account_id, players.level, players.vocation' . $outfit . $promotion)
	->orderByDesc('value');

// --- K50: Helper to query canary_modern highscores via raw PDO ---
function queryModernHighscores(PDO $modernPdo, int $skill, ?int $vocationId, array $addVocs, int $limit, int $offset): array {
	$skillMap = [
		POT::SKILL_FIST => 'skill_fist', POT::SKILL_CLUB => 'skill_club',
		POT::SKILL_SWORD => 'skill_sword', POT::SKILL_AXE => 'skill_axe',
		POT::SKILL_DIST => 'skill_dist', POT::SKILL_SHIELD => 'skill_shielding',
		POT::SKILL_FISH => 'skill_fishing',
	];

	if ($skill >= POT::SKILL_FIRST && $skill <= POT::SKILL_LAST && isset($skillMap[$skill])) {
		$valueCol = 'p.' . $skillMap[$skill];
	} elseif ($skill == POT::SKILL__MAGLEVEL) {
		$valueCol = 'p.maglevel';
	} elseif ($skill == SKILL_ONLINETIME) {
		$valueCol = 'p.onlinetime';
	} else {
		$valueCol = 'p.level';
	}

	$sql = "SELECT p.id, p.name, p.level, p.vocation, p.account_id,
			p.lookbody, p.lookfeet, p.lookhead, p.looklegs, p.looktype,
			{$valueCol} AS value";
	if ($skill == POT::SKILL__LEVEL || $skill == POT::SKILL_LEVEL) {
		$sql .= ", p.experience";
	}
	if ($skill == POT::SKILL__MAGLEVEL) {
		$sql .= ", p.maglevel";
	}
	$sql .= " FROM players p WHERE p.group_id < 4 AND p.deletion = 0";

	$params = [];
	if ($vocationId !== null && !empty($addVocs)) {
		$placeholders = implode(',', array_fill(0, count($addVocs), '?'));
		$sql .= " AND p.vocation IN ({$placeholders})";
		$params = array_values($addVocs);
	}

	$sql .= " ORDER BY value DESC";
	if ($skill == POT::SKILL__LEVEL || $skill == POT::SKILL_LEVEL) {
		$sql .= ", p.experience DESC";
	}
	$sql .= " LIMIT " . (int)$limit . " OFFSET " . (int)$offset;

	$stmt = $modernPdo->prepare($sql);
	$stmt->execute($params);
	return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

function countModernPlayers(PDO $modernPdo, ?int $vocationId, array $addVocs): int {
	$sql = "SELECT COUNT(*) FROM players WHERE group_id < 4 AND deletion = 0";
	$params = [];
	if ($vocationId !== null && !empty($addVocs)) {
		$placeholders = implode(',', array_fill(0, count($addVocs), '?'));
		$sql .= " AND vocation IN ({$placeholders})";
		$params = array_values($addVocs);
	}
	$stmt = $modernPdo->prepare($sql);
	$stmt->execute($params);
	return (int)$stmt->fetchColumn();
}
// --- END K50 helper ---

if (empty($highscores)) {
	if ($skipMainQuery) {
		// Mode=modern with dual PDO: query only canary_modern
		$modernPdo = getModernDb();
		if ($modernPdo) {
			$highscores = queryModernHighscores($modernPdo, $skill, $vocationId, $add_vocs ?? [], $limit, $offset);
			$totalResults = countModernPlayers($modernPdo, $vocationId, $add_vocs ?? []);
			// Add missing fields for template compatibility
			foreach ($highscores as &$row) {
				$row['country'] = '';
				$row['online'] = 0;
				$row['vocation'] = config('vocations')[$row['vocation']] ?? __('vocation_unknown');
				$row['outfit_url'] = '';
				$row['server'] = 'modern';
			}
			unset($row);
		}
		$updatedAt = time();
	} else {
	if ($skill >= POT::SKILL_FIRST && $skill <= POT::SKILL_LAST) { // skills
		if ($db->hasColumn('players', 'skill_fist')) {// tfs 1.0
			$skill_ids = array(
				POT::SKILL_FIST => 'skill_fist',
				POT::SKILL_CLUB => 'skill_club',
				POT::SKILL_SWORD => 'skill_sword',
				POT::SKILL_AXE => 'skill_axe',
				POT::SKILL_DIST => 'skill_dist',
				POT::SKILL_SHIELD => 'skill_shielding',
				POT::SKILL_FISH => 'skill_fishing',
			);

			$query->addSelect($skill_ids[$skill] . ' as value');
		} else {
			$query
				->join('player_skills', 'player_skills.player_id', '=', 'players.id')
				->where('skillid', $skill)
				->addSelect('player_skills.value as value');
		}
	} else if ($skill == SKILL_FRAGS) // frags
	{
		if ($db->hasTable('player_killers')) {
			$query->addSelect(['value' => PlayerKillers::whereColumn('player_killers.player_id', 'players.id')->selectRaw('COUNT(*)')]);
		} else {
			$query->addSelect(['value' => PlayerDeath::unjustified()->whereColumn('player_deaths.killed_by', 'players.name')->selectRaw('COUNT(*)')]);
		}
	} else if ($skill == SKILL_BALANCE) // balance
	{
		$query
			->addSelect('players.balance as value');
	} else if ($skill == SKILL_ONLINETIME) // online time
	{
		$query
			->addSelect('players.onlinetime as value');
	} else {
		if ($skill == POT::SKILL__MAGLEVEL) {
			$query
				->addSelect('players.maglevel as value', 'players.maglevel')
				->orderBy('manaspent');
		} else { // level
			$query
				->addSelect('players.level as value', 'players.experience')
				->orderBy('experience');
			$list = 'experience';
		}
	}

			$highscores = $query->get()->map(function($row) {
				$tmp = $row->toArray();
				$tmp['online'] = $row->online_status;
				$tmp['vocation'] = $row->vocation_name;
				$tmp['outfit_url'] = $row->outfit_url; // @phpstan-ignore-line
				$tmp['server'] = 'classic74';
				unset($tmp['online_table']);

		return $tmp;
	})->toArray();

	$updatedAt = time();
	$totalResults = $totalResultsQuery->count();

	// K50: For mode=all, append modern results
		if ($mode === 'all' && $useModernDb) {
			$modernPdo = getModernDb();
			if ($modernPdo) {
				$modernRows = queryModernHighscores($modernPdo, $skill, $vocationId, $add_vocs ?? [], $mergeLimit, 0);
				foreach ($modernRows as &$row) {
					$row['country'] = '';
					$row['online'] = 0;
				$row['vocation'] = config('vocations')[$row['vocation']] ?? __('vocation_unknown');
				$row['outfit_url'] = '';
				$row['server'] = 'modern';
			}
			unset($row);
			$highscores = array_merge($highscores, $modernRows);
			usort($highscores, function($a, $b) { return ($b['value'] ?? 0) <=> ($a['value'] ?? 0); });
			$totalResults += countModernPlayers($modernPdo, $vocationId, $add_vocs ?? []);
			$highscores = array_slice($highscores, $offset, $configHighscoresPerPage + 1);
		}
	}
	} // close else from $skipMainQuery
}

if ($highscoresTTL > 0 && $cache->enabled() && $needReCache) {
	$cache->set($cacheKey, serialize(
		[
			'totalResults' => $totalResults,
			'highscores' => $highscores,
			'updatedAt' => $updatedAt,
		]
	), $highscoresTTL * 60);
}

$show_link_to_next_page = false;
$i = 0;

foreach($highscores as $id => &$player)
{
	if(++$i <= $configHighscoresPerPage)
	{
		$player['vocation'] = $localizeVocationName((string)($player['vocation'] ?? ''));
		if($skill == POT::SKILL__MAGLEVEL)
			$player['value'] = $player['maglevel'];
		else if($skill == POT::SKILL__LEVEL) {
			$player['value'] = $player['level'];
			$player['experience'] = number_format($player['experience']);
		}
		else if($skill == SKILL_ONLINETIME) {
			$player['value'] = (int)($player['value'] ?? 0);
			$player['value_formatted'] = formatHighscoresOnlineTime((int)$player['value']);
		}

			$player['link'] = getPlayerLink($player['name'], false);
			if ($player['link'] === '(error)' || empty($player['link'])) {
				$player['link'] = getLink('characters') . '/' . urlencode($player['name']);
			}
			$player['flag'] = getFlagImage($player['country']);
			$player['outfit'] = '<img style="position:absolute;margin-top:' . (in_array($player['looktype'], setting('core.outfit_images_wrong_looktypes')) ? '-15px;margin-left:5px' : '-45px;margin-left:-25px') . ';" src="' . $player['outfit_url'] . '" alt="" />';
			$player['server_label'] = match ($player['server'] ?? 'classic74') {
				'modern' => __('server_modern'),
				default => __('server_classic74'),
			};

		if ($skill != POT::SKILL__LEVEL) {
			if (isset($lastValue) && $lastValue == $player['value']) {
				$player['rank'] = $lastRank;
			}
			else {
				$player['rank'] = $offset + $i;
			}

			$lastRank = $player['rank'] ;
			$lastValue = $player['value'];
		}
		else {
			$player['rank'] = $offset + $i;
		}
	}
	else {
		unset($highscores[$id]);
		$show_link_to_next_page = true;
		break;
	}
}

$vocationUrlPart = ($vocationId !== null && isset($vocationSlugs[$vocationId])) ? '/' . $vocationSlugs[$vocationId] : '';

//link to previous page if actual page is not first
$linkPreviousPage = '';
if($page > 1) {
	$linkPreviousPage = getLink('highscores') . '/' . $list . $vocationUrlPart . '/' . ($page - 1) . '?mode=' . urlencode($mode);
}

//link to next page if any result will be on next page
$linkNextPage = '';
if($show_link_to_next_page) {
	$linkNextPage = getLink('highscores') . '/' . $list . $vocationUrlPart . '/' . ($page + 1) . '?mode=' . urlencode($mode);
}

$baseLink = getLink('highscores') . '/' . $list . $vocationUrlPart . '/' . '?mode=' . urlencode($mode);
$modeQuery = '?mode=' . urlencode($mode);

$modes = [
	[
		'key' => 'all',
		'name' => __('server_all'),
		'link' => getLink('highscores') . '/' . $list . $vocationUrlPart . '?mode=all',
	],
	[
		'key' => 'classic74',
		'name' => __('server_classic74'),
		'link' => getLink('highscores') . '/' . $list . $vocationUrlPart . '?mode=classic74',
	],
	[
		'key' => 'modern',
		'name' => __('server_modern'),
		'link' => getLink('highscores') . '/' . $list . $vocationUrlPart . '?mode=modern',
	],
];

$types = array(
	'experience' => __('category_experience_points'),
	'magic' => __('category_magic_level'),
	'shield' => __('category_shielding'),
	'distance' => __('category_distance_fighting'),
	'club' => __('category_club_fighting'),
	'sword' => __('category_sword_fighting'),
	'axe' => __('category_axe_fighting'),
	'fist' => __('category_fist_fighting'),
	'fishing' => __('category_fishing'),
	'onlinetime' => __('category_online_time'),
);

if(setting('core.highscores_frags')) {
	$types['frags'] = __('category_frags');
}
if(setting('core.highscores_balance'))
	$types['balance'] = __('category_balance');

if ($highscoresTTL > 0 && $cache->enabled()) {
	echo '<small>*' . __('highscores_note_updated_every', ['MINUTES' => $highscoresTTL]) . '</small><br/><br/>';
}

$modeLabel = match ($mode) {
	'classic74' => configLua('serverName'),
	'modern' => __('server_modern'),
	default => configLua('serverName'),
};

/** @var Twig\Environment $twig */
$twig->display('highscores.html.twig', [
	'highscores' => $highscores,
	'list' => $list,
	'skill' => $skill,
	'skillName' => ($types[$list] ?? getSkillName($skill)),
	'levelName' => ($skill == SKILL_FRAGS
		? __('category_frags')
		: ($skill == SKILL_BALANCE
			? __('category_balance')
			: ($skill == SKILL_ONLINETIME ? __('category_online_time') : __('col_level')))),
	'vocation' => $vocation !== 'all' ? $localizeVocationName(ucfirst($vocation)) : null,
	'vocationId' => $vocationId,
	'types' => $types,
	'mode' => $mode,
	'modeLabel' => $modeLabel,
	'vocationSlugs' => $vocationSlugs,
	'vocationNames' => [
		0 => __('vocation_none'),
		1 => __('vocation_sorcerer'),
		2 => __('vocation_druid'),
		3 => __('vocation_paladin'),
		4 => __('vocation_knight'),
	],
	'modes' => $modes,
	'modeQuery' => $modeQuery,
	'linkPreviousPage' => $linkPreviousPage,
	'linkNextPage' => $linkNextPage,
	'totalResults' => $totalResults,
	'page' => $page,
	'baseLink' => $baseLink,
	'updatedAt' => $updatedAt,
]);
