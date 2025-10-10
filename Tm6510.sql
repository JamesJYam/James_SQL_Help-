Use Finance

declare @date date = '4-30-2025'

IF OBJECT_ID('tempdb..#TMList') IS NOT NULL DROP TABLE #TMList 


/*build list of TM clients*/

select distinct
	@date as [DataDate]
	,t.AccountNumber
	,d.CIFNO
	,d.SNAME as [Client Name]

into #TMList

from stp.TMServiceItems t
join Archive.[silverlake.jha].DDMAST d
on t.AccountNumber = d.ACCTNO
and d.JhaPostingDate = @date

where month(t.analysisdate) = month(@date)
and year(t.analysisdate) = year(@date)


/*Join with Cost Driver Table*/ 

Select distinct
c.CostDriver
,c.ACCTNO
,t.CIFNO
,c.DataCount
,c.datadate


From [STP].[CostDriver_6510] c
join #TMList t on t.AccountNumber = c.ACCTNO and t.DataDate = c.DataDate

where c.DataDate = @date