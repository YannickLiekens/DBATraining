USE StackOverflow2013
GO

exec DropIndexes

ALTER DATABASE [StackOverflow2013] SET COMPATIBILITY_LEVEL = 130
GO
SET STATISTICS TIME,IO ON 
-- Should be done in 1.Scalar... if not create it now.
CREATE INDEX NCIi_OwnerUserID ON  dbo.Posts(OwnerUserID) WITH (DATA_COMPRESSION = PAGE)



/*

So we're going to make a table variable and load in 100 records, then join it to their posts and check the performance


*/
 DECLARE @Users_Table TABLE (Id INT,DisplayName varchar(50))


INSERT INTO @Users_Table 
 SELECT Id,DisplayName
  FROM dbo.Users
 WHERE Id < 100 

SELECT TableType.DisplayName,COUNT(*)
  FROM @Users_Table TableType
  INNER JOIN dbo.Posts Posts
  ON Posts.OwnerUserID = TableType.ID 
  GROUP BY TableType.DisplayName
GO


  
/*

That went fast! Now what if we increase the amount of records

*/

 DECLARE @Users_Table TABLE (Id INT,DisplayName varchar(50))


INSERT INTO @Users_Table 
SELECT Id,DisplayName
FROM dbo.Users

SELECT TableType.DisplayName,COUNT(*)
FROM @Users_Table TableType
INNER JOIN dbo.Posts Posts
ON Posts.OwnerUserID = TableType.ID 
GROUP BY TableType.DisplayName
OPTION (MAXDOP 1)



 GO



 /*

That took a bit longer, which is to be expected when loading in more data.. however that estimate is not what we're expecting

Now, what if we'd try the same with temp tables?

*/

SET STATISTICS time, IO ON
DROP TABLE IF EXISTS #Users_TempTable

CREATE TABLE #Users_TempTable(Id INT,DisplayName varchar(50))

INSERT INTO #Users_TempTable 
SELECT Id,DisplayName
FROM dbo.Users
WHERE Id < 100 


SELECT TempTable.DisplayName,COUNT(*)
  FROM #Users_TempTable TempTable
  INNER JOIN dbo.Posts Posts
  ON Posts.OwnerUserID = TempTable.ID 
  GROUP BY TempTable.DisplayName
  OPTION (MAXDOP 1)


 /*

Same as table varibles 

Let's increase the data again
*/

GO

SET STATISTICS time, IO ON
DROP TABLE IF EXISTS #Users_TempTable

CREATE TABLE #Users_TempTable(Id INT,DisplayName varchar(50))

INSERT INTO #Users_TempTable 
SELECT Id,DisplayName
FROM dbo.Users


SELECT TempTable.DisplayName,COUNT(*)
FROM #Users_TempTable TempTable
INNER JOIN dbo.Posts Posts
ON Posts.OwnerUserID = TempTable.ID 
GROUP BY TempTable.DisplayName
OPTION (MAXDOP 1)


 /*

That went about twice as fast, without changing anything!
Mainly because it's now using a different type of join. Nested loops is not that efficient for large joins.


Now... depending on the case you could make this go even faster since you' be able to create indexes on the temp table
Which you cannot do on the table variable.

*/



CREATE NONCLUSTERED INDEX NCIi_ID ON #Users_TempTable(id) INCLUDE (DisplayName)
GO


exec DropIndexes
