<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * game-profiles.php — API-001
 *
 * GET /apik/v1/game-profiles.php
 *
 * Returns dynamic list of available game profiles (modes/servers) with configuration.
 * This is the single source of truth for game modes — replaces hardcoded GameModes in init.lua.
 *
 * No auth required (public endpoint). Rate limited per IP.
 *
 * Response contract per 15_ARCHITEKTURA_LAUNCHER_KLIENT_KONTRAKTY.md sekcja 4.1:
 * {
 *   "profiles": [{ id, name, description, status, clientVersion, protocolVersion,
 *                   servers: [{ worldId, name, host, port, pvpType, status }],
 *                   features: { hotkeys_items, market, ... },
 *                   loginUrl, ticketUrl, platform: [] }],
 *   "defaultProfile": "classic74"
 * }
 */

require_once __DIR__ . '/common.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendLauncherError('method_not_allowed', 'Only GET is supported.', 405);
}

$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);

$clientIp = getClientIp($ENV);
$ipHash = hashClientIp($clientIp, $ENV);

$db = getApiDb($ENV);

// Rate limit: 20 requests per minute per IP (per 16_BEZPIECZENSTWO_RATE_LIMITS.md)
$rl = applyRateLimit($db, 'game_profiles:ip', $ipHash, 20, 60);
if (!$rl['allowed']) {
    sendLauncherError('rate_limited', 'Too many requests. Try again later.', 429);
}

// Feature flags per game mode — DB-driven when available, fallback to defaults.
// These map directly to what init.lua GameModes[].features currently hardcodes.
$defaultFeatures = [
    'classic74' => [
        'hotkeys_items'  => false,  // jedyne ograniczenie Classic 7.4 — blokada hotkey na runy/itemy
        'hotkeys_spells' => true,
        'quick_loot'     => true,   // KOREKTA 2026-03-18: odblokowane — Classic 7.4 = tylko walka/PvP
        'auto_loot'      => true,
        'market'         => true,
        'action_bar'     => true,
        'smart_equip'    => true,
        'prey'           => true,
        'bestiary'       => true,
        'wheel'          => true,
        'analytics'      => true,
    ],
    'modern' => [
        'hotkeys_items'  => true,
        'hotkeys_spells' => true,
        'quick_loot'     => true,
        'auto_loot'      => true,
        'market'         => true,
        'action_bar'     => true,
        'smart_equip'    => true,
        'prey'           => true,
        'bestiary'       => true,
        'wheel'          => true,
        'analytics'      => true,
    ],
];

$defaultDescriptions = [
    'classic74' => 'Serwer w stylu Tibia 7.4 — ograniczenia hotkeyów na runy/itemy (styl walki 7.4).',
    'modern'    => 'Pełna wersja Tibia — wszystkie nowoczesne funkcje.',
];

$apiBaseUrl = rtrim($ENV['API_BASE_URL'] ?? 'https://tibia.reddaxe.pl/apik/v1', '/');

// Read active games from DB (single source of truth — same table as server-status, ticket, login)
$profiles = [];
try {
    $globalDb = getGlobalDb($ENV);
    $games = getActiveGamesFromDb($globalDb, 'active,maintenance');

    foreach ($games as $game) {
        $slug = (string)($game['game_mode'] ?: $game['slug']);
        $worldId = (int)$game['sort_order'] - 1;

        $features = $defaultFeatures[$slug] ?? $defaultFeatures['modern'];
        $description = $defaultDescriptions[$slug] ?? (string)($game['description'] ?? '');

        $profile = [
            'id'              => $slug,
            'name'            => (string)$game['name'],
            'description'     => $description,
            'status'          => (string)$game['status'],
            'clientVersion'   => 1412,
            'protocolVersion' => 1412,
            'servers'         => [
                [
                    'worldId'  => $worldId,
                    'name'     => (string)$game['name'],
                    'host'     => (string)$game['game_host'],
                    'port'     => (int)$game['game_port'],
                    'pvpType'  => 'open',
                    'status'   => (string)$game['status'],
                ],
            ],
            'features'  => $features,
            'loginUrl'  => $apiBaseUrl . '/login.php',
            'ticketUrl' => $apiBaseUrl . '/ticket.php',
            'platform'  => ['windows', 'linux'],
        ];

        $profiles[] = $profile;
    }
} catch (\PDOException $e) {
    // DB unavailable — return empty profiles (fail-open for read-only data)
}

// Fallback: if no games in DB, return hardcoded defaults (same as init.lua)
if (empty($profiles)) {
    $worldIp = $ENV['WORLD_IP'] ?? 'tibia.reddaxe.pl';

    $profiles = [
        [
            'id'              => 'classic74',
            'name'            => 'Classic 7.4',
            'description'     => $defaultDescriptions['classic74'],
            'status'          => 'active',
            'clientVersion'   => 1412,
            'protocolVersion' => 1412,
            'servers'         => [[
                'worldId'  => 0,
                'name'     => 'Classic 7.4',
                'host'     => $ENV['WORLD_CLASSIC74_IP'] ?? $worldIp,
                'port'     => (int)($ENV['WORLD_CLASSIC74_PORT'] ?? 7172),
                'pvpType'  => 'open',
                'status'   => 'active',
            ]],
            'features'  => $defaultFeatures['classic74'],
            'loginUrl'  => $apiBaseUrl . '/login.php',
            'ticketUrl' => $apiBaseUrl . '/ticket.php',
            'platform'  => ['windows', 'linux'],
        ],
        [
            'id'              => 'modern',
            'name'            => 'Modern 14.20+',
            'description'     => $defaultDescriptions['modern'],
            'status'          => 'active',
            'clientVersion'   => 1412,
            'protocolVersion' => 1412,
            'servers'         => [[
                'worldId'  => 1,
                'name'     => 'Modern',
                'host'     => $ENV['WORLD_MODERN_IP'] ?? $worldIp,
                'port'     => (int)($ENV['WORLD_MODERN_PORT'] ?? 7174),
                'pvpType'  => 'open',
                'status'   => 'active',
            ]],
            'features'  => $defaultFeatures['modern'],
            'loginUrl'  => $apiBaseUrl . '/login.php',
            'ticketUrl' => $apiBaseUrl . '/ticket.php',
            'platform'  => ['windows', 'linux'],
        ],
    ];
}

// Determine default profile
$defaultProfile = 'classic74';
foreach ($profiles as $p) {
    if ($p['status'] === 'active') {
        $defaultProfile = $p['id'];
        break;
    }
}

json_out([
    'profiles'       => $profiles,
    'defaultProfile' => $defaultProfile,
]);
