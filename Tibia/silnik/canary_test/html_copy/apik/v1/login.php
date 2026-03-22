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
 * - Weryfikuje hasło albo launcherowy `sessionToken`.
 * - Tworzy sesję z losowym kluczem (UUID) zamiast account\npassword.
 * - Buduje listę postaci i dane świata (filtrowane wg gameMode).
 */

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
    // OTC-014: dodano online_players — klient może wyświetlić status serwera
    $buildWorld = function(int $id, string $name, string $ip, int $port, int $onlinePlayers = 0): array {
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
            'online_players'             => $onlinePlayers,
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
$sessionToken = isset($req['sessionToken']) ? trim((string)$req['sessionToken']) : '';
if ($sessionToken === '' && ($email === '' || $plain === '')) {
    sendError('Email or password is empty.', 200, 'LCH_EMPTY_CREDENTIALS');
}

// B1: Opcjonalny gameMode z klienta (classic74 / modern / all / brak)
// PLAN-S2: walidacja dynamiczna z tabeli games — nie hardkodujemy listy
$gameMode = isset($req['gameMode']) ? trim((string)$req['gameMode']) : '';
if ($gameMode !== '' && $gameMode !== 'all') {
    $gameModeNeedsValidation = true;
} else {
    $gameModeNeedsValidation = false;
}

// ------- DB config (F1: multi-DB) -------
$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env',
]);

$globalDb = getGlobalDb($ENV);  // accounts, games
$apiDb    = getApiDb($ENV);     // ticket_sessions, launch_tokens

// W71: Rate limiting — per IP + per email/session
$clientIpForRate = getClientIp($ENV);
$ipHashRate = hashClientIp($clientIpForRate, $ENV);

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

if ($sessionToken !== '') {
    if (strlen($sessionToken) > 256 || !ctype_xdigit($sessionToken)) {
        sendError('Invalid launcher session. Please log in again in launcher.', 200, 'LCH_SESSION_TOKEN_INVALID');
    }
    $sessionHashRate = hash('sha256', strtolower($sessionToken));
    $rlSession = applyRateLimit($apiDb, 'login:session', $sessionHashRate, 30, 60);
    if (!$rlSession['allowed']) {
        logTicketEvent('login.rejected.rate_limited', [
            'endpoint' => 'login.php',
            'bucket' => 'login:session',
            'ipHash' => $ipHashRate,
            'retryAfter' => $rlSession['retryAfter'],
        ], $ENV);
        sendError('Too many login attempts for this launcher session. Please try again later.', 429, 'LCH_RATE_LIMITED_SESSION');
    }
} else {
    $emailHashRate = hash('sha256', strtolower($email));
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
}

$sessionTtl = isset($ENV['SESSION_TTL']) ? (int)$ENV['SESSION_TTL'] : 1800;

// PLAN-S2: Dynamiczna walidacja gameMode z tabeli games (GLOBAL_DB)
if ($gameModeNeedsValidation) {
    $vStmt = $globalDb->prepare("SELECT 1 FROM games WHERE game_mode = ? AND status = 'active' LIMIT 1");
    $vStmt->execute([$gameMode]);
    if (!$vStmt->fetch()) {
        sendError('Invalid gameMode: ' . $gameMode, 200, 'LCH_INVALID_GAMEMODE');
    }
}

$authMethod = ($sessionToken !== '') ? 'session_token' : 'password';

if ($sessionToken !== '') {
    $sessionLookup = $apiDb->prepare(
        "SELECT session_key, account_id, game_mode, expires_at FROM ticket_sessions WHERE session_key = ? LIMIT 1"
    );
    $sessionLookup->execute([$sessionToken]);
    $launcherSession = $sessionLookup->fetch();
    if (!$launcherSession) {
        logTicketEvent('login.rejected.invalid_session_token', [
            'endpoint' => 'login.php',
            'ipHash' => $ipHashRate,
        ], $ENV);
        sendError('Invalid launcher session. Please log in again in launcher.', 200, 'LCH_SESSION_TOKEN_INVALID');
    }

    $now = time();
    if ((int)$launcherSession['expires_at'] < $now) {
        $deleteSession = $apiDb->prepare("DELETE FROM ticket_sessions WHERE session_key = ?");
        $deleteSession->execute([$sessionToken]);
        logTicketEvent('login.rejected.expired_session_token', [
            'endpoint' => 'login.php',
            'ipHash' => $ipHashRate,
        ], $ENV);
        sendError('Launcher session expired. Please log in again in launcher.', 200, 'LCH_SESSION_TOKEN_EXPIRED');
    }

    $stmt = $globalDb->prepare("SELECT id, name, password, premdays, lastday FROM accounts WHERE id = ? LIMIT 1");
    $stmt->execute([(int)$launcherSession['account_id']]);
    $acc = $stmt->fetch();
    if (!$acc) {
        logTicketEvent('login.rejected.account_not_found', [
            'endpoint' => 'login.php',
            'ipHash' => $ipHashRate,
        ], $ENV);
        sendError('Account linked to launcher session was not found.', 200, 'LCH_SESSION_TOKEN_ACCOUNT_MISSING');
    }
} else {
    // ------- fetch account by email (GLOBAL_DB) -------
    $stmt = $globalDb->prepare("SELECT id, name, password, premdays, lastday FROM accounts WHERE email = ? LIMIT 1");
    $stmt->execute([$email]);
    $acc = $stmt->fetch();
    if (!$acc) {
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
        $hashType = 'sha1';
        $ok = hash_equals(strtolower($stored), strtolower(sha1($plain)));
    } elseif (str_starts_with($stored, '$2') || str_starts_with($stored, '$argon2')) {
        $hashType = str_starts_with($stored, '$argon2') ? 'argon2' : 'bcrypt';
        $ok = password_verify($plain, $stored);
    } else {
        $hashType = 'plain(len=' . strlen($stored) . ')';
        $ok = hash_equals($stored, $plain);
    }

    if (!$ok) {
        logTicketEvent('login.rejected.bad_password', [
            'endpoint' => 'login.php',
            'accountId' => (int)$acc['id'],
            'ipHash' => $ipHashRate,
            'hashType' => $hashType,
        ], $ENV);
        sendError('Email or password is not correct.', 200, 'LCH_WRONG_CREDENTIALS');
    }
}

// ============================================================
// E11: LaunchToken validation — klient musi przejść przez launcher
// Launcher pobiera token z launcher-token.php i przekazuje go przez env OTC_LAUNCH_TOKEN.
// Klient dołącza token do JSON body logowania.
// Jeden token = jedno logowanie (one-time use, atomowa konsumpcja).
// ============================================================
$launchToken = isset($req['launchToken']) ? trim((string)$req['launchToken']) : '';
$clientLocked = ($ENV['CLIENT_LOCKED'] ?? 'false') === 'true';
$freshInstall = isset($req['freshInstall']) && $req['freshInstall'] === true;
$sourceIsWeb = isset($req['source']) && $req['source'] === 'web';

if ($clientLocked && !$freshInstall && !$sourceIsWeb) {
    if ($launchToken === '') {
        sendError('Launch token required. Please use the official launcher.', 200, 'LCH_TOKEN_REQUIRED');
    }

    $clientIp = getClientIp($ENV);
    $now = time();

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

        if (strtotime($tokenRow['expires_at']) < $now) {
            $delStmt = $apiDb->prepare("DELETE FROM launch_tokens WHERE token = ?");
            $delStmt->execute([$launchToken]);
            $apiDb->commit();
            sendError('Launch token expired. Please restart the launcher.', 200, 'LCH_TOKEN_EXPIRED');
        }

        if ($tokenRow['client_ip'] !== $clientIp) {
            $apiDb->rollBack();
            sendError('Launch token IP mismatch. Do not share tokens.', 200, 'LCH_TOKEN_IP_MISMATCH');
        }

        $expectedHash = $ENV['EXPECTED_FILES_HASH'] ?? '';
        if ($expectedHash !== '' && $tokenRow['files_hash'] !== $expectedHash) {
            $delStmt = $apiDb->prepare("DELETE FROM launch_tokens WHERE token = ?");
            $delStmt->execute([$launchToken]);
            $apiDb->commit();
            sendError('Client files integrity check failed. Please update your client.', 200, 'LCH_INTEGRITY_FAILED');
        }

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

$worldIdFixed = null;
if ($gameMode !== '' && $gameMode !== 'all' && count($worlds) === 1) {
    $worldIdFixed = $worlds[0]['id'];
}

$worldIdsAvailable = array_column($worlds, 'id');

$playerSql = "SELECT name, level, sex, vocation, looktype, lookhead, lookbody, looklegs, lookfeet, lookaddons, lastlogin, main
              FROM players WHERE account_id = ? AND deletion = 0 ORDER BY name";

if ($gameMode !== '' && $gameMode !== 'all') {
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

// ------- OTC-013: Account ban check -------
$banInfo = null;
$banStmt = $globalDb->prepare(
    "SELECT reason, expires_at FROM account_bans WHERE account_id = ? LIMIT 1"
);
$banStmt->execute([(int)$acc['id']]);
$banRow = $banStmt->fetch();
if ($banRow) {
    $banExpires = (int)$banRow['expires_at'];
    if ($banExpires > time()) {
        $banInfo = [
            'reason'    => $banRow['reason'],
            'expiresAt' => $banExpires,
        ];
    }
}

// ------- B1: session z kluczem UUID + zapis do ticket_sessions -------
$sessionUuid = bin2hex(random_bytes(32));

$expiresAt = time() + $sessionTtl;
$stmt = $apiDb->prepare(
    "INSERT INTO ticket_sessions (session_key, account_id, game_mode, expires_at)
     VALUES (?, ?, ?, ?)
     ON DUPLICATE KEY UPDATE account_id = VALUES(account_id), game_mode = VALUES(game_mode), expires_at = VALUES(expires_at)"
);
$accountId = (int)$acc['id'];
$gameModeDb = ($gameMode === '') ? 'all' : $gameMode;
$stmt->execute([$sessionUuid, $accountId, $gameModeDb, $expiresAt]);

if (mt_rand(1, 10) === 1) {
    $now = time();
    $apiDb->exec("DELETE FROM ticket_sessions WHERE expires_at < {$now}");
}

$legacySessionKey = ($sessionToken === '') ? ($acc['name'] . "\n" . $plain) : $sessionUuid;

$lastDay  = (int)($acc['lastday'] ?? 0);
$isPremium = false;
$premiumUntil = 0;
if ($lastDay > 0) {
    $premiumUntil = $lastDay;
    $isPremium = ($premiumUntil > time());
}

$session = [
    'sessionkey'    => $sessionUuid,
    'key'           => $legacySessionKey,
    'lastlogintime' => 0,
    'ispremium'     => $isPremium,
    'premiumuntil'  => $premiumUntil,
    'status'        => 'active',
    'gameMode'      => $gameModeDb,
];

if ($banInfo !== null) {
    $session['accountBan'] = $banInfo;
}

$requestEndTime = microtime(true);
$latencyMs = (int)(($requestEndTime - ($requestStartedAt ?? $requestEndTime)) * 1000);
logTicketEvent('login.success', [
    'endpoint' => 'login.php',
    'accountId' => $accountId,
    'authMethod' => $authMethod,
    'gameMode' => $gameModeDb,
    'ipHash' => $ipHashRate,
    'characters' => count($chars),
    'latencyMs' => $latencyMs,
], $ENV);

json_out(['session' => $session, 'playdata' => $playdata]);
