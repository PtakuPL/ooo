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
    '#(^|/)\.gitattributes$#',
    '#(^|/)\.editorconfig$#',
    '#(^|/)\.env$#',
    '#(^|/)\.dockerignore$#',
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
    // Katalogi źródłowe/deweloperskie
    '#(^|/)src/#',
    '#(^|/)cmake/#',
    '#(^|/)\.github/#',
    '#(^|/)vc17/#',
    '#(^|/)android/#',
    '#(^|/)browser/#',
    '#(^|/)docs/#',
    '#(^|/)tests/#',
    '#(^|/)tools/#',
    '#(^|/)freetype-opengl-experiments-master/#',
    '#(^|/)staging_[^/]+/#',
    // Pliki budowania
    '#CMakeLists\.txt$#',
    '#CMakePresets\.json$#',
    '#Dockerfile$#',
    '#\.cpp$#',
    '#\.h$#',
    '#\.hpp$#',
    '#build_log\.txt$#',
    '#(^|/)AUTHORS$#',
    '#(^|/)BUGS$#',
    '#(^|/)LICENSE$#',
    '#Zone\.Identifier$#',
];

$denyPatterns = [
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

function shouldIgnore(string $relativePath, array $patterns): bool {
    foreach ($patterns as $pattern) {
        if (preg_match($pattern, $relativePath)) {
            return true;
        }
    }
    return false;
}

function matchesAnyPattern(string $relativePath, array $patterns): bool {
    foreach ($patterns as $pattern) {
        if (preg_match($pattern, $relativePath)) {
            return true;
        }
    }
    return false;
}


// ─── Buduj listę krytycznych plików z SHA ─────────────────────
function buildCriticalFilesList(array $files, array $patterns): array {
    $result = [];
    foreach ($files as $f) {
        if (in_array($f['path'], $patterns, true)) {
            $result[] = [
                'path'   => $f['path'],
                'sha256' => $f['sha256'],
            ];
        }
    }
    return $result;
}

// ─── Kategoryzacja plików ───────────────────────────────────
function categorizeFile(string $path): array {
    // 1. USER FILES — nie nadpisuj jeśli istnieją
    if ($path === 'otclientrc.lua'
        || str_starts_with($path, 'data/settings/')
    ) {
        return ['managed' => true, 'overwritePolicy' => 'preserve_user'];
    }

    // 2. UNMANAGED — launcher w ogóle nie rusza
    if (str_starts_with($path, 'records/')
        || str_starts_with($path, 'screenshots/')
    ) {
        return ['managed' => false, 'overwritePolicy' => 'never'];
    }

    // 3. Wszystko inne — zarządzane, aktualizowane przy różnicy hash
    return ['managed' => true, 'overwritePolicy' => 'if_hash_differs'];
}

// Lista plików krytycznych (integrity check przed launch)
$criticalFilePatterns = [
    'init.lua',
    'meta.lua',
    'modules/client_entergame/entergame.lua',
    'modules/client_entergame/characterlist.lua',
    'modules/client_serverlist/serverlist.lua',
    'modules/client_serverlist/addserver.lua',
    'modules/startup/startup.lua',
];

// ------- scan files -------
$files = [];
$totalSize = 0;
$blockedFiles = [];

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

    if (matchesAnyPattern($relativePath, $denyPatterns)) {
        $blockedFiles[] = $relativePath;
        continue;
    }

    if (shouldIgnore($relativePath, $ignorePatterns)) {
        continue;
    }

    $size = $file->getSize();
    $sha256 = hash_file('sha256', $fullPath);

    $cat = categorizeFile($relativePath);
    $files[] = [
        'path'            => $relativePath,
        'sha256'          => $sha256,
        'size'            => $size,
        'url'             => "",
        'managed'         => $cat['managed'],
        'overwritePolicy' => $cat['overwritePolicy'],
    ];

    $totalSize += $size;
    $fileCount++;

    if ($fileCount % 100 === 0) {
        fwrite(STDERR, "  Skanowanie... {$fileCount} plików\r");
    }
}

if ($blockedFiles !== [] && (($ENV['ALLOW_DEV_CLIENT_MANIFEST'] ?? '') !== '1')) {
    sort($blockedFiles);
    fwrite(STDERR, "BŁĄD: manifest klienta zawierałby pliki zabronione dla paczki gracza:\n");
    foreach ($blockedFiles as $blockedFile) {
        fwrite(STDERR, "  - {$blockedFile}\n");
    }
    fwrite(STDERR, "Usuń pliki z runtime albo ustaw ALLOW_DEV_CLIENT_MANIFEST=1 tylko dla środowiska dev.\n");
    exit(1);
}

// Sort by path for deterministic output
usort($files, fn($a, $b) => strcmp($a['path'], $b['path']));

fwrite(STDERR, "  Przeskanowano: {$fileCount} plików, " . round($totalSize / 1024 / 1024, 1) . " MB\n");

// ------- compute combined hash (for filesHash verification) -------
$hashes = array_map(fn($f) => $f['sha256'], $files);
$combinedHash = hash('sha256', implode('', $hashes));

// ------- build manifest -------
// Odczytaj BASE_URL z env lub użyj domyślnego
$baseUrl = $ENV['BASE_URL'] ?? 'https://172.29.76.234/apik/v1';

$manifest = [
    'schemaVersion'  => '2.0',
    'manifestId'     => $channel . ':' . $version,
    'version'        => $version,
    'channel'        => $channel,
    'generatedAtUtc' => gmdate('Y-m-d\TH:i:s\Z'),
    'releaseDate'    => date('Y-m-d'),
    'baseUrl'        => $baseUrl . '/files/' . $channel . '/' . $version,
    'fileCount'      => $fileCount,
    'totalSize'      => $totalSize,
    'filesHash'          => $combinedHash,
    'filesHashExpected'  => $combinedHash,
    'files'          => $files,
    'criticalFiles'  => buildCriticalFilesList($files, $criticalFilePatterns),
    'servers'        => buildServersListFromDb($ENV),
    'changelog'      => [],
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
$dbhost = $ENV['DB_HOST'] ?? '127.0.0.1';
$dbuser = $ENV['DB_USER'] ?? 'ptaku';
$dbpass = $ENV['DB_PASS'] ?? '12345678';
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

// Output to stdout as well (for piping)
echo $manifestJson . "\n";

// ─────────────────────────────────────────────

/**
 * INS-64: Build servers list from games DB table.
 * Falls back to .env-based config if DB unavailable.
 */
function buildServersListFromDb(array $ENV): array {
    try {
        $host = $ENV['DB_HOST'] ?? '127.0.0.1';
        $port = (int)($ENV['DB_PORT'] ?? 3306);
        $name = $ENV['DB_NAME'] ?? 'canaryaac';
        $user = $ENV['DB_USER'] ?? 'root';
        $pass = $ENV['DB_PASS'] ?? '';

        $dsn = "mysql:host={$host};port={$port};dbname={$name};charset=utf8mb4";
        $pdo = new PDO($dsn, $user, $pass, [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]);

        $stmt = $pdo->prepare(
            "SELECT id, slug, game_mode, name, game_host, game_port, login_port, status, visible, sort_order
             FROM games
             WHERE status = 'active'
             ORDER BY sort_order ASC"
        );
        $stmt->execute();
        $games = $stmt->fetchAll();

        if (empty($games)) {
            fwrite(STDERR, "  UWAGA: Brak serwerów w DB — używam fallback .env\n");
            return buildServersListFallback($ENV);
        }

        $servers = [];
        foreach ($games as $game) {
            $worldId = (int)$game['sort_order'] - 1;
            $gamePort = (int)$game['game_port'];
            $loginPort = (int)($game['login_port'] ?? 0);
            if ($loginPort <= 0) $loginPort = $gamePort;
            $mode = $game['game_mode'] ?: $game['slug'];

            $servers[] = [
                'id'        => $mode . '-' . $worldId,
                'worldId'   => $worldId,
                'name'      => $game['name'],
                'host'      => $game['game_host'],
                'port'      => $gamePort,
                'loginPort' => $loginPort,
                'gamePort'  => $gamePort,
                'gameMode'  => $mode,
                'visible'   => (bool)($game['visible'] ?? true),
                'enabled'   => true,
                'priority'  => (int)$game['sort_order'],
                'channel'   => 'stable',
            ];
        }

        fwrite(STDERR, "  Serwery z DB: " . count($servers) . " aktywnych\n");
        return $servers;

    } catch (\Throwable $e) {
        fwrite(STDERR, "  UWAGA: DB niedostępna dla serwerów — fallback .env: {$e->getMessage()}\n");
        return buildServersListFallback($ENV);
    }
}

function buildServersListFallback(array $ENV): array {
    return [
        [
            'id'        => 'classic74-0',
            'worldId'   => 0,
            'name'      => 'Classic 7.4',
            'host'      => $ENV['WORLD_CLASSIC74_IP'] ?? $ENV['WORLD_IP'] ?? '127.0.0.1',
            'port'      => (int)($ENV['WORLD_CLASSIC74_PORT'] ?? $ENV['WORLD_PORT'] ?? 7172),
            'loginPort' => (int)($ENV['WORLD_LOGIN_PORT'] ?? 7171),
            'gamePort'  => (int)($ENV['WORLD_CLASSIC74_PORT'] ?? $ENV['WORLD_PORT'] ?? 7172),
            'gameMode'  => 'classic74',
            'visible'   => true,
            'enabled'   => true,
            'priority'  => 1,
            'channel'   => 'stable',
        ],
        [
            'id'        => 'modern-1',
            'worldId'   => 1,
            'name'      => 'Modern',
            'host'      => $ENV['WORLD_MODERN_IP'] ?? $ENV['WORLD_IP'] ?? '127.0.0.1',
            'port'      => (int)($ENV['WORLD_MODERN_PORT'] ?? $ENV['WORLD_PORT'] ?? 7174),
            'loginPort' => (int)($ENV['WORLD_LOGIN_PORT'] ?? 7173),
            'gamePort'  => (int)($ENV['WORLD_MODERN_PORT'] ?? $ENV['WORLD_PORT'] ?? 7174),
            'gameMode'  => 'modern',
            'visible'   => true,
            'enabled'   => true,
            'priority'  => 2,
            'channel'   => 'stable',
        ],
    ];
}
