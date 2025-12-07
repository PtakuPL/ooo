<?php
$config['installed'] = true;
$config['env'] = 'prod';
$config['site_url'] = 'http://127.0.0.1';
$config['server_path'] = '/home/ptaku/serweryt/Tibia/silnik/canary_test/';
$config['gzip_output'] = false;
$config['cache_engine'] = 'auto';
$config['cache_prefix'] = 'myaac_ntbjl75y';
$config['database_auto_migrate'] = true;

// Disable pretty URLs to avoid 404 when server rewrites are missing
$config['core']['friendly_urls'] = false;

// Clean up footer to remove extra counters/noise
$config['core']['visitors_counter'] = false;
$config['core']['views_counter'] = false;
$config['core']['footer_load_time'] = false;
$config['core']['footer'] = '';
