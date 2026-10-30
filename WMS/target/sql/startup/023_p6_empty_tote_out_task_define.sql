-- P6 automatic-loading tote outbound task definition.
-- Empty toteboxes are preferred; partial toteboxes are also supported for loading.

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
    'P6_LOADING_OUT',
    'P6放料出库',
    1,
    1,
    'XjHandle.p6LockOutboundSource',
    'XjHandle.p6SendTask',
    'XjHandle.finishTask',
    'XjHandle.p6FinishTask',
    'XjHandle.releaseP6OutboundSource',
    'P6'
WHERE NOT EXISTS (
    SELECT 1
    FROM task_define
    WHERE ware_code = 'P6'
      AND type = 'P6_LOADING_OUT'
      AND cmd_pre = 'XjHandle.p6LockOutboundSource'
      AND cmd = 'XjHandle.p6SendTask'
);
