<?php
/**
 * Payment route compatibility fallback.
 */

defined('MYAAC') or die('Direct access not allowed!');

header('Location: /account/login', true, 302);
exit;
