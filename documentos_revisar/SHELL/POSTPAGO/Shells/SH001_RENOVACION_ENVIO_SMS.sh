#bin/sh
#***************************************************************************
#DESCRIPCION         : Proceso que ...					                   *	
#EJECUCION           : Control-M                             			   *
#AUTOR               : Jesus Valdiviezo                		               *
#FECHA               : 26/04/2012                            			   *
#VERSION             : 1.0                                   			   *
#***************************************************************************

clear
# Inicializacion de Variables
RUTA_HOME=/home/usrclaroclub/CLAROCLUB/Interno/Postpago
. $RUTA_HOME/Bin/.varset
. $RUTA_HOME/Bin/.passet
. $RUTA_HOME/Bin/.mailset

cd ${DIR_POST_SHELL}
#-----------------------------------------------------------------
#	FUNCION PARA MANEJO DEL LOG
#-----------------------------------------------------------------
pMessage () {   
   LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
   echo "($LOGDATE) $*" 
} 	



#Variables
FECHA=`date +%Y%m%d_%H%M%S`
DIRLOG=/home/usrclaroclub/CLAROCLUB/Interno/Postpago/Logs
FILELOG=SH001_RENOVACION_ENVIO_SMS_$FECHA.log
#FILELOG=SH001_RENOVACION_ENVIO_SMS.log

### EJECUCION DEL SP
sqlplus -s $USER_BD/$CLAVE_BD@$SID_BD <<EOP >> ${DIRLOG}/${FILELOG}
WHENEVER SQLERROR EXIT SQL.SQLCODE;
 SET pagesize 0
 SET linesize 400
 SET SPACE 0
 SET feedback off
 SET trimspool on
 SET termout off
 SET heading off
 SET verify off
 SET serveroutput on size 1000000
 SET echo off

DECLARE

V_RESULTADO INTEGER;

BEGIN
SELECT COUNT(*) INTO V_RESULTADO  
  FROM $PCLUB_OW.ADMPT_KARDEX K
 WHERE K.ADMPD_FEC_TRANS >= sysdate AND K.ADMPV_COD_CPTO='22';
 
 dbms_output.put_line('Cantidad de Registros: '||V_RESULTADO);
 
END;

/

EXIT
EOP

cd ${DIRLOG}

if [ `cat $FILELOG | awk '{print $4}' ` -eq 0 ]; then
	##TELEFONOLISTA="993750417"
	##MENSAJE="Bienvenido;a;ClaroClub,;desde;ahora;acumularas;ClaroPuntos;para;que;los;puedas;canjear;muchos;beneficios.;Informate;en;www.claro.com.pe/claroclub"
	pMessage `date +"%Y-%m-%d %H:%M:%S"` "No existen datos."$'\n' 
    echo  $'\n'" No hay Registros Concepto Renovacion  "| mail -s "Proceso RENOVACION DE CONTRATO" $IT_OPERADOR
	##$RUTA_JAVA/java -jar $RUTA_JAR/EnviaSMS.jar $FARCH $IP_AUDIT $USUARIO $MENSAJE  $IDENTIFICADOR $TELEFONOLISTA ${RUTAWS}

/home/usrclaroclub/CLAROCLUB/Interno/Postpago/monitoreo/SMS_ALARMAS/jdom.jar:/home/usrclaroclub/CLAROCLUB/Interno/Postpago/monitoreo/SMS_ALARMAS/mas4.0.7_5.jar:/home/usrclaroclub/CLAROCLUB/Interno/Postpago/monitoreo/SMS_ALARMAS/xercesImpl.jar EnviaMensaje 980707946 987766020 989119538 "Encuesta de Satisfaccion - No hay mensajes para enviar"
fi