WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/RRRR';

BEGIN
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.dw_bloqueos_suspenciones_spss');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.dw_periodos_bloqueos_spss');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.dw_flag_bloqueos_periodo_spss');
END;
/
create table DM.dw_bloqueos_suspenciones_spss nologging parallel 4 compress as
select customer_id,co_id,tickler_status,created_date,closed_date,tickler_code,long_description
from dmred.tickler_records
where tickler_code in
(select tickler_code
from dws.sa_tickler_code_def
where upper(long_desc) like '%BLOQUEO%'
or upper(long_desc) like '%SUSPEN%')
and to_char(created_date, 'yyyymm')='&1';
ALTER TABLE DM.dw_bloqueos_suspenciones_spss NOPARALLEL;

create table DM.dw_periodos_bloqueos_spss nologging parallel 4 compress as
select customer_id,
co_id,
to_char(created_date, 'yyyymm') mes_bloqueo,
to_char(nvl(closed_date, to_date('99991231', 'yyyymmdd')), 'yyyymm') mes_reconexion,
tickler_code tipo_bloqueo
from DM.dw_bloqueos_suspenciones_spss;
ALTER TABLE DM.dw_periodos_bloqueos_spss NOPARALLEL;

create table DM.dw_flag_bloqueos_periodo_spss nologging parallel 4 as
select base.mes,base.customer_id,base.co_id,max(nvl2(bloq.co_id,1,0)) VF2_144 from dwm.dw_maestra_postpago base left join
DM.dw_periodos_bloqueos_spss bloq on base.customer_id=bloq.customer_id and base.co_id=bloq.co_id
and base.mes between bloq.mes_bloqueo and bloq.mes_reconexion
where base.mes= '&1'
group by base.mes,base.customer_id,base.co_id;
ALTER TABLE DM.dw_flag_bloqueos_periodo_spss NOPARALLEL;

DELETE FROM DWM.dw_flag_bloqueos_periodo_spss WHERE MES='&1';
COMMIT;
INSERT INTO DWM.dw_flag_bloqueos_periodo_spss SELECT * FROM DM.dw_flag_bloqueos_periodo_spss; 
COMMIT;

DROP TABLE DM.dw_bloqueos_suspenciones_spss PURGE;
DROP TABLE DM.dw_periodos_bloqueos_spss PURGE;
DROP TABLE DM.dw_flag_bloqueos_periodo_spss PURGE;

EXIT;