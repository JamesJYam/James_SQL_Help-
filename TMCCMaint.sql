

Declare @startdate date = '4-01-2025'
	 ,@enddate date = '4-30-2025'

IF OBJECT_ID('tempdb..#Creditcards') IS NOT NULL DROP TABLE #Creditcards
IF OBJECT_ID('tempdb..#Costdrivers') IS NOT NULL DROP TABLE #Costdrivers
IF OBJECT_ID('tempdb..#TMinfo') IS NOT NULL DROP TABLE #TMinfo
IF OBJECT_ID('tempdb..#DDMAST') IS NOT NULL DROP TABLE #DDMAST
IF OBJECT_ID('tempdb..#pfj') IS NOT NULL DROP TABLE #pfj

------ TM SVC Items 
SELECT distinct [CostDriver]
      ,[AnalysisDate]
      ,AccountNumber
	  ,Client
into #TMinfo

  FROM [Finance].[STP].[TMServiceItems]

 where [AnalysisDate] between @startdate and @enddate 


-------- DDMAST 
Select
	   [ACCTNO]
      ,[ACTYPE]
	  ,[CIFNO]
	  ,[JhaPostingDate]
 into #DDMAST

 From [Archive].[silverlake.jha].[DDMAST] 
 
 where [JhaPostingDate] between @startdate and @enddate 


----cards 

Select
[Account Number]
,[Product Code]
,[Sub Product Code] 
,[datadate]
Into #CreditCards

From [BannerInternal].[CreditCard_Report].[Cards] cc 

where DataDate between @startdate and @enddate 

------ Cost Driver 

Select
[CostDriver]
,[datacount]
,[Datadate]
,[ACCTNO]
Into #Costdrivers 

From finance.stp.CostDriver_8321 

where DataDate = @enddate



--/** Pre Final Join**/ 

select distinct
      t.[AnalysisDate]
      ,t.AccountNumber
	  ,d.CIFNO
	  ,t.Client
	Into #pfj
from #TMinfo T

join #DDMAST d on d.JhaPostingDate = t.AnalysisDate and t.AccountNumber = d.ACCTNO


--/**/ 
Select Distinct 
cd.DataDate
,cd.CostDriver
,m.CIFNO
--,m.AccountNumber as TM_ACCT_NO
,cd.ACCTNO


From #Costdrivers cd

join #CreditCards c on c.[Account Number] = cd.ACCTNO
and c.DataDate = cd.DataDate 

join #pfj m on m.AnalysisDate = cd.DataDate 






