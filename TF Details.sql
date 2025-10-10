Use Finance
IF OBJECT_ID('tempdb..#DDMNAST ') IS NOT NULL DROP TABLE #DDMNAST 

SELECT distinct a.[CIF]
      ,a.[Security Acct#]
      ,a.[ACTYPE]
      ,a.[TF Inst#]
      ,a.[TF Prod#]
	  ,b.Driver#
      ,a.[DataDate]
      ,a.[ActiveFlag]
	  ,t.[Product Line]
	  ,t.[Product Line Desc]
	  ,t.[Product Desc]
	-- into #DDMNAST 
  FROM [Sandbox].[CostDriver_409_Instruments] a

  join finance.[Sandbox].[TF_ProductsDrivers] b on a.[TF Prod#] =b.TFProduct#

  join archive.[silverlake.jha].[DDMAST] c on c.CIFNO =a.CIF and c.ACTYPE = a.ACTYPE
  join [Finance].[STP].[FullProdHierarchyNewv2] t on t.SCCODE = c.SCCODE and a.ACTYPE =t.ACTYPE




SELECT distinct d.[CIF]
      ,d.[Security Acct#]
      ,d.[ACTYPE]
      ,d.[TF Inst#]
      ,d.[TF Prod#]
	  ,e.Driver#
      ,d.[DataDate]
      ,d.[ActiveFlag]
	  ,t.[Product Line]
	  ,t.[Product Line Desc]
	  ,t.[Product Desc]

	--into #Lnmast
  FROM [Sandbox].[CostDriver_409_Instruments] d

  join finance.[Sandbox].[TF_ProductsDrivers] e on d.[TF Prod#] =e.TFProduct#

  join archive.[silverlake.jha].[LNMAST] f on f.CIFNO =d.CIF and f.ACTYPE = d.ACTYPE
  join [Finance].[STP].[FullProdHierarchyNewv2] t on t.SCCODE = f.type and d.ACTYPE =t.ACTYPE




  