##################################################################################
# NOMBRE		: SPSS_POSTPAGO_4.SH                           
# OBJETIVO		: INSERTA TEMPORALES DE REPTDM A DWO
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

sqlplus -s ${USRPWCID}/${USRPWCPS}@${USRPWCBD} @${DIR_POST_SQL}/6_USRPWC.sql $V_FECHA > ${DIR_POST_LOG}/6_USRPWC.LOG
sqlplus -s ${USRPWCID}/${USRPWCPS}@${USRPWCBD} @${DIR_POST_SQL}/17_USRPWCS.sql $V_FECHA > ${DIR_POST_LOG}/17_USRPWCS.LOG
exit $?