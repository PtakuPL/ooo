<?php
/**
 * Houses
 *
 * @package   MyAAC
 * @author    Gesior <jerzyskalski@wp.pl>
 * @author    Slawkens <slawkens@gmail.com>
 * @author    whiteblXK
 * @copyright 2019 MyAAC
 * @link      https://my-aac.org
 */
defined('MYAAC') or die('Direct access not allowed!');
require_once SYSTEM . 'database_modern.php';
$title = __('menu_houses');

$housesServerMode = $_SESSION['server_mode'] ?? 'all';

$errors = array();
if(!$db->hasColumn('houses', 'name')) {
	$errors[] = 'Lista domów nie jest dostępna na tym serwerze.';

	$twig->display('houses.html.twig', array(
		'errors' => $errors
	));
	return;
}

$rentType = trim(strtolower($config['lua']['houseRentPeriod']));
if($rentType != 'yearly' && $rentType != 'monthly' && $rentType != 'weekly' && $rentType != 'daily')
	$rentType = 'never';

$state = '';
$order = '';
$type = '';

if(isset($_REQUEST['name']))
{
	$beds = array("", "one", "two", "three", "fourth", "fifth");
	$houseName = urldecode($_REQUEST['name']);
	$houseId = (Validator::number($_REQUEST['name']) ? $_REQUEST['name'] : -1);
	$selectHouse = $db->query('SELECT * FROM ' . $db->tableName('houses') . ' WHERE ' . $db->fieldName('name') . ' LIKE ' . $db->quote($houseName) . ' OR `id` = ' . $db->quote($houseId));

	$house = array();
	if($selectHouse->rowCount() > 0)
	{
		$house = $selectHouse->fetch();
		$houseId = $house['id'];

		$title = $house['name'] . ' - ' . $title;

		$imgPath = 'images/houses/' . $houseId . '.gif';
		if(!file_exists($imgPath)) {
			$imgPath = 'images/houses/default.jpg';
		}

		$bedsMessage = null;
		$houseBeds = $house['beds'];
		if($houseBeds > 0)
			$bedsMessage = 'Dom ma ' . (isset($beds[$houseBeds]) ? $beds[$houseBeds] : $houseBeds) . ' łóżk' . ($houseBeds > 1 ? 'a' : 'o');
		else
			$bedsMessage = 'Ten dom nie ma żadnych łóżek';

		$houseOwner = $house['owner'];
		if($houseOwner > 0)
		{
			$guild = NULL;
			$owner = null;
			if(isset($house['guild']) && $house['guild'] == 1)
			{
				$guild = new OTS_Guild();
				$guild->load($houseOwner);
				$owner = getGuildLink($guild->getName());
			}
			else
				$owner = getCreatureName($houseOwner);

			if($rentType != 'never' && $house['paid'] > 0)
			{
				$who = '';
				if($guild)
					$who = $guild->getName();
				else
				{
					$player = new OTS_Player();
					$player->load($houseOwner);
					if($player->isLoaded())
					{
						$sexs = array('She', 'He');
						$who = $sexs[$player->getSex()];
					}
				}
				$owner .= ' ' . $who . ' opłacił czynsz do ' . date("M d Y, H:i:s", $house['paid']) . ' CEST.';
			}
		}
	}
	else
		$errors[] =  'Dom o nazwie ' . $houseName . ' nie istnieje.';

	$twig->display('houses.view.html.twig', array(
		'errors' => $errors,
		'imgPath' => isset($imgPath) ? $imgPath : null,
		'houseName' => isset($house['name']) ? $house['name'] : null,
		'bedsMessage' => isset($bedsMessage) ? $bedsMessage : null,
		'houseSize' => isset($house['size']) ? $house['size'] : null,
		'houseRent' => isset($house['rent']) ? $house['rent'] : null,
		'owner' => isset($owner) ? $owner : null,
		'rentType' => $rentType
	));

	if (count($errors) > 0) {
		return;
	}
}

$cleanOldHouse = null;
if(isset($config['lua']['houseCleanOld'])) {
	$cleanOldHouse = (int)(eval('return ' . $config['lua']['houseCleanOld'] . ';') / (24 * 60 * 60));
}

$housesSearch = false;
if(isset($_POST['town']) && isset($_POST['state']) && isset($_POST['order']) && (isset($_POST['type']) || !$db->hasColumn('houses', 'guild')))
{
	$townName = $config['towns'][$_POST['town']];
	$order = $_POST['order'];
	$orderby = '`name`';
	if(!empty($order))
	{
		if($order == 'size')
			$orderby = '`size`';
		else if($order == 'rent')
			$orderby = '`rent`';
	}

	$town = 'town';
	if($db->hasColumn('houses', 'town_id'))
		$town = 'town_id';
	else if($db->hasColumn('houses', 'townid'))
		$town = 'townid';

	$whereby = '`' . $town . '` = ' .(int)$_POST['town'];
	$state = $_POST['state'];
	if(!empty($state))
		$whereby .= ' AND `owner` ' . ($state == 'free' ? '' : '!'). '= 0';

	$type = isset($_POST['type']) ? $_POST['type'] : NULL;
	if($type == 'guildhalls' && !$db->hasColumn('houses', 'guild'))
		$type = 'all';

	if (!empty($type) && $type != 'all')
	{
		$guildColumn = '';
		if ($db->hasColumn('houses', 'guild')) {
			$guildColumn = 'guild';
		}
		else if ($db->hasColumn('houses', 'guildid')) {
			$guildColumn = 'guildid';
		}

		if($guildColumn !== '') {
			$whereby .= ' AND `' . $guildColumn . '` ' . ($type == 'guildhalls' ? '!' : '') . '= 0';
		}
	}

	$houses_info = $db->query('SELECT * FROM `houses` WHERE ' . $whereby. ' ORDER BY ' . $orderby);

	$players_info = $db->query("SELECT `houses`.`id` AS `houseid` , `players`.`name` AS `ownername` FROM `houses` , `players` , `accounts` WHERE `players`.`id` = `houses`.`owner` AND `accounts`.`id` = `players`.`account_id`");
	$players = array();
	foreach($players_info->fetchAll() as $player)
		$players[$player['houseid']] = array('name' => $player['ownername']);

	$hasTilesColumn = $db->hasColumn('houses', 'tiles');

	// If modern server mode, also fetch houses from canary_modern
	$modernHousesResults = [];
	if ($housesServerMode === 'modern' || $housesServerMode === 'all') {
		$mDb = getModernDb();
		if ($mDb) {
			$mTown = 'town_id'; // canary_modern uses town_id
			$mWhereby = '`' . $mTown . '` = ' . (int)$_POST['town'];
			if (!empty($state)) {
				$mWhereby .= ' AND `owner` ' . ($state == 'free' ? '' : '!') . '= 0';
			}
			$mStmt = $mDb->query('SELECT * FROM `houses` WHERE ' . $mWhereby . ' ORDER BY ' . $orderby);
			if ($mStmt) {
				$mPlayersStmt = $mDb->query("SELECT houses.id AS houseid, players.name AS ownername FROM houses, players, accounts WHERE players.id = houses.owner AND accounts.id = players.account_id");
				$mPlayers = [];
				if ($mPlayersStmt) {
					foreach ($mPlayersStmt->fetchAll(PDO::FETCH_ASSOC) as $mp) {
						$mPlayers[$mp['houseid']] = ['name' => $mp['ownername']];
					}
				}
				foreach ($mStmt->fetchAll(PDO::FETCH_ASSOC) as $mh) {
					$modernHousesResults[] = ['house' => $mh, 'players' => $mPlayers];
				}
			}
		}
	}

	$houses = array();

	// Classic houses (skip if server_mode is modern-only)
	if ($housesServerMode !== 'modern') {
		foreach($houses_info->fetchAll() as $house)
		{
			$owner = isset($players[$house['id']]) ? $players[$house['id']] : array();

			$houseRent = null;
			if($db->hasColumn('houses', 'guild') && $house['guild'] == 1 && $house['owner'] != 0)
			{
				$guild = new OTS_Guild();
				$guild->load($house['owner']);
				$houseRent = 'Wynajęty przez ' . getGuildLink($guild->getName());
			}
			else
			{
				if(!empty($owner['name']))
					$houseRent = 'Wynajęty przez ' . getPlayerLink($owner['name']);
				else
					$houseRent = 'Wolny';
			}

			$houses[] = array('owner' => $owner, 'name' => $house['name'], 'size' => ($hasTilesColumn ? $house['tiles'] : $house['size']), 'rent' => $house['rent'], 'rentedBy' => $houseRent, 'link' => getHouseLink($house['name'], false), 'server' => 'Classic 7.4');
		}
	}

	// Modern houses
	foreach ($modernHousesResults as $mhr) {
		$mh = $mhr['house'];
		$mPlayers = $mhr['players'];
		$owner = isset($mPlayers[$mh['id']]) ? $mPlayers[$mh['id']] : [];
		$houseRent = !empty($owner['name']) ? 'Wynajęty przez ' . getPlayerLink($owner['name']) : 'Wolny';
		$houseSize = isset($mh['tiles']) ? $mh['tiles'] : (isset($mh['size']) ? $mh['size'] : 0);
		$houses[] = ['owner' => $owner, 'name' => $mh['name'], 'size' => $houseSize, 'rent' => $mh['rent'] ?? 0, 'rentedBy' => $houseRent, 'link' => getHouseLink($mh['name'], false), 'server' => 'Modern'];
	}

	$housesSearch = true;
}

$guild = $db->hasColumn('houses', 'guild') ? ' or guildhall' : '';
$twig->display('houses.html.twig', array(
	'state' => $state,
	'order' => $order,
	'type' => $type,
	'houseType' => $type == 'guildhalls' ? 'Hale gildii' : 'Domy i mieszkania',
	'townName' => isset($townName) ? $townName : null,
	'townId' => isset($_POST['town']) ? $_POST['town'] : null,
	'guild' => $guild,
	'cleanOldHouse' => isset($cleanOld) ? $cleanOld : null,
	'housesSearch' => $housesSearch,
	'houses' => isset($houses) ? $houses : null
));
