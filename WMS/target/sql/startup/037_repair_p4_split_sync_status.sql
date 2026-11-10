-- 修正旧逻辑在P4入库外部同步失败时仍将pallet_split.sync_flag置为1的问题。
-- 同一P1出库单只要仍有待同步或同步失败的P4 IN交易事件，其拆托记录就应保持未同步。

UPDATE `pallet_split` ps
    INNER JOIN `pick_task` pt ON pt.`pallet_code` = ps.`parent_pallet_code`
    INNER JOIN `out_master` om ON om.`out_master_id` = pt.`out_master_id`
SET ps.`sync_flag` = 0
WHERE EXISTS (
    SELECT 1
    FROM `inventory_transaction` it
    WHERE it.`out_bill_no` = om.`bill_no`
      AND it.`ware_code` = 'P4'
      AND it.`type` = 'IN'
      AND it.`need_sync` = 1
      AND it.`sync_status` IN (0, 2)
);
