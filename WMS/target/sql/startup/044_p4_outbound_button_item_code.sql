-- Optional material filter for P4 outbound request buttons.
-- The UI requires a material for new/edited configurations, while NULL keeps
-- legacy buttons compatible with the original type-only inventory selection.

SET @schema_name = DATABASE();

SELECT IF(
    EXISTS(
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = @schema_name
          AND TABLE_NAME = 'p4_outbound_button_config'
          AND COLUMN_NAME = 'item_code'
    ),
    'SELECT ''skip p4_outbound_button_config.item_code''',
    'ALTER TABLE p4_outbound_button_config ADD COLUMN item_code varchar(64) DEFAULT NULL COMMENT ''Optional material code filter'' AFTER pallet_prefix'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
