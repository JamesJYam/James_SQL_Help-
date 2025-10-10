Declare @startdate date = '5-01-2024'
	 ,@enddate date = '4-30-2025'


IF OBJECT_ID('tempdb..#DDMAST') IS NOT NULL DROP TABLE #DDMAST
IF OBJECT_ID('tempdb..#TMDDA') IS NOT NULL DROP TABLE #TMDDA
IF OBJECT_ID('tempdb..#TMinfo') IS NOT NULL DROP TABLE #TMinfo

SELECT distinct [CostDriver]
      ,[AnalysisDate]
      ,AccountNumber
	  ,Client
into #TMinfo

  FROM [Finance].[STP].[TMServiceItems]

 where [AnalysisDate] between @startdate and @enddate 


 Select
	   [ACCTNO]
      ,[ACTYPE]
	  ,[CIFNO]
	  ,[JhaPostingDate]
 into #DDMAST

 From [Archive].[silverlake.jha].[DDMAST] 
 
 where [JhaPostingDate] between @startdate and @enddate 

 Select distinct 
      t.AccountNumber
	  ,d.CIFNO
Into #TMDDA
From #TMinfo T

join #DDMAST D on D.ACCTNO = t.AccountNumber and t.AnalysisDate = d.JhaPostingDate

where [AnalysisDate] between @startdate and @enddate 

/*Final*/ 

Select distinct
[CostDriver]
,[Datadate]
,[ACCTNO]
,td.CIFNO
,datacount


From finance.stp.CostDriver_8320 cd

join #TMDDA TD on td.CIFNO = cd.[CIFNO] 

where DataDate between @startdate and @enddate