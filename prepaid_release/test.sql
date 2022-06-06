

--testing 
select rotational_flag, count(*)
from prepaid_rotational_flag_week
where prd_week IS NOT NULL
group by 1

select top 5 *
from prepaid_rotational_flag_week
where subs_id = 367044155

drop prepaid_rotational_flag_week





-- daily (5th Jun)
select NEXT_DAY(prd_dt, 'SUNDAY') prd_week, 
prd_dt,
count(1)
from (
	select conn.prd_dt
	from
		(SELECT prd_dt, subs_id FROM cust_knowledge_db.ow_prepaid_agg_daily WHERE prd_dt BETWEEN '2022-05-29' AND '2022-06-04' GROUP BY 1,2) conn
    LEFT JOIN Aupr_Bus_View.Cmpst_prepay_Active_hist ah
    ON conn.subs_id = ah.subs_id
    AND NEXT_DAY(conn.prd_dt, 'SUNDAY') = ah.prd_dt
    AND ah.Prd_Type_Cd = 'week'
    AND Coalesce(ah.PLAN_TYPE_CD,'Handset')  ='Handset'
    AND ah.ACCT_TYPE_CD ='Prepay'
    

) a
group by 1,2

select top 5 
prd_dt,
prd_dt - Extract(DAY From prd_dt) as prd_dt_mod
from cust_knowledge_db.ow_prepaid_agg_daily
where prd_dt = '2022-05-28'


-- got weekly and monthly (most recent 5th June, 29th May)
select distinct prd_dt
from Aupr_Bus_View.Cmpst_prepay_Active_hist ah
where ah.Prd_Type_Cd <> 'month'
AND Coalesce(ah.PLAN_TYPE_CD,'Handset')  ='Handset'
AND ah.ACCT_TYPE_CD ='Prepay'
order by prd_dt DESC

select count(*)
from Aupr_Bus_View.Cmpst_prepay_Active_hist ah
where prd_dt = '2022-06-05'


SELECT NEXT_DAY(DATE '2022-06-05', 'SUNDAY'); 
