-- P4 outbound request page, button configuration and idempotency records.

CREATE TABLE IF NOT EXISTS `p4_outbound_button_config` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `button_no` int NOT NULL COMMENT 'Button number (1-5)',
  `button_name` varchar(64) NOT NULL COMMENT 'Chinese button name',
  `button_name_en` varchar(128) NOT NULL COMMENT 'English button name',
  `button_color` varchar(16) NOT NULL COMMENT 'Button colour',
  `position_code` varchar(64) DEFAULT NULL COMMENT 'P4 outbound station code',
  `goods_type` varchar(32) NOT NULL DEFAULT 'CASE_ID' COMMENT 'CASE_ID: carton, BLACK: black box',
  `pallet_prefix` varchar(64) DEFAULT NULL COMMENT 'Black-box pallet prefix',
  `enabled` tinyint NOT NULL DEFAULT 1 COMMENT '0: disabled, 1: enabled',
  `version` int NOT NULL DEFAULT 0 COMMENT 'Optimistic lock version',
  `create_by` varchar(64) DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_by` varchar(64) DEFAULT NULL,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_p4_outbound_button_no` (`button_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='P4 outbound request button configuration';

INSERT INTO `p4_outbound_button_config`
(`button_no`, `button_name`, `button_name_en`, `button_color`, `goods_type`, `enabled`)
SELECT 1, '一组出库', 'Group 1 Outbound', '#409EFF', 'CASE_ID', 1
WHERE NOT EXISTS (SELECT 1 FROM `p4_outbound_button_config` WHERE `button_no` = 1);

INSERT INTO `p4_outbound_button_config`
(`button_no`, `button_name`, `button_name_en`, `button_color`, `goods_type`, `enabled`)
SELECT 2, '二组出库', 'Group 2 Outbound', '#67C23A', 'CASE_ID', 1
WHERE NOT EXISTS (SELECT 1 FROM `p4_outbound_button_config` WHERE `button_no` = 2);

INSERT INTO `p4_outbound_button_config`
(`button_no`, `button_name`, `button_name_en`, `button_color`, `goods_type`, `enabled`)
SELECT 3, '三组出库', 'Group 3 Outbound', '#E6A23C', 'CASE_ID', 1
WHERE NOT EXISTS (SELECT 1 FROM `p4_outbound_button_config` WHERE `button_no` = 3);

INSERT INTO `p4_outbound_button_config`
(`button_no`, `button_name`, `button_name_en`, `button_color`, `goods_type`, `enabled`)
SELECT 4, '四组出库', 'Group 4 Outbound', '#F56C6C', 'CASE_ID', 1
WHERE NOT EXISTS (SELECT 1 FROM `p4_outbound_button_config` WHERE `button_no` = 4);

INSERT INTO `p4_outbound_button_config`
(`button_no`, `button_name`, `button_name_en`, `button_color`, `goods_type`, `enabled`)
SELECT 5, '五组出库', 'Group 5 Outbound', '#909399', 'CASE_ID', 1
WHERE NOT EXISTS (SELECT 1 FROM `p4_outbound_button_config` WHERE `button_no` = 5);

CREATE TABLE IF NOT EXISTS `p4_outbound_request` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `request_id` varchar(64) NOT NULL COMMENT 'Frontend idempotency key',
  `button_id` bigint NOT NULL COMMENT 'Button configuration id',
  `out_master_id` bigint DEFAULT NULL,
  `out_detail_id` bigint DEFAULT NULL,
  `pick_task_id` bigint DEFAULT NULL,
  `task_info_id` bigint DEFAULT NULL,
  `bill_no` varchar(64) DEFAULT NULL,
  `pallet_code` varchar(128) DEFAULT NULL,
  `status` varchar(16) NOT NULL DEFAULT 'SUCCESS',
  `create_user_id` bigint DEFAULT NULL,
  `create_user_name` varchar(64) DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_p4_outbound_request_id` (`request_id`),
  KEY `idx_p4_outbound_request_button_time` (`button_id`, `create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='P4 outbound request idempotency record';

-- Backfill existing P4 inventory: CFS prefix is carton; all other codes are black boxes.
UPDATE `inventory`
SET `record_type` = CASE
    WHEN UPPER(TRIM(`pallet_code`)) LIKE 'CFS%' THEN 'CASE_ID'
    ELSE 'BLACK'
END
WHERE `ware_code` = 'P4'
  AND `pallet_code` IS NOT NULL
  AND TRIM(`pallet_code`) <> '';

-- Add a covering index only when it does not already exist.
SET @p4_inventory_index_exists = (
  SELECT COUNT(1)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'inventory'
    AND index_name = 'idx_p4_outbound_select'
);
SET @p4_inventory_index_sql = IF(
  @p4_inventory_index_exists = 0,
  'ALTER TABLE `inventory` ADD INDEX `idx_p4_outbound_select` (`ware_code`, `record_type`, `allot_quantity`, `sync_lock_status`, `in_date`)',
  'SELECT 1'
);
PREPARE p4_inventory_index_stmt FROM @p4_inventory_index_sql;
EXECUTE p4_inventory_index_stmt;
DEALLOCATE PREPARE p4_inventory_index_stmt;

-- Add the page below Outbound Management and grant it to roles that already own the parent menu.
SET @p4_outbound_parent_menu_id = (
  SELECT `menu_id` FROM `sys_menu`
  WHERE `menu_name` = '出库管理' AND `menu_type` IN ('M', 'C')
  ORDER BY `menu_id` LIMIT 1
);
SET @p4_outbound_menu_id = (
  SELECT `menu_id` FROM `sys_menu`
  WHERE `path` = 'p4OutboundRequest'
     OR `component` = 'wms-xj/P4OutboundRequest/index'
  ORDER BY `menu_id` LIMIT 1
);
SET @p4_outbound_new_menu_id = IFNULL(
  @p4_outbound_menu_id,
  (SELECT IFNULL(MAX(`menu_id`), 0) + 1 FROM `sys_menu` menu_id_source)
);

INSERT INTO `sys_menu`
(`menu_id`, `menu_name`, `menu_name_en`, `parent_id`, `order_num`, `path`, `component`,
 `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`,
 `create_by`, `create_time`, `remark`)
SELECT @p4_outbound_new_menu_id, 'P4 出库申请', 'P4 Outbound Request',
       @p4_outbound_parent_menu_id, 99, 'p4OutboundRequest',
       'wms-xj/P4OutboundRequest/index', '1', '0', 'C', '0', '0',
       'wms-xj:P4OutboundRequest:list', 'button', 'system', NOW(),
       'Five-group P4 outbound request page'
WHERE @p4_outbound_parent_menu_id IS NOT NULL
  AND @p4_outbound_menu_id IS NULL;

SET @p4_outbound_menu_id = (
  SELECT `menu_id` FROM `sys_menu`
  WHERE `path` = 'p4OutboundRequest'
     OR `component` = 'wms-xj/P4OutboundRequest/index'
  ORDER BY `menu_id` LIMIT 1
);

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT DISTINCT parent_role.`role_id`, @p4_outbound_menu_id
FROM `sys_role_menu` parent_role
WHERE parent_role.`menu_id` = @p4_outbound_parent_menu_id
  AND @p4_outbound_menu_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM `sys_role_menu` existing_role
    WHERE existing_role.`role_id` = parent_role.`role_id`
      AND existing_role.`menu_id` = @p4_outbound_menu_id
  );

-- Stable goods-type dictionary codes with bilingual labels.
INSERT INTO `sys_dict_type`
(`dict_name`, `dict_type`, `status`, `create_by`, `create_time`, `remark`)
SELECT 'P4出库货物类型', 'p4_outbound_goods_type', '0', 'system', NOW(), 'P4 outbound goods type'
WHERE NOT EXISTS (
  SELECT 1 FROM `sys_dict_type` WHERE `dict_type` = 'p4_outbound_goods_type'
);

INSERT INTO `sys_dict_data`
(`dict_sort`, `dict_label`, `dict_label_en`, `dict_value`, `dict_type`, `status`, `create_by`, `create_time`, `remark`)
SELECT 1, '纸箱', 'Carton', 'CASE_ID', 'p4_outbound_goods_type', '0', 'system', NOW(), 'P4 carton'
WHERE NOT EXISTS (
  SELECT 1 FROM `sys_dict_data`
  WHERE `dict_type` = 'p4_outbound_goods_type' AND `dict_value` = 'CASE_ID'
);

INSERT INTO `sys_dict_data`
(`dict_sort`, `dict_label`, `dict_label_en`, `dict_value`, `dict_type`, `status`, `create_by`, `create_time`, `remark`)
SELECT 2, '黑箱', 'Black Box', 'BLACK', 'p4_outbound_goods_type', '0', 'system', NOW(), 'P4 black box'
WHERE NOT EXISTS (
  SELECT 1 FROM `sys_dict_data`
  WHERE `dict_type` = 'p4_outbound_goods_type' AND `dict_value` = 'BLACK'
);
