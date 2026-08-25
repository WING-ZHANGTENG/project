-- Startup-safe schema patch for inventory_transaction final ASRS fields.
-- This script is idempotent: existing columns are skipped automatically.

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
              AND COLUMN_NAME = 'asrs_status'
        ),
        'SELECT ''skip inventory_transaction.asrs_status''',
        'ALTER TABLE `inventory_transaction` ADD COLUMN `asrs_status` varchar(32) DEFAULT NULL COMMENT ''ASRS final status'' AFTER `sync_time`'
    )
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT IF(
    @table_exists = 0,
    'SELECT ''skip inventory_transaction table missing''',
    IF(
        EXISTS(
            SELECT 1
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name
              AND TABLE_NAME = 'inventory_transaction'
              AND COLUMN_NAME = 'asrs_request_url'
        ),
        'SELECT ''skip inventory_transaction.asrs_request_url''',
        'ALTER TABLE `inventory_transaction` ADD COLUMN `asrs_request_url` varchar(255) DEFAULT NULL COMMENT ''ASRS final request URL'' AFTER `asrs_status`'
    )
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT IF(
    @table_exists = 0,
    'SELECT ''skip inventory_transaction table missing''',
    IF(
        EXISTS(
            SELECT 1
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name
              AND TABLE_NAME = 'inventory_transaction'
              AND COLUMN_NAME = 'asrs_response_body'
        ),
        'SELECT ''skip inventory_transaction.asrs_response_body''',
        'ALTER TABLE `inventory_transaction` ADD COLUMN `asrs_response_body` text COMMENT ''ASRS final response body'' AFTER `asrs_request_url`'
    )
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT IF(
    @table_exists = 0,
    'SELECT ''skip inventory_transaction table missing''',
    IF(
        EXISTS(
            SELECT 1
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name
              AND TABLE_NAME = 'inventory_transaction'
              AND COLUMN_NAME = 'asrs_response_time'
        ),
        'SELECT ''skip inventory_transaction.asrs_response_time''',
        'ALTER TABLE `inventory_transaction` ADD COLUMN `asrs_response_time` datetime DEFAULT NULL COMMENT ''ASRS final response time'' AFTER `asrs_response_body`'
    )
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
