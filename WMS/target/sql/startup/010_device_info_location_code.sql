-- New device_info table definition used by the WCS device synchronization.
CREATE TABLE IF NOT EXISTS `device_info` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `ip` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'IP',
  `location_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '位置编码',
  `is_online` int NOT NULL DEFAULT 0 COMMENT '是否在线 0-否 1-是',
  `state` int NOT NULL DEFAULT 0 COMMENT '0-空闲 1-运行中 2-故障',
  `create_time` datetime NULL DEFAULT NULL,
  `create_user_id` bigint NULL DEFAULT NULL,
  `create_user_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `update_user_id` bigint NULL DEFAULT 0,
  `update_user_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_device_info_code` (`code`)
) ENGINE=InnoDB CHARACTER SET=utf8mb3 COLLATE=utf8mb3_general_ci ROW_FORMAT=DYNAMIC;

-- Upgrade an existing device_info table without failing if location_code already exists.
SET @column_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'device_info' AND column_name = 'location_code'
);
SET @sql = IF(
    @column_exists = 0,
    'ALTER TABLE device_info ADD COLUMN location_code varchar(255) NULL DEFAULT NULL COMMENT ''位置编码'' AFTER ip',
    'SELECT ''device_info.location_code already exists'''
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
