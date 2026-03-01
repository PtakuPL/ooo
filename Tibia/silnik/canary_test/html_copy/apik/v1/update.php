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

$channel = isset($_GET['channel']) ? preg_replace('/[^a-z0-9_-]/i', '', $_GET['channel']) : 'stable';
$version = isset($_GET['version']) ? preg_replace('/[^a-z0-9._-]/i', '', $_GET['version']) : 'latest';

if ($channel === '') $channel = 'stable';
if ($version === '') $version = 'latest';

$manifestDir = __DIR__ . '/manifests/' . $channel;
$manifestFile = $manifestDir . '/' . $version . '.json';

if (!is_file($manifestFile)) {
    http_response_code(404);
    echo json_encode(['error' => 'Manifest not found', 'channel' => $channel, 'version' => $version]);
    exit;
}

// Serve the manifest file directly (already JSON)
$content = file_get_contents($manifestFile);

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
