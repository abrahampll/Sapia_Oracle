#!/bin/sh -x
#*************************************************************
#Programa      :  SH061_MIGRACION_PUNTOSCC.sh
#Autor         :  Jesus Valdiviezo
#Descripcion   :  Proceso encargado de migrar puntos de prepago a postpago segun convenga.
#		       	   
#		       
#FECHA_HORA    :  26/01/2012--Modificado 26/05/2012
#.
#*************************************************************

clear
# Inicializacion de Variables
HOME_CC=/home/usrclaroclub/CLAROCLUB/Interno/Prepago
. $HOME_CC/Bin/.varset
. $HOME_CC/Bin/.mailset
. $HOME_CC/Bin/.passet 

cd ${DIRSHELL}
#-----------------------------------------------------------------
#	FUNCION PARA MANEJO DEL LOG
#-----------------------------------------------------------------
pMessage () {   
   LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
   echo "($LOGDATE) $*"
   echo "($LOGDATE) $*"  >> $DIRLOG/$LOGFILE1
}
pMessage2 () {   
   LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
   echo "($LOGDATE) $*"
   echo "($LOGDATE) $*"  >> $DIRLOG/$LOGFILE2
}


NPROCESO=$$
FECHA=`date +%d%m%Y`
FECHA_HORA=`date +%Y%m%d%H%M%S`
HORA=`date +%H%M%S`
HOST=`hostname`
IP_SERV=`cat /etc/hosts | grep -v '#' | grep ${HOST} | awk '{print $1}'`
USER_SERV=`whoami`
SHELL=SH061_MIGRACION_PUNTOSCC.sh
LOGFILE1=LOG_MIGRACION_POSAPRE_${FECHA_HORA}.log
LOGFILE2=LOG_MIGRACION_PREAPOS_${FECHA_HORA}.log

demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "************************************* " 
pMessage "Iniciando proceso                     " 
pMessage "Fecha y Hora : ${FECHA_HORA}          " 
pMessage "Usuario :  ${USER_SERV}               " 
pMessage "Shell : ${SHELL}                      " 
pMessage "Ip : ${IP_SERV}                       " 
pMessage "*************************************"$'\n' 

pMessage "Se ejecuta el SP PKG_CC_MIGRACION.ADMPSI_PREMIGPOS para el proceso de MIGRACION POSTPAGO a PREPAGO"	

sqlplus -s ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> ${DIRLOG}/${LOGFILE1}
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

k_fecha  		DATE;
k_coderror 		NUMBER;
k_descerror  	VARCHAR2(200); 
k_numregtot  	NUMBER; 
k_numregpro  	NUMBER; 
k_numregerr  	NUMBER;

BEGIN

SELECT TRUNC(SYSDATE-1) INTO k_fecha FROM DUAL;


$PCLUB_OW.PKG_CC_MIGRACION.ADMPSI_PREMIGPOS(k_fecha, k_coderror, k_descerror, k_numregtot, k_numregpro, k_numregerr);
											 
dbms_output.put_line('Indicador: '||k_coderror);
dbms_output.put_line('Descripcion: '||k_descerror);
dbms_output.put_line('Total Registros: '||k_numregtot);
dbms_output.put_line('Total Procesados: '||k_numregpro);
dbms_output.put_line('Total Errores: '||k_numregerr);
 
EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
 
END;
/

EXIT
EOP

pMessage "Se valida si existen errores"

VALIDAT_CTL=`grep 'ORA-' ${DIRLOG}/${LOGFILE1} | wc -l`
if [ $VALIDAT_CTL -ne 0 ]
	then
	pMessage `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del procedure . Contacte al administrador."$'\n' 
    echo  $'\n'"Error al ejecutar el procedure CLAROCLUB "| mail -s "PKG_CC_MIGRACION.ADMPSI_PREMIGPOS – error al migrar puntos Postpago a Prepago" $IT_OPERADOR
	
fi

pMessage "Termino proceso migracion Postpago a Prepago"
pMessage "********** FINALIZANDO PROCESO ********** " 
pMessage "Fin de proceso "
pMessage "************************************" 
pMessage "Ruta del Archivo log POSTPAGO A PREPAGO: ${DIRLOG}/${LOGFILE1}" 
pMessage "" 

pMessage2 "Se ejecuta el SP PKG_CC_MIGRACION.ADMPSI_PREMIGPRE para el proceso de MIGRACION PREPAGO A POSTPAGO"	

sqlplus -s ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> ${DIRLOG}/${LOGFILE2}
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

k_fecha  		DATE;
k_coderror 		NUMBER;
k_descerror  	VARCHAR2(200); 
k_numregtot  	NUMBER; 
k_numregpro  	NUMBER; 
k_numregerr  	NUMBER;

BEGIN

SELECT TRUNC(SYSDATE-1) INTO k_fecha FROM DUAL;


$PCLUB_OW.PKG_CC_MIGRACION.ADMPSI_PREMIGPRE(k_fecha, k_coderror, k_descerror, k_numregtot, k_numregpro, k_numregerr);
											 
dbms_output.put_line('Indicador: '||k_coderror);
dbms_output.put_line('Descripcion: '||k_descerror);
dbms_output.put_line('Total Registros: '||k_numregtot);
dbms_output.put_line('Total Procesados: '||k_numregpro);
dbms_output.put_line('Total Errores: '||k_numregerr);
 
EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
 
END;
/

EXIT
EOP


pMessage2 "Se valida la existencia de errores durante la ejecución"
VALIDAT_CTL=`grep 'ORA-' ${DIRLOG}/${LOGFILE2} | wc -l`
if [ $VALIDAT_CTL -ne 0 ]
	then
	pMessage2 `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del procedure . Contacte al administrador."$'\n' 
    echo  $'\n'"Error al ejecutar el procedure CLAROCLUB "| mail -s "PKG_CC_MIGRACION.ADMPSI_PREMIGPRE – error al migrar puntos Prepago a Postpago" $IT_OPERADOR	
fi

pMessage2 "Termino proceso Prepago Postpago"

pMessage2 "********** FINALIZANDO PROCESO ********** " 
pMessage2 "Fin de proceso "
pMessage2 "************************************" 
pMessage2 "Ruta del Archivo log PREPAGO A POSTPAGO: ${DIRLOG}/${LOGFILE2}" 
pMessage2 "" 
exit
