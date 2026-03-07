<?php
declare(strict_types=1);

require_once __DIR__ . '/bootstrap.php';

$cfg = reddaxe_build_config();
$key = trim((string)($_GET['to'] ?? ''));

if ($key === '' || !isset($cfg['redirectLinks'][$key])) {
    http_response_code(400);
    header('Content-Type: text/plain; charset=utf-8');
    echo reddaxe_t('redirect.invalid_key');
    exit;
}

$target = (string)$cfg['redirectLinks'][$key];
if (!reddaxe_is_allowed_target($target, $cfg['allowedExternalHosts'])) {
    http_response_code(400);
    header('Content-Type: text/plain; charset=utf-8');
    echo reddaxe_t('redirect.blocked_target');
    exit;
}

reddaxe_log_redirect($key, $target);
header('Location: ' . $target, true, 302);
exit;
