WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

BEGIN
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_BAJAS_2G_HP_POST');
END;
/

ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/RRRR';
CREATE TABLE DM.DW_BAJAS_2G_HP_POST NOLOGGING AS
SELECT  B.MES, B.TIM_NUMBER,  A.ACC_PS VF2_047, A.RET_PS VF2_049, A.TH_DL VF2_051
FROM DWS.SA_BASE_BAJAS_2G_HP A
INNER JOIN USRPWC.F_M_LINEAS_CELDA_CDR B
ON A.LAC = B.LAC
AND A.CELL_ID = B.CELDA
AND REPLACE (A.PERIODO,'-','') = B.MES
WHERE B.MES = '&1';

INSERT INTO DWM.DW_BAJAS_2G_HP_POST SELECT * FROM DM.DW_BAJAS_2G_HP_POST; 
COMMIT;

DROP TABLE DM.DW_BAJAS_2G_HP_POST PURGE;

EXIT;