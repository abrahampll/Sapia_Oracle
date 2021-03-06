WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

BEGIN
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_SPSS2_VF2_015');
END;
/

ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/RRRR';

CREATE TABLE DM.DW_SPSS2_VF2_015 AS
SELECT PERIODO, MSISDN, VF2_015 FROM (
SELECT '&1' AS PERIODO, B.TELEFONO AS MSISDN, B.DESCUENTO AS VF2_015,
ROW_NUMBER () OVER (PARTITION BY B.TELEFONO ORDER BY FECHA_VENTA DESC) RW
FROM DWS.SA_SISACT_AP_VENTA V
INNER JOIN DWS.SA_SISACT_AP_VENTA_DETALLE B
ON B.ID_DOCUMENTO = V.ID_DOCUMENTO
WHERE V.TVENC_CODIGO = '01'
AND TO_CHAR (V.FECHA_VENTA, 'YYYYMM') < '&1'
AND B.DESCUENTO >0
AND V.TOPEN_CODIGO IN (1,2)
AND EXISTS (SELECT 1 FROM DWM.DW_MAESTRA_POSTPAGO D
WHERE D.MSISDN = '51'|| B.TELEFONO
AND MES = '&1'))
WHERE RW=1;

INSERT INTO DWM.DW_SPSS2_VF2_015 SELECT * FROM DM.DW_SPSS2_VF2_015; 
COMMIT;

DROP TABLE DM.DW_SPSS2_VF2_015 PURGE;

EXIT;