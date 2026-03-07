<?php
/**
 * Global account profile-mode helpers.
 *
 * Defines the active profile scope for the website session:
 * - all
 * - classic74
 * - modern
 */
defined('MYAAC') or die('Direct access not allowed!');

if (!function_exists('globalProfileAllowedModes')) {
	function globalProfileAllowedModes(): array
	{
		return ['all', 'classic74', 'modern'];
	}
}

if (!function_exists('globalProfileNormalizeMode')) {
	function globalProfileNormalizeMode(string $mode, string $fallback = 'all'): string
	{
		$mode = strtolower(trim($mode));
		if (!in_array($mode, globalProfileAllowedModes(), true)) {
			$mode = strtolower(trim($fallback));
		}
		if (!in_array($mode, globalProfileAllowedModes(), true)) {
			$mode = 'all';
		}
		return $mode;
	}
}

if (!function_exists('globalProfileGetActiveMode')) {
	function globalProfileGetActiveMode(string $fallback = 'all'): string
	{
		$current = (string)getSession('global_profile_mode');
		if ($current === '') {
			$current = $fallback;
		}

		$current = globalProfileNormalizeMode($current, $fallback);
		setSession('global_profile_mode', $current);
		return $current;
	}
}

if (!function_exists('globalProfileSetActiveMode')) {
	function globalProfileSetActiveMode(string $mode): string
	{
		$mode = globalProfileNormalizeMode($mode, 'all');
		setSession('global_profile_mode', $mode);
		return $mode;
	}
}

if (!function_exists('globalProfileModeLabel')) {
	function globalProfileModeLabel(string $mode, array $worldLabels = []): string
	{
		if ($mode === 'classic74') {
			return (string)($worldLabels['classic74'] ?? 'Classic 7.4');
		}
		if ($mode === 'modern') {
			return (string)($worldLabels['modern'] ?? 'Modern');
		}
		return 'All Worlds';
	}
}
