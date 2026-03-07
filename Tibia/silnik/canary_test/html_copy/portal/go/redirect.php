<?php
/**
 * RedDAXE.pl — bezpieczny redirect controller (H5+H6).
 * 
 * Dozwolone targety:
 *   - www, forum, wiki  (z REDIRECT_ALLOW_LIST)
 *   - external&slug=<slug> (z EXTERNAL_LINKS allow-list)
 *
 * Brak open-redirect: URL nigdy nie pochodzi od usera, zawsze z allow-list.
 * Kazdy redirect jest logowany do pliku (H6).
 */
declare(strict_types=1);
require_once __DIR__ . '/../config.php';

$target = $_GET['target'] ?? '';
$slug   = $_GET['slug'] ?? '';

// ---- resolve target URL from allow-list only ----
$redirectUrl = null;
$targetKey   = '';

if ($target === 'external' && $slug !== '') {
    // Zewnetrzny link — musi byc na allow-list
    $links = EXTERNAL_LINKS;
    if (isset($links[$slug]) && filter_var($links[$slug]['url'], FILTER_VALIDATE_URL)) {
        $redirectUrl = $links[$slug]['url'];
        $targetKey   = "external:{$slug}";
    }
} else {
    // Wewnetrzny link — musi byc w REDIRECT_ALLOW_LIST
    $allowed = REDIRECT_ALLOW_LIST;
    if (isset($allowed[$target]) && filter_var($allowed[$target], FILTER_VALIDATE_URL)) {
        $redirectUrl = $allowed[$target];
        $targetKey   = $target;
    }
}

if ($redirectUrl === null) {
    http_response_code(400);
    echo '<!DOCTYPE html><html lang="' . htmlspecialchars(portalCurrentLang()) . '"><head><meta charset="UTF-8"><title>' . htmlspecialchars(portalT('redirect.invalid.title')) . '</title></head>';
    echo '<body style="font-family:sans-serif;text-align:center;margin-top:4rem;">';
    echo '<h2>' . htmlspecialchars(portalT('redirect.invalid.heading')) . '</h2>';
    echo '<p>' . htmlspecialchars(portalT('redirect.invalid.text')) . '</p>';
    echo '<a href="/portal/">' . htmlspecialchars(portalT('redirect.invalid.back')) . '</a>';
    echo '</body></html>';
    exit;
}

// ---- H6: logowanie zdarzenia redirect ----
$logDir  = dirname(__DIR__, 2) . '/portal_logs';
if (!is_dir($logDir)) {
    @mkdir($logDir, 0770, true);
}
$logFile = $logDir . '/redirects_' . date('Y-m') . '.log';

$ipRaw  = $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
$ipHash = hash('sha256', $ipRaw . ($ENV['REDIRECT_LOG_SALT'] ?? 'reddaxe'));

$logEntry = json_encode([
    'ts'        => gmdate('c'),
    'targetKey' => $targetKey,
    'ipHash'    => substr($ipHash, 0, 16),
    'ua'        => substr($_SERVER['HTTP_USER_AGENT'] ?? '', 0, 120),
], JSON_UNESCAPED_SLASHES) . "\n";

@file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX);

// ---- redirect (302) ----
header('Location: ' . $redirectUrl, true, 302);
exit;
