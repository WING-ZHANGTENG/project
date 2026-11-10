-- P1 empty-black-carton palletizing lifecycle.
-- WCS reports carton/pallet binding; repeated carton codes overwrite the previous pallet.

CREATE TABLE IF NOT EXISTS `p1_empty_black_info` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `carton_code` varchar(255) NOT NULL COMMENT 'empty black carton code',
  `pallet_code` varchar(255) NOT NULL COMMENT 'P1 inbound pallet code',
  `status` varchar(32) NOT NULL DEFAULT 'PALLETIZED' COMMENT 'PALLETIZED/IN_STOCK',
  `palletized_time` datetime DEFAULT NULL COMMENT 'latest palletized time',
  `inbound_time` datetime DEFAULT NULL COMMENT 'P1 inbound completion time',
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_p1_empty_black_carton` (`carton_code`),
  KEY `idx_p1_empty_black_pallet_status` (`pallet_code`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='P1 empty black carton palletizing records';

INSERT INTO sys_dict_type (dict_name, dict_type, status, create_by, create_time, remark)
SELECT 'P1空黑箱状态', 'p1_empty_black_status', '0', 'admin', NOW(), 'P1 empty black carton lifecycle status'
WHERE NOT EXISTS (
  SELECT 1 FROM sys_dict_type WHERE dict_type='p1_empty_black_status'
);

INSERT INTO sys_dict_data
  (dict_sort,dict_label,dict_label_en,dict_value,dict_type,list_class,is_default,status,create_by,create_time,remark)
SELECT v.sort_no,v.zh,v.en,v.code,'p1_empty_black_status',v.css,'N','0','admin',NOW(),'P1 empty black carton status'
FROM (
  SELECT 1 sort_no,'已码垛' zh,'Palletized' en,'PALLETIZED' code,'primary' css
  UNION ALL
  SELECT 2,'已入库','In Stock','IN_STOCK','success'
) v
WHERE NOT EXISTS (
  SELECT 1 FROM sys_dict_data d
  WHERE d.dict_type='p1_empty_black_status' AND d.dict_value=v.code
);
