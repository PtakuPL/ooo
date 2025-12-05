# Canary Server Database Schema Documentation

## Overview

This document describes the database schema for the Canary Open Tibia server with internationalization (I18N) support. The schema supports multi-language content for player interactions, messages, and server-generated text.

## Core Tables

### Players Table
```sql
CREATE TABLE `players` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `group_id` INT NOT NULL DEFAULT 1,
  `account_id` INT NOT NULL DEFAULT 0,
  `level` INT NOT NULL DEFAULT 1,
  `vocation` INT NOT NULL DEFAULT 0,
  `health` INT NOT NULL DEFAULT 150,
  `healthmax` INT NOT NULL DEFAULT 150,
  `experience` BIGINT NOT NULL DEFAULT 0,
  `lookbody` INT NOT NULL DEFAULT 0,
  `lookfeet` INT NOT NULL DEFAULT 0,
  `lookhead` INT NOT NULL DEFAULT 0,
  `looklegs` INT NOT NULL DEFAULT 0,
  `looktype` INT NOT NULL DEFAULT 136,
  `lookaddons` INT NOT NULL DEFAULT 0,
  `maglevel` INT NOT NULL DEFAULT 0,
  `mana` INT NOT NULL DEFAULT 0,
  `manamax` INT NOT NULL DEFAULT 0,
  `manaspent` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `soul` INT UNSIGNED NOT NULL DEFAULT 0,
  `town_id` INT NOT NULL DEFAULT 1,
  `posx` INT NOT NULL DEFAULT 0,
  `posy` INT NOT NULL DEFAULT 0,
  `posz` INT NOT NULL DEFAULT 0,
  `conditions` BLOB NOT NULL,
  `cap` INT NOT NULL DEFAULT 400,
  `sex` INT NOT NULL DEFAULT 0,
  `lastlogin` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `lastip` INT UNSIGNED NOT NULL DEFAULT 0,
  `save` TINYINT NOT NULL DEFAULT 1,
  `skull` TINYINT NOT NULL DEFAULT 0,
  `skulltime` BIGINT NOT NULL DEFAULT 0,
  `lastlogout` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `blessings` TINYINT NOT NULL DEFAULT 0,
  `onlinetime` INT NOT NULL DEFAULT 0,
  `deletion` BIGINT NOT NULL DEFAULT 0,
  `balance` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `offlinetraining_time` SMALLINT UNSIGNED NOT NULL DEFAULT 43200,
  `offlinetraining_skill` INT NOT NULL DEFAULT -1,
  `stamina` SMALLINT UNSIGNED NOT NULL DEFAULT 2520,
  `skill_fist` INT UNSIGNED NOT NULL DEFAULT 10,
  `skill_fist_tries` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `skill_club` INT UNSIGNED NOT NULL DEFAULT 10,
  `skill_club_tries` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `skill_sword` INT UNSIGNED NOT NULL DEFAULT 10,
  `skill_sword_tries` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `skill_axe` INT UNSIGNED NOT NULL DEFAULT 10,
  `skill_axe_tries` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `skill_dist` INT UNSIGNED NOT NULL DEFAULT 10,
  `skill_dist_tries` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `skill_shielding` INT UNSIGNED NOT NULL DEFAULT 10,
  `skill_shielding_tries` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `skill_fishing` INT UNSIGNED NOT NULL DEFAULT 10,
  `skill_fishing_tries` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `language` VARCHAR(5) NOT NULL DEFAULT 'en',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `account_id` (`account_id`),
  KEY `vocation` (`vocation`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Accounts Table
```sql
CREATE TABLE `accounts` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(32) NOT NULL,
  `password` CHAR(40) NOT NULL,
  `email` VARCHAR(255) NOT NULL DEFAULT '',
  `premdays` INT NOT NULL DEFAULT 0,
  `lastday` INT UNSIGNED NOT NULL DEFAULT 0,
  `type` INT NOT NULL DEFAULT 1,
  `coins` INT NOT NULL DEFAULT 0,
  `creation` INT NOT NULL DEFAULT 0,
  `language` VARCHAR(5) NOT NULL DEFAULT 'en',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

## I18N Tables

### Server Messages Table
```sql
CREATE TABLE `server_messages` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `message_key` VARCHAR(255) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `message_key` (`message_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Message Translations Table
```sql
CREATE TABLE `message_translations` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `message_id` INT NOT NULL,
  `language_code` VARCHAR(5) NOT NULL,
  `translation` TEXT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `message_language` (`message_id`, `language_code`),
  KEY `language_code` (`language_code`),
  FOREIGN KEY (`message_id`) REFERENCES `server_messages`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Supported Languages Table
```sql
CREATE TABLE `languages` (
  `code` VARCHAR(5) NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `native_name` VARCHAR(50) NOT NULL,
  `is_rtl` TINYINT NOT NULL DEFAULT 0,
  `is_active` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Initial Language Data
```sql
INSERT INTO `languages` (`code`, `name`, `native_name`, `is_rtl`, `is_active`) VALUES
-- Western European
('en', 'English', 'English', 0, 1),
('de', 'German', 'Deutsch', 0, 1),
('es', 'Spanish', 'Español', 0, 1),
('fr', 'French', 'Français', 0, 1),
('it', 'Italian', 'Italiano', 0, 1),
('pt', 'Portuguese', 'Português', 0, 1),
('nl', 'Dutch', 'Nederlands', 0, 1),
('sv', 'Swedish', 'Svenska', 0, 1),
('da', 'Danish', 'Dansk', 0, 1),
('no', 'Norwegian', 'Norsk', 0, 1),
('fi', 'Finnish', 'Suomi', 0, 1),
('is', 'Icelandic', 'Íslenska', 0, 1),
-- Eastern European
('pl', 'Polish', 'Polski', 0, 1),
('cs', 'Czech', 'Čeština', 0, 1),
('hu', 'Hungarian', 'Magyar', 0, 1),
('ro', 'Romanian', 'Română', 0, 1),
('bg', 'Bulgarian', 'Български', 0, 1),
('sk', 'Slovak', 'Slovenčina', 0, 1),
('hr', 'Croatian', 'Hrvatski', 0, 1),
('sr', 'Serbian', 'Српски', 0, 1),
('sl', 'Slovenian', 'Slovenščina', 0, 1),
('sq', 'Albanian', 'Shqip', 0, 1),
('mk', 'Macedonian', 'Македонски', 0, 1),
-- Baltic
('lt', 'Lithuanian', 'Lietuvių', 0, 1),
('lv', 'Latvian', 'Latviešu', 0, 1),
('et', 'Estonian', 'Eesti', 0, 1),
-- Slavic
('ru', 'Russian', 'Русский', 0, 1),
('uk', 'Ukrainian', 'Українська', 0, 1),
-- Asian
('zh', 'Chinese', '中文', 0, 1),
('ja', 'Japanese', '日本語', 0, 1),
('ko', 'Korean', '한국어', 0, 1),
('vi', 'Vietnamese', 'Tiếng Việt', 0, 1),
('th', 'Thai', 'ไทย', 0, 1),
('hi', 'Hindi', 'हिन्दी', 0, 1),
('id', 'Indonesian', 'Bahasa Indonesia', 0, 1),
('ms', 'Malay', 'Bahasa Melayu', 0, 1),
('fil', 'Filipino', 'Filipino', 0, 1),
('bn', 'Bengali', 'বাংলা', 0, 1),
-- Middle Eastern (RTL)
('ar', 'Arabic', 'العربية', 1, 1),
('he', 'Hebrew', 'עברית', 1, 1),
('fa', 'Persian', 'فارسی', 1, 1),
('tr', 'Turkish', 'Türkçe', 0, 1),
-- Caucasus
('ka', 'Georgian', 'ქართული', 0, 1),
('hy', 'Armenian', 'Հdelays', 0, 1),
('az', 'Azerbaijani', 'Azərbaycan', 0, 1),
-- Central Asian
('kk', 'Kazakh', 'Қазақ', 0, 1),
('uz', 'Uzbek', "O'zbek", 0, 1),
-- African
('af', 'Afrikaans', 'Afrikaans', 0, 1),
('sw', 'Swahili', 'Kiswahili', 0, 1),
-- Other
('eu', 'Basque', 'Euskara', 0, 1),
('ca', 'Catalan', 'Català', 0, 1),
('gl', 'Galician', 'Galego', 0, 1),
('el', 'Greek', 'Ελληνικά', 0, 1);
```

## NPC Dialogue Tables

### NPC Table
```sql
CREATE TABLE `npcs` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `script_name` VARCHAR(255) NOT NULL,
  `posx` INT NOT NULL DEFAULT 0,
  `posy` INT NOT NULL DEFAULT 0,
  `posz` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### NPC Dialogue Keys Table
```sql
CREATE TABLE `npc_dialogue_keys` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `npc_id` INT NOT NULL,
  `dialogue_key` VARCHAR(255) NOT NULL,
  `context` VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `npc_dialogue` (`npc_id`, `dialogue_key`),
  FOREIGN KEY (`npc_id`) REFERENCES `npcs`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### NPC Dialogue Translations Table
```sql
CREATE TABLE `npc_dialogue_translations` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `dialogue_id` INT NOT NULL,
  `language_code` VARCHAR(5) NOT NULL,
  `translation` TEXT NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `dialogue_language` (`dialogue_id`, `language_code`),
  FOREIGN KEY (`dialogue_id`) REFERENCES `npc_dialogue_keys`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`language_code`) REFERENCES `languages`(`code`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

## Item Tables with I18N

### Items Base Table
```sql
CREATE TABLE `items` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `item_id` INT NOT NULL,
  `name_key` VARCHAR(255) NOT NULL,
  `description_key` VARCHAR(255) DEFAULT NULL,
  `weight` INT NOT NULL DEFAULT 0,
  `attack` INT NOT NULL DEFAULT 0,
  `defense` INT NOT NULL DEFAULT 0,
  `armor` INT NOT NULL DEFAULT 0,
  `slot_type` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `item_id` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Item Translations Table
```sql
CREATE TABLE `item_translations` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `item_id` INT NOT NULL,
  `language_code` VARCHAR(5) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `description` TEXT DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `item_language` (`item_id`, `language_code`),
  FOREIGN KEY (`item_id`) REFERENCES `items`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`language_code`) REFERENCES `languages`(`code`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

## Query Examples

### Get Player's Preferred Language
```sql
SELECT language FROM players WHERE id = ?;
```

### Get Translated Server Message
```sql
SELECT mt.translation 
FROM server_messages sm
JOIN message_translations mt ON sm.id = mt.message_id
WHERE sm.message_key = ? AND mt.language_code = ?;
```

### Get Translated NPC Dialogue with Fallback
```sql
SELECT COALESCE(
  (SELECT translation FROM npc_dialogue_translations 
   WHERE dialogue_id = ? AND language_code = ?),
  (SELECT translation FROM npc_dialogue_translations 
   WHERE dialogue_id = ? AND language_code = 'en')
) AS translation;
```

### Get All Translations for a Message
```sql
SELECT l.code, l.name, l.native_name, mt.translation
FROM languages l
LEFT JOIN message_translations mt ON l.code = mt.language_code AND mt.message_id = ?
WHERE l.is_active = 1
ORDER BY l.name;
```

### Update Player Language Preference
```sql
UPDATE players SET language = ? WHERE id = ?;
```

## Stored Procedures

### Get Localized Message
```sql
DELIMITER //
CREATE PROCEDURE GetLocalizedMessage(
  IN p_message_key VARCHAR(255),
  IN p_language_code VARCHAR(5)
)
BEGIN
  DECLARE v_translation TEXT;
  
  -- Try to get translation in requested language
  SELECT mt.translation INTO v_translation
  FROM server_messages sm
  JOIN message_translations mt ON sm.id = mt.message_id
  WHERE sm.message_key = p_message_key 
    AND mt.language_code = p_language_code;
  
  -- Fallback to English if not found
  IF v_translation IS NULL THEN
    SELECT mt.translation INTO v_translation
    FROM server_messages sm
    JOIN message_translations mt ON sm.id = mt.message_id
    WHERE sm.message_key = p_message_key 
      AND mt.language_code = 'en';
  END IF;
  
  -- Return the key if no translation exists
  IF v_translation IS NULL THEN
    SET v_translation = p_message_key;
  END IF;
  
  SELECT v_translation AS translation;
END //
DELIMITER ;
```

### Add New Translation
```sql
DELIMITER //
CREATE PROCEDURE AddTranslation(
  IN p_message_key VARCHAR(255),
  IN p_language_code VARCHAR(5),
  IN p_translation TEXT
)
BEGIN
  DECLARE v_message_id INT;
  
  -- Get or create message key
  INSERT INTO server_messages (message_key) 
  VALUES (p_message_key)
  ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);
  
  SET v_message_id = LAST_INSERT_ID();
  
  -- Insert or update translation
  INSERT INTO message_translations (message_id, language_code, translation)
  VALUES (v_message_id, p_language_code, p_translation)
  ON DUPLICATE KEY UPDATE translation = p_translation;
END //
DELIMITER ;
```

## Performance Indexes

```sql
-- Index for fast language lookups
CREATE INDEX idx_translations_language ON message_translations(language_code);

-- Index for player language preference
CREATE INDEX idx_player_language ON players(language);

-- Index for active languages
CREATE INDEX idx_languages_active ON languages(is_active);

-- Composite index for NPC dialogue lookups
CREATE INDEX idx_npc_dialogue_lookup ON npc_dialogue_translations(dialogue_id, language_code);
```

## Migration Scripts

### Migration to Add I18N Support
```sql
-- Add language column to players if not exists
ALTER TABLE players 
ADD COLUMN IF NOT EXISTS `language` VARCHAR(5) NOT NULL DEFAULT 'en';

-- Add language column to accounts if not exists
ALTER TABLE accounts 
ADD COLUMN IF NOT EXISTS `language` VARCHAR(5) NOT NULL DEFAULT 'en';

-- Create languages table if not exists
CREATE TABLE IF NOT EXISTS `languages` (
  `code` VARCHAR(5) NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `native_name` VARCHAR(50) NOT NULL,
  `is_rtl` TINYINT NOT NULL DEFAULT 0,
  `is_active` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

## Best Practices

1. **Always Use Parameterized Queries**: Prevent SQL injection when handling user language preferences.

2. **Implement Caching**: Cache frequently accessed translations to reduce database load.

3. **Fallback Chain**: Implement language fallback (requested → English → key).

4. **Character Set**: Use `utf8mb4` for full Unicode support including emojis.

5. **Indexes**: Create appropriate indexes for language-related queries.

6. **Transactions**: Use transactions when updating multiple translation records.

## Related Documentation

- [INTERNATIONALIZATION.md](INTERNATIONALIZATION.md) - Server-side I18N implementation
- [LUA_SCRIPTING.md](LUA_SCRIPTING.md) - Lua API for translations
- [CONFIGURATION.md](CONFIGURATION.md) - Server configuration settings
