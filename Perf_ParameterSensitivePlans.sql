CREATE DATABASE [FunWithParameterSniffing]
GO

/* Change Database name FunWithParameterSniffing to any database you want to work on */ 
ALTER DATABASE [FunWithParameterSniffing] SET COMPATIBILITY_LEVEL = 150 
GO 
 
/* Create the table we'll use in the demo */  
CREATE TABLE dbo.SnifSnif( Id int PRIMARY KEY IDENTITY(1,1), Reputation INT , WillItRun nvarchar(512))  
GO 
 
/* Fill the table with dummy data */  
 
INSERT INTO dbo.SnifSnif ( Reputation, WillItRun)  
SELECT TOP 10 0,'We will find out' 
FROM master.dbo.syscolumns SysCol CROSS JOIN master.dbo.syscolumns SysCol2 
 
INSERT INTO dbo.SnifSnif ( Reputation, WillItRun)  
SELECT TOP 1000000 1, 'Hopefully?' 
FROM master.dbo.syscolumns SysCol CROSS JOIN master.dbo.syscolumns SysCol2 
 
/* Create an index on the field we're going to work with */  
CREATE NONCLUSTERED INDEX NCI_Id ON dbo.SnifSnif(Reputation) 
GO



SET STATISTICS TIME,IO ON 
SELECT id, WillItRun 
FROM dbo.SnifSnif 
WHERE Reputation = 0


SET STATISTICS TIME,IO ON 
SELECT id, WillItRun 
 FROM dbo.SnifSnif 
 WHERE Reputation  = 1
 go

 CREATE OR ALTER PROCEDURE dbo.SnifSnifByReputation 
  @Reputation int 
AS 
SELECT id, WillItRun 
FROM dbo.SnifSnif 
WHERE Reputation=@Reputation 
GO


/* DO NOT RUN THIS ON PRODUCTION */ 
DBCC FREEPROCCACHE 
GO 
EXEC dbo.SnifSnifByReputation @Reputation =0; 
GO 
EXEC dbo.SnifSnifByReputation @Reputation =1; 
GO

/* Query cache */  
SELECT Cached_Plans.usecounts, sql_text.text, Query_Plans.query_plan 
-- SELECT *  
FROM sys.dm_exec_cached_plans Cached_Plans 
CROSS APPLY sys.dm_exec_sql_text(plan_handle) sql_text 
CROSS APPLY sys.dm_exec_query_plan(plan_handle) Query_Plans 
ORDER BY Cached_Plans.usecounts DESC


DBCC FREEPROCCACHE 
GO 
EXEC dbo.SnifSnifByReputation @Reputation =1; 
GO 
EXEC dbo.SnifSnifByReputation @Reputation =0; 
GO


/* Query cache */  
SELECT Cached_Plans.usecounts, sql_text.text, Query_Plans.query_plan 
-- SELECT *  
FROM sys.dm_exec_cached_plans AS Cached_Plans 
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS sql_text 
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS Query_Plans 
ORDER BY Cached_Plans.usecounts DESC


/* Turn on correct database settings needed */  
/* Change Database name FunWithParameterSniffing to any database you want to work on */ 
ALTER DATABASE [FunWithParameterSniffing] SET COMPATIBILITY_LEVEL = 160 
GO 
 
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SENSITIVE_PLAN_OPTIMIZATION = ON


/* DO NOT RUN THIS ON PRODUCTION */ 
DBCC FREEPROCCACHE 
GO 
EXEC dbo.SnifSnifByReputation @Reputation =0; 
GO 
EXEC dbo.SnifSnifByReputation @Reputation =1;

/* Query cache */  
SELECT Cached_Plans.usecounts, sql_text.text, Query_Plans.query_plan 
-- SELECT *  
FROM sys.dm_exec_cached_plans AS Cached_Plans 
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS sql_text 
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS Query_Plans 
ORDER BY Cached_Plans.usecounts DESC

/* BOL
https://learn.microsoft.com/en-us/sql/relational-databases/performance/parameter-sensitive-plan-optimization?view=sql-server-ver16
*/

