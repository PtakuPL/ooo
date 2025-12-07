<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

$now = time();
$resp = [
  'ok' => true,
  'kind' => 'api/v1/ping',
  'ts' => $now,
  'iso' => gmdate('c', $now),
  'method' => $_SERVER['REQUEST_METHOD'] ?? '',
  'uri' => $_SERVER['REQUEST_URI'] ?? '',
  'host' => $_SERVER['HTTP_HOST'] ?? '',
  'client' => $_SERVER['REMOTE_ADDR'] ?? '',
  'file' => __FILE__,
  'cwd' => getcwd(),
  'php' => PHP_VERSION,
  'fpm' => (php_sapi_name() === 'fpm-fcgi'),
  'rand' => bin2hex(random_bytes(4)),
];

// Optional: include basic server details with ?details=1
if (isset($_GET['details']) && $_GET['details'] == '1') {
  $resp['server'] = [
    'software' => $_SERVER['SERVER_SOFTWARE'] ?? '',
    'document_root' => $_SERVER['DOCUMENT_ROOT'] ?? '',
    'opcache' => function_exists('opcache_get_status') ? (bool) (opcache_get_status(false)['opcache_enabled'] ?? false) : null,
  ];
}

// Echo back body for quick POST tests
$raw = file_get_contents('php://input');
if ($raw !== false && $raw !== '') {
  $resp['echo'] = $raw;
  $json = json_decode($raw, true);
  if (is_array($json)) {
    $resp['json'] = $json;
  }
}

echo json_encode($resp, JSON_UNESCAPED_SLASHES);
