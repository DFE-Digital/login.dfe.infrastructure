SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditLogsBackUp](
	[id] [uniqueidentifier] NOT NULL,
	[level] [nvarchar](255) NULL,
	[message] [nvarchar](max) NULL,
	[createdAt] [datetimeoffset](7) NOT NULL,
	[updatedAt] [datetimeoffset](7) NOT NULL,
	[application] [varchar](255) NULL,
	[environment] [varchar](255) NULL,
	[type] [varchar](255) NULL,
	[subType] [varchar](255) NULL,
	[userId] [uniqueidentifier] NULL,
	[organisationId] [uniqueidentifier] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[AuditLogsBackUp] ADD PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [level] ON [dbo].[AuditLogsBackUp]
(
	[level] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [type] ON [dbo].[AuditLogsBackUp]
(
	[type] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [userId] ON [dbo].[AuditLogsBackUp]
(
	[userId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
