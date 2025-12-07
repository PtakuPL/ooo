<?php
declare(strict_types=1);
@ini_set('display_errors', '0');
@ini_set('log_errors', '1');
@error_reporting(0);

header('Content-Type: application/json; charset=utf-8');

// Minimal env loader (same search order as login.php)
if (!function_exists('env_get')) {
  function env_get(string $key, $default = null) {
    static $env = null;
    if ($env === null) {
      $env = [];
      $candidates = [
        __DIR__ . '/.env',
        __DIR__ . '/../.env',
        '/var/www/html/.env',
      ];
      foreach ($candidates as $envFile) {
        if (@is_file($envFile)) {
          $lines = @file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
          if ($lines !== false) {
            foreach ($lines as $line) {
              if ($line === '' || $line[0] === '#' || strpos($line, '=') === false) { continue; }
              [$k, $v] = array_map('trim', explode('=', $line, 2));
              $env[$k] = trim($v, "\"'");
            }
          }
          break;
        }
      }
      foreach (['_ENV', '_SERVER'] as $src) {
        foreach (($GLOBALS[$src] ?? []) as $k => $v) {
          if (!array_key_exists($k, $env)) { $env[$k] = $v; }
        }
      }
    }
    $val = $env[$key] ?? getenv($key);
    return ($val === false || $val === null) ? $default : $val;
  }
}

$DEBUG = filter_var(env_get('DEBUG', false), FILTER_VALIDATE_BOOLEAN);
$deep  = isset($_GET['deep']) && $_GET['deep'] !== '0';

$worldHost = (string)env_get('OTS_GAME_HOST', env_get('OTS_IP', '127.0.0.1'));
$worldPort = (int)env_get('OTS_GAME_PORT', (int)env_get('OTS_PORT', 7172));

$out = [
  'ok'  => true,
  'ts'  => time(),
  'world' => ['host' => $worldHost, 'port' => $worldPort],
  'version' => 'health-1',
];

if ($deep) {
  $out['db'] = ['aac' => 'skip', 'engine' => 'skip'];
  try {
    $dsn = sprintf('mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
      env_get('DB_HOST','127.0.0.1'), env_get('DB_PORT','3306'), env_get('DB_NAME','canaryaac'));
    $pdo = new PDO($dsn, (string)env_get('DB_USER','root'), (string)env_get('DB_PASS',''), [
      PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);
    $pdo->query('SELECT 1'); $out['db']['aac'] = 'ok';
  } catch (Throwable $e) { $out['db']['aac'] = $DEBUG ? ('fail: '.$e->getMessage()) : 'fail'; }

  try {
    $dsn = sprintf('mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
      env_get('ENGINE_DB_HOST','127.0.0.1'), env_get('ENGINE_DB_PORT','3306'), env_get('ENGINE_DB_NAME','canaryaac'));
    $pdo = new PDO($dsn, (string)env_get('ENGINE_DB_USER','root'), (string)env_get('ENGINE_DB_PASS',''), [
      PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);
    $pdo->query('SELECT 1'); $out['db']['engine'] = 'ok';
  } catch (Throwable $e) { $out['db']['engine'] = $DEBUG ? ('fail: '.$e->getMessage()) : 'fail'; }
}

echo json_encode($out, JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES);
