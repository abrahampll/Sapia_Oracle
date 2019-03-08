##################################################################################
# NOMBRE		: SPSS_POSTPAGO_5.SH                           
# OBJETIVO		: CREACION DE TEMPORALES FALTANTES EN DWO
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

sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/4_VF2_391_REPTDM_DWO.sql $V_FECHA > ${DIR_POST_LOG}/4_VF2_391_REPTDM_DWO.LOG
exit $?