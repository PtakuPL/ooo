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