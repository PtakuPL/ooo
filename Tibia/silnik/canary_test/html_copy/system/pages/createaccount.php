<?php
/**
 * Legacy createaccount compatibility endpoint.
 */

defined('MYAAC') or die('Direct access not allowed!');

header('Location: /reddaxe/account-create.php?source=tibiawww', true, 302);
exit;
