-- P4不拆托直接入库只记录库存交易事件，不同步外部系统。
-- 仅修正尚未同步且没有关联P1出库单的历史入库事件。

UPDATE `inventory_transaction`
SET `need_sync` = 0,
    `update_time` = NOW()
WHERE `ware_code` = 'P4'
  AND `type` = 'IN'
  AND `need_sync` = 1
  AND `sync_status` = 0
  AND (`out_bill_no` IS NULL OR TRIM(`out_bill_no`) = '');
