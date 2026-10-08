-- P1 scanned-in inventory synchronization lock.
-- This script is idempotent and can be applied during service startup or deployment.

SET @schema_name = DATABASE();

SELECT EXISTS(
    SELECT 1
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = @schema_name
      AND TABLE_NAME = 'inventory'
) INTO @inventory_table_exists;

SELECT IF(
    @inventory_table_exists = 0,
    'SELECT ''skip inventory table missing''',
    IF(
        EXISTS(
            SELECT 1
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @schema_name
              AND TABLE_NAME = 'inventory'
              AND COLUMN_NAME = 'sync_lock_status'
        ),
        'SELECT ''skip inventory.sync_lock_status''',
        'ALTER TABLE `inventory` ADD COLUMN `sync_lock_status` tinyint NOT NULL DEFAULT 0 COMMENT ''P1 inbound synchronization lock: 0-unlocked, 1-locked'' AFTER `allot_quantity`'
    )
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Backfill P1 inbound records that require synchronization and whose latest
-- inbound result is not Success or Void. Existing unlocked stock remains unchanged.
SELECT EXISTS(
    SELECT 1
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = @schema_name
      AND TABLE_NAME = 'inventory_transaction'
) INTO @transaction_table_exists;

SELECT IF(
    @inventory_table_exists = 0 OR @transaction_table_exists = 0,
    'SELECT ''skip P1 sync-lock backfill because a required table is missing''',
    'UPDATE inventory i
     INNER JOIN inventory_transaction t
         ON t.inventory_id = i.inventory_id
        AND t.ware_code = ''P1''
        AND UPPER(t.type) = ''IN''
        AND COALESCE(t.need_sync, 0) = 1
        AND t.remark IN (''P1原材料入库'', ''P1料盒入库'', ''P1成品入库'')
     LEFT JOIN inventory_transaction newer
         ON newer.inventory_id = t.inventory_id
        AND newer.ware_code = ''P1''
        AND UPPER(newer.type) = ''IN''
        AND newer.id > t.id
     SET i.sync_lock_status = 1
     WHERE i.ware_code = ''P1''
       AND newer.id IS NULL
       AND UPPER(COALESCE(t.asrs_status, '''')) NOT IN (
           ''SUCCESS'', ''VOID'', ''SYNCED_SUCCESS'', ''SYNCED_VOID''
       )'
) INTO @backfill_sql;
PREPARE backfill_stmt FROM @backfill_sql;
EXECUTE backfill_stmt;
DEALLOCATE PREPARE backfill_stmt;
