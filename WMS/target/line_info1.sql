/*
 Navicat Premium Dump SQL

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 80046 (8.0.46)
 Source Host           : localhost:3306
 Source Schema         : deer_wms_xj

 Target Server Type    : MySQL
 Target Server Version : 80046 (8.0.46)
 File Encoding         : 65001

 Date: 26/08/2026 10:17:47
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for line_info
-- ----------------------------
DROP TABLE IF EXISTS `line_info`;
CREATE TABLE `line_info`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `type` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0' COMMENT '0-堆垛机巷道 1-四向车通道',
  `ware_code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ware_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `area_code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `area_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `inven_state` int NOT NULL DEFAULT 0,
  `task_state` int NOT NULL DEFAULT 0,
  `disable_state` int NOT NULL DEFAULT 0,
  `is_delete` int NOT NULL DEFAULT 0,
  `version` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '1',
  `create_time` datetime NULL DEFAULT NULL,
  `create_user_id` bigint NULL DEFAULT NULL,
  `create_user_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `update_user_id` bigint NULL DEFAULT NULL,
  `update_user_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `max_y` int NULL DEFAULT NULL,
  `min_y` int NULL DEFAULT NULL,
  `max_z` int NULL DEFAULT NULL,
  `model_data` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL,
  `start_direction` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of line_info
-- ----------------------------
INSERT INTO `line_info` VALUES (1, 'P4-1', 'P4-1', 'line', 'P4', 'P4', 'P4', 'P4', 0, 0, 0, 0, '45', '2026-05-09 13:53:08', 1, 'admin', NULL, NULL, NULL, 29, NULL, 6, 'crn1', NULL);
INSERT INTO `line_info` VALUES (2, 'P4-2', 'P4-2', 'line', 'P4', 'P4', 'P4', 'P4', 0, 0, 0, 0, '94', '2026-08-06 08:57:13', 1, 'admin', NULL, NULL, NULL, 29, NULL, 6, 'crn2', NULL);
INSERT INTO `line_info` VALUES (3, 'P4-3', 'P4-3', 'line', 'P4', 'P4', 'P4', 'P4', 0, 0, 0, 0, '0', '2026-08-06 08:57:42', 1, 'admin', NULL, NULL, NULL, 29, NULL, 6, 'crn3', NULL);

SET FOREIGN_KEY_CHECKS = 1;
