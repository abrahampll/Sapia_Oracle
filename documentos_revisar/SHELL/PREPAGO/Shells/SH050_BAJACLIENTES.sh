#!/bin/sh -x
#*************************************************************
#Programa      :  SH050_BAJACLIENTES
#Autor         :  Jorge Andres Thomburne Vidales 
#Descripcion   :  Elimina puntos de clientes dados de baja
#		       	  si no cuentan con otra linea activa
#		       
#FECHA_HORA    :  11/01/2010
#.
#*************************************************************
clear

# Inicialización de Variables
. /home/usrclaroclub/CLAROCLUB/Interno/Prepago/Bin/.varset
. /home/usrclaroclub/CLAROCLUB/Interno/Prepago/Bin/.passet
. /home/usrclaroclub/CLAROCLUB/Interno/Prepago/Bin/.mailset

cd ${DIRSHELL}

#-----------------------------------------------------------------
#	FUNCION PARA MANEJO DEL LOG
#-----------------------------------------------------------------
pMessage () {   
   LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
   echo "($LOGDATE) $*" 
   echo "($LOGDATE) $*"  >> $DIRLOG/$LOGFILE
} # pMessage	

FECHA=`date +%d%m%Y`
FECHA_HORA=`date +%Y%m%d%H%M%S`
HORA=`date +%H%M%S`

# ip de TIM-FTP1
HOST=`hostname`
IP_SERV=`cat /etc/hosts | grep -v '#' | grep ${HOST} | awk '{print $1}'`
#usuario
USER_SERV=`whoami`
SHELL=SH050_BAJACLIENTES.sh
USER_PROC="USRBAJACLI"
PREF_SHELL="SH050_"
NOMB_SHELL="BAJACLIENTES"

#VARIABLES ARCHIVOS
DIRD_ARCHDOCU=$DIRDOCUMENTOS
DIRD_ARCHPROC=$DIRPROCESADO
DATAFILE=CHURNCC_*.TXT
LOGFILE=${PREF_SHELL}${NOMB_SHELL}_$FECHA_HORA.log
CONTROL=CTL050_${NOMB_SHELL}.ctl
CTLLOG=SH050_CTL_BAJACLIENTES_${FECHA_HORA}.log
CTLBAD=${PREF_SHELL}${NOMB_SHELL}_$FECHA_HORA.bad

LISTA=lista50.tmp

demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "************************************* " 
pMessage "Iniciando proceso                     " 
pMessage "Fecha y Hora : ${FECHA_HORA}          " 
pMessage "Usuario :  ${USER_SERV}               " 
pMessage "Shell : ${SHELL}                      " 
pMessage "Ip : ${IP_SERV}                       " 
pMessage "*************************************"$'\n' 

pMessage "Busca archivos a procesar según la estructura predefinida"
cd ${DIRD_ARCHDOCU}
ls ${DATAFILE} > ${DIRLOG}/${LISTA}

FILEBODY=`wc -l ${DIRLOG}/${LISTA} | awk '{print $1}'`
if [ "$FILEBODY" = "0" ] ; then
	pMessage " Error: No se encontraron archivos a procesar"
	pMessage "${DIRD_ARCHDOCU}/CHURNCC_MMYYYY.TXT"
	echo $'\n'"No se encontraron archivos a procesar : ${DIRD_ARCHDOCU}/CHURNCC_MMYYYY.TXT"| mail -s "BAJA DE CLIENTES CLAROCLUB PREPAGO – Se encontraron errores" $IT_OPERADOR
	pMessage "Termino proceso"
	pMessage "************************************"
	pMessage " FINALIZANDO PROCESO..............."
	pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso "
	pMessage "************************************"
	echo "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso"$'\n'
	echo $'\n'
	echo "Ruta del Archivo log : " $DIRLOG/$LOGFILE
	echo $'\n'
	exit
fi

while read FIELD001
do

	dos2unix ${DIRD_ARCHDOCU}/${FIELD001}

	TMP=${DIRLOG}/TEMPDATA.tmp
	echo "" >> ${DIRD_ARCHDOCU}/${FIELD001}
	cat ${DIRD_ARCHDOCU}/${FIELD001} | sed '/^$/d' > $TMP
	cat $TMP > ${DIRD_ARCHDOCU}/${FIELD001}

	rm -f $TMP

	cd ${DIRSHELL}
	pMessage "Se importa la data del archivo a su respectiva tabla"	
	
	sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$DIRCTL/$CONTROL data=${DIRD_ARCHDOCU}/$FIELD001 bad=$DIRLOG/$CTLBAD log=$DIRLOG/$CTLLOG bindsize=200000 readsize=200000 rows=1000 skip=0
	
	mv ${DIRD_ARCHDOCU}/${FIELD001} ${DIRD_ARCHPROC}/${FIELD001}

done < ${DIRLOG}/${LISTA}

rm -f ${DIRLOG}/${LISTA}

pMessage "Se ejecuta el procedimiento"

sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> ${DIRLOG}/${LOGFILE}
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

v_tmp			varchar2(10);
v_FECHA  		DATE;
v_CODERROR 		NUMBER;
v_DESCERROR  	VARCHAR2(200); 
v_NUMREGTOT  	NUMBER; 
v_NUMREGPRO  	NUMBER; 
v_NUMREGERR  	NUMBER;

BEGIN

v_tmp:=to_char(sysdate,'ddmmyyyy');
v_FECHA:=to_date(v_tmp,'ddmmyyyy');

$PCLUB_OW.PKG_CC_PREPAGO.ADMPSI_PREBAJACL(v_FECHA, '$USER_PROC', v_CODERROR, v_DESCERROR, v_NUMREGTOT, v_NUMREGPRO, v_NUMREGERR);
											 
dbms_output.put_line('Indicador: '||v_CODERROR);
dbms_output.put_line('Descripcion: '||v_DESCERROR);
dbms_output.put_line('Total Registros: '||v_NUMREGTOT);
dbms_output.put_line('Total Procesados: '||v_NUMREGPRO);
dbms_output.put_line('Total Errores: '||v_NUMREGERR);
 
EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
 
END;
/

EXIT
EOP

pMessage "Se valida la ejecución del procedimiento"	
VALIDAT_CTL1=`grep 'ORA-' ${DIRLOG}/${LOGFILE} | wc -l`
if [ $VALIDAT_CTL1 -ne 0 ]
	then
	pMessage `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del procedure de BAJA DE CLIENTES CLAROCLUB : PREPAGO ${PCLUB_OW}.PKG_CC_PREPAGO.ADMPSI_PREBAJACL. Contacte al administrador."$'\n' 
	echo  $'\n'"Error al ejecutar el procedure de BAJA DE CLIENTES CLAROCLUB PREPAGO : ${PCLUB_OW}.PKG_CC_PREPAGO.ADMPSI_PREBAJACL"| mail -s "BAJA DE CLIENTES CLAROCLUB PREPAGO – Se encontraron errores" $IT_OPERADOR
	pMessage "Termino proceso"
	pMessage "************************************" 
	pMessage " FINALIZANDO PROCESO..............."
	pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso " 
	pMessage "************************************" 
	echo "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso"$'\n'
	echo $'\n'
	echo "Ruta del Archivo log : " $DIRLOG/$LOGFILE
	echo $'\n'
	exit	
fi

pMessage "Termino proceso"
pMessage "********** FINALIZANDO PROCESO ********** " 
pMessage "Fin de proceso "
pMessage "************************************" 
pMessage "Ruta del Archivo log : ${DIRLOG}/${LOGFILE}" 
pMessage "" 
pMessage "" 

exit