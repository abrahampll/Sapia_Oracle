#!/bin/sh -x
#*************************************************************
#Programa        : SH009_ACT_CLIENTE
#Descripción     : Actualizacion Cliente Postpago
#Fecha Creación  : 21/10/2013
#Usuario Creación: Evelyn Sosa Cabillas
#Correo Creación : E77988@claro.com.pe
#*************************************************************

# Inicialización de Variables
. /home/usrclaroclub/CLAROCLUB/Interno/Postpago/Bin/.varset
. /home/usrclaroclub/CLAROCLUB/Interno/Postpago/Bin/.passet
. /home/usrclaroclub/CLAROCLUB/Interno/Postpago/Bin/.mailset

cd ${DIRSHELL}

#VARIABLES 
FECHA_HORA=`date +%Y%m%d_%H%M%S`
USER_SERV=`whoami`
IP_SERV=`cat /etc/sysconfig/network-scripts/ifcfg-eth0|grep IPADDR|sed 's/^[A-Z].*=//'`
USER_PROC=`whoami`
PREF_SHELL="SH009_"
NOMB_SHELL="ACT_CLIENTE"
NOMB_ARCH="ACT_CLIENTE"
DESC_PROCESO="Actualizacion de Datos de Clientes Postpago"
ASUN_MAIL="ERROR: $DESC_PROCESO"
ASUN_MAIL_REP="Actualización de datos del cliente móvil postpago Registros que no se procesaron"
SLDO_MAIL="\n\nPor favor atender este inconveniente. \nGracias"
CONT_MSJE_ERR="Buen día, se adjunta archivo con el detalle de los cliente que no se procesaron."
LINEA1="Proceso: ACTUALIZACIÓN DE DATOS DEL CLIENTE MÓVIL POSTPAGO."
LINEA2="Saludos."


#VARIABLES ARCHIVOS
FILE_REPORTE=${PREF_SHELL}CLIENTE_$FECHA_HORA.dat
FILE_CLIENTE=$DIRTMP/${FILE_REPORTE}
FILE_DATOS=$DIRTMP/${PREF_SHELL}PARAMETRO_$FECHA_HORA.dat
FILE_LOG=$DIRLOGPOST/${PREF_SHELL}${NOMB_SHELL}_$FECHA_HORA.log
FILE_BAD=$DIRFALLOSPOST/${PREF_SHELL}${NOMB_SHELL}_$FECHA_HORA.bad
FILE_ERR=$DIRERROR/${PREF_SHELL}${NOMB_SHELL}_$FECHA_HORA.err
FILE_FINAL=$DIRTMP/${PREF_SHELL}${NOMB_SHELL}_$FECHA_HORA.tmp
FILE_CTL=$DIRCONTROLPOST/CTL001_${NOMB_ARCH}.ctl
CTRL_LOG=$DIRLOGPOST/CTL001_${NOMB_ARCH}_$FECHA_HORA.log
EMAIL=$IT_SOAP

#-----------------------------------------------------------------
#	FUNCION PARA MANEJO DEL LOG
#-----------------------------------------------------------------
pMessage () {   
   LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
   echo "($LOGDATE) $*" 
   echo "($LOGDATE) $*"  >> $FILE_LOG
} # pMessage	

InicioShell(){
pMessage "-------------------------------------------------------"
pMessage "|        INICIANDO ACTUALIZACION CLIENTE POSTPAGO        |"
pMessage "-------------------------------------------------------"
pMessage "   Fecha y Hora   |      `date +'%d-%m-%Y %H:%M:%S'`   "
pMessage "   Usuario        |      $USER_SERV                    "
pMessage "   Shell          |      $0                            "
pMessage "   Ip             |      $IP_SERV      	  	         "
pMessage "-------------------------------------------------------"
}

FinalShell(){
pMessage "-------------------------------------------------------"
pMessage "|       FINALIZANDO ACTUALIZACION CLIENTE POSTPAGO         |"
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

ActualizarClientes() {
#Función encargada de Actualizar los clientes postpago

OUTPUT=$1  

#Archivo Log de transacciones

sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> $OUTPUT
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

K_TIPO_CODE  VARCHAR2(2) :='2';
K_USUARIO VARCHAR(20):='usrActDatPost';
K_CODERROR  NUMBER; 
K_DESCERROR  VARCHAR2(100);
K_TOT_REG  NUMBER;
K_TOT_PRO  NUMBER;
K_TOT_ERR  NUMBER;

BEGIN

$PCLUB_OW.PKG_CC_TRANSACCION.ADMPU_ACT_MASIVA(K_TIPO_CODE,K_USUARIO,K_CODERROR,K_DESCERROR,K_TOT_REG,K_TOT_PRO,K_TOT_ERR);	

dbms_output.put_line(K_CODERROR || '|' || K_DESCERROR || '|' || K_TOT_REG || '|' || K_TOT_PRO || '|' || K_TOT_ERR);	

EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
 
END;
/

EXIT
EOP

RETORNOS=-1 
RETORNOS=$(ValidaError $OUTPUT)
echo $RETORNOS 
}

ObtenerClientesErrorProceso() {

OUTPUT=$1

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

C_NUM_DOC  VARCHAR2(50);
C_NOMBRE VARCHAR2(1000);
C_APELLIDO VARCHAR2(1000);
C_TIPO_DOC VARCHAR2(20);
C_MSJE VARCHAR2(400);
C_DOC VARCHAR2(15);
V_CUR_CLIENTE SYS_REFCURSOR;
C_NUM_PHONE VARCHAR2(20);

BEGIN

	OPEN V_CUR_CLIENTE FOR	
		SELECT P.ADMPV_COD_CLIENTE,
			P.ADMPV_FIRST_NAME,
			P.ADMPV_LAST_NAME,
			P.ADMPV_NUM_DOC,
			P.ADMPV_TIPO_DOC,
			P.ADMPV_MSJE_ERROR,
			P.ADMPV_NUM_PHONE
		FROM $PCLUB_OW.ADMPT_IMP_ACTCLIENTES_POST P
		WHERE P.ADMPV_COD_ERROR is not null AND P.ADMPD_FEC_REG>= TRUNC(SYSDATE);
	FETCH V_CUR_CLIENTE INTO C_NUM_DOC, C_NOMBRE, C_APELLIDO,C_DOC,C_TIPO_DOC, C_MSJE,C_NUM_PHONE ;
		WHILE V_CUR_CLIENTE%FOUND LOOP
	  dbms_output.put_line(C_NUM_PHONE ||'|'|| C_NUM_DOC||'|'||C_NOMBRE||'|'||C_APELLIDO||'|'||C_DOC||'|'||C_TIPO_DOC||'|'||C_MSJE);
	  FETCH V_CUR_CLIENTE INTO C_NUM_DOC, C_NOMBRE, C_APELLIDO,C_DOC,C_TIPO_DOC,C_MSJE,C_NUM_PHONE;
		END LOOP;
    CLOSE V_CUR_CLIENTE;
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


Send_Email() { 
# 
#Funcion para el envio de correos al IT_OPERADOR
# DIRECCION  = Destinatario
# ASUNTO     = Asunto del email
# MENSAJE    = Cuerpo del email
# ARCHIVO    = Archivo Adjunto si no se envia sera -
#
  DIRECCION="$1" 
  ASUNTO="" 
  MENSAJE="" 
  if [ $# -ge 2 ]; then 
    if [ "$2" != "-" ]; then 
      ASUNTO="$2" 
    fi 
  fi 
  if [ $# -ge 3 ]; then 
    if [ "$3" != "-" ]; then 
      MENSAJE="$3" 
    fi 
  fi 
  ADJUNTO="" 
  if [ $# -ge 4 ]; then 
    if [ "$4" != "-" ]; then 
      ADJUNTO="$4" 
    fi 
	fi 
  ( 
	echo "$MENSAJE"; 
    if [ "$ADJUNTO" != "" ]; then 
      archivo=`echo $ADJUNTO|cut -d'~' -f1` 
      nombre=`echo $ADJUNTO|cut -d'~' -f2` 
      if [[ "$archivo" == "$nombre" || "$nombre" == "" ]]; then 
        nombre=`basename $archivo` 
      fi 
      if [ -f "$archivo" ]; then 
        uuencode "$archivo" "$nombre"; 
      fi 
    fi; 
  ) |  mailx -s "$ASUNTO" "$DIRECCION" 
}
#########################################
#INICIO DE ACTUALIZACION CLIENTE POSTPAGO
#########################################

clear
InicioShell

pMessage "Se procede a procesar $DESC_PROCESO. El proceso puede durar varios minutos."
#pMessage "SubProceso 1: Obteniendo Datos de Clientes Postpago."

#ESTADO=$(ObtenerDatosPostpago ${FILE_DATOS})

#if [ $ESTADO -ne 1 ] ; then
#	pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
#	pMessage "ERROR: Ocurrió un error en la ejecución del procedure de $DESC_PROCESO"
#	pMessage "A continuación se enviará un correo a $EMAIL con el asunto: $ASUN_MAIL"
#	pMessage "Verifique el log para mayor detalle $FILE_LOG"
#	pMessage "Terminó subproceso"
#	pMessage "************************************" 
#	echo -e "Error al ejecutar el procedure de $DESC_PROCESO: ${SLDO_MAIL}" | mail -s "$ASUN_MAIL" $EMAIL	
#	echo $'\n'
#	cat $FILE_DATOS >> $FILE_ERR
#	cat $FILE_DATOS >> $FILE_LOG	
#	FinalShell
#	exit
#fi

#CANT_DATA=`cat ${FILE_DATOS} | wc -l | sed 's/ //g'`

#if [ $CANT_DATA -eq 0 ] ; then
#	pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
#	pMessage "No existen datos para procesar." 
#	echo $'\n'
#	FinalShell
#	exit
#fi

#FILECTL=`find $FILE_CTL`

#if [ "$FILECTL" = "" ] ; then
#	pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
#	pMessage "ERROR: No se encontró el archivo de Control de $DESC_PROCESO $FILE_CTL en la carpeta $DIRCONTROLPOST."
#	pMessage "A continuación se enviará un correo a $EMAIL con el asunto: $ASUN_MAIL"
#	pMessage "Terminó subproceso"
#	pMessage "************************************"
#	echo -e "No se encontró el archivo $FILE_CTL en la carpeta $DIRCONTROLPOST.${SLDO_MAIL}" | mail -s "$ASUN_MAIL" $EMAIL
#	echo $'\n'
#	FinalShell
#	exit
#fi

#pMessage "SubProceso 2: Se procede a importar los datos del archivo de entrada a la tabla de $DESC_PROCESO"

#ESTADO=$(ImportaArchivo ${FILE_CTL} ${FILE_DATOS} ${FILE_BAD} ${CTRL_LOG})

#if [ $ESTADO -ne 1 ] ; then
#	pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
#	pMessage "ERROR: Ocurrió un error al ejecutar el SQL Loader. Contacte al administrador."		
#	pMessage "A continuación se enviará un correo a $EMAIL con el asunto: $ASUN_MAIL" 		
	
#	FILEBAD=`find ${FILE_BAD}`
#	if [ "$FILEBAD" = "" ] ; then
#		pMessage "Verifique el log para mayor detalle $CTRL_LOG"
#		echo -e "SQL Loader falló por conectividad. Verifique el log para mayor detalle $CTRL_LOG.${SLDO_MAIL}" | mail -s "$ASUN_MAIL" $EMAIL
#	else
#		pMessage "Verifique el log para mayor detalle $FILE_BAD"
#		echo -e "Los registros no se cargaron correctamente. Verifique el log para mayor detalle $FILE_BAD.${SLDO_MAIL}" | mail -s "$ASUN_MAIL" $EMAIL
#	fi
	
#	cat $CTRL_LOG >> $FILE_LOG
#	pMessage "El proceso de importación culminó con errores."
#	pMessage "**********************************************" 	    
#else
#	pMessage "El proceso de importación culminó satisfactoriamente."
#	pMessage "*****************************************************" 	    
#fi

pMessage "Proceso 1: Se procede con la actualización de los clientes en ClaroClub"
ESTADO=$(ActualizarClientes ${FILE_FINAL})  

if [ $ESTADO -ne 1 ] ; then
	pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
	pMessage "ERROR: Ocurrió un error en la ejecución del procedure de $DESC_PROCESO: ${PCLUB_OW}.PKG_CC_TRANSACCION.ADMPU_ACT_MASIVA."
	pMessage "Verifique el log para mayor detalle $FILE_LOG"
	pMessage "Terminó subproceso"
	pMessage "************************************"
	cat $FILE_FINAL >> $FILE_ERR
	cat $FILE_FINAL >> $FILE_LOG
	echo -e "Ocurrió un error en $DESC_PROCESO. ${SLDO_MAIL}" | mail -s "$ASUN_MAIL" $EMAIL
	FinalShell
	exit
fi

while read FIELD01
do
CODERROR=`echo $FIELD01 | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}' `
DESERROR=`echo $FIELD01 | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $2}' `	
TOTALREG=`echo $FIELD01 | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $3}' `
TOTALEXIT=`echo $FIELD01 | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $4}' `
TOTALERR=`echo $FIELD01 | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $5}' `
done < $FILE_FINAL

if [ $CODERROR -eq 36 ]; then
	pMessage "No existen datos ha procesar "
	FinalShell
	exit
 
fi
if [ $TOTALERR -gt 0 ]; then
pMessage "Se encontro $TOTALERR cliente(s) procesado(s) incorrectamente"
ESTADO=$(ObtenerClientesErrorProceso ${FILE_CLIENTE}) 

if [ $ESTADO -ne 1 ] ; then
	pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
	pMessage "ERROR: Ocurrió un error al obtener los clientes procesados incorrectamente."
	pMessage "Verifique el log para mayor detalle $FILE_LOG"
	pMessage "Terminó subproceso"
	pMessage "************************************"
	cat $FILE_CLIENTE >> $FILE_ERR
	cat $FILE_CLIENTE >> $FILE_LOG
	echo -e "Ocurrió un error al obtener los clientes procesados incorrectamente. ${SLDO_MAIL}" | mail -s "$ASUN_MAIL" $EMAIL
	FinalShell
	exit
fi
cd $DIRTMP
FILE_FINAL_ZIP=${PREF_SHELL}${NOMB_SHELL}_$FECHA_HORA.zip

zip ${FILE_FINAL_ZIP} ${FILE_REPORTE} > /dev/null
EXITSTAT=$?
if 	[ $EXITSTAT -gt 0 ] ; then
	echo "Ocurrió un error al ejecutar el comando zip ${FILE_FINAL_ZIP} ${FILE_FINAL}">> $FILE_ERR
	cat $FILE_ERR >> $FILE_LOG
else
	pMessage "El proceso termino con errores."
	pMessage "Se enviara un Correo a $EMAIL con las líneas no actualizadas"
	FILE_TMP_MSJE=${DIRTMP}/FILE_$RANDOM.LOG
	echo $CONT_MSJE_ERR > $FILE_TMP_MSJE
	echo $LINEA1 >>$FILE_TMP_MSJE
	echo "     " >> $FILE_TMP_MSJE
	echo $LINEA2 >> $FILE_TMP_MSJE
	echo $FILE_TMP_MSJE
	CONT_MSJE_ERR=`cat $FILE_TMP_MSJE`
	Send_Email "$EMAIL" "$ASUN_MAIL_REP" "$CONT_MSJE_ERR" "${DIRTMP}/${FILE_FINAL_ZIP}"
	if [ -f $FILE_TMP_MSJE ]; then
	  rm -f $FILE_TMP_MSJE
	fi 
	mv -f ${DIRTMP}/${FILE_FINAL_ZIP} $DIRERROR 
fi
else
	pMessage "El proceso termino satisfactoriamente"
fi 

pMessage "*************************************************************" 
pMessage "Verifique el log para mayor detalle $FILE_LOG"
pMessage "*************************************************************" 
FinalShell
			
exit


