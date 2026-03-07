/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.13-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: canaryaac
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
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `accounts` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `password` text NOT NULL,
  `engine_password_sha1` char(40) DEFAULT NULL,
  `email` varchar(255) NOT NULL DEFAULT '',
  `key` varchar(64) NOT NULL DEFAULT '',
  `created` int(11) NOT NULL DEFAULT 0,
  `rlname` varchar(255) NOT NULL DEFAULT '',
  `location` varchar(255) NOT NULL DEFAULT '',
  `country` varchar(3) NOT NULL DEFAULT '',
  `web_lastlogin` int(11) NOT NULL DEFAULT 0,
  `web_flags` int(11) NOT NULL DEFAULT 0,
  `email_hash` varchar(32) NOT NULL DEFAULT '',
  `email_new` varchar(255) NOT NULL DEFAULT '',
  `email_new_time` int(11) NOT NULL DEFAULT 0,
  `email_code` varchar(255) NOT NULL DEFAULT '',
  `email_next` int(11) NOT NULL DEFAULT 0,
  `premium_points` int(11) NOT NULL DEFAULT 0,
  `email_verified` tinyint(1) NOT NULL DEFAULT 0,
  `premdays` int(11) NOT NULL DEFAULT 0,
  `premdays_purchased` int(11) NOT NULL DEFAULT 0,
  `lastday` int(10) unsigned NOT NULL DEFAULT 0,
  `type` tinyint(1) unsigned NOT NULL DEFAULT 1,
  `coins` int(12) unsigned NOT NULL DEFAULT 0,
  `coins_transferable` int(12) unsigned NOT NULL DEFAULT 0,
  `tournament_coins` int(12) unsigned NOT NULL DEFAULT 0,
  `creation` timestamp NOT NULL DEFAULT current_timestamp(),
  `recruiter` int(6) DEFAULT 0,
  `house_bid_id` int(11) NOT NULL DEFAULT 0,
  `page_access` int(11) NOT NULL DEFAULT 0,
  `account` varchar(64) GENERATED ALWAYS AS (`name`) STORED,
  `account_name` varchar(64) GENERATED ALWAYS AS (`name`) STORED,
  `vote` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_accounts_email` (`email`),
  KEY `idx_accounts_name` (`name`),
  KEY `idx_accounts_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts`
--

LOCK TABLES `accounts` WRITE;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
INSERT INTO `accounts` VALUES
(3,'','a94a8fe5ccb19ba61c4c0873d391e987982fbbd3',NULL,'admin@canaryaac.com','',0,'','','',0,0,'','',0,'',0,0,0,0,0,0,5,2000,0,0,'2022-08-03 06:44:10',0,0,3,'','',0),
(6,'ptakukolo','a94a8fe5ccb19ba61c4c0873d391e987982fbbd3','A94A8FE5CCB19BA61C4C0873D391E987982FBBD3','proeloptaku3@wp.pl','',0,'','','us',0,3,'','',0,'',0,0,1,0,0,0,5,0,0,0,'2025-08-09 20:10:31',0,0,0,'ptakukolo','ptakukolo',0),
(7,'ptakukolo1','D54489920F8600AEF4F412830EF4FE10B4608B78',NULL,'proeloptaku@wp.pl','',0,'','','',0,0,'','',0,'',0,0,0,0,0,0,0,0,0,0,'2025-08-13 23:47:03',0,0,0,'ptakukolo1','ptakukolo1',0),
(10,'testruntime','$argon2id$v=19$m=65536,t=4,p=1$NVZLNVlnNG1EOVp0ZktjRA$4k1J79VUAfyIye1zaY+hEEBhamkmFcUE9+7kMdXxf7M','662339c7d8d89efb5f06507f92120262d0ed901d','testruntime@test.pl','24d87ba674cb2f727fcef99e02d53fe7199594448b1fd64b356557d5d3981c7b',1772738518,'','','',0,0,'1ff7c268fa4ac59f76ffe89328f78a9c','',0,'',0,0,1,0,0,0,1,0,0,0,'2026-03-05 19:21:58',0,0,0,'testruntime','testruntime',0),
(11,'testportal01','$argon2id$v=19$m=65536,t=4,p=1$ZlRiLi9PcFlvYjQ0S2tlUw$hqfjLVWgj8gNwUHKVMuVEWNMM0s3uIUFJ8PYAyVH0tE','dddd5d7b474d2c78ebbb833789c4bfd721edf4bf','testportal01@test.com','',0,'','','',0,0,'','',0,'',0,0,1,0,0,0,1,0,0,0,'2026-03-05 19:29:04',0,0,0,'testportal01','testportal01',0),
(12,'testportal02','$argon2id$v=19$m=65536,t=4,p=1$QnpBZk11TThDQ3hod2c1QQ$7ujuk8KSs+gmNrjtXhRI8HKgS4KB2Iz8gW+ZRVBu6Sg','2234e5756200f73413109c55b1b4b3267db42011','testportal02@test.com','',0,'','','',0,0,'','',0,'',0,0,1,0,0,0,1,0,0,0,'2026-03-05 19:29:17',0,0,0,'testportal02','testportal02',0),
(13,'reddaxe_1772743014','$argon2id$v=19$m=65536,t=4,p=1$ZzFkTGlkY1JFRTlwNkoyMw$GpMIbo2maKSKPTEJZ1RH7R9tKOSyjJiFqabO32bx6ME','f4a69973e7b0bf9d160f9f60e3c3acd2494beb0d','reddaxe_1772743014@example.com','2560f6f96175a489ac6ced2aa7a823698926d6574937c408b1bcb3b2fb5bb57c',1772743030,'','','',0,0,'8861b89e7c168d436fd209f0350cf6e3','',0,'',0,0,1,0,0,0,0,0,0,0,'2026-03-05 20:37:10',0,0,0,'reddaxe_1772743014','reddaxe_1772743014',0),
(14,'reddaxe_1772743140','$argon2id$v=19$m=65536,t=4,p=1$UUZiQ0ZNcWZ3QU84UWJqbw$mtSNvQzonhrvi4mOrEFZq4a5pHa1O0KYjjzDgbYBNdg','f4a69973e7b0bf9d160f9f60e3c3acd2494beb0d','reddaxe_1772743140@example.com','a78e7dc714fe5a28a6f2e11ab263dc5797bb4bdca8d806e26979a1fe010d8c51',1772743141,'','','',0,0,'edbdec78867ee4ff4f553963dcd9ac5c','',0,'',0,0,1,0,0,0,0,0,0,0,'2026-03-05 20:39:01',0,0,0,'reddaxe_1772743140','reddaxe_1772743140',0),
(15,'reddaxelog_1772743158','$argon2id$v=19$m=65536,t=4,p=1$NXdzZGdhL050NFRGVDlkbA$mJtulvi0fQHCXg9WXTSEGi2tfFG9NL7No8Ov7ny9DTw','f4a69973e7b0bf9d160f9f60e3c3acd2494beb0d','reddaxelog_1772743158@example.com','79e0e1c02dd7822696628161d02fae8924da71859597056bbca382a2c2178c85',1772743159,'','','',0,0,'eef6473d91b90e456ce1c7e63fc47a7e','',0,'',0,0,1,0,0,0,0,0,0,0,'2026-03-05 20:39:19',0,0,0,'reddaxelog_1772743158','reddaxelog_1772743158',0),
(16,'reddaxelog_1772743171','$argon2id$v=19$m=65536,t=4,p=1$R0hYcklTdjgxU0NiVC9YOQ$4WVCAKmzJkzJXUvnO3LJm1urZ185kfadtXGMuI0DtJ8','f4a69973e7b0bf9d160f9f60e3c3acd2494beb0d','reddaxelog_1772743171@example.com','c8e317a8c4d803e6dafc2f145b0c13569b8f7de7e58fef820dfeea16f5852c26',1772743172,'','','',0,0,'01cde50947d81c1230c574de5de01928','',0,'',0,0,1,0,0,0,0,0,0,0,'2026-03-05 20:39:32',0,0,0,'reddaxelog_1772743171','reddaxelog_1772743171',0),
(17,'regapi_1772743375','$argon2id$v=19$m=65536,t=4,p=1$SjJsQ3FhZFdpSEd4b0xpRQ$3F2DUqyhZV+yQLPhwuzumLG4js5gRvyDr0X+2BsEVz8','f4a69973e7b0bf9d160f9f60e3c3acd2494beb0d','regapi_1772743375@example.com','89673bffab7a40cb53a44cdecc0212eec3535c4671c739f8c26dbbca824ca870',1772743376,'','','',0,0,'05d9c233f8f58acc0cb3c5cab139a63c','',0,'',0,0,1,0,0,0,0,0,0,0,'2026-03-05 20:42:56',0,0,0,'regapi_1772743375','regapi_1772743375',0),
(18,'regapi_1772743384','$argon2id$v=19$m=65536,t=4,p=1$dW9IMFFtbDlZbm1nZzJJdA$YuWPmXLG/laxZUaHl9ryeDK8VU6viRthOrrwhWCrLds','f4a69973e7b0bf9d160f9f60e3c3acd2494beb0d','regapi_1772743384@example.com','372ddd3a876eac31488c9949be80c80e5510f5565a67bcace9da29c9e2f63667',1772743385,'','','',0,0,'4f7ca04cebaa615f2db6896ad2a148a5','',0,'',0,0,1,0,0,0,0,0,0,0,'2026-03-05 20:43:05',0,0,0,'regapi_1772743384','regapi_1772743384',0),
(19,'final_1772743577','$argon2id$v=19$m=65536,t=4,p=1$amcwakFNYVc4eGxhN0s1NQ$T1oMZx9vWpoqikoeI4bm/S4VJS80TnCx2PR5W2qfySQ','f4a69973e7b0bf9d160f9f60e3c3acd2494beb0d','final_1772743577@example.com','04a6f6a2044680787516194bb81ac8543d9ba0f8445bcd10e3a58d1e1f0a964b',1772743578,'','','',0,0,'37639bd2dfea2651ded161692ef6363c','',0,'',0,0,1,0,0,0,0,0,0,0,'2026-03-05 20:46:18',0,0,0,'final_1772743577','final_1772743577',0),
(20,'portaltest9850','$argon2id$v=19$m=65536,t=4,p=1$VkxEZ2dwLkIuNjcuSU9Xaw$jrMgDCmSaxSPaGNDUnmq3Tq/RU4bsp3OEYrbbMx81Wk','2fadc2d2915b91f2eaf3c53e3e2d373a05e97738','portaltest9850@test.local','',0,'','','',0,0,'','',0,'',0,0,1,0,0,0,1,0,0,0,'2026-03-05 19:51:22',0,0,0,'portaltest9850','portaltest9850',0),
(21,'portal_i18n_220617','$argon2id$v=19$m=65536,t=4,p=1$d0MyelBNZi55QzN6VEVQaQ$EGo7KLVqDa/+X3PIoO/DjDwoXAPMmIFP/6aOnNMiFfE','4bd074cf429ab454cd7bee74be51083a93cd8aa9','portal_i18n_220617@example.com','6816dc70c712da8455ba1aea467567ba1a8b873ce9c407510c103755892b4ca1',1772744778,'','','',0,0,'37a7ac8d286b1c9cda1b1a0a86f4e42c','',0,'',0,0,1,0,0,0,0,0,0,0,'2026-03-05 21:06:18',0,0,0,'portal_i18n_220617','portal_i18n_220617',0),
(22,'portal_login_220631','$argon2id$v=19$m=65536,t=4,p=1$S3h6bTJPR1EwVWpYY3BrbA$y9sPNXZjyW8IcazQEQUl/u63BwST0xK4ZSuruxibgTY','4bd074cf429ab454cd7bee74be51083a93cd8aa9','portal_login_220631@example.com','55029807f775720a72a91d8e79477b59f4e87cb8718be2719002cd736c23fef9',1772744792,'','','',0,0,'f49786c2f97967c0329b3f13111844d7','',0,'',0,0,1,0,0,0,0,0,0,0,'2026-03-05 21:06:32',0,0,0,'portal_login_220631','portal_login_220631',0),
(23,'i18n_en_221438','$argon2id$v=19$m=65536,t=4,p=1$N3ZENFdQODhjcEhtRlF6aA$dl2sWYSec7gj/OOl3nV5N/1lG9sNs6VzVH4yA23a5OE','4bd074cf429ab454cd7bee74be51083a93cd8aa9','i18n_en_221438@example.com','4a0c062ae56c91b14c28211b579f44e2317e8d33fa81f1e13adaf86c658b2c5f',1772745279,'','','',0,0,'8694e9d80556e36b676c8551c638b30f','',0,'',0,0,1,0,0,0,0,0,0,0,'2026-03-05 21:14:39',0,0,0,'i18n_en_221438','i18n_en_221438',0);
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
/*!50003 CREATE*/ /*!50017 DEFINER=`myaac`@`localhost`*/ /*!50003 TRIGGER `oncreate_accounts` AFTER INSERT ON `accounts` FOR EACH ROW BEGIN
    INSERT INTO `account_vipgroups` (`account_id`, `name`, `customizable`) VALUES (NEW.`id`, 'Enemies', 0);
    INSERT INTO `account_vipgroups` (`account_id`, `name`, `customizable`) VALUES (NEW.`id`, 'Friends', 0);
    INSERT INTO `account_vipgroups` (`account_id`, `name`, `customizable`) VALUES (NEW.`id`, 'Trading Partner', 0);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`ptaku`@`localhost`*/ /*!50003 TRIGGER `acc_sync_ai` AFTER INSERT ON `accounts`
FOR EACH ROW
BEGIN
  INSERT INTO `canary`.`accounts` (`name`, `password`, `email`, `type`, `premdays`)
  VALUES (NEW.`name`, COALESCE(NEW.`engine_password_sha1`, '0'), NEW.`email`, 1, 0)
  ON DUPLICATE KEY UPDATE
    `password` = COALESCE(NEW.`engine_password_sha1`, `password`),
    `email`    = NEW.`email`;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`ptaku`@`localhost`*/ /*!50003 TRIGGER canaryaac.modern_sync_ai
AFTER INSERT ON canaryaac.accounts
FOR EACH ROW
BEGIN
    INSERT INTO canary_modern.accounts
        (id, name, password, email, type, creation)
    VALUES
        (NEW.id, NEW.name, COALESCE(NEW.engine_password_sha1, '0'), NEW.email, NEW.type,
         UNIX_TIMESTAMP(NEW.creation))
    ON DUPLICATE KEY UPDATE
        name     = NEW.name,
        password = COALESCE(NEW.engine_password_sha1, canary_modern.accounts.password),
        email    = NEW.email,
        type     = NEW.type;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`ptaku`@`localhost`*/ /*!50003 TRIGGER acc_sync_au AFTER UPDATE ON accounts
FOR EACH ROW
BEGIN
  INSERT INTO canary.accounts (name, password, email, type, premdays)
  VALUES (NEW.name, COALESCE(NEW.engine_password_sha1, '0'), NEW.email, 1, 0)
  ON DUPLICATE KEY UPDATE
    password = COALESCE(NEW.engine_password_sha1, password),
    email    = NEW.email;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`ptaku`@`localhost`*/ /*!50003 TRIGGER canaryaac.modern_sync_au
AFTER UPDATE ON canaryaac.accounts
FOR EACH ROW
BEGIN
    UPDATE canary_modern.accounts
    SET
        name     = NEW.name,
        password = COALESCE(NEW.engine_password_sha1, password),
        email    = NEW.email,
        type     = NEW.type
    WHERE id = NEW.id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`ptaku`@`localhost`*/ /*!50003 TRIGGER canaryaac.modern_sync_ad
AFTER DELETE ON canaryaac.accounts
FOR EACH ROW
BEGIN
    DELETE FROM canary_modern.accounts WHERE id = OLD.id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`ptaku`@`localhost`*/ /*!50003 TRIGGER acc_sync_ad AFTER DELETE ON canaryaac.accounts
FOR EACH ROW
BEGIN
    DELETE FROM canary.accounts WHERE id = OLD.id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-06 10:03:10
