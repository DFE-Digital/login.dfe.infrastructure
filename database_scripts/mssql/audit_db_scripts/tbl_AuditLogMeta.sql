SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditLogMeta](
	[id] [uniqueidentifier] NOT NULL,
	[auditId] [uniqueidentifier] NOT NULL,
	[key] [nvarchar](125) NOT NULL,
	[value] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[AuditLogMeta] ADD PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AuditLogMeta]  WITH CHECK ADD  CONSTRAINT [AuditLog_FK] FOREIGN KEY([auditId])
REFERENCES [dbo].[AuditLogs] ([id])
GO
ALTER TABLE [dbo].[AuditLogMeta] CHECK CONSTRAINT [AuditLog_FK]
GO
