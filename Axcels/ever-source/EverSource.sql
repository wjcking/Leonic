USE [EverSource]
GO
/****** Object:  StoredProcedure [dbo].[sp_interweave_elements]    Script Date: 2021/3/10 星期三 下午 11:27:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		狒 暗能 日
-- Create date: 2020年4月2日
-- Description:	物理和化学元素交织
-- =============================================
CREATE PROCEDURE  [dbo].[sp_interweave_elements]
	@order int = 0
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	DECLARE @sql AS NVARCHAR(MAX)

	SET NOCOUNT ON;
	SET @sql = '
	SELECT
		ROW_NUMBER() OVER(ORDER BY D.id) AS id
		,D.id	AS dimension_id
		,I.id	AS interweaved_id
		,P.id	AS physical_id
		,D.name AS dimension_name
		,I.name AS interweaved_name
		,P.name AS physical_name
		,I.classify AS classify
		,CE.name AS chemical_name
		,CE.abbr
		,CE.[name]
		,CE.[desc]
		,CE.attribute
	FROM 
		[EverSource].[dbo].[dimension] AS D	
		CROSS JOIN [EverSource].[dbo].[interweave] AS I
		CROSS JOIN [EverSource].[dbo].[physical] AS P
		CROSS JOIN [EverSource].[dbo].[chemical_elements] AS CE
		--ON I.[order] = CE.magnetic_order
	GROUP BY
		 D.id
		,I.id
		,P.id
		,D.name
		,I.name 
		,I.classify
		,P.name
		,CE.abbr
		,CE.name
		,CE.[desc]
		,CE.attribute
	--  HAVING   AND 0 = 0
		--   D.id = 1 
	 --	AND I.id= 1
		--AND I.classify = 1
		--AND P.id=1 
	'
	IF @order <> 0  
	BEGIN
	SET @sql = @sql + 'HAVING I.[order] = ' + CONVERT(VARCHAR(20),@order) + ''
	END
	print(@sql)
	EXECUTE(@sql)
	
END
GO
