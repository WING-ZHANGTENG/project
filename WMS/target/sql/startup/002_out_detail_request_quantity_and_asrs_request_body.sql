-- Startup-safe schema patch for fields added after 001.
-- This script is idempotent: existing columns are skipped automatically.

SET @schema_name = DATABASE();

SELECT EXISTS(
    SELECT 1
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = @schema_name
      AND TABLE_NAME = 'out_detail'
) INTO @table_exists;

SELECT IF(
    @table_exists = 0,
    'SELECT ''skip out_detail table missing''',
    IF(
        EXISTS(
            SELECT 1
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name
              AND TABLE_NAME = 'out_detail'
              AND COLUMN_NAME = 'request_quantity'
        ),
        'SELECT ''skip out_detail.request_quantity''',
        'ALTER TABLE `out_detail` ADD COLUMN `request_quantity` double DEFAULT NULL COMMENT ''Upstream requested quantity'''
    )
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

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
              AND COLUMN_NAME = 'asrs_request_body'
        ),
        'SELECT ''skip inventory_transaction.asrs_request_body''',
        'ALTER TABLE `inventory_transaction` ADD COLUMN `asrs_request_body` text COMMENT ''ASRS final request body'''
    )
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
