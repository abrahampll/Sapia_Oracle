##################################################################################
# NOMBRE		: SPSS_POSTPAGO_3.SH                           
# OBJETIVO		: DROPEAR TEMPORALES EN REPTDM
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

sqlplus -s ${REPTDMID}/${REPTDMPS}@${REPTDMBD} @${DIR_POST_SQL}/28_DROP_TEMPORAL_REPTDM.sql $V_FECHA > ${DIR_POST_LOG}/28_DROP_TEMPORAL_REPTDM.LOG
exit $?