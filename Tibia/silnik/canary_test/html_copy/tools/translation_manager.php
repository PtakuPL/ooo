#!/usr/bin/env php
<?php
/**
 * Translation Management Tool
 * 
 * This script helps manage translations across all locale files:
 * - Generate translation templates
 * - Validate completeness
 * - Show statistics and missing keys
 * 
 * Usage:
 *   php tools/translation_manager.php --action=stats
 *   php tools/translation_manager.php --action=template --lang=es
 *   php tools/translation_manager.php --action=validate
 */

define('MYAAC', true);
define('LOCALE_DIR', __DIR__ . '/../system/locale/');

// Parse command line arguments
$options = getopt('', ['action:', 'lang::', 'output::']);
$action = $options['action'] ?? 'help';

/**
 * Get all available locales
 */
function get_locales() {
	$locales = [];
	foreach (scandir(LOCALE_DIR) as $dir) {
		if ($dir[0] !== '.' && is_dir(LOCALE_DIR . $dir)) {
			$locales[] = $dir;
		}
	}
	return $locales;
}

/**
 * Load all translation keys from a locale
 */
function load_locale_keys($locale, $file) {
	$filepath = LOCALE_DIR . $locale . '/' . $file . '.php';
	if (!file_exists($filepath)) {
		return [];
	}
	
	$locale = [];
	require $filepath;
	return $locale;
}

/**
 * Get all unique keys from English (master) locale
 */
function get_master_keys() {
	$files = ['main', 'admin', 'install'];
	$all_keys = [];
	
	foreach ($files as $file) {
		$keys = load_locale_keys('en', $file);
		$all_keys[$file] = array_keys($keys);
	}
	
	return $all_keys;
}

/**
 * Show translation statistics
 */
function show_stats() {
	echo "Translation Statistics\n";
	echo str_repeat('=', 80) . "\n\n";
	
	$locales = get_locales();
	$master_keys = get_master_keys();
	$files = ['main', 'admin', 'install'];
	
	$total_master = 0;
	foreach ($master_keys as $file => $keys) {
		$total_master += count($keys);
	}
	
	echo sprintf("%-10s", "Locale");
	foreach ($files as $file) {
		echo sprintf("%-15s", ucfirst($file));
	}
	echo sprintf("%-15s%-15s\n", "Total", "Complete %");
	echo str_repeat('-', 80) . "\n";
	
	foreach ($locales as $locale) {
		echo sprintf("%-10s", $locale);
		$total_translated = 0;
		
		foreach ($files as $file) {
			$keys = load_locale_keys($locale, $file);
			$count = count($keys);
			$total_translated += $count;
			
			$master_count = count($master_keys[$file]);
			$percent = $master_count > 0 ? round(($count / $master_count) * 100) : 0;
			
			echo sprintf("%-15s", "$count/$master_count ($percent%)");
		}
		
		$overall_percent = $total_master > 0 ? round(($total_translated / $total_master) * 100, 1) : 0;
		echo sprintf("%-15s%-15s\n", "$total_translated/$total_master", "$overall_percent%");
	}
	
	echo "\n";
}

/**
 * Generate translation template for a new language
 */
function generate_template($lang) {
	if (empty($lang)) {
		echo "Error: Please specify language code with --lang=CODE\n";
		return;
	}
	
	$lang_dir = LOCALE_DIR . $lang;
	if (is_dir($lang_dir)) {
		echo "Warning: Directory for '$lang' already exists.\n";
		$response = readline("Do you want to overwrite? (y/N): ");
		if (strtolower(trim($response)) !== 'y') {
			echo "Aborted.\n";
			return;
		}
	} else {
		mkdir($lang_dir, 0755, true);
	}
	
	$files = ['main', 'admin', 'install'];
	$master_keys = get_master_keys();
	
	foreach ($files as $file) {
		$output = "<?php\n";
		$output .= "/**\n";
		$output .= " * $lang language file\n";
		$output .= " * $file.php\n";
		$output .= " *\n";
		$output .= " * @author Your Name <your@email.com>\n";
		$output .= " */\n";
		
		foreach ($master_keys[$file] as $key) {
			$en_value = load_locale_keys('en', $file)[$key] ?? '';
			$output .= "\$locale['$key'] = ''; // EN: " . addslashes($en_value) . "\n";
		}
		
		if ($file === 'admin' || $file === 'install') {
			$output .= "?>\n";
		}
		
		$filepath = $lang_dir . '/' . $file . '.php';
		file_put_contents($filepath, $output);
		echo "Generated: $filepath\n";
	}
	
	echo "\nTemplate generated successfully for '$lang'!\n";
}

/**
 * Validate translations and show missing keys
 */
function validate_translations() {
	echo "Translation Validation\n";
	echo str_repeat('=', 80) . "\n\n";
	
	$locales = get_locales();
	$master_keys = get_master_keys();
	$files = ['main', 'admin', 'install'];
	
	$has_missing = false;
	
	foreach ($locales as $locale) {
		if ($locale === 'en') continue; // Skip master locale
		
		$locale_has_missing = false;
		
		foreach ($files as $file) {
			$locale_keys = array_keys(load_locale_keys($locale, $file));
			$master = $master_keys[$file];
			$missing = array_diff($master, $locale_keys);
			
			if (!empty($missing)) {
				if (!$locale_has_missing) {
					echo "Locale: $locale\n";
					echo str_repeat('-', 80) . "\n";
					$locale_has_missing = true;
					$has_missing = true;
				}
				
				echo "  $file.php - Missing keys (" . count($missing) . "):\n";
				foreach ($missing as $key) {
					echo "    - $key\n";
				}
				echo "\n";
			}
		}
		
		if ($locale_has_missing) {
			echo "\n";
		}
	}
	
	if (!$has_missing) {
		echo "All translations are complete! ✓\n";
	}
}

/**
 * Show help
 */
function show_help() {
	echo "Translation Management Tool\n\n";
	echo "Usage:\n";
	echo "  php translation_manager.php --action=ACTION [OPTIONS]\n\n";
	echo "Actions:\n";
	echo "  stats                Show translation statistics for all locales\n";
	echo "  template             Generate translation template for new language\n";
	echo "  validate             Validate translations and show missing keys\n";
	echo "  help                 Show this help message\n\n";
	echo "Options:\n";
	echo "  --lang=CODE          Language code for template generation (e.g., es, fr, de)\n\n";
	echo "Examples:\n";
	echo "  php translation_manager.php --action=stats\n";
	echo "  php translation_manager.php --action=template --lang=es\n";
	echo "  php translation_manager.php --action=validate\n\n";
}

// Execute action
switch ($action) {
	case 'stats':
		show_stats();
		break;
	
	case 'template':
		generate_template($options['lang'] ?? '');
		break;
	
	case 'validate':
		validate_translations();
		break;
	
	case 'help':
	default:
		show_help();
		break;
}
