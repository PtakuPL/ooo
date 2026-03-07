<?php
/**
 * Account confirm mail
 * Keept for compability
 *
 * @package   MyAAC
 * @author    Slawkens <slawkens@gmail.com>
 * @copyright 2019 MyAAC
 * @link      https://my-aac.org
 */
defined('MYAAC') or die('Direct access not allowed!');

if(!$logged)
{
	// Redirect to RedDAXE global login instead of showing per-server MyAAC login form
	header('Location: /reddaxe/account-login.php?source=tibiawww', true, 302);
	exit;
}
else {
	$show_form = true;
}
