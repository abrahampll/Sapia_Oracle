#!/bin/sh -x
#*************************************************************
#Programa        : SH004_BONO_FID12M
#Descripción     : Entrega de bono por fidelidad 12M 
#Fecha Creación  : 09/08/2013
#Usuario Creación: Jorge Luis Ortiz
#*************************************************************

# Inicialización de Variables
. /home/usrclaroclub/CLAROCLUB/Interno/Prepago/Bin/.varset
. /home/usrclaroclub/CLAROCLUB/Interno/Prepago/Bin/.passet
. /home/usrclaroclub/CLAROCLUB/Interno/Prepago/Bin/.mailset

#VARIABLES 
FECHA_HORA=`date +%Y%m%d_%H%M%S`
FECHA_ARCH=`date +%Y%m`
USER_SERV=`whoami`
IP_SERV=`cat /etc/sysconfig/network-scripts/ifcfg-eth0|grep IPADDR|sed 's/^[A-Z].*=//'`
USER_PROC="USRBONO12M"
PREF_SHELL="SH004_"
NOMB_SHELL="BONO_FID12M"
DESC_PROCESO="Entrega de Bono por Fidelidad 12M"
ASUN_MAIL="ERROR: $DESC_PROCESO"
SLDO_MAIL="\n\nPor favor atender este inconveniente. \nGracias"
TIPO_BONO_FIDEL="A"
NOMB_ARCH="BONO_FID12M"
EXTE_ARCH=".CCL"
BONO="BONFID13M"
PRMT_ARCH=$1

#VARIABLES ARCHIVOS
DIRD_ARCHDOCU=$DIRDOCUMENTOSBONO
DIRD_ARCHPROC=$DIRPROCESADOBONO
FILE_CTL=$DIRCTL/CTL004_${NOMB_ARCH}.ctl
FILE_REGNOPROC=$DIRENTRADA/${PREF_SHELL}REGNOPROC_$FECHA_HORA.tmp
FILE_PROCESO=$DIRENTRADA/${PREF_SHELL}PROCESO_$FECHA_HORA.tmp
FILE_LOG=$DIRLOG/${PREF_SHELL}${NOMB_SHELL}_$FECHA_HORA.log
FILE_BAD=$DIRFALLOS/${PREF_SHELL}${NOMB_SHELL}_$FECHA_HORA.bad
FILE_ERR=$DIRERROR/${PREF_SHELL}${NOMB_SHELL}_$FECHA_HORA.err
CTRL_LOG=$DIRLOG/CTL004_${NOMB_SHELL}_$FECHA_HORA.log
EMAIL=$IT_OPERADOR

pMessage () {
LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
echo "($LOGDATE) $*" 
echo "($LOGDATE) $*"  >> $FILE_LOG
}

InicioShell(){
pMessage "-------------------------------------------------------"
pMessage "|      INICIANDO ENTREGA DE BONO POR FIDELIDAD 12M     |"
pMessage "-------------------------------------------------------"
pMessage "   Fecha y Hora   |      `date +'%d-%m-%Y %H:%M:%S'`   "
pMessage "   Usuario        |      $USER_SERV                    "
pMessage "   Shell          |      $0                            "
pMessage "   Ip             |      $IP_SERV      	  	         "
pMessage "-------------------------------------------------------"
}

FinalShell(){
pMessage "-------------------------------------------------------"
pMessage "|     FINALIZANDO ENTREGA DE BONO POR FIDELIDAD 12M    |"
pMessage "-------------------------------------------------------"
pMessage "   Fecha y Hora   |      `date +'%d-%m-%Y %H:%M:%S'`   "
pMessage "   Usuario        |      $USER_SERV                    "
pMessage "   Shell          |      $0                            "
pMessage "   Ip             |      $IP_SERV      	  	         "
pMessage "-------------------------------------------------------"
}

ValidaError() {
#Función encargada de verificar el archivo respuesta de un proceso de base de datos y validar si contiene o no errores

FILENAME=$1
RETORNOS=1
if [ -e $FILENAME ]; then
VALIDA_ORA=`grep 'ORA-' $FILENAME | wc -l`
VALIDA_SP2=`grep 'SP2-' $FILENAME | wc -l` 
  if [ $VALIDA_ORA -gt 0 ] || [ $VALIDA_SP2 -gt 0 ]; then
	RETORNOS=-1
  fi
else
RETORNOS=-1
fi

echo $RETORNOS
}

ObtenerRegNoProcesado() {
#Función encargada de obtener los parámetros

TIPOFIDEL=$1
NOMBARCH=$2
OUTPUT=$3  #Archivo Log de transacciones

sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP > $OUTPUT

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

V_NUMREG NUMBER;
V_CODERROR NUMBER;
V_DESCERROR VARCHAR2(250);

BEGIN

$PCLUB_OW.PKG_CC_BONOS.ADMPSS_TMP_BONOFIDEL_PRE('$TIPOFIDEL','$NOMBARCH',V_NUMREG,V_CODERROR,V_DESCERROR);

dbms_output.put_line(V_NUMREG || '|' || V_CODERROR || '|' || V_DESCERROR);

EXCEPTION
    WHEN OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
END;
/

EXIT
EOP

RETORNOS=-1 
RETORNOS=$(ValidaError $OUTPUT)
echo $RETORNOS 
}

ImportaArchivo() {
#Función encargada de realizar la importación del archivo al temporal

FILECTRO=$1  #Archivo Control de datos
FILEDATA=$2  #Archivo Fuente  de datos
FILEBADS=$3  #Archivo Malos que no se registraron
FILELOGS=$4  #Archivo Log de transacciones

sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$FILECTRO data=$FILEDATA bad=$FILEBADS log=$FILELOGS bindsize=200000 readsize=200000 rows=1000 skip=0 >/dev/null

RETORNOS=-1 
RETORNOS=$(ValidaError $FILELOGS)
echo $RETORNOS 
}

ProcesarBono() {
#Función encargada de obtener los parámetros

NOMBARCH=$1
BONO=$2
USUARIO=$3
OUTPUT=$4  #Archivo Log de transacciones

sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP > $OUTPUT

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

V_CODERROR NUMBER;
V_DESCERROR VARCHAR2(250);
V_NUMREGTOT NUMBER;
V_NUMREGVAL NUMBER; 
V_NUMREGERR NUMBER;

BEGIN

$PCLUB_OW.PKG_CC_BONOS.ADMPSI_ENTR_BONOFID12M('$NOMBARCH','$BONO','$USUARIO',V_CODERROR,V_DESCERROR,V_NUMREGTOT,V_NUMREGVAL,V_NUMREGERR);

dbms_output.put_line(V_NUMREGTOT || '|' || V_NUMREGVAL || '|' || V_NUMREGERR || '|' || V_CODERROR || '|' || V_DESCERROR);

EXCEPTION
    WHEN OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
END;
/

EXIT
EOP

RETORNOS=-1 
RETORNOS=$(ValidaError $OUTPUT)
echo $RETORNOS 
}

RetornaRegErr() {
#Función encargada de obtener los registros errados

NOMBARCH=$1 #Nombre del archivo
OUTPUT=$2   #Archivo Log de transacciones

sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP > $OUTPUT

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

VC_SEC NUMBER;
VC_LINEA VARCHAR2(20);
VC_CODERROR NUMBER;
VC_MSJERROR VARCHAR2(100); 
V_CUR_LISTA SYS_REFCURSOR;
V_CODERROR NUMBER;
V_DESCERROR VARCHAR2(250); 

BEGIN

$PCLUB_OW.PKG_CC_BONOS.ADMPSS_TMP_EBONOFIDEL_PRE('$TIPO_BONO_FIDEL','$NOMBARCH',V_CUR_LISTA,V_CODERROR,V_DESCERROR);

IF V_CODERROR = 0 THEN
	LOOP
		FETCH V_CUR_LISTA INTO VC_SEC,VC_LINEA,VC_CODERROR,VC_MSJERROR;
		EXIT WHEN V_CUR_LISTA%NOTFOUND;
		dbms_output.put_line(VC_LINEA || '|' || VC_MSJERROR);
	END LOOP;
	CLOSE V_CUR_LISTA;
ELSE
	dbms_output.put_line('Error: ORA-' || V_CODERROR || ' Msg: ' || V_DESCERROR);
END IF;

EXCEPTION
    WHEN OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
END;
/

EXIT
EOP

RETORNOS=-1 
RETORNOS=$(ValidaError $OUTPUT)
echo $RETORNOS 
}

#########################################
#INICIO DE ENTREGA DE BONO POR FIDELIDAD#
#########################################

clear
InicioShell

pMessage "Se procede a procesar $DESC_PROCESO. El proceso puede durar varios minutos."

FILECTL=`find $FILE_CTL`

if [ "$FILECTL" = "" ] ; then
	pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
	pMessage "ERROR: No se encontró el archivo de Control de $DESC_PROCESO $FILE_CTL en la carpeta $DIRCTL."
	pMessage "A continuación se enviará un correo a $EMAIL con el asunto: $ASUN_MAIL"
	pMessage "Terminó subproceso"
	pMessage "************************************"
	echo -e "No se encontró el archivo $FILE_CTL en la carpeta $DIRCTL.${SLDO_MAIL}" | mail -s "$ASUN_MAIL" $EMAIL
	echo $'\n'
	FinalShell
	exit
fi

if [ "$1" = "" ] ; then
	NOMBREARCHIVO=${NOMB_ARCH}_${FECHA_ARCH}${EXTE_ARCH}
	RUTAFILE="${DIRD_ARCHDOCU}/"
else
    POSICION1=`awk -v a="${PRMT_ARCH}" -v b="${NOMB_ARCH}" 'BEGIN{print index(a,b)}' `
    POSICION2=`awk -v a="${PRMT_ARCH}" -v b="${EXTE_ARCH}" 'BEGIN{print index(a,b)}' `
	if [ $POSICION1 -ne 1 -o $POSICION2 -lt 1 ];then
		pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
		pMessage "ERROR: Nombre del archivo no cumple con el formato adecuado."
		FinalShell
		exit
	fi
	NOMBREARCHIVO=${PRMT_ARCH}
	RUTAFILE=""
fi

FILEDATA=`find ${RUTAFILE}${NOMBREARCHIVO}`
SIZERUTA=${#RUTAFILE}
FILE_NAME=${FILEDATA:SIZERUTA}

if [ "$FILEDATA" = "" ] ; then
	pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
	pMessage "ERROR: No se encontró el archivo de datos $NOMBREARCHIVO en la carpeta $DIRD_ARCHDOCU."    
	pMessage "A continuación se enviará un correo a $EMAIL con el asunto: $ASUN_MAIL" 
	pMessage "Verifique el log para mayor detalle $FILE_LOG"	
	pMessage "Terminó subproceso"
	pMessage "************************************" 	    
	echo -e "No se encontró el archivo $NOMBREARCHIVO en la carpeta $DIRD_ARCHDOCU.${SLDO_MAIL}"  | mail -s "$ASUN_MAIL" $EMAIL
	echo $'\n'
	FinalShell
	exit
fi

pMessage "Archivo: $FILE_NAME"
pMessage "Proceso1: Obteniendo registros no procesados."
ESTADO=$(ObtenerRegNoProcesado ${TIPO_BONO_FIDEL} ${FILE_NAME} ${FILE_REGNOPROC})

if [ $ESTADO -ne 1 ] ; then
	pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
	pMessage "ERROR: Ocurrió un error en la ejecución del procedure de $DESC_PROCESO: ${PCLUB_OW}.PKG_CC_BONOS.ADMPSS_TMP_BONOFIDEL_PRE. Contacte al administrador."
	pMessage "A continuación se enviará un correo a $EMAIL con el asunto: $ASUN_MAIL" 
	pMessage "Verifique el log para mayor detalle $FILE_LOG"
	pMessage "Terminó subproceso"
	pMessage "************************************" 
    echo -e "Error al ejecutar el procedure de $DESC_PROCESO: ${PCLUB_OW}.PKG_CC_BONOS.ADMPSS_TMP_BONOFIDEL_PRE.${SLDO_MAIL}" | mail -s "$ASUN_MAIL" $EMAIL
	echo $'\n'
	cat $FILE_REGNOPROC >> $FILE_LOG
	rm -f $FILE_REGNOPROC
	FinalShell
	exit
fi

REGISTRO=`head -1 ${FILE_REGNOPROC}`
CANTREGNOPROC=`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}' `
rm -f $FILE_REGNOPROC

pMessage "Se obtuvo los registros no procesados satisfactoriamente."
pMessage "Registros no procesados: $CANTREGNOPROC"

pMessage "Proceso2: Se ejecuta el SQL Loader si no existen registros no procesados."

if [ $CANTREGNOPROC -eq 0 ] ; then
	CANT_DATA=`cat ${RUTAFILE}${NOMBREARCHIVO} | wc -l | sed 's/ //g'`

	if [ $CANT_DATA -eq 0 ] ; then
		pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
		pMessage "ERROR: El archivo $FILE_NAME en la carpeta de $DIRD_ARCHDOCU no tiene data..." 
		pMessage "A continuación se enviará un correo a $EMAIL con el asunto: $ASUN_MAIL" 
		pMessage "Verifique el log para mayor detalle $FILE_LOG"
		pMessage "Terminó subproceso"
		pMessage "************************************" 
		echo -e "El archivo $FILE_NAME en la carpeta $DIRD_ARCHDOCU no tiene data.${SLDO_MAIL}" | mail -s "$ASUN_MAIL" $EMAIL
		echo $'\n'
		FinalShell
		exit
	fi

	dos2unix ${FILEDATA}

	TMP=$DIRLOG/TMP$NOMB_ARCH_$FECHA_HORA.tmp
	echo "" >> ${FILEDATA}
	cat ${FILEDATA} | sed '/^$/d' > $TMP
	cat $TMP > ${FILEDATA}

	rm -f $TMP
	TEMP_FILE=TEMP01_${FECHA_HORA}.TMP

	while read FIELD02
	do
		echo "${FIELD02}|${FILE_NAME}" >> $DIRLOG/${TEMP_FILE}
	done < $FILEDATA	
	
	pMessage "Se procede a importar los datos del archivo de entrada a la tabla de $DESC_PROCESO"
	ESTADO=$(ImportaArchivo ${FILE_CTL} ${DIRLOG}/${TEMP_FILE} ${FILE_BAD} ${CTRL_LOG})
	
	if [ $ESTADO -ne 1 ] ; then
		pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
		pMessage "ERROR: Ocurrió un error al ejecutar el SQL Loader. Contacte al administrador."		
		pMessage "A continuación se enviará un correo a $EMAIL con el asunto: $ASUN_MAIL" 		
		
		FILEBAD=`find ${FILE_BAD}`
		if [ "$FILEBAD" = "" ] ; then
			pMessage "Verifique el log para mayor detalle $CTRL_LOG"
			echo -e "SQL Loader falló por conectividad. Verifique el log para mayor detalle $CTRL_LOG.${SLDO_MAIL}" | mail -s "$ASUN_MAIL" $EMAIL
		else
			pMessage "Verifique el log para mayor detalle $FILE_BAD"
			echo -e "Registros no se cargaron correctamente. Verifique el log para mayor detalle $FILE_BAD.${SLDO_MAIL}" | mail -s "$ASUN_MAIL" $EMAIL
		fi
		
		cat $CTRL_LOG >> $FILE_LOG
		pMessage "El proceso de importación culminó con errores."
		pMessage "**********************************************" 	    
	else
		pMessage "El proceso de importación culminó satisfactoriamente."
		pMessage "*****************************************************" 	    
	fi
	rm -f $DIRLOG/${TEMP_FILE}
fi

pMessage "Proceso3: Procesando $DESC_PROCESO."

ESTADO=$(ProcesarBono ${FILE_NAME} ${BONO} ${USER_PROC} ${FILE_PROCESO})

if [ $ESTADO -ne 1 ] ; then
	pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
	pMessage "ERROR: Ocurrió un error en la ejecución del procedure de $DESC_PROCESO: ${PCLUB_OW}.PKG_CC_BONOS.ADMPSI_ENTR_BONOFID12M. Contacte al administrador."$'\n' 
	pMessage "A continuación se enviará un correo a $EMAIL con el asunto: $ASUN_MAIL" 
	pMessage "Verifique el log para mayor detalle $FILE_LOG"
	pMessage "Terminó subproceso"
	pMessage "************************************" 
    echo -e "Error al ejecutar el procedure de $DESC_PROCESO: ${PCLUB_OW}.PKG_CC_BONOS.ADMPSI_ENTR_BONOFID12M.${SLDO_MAIL}" | mail -s "$ASUN_MAIL" $EMAIL
	echo $'\n'
	cat $FILE_PROCESO >> $FILE_LOG
	rm -f $FILE_PROCESO
	FinalShell
	exit
fi

REGISTRO=`head -1 ${FILE_PROCESO}`
CANTREGTOT=`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}' `
CANTREGVAL=`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $2}' `
CANTREGERR=`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $3}' `

pMessage "Total de registros: $CANTREGTOT"
pMessage "Registros válidos: $CANTREGVAL"
pMessage "Registros errados: $CANTREGERR"

rm -f $FILE_PROCESO

if [ $CANTREGERR -gt 0 ] ; then
	pMessage "Proceso4: Obteniendo registros errados $DESC_PROCESO."
	ESTADO=$(RetornaRegErr ${FILE_NAME} ${FILE_ERR})

	cat $FILE_ERR >> $FILE_LOG

	if [ $ESTADO -ne 1 ] ; then
		pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
		pMessage "ERROR: Ocurrió un error en la ejecución del procedure de $DESC_PROCESO: ${PCLUB_OW}.PKG_CC_BONOS.ADMPSS_TMP_EBONOFIDEL_PRE. Contacte al administrador."
		pMessage "A continuación se enviará un correo a $EMAIL con el asunto: $ASUN_MAIL"
		pMessage "Verifique el log para mayor detalle $FILE_LOG"
		pMessage "Terminó subproceso"
		pMessage "************************************" 
		echo -e "Error al ejecutar el procedure de $DESC_PROCESO: ${PCLUB_OW}.PKG_CC_BONOS.ADMPSS_TMP_EBONOFIDEL_PRE.${SLDO_MAIL}" | mail -s "$ASUN_MAIL" $EMAIL
		rm -f $FILE_ERR
	else 
		pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
		pMessage "Existe(n) $CANTREGERR registro(s) errado(s) en $DESC_PROCESO."
		pMessage "A continuación se enviará un correo a $EMAIL con el asunto: $DESC_PROCESO" 
		pMessage "Verifique el log para mayor detalle $FILE_ERR"
		echo -e "Existe(n) $CANTREGERR registro(s) errado(s) en $DESC_PROCESO. Verifique el log para mayor detalle $FILE_ERR.${SLDO_MAIL}" | mail -s "$DESC_PROCESO" $EMAIL
	fi	
fi

mv -f $FILEDATA ${DIRD_ARCHPROC}
pMessage "El proceso de $DESC_PROCESO culminó satisfactoriamente."
pMessage "Verifique el log para mayor detalle $FILE_LOG"
pMessage "*************************************************************" 
FinalShell
exit
