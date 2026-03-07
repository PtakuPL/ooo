<?php
declare(strict_types=1);

require_once __DIR__ . '/bootstrap.php';

reddaxe_start_shared_session();

// Clear RedDAXE session data
unset(
    $_SESSION['account']['user'],
    $_SESSION['account']['sessionKey'],
    $_SESSION['login_timeout']
);

// Clear MyAAC cross-site session keys
unset(
    $_SESSION['myaac_account'],
    $_SESSION['myaac_password'],
    $_SESSION['myaac_last_visit'],
    $_SESSION['myaac_remember_me']
);

session_write_close();

header('Location: /reddaxe/index.php', true, 302);
exit;
