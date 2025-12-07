<?php
/**
 * russian language file
 * install.php
 *
 * @author Slawkens <slawkens@gmail.com>
 */
$locale['installation'] = 'Установка';
$locale['steps'] = 'Шаги';

$locale['previous'] = 'Назад';
$locale['next'] = 'Далее';

$locale['on'] = 'Вкл';
$locale['off'] = 'Выкл';

$locale['loaded'] = 'Загружено';
$locale['not_loaded'] = 'Не загружено';

$locale['loading_spinner'] = 'Пожалуйста, подождите, установка...';
$locale['importing_spinner'] = 'Пожалуйста, подождите, импорт данных...';
$locale['please_fill_all'] = 'Пожалуйста, заполните все поля!';
$locale['already_installed'] = 'MyAAC уже установлен. Пожалуйста, удалите директорию <b>install/</b>. Если вы хотите переустановить MyAAC - пожалуйста, удалите файл <strong>config.local.php</strong> из основной директории и обновите страницу.';

// welcome
$locale['step_welcome'] = 'Добро пожаловать';
$locale['step_welcome_title'] = 'Добро пожаловать в установщик';
$locale['step_welcome_desc'] = 'Выберите язык для установщика';

// license
$locale['step_license'] = 'Лицензия';
$locale['step_license_title'] = 'GNU/GPL Лицензия';

// requirements
$locale['step_requirements'] = 'Требования';
$locale['step_requirements_title'] = 'Проверка требований';
$locale['step_requirements_php_version'] = 'Версия PHP';
$locale['step_requirements_write_perms'] = 'Права на запись';
$locale['step_requirements_folder_exists'] = 'Директория существует';
$locale['step_requirements_folder_not_exists_tools_ext'] = 'NPM Package Manager используется для внешних библиотек JavaScript/CSS.'
	. ' Вам необходимо установить его через командную строку: <a href="https://docs.npmjs.com/downloading-and-installing-node-js-and-npm">https://docs.npmjs.com/downloading-and-installing-node-js-and-npm</a>'
	. ' После установки выполните: "npm install" в основной папке MyAAC.';
$locale['step_requirements_failed'] = 'Установка будет отключена до выполнения этих требований.</b><br/>Для получения дополнительной информации см. файл <b>README</b>.';
$locale['step_requirements_extension'] = '$EXTENSION$ расширение PHP';
$locale['step_requirements_warning_images_guilds'] = 'Загрузка логотипа гильдии не будет работать';
$locale['step_requirements_warning_images_gallery'] = 'Загрузка изображений галереи не будет работать';
$locale['step_requirements_warning_player_signatures'] = 'Подписи игроков не будут работать';
$locale['step_requirements_warning_install_plugins'] = 'Установка плагинов будет невозможна';

// config
$locale['step_config'] = 'Конфигурация';
$locale['step_config_title'] = 'Конфигурация сервера';
$locale['step_config_server_path'] = 'Путь к серверу';
$locale['step_config_server_path_desc'] = 'Путь к основной директории TFS, где находится файл config.lua.';
$locale['step_config_site_url'] = 'URL сайта';
$locale['step_config_site_url_desc'] = 'Базовый адрес вашего сайта, например: https://example.com';
$locale['step_config_mail_admin'] = 'Email администратора';
$locale['step_config_mail_admin_desc'] = 'Адрес, на который будут приходить письма из формы обратной связи, например admin@gmail.com';
$locale['step_config_mail_admin_error'] = 'Email администратора указан неверно.';
$locale['step_config_timezone'] = 'Часовой пояс';
$locale['step_config_timezone_desc'] = 'Используется для функций работы с датой и временем.';
$locale['step_config_timezone_error'] = 'Пожалуйста, выберите часовой пояс!';
$locale['step_config_client'] = 'Клиент';
$locale['step_config_client_desc'] = 'Используется для страницы загрузки и некоторых шаблонов.';
$locale['step_config_client_error'] = 'Пожалуйста, выберите клиент!';
$locale['step_config_usage'] = 'Статистика использования';
$locale['step_config_usage_desc'] = 'Разрешить MyAAC отправлять анонимную статистику? Данные отправляются только раз в 30 дней и полностью конфиденциальны.';

// database
$locale['step_database'] = 'База данных';
$locale['step_database_title'] = 'Настройки базы данных';
$locale['step_database_importing'] = 'Ваша база данных MySQL. Имя базы: "$DATABASE_NAME$". Импорт схемы...';
$locale['step_database_config_saved'] = 'Конфигурация базы данных сохранена.';
$locale['step_database_error_path'] = 'Пожалуйста, укажите путь к серверу.';
$locale['step_database_error_database_empty'] = 'Не удалось определить тип базы данных из config.lua. Ваш OTS не поддерживается этим AAC.';
$locale['step_database_error_only_mysql'] = 'Этот AAC поддерживает только MySQL. Судя по вашему конфигурационному файлу, ваш OTS использует: $DATABASE_TYPE$ базу данных. Пожалуйста, измените базу данных на MySQL и повторите установку.';
$locale['step_database_error_table'] = 'Таблица $TABLE$ не существует. Пожалуйста, сначала импортируйте схему базы данных OTS.';
$locale['step_database_error_table_exist'] = 'Таблица $TABLE$ уже существует. Похоже, что AAC уже установлен. Пропуск импорта схемы MySQL.';
$locale['step_database_error_mysql_connect'] = 'Не удалось подключиться к базе данных MySQL.';
$locale['step_database_error_mysql_connect_2'] = 'Возможные причины:';
$locale['step_database_error_mysql_connect_3'] = 'MySQL неправильно настроен в <i>config.lua</i>.';
$locale['step_database_error_mysql_connect_4'] = 'Сервер MySQL не запущен.';
$locale['step_database_error_schema'] = 'Ошибка импорта схемы:';
$locale['step_database_success_schema'] = 'Таблицы $PREFIX$ успешно установлены.';
$locale['step_database_error_file'] = 'Не удалось открыть $FILE$. Пожалуйста, скопируйте содержимое и вставьте в файл:';
$locale['step_database_adding_field'] = 'Добавление поля';
$locale['step_database_modifying_field'] = 'Изменение поля';
$locale['step_database_changing_field'] = 'Изменение $FIELD$ на $FIELD_NEW$...';
$locale['step_database_imported_players'] = 'Импортированы примеры игроков...';
$locale['step_database_loaded_items'] = 'Загружены предметы...';
$locale['step_database_loaded_weapons'] = 'Загружено оружие...';
$locale['step_database_loaded_monsters'] = 'Загружены монстры...';
$locale['step_database_error_monsters'] = 'Возникли проблемы при загрузке файла monsters.xml. Пожалуйста, проверьте $LOG$ для получения дополнительной информации.';
$locale['step_database_loaded_npcs'] = 'Загружены NPC...';
$locale['step_database_error_npcs'] = 'Ошибка загрузки NPC.';
$locale['step_database_loaded_spells'] = 'Загружены заклинания...';
$locale['step_database_loaded_towns'] = 'Загружены города...';
$locale['step_database_error_towns'] = 'Ошибка загрузки городов.';
$locale['step_database_host'] = 'Хост';
$locale['step_database_user'] = 'Пользователь';
$locale['step_database_password'] = 'Пароль';
$locale['step_database_name'] = 'Имя базы данных';
$locale['step_database_file'] = 'Файл базы данных (только SQLite)';
$locale['step_database_error_config'] = 'Не удалось сохранить конфигурацию базы данных!';
$locale['step_database_error_connect'] = 'Не удалось подключиться к базе данных!';
$locale['step_database_created_account'] = 'Создан аккаунт администратора...';
$locale['step_database_created_news'] = 'Созданы новости...';

// admin
$locale['step_admin'] = 'Администратор';
$locale['step_admin_title'] = 'Создание аккаунта администратора';
$locale['step_admin_email'] = 'Email';
$locale['step_admin_email_desc'] = 'Email вашего аккаунта администратора, может использоваться для сброса пароля.';
$locale['step_admin_email_error_empty'] = 'Пожалуйста, введите email!';
$locale['step_admin_email_error_format'] = 'Неверный формат email!';
$locale['step_admin_account_id'] = 'ID аккаунта';
$locale['step_admin_account_id_desc'] = 'Номер вашего аккаунта администратора, который будет использоваться для входа на сайт и на сервер.';
$locale['step_admin_account_id_error_empty'] = 'Пожалуйста, введите ID аккаунта!';
$locale['step_admin_account_id_error_format'] = 'ID аккаунта должен быть числом!';
$locale['step_admin_account_id_error_same'] = 'ID аккаунта уже существует!';
$locale['step_admin_account'] = 'Логин аккаунта';
$locale['step_admin_account_desc'] = 'Имя вашего аккаунта администратора, которое будет использоваться для входа на сайт и на сервер.';
$locale['step_admin_account_error_empty'] = 'Пожалуйста, введите логин аккаунта!';
$locale['step_admin_account_error_format'] = 'Логин аккаунта должен содержать минимум 3 символа!';
$locale['step_admin_account_error_same'] = 'Логин аккаунта уже существует!';
$locale['step_admin_password'] = 'Пароль';
$locale['step_admin_password_desc'] = 'Пароль для вашего аккаунта администратора.';
$locale['step_admin_password_confirm'] = 'Подтверждение пароля';
$locale['step_admin_password_confirm_desc'] = 'Подтверждение пароля для вашего аккаунта администратора.';
$locale['step_admin_password_error_empty'] = 'Пожалуйста, введите пароль!';
$locale['step_admin_password_error_format'] = 'Пароль должен содержать минимум 6 символов!';
$locale['step_admin_password_confirm_error_not_same'] = 'Пароли не совпадают!';
$locale['step_admin_player_name'] = 'Имя персонажа';
$locale['step_admin_player_name_desc'] = 'Имя персонажа администратора, который будет создан.';
$locale['step_admin_player_name_error_empty'] = 'Пожалуйста, введите имя персонажа!';
$locale['step_admin_player_name_error_format'] = 'Имя персонажа должно содержать минимум 3 символа!';

// finish
$locale['step_finish'] = 'Завершение';
$locale['step_finish_title'] = 'Установка завершена!';
$locale['step_finish_admin_panel'] = 'Панель администратора';
$locale['step_finish_homepage'] = 'главная страница';
$locale['step_finish_desc'] = 'Поздравляем! MyAAC был успешно установлен.';
$locale['step_finish_note'] = '<strong>ВАЖНО:</strong> Пожалуйста, удалите директорию <strong>install/</strong> из соображений безопасности!';
$locale['step_finish_go_site'] = 'Перейти на сайт';
$locale['step_finish_go_admin'] = 'Перейти в админ-панель';
?>
