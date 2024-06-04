EXEC sp_configure 'show advanced options',1
GO
RECONFIGURE
GO

EXEC sys.sp_configure N'min server memory (MB)', N'2048'
GO
EXEC sys.sp_configure N'max server memory (MB)', N'6144'
GO
EXEC sys.sp_configure N'backup compression default', N'1'
GO
EXEC sp_configure 'xp_cmdshell',0
GO
EXEC sys.sp_configure N'cost threshold for parallelism', N'80'
GO
EXEC sys.sp_configure N'max degree of parallelism', N'2'
RECONFIGURE WITH OVERRIDE
GO
EXEC sp_configure 'show advanced options',0
GO


-- IF INSTALLING OLDER VERSIONS, ALSO DO MODEL DATABASE
USE [master]
GO
ALTER DATABASE [master] MODIFY FILE ( NAME = N'master', FILEGROWTH = 65536KB, SIZE =65536KB  )
GO
ALTER DATABASE [master] MODIFY FILE ( NAME = N'mastlog', FILEGROWTH = 65536KB, SIZE =65536KB )
GO

-- Install mail agent 

-- Install alerts (if requested)