WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

BEGIN
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.DW_F2_C_M_GPRS_ENE');
END;
/

CREATE TABLE dm.DW_F2_C_M_GPRS_ENE AS
SELECT ROUND((SUM(CASE WHEN ACCESS_TYPE = '2G' AND rating_group = '25' THEN (UPLINK + DOWNLINK) ELSE 0 END)/1024/1024),2) AS VF2_248,
ROUND((SUM(CASE WHEN ACCESS_TYPE = '3G' AND rating_group = '25' THEN (UPLINK + DOWNLINK) ELSE 0 END)/1024/1024),2) AS VF2_249,
ROUND((SUM(CASE WHEN ACCESS_TYPE = '4G' AND rating_group = '25' THEN (UPLINK + DOWNLINK) ELSE 0 END)/1024/1024),2) AS VF2_250,
ROUND((SUM(CASE WHEN  rating_group = '25' THEN (UPLINK + DOWNLINK) ELSE 0 END)/1024/1024),2) AS VF2_242,
ROUND((SUM(CASE WHEN ACCESS_TYPE = '2G' AND rating_group = '26' THEN (UPLINK + DOWNLINK) ELSE 0 END)/1024/1024),2) AS VF2_251,
ROUND((SUM(CASE WHEN ACCESS_TYPE = '3G' AND rating_group = '26' THEN (UPLINK + DOWNLINK) ELSE 0 END)/1024/1024),2) AS VF2_252,
ROUND((SUM(CASE WHEN ACCESS_TYPE = '4G' AND rating_group = '26' THEN (UPLINK + DOWNLINK) ELSE 0 END)/1024/1024),2) AS VF2_253,
ROUND((SUM(CASE WHEN  rating_group = '26' THEN (UPLINK + DOWNLINK) ELSE 0 END)/1024/1024),2) AS VF2_243,
ROUND((SUM(CASE WHEN ACCESS_TYPE = '2G'  THEN (UPLINK + DOWNLINK) ELSE 0 END)/1024/1024),2) AS VF2_254,
ROUND((SUM(CASE WHEN ACCESS_TYPE = '3G'  THEN (UPLINK + DOWNLINK) ELSE 0 END)/1024/1024),2) AS VF2_255,
ROUND((SUM(CASE WHEN ACCESS_TYPE = '4G' THEN (UPLINK + DOWNLINK) ELSE 0 END)/1024/1024),2) AS VF2_256,
ROUND((SUM(CASE WHEN IDSEGMENTO IN ('2','3','4') THEN (UPLINK + DOWNLINK) ELSE 0 END)/1024/1024),2) AS VF2_244,
msisdn, MES
from DM.F_D_GPRS 
WHERE to_char(FCH_TRANSACCION, 'yyyymm') = '&1'
AND IDSEGMENTO IN ('2', '3', '4')
AND msisdn like '519%'
group by  msisdn, mes;

INSERT INTO DWM.DW_F2_C_M_GPRS_ENE SELECT * FROM DM.DW_F2_C_M_GPRS_ENE; 
COMMIT;

DROP TABLE DM.DW_F2_C_M_GPRS_ENE PURGE;

EXIT;