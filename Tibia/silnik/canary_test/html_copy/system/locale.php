<?php
/**
 * Locale management and language detection
 *
 * @package   MyAAC
 * @author    Slawkens <slawkens@gmail.com>
 * @copyright 2019 MyAAC
 * @link      https://my-aac.org
 */

defined('MYAAC') or die('Direct access not allowed!');

/**
 * Get current language from various sources
 * Priority: ?lang= parameter > cookie > Accept-Language header > default (en)
 */
function get_current_language() {
	$available_locales = get_locales();
	$detected_locale = config('default_locale') ?: 'pl';
	if (!in_array($detected_locale, $available_locales, true)) {
		$detected_locale = 'en';
	}
	
	// 1. Check URL parameter ?lang=
	if (isset($_GET['lang'])) {
		$lang = $_GET['lang'];
		if (validate_locale($lang)) {
			setcookie('locale', $lang, time() + (365 * 24 * 60 * 60), '/'); // 1 year
			return $lang;
		}
	}
	
	// 2. Check cookie
	if (isset($_COOKIE['locale'])) {
		$lang = $_COOKIE['locale'];
		if (validate_locale($lang)) {
			return $lang;
		}
	}
	
	// 3. Check Accept-Language header
	$browser_langs = get_browser_languages();
	
	foreach ($browser_langs as $lang) {
		if (in_array($lang, $available_locales)) {
			return $lang;
		}
	}
	
	// 4. Fallback to configured default
	return $detected_locale;
}

/**
 * Validate locale code
 */
function validate_locale($locale) {
	if (empty($locale)) {
		return false;
	}
	
	$lang_size = strlen($locale);
	if ($lang_size > 5 || !preg_match("/^[a-z_]+$/", $locale)) {
		return false;
	}
	
	$available_locales = get_locales();
	return in_array($locale, $available_locales);
}

/**
 * Load locale files for current language
 */
function load_locale($lang_code = null) {
	global $locale;
	
	// Initialize $locale as an empty array if it doesn't exist
	if (!isset($locale)) {
		$locale = [];
	}
	
	// Get language code
	if ($lang_code === null) {
		$lang_code = get_current_language();
	}
	
	// Always load English as base (fallback)
	if (file_exists(LOCALE . 'en/main.php')) {
		require LOCALE . 'en/main.php';
	}
	
	// Load admin locale if in admin panel
	if (defined('MYAAC_ADMIN') && file_exists(LOCALE . 'en/admin.php')) {
		require LOCALE . 'en/admin.php';
	}
	
	// Load install locale if in installer
	if (defined('MYAAC_INSTALL') && file_exists(LOCALE . 'en/install.php')) {
		require LOCALE . 'en/install.php';
	}
	
	// Load selected language (if not English)
	if ($lang_code !== 'en') {
		$main_file = LOCALE . $lang_code . '/main.php';
		if (file_exists($main_file)) {
			require $main_file;
		}
		
		if (defined('MYAAC_ADMIN')) {
			$admin_file = LOCALE . $lang_code . '/admin.php';
			if (file_exists($admin_file)) {
				require $admin_file;
			}
		}
		
		if (defined('MYAAC_INSTALL')) {
			$install_file = LOCALE . $lang_code . '/install.php';
			if (file_exists($install_file)) {
				require $install_file;
			}
		}
	}
	
	return $lang_code;
}

/**
 * Get available languages with their native names
 */
function get_available_languages() {
	$locales = get_locales();
	$languages = [];
	
	foreach ($locales as $locale_code) {
		$file = LOCALE . $locale_code . '/main.php';
		if (file_exists($file)) {
			$locale = [];
			require $file;
			
			if (isset($locale['name'])) {
				$languages[$locale_code] = [
					'code' => $locale_code,
					'name' => $locale['name'],
					'lang' => $locale['lang'] ?? $locale_code,
				];
			}
		}
	}
	
	return $languages;
}

// Initialize locale
$current_locale = load_locale();
define('CURRENT_LOCALE', $current_locale);
