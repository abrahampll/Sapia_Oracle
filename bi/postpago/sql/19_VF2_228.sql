WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

BEGIN
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_SPSS2_TAG_1460_VF2_228_375');
END;
/

CREATE TABLE dm.dw_SPSS2_TAG_1460_VF2_228_375 AS
SELECT /*PARALLEL(40)*/'51'||sa.msisdn as msisdn,sa.period,
ROUND(SUM((CASE WHEN  SA.CALLDESTINATION = 'CLA' AND  SA.CALLTOTAL = 0 
THEN (CASE WHEN instr(SA.CALLDURATION,':',1,1) > 0 THEN (to_number(substr(SA.CALLDURATION,1 ,(instr(SA.CALLDURATION,':',1,1)-1))) * 60) +  to_number(substr(SA.CALLDURATION,(instr(SA.CALLDURATION,':',1,1)+ 1),length(SA.CALLDURATION)))
WHEN instr(SA.CALLDURATION,'.',1,1) > 0 THEN (to_number(substr(SA.CALLDURATION,1 ,(instr(SA.CALLDURATION,'.',1,1)-1))) * 60) +  to_number(substr(SA.CALLDURATION,(instr(SA.CALLDURATION,'.',1,1)+ 1),length(SA.CALLDURATION)))
ELSE to_number(sa.callduration) END)ELSE 0 END)) / 60, 2) VF2_228 ,
COUNT(CASE WHEN (CASE WHEN  SA.CALLDESTINATION = 'VIE' and SA.TARIFFZONE NOT LIKE 'FIJ%' and SA.CALLTOTAL > 0 THEN 1 ELSE 0 END)>0 THEN (SA.CALLNUMBER) END)VF2_308,
COUNT(CASE WHEN (CASE WHEN  SA.CALLDESTINATION = 'NEX' AND SA.TARIFFZONE NOT LIKE 'FIJ%' AND SA.CALLTOTAL = 0 THEN 1 ELSE 0 END)>0  THEN (CALLNUMBER) END)VF2_309,
COUNT(CASE WHEN (CASE WHEN  SA.CALLDESTINATION = 'TM'  AND SA.TARIFFZONE NOT LIKE 'FIJ%' AND SA.CALLTOTAL = 0 THEN 1 ELSE 0 END)>0  THEN (CALLNUMBER) END)VF2_310,
COUNT(CASE WHEN (CASE WHEN  SA.CALLDESTINATION = 'VIR' AND SA.TARIFFZONE NOT LIKE 'FIJ%' AND SA.CALLTOTAL = 0 THEN 1 ELSE 0 END)>0  THEN (SA.CALLNUMBER) END)VF2_312,
COUNT(CASE WHEN (CASE WHEN  SA.CALLDESTINATION = 'TDP' AND SA.TARIFFZONE LIKE 'FIJ%' AND SA.CALLTOTAL = 0  THEN 1 ELSE 0 END)>0 THEN (CALLNUMBER) END)VF2_313,                  
ROUND(SUM((CASE WHEN  SA.CALLDESTINATION = 'VIE' AND SA.TARIFFZONE NOT LIKE 'FIJ%' AND SA.CALLTOTAL = 0 
THEN (CASE WHEN instr(SA.CALLDURATION,':',1,1) > 0 THEN (to_number(substr(SA.CALLDURATION,1 ,(instr(SA.CALLDURATION,':',1,1)-1))) * 60) +  to_number(substr(SA.CALLDURATION,(instr(SA.CALLDURATION,':',1,1)+ 1),length(SA.CALLDURATION)))
WHEN instr(SA.CALLDURATION,'.',1,1) > 0 THEN (to_number(substr(SA.CALLDURATION,1 ,(instr(SA.CALLDURATION,'.',1,1)-1))) * 60) +  to_number(substr(SA.CALLDURATION,(instr(SA.CALLDURATION,'.',1,1)+ 1),length(SA.CALLDURATION)))
ELSE to_number(sa.callduration) END)ELSE 0 END)) / 60, 2) VF2_333,
ROUND(SUM((CASE WHEN  SA.CALLDESTINATION = 'NEX' AND SA.TARIFFZONE NOT LIKE 'FIJ%' AND SA.CALLTOTAL = 0
THEN (CASE WHEN instr(SA.CALLDURATION,':',1,1) > 0 THEN (to_number(substr(SA.CALLDURATION,1 ,(instr(SA.CALLDURATION,':',1,1)-1))) * 60) +  to_number(substr(SA.CALLDURATION,(instr(SA.CALLDURATION,':',1,1)+ 1),length(SA.CALLDURATION)))
WHEN instr(SA.CALLDURATION,'.',1,1) > 0 THEN (to_number(substr(SA.CALLDURATION,1 ,(instr(SA.CALLDURATION,'.',1,1)-1))) * 60) +  to_number(substr(SA.CALLDURATION,(instr(SA.CALLDURATION,'.',1,1)+ 1),length(SA.CALLDURATION)))
ELSE to_number(sa.callduration) END)ELSE 0 END)) / 60, 2) VF2_334,
ROUND(SUM((CASE WHEN  SA.CALLDESTINATION = 'TM'  AND SA.TARIFFZONE NOT LIKE 'FIJ%' AND SA.CALLTOTAL = 0 
THEN (CASE WHEN instr(SA.CALLDURATION,':',1,1) > 0 THEN (to_number(substr(SA.CALLDURATION,1 ,(instr(SA.CALLDURATION,':',1,1)-1))) * 60) +  to_number(substr(SA.CALLDURATION,(instr(SA.CALLDURATION,':',1,1)+ 1),length(SA.CALLDURATION)))
WHEN instr(SA.CALLDURATION,'.',1,1) > 0 THEN (to_number(substr(SA.CALLDURATION,1 ,(instr(SA.CALLDURATION,'.',1,1)-1))) * 60) +  to_number(substr(SA.CALLDURATION,(instr(SA.CALLDURATION,'.',1,1)+ 1),length(SA.CALLDURATION)))
ELSE to_number(sa.callduration) END)ELSE 0 END)) / 60, 2) VF2_335,   
ROUND(SUM((CASE WHEN  SA.CALLDESTINATION = 'VIR' AND SA.TARIFFZONE NOT LIKE 'FIJ%' AND SA.CALLTOTAL = 0 
THEN (CASE WHEN instr(SA.CALLDURATION,':',1,1) > 0 THEN (to_number(substr(SA.CALLDURATION,1 ,(instr(SA.CALLDURATION,':',1,1)-1))) * 60) +  to_number(substr(SA.CALLDURATION,(instr(SA.CALLDURATION,':',1,1)+ 1),length(SA.CALLDURATION)))
WHEN instr(SA.CALLDURATION,'.',1,1) > 0 THEN (to_number(substr(SA.CALLDURATION,1 ,(instr(SA.CALLDURATION,'.',1,1)-1))) * 60) +  to_number(substr(SA.CALLDURATION,(instr(SA.CALLDURATION,'.',1,1)+ 1),length(SA.CALLDURATION)))
ELSE to_number(sa.callduration) END)ELSE 0 END)) / 60, 2) VF2_337,
ROUND(SUM((CASE WHEN  SA.CALLDESTINATION = 'TDP' AND SA.TARIFFZONE LIKE 'FIJ%' AND SA.CALLTOTAL = 0
THEN (CASE WHEN instr(SA.CALLDURATION,':',1,1) > 0 THEN (to_number(substr(SA.CALLDURATION,1 ,(instr(SA.CALLDURATION,':',1,1)-1))) * 60) +  to_number(substr(SA.CALLDURATION,(instr(SA.CALLDURATION,':',1,1)+ 1),length(SA.CALLDURATION)))
WHEN instr(SA.CALLDURATION,'.',1,1) > 0 THEN (to_number(substr(SA.CALLDURATION,1 ,(instr(SA.CALLDURATION,'.',1,1)-1))) * 60) +  to_number(substr(SA.CALLDURATION,(instr(SA.CALLDURATION,'.',1,1)+ 1),length(SA.CALLDURATION)))
ELSE to_number(sa.callduration) END)ELSE 0 END)) / 60, 2) VF2_338,
COUNT(CASE WHEN (CASE WHEN SA.CALLDESTINATION = 'CLA' and SA.TARIFFZONE NOT LIKE 'FIJ%' and SA.CALLTOTAL = 0 THEN 1 ELSE 0 END)>0 THEN  (SA.CALLNUMBER) END)VF2_357,
COUNT(CASE WHEN (CASE WHEN SA.CALLDESTINATION = 'CLA' AND SA.TARIFFZONE LIKE 'FIJ%' AND SA.CALLTOTAL = 0 THEN 1 ELSE 0 END)>0 THEN (CALLNUMBER) END)VF2_358,
ROUND(SUM((CASE WHEN  SA.CALLDESTINATION = 'CLA' AND SA.TARIFFZONE NOT LIKE 'FIJ%' AND SA.CALLTOTAL = 0
THEN (CASE WHEN instr(SA.CALLDURATION,':',1,1) > 0 THEN (to_number(substr(SA.CALLDURATION,1 ,(instr(SA.CALLDURATION,':',1,1)-1))) * 60) +  to_number(substr(SA.CALLDURATION,(instr(SA.CALLDURATION,':',1,1)+ 1),length(SA.CALLDURATION)))
WHEN instr(SA.CALLDURATION,'.',1,1) > 0 THEN (to_number(substr(SA.CALLDURATION,1 ,(instr(SA.CALLDURATION,'.',1,1)-1))) * 60) +  to_number(substr(SA.CALLDURATION,(instr(SA.CALLDURATION,'.',1,1)+ 1),length(SA.CALLDURATION)))
ELSE to_number(sa.callduration) END)ELSE 0 END)) / 60, 2) VF2_363,
ROUND(SUM((CASE WHEN  SA.CALLDESTINATION = 'CLA' AND SA.TARIFFZONE LIKE 'FIJ%' AND SA.CALLTOTAL= 0 
THEN (CASE WHEN instr(SA.CALLDURATION,':',1,1) > 0 THEN (to_number(substr(SA.CALLDURATION,1 ,(instr(SA.CALLDURATION,':',1,1)-1))) * 60) +  to_number(substr(SA.CALLDURATION,(instr(SA.CALLDURATION,':',1,1)+ 1),length(SA.CALLDURATION)))
WHEN instr(SA.CALLDURATION,'.',1,1) > 0 THEN (to_number(substr(SA.CALLDURATION,1 ,(instr(SA.CALLDURATION,'.',1,1)-1))) * 60) +  to_number(substr(SA.CALLDURATION,(instr(SA.CALLDURATION,'.',1,1)+ 1),length(SA.CALLDURATION)))
ELSE to_number(sa.callduration) END)ELSE 0 END)) / 60, 2) VF2_364,
COUNT(CASE WHEN (CASE WHEN SA.CALLDESTINATION NOT IN 'CLA' AND CALLTOTAL = 0 THEN 1 ELSE 0 END)>0 THEN (SA.CALLNUMBER) END)VF2_307,
ROUND(SUM((CASE WHEN  CALLDESTINATION NOT IN 'CLA' AND SA.CALLTOTAL= 0
THEN (CASE WHEN instr(SA.CALLDURATION,':',1,1) > 0 THEN (to_number(substr(SA.CALLDURATION,1 ,(instr(SA.CALLDURATION,':',1,1)-1))) * 60) +  to_number(substr(SA.CALLDURATION,(instr(SA.CALLDURATION,':',1,1)+ 1),length(SA.CALLDURATION)))
WHEN instr(SA.CALLDURATION,'.',1,1) > 0 THEN (to_number(substr(SA.CALLDURATION,1 ,(instr(SA.CALLDURATION,'.',1,1)-1))) * 60) +  to_number(substr(SA.CALLDURATION,(instr(SA.CALLDURATION,'.',1,1)+ 1),length(SA.CALLDURATION)))
ELSE to_number(sa.callduration) END)ELSE 0 END)) / 60, 2) VF2_332, 
ROUND(SUM((CASE WHEN  TIPOLLAMADA = '30' AND CALLTOTAL=0
THEN (CASE WHEN instr(SA.CALLDURATION,':',1,1) > 0 THEN (to_number(substr(SA.CALLDURATION,1 ,(instr(SA.CALLDURATION,':',1,1)-1))) * 60) +  to_number(substr(SA.CALLDURATION,(instr(SA.CALLDURATION,':',1,1)+ 1),length(SA.CALLDURATION)))
WHEN instr(SA.CALLDURATION,'.',1,1) > 0 THEN (to_number(substr(SA.CALLDURATION,1 ,(instr(SA.CALLDURATION,'.',1,1)-1))) * 60) +  to_number(substr(SA.CALLDURATION,(instr(SA.CALLDURATION,'.',1,1)+ 1),length(SA.CALLDURATION)))
ELSE to_number(sa.callduration) END)ELSE 0 END)) / 60, 2) VF2_375
FROM DWS.SA_TEMP_TAG_1460 SA
where SA.PERIOD = '&1'
GROUP BY '51'||sa.msisdn,sa.period;


EXIT;
