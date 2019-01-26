#!/bin/sh -x
#*************************************************************
#Programa      :  SH060_PUNTOSCC
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
SHELL=SH060_PUNTOSCC.sh
FILELOG=SH060_PUNTOSCC_${FECHA_HORA}.log

demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "************************************* " 
pMessage "Iniciando proceso                     " 
pMessage "Fecha y Hora  : ${FECHA_HORA}         " 
pMessage "Usuario :  ${USER_SERV}               " 
pMessage "Shell : ${SHELL}                      " 
pMessage "Ip : ${IP_SERV}                       " 
pMessage "*************************************"$'\n' 

pMessage "Se ejecuta el SP PKG_CC_PREPAGO.ADMPSI_PREVENCPTO para el proceso de Vencimiento de Puntos"	

#sh SH061_EJECUTASP.sh ${DIRLOG}/${FILELOG}


VALIDAT_CTL=`grep 'ORA-' ${DIRLOG}/${FILELOG} | wc -l`
if [ $VALIDAT_CTL -ne 0 ]
	then
	pMessage `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del procedure . Contacte al administrador."$'\n' 
    echo  $'\n'"Error al ejecutar el procedure CLAROCLUB "| mail -s "CLARO CLUB PREPAGO: VIGENCIA DE PUNTOS – error el procesar datos" $IT_OPERADOR
fi


pMessage "Se ejecuta el Sp PKG_CC_PREPAGO.ADMPSI_PREPROMOCION para el proceso de Puntos por Promocion"	
#sh SH066_EJECUTA_SP.sh ${DIRLOG}/${FILELOG}

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

K_FECHA  DATE;
K_CODERROR  NUMBER; 
K_DESCERROR  VARCHAR2(100);
K_NUMREGTOT  NUMBER;
K_NUMREGPRO  NUMBER;
K_NUMREGERR  NUMBER;

BEGIN

SELECT sysdate INTO K_FECHA FROM DUAL;
  
$PCLUB_OW.PKG_CC_PREPAGO.ADMPSI_PREPROMOCION(K_FECHA,K_CODERROR,K_DESCERROR,K_NUMREGTOT,K_NUMREGPRO,K_NUMREGERR);

dbms_output.put_line('Fecha: '||to_char(K_FECHA,'dd/mm/yyyy'));	
dbms_output.put_line('Codigo Error: '||K_CODERROR);	
dbms_output.put_line('Mensaje Error: '||K_DESCERROR);	
dbms_output.put_line('Total de Registros: '||K_NUMREGTOT);	
dbms_output.put_line('Total Procesados: '||K_NUMREGPRO);	
dbms_output.put_line('Total con errores: '||K_NUMREGERR);		

EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
 
END;
/

EXIT
EOP


pMessage "Se valida la existencia de errores durante la ejecución"
VALIDAT_CTL=`grep 'ORA-' ${DIRLOG}/${FILELOG} | wc -l`
if [ $VALIDAT_CTL -ne 0 ]
	then
	pMessage `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del procedure . Contacte al administrador."$'\n' 
    echo  $'\n'"Error al ejecutar el procedure CLAROCLUB "| mail -s "CLARO CLUB PREPAGO: PUNTOS POR PROMOCION – error el procesar datos" $IT_OPERADOR

fi


pMessage "Termino proceso"
pMessage "********** FINALIZANDO PROCESO ********** " 
pMessage "Fin de proceso "
pMessage "************************************" 
pMessage "Ruta del Archivo log : ${DIRLOG}/${FILELOG}" 
pMessage "" 
			
exit