-- device_info 和 warn_msg 部署建表脚本。
-- 表已存在时不进行任何修改；已部署环境的字段升级由后续编号脚本处理。

CREATE TABLE IF NOT EXISTS `device_info` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `ip` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `location_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '位置编码',
  `is_online` int NOT NULL DEFAULT 0 COMMENT '是否在线：0-否，1-是',
  `state` int NOT NULL DEFAULT 0 COMMENT '设备状态：0-空闲，1-运行中，2-故障',
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
  `code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '设备编码',
  `type` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '日志状态码',
  `warn_msg` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL COMMENT '日志信息',
  `log_time` datetime NULL DEFAULT NULL COMMENT '日志时间',
  `send_status` int NOT NULL DEFAULT 0 COMMENT '首次告警发送状态：0-待发送，1-已发送，2-发送失败，3-无需发送',
  `clear_status` int NOT NULL DEFAULT 0 COMMENT '告警消除状态：0-未消除，1-待通知，2-已通知，3-通知失败，4-无需通知',
  `clear_time` datetime NULL DEFAULT NULL COMMENT '告警消除时间',
  `active_alarm_key` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '活动告警唯一键：设备编码和异常类型',
  `repeat_count` int NOT NULL DEFAULT 1 COMMENT '同一活动告警的重复上报次数',
  `create_time` datetime NULL DEFAULT NULL,
  `create_user_id` bigint NULL DEFAULT NULL,
  `create_user_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `update_user_id` bigint NULL DEFAULT 0,
  `update_user_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_warn_msg_code_time` (`code`, `log_time`),
  UNIQUE KEY `uk_warn_msg_active_alarm_key` (`active_alarm_key`)
) ENGINE=InnoDB AUTO_INCREMENT=237 CHARACTER SET=utf8mb3 COLLATE=utf8mb3_general_ci ROW_FORMAT=DYNAMIC;
