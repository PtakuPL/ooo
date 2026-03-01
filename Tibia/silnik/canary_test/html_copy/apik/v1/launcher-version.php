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
 *     "changelog": "Initial release"
 *   }
 *
 * required = true → launcher MUSI się zaktualizować (hard block)
 * required = false → opcjonalny update (banner)
 */

// ------- utils -------
function loadEnvFiles(array $paths): array {
    $env = [];
    foreach ($paths as $path) {
        if (!is_file($path)) continue;
        $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        foreach ($lines as $line) {
            $line = trim($line);
            if ($line === '' || $line[0] === '#') continue;
            $eq = strpos($line, '=');
            if ($eq === false) continue;
            $k = trim(substr($line, 0, $eq));
            $v = trim(substr($line, $eq + 1));
            if ((str_starts_with($v, '"') && str_ends_with($v, '"')) ||
                (str_starts_with($v, "'") && str_ends_with($v, "'"))) {
                $v = substr($v, 1, -1);
            }
            $env[$k] = $v;
        }
    }
    return $env;
}

$ENV = loadEnvFiles([__DIR__ . '/.env']);

$currentVersion = $ENV['LAUNCHER_VERSION']     ?? '1.0.0';
$minVersion     = $ENV['LAUNCHER_MIN_VERSION'] ?? '1.0.0';
$downloadUrl    = $ENV['LAUNCHER_DOWNLOAD_URL'] ?? '/files/launcher/launcher.exe';

// Jeśli klient przesyła swoją wersję, sprawdzamy czy potrzebuje update
$clientVersion = isset($_GET['v']) ? trim($_GET['v']) : '';
$required = false;
if ($clientVersion !== '' && version_compare($clientVersion, $minVersion) < 0) {
    $required = true; // hard block — launcher musi się zaktualizować
}

// Cache headers
header('Cache-Control: public, max-age=300');

echo json_encode([
    'version'    => $currentVersion,
    'minVersion' => $minVersion,
    'required'   => $required,
    'url'        => $downloadUrl,
    'changelog'  => 'Initial release — auto-update + ticket-gate integration',
], JSON_UNESCAPED_SLASHES);
