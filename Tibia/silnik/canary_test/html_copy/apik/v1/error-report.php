<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * error-report.php — przyjmuje raporty o błędach z launchera.
 *
 * POST /apik/v1/error-report.php
 * Body: { "errorCode": "...", "message": "...", "context": {...}, "launcherVersion": "...", "os": "..." }
 *
 * Rate limit: max 5 raportów per IP na minutę.
 * Logi: /var/log/serwercanary/error-reports.log (JSONL)
 */

require_once __DIR__ . '/common.php';

$ENV = loadEnvFiles([__DIR__ . '/.env', __DIR__ . '/../.env', '/var/www/html/.env']);

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    json_out(['error' => 'method_not_allowed']);
    exit;
}

// ------- Parse input -------
$raw = file_get_contents('php://input');
if ($raw === false || $raw === '') {
    http_response_code(400);
    json_out(['error' => 'empty_body']);
    exit;
}

$body = json_decode($raw, true);
if (!is_array($body)) {
    http_response_code(400);
    json_out(['error' => 'invalid_json']);
    exit;
}

// ------- Extract and sanitize fields -------
$errorCode       = mb_substr(trim((string)($body['errorCode'] ?? 'unknown')), 0, 100);
$message         = mb_substr(trim((string)($body['message'] ?? '')), 0, 2000);
$launcherVersion = mb_substr(trim((string)($body['launcherVersion'] ?? '')), 0, 20);
$os              = mb_substr(trim((string)($body['os'] ?? '')), 0, 50);
$context         = $body['context'] ?? null;

// Sanitize context: limit size, remove any deeply nested structures
if (is_array($context)) {
    $contextJson = json_encode($context);
    if ($contextJson === false || strlen($contextJson) > 4096) {
        $context = ['_truncated' => true, '_original_size' => strlen((string)$contextJson)];
    }
} else {
    $context = null;
}

if ($errorCode === '' || $errorCode === 'unknown') {
    http_response_code(400);
    json_out(['error' => 'missing_error_code']);
    exit;
}

// ------- Rate limiting (IP-based, in-memory via temp file) -------
$clientIp = getClientIp($ENV);
$ipHash = hashClientIp($clientIp, $ENV);
$rateFile = sys_get_temp_dir() . '/serwercanary_errrate_' . md5($clientIp);
$now = time();
$maxPerMinute = 5;

$attempts = [];
if (file_exists($rateFile)) {
    $data = @file_get_contents($rateFile);
    if ($data !== false) {
        $attempts = array_filter(
            explode("\n", trim($data)),
            fn($ts) => $ts !== '' && ((int)$ts) > ($now - 60)
        );
    }
}

if (count($attempts) >= $maxPerMinute) {
    http_response_code(429);
    json_out(['error' => 'rate_limited', 'retryAfterSeconds' => 60]);
    exit;
}

$attempts[] = (string)$now;
@file_put_contents($rateFile, implode("\n", $attempts));

// ------- Write to log -------
$record = [
    'ts'               => gmdate('c'),
    'event'            => 'error_report',
    'errorCode'        => $errorCode,
    'message'          => $message,
    'launcherVersion'  => $launcherVersion,
    'os'               => $os,
    'ipHash'           => $ipHash,
];

if ($context !== null) {
    $record['context'] = $context;
}

$logFile = (string)($ENV['ERROR_REPORT_LOG_FILE'] ?? '/var/log/serwercanary/error-reports.log');
$logDir = dirname($logFile);
if (!is_dir($logDir)) {
    @mkdir($logDir, 0750, true);
}

$line = json_encode($record, JSON_UNESCAPED_SLASHES) . PHP_EOL;
$ok = @file_put_contents($logFile, $line, FILE_APPEND | LOCK_EX);
if ($ok === false) {
    error_log('[error-report] Failed to write: ' . trim($line));
}

// ------- Response -------
json_out(['status' => 'accepted', 'id' => substr(md5($line), 0, 12)]);
