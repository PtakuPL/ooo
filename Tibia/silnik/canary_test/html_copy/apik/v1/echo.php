<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

// T-03: DEV_MODE guard — diagnostic endpoint, production must return 404
function env_get_echo($k,$d=null){static $e=null;if($e===null){$e=[];
foreach([__DIR__.'/.env',__DIR__.'/../.env','/var/www/html/.env'] as $f)
 if(@is_file($f)){foreach(@file($f,FILE_IGNORE_NEW_LINES|FILE_SKIP_EMPTY_LINES)?:[] as $l)
 { if($l===''||$l[0]=='#'||strpos($l,'=')===false) continue; [$K,$V]=array_map('trim',explode('=',$l,2)); $e[$K]=trim($V,"\"'"); } break;}
foreach(['_ENV','_SERVER'] as $S) foreach(($GLOBALS[$S]??[]) as $K=>$V) if(!array_key_exists($K,$e)) $e[$K]=$V;}
$v=$e[$k]??getenv($k); return ($v===false||$v===null)?$d:$v;}
if (strtolower((string)env_get_echo('DEV_MODE', '')) !== 'true') {
    http_response_code(404);
    echo json_encode(['error' => 'Not Found']);
    exit;
}

$raw = file_get_contents('php://input');
$in = json_decode($raw, true);
if (!is_array($in)) { $in = $_POST ?? []; }
echo json_encode(['raw'=>$raw, 'parsed'=>$in], JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE);
