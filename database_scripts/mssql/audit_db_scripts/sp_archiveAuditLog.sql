SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[archiveAuditLog]
AS
DECLARE @exectime DATE;

SET @exectime = GETDATE();

PRINT 'Backing up data'
-- Insert all the records that are past last 3 months into the Audit backup tables
INSERT INTO dbo.[AuditLogsBackup]
SELECT *
FROM dbo.[AuditLogs] AL
WHERE NOT EXISTS (
		SELECT 1
		FROM dbo.[AuditLogsBackup] ALB
		WHERE ALB.id = AL.id
			AND AL.createdAt < DATEADD(MONTH, - 3, @exectime)
		)
	AND AL.createdAt < DATEADD(MONTH, - 3, @exectime)


INSERT INTO dbo.[AuditLogMetaBackup] (
	id
	,auditId
	,[key]
	,[value]
	)
SELECT [alm].[id]
	,[alm].[auditId]
	,[alm].[key]
	,[alm].[value]
FROM AuditLogMeta [alm]
INNER JOIN dbo.AuditLogsBackup [al] ON [alm].[auditId] = [al].[id]
WHERE NOT EXISTS (
		SELECT 1
		FROM dbo.AuditLogMetaBackUp ALB
		WHERE ALB.id = alm.id
		)
-- End of Insertion

-- Delete all the records past last 3 months from the main Audit Log tables
PRINT 'Deleting data'
DELETE ALM
FROM dbo.AuditLogMeta ALM
INNER JOIN dbo.AuditLogs AL ON ALM.auditId = AL.id
WHERE AL.createdAt < DATEADD(MONTH, - 3, @exectime);

DELETE AL
FROM dbo.AuditLogs AL
WHERE AL.createdAt < DATEADD(MONTH, - 3, @exectime);

-- End of deletion
GO
