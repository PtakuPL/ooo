<?php

$serverMode = $_SESSION['server_mode'] ?? 'all';
if (!in_array($serverMode, ['all', 'classic74', 'modern'], true)) {
	$serverMode = 'all';
}

$twig->display('newcomer.html.twig', [
	'server_mode' => $serverMode,
]);
