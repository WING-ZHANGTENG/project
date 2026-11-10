-- Clean redundant pallet_info rows that occupy the same warehouse cell.
-- The task physically deletes redundant pallet records and never deletes inventory.
-- The job is enabled and runs through clustered Quartz every 20 seconds.

INSERT INTO sys_job
    (job_name, job_group, invoke_target, cron_expression, misfire_policy, concurrent, status,
     create_by, create_time, update_by, update_time, remark)
SELECT
    '托盘库位一致性检查',
    'DEFAULT',
    'palletCellConsistencyTask.cleanDuplicatePallets',
    '0/20 * * * * ?',
    '3',
    '0',
    '1',
    'admin',
    NOW(),
    'admin',
    NOW(),
    '每20秒检查同仓库同库位的重复托盘；仅物理删除冗余托盘记录，不删除库存'
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1
    FROM sys_job
    WHERE invoke_target = 'palletCellConsistencyTask.cleanDuplicatePallets'
);
