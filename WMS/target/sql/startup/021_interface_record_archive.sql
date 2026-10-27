-- 接口记录归档表：主表仅保留一个月，归档表保留六个月。
-- LIKE 会复制 interface_record 的列、主键与索引；脚本重复执行不会覆盖历史归档数据。
CREATE TABLE IF NOT EXISTS interface_record_log LIKE interface_record;

SET @schema_name = DATABASE();

SELECT IF(
    EXISTS (SELECT 1 FROM information_schema.STATISTICS
            WHERE TABLE_SCHEMA = @schema_name AND TABLE_NAME = 'interface_record_log'
              AND INDEX_NAME = 'idx_interface_record_log_create_time'),
    'SELECT ''interface_record_log.idx_interface_record_log_create_time already exists''',
    'ALTER TABLE interface_record_log ADD INDEX idx_interface_record_log_create_time (create_time)'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
