#!/bin/sh -x
#*************************************************************
#Programa      :  SH080_PUNTOS_PREPAGO
#Autor           :   Maomed Alexandr Chocce Cruces
#Descripcion   :  Asignacion de puntos por Recarga 
#FECHA_HORA    :  24/01/2010
#FECHA_MODIF   :  25/04/2013
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
SHELL1=SH081_PUNTOS_RECARGAS.sh
DATAFILE1=RECARGA_*.TXT
LOGFILE=SH080_PUNTOS_PREPAGO_${FECHA_HORA}.log
#LOGFILE=SH081_PUNTOS_RECARGAS_${FECHA_HORA}.log

CONTROL1=CTL081_PUNTOSRECARGA.ctl
CTLLOG1=SH081_CTL_PUNTOSRECARGA_${FECHA_HORA}.log
CTLBAD1=CTL81_BAD.txt
ESTADO1=1

LISTA1=lista81.tmp

#Variable del dia de hoy
DIA=`date +%d`
DIA=`expr $DIA + 0`
#Validar los días que están configurado en la tabla pclub.t_admpt_param con el dia de hoy (DIA)
cont1=`sqlplus -s ${USER_BD}/${CLAVE_BD}@${SID_BD}<<FIN 
set pagesize 0 feedback off verify off heading off echo off
select count(*) from dual
where nvl($DIA,0) in (select parn_dia_ejec 
							   from PCLUB.T_ADMPT_PARAM
							   where parn_num_arch=1);
exit;
FIN`
#Si la variable cont1 es igual a 1 entonces buscará el archivo RECARGA_*txt
if [ $cont1 -eq 1 ]; then

#*********************************************
#**PROCESO DE ASIGNACION DE PUNTOS POR RECARGA 
demora1=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "************************************* " 
pMessage "Iniciando subproceso                     " 
pMessage "Fecha y Hora  : ${FECHA_HORA}         " 
pMessage "Usuario :  ${USER_SERV}               " 
pMessage "Shell : ${SHELL1}                      " 
pMessage "Ip : ${IP_SERV}                       " 
pMessage "*************************************"$'\n' 

pMessage "Busca archivos a procesar según la estructura predefinida"
cd ${DIRDOCUMENTOS}
ls ${DATAFILE1} > ${DIRLOG}/${LISTA1}

FILEBODY1=`wc -l ${DIRLOG}/${LISTA1} | awk '{print $1}'`
if [ "$FILEBODY1" = "0" ] ; then
	pMessage " Error: No se encontraron archivos a procesar : "
	pMessage "${DIRDOCUMENTOS}/RECARGA_DDMMYYHH24MI.TXT"
	echo $'\n'"No se encontraron archivos a procesar : ${DIRDOCUMENTOS}/RECARGA_DDMMYYHH24MI.TXT"| mail -s "ASIGNACION DE PUNTOS POR RECARGAS CLAROCLUB PREPAGO – Se encontraron errores" $IT_OPERADOR
	pMessage "Termino subproceso Asignacion de Puntos por Recargas ClaroClub Prepago"
	pMessage "************************************"
	pMessage " FINALIZANDO PROCESO ASIGNACION DE PUNTOS POR RECARGAS CLAROCLUB PREPAGO.............."
	pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de subproceso "
	pMessage "************************************"
	echo "`date +%Y-%m-%d@%H:%M:%S` Fin de subproceso"$'\n'
	echo $'\n'
	echo "Ruta del Archivo log : " $DIRLOG/$LOGFILE
	echo $'\n'
	ESTADO1=0
fi
if [ $ESTADO1 -ne 0 ] ; then
while read FIELD001
do
#conversion de formato a unix
dos2unix ${DIRDOCUMENTOS}/${FIELD001}

	#script utilizado para anular el problema del reconocimiento de la ultima linea 
	#de archivos de texto
	TMP1=${DIRLOG}/TEMPDATA1.tmp
	echo "" >> ${DIRDOCUMENTOS}/${FIELD001}
	cat ${DIRDOCUMENTOS}/${FIELD001} | sed '/^$/d' > $TMP1
	cat $TMP1 > ${DIRDOCUMENTOS}/${FIELD001}

	rm -f $TMP1

	cd ${DIRSHELL}
	
	pMessage "Se importa la data del archivo a su respectiva tabla"	
	
	#sh SH081_SQLLDR.sh ${CONTROL} ${FIELD001} ${CTLBAD} ${CTLLOG}
	sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$DIRCTL/$CONTROL1 data=$DIRDOCUMENTOS/$FIELD001 bad=$DIRLOG/$CTLBAD1 log=$DIRLOG/$CTLLOG1 bindsize=200000 readsize=200000 rows=1000 skip=0

	
	mv ${DIRDOCUMENTOS}/${FIELD001} ${DIRPROCESADO}/${FIELD001}

done < ${DIRLOG}/${LISTA1}

rm -f ${DIRLOG}/${LISTA1}

pMessage "Se ejecuta el procedimiento"	
#sh SH081_SP_ASIGNARPUNTOS.sh ${DIRLOG}/${LOGFILE}

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

v_tmp			    varchar2(10);
v_FECHA  		    DATE;
v_CODERROR 	NUMBER;
v_DESCERROR  	VARCHAR2(200); 
v_NUMREGTOT  	NUMBER; 
v_NUMREGPRO  	NUMBER; 
v_NUMREGERR  	NUMBER;

BEGIN
v_tmp:=to_char(sysdate,'ddmmyyyy');
v_FECHA:=to_date(v_tmp,'ddmmyyyy');
										 
$PCLUB_OW.PKG_CC_PREPAGO.ADMPSI_PRERECAR(v_FECHA, v_CODERROR, v_DESCERROR, v_NUMREGTOT, v_NUMREGPRO, v_NUMREGERR);
											 
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

pMessage "Se valida la existencia de errores durante la ejecución"
VALIDAT_CTL1=`grep 'ORA-' ${DIRLOG}/${LOGFILE} | wc -l`
if [ $VALIDAT_CTL1 -ne 0 ]
	then
	
	pMessage `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del procedure de ASIGNACION DE PUNTOS POR	RECARGAS CLAROCLUB PREPAGO: ${PCLUB_OW}.PKG_CC_PREPAGO.ADMPSI_PRERECAR. Contacte al administrador."$'\n' 
    echo  $'\n'"Error al ejecutar el procedure ASIGNACION DE PUNTOS POR RECARGAS CLAROCLUB PREPAGO: ${PCLUB_OW}.PKG_CC_PREPAGO.ADMPSI_PRERECAR"| mail -s "ASIGNACION DE PUNTOS POR RECARGAS CLAROCLUB PREPAGO – error al ejecutar el procedure" $IT_OPERADOR
	pMessage "Termino subproceso Asignacion de Puntos por Recargas ClaroClub Prepago"
	pMessage "*******************************************************"
	pMessage " FINALIZANDO SUBPROCESO ASIGNACION DE PUNTOS POR RECARGAS CLAROCLUB PREPAGO........"
	pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de subproceso "
	pMessage "*******************************************************"
	echo "`date +%Y-%m-%d@%H:%M:%S` Fin de subproceso"$'\n'
	echo $'\n'
	echo "Ruta del Archivo log : " ${DIRLOG}/${LOGFILE}
	echo $'\n'
	ESTADO1=0
fi
else
	rm -f ${DIRLOG}/${LISTA1}
fi
pMessage "Termino subproceso Asignacion de Puntos por Recargas ClaroClub Prepago"
pMessage "********** FINALIZANDO SUBPROCESO ********** " 
pMessage "Fin de subproceso "
pMessage "************************************" 
pMessage "Ruta del Archivo log : ${DIRLOG}/${LOGFILE}" 
pMessage "*************************************" 
fi


pMessage "Termino proceso"
pMessage "********** FINALIZANDO PROCESO ********** " 
pMessage "Fin de proceso "
pMessage "************************************" 
pMessage "Ruta del Archivo log : ${DIRLOG}/${LOGFILE}" 
pMessage "" 	

exit









