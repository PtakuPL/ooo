<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/common.php';

$env = loadEnvFiles([__DIR__ . '/.env']);

function sanitizeCatalogChannel(string $channel): string {
    $channel = strtolower(preg_replace('/[^a-z0-9_-]/i', '', $channel));
    return $channel !== '' ? $channel : 'stable';
}

function envInt(array $env, string $key): ?int {
    $raw = trim((string)($env[$key] ?? ''));
    if ($raw === '' || !ctype_digit($raw)) {
        return null;
    }

    $value = (int)$raw;
    return $value > 0 ? $value : null;
}

function localPathForArtifactUrl(string $url): ?string {
    $path = parse_url($url, PHP_URL_PATH);
    if (!is_string($path) || $path === '' || $path[0] !== '/') {
        return null;
    }

    $webRoot = realpath(__DIR__ . '/../..');
    if ($webRoot === false) {
        return null;
    }

    return $webRoot . '/' . ltrim($path, '/');
}

function artifactSize(array $env, string $envKey, string $url): ?int {
    $fromEnv = envInt($env, $envKey);
    if ($fromEnv !== null) {
        return $fromEnv;
    }

    $localPath = localPathForArtifactUrl($url);
    if ($localPath !== null && is_file($localPath)) {
        $size = filesize($localPath);
        return $size !== false && $size > 0 ? $size : null;
    }

    return null;
}

function artifactSizeFromKeys(array $env, array $envKeys, string $url): ?int {
    foreach ($envKeys as $envKey) {
        $fromEnv = envInt($env, $envKey);
        if ($fromEnv !== null) {
            return $fromEnv;
        }
    }

    $localPath = localPathForArtifactUrl($url);
    if ($localPath !== null && is_file($localPath)) {
        $size = filesize($localPath);
        return $size !== false && $size > 0 ? $size : null;
    }

    return null;
}

$catalogChannel = sanitizeCatalogChannel((string)($_GET['channel'] ?? ($env['UPDATE_CHANNEL'] ?? 'stable')));

$launcherVersion = trim((string)($env['LAUNCHER_VERSION'] ?? '1.0.0'));
$launcherMinVersion = trim((string)($env['LAUNCHER_MIN_VERSION'] ?? $launcherVersion));
$launcherUrlWin = trim((string)($env['LAUNCHER_PACKAGE_URL_WIN'] ?? ($env['LAUNCHER_DOWNLOAD_URL'] ?? '/downloads')));
$launcherUrlLinux = trim((string)($env['LAUNCHER_PACKAGE_URL_LINUX'] ?? ($env['LAUNCHER_DOWNLOAD_URL_LINUX'] ?? '')));
$launcherSha256Win = strtolower(trim((string)($env['LAUNCHER_PACKAGE_SHA256_WIN'] ?? ($env['LAUNCHER_SHA256'] ?? ''))));
$launcherSha256Linux = strtolower(trim((string)($env['LAUNCHER_PACKAGE_SHA256_LINUX'] ?? ($env['LAUNCHER_SHA256_LINUX'] ?? ''))));
$launcherFilenameWin = trim((string)($env['LAUNCHER_PACKAGE_FILENAME_WIN'] ?? ($env['LAUNCHER_FILENAME_WIN'] ?? 'launcher-tauri-windows-x86_64.zip')));
$launcherFilenameLinux = trim((string)($env['LAUNCHER_PACKAGE_FILENAME_LINUX'] ?? ($env['LAUNCHER_FILENAME_LINUX'] ?? 'launcher-tauri-linux-x86_64.zip')));
$launcherSizeWin = artifactSizeFromKeys($env, ['LAUNCHER_PACKAGE_SIZE_WIN', 'LAUNCHER_SIZE_WIN'], $launcherUrlWin);
$launcherSizeLinux = artifactSizeFromKeys($env, ['LAUNCHER_PACKAGE_SIZE_LINUX', 'LAUNCHER_SIZE_LINUX'], $launcherUrlLinux);
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
// ?type=bootstrap → only bootstrap artifacts
// ?type=client    → only client pack artifacts (player/staff)
// ?type=all (or omitted) → all artifacts
$requestedType = strtolower(trim($_GET['type'] ?? 'all'));
$allowedTypes = ['all', 'launcher', 'installer', 'bootstrap', 'client'];
if (!in_array($requestedType, $allowedTypes, true)) {
    $requestedType = 'all';
}

// ── profile filter (for client packs) ──
// ?profile=player → only player client pack
// ?profile=staff  → only staff client pack
$requestedProfile = strtolower(trim($_GET['profile'] ?? ''));

// Build the full artifact list
$allArtifacts = [];

// Launcher artifacts (type = "launcher")
$launcherArtifactWin = [
    'id' => 'launcher-main-win',
    'name' => 'Launcher',
    'type' => 'launcher',
    'platform' => 'windows',
    'arch' => 'x86_64',
    'channel' => $catalogChannel,
    'version' => $launcherVersion,
    'minVersion' => $launcherMinVersion,
    'filename' => $launcherFilenameWin,
    'url' => $launcherUrlWin,
    'sha256' => $launcherSha256Win,
    'size' => $launcherSizeWin,
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
    'channel' => $catalogChannel,
    'version' => $launcherVersion,
    'minVersion' => $launcherMinVersion,
    'filename' => $launcherFilenameLinux,
    'url' => $launcherUrlLinux,
    'sha256' => $launcherSha256Linux,
    'size' => $launcherSizeLinux,
    'releaseDate' => $launcherReleaseDate,
    'notes' => $launcherNotes,
    'fallbackUrl' => $fallbackUrl,
];

if ($launcherUrlWin !== '') {
    $allArtifacts[] = $launcherArtifactWin;
}
if ($launcherUrlLinux !== '') {
    $allArtifacts[] = $launcherArtifactLinux;
}

// Bootstrap launcher artifacts (type = "bootstrap")
// Lekki launcher (~KB) pobierany ze strony, jednorazowo instaluje pełny launcher
$bootstrapVersion = trim((string)($env['BOOTSTRAP_VERSION'] ?? '1.0.0'));
$bootstrapUrlWin = trim((string)($env['BOOTSTRAP_DOWNLOAD_URL_WIN'] ?? ''));
$bootstrapUrlLinux = trim((string)($env['BOOTSTRAP_DOWNLOAD_URL_LINUX'] ?? ''));
$bootstrapSha256Win = strtolower(trim((string)($env['BOOTSTRAP_SHA256_WIN'] ?? '')));
$bootstrapSha256Linux = strtolower(trim((string)($env['BOOTSTRAP_SHA256_LINUX'] ?? '')));
$bootstrapSizeWin = artifactSize($env, 'BOOTSTRAP_SIZE_WIN', $bootstrapUrlWin);
$bootstrapSizeLinux = artifactSize($env, 'BOOTSTRAP_SIZE_LINUX', $bootstrapUrlLinux);
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
        'channel' => $catalogChannel,
        'version' => $bootstrapVersion,
        'filename' => 'launcher-bootstrap-windows-x86_64.exe',
        'url' => $bootstrapUrlWin,
        'sha256' => $bootstrapSha256Win,
        'size' => $bootstrapSizeWin,
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
        'channel' => $catalogChannel,
        'version' => $bootstrapVersion,
        'filename' => 'launcher-bootstrap-linux-x86_64',
        'url' => $bootstrapUrlLinux,
        'sha256' => $bootstrapSha256Linux,
        'size' => $bootstrapSizeLinux,
        'releaseDate' => $bootstrapReleaseDate,
        'notes' => $bootstrapNotes,
    ];
}

// Installer artifacts (type = "installer") — legacy single-entry for backward compat
$installerArtifact = [
    'id' => 'launcher-main',
    'name' => 'Launcher',
    'type' => 'installer',
    'channel' => $catalogChannel,
    'version' => $launcherVersion,
    'minVersion' => $launcherMinVersion,
    'url' => $launcherUrlWin,
    'sha256' => $launcherSha256Win,
    'size' => $launcherSizeWin,
    'releaseDate' => $launcherReleaseDate,
    'notes' => $launcherNotes,
    'fallbackUrl' => $fallbackUrl,
];

$allArtifacts[] = $installerArtifact;

// ── Client pack artifacts (type = "client") ──
// Paczka klienta gry pobierana przez launcher (manifest-based update)
$clientPackVersion = trim((string)($env['CLIENT_PACK_VERSION'] ?? ''));
$clientPackProfile = trim((string)($env['CLIENT_PACK_PROFILE'] ?? 'player'));
$clientPackUrlWin = trim((string)($env['CLIENT_PACK_DOWNLOAD_URL_WIN'] ?? ''));
$clientPackUrlLinux = trim((string)($env['CLIENT_PACK_DOWNLOAD_URL_LINUX'] ?? ''));
$clientPackFilenameWin = trim((string)($env['CLIENT_PACK_FILENAME_WIN'] ?? ''));
$clientPackFilenameLinux = trim((string)($env['CLIENT_PACK_FILENAME_LINUX'] ?? ''));
$clientPackSha256Win = strtolower(trim((string)($env['CLIENT_PACK_SHA256_WIN'] ?? '')));
$clientPackSha256Linux = strtolower(trim((string)($env['CLIENT_PACK_SHA256_LINUX'] ?? '')));
$clientPackSizeWin = artifactSize($env, 'CLIENT_PACK_SIZE_WIN', $clientPackUrlWin);
$clientPackSizeLinux = artifactSize($env, 'CLIENT_PACK_SIZE_LINUX', $clientPackUrlLinux);
$clientPackReleaseDate = trim((string)($env['CLIENT_PACK_RELEASE_DATE'] ?? date('Y-m-d')));
$clientPackNotes = trim((string)($env['CLIENT_PACK_NOTES'] ?? 'Client package'));
$clientPackManifestUrlWin = trim((string)($env['CLIENT_PACK_MANIFEST_URL_WIN'] ?? ''));
$clientPackManifestUrlLinux = trim((string)($env['CLIENT_PACK_MANIFEST_URL_LINUX'] ?? ''));

if ($clientPackSha256Win !== '' && !preg_match('/^[a-f0-9]{64}$/', $clientPackSha256Win)) {
    $clientPackSha256Win = '';
}
if ($clientPackSha256Linux !== '' && !preg_match('/^[a-f0-9]{64}$/', $clientPackSha256Linux)) {
    $clientPackSha256Linux = '';
}

if ($clientPackVersion !== '' && $clientPackUrlWin !== '') {
    $allArtifacts[] = [
        'id' => 'client-' . $clientPackProfile . '-win',
        'name' => 'Player Client',
        'type' => 'client',
        'clientProfile' => $clientPackProfile,
        'platform' => 'windows',
        'arch' => 'x86_64',
        'channel' => $catalogChannel,
        'version' => $clientPackVersion,
        'filename' => $clientPackFilenameWin,
        'url' => $clientPackUrlWin,
        'sha256' => $clientPackSha256Win,
        'size' => $clientPackSizeWin,
        'manifestUrl' => $clientPackManifestUrlWin,
        'releaseDate' => $clientPackReleaseDate,
        'notes' => $clientPackNotes,
    ];
}

if ($clientPackVersion !== '' && $clientPackUrlLinux !== '') {
    $allArtifacts[] = [
        'id' => 'client-' . $clientPackProfile . '-linux',
        'name' => 'Player Client',
        'type' => 'client',
        'clientProfile' => $clientPackProfile,
        'platform' => 'linux',
        'arch' => 'x86_64',
        'channel' => $catalogChannel,
        'version' => $clientPackVersion,
        'filename' => $clientPackFilenameLinux,
        'url' => $clientPackUrlLinux,
        'sha256' => $clientPackSha256Linux,
        'size' => $clientPackSizeLinux,
        'manifestUrl' => $clientPackManifestUrlLinux,
        'releaseDate' => $clientPackReleaseDate,
        'notes' => $clientPackNotes,
    ];
}

// Filter by type
if ($requestedType !== 'all') {
    $allArtifacts = array_values(array_filter($allArtifacts, function ($a) use ($requestedType) {
        return ($a['type'] ?? '') === $requestedType;
    }));
}

// Filter by profile (only applies to client pack artifacts)
if ($requestedProfile !== '' && in_array($requestedProfile, ['player', 'staff', 'dev'], true)) {
    $allArtifacts = array_values(array_filter($allArtifacts, function ($a) use ($requestedProfile) {
        // Non-client artifacts pass through, client artifacts must match profile
        if (($a['type'] ?? '') !== 'client') {
            return true;
        }
        return ($a['clientProfile'] ?? '') === $requestedProfile;
    }));
}

header('Cache-Control: public, max-age=120');

json_out([
    'brand' => (string)($env['REDDAXE_BRAND'] ?? 'RedDAXE.pl'),
    'channel' => $catalogChannel,
    'version' => $launcherVersion,
    'generatedAtUtc' => gmdate('Y-m-d\TH:i:s\Z'),
    'artifacts' => $allArtifacts,
], 200);
