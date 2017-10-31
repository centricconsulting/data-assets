USE [tog_warehouse]
GO

/****** Object:  Table [dbo].[currency]    Script Date: 08/30/2011 11:36:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[currency](
	[currency_key] [int] NOT NULL,
	[currency_uid] [varchar](20) NOT NULL,
	[currency_cd] [varchar](20) NULL,
	[currency_name] [varchar](200) NULL,
	[currency_iso_nbr] [char](3) NULL,
	[significant_digits] [int] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


