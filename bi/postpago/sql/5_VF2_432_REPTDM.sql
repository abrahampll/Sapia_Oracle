WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

DROP TABLE DM.DW_SPSS2_SVA PURGE;



CREATE TABLE DM.DW_SPSS2_SVA nologging parallel 10 AS 
Select /* parallel(2)*/ TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'YYYYMM') AS  PERIODO, b.td_msisdn MSISDN,  
count(distinct(td_service_id)) as VAR_209,
SUM(CASE WHEN b.td_total_amt IS NOT NULL THEN b.td_total_amt ELSE 0 END)  VF2_432,
(CASE WHEN SUM(CASE WHEN b.td_charge_code_id in ('10031','5270','5271','5269') THEN 1 ELSE 0 END)>0 THEN 'SI' ELSE 'NO' END) VAR_240,  
(CASE WHEN SUM(CASE WHEN b.td_charge_code_id in ('3227','3228','3234','3236','3238','3239','10057','5252','5253') THEN 1 ELSE 0 END)>0 THEN 'SI' ELSE 'NO' END) VAR_241   
FROM DM.TP_transaction_details_ext PARTITION (P_20170101) b
where exists (select 1 from DM.DW_MAESTRA_POSTPAGO a where a.msisdn=b.td_msisdn)
GROUP BY b.td_msisdn;

GRANT ALL ON DM.DW_SPSS2_SVA TO DBLINK_DWO;

EXIT;