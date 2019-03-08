##################################################################################
# NOMBRE		: SPSS_POSTPAGO_0.SH                           
# OBJETIVO		: POBLAR MAESTRA POSTPAGO EN DWO
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

sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/dwh_EXT_DWO_Bajas_Masivo.sql $V_FECHA > ${DIR_POST_LOG}/dwh_EXT_DWO_Bajas_Masivo.log
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/dwh_EXT_DWO_Bajas_Corp.sql $V_FECHA > ${DIR_POST_LOG}/dwh_EXT_DWO_Bajas_Corp.log
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/0_VF2_MAESTRA_POSTPAGO.sql $V_FECHA > ${DIR_POST_LOG}/0_VF2_MAESTRA_POSTPAGO.log
exit $?