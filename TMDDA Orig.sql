
Use Finance

IF OBJECT_ID('tempdb..#CardList') IS NOT NULL DROP TABLE #CardList 
IF OBJECT_ID('tempdb..#CardsWithCIFs') IS NOT NULL DROP TABLE #CardsWithCIFs
IF OBJECT_ID('tempdb..#TMList') IS NOT NULL DROP TABLE #TMList 




declare @date date = '4-30-2025'
	

/*build roster of active cards*/

select c.[Account Number]
		,c.[Product Code]
		,c.[Sub Product Code] 
		,f.[Product Desc]
		,f.[Core Product Group Desc]
		,c.[datadate]

into #CardList

from [BannerInternal].[CreditCard_Report].[Cards] c

left join [STP].[FullProdHierarchyNewv2] f
on f.Line = c.[Sub Product Code]
and f.SCCODE = c.[Product Code]

where [Card Status] = 'a'
and DataDate = @date



/*find CIFs for active cards*/

select distinct 
	c.DataDate
	,c.[Account Number]
	,c.[Product Desc]
	,c.[Core Product Group Desc]
	,d.[CIFNO]

into #CardsWithCIFs

from [STP].[CostDriver_8320] d
join #CardList c
on d.ACCTNO = c.[Account Number]
and d.DataDate = c.DataDate



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



/*match the TM CIFs to the Credit Card CIFs*/

select distinct
	t.DataDate
	,t.CIFNO
	,t.[Client Name]
	,CONCAT(left(c.[Account Number],4),'XXXX',right(c.[Account Number],4)) as [CC Account]
	,c.[Core Product Group Desc]
	,c.[Product Desc]


from #TMList t
join #CardsWithCIFs c
on t.CIFNO = c.CIFNO


