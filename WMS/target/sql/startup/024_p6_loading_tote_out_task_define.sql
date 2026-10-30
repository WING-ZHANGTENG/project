-- Upgrade deployments that already installed the original P6 empty-tote task definition.
-- The same physical auto-loading machine can now receive either an empty or a partial totebox.

UPDATE task_define
SET type = 'P6_LOADING_OUT',
    job_name = 'P6放料出库'
WHERE ware_code = 'P6'
  AND type = 'P6_EMPTY_OUT'
  AND cmd_pre = 'XjHandle.p6LockOutboundSource'
  AND cmd = 'XjHandle.p6SendTask'
  AND success_pre = 'XjHandle.finishTask'
  AND success = 'XjHandle.p6FinishTask';
