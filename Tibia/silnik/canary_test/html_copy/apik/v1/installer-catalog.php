<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/common.php';

$env = loadEnvFiles([__DIR__ . '/.env']);

$launcherVersion = trim((string)($env['LAUNCHER_VERSION'] ?? '1.0.0'));
$launcherMinVersion = trim((string)($env['LAUNCHER_MIN_VERSION'] ?? $launcherVersion));
$launcherUrlWin = trim((string)($env['LAUNCHER_DOWNLOAD_URL'] ?? '/downloads'));
$launcherUrlLinux = trim((string)($env['LAUNCHER_DOWNLOAD_URL_LINUX'] ?? ''));
$launcherSha256Win = strtolower(trim((string)($env['LAUNCHER_SHA256'] ?? '')));
$launcherSha256Linux = strtolower(trim((string)($env['LAUNCHER_SHA256_LINUX'] ?? '')));
$launcherFilenameWin = trim((string)($env['LAUNCHER_FILENAME_WIN'] ?? 'launcher-tauri-windows-x86_64.zip'));
$launcherFilenameLinux = trim((string)($env['LAUNCHER_FILENAME_LINUX'] ?? 'launcher-tauri-linux-x86_64.zip'));
$launcherReleaseDate = trim((string)($env['LAUNCHER_RELEASE_DATE'] ?? date('Y-m-d')));
$launcherNotes = trim((string)($env['LAUNCHER_NOTES'] ?? 'Launcher package'));

$fallbackUrl = trim((string)($env['REDDAXE_LAUNCHER_FALLBACK_URL'] ?? '/downloads'));

if ($launcherVersion === '') {
    $launcherVersion = '1.0.0';
}
if ($launcherMinVersion === '') {
    $launcherMinVersion = $launcherVersion;
}
if ($launcherUrlWin === '') {
    $launcherUrlWin = '/downloads';
}
if ($launcherUrlLinux === '') {
    $launcherUrlLinux = str_replace('windows', 'linux', $launcherUrlWin);
}
if ($fallbackUrl === '') {
    $fallbackUrl = '/downloads';
}

if ($launcherSha256Win !== '' && !preg_match('/^[a-f0-9]{64}$/', $launcherSha256Win)) {
    $launcherSha256Win = '';
}
if ($launcherSha256Linux !== '' && !preg_match('/^[a-f0-9]{64}$/', $launcherSha256Linux)) {
    $launcherSha256Linux = '';
}

// ── type filter ──
// ?type=launcher  → only launcher artifacts
// ?type=installer → only installer artifacts (legacy)
// ?type=all (or omitted) → all artifacts
$requestedType = strtolower(trim($_GET['type'] ?? 'all'));
$allowedTypes = ['all', 'launcher', 'installer', 'bootstrap'];
if (!in_array($requestedType, $allowedTypes, true)) {
    $requestedType = 'all';
}

// Build the full artifact list
$allArtifacts = [];

// Launcher artifacts (type = "launcher")
$launcherArtifactWin = [
    'id' => 'launcher-main-win',
    'name' => 'Launcher',
    'type' => 'launcher',
    'platform' => 'windows',
    'arch' => 'x86_64',
    'channel' => 'stable',
    'version' => $launcherVersion,
    'minVersion' => $launcherMinVersion,
    'filename' => $launcherFilenameWin,
    'url' => $launcherUrlWin,
    'sha256' => $launcherSha256Win,
    'releaseDate' => $launcherReleaseDate,
    'notes' => $launcherNotes,
    'fallbackUrl' => $fallbackUrl,
];

$launcherArtifactLinux = [
    'id' => 'launcher-main-linux',
    'name' => 'Launcher',
    'type' => 'launcher',
    'platform' => 'linux',
    'arch' => 'x86_64',
    'channel' => 'stable',
    'version' => $launcherVersion,
    'minVersion' => $launcherMinVersion,
    'filename' => $launcherFilenameLinux,
    'url' => $launcherUrlLinux,
    'sha256' => $launcherSha256Linux,
    'releaseDate' => $launcherReleaseDate,
    'notes' => $launcherNotes,
    'fallbackUrl' => $fallbackUrl,
];

$allArtifacts[] = $launcherArtifactWin;
$allArtifacts[] = $launcherArtifactLinux;

// Bootstrap launcher artifacts (type = "bootstrap")
// Lekki launcher (~KB) pobierany ze strony, jednorazowo instaluje pełny launcher
$bootstrapVersion = trim((string)($env['BOOTSTRAP_VERSION'] ?? '1.0.0'));
$bootstrapUrlWin = trim((string)($env['BOOTSTRAP_DOWNLOAD_URL_WIN'] ?? ''));
$bootstrapUrlLinux = trim((string)($env['BOOTSTRAP_DOWNLOAD_URL_LINUX'] ?? ''));
$bootstrapSha256Win = strtolower(trim((string)($env['BOOTSTRAP_SHA256_WIN'] ?? '')));
$bootstrapSha256Linux = strtolower(trim((string)($env['BOOTSTRAP_SHA256_LINUX'] ?? '')));
$bootstrapReleaseDate = trim((string)($env['BOOTSTRAP_RELEASE_DATE'] ?? date('Y-m-d')));
$bootstrapNotes = trim((string)($env['BOOTSTRAP_NOTES'] ?? 'Lekki launcher'));

if ($bootstrapSha256Win !== '' && !preg_match('/^[a-f0-9]{64}$/', $bootstrapSha256Win)) {
    $bootstrapSha256Win = '';
}
if ($bootstrapSha256Linux !== '' && !preg_match('/^[a-f0-9]{64}$/', $bootstrapSha256Linux)) {
    $bootstrapSha256Linux = '';
}

if ($bootstrapUrlWin !== '') {
    $allArtifacts[] = [
        'id' => 'bootstrap-win',
        'name' => 'Bootstrap Launcher',
        'type' => 'bootstrap',
        'platform' => 'windows',
        'arch' => 'x86_64',
        'channel' => 'stable',
        'version' => $bootstrapVersion,
        'filename' => 'launcher-bootstrap-windows-x86_64.exe',
        'url' => $bootstrapUrlWin,
        'sha256' => $bootstrapSha256Win,
        'releaseDate' => $bootstrapReleaseDate,
        'notes' => $bootstrapNotes,
    ];
}
if ($bootstrapUrlLinux !== '') {
    $allArtifacts[] = [
        'id' => 'bootstrap-linux',
        'name' => 'Bootstrap Launcher',
        'type' => 'bootstrap',
        'platform' => 'linux',
        'arch' => 'x86_64',
        'channel' => 'stable',
        'version' => $bootstrapVersion,
        'filename' => 'launcher-bootstrap-linux-x86_64',
        'url' => $bootstrapUrlLinux,
        'sha256' => $bootstrapSha256Linux,
        'releaseDate' => $bootstrapReleaseDate,
        'notes' => $bootstrapNotes,
    ];
}

// Installer artifacts (type = "installer") — legacy single-entry for backward compat
$installerArtifact = [
    'id' => 'launcher-main',
    'name' => 'Launcher',
    'type' => 'installer',
    'channel' => 'stable',
    'version' => $launcherVersion,
    'minVersion' => $launcherMinVersion,
    'url' => $launcherUrlWin,
    'sha256' => $launcherSha256Win,
    'releaseDate' => $launcherReleaseDate,
    'notes' => $launcherNotes,
    'fallbackUrl' => $fallbackUrl,
];

$allArtifacts[] = $installerArtifact;

// Filter by type
if ($requestedType !== 'all') {
    $allArtifacts = array_values(array_filter($allArtifacts, function ($a) use ($requestedType) {
        return ($a['type'] ?? '') === $requestedType;
    }));
}

header('Cache-Control: public, max-age=120');

json_out([
    'brand' => (string)($env['REDDAXE_BRAND'] ?? 'RedDAXE.pl'),
    'generatedAtUtc' => gmdate('Y-m-d\TH:i:s\Z'),
    'artifacts' => $allArtifacts,
], 200);
