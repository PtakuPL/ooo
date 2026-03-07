<?php
/**
 * artifacts-health.php — BL-18: Health-check artefaktów do pobrania.
 *
 * Sprawdza czy pliki bootstrap i launchera istnieją na serwerze
 * i czy ich SHA-256 zgadza się z .env.
 *
 * GET /apik/v1/artifacts-health.php
 * GET /apik/v1/artifacts-health.php?deep=1  (sprawdza SHA-256)
 */
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-cache');

require_once __DIR__ . '/common.php';

$env = loadEnvFiles([__DIR__ . '/.env']);
$deep = isset($_GET['deep']) && $_GET['deep'] !== '0';

$baseDir = realpath(__DIR__ . '/..') ?: __DIR__;

$artifacts = [];

// Bootstrap launcher — Windows
$bsWinUrl = trim((string)($env['BOOTSTRAP_DOWNLOAD_URL_WIN'] ?? ''));
if ($bsWinUrl !== '') {
    $bsWinPath = $baseDir . '/' . ltrim($bsWinUrl, '/');
    $artifacts[] = [
        'id' => 'bootstrap-win',
        'file' => $bsWinUrl,
        'exists' => is_file($bsWinPath),
        'expectedSha256' => strtolower(trim((string)($env['BOOTSTRAP_SHA256_WIN'] ?? ''))),
    ];
}

// Bootstrap launcher — Linux
$bsLinuxUrl = trim((string)($env['BOOTSTRAP_DOWNLOAD_URL_LINUX'] ?? ''));
if ($bsLinuxUrl !== '') {
    $bsLinuxPath = $baseDir . '/' . ltrim($bsLinuxUrl, '/');
    $artifacts[] = [
        'id' => 'bootstrap-linux',
        'file' => $bsLinuxUrl,
        'exists' => is_file($bsLinuxPath),
        'expectedSha256' => strtolower(trim((string)($env['BOOTSTRAP_SHA256_LINUX'] ?? ''))),
    ];
}

// Pełny launcher
$launcherUrl = trim((string)($env['LAUNCHER_DOWNLOAD_URL'] ?? ''));
if ($launcherUrl !== '' && $launcherUrl !== '/downloads') {
    $launcherPath = $baseDir . '/' . ltrim($launcherUrl, '/');
    $artifacts[] = [
        'id' => 'launcher-main',
        'file' => $launcherUrl,
        'exists' => is_file($launcherPath),
        'expectedSha256' => strtolower(trim((string)($env['LAUNCHER_SHA256'] ?? ''))),
    ];
}

// Sprawdzanie SHA-256 (jeśli deep=1)
$allOk = true;
foreach ($artifacts as &$a) {
    if (!$a['exists']) {
        $a['status'] = 'missing';
        $allOk = false;
        continue;
    }

    $filePath = $baseDir . '/' . ltrim($a['file'], '/');

    if ($deep && $a['expectedSha256'] !== '') {
        $actualHash = hash_file('sha256', $filePath);
        $a['actualSha256'] = $actualHash;
        $a['hashMatch'] = ($actualHash === $a['expectedSha256']);
        $a['status'] = $a['hashMatch'] ? 'ok' : 'hash_mismatch';
        if (!$a['hashMatch']) {
            $allOk = false;
        }
    } else {
        $a['status'] = 'ok';
    }

    $a['size'] = filesize($filePath);
    $a['sizeKB'] = (int)ceil($a['size'] / 1024);

    // Nie ujawniaj oczekiwanego hasha w odpowiedzi publicznej
    unset($a['expectedSha256']);
}
unset($a);

json_out([
    'ok' => $allOk,
    'ts' => time(),
    'deep' => $deep,
    'artifacts' => $artifacts,
    'version' => 'artifacts-health-1',
], $allOk ? 200 : 503);
