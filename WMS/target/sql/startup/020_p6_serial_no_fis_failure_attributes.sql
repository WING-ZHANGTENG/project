-- P6 HDD FIS additional attributes. Missing attributes in a FIS response are saved as NULL.
-- This script is safe to run repeatedly during deployment.

SET @schema_name = DATABASE();

SELECT IF(EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'serial_no' AND COLUMN_NAME = 'fail_ts'),
    'SELECT ''serial_no.fail_ts already exists''',
    'ALTER TABLE serial_no ADD COLUMN fail_ts VARCHAR(100) NULL COMMENT ''希捷FIS返回的FAIL_TS'' AFTER fail_code') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'serial_no' AND COLUMN_NAME = 'fail_oper'),
    'SELECT ''serial_no.fail_oper already exists''',
    'ALTER TABLE serial_no ADD COLUMN fail_oper VARCHAR(100) NULL COMMENT ''希捷FIS返回的FAIL_OPER'' AFTER fail_ts') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'serial_no' AND COLUMN_NAME = 'fail_seq'),
    'SELECT ''serial_no.fail_seq already exists''',
    'ALTER TABLE serial_no ADD COLUMN fail_seq VARCHAR(100) NULL COMMENT ''希捷FIS返回的FAIL_SEQ'' AFTER fail_oper') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'serial_no' AND COLUMN_NAME = 'rwk_code'),
    'SELECT ''serial_no.rwk_code already exists''',
    'ALTER TABLE serial_no ADD COLUMN rwk_code VARCHAR(100) NULL COMMENT ''希捷FIS返回的RWK_CODE'' AFTER fail_seq') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'serial_no' AND COLUMN_NAME = 'diag_remark'),
    'SELECT ''serial_no.diag_remark already exists''',
    'ALTER TABLE serial_no ADD COLUMN diag_remark VARCHAR(1000) NULL COMMENT ''希捷FIS返回的DIAG_REMARK'' AFTER rwk_code') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SELECT IF(EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'serial_no' AND COLUMN_NAME = 'dispose'),
    'SELECT ''serial_no.dispose already exists''',
    'ALTER TABLE serial_no ADD COLUMN dispose VARCHAR(500) NULL COMMENT ''希捷FIS返回的DISPOSE'' AFTER diag_remark') INTO @ddl;
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;
