WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

BEGIN
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_SPSS2_TARIFF');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_SPSS2_TARIFF_UND');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_SPSS2_TARIFF_UND_DATOS');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_spss2_otorgamiento_plan');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_spss2_otorgado');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_spps2_porc_con_mb_sms');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_spps2_porc_con_min');
END;
/

CREATE TABLE DM.DW_SPSS2_TARIFF NOLOGGING AS
SELECT CA.CO_ID, CA.TMCODE, PJ.TARIFF_ID as TARIFF_ID_B, PJ.COD_PROD3 as TARIFF_ID_O
FROM dmred.CONTRACT_ALL CA, dws.sa_RP_PROD_JANUS PJ 
WHERE PJ.CAMPO = 'PLAN'
AND CA.TMCODE = PJ.COD_PROD1
AND EXISTS (SELECT 1 FROM dwm.dw_maestra_postpago B WHERE B.CO_ID=CA.CO_ID AND B.MES = '&1');

CREATE TABLE DM.DW_SPSS2_TARIFF_UND NOLOGGING AS
select t.co_id, L.TMCODE,L.WALLET_ID, L.LIMITE, L.UNIDAD, L.TARIFF_ID , L.AUDIO_ID  ,
L.REPRODUCIR , L.TIPO_BOLSA , L.NOMBRE_AUDIO 
from dws.sa_RP_LIMIT_WALLET_JANUS L, DM.DW_SPSS2_TARIFF T
where L.TMCODE = T.TMCODE and L.REPRODUCIR='S'
AND (L.TARIFF_ID = T.TARIFF_ID_B or L.TARIFF_ID = T.TARIFF_ID_O)
group by  t.co_id, L.TMCODE,L.WALLET_ID, L.LIMITE, L.UNIDAD, L.TARIFF_ID , L.AUDIO_ID  ,
L.REPRODUCIR , L.TIPO_BOLSA , L.NOMBRE_AUDIO ;

CREATE TABLE DM.DW_SPSS2_TARIFF_UND_DATOS NOLOGGING AS
SELECT  t.CO_ID, LI.TMCODE, LI.WALLET_ID, LI.LIMITE, LI.UNIDAD, LI.TARIFF_ID , LI.AUDIO_ID ,
LI.REPRODUCIR , LI.TIPO_BOLSA , Li.NOMBRE_AUDIO
FROM dmred.PROFILE_SERVICE PS, dws.sa_RP_PROD_JANUS PJS, dws.sa_RP_LIMIT_WALLET_JANUS LI,
dmred.PR_SERV_STATUS_HIST SSH, dmred.PR_SERV_SPCODE_HIST SPH, DM.DW_SPSS2_TARIFF T
WHERE  PS.CO_ID = T.CO_ID
AND PJS.CAMPO = 'SERVICIO'
AND PS.CO_ID = SSH.CO_ID
AND PS.SNCODE = SSH.SNCODE
AND PS.STATUS_HISTNO = SSH.HISTNO
AND PS.CO_ID = SPH.CO_ID
AND PS.SNCODE = SPH.SNCODE
AND PS.SPCODE_HISTNO = SPH.HISTNO
AND SSH.STATUS = 'A'
AND PJS.COD_PROD1 = PS.SNCODE
AND NVL(PJS.COD_PROD2,SPH.SPCODE) = SPH.SPCODE
AND NVL(PJS.COD_PROD3,T.TMCODE) = T.TMCODE
AND PJS.TARIFF_ID = LI.TARIFF_ID
and LI.REPRODUCIR='S';   

create table DM.DW_spss2_otorgamiento_plan nologging as
select TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'YYYYMM') as periodo, co_id,
SUM(case when unidad='1' and upper(nombre_audio) LIKE '%RPC%' THEN ROUND(LIMITE/60,2) ELSE 0 END) VF2_181,
SUM(case when unidad='1' and upper(nombre_audio) not LIKE '%RPC%' THEN ROUND(LIMITE/60,2) ELSE 0 END) VF2_180,
SUM(case when unidad='3'  THEN LIMITE ELSE 0 END) VF2_182,
SUM(case when unidad='5' and upper(nombre_audio) LIKE '%GPRS%' THEN ROUND(LIMITE/1024/1024,2) ELSE 0 END) VF2_179
from 
(
select * from DM.DW_SPSS2_TARIFF_UND 
union all
select * from DM.DW_SPSS2_TARIFF_UND_DATOS 
) 
GROUP BY CO_ID;

create table dm.dw_spss2_otorgado nologging as 
select m.msisdn, m.co_id, m.mes as periodo, op.vf2_181, op.vf2_180, op.vf2_182, op.vf2_179
from dwm.dw_maestra_postpago m
left join dm.dw_spss2_otorgamiento_plan op on m.co_id=op.co_id and m.mes=op.periodo 
WHERE  M.STATUS='ACTIVO' AND M.FCH_ACTIVACION IS NOT NULL and m.mes = '&1';

create table dm.dw_spps2_porc_con_mb_sms nologging as
select o.periodo, o.msisdn, o.co_id,
case when o.vf2_182 is null or o.vf2_182=0  then 0 else round((tp.vf2_302+tp.vf2_305)/o.vf2_182,2) end vf2_240,
case when o.vf2_179 is null or o.vf2_179=0 then 0 else round(tp.vf2_224/o.vf2_179,2) end vf2_236  
from dm.dw_spss2_otorgado o
inner join  dwm.DW_SPSS2_TRAFICO_PLAN_2 tp on o.msisdn='51'||tp.msisdn and o.periodo=tp.period;

create table dm.dw_spps2_porc_con_min nologging as
select o.periodo, o.msisdn, o.co_id,
case when o.vf2_181 is null or o.vf2_181=0 then 0 else round(tt.vf2_228/o.vf2_181,2) end vf2_239, 
case when o.vf2_180 is null or o.vf2_180=0 then 0 else round(tt.vf2_332/o.vf2_180,2) end vf2_238,
case when (o.vf2_181 is null or o.vf2_180 is null or o.vf2_181=0 or o.vf2_180=0) then 0 else round((tt.vf2_228+tt.vf2_332)/(o.vf2_181+o.vf2_180),2) end vf2_237 
from dm.dw_spss2_otorgado o
inner join dm.dw_SPSS2_TAG_1460_VF2_228_375 tt on o.msisdn=tt.msisdn and o.periodo=tt.period;

INSERT INTO DWM.dw_spps2_porc_con_min SELECT * FROM DM.dw_spps2_porc_con_min; 
COMMIT;
INSERT INTO DWM.dw_spps2_porc_con_mb_sms SELECT * FROM DM.dw_spps2_porc_con_mb_sms; 
COMMIT;

DROP TABLE DM.DW_SPSS2_TARIFF PURGE;
DROP TABLE DM.DW_SPSS2_TARIFF_UND PURGE;
DROP TABLE DM.DW_SPSS2_TARIFF_UND_DATOS PURGE;
DROP TABLE DM.DW_spss2_otorgamiento_plan PURGE;
DROP TABLE dm.dw_spss2_otorgado PURGE;
DROP TABLE DM.dw_spps2_porc_con_mb_sms PURGE;
DROP TABLE DM.dw_spps2_porc_con_min PURGE;

EXIT;