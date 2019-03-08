WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;
BEGIN
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_cuentas_base');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_cuentas_base_1');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_base_pagos');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_base_pagos_detalle');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_base_pagos_detalle_medio');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_base_pagos_detalle_app');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_base_pagos_detalle_app_sts');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_base_pagos_detalle_bill');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_base_final_pagos');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_spss_vf2_166_167');
END;
/

create table dm.dw_cuentas_base nologging parallel 4 as
select mes,customer_id,to_char(customer_id) customerid 
from dwm.dw_maestra_postpago where mes = '&1' group by mes,customer_id,to_char(customer_id);

create table dm.dw_cuentas_base_1 nologging parallel 4 as
select a.*, b.customer_account_id
from dm.dw_cuentas_base a
left join dwo.iden_customer_account b
on a.customerid = b.iden_account_value
and b.iden_type = 111;

create table dm.dw_base_pagos nologging parallel 4 as
select base.*,pmt.payment_id,pmt.payment_date,pmt.payment_type_id from  dm.dw_cuentas_base_1 base join
dwo.customer_payment pmt 
on base.customer_account_id=pmt.customer_account_id
and to_date(base.mes,'yyyymm')<=pmt.payment_date
and pmt.payment_date<add_months(to_date(base.mes,'yyyymm'),1);

create table dm.dw_base_pagos_detalle nologging parallel 4 as
select pmt.*,dtl.payment_method_id,currency_id,receipt_date,amount from  dm.dw_base_pagos pmt join 
dwo.customer_payment_detail dtl
on pmt.payment_id=dtl.payment_id;

create table dm.dw_base_pagos_detalle_medio nologging parallel 4 as
select pmt_dtl.*,
mthd.description,
z.receipt_class_id,
z.name,
rmthd.receipt_method_id,
z.forma_pago,
z.medio_pago
from dm.dw_base_pagos_detalle pmt_dtl
join DWO.DW_C_PAYMENT_METHOD mthd
on pmt_dtl.PAYMENT_METHOD_ID = mthd.PAYMENT_METHOD_ID
left join DWS.SA_AR_RECEIPT_METHODS rmthd
on mthd.source_code = rmthd.receipt_method_id
left join CLIBAJA.AB_CAT_FORMA_MEDIO_PAGO z -- Catalogo del usuario
on rmthd.receipt_class_id = z.receipt_class_id
and rmthd.receipt_method_id = z.receipt_method_id;
   
create table dm.dw_base_pagos_detalle_app nologging parallel 4 as
select pmt.*,app.bill_id,app.applied_type_id,app.amount_applied,app.applied_date
from  dm.dw_base_pagos_detalle_medio pmt
join dwo.payment_applied_bill app
on pmt.payment_id = app.payment_id
and flag_active = 1
and flag_applied = 1;

create table dm.dw_base_pagos_detalle_app_sts nologging parallel 4 as
select app.*,status_id from  dm.dw_base_pagos_detalle_app app join
dwo.customer_payment_status sts on app.payment_id=sts.payment_id and flag_active=1;

create table dm.dw_base_pagos_detalle_bill nologging parallel 4 as
select distinct pmt.*,
bill.bill_number,
bill.bill_type_id,
bill.bill_date,
bill.bill_amount,
bill.payment_due_date
from  dm.dw_base_pagos_detalle_app_sts pmt
left join dwo.customer_bill bill
on pmt.bill_id = bill.bill_id;

create table dm.dw_base_final_pagos nologging parallel 2 as
select a.*,
row_number() over(partition by customer_account_id,mes order by payment_date desc) rank
from  dm.dw_base_pagos_detalle_bill a
where bill_type_id = 9716
and status_id in (1081,1082);

create table dm.dw_spss_vf2_166_167 nologging parallel 2 as
select mes,customer_id,forma_pago as VF2_166, medio_pago as VF2_167 
from 
(                     
select * from  dm.dw_base_final_pagos where rank=1
and  mes = '&1'
);

INSERT INTO DWM.dw_spss_vf2_166_167 SELECT * FROM DM.dw_spss_vf2_166_167; 
COMMIT;

DROP TABLE dm.dw_cuentas_base PURGE;
DROP TABLE dm.dw_cuentas_base_1 PURGE;
DROP TABLE dm.dw_base_pagos PURGE;
DROP TABLE dm.dw_base_pagos_detalle PURGE;
DROP TABLE dm.dw_base_pagos_detalle_medio PURGE;
DROP TABLE dm.dw_base_pagos_detalle_app PURGE;
DROP TABLE dm.dw_base_pagos_detalle_app_sts PURGE;
DROP TABLE dm.dw_base_pagos_detalle_bill PURGE;
DROP TABLE dm.dw_base_final_pagos PURGE;
DROP TABLE dm.dw_spss_vf2_166_167 PURGE;

EXIT;