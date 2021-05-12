SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT Routine_Name from information_schema.Routines WHERE Routine_Name = 'archiveAuditLog')
DROP PROCEDURE [archiveAuditLog]
GO


CREATE PROCEDURE [dbo].[archiveAuditLog]
AS

DECLARE @exectime DATE;
SET @exectime = GETDATE();

INSERT INTO dbo.[AuditLogsBackup] 
SELECT * FROM dbo.[AuditLogs] WHERE createdAt >= DATEADD(MONTH, -3, @exectime);


INSERT INTO dbo.[AuditLogMetaBackup] (id,auditId, "key","value")
SELECT [alm].[id], [alm].[auditId], [alm].[key], [alm].[value] FROM AuditLogMeta [alm] INNER JOIN dbo.AuditLogsBackup [al] ON [alm].[auditId] = [al].[id];


DELETE [alm]
FROM AuditLogMeta [alm]
INNER JOIN dbo.[AuditLogsBackup] [al] ON [alm].[auditId] = [al].[id];

DELETE FROM dbo.[AuditLogsBackup] WHERE [createdAt] >= DATEADD(MONTH, -3, @exectime);
GO
