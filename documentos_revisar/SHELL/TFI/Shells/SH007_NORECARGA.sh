#!/bin/sh -x
#*************************************************************
#Programa        : SH007_NORECARGA
#Descripción     : Eliminación de puntos por No Recarga
#Fecha Creación  : 08/04/2013
#Usuario Creación: Oscar Paucar
#Correo Creación : E75874@claro.com.pe
#*************************************************************

# Inicialización de Variables
. /home/usrclaroclub/CLAROCLUB/Interno/TFI/Bin/.varset
. /home/usrclaroclub/CLAROCLUB/Interno/TFI/Bin/.passet
. /home/usrclaroclub/CLAROCLUB/Interno/TFI/Bin/.mailset

#VARIABLES 
FECHA_HORA=`date +%Y%m%d_%H%M%S`
FECHA_ARCH=`date +%Y%m%d`
FECHA_TIEMPO=`date +'%d-%m-%Y %H:%M:%S'`
USER_SERV=`whoami`
IP_SERV=`cat /etc/sysconfig/network-scripts/ifcfg-eth0|grep IPADDR|sed 's/^[A-Z].*=//'`

#VARIABLES ARCHIVOS
FILE_NAME=NORECARGA_$FECHA_ARCH.CCL
FILE_DATA=$DIRENT_NORECAR/$FILE_NAME
FILE_CTL=$DIRCTL/NoRecargaTFI.ctl
FILE_BAD=$DIRFALLOS/NoRecargaTFI_$FECHA_HORA.bad
FILE_ERR=$DIRERR_NORECAR/NoRecargaTFI_$FECHA_HORA.err
FILE_LOG=$DIRLOG/SH007_NORECARGA_$FECHA_HORA.log
CTRL_LOG=$DIRLOG/CTL007_LOG_$FECHA_HORA.log
EMAIL=$IT_MAIL

pMessage () {
LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
echo "($LOGDATE) $*" 
echo "($LOGDATE) $*"  >> $FILE_LOG
}

InicioShell(){
pMessage "-------------------------------------------------------"
pMessage "|   INICIANDO ELIMINACION DE PUNTOS POR NO RECARGA    |"
pMessage "-------------------------------------------------------"
pMessage "   Fecha y Hora   |      ${FECHA_TIEMPO}               "
pMessage "   Usuario        |      $USER_SERV                    "
pMessage "   Shell          |      $0                            "
pMessage "   Ip             |      $IP_SERV      	  	         "
pMessage "-------------------------------------------------------"
}

FinalShell(){
pMessage "-------------------------------------------------------"
pMessage "|  FINALIZANDO ELIMINACION DE PUNTOS POR NO RECARGA   |"
pMessage "-------------------------------------------------------"
pMessage "   Fecha y Hora   |      ${FECHA_TIEMPO}               "
pMessage "   Usuario        |      $USER_SERV                    "
pMessage "   Shell          |      $0                            "
pMessage "   Ip             |      $IP_SERV      	  	         "
pMessage "-------------------------------------------------------"
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

AsignaPuntos() {
#Función encargada de realizar la eliminación de puntos

FILELOGS=$1  #Archivo Log de transacciones

sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> $FILELOGS

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

K_FECHA DATE;
K_CODERROR	NUMBER;
K_DESCERROR VARCHAR2(200); 
K_NUMREGTOT NUMBER; 
K_NUMREGPRO NUMBER; 
K_NUMREGERR NUMBER;

BEGIN

K_FECHA := TO_DATE(TO_CHAR(SYSDATE,'ddmmyyyy'),'ddmmyyyy');

$PCLUB_OW.PKG_CC_PTOSTFI.ADMPSI_NO_RECARGA(K_FECHA, '$FILE_NAME', K_CODERROR, K_DESCERROR, K_NUMREGTOT, K_NUMREGPRO, K_NUMREGERR);

dbms_output.put_line('Indicador: '||K_CODERROR);
dbms_output.put_line('Descripción: '||K_DESCERROR);
dbms_output.put_line('Total Registros: '||K_NUMREGTOT);
dbms_output.put_line('Total Procesados: '||K_NUMREGPRO);
dbms_output.put_line('Total Errores: '||K_NUMREGERR);

EXCEPTION
    WHEN OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
END;
/

EXIT
EOP

RETORNOS=-1 
RETORNOS=$(ValidaError $FILELOGS)
echo $RETORNOS 
}

RetornaRegErr() {
#Función encargada de obtener los registros errados

FILELOGS=$1  #Archivo Log de transacciones

sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> $FILELOGS

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

K_FECHA DATE;
K_CODERROR NUMBER;
K_DESCERROR VARCHAR2(200); 
K_CUR_ERRORES SYS_REFCURSOR;
V_REGISTRO ADMPT_IMP_SINRECARGATFI%ROWTYPE;

BEGIN

K_FECHA := TO_DATE(TO_CHAR(SYSDATE,'ddmmyyyy'),'ddmmyyyy');

$PCLUB_OW.PKG_CC_PTOSTFI.ADMPSS_ENO_RECARGA(K_FECHA, K_CODERROR, K_DESCERROR, K_CUR_ERRORES);

LOOP
	FETCH K_CUR_ERRORES INTO V_REGISTRO;
	EXIT WHEN K_CUR_ERRORES%NOTFOUND;
	dbms_output.put_line(V_REGISTRO.ADMPV_COD_CLI || '|' || V_REGISTRO.ADMPV_MSJE_ERROR);
END LOOP;

CLOSE K_CUR_ERRORES;

EXCEPTION
    WHEN OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
END;
/

EXIT
EOP

RETORNOS=-1 
RETORNOS=$(ValidaError $FILELOGS)
echo $RETORNOS 
}

ValidaError() {
#Función encarga de verificar el archivo respuesta de un proceso de base de datos y validar si contiene o no errores

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

###################################
#INICIO DE ELIMINACION DE PUNTOS
###################################

clear
InicioShell

pMessage "Buscando información en el repositorio de archivos fuentes"

FILECTL=`find $FILE_CTL`

if [ "$FILECTL" = "" ] ; then
	pMessage "Hora y Fecha: $FECHA_TIEMPO"
	pMessage "Error: No se encontró el archivo de Control de No Recarga $FILE_CTL en la carpeta $DIRCTL."    
	pMessage "A continuación se enviará un correo a $EMAIL con el asunto: El archivo de Control de No Recarga TFI no se encuentra en la ruta." 
	pMessage "Terminó subproceso"
	pMessage "************************************"
	echo "No se encontró el archivo $FILE_CTL en la carpeta $DIRCTL." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El archivo de Control de No Recarga TFI no se encuentra en la ruta." $EMAIL
	echo $'\n'
	FinalShell
	exit
fi

FILEDATA=`find $FILE_DATA`
CANT_DATA=`cat  $FILE_DATA | wc -l | sed 's/ //g'`

if [ "$FILEDATA" = "" ] ; then
	pMessage "Hora y Fecha: $FECHA_TIEMPO"
	pMessage "Error: No se encontró el archivo de datos $FILE_NAME en la carpeta $DIRENT_NORECAR."    
	pMessage "A continuación se enviará un correo a $EMAIL con el asunto: El archivo de No Recarga TFI no se encuentra en la ruta." 
	pMessage "Terminó subproceso"
	pMessage "************************************" 	    
	echo "No se encontró el archivo $FILE_NAME en la carpeta $DIRENT_NORECAR." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El archivo de No Recarga TFI no se encuentra en la ruta." $EMAIL
	echo $'\n'
	FinalShell
	exit
fi

if [ $CANT_DATA -eq 0 ] ; then
	pMessage "Hora y Fecha: $FECHA_TIEMPO"
	pMessage "Error: El archivo $FILE_NAME en la carpeta de $DIRENT_NORECAR no tiene data..." 
	pMessage "A continuación se enviará un correo a $EMAIL con el asunto: El archivo de No Recarga TFI se encuentra vacio." 
	pMessage "Terminó subproceso"
	pMessage "************************************" 
	echo "El archivo $FILE_NAME en la carpeta $DIRENT_NORECAR no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "El archivo de No Recarga TFI se encuentra vacio." $EMAIL
	echo $'\n'
	FinalShell
	exit
fi

dos2unix ${FILEDATA}

TMP=$DIRLOG/TMPNORECARGA_$FECHA_HORA.tmp
echo "" >> ${FILEDATA}
cat ${FILEDATA} | sed '/^$/d' > $TMP
cat $TMP > ${FILEDATA}

rm -f $TMP

pMessage "Se procede a importar los datos del archivo de entrada a la tabla de No Recarga TFI"
ESTADO=$(ImportaArchivo ${FILE_CTL} ${FILEDATA} ${FILE_BAD} ${CTRL_LOG})

if [ $ESTADO -ne 1 ] ; then
	pMessage "Hora y Fecha: $FECHA_TIEMPO"
	pMessage "Error: Ocurrió un error al momento de importar los datos del archivo a la tabla de No Recarga TFI. Contacte al administrador."$'\n'
	pMessage "Verifique el log para mayor detalle $CTRL_LOG"$'\n'
	cat $CTRL_LOG >> $FILE_LOG
	pMessage "El proceso de importación culminó con errores."
	pMessage "**********************************************" 	    
else
	pMessage "El proceso de importación culminó satisfactoriamente."
	pMessage "*****************************************************" 	    
fi

mv -f $FILE_DATA $DIRPROC_NORECAR
TMP=$DIRLOG/TMPNORECARGA_$FECHA_HORA.tmp

pMessage "Se procede a registrar la eliminación de puntos"
ESTADO=$(AsignaPuntos $TMP)

cat $TMP >> $FILE_LOG

if [ $ESTADO -ne 1 ] ; then
	rm -f $TMP
	pMessage "Hora y Fecha: $FECHA_TIEMPO"
	pMessage "Error: Ocurrió un error en la ejecución del procedure de eliminación de puntos por no recarga ClaroClub Prepago TFI: ${PCLUB_OW}.PKG_CC_PTOSTFI.ADMPSI_NO_RECARGA. Contacte al administrador."$'\n' 
	pMessage "A continuación se enviará un correo a $EMAIL con el asunto: Eliminación de puntos por no recarga ClaroClub Prepago TFI – Error al ejecutar el procedure" 
	pMessage "Verifique el log para mayor detalle $FILE_LOG"$'\n'
	pMessage "Terminó subproceso"
	pMessage "************************************" 
    echo "Error al ejecutar el procedure eliminación de puntos por no recarga ClaroClub Prepago TFI: ${PCLUB_OW}.PKG_CC_PTOSTFI.ADMPSI_NO_RECARGA" | mail -s "Eliminación de puntos por no recarga ClaroClub Prepago TFI – Error al ejecutar el procedure" $EMAIL
	echo $'\n'
	FinalShell
	exit
fi

REGTOT=`cat $TMP|grep "Registros"`
REGPRO=`cat $TMP|grep "Procesados"`
REGERR=`cat $TMP|grep "Errores"`
NUMREGTOT=`echo $REGTOT | sed 's/\\r//g'|awk 'BEGIN{FS=":"} {print $2}'`
NUMREGERR=`echo $REGERR | sed 's/\\r//g'|awk 'BEGIN{FS=":"} {print $2}'`

echo $REGTOT
echo $REGPRO
echo $REGERR
rm -f $TMP

if [ $NUMREGTOT -eq 0 ] ; then
	pMessage "Hora y Fecha: $FECHA_TIEMPO"
	pMessage "El SQL Loader del proceso eliminación de puntos por no recarga cargó 0 registros. Contacte al administrador."$'\n' 
	pMessage "A continuación se enviará un correo a $EMAIL con el asunto: SQL Loader del proceso cargó 0 registros" 
	pMessage "Verifique el log para mayor detalle $FILE_LOG"$'\n'
	pMessage "Terminó subproceso"
	pMessage "************************************" 
    echo "El SQL Loader del proceso eliminación de puntos por no recarga cargó 0 registros." | mail -s "SQL Loader del proceso cargó 0 registros" $EMAIL
	echo $'\n'
	FinalShell
	exit
fi

if [ $NUMREGERR -gt 0 ] ; then
	pMessage "Se procede a generar archivos con registros errados"
	ESTADO=$(RetornaRegErr ${FILE_ERR})

	cat $FILE_ERR >> $FILE_LOG

	if [ $ESTADO -ne 1 ] ; then
		rm -f $FILE_ERR
		pMessage "Hora y Fecha: $FECHA_TIEMPO"
		pMessage "Error: Ocurrió un error en la ejecución del procedure de consulta de registros errados: ${PCLUB_OW}.PKG_CC_PTOSTFI.ADMPSS_ENO_RECARGA. Contacte al administrador."$'\n' 
		pMessage "A continuación se enviará un correo a $EMAIL con el asunto: Consulta de registros errados de no recarga ClaroClub Prepago TFI – Error al ejecutar el procedure" 
		pMessage "Verifique el log para mayor detalle $FILE_LOG"$'\n'
		pMessage "Terminó subproceso"
		pMessage "************************************" 
		echo "Error al ejecutar el procedure Consulta de registros errados de no recarga ClaroClub Prepago TFI: ${PCLUB_OW}.PKG_CC_PTOSTFI.ADMPSS_ENO_RECARGA" | mail -s "Consulta de registros errados de no recarga ClaroClub Prepago TFI – Error al ejecutar el procedure" $EMAIL
		echo $'\n'
		FinalShell
		exit
	else 
		pMessage "Hora y Fecha: $FECHA_TIEMPO"
		pMessage "Existen $NUMREGERR registros errados de no recarga ClaroClub Prepago TFI."
		pMessage "A continuación se enviará un correo a $EMAIL con el asunto: Registros errados de no recarga ClaroClub Prepago TFI" 
		pMessage "Verifique el log para mayor detalle $FILE_ERR"$'\n'
		echo "Existen $NUMREGERR registros errados de no recarga ClaroClub Prepago TFI. Verifique el log para mayor detalle $FILE_ERR" | mail -s "Registros errados de no recarga ClaroClub Prepago TFI" $EMAIL
		echo $'\n'
	fi	
fi

pMessage "El proceso de eliminación de puntos culminó satisfactoriamente"
pMessage "*************************************************************" 
pMessage "Verifique el log para mayor detalle $FILE_LOG"
pMessage "*************************************************************" 
FinalShell
exit
