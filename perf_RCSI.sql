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