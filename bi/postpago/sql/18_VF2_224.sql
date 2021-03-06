WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

BEGIN
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_SPSS2_TRAFICO_PLAN_2');
END;
/
CREATE TABLE DM.DW_SPSS2_TRAFICO_PLAN_2 nologging AS
SELECT /*+ PARALLEL(30)*/ MSISDN ,period, 
SUM(CASE WHEN SMSTOTAL=0 and TARIFFZONE='DAT01' then (SMSDURATION/1024/1024) ELSE 0 END) as VF2_224,
SUM(CASE WHEN TARIFFZONE='DAT01' AND SMSTOTAL>0 THEN SMSTOTAL ELSE 0 END) VF2_247,
sum(CASE WHEN SMSDESTINATION = 'VIE' and TARIFFZONE NOT LIKE 'IDE%' and tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') and SMSTOTAL=0 THEN smsduration else 0 END) VF2_297,
sum(CASE WHEN SMSDESTINATION = 'NEX' and TARIFFZONE NOT LIKE 'IDE%' and tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') and SMSTOTAL=0 THEN smsduration else 0 END) VF2_298,
sum(CASE WHEN SMSDESTINATION = 'TM'  AND TARIFFZONE NOT LIKE 'IDE%' and tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') and SMSTOTAL=0 THEN smsduration else 0 END) VF2_299,
sum(CASE WHEN SMSDESTINATION = 'VIR' AND TARIFFZONE NOT LIKE 'IDE%' and tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') and SMSTOTAL=0 THEN smsduration else 0 END) VF2_300,
sum(CASE WHEN SMSDESTINATION = 'CLA' AND TARIFFZONE NOT LIKE 'IDE%' and tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') and SMSTOTAL=0 THEN smsduration else 0 END) VF2_305,
sum(CASE WHEN SMSDESTINATION NOT IN ('CLA', 'VIE', 'TM', 'NEX', 'VIR') AND SMSTOTAL = 0 AND TARIFFZONE NOT LIKE 'IDE%' and tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') THEN smsduration else 0 END) VF2_301,
sum(CASE WHEN SMSDESTINATION = 'VIE' AND SMSTOTAL>0 AND  TARIFFZONE NOT LIKE 'IDE%' and tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') THEN  smsduration  else 0 END)VF2_287,
sum(CASE WHEN SMSDESTINATION = 'NEX' AND TARIFFZONE NOT LIKE 'IDE%' and tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') AND SMSTOTAL>0 THEN smsduration  else 0 END) VF2_288,
sum(CASE WHEN SMSDESTINATION = 'TM'  AND TARIFFZONE NOT LIKE 'IDE%' and tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') AND SMSTOTAL>0 THEN smsduration  else 0 END) VF2_289,
sum(CASE WHEN SMSDESTINATION = 'VIR' AND TARIFFZONE NOT LIKE 'IDE%' and tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') AND SMSTOTAL>0 THEN smsduration  else 0 END) VF2_290,
sum(CASE WHEN SMSDESTINATION NOT IN ('CLA', 'VIE', 'TM', 'NEX', 'VIR') AND TARIFFZONE NOT LIKE 'IDE%' and tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') AND SMSTOTAL>0 THEN smsduration else 0 END) VF2_291,
sum(CASE WHEN SMSDESTINATION = 'CLA' AND TARIFFZONE NOT LIKE 'IDE%' and tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') AND SMSTOTAL>0 THEN smsduration else 0  END) VF2_303, 
(CASE WHEN SUM (CASE WHEN TARIFFZONE='DAT01' AND SMSTOTAL>0 THEN 1 ELSE 0 END) > 0 THEN 'SI' ELSE 'NO' END) VF2_231,
(CASE WHEN SUM (CASE WHEN SMSTOTAL>0 AND TARIFFZONE NOT LIKE 'IDE%' and tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') THEN 1 ELSE 0 END) >0 THEN 'SI' ELSE 'NO' END) VF2_233,
sum(CASE WHEN SMSDESTINATION <> 'CLA' and TARIFFZONE NOT LIKE 'IDE%' and tariffzone NOT IN ('NET03','MAI01','DAT01','GRA01') AND  SMSTOTAL = 0 THEN smsduration else 0 END) VF2_302
FROM DWS.SA_TEMP_TAG_1480  sa
WHERE PERIOD='&1'
GROUP BY MSISDN, PERIOD;

DELETE FROM DWM.DW_SPSS2_TRAFICO_PLAN_2 WHERE PERIOD='&1';
COMMIT;
INSERT INTO DWM.DW_SPSS2_TRAFICO_PLAN_2 SELECT * FROM DM.DW_SPSS2_TRAFICO_PLAN_2; 
COMMIT;

DROP TABLE DM.DW_SPSS2_TRAFICO_PLAN_2 PURGE;

EXIT;