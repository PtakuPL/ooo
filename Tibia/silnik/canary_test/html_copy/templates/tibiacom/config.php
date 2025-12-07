<?php
$config['menu_default_links_color'] = '#ffffff';

$config['menu_categories'] = [
	MENU_CATEGORY_NEWS => ['id' => 'news', 'name' => __('menu_category_news')],
	MENU_CATEGORY_ACCOUNT => ['id' => 'account', 'name' => __('menu_category_account')],
	MENU_CATEGORY_COMMUNITY => ['id' => 'community', 'name' => __('menu_category_community')],
	MENU_CATEGORY_FORUM => ['id' => 'forum', 'name' => __('menu_category_forum')],
	MENU_CATEGORY_LIBRARY => ['id' => 'library', 'name' => __('menu_category_library')],
	MENU_CATEGORY_SHOP => ['id' => 'shops', 'name' => __('menu_category_shop')],
];

$config['menus'] = require __DIR__ . '/menus.php';
