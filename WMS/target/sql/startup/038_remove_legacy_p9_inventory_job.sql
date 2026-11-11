-- P9入库已在WCS入库回调中同步查询箱信息并创建库存。
-- 删除旧的异步库存请求任务，避免误启用后重复请求并重复生成库存交易事件。
DELETE FROM `sys_job`
WHERE `invoke_target` = 'XjRecordType.requestP9Inventory';
