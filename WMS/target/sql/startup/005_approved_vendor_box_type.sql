-- Add the configurable box type used by the P1 WCS box-type confirmation API.
-- Safe to run repeatedly: it skips the ALTER when the column already exists.

SET @sql = IF(
    EXISTS (
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'approved_vendor'
          AND COLUMN_NAME = 'box_type'
    ),
    'SELECT ''approved_vendor.box_type already exists'' AS message',
    'ALTER TABLE approved_vendor ADD COLUMN box_type VARCHAR(32) NULL COMMENT ''箱子类型：Carton/Tote'' AFTER vendor_name'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
