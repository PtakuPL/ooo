<?php
/**
 * Characters
 *
 * @package   MyAAC
 * @author    Gesior <jerzyskalski@wp.pl>
 * @author    Slawkens <slawkens@gmail.com>
 * @copyright 2019 MyAAC
 * @link      https://my-aac.org
 */

use MyAAC\Models\PlayerDeath;

defined('MYAAC') or die('Direct access not allowed!');
require_once SYSTEM . 'database_modern.php';
$title = __('menu_characters');

$groups = new OTS_Groups_List();
function generate_search_form($autofocus = false)
{
	global $config, $twig;
	return $twig->render('characters.form.html.twig', array(
		'link' => getLink('characters'),
		'autofocus' => $autofocus
	));
}

function retrieve_former_name($name)
{
	global $oldName, $db;

	if($db->hasTable('player_namelocks') && $db->hasColumn('player_namelocks', 'name')) {
		$newNameSql = $db->query('SELECT `name`, `new_name` FROM `player_namelocks` WHERE `name` = ' . $db->quote($name));
		if($newNameSql->rowCount() > 0) // namelocked
		{
			$newNameSql = $newNameSql->fetch();
			$oldName = ' (<small><b>Former name:</b> ' . $newNameSql['name'] . '</small>)';
			return $newNameSql['new_name'];
		}
	}

	return '';
}

$name = '';
if(isset($_REQUEST['name']))
	$name = urldecode(stripslashes(ucwords(strtolower($_REQUEST['name']))));

if(empty($name))
{
	$tmp_link = getPlayerLink($name);
	echo 'Here you can get detailed information about a certain player on ' . $config['lua']['serverName'] . '.<br/>';
	echo generate_search_form(true);
	return;
}

$name = str_replace('/', '', $name);

$oldName = '';

$player = new OTS_Player();
$player->find($name);
$playerServer = 'classic74'; // default server
if(!$player->isLoaded())
{
	$tmp_zmienna = "";
	$tmp_name = retrieve_former_name($name);
	while(!empty($tmp_name))
	{
		$tmp_zmienna = $tmp_name;
		$tmp_name = retrieve_former_name($tmp_zmienna);
	}

	if(!empty($tmp_zmienna))
		$player->find($tmp_zmienna);
}

// Cross-server search: try canary_modern if not found in default DB
$modernPlayerData = null;
if (!$player->isLoaded() || $player->isDeleted()) {
	$modernDb = getModernDb();
	if ($modernDb) {
		$stmt = $modernDb->prepare('SELECT * FROM `players` WHERE `name` = ? AND `deletion` = 0 LIMIT 1');
		$stmt->execute([$name]);
		$modernPlayerData = $stmt->fetch(PDO::FETCH_ASSOC);
		if ($modernPlayerData) {
			$playerServer = 'modern';
		}
	}
}

if($player->isLoaded() && !$player->isDeleted())
{
	$title = $player->getName() . ' - ' . $title;
	$account = $player->getAccount();
	$rows = 0;

	if($config['characters']['outfit'])
		$outfit = setting('core.outfit_images_url') . '?id=' . $player->getLookType() . ($db->hasColumn('players', 'lookaddons') ? '&addons=' . $player->getLookAddons() : '') . '&head=' . $player->getLookHead() . '&body=' . $player->getLookBody() . '&legs=' . $player->getLookLegs() . '&feet=' . $player->getLookFeet();

	$flag = '';
	if(setting('core.account_country')) {
		$flag = getFlagImage($account->getCountry());
	}

	$player_sex = 'Unknown';
	if(isset($config['genders'][$player->getSex()]))
		$player_sex = $config['genders'][$player->getSex()];

	$marital_status = 'single';
	$marriage_id = $player->getMarriage();
	if($marriage_id > 0) {
		$marriage = new OTS_Player();
		$marriage->load($player->getMarriage(), array('id', 'name'), false);
		if($marriage->isLoaded()) {
			$marital_status = 'married to ' . getPlayerLink($marriage->getName());
		}
	}

	$frags_enabled = $db->hasTable('player_killers') && $config['characters']['frags'];
	$frags_count = 0;
	if($frags_enabled) {
		$query = $db->query(
			'SELECT COUNT(`player_id`) as `frags`' .
			'FROM `player_killers`' .
			'WHERE `player_id` = ' .$player->getId() . ' ' .
			'GROUP BY `player_id`' .
			'ORDER BY COUNT(`player_id`) DESC');

		if($query->rowCount() > 0)
		{
			$query = $query->fetch();
			$frags_count = $query['frags'];
		}
	}

	$town_field = 'town';
	if($db->hasColumn('houses', 'town_id'))
		$town_field = 'town_id';
	else if($db->hasColumn('houses', 'townid'))
		$town_field = 'townid';
	else if(!$db->hasColumn('houses', 'town'))
		$town_field = false;

	if($db->hasColumn('houses', 'name')) {
		$house = $db->query('SELECT `id`, `paid`, `name`' . ($town_field != false ? ', `' . $town_field . '` as `town`' : '') . ' FROM `houses` WHERE `owner` = '.$player->getId())->fetch();
		if(isset($house['id']))
		{
			$add = '';
			if($house['paid'] > 0)
				$add = ' is paid until '.date("M d Y", $house['paid']);
		}
	}

	$rank_of_player = $player->getRank();
	if($rank_of_player->isLoaded()) {
		$guild = $rank_of_player->getGuild();
		if($guild->isLoaded()) {
			$guild_name = $guild->getName();
		}
	}

	$comment = $player->getComment();

	if($config['characters']['skills'])
	{
		if($db->hasColumn('players', 'skill_fist')) {// tfs 1.0+
			$skills_db = $db->query('SELECT `maglevel`, `skill_fist`, `skill_club`, `skill_sword`, `skill_axe`, `skill_dist`, `skill_shielding`, `skill_fishing` FROM `players` WHERE `id` = ' . $player->getId())->fetch();

			$skill_ids = array(
				POT::SKILL_MAGIC => 'maglevel',
				POT::SKILL_FIST => 'skill_fist',
				POT::SKILL_CLUB => 'skill_club',
				POT::SKILL_SWORD => 'skill_sword',
				POT::SKILL_AXE => 'skill_axe',
				POT::SKILL_DIST => 'skill_dist',
				POT::SKILL_SHIELD => 'skill_shielding',
				POT::SKILL_FISH => 'skill_fishing',
			);

			$skills = array();
			foreach($skill_ids as $skillid => $field_name) {
				$skills[] = array('skillid' => $skillid, 'value' => $skills_db[$field_name]);
			}
		}
		else {
			$skills_db = $db->query('SELECT `skillid`, `value` FROM `player_skills` WHERE `player_id` = ' . $player->getId() . ' LIMIT 7');
			$skills = $skills_db->fetchAll();
		}

		foreach($skills as &$skill) {
			$skill['name'] = getSkillName($skill['skillid']);
		}
	}

	$quests_enabled = $config['characters']['quests'] && !empty($config['quests']);
	if($quests_enabled) {
		$quests = $config['quests'];
		$sql_query_in = '';
		$i = 0;
		foreach($quests as $quest_name => $quest_storage)
		{
			if($i != 0)
				$sql_query_in .= ', ';

			$sql_query_in .= $quest_storage;
			$i++;
		}

		$storage_sql = $db->query('SELECT `key`, `value` FROM `player_storage` WHERE `player_id` = '.$player->getId().' AND `key` IN (' . $sql_query_in . ')');
		$player_storage = array();
		foreach($storage_sql as $storage)
			$player_storage[$storage['key']] = $storage['value'];

		foreach($quests as &$storage) {
			$storage = isset($player_storage[$storage]) && $player_storage[$storage] > 0;
		}
		unset($storage);
	}

	if($db->hasTable('player_items') && $db->hasColumn('player_items', 'pid') && $db->hasColumn('player_items', 'sid') && $db->hasColumn('player_items', 'itemtype')) {
		$eq_sql = $db->query('SELECT `pid`, `itemtype` FROM player_items WHERE player_id = '.$player->getId().' AND (`pid` >= 1 and `pid` <= 10)');
		$equipment = array();
		foreach($eq_sql as $eq)
			$equipment[$eq['pid']] = $eq['itemtype'];

		$empty_slots = array("", "no_helmet", "no_necklace", "no_backpack", "no_armor", "no_handleft", "no_handright", "no_legs", "no_boots", "no_ring", "no_ammo");
		for($i = 0; $i <= 10; $i++)
		{
			if(!isset($equipment[$i]) || $equipment[$i] == 0)
				$equipment[$i] = $empty_slots[$i];
		}

		for($i = 1; $i < 11; $i++)
		{
			if(Validator::number($equipment[$i]))
				$equipment[$i] = getItemImage($equipment[$i]);
			else
				$equipment[$i] = '<img src="images/items/' . $equipment[$i] . '.gif" width="32" height="32" border="0" alt=" ' . $equipment[$i] . '" />';
		}

		$skulls = array(
			1 => 'yellow_skull',
			2 => 'green_skull',
			3 => 'white_skull',
			4 => 'red_skull',
			5 => 'black_skull'
		);
	}

	$dead_add_content = '';
	$deaths = array();
	if($db->hasTable('killers')) {
		$player_deaths = $db->query('SELECT `id`, `date`, `level` FROM `player_deaths` WHERE `player_id` = '.$player->getId().' ORDER BY `date` DESC LIMIT 0,10;')->fetchAll();
		if(count($player_deaths))
		{
			$number_of_rows = 0;
			foreach($player_deaths as $death)
			{
				$killers = $db->query("SELECT environment_killers.name AS monster_name, players.name AS player_name, players.deleted AS player_exists FROM killers LEFT JOIN environment_killers ON killers.id = environment_killers.kill_id
LEFT JOIN player_killers ON killers.id = player_killers.kill_id LEFT JOIN players ON players.id = player_killers.player_id
WHERE killers.death_id = '".$death['id']."' ORDER BY killers.final_hit DESC, killers.id ASC")->fetchAll();

				$description = '';
				$i = 0;
				$count = count($killers);
				foreach($killers as $killer)
				{
					$i++;
					if($killer['player_name'] != "")
					{
						if($i == 1)
							$description .= "Killed at level <b>".$death['level']."</b>";
						else if($i == $count)
							$description .= " and";
						else
							$description .= ",";

						$description .= " by ";
						if($killer['monster_name'] != "")
							$description .= $killer['monster_name']." summoned by ";

						if($killer['player_exists'] == 0)
							$description .= getPlayerLink($killer['player_name']);
						else
							$description .= $killer['player_name'];
					}
					else
					{
						if($i == 1)
							$description .= "Died at level <b>".$death['level']."</b>";
						else if($i == $count)
							$description .= " and";
						else
							$description .= ",";

						$description .= " by ".$killer['monster_name'];
					}
				}

				$deaths[] = array('time' => $death['date'], 'description' => $description . '.');
			}
		}
	} else if ($db->hasColumn('player_deaths', 'time') && $db->hasColumn('player_deaths', 'level') && $db->hasColumn('player_deaths', 'killed_by') && $db->hasColumn('player_deaths', 'is_player')) {
		$mostdamage = '';
		if($db->hasColumn('player_deaths', 'mostdamage_by'))
			$mostdamage = ', `mostdamage_by`, `mostdamage_is_player`, `unjustified`, `mostdamage_unjustified`';
		$deaths_db = $db->query('SELECT
				`player_id`, `time`, `level`, `killed_by`, `is_player`' . $mostdamage . '
				FROM `player_deaths`
				WHERE `player_id` = ' . $player->getId() . ' ORDER BY `time` DESC LIMIT 10;')->fetchAll();

		if(count($deaths_db)) {
			$number_of_rows = 0;
			foreach($deaths_db as $death)
			{
				$lasthit = ($death['is_player']) ? getPlayerLink($death['killed_by']) : $death['killed_by'];
				$description =  'Killed at level ' . $death['level'] . ' by ' . $lasthit;
				if($death['unjustified']) {
					$description .=  ' <span style="color: red; font-style: italic;">(unjustified)</span>';
				}

				$mostdmg = ($death['mostdamage_by'] !== $death['killed_by']) ? true : false;
				if($mostdmg)
				{
					$mostdmg = ($death['mostdamage_is_player']) ? getPlayerLink($death['mostdamage_by']) : $death['mostdamage_by'];
					$description .=  ' and by ' . $mostdmg;

					if ($death['mostdamage_unjustified']) {
						$description .=  ' <span style="color: red; font-style: italic;">(unjustified)</span>';
					}
				}
				else {
					$description .=  " <b>(soloed)</b>";
				}

				$deaths[] = array('time' => $death['time'], 'description' => $description);
			}
		}
	}

	$frags = array();
	$frag_add_content = '';
	if ($config['characters']['frags']) {
		$frags_limit = 10; // frags limit to show? // default: 10

		if ($db->hasTable('killers')) {
			//frags list by Xampy
			$i = 0;
			$player_frags = $db->query('SELECT `player_deaths`.*, `players`.`name`, `killers`.`unjustified` FROM `player_deaths` LEFT JOIN `killers` ON `killers`.`death_id` = `player_deaths`.`id` LEFT JOIN `player_killers` ON `player_killers`.`kill_id` = `killers`.`id` LEFT JOIN `players` ON `players`.`id` = `player_deaths`.`player_id` WHERE `player_killers`.`player_id` = ' . $player->getId() . ' ORDER BY `date` DESC LIMIT 0,' . $frags_limit . ';')->fetchAll();
			if (count($player_frags)) {
				$row_count = 0;
				foreach ($player_frags as $frag) {
					$description = 'Fragged <a href="' . getPlayerLink($frag['name'], false) . '">' . $frag['name'] . '</a> at level ' . $frag['level'];
					$frags[] = array('time' => $frag['date'], 'description' => $description, 'unjustified' => $frag['unjustified'] != 0);
				}
			}
		}
		else if($db->hasTable('player_deaths') && $db->hasColumn('player_deaths', 'killed_by')) {
			$i = 0;
			$player_frags = PlayerDeath::where('player_deaths.killed_by', $player->getName())
				->join('players', 'players.id', '=', 'player_deaths.player_id')
				->limit($frags_limit)
				->selectRaw('players.name, player_deaths.*')
				->orderBy('player_deaths.time', 'DESC')
				->get();

			if ($player_frags->count()) {
				$row_count = 0;
				foreach ($player_frags as $frag) {
					$description = 'Fragged <a href="' . getPlayerLink($frag->name, false) . '">' . $frag->name . '</a> at level ' . $frag->level;
					$frags[] = array('time' => $frag->time, 'description' => $description, 'unjustified' => $frag->unjustified != 0);
				}
			}
		}
	}

	// signature
	if(setting('core.signature_enabled')) {
		$signature_url = BASE_URL . (setting('core.friendly_urls') ? '' : 'index.php/') . urlencode($player->getName()) . '.png';
	}

	$hide = $player->isHidden();
	if(!$hide) {
		// check if account has been banned
		$bannedUntil = '';
		$banned = array();
		if($db->hasTable('account_bans'))
			$banned = $db->query('SELECT `expires_at` as `expires` FROM `account_bans` WHERE `account_id` = ' . $account->getId() . ' and (`expires_at` > ' . time() . ' OR `expires_at` = -1);');
		else if ($db->hasTable('bans')) {
			if ($db->hasColumn('bans', 'expires'))
				$banned = $db->query('SELECT `expires` FROM `bans` WHERE (`value` = ' . $account->getId() . ' or `value` = ' . $player->getId() . ') and `active` = 1 and `type` != 2 and `type` != 4 and (`expires` > ' . time() . ' OR `expires` = -1);');
			else
				$banned = $db->query('SELECT `time` as `time` FROM `bans` WHERE (`account` = ' . $account->getId() . ' or `player` = ' . $player->getId() . ') and `type` != 2 and `type` != 4 and (`time` > ' . time() . ' OR `time` = -1);');
		}
		foreach($banned as $ban) {
			$bannedUntil = $ban['expires'];
		}

		$account_players = array();
		$other_server_players = array();
		$currentWorldId = (int)$db->query('SELECT `world` FROM `players` WHERE `id` = ' . $player->getId())->fetchColumn();
		$query = $db->query('SELECT `id`, `world` FROM `players` WHERE `account_id` = ' . $account->getId() . ' ORDER BY `name`')->fetchAll();
		foreach($query as $p) {
			$_player = new OTS_Player();
			$fields = array('id', 'name', 'vocation', 'level', 'online', 'deleted', 'hide');
			$_player->load($p['id'], $fields, false);
			if($_player->isLoaded() && !$_player->isHidden()) {
				if ((int)$p['world'] === $currentWorldId) {
					$account_players[] = $_player;
				} else {
					$other_server_players[] = $_player;
				}
			}
		}
		$currentServerLabel = $currentWorldId === 1 ? 'Modern' : 'Classic 7.4';
		$otherServerLabel = $currentWorldId === 1 ? 'Classic 7.4' : 'Modern';
	}

	$twig->display('characters.html.twig', array(
		'outfit' => isset($outfit) ? $outfit : null,
		'player' => $player,
		'account' => $account,
		'flag' => $flag,
		'oldName' => $oldName,
		'sex' => $player_sex,
		'marriage_enabled' => $config['characters']['marriage_info'] && $db->hasColumn('players', 'marriage'),
		'marital_status' => $marital_status,
		'vocation' => $player->getVocationName(),
		'frags_enabled' => $frags_enabled,
		'frags_count' => $frags_count,
		'town' => isset($config['towns'][$player->getTownId()]) ? $config['towns'][$player->getTownId()] : null,
		'house' => array(
			'found' => isset($house['id']),
			'add' => isset($house['id']) ? $add : null,
			'name' => isset($house['id']) ? (isset($house['name']) ? $house['name'] : $house['id']) : null,
			'town' => isset($house['town']) ? ' (' . $config['towns'][$house['town']] . ')' : ''
		),
		'guild' => array(
			'rank' => isset($guild_name) ? $rank_of_player->getName() : null,
			'link' => isset($guild_name) ? getGuildLink($guild_name) : null
		),
		'comment' => !empty($comment) ? nl2br($comment) : null,
		'skills' => isset($skills) ? $skills : null,
		'quests_enabled' => $quests_enabled,
		'quests' => isset($quests) ? $quests : null,
		'equipment' => isset($equipment) ? $equipment : null,
		'skull' => $player->getSkullTime() > 0 && ($player->getSkull() == 4 || $player->getSkull() == 5) ? $skulls[$player->getSkull()] : null,
		'deaths' => $deaths,
		'frags' => $frags,
		'signature_url' => isset($signature_url) ? $signature_url : null,
		'player_link' => getPlayerLink($player->getName(), false),
		'hide' => $hide,
		'hidden' => $hide,
		'bannedUntil' => isset($bannedUntil) ? $bannedUntil : null,
		'account_players' => isset($account_players) ? $account_players : null,
		'other_server_players' => isset($other_server_players) ? $other_server_players : null,
		'current_server_label' => isset($currentServerLabel) ? $currentServerLabel : '',
		'other_server_label' => isset($otherServerLabel) ? $otherServerLabel : '',
		'search_form' => generate_search_form(),
		'canEdit' => hasFlag(FLAG_CONTENT_PLAYERS) || superAdmin()
	));
} elseif ($modernPlayerData) {
	// Player found in canary_modern — display simplified profile from PDO data
	$title = $modernPlayerData['name'] . ' - ' . $title;

	$modernSex = 'Unknown';
	if (isset($config['genders'][$modernPlayerData['sex']])) {
		$modernSex = $config['genders'][$modernPlayerData['sex']];
	}

	$modernVoc = isset($config['vocations'][$modernPlayerData['vocation']]) ? $config['vocations'][$modernPlayerData['vocation']] : 'None';
	$modernTown = isset($config['towns'][$modernPlayerData['town_id']]) ? $config['towns'][$modernPlayerData['town_id']] : 'Unknown';
	$modernLevel = (int)$modernPlayerData['level'];

	$modernOutfit = '';
	if ($config['characters']['outfit'] ?? false) {
		$modernOutfit = setting('core.outfit_images_url') . '?id=' . $modernPlayerData['looktype']
			. (isset($modernPlayerData['lookaddons']) ? '&addons=' . $modernPlayerData['lookaddons'] : '')
			. '&head=' . $modernPlayerData['lookhead'] . '&body=' . $modernPlayerData['lookbody']
			. '&legs=' . $modernPlayerData['looklegs'] . '&feet=' . $modernPlayerData['lookfeet'];
	}

	// Fetch deaths from canary_modern
	$modernDeaths = [];
	$modernDb2 = getModernDb();
	if ($modernDb2) {
		$deathStmt = $modernDb2->prepare('SELECT `player_id`, `time`, `level`, `killed_by`, `is_player`, `mostdamage_by`, `mostdamage_is_player`, `unjustified`, `mostdamage_unjustified` FROM `player_deaths` WHERE `player_id` = ? ORDER BY `time` DESC LIMIT 10');
		$deathStmt->execute([$modernPlayerData['id']]);
		foreach ($deathStmt->fetchAll(PDO::FETCH_ASSOC) as $d) {
			$lasthit = $d['is_player'] ? getPlayerLink($d['killed_by']) : $d['killed_by'];
			$desc = 'Killed at level ' . $d['level'] . ' by ' . $lasthit;
			if ($d['unjustified']) {
				$desc .= ' <span style="color: red; font-style: italic;">(unjustified)</span>';
			}
			if ($d['mostdamage_by'] !== $d['killed_by']) {
				$mostdmg = $d['mostdamage_is_player'] ? getPlayerLink($d['mostdamage_by']) : $d['mostdamage_by'];
				$desc .= ' and by ' . $mostdmg;
				if ($d['mostdamage_unjustified']) {
					$desc .= ' <span style="color: red; font-style: italic;">(unjustified)</span>';
				}
			} else {
				$desc .= ' <b>(soloed)</b>';
			}
			$modernDeaths[] = ['time' => $d['time'], 'description' => $desc];
		}

		// Fetch other characters on the same account from modern DB
		$accStmt = $modernDb2->prepare('SELECT `id`, `name`, `vocation`, `level` FROM `players` WHERE `account_id` = ? AND `deletion` = 0 ORDER BY `name`');
		$accStmt->execute([$modernPlayerData['account_id']]);
		$modernAccountPlayers = $accStmt->fetchAll(PDO::FETCH_ASSOC);

		// Fetch classic server characters for the same account (other server)
		$classicAccountPlayers = array();
		$classicQuery = $db->query('SELECT `id` FROM `players` WHERE `account_id` = ' . (int)$modernPlayerData['account_id'] . ' AND `world` = 0 ORDER BY `name`')->fetchAll();
		foreach($classicQuery as $cp) {
			$_cplayer = new OTS_Player();
			$_cplayer->load($cp['id'], array('id', 'name', 'vocation', 'level', 'online', 'deleted', 'hide'), false);
			if($_cplayer->isLoaded() && !$_cplayer->isHidden()) {
				$classicAccountPlayers[] = $_cplayer;
			}
		}
	}

	// Create a compatible player proxy object for the Twig template
	$modernPlayerProxy = new class($modernPlayerData) {
		private $data;
		public function __construct(array $data) { $this->data = $data; }
		public function getId() { return (int)$this->data['id']; }
		public function getName() { return $this->data['name']; }
		public function getLevel() { return (int)$this->data['level']; }
		public function getExperience() { return (int)($this->data['experience'] ?? 0); }
		public function getLookType() { return (int)($this->data['looktype'] ?? 136); }
		public function getLookAddons() { return (int)($this->data['lookaddons'] ?? 0); }
		public function getLookHead() { return (int)($this->data['lookhead'] ?? 0); }
		public function getLookBody() { return (int)($this->data['lookbody'] ?? 0); }
		public function getLookLegs() { return (int)($this->data['looklegs'] ?? 0); }
		public function getLookFeet() { return (int)($this->data['lookfeet'] ?? 0); }
		public function isOnline() { return false; }
		public function isDeleted() { return false; }
		public function isHidden() { return false; }
		public function getSex() { return (int)($this->data['sex'] ?? 0); }
		public function getBalance() { return (int)($this->data['balance'] ?? 0); }
		public function getVocation() { return (int)($this->data['vocation'] ?? 0); }
		public function getVocationName() {
			global $config;
			$voc = (int)($this->data['vocation'] ?? 0);
			return $config['vocations'][$voc] ?? 'None';
		}
		public function getSkullTime() { return 0; }
		public function getSkull() { return 0; }
		public function getCreationDate() { return (int)($this->data['creation'] ?? 0); }
		public function getLastLogin() { return (int)($this->data['lastlogin'] ?? 0); }
		public function getMagLevel() { return (int)($this->data['maglevel'] ?? 0); }
	};

	// Wrap modern account players as proxy objects for the template
	$modernAccountPlayerProxies = [];
	foreach ($modernAccountPlayers ?? [] as $mp) {
		$modernAccountPlayerProxies[] = new class($mp) {
			private $d;
			public function __construct(array $d) { $this->d = $d; }
			public function getName() { return $this->d['name']; }
			public function getLevel() { return (int)$this->d['level']; }
			public function getVocationName() {
				global $config;
				return $config['vocations'][(int)$this->d['vocation']] ?? 'None';
			}
			public function isOnline() { return false; }
			public function isDeleted() { return false; }
			public function isHidden() { return false; }
		};
	}

	$twig->display('characters.html.twig', [
		'outfit' => !empty($modernOutfit) ? $modernOutfit : null,
		'player' => $modernPlayerProxy,
		'account' => null,
		'flag' => '',
		'oldName' => '',
		'sex' => $modernSex,
		'marriage_enabled' => false,
		'marital_status' => 'single',
		'vocation' => $modernVoc,
		'frags_enabled' => false,
		'frags_count' => 0,
		'town' => $modernTown,
		'house' => ['found' => false, 'add' => null, 'name' => null, 'town' => ''],
		'guild' => ['rank' => null, 'link' => null],
		'comment' => !empty($modernPlayerData['comment']) ? nl2br($modernPlayerData['comment']) : null,
		'skills' => null,
		'quests_enabled' => false,
		'quests' => null,
		'equipment' => null,
		'skull' => null,
		'deaths' => $modernDeaths,
		'frags' => [],
		'signature_url' => null,
		'player_link' => getPlayerLink($modernPlayerData['name'], false),
		'hide' => false,
		'hidden' => false,
		'bannedUntil' => null,
		'account_players' => $modernAccountPlayerProxies,
		'other_server_players' => !empty($classicAccountPlayers) ? $classicAccountPlayers : null,
		'current_server_label' => 'Modern',
		'other_server_label' => 'Classic 7.4',
		'search_form' => generate_search_form(),
		'canEdit' => false,
		'serverTag' => 'Modern',
		'serverBadgeClass' => 'badge badge-info',
		'level' => $modernLevel,
	]);
} else {
	$search_errors[] = 'Character <b>' . $name . '</b> does not exist or has been deleted.';
	$twig->display('error_box.html.twig', array('errors' => $search_errors));
	$search_errors = array();

	$promotion = '';
	if($db->hasColumn('players', 'promotion'))
		$promotion = ', `promotion`';

	$deleted = 'deleted';
	if($db->hasColumn('players', 'deletion'))
		$deleted = 'deletion';

	$query = $db->query('SELECT `name`, `level`, `vocation`' . $promotion . ' FROM `players` WHERE `name` LIKE  ' . $db->quote('%' . $name . '%') . ' AND ' . $deleted . ' != 1 LIMIT ' . (int)setting('core.characters_search_limit') . ';');
	if($query->rowCount() > 0) {
		echo 'Did you mean:<ul>';
		foreach($query as $player) {
			if(isset($player['promotion'])) {
				if((int)$player['promotion'] > 0)
					$player['vocation'] += ($player['promotion'] * $config['vocations_amount']);
			}
			echo '<li>' . getPlayerLink($player['name']) . ' (<small><strong>level ' . $player['level'] . ', ' . $config['vocations'][$player['vocation']] . '</strong></small>) <span style="color:#888;">[Classic 7.4]</span></li>';
		}
		echo '</ul>';
	}

	// Also search canary_modern for matching names
	$modernDb3 = getModernDb();
	if ($modernDb3) {
		$modernSearch = $modernDb3->prepare('SELECT `name`, `level`, `vocation` FROM `players` WHERE `name` LIKE ? AND `deletion` = 0 LIMIT ' . (int)setting('core.characters_search_limit'));
		$modernSearch->execute(['%' . $name . '%']);
		$modernResults = $modernSearch->fetchAll(PDO::FETCH_ASSOC);
		if (count($modernResults) > 0) {
			if ($query->rowCount() == 0) {
				echo 'Did you mean:<ul>';
			}
			foreach ($modernResults as $mp) {
				$mpVoc = isset($config['vocations'][$mp['vocation']]) ? $config['vocations'][$mp['vocation']] : 'None';
				echo '<li>' . getPlayerLink($mp['name']) . ' (<small><strong>level ' . (int)$mp['level'] . ', ' . $mpVoc . '</strong></small>) <span style="color:#17a2b8;">[Modern]</span></li>';
			}
			echo '</ul>';
		}
	}

	echo generate_search_form(true);
}

if(!empty($search_errors))
	$twig->display('error_box.html.twig', array('errors' => $search_errors));
