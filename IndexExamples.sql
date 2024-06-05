use StackOverflow2010
GO

exec dbo.DropIndexes

SET STATISTICS TIME,IO ON

/*
Indexes are needed in order to get performant queries
*/

exec dba.dbo.sp_blitzindex @databasename = 'stackoverflow2010',@schemaname = 'dbo',@tablename = 'Users'

/* Show all users with reputation > 50000 */
SELECT * 
FROM dbo.Users
WHERE Reputation > 50000

/* scans entire table */ 

/* Now let's create an index */

CREATE NONCLUSTERED INDEX NCI_Reputation on dbo.Users(reputation)

SELECT * 
FROM dbo.Users
WHERE Reputation > 50000

/* Now we get a seek!
However, what is that lookup?
*/

SELECT Reputation
FROM dbo.Users
WHERE Reputation > 50000

/* Way better */

/* Let's add another predicate */
SELECT Reputation
FROM dbo.Users
WHERE Reputation > 50000


SELECT Reputation,DisplayName
FROM dbo.Users
WHERE Reputation > 50000
AND displayname = 'Rich Bradshaw'
/* Seeks into the the reputation, then filters out the displayname*/

exec dbo.DropIndexes

-- What if we create an index with a different order?
CREATE NONCLUSTERED INDEX NCI_Age_Reputation on dbo.Users(age,reputation)


SELECT Reputation,DisplayName
FROM dbo.Users
WHERE Reputation > 50000
AND displayname = 'Rich Bradshaw'

/* It can't use the reputation to seek on, so it just chooses to use the PK */