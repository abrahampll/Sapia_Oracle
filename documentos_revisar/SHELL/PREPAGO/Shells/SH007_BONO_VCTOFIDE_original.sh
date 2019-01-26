#!/bin/sh -x
#*************************************************************
#Programa        : SH007_VCTO_FIDEL.sh
#Descripción     : Vencer los puntos Bono de fidelizacion
#Fecha Creación  : 08/01/2014
#Usuario Creación: Henry Herrera Ch
#*************************************************************
# Inicialización de Variables
. /home/usrclaroclub/CLAROCLUB/Interno/Prepago/Bin/.varset
. /home/usrclaroclub/CLAROCLUB/Interno/Prepago/Bin/.passet
. /home/usrclaroclub/CLAROCLUB/Interno/Prepago/Bin/.mailset

###VARIABLES###
FECHAHORA=`date +'%Y-%m-%d %H:%M:%S'`
USER_SERV=`whoami`
NUIP_SERV=`cat /etc/sysconfig/network-scripts/ifcfg-eth0|grep IPADDR|sed 's/^[A-Z].*=//'`
ASUNTO_MAIL="STATUS VENCIMIENTO DE BONOS DE FIDELIZACION"

###FUNCIONES###
pMessage(){
  TYPEOUT=$1
	LOGFILE=$2
	LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
	if [ $TYPEOUT -eq 0 ]; then
    echo "[$LOGDATE] $3"  >> $LOGFILE
	else
		echo "[$LOGDATE] $3"
		echo "[$LOGDATE] $3"  >> $LOGFILE
	fi;
}

IniciShell(){
TYPEOUT=$1
FILLOGM=$2
	NROPROC=$3
	pMessage $TYPEOUT $FILLOGM "________________________________________________________________________"
	pMessage $TYPEOUT $FILLOGM "        INICIAR  VENCER LOS PUNTOS BONO : $NROPROC                      "  
	pMessage $TYPEOUT $FILLOGM "________________________________________________________________________"
	pMessage $TYPEOUT $FILLOGM "   FECHA Y HORA     | ${FECHAHORA}                             					"  
	pMessage $TYPEOUT $FILLOGM "   USUARIO          | $USER_SERV                               					" 
	pMessage $TYPEOUT $FILLOGM "   SHELL            | $0                                       					" 
	pMessage $TYPEOUT $FILLOGM "   NUM. IP          | $NUIP_SERV      	  	                    				" 
	pMessage $TYPEOUT $FILLOGM "________________________________________________________________________"
}

FinalShell(){
  #Presentacion de  salida
	TYPEOUT=$1
	FILLOGM=$2
	HORAINI=$3
	NROPROC=$4
  FECHAHORA=`date +'%Y-%m-%d %H:%M:%S'`
  HORAFIN=`date +'%H%M%S'`
  INTERVA=$(InterlTime $HORAINI $HORAFIN)
	pMessage $TYPEOUT $FILLOGM "________________________________________________________________________"
	pMessage $TYPEOUT $FILLOGM "        FINALIZAR VENCER LOS PUNTOS BONO : $NROPROC                     " 
	pMessage $TYPEOUT $FILLOGM "________________________________________________________________________"
	pMessage $TYPEOUT $FILLOGM "   FECHA Y HORA     | ${FECHAHORA}        		                          " 
	pMessage $TYPEOUT $FILLOGM "   USUARIO          | $USER_SERV	      			                          " 
	pMessage $TYPEOUT $FILLOGM "   SHELL            | $0                  		                          " 
	pMessage $TYPEOUT $FILLOGM "   IP               | $NUIP_SERV     	  			                          " 
	pMessage $TYPEOUT $FILLOGM "   TIEMPO EJECUTADO | $INTERVA       	  			                          " 
	pMessage $TYPEOUT $FILLOGM "________________________________________________________________________"
}

InterlTime(){

  # Arg_1 = HHMMSS
  # Arg_2 = HHM0MSS
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

GetNumSecuencial(){
 echo `date +'%Y%m%d%H%M%S%N'`
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
 RETORNOS=$(ValidaErro $FILECON)
 echo $RETORNOS
}

ValidaErro(){
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

EXEC_OBTENER_BONOS(){
USER=$1
PASS=$2
BASE=$3
FILE=$4
sqlplus -s $USER/$PASS@$BASE <<EOP >$FILE
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
  TYPE CURSOREF IS REF CURSOR;
	K_USUARIO		VARCHAR2(40):='$USER_VEFID';
	K_REGISTRO	NUMBER;
	K_CODERROR 	NUMBER;
	K_DESCERROR	VARCHAR2(400);
BEGIN
	$PCLUB_OW.PKG_CC_BONOS_P.ADMPSS_LST_CLIENTE_BONOS(K_USUARIO,K_REGISTRO,K_CODERROR,K_DESCERROR);
  IF K_CODERROR !=0 THEN
		DBMS_OUTPUT.PUT_LINE(TO_CHAR(K_CODERROR) ||'|' || K_DESCERROR);
  ELSE
		DBMS_OUTPUT.PUT_LINE(TO_CHAR(K_REGISTRO));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: '||TO_CHAR(SQLCODE)||' MSG: '||SQLERRM);
END;
/
EXIT
EOP
RETORNOS=-1 
RETORNOS=$(ValidaErro $FILE)
echo $RETORNOS
}

EXEC_ACTUALI_BONOS(){
USER=${USER_BD} 
PASS=${CLAVE_BD}
BASE=${SID_BD} 
PROC=$1
FILE=$2
sqlplus -s $USER/$PASS@$BASE <<EOP >$FILE
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
	K_NUME_PROCES	 NUMBER:=$PROC;
	K_CANT_PROCES	 NUMBER:=0;
  K_CANT_EXITOS  NUMBER:=0;
  K_CANT_ERRADO  NUMBER:=0;
  K_FLAG_EXITOS  NUMBER;
  K_MENS_TRANSA  VARCHAR2(400);
BEGIN
	$PCLUB_OW.PKG_CC_BONOS_P.ADMPSU_UPD_ENTREGA_BONOS(K_NUME_PROCES,K_CANT_PROCES,K_CANT_EXITOS,K_CANT_ERRADO,K_FLAG_EXITOS,K_MENS_TRANSA);
  IF K_FLAG_EXITOS <> 0 THEN
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(K_FLAG_EXITOS) ||'|' || K_MENS_TRANSA);
  ELSE
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(K_FLAG_EXITOS) ||'|' || K_MENS_TRANSA);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: '||TO_CHAR(SQLCODE)||' MSG: '||SQLERRM);
END;
/
EXIT
EOP
RETORNOS=`head -1 $FILE`
VALOR=`echo $RETORNOS | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}'`

#RETORNOS=$(ValidaErro $FILE)
echo $VALOR
}

NROPARAMETROS=$#
if [ $NROPARAMETROS -eq 0 ]; then
	###########################################################
	####################---PROCESO PADRE---####################
	###########################################################
	
	HORAINICIOP=`date +'%H%M%S'`
	NROIDENTIFI=$(GetNumSecuencial)
	FILELOG=$DIRLOG/SH007_LOGPADRE_$NROIDENTIFI.log #LOG  PARA EL PADRE
	FILEDATPADRE=$DIRTMP/SH007_FIDATPADRE_$NROIDENTIFI.dat #DATA PARA EL PADRE
	FILEVALCONNE=$DIRTMP/SH007_FICONEXIBD_$NROIDENTIFI.tmp
	#--------------------------------------------------------------------------
	FILELOGHIJ01=$DIRLOG/SH007_FILOGHIJ01_$NROIDENTIFI.log #LOG  PARA EL HIJO01
	FILELOGHIJ02=$DIRLOG/SH007_FILOGHIJ02_$NROIDENTIFI.log #LOG  PARA EL HIJO02
	FILELOGHIJ03=$DIRLOG/SH007_FILOGHIJ03_$NROIDENTIFI.log #LOG  PARA EL HIJO03	
	FILELOGHIJO4=$DIRLOG/SH007_FILOGHIJ04_$NROIDENTIFI.log #LOG  PARA EL HIJO04	
	FILELOGHIJO5=$DIRLOG/SH007_FILOGHIJ05_$NROIDENTIFI.log #LOG  PARA EL HIJO05	
	FILELOGHIJO6=$DIRLOG/SH007_FILOGHIJ06_$NROIDENTIFI.log #LOG  PARA EL HIJO06	
	FILELOGHIJO7=$DIRLOG/SH007_FILOGHIJ07_$NROIDENTIFI.log #LOG  PARA EL HIJO07	
	FILELOGHIJO8=$DIRLOG/SH007_FILOGHIJ08_$NROIDENTIFI.log #LOG  PARA EL HIJO08	
	FILELOGHIJO9=$DIRLOG/SH007_FILOGHIJ09_$NROIDENTIFI.log #LOG  PARA EL HIJO09	
	FILELOGHIJO10=$DIRLOG/SH007_FILOGHIJ010_$NROIDENTIFI.log #LOG  PARA EL HIJO010
	FILELOGHIJO11=$DIRLOG/SH007_FILOGHIJ011_$NROIDENTIFI.log #LOG  PARA EL HIJO011	
	FILELOGHIJO12=$DIRLOG/SH007_FILOGHIJ012_$NROIDENTIFI.log #LOG  PARA EL HIJO012	
	FILELOGHIJO13=$DIRLOG/SH007_FILOGHIJ013_$NROIDENTIFI.log #LOG  PARA EL HIJO013
	FILELOGHIJO14=$DIRLOG/SH007_FILOGHIJ014_$NROIDENTIFI.log #LOG  PARA EL HIJO014
	FILELOGHIJO15=$DIRLOG/SH007_FILOGHIJ015_$NROIDENTIFI.log #LOG  PARA EL HIJO015
	FILELOGHIJO16=$DIRLOG/SH007_FILOGHIJ016_$NROIDENTIFI.log #LOG  PARA EL HIJO016
	FILELOGHIJO17=$DIRLOG/SH007_FILOGHIJ017_$NROIDENTIFI.log #LOG  PARA EL HIJO017
	FILELOGHIJO18=$DIRLOG/SH007_FILOGHIJ018_$NROIDENTIFI.log #LOG  PARA EL HIJO018
	FILELOGHIJO19=$DIRLOG/SH007_FILOGHIJ019_$NROIDENTIFI.log #LOG  PARA EL HIJO019
	FILELOGHIJO20=$DIRLOG/SH007_FILOGHIJ020_$NROIDENTIFI.log #LOG  PARA EL HIJO020
	
  clear
	IniciShell 1 $FILELOG "00"
	##--------------------------
	pMessage 1 $FILELOG "Verificar conectividad de base de datos"
	STADOCONEX01=$(ValidConex $USER_BD $CLAVE_BD $SID_BD $FILEVALCONNE )                  #Estado conexion 
	if [ $STADOCONEX01 -eq -1 ] ; then
		pMessage 1 $FILELOG "No existe conectividad con la base de datos"
		FinalShell 1 $FILELOG $HORAINICIOP "00"
		Send_Email "$IT_SOAP" "$ASUNTO_MAIL" "No existe conectividad con la base de datos" "$FILELOG"
		exit
	else
		pMessage 1 $FILELOG "Conexion de base de datos exitosa"
	fi
	##--------------------------
	STADOOBTENE=$(EXEC_OBTENER_BONOS $USER_BD $CLAVE_BD $SID_BD $FILEDATPADRE)
	if [ $STADOOBTENE -eq -1 ]; then
		pMessage 1 $FILELOG "Error al generar la información de los clientes a entregar bonos"
		FinalShell 1 $FILELOG $HORAINICIOP "00"
		Send_Email "$IT_SOAP" "$ASUNTO_MAIL" "Error al generar la información de las linea a entregar el bono" "$FILELOG"
		exit
	else
		pMessage 1 $FILELOG "Obteniendo informacion de bonos a dar de baja"
	fi
	
	if [ -f $FILEDATPADRE ]; then
		NROLINEAS=`head -1  $FILEDATPADRE`
		NROLINEAS=${NROLINEAS:-0}
		if [ $NROLINEAS -eq 0 ]; then
			pMessage 1 $FILELOG "No se puede ejecutar no existe información a procesar"
			FinalShell 1 $FILELOG $HORAINICIOP "00"
			Send_Email "$IT_SOAP" "$ASUNTO_MAIL" "No se puede ejecutar no existe información a procesar" "$FILELOG"
			exit
		else
			pMessage 1 $FILELOG "Se procesaran $NROLINEAS registros a dar de baja"
		fi
	else
		pMessage 1 $FILELOG "No existe informacion de bonos de fidelidad a procesar"
		FinalShell 1 $FILELOG $HORAINICIOP "00"
		Send_Email "$IT_SOAP" "$ASUNTO_MAIL" "No se puede ejecutar no existe información a procesar" "$FILELOG"
		exit
	fi
	######################################
	if [ $NROLINEAS -ge 1 ]; then
		pMessage 1 $FILELOG "PROCESANDO HIJO 01 CON LOG : $FILELOGHIJ01"
		sh $DIRSHELL/SH007_BONO_VCTOFIDE.sh "01" 1 $FILELOGHIJ01 &	
	fi;
	######################################
	if [ $NROLINEAS -ge 2 ]; then
		pMessage 1 $FILELOG "PROCESANDO HIJO 02 CON LOG : $FILELOGHIJ02"
		sh $DIRSHELL/SH007_BONO_VCTOFIDE.sh "02" 2 $FILELOGHIJ02 &	
	fi;
	######################################
	if [ $NROLINEAS -ge 3 ]; then
		pMessage 1 $FILELOG "PROCESANDO HIJO 03 CON LOG : $FILELOGHIJ03"
		sh $DIRSHELL/SH007_BONO_VCTOFIDE.sh "03" 3 $FILELOGHIJ03 &	
	fi;
	######################################
	if [ $NROLINEAS -ge 4 ]; then
		pMessage 1 $FILELOG "PROCESANDO HIJO 04 CON LOG : $FILELOGHIJO4"
		sh $DIRSHELL/SH007_BONO_VCTOFIDE.sh "04" 4 $FILELOGHIJO4 &	
	fi;
	######################################
	if [ $NROLINEAS -ge 5 ]; then
		pMessage 1 $FILELOG "PROCESANDO HIJO 05 CON LOG : $FILELOGHIJO5"
		sh $DIRSHELL/SH007_BONO_VCTOFIDE.sh "05" 5 $FILELOGHIJO5 &	
	fi;
	######################################
	if [ $NROLINEAS -ge 6 ]; then
		pMessage 1 $FILELOG "PROCESANDO HIJO 06 CON LOG : $FILELOGHIJO6"
		sh $DIRSHELL/SH007_BONO_VCTOFIDE.sh "06" 6 $FILELOGHIJO6 &	
	fi;
	######################################
	if [ $NROLINEAS -ge 7 ]; then
		pMessage 1 $FILELOG "PROCESANDO HIJO 07 CON LOG : $FILELOGHIJO7"
		sh $DIRSHELL/SH007_BONO_VCTOFIDE.sh "07" 7 $FILELOGHIJO7 &	
	fi;
	######################################
	if [ $NROLINEAS -ge 8 ]; then
		pMessage 1 $FILELOG "PROCESANDO HIJO 08 CON LOG : $FILELOGHIJO8"
		sh $DIRSHELL/SH007_BONO_VCTOFIDE.sh "08" 8 $FILELOGHIJO8 &	
	fi;
  ######################################
	if [ $NROLINEAS -ge 9 ]; then
		pMessage 1 $FILELOG "PROCESANDO HIJO 09 CON LOG : $FILELOGHIJO9"
		sh $DIRSHELL/SH007_BONO_VCTOFIDE.sh "09" 9 $FILELOGHIJO9 &	
	fi;
	######################################
	if [ $NROLINEAS -ge 10 ]; then
		pMessage 1 $FILELOG "PROCESANDO HIJO 10 CON LOG : $FILELOGHIJO10"
		sh $DIRSHELL/SH007_BONO_VCTOFIDE.sh "10" 10 $FILELOGHIJO10 &	
	fi;
	######################################
	if [ $NROLINEAS -ge 11 ]; then
		pMessage 1 $FILELOG "PROCESANDO HIJO 11 CON LOG : $FILELOGHIJO11"
		sh $DIRSHELL/SH007_BONO_VCTOFIDE.sh "11" 11 $FILELOGHIJO11 &	
	fi;
	######################################
	if [ $NROLINEAS -ge 12 ]; then
		pMessage 1 $FILELOG "PROCESANDO HIJO 12 CON LOG : $FILELOGHIJO12"
		sh $DIRSHELL/SH007_BONO_VCTOFIDE.sh "12" 12 $FILELOGHIJO12 &	
	fi;
	######################################
	if [ $NROLINEAS -ge 13 ]; then
		pMessage 1 $FILELOG "PROCESANDO HIJO 13 CON LOG : $FILELOGHIJO13"
		sh $DIRSHELL/SH007_BONO_VCTOFIDE.sh "13" 13 $FILELOGHIJO13 &	
	fi;
	######################################
	if [ $NROLINEAS -ge 14 ]; then
		pMessage 1 $FILELOG "PROCESANDO HIJO 14 CON LOG : $FILELOGHIJO14"
		sh $DIRSHELL/SH007_BONO_VCTOFIDE.sh "14" 14 $FILELOGHIJO14 &	
	fi;
	######################################
	if [ $NROLINEAS -ge 15 ]; then
		pMessage 1 $FILELOG "PROCESANDO HIJO 15 CON LOG : $FILELOGHIJO15"
		sh $DIRSHELL/SH007_BONO_VCTOFIDE.sh "15" 15 $FILELOGHIJO15 &	
	fi;
	######################################
	if [ $NROLINEAS -ge 16 ]; then
		pMessage 1 $FILELOG "PROCESANDO HIJO 16 CON LOG : $FILELOGHIJO16"
		sh $DIRSHELL/SH007_BONO_VCTOFIDE.sh "16" 16 $FILELOGHIJO16 &	
	fi;
	######################################
	if [ $NROLINEAS -ge 17 ]; then
		pMessage 1 $FILELOG "PROCESANDO HIJO 17 CON LOG : $FILELOGHIJO17"
		sh $DIRSHELL/SH007_BONO_VCTOFIDE.sh "17" 17 $FILELOGHIJO17 &	
	fi;
	######################################
	if [ $NROLINEAS -ge 18 ]; then
		pMessage 1 $FILELOG "PROCESANDO HIJO 18 CON LOG : $FILELOGHIJO18"
		sh $DIRSHELL/SH007_BONO_VCTOFIDE.sh "18" 18 $FILELOGHIJO18 &	
	fi;
	######################################
	if [ $NROLINEAS -ge 19 ]; then
		pMessage 1 $FILELOG "PROCESANDO HIJO 19 CON LOG : $FILELOGHIJO19"
		sh $DIRSHELL/SH007_BONO_VCTOFIDE.sh "19" 19 $FILELOGHIJO19 &	
	fi;
	######################################
	if [ $NROLINEAS -ge 20 ]; then
		pMessage 1 $FILELOG "PROCESANDO HIJO 20 CON LOG : $FILELOGHIJO20"
		sh $DIRSHELL/SH007_BONO_VCTOFIDE.sh "20" 20 $FILELOGHIJO20 &	
	fi;
	
	######################################
	FinalShell 1 $FILELOG $HORAINICIOP "00"
	##FALTA ENVIO SMS
	Send_Email "$IT_SOAP" "$ASUNTO_MAIL" "Proceso Padre" "$FILELOG"
	exit
else
	###########################################################
	####################---PROCESO HIJOS---####################
	###########################################################
	HORCHI=`date +'%H%M%S'`
	IDENTI=$1
	PROCES=$2
	FILLOG=$3
	RTOTAL=0
	REXITO=0
	RERRAD=0
	##--------------------------
	IniciShell 0 $FILLOG "$IDENTI"
	##--------------------------
	IDENTEMP=$(GetNumSecuencial)
	FILETMP=$DIRTMP/"SH007_${IDENTI}_${IDENTEMP}.tmp"
	STADOUPDATE=$(EXEC_ACTUALI_BONOS $PROCES $FILETMP)
	if [ $STADOUPDATE -eq 0 ]; then
		REGRESUMEN=`head -1 $FILETMP`
		LINEAVALID=`echo $REGRESUMEN | tr -d ' '`
		if [ "$LINEAVALID" != "" ]; then
			TOTAREG=`echo $REGRESUMEN | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}'`
			GOODREG=`echo $REGRESUMEN | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $2}'`
			BADSREG=`echo $REGRESUMEN | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $3}'`
			pMessage 0 $FILLOG "Total de registros procesados : $TOTAREG"
			pMessage 0 $FILLOG "Total de registros exitosos   : $GOODREG"
			pMessage 0 $FILLOG "Total de registros errados    : $BADSREG"
		fi
		FinalShell 0 $FILLOG $HORCHI "$IDENTI"
		Send_Email "$IT_SOAP" "$ASUNTO_MAIL PROCESO $IDENTI" "FIN DE PROCESO $IDENTI" "$FILLOG"
		exit
	else
		MENSAJE=`echo $FILETMP | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $2}'`
              pMessage 1 $FILLOG $MENSAJE
		FinalShell 0 $FILLOG $HORCHI "$IDENTI"
		Send_Email "$IT_SOAP" "$ASUNTO_MAIL PROCESO $IDENTI" "FIN DE PROCESO $IDENTI" "$FILLOG"
		exit
	fi
fi
