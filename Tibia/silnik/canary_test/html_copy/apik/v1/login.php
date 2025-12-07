<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * /api/v1/login.php — standalone login endpoint for OTClient/Canary
 * (bez zależności od MyAAC).
 *
 * - Czyta konfigurację DB z .env (najpierw /var/www/html/api/v1/.env, potem /var/www/html/.env).
 * - Weryfikuje hasło:
 *      • jeśli w DB jest 40-znakowy hex (SHA1) → porównanie case-insensitive (lower/UPPER)
 *      • w innym wypadku dopuszcza tryb plain (==)
 * - Zwraca sessionkey = "<accountName>\n<plainPassword>"
 * - Buduje listę postaci i dane świata.
 */

// ------- utils -------
function sendError(string $msg, int $code = 200): void {
    http_response_code($code); // OTClient oczekuje 200 nawet dla błędów
    echo json_encode(['errorCode' => 3, 'errorMessage' => $msg], JSON_UNESCAPED_SLASHES);
    exit;
}

function json_out($data, int $code = 200): void {
    http_response_code($code);
    echo json_encode($data, JSON_UNESCAPED_SLASHES);
    exit;
}

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

// ------- read request -------
$raw = file_get_contents('php://input') ?: '';
$req = json_decode($raw, true);
$action = is_array($req) && isset($req['type']) ? (string)$req['type'] : 'login';

if ($action !== 'login') {
    sendError("Unrecognized event {$action}.");
}

$email = isset($req['email']) ? trim((string)$req['email']) : '';
$plain = isset($req['password']) ? (string)$req['password'] : '';
if ($email === '' || $plain === '') {
    sendError('Email or password is empty.');
}

// ------- DB config -------
$ENV = loadEnvFiles([
    __DIR__ . '/.env',
    dirname(__DIR__, 2) . '/.env', // /var/www/html/.env
]);

$dbhost = $ENV['DB_HOST'] ?? '127.0.0.1';
$dbuser = $ENV['DB_USER'] ?? 'ptaku';
$dbpass = $ENV['DB_PASS'] ?? '12345678';
$dbname = $ENV['DB_NAME'] ?? 'canaryaac';
$dbport = isset($ENV['DB_PORT']) ? (int)$ENV['DB_PORT'] : 3306;

// ------- connect -------
$mysqli = @new mysqli($dbhost, $dbuser, $dbpass, $dbname, $dbport);
if ($mysqli->connect_errno) {
    sendError('Database connection failed.');
}
$mysqli->set_charset('utf8mb4');

// ------- fetch account by email -------
$stmt = $mysqli->prepare("SELECT id, name, password FROM accounts WHERE email = ? LIMIT 1");
$stmt->bind_param('s', $email);
$stmt->execute();
$res = $stmt->get_result();
if ($res->num_rows === 0) {
    sendError('Email or password is not correct.');
}
$acc = $res->fetch_assoc();
$stmt->close();

// ------- password check (case-insensitive for SHA1 hex) -------
$stored = (string)$acc['password'];
$ok = false;
if (strlen($stored) === 40 && ctype_xdigit($stored)) {
    $ok = hash_equals(strtolower($stored), strtolower(sha1($plain)));
} else {
    $ok = hash_equals($stored, $plain);
}
if (!$ok) {
    sendError('Email or password is not correct.');
}

// ------- characters -------
$chars = [];
$stmt = $mysqli->prepare("SELECT name, level, sex, vocation, looktype, lookhead, lookbody, looklegs, lookfeet, lookaddons, lastlogin
                          FROM players WHERE account_id = ? AND deletion = 0 ORDER BY name");
$stmt->bind_param('i', $acc['id']);
$stmt->execute();
$r = $stmt->get_result();
while ($p = $r->fetch_assoc()) {
    $chars[] = [
        'worldid'     => 0,
        'name'        => $p['name'],
        'ismale'      => ((int)$p['sex'] === 1),
        'vocation'    => (int)$p['vocation'],
        'level'       => (int)$p['level'],
        'outfitid'    => (int)$p['looktype'],
        'headcolor'   => (int)$p['lookhead'],
        'torsocolor'  => (int)$p['lookbody'],
        'legscolor'   => (int)$p['looklegs'],
        'detailcolor' => (int)$p['lookfeet'],
        'addonsflags' => (int)$p['lookaddons'],
        'istutorial'  => false,
        'lastlogin'   => (int)$p['lastlogin'],
    ];
}
$stmt->close();

// ------- world (configurable via .env) -------
$worldIp   = $ENV['WORLD_IP']  ?? '127.0.0.1';
$worldPort = isset($ENV['WORLD_PORT']) ? (int)$ENV['WORLD_PORT'] : 7172;

$world = [
    'id'                         => 0,
    'name'                       => 'Local',
    'externaladdress'            => $worldIp,
    'externaladdressprotected'   => $worldIp,
    'externaladdressunprotected' => $worldIp,
    'externalport'               => $worldPort,
    'externalportprotected'      => $worldPort,
    'externalportunprotected'    => $worldPort,
    'previewstate'               => 0,
    'location'                   => 'EUR',
    'anticheatprotection'        => false,
    'pvptype'                    => 0,
    'anticheatprotectiontournament' => false,
    'pvp_type'                   => 0,
    'battleye_protected'         => false,
    'worldstatus'                => 'online',
];

$playdata = ['worlds' => [$world], 'characters' => $chars];

// ------- session -------
$session = [
    'sessionkey'    => $acc['name'] . "\n" . $plain,
    'key'           => $acc['name'] . "\n" . $plain,
    'lastlogintime' => 0,
    'ispremium'     => false,
    'premiumuntil'  => 0,
    'status'        => 'active',
];

json_out(['session' => $session, 'playdata' => $playdata]);
