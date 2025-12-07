<?php
header('Content-Type: text/plain; charset=utf-8');
echo "FILE=".__FILE__."\n";
echo "PWD=".__DIR__."\n";
echo "ENV_EXISTS=".(file_exists(__DIR__.'/.env')?'yes':'no')."\n";
echo "HASH_LOGIN_PHP=".(file_exists(__DIR__.'/login.php')?substr(sha1_file(__DIR__.'/login.php'),0,12):'missing')."\n";
