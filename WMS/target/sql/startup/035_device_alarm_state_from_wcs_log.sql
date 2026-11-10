-- 设备状态改为由WCS运行日志驱动，仅保留正常/告警两态。
-- is_online字段暂时保留以兼容既有表结构和接口，但不再参与设备告警业务。

UPDATE `device_info`
SET `state` = CASE WHEN `state` = 2 THEN 2 ELSE 0 END;

ALTER TABLE `device_info`
    MODIFY COLUMN `is_online` int NOT NULL DEFAULT 0 COMMENT '兼容保留字段，设备告警业务不使用',
    MODIFY COLUMN `state` int NOT NULL DEFAULT 0 COMMENT '设备告警状态：0-正常，2-告警';

-- 设备状态不再从旧的WCS设备列表接口拉取，避免覆盖运行日志刚更新的状态。
UPDATE `sys_job`
SET `status` = '1',
    `update_by` = 'admin',
    `update_time` = NOW(),
    `remark` = '已停用：设备正常/告警状态改由WCS运行日志上报驱动'
WHERE `invoke_target` = 'DeviceWarnHandle.syncDeviceInfo';
