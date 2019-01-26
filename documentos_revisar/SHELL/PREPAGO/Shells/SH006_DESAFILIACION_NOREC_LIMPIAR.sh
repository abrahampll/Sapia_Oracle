#!/bin/sh -x
#*************************************************************
#Programa      :  SH006_DESAFILIACION_NOREC_LIMPIAR.sh
#Autor         :  Moisés Jurado
#Descripción   :  Desafiliación por no recarga.
#Fecha Creación:  23/09/2015
#*************************************************************
#clear

# Inicializacion de Variables
HOME_GAT=/home/usrclaroclub/CLAROCLUB/Interno/Prepago
. $HOME_GAT/Bin/.varset
. $HOME_GAT/Bin/.mailset
. $HOME_GAT/Bin/.passet 
cd ${DIRSHELL}

FECHA_HORA=`date +'%Y%m%d%H%M%S'`
HORAINI=`date +'%H%M%S'`
FECHAHORA=`date +'%Y-%m-%d %H:%M:%S'`
EXTENCION=`date +'%Y%m%d%H%M%S'`
USER_SERV=`whoami`
IP_SERVID=`cat /etc/sysconfig/network-scripts/ifcfg-eth0|grep IPADDR|sed 's/^[A-Z].*=//'`

MSGE_IT_OPERADOR="Estatus de Limpiar Temporal de desaliacion de no recarga Inicial."
MAIL_CUERPO="Informacion de estado de ejecucion del Shell :$0"
COL=`echo "\033[40m\033[1;31m"`
NOR=`echo "\033[m"`

#-----------------------------------------------------------------------------
#--------------------------------VARIABLES------------------------------------
#-----------------------------------------------------------------------------
FILE_CONN_TMP=""
FILE_PING_TMP=""
FILE_LIST_FIL=""
FILE_RPTA_FTP=""
FIL_LOG=$DIRLOG/SH006_DESAFILIACION_NOREC_LIMPIAR_${EXTENCION}.log

#-----------------------------------------------------------------------------
#--------------------------------FUNCIONES------------------------------------
#-----------------------------------------------------------------------------

InterlTime() {

  
	_hour_1=`echo "$1" | cut -c1-2`
	_mins_1=`echo "$1" | cut -c3-4`
	_secs_1=`echo "$1" | cut -c5-6`
  
	_hour_2=`echo "$2" | cut -c1-2`
	_mins_2=`echo "$2" | cut -c3-4`
	_secs_2=`echo "$2" | cut -c5-6`
	
  _secs_3=`expr $_secs_2 - $_secs_1`
	
  if [ $_secs_3 -lt 0 ] ; 	then
		_secs_3=`expr $_secs_3 + 60`
		_mins_1=`expr $_mins_1 + 1`
	fi
	_mins_3=`expr $_mins_2 - $_mins_1`
  
	if [ $_mins_3 -lt 0 ] ;  then
		_mins_3=`expr $_mins_3 + 60`
		_hour_1=`expr $_hour_1 + 1`
	fi
  _hour_3=`expr $_hour_2 - $_hour_1`
  
  Horas=''
  Minut=''
  Segun=''
  if [ $_hour_3 -lt 10 ]; then
    Horas="0$_hour_3"
  else
    Horas="$_hour_3"
  fi
  
  if [ $_mins_3 -lt 10 ]; then
    Minut="0$_mins_3"
  else
    Minut="$_mins_3"
  fi
  
  if [ $_secs_3 -lt 10 ]; then
    Segun="0$_secs_3"
  else
    Segun="$_secs_3"
  fi
  
	echo "$Horas:$Minut:$Segun"
}

pMessage(){   
   LOGDATE="$FECHAHORA"
   echo -e $COL "[$LOGDATE] $*" $NOR
   echo "[$LOGDATE] $*"  >> ${FIL_LOG}
}

Send_Email() { 
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

IniciShell() {
  #Presentacion de  Inicio
	pMessage "------------------------------------------------------------------" 
	pMessage "          INICIANDO LIMPIAR TMP DESAFILIACION INI                       " 
	pMessage "Fecha y Hora    : ${FECHAHORA}                                    " 
	pMessage "Usuario         : $USER_SERV	      	                            " 
	pMessage "Shell           : $0                                              " 
	pMessage "Ip              : $IP_SERVID     	  	                            " 
	pMessage "------------------------------------------------------------------" 
}

FinalShell() {
  #Presentacion de  salida
  FECHAHORA=`date +'%Y-%m-%d %H:%M:%S'`
  HORAFIN=`date +'%H%M%S'`
  INTERVA=$(InterlTime $HORAINI $HORAFIN)
	pMessage "------------------------------------------------------------------" 
	pMessage "        FINALIZAR LIMPIAR TMP DESAFILIACION INI                         " 
	pMessage "Fecha y Hora    : ${FECHAHORA}                                    " 
	pMessage "Usuario         : $USER_SERV	      		                    " 
	pMessage "Shell           : $0                  	                    " 
	pMessage "Ip              : $IP_SERVID     	  	                        " 
	pMessage "Tiempo Ejecutado: $INTERVA       	  	                        " 
	pMessage "------------------------------------------------------------------"
}

ValidConex() {
#Sumary
#Procedimiento que nos permite validar si tenemos conexion a una base de datos
#aqui realizamos una consulta a la base de datos y obtemos la fecha de ella 
#si hay conexion imprimimos 1 (Hay conexion)
#imprimimos -1 (si no lo hay)
USUARIO=$1
PASSWOR=$2
BASEDAT=$3
FILECON=$4

sqlplus -s $USUARIO/$PASSWOR@$BASEDAT <<EOP>$FILECON
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
 RETORNOS=$(ValidaErro $FILECON)
 echo $RETORNOS
}

ValidaErro() {
#
# Funcion encarga de verificar el archivo respuesta de un proceso de base de datos
# y validar si contiene o no errores
#
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

GetNumRandom(){
 #Sumary
 #Permite generar valores aleatorios a fin de no tener repeticiones
 #en algun proceso
	echo `echo $RANDOM`
}

RemoveTemp(){
#Sumary
#Eliminar todos los archivos de tipo temporal (*.tmp) de un directorio
#
strRutaDir=$1
for file in $( find $strRutaDir -type f -name '*.tmp' | sort)
do
    if [ -f $file ] ; then
       rm $file
    fi
done
}

LimpiarTemporalDesafiliacionIni() {
#Sumary
#Procedimiento que nos permite validar si tenemos conexion a una base de datos
#aqui realizamos una consulta a la base de datos y obtemos la fecha de ella 
#si hay conexion imprimimos 1 (Hay conexion)
#imprimimos -1 (si no lo hay)
USUARIO=$1
PASSWOR=$2
BASEDAT=$3
FILEMIG=$4

sqlplus -s $USUARIO/$PASSWOR@$BASEDAT <<EOP>$FILEMIG
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
    declare 
  
  k_resultado number;
  k_coderror number;
  k_descerror varchar2(250);
 
 
  begin
   
    $PCLUB_OW.PKG_CC_PREPAGO.ADMPSI_DESAFI_LIMP(k_resultado,k_coderror,k_descerror);
    DBMS_OUTPUT.PUT_LINE(to_char(k_coderror) || '|' || k_descerror || '|' || to_char(k_resultado));                                        
  
end;
  /
  EXIT
EOP
 #Validar la conexion con el servidor de BD
 RETORNOS=-1 
 RETORNOS=$(ValidaErro $FILEMIG)
 echo $RETORNOS
}


############################################################
################ INICIO DE DESARROLLO SHELL ################
############################################################

IniciShell

#Verificando conexion con la base de datos
IDEN_FILE_TMP=$(GetNumRandom )
FILE_CONN_TMP=$DIRTMP/FILE_CONN_TMP_DESAFI_INI_$IDEN_FILE_TMP.tmp
pMessage "ValidConex"
RPTA_CONN=$(ValidConex $USER_BD $CLAVE_BD $SID_BD $FILE_CONN_TMP)
if [ $RPTA_CONN -eq 1 ]; then
	pMessage "Verificando conexion con la base de datos"
else
	pMessage "No existe conexion a la base de datos Claro Club"
	FinalShell
	Send_Email "$IT_DESAFILIACION" "$MSGE_IT_OPERADOR" "$MAIL_CUERPO" $FIL_LOG
	exit
fi


#Procediendo de limpieza de temporal de tmp
pMessage "Iniciando limpieza de tabla temporal ADMPT_TMP_PRESINRECARGA"
IDEN_FILE_TMP=$(GetNumRandom )
FILE_CLEAN_TMP=$DIRTMP/FILE_CLEAN_TMP_ALIN_INI_$IDEN_FILE_TMP.tmp

sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> ${FILE_CLEAN_TMP}
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

K_FEC_PRO  DATE;

K_TOT_REG  NUMBER;
K_TOT_PRO  NUMBER;
K_TOT_ERR  NUMBER;
  k_resultado number;
  k_coderror number;
  k_descerror varchar2(250);
BEGIN

$PCLUB_OW.PKG_CC_PREPAGO.ADMPSI_DESAFI_LIMP(k_resultado,k_coderror,k_descerror);
dbms_output.put_line(to_char(k_coderror) || '|' || k_descerror || '|' || to_char(k_resultado)); 
	
EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
 
END;
/

EXIT
EOP

VAR_EXITO=0
RPTA_MIG=$(ValidaErro $FILE_CLEAN_TMP)
if [ $RPTA_MIG -eq 1 ]; then
	PRIMERALINEA=`head -1 $FILE_CLEAN_TMP`
	CODIGOMSG=`echo $PRIMERALINEA | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}'`
	DESCMSG=`echo $PRIMERALINEA | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $2}'`
	RESULTADO=`echo $PRIMERALINEA | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $3}'`
	
	if [ $CODIGOMSG -eq 0 ]; then
	  if [ $RESULTADO -eq 0 ]; then
		  pMessage "El proceso de limpiar temporal de desafiliacion de no recarga culmino satisfactoriamente"
		  pMessage "Limpieza de tabla temporal ADMPT_TMP_PRESINRECARGA culminada."
		  VAR_EXITO=1
	  else
		  if [ $RESULTADO -eq 2 ]; then
			pMessage "No se encontraron registros en la tabla ADMPT_TMP_PRESINRECARGA."
		  else
				pMessage "Aun se encuentra procesando el proceso de desafiliacion de no recarga." 
				pMessage "A continuacion se enviara un correo a $IT_DESAFILIACION con el asunto PROCESO DE LIMPIEZA DE TEMPORAL DE DESAFILIACION DE NO RECARGA." 
				FinalShell
				Send_Email "$IT_DESAFILIACION" "PROCESO DE LIMPIEZA DE TEMPORAL DE DESAFILIACION DE NO RECARGA" "Aun se encuentra procesando la desafiliacion de no recarga." $FIL_LOG
				exit
		  fi
		
	  fi
	else
	  pMessage "La operación no fue exitosa: $DESCMSG" 
	fi
	FinalShell
	Send_Email "$IT_DESAFILIACION" "$MSGE_IT_OPERADOR" "$MAIL_CUERPO" $FIL_LOG
else
	pMessage "Ocurrieron errores al realizarse la limpieza de tmp."
	FinalShell
	Send_Email "$IT_DESAFILIACION" "$MSGE_IT_OPERADOR" "$MAIL_CUERPO" $FIL_LOG
	exit
fi

rm -f $FILE_CLEAN_TMP
rm -f $FILE_CONN_TMP

exit
