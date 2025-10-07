SELECT  distinct 
	t.CIFClass
	,sum (d.datacount) over ( partition by t.cifclass) as [Volume] 
  FROM [Finance].[STP].[CostDriver_6560] d

  join archive.[silverlake.jha].CFMAST c
  on d.CIFNO = c.CFCIF# and d.DataDate = c.JhaPostingDate

  join stp.CIFTypes t 
  on t.CFSSCD = c.CFSSCD
  
  where DataDate = '6-28-2024'


