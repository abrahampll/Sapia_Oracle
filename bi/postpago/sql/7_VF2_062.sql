WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;
BEGIN
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_BAJAS_4G_POST');
END;
/

CREATE TABLE DM.DW_BAJAS_4G_POST AS
SELECT B.MES, B.TIM_NUMBER, A.ACC_PS VF2_062, A.RET_PS VF2_064, A.TH_DL VF2_066, A.TH_UL VF2_068
FROM DWS.SA_BASE_BAJAS_4G A
INNER JOIN USRPWC.F_M_LINEAS_CELDA_CDR B
ON A.LAC = B.LAC
AND A.CELL_ID = B.CELDA
AND REPLACE (A.PERIODO,'-','') = B.MES
WHERE B.MES = '&1';

DELETE FROM DWM.DW_BAJAS_4G_POST WHERE MES='&1';
COMMIT;

INSERT INTO DWM.DW_BAJAS_4G_POST SELECT * FROM DM.DW_BAJAS_4G_POST; 
COMMIT;

DROP TABLE DM.DW_BAJAS_4G_POST PURGE;

EXIT;