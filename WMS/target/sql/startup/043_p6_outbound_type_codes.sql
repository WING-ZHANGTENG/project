-- Normalize outbound-order types to stable English codes.

UPDATE out_master
SET type = 'P4_MATERIAL_OUT'
WHERE ware_code = 'P4'
  AND type IN ('P4领料出库', 'P4 Material Picking Outbound');

UPDATE out_master
SET type = 'P4_MANUAL_OUT'
WHERE ware_code = 'P4'
  AND type = 'P4 Manual Outbound';

UPDATE out_master
SET type = 'P4_BUTTON_OUT'
WHERE ware_code = 'P4'
  AND type = 'P4 Button Outbound';

-- Repair pending P6 orders created by earlier versions so that XjHandle can
-- continue choosing the correct loading or picking destination.

UPDATE out_master
SET type = 'P6_LOADING_OUT'
WHERE ware_code = 'P6'
  AND type IN ('P6放料出库', 'P6 Loading Outbound');

UPDATE out_master
SET type = 'P6_PICKING_OUT'
WHERE ware_code = 'P6'
  AND type IN ('P6取货出库', 'P6 Picking Outbound');

UPDATE task_define
SET job_name = 'P6 Loading Outbound'
WHERE ware_code = 'P6'
  AND type = 'P6_LOADING_OUT';

UPDATE task_define
SET job_name = 'P6 Picking Outbound'
WHERE ware_code = 'P6'
  AND type = 'P6_PICKING_OUT';
