/* Anoter common mistake is the use of variables.
 */

 SET STATISTICS TIME,IO ON

CREATE NONCLUSTERED INDEX NCI_Reputation ON dbo.Users(Reputation)

DECLARE @Reputation INT = 50000

SELECT * FROM dbo.Users 
WHERE Reputation > @Reputation
GO
-- 89819

SELECT COUNT(*) FROM dbo.Users
--299398 
/* +- 30% */ 


/*
Lets run it without variable*/
 SELECT * FROM dbo.Users 
WHERE Reputation > 50000


-- Fixes?
-- - Don't use them.
-- - OPTION RECOMPILE
-- Use SP and use parameter


DECLARE @Reputation INT = 50000

SELECT * FROM dbo.Users 
WHERE Reputation > @Reputation
OPTION (RECOMPILE)
GO


CREATE OR ALTER PROCEDURE dbo.Users_ProcedureTest(@Reputation INT)
AS
BEGIN
SELECT * FROM dbo.Users 
WHERE Reputation > @Reputation
END

EXEC dbo.Users_ProcedureTest 50000