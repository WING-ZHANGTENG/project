-- Startup-safe data patch for ASRS final status values.
-- This script is idempotent: old Synced_* values are normalized only when present.

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
        'UPDATE `inventory_transaction` SET `asrs_status` = CASE `asrs_status` WHEN ''Synced_SUCCESS'' THEN ''SUCCESS'' WHEN ''Synced_FAIL'' THEN ''FAIL'' WHEN ''Synced_FAILED'' THEN ''FAIL'' WHEN ''FAILED'' THEN ''FAIL'' WHEN ''Synced_VOID'' THEN ''VOID'' WHEN ''Synced_TIMEOUT'' THEN ''TIMEOUT'' ELSE `asrs_status` END WHERE `asrs_status` IN (''Synced_SUCCESS'', ''Synced_FAIL'', ''Synced_FAILED'', ''FAILED'', ''Synced_VOID'', ''Synced_TIMEOUT'')',
        'SELECT ''skip inventory_transaction.asrs_status missing'''
    )
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
