Use StackOverflow2013


-- Creating extra indexes

CREATE NONCLUSTERED INDEX NCI_DisplayName ON dbo.Users(DisplayName) WITH (DATA_COMPRESSION = PAGE)
CREATE NONCLUSTERED INDEX NCI_CreationDate ON dbo.Users(CreationDate) WITH (DATA_COMPRESSION = PAGE)


/*
As per wikipedia SARGable is defined as “In relational databases, a condition (or predicate) in a query is said to be sargable if the DBMS engine can take advantage of an index to speed up the execution of the query. The term is derived from a contraction of Search ARGument ABLE”

Advantage of sargable queries include:

consuming less system resources
speeding up query performance
using indexes more effectively
*/


/* 

Two ways of using your index
* Seek
* Scan

Seek : Can directly start at where your predicate has to be, and run till it fetches all the data
SCan : Just scan over the entire index

*/


SET STATISTICS TIME,IO ON
-- Starting with a
SELECT COUNT(*)
 FROM dbo.Users
 WHERE  LEFT(DisplayName,1)='a'
 GO










 -- Starting with a SARG
 SELECT COUNT(*)
 FROM dbo.Users
 WHERE DisplayName LIKE 'a%'
 GO








 -- Same with datetime functions

-- All records made in 2008
 SELECT COUNT(*)
 FROM dbo.Users
 WHERE YEAR(creationdate) = '2008'
 GO



 -- All records made in 2008 SARG
SELECT COUNT(*)
 FROM dbo.Users
 WHERE CreationDate >= '20080101' AND  CreationDate < '20090101'
 GO





-- cleanup 
exec dbo.DropIndexes
