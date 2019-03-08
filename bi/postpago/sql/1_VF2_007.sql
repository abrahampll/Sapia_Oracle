WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

BEGIN
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_MOT_ACT_VF2_007');
END;
/

CREATE TABLE DM.DW_MOT_ACT_VF2_007 AS
SELECT  A.DES_MOTIVO_ACT AS VF2_007, A.CO_ID, B.MES 
FROM DMRED.PP_DATOS_CONTRATO A
INNER JOIN DWM.DW_MAESTRA_POSTPAGO B
ON A.CO_ID= B.CO_ID
AND B.POSTPAGO IN ('CORPORATIVO', 'MASIVO')
AND B.STATUS IN ('ACTIVO', 'SUSPENDIDO')
AND B.FCH_ACTIVACION IS NOT NULL
AND B.MES = '&1';

INSERT INTO DWM.DW_MOT_ACT_VF2_007 SELECT * FROM DM.DW_MOT_ACT_VF2_007; 
COMMIT;

DROP TABLE DM.DW_MOT_ACT_VF2_007 PURGE;

EXIT;