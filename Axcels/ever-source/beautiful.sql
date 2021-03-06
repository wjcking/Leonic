USE [Beautiful]
GO
/****** Object:  StoredProcedure [dbo].[$sp_import_datasource]    Script Date: 2021/3/10 星期三 下午 11:26:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[$sp_import_datasource]
	@sourcePath AS NVARCHAR(MAX) = 'e:\附体记录\beautiful.xlsx'
	, @sheetName AS  NVARCHAR(MAX) = 'characters' -- 不用[$]
AS
BEGIN
	DECLARE @sql AS NVARCHAR(MAX) 
	
	IF OBJECT_ID(@sheetName, 'U') IS NOT NULL
	BEGIN
		SET @sql = 'DROP TABLE [dbo].' + @sheetName
		EXECUTE(@sql)
	END

	SET @sql = '  SELECT * INTO [dbo].['+@sheetName+'] FROM OPENDATASOURCE(''Microsoft.ACE.OLEDB.12.0'',''Excel 12.0;HDR=Yes;IMEX=1; Database=' + @sourcePath + ''')...[' + @sheetName+'$]'
	--PRINT(@sql)
	EXECUTE(@sql)
	RETURN 0
END
GO
/****** Object:  StoredProcedure [dbo].[add_incident_info]    Script Date: 2021/3/10 星期三 下午 11:26:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[add_incident_info]
	 @rid  AS NVARCHAR(MAX) = 0
	,@desc AS NVARCHAR(MAX) = ''

	,@priority_id AS INT = 0
	--,@inserttime AS DATETIME  
	--,@updatetime AS DATETIME 
AS
BEGIN
	SET NOCOUNT ON;
	
	IF (@desc = '')  
	BEGIN
		SELECT -1 
		RETURN
	END
 
	DECLARE @count AS INT =  0
	SELECT @count = count(*)  FROM [dbo].incident WHERE rid = @rid AND [desc] = @desc
	 
	IF (@count  > 0)  
	BEGIN
		SELECT -2 
		RETURN
	END


	INSERT INTO [dbo].[incident]  (rid ,[desc] ,[priority_id] ,insert_time ,update_time)
	VALUES(@rid,@desc,@priority_id,getdate(),getdate())

	SELECT 1 
END
GO
/****** Object:  StoredProcedure [dbo].[add_role_info]    Script Date: 2021/3/10 星期三 下午 11:26:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[add_role_info]
	@id AS INT =  0
	 ,@name  AS NVARCHAR(MAX) =''
	 ,@parent_id AS INT = 0
	,@desc AS NVARCHAR(MAX) = ''
	,@category_id AS NVARCHAR(MAX) = 0
	,@priority_id AS INT = 0
	--,@starttime AS DATETIME  
	--,@endtime AS DATETIME  
AS
BEGIN

	SET NOCOUNT ON;

	IF (@name = '') 
	BEGIN
		SELECT -1
		RETURN 
	END
	-- id= 0 Max
	DECLARE @maxID AS INT = 0
	IF (@id = 0) 
	BEGIN
		SELECT  @maxID = max(id) FROM [dbo].[role]
	END
	SET @maxID = @id
	-- parent 模式
	--DECLARE @count AS INT = 0

	--IF EXISTS ( SELECT TOP 1 * FROM [dbo].[role] WHERE id=@maxID AND parent_id = @parent_id)
	--BEGIN
	--	SELECT -2
	--	RETURN 
	--END

	INSERT INTO [dbo].[role]  (id,[name] , [parent_id],[desc],category_id,[priority_id])
	VALUES(@maxID,@name,@parent_id, @desc,@category_id,@priority_id)
	
	SELECT @maxID
	 
END
GO
/****** Object:  StoredProcedure [dbo].[get_category_list]    Script Date: 2021/3/10 星期三 下午 11:26:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[get_category_list]
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	 SELECT  
		 rc.id
		,rc.parent_id
		, rc.[name] 
		 ,n.[name] as shape
	   ,n.[desc] as node_style
	   
	   ,e.[name]  as edge_label
	   ,e.[desc] as edge_style
	  FROM   [Beautiful].[dbo].[role_category] rc
		 
	  --不和shape关联 是 role id 和 node id
		  LEFT JOIN [Beautiful].[dbo].[nodes] n
		  ON rc.id = n.id
 
 
		  --注意FROM   TO   
		  LEFT JOIN [Beautiful].[dbo].[edges] e
		  ON rc.id   = e.id
	 -- ORDER BY i.insert_time DESC
	  --GROUP BY 	c.[name]
			--,c.[priority]
			--,i.[desc]
			--,i.[priority]

END
GO
/****** Object:  StoredProcedure [dbo].[get_incident_list]    Script Date: 2021/3/10 星期三 下午 11:26:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[get_incident_list]
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	 SELECT  
		i.id as [incident_id]
		, r.id  AS role_id
		 ,r.parent_id AS role_parent_id
		,r.[name]  AS role_name
		,r.category_id AS role_category_id
		,rc.[name] as role_category_name

		,r.[priority_id] AS role_priority_id
		,i.[desc] as incident_desc
		,i.[priority_id] AS incident_priority_id


		,n.[name] as shape
	   ,n.[desc] as node_style
	   
	   ,e.[name]  as edge_label
	   ,e.[desc] as edge_style
		,i.insert_time


	  FROM  
		  [Beautiful].[dbo].incident  i
			LEFT JOIN [Beautiful].[dbo].[role] r
		  ON  i.role_id=r.id 
	   	LEFT JOIN [dbo].[role_category] rc
		  ON  r.category_id =rc.id 
	  --不和shape关联 是 role id 和 node id
	  LEFT JOIN [Beautiful].[dbo].[nodes] n
	  ON r.category_id = n.id
 
 
	  --注意FROM   TO   
	  LEFT JOIN [Beautiful].[dbo].[edges] e
	  ON r.category_id   = e.id

		  
	  ORDER BY i.insert_time DESC
	  --GROUP BY 	c.[name]
			--,c.[priority]
			--,i.[desc]
			--,i.[priority]

END
GO
/****** Object:  StoredProcedure [dbo].[get_role_group]    Script Date: 2021/3/10 星期三 下午 11:26:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[get_role_group]
	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 
	SELECT  
		 r.[id]	
		 --  ,r.[parent_id] 
		,r.[name]
		,r.[category_id]
		,rc.[name] AS category_name
		
	
		,r.[desc]
		,r.[priority_id]
		,r.[order_id]
 
	  ,rn.[name] AS shape
	  ,rn.[desc] AS node_style
 
	  ,re.[desc] AS edge_style
     --,r.[insert_time]
     -- ,r.[update_time]
	  FROM [Beautiful].[dbo].[role] AS r
	  LEFT JOIN [Beautiful].[dbo].[role_category] rc
	  
	  ON r.category_id = rc.id
	  
	  --不和shape关联 是 role id 和 node id
	  LEFT JOIN [Beautiful].[dbo].nodes rn
	  ON r.category_id = rn.id
	  
	  --注意FROM parent_id TO role id
	  LEFT JOIN [Beautiful].[dbo].edges re
	  ON r.category_id = re.id

	
	 GROUP BY 
	  rc.[name]  
		, r.[id]
		,r.[name]
      ,r.[desc]
      ,r.[category_id]
      ,r.[priority_id]

      ,r.order_id
	   ,rn.[name]
	   ,rn.[desc]
	  
	   ,re.[desc]
	  HAVING r.[priority_id] != -1
	  
 
END
GO
/****** Object:  StoredProcedure [dbo].[get_role_list]    Script Date: 2021/3/10 星期三 下午 11:26:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[get_role_list]
	 @id INT = 0
	 ,@name VARCHAR(MAX) = NULL
	 ,@priority INT = NULL 
	 ,@order NVARCHAR(MAX) = 'insert_time DESC'
AS
BEGIN
 
	SET NOCOUNT ON;
	DECLARE @sql AS NVARCHAR(MAX)
	SET @sql = '
	  SELECT  
	   r.[id]
      ,r.[parent_id] 
      ,r.[name]
      ,r.[desc]
      ,r.[category_id]
	  ,rc.[name] AS category_name
      ,r.[priority_id]
      ,r.[insert_time]
      ,r.[update_time]
	    
		,n.[name] as shape
	   ,n.[desc] as node_style
	   
	   ,e.[name]  as edge_label
	   ,e.[desc] as edge_style
	  FROM [Beautiful].[dbo].[role] AS r
	  LEFT JOIN [Beautiful].[dbo].[role_category] rc
	  ON r.category_id = rc.id

	  --不和shape关联 是 role id 和 node id
	  LEFT JOIN [Beautiful].[dbo].[nodes] n
	  ON r.category_id = n.id
 
 
	  --注意FROM   TO   
	  LEFT JOIN [Beautiful].[dbo].[edges] e
	  ON r.category_id   = e.id

	  WHERE 1 = 1  '

	IF (@id = 0) 
	BEGIN
		IF (@name is NOT NULL)
			SET @sql = @sql + 'AND [name]  = ''' + @name + ''''
	END
	ELSE
	BEGIN 
			SET @sql = @sql + 'AND r.id=' + str(@id)
	END
	IF (@priority IS NOT NULL) 
		SET @sql = @sql +  'AND   priority = ' +@priority + ' '
	
	SET @sql = @sql + ' ORDER BY  ' + @order
	PRINT @sql
	EXECUTE (@sql)
	--EXECUTE	sp_executesql @sql,N'@name nvarchar(MAX)', @name
END
GO
/****** Object:  StoredProcedure [dbo].[mt_generate_info]    Script Date: 2021/3/10 星期三 下午 11:26:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		鼠
-- Create date: 2020-5-15 12：43
-- Description:	 
-- =============================================
CREATE  PROCEDURE  [dbo].[mt_generate_info]
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	 
	SELECT
	--so.[name]
	--,  t.COLUMN_NAME
	*
	FROM sysobjects so
	LEFT JOIN  
	(SELECT TABLE_NAME,COLUMN_NAME,DATA_TYPE FROM INFORMATION_SCHEMA.columns) AS t
	ON so.[name] = t.[TABLE_NAME]
	WHERE 
	so.xtype='u' or xtype='p'
	--AND t.TABLE_NAME='trace'
END
GO
