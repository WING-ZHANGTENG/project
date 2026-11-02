-- P6 manual picking task definition. The destination is read from
-- xj.p6.outbound.picking-to-cell-code when XjHandle creates the TaskInfo.

INSERT INTO task_define (
    type,
    job_name,
    job_index,
    wcs_task_type,
    cmd_pre,
    cmd,
    success_pre,
    success,
    delete_pre,
    ware_code
)
SELECT
    'P6_PICKING_OUT',
    'P6取货出库',
    1,
    1,
    'XjHandle.p6LockOutboundSource',
    'XjHandle.p6SendPickingTask',
    'XjHandle.finishTask',
    'XjHandle.p6FinishTask',
    'XjHandle.releaseP6OutboundSource',
    'P6'
WHERE NOT EXISTS (
    SELECT 1
    FROM task_define
    WHERE ware_code = 'P6'
      AND type = 'P6_PICKING_OUT'
      AND cmd_pre = 'XjHandle.p6LockOutboundSource'
      AND cmd = 'XjHandle.p6SendPickingTask'
);
