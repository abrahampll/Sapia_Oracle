WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;
BEGIN
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_VF2_009_RESUMEN_NOV_17');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_VF2_009_NOV_17');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_SPSS2_VF2_009_17');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_VF2_009_COMBO_NOV_17');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_spss2_VF2_009_TIP_VENT_17');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_VF2_009_SELLOUT');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_spss2_VF2_009_FIN_17');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_VF2_009_COMBO_17');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_spss2_VF2_009_17_F');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_SPSS2_VF2_009_FI_17');

END;
/
CREATE TABLE DM.DW_VF2_009_RESUMEN_NOV_17 NOLOGGING AS
SELECT 
A.CO_ID, 
A.MSISDN, 
A.MES,
CASE WHEN ((B.EQUIPO IS NOT NULL AND TRIM (B.EQUIPO)<> 'TIM CHIP POSTPAGO' ) OR (B.IMEI IS NOT NULL AND TRIM (B.IMEI) <> 'SIN EQUIPO')
OR NVL (B.PRECIO_VTA_EQUIPO,0) >0) THEN 'EQUIPO'
WHEN (B.SIMCARD IS NOT NULL AND (B.IMEI IS NULL OR NVL (B.PRECIO_VTA_EQUIPO,0)=0)) THEN 'CHIP'
ELSE 'SIN DATA'
END VF2_009
FROM DWM.DW_MAESTRA_POSTPAGO A
INNER JOIN DM.DW_RESUMEN_VENTAS_POST B
ON A.CO_ID = B.IDCONTRATO
AND A.MSISDN = B.MSISDN
WHERE A.MES = '&1';

CREATE TABLE DM.DW_VF2_009_NOV_17 NOLOGGING AS
SELECT 
a.co_id,
a.msisdn, 
a.mes,
case when ((b.equipo is not null and trim(b.equipo) <> 'TIM CHIP POSTPAGO') or
(b.imei is not null and trim(b.imei) <> 'SIN EQUIPO') or
nvl(b.precio_vta_equipo, 0) > 0) then 'EQUIPO'
when (b.simcard is not null and 
(b.imei is null or nvl(b.precio_vta_equipo, 0) = 0)) then 'CHIP'
else 'SIN_DATA'
end VF2_009
FROM DWM.DW_MAESTRA_POSTPAGO a
left join 
(
select bb.*, row_number() over(partition by bb.nro_telefono order by bb.fecha_creacion desc) seq 
from dm.dw_sellout bb 
inner join DWM.DW_MAESTRA_POSTPAGO aa 
on aa.MSISDN = bb.nro_telefono
and abs(nvl(bb.fecha_act,bb.fecha_venta)-to_date(aa.fch_activacion, 'dd/mm/yyyy'))<=7
WHERE bb.clase_venta in ('01', '04', '18')
and bb.tipo_venta = '01'
AND aa.MES = '&1'
) b 
on a.msisdn = b.nro_telefono
and abs(nvl(b.fecha_act,b.fecha_venta)-to_date(a.fch_activacion, 'dd/mm/yyyy'))<=7
and b.seq=1
WHERE a.MES = '&1';

CREATE TABLE DM.DW_SPSS2_VF2_009_17 AS
SELECT CO_ID, MSISDN, MES, VF2_009 
FROM
(
SELECT  A.CO_ID, A.MSISDN, A.MES, 
CASE WHEN B.COD_EQUIPO IS NOT NULL THEN 'EQUIPO'
WHEN B.COD_EQUIPO IS NULL AND B.MATERIAL IS NOT NULL THEN 'CHIP'
ELSE 'SIN DATA' 
END VF2_009,
ROW_NUMBER() OVER (PARTITION BY A.MSISDN, B.CO_ID , A.MES ORDER BY b.ID_CONTRATO DESC) RA
FROM DWM.DW_MAESTRA_POSTPAGO A
INNER JOIN DWS.SA_SISACT_AP_CONTRATO_DET B
ON A.CO_ID = B.CO_ID
WHERE A.MES = '&1'
)
WHERE RA=1;

CREATE TABLE DM.DW_VF2_009_COMBO_NOV_17 AS
SELECT 
a.co_id, 
a.msisdn, 
a.mes,
case when ((ico.combo13 is not null and upper(trim(ico.combo13)) <> 'TIM CHIP POSTPAGO') or
(ict.text18 is not null and upper(trim(ict.text18)) <> 'SIN EQUIPO')) then 'EQUIPO'
when (upper(trim(ico.combo13)) = 'TIM CHIP POSTPAGO') then 'CHIP'
else 'SIN_DATA'
end VF2_009
FROM DWM.DW_MAESTRA_POSTPAGO a
left join DMRED.info_contr_combo ico 
on a.co_id = ico.co_id
left join DMRED.info_contr_text ict
on a.co_id = ict.co_id
and ict.text18 is not null
and ico.combo13 is not null
WHERE A.MES = '&1';

CREATE table DM.DW_spss2_VF2_009_TIP_VENT_17 AS
select MES, msisdn,CO_ID, VF2_009 from (
SELECt MES, msisdn, CO_ID,
VF2_009,
row_number() over (partition by MSISDN, MES order by VF2_009 desc) rw
from (
SELECT * FROM DM.DW_SPSS2_VF2_009_17
union all
SELECT * FROM DM.DW_VF2_009_RESUMEN_NOV_17
))
where rw=1;

CREATE TABLE DM.DW_VF2_009_SELLOUT AS
select MES, MSISDN, CO_ID, VF2_009 from  DM.DW_VF2_009_NOV_17;

CREATE table DM.DW_spss2_VF2_009_FIN_17 AS
select MES, msisdn,CO_ID, VF2_009 from (
SELECt MES, msisdn, CO_ID,
VF2_009,
row_number() over (partition by MSISDN, MES order by VF2_009 ASC) rw
from (
SELECT * FROM DM.DW_spss2_VF2_009_TIP_VENT_17
union all
SELECT * FROM DM.DW_VF2_009_SELLOUT
))
where rw=1;

CREATE TABLE DM.DW_VF2_009_COMBO_17 AS
SELECT MES, MSISDN, CO_ID, VF2_009 FROM DM.DW_VF2_009_COMBO_NOV_17;

CREATE table DM.DW_spss2_VF2_009_17_F AS
select MES, msisdn,CO_ID, VF2_009 from (
SELECt MES, msisdn, CO_ID,
VF2_009,
row_number() over (partition by MSISDN, MES order by VF2_009 ASC) rw
from (
SELECT * FROM DM.DW_spss2_VF2_009_FIN_17
union all
SELECT * FROM DM.DW_VF2_009_COMBO_17
))
where rw=1;

CREATE TABLE DM.DW_SPSS2_VF2_009_FI_17 AS
SELECT MES, MSISDN, CO_ID, 
CASE WHEN VF2_009 = 'CHIP' THEN 'CHIP' WHEN VF2_009 = 'EQUIPO' THEN 'EQUIPO' WHEN VF2_009 = 'SIN DATA' THEN 'SIN DATA' 
WHEN VF2_009 = 'SIN_DATA' THEN 'SIN DATA' END VF2_009
FROM DM.DW_spss2_VF2_009_17_F;

DELETE FROM DWM.DW_SPSS2_VF2_009_FI_17 WHERE MES='&1';
COMMIT;
INSERT INTO DWM.DW_SPSS2_VF2_009_FI_17 SELECT * FROM DM.DW_SPSS2_VF2_009_FI_17; 
COMMIT;

DROP TABLE DM.DW_VF2_009_RESUMEN_NOV_17 PURGE;
DROP TABLE DM.DW_VF2_009_NOV_17 PURGE;
DROP TABLE DM.DW_SPSS2_VF2_009_17 PURGE;
DROP TABLE DM.DW_VF2_009_COMBO_NOV_17 PURGE;
DROP table DM.DW_spss2_VF2_009_TIP_VENT_17 PURGE;
DROP TABLE DM.DW_VF2_009_SELLOUT PURGE;
DROP table DM.DW_spss2_VF2_009_FIN_17 PURGE;
DROP TABLE DM.DW_VF2_009_COMBO_17 PURGE;
DROP table DM.DW_spss2_VF2_009_17_F PURGE;
DROP TABLE DM.DW_SPSS2_VF2_009_FI_17 PURGE;

EXIT;