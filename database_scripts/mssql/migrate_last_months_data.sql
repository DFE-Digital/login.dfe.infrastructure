IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'AuditLogs')
    BEGIN
    CREATE TABLE AuditLogs
    (
        id uniqueidentifier NOT NULL,
        level nvarchar(255),
        message nvarchar(max),
        createdAt datetimeoffset NOT NULL,
        updatedAt datetimeoffset NOT NULL,
        application varchar(255),
        environment varchar(255),
        type varchar(255),
        subType varchar(255),
        userId uniqueidentifier,
        organisationid uniqueidentifier
    );
END

---------------------------------------------

BEGIN TRANSACTION COPYAUDITDATA;
INSERT INTO dbo.AuditLogs
SELECT * FROM dbo.AuditLogsBackup WHERE createdAt >= DATEADD(MONTH, -3, GETDATE());
COMMIT TRANSACTION COPYAUDITDATA;

---------------------------------------------

ALTER TABLE dbo.AuditLogs add primary key (id);
CREATE INDEX level ON dbo.AuditLogs (level);
CREATE INDEX userId ON dbo.AuditLogs (userId);
CREATE INDEX type ON dbo.AuditLogs (type);

---------------------------------------------

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'AuditLogMeta')
    BEGIN
    CREATE TABLE AuditLogMeta
    (
        id uniqueidentifier NOT NULL,
        auditId uniqueidentifier NOT NULL,
        [key] nvarchar(125) NOT NULL,
        [value] nvarchar(max) NULL,
        CONSTRAINT [AuditLog_FK2] FOREIGN KEY (auditId) REFERENCES AuditLogs(id)
    );
END
--------------------------

BEGIN TRANSACTION COPYAUDITMETADATA;
INSERT INTO dbo.AuditLogMeta (id,auditId, "key","value")
SELECT almb.[id], almb.[auditId], almb.[key], almb.[value] FROM AuditLogMetaBackUp almb INNER JOIN dbo.AuditLogs al ON almb.auditId = al.id;

DELETE almb
FROM AuditLogMetaBackUp almb
INNER JOIN dbo.AuditLogs al ON almb.auditId = al.id;
COMMIT TRANSACTION COPYAUDITMETADATA;

------------

BEGIN TRANSACTION DELETELOGBACKUP;
DELETE FROM dbo.AuditLogsBackup WHERE createdAt >= DATEADD(MONTH, -3, GETDATE());
COMMIT TRANSACTION DELETELOGBACKUP;