-- P6 totebox type belongs to the totebox itself, including after all HDD inventory has left the box.
-- This script is safe to run repeatedly during deployment.

SET @schema_name = DATABASE();

SELECT IF(
    EXISTS (
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = @schema_name
          AND TABLE_NAME = 'pallet_info'
          AND COLUMN_NAME = 'box_type'
    ),
    'SELECT ''pallet_info.box_type already exists''',
    'ALTER TABLE pallet_info ADD COLUMN box_type INT NULL COMMENT ''P6周转箱类型：1-25mm HDD，2-20mm HDD'' AFTER type'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Preserve the type of toteboxes already received before this column existed.
UPDATE pallet_info pallet
INNER JOIN inventory inventory ON inventory.ware_code = pallet.ware_code
    AND inventory.pallet_code = pallet.code
INNER JOIN serial_no serial_no ON serial_no.wms_id = inventory.inventory_id
    AND serial_no.type = 1
SET pallet.box_type = serial_no.box_type
WHERE pallet.ware_code = 'P6'
  AND pallet.box_type IS NULL
  AND serial_no.box_type IS NOT NULL;
