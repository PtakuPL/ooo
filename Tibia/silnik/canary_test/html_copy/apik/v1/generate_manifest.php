<?php
declare(strict_types=1);

/**
 * E1: generate_manifest.php — Generowanie manifestu plików klienta.
 *
 * Skanuje wskazany katalog, oblicza SHA-256 każdego pliku,
 * i generuje manifest JSON gotowy do serwowania przez update.php.
 *
 * Użycie:
 *   php generate_manifest.php [katalog_klienta] [wersja] [kanał]
 *
 * Przykład:
 *   php generate_manifest.php /home/ptaku/serweryt/Tibia/silnik/canary_test/testyy 1.0.0 stable
 *
 * Wynik: zapisuje manifest do ./manifests/{channel}/{version}.json
 *        oraz aktualizuje manifest_versions w MySQL.
 *
 * Pliki ignorowane (nie wchodzą do manifestu):
 *   - .git/        (repozytorium git)
 *   - .gitignore
 *   - *.md         (dokumentacja)
 *   - cache/       (pliki tymczasowe klienta)
 *   - *.log        (logi)
 */

// FIX42: Shared utilities
require_once __DIR__ . '/common.php';

// ------- config -------
$ENV = loadEnvFiles([__DIR__ . '/.env']);

$clientDir = $argv[1] ?? ($ENV['CLIENT_FILES_DIR'] ?? '');
$version   = $argv[2] ?? '0.0.1';
$channel   = $argv[3] ?? ($ENV['UPDATE_CHANNEL'] ?? 'stable');

if ($clientDir === '' || !is_dir($clientDir)) {
    fwrite(STDERR, "Użycie: php generate_manifest.php <katalog_klienta> [wersja] [kanał]\n");
    fwrite(STDERR, "Błąd: Katalog '$clientDir' nie istnieje.\n");
    exit(1);
}

$clientDir = rtrim(realpath($clientDir), '/');

// Wzorce do ignorowania
$ignorePatterns = [
    '#(^|/)\.git(/|$)#',
    '#(^|/)\.gitignore$#',
    '#(^|/)\.env$#',
    '#\.md$#i',
    '#(^|/)cache/#',
    '#\.log$#i',
    '#(^|/)\.DS_Store$#',
    '#(^|/)Thumbs\.db$#',
    '#(^|/)node_modules/#',
    '#(^|/)__pycache__/#',
    '#\.pyc$#',
    '#(^|/)build/#',
    '#(^|/)CMakeFiles/#',
    '#(^|/)compile_commands\.json$#',
    '#(^|/)CMakeCache\.txt$#',
];

function shouldIgnore(string $relativePath, array $patterns): bool {
    foreach ($patterns as $pattern) {
        if (preg_match($pattern, $relativePath)) {
            return true;
        }
    }
    return false;
}

// ------- scan files -------
$files = [];
$totalSize = 0;

$iterator = new RecursiveIteratorIterator(
    new RecursiveDirectoryIterator($clientDir, FilesystemIterator::SKIP_DOTS),
    RecursiveIteratorIterator::LEAVES_ONLY
);

$fileCount = 0;
foreach ($iterator as $file) {
    if (!$file->isFile()) continue;

    $fullPath = $file->getPathname();
    $relativePath = str_replace($clientDir . '/', '', $fullPath);
    // Normalize separators
    $relativePath = str_replace('\\', '/', $relativePath);

    if (shouldIgnore($relativePath, $ignorePatterns)) {
        continue;
    }

    $size = $file->getSize();
    $sha256 = hash_file('sha256', $fullPath);

    $files[] = [
        'path'   => $relativePath,
        'sha256' => $sha256,
        'size'   => $size,
        'url'    => "/files/{$channel}/{$version}/{$relativePath}",
    ];

    $totalSize += $size;
    $fileCount++;

    if ($fileCount % 100 === 0) {
        fwrite(STDERR, "  Skanowanie... {$fileCount} plików\r");
    }
}

// Sort by path for deterministic output
usort($files, fn($a, $b) => strcmp($a['path'], $b['path']));

fwrite(STDERR, "  Przeskanowano: {$fileCount} plików, " . round($totalSize / 1024 / 1024, 1) . " MB\n");

// ------- compute combined hash (for filesHash verification) -------
$hashes = array_map(fn($f) => $f['sha256'], $files);
$combinedHash = hash('sha256', implode('', $hashes));

// ------- build manifest -------
$manifest = [
    'version'     => $version,
    'channel'     => $channel,
    'releaseDate' => date('Y-m-d'),
    'fileCount'   => $fileCount,
    'totalSize'   => $totalSize,
    'filesHash'   => $combinedHash,
    'files'       => $files,
    'changelog'   => [],
];

// ------- save to file -------
$manifestDir = __DIR__ . '/manifests/' . $channel;
if (!is_dir($manifestDir)) {
    mkdir($manifestDir, 0755, true);
}
$manifestFile = $manifestDir . '/' . $version . '.json';
$manifestJson = json_encode($manifest, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
file_put_contents($manifestFile, $manifestJson);

// Also save as "latest.json" symlink/copy
$latestFile = $manifestDir . '/latest.json';
file_put_contents($latestFile, $manifestJson);

fwrite(STDERR, "  Manifest saved: {$manifestFile}\n");
fwrite(STDERR, "  Latest saved:   {$latestFile}\n");
fwrite(STDERR, "  Files hash:     {$combinedHash}\n");

// ------- optional: update DB -------
// FIX-AUD18: fail-closed — wymagaj .env z DB credentials
if (!isset($ENV['DB_USER']) || !isset($ENV['DB_PASS'])) {
    fwrite(STDERR, "  [WARN] DB_USER/DB_PASS not in .env — skipping DB update. Deploy .env first.\n");
} else {
    $dbhost = $ENV['DB_HOST'] ?? '127.0.0.1';
    $dbuser = $ENV['DB_USER'];
    $dbpass = $ENV['DB_PASS'];
    $dbname = $ENV['DB_NAME'] ?? 'canaryaac';
    $dbport = isset($ENV['DB_PORT']) ? (int)$ENV['DB_PORT'] : 3306;

    $mysqli = @new mysqli($dbhost, $dbuser, $dbpass, $dbname, $dbport);
    if (!$mysqli->connect_errno) {
        $mysqli->set_charset('utf8mb4');
        $stmt = $mysqli->prepare(
            "INSERT INTO manifest_versions (version, channel, files_hash, file_count, total_size)
             VALUES (?, ?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE files_hash = VALUES(files_hash), file_count = VALUES(file_count),
                                     total_size = VALUES(total_size), is_active = 1"
        );
        $stmt->bind_param('sssii', $version, $channel, $combinedHash, $fileCount, $totalSize);
        $stmt->execute();
        $stmt->close();
        $mysqli->close();
        fwrite(STDERR, "  DB updated: manifest_versions\n");
    } else {
        fwrite(STDERR, "  UWAGA: Nie udało się połączyć z DB — manifest zapisany tylko do pliku.\n");
    }
} // FIX-AUD18 endif

// Output to stdout as well (for piping)
echo $manifestJson . "\n";
