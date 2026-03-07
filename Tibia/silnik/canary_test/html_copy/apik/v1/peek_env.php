<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');
function env_get($k,$d=null){static $e=null;if($e===null){$e=[];
foreach([__DIR__.'/.env',__DIR__.'/../.env','/var/www/html/.env'] as $f)
 if(@is_file($f)){foreach(@file($f,FILE_IGNORE_NEW_LINES|FILE_SKIP_EMPTY_LINES)?:[] as $l)
 { if($l===''||$l[0]=='#'||strpos($l,'=')===false) continue; [$K,$V]=array_map('trim',explode('=',$l,2)); $e[$K]=trim($V,"\"'"); } break;}
foreach(['_ENV','_SERVER'] as $S) foreach(($GLOBALS[$S]??[]) as $K=>$V) if(!array_key_exists($K,$e)) $e[$K]=$V;}
$v=$e[$k]??getenv($k); return ($v===false||$v===null)?$d:$v;}

// T-01: DEV_MODE guard — diagnostic endpoint, production must return 404
if (strtolower((string)env_get('DEV_MODE', '')) !== 'true') {
    http_response_code(404);
    echo json_encode(['error' => 'Not Found']);
    exit;
}

$out=[
  'ENGINE_DB_HOST'=>env_get('ENGINE_DB_HOST','(def)'),
  'ENGINE_DB_PORT'=>env_get('ENGINE_DB_PORT','(def)'),
  'ENGINE_DB_NAME'=>env_get('ENGINE_DB_NAME','(def)'),
  'ENGINE_DB_USER'=>env_get('ENGINE_DB_USER','(def)'),
  'ENGINE_DB_PASS_len'=>strlen((string)env_get('ENGINE_DB_PASS','')),
];
echo json_encode($out, JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE);
