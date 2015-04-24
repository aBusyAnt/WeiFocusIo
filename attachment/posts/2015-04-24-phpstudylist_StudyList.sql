/*
 Navicat Premium Data Transfer

 Source Server         : 218.244.147.49
 Source Server Type    : MySQL
 Source Server Version : 50173
 Source Host           : 218.244.147.49
 Source Database       : StudyList

 Target Server Type    : MySQL
 Target Server Version : 50173
 File Encoding         : utf-8

 Date: 04/24/2015 17:06:51 PM
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Table structure for `Attachment`
-- ----------------------------
DROP TABLE IF EXISTS `Attachment`;
CREATE TABLE `Attachment` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `courseId` int(11) unsigned NOT NULL,
  `url` varchar(255) NOT NULL DEFAULT '',
  `type` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `courseId` (`courseId`),
  CONSTRAINT `Attachment_ibfk_1` FOREIGN KEY (`courseId`) REFERENCES `Course` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `Comment`
-- ----------------------------
DROP TABLE IF EXISTS `Comment`;
CREATE TABLE `Comment` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `courseId` int(11) unsigned NOT NULL,
  `userId` int(11) unsigned NOT NULL,
  `content` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `courseId` (`courseId`),
  KEY `userId` (`userId`),
  CONSTRAINT `Comment_ibfk_1` FOREIGN KEY (`courseId`) REFERENCES `Course` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `Comment_ibfk_2` FOREIGN KEY (`userId`) REFERENCES `User` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `Course`
-- ----------------------------
DROP TABLE IF EXISTS `Course`;
CREATE TABLE `Course` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL DEFAULT '',
  `speechMakerId` int(11) unsigned NOT NULL,
  `authorId` int(11) unsigned NOT NULL,
  `createdTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `planTime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  KEY `authorId` (`authorId`),
  KEY `speechMakerId` (`speechMakerId`),
  CONSTRAINT `Course_ibfk_1` FOREIGN KEY (`authorId`) REFERENCES `User` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `Course_ibfk_2` FOREIGN KEY (`speechMakerId`) REFERENCES `User` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `Pv`
-- ----------------------------
DROP TABLE IF EXISTS `Pv`;
CREATE TABLE `Pv` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `courseId` int(11) unsigned NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `userId` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `courseId` (`courseId`),
  KEY `userId` (`userId`),
  CONSTRAINT `Pv_ibfk_1` FOREIGN KEY (`courseId`) REFERENCES `Course` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `Pv_ibfk_2` FOREIGN KEY (`userId`) REFERENCES `User` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `Role`
-- ----------------------------
DROP TABLE IF EXISTS `Role`;
CREATE TABLE `Role` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL DEFAULT '',
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `Tag`
-- ----------------------------
DROP TABLE IF EXISTS `Tag`;
CREATE TABLE `Tag` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `courseId` int(11) unsigned NOT NULL,
  `title` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `courseId` (`courseId`),
  CONSTRAINT `Tag_ibfk_1` FOREIGN KEY (`courseId`) REFERENCES `Course` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `Team`
-- ----------------------------
DROP TABLE IF EXISTS `Team`;
CREATE TABLE `Team` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL DEFAULT '',
  `description` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `User`
-- ----------------------------
DROP TABLE IF EXISTS `User`;
CREATE TABLE `User` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` char(255) NOT NULL DEFAULT '',
  `password` char(32) NOT NULL DEFAULT '',
  `createdOn` timestamp NULL DEFAULT NULL,
  `teamId` int(11) unsigned NOT NULL,
  `roleId` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `teamId` (`teamId`),
  KEY `roleId` (`roleId`),
  CONSTRAINT `User_ibfk_1` FOREIGN KEY (`teamId`) REFERENCES `Team` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `User_ibfk_2` FOREIGN KEY (`roleId`) REFERENCES `Role` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

SET FOREIGN_KEY_CHECKS = 1;
