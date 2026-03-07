<?php
/**
 * games-manage.php — Admin CRUD API for managing game servers.
 *
 * INS-60: Only accessible with valid admin API key (X-Admin-Key header).
 * All changes are logged to admin_audit_log.
 *
 * Endpoints:
 *   GET    /games-manage.php              — List all games
 *   GET    /games-manage.php?id=1         — Get single game
 *   POST   /games-manage.php              — Create new game server
 *   PUT    /games-manage.php?id=1         — Update existing game server
 *   DELETE /games-manage.php?id=1         — Disable game server (soft delete: status='disabled')
 *
 * Headers:
 *   X-Admin-Key: <your-api-key>
 *   Content-Type: application/json (for POST/PUT)
 *
 * Example — Create new server:
 *   curl -X POST https://your-server/apik/v1/games-manage.php \
 *     -H "X-Admin-Key: your-secret-key" \
 *     -H "Content-Type: application/json" \
 *     -d '{"slug":"tibia_pvp","game_mode":"pvp","name":"PvP Arena","game_host":"10.0.0.5","game_port":7176}'
 *
 * Example — Update server IP:
 *   curl -X PUT "https://your-server/apik/v1/games-manage.php?id=3" \
 *     -H "X-Admin-Key: your-secret-key" \
 *     -H "Content-Type: application/json" \
 *     -d '{"game_host":"10.0.0.6","game_port":7177}'
 */
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/common.php';

$ENV = loadEnvFiles([__DIR__ . '/.env', __DIR__ . '/../.env', '/var/www/html/.env']);

// --- Auth ---
$db = getGlobalDb($ENV);
$adminKey = validateAdminKey($db, $ENV, 'games.manage');

// --- Rate limit admin endpoints (10/min per key) ---
$rl = applyRateLimit($db, 'admin:games', hash('sha256', (string)$adminKey['id']), 10, 60);
if (!$rl['allowed']) {
    http_response_code(429);
    header('Retry-After: ' . $rl['retryAfter']);
    json_out(['error' => 'rate_limited', 'message' => 'Too many admin requests', 'retryAfter' => $rl['retryAfter']], 429);
}

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        handleGet($db, $adminKey, $ENV);
        break;
    case 'POST':
        handleCreate($db, $adminKey, $ENV);
        break;
    case 'PUT':
        handleUpdate($db, $adminKey, $ENV);
        break;
    case 'DELETE':
        handleDelete($db, $adminKey, $ENV);
        break;
    default:
        http_response_code(405);
        json_out(['error' => 'method_not_allowed', 'message' => 'Use GET, POST, PUT, or DELETE'], 405);
}

// ─────────────────────────────────────────────────────────────────

function handleGet(PDO $db, array $adminKey, array $ENV): void {
    $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;

    if ($id > 0) {
        $stmt = $db->prepare("SELECT * FROM games WHERE id = ?");
        $stmt->execute([$id]);
        $game = $stmt->fetch();
        if (!$game) {
            sendError('Game not found', 404);
        }
        json_out(['game' => formatGameRow($game)]);
    } else {
        // List all (optionally filter by status)
        $status = $_GET['status'] ?? '';
        if ($status !== '') {
            $allowed = ['active', 'maintenance', 'disabled'];
            if (!in_array($status, $allowed, true)) {
                sendError('Invalid status filter. Allowed: ' . implode(', ', $allowed));
            }
            $stmt = $db->prepare("SELECT * FROM games WHERE status = ? ORDER BY sort_order ASC");
            $stmt->execute([$status]);
        } else {
            $stmt = $db->prepare("SELECT * FROM games ORDER BY sort_order ASC");
            $stmt->execute();
        }
        $games = $stmt->fetchAll();
        json_out(['games' => array_map('formatGameRow', $games), 'count' => count($games)]);
    }
}

function handleCreate(PDO $db, array $adminKey, array $ENV): void {
    $input = getJsonInput();

    // Required fields
    $required = ['slug', 'game_mode', 'name'];
    foreach ($required as $field) {
        if (!isset($input[$field]) || trim((string)$input[$field]) === '') {
            sendError("Missing required field: {$field}");
        }
    }

    // Validate slug format (alphanumeric + underscore)
    if (!preg_match('/^[a-z0-9_]{2,64}$/', $input['slug'])) {
        sendError('Invalid slug format. Use lowercase alphanumeric + underscore, 2-64 chars.');
    }

    // Validate game_mode format
    if (!preg_match('/^[a-z0-9_]{2,32}$/', $input['game_mode'])) {
        sendError('Invalid game_mode format. Use lowercase alphanumeric + underscore, 2-32 chars.');
    }

    // Check slug uniqueness
    $check = $db->prepare("SELECT id FROM games WHERE slug = ?");
    $check->execute([$input['slug']]);
    if ($check->fetch()) {
        sendError('Game with this slug already exists');
    }

    // Build insert data with defaults
    $data = [
        'slug'             => $input['slug'],
        'game_mode'        => $input['game_mode'],
        'name'             => substr(trim($input['name']), 0, 128),
        'description'      => substr(trim($input['description'] ?? ''), 0, 255),
        'engine_type'      => $input['engine_type'] ?? 'canary',
        'engine_db_name'   => $input['engine_db_name'] ?? '',
        'engine_db_host'   => $input['engine_db_host'] ?? '127.0.0.1',
        'game_host'        => $input['game_host'] ?? '127.0.0.1',
        'game_port'        => (int)($input['game_port'] ?? 7172),
        'login_port'       => (int)($input['login_port'] ?? 0),
        'platform_windows' => (int)($input['platform_windows'] ?? 1),
        'platform_linux'   => (int)($input['platform_linux'] ?? 1),
        'platform_android' => (int)($input['platform_android'] ?? 0),
        'status'           => 'active',
        'visible'          => (int)($input['visible'] ?? 1),
        'sort_order'       => (int)($input['sort_order'] ?? 0),
    ];

    // Validate game_host (basic IP/hostname check)
    if (!filter_var($data['game_host'], FILTER_VALIDATE_IP) &&
        !preg_match('/^[a-zA-Z0-9][a-zA-Z0-9.\-]{0,126}$/', $data['game_host'])) {
        sendError('Invalid game_host: must be IP address or valid hostname');
    }

    // Validate port range
    if ($data['game_port'] < 1 || $data['game_port'] > 65535) {
        sendError('Invalid game_port: must be 1-65535');
    }

    $stmt = $db->prepare(
        "INSERT INTO games (slug, game_mode, name, description, engine_type, engine_db_name, engine_db_host,
                            game_host, game_port, login_port, platform_windows, platform_linux, platform_android,
                            status, visible, sort_order)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
    );
    try {
        $stmt->execute([
            $data['slug'], $data['game_mode'], $data['name'], $data['description'],
            $data['engine_type'], $data['engine_db_name'], $data['engine_db_host'],
            $data['game_host'], $data['game_port'], $data['login_port'],
            $data['platform_windows'], $data['platform_linux'], $data['platform_android'],
            $data['status'], $data['visible'], $data['sort_order'],
        ]);
    } catch (\PDOException $e) {
        if (str_starts_with($e->getCode(), '23')) {
            sendError('Duplicate slug or constraint violation', 409);
        }
        throw $e;
    }

    $newId = (int)$db->lastInsertId();

    logAdminAction($db, (int)$adminKey['id'], 'games.create', 'games', (string)$newId, $data, $ENV);

    http_response_code(201);
    json_out(['success' => true, 'id' => $newId, 'game' => $data]);
}

function handleUpdate(PDO $db, array $adminKey, array $ENV): void {
    $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
    if ($id <= 0) {
        sendError('Missing ?id= parameter');
    }

    // Check game exists
    $stmt = $db->prepare("SELECT * FROM games WHERE id = ?");
    $stmt->execute([$id]);
    $existing = $stmt->fetch();
    if (!$existing) {
        sendError('Game not found', 404);
    }

    $input = getJsonInput();
    if (empty($input)) {
        sendError('Request body is empty');
    }

    // Allowed fields to update
    $allowed = [
        'game_mode', 'name', 'description', 'engine_type', 'engine_db_name', 'engine_db_host',
        'game_host', 'game_port', 'login_port', 'platform_windows', 'platform_linux',
        'platform_android', 'status', 'visible', 'sort_order',
    ];

    $sets = [];
    $params = [];
    $changes = [];

    foreach ($allowed as $field) {
        if (!array_key_exists($field, $input)) continue;

        $val = $input[$field];

        // Validate specific fields
        if ($field === 'game_host') {
            if (!filter_var($val, FILTER_VALIDATE_IP) &&
                !preg_match('/^[a-zA-Z0-9][a-zA-Z0-9.\-]{0,126}$/', (string)$val)) {
                sendError('Invalid game_host');
            }
        }
        if ($field === 'game_port' || $field === 'login_port') {
            $val = (int)$val;
            if ($field === 'game_port' && ($val < 1 || $val > 65535)) {
                sendError("Invalid {$field}: must be 1-65535");
            }
        }
        if ($field === 'status') {
            if (!in_array($val, ['active', 'maintenance', 'disabled'], true)) {
                sendError('Invalid status. Allowed: active, maintenance, disabled');
            }
        }
        if ($field === 'game_mode') {
            if (!preg_match('/^[a-z0-9_]{2,32}$/', (string)$val)) {
                sendError('Invalid game_mode format');
            }
        }

        $changes[$field] = ['from' => $existing[$field] ?? null, 'to' => $val];
        $sets[] = "`{$field}` = ?";
        $params[] = $val;
    }

    if (empty($sets)) {
        sendError('No valid fields to update');
    }

    $params[] = $id;
    $sql = "UPDATE games SET " . implode(', ', $sets) . " WHERE id = ?";
    try {
        $db->prepare($sql)->execute($params);
    } catch (\PDOException $e) {
        error_log('[games-manage.php] UPDATE failed: ' . $e->getMessage());
        sendError('Database error: ' . ($e->getCode() === '23000' ? 'Duplicate value or constraint violation' : 'Update failed'), 500);
    }

    logAdminAction($db, (int)$adminKey['id'], 'games.update', 'games', (string)$id, $changes, $ENV);

    json_out(['success' => true, 'id' => $id, 'updated' => array_keys($changes)]);
}

function handleDelete(PDO $db, array $adminKey, array $ENV): void {
    $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
    if ($id <= 0) {
        sendError('Missing ?id= parameter');
    }

    $stmt = $db->prepare("SELECT id, slug, name, status FROM games WHERE id = ?");
    $stmt->execute([$id]);
    $existing = $stmt->fetch();
    if (!$existing) {
        sendError('Game not found', 404);
    }

    // Soft delete: set status to 'disabled'
    $db->prepare("UPDATE games SET status = 'disabled' WHERE id = ?")->execute([$id]);

    logAdminAction($db, (int)$adminKey['id'], 'games.delete', 'games', (string)$id, [
        'slug' => $existing['slug'],
        'name' => $existing['name'],
        'previous_status' => $existing['status'],
    ], $ENV);

    json_out(['success' => true, 'id' => $id, 'message' => 'Game disabled (soft delete)']);
}

// ─────────────────────────────────────────────────────────────────

function getJsonInput(): array {
    $raw = file_get_contents('php://input');
    if ($raw === '' || $raw === false) {
        return [];
    }
    $data = json_decode($raw, true);
    if (!is_array($data)) {
        sendError('Invalid JSON body');
    }
    return $data;
}

function formatGameRow(array $row): array {
    return [
        'id'               => (int)$row['id'],
        'slug'             => $row['slug'],
        'game_mode'        => $row['game_mode'] ?? '',
        'name'             => $row['name'],
        'description'      => $row['description'] ?? '',
        'engine_type'      => $row['engine_type'],
        'engine_db_name'   => $row['engine_db_name'],
        'game_host'        => $row['game_host'],
        'game_port'        => (int)$row['game_port'],
        'login_port'       => (int)($row['login_port'] ?? 0),
        'platform_windows' => (bool)$row['platform_windows'],
        'platform_linux'   => (bool)$row['platform_linux'],
        'platform_android' => (bool)($row['platform_android'] ?? false),
        'status'           => $row['status'],
        'visible'          => (bool)($row['visible'] ?? true),
        'sort_order'       => (int)$row['sort_order'],
        'created_at'       => $row['created_at'] ?? null,
        'updated_at'       => $row['updated_at'] ?? null,
    ];
}
