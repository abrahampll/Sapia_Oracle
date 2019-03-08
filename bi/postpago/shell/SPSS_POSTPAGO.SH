##################################################################################
# NOMBRE		: SPSS_POSTPAGO_0.SH                           
# OBJETIVO		: SHELL ORQUESTADOR
# TIPO			: SHELL		
# FRECUENCIA	: MENSUAL   									    
# 									                            	
# VERSION		DESARROLLADOR		PROVEEDOR		FECHA		DETALLE	
#---------------------------------------------------------------------------------
# 1				MIGUEL QUISPE		SAPIA			17/07/2018  DESARROLLO
#---------------------------------------------------------------------------------
V_FECHA=$1
echo 'Se esta ejecutando SPSS_POSTPAGO_0.SH'
./SPSS_POSTPAGO_0.SH $V_FECHA
res=$?
if [ $res -eq 0 ]; then
echo 'Ejecucion exitosa de SPSS_POSTPAGO_0.SH'
echo 'Se esta ejecutando SPSS_POSTPAGO_1.SH'
./SPSS_POSTPAGO_1.SH $V_FECHA
res1=$?
if [ $res1 -eq 0 ]; then
echo 'Ejecucion exitosa de SPSS_POSTPAGO_1.SH'
echo 'Se esta ejecutando SPSS_POSTPAGO_2.SH'
./SPSS_POSTPAGO_2.SH $V_FECHA
res2=$?
if [ $res2 -eq 0 ]; then
echo 'Ejecucion exitosa de SPSS_POSTPAGO_2.SH'
echo 'Se esta ejecutando SPSS_POSTPAGO_3.SH'
./SPSS_POSTPAGO_3.SH $V_FECHA
res3=$?
if [ $res3 -eq 0 ]; then
echo 'Ejecucion exitosa de SPSS_POSTPAGO_3.SH'
echo 'Se esta ejecutando SPSS_POSTPAGO_4.SH'
./SPSS_POSTPAGO_4.SH $V_FECHA
res4=$?
if [ $res4 -eq 0 ]; then
echo 'Ejecucion exitosa de SPSS_POSTPAGO_4.SH'
echo 'Se esta ejecutando SPSS_POSTPAGO_5.SH'
./SPSS_POSTPAGO_5.SH $V_FECHA
res6=$?
if [ $res6 -eq 0 ]; then
echo 'Ejecucion exitosa de SPSS_POSTPAGO_5.SH'
echo 'Se esta ejecutando SPSS_POSTPAGO_6.SH'
./SPSS_POSTPAGO_6.SH $V_FECHA
res7=$?
if [ $res7 -eq 0 ]; then
echo 'Ejecucion exitosa de SPSS_POSTPAGO_6.SH'
echo 'Se esta ejecutando SPSS_POSTPAGO_7.SH'
./SPSS_POSTPAGO_7.SH $V_FECHA
exit $?
else 
exit $?
fi
else 
exit $?
fi
else 
exit $?
fi
else 
exit $?
fi
else 
exit $?
fi
else 
exit $?
fi
else 
exit $?
fi