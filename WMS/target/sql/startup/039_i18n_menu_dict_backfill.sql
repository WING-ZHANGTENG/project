-- Backfill missing English labels used by the bilingual UI.
-- Safe to execute repeatedly: existing non-blank English values are preserved.

SET @schema_name = DATABASE();

SELECT IF(
    EXISTS(
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = @schema_name
          AND TABLE_NAME = 'sys_menu'
          AND COLUMN_NAME = 'menu_name_en'
    ),
    'SELECT ''skip sys_menu.menu_name_en''',
    'ALTER TABLE sys_menu ADD COLUMN menu_name_en varchar(100) DEFAULT NULL COMMENT ''English menu name'' AFTER menu_name'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT IF(
    EXISTS(
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = @schema_name
          AND TABLE_NAME = 'sys_dict_data'
          AND COLUMN_NAME = 'dict_label_en'
    ),
    'SELECT ''skip sys_dict_data.dict_label_en''',
    'ALTER TABLE sys_dict_data ADD COLUMN dict_label_en varchar(100) DEFAULT NULL COMMENT ''English dictionary label'' AFTER dict_label'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE sys_menu
SET menu_name_en = CASE menu_id
    WHEN 24011443 THEN 'Version Updates'
    WHEN 24011446 THEN 'Aisle 1'
    ELSE menu_name_en
END
WHERE menu_id IN (24011443, 24011446)
  AND (menu_name_en IS NULL OR TRIM(menu_name_en) = '');

UPDATE sys_dict_data
SET dict_label_en = CASE CONCAT(dict_type, ':', dict_value)
    WHEN 'in_state:0' THEN 'Pending Review'
    WHEN 'in_state:1' THEN 'Approved'
    WHEN 'in_type:1' THEN 'Raw Material Inbound'
    WHEN 'is_delete:0' THEN 'Not Deleted'
    WHEN 'is_delete:1' THEN 'Deleted'
    WHEN 'sys_common_status:0' THEN 'Success'
    WHEN 'sys_common_status:1' THEN 'Failed'
    WHEN 'sys_job_group:DEFAULT' THEN 'Default'
    WHEN 'sys_job_group:SYSTEM' THEN 'System'
    WHEN 'sys_job_status:0' THEN 'Normal'
    WHEN 'sys_job_status:1' THEN 'Paused'
    WHEN 'sys_normal_disable:0' THEN 'Normal'
    WHEN 'sys_normal_disable:1' THEN 'Disabled'
    WHEN 'sys_notice_status:0' THEN 'Normal'
    WHEN 'sys_notice_status:1' THEN 'Closed'
    WHEN 'sys_notice_type:1' THEN 'Notification'
    WHEN 'sys_notice_type:2' THEN 'Announcement'
    WHEN 'sys_oper_type:0' THEN 'Other'
    WHEN 'sys_oper_type:1' THEN 'Add'
    WHEN 'sys_oper_type:2' THEN 'Edit'
    WHEN 'sys_oper_type:3' THEN 'Delete'
    WHEN 'sys_oper_type:4' THEN 'Authorize'
    WHEN 'sys_oper_type:5' THEN 'Export'
    WHEN 'sys_oper_type:6' THEN 'Import'
    WHEN 'sys_oper_type:7' THEN 'Force Sign Out'
    WHEN 'sys_oper_type:8' THEN 'Generate Code'
    WHEN 'sys_oper_type:9' THEN 'Clear Data'
    WHEN 'sys_show_hide:0' THEN 'Show'
    WHEN 'sys_show_hide:1' THEN 'Hide'
    WHEN 'sys_user_sex:0' THEN 'Male'
    WHEN 'sys_user_sex:1' THEN 'Female'
    WHEN 'sys_user_sex:2' THEN 'Unknown'
    WHEN 'sys_yes_no:Y' THEN 'Yes'
    WHEN 'sys_yes_no:N' THEN 'No'
    WHEN 'task_type:IN' THEN 'Inbound'
    WHEN 'task_type:OUT' THEN 'Outbound'
    WHEN 'task_type:MOVE' THEN 'Relocation'
    ELSE dict_label_en
END
WHERE CONCAT(dict_type, ':', dict_value) IN (
    'in_state:0', 'in_state:1', 'in_type:1',
    'is_delete:0', 'is_delete:1',
    'sys_common_status:0', 'sys_common_status:1',
    'sys_job_group:DEFAULT', 'sys_job_group:SYSTEM',
    'sys_job_status:0', 'sys_job_status:1',
    'sys_normal_disable:0', 'sys_normal_disable:1',
    'sys_notice_status:0', 'sys_notice_status:1',
    'sys_notice_type:1', 'sys_notice_type:2',
    'sys_oper_type:0', 'sys_oper_type:1', 'sys_oper_type:2',
    'sys_oper_type:3', 'sys_oper_type:4', 'sys_oper_type:5',
    'sys_oper_type:6', 'sys_oper_type:7', 'sys_oper_type:8',
    'sys_oper_type:9', 'sys_show_hide:0', 'sys_show_hide:1',
    'sys_user_sex:0', 'sys_user_sex:1', 'sys_user_sex:2',
    'sys_yes_no:Y', 'sys_yes_no:N',
    'task_type:IN', 'task_type:OUT', 'task_type:MOVE'
)
  AND (dict_label_en IS NULL OR TRIM(dict_label_en) = '');
