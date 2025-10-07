

IF OBJECT_ID('tempdb..#ddmast') IS NOT NULL DROP TABLE table
IF OBJECT_ID('tempdb..#lnmast') IS NOT NULL DROP TABLE table
IF OBJECT_ID('tempdb..#tableh') IS NOT NULL DROP TABLE table 

Select distinct /*(use this to get better defined results, examples above and below are merging many tables to 1)*/
CIFNO
,JhaPostingDate

into #ddmast
From Archive.[silverlake.jha].DDMAST
where STATUS in (1,4) 
and JhaPostingDate = 


Select distinct 
b.C
,b.J

into #ln
from archive.[silverlake.jha].L b
where b.S in (1,4) 
and b.J = 


Select distinct
c.CIFNO
,c.JhaPostingDate

into #tableh
from [databaseinQ].St in (1,4) 
and c.J= 

/*Union*/ 

select distinct a.* 

from 

(	select* From #d
	union all
	select* From #l
	union all 
	select* From #t
	) a 

