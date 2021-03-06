WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

CREATE TABLE DM.DM_SPSS_LOCALIDAD_CONTRACT AS
SELECT MES AS PERIODO, B.CO_ID, B.MSISDN NRO_TELEFONO, D.DESCDEPARTAMENTO VF2_006
FROM DM.F_M_CONTRATO B, DM.DW_SUS_D_DEPARTAMENTO D
WHERE B.FLAG_ACT = 'X'
AND B.IDDEPARTAMENTO =  D.IDDEPARTAMENTO
AND  D.IDDEPARTAMENTO <> 25
AND MES = TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'YYYYMM');

GRANT ALL ON DM.DM_SPSS_LOCALIDAD_CONTRACT TO DBLINK_DWO;

EXIT;