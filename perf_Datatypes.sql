/* 
Displayname is an NVARCHAR(40)
*/

/*
Let's start by seeing how it looks like when we use the correct data types
*/

CREATE INDEX NCI_displayName ON dbo.Users( displayName )


DECLARE @Input NVARCHAR(40)
SET @Input = 'Brent Ozar'

SELECT * FROM dbo.Users
WHERE displayName = @Input
GO

/*
Uses the Index
*/ 

/*
Does it change if we use incorrect parameters?
*/

DECLARE @Input NVARCHAR(MAX)
SET @Input = 'Brent Ozar'

SELECT * FROM dbo.Users
WHERE displayName = @Input
GO



/*
Will be making a copy of the users database and changing DisplayName to VARCHAR(40)
*/

SELECT * INTO dbo.UsersVARCHAR
FROM dbo.Users

ALTER TABLE dbo.UsersVARCHAR
ALTER COLUMN DisplayName VARCHAR(40)


/****** Object:  Index [PK_Users_Id]    Script Date: 03/06/2024 11:21:36 ******/
ALTER TABLE [dbo].UsersVARCHAR ADD  CONSTRAINT [PK_UsersVARCHAR_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

CREATE INDEX NCI_displayName ON dbo.UsersVARCHAR( displayName )

/*
What if we do the same now?
*/

DECLARE @Input NVARCHAR(40)
SET @Input = 'Brent Ozar'

SELECT * FROM dbo.UsersVARCHAR
WHERE displayName = @Input
GO

DECLARE @Input VARCHAR(40)
SET @Input = 'Brent Ozar'

SELECT * FROM dbo.UsersVARCHAR
WHERE displayName = @Input
GO




/* Now let's see if we create a table with NVARCHAR(MAX)
*/


SELECT * INTO dbo.UsersVARCHARMAX
FROM dbo.Users


ALTER TABLE dbo.UsersVARCHARMAX
ALTER COLUMN DisplayName NVARCHAR(MAX)


CREATE INDEX NCI_displayName ON dbo.UsersVARCHARMAX( displayName )


/* Oh oh, this is already not possible
*/


DECLARE @Input NVARCHAR(40)
SET @Input = 'Brent Ozar'

SELECT * FROM dbo.UsersVARCHARMAX
WHERE displayName = @Input
GO

ALTER TABLE dbo.UsersVARCHARMAX
ALTER COLUMN DisplayName VARCHAR(40)


DECLARE @Input NVARCHAR(40)
SET @Input = 'Brent Ozar'

SELECT * FROM dbo.UsersVARCHARMAX
WHERE displayName = @Input
GO


exec DropIndexes
DROP TABLE dbo.UsersVARCHARMAX
DROP TABLE dbo.UsersVARCHAR


/* 
* No index usage or bad index usage
* More resources to build plans AND memory requested
*/ 