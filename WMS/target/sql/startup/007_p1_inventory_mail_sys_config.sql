-- P1 inventory email settings are maintained in sys_config so changes apply without restarting.
-- Scheduling is maintained separately in sys_job using p1InventoryMailTask.sendP1InventoryMail().

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT 'P1库存邮件仓库编码', 'xj.mail.p1Inventory.wareCode', 'P1', 'N', 'admin', NOW(), 'P1库存邮件导出仓库'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_config WHERE config_key = 'xj.mail.p1Inventory.wareCode'
);

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT 'P1库存邮件报表名称', 'xj.mail.p1Inventory.reportName', 'P1 warehouse inventory details', 'N', 'admin', NOW(), 'P1库存邮件附件名称和Excel工作表名称'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_config WHERE config_key = 'xj.mail.p1Inventory.reportName'
);

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT 'P1库存邮件正文', 'xj.mail.p1Inventory.body', 'Please find the attachment', 'N', 'admin', NOW(), 'P1库存邮件正文'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_config WHERE config_key = 'xj.mail.p1Inventory.body'
);
