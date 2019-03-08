WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

BEGIN
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.DW_spps_post_vf2_147');
END;
/

CREATE TABLE dm.DW_spps_post_vf2_147 NOLOGGING AS
SELECT a.mes
,a.customer_id
,a.co_id
,a.msisdn
,DECODE(cc.check02,NULL,0,1) VF2_147
FROM (SELECT * FROM dwm.DW_MAESTRA_POSTPAGO a where a.mes='&1') a
LEFT JOIN dws.sa_info_cust_check cc ON (cc.customer_id=a.customer_id);

DELETE FROM DWM.DW_spps_post_vf2_147 WHERE MES='&1';
COMMIT;

INSERT INTO DWM.DW_spps_post_vf2_147 SELECT * FROM DM.DW_spps_post_vf2_147; 
COMMIT;

DROP TABLE DM.DW_spps_post_vf2_147 PURGE;

EXIT;