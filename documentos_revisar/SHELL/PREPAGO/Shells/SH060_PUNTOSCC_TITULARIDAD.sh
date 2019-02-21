#!/bin/sh -x
#*************************************************************
#Programa      :  SH060_PUNTOSCC_TITULARIDAD
#Autor         :  Jorge Andres Thomburne Vidales 
#Descripcion   :  Proceso encargado de asignacion de puntos segun sea el caso descrito
#		       	   
#		       
#FECHA_HORA    :  10/01/2010
#.
#*************************************************************
#clear

# Inicializacion de Variables
HOME_GAT=/home/usrclaroclub/CLAROCLUB/Interno/Prepago
. $HOME_GAT/Bin/.varset
. $HOME_GAT/Bin/.mailset
. $HOME_GAT/Bin/.passet

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
SHELL=SH060_PUNTOSCC_TITULARIDAD.sh
FILELOG=SH060_PUNTOSCC_TITULARIDAD_${FECHA_HORA}.log

demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "************************************* " 
pMessage "Iniciando proceso                     " 
pMessage "Fecha y Hora  : ${FECHA_HORA}         " 
pMessage "Usuario :  ${USER_SERV}               " 
pMessage "Shell : ${SHELL}                      " 
pMessage "Ip : ${IP_SERV}                       " 
pMessage "*************************************"$'\n' 


pMessage "Se ejecuta el SP PKG_CC_PREPAGO.ADMPSI_PRECMBTIT para el proceso de Cambio de Titular"	
#sh SH062_EJECUTA_SP.sh ${DIRLOG}/${FILELOG}

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

K_FEC_PRO  DATE;
K_CODERROR  NUMBER; 
K_DESCERROR  VARCHAR2(100);
K_TOT_REG  NUMBER;
K_TOT_PRO  NUMBER;
K_TOT_ERR  NUMBER;

BEGIN


SELECT sysdate - 1 INTO K_FEC_PRO FROM DUAL;

$PCLUB_OW.PKG_CC_PREPAGO.ADMPSI_PRECMBTIT(K_FEC_PRO,K_CODERROR,K_DESCERROR,K_TOT_REG,K_TOT_PRO,K_TOT_ERR);

--dbms_output.put_line('Fecha sIN : '|| to_char(K_FEC_PRO));	
dbms_output.put_line('Fecha: '||to_char(K_FEC_PRO,'dd/mm/yyyy'));	
dbms_output.put_line('Codigo Error: '||K_CODERROR);	
dbms_output.put_line('Mensaje Error: '||K_DESCERROR);	
dbms_output.put_line('Total de Registros: '||K_TOT_REG);	
dbms_output.put_line('Total Procesados: '||K_TOT_PRO);	
dbms_output.put_line('Total con errores: '||K_TOT_ERR);		

EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
 
END;
/

EXIT
EOP

pMessage "Se valida la existencia durante la ejecución"
VALIDAT_CTL=`grep 'ORA-' ${DIRLOG}/${FILELOG} | wc -l`
if [ $VALIDAT_CTL -ne 0 ]
	then
	pMessage `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del procedure . Contacte al administrador."$'\n' 
    echo  $'\n'"Error al ejecutar el procedure CLAROCLUB "| mail -s "CLARO CLUB PREPAGO: CAMBIO DE TITULAR – error el procesar datos" $IT_OPERADOR
	
fi


pMessage "Termino proceso"
pMessage "********** FINALIZANDO PROCESO ********** " 
pMessage "Fin de proceso "
pMessage "************************************" 
pMessage "Ruta del Archivo log : ${DIRLOG}/${FILELOG}" 
pMessage "" 
			
exit