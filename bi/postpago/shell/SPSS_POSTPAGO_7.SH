##################################################################################
# NOMBRE		: SPSS_POSTPAGO_5.SH                           
# OBJETIVO		: CREACION DE TABLONES TEMPORALES DE EMPRESA Y MASIVO
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

sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/29_TABLON_POSTPAGO_EMPRESA.sql $V_FECHA > ${DIR_POST_LOG}/29_TABLON_POSTPAGO_EMPRESA.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/30_TABLON_POSTPAGO_MASIVO.sql $V_FECHA > ${DIR_POST_LOG}/30_TABLON_POSTPAGO_MASIVO.LOG
exit $?