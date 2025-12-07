<?php
/**
 * japanese language file
 * install.php
 *
 * @author Slawkens <slawkens@gmail.com>
 */
$locale['installation'] = 'インストール';
$locale['steps'] = 'ステップ';

$locale['previous'] = '前へ';
$locale['next'] = '次へ';

$locale['on'] = 'オン';
$locale['off'] = 'オフ';

$locale['loaded'] = '読み込み済み';
$locale['not_loaded'] = '未読み込み';

$locale['loading_spinner'] = 'お待ちください、インストール中...';
$locale['importing_spinner'] = 'お待ちください、データをインポート中...';
$locale['please_fill_all'] = 'すべての入力フィールドを入力してください！';
$locale['already_installed'] = 'MyAACは既にインストールされています。<b>install/</b>ディレクトリを削除してください。MyAACを再インストールする場合は、メインディレクトリから<strong>config.local.php</strong>ファイルを削除してページを更新してください。';

// welcome
$locale['step_welcome'] = 'ようこそ';
$locale['step_welcome_title'] = 'インストーラーへようこそ';
$locale['step_welcome_desc'] = 'インストーラーで使用する言語を選択してください';

// license
$locale['step_license'] = 'ライセンス';
$locale['step_license_title'] = 'GNU/GPL ライセンス';

// requirements
$locale['step_requirements'] = '必要条件';
$locale['step_requirements_title'] = '必要条件のチェック';
$locale['step_requirements_php_version'] = 'PHPバージョン';
$locale['step_requirements_write_perms'] = '書き込み権限';
$locale['step_requirements_folder_exists'] = 'ディレクトリが存在します';
$locale['step_requirements_folder_not_exists_tools_ext'] = 'NPM Package Managerは外部のJavaScript/CSSライブラリに使用されます。'
	. ' コマンドラインからインストールする必要があります：<a href="https://docs.npmjs.com/downloading-and-installing-node-js-and-npm">https://docs.npmjs.com/downloading-and-installing-node-js-and-npm</a>'
	. ' そのツールのインストールが完了したら、MyAACメインフォルダで"npm install"を実行してください。';
$locale['step_requirements_failed'] = 'これらの必要条件が満たされるまで、インストールは無効になります。</b><br/>詳細については<b>README</b>ファイルを参照してください。';
$locale['step_requirements_extension'] = '$EXTENSION$ PHP拡張機能';
$locale['step_requirements_warning_images_guilds'] = 'ギルドロゴのアップロードは機能しません';
$locale['step_requirements_warning_images_gallery'] = 'ギャラリー画像のアップロードは機能しません';
$locale['step_requirements_warning_player_signatures'] = 'プレイヤーシグネチャは機能しません';
$locale['step_requirements_warning_install_plugins'] = 'プラグインのインストールができません';

// config
$locale['step_config'] = '設定';
$locale['step_config_title'] = 'サーバー設定';
$locale['step_config_server_path'] = 'サーバーパス';
$locale['step_config_server_path_desc'] = 'config.luaがあるTFSメインディレクトリへのパス。';
$locale['step_config_site_url'] = 'サイトURL';
$locale['step_config_site_url_desc'] = 'サイトのベースアドレス、例: https://example.com';
$locale['step_config_mail_admin'] = '管理者メール';
$locale['step_config_mail_admin_desc'] = 'お問い合わせフォームからのメールが配信されるアドレス、例: admin@gmail.com';
$locale['step_config_mail_admin_error'] = '管理者メールアドレスが正しくありません。';
$locale['step_config_timezone'] = 'タイムゾーン';
$locale['step_config_timezone_desc'] = '日付関数に使用されます。';
$locale['step_config_timezone_error'] = 'タイムゾーンを選択してください！';
$locale['step_config_client'] = 'クライアント';
$locale['step_config_client_desc'] = 'ダウンロードページといくつかのテンプレートに使用されます。';
$locale['step_config_client_error'] = 'クライアントを選択してください！';
$locale['step_config_usage'] = '使用統計';
$locale['step_config_usage_desc'] = 'MyAACが匿名の使用統計を報告することを許可しますか？データは30日ごとに1回のみ送信され、完全に機密です。';

// database
$locale['step_database'] = 'データベース';
$locale['step_database_title'] = 'データベース設定';
$locale['step_database_importing'] = 'データベースはMySQLです。データベース名: "$DATABASE_NAME$"。スキーマをインポート中...';
$locale['step_database_config_saved'] = 'データベース設定が保存されました。';
$locale['step_database_error_path'] = 'サーバーパスを指定してください。';
$locale['step_database_error_database_empty'] = 'config.luaからデータベースタイプを判別できません。このAACではお使いのOTSはサポートされていません。';
$locale['step_database_error_only_mysql'] = 'このAACはMySQLのみをサポートしています。設定ファイルから判断すると、お使いのOTSは$DATABASE_TYPE$データベースを使用しているようです。データベースをMySQLに変更してから、再度インストールを行ってください。';
$locale['step_database_error_table'] = 'テーブル$TABLE$が存在しません。まずOTSデータベーススキーマをインポートしてください。';
$locale['step_database_error_table_exist'] = 'テーブル$TABLE$は既に存在します。AACは既にインストールされているようです。MySQLスキーマのインポートをスキップします。';
$locale['step_database_error_mysql_connect'] = 'MySQLデータベースに接続できません。';
$locale['step_database_error_mysql_connect_2'] = '考えられる原因：';
$locale['step_database_error_mysql_connect_3'] = '<i>config.lua</i>でMySQLが正しく設定されていません。';
$locale['step_database_error_mysql_connect_4'] = 'MySQLサーバーが起動していません。';
$locale['step_database_error_schema'] = 'スキーマのインポートエラー：';
$locale['step_database_success_schema'] = '$PREFIX$テーブルが正常にインストールされました。';
$locale['step_database_error_file'] = '$FILE$を開けませんでした。内容をコピーしてファイルに貼り付けてください：';
$locale['step_database_adding_field'] = 'フィールドを追加中';
$locale['step_database_modifying_field'] = 'フィールドを変更中';
$locale['step_database_changing_field'] = '$FIELD$を$FIELD_NEW$に変更中...';
$locale['step_database_imported_players'] = 'プレイヤーサンプルをインポートしました...';
$locale['step_database_loaded_items'] = 'アイテムを読み込みました...';
$locale['step_database_loaded_weapons'] = '武器を読み込みました...';
$locale['step_database_loaded_monsters'] = 'モンスターを読み込みました...';
$locale['step_database_error_monsters'] = 'monsters.xmlファイルの読み込み中に問題が発生しました。詳細は$LOG$を確認してください。';
$locale['step_database_loaded_npcs'] = 'NPCを読み込みました...';
$locale['step_database_error_npcs'] = 'NPCの読み込みエラー。';
$locale['step_database_loaded_spells'] = '魔法を読み込みました...';
$locale['step_database_loaded_towns'] = '街を読み込みました...';
$locale['step_database_error_towns'] = '街の読み込みエラー。';
$locale['step_database_host'] = 'ホスト';
$locale['step_database_user'] = 'ユーザー';
$locale['step_database_password'] = 'パスワード';
$locale['step_database_name'] = 'データベース名';
$locale['step_database_file'] = 'データベースファイル（SQLiteのみ）';
$locale['step_database_error_config'] = 'データベース設定の保存に失敗しました！';
$locale['step_database_error_connect'] = 'データベースへの接続に失敗しました！';
$locale['step_database_created_account'] = '管理者アカウントを作成しました...';
$locale['step_database_created_news'] = 'ニュースを作成しました...';

// admin
$locale['step_admin'] = '管理者';
$locale['step_admin_title'] = '管理者アカウントの作成';
$locale['step_admin_email'] = 'メールアドレス';
$locale['step_admin_email_desc'] = '管理者アカウントのメールアドレス。パスワードリセットに使用できます。';
$locale['step_admin_email_error_empty'] = 'メールアドレスを入力してください！';
$locale['step_admin_email_error_format'] = '無効なメールアドレス形式です！';
$locale['step_admin_account_id'] = 'アカウントID';
$locale['step_admin_account_id_desc'] = '管理者アカウントの番号。サイトとサーバーへのログインに使用されます。';
$locale['step_admin_account_id_error_empty'] = 'アカウントIDを入力してください！';
$locale['step_admin_account_id_error_format'] = 'アカウントIDは数字である必要があります！';
$locale['step_admin_account_id_error_same'] = 'アカウントIDは既に存在します！';
$locale['step_admin_account'] = 'アカウント名';
$locale['step_admin_account_desc'] = '管理者アカウントの名前。サイトとサーバーへのログインに使用されます。';
$locale['step_admin_account_error_empty'] = 'アカウント名を入力してください！';
$locale['step_admin_account_error_format'] = 'アカウント名は最低3文字必要です！';
$locale['step_admin_account_error_same'] = 'アカウント名は既に存在します！';
$locale['step_admin_password'] = 'パスワード';
$locale['step_admin_password_desc'] = '管理者アカウントのパスワード。';
$locale['step_admin_password_confirm'] = 'パスワード確認';
$locale['step_admin_password_confirm_desc'] = '管理者アカウントのパスワード確認。';
$locale['step_admin_password_error_empty'] = 'パスワードを入力してください！';
$locale['step_admin_password_error_format'] = 'パスワードは最低6文字必要です！';
$locale['step_admin_password_confirm_error_not_same'] = 'パスワードが一致しません！';
$locale['step_admin_player_name'] = 'キャラクター名';
$locale['step_admin_player_name_desc'] = '作成される管理者キャラクターの名前。';
$locale['step_admin_player_name_error_empty'] = 'キャラクター名を入力してください！';
$locale['step_admin_player_name_error_format'] = 'キャラクター名は最低3文字必要です！';

// finish
$locale['step_finish'] = '完了';
$locale['step_finish_title'] = 'インストール完了！';
$locale['step_finish_admin_panel'] = '管理パネル';
$locale['step_finish_homepage'] = 'ホームページ';
$locale['step_finish_desc'] = 'おめでとうございます！MyAACのインストールが正常に完了しました。';
$locale['step_finish_note'] = '<strong>重要：</strong>セキュリティのため<strong>install/</strong>ディレクトリを削除してください！';
$locale['step_finish_go_site'] = 'サイトへ移動';
$locale['step_finish_go_admin'] = '管理パネルへ移動';
?>
