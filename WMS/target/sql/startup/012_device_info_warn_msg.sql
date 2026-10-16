-- Deployment schema script for device_info and warn_msg.
-- It is idempotent and can be included in the deployment SQL sequence.

CREATE TABLE IF NOT EXISTS `device_info` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `ip` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'IP',
  `location_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'Position code',
  `is_online` int NOT NULL DEFAULT 0 COMMENT 'Online state: 0-offline, 1-online',
  `state` int NOT NULL DEFAULT 0 COMMENT 'Device state: 0-idle, 1-running, 2-fault',
  `create_time` datetime NULL DEFAULT NULL,
  `create_user_id` bigint NULL DEFAULT NULL,
  `create_user_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `update_user_id` bigint NULL DEFAULT 0,
  `update_user_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_device_info_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=1000 CHARACTER SET=utf8mb3 COLLATE=utf8mb3_general_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE IF NOT EXISTS `warn_msg` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'Device code',
  `type` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'Log status code',
  `warn_msg` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL COMMENT 'Log message',
  `log_time` datetime NULL DEFAULT NULL COMMENT 'Log time',
  `create_time` datetime NULL DEFAULT NULL,
  `create_user_id` bigint NULL DEFAULT NULL,
  `create_user_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `update_user_id` bigint NULL DEFAULT 0,
  `update_user_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_warn_msg_code_time` (`code`, `log_time`)
) ENGINE=InnoDB AUTO_INCREMENT=237 CHARACTER SET=utf8mb3 COLLATE=utf8mb3_general_ci ROW_FORMAT=DYNAMIC;

-- Add fields missing from device_info installations created before location code support.
SET @column_exists = (
  SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'device_info' AND column_name = 'location_code'
);
SET @sql = IF(
  @column_exists = 0,
  'ALTER TABLE device_info ADD COLUMN location_code varchar(255) NULL DEFAULT NULL COMMENT ''Position code'' AFTER ip',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @index_exists = (
  SELECT COUNT(*) FROM information_schema.statistics
  WHERE table_schema = DATABASE() AND table_name = 'device_info' AND index_name = 'idx_device_info_code'
);
SET @sql = IF(
  @index_exists = 0,
  'ALTER TABLE device_info ADD KEY idx_device_info_code (code)',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add fields missing from the original warn_msg table used by WCS log reporting.
SET @column_exists = (
  SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'warn_msg' AND column_name = 'log_time'
);
SET @sql = IF(
  @column_exists = 0,
  'ALTER TABLE warn_msg ADD COLUMN log_time datetime NULL DEFAULT NULL COMMENT ''Log time'' AFTER warn_msg',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @column_exists = (
  SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'warn_msg' AND column_name = 'create_time'
);
SET @sql = IF(
  @column_exists = 0,
  'ALTER TABLE warn_msg ADD COLUMN create_time datetime NULL DEFAULT NULL AFTER log_time',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @column_exists = (
  SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'warn_msg' AND column_name = 'create_user_id'
);
SET @sql = IF(
  @column_exists = 0,
  'ALTER TABLE warn_msg ADD COLUMN create_user_id bigint NULL DEFAULT NULL AFTER create_time',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @column_exists = (
  SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'warn_msg' AND column_name = 'create_user_name'
);
SET @sql = IF(
  @column_exists = 0,
  'ALTER TABLE warn_msg ADD COLUMN create_user_name varchar(255) NULL DEFAULT NULL AFTER create_user_id',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @column_exists = (
  SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'warn_msg' AND column_name = 'update_time'
);
SET @sql = IF(
  @column_exists = 0,
  'ALTER TABLE warn_msg ADD COLUMN update_time datetime NULL DEFAULT NULL AFTER create_user_name',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @column_exists = (
  SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'warn_msg' AND column_name = 'update_user_id'
);
SET @sql = IF(
  @column_exists = 0,
  'ALTER TABLE warn_msg ADD COLUMN update_user_id bigint NULL DEFAULT 0 AFTER update_time',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @column_exists = (
  SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'warn_msg' AND column_name = 'update_user_name'
);
SET @sql = IF(
  @column_exists = 0,
  'ALTER TABLE warn_msg ADD COLUMN update_user_name varchar(50) NULL DEFAULT NULL AFTER update_user_id',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @index_exists = (
  SELECT COUNT(*) FROM information_schema.statistics
  WHERE table_schema = DATABASE() AND table_name = 'warn_msg' AND index_name = 'idx_warn_msg_code_time'
);
SET @sql = IF(
  @index_exists = 0,
  'ALTER TABLE warn_msg ADD KEY idx_warn_msg_code_time (code, log_time)',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
