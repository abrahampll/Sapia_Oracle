WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

BEGIN
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_SPSS2_TEMP_TAG_1470');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_SPSS2_TEMP_TAG_1470_F');
END;
/

CREATE TABLE DM.DW_SPSS2_TEMP_TAG_1470 AS
SELECT /*+ PARALLEL(30)*/ concat('51',a.msisdn)msisdn , substr (a.invoicenumber, 11,6) as periodo,
COUNT(case when a.calldestination = '2' then (a.callnumber) END)VF2_284,
ROUND(SUM(case when a.calldestination = '2' then (a.callduration/60) END),2)VF2_285,
COUNT(CASE when a.calldestination = '1' then (a.callnumber) END)VF2_372,
ROUND(SUM(case when a.calldestination = '1' then (a.callduration/60) END),2)VF2_376,
COUNT(CASE WHEN a.calldestination = '4'  then (a.callnumber) END)VF2_262,
COUNT(case when a.calldestination = '3' then (a.callnumber) END)VF2_306
FROM DWS.SA_TEMP_TAG_1470 a
where substr (a.invoicenumber, 11,6) = SUBSTR('&1',5,2)||SUBSTR('&1',1,4)
GROUP BY concat('51',a.msisdn), substr (a.invoicenumber, 11,6);

CREATE TABLE DM.DW_SPSS2_TEMP_TAG_1470_F AS
SELECT  MSISDN, SUBSTR (PERIODO,3,6) || SUBSTR (PERIODO,1,2) AS PERIODO, VF2_284, VF2_285, VF2_372, VF2_376, VF2_262, VF2_306 
FROM   DM.DW_SPSS2_TEMP_TAG_1470 A;

INSERT INTO DWM.DW_SPSS2_TEMP_TAG_1470_F SELECT * FROM DM.DW_SPSS2_TEMP_TAG_1470_F; 
COMMIT;

DROP TABLE DM.DW_SPSS2_TEMP_TAG_1470_F PURGE;
DROP TABLE DM.DW_SPSS2_TEMP_TAG_1470 PURGE;

EXIT;