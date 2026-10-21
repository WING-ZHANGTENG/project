-- Runtime log table. code is the device code, type is the log status code, and warn_msg is the log message.
CREATE TABLE IF NOT EXISTS `warn_msg` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '设备编码',
  `type` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '日志状态码',
  `warn_msg` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL COMMENT '日志信息',
  `log_time` datetime NULL DEFAULT NULL COMMENT '日志发生时间',
  `create_time` datetime NULL DEFAULT NULL,
  `create_user_id` bigint NULL DEFAULT NULL,
  `create_user_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `update_user_id` bigint NULL DEFAULT 0,
  `update_user_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_warn_msg_code_time` (`code`, `log_time`)
) ENGINE=InnoDB CHARACTER SET=utf8mb3 COLLATE=utf8mb3_general_ci ROW_FORMAT=DYNAMIC;

-- Existing warn_msg tables can be upgraded safely.
SET @log_time_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'warn_msg' AND column_name = 'log_time'
);
SET @sql = IF(@log_time_exists = 0,
    'ALTER TABLE warn_msg ADD COLUMN log_time datetime NULL DEFAULT NULL COMMENT ''日志发生时间'' AFTER warn_msg',
    'SELECT ''warn_msg.log_time already exists''');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @create_time_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'warn_msg' AND column_name = 'create_time'
);
SET @sql = IF(@create_time_exists = 0,
    'ALTER TABLE warn_msg ADD COLUMN create_time datetime NULL DEFAULT NULL AFTER log_time',
    'SELECT ''warn_msg.create_time already exists''');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @create_user_id_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'warn_msg' AND column_name = 'create_user_id'
);
SET @sql = IF(@create_user_id_exists = 0,
    'ALTER TABLE warn_msg ADD COLUMN create_user_id bigint NULL DEFAULT NULL AFTER create_time',
    'SELECT ''warn_msg.create_user_id already exists''');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @create_user_name_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'warn_msg' AND column_name = 'create_user_name'
);
SET @sql = IF(@create_user_name_exists = 0,
    'ALTER TABLE warn_msg ADD COLUMN create_user_name varchar(255) NULL DEFAULT NULL AFTER create_user_id',
    'SELECT ''warn_msg.create_user_name already exists''');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @update_time_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'warn_msg' AND column_name = 'update_time'
);
SET @sql = IF(@update_time_exists = 0,
    'ALTER TABLE warn_msg ADD COLUMN update_time datetime NULL DEFAULT NULL AFTER create_user_name',
    'SELECT ''warn_msg.update_time already exists''');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @update_user_id_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'warn_msg' AND column_name = 'update_user_id'
);
SET @sql = IF(@update_user_id_exists = 0,
    'ALTER TABLE warn_msg ADD COLUMN update_user_id bigint NULL DEFAULT 0 AFTER update_time',
    'SELECT ''warn_msg.update_user_id already exists''');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @update_user_name_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'warn_msg' AND column_name = 'update_user_name'
);
SET @sql = IF(@update_user_name_exists = 0,
    'ALTER TABLE warn_msg ADD COLUMN update_user_name varchar(50) NULL DEFAULT NULL AFTER update_user_id',
    'SELECT ''warn_msg.update_user_name already exists''');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @code_time_index_exists = (
    SELECT COUNT(*) FROM information_schema.statistics
    WHERE table_schema = DATABASE() AND table_name = 'warn_msg' AND index_name = 'idx_warn_msg_code_time'
);
SET @sql = IF(@code_time_index_exists = 0,
    'ALTER TABLE warn_msg ADD KEY idx_warn_msg_code_time (code, log_time)',
    'SELECT ''warn_msg.idx_warn_msg_code_time already exists''');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
