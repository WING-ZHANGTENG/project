-- Add out_detail.inventory_id for P1 outbound inventory selection.
-- Safe to run repeatedly: it skips the ALTER when the column already exists.

SET @sql = IF(
    EXISTS (
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'out_detail'
          AND COLUMN_NAME = 'inventory_id'
    ),
    'SELECT ''out_detail.inventory_id already exists'' AS message',
    'ALTER TABLE out_detail ADD COLUMN inventory_id BIGINT NULL COMMENT ''P1指定库存ID'' AFTER out_master_id'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
