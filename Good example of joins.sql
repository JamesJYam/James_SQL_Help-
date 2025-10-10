/****** Script for SelectTopNRows command from SSMS  ******/
SELECT a.[CostDriver]
      ,a.[AnalysisDate]
      ,a.[AA_ItemDescription]
      ,a.[AccountNumber]
	  ,a.cifno
	  ,a.Client
	  ,a.ActivityCount
	  ,f.Product
	  ,f.[Product Desc]
  FROM [Finance].[STP].[TMServiceItems]a

  join [Archive].[silverlake.jha].[DDMAST] b
  on b.ACCTNO = a.AccountNumber
  and b.JhaPostingDate = a.AnalysisDate

  join [Finance].[STP].[FullProdHierarchyNewv2] f
  on f.SCCODE = b.SCCODE
  and f.ACTYPE = b.ACTYPE
  and f.Line = cast(b.GLPROD as nvarchar)
 
 
 Where AnalysisDate = '2025-03-31'

  and CostDriver in (10027) 

  and b.STATUS <> 0 




 --join product heiarchy 
 --intermediate join is ddmast 
 --bring in CIF and client name

 --what accounts they are 

 --product desc 

 --do the same with 10001 

