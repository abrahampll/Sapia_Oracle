
#!/bin/sh -x
#*************************************************************
#Programa      :  SH100_CARGA_CLIENTES_PREPAGO
#Autor         :  Deysi Galvez Medrano
#Descripcion   :  Registra lineas prepago activas
#		       	   
#		       
#FECHA_HORA    :  25/08/2011
#.
#*************************************************************
clear

# Inicializacion de Variables
HOME_GAT=/home/usrclaroclub/CLAROCLUB/Interno/Prepago
. $HOME_GAT/Bin/.varset
. $HOME_GAT/Bin/.mailset
. $HOME_GAT/Bin/.passet 

#. $HOME_GAT/Shells/autlib.sh

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
SHELL=SH100_CARGA_CLIENTES_PREPAGO.sh
DATAFILE=HIST_PREPAGO_${FECHA}.TXT
LOGFILE=LOG100_CARGA_PREPAGO_${FECHA_HORA}.log
CONTROL=CTL100_IMPCLIENTES.ctl
CTLLOG=SH100_CTL_IMPCLIENTES_${FECHA_HORA}.log
CTLBAD=CTL100_BAD.txt


LISTA=lista100.tmp

demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "************************************* " 
pMessage "Iniciando proceso                     " 
pMessage "Fecha y Hora : ${FECHA_HORA}          " 
pMessage "Usuario :  ${USER_SERV}               " 
pMessage "Shell : ${SHELL}                      " 
pMessage "Ip : ${IP_SERV}                       " 
pMessage "*************************************"$'\n' 

pMessage "Busca archivos a procesar según la estructura predefinida"
cd ${DIRENTRADA}
ls ${DATAFILE} > ${DIRLOG}/${LISTA}

FILEBODY=`wc -l ${DIRLOG}/${LISTA} | awk '{print $1}'`
if [ "$FILEBODY" = "0" ] ; then
   pMessage " $demora: Error: No se encontraron archivos a procesar:"
   pMessage "${DIRENTRADA}/${DATAFILE}"
    echo $'\n'"No se encuentra el archivo ${DIRENTRADA}/${DATAFILE}"| mail -s "CARGA DE CLIENTES CLAROCLUB PREPAGO . Se encontraron errores" $IT_OPERADOR
	pMessage "Termino proceso"
	pMessage "************************************"
	pMessage " FINALIZANDO PROCESO..............."
	pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso "
	pMessage "************************************"
	echo "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso"$'\n'
	echo $'\n'
	echo "Ruta del Archivo log : " ${DIRLOG}/${LOGFILE}
	echo $'\n'
	exit -1
fi



TMP1=${DIRLOG}/TEMPDATA1.tmp
echo "" >> ${DIRENTRADA}/${DATAFILE}
cat ${DIRENTRADA}/${DATAFILE} | sed '/^$/d' > $TMP1
cat $TMP1 > ${DIRENTRADA}/${DATAFILE}
		
rm -f $TMP1

FILEBODY2=`wc -l ${DIRENTRADA}/${DATAFILE} | awk '{print $1}'`
if [ "$FILEBODY2" = "0" ] ; then
	pMessage " Error: El archivo de datos se encuentra vacio :"
	pMessage " ${DIRENTRADA}/${DATAFILE}"
	echo $'\n'"El archivo de datos de CARGA DE CLIENTES CLAROCLUB PREPAGO se encuentra vacio : ${DIRENTRADA}/${DATAFILE}"| mail -s "CARGA DE CLIENTES CLAROCLUB PREPAGO . Se encontraron errores" $IT_OPERADOR
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
       cd ${DIRSHELL}
       pMessage "Se importa la data del archivo a su respectiva tabla " `date +%H%M%S`
       
       sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$DIRCTL/$CONTROL data=$DIRENTRADA/$DATAFILE bad=$DIRFALLOS/$CTLBAD log=$DIRLOG/$CTLLOG bindsize=200000 readsize=200000 rows=1000 skip=0 errors=1000
	
	VALIDAT_CTL=`grep 'ORA-' $DIRLOG/$CTLLOG | wc -l`
	#DEYSI
	
	rm -f ${DIRLOG}/${LISTA}
	
	if [ $VALIDAT_CTL -ne 0 ]
                then
                        echo "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n'
                        echo "FECHA $Demora - Verifique el log para mayor detalle $LOGFILE"$'\n'
                        echo `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n' >> $LOGFILE
                        echo "Termino proceso">>  $LOGFILE
                        echo "************************************" >>  $LOGFILE
                        echo " FINALIZANDO PROCESO..............." >>  $LOGFILE
                        echo "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso " >>  $LOGFILE
                        echo "************************************" >>  $LOGFILE
                        echo "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso"$'\n'
                        echo $'\n'
                        echo "Ruta del Archivo log : " $LOGFILE
                        echo $'\n'
						exit -1
		else
			mv ${DIRENTRADA}/${DATAFILE} ${DIRPROCESADO}/${DATAFILE}
			

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
v_FECHA:=to_date(v_tmp,'dd/mm/yyyy');

$PCLUB_OW.PKG_CC_PREPAGO.ADMPSI_CARGA_CLIENTE(v_FECHA, v_CODERROR, v_DESCERROR, v_NUMREGTOT, v_NUMREGPRO, v_NUMREGERR);
											 
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
	pMessage `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del procedure de CARGA DE CLIENTES CLAROCLUB PREPAGO : ${PCLUB_OW}.PKG_CC_PREPAGO.ADMPSI_CARGA_CLIENTE . Contacte al administrador."$'\n' 
	echo  $'\n'"Error al ejecutar el procedure de CARGA DE CLIENTES CLAROCLUB PREPAGO : ${PCLUB_OW}.PKG_CC_PREPAGO.ADMPSI_CARGA_CLIENTE"| mail -s "CARGA DE CLIENTES CLAROCLUB PREPAGO . Se encontraron errores" $IT_OPERADOR
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

pMessage "Se mueve el archivo a la carpeta ${DIRPROCESADO}"
mv ${DIRENTRADA}/${DATAFILE} ${DIRPROCESADO}/${DATAFILE}

pMessage "Termino proceso"
pMessage "********** FINALIZANDO PROCESO ********** " 
pMessage "Fin de proceso "
pMessage "************************************" 
pMessage "Ruta del Archivo log : ${DIRLOG}/${LOGFILE}" 
pMessage "" 
pMessage "" 
fi	
exit

