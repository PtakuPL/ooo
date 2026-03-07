/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.13-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: canary
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
  `email` varchar(255) NOT NULL DEFAULT '',
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
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_accounts_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts`
--

LOCK TABLES `accounts` WRITE;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
INSERT INTO `accounts` VALUES
(3,'migrated_3','a94a8fe5ccb19ba61c4c0873d391e987982fbbd3','admin@canaryaac.com',0,0,0,5,2000,0,0,'2022-08-03 06:44:10',0,0,3),
(4,'migrated_4','a94a8fe5ccb19ba61c4c0873d391e987982fbbd3','admin@canaryaac.com',0,0,0,5,2000,0,0,'2022-08-03 06:44:10',0,0,3),
(6,'proelo','269f793d1c82bf78ca1b790009c3faba6ba856b7','',0,0,0,1,0,0,0,'2025-08-13 02:04:07',0,0,0),
(7,'ptakukolo','A94A8FE5CCB19BA61C4C0873D391E987982FBBD3','proeloptaku3@wp.pl',0,0,0,1,0,0,0,'2025-08-25 07:48:04',0,0,0),
(81,'k10test_1772733489','9d65dfb5b8510a234920820b64c4b9da637666e5','k10_1772733489@example.com',0,0,0,1,0,0,0,'2026-03-05 17:58:09',0,0,0),
(82,'k13k14_1772734847','ab3eb0f868f05373c611a6c904ae319ff0772c0c','k13k14_1772734847@example.com',0,0,0,1,0,0,0,'2026-03-05 18:20:48',0,0,0),
(83,'testruntime','662339c7d8d89efb5f06507f92120262d0ed901d','testruntime@test.pl',0,0,0,1,0,0,0,'2026-03-05 19:21:58',0,0,0),
(84,'testportal01','dddd5d7b474d2c78ebbb833789c4bfd721edf4bf','testportal01@test.com',0,0,0,1,0,0,0,'2026-03-05 20:29:04',0,0,0),
(85,'testportal02','2234e5756200f73413109c55b1b4b3267db42011','testportal02@test.com',0,0,0,1,0,0,0,'2026-03-05 20:29:17',0,0,0),
(86,'reddaxe_1772743014','f4a69973e7b0bf9d160f9f60e3c3acd2494beb0d','reddaxe_1772743014@example.com',0,0,0,1,0,0,0,'2026-03-05 20:37:10',0,0,0),
(87,'reddaxe_1772743140','f4a69973e7b0bf9d160f9f60e3c3acd2494beb0d','reddaxe_1772743140@example.com',0,0,0,1,0,0,0,'2026-03-05 20:39:01',0,0,0),
(88,'reddaxelog_1772743158','f4a69973e7b0bf9d160f9f60e3c3acd2494beb0d','reddaxelog_1772743158@example.com',0,0,0,1,0,0,0,'2026-03-05 20:39:19',0,0,0),
(89,'reddaxelog_1772743171','f4a69973e7b0bf9d160f9f60e3c3acd2494beb0d','reddaxelog_1772743171@example.com',0,0,0,1,0,0,0,'2026-03-05 20:39:32',0,0,0),
(90,'regapi_1772743375','f4a69973e7b0bf9d160f9f60e3c3acd2494beb0d','regapi_1772743375@example.com',0,0,0,1,0,0,0,'2026-03-05 20:42:56',0,0,0),
(91,'regapi_1772743384','f4a69973e7b0bf9d160f9f60e3c3acd2494beb0d','regapi_1772743384@example.com',0,0,0,1,0,0,0,'2026-03-05 20:43:05',0,0,0),
(92,'final_1772743577','f4a69973e7b0bf9d160f9f60e3c3acd2494beb0d','final_1772743577@example.com',0,0,0,1,0,0,0,'2026-03-05 20:46:18',0,0,0),
(93,'portaltest9850','2fadc2d2915b91f2eaf3c53e3e2d373a05e97738','portaltest9850@test.local',0,0,0,1,0,0,0,'2026-03-05 20:51:22',0,0,0),
(94,'portal_i18n_220617','4bd074cf429ab454cd7bee74be51083a93cd8aa9','portal_i18n_220617@example.com',0,0,0,1,0,0,0,'2026-03-05 21:06:18',0,0,0),
(95,'portal_login_220631','4bd074cf429ab454cd7bee74be51083a93cd8aa9','portal_login_220631@example.com',0,0,0,1,0,0,0,'2026-03-05 21:06:32',0,0,0),
(96,'i18n_en_221438','4bd074cf429ab454cd7bee74be51083a93cd8aa9','i18n_en_221438@example.com',0,0,0,1,0,0,0,'2026-03-05 21:14:39',0,0,0),
(97,'k47_test_sync','sha1_updated_hash','k47sync_updated@test.com',0,0,0,1,0,0,0,'2026-03-05 22:03:00',0,0,0),
(99,'e2e_smoke_k47','sha1_updated_e2e','e2e@smoke.test',0,0,0,1,0,0,0,'2026-03-05 22:36:37',0,0,0),
(101,'e2e_k47','sha1_UPD','e2e@k47.test',0,0,0,1,0,0,0,'2026-03-05 22:37:26',0,0,0);
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `oncreate_accounts` AFTER INSERT ON `accounts` FOR EACH ROW BEGIN
    INSERT INTO `account_vipgroups` (`account_id`, `name`, `customizable`) VALUES (NEW.`id`, 'Enemies', 0);
    INSERT INTO `account_vipgroups` (`account_id`, `name`, `customizable`) VALUES (NEW.`id`, 'Friends', 0);
    INSERT INTO `account_vipgroups` (`account_id`, `name`, `customizable`) VALUES (NEW.`id`, 'Trading Partner', 0);
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
