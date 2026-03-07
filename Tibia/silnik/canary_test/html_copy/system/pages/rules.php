<?php
/**
 * Server rules page with per-mode switch (all/classic74/modern)
 */
defined('MYAAC') or die('Direct access not allowed!');

$title = __('menu_server_rules');

$allowedModes = ['all', 'classic74', 'modern'];
$mode = strtolower((string)($_GET['mode'] ?? getSession('rules_mode')));
if (!in_array($mode, $allowedModes, true)) {
	$mode = 'all';
}
setSession('rules_mode', $mode);

$rulesCandidates = [
	'all' => ['rules_all', 'rules'],
	'classic74' => ['rules_classic74', 'rules_classic', 'rules74', 'rules'],
	'modern' => ['rules_modern', 'rules_modern_server', 'rules'],
];

$resolveRulesContent = static function(array $candidates): array {
	foreach ($candidates as $pageName) {
		$titleBefore = $GLOBALS['title'] ?? '';
		$ignoreBefore = $GLOBALS['ignore'] ?? false;
		$loaded = false;
		$content = getCustomPage($pageName, $loaded);
		$GLOBALS['title'] = $titleBefore;
		$GLOBALS['ignore'] = $ignoreBefore;

		if ($loaded && trim($content) !== '') {
			return ['content' => $content, 'source' => $pageName];
		}
	}

	return ['content' => '', 'source' => null];
};

$result = $resolveRulesContent($rulesCandidates[$mode]);
$fallbackUsed = false;
if ($result['content'] === '' && $mode !== 'all') {
	$fallbackResult = $resolveRulesContent($rulesCandidates['all']);
	if ($fallbackResult['content'] !== '') {
		$result = $fallbackResult;
		$fallbackUsed = true;
	}
}

$tabs = [
	['mode' => 'all', 'label' => __('server_mode_all'), 'link' => BASE_URL . '?subtopic=rules&mode=all'],
	['mode' => 'classic74', 'label' => __('server_mode_classic74'), 'link' => BASE_URL . '?subtopic=rules&mode=classic74'],
	['mode' => 'modern', 'label' => __('server_mode_modern'), 'link' => BASE_URL . '?subtopic=rules&mode=modern'],
];

$twig->display('rules.mode.html.twig', [
	'mode' => $mode,
	'tabs' => $tabs,
	'rules_content' => $result['content'],
	'rules_source' => $result['source'],
	'rules_missing' => $result['content'] === '',
	'fallback_used' => $fallbackUsed,
]);
