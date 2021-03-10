USE [LiveBeings]
GO
/****** Object:  StoredProcedure [dbo].[sp_revive]    Script Date: 2021/3/10 星期三 下午 11:28:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_revive]
	 
AS
BEGIN

	SET NOCOUNT ON;
	SELECT
	--	nt.name nerve_name
		-- c.name   cell_name
		  bs.id   brain_system_id
		 ,bs.name brain_system_name
		 ,bf.name brain_function_name
		--,lc.source_id   cell_id
	--	,lc.name 
		
	FROM 
	--[EverSource].[dbo].[cells] AS c
    --RIGHT JOIN [LiveBeings].[dbo].[cells] AS lc
 	 -- ON  c.id = c.id --lc.source_id	
	--   [LiveBeings].[dbo].[nerve_tissue] AS nt
--	  ON lc.id =  nt.id --AND nt.id = 1
	   [LiveBeings].[dbo].[brain_system] AS bs
	 
	 LEFT JOIN [LiveBeings].[dbo].[brain_function] AS bf
	 ON bs.id =  bf.system_id

END
GO
