WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

create table dm.dw_spss2_eq_trafico nologging parallel 2 as 
select a.mes as periodo, a.tim_number as msisdn, b.MANUFACTURER as vf2_386, b.model_name as vf2_388,
b.tac vf2_389, B.CATEGORY AS VF2_391 
from dm.dw_spss2_f_m_lineas_celda_cdr a
inner join dws.SA_BASE_GSMA_BANDS b on  b.tac=substr(trim(a.imei),1,8);

INSERT INTO DWM.dw_spss2_eq_trafico SELECT * FROM DM.dw_spss2_eq_trafico; 
COMMIT;

DROP TABLE DM.DW_SPSS2_EQ_TRAFICO PURGE;
DROP TABLE DM.SA_TEMP_TAG_1460_SPSS2 PURGE;

EXIT;