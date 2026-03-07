<?php
/**
 * common.php — shared utilities for all API endpoints.
 * FIX42: Extracted from login.php, ticket.php, launcher-token.php, etc.
 * 
 * Functions:
 *   loadEnvFiles(array $paths): array
 *   sendError(string $msg, int $code = 200): void  [exits]
 *   json_out($data, int $code = 200): void          [exits]
 */
declare(strict_types=1);

if (!function_exists('sendError')) {
    /**
     * Send standardized JSON error response and exit.
     * Format: {"errorCode": 3, "errorMessage": "..."} — compatible with OTClient.
     */
    function sendError(string $msg, int $code = 200): void {
        http_response_code($code);
        echo json_encode(['errorCode' => 3, 'errorMessage' => $msg], JSON_UNESCAPED_SLASHES);
        exit;
    }
}

if (!function_exists('sendLauncherError')) {
    /**
     * Send launcher-contract error response and exit.
     * Format: {"error": "error_code", "message": "human-readable"} — Rust launcher contract.
     * Used by launcher-token.php and other launcher-facing endpoints.
     */
    function sendLauncherError(string $errorCode, string $message, int $httpCode = 400): void {
        http_response_code($httpCode);
        echo json_encode(['error' => $errorCode, 'message' => $message], JSON_UNESCAPED_SLASHES);
        exit;
    }
}

if (!function_exists('json_out')) {
    /**
     * Send JSON response and exit.
     */
    function json_out($data, int $code = 200): void {
        http_response_code($code);
        echo json_encode($data, JSON_UNESCAPED_SLASHES);
        exit;
    }
}

if (!function_exists('loadEnvFiles')) {
    /**
     * Load environment variables from one or more .env files.
     * Later files override earlier ones.
     */
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
}

if (!function_exists('getClientIp')) {
    /**
     * FIX-AUD12: Pobierz prawdziwe IP klienta z obsługą trusted reverse proxy.
     *
     * Obsługiwane nagłówki (w kolejności priorytetu):
     *   1. CF-Connecting-IP  (Cloudflare)
     *   2. X-Real-IP         (nginx)
     *   3. X-Forwarded-For   (ogólny, pierwszy IP = klient)
     *
     * Nagłówki proxy są akceptowane TYLKO jeśli REMOTE_ADDR jest na liście
     * trusted proxies (env TRUSTED_PROXIES — CSV, np. "127.0.0.1,172.16.0.0/12").
     * Domyślnie pusta lista = brak zaufanych proxy → zawsze REMOTE_ADDR.
     *
     * @param array $ENV  Załadowane zmienne środowiskowe (.env)
     */
    function getClientIp(array $ENV = []): string {
        $remoteAddr = $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1';

        // Parsuj trusted proxies z ENV (CSV)
        $trustedRaw = $ENV['TRUSTED_PROXIES'] ?? '';
        if ($trustedRaw === '') {
            return $remoteAddr;
        }

        $trustedList = array_map('trim', explode(',', $trustedRaw));
        $isTrusted = false;
        foreach ($trustedList as $trusted) {
            if (str_contains($trusted, '/')) {
                // CIDR check
                if (_ipInCidr($remoteAddr, $trusted)) {
                    $isTrusted = true;
                    break;
                }
            } elseif ($remoteAddr === $trusted) {
                $isTrusted = true;
                break;
            }
        }

        if (!$isTrusted) {
            return $remoteAddr;
        }

        // Cloudflare
        if (!empty($_SERVER['HTTP_CF_CONNECTING_IP'])) {
            $ip = filter_var($_SERVER['HTTP_CF_CONNECTING_IP'], FILTER_VALIDATE_IP);
            if ($ip !== false) return $ip;
        }
        // nginx X-Real-IP
        if (!empty($_SERVER['HTTP_X_REAL_IP'])) {
            $ip = filter_var($_SERVER['HTTP_X_REAL_IP'], FILTER_VALIDATE_IP);
            if ($ip !== false) return $ip;
        }
        // X-Forwarded-For (first IP = original client)
        if (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
            $parts = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR']);
            $ip = filter_var(trim($parts[0]), FILTER_VALIDATE_IP);
            if ($ip !== false) return $ip;
        }

        return $remoteAddr;
    }
}

if (!function_exists('_ipInCidr')) {
    /**
     * Check if an IP address is within a CIDR range.
     * Supports IPv4 only (sufficient for trusted proxy config).
     */
    function _ipInCidr(string $ip, string $cidr): bool {
        $parts = explode('/', $cidr, 2);
        if (count($parts) !== 2) return false;
        $subnet = ip2long($parts[0]);
        $mask = (int)$parts[1];
        $ipLong = ip2long($ip);
        if ($subnet === false || $ipLong === false || $mask < 0 || $mask > 32) return false;
        $maskBin = $mask === 0 ? 0 : (~0 << (32 - $mask));
        return ($ipLong & $maskBin) === ($subnet & $maskBin);
    }
}

if (!function_exists('requireDbConfig')) {
    /**
     * FIX-AUD18: Fail-closed DB config — wymagaj .env zamiast fallbacku na hardcoded credentials.
     * Zwraca tablicę z kluczami: host, user, pass, name, port.
     * Jeśli .env nie istnieje lub brak DB_USER/DB_PASS — sendError i exit.
     */
    function requireDbConfig(array $ENV): array {
        // Wymagane minimum: DB_USER i DB_PASS muszą być z .env
        if (!isset($ENV['DB_USER']) || !isset($ENV['DB_PASS'])) {
            error_log('[API] FIX-AUD18 BLOCKED: DB_USER or DB_PASS not configured in .env. Deploy .env first.');
            sendError('Server configuration error: database not configured. Contact administrator.');
        }
        return [
            'host' => $ENV['DB_HOST'] ?? '127.0.0.1',
            'user' => $ENV['DB_USER'],
            'pass' => $ENV['DB_PASS'],
            'name' => $ENV['DB_NAME'] ?? 'canaryaac',
            'port' => isset($ENV['DB_PORT']) ? (int)$ENV['DB_PORT'] : 3306,
        ];
    }
}

if (!function_exists('hashClientIp')) {
    /**
     * Zwraca skrót IP do logów bezpieczeństwa (bez trzymania raw IP).
     * Używa LOG_IP_SALT z .env lub fallback do TICKET_SECRET.
     */
    function hashClientIp(string $ip, array $ENV = []): string {
        $salt = (string)($ENV['LOG_IP_SALT'] ?? ($ENV['TICKET_SECRET'] ?? 'serwercanary-dev-salt'));
        return substr(hash('sha256', $salt . '|' . $ip), 0, 16);
    }
}

if (!function_exists('logTicketEvent')) {
    /**
     * Structured security logging (JSONL).
     *
     * Przykład:
     *   logTicketEvent('ticket.issued', [
     *      'endpoint' => 'ticket.php',
     *      'accountId' => 123,
     *      'worldId' => 1,
     *      'ipHash' => 'ab12cd34...',
     *      'latencyMs' => 12,
     *   ], $ENV);
     */
    function logTicketEvent(string $event, array $fields = [], array $ENV = []): void {
        $record = [
            'ts' => gmdate('c'),
            'event' => $event,
        ];

        foreach ($fields as $k => $v) {
            if ($v === null || $v === '') {
                continue;
            }
            $record[$k] = $v;
        }

        $line = json_encode($record, JSON_UNESCAPED_SLASHES);
        if ($line === false) {
            return;
        }
        $line .= PHP_EOL;

        $logFile = (string)($ENV['SECURITY_LOG_FILE'] ?? '/var/log/serwercanary/security-events.log');
        $logDir = dirname($logFile);

        // Best-effort: jeśli katalog nie istnieje, spróbuj utworzyć.
        if (!is_dir($logDir)) {
            @mkdir($logDir, 0750, true);
        }

        // Best-effort: nigdy nie wywal endpointu przez błąd logowania.
        $ok = @file_put_contents($logFile, $line, FILE_APPEND | LOCK_EX);
        if ($ok === false) {
            error_log('[security-event] ' . trim($line));
        }
    }
}

if (!function_exists('applyRateLimit')) {
    /**
     * W71: Generic rate limiting using api_rate_limits table.
     *
     * @param PDO    $db          PDO connection (typically apiDb)
     * @param string $bucket      Rate limit bucket name (e.g., 'login:email', 'register:ip')
     * @param string $keyHash     Hashed key identifying the subject (e.g., hashed email or IP)
     * @param int    $maxHits     Maximum allowed hits within the window
     * @param int    $windowSec   Time window in seconds
     * @return array{allowed:bool, retryAfter:int}
     */
    function applyRateLimit(PDO $db, string $bucket, string $keyHash, int $maxHits, int $windowSec): array {
        if ($maxHits <= 0 || $windowSec <= 0) {
            return ['allowed' => true, 'retryAfter' => 0];
        }

        $now = time();
        try {
            $stmt = $db->prepare(
                "SELECT COUNT(*) AS cnt, MIN(expires_at) AS min_exp
                 FROM api_rate_limits
                 WHERE bucket = ? AND key_hash = ? AND expires_at >= ?"
            );
            $stmt->execute([$bucket, $keyHash, $now]);
            $row = $stmt->fetch();
        } catch (\PDOException $e) {
            // Table missing — allow (fail-open to not break service)
            if (str_contains($e->getMessage(), '1146')) {
                return ['allowed' => true, 'retryAfter' => 0];
            }
            return ['allowed' => true, 'retryAfter' => 0];
        }

        $count = $row ? (int)($row['cnt'] ?? 0) : 0;
        $minExp = $row ? (int)($row['min_exp'] ?? 0) : 0;

        if ($count >= $maxHits) {
            $retryAfter = max(1, $minExp > $now ? ($minExp - $now) : $windowSec);
            return ['allowed' => false, 'retryAfter' => $retryAfter];
        }

        $expiresAt = $now + $windowSec;
        try {
            $ins = $db->prepare(
                "INSERT INTO api_rate_limits (bucket, key_hash, expires_at) VALUES (?, ?, ?)"
            );
            $ins->execute([$bucket, $keyHash, $expiresAt]);
        } catch (\PDOException $e) {
            if (str_contains($e->getMessage(), '1146')) {
                return ['allowed' => true, 'retryAfter' => 0];
            }
        }

        // Probabilistic cleanup (~5% of requests)
        if (mt_rand(1, 20) === 1) {
            try {
                $db->prepare("DELETE FROM api_rate_limits WHERE expires_at < ?")->execute([$now]);
            } catch (\PDOException $e) {
                // ignore
            }
        }

        return ['allowed' => true, 'retryAfter' => 0];
    }
}

if (!function_exists('getEnginePdo')) {
    /**
     * API-06: Dual PDO helper — zwraca połączenie do engine DB na podstawie gameMode.
     *
     * @param array  $ENV      Załadowane zmienne .env
     * @param string $gameMode 'classic74' | 'modern' | 'all' (default: classic)
     * @return PDO
     */
    function getEnginePdo(array $ENV, string $gameMode = 'classic74'): PDO {
        if ($gameMode === 'modern') {
            $host = $ENV['ENGINE_MODERN_DB_HOST'] ?? ($ENV['ENGINE_DB_HOST'] ?? '127.0.0.1');
            $name = $ENV['ENGINE_MODERN_DB_NAME'] ?? 'canary_modern';
            $user = $ENV['ENGINE_MODERN_DB_USER'] ?? ($ENV['ENGINE_DB_USER'] ?? ($ENV['DB_USER'] ?? 'root'));
            $pass = $ENV['ENGINE_MODERN_DB_PASS'] ?? ($ENV['ENGINE_DB_PASS'] ?? ($ENV['DB_PASS'] ?? ''));
            $port = (int)($ENV['ENGINE_MODERN_DB_PORT'] ?? ($ENV['ENGINE_DB_PORT'] ?? 3306));
        } else {
            $host = $ENV['ENGINE_DB_HOST'] ?? ($ENV['DB_HOST'] ?? '127.0.0.1');
            $name = $ENV['ENGINE_DB_NAME'] ?? 'canary';
            $user = $ENV['ENGINE_DB_USER'] ?? ($ENV['DB_USER'] ?? 'root');
            $pass = $ENV['ENGINE_DB_PASS'] ?? ($ENV['DB_PASS'] ?? '');
            $port = (int)($ENV['ENGINE_DB_PORT'] ?? ($ENV['DB_PORT'] ?? 3306));
        }

        $dsn = "mysql:host={$host};port={$port};dbname={$name};charset=utf8mb4";
        return new PDO($dsn, $user, $pass, [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]);
    }
}

if (!function_exists('getAacPdo')) {
    /**
     * API-06: Połączenie do master AAC DB (canaryaac).
     *
     * @param array $ENV Załadowane zmienne .env
     * @return PDO
     */
    function getAacPdo(array $ENV): PDO {
        $dbConf = requireDbConfig($ENV);
        $dsn = "mysql:host={$dbConf['host']};port={$dbConf['port']};dbname={$dbConf['name']};charset=utf8mb4";
        return new PDO($dsn, $dbConf['user'], $dbConf['pass'], [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]);
    }
}

if (!function_exists('getBothEnginePdos')) {
    /**
     * API-06: Zwraca oba połączenia engine (classic + modern) — dla zapytań 'all'.
     *
     * @param array $ENV
     * @return array{classic74: PDO, modern: PDO}
     */
    function getBothEnginePdos(array $ENV): array {
        return [
            'classic74' => getEnginePdo($ENV, 'classic74'),
            'modern'    => getEnginePdo($ENV, 'modern'),
        ];
    }
}

if (!function_exists('getGlobalDb')) {
    /**
     * PLAN-P2: PDO do bazy kont globalnych (global_accounts).
     * Teraz = canaryaac, po separacji F3 = global_accounts.
     */
    function getGlobalDb(array $ENV): PDO {
        $host = $ENV['GLOBAL_DB_HOST'] ?? ($ENV['DB_HOST'] ?? '127.0.0.1');
        $name = $ENV['GLOBAL_DB_NAME'] ?? ($ENV['DB_NAME'] ?? 'canaryaac');
        $user = $ENV['GLOBAL_DB_USER'] ?? ($ENV['DB_USER'] ?? 'root');
        $pass = $ENV['GLOBAL_DB_PASS'] ?? ($ENV['DB_PASS'] ?? '');
        $port = (int)($ENV['GLOBAL_DB_PORT'] ?? ($ENV['DB_PORT'] ?? 3306));

        $dsn = "mysql:host={$host};port={$port};dbname={$name};charset=utf8mb4";
        return new PDO($dsn, $user, $pass, [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]);
    }
}

if (!function_exists('getApiDb')) {
    /**
     * PLAN-P2: PDO do bazy operacyjnej API (api_core).
     * Teraz = canaryaac, po separacji F3 = api_core.
     */
    function getApiDb(array $ENV): PDO {
        $host = $ENV['API_DB_HOST'] ?? ($ENV['DB_HOST'] ?? '127.0.0.1');
        $name = $ENV['API_DB_NAME'] ?? ($ENV['DB_NAME'] ?? 'canaryaac');
        $user = $ENV['API_DB_USER'] ?? ($ENV['DB_USER'] ?? 'root');
        $pass = $ENV['API_DB_PASS'] ?? ($ENV['DB_PASS'] ?? '');
        $port = (int)($ENV['API_DB_PORT'] ?? ($ENV['DB_PORT'] ?? 3306));

        $dsn = "mysql:host={$host};port={$port};dbname={$name};charset=utf8mb4";
        return new PDO($dsn, $user, $pass, [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]);
    }
}

if (!function_exists('getGameDb')) {
    /**
     * PLAN-P2: PDO do engine DB na podstawie game slug.
     * Czyta games table z global_accounts, zwraca PDO do engine DB.
     *
     * @param array  $ENV      Zmienne .env
     * @param string $gameSlug np. 'tibia_classic74', 'tibia_modern'
     * @return PDO
     * @throws RuntimeException jeśli gra nie istnieje lub DB niedostępna
     */
    function getGameDb(array $ENV, string $gameSlug): PDO {
        // Szukaj w games table
        $globalDb = getGlobalDb($ENV);
        $stmt = $globalDb->prepare('SELECT engine_db_name, engine_db_host, engine_db_user, engine_db_pass, engine_db_port FROM games WHERE slug = ? AND status = \'active\' LIMIT 1');
        $stmt->execute([$gameSlug]);
        $game = $stmt->fetch();

        if (!$game) {
            throw new RuntimeException("Game '{$gameSlug}' not found or not active");
        }

        $host = $game['engine_db_host'] ?: '127.0.0.1';
        $name = $game['engine_db_name'];
        $user = $game['engine_db_user'] ?: ($ENV['DB_USER'] ?? 'root');
        $pass = $game['engine_db_pass'] ?: ($ENV['DB_PASS'] ?? '');
        $port = (int)($game['engine_db_port'] ?: 3306);

        $dsn = "mysql:host={$host};port={$port};dbname={$name};charset=utf8mb4";
        return new PDO($dsn, $user, $pass, [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]);
    }
}

if (!function_exists('validateAdminKey')) {
    /**
     * INS-61: Validate admin API key from X-Admin-Key header.
     *
     * Checks key hash against admin_api_keys table.
     * Returns key row on success, calls sendError() and exits on failure.
     *
     * @param PDO    $db         PDO connection (globalDb or aacDb)
     * @param array  $ENV        Loaded .env vars
     * @param string $permission Required permission (e.g. 'games.manage'). '*' always passes.
     * @return array The admin key row (id, name, permissions)
     */
    function validateAdminKey(PDO $db, array $ENV, string $permission = ''): array {
        $rawKey = $_SERVER['HTTP_X_ADMIN_KEY'] ?? '';
        if ($rawKey === '') {
            sendError('Missing X-Admin-Key header', 401);
        }

        $keyHash = hash('sha256', $rawKey);

        try {
            $stmt = $db->prepare(
                "SELECT id, name, permissions, expires_at
                 FROM admin_api_keys
                 WHERE key_hash = ? AND is_active = 1
                 LIMIT 1"
            );
            $stmt->execute([$keyHash]);
            $row = $stmt->fetch();
        } catch (\PDOException $e) {
            error_log('[admin-auth] DB error: ' . $e->getMessage());
            sendError('Server error during authentication', 500);
        }

        if (!$row) {
            sendError('Invalid admin API key', 403);
        }

        // Check expiry
        if ($row['expires_at'] !== null && strtotime($row['expires_at']) < time()) {
            sendError('Admin API key expired', 403);
        }

        // Check permission
        if ($permission !== '' && $row['permissions'] !== '*') {
            $perms = array_map('trim', explode(',', $row['permissions']));
            if (!in_array($permission, $perms, true)) {
                sendError('Insufficient permissions: ' . $permission, 403);
            }
        }

        // Update last_used_at (best-effort)
        try {
            $db->prepare("UPDATE admin_api_keys SET last_used_at = NOW() WHERE id = ?")->execute([$row['id']]);
        } catch (\PDOException $e) {
            // ignore
        }

        return $row;
    }
}

if (!function_exists('logAdminAction')) {
    /**
     * INS-61: Log admin action to admin_audit_log table.
     */
    function logAdminAction(PDO $db, int $keyId, string $action, string $targetType, string $targetId, array $details, array $ENV): void {
        try {
            $ipHash = hashClientIp(getClientIp($ENV), $ENV);
            $stmt = $db->prepare(
                "INSERT INTO admin_audit_log (admin_key_id, action, target_type, target_id, details, ip_hash)
                 VALUES (?, ?, ?, ?, ?, ?)"
            );
            $stmt->execute([$keyId, $action, $targetType, $targetId, json_encode($details), $ipHash]);
        } catch (\PDOException $e) {
            error_log('[admin-audit] Failed to log: ' . $e->getMessage());
        }
    }
}

if (!function_exists('getActiveGamesFromDb')) {
    /**
     * INS-63/64: Read active games from DB for server-status and manifest generation.
     *
     * @param PDO    $db  PDO to global/aac database containing games table
     * @param string $statusFilter Comma-separated statuses (default: 'active,maintenance')
     * @return array List of games rows
     */
    function getActiveGamesFromDb(PDO $db, string $statusFilter = 'active,maintenance'): array {
        $statuses = array_map('trim', explode(',', $statusFilter));
        $placeholders = implode(',', array_fill(0, count($statuses), '?'));

        $stmt = $db->prepare(
            "SELECT id, slug, game_mode, name, description, engine_type, engine_db_name, engine_db_host,
                    game_host, game_port, login_port, platform_windows, platform_linux, platform_android,
                    status, visible, sort_order
             FROM games
             WHERE status IN ({$placeholders})
             ORDER BY sort_order ASC"
        );
        $stmt->execute($statuses);
        return $stmt->fetchAll();
    }
}
