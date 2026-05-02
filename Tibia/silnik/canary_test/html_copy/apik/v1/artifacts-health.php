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

$baseDir = realpath(__DIR__ . '/../..') ?: dirname(__DIR__, 2);

$artifacts = [];

function artifactLocalPath(string $baseDir, string $url): ?string {
    $path = parse_url($url, PHP_URL_PATH);
    if (!is_string($path) || $path === '' || $path[0] !== '/') {
        return null;
    }

    return $baseDir . '/' . ltrim($path, '/');
}

function addArtifactCheck(array &$artifacts, string $id, string $url, string $expectedSha256, string $baseDir): void {
    if ($url === '' || $url === '/downloads') {
        return;
    }

    $path = artifactLocalPath($baseDir, $url);
    $artifacts[] = [
        'id' => $id,
        'file' => $url,
        'path' => $path,
        'exists' => $path !== null && is_file($path),
        'expectedSha256' => strtolower(trim($expectedSha256)),
    ];
}

// Bootstrap launcher — Windows
$bsWinUrl = trim((string)($env['BOOTSTRAP_DOWNLOAD_URL_WIN'] ?? ''));
addArtifactCheck($artifacts, 'bootstrap-win', $bsWinUrl, (string)($env['BOOTSTRAP_SHA256_WIN'] ?? ''), $baseDir);

// Bootstrap launcher — Linux
$bsLinuxUrl = trim((string)($env['BOOTSTRAP_DOWNLOAD_URL_LINUX'] ?? ''));
addArtifactCheck($artifacts, 'bootstrap-linux', $bsLinuxUrl, (string)($env['BOOTSTRAP_SHA256_LINUX'] ?? ''), $baseDir);

// Pełny launcher — paczki instalowane przez bootstrap
$launcherPackageUrlWin = trim((string)($env['LAUNCHER_PACKAGE_URL_WIN'] ?? ''));
addArtifactCheck($artifacts, 'launcher-package-win', $launcherPackageUrlWin, (string)($env['LAUNCHER_PACKAGE_SHA256_WIN'] ?? ''), $baseDir);

$launcherPackageUrlLinux = trim((string)($env['LAUNCHER_PACKAGE_URL_LINUX'] ?? ''));
addArtifactCheck($artifacts, 'launcher-package-linux', $launcherPackageUrlLinux, (string)($env['LAUNCHER_PACKAGE_SHA256_LINUX'] ?? ''), $baseDir);

// Pełny launcher — raw binarki do self-update
$launcherUrl = trim((string)($env['LAUNCHER_DOWNLOAD_URL'] ?? ''));
addArtifactCheck($artifacts, 'launcher-selfupdate-win', $launcherUrl, (string)($env['LAUNCHER_SHA256'] ?? ''), $baseDir);

$launcherUrlLinux = trim((string)($env['LAUNCHER_DOWNLOAD_URL_LINUX'] ?? ''));
addArtifactCheck($artifacts, 'launcher-selfupdate-linux', $launcherUrlLinux, (string)($env['LAUNCHER_SHA256_LINUX'] ?? ''), $baseDir);

// Sprawdzanie SHA-256 (jeśli deep=1)
$allOk = true;
foreach ($artifacts as &$a) {
    if (!$a['exists']) {
        $a['status'] = 'missing';
        $allOk = false;
        continue;
    }

    $filePath = $a['path'];

    if ($filePath === null) {
        $a['status'] = 'invalid_path';
        $allOk = false;
        continue;
    }

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
    unset($a['path']);
}
unset($a);

json_out([
    'ok' => $allOk,
    'ts' => time(),
    'deep' => $deep,
    'artifacts' => $artifacts,
    'version' => 'artifacts-health-1',
], $allOk ? 200 : 503);
