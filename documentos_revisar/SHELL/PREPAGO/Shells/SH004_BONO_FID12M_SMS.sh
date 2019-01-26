#!/bin/sh -x
#*************************************************************
#Programa        : SH004_BONO_FID12M_SMS.sh
#Descripción     : Envío de mensaje de bono de fidelidad 
#Fecha Creación  : 12/08/2013
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
NOMB_SHELL="BONO_FID12M_SMS"
DESC_PROCESO="Envío de mensajes por bono de fidelidad"
ASUN_MAIL="ERROR: $DESC_PROCESO"
SLDO_MAIL="\n\nPor favor atender este inconveniente. \nGracias"
FLAG_PROCESO="BONO"
TIPO_BONO_FIDEL="A"
NOMB_ARCH="BONO_FID12M"
EXTE_ARCH=".CCL"
IDEN_MENSAJE="MSJENTBONPLANFID12"
PRMT_HORINIENV="HORA_INICIO_ENVIO_SMS"
PRMT_HORFINENV="HORA_FIN_ENVIO_SMS"
PRMT_CANREGENV="CANT_REG_ENVIO_SMS"
PRMT_ARCH=$1

#VARIABLES ARCHIVOS
FILE_PRMHIN=$DIRENTRADA/${PREF_SHELL}PRMHIN_$FECHA_HORA.tmp
FILE_PRMHFI=$DIRENTRADA/${PREF_SHELL}PRMHFI_$FECHA_HORA.tmp
FILE_PRMCAN=$DIRENTRADA/${PREF_SHELL}PRMCAN_$FECHA_HORA.tmp
FILE_MENSAJ=$DIRENTRADA/${PREF_SHELL}MENSAJ_$FECHA_HORA.tmp
FILE_TOTLIN=$DIRENTRADA/${PREF_SHELL}TOTLIN_$FECHA_HORA.tmp
FILE_LINEAS=$DIRENTRADA/${PREF_SHELL}LINEAS_$FECHA_HORA.tmp
FILE_ACTEST=$DIRENTRADA/${PREF_SHELL}ACTEST_$FECHA_HORA.tmp
FILE_LOG=$DIRLOG/${PREF_SHELL}${NOMB_SHELL}_$FECHA_HORA.log
FILE_ERR=$DIRERROR/${PREF_SHELL}${NOMB_SHELL}_$FECHA_HORA.err
EMAIL=$IT_OPERADOR

pMessage () {
LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
echo "($LOGDATE) $*" 
echo "($LOGDATE) $*"  >> $FILE_LOG
}

InicioShell(){
pMessage "-------------------------------------------------------"
pMessage "|             INICIANDO ENVIO DE MENSAJES             |"
pMessage "-------------------------------------------------------"
pMessage "   Fecha y Hora   |      `date +'%d-%m-%Y %H:%M:%S'`   "
pMessage "   Usuario        |      $USER_SERV                    "
pMessage "   Shell          |      $0                            "
pMessage "   Ip             |      $IP_SERV      	  	         "
pMessage "-------------------------------------------------------"
}

FinalShell(){
pMessage "-------------------------------------------------------"
pMessage "|            FINALIZANDO ENVIO DE MENSAJES            |"
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

ParamHoraIni() {
#Función encargada de obtener la hora inicial de envío de SMS

OUTPUT=$1  #Archivo Log de transacciones

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

V_VALOR VARCHAR2(50);

BEGIN

SELECT ADMPV_VALOR INTO V_VALOR 
FROM PCLUB.ADMPT_PARAMSIST
WHERE ADMPV_DESC = '$PRMT_HORINIENV';

dbms_output.put_line(V_VALOR);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
	dbms_output.put_line('Error: ORA-XXX Msg: No está registrado el parámetro ' || '$PRMT_HORINIENV');
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

ParamHoraFin() {
#Función encargada de obtener la hora final de envío de SMS

OUTPUT=$1  #Archivo Log de transacciones

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

V_VALOR VARCHAR2(50);

BEGIN

SELECT ADMPV_VALOR INTO V_VALOR 
FROM PCLUB.ADMPT_PARAMSIST
WHERE ADMPV_DESC = '$PRMT_HORFINENV';

dbms_output.put_line(V_VALOR);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
	dbms_output.put_line('Error: ORA-XXX Msg: No está registrado el parámetro ' || '$PRMT_HORFINENV');
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

ParamCantReg() {
#Función encargada de obtener el cantidad de líneas por paquete a enviar

OUTPUT=$1  #Archivo Log de transacciones

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

V_VALOR VARCHAR2(50);

BEGIN

SELECT ADMPV_VALOR INTO V_VALOR 
FROM PCLUB.ADMPT_PARAMSIST
WHERE ADMPV_DESC = '$PRMT_CANREGENV';

dbms_output.put_line(V_VALOR);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
	dbms_output.put_line('Error: ORA-XXX Msg: No está registrado el parámetro ' || '$PRMT_CANREGENV');
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

ObtenerMensaje() {
#Función encargada de obtener el mensaje a enviar

OUTPUT=$1  #Archivo Log de transacciones

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

V_MENSAJE VARCHAR2(1000);
V_CODERROR NUMBER;
V_DESCERROR VARCHAR2(250); 

BEGIN

$PCLUB_OW.PKG_CC_ENVIO_SMS.ADMPSS_OBTENER_MENSAJE('$IDEN_MENSAJE',V_MENSAJE,V_CODERROR,V_DESCERROR);

IF V_CODERROR = 0 THEN
	dbms_output.put_line(V_MENSAJE);
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

TotalLineas() {
#Función encargada de obtener el número total de teléfonos

NOMARCH=$1 #Nombre del archivo
OUTPUT=$2  #Archivo Log de transacciones

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

V_TOTAL NUMBER;
V_CODERROR NUMBER;
V_DESCERROR VARCHAR2(250); 

BEGIN

$PCLUB_OW.PKG_CC_ENVIO_SMS.ADMPSU_IMP_BLACKLIST('$FLAG_PROCESO','$TIPO_BONO_FIDEL','$NOMARCH','$USER_PROC',V_TOTAL,V_CODERROR,V_DESCERROR);

IF V_CODERROR = 0 THEN
	dbms_output.put_line(V_TOTAL);
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

ProcesarLineas() {
#Función encargada de procesar las líneas

CANTREG=$1  #Cantidad de teléfonos a enviar
NOMBARCH=$2 #Nombre del archivo
OUTPUT=$3   #Archivo Log de transacciones

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

V_CUR_LINEA SYS_REFCURSOR;
V_ID NUMBER;
V_TELEFONO VARCHAR2(20);
V_CODERROR NUMBER;
V_DESCERROR VARCHAR2(250); 

BEGIN

$PCLUB_OW.PKG_CC_ENVIO_SMS.ADMPSS_OBTENER_TELEF_SMS('$FLAG_PROCESO','$CANTREG','$TIPO_BONO_FIDEL','$NOMBARCH',V_CUR_LINEA,V_CODERROR,V_DESCERROR);

IF V_CODERROR = 0 THEN
	LOOP
		FETCH V_CUR_LINEA INTO V_ID,V_TELEFONO;
		EXIT WHEN V_CUR_LINEA%NOTFOUND;
		dbms_output.put_line(V_TELEFONO);
	END LOOP;
	CLOSE V_CUR_LINEA;
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

ActualizarEstado() {
#Función encargada de actualizar el estado de los enviados

CANTREG=$1  #Cantidad de teléfonos a actualizar
NOMBARCH=$2 #Nombre del archivo
OUTPUT=$3   #Archivo Log de transacciones

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

BEGIN

$PCLUB_OW.PKG_CC_ENVIO_SMS.ADMPSU_IMP_ESTADOSMS('$FLAG_PROCESO',$CANTREG,'$TIPO_BONO_FIDEL','$NOMBARCH','$USER_PROC',V_CODERROR,V_DESCERROR);

IF V_CODERROR <> 0 THEN
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

#############################
#INICIO DE ENVIO DE MENSAJES#
#############################

clear
InicioShell

pMessage "Se procede a procesar $DESC_PROCESO. El proceso puede durar varios minutos."

pMessage "Proceso1: Obteniendo el parámetro que indica la hora inicial de envío de SMS."
ESTADO=$(ParamHoraIni ${FILE_PRMHIN})

if [ $ESTADO -ne 1 ] ; then
	pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
	pMessage "Error: Ocurrió un error al obtener el parámetro $PRMT_HORINIENV. Contacte al administrador."
	pMessage "A continuación se enviará un correo a $EMAIL con el asunto: $ASUN_MAIL"
	pMessage "Verifique el log para mayor detalle $FILE_LOG"
	pMessage "Terminó subproceso"
	pMessage "************************************" 
    echo -e "Error al obtener el parámetro $PRMT_HORINIENV. Verifique el log para mayor detalle $FILE_LOG.${SLDO_MAIL}" | mail -s "$ASUN_MAIL" $EMAIL
	echo $'\n'
	cat $FILE_PRMHIN >> $FILE_LOG
	rm -f $FILE_PRMHIN
	FinalShell
	exit
fi

REGISTRO=`head -1 ${FILE_PRMHIN}`
HORAINIENV=`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}' `
HORAINI=`echo $HORAINIENV | sed 's/\\r//g'|awk 'BEGIN{FS=":"} {print $1}' `
MINUINI=`echo $HORAINIENV | sed 's/\\r//g'|awk 'BEGIN{FS=":"} {print $2}' `
MINTOTHORINI=`expr $HORAINI \* 60 + $MINUINI`
rm -f $FILE_PRMHIN

pMessage "Se obtuvo el parámetro $PRMT_HORINIENV satisfactoriamente."
pMessage "Parámetro: $HORAINIENV"

HORACT=`date +%H`
MINACT=`date +%M`
MINTOTHORACT=`expr $HORACT \* 60 + $MINACT`
if [ $MINTOTHORINI -gt $MINTOTHORACT ] ; then
	pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
	pMessage "La hora actual está fuera del rango del tiempo mínimo de envío de SMS."
	pMessage "Terminó proceso"
	pMessage "*************************************************************" 
	pMessage "Verifique el log para mayor detalle $FILE_LOG"
	pMessage "*************************************************************" 
	FinalShell
	exit
fi

pMessage "Proceso2: Obteniendo el parámetro que indica la hora final de envío de SMS."
ESTADO=$(ParamHoraFin ${FILE_PRMHFI})

if [ $ESTADO -ne 1 ] ; then
        pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
	pMessage "Error: Ocurrió un error al obtener el parámetro $PRMT_HORFINENV. Contacte al administrador."
	pMessage "A continuación se enviará un correo a $EMAIL con el asunto: $ASUN_MAIL"
	pMessage "Verifique el log para mayor detalle $FILE_LOG"
	pMessage "Terminó subproceso"
	pMessage "************************************" 
    echo -e "Error al obtener el parámetro $PRMT_HORFINENV. Verifique el log para mayor detalle $FILE_LOG.${SLDO_MAIL}" | mail -s "$ASUN_MAIL" $EMAIL
	echo $'\n'
	cat $FILE_PRMHFI >> $FILE_LOG
	rm -f $FILE_PRMHFI
	FinalShell
	exit
fi

REGISTRO=`head -1 ${FILE_PRMHFI}`
HORAFINENV=`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}' `
HORAFIN=`echo $HORAFINENV | sed 's/\\r//g'|awk 'BEGIN{FS=":"} {print $1}' `
MINUFIN=`echo $HORAFINENV | sed 's/\\r//g'|awk 'BEGIN{FS=":"} {print $2}' `
MINTOTHORFIN=`expr $HORAFIN \* 60 + $MINUFIN`
rm -f $FILE_PRMHFI

pMessage "Se obtuvo el parámetro $PRMT_HORFINENV satisfactoriamente."
pMessage "Parámetro: $HORAFINENV"

pMessage "Proceso3: Obteniendo el parámetro que indica cada cuantos teléfonos se van a enviar mensajes."
ESTADO=$(ParamCantReg ${FILE_PRMCAN})

if [ $ESTADO -ne 1 ] ; then
	pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
	pMessage "ERROR: Ocurrió un error al obtener el parámetro $PRMT_CANREGENV. Contacte al administrador."
	pMessage "A continuación se enviará un correo a $EMAIL con el asunto: $ASUN_MAIL" 
	pMessage "Verifique el log para mayor detalle $FILE_LOG"
	pMessage "Terminó subproceso"
	pMessage "************************************" 
    echo -e "Error al obtener el parámetro $PRMT_CANREGENV. Verifique el log para mayor detalle $FILE_LOG.${SLDO_MAIL}" | mail -s "$ASUN_MAIL" $EMAIL
	echo $'\n'
	cat $FILE_PRMCAN >> $FILE_LOG
	rm -f $FILE_PRMCAN
	FinalShell
	exit
fi

REGISTRO=`head -1 ${FILE_PRMCAN}`
CANTREGENV=`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}' `
rm -f $FILE_PRMCAN

pMessage "Se obtuvo el parámetro $PRMT_CANREGENV satisfactoriamente."
pMessage "Parámetro: $CANTREGENV"

pMessage "Proceso4: Obteniendo el mensaje a enviar."
ESTADO=$(ObtenerMensaje ${FILE_MENSAJ})

if [ $ESTADO -ne 1 ] ; then
	pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
	pMessage "ERROR: Ocurrió un error al obtener el mensaje a enviar. Contacte al administrador."
	pMessage "A continuación se enviará un correo a $EMAIL con el asunto: $ASUN_MAIL" 
	pMessage "Verifique el log para mayor detalle $FILE_LOG"
	pMessage "Terminó subproceso"
	pMessage "************************************" 
    echo -e "Error al obtener el mensaje a enviar. Verifique el log para mayor detalle $FILE_LOG.${SLDO_MAIL}" | mail -s "$ASUN_MAIL" $EMAIL
	echo $'\n'
	cat $FILE_MENSAJ >> $FILE_LOG
	rm -f $FILE_MENSAJ
	FinalShell
	exit
fi

REGISTRO=`head -1 ${FILE_MENSAJ}`
MENSAJE=`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}' `
rm -f $FILE_MENSAJ

pMessage "Se obtuvo el mensaje a enviar satisfactoriamente."
pMessage "Mensaje: $MENSAJE"

if [ "$1" = "" ] ; then
	NOMBREARCHIVO=${NOMB_ARCH}_$FECHA_ARCH.CCL
else
    POSICION1=`awk -v a="${PRMT_ARCH}" -v b="${NOMB_ARCH}" 'BEGIN{print index(a,b)}' `
    POSICION2=`awk -v a="${PRMT_ARCH}" -v b="${EXTE_ARCH}" 'BEGIN{print index(a,b)}' `
	if [ $POSICION1 -ne 1 -o $POSICION2 -lt 1 ];then
		pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
		pMessage "Error: Nombre del archivo no cumple con el formato adecuado."
		FinalShell
		exit
	fi
	NOMBREARCHIVO=${PRMT_ARCH}
fi

pMessage "Nombre del archivo: $NOMBREARCHIVO"
pMessage "Proceso5: Obteniendo la cantidad de teléfonos."
ESTADO=$(TotalLineas ${NOMBREARCHIVO} ${FILE_TOTLIN})

if [ $ESTADO -ne 1 ] ; then
	pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
	pMessage "Error: Ocurrió un error al obtener la cantidad de teléfonos. Contacte al administrador."
	pMessage "A continuación se enviará un correo a $EMAIL con el asunto: $ASUN_MAIL" 
	pMessage "Verifique el log para mayor detalle $FILE_LOG"
	pMessage "Terminó subproceso"
	pMessage "************************************" 
    echo -e "Error al obtener la cantidad de teléfonos. Verifique el log para mayor detalle $FILE_LOG.${SLDO_MAIL}" | mail -s "$ASUN_MAIL" $EMAIL
	echo $'\n'
	cat $FILE_TOTLIN >> $FILE_LOG
	rm -f $FILE_TOTLIN
	FinalShell
	exit
fi

REGISTRO=`head -1 ${FILE_TOTLIN}`
TOTAL_LINEAS=`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}' `

pMessage "Se obtuvo la cantidad de teléfonos satisfactoriamente."
pMessage "Cantidad de teléfonos: $TOTAL_LINEAS"

if [ $TOTAL_LINEAS -eq 0 ] ; then
	pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
	pMessage "No existen teléfonos a quien enviar mensajes." 
	echo $'\n'
	rm -f $FILE_TOTLIN
	FinalShell
	exit
fi

CONTADOR=0
CONTLOOP=0
CONTITER=0
CONTREGVAL=0

while [ $CONTADOR -lt $TOTAL_LINEAS ]
do
	HORACT=`date +%H`
	MINACT=`date +%M`
	MINTOTHORACT=`expr $HORACT \* 60 + $MINACT`
	if [ $MINTOTHORACT -gt $MINTOTHORFIN ] ; then
		pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
		pMessage "La hora actual está fuera del rango del tiempo máximo de envío de SMS."
		pMessage "Terminó proceso"
		pMessage "*************************************************************" 
		pMessage "Verifique el log para mayor detalle $FILE_LOG"
		pMessage "*************************************************************" 
		FinalShell
		exit
	fi

        CONTITER=`expr $CONTITER + 1`
	pMessage "Proceso6: Obteniendo teléfonos. Iteración: $CONTITER"
	
	ESTADO=$(ProcesarLineas ${CANTREGENV} ${NOMBREARCHIVO} ${FILE_LINEAS})
	
	if [ $ESTADO -ne 1 ] ; then
		pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
		pMessage "Error: Ocurrió un error al obtener los teléfonos a quien enviar. Contacte al administrador." 
		pMessage "Terminó subproceso"
		pMessage "************************************" 
		cat $FILE_LINEAS >> $FILE_ERR
		cat $FILE_LINEAS >> $FILE_LOG
	else
		TELEFONOLISTA=''
		CONTLOOP=0
		while read FIELD01
		do
			TELEFONO=`echo $FIELD01 | sed 's/\\r//g'|awk 'BEGIN{FS=","} {print $1}' `
			TELEFONOLISTA=$TELEFONOLISTA","$TELEFONO
			CONTADOR=`expr $CONTADOR + 1`
			CONTLOOP=`expr $CONTLOOP + 1`
		done < $FILE_LINEAS

		${RUTA_JAVA}/java -jar ${RUTA_JAR}/EnviaSMS.jar ${FECHA_HORA} ${IP_SERV} ${USER_PROC} ${MENSAJE} ${IDENTIFICADOR} ${TELEFONOLISTA} ${RUTAWS}

		EXITSTAT=$?
		if [ $EXITSTAT -ne 0 ] ; then
			pMessage "Ocurrió un error al ejecutar el comando ${RUTA_JAVA}/java -jar ${RUTA_JAR}/EnviaSMS.jar">>$FILE_ERR
		else
			pMessage "Se enviaron mensajes a $CONTLOOP teléfonos."
			CONTREGVAL=`expr $CONTREGVAL + $CONTLOOP`
			
			pMessage "Proceso7: Actualizando el estado de teléfonos a quienes se enviaron mensajes. Iteración: $CONTITER"
			ESTADO=$(ActualizarEstado ${CANTREGENV} ${NOMBREARCHIVO} ${FILE_ACTEST})
			if [ $ESTADO -ne 1 ] ; then
				pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
				pMessage "Error: Ocurrió un error al actualizar el estado de teléfonos. Contacte al administrador."
				pMessage "Verifique el log para mayor detalle $FILE_LOG"
				pMessage "Terminó subproceso"
				pMessage "************************************" 
				cat $FILE_ACTEST >> $FILE_ERR
				cat $FILE_ACTEST >> $FILE_LOG
			fi
			rm -f ${FILE_ACTEST}
            sleep $SLEEP_SMS
		fi
	fi
        rm -f ${FILE_LINEAS}
done

CANTREGNOP=`expr $CONTADOR - $CONTREGVAL`

pMessage "Cantidad de teléfonos: $CONTADOR"
pMessage "Teléfonos enviados: $CONTREGVAL"
pMessage "Teléfonos no enviados: $CANTREGNOP"

if [ -e $FILE_ERR ] ; then 
	CANT_DATA=`cat $FILE_ERR | wc -l | sed 's/ //g'`
	if [ $CANT_DATA -ne 0 ] ; then
		pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
		pMessage "Error: El proceso $DESC_PROCESO generó errores."
		pMessage "A continuación se enviará un correo a $EMAIL con el asunto: $ASUN_MAIL" 
		echo -e "Verifique el log para mayor detalle $FILE_ERR.${SLDO_MAIL}" | mail -s "$ASUN_MAIL" $EMAIL
		pMessage "El proceso de $DESC_PROCESO culminó con errores."
	else
		pMessage "El proceso de $DESC_PROCESO culminó satisfactoriamente."
	fi
else
  pMessage "El proceso de $DESC_PROCESO culminó satisfactoriamente."
fi

pMessage "*************************************************************" 
pMessage "Verifique el log para mayor detalle $FILE_LOG"
pMessage "*************************************************************" 
FinalShell
exit
