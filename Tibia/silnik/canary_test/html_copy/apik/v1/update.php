<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * E2: GET /api/update.php — Zwraca manifest plików klienta.
 *
 * Parametry GET:
 *   channel  — kanał aktualizacji (domyślnie "stable")
 *   version  — konkretna wersja (opcjonalnie; domyślnie "latest")
 *
 * Manifest jest generowany przez generate_manifest.php i zapisywany
 * w katalogu manifests/{channel}/{version}.json.
 *
 * Przykłady:
 *   GET /api/update.php?channel=stable           → latest manifest
 *   GET /api/update.php?channel=stable&version=1.0.0  → konkretna wersja
 */

require_once __DIR__ . '/common.php';

function publicUpdateBaseUrl(array $env, string $channel, string $version): ?string {
    $template = trim((string)($env['UPDATE_BASE_URL'] ?? $env['UPDATE_FILES_BASE_URL'] ?? ''));
    if ($template !== '') {
        return str_replace(['{channel}', '{version}'], [$channel, $version], rtrim($template, '/'));
    }

    $host = trim((string)($_SERVER['HTTP_HOST'] ?? ''));
    if ($host === '') {
        return null;
    }

    $forwardedProto = strtolower(trim((string)($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '')));
    $scheme = $forwardedProto !== '' ? $forwardedProto : ((!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http');
    if (!in_array($scheme, ['http', 'https'], true)) {
        $scheme = 'https';
    }

    $scriptDir = rtrim(str_replace('\\', '/', dirname((string)($_SERVER['SCRIPT_NAME'] ?? '/apik/v1/update.php'))), '/');
    if ($scriptDir === '') {
        $scriptDir = '/';
    }

    return $scheme . '://' . $host . rtrim($scriptDir, '/') . '/files/' . $channel . '/' . $version;
}

function playerManifestDenyPatterns(): array {
    return [
        '#(^|/)start_dev\.(sh|bat|cmd|ps1)$#i',
        '#(^|/)start_player\.(sh|bat|cmd|ps1)$#i',
        '#(^|/)serverlist\.(json|lua)$#i',
        '#(^|/)init_serverlist\.lua$#i',
        '#(^|/)otclientrc\.lua$#i',
        '#(^|/)otclientrc\.lua\.default$#i',
        '#(^|/)src/#',
        '#(^|/)tools/#',
        '#(^|/)docs/#',
        '#(^|/)tests/#',
        '#(^|/)serverSIDE(/|$)#i',
        '#(^|/)\.github/#',
        '#\.sh$#i',
        '#\.bat$#i',
        '#\.cmd$#i',
        '#\.ps1$#i',
        '#\.cpp$#i',
        '#\.c$#i',
        '#\.h$#i',
        '#\.hpp$#i',
        '#\.rs$#i',
        '#(^|/)Cargo\.(toml|lock)$#i',
        '#(^|/)CMakeLists\.txt$#i',
        '#(^|/)CMakeCache\.txt$#i',
        '#\.pdb$#i',
        '#\.ilk$#i',
        '#\.obj$#i',
        '#\.o$#i',
        '#\.lib$#i',
        '#\.a$#i',
        '#\.md$#i',
        '#\.patch$#i',
        '#\.orig$#i',
        '#\.bak$#i',
        '#\.bak\.[^/]+$#i',
        '#\.txt$#i',
        '#(^|/)README[^/]*$#i',
        '#(^|/)\.env(\.|$)#i',
        '#\.key$#i',
        '#\.secret$#i',
    ];
}

function blockedPlayerManifestPaths(array $manifest): array {
    $blocked = [];
    $patterns = playerManifestDenyPatterns();
    foreach (($manifest['files'] ?? []) as $file) {
        $path = is_array($file) ? (string)($file['path'] ?? '') : '';
        if ($path === '') {
            continue;
        }
        foreach ($patterns as $pattern) {
            if (preg_match($pattern, $path)) {
                $blocked[] = $path;
                break;
            }
        }
    }
    sort($blocked);
    return $blocked;
}

$channel = isset($_GET['channel']) ? preg_replace('/[^a-z0-9_-]/i', '', $_GET['channel']) : 'stable';
$version = isset($_GET['version']) ? preg_replace('/[^a-z0-9._-]/i', '', $_GET['version']) : 'latest';

if ($channel === '') $channel = 'stable';
if ($version === '') $version = 'latest';

$manifestDir = __DIR__ . '/manifests/' . $channel;
$manifestFile = $manifestDir . '/' . $version . '.json';

if (!is_file($manifestFile)) {
    // FIX62: Ujednolicony format błędów — używamy sendError() z common.php
    sendError('Manifest not found for channel=' . $channel . ' version=' . $version, 404);
}

// Serve the manifest file directly (already JSON)
$content = file_get_contents($manifestFile);

$env = loadEnvFiles([__DIR__ . '/.env']);
$manifest = json_decode((string)$content, true);
if (is_array($manifest)) {
    if (($env['ALLOW_DEV_CLIENT_MANIFEST'] ?? '') !== '1') {
        $blockedPaths = blockedPlayerManifestPaths($manifest);
        if ($blockedPaths !== []) {
            error_log('[UPDATE] blocked dirty player manifest channel=' . $channel . ' version=' . $version . ' paths=' . implode(',', array_slice($blockedPaths, 0, 20)));
            sendError('Client update manifest is blocked because it contains non-player files. Rebuild and redeploy a clean player package.', 503);
        }
    }

    $manifestVersion = trim((string)($manifest['version'] ?? $version));
    if ($manifestVersion === '' || $manifestVersion === 'latest') {
        $manifestVersion = $version;
    }

    $publicBaseUrl = publicUpdateBaseUrl($env, $channel, $manifestVersion);
    if ($publicBaseUrl !== null) {
        $manifest['baseUrl'] = $publicBaseUrl;
        $content = json_encode($manifest, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
    }
}

// Add cache headers (manifest zmienia się rzadko — cache 60s)
header('Cache-Control: public, max-age=60');
header('ETag: "' . md5($content) . '"');

// Check If-None-Match for 304
$etag = '"' . md5($content) . '"';
if (isset($_SERVER['HTTP_IF_NONE_MATCH']) && trim($_SERVER['HTTP_IF_NONE_MATCH']) === $etag) {
    http_response_code(304);
    exit;
}

echo $content;
