#!/bin/sh -x
#*************************************************************
#Programa      :  SH023_IMPDESREN
#Autor         :  Jorge Andres Thomburne Vidales 
#Descripcion   :     
#		       	   
#		       
#FECHA_HORA    :  21/10/2010
#.
#*************************************************************
clear

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

FECHA_HORA=`date +%Y%m%d%H%M%S`
HORA=`date +%H%M%S`
FARCH=`date +%Y%m%d`

# ip de TIM-FTP1
HOST=`hostname`
IP_SERV=`cat /etc/hosts | grep -v '#' | grep ${HOST} | awk '{print $1}'`
#usuario
USER_SERV=`whoami`
SHELL=SH023_IMPDESREN.sh

#DATA=PROXRENO_CONTRATOS_${FECHA}.CCL

FILELOG=SH023_IMPDESREN_${FECHA_HORA}.log
CTLLOG=SH023_SQLLDR_${FECHA_HORA}.log
CONTROL=CTL23_IMPDESREN.ctl
LISTA=LIST_FILES23_${FECHA_HORA}.tmp

INPUT_NAME=$1

demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "************************************* " 
pMessage "Iniciando proceso                     " 
pMessage "Fecha y Hora : ${FECHA_HORA}          " 
pMessage "Usuario :  ${USER_SERV}               " 
pMessage "Shell : ${SHELL}                      " 
pMessage "Ip : ${IP_SERV}                       " 
pMessage "*************************************"$'\n' 

IND="0"
if [ ${#INPUT_NAME} = 0 ];
then
	#RUTA_FILE=$DIRENTRADAPOST/$DATA
	cd $DIRENTRADAPOST
	ls BONUS_PROXRENO_CONTRATOS_$FARCH.RE > ${DIRLOGPOST}/${LISTA}
		
	FILEDATA=`wc -l ${DIRLOGPOST}/${LISTA} | awk '{print $1}'`
	if [ "$FILEDATA" = "0" ] ; then
	   pMessage " Error: No hay archivos para procesar..."
		echo $'\n'"No hay archivos para procesar : $RUTA_FILE"| mail -s "MESES CONSECUTIVOS SIN FACTURACION – Se encontraron errores" $IT_OPERADOR
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
	IND="1"
	
else
	RUTA_FILE=${INPUT_NAME}
	echo ${RUTA_FILE} > ${DIRLOGPOST}/${LISTA}	
fi

cd $DIR_POST_SHELL

while read FIELD01
do
	FECHA=`date +%Y%m%d`
	TEMP_FILE=TEMP23_${FECHA_HORA}.TMP

	TEMP_NAME=$FIELD01
	#FILEDATA=`find $TEMP_NAME`
	if [ "$IND" = "1" ] ; then
		TEMP_NAME=$DIRENTRADAPOST/$FIELD01
	fi

	FILE_NAME=`echo $TEMP_NAME | awk 'BEGIN{FS="/"} {print $NF}'`
	FILE_DATE=`expr substr ${FILE_NAME} 26 8`

	FILEERR=PROXRENO_CONTRATOS_${FILE_DATE}.ERR
	FILEEXP=PROXRENO_CONTRATOS_${FILE_DATE}.CCL
	FILETLV=TELEVENTAS_${FILE_DATE}.CCL
	
	echo ${FILE_NAME}
	echo ${FILE_DATE}
	
	rm -f $DIRLOGPOST/$TEMP_FILE
	
	TMP=$DIRLOGPOST/TEMPDATA23.tmp

	echo "" >> $TEMP_NAME
	cat $TEMP_NAME | sed '/^$/d' > $TMP
	cat $TMP > $TEMP_NAME
		
	rm -f $TMP
		
	dos2unix $TEMP_NAME
	
	while read FIELD02
	do
		echo "${FIELD02}|${FILE_DATE}|${FILE_NAME}" >> $DIRLOGPOST/$TEMP_FILE	
	done < $TEMP_NAME
		
	RUTA_FILE=$TEMP_NAME

	BAD=PROXRENO_CONTRATOS_${FECHA}.ERR

	pMessage "Se comprueba la existencia del archivo $RUTA_FILE"	

	# File Data
	FILEDATA=`find $RUTA_FILE`
	if [ "$FILEDATA" = "" ]; then
	   pMessage " $demora: Error: No se encontro el archivo de datos..."
		echo $'\n'"No se encuentra el archivo $RUTA_FILE"| mail -s "DESCUENTO POR RENOVACION DE CONTRATOS – Se encontraron errores" $IT_OPERADOR
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
	pMessage "Se comprueba el contenido del archivo $RUTA_FILE"	
	FILEDATA=`wc -l ${RUTA_FILE}| awk '{print $1}'`
	if [ "$FILEDATA" = "0" ]; then
	   pMessage " Error: El archivo de datos se encuentra vacio..."
		echo $'\n'"El archivo de datos se encuentra vacio : $RUTA_FILE"| mail -s "DESCUENTO POR RENOVACION DE CONTRATOS – Se encontraron errores" $IT_OPERADOR
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
	
	dos2unix $DIRLOGPOST/$TEMP_FILE
	
	pMessage "Se importa la data del archivo a su respectiva tabla"	
#	sh SH023_SQLLDR.sh $CONTROL $DIRLOGPOST/$TEMP_FILE $BAD $CTLLOG 
	sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$DIRCONTROLPOST/$CONTROL data=$DIRLOGPOST/$TEMP_FILE bad=$DIRFALLOSPOST/$BAD log=$DIRLOGPOST/$CTLLOG bindsize=200000 readsize=200000 rows=1000 skip=0

	#pMessage "Se mueve el archivo de entrada a la carpeta $DIRPROCPOST"	
	#mv $RUTA_FILE $DIRPROCPOST
			
	VALIDAT_CTL=`grep 'ORA-' $DIRLOGPOST/$CTLLOG | wc -l`
	if [ $VALIDAT_CTL -ne 0 ]
		then
		echo "FECHA $demora - Verifique el log para mayor detalle $DIRLOGPOST/$FILELOG"$'\n'
		pMessage `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n' 
		echo  $'\n'"Error al importar los datos de "| mail -s "DESCUENTO POR RENOVACION DE CONTRATOS – Se encontraron errores" $IT_OPERADOR
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
	
	pMessage "El proceso de importacion se ejecuto correctamente"	
	
	rm -f $DIRLOGPOST/$CTLLOG
	
	pMessage "Se ejecuta el procedimiento PKG_CC_PROCACUMULA.ADMPSI_PRXRCONC"
	
	#sh SH023_VALIDA.sh ${DIRLOGPOST}/${FILELOG} ${FILE_DATE}
	
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

v_fecha 	date;
v_coderr	char(1);
v_deserr	varchar2(200);
v_regtot	number;
v_regpro	number;
v_regerr	number;

BEGIN

select to_date('$FILE_DATE','yyyymmdd') into v_fecha from dual;

$PCLUB_OW.PKG_CC_PROCACUMULA.ADMPSI_PRXRCONC(v_fecha,v_coderr,v_deserr,v_regtot,v_regpro,v_regerr);

dbms_output.put_line('Indicador: '||v_coderr);
dbms_output.put_line('Descripcion: '||v_deserr);
dbms_output.put_line('Total Registros: '||v_regtot);
dbms_output.put_line('Total Procesados: '||v_regpro);
dbms_output.put_line('Total con Errores: '||v_regerr);
 
EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
 
END;
/

EXIT
EOP
	
	pMessage "Se valida la ejecución del procedimiento"	
	VALIDAT_CTL1=`grep 'ORA-' $DIRLOGPOST/$FILELOG | wc -l`
	if [ $VALIDAT_CTL1 -ne 0 ]
		then
		echo "FECHA $demora - Verifique el log para mayor detalle $DIRLOGPOST/$FILELOG"$'\n'
		pMessage `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del procedure. Contacte al administrador."$'\n' 
		echo  $'\n'"Error al ejecutar el procedure "| mail -s "DESCUENTO POR RENOVACION DE CONTRATOS – Se encontraron errores" $IT_OPERADOR
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
	
	pMessage "Se ejecuta el procedimiento PKG_CC_PROCACUMULA.ADMPSI_EPRXRCONC"
	#sh SH024_REPDESREN.sh $RUTA_FILE $FILE_DATE
	sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> ${DIRFALLOSPOST}/${FILEERR}
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

v_fecha 	date;

ADMPV_COD_CLI varchar2(100);
ADMPC_TIPO  varchar2(100);
ADMPN_COD_CONTR  NUMBER;
ADMPC_COD_ERROR	varchar2(100);
ADMPV_MSJE_ERROR	varchar2(100);

BEGIN

dbms_output.enable(NULL);

select to_date('$FILE_DATE','yyyymmdd') into v_fecha from dual;

$PCLUB_OW.PKG_CC_PROCACUMULA.ADMPSI_EPRXRCONC(v_fecha,C_CURSOR);

LOOP
FETCH C_CURSOR INTO ADMPV_COD_CLI, ADMPC_TIPO, ADMPN_COD_CONTR, ADMPC_COD_ERROR, ADMPV_MSJE_ERROR;

EXIT WHEN C_CURSOR%NOTFOUND;
 		
dbms_output.put_line(ADMPV_COD_CLI||'|'||ADMPC_TIPO||'|'||ADMPN_COD_CONTR||'|'||ADMPC_COD_ERROR||'|'||ADMPV_MSJE_ERROR);		

END LOOP;

CLOSE C_CURSOR;

EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
 
END;
/

EXIT
EOP

VALIDAT_CTL2=`grep 'ORA-' ${DIRFALLOSPOST}/${FILEERR} | wc -l`
if [ $VALIDAT_CTL2 -ne 0 ]
	then
	pMessage `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del procedure . Contacte al administrador."$'\n' 
    echo  $'\n'"Error al ejecutar el procedure"| mail -s "DESCUENTO POR RENOVACION DE CONTRATOS – Se encontraron errores" $IT_OPERADOR
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
	


DATAVALUE=`wc -l ${DIRFALLOSPOST}/${FILEERR} | awk '{print $1}' `
if [ "$DATAVALUE" = "0" ] ; then	
	rm -f ${DIRFALLOSPOST}/${FILEERR}
fi

#sh SH024_REPORTE2.sh ${DIRENTRADAPOST}/${FILEEXP} ${FILE_DATE}

	
	
pMessage "Se ejecuta el procedimiento PPKG_CC_PROCACUMULA.ADMPSS_PROXRCOC"

sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> ${DIRENTRADAPOST}/${FILEEXP}
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

v_fecha 	date;

ADMPV_COD_CLI varchar2(100);
ADMPC_TIPO  varchar2(100);
ADMPN_COD_CONTR  NUMBER;
ADMPC_PUN_TOT	NUMBER;
ADMPV_EQ_PUN	NUMBER;

BEGIN

dbms_output.enable(NULL);

select to_date('$FILE_DATE','yyyymmdd') into v_fecha from dual;

$PCLUB_OW.PKG_CC_PROCACUMULA.ADMPSS_PROXRCOC(v_fecha,C_CURSOR);

LOOP
FETCH C_CURSOR INTO ADMPV_COD_CLI, ADMPC_TIPO, ADMPN_COD_CONTR, ADMPC_PUN_TOT, ADMPV_EQ_PUN;

EXIT WHEN C_CURSOR%NOTFOUND;
 		
dbms_output.put_line(ADMPV_COD_CLI||'|'||ADMPC_TIPO||'|'||ADMPN_COD_CONTR||'|'||ADMPC_PUN_TOT||'|'||ADMPV_EQ_PUN);		

END LOOP;

CLOSE C_CURSOR;

EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
 
END;
/

EXIT
EOP

VALIDAT_CTL3=`grep 'ORA-' ${DIRENTRADAPOST}/${FILEEXP} | wc -l`
if [ $VALIDAT_CTL3 -ne 0 ]
	then
	pMessage `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del procedure . Contacte al administrador."$'\n' 
    echo  $'\n'"Error al ejecutar el procedure"| mail -s "DESCUENTO POR RENOVACION DE CONTRATOS – Se encontraron errores" $IT_OPERADOR
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

while read FIELD03
do
	echo $FIELD03	| awk 'BEGIN{FS="|"} {print $1"|"$3"|"$4}' >> ${DIRENTRADAPOST}/${FILETLV}
done < ${DIRENTRADAPOST}/${FILEEXP}
#----------------
		
	rm -f $DIRLOGPOST/$TEMP_FILE
	
done < ${DIRLOGPOST}/${LISTA}

rm -f ${DIRLOGPOST}/${LISTA}
	
pMessage "Termino proceso"
pMessage "********** FINALIZANDO PROCESO ********** " 
pMessage "Fin de proceso "
pMessage "************************************" 
pMessage "Ruta del Archivo log : ${DIRLOGPOST}/${FILELOG}" 
pMessage "" 
pMessage "" 
 	
exit