/* How to we create indexes for the following queries?*/

SET STATISTICS TIME,IO ON

use StackOverflow2010
GO

/* Use EXEC dbo.DropIndexes after every query to clear all indexes in the database */ 

/* ex 1 */  

SELECT Id,DisplayName
FROM dbo.Users
WHERE Reputation > 100
	AND LastAccessDate < '20200101'

exec dbo.DropIndexes

/* ex 2 */ 

SELECT TOP (1000)
U.Reputation,
U.Upvotes,
U.DownVotes,
U.CreationDate
FROM dbo.Users U
ORDER BY u.UpVotes

exec dbo.DropIndexes

/* ex 3 */ 

SELECT 
U.Reputation,
U.Upvotes,
U.DownVotes,
U.CreationDate
FROM dbo.Users U
WHERE u.Reputation = 1 
ORDER BY u.UpVotes

exec dbo.DropIndexes

/* ex 4 
Ps no results here */

SELECT 
U.Reputation,
U.Upvotes,
U.DownVotes,
U.CreationDate
FROM dbo.Users U
WHERE u.Reputation > 100000
	AND  [location] = 'Corvallis, OR'

exec dbo.DropIndexes

/* ex 5 */

SELECT TOP (39)
u.DisplayName,
u.reputation,
b.Name
FROM dbo.Users U
CROSS APPLY ( SELECT TOP (1) b.Name
	FROM dbo.Badges as b
	WHERE b.userId = u.Id 
	ORDER BY b.Date DESC )
	AS B
WHERE U.Reputation > 5000

exec dbo.DropIndexes

/* ex 6 */
SELECT AboutMe
FROM dbo.Users
WHERE AboutMe LIKE 'test%'

exec dbo.DropIndexes


/* ex 7 */
SELECT Id
FROM dbo.Users
WHERE Reputation > 0 

exec dbo.DropIndexes
