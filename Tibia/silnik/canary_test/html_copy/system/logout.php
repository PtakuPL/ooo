<?php
/**
 * Logout from account
 *
 * @package   MyAAC
 * @author    Slawkens <slawkens@gmail.com>
 * @copyright 2019 MyAAC
 * @link      https://my-aac.org
 */

use MyAAC\CsrfToken;

defined('MYAAC') or die('Direct access not allowed!');

if(isset($account_logged) && $account_logged->isLoaded()) {
	if($hooks->trigger(HOOK_LOGOUT, ['account_id' => $account_logged->getId()])) {
		unsetSession('account');
		unsetSession('password');
		unsetSession('remember_me');

		// Clear RedDAXE cross-site session keys
		unset(
			$_SESSION['account'],
			$_SESSION['login_timeout']
		);

		CsrfToken::generate();

		$logged = false;
		unset($account_logged);
	}
}
