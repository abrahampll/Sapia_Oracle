--##############################################################################
--#                                                                            #
--#   NOMBRE         :                                                         #
--#                                                                            #
--#   AUTOR          :   < SUSAN DELGADO >                                     #
--#   FECHA          :   < 20/08/2018>                                         #
--#   FUNCION        :   < SQL PLANTILLA >                                     #
--#   TABLAS         :   <DWM.DW_SPSS2_VF2_002_008>                            #
--#						 <DWM.DW_VF2_183_CARGO_FIJO>						   #
--#						 <DWM.DW_MOT_ACT_VF2_007>					     	   #
--#						 <DWM.DW_SPSS2_VF2_009_FI_17>					       #
--#						 <DWM.DW_SPSS2_BLACKLIST_VF2_135_136>				   #
--#						 <DWM.DW_SPSS2_VF2_186>							       #
--#                                                                            #
--#   COMENTARIO    :   <CREACION DE TABLAS TEMPORALES VARIABLES POSTPAGO>     #
--#                                                                            #
--#   DEPENDENCIAS  :   <>                                                     #
--#                                                                            #
--#  VERSION       :  1.0                                                      #
--#                : <FECHA> <PERSONA> : <DETALLE DE CAMBIOS>                  #
--##############################################################################

--#-------------------------------------------------------------------------------------------------------#  
--#  1.- DEFINICION DE PARAMETROS DINAMICOS                                                               #  
--#-------------------------------------------------------------------------------------------------------#  
--# <VARIABLE_NAME1> : VARIABLE CONFIGURADA EN LA APLICACION 
--# <P_VAR_SCHEMA_TEMP>  
--# <P_DB_TBS_STAGING> 
--# <P_VAR_SCHEMA_DWS> 
--# <P_VAR_SCHEMA_USR_ADMIN>
--# <P_VAR_PROCESS_DATE> 
--#-------------------------------------------------------------------------------------------------------#  

--#-------------------------------------------------------------------------------------------------------#  
--#  2.INICIO - PROCESO DE ELIMINACION Y TRUNCADO DE TABLAS                                               #  
--#-------------------------------------------------------------------------------------------------------#  
 
----#-------------------------------------------------------------------------------------------------------#  
----#  2.1.- ELIMINACION DE TABLAS TEMPORALES                              							        #   
----#-------------------------------------------------------------------------------------------------------#  
------------------------------------------------------------------------------------------------------------------------
EXEC DWO.PKG_FRAME_IDEAS_REPORT.SP_SET_PROCESS_STEP_LOG(<G_PROCESS_ID>,'','INICIANDO DROPEO DE TEMPORALES DE AMBITO LOCAL');
------------------------------------------------------------------------------------------------------------------------
BEGIN
<P_VAR_SCHEMA_TEMP>.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => '<P_VAR_SCHEMA_TEMP>.dw_cuentas_base');
<P_VAR_SCHEMA_TEMP>.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => '<P_VAR_SCHEMA_TEMP>.dw_variables_postpago_fact');
<P_VAR_SCHEMA_TEMP>.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => '<P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi');
<P_VAR_SCHEMA_TEMP>.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => '<P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi_null');
<P_VAR_SCHEMA_TEMP>.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => '<P_VAR_SCHEMA_TEMP>.dw_datos_ubicacion');
<P_VAR_SCHEMA_TEMP>.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => '<P_VAR_SCHEMA_TEMP>.t$_ciclo_facturacion_post');
<P_VAR_SCHEMA_TEMP>.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => '<P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi_F');

END;
/
------------------------------------------------------------------------------------------------------------------------
EXEC DWO.PKG_FRAME_IDEAS_REPORT.SP_SET_PROCESS_STEP_LOG(<G_PROCESS_ID>,'','TABLAS TEMPORALES DROPEADAS CORRECTAMENTE');
------------------------------------------------------------------------------------------------------------------------

--#-------------------------------------------------------------------------------------------------------#  
--#  3.- EJECUCION - PROCESO DE CARGA 														  			  #   
--#-------------------------------------------------------------------------------------------------------#  

----#-------------------------------------------------------------------------------------------------------#  
----#  3.1.- CREACION DE TABLAS TEMPORALES														  			#   
----#-------------------------------------------------------------------------------------------------------#  

------------------------------------------------------------------------------------------------------------------------  
EXEC DWO.PKG_FRAME_IDEAS_REPORT.SP_SET_PROCESS_STEP_LOG(<G_PROCESS_ID>,'','INICIANDO LA CREACION DE LA TABLA <P_VAR_SCHEMA_TEMP>.dw_cuentas_base PERIODO: <P_VAR_PROCESS_MONTH_ADD>');
------------------------------------------------------------------------------------------------------------------------ 
create table <P_VAR_SCHEMA_TEMP>.dw_cuentas_base nologging parallel 4 as
select mes,customer_id,to_char(customer_id) customerid 
from dwm.dw_maestra_postpago
where mes = '<P_VAR_PROCESS_MONTH_ADD>'
group by mes,customer_id,to_char(customer_id);
------------------------------------------------------------------------------------------------------------------------  
EXEC DWO.PKG_FRAME_IDEAS_REPORT.SP_SET_PROCESS_STEP_LOG(<G_PROCESS_ID>,'','TABLA <P_VAR_SCHEMA_TEMP>.dw_cuentas_base CREADA CORRECTAMENTE');
EXEC DWO.PKG_FRAME_IDEAS_REPORT.SP_SET_PROCESS_STEP_LOG(<G_PROCESS_ID>,'','INICIANDO LA CREACION DE LA TABLA <P_VAR_SCHEMA_TEMP>.dw_variables_postpago_fact PERIODO: <P_VAR_PROCESS_MONTH_ADD>');
------------------------------------------------------------------------------------------------------------------------ 
create table <P_VAR_SCHEMA_TEMP>.dw_variables_postpago_fact nologging parallel 4 as
select base.*,
t11.invoicenumber,
t11.invoicedate,
t11.cscompregno,
t11.periodstart,
t11.periodend,
ccaddr3 departamento_facturacion,
ccstreet provincia_facturacion,
cccity distrito_facturacion,
cycle Ciclo_facturación,
row_number() over(partition by customer_id,mes order by invoicedate desc) rank
from <P_VAR_SCHEMA_TEMP>.dw_cuentas_base base
left join dws.sa_temp_tag_11 t11
on base.mes = t11.periodo
and base.customerid=t11.customerid;
------------------------------------------------------------------------------------------------------------------------  
EXEC DWO.PKG_FRAME_IDEAS_REPORT.SP_SET_PROCESS_STEP_LOG(<G_PROCESS_ID>,'','TABLA <P_VAR_SCHEMA_TEMP>.dw_variables_postpago_fact CREADA CORRECTAMENTE');
EXEC DWO.PKG_FRAME_IDEAS_REPORT.SP_SET_PROCESS_STEP_LOG(<G_PROCESS_ID>,'','INICIANDO LA CREACION DE LA TABLA <P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi PERIODO: <P_VAR_PROCESS_MONTH_ADD>');
------------------------------------------------------------------------------------------------------------------------ 
create table <P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi as
select mes,
customer_id,
departamento_facturacion,
provincia_facturacion,
distrito_facturacion
from <P_VAR_SCHEMA_TEMP>.dw_variables_postpago_fact where rank=1;
------------------------------------------------------------------------------------------------------------------------  
EXEC DWO.PKG_FRAME_IDEAS_REPORT.SP_SET_PROCESS_STEP_LOG(<G_PROCESS_ID>,'','TABLA <P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi CREADA CORRECTAMENTE');
EXEC DWO.PKG_FRAME_IDEAS_REPORT.SP_SET_PROCESS_STEP_LOG(<G_PROCESS_ID>,'','INICIANDO LA CREACION DE LA TABLA <P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi_null PERIODO: <P_VAR_PROCESS_MONTH_ADD>');
------------------------------------------------------------------------------------------------------------------------ 
create table <P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi_null as
select a.mes,b.customer_id,b.departamento_facturacion,b.provincia_facturacion,b.distrito_facturacion,
row_number() over(partition by a.mes,a.customer_id order by b.mes asc) rank
from <P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi a,
(
select *
from <P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi
where departamento_facturacion is not null
) b
where a.customer_id = b.customer_id
and a.mes < b.mes
and a.departamento_facturacion is null;
------------------------------------------------------------------------------------------------------------------------  
EXEC DWO.PKG_FRAME_IDEAS_REPORT.SP_SET_PROCESS_STEP_LOG(<G_PROCESS_ID>,'','TABLA <P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi_null CREADA CORRECTAMENTE');
EXEC DWO.PKG_FRAME_IDEAS_REPORT.SP_SET_PROCESS_STEP_LOG(<G_PROCESS_ID>,'','INICIANDO LA CREACION DE LA TABLA <P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi PERIODO: <P_VAR_PROCESS_MONTH_ADD>');
------------------------------------------------------------------------------------------------------------------------ 
merge into <P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi mp
using (select * from <P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi_null where rank=1) tmp
on (mp.customer_id=tmp.customer_id and mp.mes=tmp.mes)
when matched then 
update set mp.departamento_facturacion=tmp.departamento_facturacion,
mp.provincia_facturacion=tmp.provincia_facturacion,
mp.distrito_facturacion=tmp.distrito_facturacion;
commit;
------------------------------------------------------------------------------------------------------------------------  
EXEC DWO.PKG_FRAME_IDEAS_REPORT.SP_SET_PROCESS_STEP_LOG(<G_PROCESS_ID>,'','TABLA <P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi CREADA CORRECTAMENTE');
EXEC DWO.PKG_FRAME_IDEAS_REPORT.SP_SET_PROCESS_STEP_LOG(<G_PROCESS_ID>,'','INICIANDO LA CREACION DE LA TABLA <P_VAR_SCHEMA_TEMP>.dw_variables_postpago_fact PERIODO: <P_VAR_PROCESS_MONTH_ADD>');
------------------------------------------------------------------------------------------------------------------------ 
create table <P_VAR_SCHEMA_TEMP>.dw_datos_ubicacion AS            
select customer_id,
cccity      departamento_facturacion,
ccstreet    provincia_facturacion,
ccaddr3     distrito_facturacion
from dws.sa_ccontact_all
where customer_id in (select customer_id from <P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi where departamento_facturacion is null)
and ccbill = 'X';
------------------------------------------------------------------------------------------------------------------------  
EXEC DWO.PKG_FRAME_IDEAS_REPORT.SP_SET_PROCESS_STEP_LOG(<G_PROCESS_ID>,'','TABLA <P_VAR_SCHEMA_TEMP>.dw_datos_ubicacion CREADA CORRECTAMENTE');
EXEC DWO.PKG_FRAME_IDEAS_REPORT.SP_SET_PROCESS_STEP_LOG(<G_PROCESS_ID>,'','INICIANDO MERGE <P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi PERIODO: <P_VAR_PROCESS_MONTH_ADD>');
------------------------------------------------------------------------------------------------------------------------ 
merge into <P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi mp
using (select * from <P_VAR_SCHEMA_TEMP>.dw_datos_ubicacion) tmp
on (mp.customer_id=tmp.customer_id)
when matched then 
update set mp.departamento_facturacion=tmp.departamento_facturacion,
mp.provincia_facturacion=tmp.provincia_facturacion,
mp.distrito_facturacion=tmp.distrito_facturacion
where mp.departamento_facturacion is null;          
commit;
------------------------------------------------------------------------------------------------------------------------  
EXEC DWO.PKG_FRAME_IDEAS_REPORT.SP_SET_PROCESS_STEP_LOG(<G_PROCESS_ID>,'','TABLA <P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi CREADA CORRECTAMENTE');
EXEC DWO.PKG_FRAME_IDEAS_REPORT.SP_SET_PROCESS_STEP_LOG(<G_PROCESS_ID>,'','INICIANDO LA CREACION DE LA TABLA <P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi PERIODO: <P_VAR_PROCESS_MONTH_ADD>');
------------------------------------------------------------------------------------------------------------------------ 
CREATE TABLE <P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi_F AS
select MES, CUSTOMER_ID, DEPARTAMENTO_FACTURACION AS VF2_142, DISTRITO_FACTURACION AS VF2_143, PROVINCIA_FACTURACION AS VF2_146
from <P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi;
------------------------------------------------------------------------------------------------------------------------  
EXEC DWO.PKG_FRAME_IDEAS_REPORT.SP_SET_PROCESS_STEP_LOG(<G_PROCESS_ID>,'','TABLA <P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi_F CREADA CORRECTAMENTE');
EXEC DWO.PKG_FRAME_IDEAS_REPORT.SP_SET_PROCESS_STEP_LOG(<G_PROCESS_ID>,'','INICIANDO LA CREACION DE LA TABLA <P_VAR_SCHEMA_TEMP>.t$_ciclo_facturacion_post PERIODO: <P_VAR_PROCESS_MONTH_ADD>');
------------------------------------------------------------------------------------------------------------------------ 
create table <P_VAR_SCHEMA_TEMP>.t$_ciclo_facturacion_post nologging parallel 4 as
select base.*,
       custall.billcycle,
       new_billcycle,
       seqno,
       cycle_hist.csmoddate,
       row_number() over(partition by base.customer_id, base.mes order by cycle_hist.csmoddate desc) rank
  from <P_VAR_SCHEMA_TEMP>.dw_cuentas_base base
  join dws.sa_customer_all custall
    on base.customer_id = custall.customer_id
  left join <P_VAR_SCHEMA_TEMP>.sa_billcycle_hist cycle_hist
    on base.customer_id = cycle_hist.customer_id
   and to_char(cycle_hist.csmoddate, 'yyyymm') <= base.mes
------------------------------------------------------------------------------------------------------------------------  
EXEC DWO.PKG_FRAME_IDEAS_REPORT.SP_SET_PROCESS_STEP_LOG(<G_PROCESS_ID>,'','TABLA <P_VAR_SCHEMA_TEMP>.t$_ciclo_facturacion_post CREADA CORRECTAMENTE');
------------------------------------------------------------------------------------------------------------------------ 
----#-------------------------------------------------------------------------------------------------------#  
----#  4.- ELIMINACION DE TABLAS TEMPORALES                              							        #   
----#-------------------------------------------------------------------------------------------------------#  
------------------------------------------------------------------------------------------------------------------------
EXEC DWO.PKG_FRAME_IDEAS_REPORT.SP_SET_PROCESS_STEP_LOG(<G_PROCESS_ID>,'','INICIANDO DROPEO DE TEMPORALES DE AMBITO LOCAL');
------------------------------------------------------------------------------------------------------------------------
BEGIN
<P_VAR_SCHEMA_TEMP>.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => '<P_VAR_SCHEMA_TEMP>.dw_cuentas_base');
<P_VAR_SCHEMA_TEMP>.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => '<P_VAR_SCHEMA_TEMP>.dw_variables_postpago_fact');
<P_VAR_SCHEMA_TEMP>.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => '<P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi');
<P_VAR_SCHEMA_TEMP>.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => '<P_VAR_SCHEMA_TEMP>.dw_postpago_fact_ubi_null');
<P_VAR_SCHEMA_TEMP>.PKG_MGR_DWO_UTIL.PRC_DROP_TABLE(X_DES_TABLA => '<P_VAR_SCHEMA_TEMP>.dw_datos_ubicacion');
END;
/
------------------------------------------------------------------------------------------------------------------------
EXEC DWO.PKG_FRAME_IDEAS_REPORT.SP_SET_PROCESS_STEP_LOG(<G_PROCESS_ID>,'','TABLAS TEMPORALES DROPEADAS CORRECTAMENTE');
------------------------------------------------------------------------------------------------------------------------