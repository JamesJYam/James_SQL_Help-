

/*This query pulls origination and renewal volume by product and tier for loans.*/


Use Finance


declare @start date = '5-1-2025'
       ,@end date = '5-30-2025'
	   ,@jhdate date = '5-30-2025'
       ,@prodline int = 2				--<-- 2 = Commercial Loans, 4 = QuickStep Loans, 5 = Consumer Loans




IF OBJECT_ID('tempdb..#OrigLoans') IS NOT NULL DROP TABLE #OrigLoans
IF OBJECT_ID('tempdb..#BranchNumbers') IS NOT NULL DROP TABLE #BranchNumbers
IF OBJECT_ID('tempdb..#Tiers1') IS NOT NULL DROP TABLE #Tiers1
IF OBJECT_ID('tempdb..#AssignBR') IS NOT NULL DROP TABLE #AssignBR
IF OBJECT_ID('tempdb..#Rounds') IS NOT NULL DROP TABLE #Rounds
IF OBJECT_ID('tempdb..#Tiers2') IS NOT NULL DROP TABLE #Tiers2
IF OBJECT_ID('tempdb..#Tiers3') IS NOT NULL DROP TABLE #Tiers3
IF OBJECT_ID('tempdb..#Tiers4') IS NOT NULL DROP TABLE #Tiers4
IF OBJECT_ID('tempdb..#Tiers5') IS NOT NULL DROP TABLE #Tiers5
IF OBJECT_ID('tempdb..#Tiers6') IS NOT NULL DROP TABLE #Tiers6
IF OBJECT_ID('tempdb..#Tiers7') IS NOT NULL DROP TABLE #Tiers7
IF OBJECT_ID('tempdb..#Tiers8') IS NOT NULL DROP TABLE #Tiers8
IF OBJECT_ID('tempdb..#Tiers9') IS NOT NULL DROP TABLE #Tiers9
IF OBJECT_ID('tempdb..#Tiers10') IS NOT NULL DROP TABLE #Tiers10
IF OBJECT_ID('tempdb..#Tiers11') IS NOT NULL DROP TABLE #Tiers11
IF OBJECT_ID('tempdb..#Tiers12') IS NOT NULL DROP TABLE #Tiers12
IF OBJECT_ID('tempdb..#Report') IS NOT NULL DROP TABLE #Report
IF OBJECT_ID('tempdb..#origloans2') IS NOT NULL DROP TABLE #origloans2
IF OBJECT_ID('tempdb..#Sublines') IS NOT NULL DROP TABLE #Sublines 
IF OBJECT_ID('tempdb..#rounds2') IS NOT NULL DROP TABLE #rounds2


/*BEGIN BUSINESS BANKING SECTION*/


IF OBJECT_ID('tempdb..#Step1') IS NOT NULL DROP TABLE #Step1
IF OBJECT_ID('tempdb..#Step2') IS NOT NULL DROP TABLE #Step2
IF OBJECT_ID('tempdb..#BBOffList') IS NOT NULL DROP TABLE #BBOffList



SELECT [Line of Business]
            ,[Business Unit]
            ,Division
            ,[Branch Number]
            ,[Branch Name]
            ,Officer.OfficerName
            ,Officer.OfficerCd
            ,Officer.TerminationDate
            ,CASE WHEN Officer.TerminationDate IS NULL THEN 0 ELSE 1 END AS TerminatedFlag
	into #Step1
        FROM Finance.FPS.BranchBusinessSegment AS OrgDim
        JOIN BannerInternal.BI.vwOfficerDim AS Officer
          ON Officer.Branch = OrgDim.[Branch Number]
       WHERE Datadate = @jhdate
         AND OrgDim.[Business Unit] = 'Business Banking'


SELECT CFOFFLA.JhaBankId
         ,CFOFFLA.CFACC# AS Account_No
         ,CFOFFLA.CFATYP AS AccountType
         ,CFOFFLA.JhaRecordID
         ,CONCAT(CFOFFLA.JhaBankId, '^', CFOFFLA.CFACC#, '^', CFOFFLA.CFATYP) AS JhaKeyAccount
         ,BB.OfficerCd
         ,BB.OfficerName
         ,BB.TerminationDate
         ,BB.TerminatedFlag
         ,BB.[Branch Number]
         ,BB.[Branch Name]
         ,BB.Division
         ,BB.[Business Unit]
         ,BB.[Line of Business]
         ,ROW_NUMBER() OVER (PARTITION BY CONCAT(CFOFFLA.JhaBankId, '^', CFOFFLA.CFACC#, '^', CFOFFLA.CFATYP) ORDER BY BB.TerminatedFlag ASC, CFOFFLA.JhaRecordID DESC) AS JhaRecordIDOrder
 into #Step2
	 FROM Archive.[silverlake.jha].CFOFFLA AS CFOFFLA
     JOIN #Step1 BB
       ON CFOFFLA.CFOFFR = BB.OfficerCd -- filter to just accounts with a Business Banker as the Sales Officer
    WHERE CFOFFLA.JhaPostingDate = (SELECT CurrDay FROM Bannerinternal.BI.vwTimeParameters)
      AND CFOFFLA.CFOFFRLC = 'SALE' -- Sales Officer
      AND CFOFFLA.CFATYP = 'L' -- Loans Only


   SELECT *
   into #BBOffList
     FROM #Step2
    WHERE JhaRecordIDOrder = 1 -- primary business banker




select distinct a.DataCount,a.DataDate,a.Account,a.OrigAmount,a.CostDriver
into #OrigLoans
from 
       (select DataCount,DataDate,Account,OrigAmount,CostDriver from [STP].[CostDriver_1005]
	   where [Status] in (1,4)
       union all
       select DataCount,DataDate,Account,OrigAmount,CostDriver from [STP].[CostDriver_1010]
       where [Status] in (1,4)
	   union all
       select DataCount,DataDate,Account,OrigAmount,CostDriver from [STP].[CostDriver_1025]
       where [Status] in (1,4)
	   union all
       select DataCount,DataDate,Account,OrigAmount,CostDriver from [STP].[CostDriver_1050]
       where [Status] in (1,4)
	   union all
       select DataCount,DataDate,Account,OrigAmount,CostDriver from [STP].[CostDriver_1055]
	   where [Status] in (1,4)
	   union all
       select DataCount,DataDate,Account,OrigAmount,CostDriver from [STP].[CostDriver_1070]
	   where [Status] in (1,4)
	   union all
	   select DataCount,DataDate,Account,OrigAmount,CostDriver from [STP].[CostDriver_1105]
	   where [Status] in (1,4)
       union all
       select DataCount,DataDate,Account,OrigAmount,CostDriver from [STP].[CostDriver_1110]
       where [Status] in (1,4)
	   union all
       select DataCount,DataDate,Account,OrigAmount,CostDriver from [STP].[CostDriver_1125]
       where [Status] in (1,4)
	   union all
       select DataCount,DataDate,Account,OrigAmount,CostDriver from [STP].[CostDriver_1150]
       where [Status] in (1,4)
	   union all
       select DataCount,DataDate,Account,OrigAmount,CostDriver from [STP].[CostDriver_1155]
	   where [Status] in (1,4)
       ) a

--join #BBOffList b
--on a.Account = b.Account_No

where a.DataDate between @start and @end
	    


/*for QS loans originated by CBCs*/
select distinct sp 
into #BranchNumbers
from [Archive].[CFRBranchPL]
where datadate >= @start





Select k.* , b.USER1

into #origloans2

From #OrigLoans k 

Left Join Archive.[silverlake.jha].LNMAST b
on b.ACCTNO = k.Account
and k.DataDate = b.JhaPostingDate


/*to isolate QS loans originated via CBCs*/
/*comment out if not needed*/

--where b.BR# not in 
--	(select sp from #BranchNumbers)



/*Deleting sublines here, comment in and out as needed*/

select distinct 
	l.LNLACT as [Subline]
into #Sublines
from Archive.[silverlake.jha].LNLINE l
where l.JhaPostingDate = @jhdate
and LNLMLN <> '0'




delete from #OrigLoans
	where Account in (select * from #Sublines)








select distinct 
	o.*
	,ceiling(o.origamount / 50000) * 50000 as [Upper]
into #Rounds
from #origloans2 o



select distinct 
r.DataCount
,r.DataDate
,r.Account
,r.OrigAmount
,r.CostDriver
,r.USER1
,r.[upper] - 0.01 as [Upper] 

into #rounds2

from #Rounds r



select distinct 
	o.*
	,t.[Tier#]
into #Tiers1
from #rounds2 o
left join [STP].[ABC_LoanTiers]t 
on  
t.Upper = o.Upper



/*assign uppers*/

select distinct  
	t.DataCount
	,t.DataDate
	,t.Account
	,t.CostDriver
	,t.USER1
	,t.OrigAmount
	,case 
		when OrigAmount between 600001 and 750000 then 750000
		when OrigAmount between 750001 and 800000 then 800000
		when OrigAmount between 800001 and 900000 then 900000
		when OrigAmount between 900001 and 1000000 then 1000000
		else t.[Upper]
		end
		as [Upper]
	,t.[Tier#]
	,case	
		when t.[Tier#] is null and t.[upper] between 600000 and 750000 then 13
		when t.[Tier#] is null and t.[upper] between 750001 and 800000 then 14
		when t.[Tier#] is null and t.[upper] between 800001 and 900000 then 15
		when t.[Tier#] is null and t.[upper] between 900001 and 1000000 then 16
		else null
		end as [TTier #]
into #Tiers2
from #Tiers1 t
where [Tier#] is null


update #Tiers2 set [Tier#] = [TTier #] where [Tier#] is null
update #Tiers2 set [TTier #] = null

--select * from #Tiers2



select distinct 
	t.DataCount
	,t.DataDate
	,t.Account
	,t.CostDriver
	,t.USER1
	,t.OrigAmount
	,t.Upper
	,t.[Tier#]
	,ceiling((t.Upper-1000000) / 250000) * 250000 +1000000 as [NewUpper]
into #Tiers3
from #Tiers2 t
where [Tier#] is null
and Upper between 1000000 and 2000000

update #Tiers3 set Upper = NewUpper where [Tier#] is null

--select * from #Tiers3



select distinct 
	t.DataCount
	,t.DataDate
	,t.Account
	,t.CostDriver
	,t.USER1
	,t.OrigAmount
	,t.Upper
	,t.[Tier#]
	,ceiling((t.Upper-2000000) / 500000) * 500000 +2000000 as [NewUpper]
into #Tiers4
from #Tiers2 t
where [Tier#] is null
and Upper between 2000000 and 6000000

update #Tiers4 set Upper = NewUpper where [Tier#] is null

--select * from #Tiers4




select distinct 
	t.DataCount
	,t.DataDate
	,t.Account
	,t.CostDriver
	,t.USER1
	,t.OrigAmount
	,t.Upper
	,t.[Tier#]
	,ceiling((t.Upper-6000000) / 1000000) * 1000000 +6000000 as [NewUpper]
into #Tiers5
from #Tiers2 t
where [Tier#] is null
and Upper between 6000000 and 15000000

update #Tiers5 set Upper = NewUpper where [Tier#] is null

--select * from #Tiers5



select distinct 
	t.DataCount
	,t.DataDate
	,t.Account
	,t.CostDriver
	,t.USER1
	,t.OrigAmount
	,t.Upper
	,t.[Tier#]
	,ceiling((t.Upper-15000000) / 2500000) * 2500000 +15000000 as [NewUpper]
into #Tiers6
from #Tiers2 t
where [Tier#] is null
and Upper between 15000000 and 25000000

update #Tiers6 set Upper = NewUpper where [Tier#] is null

--select * from #Tiers6



select distinct 
	t.DataCount
	,t.DataDate
	,t.Account
	,t.CostDriver
	,t.USER1
	,t.OrigAmount
	,t.Upper
	,t.[Tier#]
	,1000000000 as [NewUpper]
into #Tiers7
from #Tiers2 t
where [Tier#] is null
and Upper > 25000000

update #Tiers7 set Upper = NewUpper where [Tier#] is null

--select * from #Tiers7

delete from #Tiers1 where [Tier#] is null
delete from #Tiers2 where [Tier#] is null


select distinct t.* 
into #Tiers8
from
(
	select distinct 
		t.DataCount
		,t.DataDate
		,t.Account
		,t.CostDriver
		,t.USER1
		,t.OrigAmount
		,t.Upper
	from #Tiers1 t

	union all 

	select distinct 
		t.DataCount
		,t.DataDate
		,t.Account
		,t.CostDriver
		,t.USER1
		,t.OrigAmount
		,t.Upper
	from #Tiers2 t

	union all 

	select distinct 
		t.DataCount
		,t.DataDate
		,t.Account
		,t.CostDriver
		,t.USER1
		,t.OrigAmount
		,t.Upper
	from #Tiers3 t

	union all

	select distinct 
		t.DataCount
		,t.DataDate
		,t.Account
		,t.CostDriver
		,t.USER1
		,t.OrigAmount
		,t.Upper
	from #Tiers4 t

	union all

	select distinct 
		t.DataCount
		,t.DataDate
		,t.Account
		,t.CostDriver
		,t.USER1
		,t.OrigAmount
		,t.Upper
	from #Tiers5 t

	union all

	select distinct 
		t.DataCount
		,t.DataDate
		,t.Account
		,t.CostDriver
		,t.USER1
		,t.OrigAmount
		,t.Upper
	from #Tiers6 t

	union all

	select distinct 
		t.DataCount
		,t.DataDate
		,t.Account
		,t.CostDriver
		,t.USER1
		,t.OrigAmount
		,t.Upper
	from #Tiers7 t
	) t


--select * from #Tiers8


/*assign tiers to all uppers*/
select distinct 
	o.*
	,t.[Tier#]
into #Tiers9
from #Tiers8 o
left join [STP].[ABC_LoanTiers] t 
on  
t.Upper = o.Upper

--select * from #Tiers9
--where [Tier #] is null




/*assign tier desc to all tiers*/
select distinct 
	t.*
	,tt.[TierDesc]
into #Tiers10
from #Tiers9 t
left join [STP].[ABC_LoanTiers]tt
on t.[Tier#] = tt.[Tier#]

--select * from #Tiers10


/*assign branch*/

select distinct t.* 
	,l.BR# as [BR]
into #AssignBR
from #Tiers10 t
join Archive.[silverlake.jha].LNMAST l
on t.Account = l.ACCTNO
and l.JhaPostingDate = @jhdate





/*retrieve TYPE and GLPROD*/

select 
	a.*
	,l.GLPROD
	,l.[TYPE]
into #Tiers11
from #AssignBR a
left join Archive.[silverlake.jha].LNMAST l
on a.Account = l.ACCTNO
and l.JhaPostingDate = @jhdate

--select * from #Tiers11



/*assign product*/

select 
	t.*
	,h.[Product Line Desc]
	,h.[Product Group Desc]
	,h.SCCODE
	,h.[Product Desc]
	,h.Product
	,h.[Product Group]
	,h.[Product Line]
into #Tiers12
from #Tiers11 t
left join [STP].[FullProdHierarchyNewv2] h
on t.[TYPE] = h.SCCODE
and cast(t.glprod as varchar)=h.Line

where h.ACTYPE = 'l'
and h.[Product Line] = @prodline



/*assign service desc*/

select distinct 
	t.*
	,case
		when t.CostDriver between 1000 and 1099 then CONCAT('Originate a New Loan ',t.[TierDesc])
		when t.CostDriver between 1100 and 1199 then CONCAT('Renew a Loan ',t.[TierDesc])
		else 'Non-Amortizing' end as [Service Desc]
into #Report
from #Tiers12 t






/*final display*/
select distinct
	year(r.datadate) as [Year]
	--,r.BR as [Branch]
	,case
		when r.BR = 741 then '1'
		else '0' end as [AffordHousing]
	--,r.[Tier #]
	--,r.[Tier Desc]
	,r.[Product Line Desc]
	,r.[Product Desc]
	--,r.[Service Desc]
	--,r.SCCODE
	,concat(r.[Product Group],'-',r.[Product Line],'-',r.Product) as [Product#]
	--,r.Product
	--,r.[Product Group]
	--,r.[Product Line]
	,r.[CostDriver]
	,case 
		when r.CostDriver = 1005 then '1'
		when r.CostDriver = 1010 then '11'
		when r.CostDriver = 1025 then '17'
		when r.CostDriver = 1050 then '22'
		when r.CostDriver = 1055 then '27'
		when r.CostDriver = 1070 then '1'
		when r.CostDriver = 1105 then '1'
		when r.CostDriver = 1110 then '11'
		when r.CostDriver = 1125 then '17'
		when r.CostDriver = 1150 then '22'
		when r.CostDriver = 1155 then '27'
		else '1' end as [LowerTier]
	,case	
		when r.CostDriver = 1005 then '10'
		when r.CostDriver = 1010 then '16'
		when r.CostDriver = 1025 then '21'
		when r.CostDriver = 1050 then '26'
		when r.CostDriver = 1055 then '42'
		when r.CostDriver = 1070 then '42'
		when r.CostDriver = 1105 then '10'
		when r.CostDriver = 1110 then '16'
		when r.CostDriver = 1125 then '21'
		when r.CostDriver = 1150 then '26'
		when r.CostDriver = 1155 then '42'
		else '42' end as [UpperTier]
	,case
		when r.[Product Desc] like '%- ag' then '1'
		else '0' end as [AgFlag]
	,case 
		when r.USER1 = 'ab' then '1'
		else '0' end as [MonitoredFlag]
	,sum(r.datacount) over (partition by year(r.datadate)
										,r.BR 
										--,r.[Tier #]
										--,r.[Tier Desc]
										,r.[Product Line Desc]
										,r.[Product Desc]
										--,r.[Service Desc]
										--,r.SCCODE
										,r.user1
										,r.product
										,r.[Product Group]
										,r.[Product Line]
										,r.[CostDriver]
										) as [AnnVol]
from #Report r
 


