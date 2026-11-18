-- P1 empty-black cartons per pallet. WCS validation only requires this parameter to exist.
INSERT INTO sys_config
    (config_name, config_key, config_value, config_type, create_by, create_time, remark)
SELECT
    'P1黑空箱成托数量',
    'xj.p1.emptyBlack.palletQuantity',
    '54',
    'Y',
    'admin',
    NOW(),
    'P1 empty-black cartons per pallet'
WHERE NOT EXISTS (
    SELECT 1
    FROM sys_config
    WHERE config_key = 'xj.p1.emptyBlack.palletQuantity'
);
