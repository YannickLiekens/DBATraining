Use StackOverflow2010
GO

/* let's show RCSI
*/

/* A common problem is locking, mostly locking select and DML lanaguage.
 in this case, we'll take a lock on a table and try to select out of it.
 */

-- The lock
BEGIN TRAN

Update dbo.Users
set Reputation = 1

ROLLBACK TRAN 


-- The SELECT
BEGIN TRAN

SELECT * FROM dbo.Users

ROLLBACK TRAN 


-- turn on RCSI and try again

ALTER DATABASE StackOverflow2010 SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE
GO

ALTER DATABASE StackOverflow2010 SET READ_COMMITTED_SNAPSHOT OFF WITH ROLLBACK IMMEDIATE
GO

/* If you have enough version store, this can give you sizeof the version store */ 
SELECT GETDATE() AS runtime,
    SUM(user_object_reserved_page_count) * 8 AS usr_obj_kb,
    SUM(internal_object_reserved_page_count) * 8 AS internal_obj_kb,
    SUM(version_store_reserved_page_count) * 8 AS version_store_kb,
    SUM(unallocated_extent_page_count) * 8 AS freespace_kb,
    SUM(mixed_extent_page_count) * 8 AS mixedextent_kb
FROM sys.dm_db_file_space_usage;