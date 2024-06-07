use StackOverflow2010
GO

CREATE INDEX Reputation ON dbo.Users(Reputation);
--CREATE INDEX Reputation ON dbo.Users(Reputation DESC);

-- If index is ASC, but index and DESC, it can still use it 

SELECT TOP 100 *
FROM dbo.Users
ORDER BY Reputation DESC;

-- Index scan operator -> properties 



CREATE INDEX Reputation_DisplayName
  ON dbo.Users(Reputation, DisplayName);
GO

SELECT TOP 100 *
FROM dbo.Users
ORDER BY Reputation DESC, DisplayName;


-- If we alternate the order of the indexes this does work:
CREATE INDEX Reputation_DESC_DisplayName_ASC
  ON dbo.Users(Reputation DESC, DisplayName ASC);
GO
SELECT TOP 100 *
FROM dbo.Users
ORDER BY Reputation DESC, DisplayName;

SELECT TOP 100 *
FROM dbo.Users
ORDER BY Reputation ASC, DisplayName DESC;


exec dbo.DropIndexes