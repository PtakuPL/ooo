<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * /api/v1/login.php — standalone login endpoint for OTClient/Canary
 * (bez zależności od MyAAC).
 *
 * B1: Obsługuje opcjonalny parametr `gameMode` z requestu klienta.
 * B2: Filtruje listę worldów wg gameMode (classic74 → tylko world classic74, modern → modern).
 *     Zapisuje sesję z gameMode do tabeli `ticket_sessions` (do użycia przez ticket.php).
 *
 * - Czyta konfigurację DB z .env (najpierw /var/www/html/api/v1/.env, potem /var/www/html/.env).
 * - Weryfikuje hasło:
 *      • jeśli w DB jest 40-znakowy hex (SHA1) → porównanie case-insensitive (lower/UPPER)
 *      • w innym wypadku dopuszcza tryb plain (==)
 * - Tworzy sesję z losowym kluczem (UUID) zamiast account\npassword
 * - Buduje listę postaci i dane świata (filtrowane wg gameMode).
 */

// FIX42: Shared utilities (loadEnvFiles, sendError, json_out)
require_once __DIR__ . '/common.php';

$requestStartedAt = microtime(true);

/**
 * PLAN-S2: Dynamic worlds from games table.
 * Replaces hardcoded classic74/modern with DB lookup.
 * World IDs = sort_order - 1 (stable: 0=classic74, 1=modern, matches players.world in DB).
 * F1: Refactored to use PDO (globalDb) instead of mysqli.
 */
function getWorldsForGameMode(string $gameMode, array $ENV, PDO $globalDb): array {
    // Build world entry template
    $buildWorld = function(int $id, string $name, string $ip, int $port): array {
        return [
            'id'                         => $id,
            'name'                       => $name,
            'externaladdress'            => $ip,
            'externaladdressprotected'   => $ip,
            'externaladdressunprotected' => $ip,
            'externalport'               => $port,
            'externalportprotected'      => $port,
            'externalportunprotected'    => $port,
            'previewstate'               => 0,
            'location'                   => 'EUR',
            'anticheatprotection'        => false,
            'pvptype'                    => 0,
            'anticheatprotectiontournament' => false,
            'pvp_type'                   => 0,
            'battleye_protected'         => false,
            'worldstatus'                => 'online',
        ];
    };

    // Query active games, optionally filtered by game_mode
    if ($gameMode !== '' && $gameMode !== 'all') {
        $stmt = $globalDb->prepare(
            "SELECT name, game_host, game_port, sort_order FROM games WHERE game_mode = ? AND status = 'active' ORDER BY sort_order"
        );
        $stmt->execute([$gameMode]);
    } else {
        $stmt = $globalDb->prepare(
            "SELECT name, game_host, game_port, sort_order FROM games WHERE status = 'active' ORDER BY sort_order"
        );
        $stmt->execute();
    }

    $worlds = [];
    while ($row = $stmt->fetch()) {
        // Stable world_id = sort_order - 1 (matches players.world in DB: 0=classic74, 1=modern)
        $worldId = (int)$row['sort_order'] - 1;
        $worlds[] = $buildWorld($worldId, $row['name'], $row['game_host'], (int)$row['game_port']);
    }

    // Fallback: if no games found (empty DB), use .env defaults
    if (empty($worlds)) {
        $worldIp   = $ENV['WORLD_IP']   ?? '127.0.0.1';
        $worldPort = isset($ENV['WORLD_PORT']) ? (int)$ENV['WORLD_PORT'] : 7172;
        $worlds[] = $buildWorld(0, 'Local', $worldIp, $worldPort);
    }

    return $worlds;
}

// ------- read request -------
$raw = file_get_contents('php://input') ?: '';
$req = json_decode($raw, true);
$action = is_array($req) && isset($req['type']) ? (string)$req['type'] : 'login';

if ($action !== 'login') {
    sendError("Unrecognized event {$action}.", 200, 'LCH_BAD_ACTION');
}

$email = isset($req['email']) ? trim((string)$req['email']) : '';
$plain = isset($req['password']) ? (string)$req['password'] : '';
if ($email === '' || $plain === '') {
    sendError('Email or password is empty.', 200, 'LCH_EMPTY_CREDENTIALS');
}

// B1: Opcjonalny gameMode z klienta (classic74 / modern / all / brak)
// PLAN-S2: walidacja dynamiczna z tabeli games — nie hardkodujemy listy
$gameMode = isset($req['gameMode']) ? trim((string)$req['gameMode']) : '';
if ($gameMode !== '' && $gameMode !== 'all') {
    // Walidacja odroczona do momentu po DB connect — zapamiętaj do sprawdzenia
    $gameModeNeedsValidation = true;
} else {
    $gameModeNeedsValidation = false;
}

// ------- DB config (F1: multi-DB) -------
$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env', // /var/www/html/.env
]);

$globalDb = getGlobalDb($ENV);  // accounts, games
$apiDb    = getApiDb($ENV);     // ticket_sessions, launch_tokens

// W71: Rate limiting — per email (10/min) + per IP (30/min)
$clientIpForRate = getClientIp($ENV);
$ipHashRate = hashClientIp($clientIpForRate, $ENV);
$emailHashRate = hash('sha256', strtolower($email));

$rlIp = applyRateLimit($apiDb, 'login:ip', $ipHashRate, 30, 60);
if (!$rlIp['allowed']) {
    logTicketEvent('login.rejected.rate_limited', [
        'endpoint' => 'login.php',
        'bucket' => 'login:ip',
        'ipHash' => $ipHashRate,
        'retryAfter' => $rlIp['retryAfter'],
    ], $ENV);
    sendError('Too many login attempts. Please try again later.', 429, 'LCH_RATE_LIMITED_IP');
}
$rlEmail = applyRateLimit($apiDb, 'login:email', $emailHashRate, 10, 60);
if (!$rlEmail['allowed']) {
    logTicketEvent('login.rejected.rate_limited', [
        'endpoint' => 'login.php',
        'bucket' => 'login:email',
        'ipHash' => $ipHashRate,
        'retryAfter' => $rlEmail['retryAfter'],
    ], $ENV);
    sendError('Too many login attempts for this account. Please try again later.', 429, 'LCH_RATE_LIMITED_EMAIL');
}

$sessionTtl = isset($ENV['SESSION_TTL']) ? (int)$ENV['SESSION_TTL'] : 1800; // 30 min

// PLAN-S2: Dynamiczna walidacja gameMode z tabeli games (GLOBAL_DB)
if ($gameModeNeedsValidation) {
    $vStmt = $globalDb->prepare("SELECT 1 FROM games WHERE game_mode = ? AND status = 'active' LIMIT 1");
    $vStmt->execute([$gameMode]);
    if (!$vStmt->fetch()) {
        sendError('Invalid gameMode: ' . $gameMode, 200, 'LCH_INVALID_GAMEMODE');
    }
}

// ------- fetch account by email (GLOBAL_DB) -------
$stmt = $globalDb->prepare("SELECT id, name, password, premdays, lastday FROM accounts WHERE email = ? LIMIT 1");
$stmt->execute([$email]);
$acc = $stmt->fetch();
if (!$acc) {
    // DEBUG-LOGIN: log account-not-found separately
    $debugLogFile = '/tmp/login_debug.log';
    $debugEntry = json_encode([
        'ts' => gmdate('c'),
        'email' => $email,
        'accountFound' => false,
        'plainLen' => strlen($plain),
        'hasFreshInstall' => isset($req['freshInstall']),
        'hasLaunchToken' => isset($req['launchToken']) && trim((string)$req['launchToken']) !== '',
        'userAgent' => substr((string)($_SERVER['HTTP_USER_AGENT'] ?? ''), 0, 120),
    ], JSON_UNESCAPED_SLASHES) . "\n";
    @file_put_contents($debugLogFile, $debugEntry, FILE_APPEND | LOCK_EX);

    logTicketEvent('login.rejected.account_not_found', [
        'endpoint' => 'login.php',
        'ipHash' => $ipHashRate,
    ], $ENV);
    sendError('Email or password is not correct.', 200, 'LCH_WRONG_CREDENTIALS');
}

// ------- password check (SHA1, argon2/bcrypt, plaintext) -------
$stored = (string)$acc['password'];
$ok = false;
$hashType = 'unknown';
if (strlen($stored) === 40 && ctype_xdigit($stored)) {
    // SHA1 hex — case-insensitive compare
    $hashType = 'sha1';
    $ok = hash_equals(strtolower($stored), strtolower(sha1($plain)));
} elseif (str_starts_with($stored, '$2') || str_starts_with($stored, '$argon2')) {
    // FIX39: bcrypt ($2a$, $2y$) lub argon2 ($argon2id$, $argon2i$) — password_verify
    $hashType = str_starts_with($stored, '$argon2') ? 'argon2' : 'bcrypt';
    $ok = password_verify($plain, $stored);
} else {
    // Fallback: plaintext
    $hashType = 'plain(len=' . strlen($stored) . ')';
    $ok = hash_equals($stored, $plain);
}

// DEBUG-LOGIN: safe diagnostic log (no plaintext password, no full hash)
$debugLogFile = '/tmp/login_debug.log';
$debugEntry = json_encode([
    'ts' => gmdate('c'),
    'email' => $email,
    'accountFound' => true,
    'accountId' => (int)$acc['id'],
    'hashType' => $hashType,
    'storedHashPrefix' => substr($stored, 0, 8) . '...',
    'storedHashLen' => strlen($stored),
    'plainLen' => strlen($plain),
    'passwordMatch' => $ok,
    'hasFreshInstall' => isset($req['freshInstall']),
    'hasLaunchToken' => isset($req['launchToken']) && trim((string)$req['launchToken']) !== '',
    'hasSource' => isset($req['source']),
    'gameMode' => $gameMode,
    'userAgent' => substr((string)($_SERVER['HTTP_USER_AGENT'] ?? ''), 0, 120),
], JSON_UNESCAPED_SLASHES) . "\n";
@file_put_contents($debugLogFile, $debugEntry, FILE_APPEND | LOCK_EX);

if (!$ok) {
    logTicketEvent('login.rejected.bad_password', [
        'endpoint' => 'login.php',
        'accountId' => (int)$acc['id'],
        'ipHash' => $ipHashRate,
        'hashType' => $hashType,
    ], $ENV);
    sendError('Email or password is not correct.', 200, 'LCH_WRONG_CREDENTIALS');
}

// ============================================================
// E11: LaunchToken validation — klient musi przejść przez launcher
// Launcher pobiera token z launcher-token.php i przekazuje go przez env OTC_LAUNCH_TOKEN.
// Klient dołącza token do JSON body logowania (E10).
// Jeden token = jedno logowanie (one-time use, atomowa konsumpcja).
// ============================================================
$launchToken = isset($req['launchToken']) ? trim((string)$req['launchToken']) : '';
$clientLocked = ($ENV['CLIENT_LOCKED'] ?? 'false') === 'true';
$freshInstall = isset($req['freshInstall']) && $req['freshInstall'] === true;
// Web login (source=web) is not subject to CLIENT_LOCKED token checks
$sourceIsWeb = isset($req['source']) && $req['source'] === 'web';

if ($clientLocked && !$freshInstall && !$sourceIsWeb) {
    if ($launchToken === '') {
        sendError('Launch token required. Please use the official launcher.', 200, 'LCH_TOKEN_REQUIRED');
    }

    // FIX-AUD12: użyj getClientIp() z common.php (obsługa trusted proxy)
    $clientIp = getClientIp($ENV);
    $now = time();

    // Atomowa walidacja + konsumpcja tokenu (SELECT FOR UPDATE + DELETE w transakcji) — API_DB
    $apiDb->beginTransaction();
    try {
        $stmt = $apiDb->prepare(
            "SELECT token, client_ip, expires_at, files_hash, manifest_version FROM launch_tokens WHERE token = ? FOR UPDATE"
        );
        $stmt->execute([$launchToken]);
        $tokenRow = $stmt->fetch();

        if (!$tokenRow) {
            $apiDb->rollBack();
            sendError('Invalid launch token. Please restart the launcher.', 200, 'LCH_TOKEN_INVALID');
        }

        // Sprawdź wygaśnięcie (expires_at jest TIMESTAMP/datetime w MySQL)
        if (strtotime($tokenRow['expires_at']) < $now) {
            $delStmt = $apiDb->prepare("DELETE FROM launch_tokens WHERE token = ?");
            $delStmt->execute([$launchToken]);
            $apiDb->commit();
            sendError('Launch token expired. Please restart the launcher.', 200, 'LCH_TOKEN_EXPIRED');
        }

        // Sprawdź IP (token przypisany do IP, z którego launcher go pobrał)
        if ($tokenRow['client_ip'] !== $clientIp) {
            $apiDb->rollBack();
            sendError('Launch token IP mismatch. Do not share tokens.', 200, 'LCH_TOKEN_IP_MISMATCH');
        }

        // Opcjonalnie: sprawdź files_hash (integralność plików klienta)
        $expectedHash = $ENV['EXPECTED_FILES_HASH'] ?? '';
        if ($expectedHash !== '' && $tokenRow['files_hash'] !== $expectedHash) {
            $delStmt = $apiDb->prepare("DELETE FROM launch_tokens WHERE token = ?");
            $delStmt->execute([$launchToken]);
            $apiDb->commit();
            sendError('Client files integrity check failed. Please update your client.', 200, 'LCH_INTEGRITY_FAILED');
        }

        // FIX-AUD6: Weryfikacja manifest_version — odrzuć tokeny z nieaktualną wersją klienta
        $requiredManifest = $ENV['REQUIRED_MANIFEST_VERSION'] ?? '';
        if ($requiredManifest !== '' && isset($tokenRow['manifest_version'])) {
            if ($tokenRow['manifest_version'] !== $requiredManifest) {
                $delStmt = $apiDb->prepare("DELETE FROM launch_tokens WHERE token = ?");
                $delStmt->execute([$launchToken]);
                $apiDb->commit();
                error_log("[login.php] Manifest version mismatch: token has '{$tokenRow['manifest_version']}', required '{$requiredManifest}'");
                sendError('Client version is outdated. Please update via launcher.', 200, 'LCH_VERSION_OUTDATED');
            }
        }

        // Konsumuj: one-time use — usuń token
        $delStmt = $apiDb->prepare("DELETE FROM launch_tokens WHERE token = ?");
        $delStmt->execute([$launchToken]);
        $apiDb->commit();
    } catch (\Exception $e) {
        $apiDb->rollBack();
        sendError('Token validation error.', 200, 'LCH_TOKEN_ERROR');
    }
}

// ------- characters (ENGINE_DB) -------
$chars = [];

// ------- PLAN-S2: dynamic worlds from games table (GLOBAL_DB) -------
$worlds = getWorldsForGameMode($gameMode, $ENV, $globalDb);

// PLAN-S2: worldIdFixed — when a specific gameMode is selected, force characters to that world
$worldIdFixed = null;
if ($gameMode !== '' && $gameMode !== 'all' && count($worlds) === 1) {
    $worldIdFixed = $worlds[0]['id'];
}

// Mapa world id → world id w odpowiedzi (walidacja)
$worldIdsAvailable = array_column($worlds, 'id');

// F1: Query players from engine DB(s) instead of monolith
$playerSql = "SELECT name, level, sex, vocation, looktype, lookhead, lookbody, looklegs, lookfeet, lookaddons, lastlogin, main
              FROM players WHERE account_id = ? AND deletion = 0 ORDER BY name";

if ($gameMode !== '' && $gameMode !== 'all') {
    // Specific game mode — query single engine DB
    $engineDb = getEnginePdo($ENV, $gameMode);
    $stmt = $engineDb->prepare($playerSql);
    $stmt->execute([(int)$acc['id']]);
    while ($p = $stmt->fetch()) {
        $charWorldId = $worldIdFixed ?? 0;
        $chars[] = [
            'worldid'           => $charWorldId,
            'name'              => $p['name'],
            'ismale'            => ((int)$p['sex'] === 1),
            'ismaincharacter'   => ((int)($p['main'] ?? 0) === 1),
            'ishidden'          => false,
            'dailyrewardstate'  => 0,
            'vocation'          => (int)$p['vocation'],
            'level'             => (int)$p['level'],
            'outfitid'          => (int)$p['looktype'],
            'headcolor'         => (int)$p['lookhead'],
            'torsocolor'        => (int)$p['lookbody'],
            'legscolor'         => (int)$p['looklegs'],
            'detailcolor'       => (int)$p['lookfeet'],
            'addonsflags'       => (int)$p['lookaddons'],
            'istutorial'        => false,
            'lastlogin'         => (int)$p['lastlogin'],
        ];
    }
} else {
    // All modes — query both engine DBs and merge
    $engines = getBothEnginePdos($ENV);
    foreach ($engines as $gm => $engineDb) {
        $engineWorldId = ($gm === 'modern') ? 1 : 0;
        if (!in_array($engineWorldId, $worldIdsAvailable, true)) {
            continue;
        }
        try {
            $stmt = $engineDb->prepare($playerSql);
            $stmt->execute([(int)$acc['id']]);
            while ($p = $stmt->fetch()) {
                $chars[] = [
                    'worldid'           => $engineWorldId,
                    'name'              => $p['name'],
                    'ismale'            => ((int)$p['sex'] === 1),
                    'ismaincharacter'   => ((int)($p['main'] ?? 0) === 1),
                    'ishidden'          => false,
                    'dailyrewardstate'  => 0,
                    'vocation'          => (int)$p['vocation'],
                    'level'             => (int)$p['level'],
                    'outfitid'          => (int)$p['looktype'],
                    'headcolor'         => (int)$p['lookhead'],
                    'torsocolor'        => (int)$p['lookbody'],
                    'legscolor'         => (int)$p['looklegs'],
                    'detailcolor'       => (int)$p['lookfeet'],
                    'addonsflags'       => (int)$p['lookaddons'],
                    'istutorial'        => false,
                    'lastlogin'         => (int)$p['lastlogin'],
                ];
            }
        } catch (\PDOException $e) {
            // Engine DB unavailable — skip silently
        }
    }
}

$playdata = ['worlds' => $worlds, 'characters' => $chars];

// ------- B1: session z kluczem UUID + zapis do ticket_sessions -------
// Generujemy losowy session key (NIE account\npassword — bezpieczniejsze).
// Stary format (account\npassword) nadal potrzebny jako fallback dla sessionkey
// w OTClient protocolgame — ale to ticket.php generuje ticket z HMAC.
$sessionUuid = bin2hex(random_bytes(32)); // 64-znakowy hex

// Zapisz sesję do bazy (ticket.php będzie weryfikować) — API_DB
$expiresAt = time() + $sessionTtl;
$stmt = $apiDb->prepare(
    "INSERT INTO ticket_sessions (session_key, account_id, game_mode, expires_at)
     VALUES (?, ?, ?, ?)
     ON DUPLICATE KEY UPDATE account_id = VALUES(account_id), game_mode = VALUES(game_mode), expires_at = VALUES(expires_at)"
);
$accountId = (int)$acc['id'];
$gameModeDb = ($gameMode === '') ? 'all' : $gameMode;
$stmt->execute([$sessionUuid, $accountId, $gameModeDb, $expiresAt]);

// Cleanup: usuń wygasłe sesje (okazyjnie, co ~10% requestów)
if (mt_rand(1, 10) === 1) {
    $now = time();
    $apiDb->exec("DELETE FROM ticket_sessions WHERE expires_at < {$now}");
}

// Session key — UUID (do ticket.php) + legacy format (do protocolgame fallback)
$legacySessionKey = $acc['name'] . "\n" . $plain;

// FIX29+FIX52: Oblicz premium z DB — Canary: lastday = UNIX timestamp KOŃCA premium
// Referencja: account_repository_db.cpp → premiumLastDay = lastday,
//             premiumRemainingDays = (lastday - now) / 86400
//             protocollogin.cpp → isPremium = premiumLastDay > now, premiumUntil = premiumLastDay
$lastDay  = (int)($acc['lastday'] ?? 0);
$isPremium = false;
$premiumUntil = 0;
if ($lastDay > 0) {
    // lastday to timestamp KOŃCA premium (NIE start + dni)
    $premiumUntil = $lastDay;
    $isPremium = ($premiumUntil > time());
}

$session = [
    'sessionkey'    => $sessionUuid,                // B1: nowy UUID session — ticket.php używa tego
    'key'           => $legacySessionKey,            // Legacy — protocolgame bez ticket-gate
    'lastlogintime' => 0,
    'ispremium'     => $isPremium,                   // FIX29: z DB
    'premiumuntil'  => $premiumUntil,                // FIX29: z DB
    'status'        => 'active',
    'gameMode'      => $gameModeDb,                  // B1: gameMode w odpowiedzi
];

$requestEndTime = microtime(true);
$latencyMs = (int)(($requestEndTime - ($requestStartedAt ?? $requestEndTime)) * 1000);
logTicketEvent('login.success', [
    'endpoint' => 'login.php',
    'accountId' => $accountId,
    'gameMode' => $gameModeDb,
    'ipHash' => $ipHashRate,
    'characters' => count($chars),
    'latencyMs' => $latencyMs,
], $ENV);

json_out(['session' => $session, 'playdata' => $playdata]);
