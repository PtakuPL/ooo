<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');

/**
 * language-packs.php — Faza 9.4 (D1)
 *
 * Returns list of available language packs for the launcher.
 * Bundled packs (shipped with the binary) are marked bundled=true.
 * Additional downloadable packs can be added here later.
 *
 * Response contract: { "availablePacks": [ { locale, version, bundled, ... }, ... ] }
 */

require_once __DIR__ . '/common.php';

$packs = [
    [
        'locale'      => 'pl',
        'version'     => '1.0.0',
        'bundled'     => true,
        'displayName' => 'Polish',
        'nativeName'  => 'Polski',
        'flag'        => '🇵🇱',
        'tier'        => 0,
    ],
    [
        'locale'      => 'en',
        'version'     => '1.0.0',
        'bundled'     => true,
        'displayName' => 'English',
        'nativeName'  => 'English',
        'flag'        => '🇬🇧',
        'tier'        => 0,
    ],
    [
        'locale'      => 'ar',
        'version'     => '1.0.0',
        'bundled'     => true,
        'displayName' => 'Arabic',
        'nativeName'  => 'العربية',
        'flag'        => '🇸🇦',
        'tier'        => 1,
    ],
    [
        'locale'      => 'he',
        'version'     => '1.0.0',
        'bundled'     => true,
        'displayName' => 'Hebrew',
        'nativeName'  => 'עברית',
        'flag'        => '🇮🇱',
        'tier'        => 1,
    ],
    [
        'locale'      => 'fa',
        'version'     => '1.0.0',
        'bundled'     => true,
        'displayName' => 'Persian',
        'nativeName'  => 'فارسی',
        'flag'        => '🇮🇷',
        'tier'        => 1,
    ],
];

json_out(['availablePacks' => $packs]);
