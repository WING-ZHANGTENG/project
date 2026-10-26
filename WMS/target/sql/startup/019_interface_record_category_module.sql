-- 接口记录分类与业务模块。字段已存在时不会重复创建。

SET @schema_name = DATABASE();

SELECT IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'interface_record' AND COLUMN_NAME = 'name_zh'),
    'SELECT ''interface_record.name_zh already exists''',
    'ALTER TABLE interface_record ADD COLUMN name_zh VARCHAR(255) NULL COMMENT ''接口中文名称'' AFTER name'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'interface_record' AND COLUMN_NAME = 'interface_category'),
    'SELECT ''interface_record.interface_category already exists''',
    'ALTER TABLE interface_record ADD COLUMN interface_category VARCHAR(50) NULL COMMENT ''接口分类：WCS_TO_WMS、SEAGATE_IT_TO_WMS、WMS_TO_WCS、WMS_TO_SEAGATE_IT'' AFTER type'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'interface_record' AND COLUMN_NAME = 'business_module'),
    'SELECT ''interface_record.business_module already exists''',
    'ALTER TABLE interface_record ADD COLUMN business_module VARCHAR(50) NULL COMMENT ''业务模块：WCS任务设备、WCS库存扫码、ASRS库存同步、FIS硬盘属性、PWAIN纸箱预处理、E10设备告警、其他'' AFTER interface_category'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT IF(
    EXISTS (SELECT 1 FROM information_schema.STATISTICS
            WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'interface_record' AND INDEX_NAME = 'idx_interface_record_category_module'),
    'SELECT ''interface_record.idx_interface_record_category_module already exists''',
    'ALTER TABLE interface_record ADD INDEX idx_interface_record_category_module (interface_category, business_module)'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
