WHENEVER SQLERROR EXIT 1;

SET ECHO ON;
SET SERVEROUTPUT ON;
SET TIMING ON;

WHENEVER SQLERROR EXIT 1;

BEGIN
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_cuentas_base');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_variables_postpago_fact');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_postpago_fact_ubi');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_postpago_fact_ubi_null');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_datos_ubicacion');
DM.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => 'dm.dw_postpago_fact_ubi_F');


END;
/

create table dm.dw_cuentas_base nologging parallel 4 as
select mes,customer_id,to_char(customer_id) customerid 
from dwm.dw_maestra_postpago
where mes = '&1'
group by mes,customer_id,to_char(customer_id);

create table dm.dw_variables_postpago_fact nologging parallel 4 as
select base.*,
t11.invoicenumber,
t11.invoicedate,
t11.cscompregno,
t11.periodstart,
t11.periodend,
ccaddr3 departamento_facturacion,
ccstreet provincia_facturacion,
cccity distrito_facturacion,
cycle ciclo_facturacion,
row_number() over(partition by customer_id,mes order by invoicedate desc) rank
from dm.dw_cuentas_base base
left join dws.sa_temp_tag_11 t11
on base.mes = t11.periodo
and base.customerid=t11.customerid;

create table dm.dw_postpago_fact_ubi as
select mes,
customer_id,
departamento_facturacion,
provincia_facturacion,
distrito_facturacion
from dm.dw_variables_postpago_fact where rank=1;

create table dm.dw_postpago_fact_ubi_null as
select a.mes,b.customer_id,b.departamento_facturacion,b.provincia_facturacion,b.distrito_facturacion,
row_number() over(partition by a.mes,a.customer_id order by b.mes asc) rank
from dm.dw_postpago_fact_ubi a,
(
select *
from dm.dw_postpago_fact_ubi
where departamento_facturacion is not null
) b
where a.customer_id = b.customer_id
and a.mes < b.mes
and a.departamento_facturacion is null;

merge into dm.dw_postpago_fact_ubi mp
using (select * from dm.dw_postpago_fact_ubi_null where rank=1) tmp
on (mp.customer_id=tmp.customer_id and mp.mes=tmp.mes)
when matched then 
update set mp.departamento_facturacion=tmp.departamento_facturacion,
mp.provincia_facturacion=tmp.provincia_facturacion,
mp.distrito_facturacion=tmp.distrito_facturacion;
commit;

create table dm.dw_datos_ubicacion AS            
select customer_id,
cccity      departamento_facturacion,
ccstreet    provincia_facturacion,
ccaddr3     distrito_facturacion
from dws.sa_ccontact_all
where customer_id in (select customer_id from dm.dw_postpago_fact_ubi where departamento_facturacion is null)
and ccbill = 'X';

merge into dm.dw_postpago_fact_ubi mp
using (select * from dm.dw_datos_ubicacion) tmp
on (mp.customer_id=tmp.customer_id)
when matched then 
update set mp.departamento_facturacion=tmp.departamento_facturacion,
mp.provincia_facturacion=tmp.provincia_facturacion,
mp.distrito_facturacion=tmp.distrito_facturacion
where mp.departamento_facturacion is null;          
commit;

CREATE TABLE dm.dw_postpago_fact_ubi_F AS
select MES, CUSTOMER_ID, DEPARTAMENTO_FACTURACION AS VF2_142, DISTRITO_FACTURACION AS VF2_143, PROVINCIA_FACTURACION AS VF2_146
from dm.dw_postpago_fact_ubi;

DELETE FROM DWM.dw_postpago_fact_ubi_F WHERE MES='&1';
COMMIT;

INSERT INTO DWM.dw_postpago_fact_ubi_F SELECT * FROM DM.dw_postpago_fact_ubi_F; 
COMMIT;

drop table dm.dw_cuentas_base purge;
drop table dm.dw_variables_postpago_fact purge;
drop table dm.dw_postpago_fact_ubi purge;
drop table dm.dw_postpago_fact_ubi_null purge;
drop table dm.dw_datos_ubicacion purge;            
drop TABLE dm.dw_postpago_fact_ubi_F purge;

EXIT;