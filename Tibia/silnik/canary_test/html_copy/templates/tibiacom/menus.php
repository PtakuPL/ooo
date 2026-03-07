<?php

return [
	MENU_CATEGORY_NEWS => [
		'<span data-i18n="nav.news_latest">' . __('menu_latest_news') . '</span>' => 'news',
		'<span data-i18n="nav.news_archive">' . __('menu_news_archive') . '</span>' => 'news/archive',
		'<span data-i18n="nav.changelog">' . __('menu_changelog') . '</span>' => 'change-log',
	],
	MENU_CATEGORY_ACCOUNT => [
		'<span data-i18n="nav.account">' . __('menu_account_management') . '</span>' => 'account/manage',
		'<span data-i18n="nav.profile_all">' . __('global_profile_all_worlds') . '</span>' => 'account/manage?active_mode=all',
		'<span data-i18n="nav.profile_classic">' . __('global_profile_classic') . '</span>' => 'account/manage?active_mode=classic74',
		'<span data-i18n="nav.profile_modern">' . __('global_profile_modern') . '</span>' => 'account/manage?active_mode=modern',
		'<span data-i18n="nav.register">' . __('menu_create_account') . '</span>' => 'account/create',
		'<span data-i18n="nav.account_lost">' . __('menu_lost_account') . '</span>' => 'account/lost',
		'<span data-i18n="nav.rules">' . __('menu_server_rules') . '</span>' => 'rules',
		'<span data-i18n="nav.downloads">' . __('menu_downloads') . '</span>' => 'downloads',
		'<span data-i18n="nav.logout">' . __('menu_logout') . '</span>' => 'account/logout',
	],
	MENU_CATEGORY_COMMUNITY => [
		'<span data-i18n="nav.characters">' . __('menu_characters') . '</span>' => 'characters',
		'<span data-i18n="nav.online">' . __('menu_who_online') . '</span>' => 'online',
		'<span data-i18n="nav.highscores">' . __('menu_highscores') . '</span>' => 'highscores',
		'<span data-i18n="nav.last_kills">' . __('menu_last_kills') . '</span>' => 'last-kills',
		'<span data-i18n="nav.houses">' . __('menu_houses') . '</span>' => 'houses',
		'<span data-i18n="nav.guilds">' . __('menu_guilds') . '</span>' => 'guilds',
		'<span data-i18n="nav.polls">' . __('menu_polls') . '</span>' => 'polls',
		'<span data-i18n="nav.bans">' . __('menu_bans') . '</span>' => 'bans',
		'<span data-i18n="nav.team">' . __('menu_support_list') . '</span>' => 'team',
	],
	MENU_CATEGORY_FORUM => [
		'<span data-i18n="nav.forum">' . __('menu_forum') . '</span>' => 'forum',
	],
	MENU_CATEGORY_LIBRARY => [
		'<span data-i18n="nav.monsters">' . __('menu_monsters') . '</span>' => 'monsters',
		'<span data-i18n="nav.spells">' . __('menu_spells') . '</span>' => 'spells',
		'<span data-i18n="nav.commands">' . __('menu_commands') . '</span>' => 'commands',
		'<span data-i18n="nav.exp_stages">' . __('menu_exp_stages') . '</span>' => 'exp-stages',
		'<span data-i18n="nav.gallery">' . __('menu_gallery') . '</span>' => 'gallery',
		'<span data-i18n="nav.server_info">' . __('menu_server_info') . '</span>' => 'ots-info',
		'<span data-i18n="nav.exp_table">' . __('menu_exp_table') . '</span>' => 'exp-table',
		'<span data-i18n="nav.faq">' . __('menu_faq') . '</span>' => 'faq',
	],
	MENU_CATEGORY_SHOP => [
		'<span data-i18n="nav.buy_points">' . __('menu_buy_points') . '</span>' => 'points',
		'<span data-i18n="nav.shop_offer">' . __('menu_shop_offer') . '</span>' => 'gifts',
		'<span data-i18n="nav.shop_history">' . __('menu_shop_history') . '</span>' => 'gifts/history',
	],
];
