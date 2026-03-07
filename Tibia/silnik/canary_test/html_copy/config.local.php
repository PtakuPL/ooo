<?php
$config['installed'] = true;
$config['env'] = 'prod';
$config['default_locale'] = 'pl';
$config['tibiacom_force_headline_php'] = true;
$config['site_url'] = 'https://127.0.0.1';
$config['server_path'] = '/home/ptaku/serweryt/Tibia/silnik/canary_test/';
$config['gzip_output'] = false;
$config['cache_engine'] = 'none';
$config['cache_prefix'] = 'myaac_ntbjl75y3';
$config['twig_auto_reload'] = true;
$config['database_auto_migrate'] = true;

// MyAAC DB override: config.lua points to "canary" (engine DB), but MyAAC needs "canaryaac" (master + myaac tables)
$config['database_overwrite'] = true;
$config['database_type'] = 'mysql';
$config['database_host'] = '127.0.0.1';
$config['database_port'] = 3306;
$config['database_user'] = 'ptaku';
$config['database_password'] = '12345678';
$config['database_name'] = 'canaryaac';
$config['database_encryption'] = 'sha1';

// Disable pretty URLs to avoid 404 when server rewrites are missing
$config['core']['friendly_urls'] = false;

// Modern server - second database connection
$config['modern_server_path'] = '/home/ptaku/serweryt/Tibia/silnik/canary_modern/';
$config['modern_database_name'] = 'canary_modern';

// Clean up footer to remove extra counters/noise
$config['core']['visitors_counter'] = false;
$config['core']['views_counter'] = false;
$config['core']['footer_load_time'] = false;
$config['core']['footer'] = '';

// Polish gender names (array index = getSex() value: 0=Female, 1=Male)
$config['genders'] = ['Kobieta', 'Mężczyzna'];

// Polish vocation names (array index = vocation id from vocations.xml)
$config['vocations'] = ['Brak', 'Czarnoksiężnik', 'Druid', 'Paladyn', 'Rycerz', 'Mistrz Czarnoksiężnik', 'Starszy Druid', 'Królewski Paladyn', 'Elitarny Rycerz'];
