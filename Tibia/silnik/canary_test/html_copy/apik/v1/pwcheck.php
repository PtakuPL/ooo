<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

// read env
function env_get($k,$d=null){static $e=null;if($e===null){$e=[];
foreach([__DIR__.'/.env',__DIR__.'/../.env','/var/www/html/.env'] as $f)
 if(@is_file($f)){foreach(@file($f,FILE_IGNORE_NEW_LINES|FILE_SKIP_EMPTY_LINES)?:[] as $l)
 { if($l===''||$l[0]=='#'||strpos($l,'=')===false) continue; [$K,$V]=array_map('trim',explode('=',$l,2)); $e[$K]=trim($V,"\"'"); } break;}
foreach(['_ENV','_SERVER'] as $S) foreach(($GLOBALS[$S]??[]) as $K=>$V) if(!array_key_exists($K,$e)) $e[$K]=$V;}
$v=$e[$k]??getenv($k); return ($v===false||$v===null)?$d:$v;}

// Q-04: DEV_MODE guard — this endpoint is for development only
if (strtolower((string)env_get('DEV_MODE', '')) !== 'true') {
    http_response_code(404);
    echo json_encode(['error' => 'Not Found']);
    exit;
}

// Q-04: Rate-limit — max 5 requests per minute per IP
$ip = $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
$rlDir = sys_get_temp_dir() . '/pwcheck_rl';
@mkdir($rlDir, 0700, true);
$rlFile = $rlDir . '/' . md5($ip) . '.json';
$rlData = @json_decode((string)@file_get_contents($rlFile), true) ?: ['ts' => 0, 'cnt' => 0];
$now = time();
if ($now - $rlData['ts'] > 60) {
    $rlData = ['ts' => $now, 'cnt' => 1];
} else {
    $rlData['cnt']++;
}
@file_put_contents($rlFile, json_encode($rlData), LOCK_EX);
if ($rlData['cnt'] > 5) {
    http_response_code(429);
    echo json_encode(['error' => 'Rate limit exceeded, try again later']);
    exit;
}

// read input JSON/POST/GET (priority: JSON > POST > GET)
$raw = file_get_contents('php://input') ?: '';
$in = [];
$ct = $_SERVER['CONTENT_TYPE'] ?? '';
if (stripos($ct,'application/json')!==false) { $in = json_decode($raw,true) ?: []; }
if (empty($in)) { $in = $_POST ?: []; }
if (empty($in)) { $in = $_GET ?: []; }

$login = (string)($in['email'] ?? $in['login'] ?? '');
$plain = (string)($in['password'] ?? '');

$out = ['login'=>$login,'ok'=>false];

try {
  $dsn=sprintf('mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',env_get('DB_HOST','127.0.0.1'),env_get('DB_PORT','3306'),env_get('DB_NAME','canaryaac'));
  $pdo=new PDO($dsn,(string)env_get('DB_USER','root'),(string)env_get('DB_PASS',''),[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
  $st=$pdo->prepare('SELECT id,name,email,password FROM accounts WHERE name=:l OR email=:l LIMIT 1');
  $st->execute([':l'=>$login]);
  if($r=$st->fetch()){
    $h=(string)$r['password'];
    $ok=false;
    if (function_exists('password_verify') && strpos($h,'$')===0) { $ok=password_verify($plain,$h); }
    if (!$ok && preg_match('/^[A-Fa-f0-9]{40}$/',$h)) { $ok = (strtoupper(sha1($plain))===strtoupper($h)); }
    if (!$ok) { $ok = hash_equals($h,$plain); }
    $out['ok']=$ok;
  } else {
    $out['error']='not found';
  }
} catch(Throwable $e){ $out['error']=$e->getMessage(); }

echo json_encode($out,JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE);
