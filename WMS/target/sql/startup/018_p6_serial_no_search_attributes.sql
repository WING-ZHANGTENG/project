-- P6 HDD 出库搜索属性。所有字段均直接来自希捷 FIS 的 CURRENT_ATTRIBUTES 返回值。
-- 脚本可重复执行：字段已存在时不会重复创建。

SET @schema_name = DATABASE();

SELECT IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'serial_no' AND COLUMN_NAME = 'prime_flag'),
    'SELECT ''serial_no.prime_flag already exists''',
    'ALTER TABLE serial_no ADD COLUMN prime_flag VARCHAR(20) NULL COMMENT ''希捷FIS返回的PRIME'' AFTER product'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'serial_no' AND COLUMN_NAME = 'media_type'),
    'SELECT ''serial_no.media_type already exists''',
    'ALTER TABLE serial_no ADD COLUMN media_type VARCHAR(50) NULL COMMENT ''希捷FIS返回的MEDIA_TYPE'' AFTER prime_flag'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'serial_no' AND COLUMN_NAME = 'org_sbg'),
    'SELECT ''serial_no.org_sbg already exists''',
    'ALTER TABLE serial_no ADD COLUMN org_sbg VARCHAR(255) NULL COMMENT ''希捷FIS返回的ORG_SBG'' AFTER media_type'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'serial_no' AND COLUMN_NAME = 'fail_code'),
    'SELECT ''serial_no.fail_code already exists''',
    'ALTER TABLE serial_no ADD COLUMN fail_code VARCHAR(100) NULL COMMENT ''希捷FIS返回的FAIL_CODE'' AFTER org_sbg'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
