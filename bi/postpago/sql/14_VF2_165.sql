WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

BEGIN
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_spss_mae_post_agg_cust');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_spss_mae_post_cust_acc');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_spps_vf2_165');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'DM.DW_spps_vf2_165_F');
END;

/

CREATE TABLE DM.DW_spss_mae_post_agg_cust NOLOGGING AS
SELECT mes, customer_id, COUNT(1) cantidad
FROM   DWM.DW_MAESTRA_POSTPAGO
WHERE MES = '&1'
GROUP  BY mes, customer_id;

CREATE TABLE DM.DW_spss_mae_post_cust_acc NOLOGGING AS
SELECT DISTINCT b.customer_account_id
,b.cust_account
FROM dwo.dw_m_customer_account b
WHERE EXISTS(SELECT 1 FROM DM.DW_spss_mae_post_agg_cust m WHERE m.customer_id=b.cust_account AND m.mes= '&1');

CREATE TABLE DM.DW_spps_vf2_165 NOLOGGING compress AS
SELECT 
b.customer_account_id
,b.bill_number
,b.due_date
FROM dwo.dw_m_customer_bill b 
WHERE period = '&1'
and type='REC'
AND EXISTS(SELECT 1 FROM DM.DW_spss_mae_post_cust_acc a WHERE a.customer_account_id=b.customer_account_id);

CREATE TABLE DM.DW_spps_vf2_165_F NOLOGGING AS
SELECT period
,customer_account_id
,cust_account customer_id
,NVL(bill_number,'-') bill_number
,due_date
FROM(
SELECT DISTINCT '&1' period
,a.customer_account_id
,a.cust_account
,b.bill_number
,b.due_date
,ROW_NUMBER() OVER(PARTITION BY a.customer_account_id ORDER BY b.due_date DESC) fila
FROM  DM.DW_spss_mae_post_cust_acc a
LEFT JOIN (SELECT * FROM  DM.DW_spps_vf2_165) b ON(b.customer_account_id=a.customer_account_id) 
) WHERE fila=1;

INSERT INTO DWM.DW_spps_vf2_165_F SELECT * FROM DM.DW_spps_vf2_165_F; 
COMMIT;

DROP TABLE DM.DW_spss_mae_post_agg_cust PURGE;
DROP TABLE DM.DW_spss_mae_post_cust_acc PURGE;
DROP TABLE DM.DW_spps_vf2_165 PURGE;
DROP TABLE DM.DW_spps_vf2_165_F PURGE;

EXIT;