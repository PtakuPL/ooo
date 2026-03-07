<?php
/**
 * List of guilds
 *
 * @package   MyAAC
 * @author    Gesior <jerzyskalski@wp.pl>
 * @author    Slawkens <slawkens@gmail.com>
 * @author    whiteblXK
 * @copyright 2019 MyAAC
 * @link      https://my-aac.org
 */
defined('MYAAC') or die('Direct access not allowed!');

require __DIR__ . '/base.php';
require_once SYSTEM . 'database_modern.php';

$serverMode = $_SESSION['server_mode'] ?? 'all';

$guilds = array();

// Classic 7.4 guilds (default DB)
if ($serverMode === 'all' || $serverMode === 'classic74') {
	$guilds_list = new OTS_Guilds_List();
	$guilds_list->orderBy('name');
	if(count($guilds_list) > 0) {
		foreach ($guilds_list as $guild) {
			$guild_logo = $guild->getCustomField('logo_name');
			if (empty($guild_logo) || !file_exists(GUILD_IMAGES_DIR . $guild_logo)) {
				$guild_logo = 'default.gif';
			}

			$description = $guild->getCustomField('description');
			$description_with_lines = str_replace(array("\r\n", "\n", "\r"), '<br />', $description, $count);
			if ($count < setting('core.guild_description_lines_limit')) {
				$description = nl2br($description);
			}

			$guildName = $guild->getName();
			$guilds[] = array('name' => $guildName, 'logo' => $guild_logo, 'link' => getGuildLink($guildName, false), 'description' => $description, 'server' => 'Classic 7.4');
		}
	}
}

// Modern guilds (canary_modern DB)
if ($serverMode === 'all' || $serverMode === 'modern') {
	$modernDb = getModernDb();
	if ($modernDb) {
		$stmt = $modernDb->query('SELECT `id`, `name`, `motd` FROM `guilds` ORDER BY `name`');
		foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $mg) {
			$guild_logo = 'default.gif';
			$description = $mg['motd'] ?? '';
			if (!empty($description)) {
				$description_with_lines = str_replace(array("\r\n", "\n", "\r"), '<br />', $description, $count);
				if ($count < setting('core.guild_description_lines_limit')) {
					$description = nl2br($description);
				}
			}
			$guilds[] = array('name' => $mg['name'], 'logo' => $guild_logo, 'link' => getGuildLink($mg['name'], false), 'description' => $description, 'server' => 'Modern');
		}
	}
}

// Sort merged list alphabetically
usort($guilds, function($a, $b) { return strcasecmp($a['name'], $b['name']); });

$twig->display('guilds.list.html.twig', array(
	'guilds' => $guilds,
	'isAdmin' => admin(),
));
