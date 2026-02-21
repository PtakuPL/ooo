-- ============================================
-- ARENA PVP SYSTEM - MIGRACJA BAZY DANYCH
-- Data: 2026-02-21
-- Opis: Tworzy tabele dla systemu areny PvP
-- ============================================

-- Statystyki graczy areny (profil arenowy)
CREATE TABLE IF NOT EXISTS `arena_players` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `player_id` INT NOT NULL,
    `mmr` INT NOT NULL DEFAULT 1000,
    `wins` INT NOT NULL DEFAULT 0,
    `losses` INT NOT NULL DEFAULT 0,
    `draws` INT NOT NULL DEFAULT 0,
    `win_streak` INT NOT NULL DEFAULT 0,
    `best_streak` INT NOT NULL DEFAULT 0,
    `total_damage` BIGINT NOT NULL DEFAULT 0,
    `total_healing` BIGINT NOT NULL DEFAULT 0,
    `total_kills` INT NOT NULL DEFAULT 0,
    `total_deaths` INT NOT NULL DEFAULT 0,
    `arena_points` INT NOT NULL DEFAULT 0,
    `last_match` DATETIME NULL DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_arena_player` (`player_id`),
    KEY `idx_arena_players_mmr` (`mmr` DESC),
    CONSTRAINT `fk_arena_players_player`
        FOREIGN KEY (`player_id`) REFERENCES `players` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Historia meczy areny
CREATE TABLE IF NOT EXISTS `arena_matches` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `mode` ENUM('1v1','2v2','3v3','ffa','ctf','koth','lms','tournament') NOT NULL,
    `map_id` INT NOT NULL DEFAULT 0,
    `started_at` DATETIME NOT NULL,
    `ended_at` DATETIME NULL DEFAULT NULL,
    `duration` INT NOT NULL DEFAULT 0 COMMENT 'czas trwania w sekundach',
    `winner_team` TINYINT NOT NULL DEFAULT 0,
    `season_id` INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_arena_matches_mode` (`mode`, `started_at` DESC),
    KEY `idx_arena_matches_season` (`season_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Uczestnicy meczy (statystyki per gracz per mecz)
CREATE TABLE IF NOT EXISTS `arena_match_players` (
    `match_id` INT NOT NULL,
    `player_id` INT NOT NULL,
    `team` TINYINT NOT NULL DEFAULT 0,
    `kills` INT NOT NULL DEFAULT 0,
    `deaths` INT NOT NULL DEFAULT 0,
    `damage_dealt` BIGINT NOT NULL DEFAULT 0,
    `healing_done` BIGINT NOT NULL DEFAULT 0,
    `mmr_change` INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`match_id`, `player_id`),
    KEY `idx_arena_mp_player` (`player_id`),
    CONSTRAINT `fk_arena_mp_match`
        FOREIGN KEY (`match_id`) REFERENCES `arena_matches` (`id`)
        ON DELETE CASCADE,
    CONSTRAINT `fk_arena_mp_player`
        FOREIGN KEY (`player_id`) REFERENCES `players` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Kolejka matchmakingu (czyszczona przy restarcie serwera)
CREATE TABLE IF NOT EXISTS `arena_queue` (
    `player_id` INT NOT NULL,
    `mode` VARCHAR(20) NOT NULL,
    `mmr` INT NOT NULL DEFAULT 1000,
    `queued_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `expanded_range` INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`player_id`),
    KEY `idx_arena_queue_mode` (`mode`, `mmr`),
    CONSTRAINT `fk_arena_queue_player`
        FOREIGN KEY (`player_id`) REFERENCES `players` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Sezony areny
CREATE TABLE IF NOT EXISTS `arena_seasons` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `start_date` DATE NOT NULL,
    `end_date` DATE NOT NULL,
    `is_active` TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Rankingi sezonowe (snapshot na koniec sezonu)
CREATE TABLE IF NOT EXISTS `arena_season_rankings` (
    `season_id` INT NOT NULL,
    `player_id` INT NOT NULL,
    `final_mmr` INT NOT NULL DEFAULT 1000,
    `final_rank` INT NOT NULL DEFAULT 0,
    `rewards_claimed` TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (`season_id`, `player_id`),
    CONSTRAINT `fk_arena_sr_season`
        FOREIGN KEY (`season_id`) REFERENCES `arena_seasons` (`id`)
        ON DELETE CASCADE,
    CONSTRAINT `fk_arena_sr_player`
        FOREIGN KEY (`player_id`) REFERENCES `players` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
