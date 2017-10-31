USE [tog_warehouse]
GO

/****** Object:  Table [dbo].[geography]    Script Date: 08/30/2011 11:31:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[geography](
	[state_or_province_key] [int] NOT NULL,
	[state_or_province_uid] [varchar](20) NOT NULL,
	[state_or_province_cd] [varchar](20) NULL,
	[state_or_province_name] [varchar](200) NULL,
	[state_or_province_type_desc] [varchar](50) NULL,
	[country_key] [int] NOT NULL,
	[country_uid] [varchar](20) NOT NULL,
	[state_or_province_unknown_flag] [char](1) NULL,
	[country_cd] [varchar](20) NULL,
	[country_name] [varchar](200) NULL,
	[country_iso_nbr] [char](3) NULL,
	[world_subregion] [varchar](50) NULL,
	[world_region] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


