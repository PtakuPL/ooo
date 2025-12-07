<?php
header('Content-Type: text/plain');
echo 'global='. (function_exists('verify_password_any') ? 1 : 0) ."\n";
echo 'ns='. (function_exists('App\\Utils\\verify_password_any') ? 1 : 0) ."\n";
