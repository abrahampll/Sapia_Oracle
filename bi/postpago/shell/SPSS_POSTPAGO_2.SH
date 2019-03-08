##################################################################################
# NOMBRE		: SPSS_POSTPAGO_2.SH                           
# OBJETIVO		: CREACION DE TEMPORALES EN DWO
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

sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/1_VF2_002_VF2_008.sql $V_FECHA > ${DIR_POST_LOG}/1_VF2_002_VF2_008.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/2_vf2_015.sql $V_FECHA > ${DIR_POST_LOG}/2_vf2_015.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/3_VF2_030.sql $V_FECHA > ${DIR_POST_LOG}/3_VF2_030.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/4_vf2_035.sql $V_FECHA > ${DIR_POST_LOG}/4_vf2_035.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/5_VF2_047.sql $V_FECHA > ${DIR_POST_LOG}/5_VF2_047.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/6_VF2_053.sql $V_FECHA > ${DIR_POST_LOG}/6_VF2_053.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/7_VF2_061.sql $V_FECHA > ${DIR_POST_LOG}/7_VF2_061.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/8_VF2_144.sql $V_FECHA > ${DIR_POST_LOG}/8_VF2_144.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/9_VF2_152.sql $V_FECHA > ${DIR_POST_LOG}/9_VF2_152.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/10_vf2_155.sql $V_FECHA > ${DIR_POST_LOG}/10_vf2_155.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/11_vf2_160.sql $V_FECHA > ${DIR_POST_LOG}/11_vf2_160.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/12_vf2_183.sql $V_FECHA > ${DIR_POST_LOG}/12_vf2_183.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/13_vf2_206.sql $V_FECHA > ${DIR_POST_LOG}/13_vf2_206.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/14_VF2_165.sql $V_FECHA > ${DIR_POST_LOG}/14_VF2_165.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/15_vf2_166_167.sql $V_FECHA > ${DIR_POST_LOG}/15_vf2_166_167.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/16_VF2_175.sql $V_FECHA > ${DIR_POST_LOG}/16_VF2_175.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/17_VF2_216.sql $V_FECHA > ${DIR_POST_LOG}/17_VF2_216.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/18_VF2_224.sql $V_FECHA > ${DIR_POST_LOG}/18_VF2_224.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/19_VF2_228.sql $V_FECHA > ${DIR_POST_LOG}/19_VF2_228.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/20_VF2_236.sql $V_FECHA > ${DIR_POST_LOG}/20_VF2_236.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/21_VF2_244.sql $V_FECHA > ${DIR_POST_LOG}/21_VF2_244.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/22_VF2_285.sql $V_FECHA > ${DIR_POST_LOG}/22_VF2_285.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/23_VF2_340.sql $V_FECHA > ${DIR_POST_LOG}/23_VF2_340.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/24_VF2_348.sql $V_FECHA > ${DIR_POST_LOG}/24_VF2_348.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/26_VF2_436.sql $V_FECHA > ${DIR_POST_LOG}/26_VF2_436.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/27_VF2_458.sql $V_FECHA > ${DIR_POST_LOG}/27_VF2_458.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/1_VF2_007.sql $V_FECHA > ${DIR_POST_LOG}/1_VF2_007.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/2_VF2_009.sql $V_FECHA > ${DIR_POST_LOG}/2_VF2_009.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/3_VF2_048.sql $V_FECHA > ${DIR_POST_LOG}/3_VF2_048.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/4_VF2_053.sql $V_FECHA > ${DIR_POST_LOG}/4_VF2_053.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/5_VF2_054.sql $V_FECHA > ${DIR_POST_LOG}/5_VF2_054.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/6_VF2_061.sql $V_FECHA > ${DIR_POST_LOG}/6_VF2_061.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/7_VF2_062.sql $V_FECHA > ${DIR_POST_LOG}/7_VF2_062.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/8_VF2_136.sql $V_FECHA > ${DIR_POST_LOG}/8_VF2_136.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/9_VF2_139.sql $V_FECHA > ${DIR_POST_LOG}/9_VF2_139.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/10_VF2_142.sql $V_FECHA > ${DIR_POST_LOG}/10_VF2_142.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/11_VF2_147.sql $V_FECHA > ${DIR_POST_LOG}/11_VF2_147.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/12_VF2_381.sql $V_FECHA > ${DIR_POST_LOG}/12_VF2_381.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/14_VF2_186.sql $V_FECHA > ${DIR_POST_LOG}/14_VF2_186.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/16_VF2_214.sql $V_FECHA > ${DIR_POST_LOG}/16_VF2_214.LOG
sqlplus -s ${DWOID}/${DWOPS}@${DWOBD} @${DIR_POST_SQL}/17_VF2_371.sql $V_FECHA > ${DIR_POST_LOG}/17_VF2_371.LOG
exit $?