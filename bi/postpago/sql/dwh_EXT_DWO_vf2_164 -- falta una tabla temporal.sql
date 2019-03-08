create table <P_VAR_SCHEMA_TEMP>.dw_cuentas_base nologging parallel 4 as
select mes,customer_id,to_char(customer_id) customerid 
from dwm.<P_VAR_SCHEMA_TEMP>.dw_maestra_postpago where mes = '<P_VAR_PROCESS_MONTH_ADD>'
group by mes,customer_id,to_char(customer_id);

create table <P_VAR_SCHEMA_TEMP>.dw_cuentas_base_1 nologging parallel 4 as
select a.*, b.customer_account_id
from <P_VAR_SCHEMA_TEMP>.dw_cuentas_base a
left join dwo.iden_customer_account b
on a.customerid = b.iden_account_value
and b.iden_type = 111;

create table <P_VAR_SCHEMA_TEMP>.dw_base_pagos nologging parallel 4 as
select base.*,pmt.payment_id,pmt.payment_date,pmt.payment_type_id
from <P_VAR_SCHEMA_TEMP>.dw_cuentas_base_1 base 
join dwo.customer_payment pmt 
on base.customer_account_id=pmt.customer_account_id
and to_date(base.mes,'yyyymm')<=pmt.payment_date
and pmt.payment_date<add_months(to_date(base.mes,'yyyymm'),1);

create table <P_VAR_SCHEMA_TEMP>.dw_base_pagos_detalle nologging parallel 4 as
select pmt.*,dtl.payment_method_id,currency_id,receipt_date,amount
from <P_VAR_SCHEMA_TEMP>.dw_base_pagos pmt
join dwo.customer_payment_detail dtl
on pmt.payment_id=dtl.payment_id;

create table <P_VAR_SCHEMA_TEMP>.dw_base_pagos_detalle_medio nologging parallel 4 as
select pmt_dtl.*,mthd.description forma_pago,clss.receipt_class_id,clss.name
from <P_VAR_SCHEMA_TEMP>.dw_base_pagos_detalle pmt_dtl
join DWO.DW_C_PAYMENT_METHOD mthd on pmt_dtl.PAYMENT_METHOD_ID=mthd.PAYMENT_METHOD_ID
left join DWS.SA_AR_RECEIPT_METHODS rmthd on mthd.source_code=rmthd.receipt_method_id
left join E704512.AR_RECEIPT_CLASSES@DBL_DWM clss on rmthd.receipt_class_id=clss.receipt_class_id

create table <P_VAR_SCHEMA_TEMP>.dw_base_pagos_detalle_app nologging parallel 4 as
select pmt.*,app.bill_id,app.applied_type_id,app.amount_applied,app.applied_date
from <P_VAR_SCHEMA_TEMP>.dw_base_pagos_detalle_medio pmt
join dwo.payment_applied_bill app
on pmt.payment_id = app.payment_id
and flag_active = 1
and flag_applied = 1;

drop table <P_VAR_SCHEMA_TEMP>.dw_base_pagos_detalle_app_sts purge;
create table <P_VAR_SCHEMA_TEMP>.dw_base_pagos_detalle_app_sts nologging parallel 4 as
select app.*,status_id from <P_VAR_SCHEMA_TEMP>.dw_base_pagos_detalle_app app left join
dwo.customer_payment_status sts on app.payment_id=sts.payment_id and flag_active=1;

drop table <P_VAR_SCHEMA_TEMP>.dw_base_pagos_detalle_bill purge;
create table <P_VAR_SCHEMA_TEMP>.dw_base_pagos_detalle_bill nologging parallel 4 as
select distinct pmt.*,
bill.bill_number,
bill.bill_type_id,
bill.bill_date,
bill.bill_amount,
bill.payment_due_date
from <P_VAR_SCHEMA_TEMP>.dw_base_pagos_detalle_app_sts pmt
left join dwo.customer_bill bill
on pmt.bill_id = bill.bill_id;

create table <P_VAR_SCHEMA_TEMP>.dw_base_final_pagos nologging parallel 2 as
select mes,
customer_id,
customer_account_id,
payment_id,
payment_date,
bill_number,
bill_date,
bill_amount,
payment_due_date,
forma_pago,
name medio_pago,
row_number() over(partition by customer_account_id,mes order by payment_date desc) rank
from <P_VAR_SCHEMA_TEMP>.dw_base_pagos_detalle_bill
where bill_type_id = 9716
and nvl(status_id,1) in (1081,1082,1);

create table <P_VAR_SCHEMA_TEMP>.dw_pagos_spss_1 nologging parallel 4 as
select mes,
customer_id,
customer_account_id,
max(payment_date) Fecha_ultimo_pago,
count(distinct payment_id) cantidad_pagos,
max(decode(rank,1,forma_pago)) forma_pago, 
max(decode(rank,1,medio_pago)) medio_pago
from <P_VAR_SCHEMA_TEMP>.dw_base_final_pagos base_pagos
group by mes,
customer_id,
customer_account_id;