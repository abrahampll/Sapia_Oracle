#!/bin/sh -x
#*************************************************************
#Programa      :  SH028_REPCATCLI
#Autor         :  Jorge Andres Thomburne Vidales
#Descripcion   :      
#		       	  
#		       
#FECHA_HORA    :  21/10/2010
#.
#*************************************************************
#clear

# Inicializacion de Variables
HOME_GAT=/home/usrclaroclub/CLAROCLUB/Interno/Postpago
. $HOME_GAT/Bin/.varset
. $HOME_GAT/Bin/.mailset
. $HOME_GAT/Bin/.passet
#. $HOME_GAT/Shells/autlib.sh

cd ${DIR_POST_SHELL}

#-----------------------------------------------------------------
#	FUNCION PARA MANEJO DEL LOG
#-----------------------------------------------------------------
pMessage () {   
   LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
   echo "($LOGDATE) $*" 
   echo "($LOGDATE) $*"  >> $DIRLOGPOST/$FILELOG
} # pMessage	

FECHA=`date +%Y%m%d`

FECHA_HORA=`date +%Y%m%d%H%M%S`
HORA=`date +%H%M%S`

# ip de TIM-FTP1
HOST=`hostname`
IP_SERV=`cat /etc/hosts | grep -v '#' | grep ${HOST} | awk '{print $1}'`
#usuario
USER_SERV=`whoami`
SHELL=SH028_REPCATCLI.sh

FILELOG=SH028_REPCATCLI_${FECHA_HORA}.log

demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "************************************* " 
pMessage "Iniciando proceso                     " 
pMessage "Fecha y Hora  : ${FECHA_HORA}                        " 
pMessage "Usuario :  ${USER_SERV}            " 
pMessage "Shell : ${SHELL}                      " 
pMessage "Ip : ${IP_SERV}                    " 
pMessage "*************************************"$'\n' 

pMessage "Se ejecuta el procedimiento PKG_CC_PROCACUMULA.ADMPSS_CATEGCLI"		
#sh SH028_REPORTE.sh ${DIRLOGPOST}/${FILELOG}

sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> ${DIRLOGPOST}/${FILELOG}
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

ADMPC_COD_ERROR	varchar2(100);
ADMPV_MSJE_ERROR	varchar2(100);

BEGIN

$PCLUB_OW.PKG_CC_PROCACUMULA.ADMPSS_CATEGCLI(ADMPC_COD_ERROR,ADMPV_MSJE_ERROR);

dbms_output.put_line('CODIGO : '||ADMPC_COD_ERROR);	
dbms_output.put_line('MENSAJE : '||ADMPV_MSJE_ERROR);	

EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
 
END;
/

EXIT
EOP

VALIDAT_CTL=`grep 'ORA-' ${DIRLOGPOST}/${FILELOG} | wc -l`
if [ $VALIDAT_CTL -ne 0 ]
	then
	pMessage `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del procedure . Contacte al administrador."$'\n' 
    echo  $'\n'"Error al ejecutar el procedure"| mail -s "CATEGORIZACION DEL CLIENTE – Se encontraron errores" $IT_OPERADOR
	pMessage "Termino proceso"
	pMessage "************************************" 
	pMessage " FINALIZANDO PROCESO..............."
	pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso " 
	pMessage "************************************" 
	echo "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso"$'\n'
	echo $'\n'
	echo "Ruta del Archivo log : " $DIRLOGPOST/$FILELOG
	echo $'\n'
	 exit	
fi

pMessage "Ejecución de SP fue satisfactorio"

pMessage "Termino proceso"
pMessage "********** FINALIZANDO PROCESO ********** " 
pMessage "Fin de proceso "
pMessage "************************************" 
pMessage "Ruta del Archivo log : ${DIRLOGPOST}/${FILELOG}" 
			
exit