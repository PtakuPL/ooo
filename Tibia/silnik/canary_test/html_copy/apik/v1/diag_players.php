<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

function env_get($k,$d=null){static $e=null;if($e===null){$e=[];
foreach([__DIR__.'/.env',__DIR__.'/../.env','/var/www/html/.env'] as $f)
 if(@is_file($f)){foreach(@file($f,FILE_IGNORE_NEW_LINES|FILE_SKIP_EMPTY_LINES)?:[] as $l)
 { if($l===''||$l[0]=='#'||strpos($l,'=')===false) continue; [$K,$V]=array_map('trim',explode('=',$l,2)); $e[$K]=trim($V,"\"'"); } break;}
foreach(['_ENV','_SERVER'] as $S) foreach(($GLOBALS[$S]??[]) as $K=>$V) if(!array_key_exists($K,$e)) $e[$K]=$V;}
$v=$e[$k]??getenv($k); return ($v===false||$v===null)?$d:$v;}

// T-02: DEV_MODE guard — diagnostic endpoint, production must return 404
if (strtolower((string)env_get('DEV_MODE', '')) !== 'true') {
    http_response_code(404);
    echo json_encode(['error' => 'Not Found']);
    exit;
}

// T-02: Rate-limit — max 5 requests per minute per IP
$ip = $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
$rlDir = sys_get_temp_dir() . '/diag_players_rl';
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

$out = ['engine_db'=>env_get('ENGINE_DB_NAME','(default)')];

try {
  $pdo = new PDO(
    sprintf('mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4', env_get('ENGINE_DB_HOST','127.0.0.1'), env_get('ENGINE_DB_PORT','3306'), env_get('ENGINE_DB_NAME','canaryaac')),
    (string)env_get('ENGINE_DB_USER','root'), (string)env_get('ENGINE_DB_PASS',''),
    [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]
  );

  // 1) znajdź konto po name/email
  $login = $_GET['login'] ?? $_GET['email'] ?? 'proeloptaku3@wp.pl';
  $st = $pdo->prepare("SELECT id,name,email FROM accounts WHERE name=:l OR email=:l LIMIT 1");
  $st->execute([':l'=>$login]);
  $acc = $st->fetch();
  $out['engine_account'] = $acc ?: '(not found)';

  // 2) policz postacie po ID z engine
  if ($acc) {
    $st = $pdo->prepare("SELECT COUNT(*) FROM players WHERE account_id = :id");
    $st->execute([':id'=>(int)$acc['id']]);
    $out['players_count'] = (int)$st->fetchColumn();
  }

  // 3) sprawdź istnienie kolumn
  $cols = ['level','vocation','sex','looktype','lookaddons','lookbody','lookfeet','lookhead','looklegs','lastlogin'];
  $exist = [];
  foreach ($cols as $c) {
    $q = $pdo->prepare("SHOW COLUMNS FROM players LIKE :c");
    $q->execute([':c'=>$c]);
    $exist[$c] = (bool)$q->fetch();
  }
  $out['players_columns'] = $exist;

  // 4) spróbuj wykonać dokładnie ten SELECT jak w login.php i złap komunikat
  try {
    $q = $pdo->prepare("SELECT id, name, level, vocation, sex, looktype, lookaddons, lookbody, lookfeet, lookhead, looklegs, lastlogin
                        FROM players WHERE account_id = :id ORDER BY name ASC LIMIT 1");
    $q->execute([':id'=>$acc ? (int)$acc['id'] : 0]);
    $out['sample_row'] = $q->fetch() ?: '(no row)';
    $out['sample_ok'] = true;
  } catch (Throwable $e) {
    $out['sample_ok'] = false;
    $out['sample_error'] = $e->getMessage();
  }

} catch (Throwable $e) {
  $out['error'] = $e->getMessage();
}

echo json_encode($out, JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE);
