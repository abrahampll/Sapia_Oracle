#!/bin/ksh
#********************************************************************
#* DESCRIPCION: SH012_VENCIMIENTO_PUNTOS       			        *
#* EJECUCION		: Control-M					 			   		*
#* AUTOR			: Diego Valdivieso                                  *
#* FECHA			: 20/04/2016								*
#* VERSION		: 1.0			       							    *
#********************************************************************
clear
#Inicializacion de Variables
. /home/puntoscc/usrclaroclub/Interno/Prepago/Jar/SH_VENCIMIENTO_PUNTOS/BIN/.varset

#Fechas
FECHA_LOG=`date +%Y%m%d`
FECHA_ACTUAL=`date +%Y-%m-%d`
NROPRO=`date +%Y%m%d%H%M%S`

TRANSACCION=TRANSACCION_$NROPRO
LOGNAME="$LOGNAME_SHELL"_$FECHA_LOG.log
HOST=`hostname`
IP_SERV=`cat /etc/hosts | grep -v '#' | grep ${HOST} | awk '{print $1}'`
FILELOG="$DIRLOG"/"$LOGNAME"

# Inicio
echo "***********************************************************************************************************************" >> $FILELOG
echo "${TRANSACCION} - [INFO] - Inicio de proceso - `date +%Y-%m-%d@%H:%M:%S`" >>  $FILELOG
echo "${TRANSACCION} - [INFO] - Inicio de proceso - `date +%Y-%m-%d@%H:%M:%S`"

USR=`whoami`
echo "${TRANSACCION} - [INFO] - Usuario : $USR ">> $FILELOG  
echo "${TRANSACCION} - [INFO] - Num. Ip : $IP_SERV ">> $FILELOG
echo "${TRANSACCION} - [INFO] - Se lanza ejecucion: [VencimientoPuntos]"
echo "${TRANSACCION} - [INFO] - Se lanza ejecucion: [VencimientoPuntos]...$1">> $FILELOG
echo "${RUTA_JAVA}java -jar ${HOME_SHELL}/VencimientoPuntosSHELLClient.jar ${NROPRO} ${RUTAPROPERTIES}"
${RUTA_JAVA}java -jar ${HOME_SHELL}/VencimientoPuntosSHELLClient.jar ${NROPRO} ${RUTAPROPERTIES}>> $FILELOG
echo "${TRANSACCION} - [INFO] - Fin de proceso - `date +%Y-%m-%d@%H:%M:%S` " >>  $FILELOG
echo "${TRANSACCION} - [INFO] - Fin de proceso - `date +%Y-%m-%d@%H:%M:%S` "'\n'
echo "${TRANSACCION} - [INFO] - Ruta del Archivo log :${FILELOG}" '\n'
echo " " >>  $FILELOG

exit