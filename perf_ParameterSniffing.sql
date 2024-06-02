/* 

We have two queries, one selecting on Reputation = 1 
One on reputation = 2

Now the interesting thing about the Reputation field is that there are a lot more people with rep = 1,
because this is what you start at

*/

--DROP INDEX NCI_CreationDate ON dbo.Users
--DROP INDEX NCI_DisplayName ON dbo.Users 
-- Create index on reputation

use StackOverflow2013
GO

CREATE INDEX NCI_Reputation ON dbo.Users(Reputation)
GO

SET STATISTICS TIME,IO ON
SELECT TOP 10000 *
FROM dbo.Users
WHERE Reputation = 1 

-- (1090043 rows affected)

SET STATISTICS TIME,IO ON
SELECT TOP 10000 *
 FROM dbo.Users
 WHERE Reputation  = 2 

 -- (1854 rows affected)
 GO


 /* 

Now we're going to create a stored procedure that does the same thing as the above queries.

*/

 CREATE OR ALTER PROCEDURE dbo.UsersByReputation
  @Reputation int
AS
SELECT TOP 10000 *
FROM dbo.Users
WHERE Reputation=@Reputation
ORDER BY DisplayName;
GO

/* 

We're going to run them, first with rep = 1 then rep 2, then we blow the plan cache, and do it in reverse order.

*/
DBCC FREEPROCCACHE
GO
EXEC dbo.UsersByReputation @Reputation =1;
GO
EXEC dbo.UsersByReputation @Reputation =2;
GO
 
DBCC FREEPROCCACHE
GO
EXEC dbo.UsersByReputation @Reputation =2;
GO
EXEC dbo.UsersByReputation @Reputation =1;
GO


/* 

Outside 

*/


EXEC dbo.usp_UsersByReputation @Reputation =2
WITH RECOMPILE;
GO
EXEC dbo.usp_UsersByReputation @Reputation =1
WITH RECOMPILE;
GO




-- cleanup
DROP INDEX NCI_Reputation ON dbo.Users