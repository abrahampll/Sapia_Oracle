#*************************************************************
#Programa      :  SH008_VENCIMIENTO.sh
#Autor         :  Roxana Chero
#Descripcion   :  Proceso encargado de dar de baja los puntos que ya hayan vencido	   	       
#FECHA_HORA    :  08/04/2013
#*************************************************************
#clear

# Inicializacion de Variables
. /home/usrclaroclub/CLAROCLUB/Interno/TFI/Bin/.varset
. /home/usrclaroclub/CLAROCLUB/Interno/TFI/Bin/.passet
. /home/usrclaroclub/CLAROCLUB/Interno/TFI/Bin/.mailset


cd ${DIRSHELL}

#-----------------------------------------------------------------
#	FUNCION PARA MANEJO DEL LOG
#-----------------------------------------------------------------
pMessage () {   
   LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
   echo "($LOGDATE) $*" 
   echo "($LOGDATE) $*"  >> $DIRLOG/$FILELOG
} # pMessage	

FECHA=`date +%Y%m%d`

FECHA_HORA=`date +%Y%m%d%H%M%S`
HORA=`date +%H%M%S`

# ip de TIM-FTP1
HOST=`hostname`
IP_SERV=`cat /etc/hosts | grep -v '#' | grep ${HOST} | awk '{print $1}'`
#usuario
USER_SERV=`whoami`
SHELL=SH008_VENCIMIENTO.sh
FILELOG=SH008_VENCIMIENTO_${FECHA_HORA}.log

demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "************************************* " 
pMessage "Iniciando proceso                     " 
pMessage "Fecha y Hora  : ${FECHA_HORA}         " 
pMessage "Usuario :  ${USER_SERV}               " 
pMessage "Shell : ${SHELL}                      " 
pMessage "Ip : ${IP_SERV}                       " 
pMessage "*************************************"$'\n' 

pMessage "Se ejecuta el SP PKG_CC_PTOSTFI.ADMPSI_TFIVENCPTO para el proceso de Vencimiento de Puntos"	

#sh SH061_EJECUTASP.sh ${DIRLOG}/${FILELOG}

sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> ${DIRLOG}/${FILELOG}
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

K_CODERROR  NUMBER;
K_DESCERROR  VARCHAR2(100);

BEGIN

$PCLUB_OW.PKG_CC_PTOSTFI.ADMPSI_TFIVENCPTO(K_CODERROR,K_DESCERROR);

dbms_output.put_line('Codigo: '||K_CODERROR||' - Mensaje: '||K_DESCERROR);		

EXCEPTION
    when OTHERS then
      dbms_output.put_line(' '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
 
END;
/

EXIT
EOP

pMessage "Se valida la existencia de errores durante la ejecución"
VALIDAT_CTL=`grep 'ORA-' ${DIRLOG}/${FILELOG} | wc -l`
if [ $VALIDAT_CTL -ne 0 ]
	then
	pMessage `date +"%Y-%m-%d %H:%M:%S"` "en la ejecucion del procedure . Contacte al administrador."$'\n' 
    echo  $'\n'"al ejecutar el procedure de Vencimiento de Puntos para los Clientes TFI Prepago "| mail -s "CLARO CLUB TFI PREPAGO: VIGENCIA DE PUNTOS . el procesar datos" $IT_MAIL
fi

pMessage "Termino proceso"
pMessage "********** FINALIZANDO PROCESO ********** " 
pMessage "Fin de proceso "
pMessage "************************************" 
pMessage "Ruta del Archivo log : ${DIRLOG}/${FILELOG}" 
pMessage "" 
			
exit

