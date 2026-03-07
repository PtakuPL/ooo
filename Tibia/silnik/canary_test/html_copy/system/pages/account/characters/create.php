<?php
/**
 * Create character
 *
 * @package   MyAAC
 * @author    Gesior <jerzyskalski@wp.pl>
 * @author    Slawkens <slawkens@gmail.com>
 * @copyright 2019 MyAAC
 * @link      https://my-aac.org
 */

use MyAAC\CreateCharacter;

defined('MYAAC') or die('Direct access not allowed!');

$title = __('create_character');
require PAGES . 'account/base.php';
require PAGES . 'account/global-profile.php';

if(!$logged) {
	return;
}

csrfProtect();

$character_name = isset($_POST['name']) ? stripslashes($_POST['name']) : null;
$character_sex = isset($_POST['sex']) ? (int)$_POST['sex'] : null;
$character_vocation = isset($_POST['vocation']) ? (int)$_POST['vocation'] : null;
$character_town = isset($_POST['town']) ? (int)$_POST['town'] : null;
$defaultMode = globalProfileGetActiveMode('classic74');
if (!in_array($defaultMode, ['classic74', 'modern'], true)) {
	$defaultMode = 'classic74';
}
$character_mode = strtolower(trim((string)($_POST['mode'] ?? $_GET['mode'] ?? $defaultMode)));
if (!in_array($character_mode, ['classic74', 'modern'], true)) {
	$character_mode = $defaultMode;
}
globalProfileSetActiveMode($character_mode);

if (!admin() && !empty($character_name)) {
	$character_name = ucwords(strtolower($character_name));
}

$character_created = false;
$save = isset($_POST['save']) && $_POST['save'] == 1;
$errors = array();
if($save) {
	$createCharacter = new CreateCharacter();

	$character_created = $createCharacter->doCreate($character_name, $character_sex, $character_vocation, $character_town, $account_logged, $errors);

	// Multi-world: store selected world id for character created in account panel.
	if ($character_created) {
		global $db;
		$selectedWorldId = $character_mode === 'modern' ? 1 : 0;
		if ($db->hasColumn('players', 'world_id')) {
			$createdPlayer = new OTS_Player();
			$createdPlayer->find($character_name);

			if ($createdPlayer->isLoaded() && (int)$createdPlayer->getAccount()->getId() === (int)$account_logged->getId()) {
				$createdPlayer->setWorldId($selectedWorldId);
				$createdPlayer->save();
			}
		} elseif ($db->hasColumn('players', 'world')) {
			$createdPlayer = new OTS_Player();
			$createdPlayer->find($character_name);
			if ($createdPlayer->isLoaded() && (int)$createdPlayer->getAccount()->getId() === (int)$account_logged->getId()) {
				$db->query(
					'UPDATE `players` SET `world` = ' . (int)$selectedWorldId .
					' WHERE `id` = ' . (int)$createdPlayer->getId() . ' LIMIT 1'
				);
			}
		}
	}
}

if(count($errors) > 0) {
	$twig->display('error_box.html.twig', array('errors' => $errors));
}

if(!$character_created) {
	$twig->display('account.characters.create.html.twig', array(
		'name' => $character_name,
		'sex' => $character_sex,
		'vocation' => $character_vocation,
		'town' => $character_town,
		'mode' => $character_mode,
		'save' => $save,
		'errors' => $errors
	));
}
