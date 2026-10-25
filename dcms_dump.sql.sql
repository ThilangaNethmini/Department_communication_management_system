CREATE DATABASE  IF NOT EXISTS `dcms` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `dcms`;
-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: dcms
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `agenda`
--

DROP TABLE IF EXISTS `agenda`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agenda` (
  `meeting_id` int NOT NULL,
  `agenda_number` int NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `upload_date` date NOT NULL,
  PRIMARY KEY (`meeting_id`,`agenda_number`),
  CONSTRAINT `fk_ag_m` FOREIGN KEY (`meeting_id`) REFERENCES `meeting` (`meeting_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agenda`
--

LOCK TABLES `agenda` WRITE;
/*!40000 ALTER TABLE `agenda` DISABLE KEYS */;
INSERT INTO `agenda` VALUES (1,1,'/files/agenda/nov_dept.pdf','2026-10-25'),(3,1,'/files/agenda/oct_dept.pdf','2026-10-01');
/*!40000 ALTER TABLE `agenda` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance_log`
--

DROP TABLE IF EXISTS `attendance_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance_log` (
  `log_number` int NOT NULL AUTO_INCREMENT,
  `meeting_id` int NOT NULL,
  `staff_id` int NOT NULL,
  `rsvp_status` enum('PENDING','ACCEPTED','DECLINED') NOT NULL DEFAULT 'PENDING',
  `marked_at` datetime DEFAULT NULL,
  `attendance_status` enum('PRESENT','ABSENT','LATE','EXCUSED') DEFAULT NULL,
  PRIMARY KEY (`log_number`),
  UNIQUE KEY `uq_att` (`meeting_id`,`staff_id`),
  KEY `fk_att_s` (`staff_id`),
  CONSTRAINT `fk_att_m` FOREIGN KEY (`meeting_id`) REFERENCES `meeting` (`meeting_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_att_s` FOREIGN KEY (`staff_id`) REFERENCES `staff` (`staff_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance_log`
--

LOCK TABLES `attendance_log` WRITE;
/*!40000 ALTER TABLE `attendance_log` DISABLE KEYS */;
INSERT INTO `attendance_log` VALUES (1,3,1,'ACCEPTED','2026-10-05 10:35:00','PRESENT'),(2,3,2,'ACCEPTED','2026-10-05 10:40:00','LATE'),(3,3,3,'DECLINED','2026-10-05 10:30:00','ABSENT'),(4,3,4,'ACCEPTED','2026-10-05 10:31:00','PRESENT'),(5,1,1,'ACCEPTED',NULL,NULL),(6,1,2,'PENDING',NULL,NULL),(7,1,3,'PENDING',NULL,NULL);
/*!40000 ALTER TABLE `attendance_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `availability_slot`
--

DROP TABLE IF EXISTS `availability_slot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `availability_slot` (
  `slot_id` int NOT NULL AUTO_INCREMENT,
  `staff_id` int NOT NULL,
  `day_of_week` enum('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday') NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `is_free` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`slot_id`),
  KEY `idx_slot_staff_day` (`staff_id`,`day_of_week`),
  CONSTRAINT `fk_slot_staff` FOREIGN KEY (`staff_id`) REFERENCES `staff` (`staff_id`) ON DELETE CASCADE,
  CONSTRAINT `ck_slot_time` CHECK ((`start_time` < `end_time`))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `availability_slot`
--

LOCK TABLES `availability_slot` WRITE;
/*!40000 ALTER TABLE `availability_slot` DISABLE KEYS */;
INSERT INTO `availability_slot` VALUES (1,2,'Monday','08:00:00','10:00:00',0),(2,2,'Monday','10:00:00','12:00:00',1),(3,3,'Monday','09:00:00','11:00:00',0),(4,3,'Monday','11:00:00','13:00:00',1),(5,1,'Monday','08:00:00','17:00:00',1);
/*!40000 ALTER TABLE `availability_slot` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `decision`
--

DROP TABLE IF EXISTS `decision`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `decision` (
  `meeting_id` int NOT NULL,
  `decision_number` int NOT NULL,
  `decision_text` text NOT NULL,
  `recorded_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`meeting_id`,`decision_number`),
  CONSTRAINT `fk_dec_m` FOREIGN KEY (`meeting_id`) REFERENCES `meeting` (`meeting_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `decision`
--

LOCK TABLES `decision` WRITE;
/*!40000 ALTER TABLE `decision` DISABLE KEYS */;
INSERT INTO `decision` VALUES (3,1,'Approve the lab upgrade proposal.','2026-10-25 18:18:51'),(3,2,'Hold the next meeting on the first Monday of November.','2026-10-25 18:18:51');
/*!40000 ALTER TABLE `decision` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meeting`
--

DROP TABLE IF EXISTS `meeting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting` (
  `meeting_id` int NOT NULL AUTO_INCREMENT,
  `meeting_name` varchar(150) NOT NULL,
  `meeting_date` datetime NOT NULL,
  `venue` varchar(100) NOT NULL,
  `status` enum('PENDING_APPROVAL','APPROVED','REJECTED','SCHEDULED','COMPLETED','CANCELLED') NOT NULL DEFAULT 'PENDING_APPROVAL',
  `schedule_id` int NOT NULL,
  `type_code` varchar(10) NOT NULL,
  `created_by` int NOT NULL,
  `leader_id` int NOT NULL,
  `delegated_to` int DEFAULT NULL,
  PRIMARY KEY (`meeting_id`),
  KEY `fk_m_plan` (`schedule_id`),
  KEY `fk_m_type` (`type_code`),
  KEY `fk_m_creator` (`created_by`),
  KEY `fk_m_leader` (`leader_id`),
  KEY `fk_m_deleg` (`delegated_to`),
  KEY `idx_meeting_date` (`meeting_date`),
  CONSTRAINT `fk_m_creator` FOREIGN KEY (`created_by`) REFERENCES `staff` (`staff_id`),
  CONSTRAINT `fk_m_deleg` FOREIGN KEY (`delegated_to`) REFERENCES `staff` (`staff_id`),
  CONSTRAINT `fk_m_leader` FOREIGN KEY (`leader_id`) REFERENCES `staff` (`staff_id`),
  CONSTRAINT `fk_m_plan` FOREIGN KEY (`schedule_id`) REFERENCES `schedule_plan` (`schedule_id`),
  CONSTRAINT `fk_m_type` FOREIGN KEY (`type_code`) REFERENCES `meeting_type` (`type_code`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meeting`
--

LOCK TABLES `meeting` WRITE;
/*!40000 ALTER TABLE `meeting` DISABLE KEYS */;
INSERT INTO `meeting` VALUES (1,'November Department Meeting','2026-11-02 10:30:00','Conference Room A','SCHEDULED',1,'DEPT',4,1,NULL),(2,'Semester 1 Exam Board','2026-11-16 14:00:00','Board Room','SCHEDULED',1,'EXAM',4,1,2),(3,'October Department Meeting','2026-10-05 10:30:00','Conference Room A','COMPLETED',1,'DEPT',4,1,NULL);
/*!40000 ALTER TABLE `meeting` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meeting_recording`
--

DROP TABLE IF EXISTS `meeting_recording`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_recording` (
  `meeting_id` int NOT NULL,
  `recording_number` int NOT NULL,
  `media_file_path` varchar(255) NOT NULL,
  `upload_timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`meeting_id`,`recording_number`),
  CONSTRAINT `fk_rec_m` FOREIGN KEY (`meeting_id`) REFERENCES `meeting` (`meeting_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meeting_recording`
--

LOCK TABLES `meeting_recording` WRITE;
/*!40000 ALTER TABLE `meeting_recording` DISABLE KEYS */;
INSERT INTO `meeting_recording` VALUES (3,1,'/files/rec/oct_dept.mp4','2026-10-25 18:18:51');
/*!40000 ALTER TABLE `meeting_recording` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meeting_type`
--

DROP TABLE IF EXISTS `meeting_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_type` (
  `type_code` varchar(10) NOT NULL,
  `type_name` varchar(80) NOT NULL,
  `frequency_rule` varchar(100) NOT NULL,
  PRIMARY KEY (`type_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meeting_type`
--

LOCK TABLES `meeting_type` WRITE;
/*!40000 ALTER TABLE `meeting_type` DISABLE KEYS */;
INSERT INTO `meeting_type` VALUES ('DEPT','Department Meeting','MONTHLY'),('EXAM','Examination Board','ONCE_PER_SEMESTER');
/*!40000 ALTER TABLE `meeting_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meeting_type_blocked_month`
--

DROP TABLE IF EXISTS `meeting_type_blocked_month`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_type_blocked_month` (
  `type_code` varchar(10) NOT NULL,
  `blocked_month` tinyint NOT NULL,
  PRIMARY KEY (`type_code`,`blocked_month`),
  CONSTRAINT `fk_bm_type` FOREIGN KEY (`type_code`) REFERENCES `meeting_type` (`type_code`) ON DELETE CASCADE,
  CONSTRAINT `ck_month` CHECK ((`blocked_month` between 1 and 12))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meeting_type_blocked_month`
--

LOCK TABLES `meeting_type_blocked_month` WRITE;
/*!40000 ALTER TABLE `meeting_type_blocked_month` DISABLE KEYS */;
INSERT INTO `meeting_type_blocked_month` VALUES ('DEPT',4),('DEPT',12),('EXAM',8);
/*!40000 ALTER TABLE `meeting_type_blocked_month` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification`
--

DROP TABLE IF EXISTS `notification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification` (
  `notification_id` int NOT NULL AUTO_INCREMENT,
  `meeting_id` int NOT NULL,
  `staff_id` int NOT NULL,
  `delivery_status` enum('PENDING','SENT','FAILED','READ') NOT NULL DEFAULT 'PENDING',
  `scheduled_send_date` datetime NOT NULL,
  PRIMARY KEY (`notification_id`),
  KEY `fk_n_m` (`meeting_id`),
  KEY `fk_n_s` (`staff_id`),
  KEY `idx_notif_status` (`delivery_status`,`scheduled_send_date`),
  CONSTRAINT `fk_n_m` FOREIGN KEY (`meeting_id`) REFERENCES `meeting` (`meeting_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_n_s` FOREIGN KEY (`staff_id`) REFERENCES `staff` (`staff_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification`
--

LOCK TABLES `notification` WRITE;
/*!40000 ALTER TABLE `notification` DISABLE KEYS */;
INSERT INTO `notification` VALUES (1,1,1,'SENT','2026-10-26 08:00:00'),(2,1,2,'PENDING','2026-10-29 08:00:00'),(3,1,3,'PENDING','2026-10-29 08:00:00'),(4,2,2,'FAILED','2026-11-09 08:00:00');
/*!40000 ALTER TABLE `notification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schedule_plan`
--

DROP TABLE IF EXISTS `schedule_plan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `schedule_plan` (
  `schedule_id` int NOT NULL AUTO_INCREMENT,
  `academic_year` varchar(9) NOT NULL,
  `semester` tinyint NOT NULL,
  `created_by` int NOT NULL,
  PRIMARY KEY (`schedule_id`),
  UNIQUE KEY `uq_plan` (`academic_year`,`semester`),
  KEY `fk_plan_staff` (`created_by`),
  CONSTRAINT `fk_plan_staff` FOREIGN KEY (`created_by`) REFERENCES `staff` (`staff_id`),
  CONSTRAINT `ck_semester` CHECK ((`semester` between 1 and 8))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schedule_plan`
--

LOCK TABLES `schedule_plan` WRITE;
/*!40000 ALTER TABLE `schedule_plan` DISABLE KEYS */;
INSERT INTO `schedule_plan` VALUES (1,'2026/2027',1,4);
/*!40000 ALTER TABLE `schedule_plan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `staff`
--

DROP TABLE IF EXISTS `staff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff` (
  `staff_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(120) NOT NULL,
  `role` varchar(30) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  PRIMARY KEY (`staff_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `staff`
--

LOCK TABLES `staff` WRITE;
/*!40000 ALTER TABLE `staff` DISABLE KEYS */;
INSERT INTO `staff` VALUES (1,'Dr. Perera','perera@dept.lk','HOD','c592df4a86933b92addc9842402ddf198c638ea9be58916ee6e3734e1e3152f8'),(2,'Ms. Silva','silva@dept.lk','LECTURER','93915a0a4bf8f634cb1856494dd4304472ad46b9827f541f76b6761c49cc55b0'),(3,'Mr. Fernando','fernando@dept.lk','LECTURER','072aa9e9fb9d5162e465d3321530463caecd59b156676fe3071997cdc1017816'),(4,'Ms. Jayasena','jayasena@dept.lk','ADMIN','0c2e7ac34c9a4f2c9058223947a466a6a21159e2e9d9e2c6597e8b7d334ae907');
/*!40000 ALTER TABLE `staff` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_meeting_attendance`
--

DROP TABLE IF EXISTS `v_meeting_attendance`;
/*!50001 DROP VIEW IF EXISTS `v_meeting_attendance`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_meeting_attendance` AS SELECT 
 1 AS `meeting_id`,
 1 AS `meeting_name`,
 1 AS `invited`,
 1 AS `attended`,
 1 AS `attendance_percentage`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `v_meeting_attendance`
--

/*!50001 DROP VIEW IF EXISTS `v_meeting_attendance`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_meeting_attendance` AS select `m`.`meeting_id` AS `meeting_id`,`m`.`meeting_name` AS `meeting_name`,count(`a`.`log_number`) AS `invited`,sum((`a`.`attendance_status` in ('PRESENT','LATE'))) AS `attended`,round(((100 * sum((`a`.`attendance_status` in ('PRESENT','LATE')))) / nullif(count(`a`.`log_number`),0)),2) AS `attendance_percentage` from (`meeting` `m` left join `attendance_log` `a` on((`a`.`meeting_id` = `m`.`meeting_id`))) group by `m`.`meeting_id`,`m`.`meeting_name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-25 20:02:07
