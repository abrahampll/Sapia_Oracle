WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

DROP TABLE DM.DW_SPSS2_SEG_CAE_VF2_213 PURGE;


CREATE TABLE DM.DW_SPSS2_SEG_CAE_VF2_213 AS
SELECT PERIODO AS MES, RUC, SECTOR AS VF2_213 FROM CLIBAJA.CORP_CAE_2017 where periodo = '&1';

GRANT ALL ON DM.DW_SPSS2_SEG_CAE_VF2_213 TO DBLINK_DWO;


EXIT;