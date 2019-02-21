#!/bin/sh -x
#*************************************************************
#Programa        : SH007_BONO_VCTOPTOS.sh
#Descripción     : Dar de baja los bonos que no son de fidelizacion
#Fecha Creación  : 09/08/2013
#Usuario Creación: E78671
#Correo Creación : lherrera@cosapisoft.com.pe
#*************************************************************

# Inicialización de Variables
. /home/usrclaroclub/CLAROCLUB/Interno/Prepago/Bin/.varset
. /home/usrclaroclub/CLAROCLUB/Interno/Prepago/Bin/.passet
. /home/usrclaroclub/CLAROCLUB/Interno/Prepago/Bin/.mailset

#VARIABLES 
FECHA_HORA=`date +%Y%m%d_%H%M%S`
USER_SERV=`whoami`
IP_SERV=`cat /etc/sysconfig/network-scripts/ifcfg-eth0|grep IPADDR|sed 's/^[A-Z].*=//'`
USER_PROC="USRBONOVCTO"
PREF_SHELL="SH007_"
DESC_PROCESO="Vencimiento de puntos por BONO"
ASUN_MAIL="ERROR: $DESC_PROCESO"
SLDO_MAIL="\n\nPor favor atender este inconveniente. \nGracias"
NOM_ARCH="VCTO_PTOS"

#VARIABLES ARCHIVOS
FILE_CONE=$DIRENTRADA/${PREF_SHELL}CONE${NOM_ARCH}_$FECHA_HORA.tmp
FILE_PROC=$DIRENTRADA/${PREF_SHELL}PROC${NOM_ARCH}_$FECHA_HORA.tmp
FILE_LOG=$DIRLOG/${PREF_SHELL}${NOM_ARCH}_$FECHA_HORA.log
FILE_ERR=$DIRERR/${PREF_SHELL}${NOM_ARCH}_ERR_$FECHA_HORA.err
EMAIL=$IT_OPERADOR
ASUNTO_MAIL="Status de ejecucion de Baja de Bonos de no fidelizacion"

#FUNCIONES
pMessage () {
LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
echo "($LOGDATE) $*" 
echo "($LOGDATE) $*"  >> $FILE_LOG
}

InicioShell(){
pMessage "-------------------------------------------------------"
pMessage "|      INICIANDO VENCIMIENTO DE PUNTOS POR BONO       |"
pMessage "-------------------------------------------------------"
pMessage "   Fecha y Hora   |  `date +'%d-%m-%Y %H:%M:%S'`       "
pMessage "   Usuario        |   $USER_SERV                       "
pMessage "   Shell          |   $0                               "
pMessage "   Ip             |   $IP_SERV      	  	             "
pMessage "-------------------------------------------------------"
}

FinalShell(){
pMessage "-------------------------------------------------------"
pMessage "|     FINALIZANDO VENCIMIENTO DE PUNTOS POR BONO      |"
pMessage "-------------------------------------------------------"
pMessage "   Fecha y Hora   |   `date +'%d-%m-%Y %H:%M:%S'`      "
pMessage "   Usuario        |   $USER_SERV                       "
pMessage "   Shell          |   $0                               "
pMessage "   Ip             |   $IP_SERV      	  	             "
pMessage "-------------------------------------------------------"
}

ValidConex(){
#Procedimiento para validar conexion a base de datos
# 1  hay conexion
# -1 No existe conexion
USUARIO=$1
PASSWOR=$2
BASEDAT=$3
FILECON=$4

sqlplus -s $USUARIO/$PASSWOR@$BASEDAT <<EOP >$FILECON
WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET pagesize 0
SET linesize 400
SET SPACE 0
SET feedback off
SET trimspool on
SET termout off
SET heading off
SET verify off
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
	FECHAHORA varchar2(20);
	BEGIN
	SELECT TO_CHAR(SYSDATE,'YYYY.MM.DD HH24:mm:ss') INTO FECHAHORA
	FROM DUAL;
	DBMS_OUTPUT.PUT_LINE(FECHAHORA);
	EXCEPTION
		WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('ORA-99999 ERROR DE TRANSACCION');
	END;
/
EXIT
EOP
#Validar la conexion con el servidor de BD
RETORNOS=-1 
RETORNOS=$(ValidaError $FILECON)
echo $RETORNOS
}

Send_Email(){ 
# 
#Funcion para el envio de correos al IT_OPERADOR
# DIRECCION  = Destinatario
# ASUNTO     = Asunto del email
# MENSAJE    = Cuerpo del email
# ARCHIVO		 = Archivo Adjunto si no se envia sera -
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

ValidaError(){
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

ProcesarVencimiento(){
#Funcion encargada de dar de baja los puntos por bono por vencer
OUTPUT=$1  #Archivo Log de transacciones
USR_PROC=$2
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

  V_TOT_PROC NUMBER;
  V_TOT_EXI NUMBER;
  V_TOT_ERR NUMBER;
  V_CODERROR NUMBER;
  V_DESCERROR VARCHAR2(250);

BEGIN

  $PCLUB_OW.PKG_CC_BONOS.ADMPSI_PREVENCPTOBONO('$USR_PROC',V_TOT_PROC, V_TOT_EXI,V_TOT_ERR,V_CODERROR,V_DESCERROR);

IF V_CODERROR = 0 THEN
  dbms_output.put_line(V_TOT_PROC||'|'||V_TOT_EXI||'|'||V_TOT_ERR);
ELSE
  dbms_output.put_line('Error: ORA-' || V_CODERROR || ' Msg: ' || V_DESCERROR);
END IF;

EXCEPTION
  WHEN OTHERS THEN
	dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
END;
/

EXIT
EOP
RETORNOS=-1 
RETORNOS=$(ValidaError $OUTPUT)
echo $RETORNOS
}

#################################
#INICIO DE VENCIMIENTO DE PUNTOS#
#################################
clear
InicioShell
ESTADOCON=$(ValidConex $USER_BD $CLAVE_BD $SID_BD $FILE_CONE)
if [ $ESTADOCON -ne 1 ]; then
	pMessage "No existe conexion con la base de datos $SID_BD"
	FinalShell
	exit
fi
pMessage "$DESC_PROCESO. El proceso puede durar varios minutos."
ESTADO=$(ProcesarVencimiento ${FILE_PROC} ${USER_PROC})
if [ $ESTADO -ne 1 ] ;then
  pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
  pMessage "ERROR: Ocurrió un error al procesar el vencimiento de puntos. Contacte al administrador."$'\n' 
  pMessage "A continuación se enviará un correo a $EMAIL con el asunto: Ocurrio un error en $DESC_PROCESO"
  pMessage "Verifique el log para mayor detalle $FILE_LOG"$'\n'
  pMessage "Terminó subproceso"
  pMessage "************************************" 
  echo -e "Error al ejecutar el procedure de $DESC_PROCESO: ${PCLUB_OW}.PKG_CC_BONOS.ADMPSI_PREVENCPTOBONO" | mail -s "$ASUN_MAIL" $EMAIL
  echo $'\n'
  cat $FILE_PROC >> $FILE_LOG
	rm -f $FILE_PROC
	FinalShell
	exit
else
	if [ -f $FILE_PROC ]; then 
		REGISTRO=`head -1 ${FILE_PROC}`
		TOT_PROC==`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}'`
		TOT_EXI==`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $2}'`
		TOT_ERR==`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $3}'`
		pMessage "Se obtuvo la cantidad de registros procesados, exitosos y erroneos"
		pMessage "Total de Registros Procesados: $TOT_PROC"
		pMessage "Total de Registros Exitosos: $TOT_EXI"
		pMessage "Total de Registros Erroneos: $TOT_ERR"
		#rm -f ${FILE_PROC}
		pMessage "*************************************************************" 
		pMessage "Verifique el log para mayor detalle $FILE_LOG"
		pMessage "*************************************************************" 
		FinalShell
		Send_Email "$IT_SOAP" "$ASUNTO_MAIL" "Resumen de Ejecucion" "$FILE_LOG"
		exit
	fi
fi
