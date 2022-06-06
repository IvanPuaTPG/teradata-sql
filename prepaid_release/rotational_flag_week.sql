-- Runs every month to get rotational_flag

CREATE VOLATILE TABLE prepaid_rotational_flag_week AS(
SEL
        NEXT_DAY(prd_dt, 'SUNDAY') prd_week -- reporting for previous week 
        ,subs_id
        ,CURR_dvc_imei_id
        ,CASE WHEN Sum(CASE WHEN prev_Sub IS NOT NULL THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS Rotational_flag
        ,Max(trav_flag) trav_flag
        ,Count(prev_Sub) AS Count_prev_subs_yr
        FROM (
            SELECT
            DISTINCT
            conn.prd_dt
            ,conn.subs_id
            ,DS.CURR_dvc_imei_id
            ,DS_before.Subs_Id AS prev_Sub
            ,CASE WHEN ah.Dlr_Cd IN
            (
            'GSM206','A406','GSM207','A407','GSM208','A408','GSM201','C403','GSM204','F417','D456'
            ,'AUS088','AWP003','AWP009','AWP010','AWP013','AWP022','AWP027','AWP038','AWP052'
            ,'AWP053','AWP054','AWP055','AWP056','AWP058','AWP063','BES010','BES012','BRI030','BRI031','NEW194'
            ,'NLK004','NLK005','NLK006','NLK022','NLK023','NLK027','NLK034','NLK035','NLK036','NLK037','NLK039'
            ,'NLK040','NLK042','NLK043','NLK050','NLK052','NLK053','NLK061','NLK062','NLK067'
            ,'NLK068','NLK070','NLK072','NLK074','NLK079','NLK080','NLK081','NLK087','NLK088','NLK091','NLK092','NLK094'
            ,'NLK095','NLK097','NLK098','NLK106','NLK107','NLK109','NLK110','NLK119','SIM025','SIM027','SIM028'
            ,'WHS005','WHS006','WHS011','WHS012','WHS013','WHS017','WHS021','WHS024'
            ,'WHS025','WHS047','WHS050','WHS051','WHS052','WHS053'
            ) THEN 1 ELSE 0 END AS trav_flag

            FROM
            	(SELECT prd_dt, subs_id FROM cust_knowledge_db.ow_prepaid_agg_daily WHERE prd_dt BETWEEN '2022-05-29' AND '2022-06-04' GROUP BY 1,2) conn -- change time range for week in concern (Sun - Sat)
            INNER JOIN AUPR_BUS_VIEW.DIM_SUBS AS DS
            ON conn.SUBS_ID = DS.SUBS_ID
            AND conn.PRD_DT BETWEEN DS.DIM_START_DT AND DS.DIM_END_DT
            AND DS.Acct_Type_Cd = 'Prepay'
            AND DS.Cust_Type_Cd = 'Consumer'
            AND DS.stat_cd='active'

            LEFT JOIN AUPR_BUS_VIEW.DIM_SUBS AS DS_before
            ON DS.CURR_dvc_imei_id = DS_BEFORE.curr_dvc_imei_id
            AND DS.CURR_dvc_imei_id > 0
            AND ds.subs_id<>ds_before.subs_id
            AND ds_before.curr_dvc_imei_id<>'-2'
            AND ds_before.acct_type_cd='prepay'
            AND DS_BEFORE.Cust_Type_Cd = 'Consumer'
            AND ds_before.stat_cd='active'
            AND conn.prd_dt -365 < DS_before.DIM_START_DT -- prepaid was inactive a year before 
            AND DS_before.DIM_START_DT < DS.DIM_START_DT

            LEFT JOIN Aupr_Bus_View.Cmpst_prepay_Active_hist ah
            ON conn.subs_id = ah.subs_id
            AND NEXT_DAY(conn.prd_dt, 'SUNDAY') = ah.prd_dt -- reporting for previous week 
            AND ah.Prd_Type_Cd = 'week'
            AND Coalesce(ah.PLAN_TYPE_CD,'Handset')  ='Handset'
            AND ah.ACCT_TYPE_CD ='Prepay'

            WHERE 1=1 -- where TRUE
        ) AS a
        WHERE
        subs_id IN (SELECT subs_id FROM Aupr_Bus_View.Cmpst_prepay_Active_hist
                        WHERE
                        prd_dt >=Current_Date - 7 -- FP
                        )
        QUALIFY Row_Number() Over(PARTITION BY subs_id, prd_week ORDER BY Rotational_flag DESC) = 1
        GROUP BY 1,2,3
)

WITH DATA
PRIMARY INDEX(subs_id)
ON COMMIT PRESERVE ROWS ;

-- testing
select top 10 * 
from prepaid_rotational_flag_week

select distinct prd_week
from prepaid_rotational_flag_week

select count(*)
from prepaid_rotational_flag_week

-- option 1: join to create temp table
select count(1)
from (
	select 
		base.*, rot.rotational_flag
	from Aupr_Bus_View.Cmpst_prepay_Active_hist AS base
	inner join prepaid_rotational_flag_week AS rot
	on base.subs_id = rot.subs_id
	and base.prd_dt = rot.prd_week
	and base.prd_type_cd = 'week'
) a









