##################################################################################
# NOMBRE		: SPSS_POSTPAGO_1.SH                           
# OBJETIVO		: POBLAR MAESTRA POSTPAGO EN REPTDM
# TIPO			: SHELL		
# FRECUENCIA	: MENSUAL   									    
# 									                            	
# VERSION		DESARROLLADOR		PROVEEDOR		FECHA		DETALLE	
#---------------------------------------------------------------------------------
# 1				MIGUEL QUISPE		SAPIA			17/07/2018  DESARROLLO
#---------------------------------------------------------------------------------

f_inicio_variables()
{
. /infa/workspace/bicc/dwh/shell/BI25982/sql/bin/.passet
. /infa/workspace/bicc/dwh/shell/BI25982/sql/bin/.varset
}
V_FECHA=$1
f_inicio_variables

sqlplus -s ${USRPWCID}/${USRPWCPS}@${USRPWCBD} @${DIR_POST_SQL}/0_VF2_MAESTRA_POSTPAGO_REPTDM_USRPWC.sql $V_FECHA > ${DIR_POST_LOG}/0_VF2_MAESTRA_POSTPAGO_REPTDM_USRPWC.LOG
exit $?