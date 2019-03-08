WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

BEGIN
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.T$_TEMP_TAG_11');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.i$_trafico_facturado_1460');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.f_d_trafico_consolidado_1460');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.t$_trafico_llamadas_sal_spss');
END;
/

create table DM.T$_TEMP_TAG_11 nologging compress parallel 4 as
select ohrefnum invoicenumber,
ohxact,
customer_id,
ohrefdate,
ohinvamt_doc,
to_char(ohrefdate,'yyyymm') periodo
from dws.sa_orderhdr_all
where TO_CHAR(ohrefdate, 'YYYYMM') = '&1'
and ohstatus in ('IN','CM');

create table DM.i$_trafico_facturado_1460 nologging parallel 4 compress as 
select
 t11.periodo,
 traf.msisdn,
 traf.calldate,
 sum(callduration) callduration,
 sum(calltotal) calltotal,
 count(1) cant_eventos,
 sum(decode(tipollamada, 11, callduration, 0)) ONNET_MOVIL_RPC,
 sum(decode(tipollamada, 12, callduration, 0)) ONNET_MOVIL,
 sum(decode(tipollamada, 14, callduration, 0)) OFFNET_MOVIL,
 sum(decode(tipollamada,13,decode(calldestination, 'CLA', callduration, 0),0)) ONNET_FIJO,
 sum(decode(tipollamada,13,decode(calldestination, 'CLA', 0, callduration),0)) OFFNET_FIJO,
 sum(decode(tipollamada, 20, callduration, 0)) LDN,
 sum(decode(tipollamada,30,decode(calldestination, 'CLA', 0, callduration),0)) LDI,
 sum(decode(tipollamada, 10, callduration, 0)) GRATUITO,
 sum(decode(tipollamada,14,decode(calldestination, 'TM', callduration, 0),0)) OFFNET_MOVIL_MOVISTAR,
 sum(decode(tipollamada,14,decode(calldestination, 'VIE', callduration, 0),0)) OFFNET_MOVIL_VIETTEL,
 sum(decode(tipollamada,14,decode(calldestination, 'NEX', callduration, 0),0)) OFFNET_MOVIL_NEXTEL,
 sum(case when tipollamada = 14 and nvl(calldestination, 'XXX') not in ('NEX', 'TM', 'VIE') then
        callduration
       else
        '0'
     end) OFFNET_MOVIL_OTROS,
 decode(calltotal, 0, 1, 0) flag_incluido
  from dws.sa_temp_tag_1460 traf
  left join DM.T$_TEMP_TAG_11 t11 
  on traf.invoicenumber=t11.invoicenumber and traf.period='&1'
 where t11.periodo = '&1'
  and tipollamada in (11,12,14,13,20,30,10)
 and replace(replace(callduration,':',''),'.','')=callduration
 group by t11.periodo,
          traf.msisdn,
          traf.calldate,
          decode(calltotal, 0, 1, 0);

create table dm.f_d_trafico_consolidado_1460 nologging compress parallel 4 as 
select a.periodo,
       a.msisdn,
       calldate,
       SUM(cant_eventos) CANT_LLAMADAS,
       sum(a.callduration) TRAF_VOZ_TOTAL,
       sum(decode(a.flag_incluido, 1, a.onnet_movil_rpc, 0))                      TRAF_VOZ_INC_ON_RPC,
       sum(decode(a.flag_incluido,1,a.onnet_fijo,0))                              TRAF_VOZ_INC_ON_FIJO,
       sum(decode(a.flag_incluido,1,a.onnet_movil,0))                             TRAF_VOZ_INC_ON_MOVIL,
       sum(decode(a.flag_incluido,1,a.offnet_fijo,0))                             TRAF_VOZ_INC_OFF_FIJO,
       sum(decode(a.flag_incluido,1,a.offnet_movil,0))                            TRAF_VOZ_INC_OFF_MOVIL,
       sum(decode(a.flag_incluido,1,a.offnet_movil_movistar,0))                   TRAF_VOZ_INC_OFF_MOVIL_MOV,
       sum(decode(a.flag_incluido,1,a.offnet_movil_nextel,0))                     TRAF_VOZ_INC_OFF_MOVIL_ENTEL,
       sum(decode(a.flag_incluido,1,a.offnet_movil_viettel,0))                    TRAF_VOZ_INC_OFF_MOVIL_VIETTEL,
       sum(decode(a.flag_incluido,1,a.offnet_movil_otros,0))                      TRAF_VOZ_INC_OFF_MOVIL_OTROS,
       sum(decode(a.flag_incluido,1,a.ldi,0))                                     TRAF_VOZ_INC_OFF_LDI,
       sum(decode(a.flag_incluido,1,a.ldn,0))                                     TRAF_VOZ_INC_OFF_LDN,
       sum(decode(a.flag_incluido,1,a.gratuito,0))                                TRAF_VOZ_GRATUITO,
       sum(decode(a.flag_incluido,0,a.onnet_fijo,0))                              TRAF_VOZ_ADI_FACT_ON_FIJO,
       sum(decode(a.flag_incluido,0,a.onnet_movil,0))                             TRAF_VOZ_ADI_FACT_ON_MOVIL,
       sum(decode(a.flag_incluido,0,a.offnet_fijo,0))                             TRAF_VOZ_ADI_FACT_OFF_FIJO,
       sum(decode(a.flag_incluido,0,a.offnet_movil,0))                            TRAF_VOZ_ADI_FACT_OFF_MOVIL,
       sum(decode(a.flag_incluido,0,a.offnet_movil_movistar,0))                   TRAF_VOZ_ADI_FACT_OFF_MOV_MOV,
       sum(decode(a.flag_incluido,0,a.offnet_movil_nextel,0))                     TRAF_VOZ_ADI_FACT_OFF_MOV_ENT,
       sum(decode(a.flag_incluido,0,a.offnet_movil_viettel,0))                    TRAF_VOZ_ADI_FACT_OFF_MOV_VIE,
       sum(decode(a.flag_incluido,0,a.offnet_movil_otros,0))                      TRAF_VOZ_ADI_FACT_OFF_MOV_OTR,
       sum(decode(a.flag_incluido,0,a.ldi,0))                                     TRAF_VOZ_ADI_FACT_OFF_LDI,
       sum(decode(a.flag_incluido,0,a.ldn,0))                                     TRAF_VOZ_ADI_FACT_OFF_LDN
  from DM.i$_trafico_facturado_1460 a
  where 
  a.periodo='&1'
  group by 
       a.periodo,
       a.calldate,
       a.msisdn;

create table dm.t$_trafico_llamadas_sal_spss nologging parallel 4 as
select periodo,
       msisdn,
       count(distinct calldate) cant_dias,
       sum(cant_llamadas)       cant_llamadas,
       max(calldate) ultimo_trafico
  from dm.f_d_trafico_consolidado_1460
 group by periodo,
       msisdn;

INSERT INTO DWM.DW_TRAFICO_LLAMADAS_SAL_SPSS SELECT * FROM DM.t$_trafico_llamadas_sal_spss; 
COMMIT;

DROP TABLE DM.T$_TRAFICO_LLAMADAS_SAL_SPSS PURGE;
drop table DM.T$_TEMP_TAG_11 purge;
drop table DM.i$_trafico_facturado_1460 purge;
drop table dm.f_d_trafico_consolidado_1460 purge;

EXIT;