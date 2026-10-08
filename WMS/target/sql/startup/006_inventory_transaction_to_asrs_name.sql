-- Store the destination ASRS for inventory transactions. The value is optional
-- because inbound and legacy events do not necessarily have a destination.
-- Safe to run repeatedly: it skips the ALTER when the column already exists.

SET @sql = IF(
    EXISTS (
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'inventory_transaction'
          AND COLUMN_NAME = 'to_asrs_name'
    ),
    'SELECT ''inventory_transaction.to_asrs_name already exists'' AS message',
    'ALTER TABLE inventory_transaction ADD COLUMN to_asrs_name VARCHAR(64) NULL COMMENT ''目标ASRS名称/交易走向'' AFTER ware_name'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
