-- Ensure WCS runtime-log auto-registration cannot create duplicate device codes.
-- Existing duplicate rows are not deleted automatically; in that exceptional case
-- the script leaves the current index unchanged so operators can merge them safely.

SET @schema_name = DATABASE();

SELECT IF(
    EXISTS(
        SELECT 1
        FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = @schema_name
          AND TABLE_NAME = 'device_info'
          AND COLUMN_NAME = 'code'
          AND NON_UNIQUE = 0
    ),
    'SELECT ''skip device_info.code unique index''',
    IF(
        EXISTS(
            SELECT 1
            FROM device_info
            GROUP BY code
            HAVING COUNT(*) > 1
        ),
        'SELECT ''device_info has duplicate codes; merge them before adding a unique index''',
        'ALTER TABLE device_info ADD UNIQUE INDEX uk_device_info_code (code)'
    )
) INTO @ddl;

PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
