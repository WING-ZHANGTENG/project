-- P6 HDD inbound attributes. This script is safe to run repeatedly during deployment.

SET @schema_name = DATABASE();

SELECT IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'serial_no' AND COLUMN_NAME = 'box_type'),
    'SELECT ''serial_no.box_type already exists''',
    'ALTER TABLE serial_no ADD COLUMN box_type INT NULL COMMENT ''P6周转箱类型：1-25mm HDD，2-20mm HDD'' AFTER wms_id'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'serial_no' AND COLUMN_NAME = 'slot_number'),
    'SELECT ''serial_no.slot_number already exists''',
    'ALTER TABLE serial_no ADD COLUMN slot_number INT NULL COMMENT ''P6 HDD在周转箱内的槽位号'' AFTER box_type'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'serial_no' AND COLUMN_NAME = 'location_code'),
    'SELECT ''serial_no.location_code already exists''',
    'ALTER TABLE serial_no ADD COLUMN location_code VARCHAR(255) NULL COMMENT ''P6入库库位编码'' AFTER slot_number'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'serial_no' AND COLUMN_NAME = 'part_num'),
    'SELECT ''serial_no.part_num already exists''',
    'ALTER TABLE serial_no ADD COLUMN part_num VARCHAR(255) NULL COMMENT ''希捷FIS返回的PART_NUM'' AFTER location_code'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'serial_no' AND COLUMN_NAME = 'sub_build_group'),
    'SELECT ''serial_no.sub_build_group already exists''',
    'ALTER TABLE serial_no ADD COLUMN sub_build_group VARCHAR(255) NULL COMMENT ''希捷FIS返回的SUB_BUILD_GROUP'' AFTER part_num'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'serial_no' AND COLUMN_NAME = 'cms_family'),
    'SELECT ''serial_no.cms_family already exists''',
    'ALTER TABLE serial_no ADD COLUMN cms_family VARCHAR(255) NULL COMMENT ''希捷FIS返回的CMS_FAMILY'' AFTER sub_build_group'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'serial_no' AND COLUMN_NAME = 'product'),
    'SELECT ''serial_no.product already exists''',
    'ALTER TABLE serial_no ADD COLUMN product VARCHAR(500) NULL COMMENT ''希捷FIS返回的PRODUCT'' AFTER cms_family'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
