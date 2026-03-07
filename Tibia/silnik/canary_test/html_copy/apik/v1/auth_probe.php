<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

function env_get(string $key, $default=null) {
  static $env=null;
  if ($env===null) {
    $env=[];
    foreach ([__DIR__.'/.env', __DIR__.'/../.env', '/var/www/html/.env'] as $f) {
      if (@is_file($f)) {
        foreach (@file($f, FILE_IGNORE_NEW_LINES|FILE_SKIP_EMPTY_LINES)?:[] as $line) {
          if ($line==='' || $line[0]==='#' || strpos($line,'=')===false) continue;
          [$k,$v]=array_map('trim', explode('=',$line,2));
          $env[$k]=trim($v,"\"'");
        }
        break;
      }
    }
    foreach (['_ENV','_SERVER'] as $S) {
      foreach (($GLOBALS[$S]??[]) as $k=>$v) if (!array_key_exists($k,$env)) $env[$k]=$v;
    }
  }
  $val = $env[$key] ?? getenv($key);
  return ($val===false || $val===null) ? $default : $val;
}

// T-04: DEV_MODE guard — diagnostic endpoint, production must return 404
if (strtolower((string)env_get('DEV_MODE', '')) !== 'true') {
    http_response_code(404);
    echo json_encode(['error' => 'Not Found']);
    exit;
}

// T-04: Rate-limit — max 5 requests per minute per IP
$ip = $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
$rlDir = sys_get_temp_dir() . '/auth_probe_rl';
@mkdir($rlDir, 0700, true);
$rlFile = $rlDir . '/' . md5($ip) . '.json';
$rlData = @json_decode((string)@file_get_contents($rlFile), true) ?: ['ts' => 0, 'cnt' => 0];
$now = time();
if ($now - $rlData['ts'] > 60) { $rlData = ['ts' => $now, 'cnt' => 1]; } else { $rlData['cnt']++; }
@file_put_contents($rlFile, json_encode($rlData), LOCK_EX);
if ($rlData['cnt'] > 5) {
    http_response_code(429);
    echo json_encode(['error' => 'Rate limit exceeded, try again later']);
    exit;
}

function db($host,$port,$name,$user,$pass): PDO {
  $pdo = new PDO(
    "mysql:host={$host};port={$port};dbname={$name};charset=utf8mb4",
    $user,$pass,
    [
      PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,
      PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC,
      PDO::ATTR_EMULATE_PREPARES=>false,
    ]
  );
  return $pdo;
}
function verify_password(string $plain, string $stored): bool {
  $s = trim($stored);
  if ($s==='') return false;
  if (str_starts_with($s,'$argon2') || str_starts_with($s,'$2y$') || str_starts_with($s,'$2a$') || str_starts_with($s,'$2b$')) {
    return verify_password_any($plain,$s);
  }
  if (preg_match('/^[A-Fa-f0-9]{40}$/',$s)) {
    return strtoupper(sha1($plain))===strtoupper($s);
  }
  return hash_equals($s, $plain);
}

$login = trim((string)($_GET['email'] ?? $_GET['login'] ?? ''));
$pass  = (string)($_GET['password'] ?? '');
$out   = ['login'=>$login];

try {
  $pdoAac = db(env_get('DB_HOST','127.0.0.1'), env_get('DB_PORT','3306'), env_get('DB_NAME','canaryaac'), env_get('DB_USER','root'), env_get('DB_PASS',''));
  $st = $pdoAac->prepare("SELECT id,name,email,password FROM accounts WHERE name=:n OR email=:e LIMIT 1");
  $st->execute([':n'=>$login, ':e'=>$login]);
  if ($row = $st->fetch()) {
    $out['aac_row_found'] = true;
    $out['aac_verify']    = verify_password($pass, (string)$row['password']);
    $out['aac_id']        = (int)$row['id'];
    $out['aac_name']      = (string)$row['name'];
  } else {
    $out['aac_row_found'] = false;
  }
} catch (Throwable $e) {
  $out['aac_error'] = $e->getMessage();
}

try {
  $pdoEng = db(env_get('ENGINE_DB_HOST','127.0.0.1'), env_get('ENGINE_DB_PORT','3306'), env_get('ENGINE_DB_NAME','canaryaac'), env_get('ENGINE_DB_USER','root'), env_get('ENGINE_DB_PASS',''));
  $se = $pdoEng->prepare("SELECT id,name,email,password FROM accounts WHERE name=:n OR email=:e LIMIT 1");
  $se->execute([':n'=>$login, ':e'=>$login]);
  if ($row = $se->fetch()) {
    $out['engine_row_found'] = true;
    $out['engine_id']        = (int)$row['id'];
    $out['engine_name']      = (string)$row['name'];
  } else {
    $out['engine_row_found'] = false;
  }
} catch (Throwable $e) {
  $out['engine_error'] = $e->getMessage();
}

echo json_encode($out, JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE);
