-- External integration URLs can be longer than the legacy VARCHAR(50).
-- Keep the live and archive tables aligned so long URLs can also be archived.
SET @schema_name = DATABASE();

SELECT IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name
              AND TABLE_NAME = 'interface_record'
              AND COLUMN_NAME = 'url'),
    'ALTER TABLE interface_record MODIFY COLUMN url VARCHAR(500) NULL COMMENT ''路径''',
    'SELECT ''interface_record.url does not exist'''
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name
              AND TABLE_NAME = 'interface_record_log'
              AND COLUMN_NAME = 'url'),
    'ALTER TABLE interface_record_log MODIFY COLUMN url VARCHAR(500) NULL COMMENT ''路径''',
    'SELECT ''interface_record_log.url does not exist; archive table will inherit the expanded column when created'''
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
