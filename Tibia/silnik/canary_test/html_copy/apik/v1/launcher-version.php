<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * E4: GET /api/launcher-version.php — Zwraca aktualną wersję launchera.
 *
 * Launcher sprawdza ten endpoint przy starcie, by ustalić
 * czy potrzebuje self-update.
 *
 * Odpowiedź:
 *   {
 *     "version": "1.0.0",
 *     "minVersion": "1.0.0",
 *     "required": false,
 *     "url": "/files/launcher/launcher.exe",
 *     "sha256": "abcdef1234...",
 *     "releaseDate": "2026-03-03",
 *     "notes": "Initial release"
 *   }
 *
 * required = true → launcher MUSI się zaktualizować (hard block)
 * required = false → opcjonalny update (banner)
 */

// FIX42: Shared utilities
require_once __DIR__ . '/common.php';

$ENV = loadEnvFiles([__DIR__ . '/.env']);

$currentVersion = $ENV['LAUNCHER_VERSION']      ?? '1.0.0';
$minVersion     = $ENV['LAUNCHER_MIN_VERSION']  ?? '1.0.0';
$releaseDate    = $ENV['LAUNCHER_RELEASE_DATE'] ?? date('Y-m-d');

$platform = strtolower(preg_replace('/[^a-z0-9_-]/i', '', (string)($_GET['platform'] ?? 'windows')));
if (!in_array($platform, ['windows', 'linux'], true)) {
    $platform = 'windows';
}

if ($platform === 'linux') {
    $downloadUrl = $ENV['LAUNCHER_DOWNLOAD_URL_LINUX'] ?? ($ENV['LAUNCHER_DOWNLOAD_URL'] ?? '/files/launcher/launcher');
    $sha256 = $ENV['LAUNCHER_SHA256_LINUX'] ?? ($ENV['LAUNCHER_SHA256'] ?? '');
    $filename = $ENV['LAUNCHER_SELFUPDATE_FILENAME_LINUX'] ?? 'launcher-tauri-linux-x86_64';
    $size = isset($ENV['LAUNCHER_SELFUPDATE_SIZE_LINUX']) && ctype_digit((string)$ENV['LAUNCHER_SELFUPDATE_SIZE_LINUX'])
        ? (int)$ENV['LAUNCHER_SELFUPDATE_SIZE_LINUX']
        : null;
} else {
    $downloadUrl = $ENV['LAUNCHER_DOWNLOAD_URL'] ?? '/files/launcher/launcher.exe';
    $sha256 = $ENV['LAUNCHER_SHA256'] ?? '';
    $filename = $ENV['LAUNCHER_SELFUPDATE_FILENAME_WIN'] ?? 'launcher-tauri-windows-x86_64.exe';
    $size = isset($ENV['LAUNCHER_SELFUPDATE_SIZE_WIN']) && ctype_digit((string)$ENV['LAUNCHER_SELFUPDATE_SIZE_WIN'])
        ? (int)$ENV['LAUNCHER_SELFUPDATE_SIZE_WIN']
        : null;
}

$sha256 = strtolower(trim((string)$sha256));
if ($sha256 !== '' && !preg_match('/^[a-f0-9]{64}$/', $sha256)) {
    $sha256 = '';
}

// Jeśli klient przesyła swoją wersję, sprawdzamy czy potrzebuje update
$clientVersion = isset($_GET['v']) ? trim($_GET['v']) : '';
$required = false;
if ($clientVersion !== '' && version_compare($clientVersion, $minVersion) < 0) {
    $required = true; // hard block — launcher musi się zaktualizować
}

// Cache headers
header('Cache-Control: public, max-age=300');

echo json_encode([
    'version'     => $currentVersion,
    'minVersion'  => $minVersion,
    'required'    => $required,
    'platform'    => $platform,
    'filename'    => $filename,
    'url'         => $downloadUrl,
    'sha256'      => $sha256,
    'size'        => $size,
    'releaseDate' => $releaseDate,
    'notes'       => $ENV['LAUNCHER_NOTES'] ?? 'Initial release — auto-update + ticket-gate integration',
], JSON_UNESCAPED_SLASHES);
