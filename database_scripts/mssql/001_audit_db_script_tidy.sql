IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'AuditLogsBackUp')
    BEGIN
    EXEC sp_rename 'AuditLogs', 'AuditLogsBackUp';
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'AuditLogMetaBackUp')
    BEGIN
    EXEC sp_rename 'AuditLogMeta', 'AuditLogMetaBackUp';
END
