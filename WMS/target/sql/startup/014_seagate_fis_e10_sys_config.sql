-- Seagate FIS E10 alarm reporting connection settings.
-- Values are maintained in sys_config and can be changed without rebuilding the application.

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT 'Seagate FIS主机', 'xj.fis.host', 'localhost', 'Y', 'admin', NOW(), 'E10告警发布的本机FIS服务主机'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_config WHERE config_key = 'xj.fis.host'
);

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT 'Seagate FIS端口', 'xj.fis.port', '9913', 'Y', 'admin', NOW(), 'E10告警发布的本机FIS服务端口'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_config WHERE config_key = 'xj.fis.port'
);

INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT 'Seagate FIS服务名', 'xj.fis.service', 'FRI', 'Y', 'admin', NOW(), 'E10告警发布的FIS服务名称'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_config WHERE config_key = 'xj.fis.service'
);
