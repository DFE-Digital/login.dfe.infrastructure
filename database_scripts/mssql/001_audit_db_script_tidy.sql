BEGIN TRANSACTION AUDITNAME;
BEGIN TRY

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'AuditLogsBackUp')
    BEGIN
    EXEC sp_rename 'AuditLogs', 'AuditLogsBackUp';
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'AuditLogsBackUp')
    BEGIN
    ALTER TABLE dbo.AuditLogsBackUp
    DROP CONSTRAINT AuditLog_FK;
END

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'AuditLogMetaBackUp')
    BEGIN
    EXEC sp_rename 'AuditLogMeta', 'AuditLogMetaBackUp';
END

--Commit transaction if all went fine
COMMIT TRAN AUDITNAME;

END TRY
BEGIN CATCH
     SELECT
    ERROR_NUMBER() AS ErrorNumber
        , ERROR_SEVERITY() AS ErrorSeverity
        , ERROR_STATE() AS ErrorState
        , ERROR_PROCEDURE() AS ErrorProcedure
        , ERROR_LINE() AS ErrorLine
        , ERROR_MESSAGE() AS ErrorMessage;
     --Rollback if there was an error
     IF @@TRANCOUNT > 0
          ROLLBACK TRAN AUDITNAME;
END CATCH;
