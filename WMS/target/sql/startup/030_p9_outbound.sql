-- P9 outbound lifecycle, configuration, dictionary, Quartz jobs and task definition.
-- This file is startup-safe and can be executed repeatedly.

SET @schema_name = DATABASE();

-- p9_carton_info was introduced by 029. Keep this CREATE for deployments whose
-- startup markers were copied without the corresponding schema change.
CREATE TABLE IF NOT EXISTS `p9_carton_info` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `pallet_code` varchar(255) NOT NULL COMMENT 'WMS pallet/carton code',
  `carton_code` varchar(255) NOT NULL COMMENT 'original carton code',
  `ware_code` varchar(50) NOT NULL DEFAULT 'P9',
  `source_status` varchar(50) DEFAULT NULL,
  `message` text,
  `ccust` varchar(255) DEFAULT NULL,
  `mdl` varchar(255) DEFAULT NULL,
  `rqty` decimal(18,4) DEFAULT NULL,
  `dqty` decimal(18,4) DEFAULT NULL,
  `pn` varchar(255) DEFAULT NULL,
  `ag` varchar(255) DEFAULT NULL,
  `grpdesc` varchar(1000) DEFAULT NULL,
  `flow_status` varchar(50) NOT NULL,
  `query_success` int NOT NULL DEFAULT 0,
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_p9_carton_code` (`carton_code`),
  KEY `idx_p9_pallet_code` (`pallet_code`),
  KEY `idx_p9_flow_status` (`flow_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Add one column at a time so a partially applied startup script can resume safely.
SELECT IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@schema_name AND TABLE_NAME='p9_carton_info' AND COLUMN_NAME='cell_code'),
  'SELECT ''skip p9_carton_info.cell_code''',
  'ALTER TABLE p9_carton_info ADD COLUMN cell_code varchar(100) DEFAULT NULL COMMENT ''source cell'' AFTER ware_code') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@schema_name AND TABLE_NAME='p9_carton_info' AND COLUMN_NAME='line_code'),
  'SELECT ''skip p9_carton_info.line_code''',
  'ALTER TABLE p9_carton_info ADD COLUMN line_code varchar(100) DEFAULT NULL COMMENT ''source aisle'' AFTER cell_code') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@schema_name AND TABLE_NAME='p9_carton_info' AND COLUMN_NAME='validation_token'),
  'SELECT ''skip p9_carton_info.validation_token''',
  'ALTER TABLE p9_carton_info ADD COLUMN validation_token varchar(64) DEFAULT NULL COMMENT ''atomic batch validation claim'' AFTER query_success') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@schema_name AND TABLE_NAME='p9_carton_info' AND COLUMN_NAME='outbound_batch_no'),
  'SELECT ''skip p9_carton_info.outbound_batch_no''',
  'ALTER TABLE p9_carton_info ADD COLUMN outbound_batch_no varchar(64) DEFAULT NULL COMMENT ''P9 outbound batch'' AFTER validation_token') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@schema_name AND TABLE_NAME='p9_carton_info' AND COLUMN_NAME='outbound_sequence'),
  'SELECT ''skip p9_carton_info.outbound_sequence''',
  'ALTER TABLE p9_carton_info ADD COLUMN outbound_sequence int DEFAULT NULL COMMENT ''strict Seagate outbound order'' AFTER outbound_batch_no') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@schema_name AND TABLE_NAME='p9_carton_info' AND COLUMN_NAME='out_master_id'),
  'SELECT ''skip p9_carton_info.out_master_id''',
  'ALTER TABLE p9_carton_info ADD COLUMN out_master_id bigint DEFAULT NULL AFTER outbound_sequence') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@schema_name AND TABLE_NAME='p9_carton_info' AND COLUMN_NAME='out_detail_id'),
  'SELECT ''skip p9_carton_info.out_detail_id''',
  'ALTER TABLE p9_carton_info ADD COLUMN out_detail_id bigint DEFAULT NULL AFTER out_master_id') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@schema_name AND TABLE_NAME='p9_carton_info' AND COLUMN_NAME='pick_task_id'),
  'SELECT ''skip p9_carton_info.pick_task_id''',
  'ALTER TABLE p9_carton_info ADD COLUMN pick_task_id bigint DEFAULT NULL AFTER out_detail_id') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@schema_name AND TABLE_NAME='p9_carton_info' AND COLUMN_NAME='task_info_id'),
  'SELECT ''skip p9_carton_info.task_info_id''',
  'ALTER TABLE p9_carton_info ADD COLUMN task_info_id bigint DEFAULT NULL AFTER pick_task_id') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@schema_name AND TABLE_NAME='p9_carton_info' AND COLUMN_NAME='flow_message'),
  'SELECT ''skip p9_carton_info.flow_message''',
  'ALTER TABLE p9_carton_info ADD COLUMN flow_message varchar(1000) DEFAULT NULL COMMENT ''lifecycle failure/detail'' AFTER task_info_id') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@schema_name AND TABLE_NAME='p9_carton_info' AND COLUMN_NAME='branch_scan_time'),
  'SELECT ''skip p9_carton_info.branch_scan_time''',
  'ALTER TABLE p9_carton_info ADD COLUMN branch_scan_time datetime DEFAULT NULL AFTER flow_message') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@schema_name AND TABLE_NAME='p9_carton_info' AND COLUMN_NAME='branch_exit_time'),
  'SELECT ''skip p9_carton_info.branch_exit_time''',
  'ALTER TABLE p9_carton_info ADD COLUMN branch_exit_time datetime DEFAULT NULL AFTER branch_scan_time') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@schema_name AND TABLE_NAME='p9_carton_info' AND COLUMN_NAME='mainline_time'),
  'SELECT ''skip p9_carton_info.mainline_time''',
  'ALTER TABLE p9_carton_info ADD COLUMN mainline_time datetime DEFAULT NULL AFTER branch_exit_time') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@schema_name AND TABLE_NAME='p9_carton_info' AND COLUMN_NAME='palletized_time'),
  'SELECT ''skip p9_carton_info.palletized_time''',
  'ALTER TABLE p9_carton_info ADD COLUMN palletized_time datetime DEFAULT NULL AFTER mainline_time') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@schema_name AND TABLE_NAME='p9_carton_info' AND COLUMN_NAME='p1_in_time'),
  'SELECT ''skip p9_carton_info.p1_in_time''',
  'ALTER TABLE p9_carton_info ADD COLUMN p1_in_time datetime DEFAULT NULL AFTER palletized_time') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Backfill aisle information for P9 cartons received before this upgrade.
UPDATE p9_carton_info p
INNER JOIN pallet_info pi ON pi.ware_code='P9' AND pi.code=p.pallet_code
LEFT JOIN cell_info c ON c.ware_code='P9' AND c.code=pi.cell_code
SET p.cell_code=COALESCE(p.cell_code,pi.cell_code),
    p.line_code=COALESCE(p.line_code,c.line_code),
    p.update_time=COALESCE(p.update_time,NOW())
WHERE p.cell_code IS NULL OR p.line_code IS NULL;

SELECT IF(EXISTS(SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=@schema_name AND TABLE_NAME='p9_carton_info' AND INDEX_NAME='idx_p9_flow_pn_ag'),
  'SELECT ''skip idx_p9_flow_pn_ag''',
  'ALTER TABLE p9_carton_info ADD INDEX idx_p9_flow_pn_ag (flow_status,pn,ag)') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS(SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=@schema_name AND TABLE_NAME='p9_carton_info' AND INDEX_NAME='idx_p9_batch_sequence'),
  'SELECT ''skip idx_p9_batch_sequence''',
  'ALTER TABLE p9_carton_info ADD INDEX idx_p9_batch_sequence (outbound_batch_no,outbound_sequence)') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS(SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=@schema_name AND TABLE_NAME='p9_carton_info' AND INDEX_NAME='idx_p9_line_flow'),
  'SELECT ''skip idx_p9_line_flow''',
  'ALTER TABLE p9_carton_info ADD INDEX idx_p9_line_flow (line_code,flow_status)') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS(SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=@schema_name AND TABLE_NAME='p9_carton_info' AND INDEX_NAME='uk_p9_batch_sequence'),
  'SELECT ''skip uk_p9_batch_sequence''',
  'ALTER TABLE p9_carton_info ADD UNIQUE INDEX uk_p9_batch_sequence (outbound_batch_no,outbound_sequence)') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS(SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=@schema_name AND TABLE_NAME='p9_carton_info' AND INDEX_NAME='idx_p9_task_info'),
  'SELECT ''skip idx_p9_task_info''',
  'ALTER TABLE p9_carton_info ADD INDEX idx_p9_task_info (task_info_id)') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS(SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=@schema_name AND TABLE_NAME='p9_carton_info' AND INDEX_NAME='idx_p9_archive'),
  'SELECT ''skip idx_p9_archive''',
  'ALTER TABLE p9_carton_info ADD INDEX idx_p9_archive (flow_status,p1_in_time)') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

CREATE TABLE IF NOT EXISTS p9_carton_info_history LIKE p9_carton_info;

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT 'P9每批出库箱数', 'p9.outbound.batch-size', '40', 'N', 'admin', NOW(), '同PN和AG必须凑满该数量才批量校验'
WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key='p9.outbound.batch-size');

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT 'P9每条支线缓存箱数', 'p9.outbound.branch-waiting-capacity', '2', 'N', 'admin', NOW(), '等待支线扫码及等待按序排出的最大合计数量'
WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key='p9.outbound.branch-waiting-capacity');

-- Existing dictionary code exposes one label. Add the English label used by the language switch.
SELECT IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@schema_name AND TABLE_NAME='sys_dict_data' AND COLUMN_NAME='dict_label_en'),
  'SELECT ''skip sys_dict_data.dict_label_en''',
  'ALTER TABLE sys_dict_data ADD COLUMN dict_label_en varchar(100) DEFAULT NULL COMMENT ''English dictionary label'' AFTER dict_label') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

INSERT INTO sys_dict_type (dict_name, dict_type, status, create_by, create_time, remark)
SELECT 'P9箱子流转状态', 'p9_flow_status', '0', 'admin', NOW(), 'P9 carton lifecycle status'
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE dict_type='p9_flow_status');

INSERT INTO sys_dict_data (dict_sort,dict_label,dict_label_en,dict_value,dict_type,list_class,is_default,status,create_by,create_time,remark)
SELECT v.sort_no,v.zh,v.en,v.code,'p9_flow_status',v.css,'N','0','admin',NOW(),'P9 flow status'
FROM (
 SELECT 1 sort_no,'失败' zh,'Failed' en,'FAILED' code,'danger' css UNION ALL
 SELECT 2,'库中','In Stock','IN_STOCK','success' UNION ALL
 SELECT 3,'批量校验中','Batch Validating','BATCH_VALIDATING','warning' UNION ALL
 SELECT 4,'待出库','Ready for Outbound','READY_OUTBOUND','primary' UNION ALL
 SELECT 5,'等待支线扫码','Waiting for Branch Scan','WAITING_BRANCH_SCAN','warning' UNION ALL
 SELECT 6,'出口已扫码等待按序排出','Exit Scanned, Waiting for Sequence','WAITING_SEQUENCE_RELEASE','warning' UNION ALL
 SELECT 7,'已排出支线','Exited Branch Line','OUTBOUND','primary' UNION ALL
 SELECT 8,'已进入主线','Entered Main Line','ENTERED_MAINLINE','success' UNION ALL
 SELECT 9,'已码垛','Palletized','PALLETIZED','success' UNION ALL
 SELECT 10,'已组盘入库P1','Palletized and Stored in P1','PALLETIZED_IN_P1','success'
) v
WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data d WHERE d.dict_type='p9_flow_status' AND d.dict_value=v.code);

INSERT INTO sys_job
 (job_name,job_group,invoke_target,cron_expression,misfire_policy,concurrent,status,create_by,create_time,update_by,update_time,remark)
SELECT 'P9自动凑批与出库','DEFAULT','p9OutboundTask.autoOutbound','0/10 * * * * ?','3','1','0','admin',NOW(),'admin',NOW(),'每10秒运行；Quartz集群禁止并发'
WHERE NOT EXISTS (SELECT 1 FROM sys_job WHERE invoke_target='p9OutboundTask.autoOutbound');

INSERT INTO sys_job
 (job_name,job_group,invoke_target,cron_expression,misfire_policy,concurrent,status,create_by,create_time,update_by,update_time,remark)
SELECT 'P9箱子历史归档','DEFAULT','p9OutboundTask.archive','0 0 3 * * ?','2','1','0','admin',NOW(),'admin',NOW(),'每日03:00归档进入P1超过24小时的数据并清理三个月前历史'
WHERE NOT EXISTS (SELECT 1 FROM sys_job WHERE invoke_target='p9OutboundTask.archive');

INSERT INTO task_define
 (type,job_name,job_index,wcs_task_type,cmd_pre,cmd,success_pre,success,delete_pre,ware_code)
SELECT 'P9_OUT','P9成品箱出库',1,1,'XjHandle.p9LockOutboundSource','XjHandle.p9SendTask',
       'XjHandle.finishTask;XjHandle.p9EnteredMainline','XjHandle.p9FinishTask','XjHandle.p9ReleaseOutboundSource','P9'
WHERE NOT EXISTS (SELECT 1 FROM task_define WHERE ware_code='P9' AND type='P9_OUT' AND job_index=1);
