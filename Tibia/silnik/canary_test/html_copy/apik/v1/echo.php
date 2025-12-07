<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');
$raw = file_get_contents('php://input');
$in = json_decode($raw, true);
if (!is_array($in)) { $in = $_POST ?? []; }
echo json_encode(['raw'=>$raw, 'parsed'=>$in], JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE);
