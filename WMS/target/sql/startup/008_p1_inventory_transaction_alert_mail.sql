-- P1 inventory transaction alert email settings and schema patch.
-- Schedule this task in sys_job every five minutes:
-- p1InventoryTransactionAlertMailTask.sendP1InventoryTransactionAlertMail()

SET @schema_name = DATABASE();
SELECT EXISTS(
    SELECT 1
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = @schema_name
      AND TABLE_NAME = 'inventory_transaction'
) INTO @table_exists;

SELECT IF(
    @table_exists = 0,
    'SELECT ''skip inventory_transaction table missing''',
    IF(
        EXISTS(
            SELECT 1
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name
              AND TABLE_NAME = 'inventory_transaction'
              AND COLUMN_NAME = 'mail_sent_status'
        ),
        'SELECT ''skip inventory_transaction.mail_sent_status''',
        'ALTER TABLE `inventory_transaction` ADD COLUMN `mail_sent_status` tinyint NOT NULL DEFAULT 0 COMMENT ''Alert email status: 0-unsent, 1-sent'' AFTER `sync_status`'
    )
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT 'P1库存交易事件告警邮件收件人', 'xj.mail.p1InventoryTransactionAlert.toEmails', '', 'N', 'admin', NOW(), '多个收件人使用英文逗号、分号或空格分隔'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_config WHERE config_key = 'xj.mail.p1InventoryTransactionAlert.toEmails'
);

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT 'P1库存交易事件告警邮件标题', 'xj.mail.p1InventoryTransactionAlert.subject', 'P1 Inventory Transaction Alert', 'N', 'admin', NOW(), 'P1 inventory transaction alert email subject'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_config WHERE config_key = 'xj.mail.p1InventoryTransactionAlert.subject'
);

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT 'P1库存交易事件告警邮件正文', 'xj.mail.p1InventoryTransactionAlert.body', 'Please find the failed P1 inventory transactions in the attachment.', 'N', 'admin', NOW(), 'P1 inventory transaction alert email body'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_config WHERE config_key = 'xj.mail.p1InventoryTransactionAlert.body'
);
