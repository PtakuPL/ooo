/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.13-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: canary_modern
-- ------------------------------------------------------
-- Server version	10.11.13-MariaDB-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `account_ban_history`
--

DROP TABLE IF EXISTS `account_ban_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_ban_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) unsigned NOT NULL,
  `reason` varchar(255) NOT NULL,
  `banned_at` bigint(20) NOT NULL,
  `expired_at` bigint(20) NOT NULL,
  `banned_by` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  KEY `banned_by` (`banned_by`),
  CONSTRAINT `account_bans_history_account_fk` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `account_bans_history_player_fk` FOREIGN KEY (`banned_by`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_ban_history`
--

LOCK TABLES `account_ban_history` WRITE;
/*!40000 ALTER TABLE `account_ban_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_ban_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account_bans`
--

DROP TABLE IF EXISTS `account_bans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_bans` (
  `account_id` int(11) unsigned NOT NULL,
  `reason` varchar(255) NOT NULL,
  `banned_at` bigint(20) NOT NULL,
  `expires_at` bigint(20) NOT NULL,
  `banned_by` int(11) NOT NULL,
  PRIMARY KEY (`account_id`),
  KEY `banned_by` (`banned_by`),
  CONSTRAINT `account_bans_account_fk` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `account_bans_player_fk` FOREIGN KEY (`banned_by`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_bans`
--

LOCK TABLES `account_bans` WRITE;
/*!40000 ALTER TABLE `account_bans` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_bans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account_sessions`
--

DROP TABLE IF EXISTS `account_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_sessions` (
  `id` varchar(191) NOT NULL,
  `account_id` int(10) unsigned NOT NULL,
  `expires` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_sessions`
--

LOCK TABLES `account_sessions` WRITE;
/*!40000 ALTER TABLE `account_sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account_vipgrouplist`
--

DROP TABLE IF EXISTS `account_vipgrouplist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_vipgrouplist` (
  `account_id` int(11) unsigned NOT NULL COMMENT 'id of account whose viplist entry it is',
  `player_id` int(11) NOT NULL COMMENT 'id of target player of viplist entry',
  `vipgroup_id` int(11) unsigned NOT NULL COMMENT 'id of vip group that player belongs',
  UNIQUE KEY `account_vipgrouplist_unique` (`account_id`,`player_id`,`vipgroup_id`),
  KEY `account_id` (`account_id`),
  KEY `player_id` (`player_id`),
  KEY `vipgroup_id` (`vipgroup_id`),
  KEY `account_vipgrouplist_vipgroup_fk` (`vipgroup_id`,`account_id`),
  CONSTRAINT `account_vipgrouplist_player_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE,
  CONSTRAINT `account_vipgrouplist_vipgroup_fk` FOREIGN KEY (`vipgroup_id`, `account_id`) REFERENCES `account_vipgroups` (`id`, `account_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_vipgrouplist`
--

LOCK TABLES `account_vipgrouplist` WRITE;
/*!40000 ALTER TABLE `account_vipgrouplist` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_vipgrouplist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account_vipgroups`
--

DROP TABLE IF EXISTS `account_vipgroups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_vipgroups` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int(11) unsigned NOT NULL COMMENT 'id of account whose vip group entry it is',
  `name` varchar(128) NOT NULL,
  `customizable` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`,`account_id`),
  KEY `account_vipgroups_accounts_fk` (`account_id`),
  CONSTRAINT `account_vipgroups_accounts_fk` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_vipgroups`
--

LOCK TABLES `account_vipgroups` WRITE;
/*!40000 ALTER TABLE `account_vipgroups` DISABLE KEYS */;
INSERT INTO `account_vipgroups` VALUES
(1,1,'Enemies',0),
(2,1,'Friends',0),
(3,1,'Trading Partner',0),
(4,6,'Enemies',0),
(5,6,'Friends',0),
(6,6,'Trading Partner',0),
(7,3,'Enemies',0),
(8,3,'Friends',0),
(9,3,'Trading Partner',0),
(10,7,'Enemies',0),
(11,7,'Friends',0),
(12,7,'Trading Partner',0),
(13,10,'Enemies',0),
(14,10,'Friends',0),
(15,10,'Trading Partner',0),
(16,11,'Enemies',0),
(17,11,'Friends',0),
(18,11,'Trading Partner',0),
(19,12,'Enemies',0),
(20,12,'Friends',0),
(21,12,'Trading Partner',0),
(22,13,'Enemies',0),
(23,13,'Friends',0),
(24,13,'Trading Partner',0),
(25,14,'Enemies',0),
(26,14,'Friends',0),
(27,14,'Trading Partner',0),
(28,15,'Enemies',0),
(29,15,'Friends',0),
(30,15,'Trading Partner',0),
(31,16,'Enemies',0),
(32,16,'Friends',0),
(33,16,'Trading Partner',0),
(34,17,'Enemies',0),
(35,17,'Friends',0),
(36,17,'Trading Partner',0),
(37,18,'Enemies',0),
(38,18,'Friends',0),
(39,18,'Trading Partner',0),
(40,19,'Enemies',0),
(41,19,'Friends',0),
(42,19,'Trading Partner',0),
(43,20,'Enemies',0),
(44,20,'Friends',0),
(45,20,'Trading Partner',0),
(46,21,'Enemies',0),
(47,21,'Friends',0),
(48,21,'Trading Partner',0),
(49,22,'Enemies',0),
(50,22,'Friends',0),
(51,22,'Trading Partner',0),
(52,23,'Enemies',0),
(53,23,'Friends',0),
(54,23,'Trading Partner',0);
/*!40000 ALTER TABLE `account_vipgroups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account_viplist`
--

DROP TABLE IF EXISTS `account_viplist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_viplist` (
  `account_id` int(11) unsigned NOT NULL COMMENT 'id of account whose viplist entry it is',
  `player_id` int(11) NOT NULL COMMENT 'id of target player of viplist entry',
  `description` varchar(128) NOT NULL DEFAULT '',
  `icon` tinyint(2) unsigned NOT NULL DEFAULT 0,
  `notify` tinyint(1) NOT NULL DEFAULT 0,
  UNIQUE KEY `account_viplist_unique` (`account_id`,`player_id`),
  KEY `account_id` (`account_id`),
  KEY `player_id` (`player_id`),
  CONSTRAINT `account_viplist_account_fk` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `account_viplist_player_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_viplist`
--

LOCK TABLES `account_viplist` WRITE;
/*!40000 ALTER TABLE `account_viplist` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_viplist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `accounts` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `password` text NOT NULL,
  `email` varchar(255) NOT NULL DEFAULT '',
  `premdays` int(11) NOT NULL DEFAULT 0,
  `premdays_purchased` int(11) NOT NULL DEFAULT 0,
  `lastday` int(10) unsigned NOT NULL DEFAULT 0,
  `type` tinyint(1) unsigned NOT NULL DEFAULT 1,
  `coins` int(12) unsigned NOT NULL DEFAULT 0,
  `coins_transferable` int(12) unsigned NOT NULL DEFAULT 0,
  `tournament_coins` int(12) unsigned NOT NULL DEFAULT 0,
  `creation` int(11) unsigned NOT NULL DEFAULT 0,
  `recruiter` int(6) DEFAULT 0,
  `house_bid_id` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `accounts_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts`
--

LOCK TABLES `accounts` WRITE;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
INSERT INTO `accounts` VALUES
(1,'god','21298df8a3277357ee55b01df9530b535cf08ec1','@god',0,0,0,5,0,0,0,1772732935,0,0),
(3,'','0','admin@canaryaac.com',0,0,0,5,0,0,0,1659509050,0,0),
(6,'ptakukolo','A94A8FE5CCB19BA61C4C0873D391E987982FBBD3','proeloptaku3@wp.pl',0,0,0,5,0,0,0,1772732935,0,0),
(7,'ptakukolo1','0','proeloptaku@wp.pl',0,0,0,0,0,0,0,1755128823,0,0),
(10,'testruntime','662339c7d8d89efb5f06507f92120262d0ed901d','testruntime@test.pl',0,0,0,1,0,0,0,1772738518,0,0),
(11,'testportal01','dddd5d7b474d2c78ebbb833789c4bfd721edf4bf','testportal01@test.com',0,0,0,1,0,0,0,1772738944,0,0),
(12,'testportal02','2234e5756200f73413109c55b1b4b3267db42011','testportal02@test.com',0,0,0,1,0,0,0,1772738957,0,0),
(13,'reddaxe_1772743014','f4a69973e7b0bf9d160f9f60e3c3acd2494beb0d','reddaxe_1772743014@example.com',0,0,0,0,0,0,0,1772743030,0,0),
(14,'reddaxe_1772743140','f4a69973e7b0bf9d160f9f60e3c3acd2494beb0d','reddaxe_1772743140@example.com',0,0,0,0,0,0,0,1772743141,0,0),
(15,'reddaxelog_1772743158','f4a69973e7b0bf9d160f9f60e3c3acd2494beb0d','reddaxelog_1772743158@example.com',0,0,0,0,0,0,0,1772743159,0,0),
(16,'reddaxelog_1772743171','f4a69973e7b0bf9d160f9f60e3c3acd2494beb0d','reddaxelog_1772743171@example.com',0,0,0,0,0,0,0,1772743172,0,0),
(17,'regapi_1772743375','f4a69973e7b0bf9d160f9f60e3c3acd2494beb0d','regapi_1772743375@example.com',0,0,0,0,0,0,0,1772743376,0,0),
(18,'regapi_1772743384','f4a69973e7b0bf9d160f9f60e3c3acd2494beb0d','regapi_1772743384@example.com',0,0,0,0,0,0,0,1772743385,0,0),
(19,'final_1772743577','f4a69973e7b0bf9d160f9f60e3c3acd2494beb0d','final_1772743577@example.com',0,0,0,0,0,0,0,1772743578,0,0),
(20,'portaltest9850','2fadc2d2915b91f2eaf3c53e3e2d373a05e97738','portaltest9850@test.local',0,0,0,1,0,0,0,1772740282,0,0),
(21,'portal_i18n_220617','4bd074cf429ab454cd7bee74be51083a93cd8aa9','portal_i18n_220617@example.com',0,0,0,0,0,0,0,1772744778,0,0),
(22,'portal_login_220631','4bd074cf429ab454cd7bee74be51083a93cd8aa9','portal_login_220631@example.com',0,0,0,0,0,0,0,1772744792,0,0),
(23,'i18n_en_221438','4bd074cf429ab454cd7bee74be51083a93cd8aa9','i18n_en_221438@example.com',0,0,0,0,0,0,0,1772745279,0,0);
/*!40000 ALTER TABLE `accounts` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`ptaku`@`localhost`*/ /*!50003 TRIGGER `oncreate_accounts` AFTER INSERT ON `accounts` FOR EACH ROW BEGIN
    INSERT INTO `account_vipgroups` (`account_id`, `name`, `customizable`) VALUES (NEW.`id`, 'Enemies', 0);
    INSERT INTO `account_vipgroups` (`account_id`, `name`, `customizable`) VALUES (NEW.`id`, 'Friends', 0);
    INSERT INTO `account_vipgroups` (`account_id`, `name`, `customizable`) VALUES (NEW.`id`, 'Trading Partner', 0);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `boosted_boss`
--

DROP TABLE IF EXISTS `boosted_boss`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `boosted_boss` (
  `boostname` text DEFAULT NULL,
  `date` varchar(250) NOT NULL DEFAULT '',
  `raceid` varchar(250) NOT NULL DEFAULT '',
  `looktypeEx` int(11) NOT NULL DEFAULT 0,
  `looktype` int(11) NOT NULL DEFAULT 136,
  `lookfeet` int(11) NOT NULL DEFAULT 0,
  `looklegs` int(11) NOT NULL DEFAULT 0,
  `lookhead` int(11) NOT NULL DEFAULT 0,
  `lookbody` int(11) NOT NULL DEFAULT 0,
  `lookaddons` int(11) NOT NULL DEFAULT 0,
  `lookmount` int(11) DEFAULT 0,
  PRIMARY KEY (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `boosted_boss`
--

LOCK TABLES `boosted_boss` WRITE;
/*!40000 ALTER TABLE `boosted_boss` DISABLE KEYS */;
INSERT INTO `boosted_boss` VALUES
('Lord Azaram','6','1756',0,1223,81,94,19,2,3,0);
/*!40000 ALTER TABLE `boosted_boss` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `boosted_creature`
--

DROP TABLE IF EXISTS `boosted_creature`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `boosted_creature` (
  `boostname` text DEFAULT NULL,
  `date` varchar(250) NOT NULL DEFAULT '',
  `raceid` varchar(250) NOT NULL DEFAULT '',
  `looktype` int(11) NOT NULL DEFAULT 136,
  `lookfeet` int(11) NOT NULL DEFAULT 0,
  `looklegs` int(11) NOT NULL DEFAULT 0,
  `lookhead` int(11) NOT NULL DEFAULT 0,
  `lookbody` int(11) NOT NULL DEFAULT 0,
  `lookaddons` int(11) NOT NULL DEFAULT 0,
  `lookmount` int(11) DEFAULT 0,
  PRIMARY KEY (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `boosted_creature`
--

LOCK TABLES `boosted_creature` WRITE;
/*!40000 ALTER TABLE `boosted_creature` DISABLE KEYS */;
INSERT INTO `boosted_creature` VALUES
('Iron Servant','6','700',395,0,0,0,0,0,0);
/*!40000 ALTER TABLE `boosted_creature` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coins_transactions`
--

DROP TABLE IF EXISTS `coins_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coins_transactions` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int(11) unsigned NOT NULL,
  `type` tinyint(1) unsigned NOT NULL,
  `coin_type` tinyint(1) unsigned NOT NULL DEFAULT 1,
  `amount` int(12) unsigned NOT NULL,
  `description` varchar(3500) NOT NULL,
  `timestamp` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  CONSTRAINT `coins_transactions_account_fk` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coins_transactions`
--

LOCK TABLES `coins_transactions` WRITE;
/*!40000 ALTER TABLE `coins_transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `coins_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `daily_reward_history`
--

DROP TABLE IF EXISTS `daily_reward_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `daily_reward_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `daystreak` smallint(2) NOT NULL DEFAULT 0,
  `player_id` int(11) NOT NULL,
  `timestamp` int(11) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`),
  CONSTRAINT `daily_reward_history_player_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `daily_reward_history`
--

LOCK TABLES `daily_reward_history` WRITE;
/*!40000 ALTER TABLE `daily_reward_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `daily_reward_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `forge_history`
--

DROP TABLE IF EXISTS `forge_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `forge_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` int(11) NOT NULL,
  `action_type` int(11) NOT NULL DEFAULT 0,
  `description` text NOT NULL,
  `is_success` tinyint(4) NOT NULL DEFAULT 0,
  `bonus` tinyint(4) NOT NULL DEFAULT 0,
  `done_at` bigint(20) NOT NULL,
  `done_at_date` datetime DEFAULT current_timestamp(),
  `cost` bigint(20) unsigned NOT NULL DEFAULT 0,
  `gained` bigint(20) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`),
  CONSTRAINT `forge_history_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `forge_history`
--

LOCK TABLES `forge_history` WRITE;
/*!40000 ALTER TABLE `forge_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `forge_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `global_storage`
--

DROP TABLE IF EXISTS `global_storage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `global_storage` (
  `key` varchar(32) NOT NULL,
  `value` text NOT NULL,
  UNIQUE KEY `global_storage_unique` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_storage`
--

LOCK TABLES `global_storage` WRITE;
/*!40000 ALTER TABLE `global_storage` DISABLE KEYS */;
INSERT INTO `global_storage` VALUES
('40000','4');
/*!40000 ALTER TABLE `global_storage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `guild_invites`
--

DROP TABLE IF EXISTS `guild_invites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `guild_invites` (
  `player_id` int(11) NOT NULL DEFAULT 0,
  `guild_id` int(11) NOT NULL DEFAULT 0,
  `date` int(11) NOT NULL,
  PRIMARY KEY (`player_id`,`guild_id`),
  KEY `guild_id` (`guild_id`),
  CONSTRAINT `guild_invites_guild_fk` FOREIGN KEY (`guild_id`) REFERENCES `guilds` (`id`) ON DELETE CASCADE,
  CONSTRAINT `guild_invites_player_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `guild_invites`
--

LOCK TABLES `guild_invites` WRITE;
/*!40000 ALTER TABLE `guild_invites` DISABLE KEYS */;
/*!40000 ALTER TABLE `guild_invites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `guild_membership`
--

DROP TABLE IF EXISTS `guild_membership`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `guild_membership` (
  `player_id` int(11) NOT NULL,
  `guild_id` int(11) NOT NULL,
  `rank_id` int(11) NOT NULL,
  `nick` varchar(15) NOT NULL DEFAULT '',
  PRIMARY KEY (`player_id`),
  KEY `guild_id` (`guild_id`),
  KEY `rank_id` (`rank_id`),
  CONSTRAINT `guild_membership_guild_fk` FOREIGN KEY (`guild_id`) REFERENCES `guilds` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `guild_membership_player_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `guild_membership_rank_fk` FOREIGN KEY (`rank_id`) REFERENCES `guild_ranks` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `guild_membership`
--

LOCK TABLES `guild_membership` WRITE;
/*!40000 ALTER TABLE `guild_membership` DISABLE KEYS */;
/*!40000 ALTER TABLE `guild_membership` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `guild_ranks`
--

DROP TABLE IF EXISTS `guild_ranks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `guild_ranks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `guild_id` int(11) NOT NULL COMMENT 'guild',
  `name` varchar(255) NOT NULL COMMENT 'rank name',
  `level` int(11) NOT NULL COMMENT 'rank level - leader, vice, member, maybe something else',
  PRIMARY KEY (`id`),
  KEY `guild_id` (`guild_id`),
  CONSTRAINT `guild_ranks_fk` FOREIGN KEY (`guild_id`) REFERENCES `guilds` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `guild_ranks`
--

LOCK TABLES `guild_ranks` WRITE;
/*!40000 ALTER TABLE `guild_ranks` DISABLE KEYS */;
/*!40000 ALTER TABLE `guild_ranks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `guild_wars`
--

DROP TABLE IF EXISTS `guild_wars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `guild_wars` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `guild1` int(11) NOT NULL DEFAULT 0,
  `guild2` int(11) NOT NULL DEFAULT 0,
  `name1` varchar(255) NOT NULL,
  `name2` varchar(255) NOT NULL,
  `status` tinyint(2) unsigned NOT NULL DEFAULT 0,
  `started` bigint(15) NOT NULL DEFAULT 0,
  `ended` bigint(15) NOT NULL DEFAULT 0,
  `frags_limit` smallint(4) unsigned NOT NULL DEFAULT 0,
  `payment` bigint(13) unsigned NOT NULL DEFAULT 0,
  `duration_days` tinyint(3) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `guild1` (`guild1`),
  KEY `guild2` (`guild2`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `guild_wars`
--

LOCK TABLES `guild_wars` WRITE;
/*!40000 ALTER TABLE `guild_wars` DISABLE KEYS */;
/*!40000 ALTER TABLE `guild_wars` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `guilds`
--

DROP TABLE IF EXISTS `guilds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `guilds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `level` int(11) NOT NULL DEFAULT 1,
  `name` varchar(255) NOT NULL,
  `ownerid` int(11) NOT NULL,
  `creationdata` int(11) NOT NULL,
  `motd` varchar(255) NOT NULL DEFAULT '',
  `residence` int(11) NOT NULL DEFAULT 0,
  `balance` bigint(20) unsigned NOT NULL DEFAULT 0,
  `points` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `guilds_name_unique` (`name`),
  UNIQUE KEY `guilds_owner_unique` (`ownerid`),
  CONSTRAINT `guilds_ownerid_fk` FOREIGN KEY (`ownerid`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `guilds`
--

LOCK TABLES `guilds` WRITE;
/*!40000 ALTER TABLE `guilds` DISABLE KEYS */;
/*!40000 ALTER TABLE `guilds` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`ptaku`@`localhost`*/ /*!50003 TRIGGER `oncreate_guilds` AFTER INSERT ON `guilds` FOR EACH ROW BEGIN
    INSERT INTO `guild_ranks` (`name`, `level`, `guild_id`) VALUES ('The Leader', 3, NEW.`id`);
    INSERT INTO `guild_ranks` (`name`, `level`, `guild_id`) VALUES ('Vice-Leader', 2, NEW.`id`);
    INSERT INTO `guild_ranks` (`name`, `level`, `guild_id`) VALUES ('Member', 1, NEW.`id`);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `guildwar_kills`
--

DROP TABLE IF EXISTS `guildwar_kills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `guildwar_kills` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `killer` varchar(50) NOT NULL,
  `target` varchar(50) NOT NULL,
  `killerguild` int(11) NOT NULL DEFAULT 0,
  `targetguild` int(11) NOT NULL DEFAULT 0,
  `warid` int(11) NOT NULL DEFAULT 0,
  `time` bigint(15) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `warid` (`warid`),
  CONSTRAINT `guildwar_kills_warid_fk` FOREIGN KEY (`warid`) REFERENCES `guild_wars` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `guildwar_kills`
--

LOCK TABLES `guildwar_kills` WRITE;
/*!40000 ALTER TABLE `guildwar_kills` DISABLE KEYS */;
/*!40000 ALTER TABLE `guildwar_kills` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `house_lists`
--

DROP TABLE IF EXISTS `house_lists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `house_lists` (
  `house_id` int(11) NOT NULL,
  `listid` int(11) NOT NULL,
  `version` bigint(20) NOT NULL DEFAULT 0,
  `list` text NOT NULL,
  PRIMARY KEY (`house_id`,`listid`),
  KEY `house_id_index` (`house_id`),
  KEY `version` (`version`),
  CONSTRAINT `houses_list_house_fk` FOREIGN KEY (`house_id`) REFERENCES `houses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `house_lists`
--

LOCK TABLES `house_lists` WRITE;
/*!40000 ALTER TABLE `house_lists` DISABLE KEYS */;
/*!40000 ALTER TABLE `house_lists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `houses`
--

DROP TABLE IF EXISTS `houses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `houses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` int(11) NOT NULL,
  `new_owner` int(11) NOT NULL DEFAULT -1,
  `paid` int(10) unsigned NOT NULL DEFAULT 0,
  `warnings` int(11) NOT NULL DEFAULT 0,
  `name` varchar(255) NOT NULL,
  `rent` int(11) NOT NULL DEFAULT 0,
  `town_id` int(11) NOT NULL DEFAULT 0,
  `size` int(11) NOT NULL DEFAULT 0,
  `guildid` int(11) DEFAULT NULL,
  `beds` int(11) NOT NULL DEFAULT 0,
  `bidder` int(11) NOT NULL DEFAULT 0,
  `bidder_name` varchar(255) NOT NULL DEFAULT '',
  `highest_bid` int(11) NOT NULL DEFAULT 0,
  `internal_bid` int(11) NOT NULL DEFAULT 0,
  `bid_end_date` int(11) NOT NULL DEFAULT 0,
  `state` smallint(5) unsigned NOT NULL DEFAULT 0,
  `transfer_status` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `owner` (`owner`),
  KEY `town_id` (`town_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3697 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `houses`
--

LOCK TABLES `houses` WRITE;
/*!40000 ALTER TABLE `houses` DISABLE KEYS */;
INSERT INTO `houses` VALUES
(2628,0,-1,0,0,'Castle of the Winds',500000,5,493,NULL,0,0,'',0,0,0,0,0),
(2629,0,-1,0,0,'Ab\'Dendriel Clanhall',250000,5,310,NULL,0,0,'',0,0,0,0,0),
(2630,0,-1,0,0,'Underwood 9',50000,5,13,NULL,0,0,'',0,0,0,0,0),
(2631,0,-1,0,0,'Treetop 13',100000,5,26,NULL,0,0,'',0,0,0,0,0),
(2632,0,-1,0,0,'Underwood 8',50000,5,17,NULL,0,0,'',0,0,0,0,0),
(2633,0,-1,0,0,'Treetop 11',50000,5,16,NULL,0,0,'',0,0,0,0,0),
(2635,0,-1,0,0,'Great Willow 2a',50000,5,17,NULL,0,0,'',0,0,0,0,0),
(2637,0,-1,0,0,'Great Willow 2b',50000,5,17,NULL,0,0,'',0,0,0,0,0),
(2638,0,-1,0,0,'Great Willow Western Wing',100000,5,53,NULL,0,0,'',0,0,0,0,0),
(2640,0,-1,0,0,'Great Willow 1',100000,5,28,NULL,0,0,'',0,0,0,0,0),
(2642,0,-1,0,0,'Great Willow 3a',50000,5,17,NULL,0,0,'',0,0,0,0,0),
(2644,0,-1,0,0,'Great Willow 3b',80000,5,32,NULL,0,0,'',0,0,0,0,0),
(2645,0,-1,0,0,'Great Willow 4a',25000,5,17,NULL,0,0,'',0,0,0,0,0),
(2648,0,-1,0,0,'Great Willow 4b',25000,5,17,NULL,0,0,'',0,0,0,0,0),
(2649,0,-1,0,0,'Underwood 6',100000,5,31,NULL,0,0,'',0,0,0,0,0),
(2650,0,-1,0,0,'Underwood 3',100000,5,33,NULL,0,0,'',0,0,0,0,0),
(2651,0,-1,0,0,'Underwood 5',80000,5,26,NULL,0,0,'',0,0,0,0,0),
(2652,0,-1,0,0,'Underwood 2',100000,5,31,NULL,0,0,'',0,0,0,0,0),
(2653,0,-1,0,0,'Underwood 1',100000,5,31,NULL,0,0,'',0,0,0,0,0),
(2654,0,-1,0,0,'Prima Arbor',400000,5,197,NULL,0,0,'',0,0,0,0,0),
(2655,0,-1,0,0,'Underwood 7',200000,5,28,NULL,0,0,'',0,0,0,0,0),
(2656,0,-1,0,0,'Underwood 10',25000,5,13,NULL,0,0,'',0,0,0,0,0),
(2657,0,-1,0,0,'Underwood 4',100000,5,43,NULL,0,0,'',0,0,0,0,0),
(2658,0,-1,0,0,'Treetop 9',50000,5,21,NULL,0,0,'',0,0,0,0,0),
(2659,0,-1,0,0,'Treetop 10',80000,5,21,NULL,0,0,'',0,0,0,0,0),
(2660,0,-1,0,0,'Treetop 8',25000,5,16,NULL,0,0,'',0,0,0,0,0),
(2661,0,-1,0,0,'Treetop 7',50000,5,16,NULL,0,0,'',0,0,0,0,0),
(2662,0,-1,0,0,'Treetop 6',25000,5,9,NULL,0,0,'',0,0,0,0,0),
(2663,0,-1,0,0,'Treetop 5 (Shop)',80000,5,27,NULL,0,0,'',0,0,0,0,0),
(2664,0,-1,0,0,'Treetop 12 (Shop)',100000,5,27,NULL,0,0,'',0,0,0,0,0),
(2665,0,-1,0,0,'Treetop 4 (Shop)',80000,5,25,NULL,0,0,'',0,0,0,0,0),
(2666,0,-1,0,0,'Treetop 3 (Shop)',80000,5,25,NULL,0,0,'',0,0,0,0,0),
(2687,0,-1,0,0,'Northern Street 1a',100000,6,21,NULL,0,0,'',0,0,0,0,0),
(2688,0,-1,0,0,'Park Lane 3a',100000,6,25,NULL,0,0,'',0,0,0,0,0),
(2689,0,-1,0,0,'Park Lane 1a',150000,6,28,NULL,0,0,'',0,0,0,0,0),
(2690,0,-1,0,0,'Park Lane 4',150000,6,22,NULL,0,0,'',0,0,0,0,0),
(2691,0,-1,0,0,'Park Lane 2',150000,6,22,NULL,0,0,'',0,0,0,0,0),
(2692,0,-1,0,0,'Theater Avenue 7, Flat 04',50000,6,11,NULL,0,0,'',0,0,0,0,0),
(2693,0,-1,0,0,'Theater Avenue 7, Flat 03',25000,6,9,NULL,0,0,'',0,0,0,0,0),
(2694,0,-1,0,0,'Theater Avenue 7, Flat 05',50000,6,9,NULL,0,0,'',0,0,0,0,0),
(2695,0,-1,0,0,'Theater Avenue 7, Flat 06',25000,6,7,NULL,0,0,'',0,0,0,0,0),
(2696,0,-1,0,0,'Theater Avenue 7, Flat 02',25000,6,9,NULL,0,0,'',0,0,0,0,0),
(2697,0,-1,0,0,'Theater Avenue 7, Flat 01',25000,6,7,NULL,0,0,'',0,0,0,0,0),
(2698,0,-1,0,0,'Northern Street 5',200000,6,47,NULL,0,0,'',0,0,0,0,0),
(2699,0,-1,0,0,'Northern Street 7',150000,6,40,NULL,0,0,'',0,0,0,0,0),
(2700,0,-1,0,0,'Theater Avenue 6e',80000,6,16,NULL,0,0,'',0,0,0,0,0),
(2701,0,-1,0,0,'Theater Avenue 6c',25000,6,5,NULL,0,0,'',0,0,0,0,0),
(2702,0,-1,0,0,'Theater Avenue 6a',80000,6,16,NULL,0,0,'',0,0,0,0,0),
(2703,0,-1,0,0,'Theater Avenue, Tower',300000,6,70,NULL,0,0,'',0,0,0,0,0),
(2705,0,-1,0,0,'East Lane 2',300000,6,108,NULL,0,0,'',0,0,0,0,0),
(2706,0,-1,0,0,'Harbour Lane 2a (Shop)',80000,6,17,NULL,0,0,'',0,0,0,0,0),
(2707,0,-1,0,0,'Harbour Lane 2b (Shop)',80000,6,17,NULL,0,0,'',0,0,0,0,0),
(2708,0,-1,0,0,'Harbour Lane 3',400000,6,84,NULL,0,0,'',0,0,0,0,0),
(2709,0,-1,0,0,'Magician\'s Alley 8',150000,6,26,NULL,0,0,'',0,0,0,0,0),
(2710,0,-1,0,0,'Lonely Sea Side Hostel',400000,6,281,NULL,0,0,'',0,0,0,0,0),
(2711,0,-1,0,0,'Suntower',500000,6,232,NULL,0,0,'',0,0,0,0,0),
(2712,0,-1,0,0,'House of Recreation',500000,6,401,NULL,0,0,'',0,0,0,0,0),
(2713,0,-1,0,0,'Carlin Clanhall',250000,6,211,NULL,0,0,'',0,0,0,0,0),
(2714,0,-1,0,0,'Magician\'s Alley 4',200000,6,49,NULL,0,0,'',0,0,0,0,0),
(2715,0,-1,0,0,'Theater Avenue 14 (Shop)',200000,6,47,NULL,0,0,'',0,0,0,0,0),
(2716,0,-1,0,0,'Theater Avenue 12',80000,6,19,NULL,0,0,'',0,0,0,0,0),
(2717,0,-1,0,0,'Magician\'s Alley 1',100000,6,19,NULL,0,0,'',0,0,0,0,0),
(2718,0,-1,0,0,'Theater Avenue 10',100000,6,22,NULL,0,0,'',0,0,0,0,0),
(2719,0,-1,0,0,'Magician\'s Alley 1b',25000,6,13,NULL,0,0,'',0,0,0,0,0),
(2720,0,-1,0,0,'Magician\'s Alley 1a',25000,6,12,NULL,0,0,'',0,0,0,0,0),
(2721,0,-1,0,0,'Magician\'s Alley 1c',25000,6,10,NULL,0,0,'',0,0,0,0,0),
(2722,0,-1,0,0,'Magician\'s Alley 1d',25000,6,9,NULL,0,0,'',0,0,0,0,0),
(2723,0,-1,0,0,'Magician\'s Alley 5c',100000,6,21,NULL,0,0,'',0,0,0,0,0),
(2724,0,-1,0,0,'Magician\'s Alley 5f',80000,6,21,NULL,0,0,'',0,0,0,0,0),
(2725,0,-1,0,0,'Magician\'s Alley 5b',50000,6,19,NULL,0,0,'',0,0,0,0,0),
(2727,0,-1,0,0,'Magician\'s Alley 5a',50000,6,22,NULL,0,0,'',0,0,0,0,0),
(2729,0,-1,0,0,'Central Plaza 3 (Shop)',50000,6,17,NULL,0,0,'',0,0,0,0,0),
(2730,0,-1,0,0,'Central Plaza 2 (Shop)',25000,6,17,NULL,0,0,'',0,0,0,0,0),
(2731,0,-1,0,0,'Central Plaza 1 (Shop)',50000,6,17,NULL,0,0,'',0,0,0,0,0),
(2732,0,-1,0,0,'Theater Avenue 8b',100000,6,26,NULL,0,0,'',0,0,0,0,0),
(2733,0,-1,0,0,'Harbour Lane 1 (Shop)',100000,6,26,NULL,0,0,'',0,0,0,0,0),
(2734,0,-1,0,0,'Theater Avenue 6f',80000,6,16,NULL,0,0,'',0,0,0,0,0),
(2735,0,-1,0,0,'Theater Avenue 6d',25000,6,5,NULL,0,0,'',0,0,0,0,0),
(2736,0,-1,0,0,'Theater Avenue 6b',50000,6,16,NULL,0,0,'',0,0,0,0,0),
(2737,0,-1,0,0,'Northern Street 3a',80000,6,16,NULL,0,0,'',0,0,0,0,0),
(2738,0,-1,0,0,'Northern Street 3b',80000,6,17,NULL,0,0,'',0,0,0,0,0),
(2739,0,-1,0,0,'Northern Street 1b',80000,6,21,NULL,0,0,'',0,0,0,0,0),
(2740,0,-1,0,0,'Northern Street 1c',80000,6,16,NULL,0,0,'',0,0,0,0,0),
(2741,0,-1,0,0,'Theater Avenue 7, Flat 14',25000,6,11,NULL,0,0,'',0,0,0,0,0),
(2742,0,-1,0,0,'Theater Avenue 7, Flat 13',25000,6,9,NULL,0,0,'',0,0,0,0,0),
(2743,0,-1,0,0,'Theater Avenue 7, Flat 15',25000,6,9,NULL,0,0,'',0,0,0,0,0),
(2744,0,-1,0,0,'Theater Avenue 7, Flat 12',25000,6,9,NULL,0,0,'',0,0,0,0,0),
(2745,0,-1,0,0,'Theater Avenue 7, Flat 11',50000,6,11,NULL,0,0,'',0,0,0,0,0),
(2746,0,-1,0,0,'Theater Avenue 7, Flat 16',25000,6,9,NULL,0,0,'',0,0,0,0,0),
(2747,0,-1,0,0,'Theater Avenue 5',200000,6,81,NULL,0,0,'',0,0,0,0,0),
(2751,0,-1,0,0,'Harbour Flats, Flat 11',25000,6,13,NULL,0,0,'',0,0,0,0,0),
(2752,0,-1,0,0,'Harbour Flats, Flat 13',25000,6,13,NULL,0,0,'',0,0,0,0,0),
(2753,0,-1,0,0,'Harbour Flats, Flat 15',50000,6,21,NULL,0,0,'',0,0,0,0,0),
(2755,0,-1,0,0,'Harbour Flats, Flat 12',50000,6,22,NULL,0,0,'',0,0,0,0,0),
(2757,0,-1,0,0,'Harbour Flats, Flat 16',50000,6,22,NULL,0,0,'',0,0,0,0,0),
(2759,0,-1,0,0,'Harbour Flats, Flat 21',50000,6,19,NULL,0,0,'',0,0,0,0,0),
(2760,0,-1,0,0,'Harbour Flats, Flat 22',80000,6,22,NULL,0,0,'',0,0,0,0,0),
(2761,0,-1,0,0,'Harbour Flats, Flat 23',25000,6,10,NULL,0,0,'',0,0,0,0,0),
(2763,0,-1,0,0,'Park Lane 1b',200000,6,32,NULL,0,0,'',0,0,0,0,0),
(2764,0,-1,0,0,'Theater Avenue 8a',100000,6,26,NULL,0,0,'',0,0,0,0,0),
(2765,0,-1,0,0,'Theater Avenue 11a',100000,6,29,NULL,0,0,'',0,0,0,0,0),
(2767,0,-1,0,0,'Theater Avenue 11b',100000,6,29,NULL,0,0,'',0,0,0,0,0),
(2768,0,-1,0,0,'Caretaker\'s Residence',600000,6,231,NULL,0,0,'',0,0,0,0,0),
(2769,0,-1,0,0,'Moonkeep',250000,6,289,NULL,0,0,'',0,0,0,0,0),
(2770,0,-1,0,0,'Mangrove 1',80000,5,31,NULL,0,0,'',0,0,0,0,0),
(2771,0,-1,0,0,'Coastwood 2',50000,5,16,NULL,0,0,'',0,0,0,0,0),
(2772,0,-1,0,0,'Coastwood 1',50000,5,16,NULL,0,0,'',0,0,0,0,0),
(2773,0,-1,0,0,'Coastwood 3',50000,5,22,NULL,0,0,'',0,0,0,0,0),
(2774,0,-1,0,0,'Coastwood 4',50000,5,19,NULL,0,0,'',0,0,0,0,0),
(2775,0,-1,0,0,'Mangrove 4',50000,5,17,NULL,0,0,'',0,0,0,0,0),
(2776,0,-1,0,0,'Coastwood 10',80000,5,26,NULL,0,0,'',0,0,0,0,0),
(2777,0,-1,0,0,'Coastwood 5',50000,5,26,NULL,0,0,'',0,0,0,0,0),
(2778,0,-1,0,0,'Coastwood 6 (Shop)',80000,5,29,NULL,0,0,'',0,0,0,0,0),
(2779,0,-1,0,0,'Coastwood 7',25000,5,12,NULL,0,0,'',0,0,0,0,0),
(2780,0,-1,0,0,'Coastwood 8',50000,5,21,NULL,0,0,'',0,0,0,0,0),
(2781,0,-1,0,0,'Coastwood 9',50000,5,17,NULL,0,0,'',0,0,0,0,0),
(2782,0,-1,0,0,'Treetop 2',25000,5,13,NULL,0,0,'',0,0,0,0,0),
(2783,0,-1,0,0,'Treetop 1',25000,5,13,NULL,0,0,'',0,0,0,0,0),
(2784,0,-1,0,0,'Mangrove 3',80000,5,21,NULL,0,0,'',0,0,0,0,0),
(2785,0,-1,0,0,'Mangrove 2',50000,5,25,NULL,0,0,'',0,0,0,0,0),
(2786,0,-1,0,0,'The Hideout',250000,5,378,NULL,0,0,'',0,0,0,0,0),
(2787,0,-1,0,0,'Shadow Towers',250000,5,402,NULL,0,0,'',0,0,0,0,0),
(2788,0,-1,0,0,'Druids Retreat A',50000,6,31,NULL,0,0,'',0,0,0,0,0),
(2789,0,-1,0,0,'Druids Retreat C',50000,6,22,NULL,0,0,'',0,0,0,0,0),
(2790,0,-1,0,0,'Druids Retreat B',50000,6,29,NULL,0,0,'',0,0,0,0,0),
(2791,0,-1,0,0,'Druids Retreat D',80000,6,27,NULL,0,0,'',0,0,0,0,0),
(2792,0,-1,0,0,'East Lane 1b',150000,6,40,NULL,0,0,'',0,0,0,0,0),
(2793,0,-1,0,0,'East Lane 1a',200000,6,54,NULL,0,0,'',0,0,0,0,0),
(2794,0,-1,0,0,'Senja Village 11',80000,6,56,NULL,0,0,'',0,0,0,0,0),
(2795,0,-1,0,0,'Senja Village 10',50000,6,33,NULL,0,0,'',0,0,0,0,0),
(2796,0,-1,0,0,'Senja Village 9',80000,6,55,NULL,0,0,'',0,0,0,0,0),
(2797,0,-1,0,0,'Senja Village 8',50000,6,35,NULL,0,0,'',0,0,0,0,0),
(2798,0,-1,0,0,'Senja Village 7',25000,6,17,NULL,0,0,'',0,0,0,0,0),
(2799,0,-1,0,0,'Senja Village 6b',25000,6,17,NULL,0,0,'',0,0,0,0,0),
(2800,0,-1,0,0,'Senja Village 6a',50000,6,17,NULL,0,0,'',0,0,0,0,0),
(2801,0,-1,0,0,'Senja Village 5',50000,6,25,NULL,0,0,'',0,0,0,0,0),
(2802,0,-1,0,0,'Senja Village 4',50000,6,34,NULL,0,0,'',0,0,0,0,0),
(2803,0,-1,0,0,'Senja Village 3',50000,6,37,NULL,0,0,'',0,0,0,0,0),
(2804,0,-1,0,0,'Senja Village 1b',50000,6,34,NULL,0,0,'',0,0,0,0,0),
(2805,0,-1,0,0,'Senja Village 1a',25000,6,17,NULL,0,0,'',0,0,0,0,0),
(2806,0,-1,0,0,'Rosebud C',100000,6,31,NULL,0,0,'',0,0,0,0,0),
(2807,0,-1,0,0,'Rosebud B',80000,6,25,NULL,0,0,'',0,0,0,0,0),
(2808,0,-1,0,0,'Rosebud A',50000,6,25,NULL,0,0,'',0,0,0,0,0),
(2809,0,-1,0,0,'Park Lane 3b',100000,6,25,NULL,0,0,'',0,0,0,0,0),
(2810,0,-1,0,0,'Northport Village 6',80000,6,37,NULL,0,0,'',0,0,0,0,0),
(2811,0,-1,0,0,'Northport Village 5',80000,6,31,NULL,0,0,'',0,0,0,0,0),
(2812,0,-1,0,0,'Northport Village 4',100000,6,47,NULL,0,0,'',0,0,0,0,0),
(2813,0,-1,0,0,'Northport Village 3',150000,6,97,NULL,0,0,'',0,0,0,0,0),
(2814,0,-1,0,0,'Northport Village 2',50000,6,25,NULL,0,0,'',0,0,0,0,0),
(2815,0,-1,0,0,'Northport Village 1',50000,6,25,NULL,0,0,'',0,0,0,0,0),
(2816,0,-1,0,0,'Nautic Observer',200000,6,156,NULL,0,0,'',0,0,0,0,0),
(2817,0,-1,0,0,'Nordic Stronghold',250000,6,410,NULL,0,0,'',0,0,0,0,0),
(2818,0,-1,0,0,'Senja Clanhall',250000,6,215,NULL,0,0,'',0,0,0,0,0),
(2819,0,-1,0,0,'Seawatch',250000,6,422,NULL,0,0,'',0,0,0,0,0),
(2820,0,-1,0,0,'Dwarven Magnate\'s Estate',300000,7,248,NULL,0,0,'',0,0,0,0,0),
(2821,0,-1,0,0,'Forge Master\'s Quarters',300000,7,352,NULL,0,0,'',0,0,0,0,0),
(2822,0,-1,0,0,'Upper Barracks 13',25000,7,16,NULL,0,0,'',0,0,0,0,0),
(2823,0,-1,0,0,'Upper Barracks 5',80000,7,27,NULL,0,0,'',0,0,0,0,0),
(2824,0,-1,0,0,'Upper Barracks 3',80000,7,16,NULL,0,0,'',0,0,0,0,0),
(2825,0,-1,0,0,'Upper Barracks 4',50000,7,16,NULL,0,0,'',0,0,0,0,0),
(2826,0,-1,0,0,'Upper Barracks 2',80000,7,27,NULL,0,0,'',0,0,0,0,0),
(2827,0,-1,0,0,'Upper Barracks 1',50000,7,16,NULL,0,0,'',0,0,0,0,0),
(2828,0,-1,0,0,'Tunnel Gardens 9',150000,7,81,NULL,0,0,'',0,0,0,0,0),
(2829,0,-1,0,0,'Tunnel Gardens 8',25000,7,21,NULL,0,0,'',0,0,0,0,0),
(2830,0,-1,0,0,'Tunnel Gardens 7',50000,7,21,NULL,0,0,'',0,0,0,0,0),
(2831,0,-1,0,0,'Tunnel Gardens 6',25000,7,21,NULL,0,0,'',0,0,0,0,0),
(2832,0,-1,0,0,'Tunnel Gardens 5',25000,7,21,NULL,0,0,'',0,0,0,0,0),
(2835,0,-1,0,0,'Tunnel Gardens 4',80000,7,30,NULL,0,0,'',0,0,0,0,0),
(2836,0,-1,0,0,'Tunnel Gardens 2',80000,7,27,NULL,0,0,'',0,0,0,0,0),
(2837,0,-1,0,0,'Tunnel Gardens 1',80000,7,27,NULL,0,0,'',0,0,0,0,0),
(2838,0,-1,0,0,'Tunnel Gardens 3',80000,7,30,NULL,0,0,'',0,0,0,0,0),
(2839,0,-1,0,0,'The Market 4 (Shop)',80000,7,36,NULL,0,0,'',0,0,0,0,0),
(2840,0,-1,0,0,'The Market 3 (Shop)',80000,7,29,NULL,0,0,'',0,0,0,0,0),
(2841,0,-1,0,0,'The Market 2 (Shop)',50000,7,22,NULL,0,0,'',0,0,0,0,0),
(2842,0,-1,0,0,'The Market 1 (Shop)',25000,7,13,NULL,0,0,'',0,0,0,0,0),
(2843,0,-1,0,0,'The Farms 6, Fishing Hut',50000,7,21,NULL,0,0,'',0,0,0,0,0),
(2844,0,-1,0,0,'The Farms 5',50000,7,26,NULL,0,0,'',0,0,0,0,0),
(2845,0,-1,0,0,'The Farms 4',25000,7,26,NULL,0,0,'',0,0,0,0,0),
(2846,0,-1,0,0,'The Farms 3',80000,7,26,NULL,0,0,'',0,0,0,0,0),
(2847,0,-1,0,0,'The Farms 2',50000,7,26,NULL,0,0,'',0,0,0,0,0),
(2849,0,-1,0,0,'The Farms 1',80000,7,42,NULL,0,0,'',0,0,0,0,0),
(2850,0,-1,0,0,'Outlaw Camp 14 (Shop)',25000,7,16,NULL,0,0,'',0,0,0,0,0),
(2852,0,-1,0,0,'Outlaw Camp 13 (Shop)',50000,7,17,NULL,0,0,'',0,0,0,0,0),
(2853,0,-1,0,0,'Outlaw Camp 9',80000,7,17,NULL,0,0,'',0,0,0,0,0),
(2854,0,-1,0,0,'Outlaw Camp 7',25000,7,17,NULL,0,0,'',0,0,0,0,0),
(2855,0,-1,0,0,'Outlaw Camp 4',50000,7,17,NULL,0,0,'',0,0,0,0,0),
(2856,0,-1,0,0,'Outlaw Camp 2',50000,7,14,NULL,0,0,'',0,0,0,0,0),
(2857,0,-1,0,0,'Outlaw Camp 3',50000,7,16,NULL,0,0,'',0,0,0,0,0),
(2858,0,-1,0,0,'Outlaw Camp 1',80000,7,39,NULL,0,0,'',0,0,0,0,0),
(2859,0,-1,0,0,'Nobility Quarter 5',100000,7,79,NULL,0,0,'',0,0,0,0,0),
(2860,0,-1,0,0,'Nobility Quarter 4',50000,7,37,NULL,0,0,'',0,0,0,0,0),
(2861,0,-1,0,0,'Nobility Quarter 3',80000,7,37,NULL,0,0,'',0,0,0,0,0),
(2862,0,-1,0,0,'Nobility Quarter 2',50000,7,37,NULL,0,0,'',0,0,0,0,0),
(2863,0,-1,0,0,'Nobility Quarter 1',80000,7,37,NULL,0,0,'',0,0,0,0,0),
(2864,0,-1,0,0,'Lower Barracks 10',80000,7,25,NULL,0,0,'',0,0,0,0,0),
(2865,0,-1,0,0,'Lower Barracks 9',80000,7,25,NULL,0,0,'',0,0,0,0,0),
(2866,0,-1,0,0,'Lower Barracks 8',80000,7,25,NULL,0,0,'',0,0,0,0,0),
(2867,0,-1,0,0,'Lower Barracks 1',80000,7,25,NULL,0,0,'',0,0,0,0,0),
(2868,0,-1,0,0,'Lower Barracks 2',80000,7,25,NULL,0,0,'',0,0,0,0,0),
(2869,0,-1,0,0,'Lower Barracks 3',80000,7,25,NULL,0,0,'',0,0,0,0,0),
(2870,0,-1,0,0,'Lower Barracks 4',50000,7,26,NULL,0,0,'',0,0,0,0,0),
(2871,0,-1,0,0,'Lower Barracks 5',100000,7,58,NULL,0,0,'',0,0,0,0,0),
(2872,0,-1,0,0,'Lower Barracks 6',100000,7,58,NULL,0,0,'',0,0,0,0,0),
(2873,0,-1,0,0,'Lower Barracks 7',80000,7,26,NULL,0,0,'',0,0,0,0,0),
(2874,0,-1,0,0,'Wolftower',500000,7,387,NULL,0,0,'',0,0,0,0,0),
(2875,0,-1,0,0,'Riverspring',250000,7,353,NULL,0,0,'',0,0,0,0,0),
(2876,0,-1,0,0,'Outlaw Castle',250000,7,180,NULL,0,0,'',0,0,0,0,0),
(2877,0,-1,0,0,'Marble Guildhall',250000,7,338,NULL,0,0,'',0,0,0,0,0),
(2878,0,-1,0,0,'Iron Guildhall',250000,7,308,NULL,0,0,'',0,0,0,0,0),
(2879,0,-1,0,0,'Hill Hideout',250000,7,251,NULL,0,0,'',0,0,0,0,0),
(2880,0,-1,0,0,'Granite Guildhall',250000,7,361,NULL,0,0,'',0,0,0,0,0),
(2881,0,-1,0,0,'Alai Flats, Flat 01',50000,8,17,NULL,0,0,'',0,0,0,0,0),
(2882,0,-1,0,0,'Alai Flats, Flat 02',50000,8,17,NULL,0,0,'',0,0,0,0,0),
(2883,0,-1,0,0,'Alai Flats, Flat 03',50000,8,17,NULL,0,0,'',0,0,0,0,0),
(2884,0,-1,0,0,'Alai Flats, Flat 04',80000,8,17,NULL,0,0,'',0,0,0,0,0),
(2885,0,-1,0,0,'Alai Flats, Flat 05',100000,8,25,NULL,0,0,'',0,0,0,0,0),
(2886,0,-1,0,0,'Alai Flats, Flat 06',100000,8,25,NULL,0,0,'',0,0,0,0,0),
(2887,0,-1,0,0,'Alai Flats, Flat 07',25000,8,17,NULL,0,0,'',0,0,0,0,0),
(2888,0,-1,0,0,'Alai Flats, Flat 08',50000,8,17,NULL,0,0,'',0,0,0,0,0),
(2889,0,-1,0,0,'Alai Flats, Flat 11',80000,8,17,NULL,0,0,'',0,0,0,0,0),
(2890,0,-1,0,0,'Alai Flats, Flat 12',25000,8,17,NULL,0,0,'',0,0,0,0,0),
(2891,0,-1,0,0,'Alai Flats, Flat 13',50000,8,17,NULL,0,0,'',0,0,0,0,0),
(2892,0,-1,0,0,'Alai Flats, Flat 14',80000,8,20,NULL,0,0,'',0,0,0,0,0),
(2893,0,-1,0,0,'Alai Flats, Flat 15',100000,8,30,NULL,0,0,'',0,0,0,0,0),
(2894,0,-1,0,0,'Alai Flats, Flat 16',100000,8,30,NULL,0,0,'',0,0,0,0,0),
(2895,0,-1,0,0,'Alai Flats, Flat 17',80000,8,20,NULL,0,0,'',0,0,0,0,0),
(2896,0,-1,0,0,'Alai Flats, Flat 18',50000,8,20,NULL,0,0,'',0,0,0,0,0),
(2897,0,-1,0,0,'Alai Flats, Flat 21',50000,8,17,NULL,0,0,'',0,0,0,0,0),
(2898,0,-1,0,0,'Alai Flats, Flat 22',50000,8,17,NULL,0,0,'',0,0,0,0,0),
(2899,0,-1,0,0,'Alai Flats, Flat 23',25000,8,17,NULL,0,0,'',0,0,0,0,0),
(2900,0,-1,0,0,'Alai Flats, Flat 28',80000,8,20,NULL,0,0,'',0,0,0,0,0),
(2901,0,-1,0,0,'Alai Flats, Flat 27',80000,8,20,NULL,0,0,'',0,0,0,0,0),
(2902,0,-1,0,0,'Alai Flats, Flat 26',100000,8,30,NULL,0,0,'',0,0,0,0,0),
(2903,0,-1,0,0,'Alai Flats, Flat 25',100000,8,30,NULL,0,0,'',0,0,0,0,0),
(2904,0,-1,0,0,'Alai Flats, Flat 24',80000,8,20,NULL,0,0,'',0,0,0,0,0),
(2905,0,-1,0,0,'Beach Home Apartments, Flat 01',50000,8,13,NULL,0,0,'',0,0,0,0,0),
(2906,0,-1,0,0,'Beach Home Apartments, Flat 02',80000,8,13,NULL,0,0,'',0,0,0,0,0),
(2907,0,-1,0,0,'Beach Home Apartments, Flat 03',80000,8,13,NULL,0,0,'',0,0,0,0,0),
(2908,0,-1,0,0,'Beach Home Apartments, Flat 04',50000,8,13,NULL,0,0,'',0,0,0,0,0),
(2909,0,-1,0,0,'Beach Home Apartments, Flat 05',80000,8,13,NULL,0,0,'',0,0,0,0,0),
(2910,0,-1,0,0,'Beach Home Apartments, Flat 06',100000,8,19,NULL,0,0,'',0,0,0,0,0),
(2911,0,-1,0,0,'Beach Home Apartments, Flat 11',25000,8,13,NULL,0,0,'',0,0,0,0,0),
(2912,0,-1,0,0,'Beach Home Apartments, Flat 12',50000,8,16,NULL,0,0,'',0,0,0,0,0),
(2913,0,-1,0,0,'Beach Home Apartments, Flat 13',80000,8,16,NULL,0,0,'',0,0,0,0,0),
(2914,0,-1,0,0,'Beach Home Apartments, Flat 14',25000,8,7,NULL,0,0,'',0,0,0,0,0),
(2915,0,-1,0,0,'Beach Home Apartments, Flat 15',25000,8,7,NULL,0,0,'',0,0,0,0,0),
(2916,0,-1,0,0,'Beach Home Apartments, Flat 16',80000,8,19,NULL,0,0,'',0,0,0,0,0),
(2917,0,-1,0,0,'Demon Tower',100000,8,72,NULL,0,0,'',0,0,0,0,0),
(2918,0,-1,0,0,'Farm Lane, 1st floor (Shop)',80000,8,21,NULL,0,0,'',0,0,0,0,0),
(2919,0,-1,0,0,'Farm Lane, 2nd Floor (Shop)',50000,8,21,NULL,0,0,'',0,0,0,0,0),
(2920,0,-1,0,0,'Farm Lane, Basement (Shop)',50000,8,21,NULL,0,0,'',0,0,0,0,0),
(2921,0,-1,0,0,'Fibula Village 1',25000,8,13,NULL,0,0,'',0,0,0,0,0),
(2922,0,-1,0,0,'Fibula Village 2',25000,8,13,NULL,0,0,'',0,0,0,0,0),
(2923,0,-1,0,0,'Fibula Village 4',25000,8,26,NULL,0,0,'',0,0,0,0,0),
(2924,0,-1,0,0,'Fibula Village 5',50000,8,26,NULL,0,0,'',0,0,0,0,0),
(2925,0,-1,0,0,'Fibula Village 3',80000,8,54,NULL,0,0,'',0,0,0,0,0),
(2926,0,-1,0,0,'Fibula Village, Tower Flat',100000,8,78,NULL,0,0,'',0,0,0,0,0),
(2927,0,-1,0,0,'Guildhall of the Red Rose',250000,8,405,NULL,0,0,'',0,0,0,0,0),
(2928,0,-1,0,0,'Fibula Village, Bar (Shop)',100000,8,79,NULL,0,0,'',0,0,0,0,0),
(2929,0,-1,0,0,'Fibula Village, Villa',200000,8,222,NULL,0,0,'',0,0,0,0,0),
(2930,0,-1,0,0,'Greenshore Village 1',80000,8,37,NULL,0,0,'',0,0,0,0,0),
(2931,0,-1,0,0,'Greenshore Clanhall',250000,8,165,NULL,0,0,'',0,0,0,0,0),
(2932,0,-1,0,0,'Castle of Greenshore',250000,8,296,NULL,0,0,'',0,0,0,0,0),
(2933,0,-1,0,0,'Greenshore Village, Shop',80000,8,30,NULL,0,0,'',0,0,0,0,0),
(2934,0,-1,0,0,'Greenshore Village, Villa',300000,8,155,NULL,0,0,'',0,0,0,0,0),
(2935,0,-1,0,0,'Greenshore Village 7',25000,8,21,NULL,0,0,'',0,0,0,0,0),
(2936,0,-1,0,0,'Greenshore Village 3',50000,8,26,NULL,0,0,'',0,0,0,0,0),
(2939,0,-1,0,0,'Greenshore Village 2',50000,8,26,NULL,0,0,'',0,0,0,0,0),
(2940,0,-1,0,0,'Greenshore Village 6',150000,8,71,NULL,0,0,'',0,0,0,0,0),
(2941,0,-1,0,0,'Harbour Place 1 (Shop)',800000,8,22,NULL,0,0,'',0,0,0,0,0),
(2942,0,-1,0,0,'Harbour Place 2 (Shop)',600000,8,26,NULL,0,0,'',0,0,0,0,0),
(2943,0,-1,0,0,'Harbour Place 3',800000,8,87,NULL,0,0,'',0,0,0,0,0),
(2944,0,-1,0,0,'Harbour Place 4',80000,8,17,NULL,0,0,'',0,0,0,0,0),
(2945,0,-1,0,0,'Lower Swamp Lane 1',400000,8,74,NULL,0,0,'',0,0,0,0,0),
(2946,0,-1,0,0,'Lower Swamp Lane 3',400000,8,74,NULL,0,0,'',0,0,0,0,0),
(2947,0,-1,0,0,'Main Street 9, 1st floor (Shop)',200000,8,32,NULL,0,0,'',0,0,0,0,0),
(2948,0,-1,0,0,'Main Street 9a, 2nd floor (Shop)',100000,8,17,NULL,0,0,'',0,0,0,0,0),
(2949,0,-1,0,0,'Main Street 9b, 2nd floor (Shop)',150000,8,28,NULL,0,0,'',0,0,0,0,0),
(2950,0,-1,0,0,'Mill Avenue 1 (Shop)',200000,8,26,NULL,0,0,'',0,0,0,0,0),
(2951,0,-1,0,0,'Mill Avenue 2 (Shop)',200000,8,45,NULL,0,0,'',0,0,0,0,0),
(2952,0,-1,0,0,'Mill Avenue 3',100000,8,26,NULL,0,0,'',0,0,0,0,0),
(2953,0,-1,0,0,'Mill Avenue 4',100000,8,26,NULL,0,0,'',0,0,0,0,0),
(2954,0,-1,0,0,'Mill Avenue 5',300000,8,59,NULL,0,0,'',0,0,0,0,0),
(2955,0,-1,0,0,'Open-Air Theatre',150000,8,60,NULL,0,0,'',0,0,0,0,0),
(2956,0,-1,0,0,'Smuggler\'s Den',400000,8,219,NULL,0,0,'',0,0,0,0,0),
(2957,0,-1,0,0,'Sorcerer\'s Avenue 1a',100000,8,21,NULL,0,0,'',0,0,0,0,0),
(2958,0,-1,0,0,'Sorcerer\'s Avenue 5 (Shop)',150000,8,49,NULL,0,0,'',0,0,0,0,0),
(2959,0,-1,0,0,'Sorcerer\'s Avenue 1b',80000,8,17,NULL,0,0,'',0,0,0,0,0),
(2960,0,-1,0,0,'Sorcerer\'s Avenue 1c',100000,8,21,NULL,0,0,'',0,0,0,0,0),
(2961,0,-1,0,0,'Sorcerer\'s Avenue Labs 2a',50000,8,29,NULL,0,0,'',0,0,0,0,0),
(2962,0,-1,0,0,'Sorcerer\'s Avenue Labs 2c',50000,8,29,NULL,0,0,'',0,0,0,0,0),
(2963,0,-1,0,0,'Sorcerer\'s Avenue Labs 2b',50000,8,29,NULL,0,0,'',0,0,0,0,0),
(2964,0,-1,0,0,'Sunset Homes, Flat 01',100000,8,13,NULL,0,0,'',0,0,0,0,0),
(2965,0,-1,0,0,'Sunset Homes, Flat 02',80000,8,13,NULL,0,0,'',0,0,0,0,0),
(2966,0,-1,0,0,'Sunset Homes, Flat 03',80000,8,13,NULL,0,0,'',0,0,0,0,0),
(2967,0,-1,0,0,'Sunset Homes, Flat 11',80000,8,13,NULL,0,0,'',0,0,0,0,0),
(2968,0,-1,0,0,'Sunset Homes, Flat 12',50000,8,13,NULL,0,0,'',0,0,0,0,0),
(2969,0,-1,0,0,'Sunset Homes, Flat 13',100000,8,19,NULL,0,0,'',0,0,0,0,0),
(2970,0,-1,0,0,'Sunset Homes, Flat 14',50000,8,13,NULL,0,0,'',0,0,0,0,0),
(2971,0,-1,0,0,'Sunset Homes, Flat 21',50000,8,13,NULL,0,0,'',0,0,0,0,0),
(2972,0,-1,0,0,'Sunset Homes, Flat 22',50000,8,13,NULL,0,0,'',0,0,0,0,0),
(2973,0,-1,0,0,'Sunset Homes, Flat 23',80000,8,19,NULL,0,0,'',0,0,0,0,0),
(2974,0,-1,0,0,'Sunset Homes, Flat 24',50000,8,13,NULL,0,0,'',0,0,0,0,0),
(2975,0,-1,0,0,'Thais Hostel',200000,8,117,NULL,0,0,'',0,0,0,0,0),
(2976,0,-1,0,0,'The City Wall 1a',150000,8,26,NULL,0,0,'',0,0,0,0,0),
(2977,0,-1,0,0,'The City Wall 1b',100000,8,26,NULL,0,0,'',0,0,0,0,0),
(2978,0,-1,0,0,'The City Wall 3a',100000,8,21,NULL,0,0,'',0,0,0,0,0),
(2979,0,-1,0,0,'The City Wall 3b',100000,8,21,NULL,0,0,'',0,0,0,0,0),
(2980,0,-1,0,0,'The City Wall 3c',100000,8,21,NULL,0,0,'',0,0,0,0,0),
(2981,0,-1,0,0,'The City Wall 3d',100000,8,21,NULL,0,0,'',0,0,0,0,0),
(2982,0,-1,0,0,'The City Wall 3e',100000,8,21,NULL,0,0,'',0,0,0,0,0),
(2983,0,-1,0,0,'The City Wall 3f',100000,8,21,NULL,0,0,'',0,0,0,0,0),
(2984,0,-1,0,0,'Upper Swamp Lane 12',300000,8,60,NULL,0,0,'',0,0,0,0,0),
(2985,0,-1,0,0,'Upper Swamp Lane 10',150000,8,31,NULL,0,0,'',0,0,0,0,0),
(2986,0,-1,0,0,'Upper Swamp Lane 8',600000,8,132,NULL,0,0,'',0,0,0,0,0),
(2987,0,-1,0,0,'Upper Swamp Lane 4',600000,8,74,NULL,0,0,'',0,0,0,0,0),
(2988,0,-1,0,0,'Upper Swamp Lane 2',600000,8,74,NULL,0,0,'',0,0,0,0,0),
(2989,0,-1,0,0,'The City Wall 9',80000,8,19,NULL,0,0,'',0,0,0,0,0),
(2990,0,-1,0,0,'The City Wall 7h',50000,8,13,NULL,0,0,'',0,0,0,0,0),
(2991,0,-1,0,0,'The City Wall 7b',25000,8,13,NULL,0,0,'',0,0,0,0,0),
(2992,0,-1,0,0,'The City Wall 7d',50000,8,17,NULL,0,0,'',0,0,0,0,0),
(2993,0,-1,0,0,'The City Wall 7f',80000,8,17,NULL,0,0,'',0,0,0,0,0),
(2994,0,-1,0,0,'The City Wall 7c',80000,8,17,NULL,0,0,'',0,0,0,0,0),
(2995,0,-1,0,0,'The City Wall 7a',80000,8,13,NULL,0,0,'',0,0,0,0,0),
(2996,0,-1,0,0,'The City Wall 7g',50000,8,13,NULL,0,0,'',0,0,0,0,0),
(2997,0,-1,0,0,'The City Wall 7e',80000,8,17,NULL,0,0,'',0,0,0,0,0),
(2998,0,-1,0,0,'The City Wall 5b',50000,8,13,NULL,0,0,'',0,0,0,0,0),
(2999,0,-1,0,0,'The City Wall 5d',50000,8,13,NULL,0,0,'',0,0,0,0,0),
(3000,0,-1,0,0,'The City Wall 5f',25000,8,13,NULL,0,0,'',0,0,0,0,0),
(3001,0,-1,0,0,'The City Wall 5a',50000,8,13,NULL,0,0,'',0,0,0,0,0),
(3002,0,-1,0,0,'The City Wall 5c',50000,8,13,NULL,0,0,'',0,0,0,0,0),
(3003,0,-1,0,0,'The City Wall 5e',50000,8,13,NULL,0,0,'',0,0,0,0,0),
(3004,0,-1,0,0,'Warriors\' Guildhall',5000000,8,307,NULL,0,0,'',0,0,0,0,0),
(3005,0,-1,0,0,'The Tibianic',500000,8,540,NULL,0,0,'',0,0,0,0,0),
(3006,0,-1,0,0,'Bloodhall',500000,8,306,NULL,0,0,'',0,0,0,0,0),
(3007,0,-1,0,0,'Fibula Clanhall',250000,8,162,NULL,0,0,'',0,0,0,0,0),
(3008,0,-1,0,0,'Dark Mansion',1000000,8,361,NULL,0,0,'',0,0,0,0,0),
(3009,0,-1,0,0,'Halls of the Adventurers',250000,8,304,NULL,0,0,'',0,0,0,0,0),
(3010,0,-1,0,0,'Mercenary Tower',250000,8,607,NULL,0,0,'',0,0,0,0,0),
(3011,0,-1,0,0,'Snake Tower',500000,8,616,NULL,0,0,'',0,0,0,0,0),
(3012,0,-1,0,0,'Southern Thais Guildhall',1000000,8,349,NULL,0,0,'',0,0,0,0,0),
(3013,0,-1,0,0,'Spiritkeep',500000,8,382,NULL,0,0,'',0,0,0,0,0),
(3014,0,-1,0,0,'Thais Clanhall',500000,8,188,NULL,0,0,'',0,0,0,0,0),
(3015,0,-1,0,0,'The Lair',200000,9,166,NULL,0,0,'',0,0,0,0,0),
(3016,0,-1,0,0,'Silver Street 4',300000,9,71,NULL,0,0,'',0,0,0,0,0),
(3017,0,-1,0,0,'Dream Street 1 (Shop)',600000,9,94,NULL,0,0,'',0,0,0,0,0),
(3018,0,-1,0,0,'Dagger Alley 1',200000,9,57,NULL,0,0,'',0,0,0,0,0),
(3019,0,-1,0,0,'Dream Street 2',400000,9,72,NULL,0,0,'',0,0,0,0,0),
(3020,0,-1,0,0,'Dream Street 3',300000,9,58,NULL,0,0,'',0,0,0,0,0),
(3021,0,-1,0,0,'Elm Street 1',300000,9,58,NULL,0,0,'',0,0,0,0,0),
(3022,0,-1,0,0,'Elm Street 3',300000,9,59,NULL,0,0,'',0,0,0,0,0),
(3023,0,-1,0,0,'Elm Street 2',300000,9,57,NULL,0,0,'',0,0,0,0,0),
(3024,0,-1,0,0,'Elm Street 4',300000,9,56,NULL,0,0,'',0,0,0,0,0),
(3025,0,-1,0,0,'Seagull Walk 1',800000,9,111,NULL,0,0,'',0,0,0,0,0),
(3026,0,-1,0,0,'Seagull Walk 2',300000,9,57,NULL,0,0,'',0,0,0,0,0),
(3027,0,-1,0,0,'Dream Street 4',400000,9,77,NULL,0,0,'',0,0,0,0,0),
(3028,0,-1,0,0,'Old Lighthouse',200000,9,78,NULL,0,0,'',0,0,0,0,0),
(3029,0,-1,0,0,'Market Street 1',600000,9,144,NULL,0,0,'',0,0,0,0,0),
(3030,0,-1,0,0,'Market Street 3',600000,9,75,NULL,0,0,'',0,0,0,0,0),
(3031,0,-1,0,0,'Market Street 4 (Shop)',800000,9,109,NULL,0,0,'',0,0,0,0,0),
(3032,0,-1,0,0,'Market Street 5 (Shop)',800000,9,135,NULL,0,0,'',0,0,0,0,0),
(3033,0,-1,0,0,'Market Street 2',600000,9,105,NULL,0,0,'',0,0,0,0,0),
(3034,0,-1,0,0,'Loot Lane 1 (Shop)',600000,9,97,NULL,0,0,'',0,0,0,0,0),
(3035,0,-1,0,0,'Mystic Lane 1',300000,9,61,NULL,0,0,'',0,0,0,0,0),
(3036,0,-1,0,0,'Mystic Lane 2',200000,9,64,NULL,0,0,'',0,0,0,0,0),
(3037,0,-1,0,0,'Lucky Lane 2 (Tower)',600000,9,118,NULL,0,0,'',0,0,0,0,0),
(3038,0,-1,0,0,'Lucky Lane 3 (Tower)',600000,9,118,NULL,0,0,'',0,0,0,0,0),
(3039,0,-1,0,0,'Iron Alley 1',300000,9,70,NULL,0,0,'',0,0,0,0,0),
(3040,0,-1,0,0,'Iron Alley 2',300000,9,70,NULL,0,0,'',0,0,0,0,0),
(3041,0,-1,0,0,'Swamp Watch',500000,9,222,NULL,0,0,'',0,0,0,0,0),
(3042,0,-1,0,0,'Golden Axe Guildhall',500000,9,213,NULL,0,0,'',0,0,0,0,0),
(3043,0,-1,0,0,'Silver Street 1',200000,9,57,NULL,0,0,'',0,0,0,0,0),
(3044,0,-1,0,0,'Valorous Venore',500000,9,303,NULL,0,0,'',0,0,0,0,0),
(3045,0,-1,0,0,'Salvation Street 2',300000,9,82,NULL,0,0,'',0,0,0,0,0),
(3046,0,-1,0,0,'Salvation Street 3',300000,9,82,NULL,0,0,'',0,0,0,0,0),
(3047,0,-1,0,0,'Silver Street 2',200000,9,44,NULL,0,0,'',0,0,0,0,0),
(3048,0,-1,0,0,'Silver Street 3',200000,9,44,NULL,0,0,'',0,0,0,0,0),
(3049,0,-1,0,0,'Mystic Lane 3 (Tower)',800000,9,118,NULL,0,0,'',0,0,0,0,0),
(3050,0,-1,0,0,'Market Street 7',200000,9,49,NULL,0,0,'',0,0,0,0,0),
(3051,0,-1,0,0,'Market Street 6',600000,9,113,NULL,0,0,'',0,0,0,0,0),
(3052,0,-1,0,0,'Iron Alley Watch, Upper',600000,9,114,NULL,0,0,'',0,0,0,0,0),
(3053,0,-1,0,0,'Iron Alley Watch, Lower',600000,9,115,NULL,0,0,'',0,0,0,0,0),
(3054,0,-1,0,0,'Blessed Shield Guildhall',500000,9,162,NULL,0,0,'',0,0,0,0,0),
(3055,0,-1,0,0,'Steel Home',500000,9,281,NULL,0,0,'',0,0,0,0,0),
(3056,0,-1,0,0,'Salvation Street 1 (Shop)',600000,9,132,NULL,0,0,'',0,0,0,0,0),
(3057,0,-1,0,0,'Lucky Lane 1 (Shop)',800000,9,148,NULL,0,0,'',0,0,0,0,0),
(3058,0,-1,0,0,'Paupers Palace, Flat 34',100000,9,35,NULL,0,0,'',0,0,0,0,0),
(3059,0,-1,0,0,'Paupers Palace, Flat 33',50000,9,17,NULL,0,0,'',0,0,0,0,0),
(3060,0,-1,0,0,'Paupers Palace, Flat 32',100000,9,23,NULL,0,0,'',0,0,0,0,0),
(3061,0,-1,0,0,'Paupers Palace, Flat 31',80000,9,19,NULL,0,0,'',0,0,0,0,0),
(3062,0,-1,0,0,'Paupers Palace, Flat 28',25000,9,7,NULL,0,0,'',0,0,0,0,0),
(3063,0,-1,0,0,'Paupers Palace, Flat 26',25000,9,10,NULL,0,0,'',0,0,0,0,0),
(3064,0,-1,0,0,'Paupers Palace, Flat 24',25000,9,10,NULL,0,0,'',0,0,0,0,0),
(3065,0,-1,0,0,'Paupers Palace, Flat 22',25000,9,10,NULL,0,0,'',0,0,0,0,0),
(3066,0,-1,0,0,'Paupers Palace, Flat 21',25000,9,7,NULL,0,0,'',0,0,0,0,0),
(3067,0,-1,0,0,'Paupers Palace, Flat 27',50000,9,13,NULL,0,0,'',0,0,0,0,0),
(3068,0,-1,0,0,'Paupers Palace, Flat 25',50000,9,13,NULL,0,0,'',0,0,0,0,0),
(3069,0,-1,0,0,'Paupers Palace, Flat 23',50000,9,13,NULL,0,0,'',0,0,0,0,0),
(3070,0,-1,0,0,'Paupers Palace, Flat 11',25000,9,7,NULL,0,0,'',0,0,0,0,0),
(3071,0,-1,0,0,'Paupers Palace, Flat 13',50000,9,10,NULL,0,0,'',0,0,0,0,0),
(3072,0,-1,0,0,'Paupers Palace, Flat 15',50000,9,10,NULL,0,0,'',0,0,0,0,0),
(3073,0,-1,0,0,'Paupers Palace, Flat 17',25000,9,10,NULL,0,0,'',0,0,0,0,0),
(3074,0,-1,0,0,'Paupers Palace, Flat 18',25000,9,7,NULL,0,0,'',0,0,0,0,0),
(3075,0,-1,0,0,'Paupers Palace, Flat 12',50000,9,13,NULL,0,0,'',0,0,0,0,0),
(3076,0,-1,0,0,'Paupers Palace, Flat 14',50000,9,13,NULL,0,0,'',0,0,0,0,0),
(3077,0,-1,0,0,'Paupers Palace, Flat 16',50000,9,13,NULL,0,0,'',0,0,0,0,0),
(3078,0,-1,0,0,'Paupers Palace, Flat 06',25000,9,10,NULL,0,0,'',0,0,0,0,0),
(3079,0,-1,0,0,'Paupers Palace, Flat 05',25000,9,7,NULL,0,0,'',0,0,0,0,0),
(3080,0,-1,0,0,'Paupers Palace, Flat 04',25000,9,10,NULL,0,0,'',0,0,0,0,0),
(3081,0,-1,0,0,'Paupers Palace, Flat 07',50000,9,13,NULL,0,0,'',0,0,0,0,0),
(3082,0,-1,0,0,'Paupers Palace, Flat 03',25000,9,9,NULL,0,0,'',0,0,0,0,0),
(3083,0,-1,0,0,'Paupers Palace, Flat 02',25000,9,10,NULL,0,0,'',0,0,0,0,0),
(3084,0,-1,0,0,'Paupers Palace, Flat 01',25000,9,9,NULL,0,0,'',0,0,0,0,0),
(3085,0,-1,0,0,'Castle, Residence',600000,11,104,NULL,0,0,'',0,0,0,0,0),
(3086,0,-1,0,0,'Castle, 3rd Floor, Flat 07',80000,11,16,NULL,0,0,'',0,0,0,0,0),
(3087,0,-1,0,0,'Castle, 3rd Floor, Flat 04',25000,11,13,NULL,0,0,'',0,0,0,0,0),
(3088,0,-1,0,0,'Castle, 3rd Floor, Flat 03',50000,11,13,NULL,0,0,'',0,0,0,0,0),
(3089,0,-1,0,0,'Castle, 3rd Floor, Flat 06',100000,11,21,NULL,0,0,'',0,0,0,0,0),
(3090,0,-1,0,0,'Castle, 3rd Floor, Flat 05',80000,11,17,NULL,0,0,'',0,0,0,0,0),
(3091,0,-1,0,0,'Castle, 3rd Floor, Flat 02',80000,11,17,NULL,0,0,'',0,0,0,0,0),
(3092,0,-1,0,0,'Castle, 3rd Floor, Flat 01',50000,11,13,NULL,0,0,'',0,0,0,0,0),
(3093,0,-1,0,0,'Castle, 4th Floor, Flat 09',50000,11,16,NULL,0,0,'',0,0,0,0,0),
(3094,0,-1,0,0,'Castle, 4th Floor, Flat 08',80000,11,21,NULL,0,0,'',0,0,0,0,0),
(3095,0,-1,0,0,'Castle, 4th Floor, Flat 07',80000,11,16,NULL,0,0,'',0,0,0,0,0),
(3096,0,-1,0,0,'Castle, 4th Floor, Flat 04',50000,11,13,NULL,0,0,'',0,0,0,0,0),
(3097,0,-1,0,0,'Castle, 4th Floor, Flat 03',50000,11,13,NULL,0,0,'',0,0,0,0,0),
(3098,0,-1,0,0,'Castle, 4th Floor, Flat 06',100000,11,21,NULL,0,0,'',0,0,0,0,0),
(3099,0,-1,0,0,'Castle, 4th Floor, Flat 05',80000,11,17,NULL,0,0,'',0,0,0,0,0),
(3100,0,-1,0,0,'Castle, 4th Floor, Flat 02',80000,11,17,NULL,0,0,'',0,0,0,0,0),
(3101,0,-1,0,0,'Castle, 4th Floor, Flat 01',50000,11,13,NULL,0,0,'',0,0,0,0,0),
(3102,0,-1,0,0,'Castle Street 2',150000,11,31,NULL,0,0,'',0,0,0,0,0),
(3103,0,-1,0,0,'Castle Street 3',150000,11,37,NULL,0,0,'',0,0,0,0,0),
(3104,0,-1,0,0,'Castle Street 4',150000,11,37,NULL,0,0,'',0,0,0,0,0),
(3105,0,-1,0,0,'Castle Street 5',150000,11,37,NULL,0,0,'',0,0,0,0,0),
(3106,0,-1,0,0,'Castle Street 1',300000,11,60,NULL,0,0,'',0,0,0,0,0),
(3107,0,-1,0,0,'Edron Flats, Flat 08',25000,11,10,NULL,0,0,'',0,0,0,0,0),
(3108,0,-1,0,0,'Edron Flats, Flat 05',25000,11,10,NULL,0,0,'',0,0,0,0,0),
(3109,0,-1,0,0,'Edron Flats, Flat 04',25000,11,10,NULL,0,0,'',0,0,0,0,0),
(3110,0,-1,0,0,'Edron Flats, Flat 01',50000,11,10,NULL,0,0,'',0,0,0,0,0),
(3111,0,-1,0,0,'Edron Flats, Flat 07',25000,11,10,NULL,0,0,'',0,0,0,0,0),
(3112,0,-1,0,0,'Edron Flats, Flat 06',25000,11,10,NULL,0,0,'',0,0,0,0,0),
(3113,0,-1,0,0,'Edron Flats, Flat 03',25000,11,10,NULL,0,0,'',0,0,0,0,0),
(3114,0,-1,0,0,'Edron Flats, Flat 02',100000,11,19,NULL,0,0,'',0,0,0,0,0),
(3115,0,-1,0,0,'Edron Flats, Basement Flat 2',100000,11,36,NULL,0,0,'',0,0,0,0,0),
(3116,0,-1,0,0,'Edron Flats, Basement Flat 1',100000,11,36,NULL,0,0,'',0,0,0,0,0),
(3119,0,-1,0,0,'Edron Flats, Flat 13',80000,11,22,NULL,0,0,'',0,0,0,0,0),
(3121,0,-1,0,0,'Edron Flats, Flat 14',100000,11,29,NULL,0,0,'',0,0,0,0,0),
(3123,0,-1,0,0,'Edron Flats, Flat 12',80000,11,22,NULL,0,0,'',0,0,0,0,0),
(3124,0,-1,0,0,'Edron Flats, Flat 11',100000,11,29,NULL,0,0,'',0,0,0,0,0),
(3125,0,-1,0,0,'Edron Flats, Flat 25',80000,11,29,NULL,0,0,'',0,0,0,0,0),
(3127,0,-1,0,0,'Edron Flats, Flat 24',80000,11,22,NULL,0,0,'',0,0,0,0,0),
(3128,0,-1,0,0,'Edron Flats, Flat 21',80000,11,19,NULL,0,0,'',0,0,0,0,0),
(3131,0,-1,0,0,'Edron Flats, Flat 23',80000,11,22,NULL,0,0,'',0,0,0,0,0),
(3133,0,-1,0,0,'Castle Shop 1',400000,11,42,NULL,0,0,'',0,0,0,0,0),
(3134,0,-1,0,0,'Castle Shop 2',400000,11,42,NULL,0,0,'',0,0,0,0,0),
(3135,0,-1,0,0,'Castle Shop 3',300000,11,42,NULL,0,0,'',0,0,0,0,0),
(3136,0,-1,0,0,'Central Circle 1',800000,11,73,NULL,0,0,'',0,0,0,0,0),
(3137,0,-1,0,0,'Central Circle 2',800000,11,80,NULL,0,0,'',0,0,0,0,0),
(3138,0,-1,0,0,'Central Circle 3',800000,11,94,NULL,0,0,'',0,0,0,0,0),
(3139,0,-1,0,0,'Central Circle 4',800000,11,94,NULL,0,0,'',0,0,0,0,0),
(3140,0,-1,0,0,'Central Circle 5',800000,11,94,NULL,0,0,'',0,0,0,0,0),
(3141,0,-1,0,0,'Central Circle 8 (Shop)',400000,11,97,NULL,0,0,'',0,0,0,0,0),
(3142,0,-1,0,0,'Central Circle 7 (Shop)',400000,11,97,NULL,0,0,'',0,0,0,0,0),
(3143,0,-1,0,0,'Central Circle 6 (Shop)',400000,11,97,NULL,0,0,'',0,0,0,0,0),
(3144,0,-1,0,0,'Central Circle 9a',150000,11,21,NULL,0,0,'',0,0,0,0,0),
(3145,0,-1,0,0,'Central Circle 9b',150000,11,21,NULL,0,0,'',0,0,0,0,0),
(3146,0,-1,0,0,'Sky Lane, Guild 1',1000000,11,421,NULL,0,0,'',0,0,0,0,0),
(3147,0,-1,0,0,'Sky Lane, Sea Tower',300000,11,95,NULL,0,0,'',0,0,0,0,0),
(3148,0,-1,0,0,'Sky Lane, Guild 3',1000000,11,347,NULL,0,0,'',0,0,0,0,0),
(3149,0,-1,0,0,'Sky Lane, Guild 2',1000000,11,400,NULL,0,0,'',0,0,0,0,0),
(3150,0,-1,0,0,'Wood Avenue 11',600000,11,149,NULL,0,0,'',0,0,0,0,0),
(3151,0,-1,0,0,'Wood Avenue 8',800000,11,128,NULL,0,0,'',0,0,0,0,0),
(3152,0,-1,0,0,'Wood Avenue 7',800000,11,128,NULL,0,0,'',0,0,0,0,0),
(3153,0,-1,0,0,'Wood Avenue 10a',200000,11,32,NULL,0,0,'',0,0,0,0,0),
(3154,0,-1,0,0,'Wood Avenue 9a',200000,11,32,NULL,0,0,'',0,0,0,0,0),
(3155,0,-1,0,0,'Wood Avenue 6a',300000,11,30,NULL,0,0,'',0,0,0,0,0),
(3156,0,-1,0,0,'Wood Avenue 6b',200000,11,30,NULL,0,0,'',0,0,0,0,0),
(3157,0,-1,0,0,'Wood Avenue 9b',200000,11,31,NULL,0,0,'',0,0,0,0,0),
(3158,0,-1,0,0,'Wood Avenue 10b',200000,11,31,NULL,0,0,'',0,0,0,0,0),
(3159,0,-1,0,0,'Stronghold',800000,11,215,NULL,0,0,'',0,0,0,0,0),
(3160,0,-1,0,0,'Wood Avenue 5',300000,11,37,NULL,0,0,'',0,0,0,0,0),
(3161,0,-1,0,0,'Wood Avenue 3',200000,11,37,NULL,0,0,'',0,0,0,0,0),
(3162,0,-1,0,0,'Wood Avenue 4',200000,11,37,NULL,0,0,'',0,0,0,0,0),
(3163,0,-1,0,0,'Wood Avenue 2',200000,11,37,NULL,0,0,'',0,0,0,0,0),
(3164,0,-1,0,0,'Wood Avenue 1',200000,11,37,NULL,0,0,'',0,0,0,0,0),
(3165,0,-1,0,0,'Wood Avenue 4c',200000,11,37,NULL,0,0,'',0,0,0,0,0),
(3166,0,-1,0,0,'Wood Avenue 4a',150000,11,31,NULL,0,0,'',0,0,0,0,0),
(3167,0,-1,0,0,'Wood Avenue 4b',150000,11,31,NULL,0,0,'',0,0,0,0,0),
(3168,0,-1,0,0,'Stonehome Village 1',150000,11,42,NULL,0,0,'',0,0,0,0,0),
(3169,0,-1,0,0,'Stonehome Flats, Flat 04',80000,11,22,NULL,0,0,'',0,0,0,0,0),
(3171,0,-1,0,0,'Stonehome Flats, Flat 03',80000,11,22,NULL,0,0,'',0,0,0,0,0),
(3173,0,-1,0,0,'Stonehome Flats, Flat 02',25000,11,16,NULL,0,0,'',0,0,0,0,0),
(3174,0,-1,0,0,'Stonehome Flats, Flat 01',25000,11,10,NULL,0,0,'',0,0,0,0,0),
(3175,0,-1,0,0,'Stonehome Flats, Flat 13',80000,11,22,NULL,0,0,'',0,0,0,0,0),
(3177,0,-1,0,0,'Stonehome Flats, Flat 11',50000,11,16,NULL,0,0,'',0,0,0,0,0),
(3178,0,-1,0,0,'Stonehome Flats, Flat 14',80000,11,22,NULL,0,0,'',0,0,0,0,0),
(3180,0,-1,0,0,'Stonehome Flats, Flat 12',50000,11,16,NULL,0,0,'',0,0,0,0,0),
(3181,0,-1,0,0,'Stonehome Village 2',50000,11,16,NULL,0,0,'',0,0,0,0,0),
(3182,0,-1,0,0,'Stonehome Village 3',50000,11,17,NULL,0,0,'',0,0,0,0,0),
(3183,0,-1,0,0,'Stonehome Village 4',80000,11,21,NULL,0,0,'',0,0,0,0,0),
(3184,0,-1,0,0,'Stonehome Village 6',100000,11,30,NULL,0,0,'',0,0,0,0,0),
(3185,0,-1,0,0,'Stonehome Village 5',80000,11,26,NULL,0,0,'',0,0,0,0,0),
(3186,0,-1,0,0,'Stonehome Village 7',100000,11,26,NULL,0,0,'',0,0,0,0,0),
(3187,0,-1,0,0,'Stonehome Village 8',25000,11,17,NULL,0,0,'',0,0,0,0,0),
(3188,0,-1,0,0,'Stonehome Village 9',50000,11,17,NULL,0,0,'',0,0,0,0,0),
(3189,0,-1,0,0,'Stonehome Clanhall',250000,11,192,NULL,0,0,'',0,0,0,0,0),
(3190,0,-1,0,0,'Mad Scientist\'s Lab',600000,17,169,NULL,0,0,'',0,0,0,0,0),
(3191,0,-1,0,0,'Radiant Plaza 4',800000,17,186,NULL,0,0,'',0,0,0,0,0),
(3192,0,-1,0,0,'Radiant Plaza 3',800000,17,120,NULL,0,0,'',0,0,0,0,0),
(3193,0,-1,0,0,'Radiant Plaza 2',600000,17,93,NULL,0,0,'',0,0,0,0,0),
(3194,0,-1,0,0,'Radiant Plaza 1',800000,17,133,NULL,0,0,'',0,0,0,0,0),
(3195,0,-1,0,0,'Aureate Court 3',400000,17,105,NULL,0,0,'',0,0,0,0,0),
(3196,0,-1,0,0,'Aureate Court 4',400000,17,92,NULL,0,0,'',0,0,0,0,0),
(3197,0,-1,0,0,'Aureate Court 5',600000,17,142,NULL,0,0,'',0,0,0,0,0),
(3198,0,-1,0,0,'Aureate Court 2',400000,17,119,NULL,0,0,'',0,0,0,0,0),
(3199,0,-1,0,0,'Aureate Court 1',600000,17,126,NULL,0,0,'',0,0,0,0,0),
(3205,0,-1,0,0,'Halls of Serenity',5000000,17,504,NULL,0,0,'',0,0,0,0,0),
(3206,0,-1,0,0,'Fortune Wing 3',600000,17,141,NULL,0,0,'',0,0,0,0,0),
(3207,0,-1,0,0,'Fortune Wing 4',600000,17,141,NULL,0,0,'',0,0,0,0,0),
(3208,0,-1,0,0,'Fortune Wing 2',600000,17,137,NULL,0,0,'',0,0,0,0,0),
(3209,0,-1,0,0,'Fortune Wing 1',800000,17,247,NULL,0,0,'',0,0,0,0,0),
(3211,0,-1,0,0,'Cascade Towers',5000000,17,405,NULL,0,0,'',0,0,0,0,0),
(3212,0,-1,0,0,'Luminous Arc 5',800000,17,117,NULL,0,0,'',0,0,0,0,0),
(3213,0,-1,0,0,'Luminous Arc 2',600000,17,154,NULL,0,0,'',0,0,0,0,0),
(3214,0,-1,0,0,'Luminous Arc 1',800000,17,159,NULL,0,0,'',0,0,0,0,0),
(3215,0,-1,0,0,'Luminous Arc 3',600000,17,130,NULL,0,0,'',0,0,0,0,0),
(3216,0,-1,0,0,'Luminous Arc 4',800000,17,190,NULL,0,0,'',0,0,0,0,0),
(3217,0,-1,0,0,'Harbour Promenade 1',800000,17,129,NULL,0,0,'',0,0,0,0,0),
(3218,0,-1,0,0,'Sun Palace',5000000,17,513,NULL,0,0,'',0,0,0,0,0),
(3219,0,-1,0,0,'Haggler\'s Hangout 3',300000,15,145,NULL,0,0,'',0,0,0,0,0),
(3220,0,-1,0,0,'Haggler\'s Hangout 7',400000,15,141,NULL,0,0,'',0,0,0,0,0),
(3221,0,-1,0,0,'Big Game Hunter\'s Lodge',600000,15,164,NULL,0,0,'',0,0,0,0,0),
(3222,0,-1,0,0,'Haggler\'s Hangout 6',400000,15,123,NULL,0,0,'',0,0,0,0,0),
(3223,0,-1,0,0,'Haggler\'s Hangout 5 (Shop)',200000,15,31,NULL,0,0,'',0,0,0,0,0),
(3224,0,-1,0,0,'Haggler\'s Hangout 4b (Shop)',150000,15,31,NULL,0,0,'',0,0,0,0,0),
(3225,0,-1,0,0,'Haggler\'s Hangout 4a (Shop)',200000,15,37,NULL,0,0,'',0,0,0,0,0),
(3226,0,-1,0,0,'Haggler\'s Hangout 2',100000,15,26,NULL,0,0,'',0,0,0,0,0),
(3227,0,-1,0,0,'Haggler\'s Hangout 1',100000,15,26,NULL,0,0,'',0,0,0,0,0),
(3228,0,-1,0,0,'Bamboo Garden 3',150000,15,32,NULL,0,0,'',0,0,0,0,0),
(3229,0,-1,0,0,'Bamboo Fortress',500000,15,446,NULL,0,0,'',0,0,0,0,0),
(3230,0,-1,0,0,'Bamboo Garden 2',80000,15,21,NULL,0,0,'',0,0,0,0,0),
(3231,0,-1,0,0,'Bamboo Garden 1',100000,15,32,NULL,0,0,'',0,0,0,0,0),
(3232,0,-1,0,0,'Banana Bay 4',25000,15,10,NULL,0,0,'',0,0,0,0,0),
(3233,0,-1,0,0,'Banana Bay 2',50000,15,17,NULL,0,0,'',0,0,0,0,0),
(3234,0,-1,0,0,'Banana Bay 3',50000,15,10,NULL,0,0,'',0,0,0,0,0),
(3235,0,-1,0,0,'Banana Bay 1',25000,15,10,NULL,0,0,'',0,0,0,0,0),
(3236,0,-1,0,0,'Crocodile Bridge 1',80000,15,21,NULL,0,0,'',0,0,0,0,0),
(3237,0,-1,0,0,'Crocodile Bridge 2',80000,15,17,NULL,0,0,'',0,0,0,0,0),
(3238,0,-1,0,0,'Crocodile Bridge 3',100000,15,26,NULL,0,0,'',0,0,0,0,0),
(3239,0,-1,0,0,'Crocodile Bridge 4',300000,15,99,NULL,0,0,'',0,0,0,0,0),
(3240,0,-1,0,0,'Crocodile Bridge 5',200000,15,86,NULL,0,0,'',0,0,0,0,0),
(3241,0,-1,0,0,'Woodway 1',80000,15,17,NULL,0,0,'',0,0,0,0,0),
(3242,0,-1,0,0,'Woodway 2',50000,15,13,NULL,0,0,'',0,0,0,0,0),
(3243,0,-1,0,0,'Woodway 3',150000,15,32,NULL,0,0,'',0,0,0,0,0),
(3244,0,-1,0,0,'Woodway 4',25000,15,9,NULL,0,0,'',0,0,0,0,0),
(3245,0,-1,0,0,'Flamingo Flats 5',150000,15,41,NULL,0,0,'',0,0,0,0,0),
(3246,0,-1,0,0,'Flamingo Flats 4',80000,15,17,NULL,0,0,'',0,0,0,0,0),
(3247,0,-1,0,0,'Flamingo Flats 1',50000,15,13,NULL,0,0,'',0,0,0,0,0),
(3248,0,-1,0,0,'Flamingo Flats 2',80000,15,21,NULL,0,0,'',0,0,0,0,0),
(3249,0,-1,0,0,'Flamingo Flats 3',50000,15,13,NULL,0,0,'',0,0,0,0,0),
(3250,0,-1,0,0,'Jungle Edge 1',200000,15,51,NULL,0,0,'',0,0,0,0,0),
(3251,0,-1,0,0,'Jungle Edge 2',200000,15,66,NULL,0,0,'',0,0,0,0,0),
(3252,0,-1,0,0,'Jungle Edge 4',80000,15,17,NULL,0,0,'',0,0,0,0,0),
(3253,0,-1,0,0,'Jungle Edge 5',80000,15,17,NULL,0,0,'',0,0,0,0,0),
(3254,0,-1,0,0,'Jungle Edge 6',25000,15,10,NULL,0,0,'',0,0,0,0,0),
(3255,0,-1,0,0,'Jungle Edge 3',80000,15,17,NULL,0,0,'',0,0,0,0,0),
(3256,0,-1,0,0,'River Homes 3',200000,15,99,NULL,0,0,'',0,0,0,0,0),
(3257,0,-1,0,0,'River Homes 2b',150000,15,31,NULL,0,0,'',0,0,0,0,0),
(3258,0,-1,0,0,'River Homes 2a',100000,15,26,NULL,0,0,'',0,0,0,0,0),
(3259,0,-1,0,0,'River Homes 1',300000,15,73,NULL,0,0,'',0,0,0,0,0),
(3260,0,-1,0,0,'Coconut Quay 4',150000,15,43,NULL,0,0,'',0,0,0,0,0),
(3261,0,-1,0,0,'Coconut Quay 3',200000,15,41,NULL,0,0,'',0,0,0,0,0),
(3262,0,-1,0,0,'Coconut Quay 2',100000,15,21,NULL,0,0,'',0,0,0,0,0),
(3263,0,-1,0,0,'Coconut Quay 1',150000,15,37,NULL,0,0,'',0,0,0,0,0),
(3264,0,-1,0,0,'Shark Manor',250000,15,164,NULL,0,0,'',0,0,0,0,0),
(3265,0,-1,0,0,'Glacier Side 2',300000,16,91,NULL,0,0,'',0,0,0,0,0),
(3266,0,-1,0,0,'Glacier Side 1',150000,16,30,NULL,0,0,'',0,0,0,0,0),
(3267,0,-1,0,0,'Glacier Side 3',150000,16,37,NULL,0,0,'',0,0,0,0,0),
(3268,0,-1,0,0,'Glacier Side 4',150000,16,41,NULL,0,0,'',0,0,0,0,0),
(3269,0,-1,0,0,'Shelf Site',300000,16,92,NULL,0,0,'',0,0,0,0,0),
(3270,0,-1,0,0,'Spirit Homes 5',150000,16,27,NULL,0,0,'',0,0,0,0,0),
(3271,0,-1,0,0,'Spirit Homes 4',80000,16,22,NULL,0,0,'',0,0,0,0,0),
(3272,0,-1,0,0,'Spirit Homes 1',150000,16,32,NULL,0,0,'',0,0,0,0,0),
(3273,0,-1,0,0,'Spirit Homes 2',150000,16,36,NULL,0,0,'',0,0,0,0,0),
(3274,0,-1,0,0,'Spirit Homes 3',300000,16,81,NULL,0,0,'',0,0,0,0,0),
(3275,0,-1,0,0,'Arena Walk 3',300000,16,67,NULL,0,0,'',0,0,0,0,0),
(3276,0,-1,0,0,'Arena Walk 2',150000,16,26,NULL,0,0,'',0,0,0,0,0),
(3277,0,-1,0,0,'Arena Walk 1',300000,16,61,NULL,0,0,'',0,0,0,0,0),
(3278,0,-1,0,0,'Bears Paw 2',300000,16,49,NULL,0,0,'',0,0,0,0,0),
(3279,0,-1,0,0,'Bears Paw 1',200000,16,38,NULL,0,0,'',0,0,0,0,0),
(3280,0,-1,0,0,'Crystal Glance',1000000,16,315,NULL,0,0,'',0,0,0,0,0),
(3281,0,-1,0,0,'Shady Rocks 2',200000,16,38,NULL,0,0,'',0,0,0,0,0),
(3282,0,-1,0,0,'Shady Rocks 1',300000,16,74,NULL,0,0,'',0,0,0,0,0),
(3283,0,-1,0,0,'Shady Rocks 3',300000,16,87,NULL,0,0,'',0,0,0,0,0),
(3284,0,-1,0,0,'Shady Rocks 4 (Shop)',200000,16,58,NULL,0,0,'',0,0,0,0,0),
(3285,0,-1,0,0,'Shady Rocks 5',300000,16,62,NULL,0,0,'',0,0,0,0,0),
(3286,0,-1,0,0,'Tusk Flats 2',80000,16,21,NULL,0,0,'',0,0,0,0,0),
(3287,0,-1,0,0,'Tusk Flats 1',80000,16,19,NULL,0,0,'',0,0,0,0,0),
(3288,0,-1,0,0,'Tusk Flats 3',80000,16,16,NULL,0,0,'',0,0,0,0,0),
(3289,0,-1,0,0,'Tusk Flats 4',25000,16,9,NULL,0,0,'',0,0,0,0,0),
(3290,0,-1,0,0,'Tusk Flats 6',50000,16,16,NULL,0,0,'',0,0,0,0,0),
(3291,0,-1,0,0,'Tusk Flats 5',25000,16,13,NULL,0,0,'',0,0,0,0,0),
(3292,0,-1,0,0,'Corner Shop (Shop)',200000,16,47,NULL,0,0,'',0,0,0,0,0),
(3293,0,-1,0,0,'Bears Paw 5',200000,16,41,NULL,0,0,'',0,0,0,0,0),
(3294,0,-1,0,0,'Bears Paw 4',400000,16,109,NULL,0,0,'',0,0,0,0,0),
(3295,0,-1,0,0,'Trout Plaza 2',150000,16,32,NULL,0,0,'',0,0,0,0,0),
(3296,0,-1,0,0,'Trout Plaza 1',200000,16,51,NULL,0,0,'',0,0,0,0,0),
(3297,0,-1,0,0,'Trout Plaza 5 (Shop)',300000,16,84,NULL,0,0,'',0,0,0,0,0),
(3298,0,-1,0,0,'Trout Plaza 3',80000,16,20,NULL,0,0,'',0,0,0,0,0),
(3299,0,-1,0,0,'Trout Plaza 4',80000,16,20,NULL,0,0,'',0,0,0,0,0),
(3300,0,-1,0,0,'Skiffs End 2',80000,16,18,NULL,0,0,'',0,0,0,0,0),
(3301,0,-1,0,0,'Skiffs End 1',100000,16,32,NULL,0,0,'',0,0,0,0,0),
(3302,0,-1,0,0,'Furrier Quarter 3',100000,16,26,NULL,0,0,'',0,0,0,0,0),
(3303,0,-1,0,0,'Fimbul Shelf 4',100000,16,27,NULL,0,0,'',0,0,0,0,0),
(3304,0,-1,0,0,'Fimbul Shelf 3',100000,16,33,NULL,0,0,'',0,0,0,0,0),
(3305,0,-1,0,0,'Furrier Quarter 2',80000,16,27,NULL,0,0,'',0,0,0,0,0),
(3306,0,-1,0,0,'Furrier Quarter 1',150000,16,41,NULL,0,0,'',0,0,0,0,0),
(3307,0,-1,0,0,'Fimbul Shelf 2',100000,16,27,NULL,0,0,'',0,0,0,0,0),
(3308,0,-1,0,0,'Fimbul Shelf 1',80000,16,25,NULL,0,0,'',0,0,0,0,0),
(3309,0,-1,0,0,'Bears Paw 3',200000,16,42,NULL,0,0,'',0,0,0,0,0),
(3310,0,-1,0,0,'Raven Corner 2',150000,16,33,NULL,0,0,'',0,0,0,0,0),
(3311,0,-1,0,0,'Raven Corner 1',80000,16,19,NULL,0,0,'',0,0,0,0,0),
(3312,0,-1,0,0,'Raven Corner 3',100000,16,19,NULL,0,0,'',0,0,0,0,0),
(3313,0,-1,0,0,'Mammoth Belly',1000000,16,362,NULL,0,0,'',0,0,0,0,0),
(3314,0,-1,0,0,'Darashia 3, Flat 01',150000,13,25,NULL,0,0,'',0,0,0,0,0),
(3315,0,-1,0,0,'Darashia 3, Flat 05',150000,13,25,NULL,0,0,'',0,0,0,0,0),
(3316,0,-1,0,0,'Darashia 3, Flat 02',200000,13,38,NULL,0,0,'',0,0,0,0,0),
(3317,0,-1,0,0,'Darashia 3, Flat 04',150000,13,38,NULL,0,0,'',0,0,0,0,0),
(3318,0,-1,0,0,'Darashia 3, Flat 03',150000,13,25,NULL,0,0,'',0,0,0,0,0),
(3319,0,-1,0,0,'Darashia 3, Flat 12',200000,13,55,NULL,0,0,'',0,0,0,0,0),
(3320,0,-1,0,0,'Darashia 3, Flat 11',100000,13,25,NULL,0,0,'',0,0,0,0,0),
(3321,0,-1,0,0,'Darashia 3, Flat 14',200000,13,55,NULL,0,0,'',0,0,0,0,0),
(3322,0,-1,0,0,'Darashia 3, Flat 13',100000,13,25,NULL,0,0,'',0,0,0,0,0),
(3323,0,-1,0,0,'Darashia 8, Flat 01',300000,13,53,NULL,0,0,'',0,0,0,0,0),
(3325,0,-1,0,0,'Darashia 8, Flat 05',300000,13,57,NULL,0,0,'',0,0,0,0,0),
(3326,0,-1,0,0,'Darashia 8, Flat 04',200000,13,61,NULL,0,0,'',0,0,0,0,0),
(3327,0,-1,0,0,'Darashia 8, Flat 03',300000,13,100,NULL,0,0,'',0,0,0,0,0),
(3328,0,-1,0,0,'Darashia 8, Flat 12',150000,13,38,NULL,0,0,'',0,0,0,0,0),
(3329,0,-1,0,0,'Darashia 8, Flat 11',200000,13,42,NULL,0,0,'',0,0,0,0,0),
(3330,0,-1,0,0,'Darashia 8, Flat 14',150000,13,38,NULL,0,0,'',0,0,0,0,0),
(3331,0,-1,0,0,'Darashia 8, Flat 13',150000,13,42,NULL,0,0,'',0,0,0,0,0),
(3332,0,-1,0,0,'Darashia, Villa',800000,13,113,NULL,0,0,'',0,0,0,0,0),
(3333,0,-1,0,0,'Darashia, Eastern Guildhall',1000000,13,248,NULL,0,0,'',0,0,0,0,0),
(3334,0,-1,0,0,'Darashia, Western Guildhall',500000,13,203,NULL,0,0,'',0,0,0,0,0),
(3335,0,-1,0,0,'Darashia 2, Flat 03',100000,13,29,NULL,0,0,'',0,0,0,0,0),
(3336,0,-1,0,0,'Darashia 2, Flat 02',100000,13,25,NULL,0,0,'',0,0,0,0,0),
(3337,0,-1,0,0,'Darashia 2, Flat 01',150000,13,25,NULL,0,0,'',0,0,0,0,0),
(3338,0,-1,0,0,'Darashia 2, Flat 04',80000,13,13,NULL,0,0,'',0,0,0,0,0),
(3339,0,-1,0,0,'Darashia 2, Flat 05',150000,13,29,NULL,0,0,'',0,0,0,0,0),
(3340,0,-1,0,0,'Darashia 2, Flat 06',80000,13,13,NULL,0,0,'',0,0,0,0,0),
(3341,0,-1,0,0,'Darashia 2, Flat 07',150000,13,25,NULL,0,0,'',0,0,0,0,0),
(3342,0,-1,0,0,'Darashia 2, Flat 13',100000,13,29,NULL,0,0,'',0,0,0,0,0),
(3343,0,-1,0,0,'Darashia 2, Flat 14',50000,13,13,NULL,0,0,'',0,0,0,0,0),
(3344,0,-1,0,0,'Darashia 2, Flat 15',100000,13,29,NULL,0,0,'',0,0,0,0,0),
(3345,0,-1,0,0,'Darashia 2, Flat 16',80000,13,17,NULL,0,0,'',0,0,0,0,0),
(3346,0,-1,0,0,'Darashia 2, Flat 17',100000,13,25,NULL,0,0,'',0,0,0,0,0),
(3347,0,-1,0,0,'Darashia 2, Flat 18',100000,13,17,NULL,0,0,'',0,0,0,0,0),
(3348,0,-1,0,0,'Darashia 2, Flat 11',100000,13,25,NULL,0,0,'',0,0,0,0,0),
(3349,0,-1,0,0,'Darashia 2, Flat 12',80000,13,13,NULL,0,0,'',0,0,0,0,0),
(3350,0,-1,0,0,'Darashia 1, Flat 03',300000,13,59,NULL,0,0,'',0,0,0,0,0),
(3351,0,-1,0,0,'Darashia 1, Flat 04',100000,13,25,NULL,0,0,'',0,0,0,0,0),
(3352,0,-1,0,0,'Darashia 1, Flat 02',100000,13,25,NULL,0,0,'',0,0,0,0,0),
(3353,0,-1,0,0,'Darashia 1, Flat 01',100000,13,25,NULL,0,0,'',0,0,0,0,0),
(3354,0,-1,0,0,'Darashia 1, Flat 05',100000,13,25,NULL,0,0,'',0,0,0,0,0),
(3355,0,-1,0,0,'Darashia 1, Flat 12',150000,13,42,NULL,0,0,'',0,0,0,0,0),
(3356,0,-1,0,0,'Darashia 1, Flat 13',150000,13,42,NULL,0,0,'',0,0,0,0,0),
(3357,0,-1,0,0,'Darashia 1, Flat 14',200000,13,59,NULL,0,0,'',0,0,0,0,0),
(3358,0,-1,0,0,'Darashia 1, Flat 11',100000,13,25,NULL,0,0,'',0,0,0,0,0),
(3359,0,-1,0,0,'Darashia 5, Flat 02',150000,13,38,NULL,0,0,'',0,0,0,0,0),
(3360,0,-1,0,0,'Darashia 5, Flat 01',150000,13,25,NULL,0,0,'',0,0,0,0,0),
(3361,0,-1,0,0,'Darashia 5, Flat 05',100000,13,25,NULL,0,0,'',0,0,0,0,0),
(3362,0,-1,0,0,'Darashia 5, Flat 04',150000,13,38,NULL,0,0,'',0,0,0,0,0),
(3363,0,-1,0,0,'Darashia 5, Flat 03',150000,13,25,NULL,0,0,'',0,0,0,0,0),
(3364,0,-1,0,0,'Darashia 5, Flat 11',150000,13,42,NULL,0,0,'',0,0,0,0,0),
(3365,0,-1,0,0,'Darashia 5, Flat 12',150000,13,38,NULL,0,0,'',0,0,0,0,0),
(3366,0,-1,0,0,'Darashia 5, Flat 13',150000,13,42,NULL,0,0,'',0,0,0,0,0),
(3367,0,-1,0,0,'Darashia 5, Flat 14',150000,13,38,NULL,0,0,'',0,0,0,0,0),
(3368,0,-1,0,0,'Darashia 6a',300000,13,67,NULL,0,0,'',0,0,0,0,0),
(3369,0,-1,0,0,'Darashia 6b',300000,13,74,NULL,0,0,'',0,0,0,0,0),
(3370,0,-1,0,0,'Darashia 4, Flat 02',200000,13,42,NULL,0,0,'',0,0,0,0,0),
(3371,0,-1,0,0,'Darashia 4, Flat 03',150000,13,25,NULL,0,0,'',0,0,0,0,0),
(3372,0,-1,0,0,'Darashia 4, Flat 04',200000,13,42,NULL,0,0,'',0,0,0,0,0),
(3373,0,-1,0,0,'Darashia 4, Flat 05',150000,13,25,NULL,0,0,'',0,0,0,0,0),
(3374,0,-1,0,0,'Darashia 4, Flat 01',100000,13,25,NULL,0,0,'',0,0,0,0,0),
(3375,0,-1,0,0,'Darashia 4, Flat 12',200000,13,59,NULL,0,0,'',0,0,0,0,0),
(3376,0,-1,0,0,'Darashia 4, Flat 11',100000,13,25,NULL,0,0,'',0,0,0,0,0),
(3377,0,-1,0,0,'Darashia 4, Flat 13',200000,13,42,NULL,0,0,'',0,0,0,0,0),
(3378,0,-1,0,0,'Darashia 4, Flat 14',150000,13,42,NULL,0,0,'',0,0,0,0,0),
(3379,0,-1,0,0,'Darashia 7, Flat 01',100000,13,25,NULL,0,0,'',0,0,0,0,0),
(3380,0,-1,0,0,'Darashia 7, Flat 02',100000,13,25,NULL,0,0,'',0,0,0,0,0),
(3381,0,-1,0,0,'Darashia 7, Flat 03',200000,13,59,NULL,0,0,'',0,0,0,0,0),
(3382,0,-1,0,0,'Darashia 7, Flat 05',150000,13,25,NULL,0,0,'',0,0,0,0,0),
(3383,0,-1,0,0,'Darashia 7, Flat 04',150000,13,25,NULL,0,0,'',0,0,0,0,0),
(3384,0,-1,0,0,'Darashia 7, Flat 12',200000,13,59,NULL,0,0,'',0,0,0,0,0),
(3385,0,-1,0,0,'Darashia 7, Flat 11',100000,13,25,NULL,0,0,'',0,0,0,0,0),
(3386,0,-1,0,0,'Darashia 7, Flat 14',200000,13,59,NULL,0,0,'',0,0,0,0,0),
(3387,0,-1,0,0,'Darashia 7, Flat 13',100000,13,25,NULL,0,0,'',0,0,0,0,0),
(3388,0,-1,0,0,'Pirate Shipwreck 1',800000,13,147,NULL,0,0,'',0,0,0,0,0),
(3389,0,-1,0,0,'Pirate Shipwreck 2',800000,13,177,NULL,0,0,'',0,0,0,0,0),
(3390,0,-1,0,0,'The Shelter',250000,14,353,NULL,0,0,'',0,0,0,0,0),
(3391,0,-1,0,0,'Litter Promenade 1',25000,14,10,NULL,0,0,'',0,0,0,0,0),
(3392,0,-1,0,0,'Litter Promenade 2',50000,14,10,NULL,0,0,'',0,0,0,0,0),
(3394,0,-1,0,0,'Litter Promenade 3',25000,14,15,NULL,0,0,'',0,0,0,0,0),
(3395,0,-1,0,0,'Litter Promenade 4',25000,14,13,NULL,0,0,'',0,0,0,0,0),
(3396,0,-1,0,0,'Rum Alley 3',25000,14,11,NULL,0,0,'',0,0,0,0,0),
(3397,0,-1,0,0,'Straycat\'s Corner 5',80000,14,22,NULL,0,0,'',0,0,0,0,0),
(3398,0,-1,0,0,'Straycat\'s Corner 6',25000,14,10,NULL,0,0,'',0,0,0,0,0),
(3399,0,-1,0,0,'Litter Promenade 5',25000,14,16,NULL,0,0,'',0,0,0,0,0),
(3401,0,-1,0,0,'Straycat\'s Corner 4',50000,14,17,NULL,0,0,'',0,0,0,0,0),
(3402,0,-1,0,0,'Straycat\'s Corner 2',50000,14,22,NULL,0,0,'',0,0,0,0,0),
(3403,0,-1,0,0,'Straycat\'s Corner 1',25000,14,10,NULL,0,0,'',0,0,0,0,0),
(3404,0,-1,0,0,'Rum Alley 2',25000,14,10,NULL,0,0,'',0,0,0,0,0),
(3405,0,-1,0,0,'Rum Alley 1',25000,14,17,NULL,0,0,'',0,0,0,0,0),
(3406,0,-1,0,0,'Smuggler Backyard 3',50000,14,20,NULL,0,0,'',0,0,0,0,0),
(3407,0,-1,0,0,'Shady Trail 3',25000,14,10,NULL,0,0,'',0,0,0,0,0),
(3408,0,-1,0,0,'Shady Trail 1',100000,14,25,NULL,0,0,'',0,0,0,0,0),
(3409,0,-1,0,0,'Shady Trail 2',25000,14,13,NULL,0,0,'',0,0,0,0,0),
(3410,0,-1,0,0,'Smuggler Backyard 4',25000,14,13,NULL,0,0,'',0,0,0,0,0),
(3411,0,-1,0,0,'Smuggler Backyard 2',25000,14,19,NULL,0,0,'',0,0,0,0,0),
(3412,0,-1,0,0,'Smuggler Backyard 1',25000,14,19,NULL,0,0,'',0,0,0,0,0),
(3413,0,-1,0,0,'Smuggler Backyard 5',25000,14,17,NULL,0,0,'',0,0,0,0,0),
(3414,0,-1,0,0,'Sugar Street 1',200000,14,56,NULL,0,0,'',0,0,0,0,0),
(3415,0,-1,0,0,'Sugar Street 2',150000,14,47,NULL,0,0,'',0,0,0,0,0),
(3416,0,-1,0,0,'Sugar Street 3a',100000,14,29,NULL,0,0,'',0,0,0,0,0),
(3417,0,-1,0,0,'Sugar Street 3b',150000,14,37,NULL,0,0,'',0,0,0,0,0),
(3418,0,-1,0,0,'Sugar Street 4d',50000,14,13,NULL,0,0,'',0,0,0,0,0),
(3419,0,-1,0,0,'Sugar Street 4c',25000,14,13,NULL,0,0,'',0,0,0,0,0),
(3420,0,-1,0,0,'Sugar Street 4b',100000,14,17,NULL,0,0,'',0,0,0,0,0),
(3421,0,-1,0,0,'Sugar Street 4a',80000,14,17,NULL,0,0,'',0,0,0,0,0),
(3422,0,-1,0,0,'Harvester\'s Haven, Flat 01',50000,14,17,NULL,0,0,'',0,0,0,0,0),
(3423,0,-1,0,0,'Harvester\'s Haven, Flat 03',50000,14,17,NULL,0,0,'',0,0,0,0,0),
(3424,0,-1,0,0,'Harvester\'s Haven, Flat 05',50000,14,17,NULL,0,0,'',0,0,0,0,0),
(3425,0,-1,0,0,'Harvester\'s Haven, Flat 06',50000,14,17,NULL,0,0,'',0,0,0,0,0),
(3426,0,-1,0,0,'Harvester\'s Haven, Flat 04',50000,14,17,NULL,0,0,'',0,0,0,0,0),
(3427,0,-1,0,0,'Harvester\'s Haven, Flat 02',50000,14,17,NULL,0,0,'',0,0,0,0,0),
(3428,0,-1,0,0,'Harvester\'s Haven, Flat 07',80000,14,17,NULL,0,0,'',0,0,0,0,0),
(3429,0,-1,0,0,'Harvester\'s Haven, Flat 09',50000,14,17,NULL,0,0,'',0,0,0,0,0),
(3430,0,-1,0,0,'Harvester\'s Haven, Flat 11',25000,14,17,NULL,0,0,'',0,0,0,0,0),
(3431,0,-1,0,0,'Harvester\'s Haven, Flat 08',50000,14,17,NULL,0,0,'',0,0,0,0,0),
(3432,0,-1,0,0,'Harvester\'s Haven, Flat 10',50000,14,17,NULL,0,0,'',0,0,0,0,0),
(3433,0,-1,0,0,'Harvester\'s Haven, Flat 12',25000,14,17,NULL,0,0,'',0,0,0,0,0),
(3434,0,-1,0,0,'Marble Lane 3',600000,14,141,NULL,0,0,'',0,0,0,0,0),
(3435,0,-1,0,0,'Marble Lane 2',400000,14,113,NULL,0,0,'',0,0,0,0,0),
(3436,0,-1,0,0,'Marble Lane 4',400000,14,110,NULL,0,0,'',0,0,0,0,0),
(3437,0,-1,0,0,'Admiral\'s Avenue 1',400000,14,91,NULL,0,0,'',0,0,0,0,0),
(3438,0,-1,0,0,'Admiral\'s Avenue 2',400000,14,94,NULL,0,0,'',0,0,0,0,0),
(3439,0,-1,0,0,'Admiral\'s Avenue 3',300000,14,73,NULL,0,0,'',0,0,0,0,0),
(3440,0,-1,0,0,'Ivory Circle 1',400000,14,76,NULL,0,0,'',0,0,0,0,0),
(3441,0,-1,0,0,'Sugar Street 5',150000,14,25,NULL,0,0,'',0,0,0,0,0),
(3442,0,-1,0,0,'Freedom Street 1',200000,14,47,NULL,0,0,'',0,0,0,0,0),
(3443,0,-1,0,0,'Trader\'s Point 1',200000,14,42,NULL,0,0,'',0,0,0,0,0),
(3444,0,-1,0,0,'Trader\'s Point 2 (Shop)',600000,14,105,NULL,0,0,'',0,0,0,0,0),
(3445,0,-1,0,0,'Trader\'s Point 3 (Shop)',600000,14,117,NULL,0,0,'',0,0,0,0,0),
(3446,0,-1,0,0,'Ivory Mansion',800000,14,265,NULL,0,0,'',0,0,0,0,0),
(3447,0,-1,0,0,'Ivory Circle 2',400000,14,126,NULL,0,0,'',0,0,0,0,0),
(3448,0,-1,0,0,'Ivy Cottage',500000,14,563,NULL,0,0,'',0,0,0,0,0),
(3449,0,-1,0,0,'Marble Lane 1',600000,14,192,NULL,0,0,'',0,0,0,0,0),
(3450,0,-1,0,0,'Freedom Street 2',400000,14,115,NULL,0,0,'',0,0,0,0,0),
(3452,0,-1,0,0,'Meriana Beach',150000,14,146,NULL,0,0,'',0,0,0,0,0),
(3453,0,-1,0,0,'The Tavern 1a',150000,14,49,NULL,0,0,'',0,0,0,0,0),
(3454,0,-1,0,0,'The Tavern 1b',100000,14,36,NULL,0,0,'',0,0,0,0,0),
(3455,0,-1,0,0,'The Tavern 1c',200000,14,79,NULL,0,0,'',0,0,0,0,0),
(3456,0,-1,0,0,'The Tavern 1d',100000,14,29,NULL,0,0,'',0,0,0,0,0),
(3457,0,-1,0,0,'The Tavern 2a',300000,14,103,NULL,0,0,'',0,0,0,0,0),
(3458,0,-1,0,0,'The Tavern 2b',100000,14,32,NULL,0,0,'',0,0,0,0,0),
(3459,0,-1,0,0,'The Tavern 2d',100000,14,25,NULL,0,0,'',0,0,0,0,0),
(3460,0,-1,0,0,'The Tavern 2c',50000,14,19,NULL,0,0,'',0,0,0,0,0),
(3461,0,-1,0,0,'The Yeah Beach Project',150000,14,115,NULL,0,0,'',0,0,0,0,0),
(3462,0,-1,0,0,'Mountain Hideout',500000,14,279,NULL,0,0,'',0,0,0,0,0),
(3463,0,-1,0,0,'Darashia 8, Flat 02',300000,13,73,NULL,0,0,'',0,0,0,0,0),
(3464,0,-1,0,0,'Castle, Basement, Flat 01',50000,11,13,NULL,0,0,'',0,0,0,0,0),
(3465,0,-1,0,0,'Castle, Basement, Flat 02',50000,11,13,NULL,0,0,'',0,0,0,0,0),
(3466,0,-1,0,0,'Castle, Basement, Flat 03',50000,11,13,NULL,0,0,'',0,0,0,0,0),
(3467,0,-1,0,0,'Castle, Basement, Flat 05',50000,11,13,NULL,0,0,'',0,0,0,0,0),
(3468,0,-1,0,0,'Castle, Basement, Flat 04',50000,11,13,NULL,0,0,'',0,0,0,0,0),
(3469,0,-1,0,0,'Castle, Basement, Flat 06',50000,11,13,NULL,0,0,'',0,0,0,0,0),
(3470,0,-1,0,0,'Castle, Basement, Flat 07',50000,11,13,NULL,0,0,'',0,0,0,0,0),
(3471,0,-1,0,0,'Castle, Basement, Flat 09',25000,11,13,NULL,0,0,'',0,0,0,0,0),
(3472,0,-1,0,0,'Castle, Basement, Flat 08',50000,11,13,NULL,0,0,'',0,0,0,0,0),
(3473,0,-1,0,0,'Cormaya 1',150000,11,26,NULL,0,0,'',0,0,0,0,0),
(3474,0,-1,0,0,'Cormaya Flats, Flat 01',25000,11,10,NULL,0,0,'',0,0,0,0,0),
(3475,0,-1,0,0,'Cormaya Flats, Flat 02',25000,11,10,NULL,0,0,'',0,0,0,0,0),
(3476,0,-1,0,0,'Cormaya Flats, Flat 03',50000,11,16,NULL,0,0,'',0,0,0,0,0),
(3477,0,-1,0,0,'Cormaya Flats, Flat 06',25000,11,10,NULL,0,0,'',0,0,0,0,0),
(3478,0,-1,0,0,'Cormaya Flats, Flat 05',25000,11,10,NULL,0,0,'',0,0,0,0,0),
(3479,0,-1,0,0,'Cormaya Flats, Flat 04',50000,11,16,NULL,0,0,'',0,0,0,0,0),
(3480,0,-1,0,0,'Cormaya Flats, Flat 11',100000,11,22,NULL,0,0,'',0,0,0,0,0),
(3482,0,-1,0,0,'Cormaya Flats, Flat 13',25000,11,16,NULL,0,0,'',0,0,0,0,0),
(3483,0,-1,0,0,'Cormaya Flats, Flat 12',100000,11,22,NULL,0,0,'',0,0,0,0,0),
(3485,0,-1,0,0,'Cormaya Flats, Flat 14',25000,11,16,NULL,0,0,'',0,0,0,0,0),
(3486,0,-1,0,0,'Cormaya 2',300000,11,78,NULL,0,0,'',0,0,0,0,0),
(3487,0,-1,0,0,'Cormaya 4',150000,11,36,NULL,0,0,'',0,0,0,0,0),
(3488,0,-1,0,0,'Cormaya 3',200000,11,43,NULL,0,0,'',0,0,0,0,0),
(3489,0,-1,0,0,'Cormaya 6',200000,11,51,NULL,0,0,'',0,0,0,0,0),
(3490,0,-1,0,0,'Cormaya 7',200000,11,51,NULL,0,0,'',0,0,0,0,0),
(3491,0,-1,0,0,'Cormaya 8',200000,11,58,NULL,0,0,'',0,0,0,0,0),
(3492,0,-1,0,0,'Cormaya 5',300000,11,115,NULL,0,0,'',0,0,0,0,0),
(3493,0,-1,0,0,'Castle of the White Dragon',1000000,11,518,NULL,0,0,'',0,0,0,0,0),
(3494,0,-1,0,0,'Cormaya 9b',150000,11,56,NULL,0,0,'',0,0,0,0,0),
(3495,0,-1,0,0,'Cormaya 9a',80000,11,25,NULL,0,0,'',0,0,0,0,0),
(3496,0,-1,0,0,'Cormaya 9d',150000,11,56,NULL,0,0,'',0,0,0,0,0),
(3497,0,-1,0,0,'Cormaya 9c',80000,11,25,NULL,0,0,'',0,0,0,0,0),
(3498,0,-1,0,0,'Cormaya 10',300000,11,80,NULL,0,0,'',0,0,0,0,0),
(3499,0,-1,0,0,'Cormaya 11',150000,11,43,NULL,0,0,'',0,0,0,0,0),
(3500,0,-1,0,0,'Edron Flats, Flat 22',50000,11,10,NULL,0,0,'',0,0,0,0,0),
(3501,0,-1,0,0,'Magic Academy, Shop',150000,11,29,NULL,0,0,'',0,0,0,0,0),
(3502,0,-1,0,0,'Magic Academy, Flat 1',100000,11,23,NULL,0,0,'',0,0,0,0,0),
(3503,0,-1,0,0,'Magic Academy, Guild',500000,11,195,NULL,0,0,'',0,0,0,0,0),
(3504,0,-1,0,0,'Magic Academy, Flat 2',80000,11,26,NULL,0,0,'',0,0,0,0,0),
(3505,0,-1,0,0,'Magic Academy, Flat 3',100000,11,26,NULL,0,0,'',0,0,0,0,0),
(3506,0,-1,0,0,'Magic Academy, Flat 4',100000,11,26,NULL,0,0,'',0,0,0,0,0),
(3507,0,-1,0,0,'Magic Academy, Flat 5',80000,11,26,NULL,0,0,'',0,0,0,0,0),
(3508,0,-1,0,0,'Oskahl I f',100000,10,21,NULL,0,0,'',0,0,0,0,0),
(3509,0,-1,0,0,'Oskahl I g',100000,10,26,NULL,0,0,'',0,0,0,0,0),
(3510,0,-1,0,0,'Oskahl I h',150000,10,39,NULL,0,0,'',0,0,0,0,0),
(3511,0,-1,0,0,'Oskahl I i',80000,10,21,NULL,0,0,'',0,0,0,0,0),
(3512,0,-1,0,0,'Oskahl I j',80000,10,17,NULL,0,0,'',0,0,0,0,0),
(3513,0,-1,0,0,'Oskahl I b',80000,10,21,NULL,0,0,'',0,0,0,0,0),
(3514,0,-1,0,0,'Oskahl I d',100000,10,26,NULL,0,0,'',0,0,0,0,0),
(3515,0,-1,0,0,'Oskahl I e',80000,10,21,NULL,0,0,'',0,0,0,0,0),
(3516,0,-1,0,0,'Oskahl I c',80000,10,17,NULL,0,0,'',0,0,0,0,0),
(3517,0,-1,0,0,'Chameken I',100000,10,17,NULL,0,0,'',0,0,0,0,0),
(3518,0,-1,0,0,'Chameken II',80000,10,17,NULL,0,0,'',0,0,0,0,0),
(3519,0,-1,0,0,'Charsirakh III',50000,10,17,NULL,0,0,'',0,0,0,0,0),
(3520,0,-1,0,0,'Charsirakh II',100000,10,26,NULL,0,0,'',0,0,0,0,0),
(3521,0,-1,0,0,'Murkhol I a',80000,10,23,NULL,0,0,'',0,0,0,0,0),
(3523,0,-1,0,0,'Murkhol I c',50000,10,11,NULL,0,0,'',0,0,0,0,0),
(3524,0,-1,0,0,'Murkhol I b',50000,10,11,NULL,0,0,'',0,0,0,0,0),
(3525,0,-1,0,0,'Charsirakh I b',150000,10,37,NULL,0,0,'',0,0,0,0,0),
(3526,0,-1,0,0,'Harrah I',250000,10,121,NULL,0,0,'',0,0,0,0,0),
(3527,0,-1,0,0,'Thanah I d',200000,10,52,NULL,0,0,'',0,0,0,0,0),
(3528,0,-1,0,0,'Thanah I c',200000,10,61,NULL,0,0,'',0,0,0,0,0),
(3529,0,-1,0,0,'Thanah I b',150000,10,56,NULL,0,0,'',0,0,0,0,0),
(3530,0,-1,0,0,'Thanah I a',25000,10,17,NULL,0,0,'',0,0,0,0,0),
(3531,0,-1,0,0,'Othehothep I c',150000,10,38,NULL,0,0,'',0,0,0,0,0),
(3532,0,-1,0,0,'Othehothep I d',150000,10,43,NULL,0,0,'',0,0,0,0,0),
(3533,0,-1,0,0,'Othehothep I b',100000,10,32,NULL,0,0,'',0,0,0,0,0),
(3534,0,-1,0,0,'Othehothep II c',80000,10,21,NULL,0,0,'',0,0,0,0,0),
(3535,0,-1,0,0,'Othehothep II d',80000,10,21,NULL,0,0,'',0,0,0,0,0),
(3536,0,-1,0,0,'Othehothep II e',150000,10,31,NULL,0,0,'',0,0,0,0,0),
(3537,0,-1,0,0,'Othehothep II f',100000,10,31,NULL,0,0,'',0,0,0,0,0),
(3538,0,-1,0,0,'Othehothep II b',150000,10,43,NULL,0,0,'',0,0,0,0,0),
(3539,0,-1,0,0,'Othehothep II a',25000,10,10,NULL,0,0,'',0,0,0,0,0),
(3540,0,-1,0,0,'Mothrem I',80000,10,26,NULL,0,0,'',0,0,0,0,0),
(3541,0,-1,0,0,'Arakmehn I',100000,10,28,NULL,0,0,'',0,0,0,0,0),
(3542,0,-1,0,0,'Arakmehn II',80000,10,26,NULL,0,0,'',0,0,0,0,0),
(3543,0,-1,0,0,'Arakmehn III',100000,10,26,NULL,0,0,'',0,0,0,0,0),
(3544,0,-1,0,0,'Arakmehn IV',100000,10,28,NULL,0,0,'',0,0,0,0,0),
(3545,0,-1,0,0,'Unklath II b',50000,10,17,NULL,0,0,'',0,0,0,0,0),
(3546,0,-1,0,0,'Unklath II c',50000,10,17,NULL,0,0,'',0,0,0,0,0),
(3547,0,-1,0,0,'Unklath II d',100000,10,37,NULL,0,0,'',0,0,0,0,0),
(3548,0,-1,0,0,'Unklath II a',50000,10,26,NULL,0,0,'',0,0,0,0,0),
(3549,0,-1,0,0,'Rathal I b',50000,10,17,NULL,0,0,'',0,0,0,0,0),
(3550,0,-1,0,0,'Rathal I c',25000,10,17,NULL,0,0,'',0,0,0,0,0),
(3551,0,-1,0,0,'Rathal I d',50000,10,17,NULL,0,0,'',0,0,0,0,0),
(3552,0,-1,0,0,'Rathal I e',50000,10,17,NULL,0,0,'',0,0,0,0,0),
(3553,0,-1,0,0,'Rathal I a',80000,10,26,NULL,0,0,'',0,0,0,0,0),
(3554,0,-1,0,0,'Rathal II b',50000,10,17,NULL,0,0,'',0,0,0,0,0),
(3555,0,-1,0,0,'Rathal II c',50000,10,17,NULL,0,0,'',0,0,0,0,0),
(3556,0,-1,0,0,'Rathal II d',100000,10,34,NULL,0,0,'',0,0,0,0,0),
(3557,0,-1,0,0,'Rathal II a',80000,10,26,NULL,0,0,'',0,0,0,0,0),
(3558,0,-1,0,0,'Esuph I',50000,10,17,NULL,0,0,'',0,0,0,0,0),
(3559,0,-1,0,0,'Esuph II b',100000,10,32,NULL,0,0,'',0,0,0,0,0),
(3560,0,-1,0,0,'Esuph II a',25000,10,7,NULL,0,0,'',0,0,0,0,0),
(3561,0,-1,0,0,'Esuph III b',100000,10,31,NULL,0,0,'',0,0,0,0,0),
(3562,0,-1,0,0,'Esuph III a',25000,10,7,NULL,0,0,'',0,0,0,0,0),
(3564,0,-1,0,0,'Esuph IV c',80000,10,23,NULL,0,0,'',0,0,0,0,0),
(3565,0,-1,0,0,'Esuph IV d',25000,10,20,NULL,0,0,'',0,0,0,0,0),
(3566,0,-1,0,0,'Esuph IV a',25000,10,10,NULL,0,0,'',0,0,0,0,0),
(3567,0,-1,0,0,'Horakhal',250000,10,203,NULL,0,0,'',0,0,0,0,0),
(3568,0,-1,0,0,'Botham II d',100000,10,37,NULL,0,0,'',0,0,0,0,0),
(3569,0,-1,0,0,'Botham II e',100000,10,31,NULL,0,0,'',0,0,0,0,0),
(3570,0,-1,0,0,'Botham II f',80000,10,31,NULL,0,0,'',0,0,0,0,0),
(3571,0,-1,0,0,'Botham II g',80000,10,26,NULL,0,0,'',0,0,0,0,0),
(3572,0,-1,0,0,'Botham II c',100000,10,23,NULL,0,0,'',0,0,0,0,0),
(3573,0,-1,0,0,'Botham II b',100000,10,30,NULL,0,0,'',0,0,0,0,0),
(3574,0,-1,0,0,'Botham II a',25000,10,17,NULL,0,0,'',0,0,0,0,0),
(3575,0,-1,0,0,'Botham III f',150000,10,43,NULL,0,0,'',0,0,0,0,0),
(3576,0,-1,0,0,'Botham III h',200000,10,71,NULL,0,0,'',0,0,0,0,0),
(3577,0,-1,0,0,'Botham III g',100000,10,31,NULL,0,0,'',0,0,0,0,0),
(3578,0,-1,0,0,'Botham III b',50000,10,17,NULL,0,0,'',0,0,0,0,0),
(3579,0,-1,0,0,'Botham III c',25000,10,17,NULL,0,0,'',0,0,0,0,0),
(3581,0,-1,0,0,'Botham III e',100000,10,38,NULL,0,0,'',0,0,0,0,0),
(3582,0,-1,0,0,'Botham III a',80000,10,26,NULL,0,0,'',0,0,0,0,0),
(3583,0,-1,0,0,'Botham IV f',100000,10,32,NULL,0,0,'',0,0,0,0,0),
(3584,0,-1,0,0,'Botham IV h',100000,10,37,NULL,0,0,'',0,0,0,0,0),
(3585,0,-1,0,0,'Botham IV i',150000,10,32,NULL,0,0,'',0,0,0,0,0),
(3586,0,-1,0,0,'Botham IV g',100000,10,31,NULL,0,0,'',0,0,0,0,0),
(3587,0,-1,0,0,'Botham IV e',100000,10,84,NULL,0,0,'',0,0,0,0,0),
(3591,0,-1,0,0,'Botham IV a',100000,10,26,NULL,0,0,'',0,0,0,0,0),
(3592,0,-1,0,0,'Ramen Tah',250000,10,124,NULL,0,0,'',0,0,0,0,0),
(3593,0,-1,0,0,'Botham I c',150000,10,32,NULL,0,0,'',0,0,0,0,0),
(3594,0,-1,0,0,'Botham I e',80000,10,31,NULL,0,0,'',0,0,0,0,0),
(3595,0,-1,0,0,'Botham I d',150000,10,57,NULL,0,0,'',0,0,0,0,0),
(3596,0,-1,0,0,'Botham I b',150000,10,56,NULL,0,0,'',0,0,0,0,0),
(3597,0,-1,0,0,'Botham I a',50000,10,19,NULL,0,0,'',0,0,0,0,0),
(3598,0,-1,0,0,'Charsirakh I a',25000,10,7,NULL,0,0,'',0,0,0,0,0),
(3599,0,-1,0,0,'Low Waters Observatory',400000,10,480,NULL,0,0,'',0,0,0,0,0),
(3600,0,-1,0,0,'Oskahl I a',150000,10,37,NULL,0,0,'',0,0,0,0,0),
(3601,0,-1,0,0,'Othehothep I a',25000,10,7,NULL,0,0,'',0,0,0,0,0),
(3602,0,-1,0,0,'Othehothep III a',25000,10,7,NULL,0,0,'',0,0,0,0,0),
(3603,0,-1,0,0,'Othehothep III b',80000,10,31,NULL,0,0,'',0,0,0,0,0),
(3604,0,-1,0,0,'Othehothep III c',80000,10,21,NULL,0,0,'',0,0,0,0,0),
(3605,0,-1,0,0,'Othehothep III d',80000,10,26,NULL,0,0,'',0,0,0,0,0),
(3606,0,-1,0,0,'Othehothep III e',50000,10,21,NULL,0,0,'',0,0,0,0,0),
(3607,0,-1,0,0,'Othehothep III f',50000,10,17,NULL,0,0,'',0,0,0,0,0),
(3608,0,-1,0,0,'Unklath I f',100000,10,37,NULL,0,0,'',0,0,0,0,0),
(3609,0,-1,0,0,'Unklath I g',100000,10,37,NULL,0,0,'',0,0,0,0,0),
(3610,0,-1,0,0,'Unklath I d',150000,10,37,NULL,0,0,'',0,0,0,0,0),
(3611,0,-1,0,0,'Unklath I e',150000,10,37,NULL,0,0,'',0,0,0,0,0),
(3612,0,-1,0,0,'Unklath I b',100000,10,34,NULL,0,0,'',0,0,0,0,0),
(3613,0,-1,0,0,'Unklath I c',100000,10,34,NULL,0,0,'',0,0,0,0,0),
(3614,0,-1,0,0,'Unklath I a',100000,10,26,NULL,0,0,'',0,0,0,0,0),
(3615,0,-1,0,0,'Thanah II a',25000,10,17,NULL,0,0,'',0,0,0,0,0),
(3616,0,-1,0,0,'Thanah II b',50000,10,9,NULL,0,0,'',0,0,0,0,0),
(3617,0,-1,0,0,'Thanah II d',50000,10,7,NULL,0,0,'',0,0,0,0,0),
(3618,0,-1,0,0,'Thanah II e',25000,10,7,NULL,0,0,'',0,0,0,0,0),
(3619,0,-1,0,0,'Thanah II c',25000,10,9,NULL,0,0,'',0,0,0,0,0),
(3620,0,-1,0,0,'Thanah II f',150000,10,53,NULL,0,0,'',0,0,0,0,0),
(3621,0,-1,0,0,'Thanah II g',100000,10,31,NULL,0,0,'',0,0,0,0,0),
(3622,0,-1,0,0,'Thanah II h',100000,10,26,NULL,0,0,'',0,0,0,0,0),
(3623,0,-1,0,0,'Thrarhor I a (Shop)',50000,10,21,NULL,0,0,'',0,0,0,0,0),
(3624,0,-1,0,0,'Thrarhor I c (Shop)',50000,10,21,NULL,0,0,'',0,0,0,0,0),
(3625,0,-1,0,0,'Thrarhor I d (Shop)',80000,10,21,NULL,0,0,'',0,0,0,0,0),
(3626,0,-1,0,0,'Thrarhor I b (Shop)',50000,10,21,NULL,0,0,'',0,0,0,0,0),
(3627,0,-1,0,0,'Uthemath I a',25000,10,10,NULL,0,0,'',0,0,0,0,0),
(3628,0,-1,0,0,'Uthemath I b',50000,10,20,NULL,0,0,'',0,0,0,0,0),
(3629,0,-1,0,0,'Uthemath I c',80000,10,20,NULL,0,0,'',0,0,0,0,0),
(3630,0,-1,0,0,'Uthemath I d',80000,10,21,NULL,0,0,'',0,0,0,0,0),
(3631,0,-1,0,0,'Uthemath I e',80000,10,21,NULL,0,0,'',0,0,0,0,0),
(3632,0,-1,0,0,'Uthemath I f',150000,10,56,NULL,0,0,'',0,0,0,0,0),
(3633,0,-1,0,0,'Uthemath II',250000,10,94,NULL,0,0,'',0,0,0,0,0),
(3634,0,-1,0,0,'Marketplace 1',400000,22,74,NULL,0,0,'',0,0,0,0,0),
(3635,0,-1,0,0,'Marketplace 2',400000,22,81,NULL,0,0,'',0,0,0,0,0),
(3636,0,-1,0,0,'Quay 1',200000,22,124,NULL,0,0,'',0,0,0,0,0),
(3637,0,-1,0,0,'Quay 2',200000,22,81,NULL,0,0,'',0,0,0,0,0),
(3638,0,-1,0,0,'Halls of Sun and Sea',1000000,22,369,NULL,0,0,'',0,0,0,0,0),
(3639,0,-1,0,0,'Palace Vicinity',200000,22,114,NULL,0,0,'',0,0,0,0,0),
(3640,0,-1,0,0,'Wave Tower',400000,22,178,NULL,0,0,'',0,0,0,0,0),
(3641,0,-1,0,0,'Old Sanctuary of God King Qjell',300000,18,537,NULL,0,0,'',0,0,0,0,0),
(3642,0,-1,0,0,'Old Heritage Estate',600000,20,255,NULL,0,0,'',0,0,0,0,0),
(3643,0,-1,0,0,'Rathleton Plaza 4',400000,20,109,NULL,0,0,'',0,0,0,0,0),
(3644,0,-1,0,0,'Rathleton Plaza 3',400000,20,123,NULL,0,0,'',0,0,0,0,0),
(3645,0,-1,0,0,'Rathleton Plaza 2',400000,20,56,NULL,0,0,'',0,0,0,0,0),
(3646,0,-1,0,0,'Rathleton Plaza 1',300000,20,62,NULL,0,0,'',0,0,0,0,0),
(3647,0,-1,0,0,'Antimony Lane 2',400000,20,101,NULL,0,0,'',0,0,0,0,0),
(3648,0,-1,0,0,'Antimony Lane 1',400000,20,149,NULL,0,0,'',0,0,0,0,0),
(3649,0,-1,0,0,'Wallside Residence',400000,20,144,NULL,0,0,'',0,0,0,0,0),
(3650,0,-1,0,0,'Wallside Lane 1',800000,20,162,NULL,0,0,'',0,0,0,0,0),
(3651,0,-1,0,0,'Wallside Lane 2',600000,20,181,NULL,0,0,'',0,0,0,0,0),
(3652,0,-1,0,0,'Vanward Flats B',400000,20,158,NULL,0,0,'',0,0,0,0,0),
(3653,0,-1,0,0,'Vanward Flats A',400000,20,158,NULL,0,0,'',0,0,0,0,0),
(3654,0,-1,0,0,'Bronze Brothers Bastion',5000000,20,749,NULL,0,0,'',0,0,0,0,0),
(3655,0,-1,0,0,'Cistern Ave',300000,20,81,NULL,0,0,'',0,0,0,0,0),
(3656,0,-1,0,0,'Antimony Lane 4',400000,20,110,NULL,0,0,'',0,0,0,0,0),
(3657,0,-1,0,0,'Antimony Lane 3',400000,20,77,NULL,0,0,'',0,0,0,0,0),
(3658,0,-1,0,0,'Rathleton Hills Residence',400000,20,155,NULL,0,0,'',0,0,0,0,0),
(3659,0,-1,0,0,'Rathleton Hills Estate',1000000,20,433,NULL,0,0,'',0,0,0,0,0),
(3660,0,-1,0,0,'Lion\'s Head Reef',400000,14,149,NULL,0,0,'',0,0,0,0,0),
(3661,0,-1,0,0,'Shadow Caves 1',50000,5,22,NULL,0,0,'',0,0,0,0,0),
(3662,0,-1,0,0,'Shadow Caves 2',50000,5,22,NULL,0,0,'',0,0,0,0,0),
(3663,0,-1,0,0,'Shadow Caves 3',100000,5,44,NULL,0,0,'',0,0,0,0,0),
(3664,0,-1,0,0,'Shadow Caves 4',100000,5,44,NULL,0,0,'',0,0,0,0,0),
(3665,0,-1,0,0,'Shadow Caves 5',100000,5,44,NULL,0,0,'',0,0,0,0,0),
(3666,0,-1,0,0,'Shadow Caves 6',100000,5,44,NULL,0,0,'',0,0,0,0,0),
(3667,0,-1,0,0,'Northport Clanhall',250000,6,162,NULL,0,0,'',0,0,0,0,0),
(3668,0,-1,0,0,'The Treehouse',250000,15,548,NULL,0,0,'',0,0,0,0,0),
(3669,0,-1,0,0,'Frost Manor',500000,16,434,NULL,0,0,'',0,0,0,0,0),
(3670,0,-1,0,0,'Hare\'s Den',150000,7,180,NULL,0,0,'',0,0,0,0,0),
(3671,0,-1,0,0,'Lost Cavern',200000,7,471,NULL,0,0,'',0,0,0,0,0),
(3673,0,-1,0,0,'Caveman Shelter',150000,12,87,NULL,0,0,'',0,0,0,0,0),
(3674,0,-1,0,0,'Eastern House of Tranquility',200000,12,268,NULL,0,0,'',0,0,0,0,0),
(3675,0,-1,0,0,'Lakeside Mansion',300000,16,149,NULL,0,0,'',0,0,0,0,0),
(3676,0,-1,0,0,'Pilchard Bin 1',80000,16,13,NULL,0,0,'',0,0,0,0,0),
(3677,0,-1,0,0,'Pilchard Bin 2',50000,16,13,NULL,0,0,'',0,0,0,0,0),
(3678,0,-1,0,0,'Pilchard Bin 3',50000,16,13,NULL,0,0,'',0,0,0,0,0),
(3679,0,-1,0,0,'Pilchard Bin 4',50000,16,13,NULL,0,0,'',0,0,0,0,0),
(3680,0,-1,0,0,'Pilchard Bin 5',80000,16,13,NULL,0,0,'',0,0,0,0,0),
(3681,0,-1,0,0,'Pilchard Bin 6',25000,16,10,NULL,0,0,'',0,0,0,0,0),
(3682,0,-1,0,0,'Pilchard Bin 7',25000,16,10,NULL,0,0,'',0,0,0,0,0),
(3683,0,-1,0,0,'Pilchard Bin 8',25000,16,10,NULL,0,0,'',0,0,0,0,0),
(3684,0,-1,0,0,'Pilchard Bin 9',50000,16,10,NULL,0,0,'',0,0,0,0,0),
(3685,0,-1,0,0,'Pilchard Bin 10',50000,16,10,NULL,0,0,'',0,0,0,0,0),
(3686,0,-1,0,0,'Mammoth House',300000,16,176,NULL,0,0,'',0,0,0,0,0),
(3687,0,-1,0,0,'Cherry Cake Tower',800000,29,153,NULL,0,0,'',0,0,0,0,0),
(3688,0,-1,0,0,'Blueberry Bay',600000,29,130,NULL,0,0,'',0,0,0,0,0),
(3689,0,-1,0,0,'Vanilla Beach',600000,29,129,NULL,0,0,'',0,0,0,0,0),
(3690,0,-1,0,0,'Centre 1',600000,30,126,NULL,0,0,'',0,0,0,0,0),
(3691,0,-1,0,0,'Centre 2',600000,30,139,NULL,0,0,'',0,0,0,0,0),
(3693,0,-1,0,0,'Cliffside',600000,31,203,NULL,0,0,'',0,0,0,0,0),
(3694,0,-1,0,0,'House of the Rising Moon',1000000,31,340,NULL,0,0,'',0,0,0,0,0),
(3695,0,-1,0,0,'Marketplace 3',400000,22,130,NULL,0,0,'',0,0,0,0,0),
(3696,0,-1,0,0,'Hanging Gardens 1',400000,22,178,NULL,0,0,'',0,0,0,0,0);
/*!40000 ALTER TABLE `houses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ip_bans`
--

DROP TABLE IF EXISTS `ip_bans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ip_bans` (
  `ip` int(11) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `banned_at` bigint(20) NOT NULL,
  `expires_at` bigint(20) NOT NULL,
  `banned_by` int(11) NOT NULL,
  PRIMARY KEY (`ip`),
  KEY `banned_by` (`banned_by`),
  CONSTRAINT `ip_bans_players_fk` FOREIGN KEY (`banned_by`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ip_bans`
--

LOCK TABLES `ip_bans` WRITE;
/*!40000 ALTER TABLE `ip_bans` DISABLE KEYS */;
/*!40000 ALTER TABLE `ip_bans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kv_store`
--

DROP TABLE IF EXISTS `kv_store`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `kv_store` (
  `key_name` varchar(191) NOT NULL,
  `timestamp` bigint(20) NOT NULL,
  `value` longblob NOT NULL,
  PRIMARY KEY (`key_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kv_store`
--

LOCK TABLES `kv_store` WRITE;
/*!40000 ALTER TABLE `kv_store` DISABLE KEYS */;
INSERT INTO `kv_store` VALUES
('migrations.20231128213158_move_hireling_data_to_kv',1772732935931,'0'),
('migrations.20241708000535_move_achievement_to_kv',1772732937040,'0'),
('migrations.20241708362079_move_vip_system_to_kv',1772732937118,'0'),
('migrations.20241708485868_move_some_storages_to_kv',1772732937198,'0'),
('migrations.20241715984279_move_wheel_scrolls_from_storagename_to_kv',1772732937280,'0'),
('migrations.20241715984294_quests_storages_to_kv',1772732937359,'0'),
('migrations.20251737599334_reset_charms',1772732937450,'0'),
('quest.soul-war.ebb-and-flow-maps.is-active',1772789467938,'0\0'),
('quest.soul-war.ebb-and-flow-maps.is-loaded-empty-map',1772789467938,'0'),
('raids.ankrahmun.the-welter.checks-today',1772758121752,'\0\0\0\0\0@z@'),
('raids.ankrahmun.the-welter.failed-attempts',1772758121752,'\0\0\0\0\0@z@'),
('raids.darashia.tyrn.checks-today',1772758121754,'\0\0\0\0\0@z@'),
('raids.darashia.tyrn.failed-attempts',1772758121754,'\0\0\0\0\0@z@'),
('raids.drefia.arachir.checks-today',1772758121755,'\0\0\0\0\0@z@'),
('raids.drefia.arachir.failed-attempts',1772758121755,'\0\0\0\0\0@z@'),
('raids.drefia.the-pale-count.checks-today',1772758121746,'\0\0\0\0\0@z@'),
('raids.drefia.the-pale-count.failed-attempts',1772758121746,'\0\0\0\0\0@z@'),
('raids.edron.valorcrest.checks-today',1772758121748,'\0\0\0\0\0@z@'),
('raids.edron.valorcrest.failed-attempts',1772758121748,'\0\0\0\0\0@z@'),
('raids.edron.weakened-shlorg.checks-today',1772758121749,'\0\0\0\0\0@z@'),
('raids.edron.weakened-shlorg.failed-attempts',1772758121749,'\0\0\0\0\0@z@'),
('raids.edron.white-pale.checks-today',1772758121751,'\0\0\0\0\0@z@'),
('raids.edron.white-pale.failed-attempts',1772758121751,'\0\0\0\0\0@z@'),
('raids.farmine.draptor.checks-today',1772758121746,'\0\0\0\0\0@z@'),
('raids.farmine.draptor.failed-attempts',1772758121746,'\0\0\0\0\0@z@'),
('raids.folda.yeti.checks-today',1772758121749,'\0\0\0\0\0@z@'),
('raids.folda.yeti.failed-attempts',1772758121749,'\0\0\0\0\0@z@'),
('raids.fury-gates.furiosa.checks-today',1772758121754,'\0\0\0\0\0@z@'),
('raids.fury-gates.furiosa.failed-attempts',1772758121754,'\0\0\0\0\0@z@'),
('raids.muggy_plains.battlemaster_zunzu.checks-today',1772758121753,'\0\0\0\0\0@z@'),
('raids.muggy_plains.battlemaster_zunzu.failed-attempts',1772758121753,'\0\0\0\0\0@z@'),
('raids.nargor.diblis.checks-today',1772758121750,'\0\0\0\0\0@z@'),
('raids.nargor.diblis.failed-attempts',1772758121750,'\0\0\0\0\0@z@'),
('raids.roshamuul.mawhawk.checks-today',1772758121752,'\0\0\0\0\0@z@'),
('raids.roshamuul.mawhawk.failed-attempts',1772758121753,'\0\0\0\0\0@z@'),
('raids.svargrond.hirintror.checks-today',1772758121747,'\0\0\0\0\0@z@'),
('raids.svargrond.hirintror.failed-attempts',1772758121747,'\0\0\0\0\0@z@'),
('raids.thais.rats.checks-today',1772758121751,'\0\0\0\0\0@z@'),
('raids.thais.rats.failed-attempts',1772758121751,'\0\0\0\0\0@z@'),
('raids.thais.wild-horses.checks-today',1772732981760,'\0\0\0\0\0\0ð?'),
('raids.thais.wild-horses.trigger-when-possible',1772758121755,'0'),
('raids.tiquanda.midnight-panther.checks-today',1772758121748,'\0\0\0\0\0@z@'),
('raids.tiquanda.midnight-panther.failed-attempts',1772758121748,'\0\0\0\0\0@z@'),
('raids.venore.the-old-widow.checks-today',1772758121745,'\0\0\0\0\0@z@'),
('raids.venore.the-old-widow.failed-attempts',1772758121745,'\0\0\0\0\0@z@');
/*!40000 ALTER TABLE `kv_store` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `market_history`
--

DROP TABLE IF EXISTS `market_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `market_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` int(11) NOT NULL,
  `sale` tinyint(1) NOT NULL DEFAULT 0,
  `itemtype` int(10) unsigned NOT NULL,
  `amount` smallint(5) unsigned NOT NULL,
  `price` bigint(20) unsigned NOT NULL DEFAULT 0,
  `expires_at` bigint(20) unsigned NOT NULL,
  `inserted` bigint(20) unsigned NOT NULL,
  `state` tinyint(1) unsigned NOT NULL,
  `tier` tinyint(3) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`,`sale`),
  CONSTRAINT `market_history_players_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `market_history`
--

LOCK TABLES `market_history` WRITE;
/*!40000 ALTER TABLE `market_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `market_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `market_offers`
--

DROP TABLE IF EXISTS `market_offers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `market_offers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` int(11) NOT NULL,
  `sale` tinyint(1) NOT NULL DEFAULT 0,
  `itemtype` int(10) unsigned NOT NULL,
  `amount` smallint(5) unsigned NOT NULL,
  `created` bigint(20) unsigned NOT NULL,
  `anonymous` tinyint(1) NOT NULL DEFAULT 0,
  `price` bigint(20) unsigned NOT NULL DEFAULT 0,
  `tier` tinyint(3) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `sale` (`sale`,`itemtype`),
  KEY `created` (`created`),
  KEY `player_id` (`player_id`),
  CONSTRAINT `market_offers_players_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `market_offers`
--

LOCK TABLES `market_offers` WRITE;
/*!40000 ALTER TABLE `market_offers` DISABLE KEYS */;
/*!40000 ALTER TABLE `market_offers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_bosstiary`
--

DROP TABLE IF EXISTS `player_bosstiary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_bosstiary` (
  `player_id` int(11) NOT NULL,
  `bossIdSlotOne` int(11) NOT NULL DEFAULT 0,
  `bossIdSlotTwo` int(11) NOT NULL DEFAULT 0,
  `removeTimes` int(11) NOT NULL DEFAULT 1,
  `tracker` blob NOT NULL,
  KEY `player_bosstiary_players_fk` (`player_id`),
  CONSTRAINT `player_bosstiary_players_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_bosstiary`
--

LOCK TABLES `player_bosstiary` WRITE;
/*!40000 ALTER TABLE `player_bosstiary` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_bosstiary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_charms`
--

DROP TABLE IF EXISTS `player_charms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_charms` (
  `player_id` int(11) NOT NULL,
  `charm_points` smallint(6) NOT NULL DEFAULT 0,
  `minor_charm_echoes` smallint(6) NOT NULL DEFAULT 0,
  `max_charm_points` smallint(6) NOT NULL DEFAULT 0,
  `max_minor_charm_echoes` smallint(6) NOT NULL DEFAULT 0,
  `charm_expansion` tinyint(1) NOT NULL DEFAULT 0,
  `UsedRunesBit` int(11) NOT NULL DEFAULT 0,
  `UnlockedRunesBit` int(11) NOT NULL DEFAULT 0,
  `charms` blob DEFAULT NULL,
  `tracker list` blob DEFAULT NULL,
  KEY `player_charms_players_fk` (`player_id`),
  CONSTRAINT `player_charms_players_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_charms`
--

LOCK TABLES `player_charms` WRITE;
/*!40000 ALTER TABLE `player_charms` DISABLE KEYS */;
INSERT INTO `player_charms` VALUES
(1,0,0,0,0,0,0,0,'\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',''),
(2,0,0,0,0,0,0,0,'\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',''),
(3,0,0,0,0,0,0,0,'\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',''),
(4,0,0,0,0,0,0,0,'\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',''),
(5,0,0,0,0,0,0,0,'\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',''),
(6,0,0,0,0,0,0,0,'\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',''),
(7,0,0,0,0,0,0,0,'\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0','');
/*!40000 ALTER TABLE `player_charms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_deaths`
--

DROP TABLE IF EXISTS `player_deaths`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_deaths` (
  `player_id` int(11) NOT NULL,
  `time` bigint(20) unsigned NOT NULL DEFAULT 0,
  `level` int(11) NOT NULL DEFAULT 1,
  `killed_by` varchar(255) NOT NULL,
  `is_player` tinyint(1) NOT NULL DEFAULT 1,
  `mostdamage_by` varchar(100) NOT NULL,
  `mostdamage_is_player` tinyint(1) NOT NULL DEFAULT 0,
  `unjustified` tinyint(1) NOT NULL DEFAULT 0,
  `mostdamage_unjustified` tinyint(1) NOT NULL DEFAULT 0,
  `participants` text NOT NULL,
  KEY `player_id` (`player_id`),
  KEY `killed_by` (`killed_by`),
  KEY `mostdamage_by` (`mostdamage_by`),
  CONSTRAINT `player_deaths_players_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_deaths`
--

LOCK TABLES `player_deaths` WRITE;
/*!40000 ALTER TABLE `player_deaths` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_deaths` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_depotitems`
--

DROP TABLE IF EXISTS `player_depotitems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_depotitems` (
  `player_id` int(11) NOT NULL,
  `sid` int(11) NOT NULL COMMENT 'any given range eg 0-100 will be reserved for depot lockers and all > 100 will be then normal items inside depots',
  `pid` int(11) NOT NULL DEFAULT 0,
  `itemtype` int(11) NOT NULL DEFAULT 0,
  `count` int(11) NOT NULL DEFAULT 0,
  `attributes` blob NOT NULL,
  UNIQUE KEY `player_depotitems_unique` (`player_id`,`sid`),
  CONSTRAINT `player_depotitems_players_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_depotitems`
--

LOCK TABLES `player_depotitems` WRITE;
/*!40000 ALTER TABLE `player_depotitems` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_depotitems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_hirelings`
--

DROP TABLE IF EXISTS `player_hirelings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_hirelings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `active` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `sex` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `posx` int(11) NOT NULL DEFAULT 0,
  `posy` int(11) NOT NULL DEFAULT 0,
  `posz` int(11) NOT NULL DEFAULT 0,
  `lookbody` int(11) NOT NULL DEFAULT 0,
  `lookfeet` int(11) NOT NULL DEFAULT 0,
  `lookhead` int(11) NOT NULL DEFAULT 0,
  `looklegs` int(11) NOT NULL DEFAULT 0,
  `looktype` int(11) NOT NULL DEFAULT 136,
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`),
  CONSTRAINT `player_hirelings_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_hirelings`
--

LOCK TABLES `player_hirelings` WRITE;
/*!40000 ALTER TABLE `player_hirelings` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_hirelings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_inboxitems`
--

DROP TABLE IF EXISTS `player_inboxitems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_inboxitems` (
  `player_id` int(11) NOT NULL,
  `sid` int(11) NOT NULL,
  `pid` int(11) NOT NULL DEFAULT 0,
  `itemtype` int(11) NOT NULL DEFAULT 0,
  `count` int(11) NOT NULL DEFAULT 0,
  `attributes` blob NOT NULL,
  UNIQUE KEY `player_inboxitems_unique` (`player_id`,`sid`),
  CONSTRAINT `player_inboxitems_players_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_inboxitems`
--

LOCK TABLES `player_inboxitems` WRITE;
/*!40000 ALTER TABLE `player_inboxitems` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_inboxitems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_items`
--

DROP TABLE IF EXISTS `player_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_items` (
  `player_id` int(11) NOT NULL DEFAULT 0,
  `pid` int(11) NOT NULL DEFAULT 0,
  `sid` int(11) NOT NULL DEFAULT 0,
  `itemtype` int(11) NOT NULL DEFAULT 0,
  `count` int(11) NOT NULL DEFAULT 0,
  `attributes` blob NOT NULL,
  PRIMARY KEY (`player_id`,`pid`,`sid`),
  KEY `player_id` (`player_id`),
  KEY `sid` (`sid`),
  CONSTRAINT `player_items_players_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_items`
--

LOCK TABLES `player_items` WRITE;
/*!40000 ALTER TABLE `player_items` DISABLE KEYS */;
INSERT INTO `player_items` VALUES
(1,11,101,23396,1,''),
(2,11,101,23396,1,''),
(3,11,101,23396,1,''),
(4,11,101,23396,1,''),
(5,11,101,23396,1,''),
(6,11,101,23396,1,''),
(7,11,101,23396,1,'');
/*!40000 ALTER TABLE `player_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_kills`
--

DROP TABLE IF EXISTS `player_kills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_kills` (
  `player_id` int(11) NOT NULL,
  `time` bigint(20) unsigned NOT NULL DEFAULT 0,
  `target` int(11) NOT NULL,
  `unavenged` tinyint(1) NOT NULL DEFAULT 0,
  KEY `player_kills_players_fk` (`player_id`),
  CONSTRAINT `player_kills_players_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_kills`
--

LOCK TABLES `player_kills` WRITE;
/*!40000 ALTER TABLE `player_kills` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_kills` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_namelocks`
--

DROP TABLE IF EXISTS `player_namelocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_namelocks` (
  `player_id` int(11) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `namelocked_at` bigint(20) NOT NULL,
  `namelocked_by` int(11) NOT NULL,
  UNIQUE KEY `player_namelocks_unique` (`player_id`),
  KEY `namelocked_by` (`namelocked_by`),
  CONSTRAINT `player_namelocks_players2_fk` FOREIGN KEY (`namelocked_by`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `player_namelocks_players_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_namelocks`
--

LOCK TABLES `player_namelocks` WRITE;
/*!40000 ALTER TABLE `player_namelocks` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_namelocks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_prey`
--

DROP TABLE IF EXISTS `player_prey`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_prey` (
  `player_id` int(11) NOT NULL,
  `slot` tinyint(1) NOT NULL,
  `state` tinyint(1) NOT NULL,
  `raceid` varchar(250) NOT NULL,
  `option` tinyint(1) NOT NULL,
  `bonus_type` tinyint(1) NOT NULL,
  `bonus_rarity` tinyint(1) NOT NULL,
  `bonus_percentage` varchar(250) NOT NULL,
  `bonus_time` varchar(250) NOT NULL,
  `free_reroll` bigint(20) NOT NULL,
  `monster_list` blob DEFAULT NULL,
  PRIMARY KEY (`player_id`,`slot`),
  CONSTRAINT `player_prey_players_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_prey`
--

LOCK TABLES `player_prey` WRITE;
/*!40000 ALTER TABLE `player_prey` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_prey` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_rewards`
--

DROP TABLE IF EXISTS `player_rewards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_rewards` (
  `player_id` int(11) NOT NULL,
  `sid` int(11) NOT NULL,
  `pid` int(11) NOT NULL DEFAULT 0,
  `itemtype` int(11) NOT NULL DEFAULT 0,
  `count` int(11) NOT NULL DEFAULT 0,
  `attributes` blob NOT NULL,
  UNIQUE KEY `player_rewards_unique` (`player_id`,`sid`),
  CONSTRAINT `player_rewards_players_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_rewards`
--

LOCK TABLES `player_rewards` WRITE;
/*!40000 ALTER TABLE `player_rewards` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_rewards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_spells`
--

DROP TABLE IF EXISTS `player_spells`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_spells` (
  `player_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`player_id`,`name`),
  KEY `player_id` (`player_id`),
  CONSTRAINT `player_spells_players_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_spells`
--

LOCK TABLES `player_spells` WRITE;
/*!40000 ALTER TABLE `player_spells` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_spells` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_stash`
--

DROP TABLE IF EXISTS `player_stash`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_stash` (
  `player_id` int(16) NOT NULL,
  `item_id` int(16) NOT NULL,
  `item_count` int(32) NOT NULL,
  PRIMARY KEY (`player_id`,`item_id`),
  CONSTRAINT `player_stash_players_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_stash`
--

LOCK TABLES `player_stash` WRITE;
/*!40000 ALTER TABLE `player_stash` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_stash` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_storage`
--

DROP TABLE IF EXISTS `player_storage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_storage` (
  `player_id` int(11) NOT NULL DEFAULT 0,
  `key` int(10) unsigned NOT NULL DEFAULT 0,
  `value` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`player_id`,`key`),
  CONSTRAINT `player_storage_players_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_storage`
--

LOCK TABLES `player_storage` WRITE;
/*!40000 ALTER TABLE `player_storage` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_storage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_taskhunt`
--

DROP TABLE IF EXISTS `player_taskhunt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_taskhunt` (
  `player_id` int(11) NOT NULL,
  `slot` tinyint(1) NOT NULL,
  `state` tinyint(1) NOT NULL,
  `raceid` varchar(250) NOT NULL,
  `upgrade` tinyint(1) NOT NULL,
  `rarity` tinyint(1) NOT NULL,
  `kills` varchar(250) NOT NULL,
  `disabled_time` bigint(20) NOT NULL,
  `free_reroll` bigint(20) NOT NULL,
  `monster_list` blob DEFAULT NULL,
  PRIMARY KEY (`player_id`,`slot`),
  CONSTRAINT `player_taskhunt_players_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_taskhunt`
--

LOCK TABLES `player_taskhunt` WRITE;
/*!40000 ALTER TABLE `player_taskhunt` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_taskhunt` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_wheeldata`
--

DROP TABLE IF EXISTS `player_wheeldata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_wheeldata` (
  `player_id` int(11) NOT NULL,
  `slot` blob NOT NULL,
  PRIMARY KEY (`player_id`),
  KEY `player_id` (`player_id`),
  CONSTRAINT `player_wheeldata_players_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_wheeldata`
--

LOCK TABLES `player_wheeldata` WRITE;
/*!40000 ALTER TABLE `player_wheeldata` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_wheeldata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `players`
--

DROP TABLE IF EXISTS `players`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `players` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `group_id` int(11) NOT NULL DEFAULT 1,
  `account_id` int(11) unsigned NOT NULL DEFAULT 0,
  `level` int(11) NOT NULL DEFAULT 1,
  `vocation` int(11) NOT NULL DEFAULT 0,
  `health` int(11) NOT NULL DEFAULT 150,
  `healthmax` int(11) NOT NULL DEFAULT 150,
  `experience` bigint(20) NOT NULL DEFAULT 0,
  `lookbody` int(11) NOT NULL DEFAULT 0,
  `lookfeet` int(11) NOT NULL DEFAULT 0,
  `lookhead` int(11) NOT NULL DEFAULT 0,
  `looklegs` int(11) NOT NULL DEFAULT 0,
  `looktype` int(11) NOT NULL DEFAULT 136,
  `lookaddons` int(11) NOT NULL DEFAULT 0,
  `maglevel` int(11) NOT NULL DEFAULT 0,
  `mana` int(11) NOT NULL DEFAULT 0,
  `manamax` int(11) NOT NULL DEFAULT 0,
  `manaspent` bigint(20) unsigned NOT NULL DEFAULT 0,
  `soul` int(10) unsigned NOT NULL DEFAULT 0,
  `town_id` int(11) NOT NULL DEFAULT 1,
  `posx` int(11) NOT NULL DEFAULT 0,
  `posy` int(11) NOT NULL DEFAULT 0,
  `posz` int(11) NOT NULL DEFAULT 0,
  `conditions` mediumblob NOT NULL,
  `cap` int(11) NOT NULL DEFAULT 0,
  `sex` int(11) NOT NULL DEFAULT 0,
  `locale` varchar(5) NOT NULL DEFAULT 'en',
  `pronoun` int(11) NOT NULL DEFAULT 0,
  `lastlogin` bigint(20) unsigned NOT NULL DEFAULT 0,
  `lastip` int(10) unsigned NOT NULL DEFAULT 0,
  `save` tinyint(1) NOT NULL DEFAULT 1,
  `skull` tinyint(1) NOT NULL DEFAULT 0,
  `skulltime` bigint(20) NOT NULL DEFAULT 0,
  `lastlogout` bigint(20) unsigned NOT NULL DEFAULT 0,
  `blessings` tinyint(2) NOT NULL DEFAULT 0,
  `blessings1` tinyint(4) NOT NULL DEFAULT 0,
  `blessings2` tinyint(4) NOT NULL DEFAULT 0,
  `blessings3` tinyint(4) NOT NULL DEFAULT 0,
  `blessings4` tinyint(4) NOT NULL DEFAULT 0,
  `blessings5` tinyint(4) NOT NULL DEFAULT 0,
  `blessings6` tinyint(4) NOT NULL DEFAULT 0,
  `blessings7` tinyint(4) NOT NULL DEFAULT 0,
  `blessings8` tinyint(4) NOT NULL DEFAULT 0,
  `onlinetime` int(11) NOT NULL DEFAULT 0,
  `deletion` bigint(15) NOT NULL DEFAULT 0,
  `balance` bigint(20) unsigned NOT NULL DEFAULT 0,
  `offlinetraining_time` smallint(5) unsigned NOT NULL DEFAULT 43200,
  `offlinetraining_skill` tinyint(2) NOT NULL DEFAULT -1,
  `stamina` smallint(5) unsigned NOT NULL DEFAULT 2520,
  `skill_fist` int(10) unsigned NOT NULL DEFAULT 10,
  `skill_fist_tries` bigint(20) unsigned NOT NULL DEFAULT 0,
  `skill_club` int(10) unsigned NOT NULL DEFAULT 10,
  `skill_club_tries` bigint(20) unsigned NOT NULL DEFAULT 0,
  `skill_sword` int(10) unsigned NOT NULL DEFAULT 10,
  `skill_sword_tries` bigint(20) unsigned NOT NULL DEFAULT 0,
  `skill_axe` int(10) unsigned NOT NULL DEFAULT 10,
  `skill_axe_tries` bigint(20) unsigned NOT NULL DEFAULT 0,
  `skill_dist` int(10) unsigned NOT NULL DEFAULT 10,
  `skill_dist_tries` bigint(20) unsigned NOT NULL DEFAULT 0,
  `skill_shielding` int(10) unsigned NOT NULL DEFAULT 10,
  `skill_shielding_tries` bigint(20) unsigned NOT NULL DEFAULT 0,
  `skill_fishing` int(10) unsigned NOT NULL DEFAULT 10,
  `skill_fishing_tries` bigint(20) unsigned NOT NULL DEFAULT 0,
  `skill_critical_hit_chance` int(10) unsigned NOT NULL DEFAULT 0,
  `skill_critical_hit_chance_tries` bigint(20) unsigned NOT NULL DEFAULT 0,
  `skill_critical_hit_damage` int(10) unsigned NOT NULL DEFAULT 0,
  `skill_critical_hit_damage_tries` bigint(20) unsigned NOT NULL DEFAULT 0,
  `skill_life_leech_chance` int(10) unsigned NOT NULL DEFAULT 0,
  `skill_life_leech_chance_tries` bigint(20) unsigned NOT NULL DEFAULT 0,
  `skill_life_leech_amount` int(10) unsigned NOT NULL DEFAULT 0,
  `skill_life_leech_amount_tries` bigint(20) unsigned NOT NULL DEFAULT 0,
  `skill_mana_leech_chance` int(10) unsigned NOT NULL DEFAULT 0,
  `skill_mana_leech_chance_tries` bigint(20) unsigned NOT NULL DEFAULT 0,
  `skill_mana_leech_amount` int(10) unsigned NOT NULL DEFAULT 0,
  `skill_mana_leech_amount_tries` bigint(20) unsigned NOT NULL DEFAULT 0,
  `skill_criticalhit_chance` bigint(20) unsigned NOT NULL DEFAULT 0,
  `skill_criticalhit_damage` bigint(20) unsigned NOT NULL DEFAULT 0,
  `skill_lifeleech_chance` bigint(20) unsigned NOT NULL DEFAULT 0,
  `skill_lifeleech_amount` bigint(20) unsigned NOT NULL DEFAULT 0,
  `skill_manaleech_chance` bigint(20) unsigned NOT NULL DEFAULT 0,
  `skill_manaleech_amount` bigint(20) unsigned NOT NULL DEFAULT 0,
  `manashield` int(10) unsigned NOT NULL DEFAULT 0,
  `max_manashield` int(10) unsigned NOT NULL DEFAULT 0,
  `xpboost_stamina` smallint(5) unsigned DEFAULT NULL,
  `xpboost_value` tinyint(4) unsigned DEFAULT NULL,
  `marriage_status` bigint(20) unsigned NOT NULL DEFAULT 0,
  `marriage_spouse` int(11) NOT NULL DEFAULT -1,
  `bonus_rerolls` bigint(21) NOT NULL DEFAULT 0,
  `prey_wildcard` bigint(21) NOT NULL DEFAULT 0,
  `task_points` bigint(21) NOT NULL DEFAULT 0,
  `quickloot_fallback` tinyint(1) DEFAULT 0,
  `lookmountbody` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `lookmountfeet` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `lookmounthead` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `lookmountlegs` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `lookfamiliarstype` int(11) unsigned NOT NULL DEFAULT 0,
  `isreward` tinyint(1) NOT NULL DEFAULT 1,
  `istutorial` tinyint(1) NOT NULL DEFAULT 0,
  `forge_dusts` bigint(21) NOT NULL DEFAULT 0,
  `forge_dust_level` bigint(21) NOT NULL DEFAULT 100,
  `randomize_mount` tinyint(1) NOT NULL DEFAULT 0,
  `boss_points` int(11) NOT NULL DEFAULT 0,
  `animus_mastery` mediumblob DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `players_unique` (`name`),
  KEY `account_id` (`account_id`),
  KEY `vocation` (`vocation`),
  KEY `idx_players_locale` (`locale`),
  CONSTRAINT `players_account_fk` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `players`
--

LOCK TABLES `players` WRITE;
/*!40000 ALTER TABLE `players` DISABLE KEYS */;
INSERT INTO `players` VALUES
(1,'Rook Sample',1,1,2,0,155,155,100,113,115,95,39,129,0,2,60,60,5936,0,1,32069,31901,6,'',410,1,'en',0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,43200,-1,2520,10,0,12,155,12,155,12,155,12,93,10,0,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,1,0,0,100,0,0,''),
(2,'Sorcerer Sample',1,1,8,1,185,185,4200,113,115,95,39,129,0,0,90,90,0,0,8,32369,32241,7,'',470,1,'en',0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,43200,-1,2520,10,0,10,0,10,0,10,0,10,0,10,0,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,1,0,0,100,0,0,''),
(3,'Druid Sample',1,1,8,2,185,185,4200,113,115,95,39,129,0,0,90,90,0,0,8,32369,32241,7,'',470,1,'en',0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,43200,-1,2520,10,0,10,0,10,0,10,0,10,0,10,0,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,1,0,0,100,0,0,''),
(4,'Paladin Sample',1,1,8,3,185,185,4200,113,115,95,39,129,0,0,90,90,0,0,8,32369,32241,7,'',470,1,'en',0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,43200,-1,2520,10,0,10,0,10,0,10,0,10,0,10,0,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,1,0,0,100,0,0,''),
(5,'Knight Sample',1,1,8,4,185,185,4200,113,115,95,39,129,0,0,90,90,0,0,8,32369,32241,7,'',470,1,'en',0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,43200,-1,2520,10,0,10,0,10,0,10,0,10,0,10,0,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,1,0,0,100,0,0,''),
(6,'GOD',6,1,2,0,155,155,100,113,115,95,39,75,0,0,60,60,0,0,8,32369,32241,7,'',410,1,'en',0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,43200,-1,2520,10,0,10,0,10,0,10,0,10,0,10,0,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,1,0,0,100,0,0,''),
(7,'Ptaku Modern',1,6,8,2,185,185,4200,116,114,97,114,128,0,0,40,40,0,100,1,32369,32241,7,'',470,1,'en',0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,43200,-1,2520,10,0,10,0,10,0,10,0,10,0,10,0,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,0,0,0,0,1,0,0,100,0,0,'');
/*!40000 ALTER TABLE `players` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`ptaku`@`localhost`*/ /*!50003 TRIGGER `ondelete_players` BEFORE DELETE ON `players` FOR EACH ROW BEGIN
    UPDATE `houses` SET `owner` = 0 WHERE `owner` = OLD.`id`;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `players_online`
--

DROP TABLE IF EXISTS `players_online`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `players_online` (
  `player_id` int(11) NOT NULL,
  PRIMARY KEY (`player_id`)
) ENGINE=MEMORY DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `players_online`
--

LOCK TABLES `players_online` WRITE;
/*!40000 ALTER TABLE `players_online` DISABLE KEYS */;
/*!40000 ALTER TABLE `players_online` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `server_config`
--

DROP TABLE IF EXISTS `server_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `server_config` (
  `config` varchar(50) NOT NULL,
  `value` varchar(256) NOT NULL DEFAULT '',
  PRIMARY KEY (`config`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `server_config`
--

LOCK TABLES `server_config` WRITE;
/*!40000 ALTER TABLE `server_config` DISABLE KEYS */;
INSERT INTO `server_config` VALUES
('db_version','53'),
('motd_hash','ff0cb6c0f582c78dc75682e93ce056b07cf18b23'),
('motd_num','1'),
('players_record','0');
/*!40000 ALTER TABLE `server_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `store_history`
--

DROP TABLE IF EXISTS `store_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `store_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) unsigned NOT NULL,
  `mode` smallint(2) NOT NULL DEFAULT 0,
  `description` varchar(3500) NOT NULL,
  `coin_type` tinyint(1) NOT NULL DEFAULT 0,
  `coin_amount` int(12) NOT NULL,
  `time` bigint(20) unsigned NOT NULL,
  `timestamp` int(11) NOT NULL DEFAULT 0,
  `coins` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  CONSTRAINT `store_history_account_fk` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `store_history`
--

LOCK TABLES `store_history` WRITE;
/*!40000 ALTER TABLE `store_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `store_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tile_store`
--

DROP TABLE IF EXISTS `tile_store`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tile_store` (
  `house_id` int(11) NOT NULL,
  `data` longblob NOT NULL,
  KEY `house_id` (`house_id`),
  CONSTRAINT `tile_store_account_fk` FOREIGN KEY (`house_id`) REFERENCES `houses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tile_store`
--

LOCK TABLES `tile_store` WRITE;
/*!40000 ALTER TABLE `tile_store` DISABLE KEYS */;
INSERT INTO `tile_store` VALUES
(3220,'cÓ\0\0\09\0'),
(3220,'`Ó\0\0\09\0');
/*!40000 ALTER TABLE `tile_store` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `towns`
--

DROP TABLE IF EXISTS `towns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `towns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `posx` int(11) NOT NULL DEFAULT 0,
  `posy` int(11) NOT NULL DEFAULT 0,
  `posz` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `towns`
--

LOCK TABLES `towns` WRITE;
/*!40000 ALTER TABLE `towns` DISABLE KEYS */;
INSERT INTO `towns` VALUES
(1,'Dawnport Tutorial',32069,31901,6),
(2,'Dawnport',32064,31894,6),
(3,'Rookgaard',32097,32219,7),
(4,'Island of Destiny',32091,32027,7),
(5,'Ab\'Dendriel',32732,31634,7),
(6,'Carlin',32360,31782,7),
(7,'Kazordoon',32649,31925,11),
(8,'Thais',32369,32241,7),
(9,'Venore',32957,32076,7),
(10,'Ankrahmun',33194,32853,8),
(11,'Edron',33217,31814,8),
(12,'Farmine',33023,31521,11),
(13,'Darashia',33213,32454,1),
(14,'Liberty Bay',32317,32826,7),
(15,'Port Hope',32594,32745,7),
(16,'Svargrond',32212,31132,7),
(17,'Yalahar',32787,31276,7),
(18,'Gray Beach',33447,31323,9),
(19,'Krailos',33657,31665,8),
(20,'Rathleton',33594,31899,6),
(21,'Roshamuul',33513,32363,6),
(22,'Issavi',33921,31477,5),
(23,'Event Room',1054,1040,7),
(24,'Cobra Bastion',33397,32651,7),
(25,'Bounac',32424,32445,7),
(26,'Feyrist',33490,32221,7),
(27,'Gnomprona',33517,32856,14),
(28,'Marapur',33842,32853,7),
(29,'Candia',33338,32125,7),
(30,'Silvertides',33776,32842,7),
(31,'Moonfall',33797,32755,5);
/*!40000 ALTER TABLE `towns` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-06 10:37:11
