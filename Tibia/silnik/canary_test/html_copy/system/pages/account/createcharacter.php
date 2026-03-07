<?php
/**
 * Legacy createcharacter compatibility endpoint.
 */

defined('MYAAC') or die('Direct access not allowed!');

header('Location: /account/character/create', true, 302);
exit;
