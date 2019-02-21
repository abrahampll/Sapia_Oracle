#!/bin/sh -x
#*************************************************************
#Programa        : SH006_DESAFILIACION_NOREC
#Descripción     : Desafiliación por no recarga 
#Fecha Creación  : 06/08/2013
#Usuario Creación: Oscar Paucar
#Correo Creación : E75874@claro.com.pe
#*************************************************************

# Inicialización de Variables
. /home/usrclaroclub/CLAROCLUB/Interno/Prepago/Bin/.varset
. /home/usrclaroclub/CLAROCLUB/Interno/Prepago/Bin/.passet
. /home/usrclaroclub/CLAROCLUB/Interno/Prepago/Bin/.mailset

#VARIABLES 
FECHA_EJC=`date +%d/%m/%Y`
FECHA_HORA=`date +%Y%m%d_%H%M%S`
FECHA_ARCH=`date +%Y%m`
USER_SERV=`whoami`
IP_SERV=`cat /etc/sysconfig/network-scripts/ifcfg-eth0|grep IPADDR|sed 's/^[A-Z].*=//'`
USER_PROC="USRBANOREC"
PREF_SHELL="SH006_"
NOMB_SHELL="DESAFILIACION_NOREC"
DESC_PROCESO="Desafiliación por no recarga"
ASUN_MAIL="ERROR: $DESC_PROCESO"
SLDO_MAIL="\n\nPor favor atender este inconveniente. \nGracias"
NOMB_ARCH="DESAFIL_NORECARGA"
EXTE_ARCH=".CCL"
PRMT_ARCH=$1

#VARIABLES ARCHIVOS
DIRD_ARCHDOCU=$DIRDOCUMENTOSBAJA
DIRD_ARCHPROC=$DIRPROCESADOBAJA
FILE_CTL=$DIRCTL/CTL006_${NOMB_ARCH}.ctl
FILE_REGNOPROC=$DIRENTRADA/${PREF_SHELL}REGNOPROC_$FECHA_HORA.tmp
FILE_PROCESO=$DIRENTRADA/${PREF_SHELL}PROCESO_$FECHA_HORA.tmp
FILE_LOG=$DIRLOG/${PREF_SHELL}${NOMB_SHELL}_$FECHA_HORA.log
FILE_BAD=$DIRFALLOS/${PREF_SHELL}${NOMB_SHELL}_$FECHA_HORA.bad
FILE_ERR=$DIRERROR/${PREF_SHELL}${NOMB_SHELL}_$FECHA_HORA.err
CTRL_LOG=$DIRLOG/CTL006_${NOMB_SHELL}_$FECHA_HORA.log
EMAIL=$IT_OPERADOR

CANT_PRO=30
MSGE_IT_OPERADOR="PROCESO DE DESAFILIACION DE NO RECARGA "
MAIL_CUERPO="Se realizó el proceso de no recarga del subproceso "

pMessage () {
LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
echo "($LOGDATE) $*" 
echo "($LOGDATE) $*"  >> $FILE_LOG
}

Send_Email() { 
# 
#Funcion para el envio de correos al IT_OPERADOR
# DIRECCION  = Destinatario
# ASUNTO     = Asunto del email
# MENSAJE    = Cuerpo del email
# ARCHIVO	 = Archivo Adjunto si no se envia sera -
#
  SUBPROCESO=""
  DIRECCION="$1" 
  ASUNTO="" 
  MENSAJE="" 
  if [ $# -ge 5 ]; then 
	if [ "$5" != "-" ]; then 
      SUBPROCESO="$5" 
    fi 
  fi
  if [ $# -ge 2 ]; then 
    if [ "$2" != "-" ]; then 
      ASUNTO="$2 $SUBPROCESO" 
    fi 
  fi 
  if [ $# -ge 3 ]; then 
    if [ "$3" != "-" ]; then 
      MENSAJE="$3 $SUBPROCESO" 
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


#----------------------------------------------------------------
pMessageIni () {
	TYPEOUT=$1
	FILLOGM=$2
	MENSAJE=$3
	
   LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
   echo "($LOGDATE) $MENSAJE" 
   echo "($LOGDATE) $MENSAJE"  >> $FILLOGM
}

IniciSubShell(){
	TYPEOUT=$1
	FILLOGM=$2
	NROPROC=$3
	
	pMessageIni $TYPEOUT $FILLOGM "________________________________________________________________________"
	pMessageIni $TYPEOUT $FILLOGM "        INICIANDO DESAFILIACION POR NO RECARGA : $NROPROC                     "  
	pMessageIni $TYPEOUT $FILLOGM "________________________________________________________________________"
	pMessageIni $TYPEOUT $FILLOGM "   FECHA Y HORA     | ${FECHAHORA}                             		   "  
	pMessageIni $TYPEOUT $FILLOGM "   USUARIO          | $USER_SERV                               		   " 
	pMessageIni $TYPEOUT $FILLOGM "   SHELL            | $0                                       		   " 
	pMessageIni $TYPEOUT $FILLOGM "   NUM. IP          | $IP_SERV      	  	                    		   " 
	pMessageIni $TYPEOUT $FILLOGM "________________________________________________________________________"
}



FinalSubPShell() {
  NROPROC=$1
  FILLOGM=$2
  TYPEOUT=0
  pMessageIni $TYPEOUT $FILLOGM "________________________________________________________________________"
  pMessageIni $TYPEOUT $FILLOGM "           FINALIZANDO DESAFILIACION POR NO RECARGA $NROPROC  				     "
  pMessageIni $TYPEOUT $FILLOGM "Fin de subproceso $NROPROC" 
  pMessageIni $TYPEOUT $FILLOGM "________________________________________________________________________"
  pMessageIni $TYPEOUT $FILLOGM "Envio de correo por fin de subproceso $NROPROC"
  Send_Email "$IT_DESAFILIACION" "$MSGE_IT_OPERADOR" "$MAIL_CUERPO" $FILLOGM "$NROPROC"
  pMessageIni $TYPEOUT $FILLOGM "________________________________________________________________________"
  pMessageIni $TYPEOUT $FILLOGM "Fin Envio de correo por fin de subproceso $NROPROC"
} 

#----------------------------------------------------------------

InicioShell(){
pMessage "-------------------------------------------------------"
pMessage "|        INICIANDO DESAFILIACION POR NO RECARGA       |"
pMessage "-------------------------------------------------------"
pMessage "   Fecha y Hora   |      `date +'%d-%m-%Y %H:%M:%S'`   "
pMessage "   Usuario        |      $USER_SERV                    "
pMessage "   Shell          |      $0                            "
pMessage "   Ip             |      $IP_SERV      	  	         "
pMessage "-------------------------------------------------------"
}

FinalShell(){
pMessage "-------------------------------------------------------"
pMessage "|       FINALIZANDO DESAFILIACION POR NO RECARGA      |"
pMessage "-------------------------------------------------------"
pMessage "   Fecha y Hora   |      `date +'%d-%m-%Y %H:%M:%S'`   "
pMessage "   Usuario        |      $USER_SERV                    "
pMessage "   Shell          |      $0                            "
pMessage "   Ip             |      $IP_SERV      	  	         "
pMessage "-------------------------------------------------------"
}


GetNumSecuencial(){
 echo `date +'%Y%m%d%H%M%S%N'`
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

NOMBARCH=$1
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

V_NUMREG NUMBER;
V_CODERROR NUMBER;
V_DESCERROR VARCHAR2(250);

BEGIN

$PCLUB_OW.PKG_CC_PREPAGO.ADMPSS_TMP_PRESINRECARGA('$NOMBARCH',V_NUMREG,V_CODERROR,V_DESCERROR);

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

CategorizarDesafiliacion() {
#Función encargada de obtener los parámetros

OUTPUT=$1    #Archivo Log de transacciones

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

k_hilos number;
k_nombrearch varchar2(30);
k_fecha date;
k_coderror number;
k_descerror varchar2(250);

BEGIN

  k_hilos:=$CANT_PRO;
  k_nombrearch:='$NOMBREARCHIVO';
  k_fecha:=to_date('$FECHA_EJC','dd/mm/yyyy');
  
$PCLUB_OW.pkg_cc_prepago.admpsi_desafi_categ(k_hilos,
                                          k_nombrearch,
                                          k_fecha,
                                          k_coderror,
                                          k_descerror);

dbms_output.put_line(k_coderror || '|' || k_descerror);

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


ProcesarDesafiliacion() {
#Función encargada de obtener los parámetros

OUTPUT=$1    #Archivo Log de transacciones
PROCESN=$2
NOMFILE=$3

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

k_nomarch varchar2(50);
k_usuario varchar2(50);
k_proces number;
k_numregtot number;
k_numregval number;
k_numregerr number;
k_ocoderror number;
k_odescerror varchar2(250);

BEGIN

k_nomarch := '$NOMFILE';
k_usuario := '$USER_PROC';
k_proces := $PROCESN;
  

$PCLUB_OW.pkg_cc_prepago.admpsi_desafi_proce(k_nomarch,
                                          k_usuario,
                                          k_proces,
                                          k_numregtot,
                                          k_numregval,
                                          k_numregerr,
                                          k_ocoderror,
                                          k_odescerror);  

dbms_output.put_line(k_numregtot || '|' || k_numregval || '|' || k_numregerr || '|' || k_ocoderror || '|' || k_odescerror || '|' || k_nomarch || '|' || k_proces);

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

########################################
#INICIO DE DESAFILIACION POR NO RECARGA#
########################################
NROPARAMETROS=$#

EMAIL=$IT_DESAFILIACION

if [ $NROPARAMETROS -eq 0 ]; then
			#Inicio del proceso padre
				clear
				InicioShell

				pMessage "Se procede a procesar el proceso padre $DESC_PROCESO. El proceso puede durar varios minutos."

				FILECTL=`find $FILE_CTL`

				if [ "$FILECTL" = "" ] ; then
					pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
					pMessage "Error: No se encontró el archivo de Control de $DESC_PROCESO $FILE_CTL en la carpeta $DIRCTL."
					pMessage "Terminó subproceso"
					pMessage "************************************"					
					FinalShell
					Send_Email "$IT_DESAFILIACION" "$MSGE_IT_OPERADOR" "Error: No se encontró el archivo de Control de $DESC_PROCESO $FILE_CTL en la carpeta $DIRCTL." $FILE_LOG
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
					pMessage "Terminó subproceso"
					pMessage "************************************" 	    
					FinalShell
					Send_Email "$IT_DESAFILIACION" "$MSGE_IT_OPERADOR" "Error: No se encontró el archivo $NOMBREARCHIVO en la carpeta $DIRD_ARCHDOCU.${SLDO_MAIL}" $FILE_LOG
					exit
				fi

				pMessage "Archivo: $FILE_NAME"
				pMessage "Proceso1: Obteniendo registros no procesados."
				ESTADO=$(ObtenerRegNoProcesado ${FILE_NAME} ${FILE_REGNOPROC})

				if [ $ESTADO -ne 1 ] ; then
					pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
					pMessage "ERROR: Ocurrió un error en la ejecución del procedure de $DESC_PROCESO: ${PCLUB_OW}.PKG_CC_PREPAGO.ADMPSS_TMP_PRESINRECARGA. Contacte al administrador."
					pMessage "A continuación se enviará un correo a $EMAIL con el asunto: $ASUN_MAIL" 
					pMessage "Verifique el log para mayor detalle $FILE_LOG"
					pMessage "Terminó subproceso"
					pMessage "************************************" 
					cat $FILE_REGNOPROC >> $FILE_LOG
					FinalShell
					Send_Email "$IT_DESAFILIACION" "$MSGE_IT_OPERADOR" "Error al ejecutar el procedure de $DESC_PROCESO: ${PCLUB_OW}.PKG_CC_PREPAGO.ADMPSS_TMP_PRESINRECARGA.${SLDO_MAIL}" $FILE_LOG
					exit
				fi

				REGISTRO=`head -1 ${FILE_REGNOPROC}`
				CANTREGNOPROC=`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}' `
				rm -f $FILE_REGNOPROC

				pMessage "Se obtuvo los registros no procesados satisfactoriamente."
				pMessage "Registros no procesados: $CANTREGNOPROC"

				pMessage "Proceso2: Se ejecuta el SQL Loader si no existen registros no procesados."

				if [ $CANTREGNOPROC -eq 0 ] ; then
					CANT_DATA=`cat $FILEDATA | wc -l | sed 's/ //g'`
					
					if [ $CANT_DATA -eq 0 ] ; then
						pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
						pMessage "ERROR: El archivo $FILE_NAME en la carpeta de $DIRD_ARCHDOCU no tiene data..." 
						pMessage "A continuación se enviará un correo a $EMAIL con el asunto: $ASUN_MAIL" 
						pMessage "Terminó subproceso"
						pMessage "************************************" 
						FinalShell
						Send_Email "$IT_DESAFILIACION" "$MSGE_IT_OPERADOR" "El archivo $FILE_NAME en la carpeta $DIRD_ARCHDOCU no tiene data.${SLDO_MAIL}" $FILE_LOG
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

				pMessage "Proceso3: Categorizacion $DESC_PROCESO."

				#SE RETIRO ESTA PARTE DEL CODIGO
				#---------------- Categorizacion de registros --------------
				ESTADO=$(CategorizarDesafiliacion ${FILE_PROCESO})

				if [ $ESTADO -ne 1 ] ; then
					pMessage "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
					pMessage "Error: Ocurrió un error en la ejecución del procedure de $DESC_PROCESO: ${PCLUB_OW}.PKG_CC_PREPAGO.ADMPSI_DESAFI_CATEG. Contacte al administrador."
					pMessage "A continuación se enviará un correo a $EMAIL con el asunto: $ASUN_MAIL" 
					pMessage "Verifique el log para mayor detalle $FILE_LOG"
					pMessage "Terminó subproceso"
					pMessage "************************************" 
					cat $FILE_PROCESO >> $FILE_LOG
					rm -f $FILE_PROCESO
					FinalShell
					
					Send_Email "$IT_DESAFILIACION" "$MSGE_IT_OPERADOR" "Error al ejecutar el procedure de $DESC_PROCESO: ${PCLUB_OW}.PKG_CC_PREPAGO.ADMPSI_DESAFI_CATEG.${SLDO_MAIL}" $FILE_LOG
					exit
				fi
				pMessage "El proceso de Categorizacion de $DESC_PROCESO culminó satisfactoriamente."

				#---------------- Fin de categorizacion ----------------
				#---------------- Procesando los registros por categoria----------------

				mv -f $FILEDATA ${DIRD_ARCHPROC}
				# FIN SE RETIRO ESTA PARTE DEL CODIGO
				
				clear 
				NROIDENTIFI=$(GetNumSecuencial)
				pMessage "Proceso4: Ejecutando subprocesos $DESC_PROCESO."
				for i in `seq 1 30`
				do
				   FILELOGHIJO=$DIRLOG/SH006_DESAFILICACION_NOREC_${i}_$NROIDENTIFI.log #LOG  PARA EL HIJO01   
				   pMessage "Procesando hijo 0$i con log : $FILELOGHIJO" 
				   sh $DIRSHELL/SH006_DESAFILIACION_NOREC.sh "0$i" $i $FILELOGHIJO $ESTADO $FILE_NAME &	
				done
				
				pMessage "El proceso padre de $DESC_PROCESO culminó satisfactoriamente."
				pMessage "Verifique el log para mayor detalle $FILE_LOG"
				pMessage "*************************************************************" 
				FinalShell
				exit
				#---------------- fin Procesando los registros por categoria----------------
				
else

	IDENTI=$1
	PROCES=$2
	FILLOG=$3
	RPTA_CATPRE_H=$4 
	FILENAMEPROC=$5
	
	IniciSubShell 0 $FILLOG "$PROCES"
    pMessageIni 0 $FILLOG "Se procede a procesar $DESC_PROCESO. El proceso puede durar varios minutos."
	pMessageIni 0 $FILLOG "Se procede a ejecutar el procedimiento ${PCLUB_OW}.PKG_CC_PREPAGO.ADMPSI_DESAFI_PROCE"
	
	TEMP_FILE_PRIN="SH006_DESA_NOREC_${PROCES}_${FECHA_HORA}.TMP"
	
	FILE_PROCESO_PRIN=$DIRTMP/$TEMP_FILE_PRIN
	
	ESTADOPRIN=$(ProcesarDesafiliacion ${FILE_PROCESO_PRIN} ${PROCES} ${FILENAMEPROC})
	
	if [ $ESTADOPRIN -ne 1 ] ; then
		pMessageIni 0 $FILLOG "Hora y Fecha: `date +'%d-%m-%Y %H:%M:%S'`"
		pMessageIni 0 $FILLOG "Error: Ocurrió un error en la ejecución del procedure de $DESC_PROCESO: ${PCLUB_OW}.PKG_CC_PREPAGO.ADMPSI_DESAFI_PROCE. Contacte al administrador."
		pMessageIni 0 $FILLOG "Terminó subproceso"
		pMessageIni 0 $FILLOG "************************************" 
		echo -e "Error al ejecutar el procedure de $DESC_PROCESO: ${PCLUB_OW}.PKG_CC_PREPAGO.ADMPSI_DESAFI_PROCE.${SLDO_MAIL}" | mail -s "$ASUN_MAIL" $EMAIL
		echo $'\n'
		cat $FILE_PROCESO_PRIN >> $FILLOG
		rm -f $FILE_PROCESO_PRIN
		FinalSubPShell $PROCES $FILLOG
		
		
		exit
	fi
    
	REGISTRO=`head -1 ${FILE_PROCESO_PRIN}`
	CANTREGTOT=`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}' `
	CANTREGVAL=`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $2}' `
	CANTREGERR=`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $3}' `
	COD_ERR=`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $4}' `
	MSG_ERR=`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $5}' `

	if [ $COD_ERR -eq 0 ] ; then
		pMessageIni 0 $FILLOG "Total de registros: $CANTREGTOT"
		pMessageIni 0 $FILLOG "Registros válidos: $CANTREGVAL"
		pMessageIni 0 $FILLOG "Registros errados: $CANTREGERR"	
	else
		pMessageIni 0 $FILLOG "$MSG_ERR"
	fi
	
	
	rm -f $FILE_PROCESO_PRIN
	
	pMessageIni 0 $FILLOG "El proceso de $DESC_PROCESO culminó satisfactoriamente."
    FinalSubPShell $PROCES $FILLOG
	
fi

