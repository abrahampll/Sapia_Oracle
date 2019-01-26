#*************************************************************
#Programa      :  SH001_CARGA_CLIENTE_MICLARO_SMS.sh
#Autor         :  Deysi Galvez Medrano
#Descripcion   :  Envio 
#FECHA_HORA    :  23/11/2011
#*************************************************************
clear
# Inicializacion de Variables
HOME=/home/usrclaroclub/CLAROCLUB/Interno/Prepago
. $HOME/Bin/.varset
. $HOME/Bin/.mailset
. $HOME/Bin/.passet 

cd ${DIRSHELL}
#-----------------------------------------------------------------
#	FUNCION PARA MANEJO DEL LOG
#-----------------------------------------------------------------
pMessage () {   
   LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
   echo "($LOGDATE) $*" 
   echo "($LOGDATE) $*"  >> $DIRLOG/$LOGFILE
}
NPROCESO=$$
FECHA=`date +%d%m%Y`
FECHA_HORA=`date +%Y%m%d%H%M%S`
HORA=`date +%H%M%S`
HOST=`hostname`
IP_SERV=`cat /etc/hosts | grep -v '#' | grep ${HOST} | awk '{print $1}'`
USER_SERV=`whoami`
SHELL=SH001_CARGA_CLIENTE_MICLARO.sh
LOGFILE=LOG_CARGA_MICLARO_SMS_${FECHA_HORA}.log
ARCH_CUR=CURSOR_MICLARO_$FECHA.tmp 
ARCH_SMS=$DIRSALIDA/$ARCH_CUR
VAR_COUNT=0
contador=1

demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "************************************* " 
pMessage "Iniciando proceso                     " 
pMessage "Fecha y Hora : ${FECHA_HORA}          " 
pMessage "Usuario :  ${USER_SERV}               " 
pMessage "Shell : ${SHELL}                      " 
pMessage "Ip : ${IP_SERV}                       " 
pMessage "*************************************"$'\n' 


pMessage "Se ejecuta el SP que obtiene la cantidad de números a los que se le va a enviar SMS"

sqlplus -s ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> ${ARCH_SMS}
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

V_COUNT			NUMBER;
V_CODERROR 		NUMBER;
v_DESCERROR  	VARCHAR2(200); 

BEGIN

dbms_output.enable(NULL);

$PCLUB_OW.PKG_CC_ENVIO_SMS.ADMPSS_COUNT_SMSMICLARO(V_COUNT, v_CODERROR, v_DESCERROR);
 
dbms_output.put_line(V_COUNT);  
   
EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
 
END;
/

EXIT
EOP

pMessage "Se valida la ejecución del SP"	
VALIDAT_ORA1=`grep 'ORA-' ${ARCH_SMS} | wc -l`
VALIDAT_SP1=`grep 'SP2-' ${ARCH_SMS} | wc -l | sed 's/ //g'`

if [ ${VALIDAT_ORA1} -ne 0 ] || [ ${VALIDAT_SP1} -ne 0 ] ;
	then
	pMessage "Problemas en la ejecucion del SP : $PCLUB_OW.PKG_CC_PREPAGO.ADMPSS_COUNT_SMS, Por favor verificar el siguiente archivo: ${ARCH_SMS}"   
	echo $'\n'"ERROR: PROBLEMAS EN EL REGISTRO DE TIPIFICACIONES.. SEGUN LA RUTINA PL/SQL, POR FAVOR VERIFICAR EL SIGUIENTE ARCHIVO:"$'\n'$'\n'"${ARCH_SMS}"$'\n'" FECHA: ${FECHA}"| mail -s "ERROR EN EL PROCESO DE CANTIDAD NROS PREPAGOS" $IT_OPERADOR
	
	exit
fi	
	
pMessage "Se obtiene la cantidad"

CANT3=`wc -l $ARCH_SMS | awk '{print $1}'`

if [ $CANT3 -eq 0 ] ; then
	pMessage "No se encontraron datos, no existen lineas disponibles"
	exit
else
	dos2unix $ARCH_SMS
fi

pMessage "CANTIDAD DE LINEAS DEL ARCHIVO $ARCH_SMS = ${CANT3}"

while read FIELD04
do

CANTIDAD2=`echo $FIELD04 | sed 's/\\r//g'|awk '{print $1}' `

done < $ARCH_SMS

pMessage "Cantidad de lineas en estado pendiente ${CANTIDAD2}"

while [ $VAR_COUNT -lt $CANTIDAD2 ]
do
pMessage "Vuelta nº ${contador}"
pMessage "Se ejecuta el SP "
FECHATRAMA=`date +%Y%m%d%H%M%S`
ARCH_TP=TR_SH001_$FECHATRAMA.txt
ARCH_WS=Respuesta_MICLARO_$FECHATRAMA.ws
TMP=$DIRSALIDA/$ARCH_TP
RESWS=$DIRSALIDA/$ARCH_WS

sqlplus -s ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> $TMP
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

v_CODERROR 		NUMBER;
v_DESCERROR  	VARCHAR2(200); 
TYPE TY_CURSOR  IS REF CURSOR;
CUR_SMS 		TY_CURSOR;
K_TELEFONO		VARCHAR2(40);
K_PREGUNTA		VARCHAR2(1000);
BEGIN

dbms_output.enable(NULL);

$PCLUB_OW.PKG_CC_ENVIO_SMS.ADMPSS_ENVIOSMS_MICLARO(v_CODERROR, v_DESCERROR, CUR_SMS);
 
LOOP  
  FETCH CUR_SMS INTO  K_TELEFONO,K_PREGUNTA;
  EXIT WHEN CUR_SMS%NOTFOUND;
  
  DBMS_OUTPUT.PUT_LINE(K_TELEFONO || '|' || K_PREGUNTA);
  
END LOOP;
  
 CLOSE CUR_SMS; 
  
EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
 
END;
/

EXIT
EOP

pMessage "Se valida la ejecución del SP"	
VALIDA_EJEC_SP2=`grep 'ORA-' $TMP | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B=`grep 'SP2-' $TMP | wc -l | sed 's/ //g'`    
    
if [ ${VALIDA_EJEC_SP2} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
	
    pMessage "Hora y Fecha: $FECHA_HORA"
    pMessage "Hubo un error durante la ejecución del SP "  
	echo $'\n'"ERROR: PROBLEMAS EN EL ENVIO DE LA ENCUESTA... SEGUN LA RUTINA PL/SQL, POR FAVOR VERIFICAR EL SIGUIENTE ARCHIVO:"$'\n'$'\n'"${TMP}"$'\n'" FECHA: ${FECHA}"| mail -s "ERROR EN EL PROCESO DE ENVIO DE LA ENCUESTA AL WS" $IT_OPERADOR
	
	exit
fi

dos2unix $TMP

CANT2=`wc -l $TMP | awk '{print $1}'`

if [ $CANT2 -eq 0 ] 
then
	pMessage "No se encontraron datos para este grupo"
	pMessage "Culmino el envio de SMS a clientes"
    pMessage "Fin del proceso."
	exit
fi

pMessage "CANTIDAD = ${CANT2}"

while read FIELD01
do

TELEFONO=`echo $FIELD01 | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}' `
MENSAJE=`echo $FIELD01 | awk 'BEGIN{FS="|"} {print $2}' `

pMessage "Invocando al WS"

TELEFONOLISTA=$TELEFONOLISTA","$TELEFONO

done < $TMP

pMessage "Telefonos a enviar: $TELEFONOLISTA"

$RUTA_JAVA/java -jar $RUTA_JAR/EnviaSMS.jar $FECHA $IP_SERV $USER_SERV $MENSAJE $IDENTIFICADOR $TELEFONOLISTA ${RUTAWS}

TELEFONOLISTA=""

rm $TMP

VAR_COUNT=`expr $VAR_COUNT + $CANT2`
contador=`expr $contador + 1`
done

rm -f $ARCH_SMS

pMessage "Culmino el proceso de envio de mensajes para el proceso MICLARO"
pMessage "Fin del proceso"