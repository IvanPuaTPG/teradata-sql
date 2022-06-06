 select tariff_simple_names,offer_name, discount_inc_gst, count(*)
 from cust_knowledge_db.ow_nba_staging
 where base_offer_name NOT LIKE '%XSELL%'
 AND hide_nba IS NULL
 group by 1, 2, 3
 order by 1, 2, 3
 
 
 
 Help table cust_knowledge_db.ow_nba_staging