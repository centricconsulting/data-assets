/* 
####################################################################

   The following script creates documentation output based the
   in specified cube/server.

   https://gist.github.com/mlongoria/a9a0bff0f51a5e9c200b9c8b378d79da
   https://community.powerbi.com/t5/Desktop/List-ALL-Calculated-COLUMNS-in-a-Data-Model/td-p/152291


	-- listing of TMSCHEMA views
	SELECT *
	FROM OPENROWSET(
	  'MSOLAP'
	, 'DATASOURCE=IAD-C-AAD08.eplus.corp; Initial Catalog=ePlus Analytics;'
	, 'SELECT * FROM $SYSTEM.DBSCHEMA_TABLES') 
	WHERE CONVERT(varchar(200),TABLE_NAME) LIKE 'TMSCHEMA%'
	ORDER BY CONVERT(varchar(200),TABLE_NAME)

	TMSCHEMA_ANNOTATIONS
	TMSCHEMA_ATTRIBUTE_HIERARCHIES
	TMSCHEMA_ATTRIBUTE_HIERARCHY_STORAGES
	TMSCHEMA_COLUMN_PARTITION_STORAGES
	TMSCHEMA_COLUMN_STORAGES
	TMSCHEMA_COLUMNS
	TMSCHEMA_CULTURES
	TMSCHEMA_DATA_SOURCES
	TMSCHEMA_DICTIONARY_STORAGES
	TMSCHEMA_HIERARCHIES
	TMSCHEMA_HIERARCHY_STORAGES
	TMSCHEMA_KPIS
	TMSCHEMA_LEVELS
	TMSCHEMA_LINGUISTIC_METADATA
	TMSCHEMA_MEASURES
	TMSCHEMA_MODEL
	TMSCHEMA_OBJECT_TRANSLATIONS
	TMSCHEMA_PARTITION_STORAGES
	TMSCHEMA_PARTITIONS
	TMSCHEMA_PERSPECTIVE_COLUMNS
	TMSCHEMA_PERSPECTIVE_HIERARCHIES
	TMSCHEMA_PERSPECTIVE_MEASURES
	TMSCHEMA_PERSPECTIVE_TABLES
	TMSCHEMA_PERSPECTIVES
	TMSCHEMA_RELATIONSHIP_INDEX_STORAGES
	TMSCHEMA_RELATIONSHIP_STORAGES
	TMSCHEMA_RELATIONSHIPS
	TMSCHEMA_ROLE_MEMBERSHIPS
	TMSCHEMA_ROLES
	TMSCHEMA_SEGMENT_MAP_STORAGES
	TMSCHEMA_SEGMENT_STORAGES
	TMSCHEMA_STORAGE_FILES
	TMSCHEMA_STORAGE_FOLDERS
	TMSCHEMA_TABLE_PERMISSIONS
	TMSCHEMA_TABLE_STORAGES
	TMSCHEMA_TABLES

####################################################################
*/

/* ################################################################# */
-- DROP TEMP TABLES

DROP TABLE #model;
DROP TABLE #tables;
DROP TABLE #columns;
DROP TABLE #measures;
DROP TABLE #data_sources;

DROP TABLE #perspectives;
DROP TABLE #perspective_columns;
DROP TABLE #perspective_measures;
DROP TABLE #perspective_tables;

DROP TABLE #attribute_hierarchies;
DROP TABLE #attribute_hierarchy_storages;

DROP TABLE #result;
DROP TABLE #doc;


/* ################################################################# */
-- CREATE TEMP TABLES
-- NOTE: The RefreshTime sometimes produces an error and must be excluded

/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 

IMPORTANT NOTE:
It is necessary to change the server and cube name in each of the 
OPENROWSET calls before executing this script.

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */

SELECT 
  ID
, TableID
, ExplicitName
, InferredName
, ExplicitDataType
, InferredDataType
, DataCategory
, [Description]
, IsHidden
, [State]
, IsUnique
, IsKey
, IsNullable
, Alignment
, TableDetailPosition
, IsDefaultLabel
, IsDefaultImage
, SummarizeBy
, ColumnStorageID
, [Type]
, SourceColumn
, ColumnOriginID
, Expression
, FormatString
, IsAvailableInMDX
, SortByColumnID
, AttributeHierarchyID
, ModifiedTime
, StructureModifiedTime
-- , RefreshedTime -- excluded, may produce error
, SystemFlags
, KeepUniqueRows
, DisplayOrdinal
, ErrorMessage
, SourceProviderType
, DisplayFolder
INTO #columns
FROM 
OPENROWSET(
  'MSOLAP'
, 'DATASOURCE=IAD-C-AAD08.eplus.corp; Initial Catalog=ePlus Analytics;'
, 'SELECT * FROM $SYSTEM.TMSCHEMA_COLUMNS');
;

SELECT *
INTO #data_sources
FROM 
OPENROWSET(
  'MSOLAP'
, 'DATASOURCE=IAD-C-AAD08.eplus.corp; Initial Catalog=ePlus Analytics;'
, 'SELECT * FROM $SYSTEM.TMSCHEMA_DATA_SOURCES');
;

SELECT *
INTO #model
FROM 
OPENROWSET(
  'MSOLAP'
, 'DATASOURCE=IAD-C-AAD08.eplus.corp; Initial Catalog=ePlus Analytics;'
, 'SELECT * FROM $SYSTEM.TMSCHEMA_MODEL');
;

SELECT *
INTO #tables
FROM 
OPENROWSET(
  'MSOLAP'
, 'DATASOURCE=IAD-C-AAD08.eplus.corp; Initial Catalog=ePlus Analytics;'
, 'SELECT * FROM $SYSTEM.TMSCHEMA_TABLES');
;

SELECT *
INTO #measures
FROM OPENROWSET(
  'MSOLAP'
, 'DATASOURCE=IAD-C-AAD08.eplus.corp; Initial Catalog=ePlus Analytics;'
, 'SELECT * FROM $SYSTEM.TMSCHEMA_MEASURES')
;

SELECT *
INTO #perspectives
FROM OPENROWSET(
  'MSOLAP'
, 'DATASOURCE=IAD-C-AAD08.eplus.corp; Initial Catalog=ePlus Analytics;'
, 'SELECT * FROM $SYSTEM.TMSCHEMA_PERSPECTIVES')
;

SELECT *
INTO #perspective_tables
FROM OPENROWSET(
  'MSOLAP'
, 'DATASOURCE=IAD-C-AAD08.eplus.corp; Initial Catalog=ePlus Analytics;'
, 'SELECT * FROM $SYSTEM.TMSCHEMA_PERSPECTIVE_TABLES')
;

SELECT *
INTO #perspective_columns
FROM OPENROWSET(
  'MSOLAP'
, 'DATASOURCE=IAD-C-AAD08.eplus.corp; Initial Catalog=ePlus Analytics;'
, 'SELECT * FROM $SYSTEM.TMSCHEMA_PERSPECTIVE_COLUMNS')
;

SELECT *
INTO #perspective_measures
FROM OPENROWSET(
  'MSOLAP'
, 'DATASOURCE=IAD-C-AAD08.eplus.corp; Initial Catalog=ePlus Analytics;'
, 'SELECT * FROM $SYSTEM.TMSCHEMA_PERSPECTIVE_MEASURES')
;

SELECT *
INTO #attribute_hierarchy_storages
FROM OPENROWSET(
  'MSOLAP'
, 'DATASOURCE=IAD-C-AAD08.eplus.corp; Initial Catalog=ePlus Analytics;'
, 'SELECT * FROM $SYSTEM.TMSCHEMA_ATTRIBUTE_HIERARCHY_STORAGES')
;

SELECT *
INTO #attribute_hierarchies
FROM OPENROWSET(
  'MSOLAP'
, 'DATASOURCE=IAD-C-AAD08.eplus.corp; Initial Catalog=ePlus Analytics;'
, 'SELECT * FROM $SYSTEM.TMSCHEMA_ATTRIBUTE_HIERARCHIES')
;

/* ################################################################# */

SELECT *
INTO #result
FROM (

	SELECT top 1000
	  t.ID AS TableID
	, CAST(t.Name AS varchar(200)) AS [Table]
	, c.ID as ElementID
	, CAST(c.ExplicitName AS varchar(200)) AS [Element]
	, 'Column' AS [Element Type]
	, CAST(ISNULL(cs.ExplicitName, c.ExplicitName) AS varchar(200)) AS [Sort Column]

	, CASE ISNULL(ahss.SortOrder, ahs.SortOrder)
	  WHEN 0 THEN 'Ascending'
	  ELSE 'Descending' 
	  END AS [Sort Direction]

	, CASE c.IsHidden 
	  WHEN 1 THEN 'Hidden'
	  ELSE 'Visible' 
	  END AS Visibility

	, CASE
	  WHEN c.DisplayFolder IS NOT NULL 
		THEN CAST(t.Name AS varchar(200)) + '\' + CAST(c.DisplayFolder AS varchar(200))
	  ELSE CAST(t.Name AS varchar(200))
	  END AS [Folder]

	, CASE
	  WHEN c.ExplicitDataType = 11 THEN 'Boolean'
	  WHEN c.ExplicitDataType = 6 THEN 'Integer'
	  WHEN c.ExplicitDataType = 9 THEN 'Date'
	  WHEN c.ExplicitDataType = 2 THEN 'Text'
	  WHEN c.ExplicitDataType = 8 AND c.FormatString LIKE '%\%' ESCAPE '\' THEN 'Percentage' 
	  WHEN c.ExplicitDataType = 20 AND c.FormatString LIKE '%\%' ESCAPE '\' THEN 'Percentage' 
	  WHEN c.ExplicitDataType = 8 THEN 'Decimal' 
	  WHEN c.ExplicitDataType = 20 THEN 'Decimal'
	  ELSE 'Other (' + CAST(c.ExplicitDataType AS varchar(200)) + ')'
	  END AS [Data Type]

	, CASE
	  WHEN c.IsHidden = 1 THEN 'Not Applicable'
	  WHEN c.ExplicitDataType = 2 THEN 'Display Text'
	  ELSE ISNULL(CAST(c.FormatString AS varchar(200)), 'Missing')
	  END AS [Format]

	, CAST(c.Expression AS varchar(200)) AS [Expression]
	
	, CAST(c.SourceColumn AS varchar(200)) AS [Source Column]
	FROM
	#tables t
	INNER JOIN #columns c ON c.TableID = t.ID
	LEFT JOIN #columns cs ON cs.TableID = c.TableID AND cs.ID = c.SortByColumnID
	LEFT JOIN #attribute_hierarchy_storages ahs ON ahs.AttributeHierarchyID = c.AttributeHierarchyID
	LEFT JOIN #attribute_hierarchy_storages ahss ON ahss.AttributeHierarchyID = cs.AttributeHierarchyID
	WHERE
	c.ExplicitName NOT LIKE 'RowNumber-%'

	UNION ALL 

	SELECT
	  t.ID AS [TableID]
	, CAST(t.Name AS varchar(200)) AS [Table]
	, m.ID AS [ElementID]
	, CAST(m.Name AS varchar(200)) AS [Element]
	, 'Measure' AS [Element Type]
	, 'Not Applicable' AS [Sort Column]
	, 'Not Applicable' AS [Sort Direction]

	, CASE m.IsHidden 
	  WHEN 1 THEN 'Hidden'
	  ELSE 'Visible' 
	  END AS [Visibility]

	, CASE
	  WHEN m.DisplayFolder IS NOT NULL 
		THEN CAST(t.Name AS varchar(200)) + '\' + CAST(m.DisplayFolder AS varchar(200))
	  ELSE CAST(t.Name AS varchar(200)) 
	  END AS [Folder]

	, CASE
	  WHEN m.DataType = 11 THEN 'Boolean'
	  WHEN m.DataType = 6 THEN 'Integer'
	  WHEN m.DataType = 9 THEN 'Date'
	  WHEN m.DataType = 2 THEN 'Text'
	  WHEN m.DataType = 8 AND m.FormatString LIKE '%\%' ESCAPE '\' THEN 'Percentage' 
	  WHEN m.DataType = 20 AND m.FormatString LIKE '%\%' ESCAPE '\' THEN 'Percentage' 
	  WHEN m.DataType = 8 THEN 'Decimal' 
	  WHEN m.DataType = 20 THEN 'Decimal' 
	  ELSE 'Other (' + CAST(m.DataType AS varchar(200)) + ')'
	  END AS [Data Type]

	, CASE
	  WHEN m.IsHidden = 1 THEN 'Not Applicable'
	  WHEN m.DataType = 2 THEN 'Display Text'
	  ELSE ISNULL(CAST(m.FormatString AS varchar(200)), 'Missing')
	  END AS [Format]

	, CAST(m.Expression AS varchar(200)) AS [Expression]
	, 'Not Applicable' AS [Source Column]

	FROM
	#tables t
	INNER JOIN #measures m ON m.TableID = t.ID

) x
;


/* ################################################################# */
-- CREATE TARGET TABLE

CREATE TABLE #doc (
  [Perspective] varchar(200)
, [Perspective Type] varchar(200) -- Base Cube, Perspective
, [Table] varchar(200)
, [Element Type] varchar(200)
, [Element] varchar(200)
, [Visibility] varchar(200)
, [Folder] varchar(200)
, [Format] varchar(200)
, [Data Type] varchar(200)
, [Expression] varchar(200)
, [Sort Column] varchar(200)
, [Sort Direction] varchar(200)
, [Source Column] varchar(200)
)
;


/* ################################################################# */
-- POPULATE TARGET TABLE

TRUNCATE TABLE #doc;

INSERT INTO #doc (
  [Perspective]
, [Perspective Type]
, [Table]
, [Element Type]
, [Element]
, [Visibility]
, [Folder]
, [Format]
, [Data Type]
, [Expression]
, [Sort Column]
, [Sort Direction]
, [Source Column]
)
SELECT
  CAST(mo.Name AS varchar(200)) AS [Perspective]
, 'Cube' AS [Perspective Type]
, r.[Table]
, r.[Element Type]
, r.[Element]
, r.[Visibility]
, r.[Folder]
, r.[Format]
, r.[Data Type]
, r.[Expression]
, r.[Sort Column]
, r.[Sort Direction]
, r.[Source Column]
FROM
#result r
CROSS JOIN #model mo

UNION ALL

SELECT
  CAST(p.Name AS varchar(200)) AS [Perspective]
, 'Subject Area' AS [Perspective Type]
, r.[Table]
, r.[Element Type]
, r.[Element]
, r.[Visibility]
, r.[Folder]
, r.[Format]
, r.[Data Type]
, r.[Expression]
, r.[Sort Column]
, r.[Sort Direction]
, r.[Source Column]
FROM
#result r
INNER JOIN #perspective_columns pc ON pc.ColumnID = r.ElementID
INNER JOIN #perspective_tables pt ON pt.ID = pc.PerspectiveTableID
INNER JOIN #perspectives p ON p.ID = pt.PerspectiveID
WHERE
r.[Element Type] = 'Column'

UNION ALL

SELECT
  CAST(p.Name AS varchar(200)) AS [Perspective]
, 'Subject Area' AS [Perspective Type]
, r.[Table]
, r.[Element Type]
, r.[Element]
, r.[Visibility]
, r.[Folder]
, r.[Format]
, r.[Data Type]
, r.[Expression]
, r.[Sort Column]
, r.[Sort Direction]
, r.[Source Column]
FROM
#result r
INNER JOIN #perspective_measures pc ON pc.MeasureID = r.ElementID
INNER JOIN #perspective_tables pt ON pt.ID = pc.PerspectiveTableID
INNER JOIN #perspectives p ON p.ID = pt.PerspectiveID
WHERE
r.[Element Type] = 'Measure'
;


/* ################################################################# */
-- FINAL SELECT FROM TARGET TABLE

SELECT * FROM #doc;


/* #################################################################
-- FOR DEVELOPMENT PURPOSES

select top 100 * from #model
select top 100 * from #tables
select top 100 * from #columns
select top 100 * from #measures
select top 100 * from #perspectives
select top 100 * from #perspective_tables
select top 100 * from #perspective_columns
select top 100 * from #perspective_measures
select top 100 * from #attribute_hierarchies
select top 100 * from #attribute_hierarchy_storages
select top 100 * from #result

################################################################# */




