-- Migrate active Spring @Scheduled jobs to the clustered Quartz scheduler.
--
-- Select the target schema before running this script:
--   Local:      USE `deer_wms_xj`;
--   Production: USE `wms`;
--
-- All jobs are inserted PAUSED (status = '1') and must be enabled from the
-- scheduled-task administration page after the new application version is deployed.
-- job_id is intentionally omitted because it is an AUTO_INCREMENT primary key.

SELECT DATABASE() AS target_schema;

START TRANSACTION;

INSERT INTO `sys_job`
    (`job_name`, `job_group`, `invoke_target`, `cron_expression`, `misfire_policy`, `concurrent`, `status`,
     `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
SELECT
    'P1库存事务同步', 'DEFAULT', 'XjRecordType.autoRun', '0/1 * * * * ?', '3', '1', '1',
    'admin', NOW(), 'admin', NOW(), '由Spring @Scheduled迁移；Quartz集群禁止并发'
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `sys_job` WHERE `invoke_target` = 'XjRecordType.autoRun'
);

INSERT INTO `sys_job`
    (`job_name`, `job_group`, `invoke_target`, `cron_expression`, `misfire_policy`, `concurrent`, `status`,
     `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
SELECT
    'P1 Pending事务重试', 'DEFAULT', 'XjRecordType.retryPendingP1Transactions', '0/30 * * * * ?', '3', '1', '1',
    'admin', NOW(), 'admin', NOW(), '由Spring @Scheduled迁移；Quartz集群禁止并发'
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `sys_job` WHERE `invoke_target` = 'XjRecordType.retryPendingP1Transactions'
);

INSERT INTO `sys_job`
    (`job_name`, `job_group`, `invoke_target`, `cron_expression`, `misfire_policy`, `concurrent`, `status`,
     `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
SELECT
    'P4库存事务同步', 'DEFAULT', 'XjRecordType.requestP4Inventory', '0/1 * * * * ?', '3', '1', '1',
    'admin', NOW(), 'admin', NOW(), '由Spring @Scheduled迁移；Quartz集群禁止并发'
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `sys_job` WHERE `invoke_target` = 'XjRecordType.requestP4Inventory'
);

INSERT INTO `sys_job`
    (`job_name`, `job_group`, `invoke_target`, `cron_expression`, `misfire_policy`, `concurrent`, `status`,
     `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
SELECT
    'P9库存请求', 'DEFAULT', 'XjRecordType.requestP9Inventory', '0/2 * * * * ?', '3', '1', '1',
    'admin', NOW(), 'admin', NOW(), '由Spring @Scheduled迁移；Quartz集群禁止并发'
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `sys_job` WHERE `invoke_target` = 'XjRecordType.requestP9Inventory'
);

INSERT INTO `sys_job`
    (`job_name`, `job_group`, `invoke_target`, `cron_expression`, `misfire_policy`, `concurrent`, `status`,
     `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
SELECT
    '货位线体位置状态清理', 'DEFAULT', 'cellState.setCellTaskState', '0/1 * * * * ?', '3', '1', '1',
    'admin', NOW(), 'admin', NOW(), '由Spring @Scheduled迁移；Quartz集群禁止并发'
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `sys_job` WHERE `invoke_target` = 'cellState.setCellTaskState'
);

INSERT INTO `sys_job`
    (`job_name`, `job_group`, `invoke_target`, `cron_expression`, `misfire_policy`, `concurrent`, `status`,
     `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
SELECT
    '自动生成盘点任务', 'DEFAULT', 'AutoPdTask.autoPd', '0/1 * * * * ?', '3', '1', '1',
    'admin', NOW(), 'admin', NOW(), '由Spring @Scheduled迁移；Quartz集群禁止并发'
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `sys_job` WHERE `invoke_target` = 'AutoPdTask.autoPd'
);

INSERT INTO `sys_job`
    (`job_name`, `job_group`, `invoke_target`, `cron_expression`, `misfire_policy`, `concurrent`, `status`,
     `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
SELECT
    'XJ货位任务状态清理', 'DEFAULT', 'XjHandle.setCellTaskState', '0/2 * * * * ?', '3', '1', '1',
    'admin', NOW(), 'admin', NOW(), '由Spring @Scheduled迁移；Quartz集群禁止并发'
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `sys_job` WHERE `invoke_target` = 'XjHandle.setCellTaskState'
);

INSERT INTO `sys_job`
    (`job_name`, `job_group`, `invoke_target`, `cron_expression`, `misfire_policy`, `concurrent`, `status`,
     `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
SELECT
    'WCS设备信息同步', 'DEFAULT', 'DeviceWarnHandle.syncDeviceInfo', '0/15 * * * * ?', '3', '1', '1',
    'admin', NOW(), 'admin', NOW(), '由Spring @Scheduled迁移；Quartz集群禁止并发'
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `sys_job` WHERE `invoke_target` = 'DeviceWarnHandle.syncDeviceInfo'
);

INSERT INTO `sys_job`
    (`job_name`, `job_group`, `invoke_target`, `cron_expression`, `misfire_policy`, `concurrent`, `status`,
     `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
SELECT
    '接口记录归档', 'DEFAULT', 'interfaceRecordArchiveTask.archiveExpiredRecords', '0 20 2 * * ?', '2', '1', '1',
    'admin', NOW(), 'admin', NOW(), '每日02:20执行；停机错过后补执行一次'
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `sys_job` WHERE `invoke_target` = 'interfaceRecordArchiveTask.archiveExpiredRecords'
);

COMMIT;

SELECT
    `job_id`,
    `job_name`,
    `job_group`,
    `invoke_target`,
    `cron_expression`,
    `misfire_policy`,
    `concurrent`,
    `status`
FROM `sys_job`
WHERE `invoke_target` IN (
    'XjRecordType.autoRun',
    'XjRecordType.retryPendingP1Transactions',
    'XjRecordType.requestP4Inventory',
    'XjRecordType.requestP9Inventory',
    'cellState.setCellTaskState',
    'AutoPdTask.autoPd',
    'XjHandle.setCellTaskState',
    'DeviceWarnHandle.syncDeviceInfo',
    'interfaceRecordArchiveTask.archiveExpiredRecords'
)
ORDER BY `job_id`;
