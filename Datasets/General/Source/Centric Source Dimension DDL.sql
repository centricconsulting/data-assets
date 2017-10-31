USE [tog_warehouse]
GO

/****** Object:  Table [dbo].[source]    Script Date: 08/30/2011 11:36:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[source](
	[source_key] [int] NOT NULL,
	[source_uid] [varchar](20) NOT NULL,
	[source_name] [varchar](50) NOT NULL,
	[source_desc] [varchar](100) NULL,
	[dmproc_batch_key] [int] NOT NULL,
	CONSTRAINT source_pk PRIMARY KEY (source_key)
) ON [PRIMARY]

GO

CREATE UNIQUE INDEX source_u1 ON [source] (source_uid);
GO


SET ANSI_PADDING OFF
GO


