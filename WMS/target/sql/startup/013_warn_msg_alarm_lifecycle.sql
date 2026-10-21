-- WCS设备异常告警生命周期字段。
-- 同一设备的同一种未消除异常只保留一条活动记录；历史已消除记录不受唯一约束影响。

SET @schema_name = DATABASE();

SELECT IF(
    EXISTS(
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'warn_msg' AND COLUMN_NAME = 'send_status'
    ),
    'SELECT ''warn_msg.send_status already exists''',
    'ALTER TABLE `warn_msg` ADD COLUMN `send_status` int NOT NULL DEFAULT 0 COMMENT ''首次告警发送状态：0-待发送，1-已发送，2-发送失败，3-无需发送'' AFTER `log_time`'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT IF(
    EXISTS(
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'warn_msg' AND COLUMN_NAME = 'clear_status'
    ),
    'SELECT ''warn_msg.clear_status already exists''',
    'ALTER TABLE `warn_msg` ADD COLUMN `clear_status` int NOT NULL DEFAULT 0 COMMENT ''告警消除状态：0-未消除，1-待通知，2-已通知，3-通知失败，4-无需通知'' AFTER `send_status`'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT IF(
    EXISTS(
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'warn_msg' AND COLUMN_NAME = 'clear_time'
    ),
    'SELECT ''warn_msg.clear_time already exists''',
    'ALTER TABLE `warn_msg` ADD COLUMN `clear_time` datetime NULL DEFAULT NULL COMMENT ''告警消除时间'' AFTER `clear_status`'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT IF(
    EXISTS(
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'warn_msg' AND COLUMN_NAME = 'active_alarm_key'
    ),
    'SELECT ''warn_msg.active_alarm_key already exists''',
    'ALTER TABLE `warn_msg` ADD COLUMN `active_alarm_key` varchar(128) NULL DEFAULT NULL COMMENT ''活动告警唯一键：设备编码和异常类型'' AFTER `clear_time`'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT IF(
    EXISTS(
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'warn_msg' AND COLUMN_NAME = 'repeat_count'
    ),
    'SELECT ''warn_msg.repeat_count already exists''',
    'ALTER TABLE `warn_msg` ADD COLUMN `repeat_count` int NOT NULL DEFAULT 1 COMMENT ''同一活动告警的重复上报次数'' AFTER `active_alarm_key`'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT IF(
    EXISTS(
        SELECT 1 FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'warn_msg' AND INDEX_NAME = 'uk_warn_msg_active_alarm_key'
    ),
    'SELECT ''warn_msg.uk_warn_msg_active_alarm_key already exists''',
    'ALTER TABLE `warn_msg` ADD UNIQUE KEY `uk_warn_msg_active_alarm_key` (`active_alarm_key`)'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
