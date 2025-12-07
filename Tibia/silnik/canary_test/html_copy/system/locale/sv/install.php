<?php
/**
 * swedish language file
 * install.php
 *
 * @author Sizaro <sizaro@live.se>
 */
$locale['installation'] = 'Installation';
$locale['steps'] = 'Steg';

$locale['previous'] = 'Föregående';
$locale['next'] = 'Nästa';

$locale['on'] = 'På';
$locale['off'] = 'Av';

$locale['loaded'] = 'Laddad';
$locale['not_loaded'] = 'Inte Laddad';

$locale['please_fill_all'] = 'Vänligen fyll i allt!';
$locale['already_installed'] = 'MyAAC är redan installerat. Vänligen ta bort <b>install/<b/> mappen. Om du vill installera MyAAC igen - ta bort filen <strong>config.local.php</strong> från huvudkatalogen och uppdatera sidan.';

// welcome
$locale['step_welcome'] = 'Välkommen';
$locale['step_welcome_title'] = 'Välkommen till installatören';
$locale['step_welcome_desc'] = 'Välj det språk du vill se installatören med';

// license
$locale['step_license'] = 'Licens';
$locale['step_license_title'] = 'GNU/GPL Licens';

// requirements
$locale['step_requirements'] = 'Krav';
$locale['step_requirements_title'] = 'Kravskontroll';
$locale['step_requirements_php_version'] = 'PHP Version';
$locale['step_requirements_write_perms'] = 'Skriv behörigheter';
$locale['step_requirements_failed'] = 'Installation kommer att inaktiveras tills dessa krav följts. </ B> <br/> Mer information finns i filen <b>README</b>.';
$locale['step_requirements_extension'] = '$EXTENSION$ PHP extension';
$locale['loading_spinner'] = 'Laddar...';
$locale['importing_spinner'] = 'Importerar...';
$locale['step_requirements_folder_exists'] = 'Mappen finns';
$locale['step_requirements_folder_not_exists_tools_ext'] = 'Mappen för externa verktyg finns inte';
$locale['step_requirements_warning_images_guilds'] = 'Varning: Bilder för guilds är inaktiverade';
$locale['step_requirements_warning_images_gallery'] = 'Varning: Bilder för galleriet är inaktiverade';
$locale['step_requirements_warning_player_signatures'] = 'Varning: Spelarunderskrifter är inaktiverade';
$locale['step_requirements_warning_install_plugins'] = 'Varning: Installera plugin kan kräva extra steg';

// config
$locale['step_config'] = 'Konfiguration';
$locale['step_config_title'] = 'Grundläggande konfiguration';
$locale['step_config_server_path'] = 'Server mapp';
$locale['step_config_server_path_desc'] = 'Mappen som innhåller exe filen till The Forgotten Server, där du har din config.lua.';

$locale['step_config_mail_admin'] = 'Admin E-Post';
$locale['step_config_mail_admin_desc'] = 'Adress där E-Post från kontaktförmolär kommer att leveraras, till exempel admin@gmail.com';
$locale['step_config_mail_admin_error'] = 'Admin E-Post är inte korrekt.';

$locale['step_config_client'] = 'Klientversion';
$locale['step_config_client_desc'] = 'Används för nerladdningssidan och teman.';
$locale['step_config_site_url'] = 'Webbplats-URL';
$locale['step_config_site_url_desc'] = 'Basadressen till din webbplats, t.ex. https://example.com';
$locale['step_config_timezone'] = 'Tidszon';
$locale['step_config_timezone_desc'] = 'Serverns tidszon, t.ex. Europe/Stockholm';
$locale['step_config_timezone_error'] = 'Ogiltig tidszon.';
$locale['step_config_client_error'] = 'Ogiltig klientversion.';
$locale['step_config_usage'] = 'Användning av data';
$locale['step_config_usage_desc'] = 'Välj hur AAC ska använda data från servern.';

// database
$locale['step_database'] = 'Importera schema';
$locale['step_database_title'] = 'Importera MySQL schema';
$locale['step_database_importing'] = 'Din databas är MySQL. Databasnamnet är: "$DATABASE_NAME$". Importerar schema nu...';
$locale['step_database_config_saved'] = 'Databaskonfiguration sparad.';
$locale['step_database_error_path'] = 'Ange server mapp.';
$locale['step_database_error_config'] = 'Kan inte hitta konfigurations fil. Är din server mapp korrekt? Gå tillbaka och kolla igen.';
$locale['step_database_error_database_empty'] = 'Kan inte bestämma databas typ från config.lua. Din OTS stöds inte av MyAAC.';
$locale['step_database_error_only_mysql'] = 'Denna AAC stöder endast MySQL. Från din konfigurationsfil verkar det som att din OTS använder: $DATABASE_TYPE$ databastypen. Var vänligen ändra din databas till MySQL och följ instruktionerna i installationen igen.';
$locale['step_database_error_table'] = 'Tabell $TABLE$ finns inte. Importera din OTS databas schema först.';
$locale['step_database_error_table_exist'] = 'Tabell $TABLE$ finns redan. Ser ut som att din AAC redan är installerad. Hoppar över importering av MySQL schema.';
$locale['step_database_error_mysql_connect'] = 'MySQL-anslutning misslyckades.';
$locale['step_database_error_mysql_connect_2'] = 'MySQL-anslutning misslyckades: felaktiga användaruppgifter.';
$locale['step_database_error_mysql_connect_3'] = 'MySQL-anslutning misslyckades: värden hittades inte.';
$locale['step_database_error_mysql_connect_4'] = 'MySQL-anslutning misslyckades: port eller socket fel.';
$locale['step_database_error_schema'] = 'Fel vid import av schema:';
$locale['step_database_success_schema'] = 'Lyckades installera $PREFIX$ tabeller.';
$locale['step_database_error_file'] = '$FILE$ kunde inte öppnas. Kopiera innehållet och klistra in här:';
$locale['step_database_adding_field'] = 'Lägger till fält';
$locale['step_database_modifying_field'] = 'Ändrar fält';
$locale['step_database_changing_field'] = 'Ändrar $FIELD$ till $FIELD_NEW$...';
$locale['step_database_loaded_items'] = 'Laddade föremål...';
$locale['step_database_loaded_weapons'] = 'Laddade vapen...';
$locale['step_database_loaded_monsters'] = 'Laddade monster...';
$locale['step_database_error_monsters'] = 'Fel vid laddning av monster.';
$locale['step_database_loaded_npcs'] = 'Laddade NPCs...';
$locale['step_database_error_npcs'] = 'Fel vid laddning av NPCs.';
$locale['step_database_loaded_spells'] = 'Laddade trollformler...';
$locale['step_database_loaded_towns'] = 'Laddade städer...';
$locale['step_database_error_towns'] = 'Fel vid laddning av städer.';
$locale['step_database_imported_players'] = 'Importerar spelarprover...';
$locale['step_database_created_account'] = 'Skapade admin konto...';
$locale['step_database_created_news'] = 'Skapade nyhetsinlägg...';

// admin account
$locale['step_admin'] = 'Admin Konto';
$locale['step_admin_title'] = 'Skapa Admin Konto';
$locale['step_admin_account'] = 'Admin konto namn';
$locale['step_admin_account_desc'] = 'Namn på ditt admin konto som kommer att användas för att logga in på hemsidan och servern.';
$locale['step_admin_account_id'] = 'Admin konto ID';
$locale['step_admin_account_id_desc'] = 'ID på ditt admin konto som kommer att användas för att logga in på hemsidan och servern.';
$locale['step_admin_password'] = 'Admin konto lösenord';
$locale['step_admin_password_desc'] = 'Lösenordet till ditt admin konto.';
$locale['step_admin_email'] = 'Admin e-post';
$locale['step_admin_email_desc'] = 'Din e-postadress för administrativa meddelanden.';
$locale['step_admin_email_error_empty'] = 'E-post kan inte vara tom.';
$locale['step_admin_email_error_format'] = 'Ogiltigt e-postformat.';
$locale['step_admin_account_error_empty'] = 'Kontonamn kan inte vara tomt.';
$locale['step_admin_account_error_format'] = 'Ogiltigt kontonamnformat.';
$locale['step_admin_account_error_same'] = 'Kontonamn och ID kan inte vara samma.';
$locale['step_admin_account_id_error_empty'] = 'Konto-ID kan inte vara tomt.';
$locale['step_admin_account_id_error_format'] = 'Ogiltigt konto-ID-format.';
$locale['step_admin_account_id_error_same'] = 'Kontonamn och ID kan inte vara samma.';
$locale['step_admin_password_error_empty'] = 'Lösenord kan inte vara tomt.';
$locale['step_admin_password_error_format'] = 'Ogiltigt lösenordsformat.';
$locale['step_admin_password_confirm'] = 'Bekräfta lösenord';
$locale['step_admin_password_confirm_desc'] = 'Bekräfta ditt admin lösenord.';
$locale['step_admin_password_confirm_error_not_same'] = 'Lösenorden matchar inte.';
$locale['step_admin_player_name'] = 'Spelarnamn';
$locale['step_admin_player_name_desc'] = 'Namn på admin-spelaren som kommer att skapas.';
$locale['step_admin_player_name_error_empty'] = 'Spelarnamn kan inte vara tomt.';
$locale['step_admin_player_name_error_format'] = 'Ogiltigt spelarnamnformat.';

// finish
$locale['step_finish_admin_panel'] = 'Admin Panelen';
$locale['step_finish_homepage'] = 'hemsida';
$locale['step_finish'] = 'Klar';
$locale['step_finish_title'] = 'Installationen klar!';
$locale['step_finish_desc'] = 'Grattis! <b>MyAAC</b> är redo att användas!<br/>Du kan logga in på $ADMIN_PANEL$, eller titta till $HOMEPAGE$.<br/><br/>
<span style="color: red">Var vänligen ta bort installations mappen.</span><br/><br/>
Var vänligen rapportera buggar och förslag på $LINK$, tack!';
?>
