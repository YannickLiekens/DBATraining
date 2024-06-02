--Sp blitz - Shows overall state of the server, configuration errors
EXEC sp_blitz 

-- BlitzIndex good overall indication of your indexes state
EXEC sp_blitzIndex @databasename = 'StackOverflow2010'

-- BlitzCache good overall check of your currently cached queries
EXEC sp_BlitzCache

-- Show WhoIsActive
-- - https://raw.githubusercontent.com/amachanic/sp_whoisactive/master/sp_WhoIsActive.sql

exec dba.dbo.sp_whoisactive

-- Place in job 
SET NOCOUNT ON;

DECLARE @retention INT = 7,
        @destination_table VARCHAR(500) = 'WhoIsActive',
        @destination_database sysname = 'dba',
        @schema VARCHAR(MAX),
        @SQL NVARCHAR(4000),
        @parameters NVARCHAR(500),
        @exists BIT;

SET @destination_table = @destination_database + '.dbo.' + @destination_table;

--create the logging table
IF OBJECT_ID(@destination_table) IS NULL
    BEGIN;
        EXEC dbo.sp_WhoIsActive @get_transaction_info = 1,
                                @get_outer_command = 1,
                                @get_plans = 1,
                                @return_schema = 1,
                                @schema = @schema OUTPUT;
        SET @schema = REPLACE(@schema, '<table_name>', @destination_table);
        EXEC ( @schema );
    END;

--create index on collection_time
SET @SQL
    = 'USE ' + QUOTENAME(@destination_database)
      + '; IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(@destination_table) AND name = N''cx_collection_time'') SET @exists = 0';
SET @parameters = N'@destination_table varchar(500), @exists bit OUTPUT';
EXEC sys.sp_executesql @SQL, @parameters, @destination_table = @destination_table, @exists = @exists OUTPUT;

IF @exists = 0
    BEGIN;
        SET @SQL = 'CREATE CLUSTERED INDEX cx_collection_time ON ' + @destination_table + '(collection_time ASC)';
        EXEC ( @SQL );
    END;

--collect activity into logging table
EXEC dbo.sp_WhoIsActive @get_transaction_info = 1,
                        @get_outer_command = 1,
                        @get_plans = 1,
                        @destination_table = @destination_table;

--purge older data
SET @SQL
    = 'DELETE FROM ' + @destination_table + ' WHERE collection_time < DATEADD(day, -' + CAST(@retention AS VARCHAR(10))
      + ', GETDATE());';
EXEC ( @SQL );


-- Show QueryStore

USE [master]
GO
ALTER DATABASE [StackOverflow2010] SET QUERY_STORE = ON
GO
ALTER DATABASE [StackOverflow2010] SET QUERY_STORE (OPERATION_MODE = READ_WRITE)
GO

Use StackOverflow2010
GO

SELECT * FROM dbo.Users
SELECT * FROM dbo.Posts

SELECT * FROM dbo.Users Users
INNER JOIN dbo.Posts Posts
ON Users.Id = Posts.ParentId
WHERE Users.Reputation > 50 



-- Extended events 
CREATE EVENT SESSION [CapturingQueries] ON SERVER 
ADD EVENT sqlserver.rpc_completed,
ADD EVENT sqlserver.sp_statement_completed(
    ACTION(sqlserver.database_id,sqlserver.database_name,sqlserver.server_principal_name,sqlserver.session_id)
    WHERE (([package0].[greater_than_uint64]([sqlserver].[database_id],(4))) AND ([package0].[equal_boolean]([sqlserver].[is_system],(0))))),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(sqlserver.database_id,sqlserver.database_name,sqlserver.server_principal_name,sqlserver.session_id)
    WHERE (([package0].[greater_than_uint64]([sqlserver].[database_id],(4))) AND ([package0].[equal_boolean]([sqlserver].[is_system],(0)))))
ADD TARGET package0.event_file(SET filename=N'C:\Temp\Backups\PerfTuning.xel')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO


-- Which metric is used
SELECT p.name package_name,
       o.name event_name,
       c.name event_field,
       DurationUnit= CASE
                         WHEN c.description LIKE '%milli%' 
                         THEN SUBSTRING(c.description, CHARINDEX('milli', c.description),12)
                         WHEN c.description LIKE '%micro%' 
                         THEN SUBSTRING(c.description, CHARINDEX('micro', c.description),12)
                         ELSE NULL
                     END,
       c.type_name field_type,
       c.column_type column_type
FROM sys.dm_xe_objects o
JOIN sys.dm_xe_packages p ON o.package_guid = p.guid
JOIN sys.dm_xe_object_columns c ON o.name = c.object_name
WHERE o.object_type = 'event'
AND c.name ='duration'



-- Diagnostic queries 
https://glennsqlperformance.com/resources/

