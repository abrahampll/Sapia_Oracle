##################################################################################
# NOMBRE		: SPSS_POSTPAGO_3.SH                           
# OBJETIVO		: CREACION DE TEMPORALES EN REPTDM
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

f_inicio_variables
V_FECHA=$1
sqlplus -s ${REPTDMID}/${REPTDMPS}@${REPTDMBD} @${DIR_POST_SQL}/1_VF2_017_VF2_018_REPTDM.sql $V_FECHA > ${DIR_POST_LOG}/1_VF2_017_VF2_018_REPTDM.LOG

exit $?