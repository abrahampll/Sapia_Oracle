#!/bin/sh -x
#*************************************************************
#Programa      :  SH027_REPSALPUN
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
. $HOME_GAT/Bin/.passet
. $HOME_GAT/Bin/.mailset
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

FECHA=`date +%d%m%Y`

FECHA_HORA=`date +%Y%m%d%H%M%S`
HORA=`date +%H%M%S`

# ip de TIM-FTP1
HOST=`hostname`
IP_SERV=`cat /etc/hosts | grep -v '#' | grep ${HOST} | awk '{print $1}'`
#usuario
USER_SERV=`whoami`
SHELL=SH027_REPSALPUN.sh

FILEERR=CLAROCLUB_${FECHA}.TXT
FILELOG=SH027_REPSALPUN_${FECHA_HORA}.log
FILETEMP=SH027_${FECHA_HORA}_TEMP.TMP

demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "************************************* " 
pMessage "Iniciando proceso                     " 
pMessage "Fecha y Hora  : ${FECHA_HORA}                        " 
pMessage "Usuario :  ${USER_SERV}            " 
pMessage "Shell : ${SHELL}                      " 
pMessage "Ip : ${IP_SERV}                    " 
pMessage "*************************************"$'\n' 

pMessage "Se ejecuta el procedimiento PKG_CC_PROCACUMULA.ADMPSS_PTOFACTU"
	
#sh SH027_REPORTE.sh ${DIRFACTUPOST}/${FILETEMP}

sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP > ${DIRFACTUPOST}/${FILETEMP}
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

TYPE CurClaro IS REF CURSOR;
C_CURSOR CurClaro;

K_CODERROR  	NUMBER;
K_DESCERROR  	VARCHAR2(100);

ADMPN_CUSTOMER_ID		VARCHAR2(50);
ADMPN_SALD_CUENTA		NUMBER;
CC_FACT					VARCHAR(20);

BEGIN

dbms_output.enable(NULL);

$PCLUB_OW.PKG_CC_PROCACUMULA.ADMPSS_PTOFACTU(K_CODERROR, K_DESCERROR, C_CURSOR);

LOOP
FETCH C_CURSOR INTO ADMPN_CUSTOMER_ID, ADMPN_SALD_CUENTA, CC_FACT;

EXIT WHEN C_CURSOR%NOTFOUND;

dbms_output.put_line('A-AERT-'||ADMPN_CUSTOMER_ID||'|'||ADMPN_SALD_CUENTA||'|'||CC_FACT);		

END LOOP;

CLOSE C_CURSOR;

EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
 
END;
/

EXIT
EOP

VALIDAT_CTL=`grep 'ORA-' ${DIRFACTUPOST}/${FILETEMP} | wc -l`
if [ $VALIDAT_CTL -ne 0 ]
	then
	
	cat ${DIRFACTUPOST}/${FILETEMP}  >> ${DIRLOGPOST}/${FILELOG}
	
	rm -f ${DIRFACTUPOST}/${FILETEMP}
	
	pMessage `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del procedure . Contacte al administrador."$'\n' 
    echo  $'\n'"Error al ejecutar el procedure"| mail -s "PUNTOS PARA FACTURACION – Se encontraron errores" $IT_OPERADOR
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

grep 'ERT-' ${DIRFACTUPOST}/${FILETEMP}| awk 'BEGIN{FS="-AERT-"} {print $2}' >> ${DIRFACTUPOST}/${FILEERR}	

rm -f ${DIRFACTUPOST}/${FILETEMP}

pMessage "Ejecución de SP fue satisfactorio"

pMessage "Termino proceso"
pMessage "********** FINALIZANDO PROCESO ********** " 
pMessage "Fin de proceso "
pMessage "************************************" 
pMessage "Ruta del Archivo log : ${DIRLOGPOST}/${FILELOG}" 
			
exit