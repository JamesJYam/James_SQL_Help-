Use Finance

declare @date date = '4-30-2025'

IF OBJECT_ID('tempdb..#TMList') IS NOT NULL DROP TABLE #TMList 
IF OBJECT_ID('tempdb..#Temp2') IS NOT NULL DROP TABLE #Temp2 

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



Select distinct
L.CIFNO
,d.acctno
,@date as datadate
,d.actype 
,d.sccode
,cast(d.Glprod as nvarchar) as [line]

Into #Temp2

From #TMList L
join Archive.[silverlake.jha].DDMAST d
on L.CIFNO = d.CIFNO 
and d.JhaPostingDate = @date
and d.status = 1



/*Join with Cost Driver Table*/ 

Select distinct
c.CostDriver
,c.ACCTNO
,t.CIFNO
,c.DataCount
,c.datadate
,h.[Product Desc]


From [STP].[CostDriver_6010] c
join #Temp2 t on t.ACCTNO = c.ACCTNO and t.DataDate = c.DataDate


left join stp.fullprodhierarchynewv2 h on h.actype = t.actype and h.sccode = t.sccode and h.line = t.line 