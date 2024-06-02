USE StackOverflow2010
GO

--exec DropIndexes

CREATE INDEX NCI_UserId ON dbo.Votes( UserId )
CREATE INDEX NCI_CreationDate ON dbo.Users (CreationDate)

ALTER DATABASE StackOverflow2010
SET COMPATIBILITY_LEVEL = 130
GO
 /*

First off, I’m using the opensource database StackOverflow2010. 
I’m going to start off with creating a SVF, 
which’ll just count the amount of votes in the Votes table for a specific UserId.

*/
CREATE OR ALTER FUNCTION dbo.svf_YesWeCan(@UserId INT)
RETURNS INT
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
DECLARE @Count INT
SELECT @Count = COUNT(*)
FROM dbo.Votes
WHERE UserId = @UserID 
RETURN @Count
END
GO






 /*

And I’m adding a data filter, just so I don’t have to wait for too long.

*/
SET STATISTICS TIME,IO ON
SELECT Id,dbo.svf_YesWeCan(Id) AmountOfVotes
FROM dbo.Users
WHERE CreationDate > '20130501' AND CreationDate < '20130601'
GO


 /*

But…, that doesn’t even look that bad? 
So are scalar-valued functions not really an issue? 
Well, a careful eye would have noticed we’re missing something here. 
The SVF I made queries data from the Votes table, 
yet nowhere in the stats or in the plan we can see the votes.
*/



 /*

Currently one of the most used fixes for this (if you can change the code) 
is to turn the SVF into an inlined table valued function, like this:

*/


CREATE OR ALTER FUNCTION dbo.TVF_YesWeCan
(
@UserId INT
)
RETURNS TABLE
AS
RETURN
(
SELECT COUNT(*) Total
FROM dbo.Votes
WHERE UserId = @UserID
)
GO

 /*

And then, we can use it in our query:

*/


SELECT Id,TVF.Total
FROM dbo.Users
CROSS APPLY dbo.TVF_YesWeCan(Id) TVF
WHERE CreationDate > '20130501' AND CreationDate < '20130601'

/*

While this plan looks more complicated, it’s a lot more transparent to us.
We can also see that the query went parallel, which is good for this query because it allows 
it to go much faster.

*/



/*

SQL Server 2019 added Scalar UDF inlining.
Which in short, does the same as how we tried to fix things, but does it in the background.

*/


ALTER DATABASE StackOverflow2010
SET COMPATIBILITY_LEVEL = 150

--We run the same query as before with the SVF:

SET STATISTICS TIME,IO ON
SELECT Id,dbo.svf_YesWeCan(Id)
FROM dbo.Users
WHERE CreationDate > '20130501' AND CreationDate < '20130601'
GO












--Cleanup
exec dbo.DropIndexes
GO
ALTER DATABASE StackOverflow2010
SET COMPATIBILITY_LEVEL = 130

-- Create index for next demo.
CREATE INDEX NCIi_OwnerUserID ON  dbo.Posts(OwnerUserID) WITH (DATA_COMPRESSION = PAGE)
