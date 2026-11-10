-- WCS仅使用200表示正常、601表示告警，活动告警改为按“设备编码 + warnMsg”区分。
-- active_alarm_key保存SHA-256摘要，避免长告警内容超过字段和唯一索引长度。

UPDATE `warn_msg`
SET `active_alarm_key` = SHA2(CONCAT(`code`, CHAR(31), TRIM(`warn_msg`)), 256)
WHERE `active_alarm_key` IS NOT NULL
  AND `clear_status` = 0;

ALTER TABLE `warn_msg`
    MODIFY COLUMN `active_alarm_key` varchar(128) NULL DEFAULT NULL
    COMMENT '活动告警唯一键：设备编码和告警内容的SHA-256摘要';
