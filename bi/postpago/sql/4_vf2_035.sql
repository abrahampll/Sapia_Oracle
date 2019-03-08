WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

BEGIN
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_BLOQUEO_VF2_035');
END;
/
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/RRRR';
CREATE TABLE DM.DW_BLOQUEO_VF2_035 NOLOGGING AS
SELECT
R.CO_ID,
R.PERIODO,
MAX(CASE
WHEN TO_CHAR(R.CREATED_DATE, 'YYYYMM') = '&1' THEN
ROUND(R.FIN - R.CREATED_DATE, 2)
WHEN R.CLOSED_DATE IS NULL THEN
EXTRACT(DAY FROM R.FIN)
ELSE
EXTRACT(DAY FROM R.FIN)
END) VF2_035
FROM (
SELECT '&1' ANALISIS,
P.CO_ID,
TO_CHAR(P.CREATED_DATE, 'YYYYMM') PERIODO,
P.CREATED_DATE,
P.CLOSED_DATE,
p.tickler_code,
TO_DATE(TO_CHAR(LAST_DAY(TO_DATE('&1','YYYYMM')),'YYYYMMDD')||' 11:59:59 PM' , 'YYYYMMDD HH:MI:SS AM') FIN
FROM DMRED.tickler_records P
WHERE TO_CHAR(P.CREATED_DATE, 'YYYYMM') BETWEEN '201605' AND '&1'
AND P.tickler_code IN ('BLOQ_COB', 'SUSP_COB')
AND P.CO_ID IS NOT NULL
AND P.short_description <> 'ALINEACION PKG111'
AND (P.CLOSED_DATE IS NULL OR
TO_CHAR(P.CLOSED_DATE, 'YYYYMMDD') > '&1'||'01')
AND TO_CHAR(P.CREATED_DATE, 'YYYYMMDD') < TO_CHAR(LAST_DAY(TO_DATE('&1','YYYYMM'))+1,'YYYYMMDD')
) R
GROUP BY R.CO_ID,R.PERIODO;

INSERT INTO DWM.DW_BLOQUEO_VF2_035 SELECT * FROM DM.DW_BLOQUEO_VF2_035; 
COMMIT;

DROP TABLE DM.DW_BLOQUEO_VF2_035 PURGE;

EXIT;