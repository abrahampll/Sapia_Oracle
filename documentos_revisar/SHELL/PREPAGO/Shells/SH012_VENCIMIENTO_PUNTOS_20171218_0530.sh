#!/bin/sh -x
#*************************************************************
#Programa      :  SH012_VENCIMIENTO_PUNTOS
#Autor         :  Fredy Fernandez Espinoza.
#Descripcion   :  Vencimiento de puntos.
#		       	   
#FECHA_HORA    :  24/01/2010
#FECHA_MODIF   :  28/05/2015
#.
#*************************************************************
#clear

# Inicializacion de Variables
HOME_GAT=/home/usrclaroclub/CLAROCLUB/Interno/Prepago
. $HOME_GAT/Bin/.varset
. $HOME_GAT/Bin/.mailset
. $HOME_GAT/Bin/.passet 

cd ${DIRSHELL}
FECHA_HORA=`date +'%Y%m%d%H%M%S'`
FECHA=`date +%d%m%Y`
FECHAEJC=`date +%d/%m/%Y`
HORA=`date +%H%M%S`

# ip de TIM-FTP1
HOST=`hostname`
IP_SERV=`cat /etc/hosts | grep -v '#' | grep ${HOST} | awk '{print $1}'`

#usuario
USER_SERV=`whoami`

LOGFILE=SH012_VENCIMIENTO_PUNTOS_${FECHA_HORA}.log

ESTADO1=1

NROLINEAS=100
MSGE_IT_OPERADOR="Status de Carga de subproceso."
MAIL_CUERPO="Se terminó la carga del subproceso."
#-----------------------------------------------------------------------------
#--------------------------------VARIABLES------------------------------------
#-----------------------------------------------------------------------------
cont1=0
cont2=0
HORAINI=`date +'%H%M%S'`
FECHAHORA=`date +'%Y-%m-%d %H:%M:%S'`
FILEBODY1=0
VALIDAT_CTL1=""
RPTA_CATPRE=0
RPTA_ANIV=0




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


pMessageIni () {
	TYPEOUT=$1
	FILLOGM=$2
	MENSAJE=$3
	
   LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
   echo "($LOGDATE) $MENSAJE" 
   echo "($LOGDATE) $MENSAJE"  >> $FILLOGM
} # pMessage
pMessage () {   
   LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
   echo "($LOGDATE) $*" 
   echo "($LOGDATE) $*"  >> $DIRLOG/$LOGFILE
} # pMessage	
IniciShell(){
	TYPEOUT=$1
	FILLOGM=$2
	NROPROC=$3
	
	pMessageIni $TYPEOUT $FILLOGM "________________________________________________________________________"
	pMessageIni $TYPEOUT $FILLOGM "        INICIAR  VENCER LOS PUNTOS  : $NROPROC                          "  
	pMessageIni $TYPEOUT $FILLOGM "________________________________________________________________________"
	pMessageIni $TYPEOUT $FILLOGM "   FECHA Y HORA     | ${FECHAHORA}                             					"  
	pMessageIni $TYPEOUT $FILLOGM "   USUARIO          | $USER_SERV                               					" 
	pMessageIni $TYPEOUT $FILLOGM "   SHELL            | $0                                       					" 
	pMessageIni $TYPEOUT $FILLOGM "   NUM. IP          | $IP_SERV      	  	                    				" 
	pMessageIni $TYPEOUT $FILLOGM "________________________________________________________________________"
}



FinalSubPShell() {
  NROPROC=$1
  pMessageIni $TYPEOUT $FILLOGM "Termino subproceso Vencimiento de Puntos 								 " 
  pMessageIni $TYPEOUT $FILLOGM "________________________________________________________________________"
  pMessageIni $TYPEOUT $FILLOGM "                  FINALIZANDO SUBPROCESO $NROPROC  				     "
  pMessageIni $TYPEOUT $FILLOGM "Fin de subproceso $NROPROC" 
  pMessageIni $TYPEOUT $FILLOGM "________________________________________________________________________"
  pMessageIni $TYPEOUT $FILLOGM "Ruta del Archivo log : ${FILLOGM}" 
  pMessageIni $TYPEOUT $FILLOGM "________________________________________________________________________"
  pMessageIni $TYPEOUT $FILLOGM "Envio de correo por fin de subproceso $NROPROC"
  Send_Email "$IT_VENCIMIENTO" "$MSGE_IT_OPERADOR" "$MAIL_CUERPO" $FILLOGM "$NROPROC"
  pMessageIni $TYPEOUT $FILLOGM "________________________________________________________________________"
  pMessageIni $TYPEOUT $FILLOGM "Fin Envio de correo por fin de subproceso $NROPROC"
}

FinalShell() {
 pMessage "Termino proceso"
 pMessage "********** FINALIZANDO PROCESO ********** " 
 pMessage "Fin de proceso "
 pMessage "************************************" 
 pMessage "Ruta del Archivo log : ${DIRLOG}/${LOGFILE}" 
 pMessage "" 
}

GetNumRandom(){
 #Sumary
 #Permite generar valores aleatorios a fin de no tener repeticiones
 #en algun proceso
	echo `echo $RANDOM`
}

#-----------------------------------------------------------------
#	FUNCION PARA VALIDAR CONEXION
#-----------------------------------------------------------------
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

#-----------------------------------------------------------------
#	FUNCION PARA MANEJO DEL LOG
#-----------------------------------------------------------------




GetNumSecuencial(){
 echo `date +'%Y%m%d%H%M%S%N'`
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

ObtenerLineasVencidas() {
USUARIO=$1
PASSWOR=$2
BASEDAT=$3
FILEACTPRE=$4

sqlplus -s $USUARIO/$PASSWOR@$BASEDAT << EOP >$FILEACTPRE
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
    declare 

  k_coderror number;
  k_descerror varchar2(500);
  k_fecha date;
  begin
    --k_fecha:=to_date('$FECHAEJC','DD/MM/YYYY');
    k_fecha:=to_date('12/02/2016','DD/MM/YYYY');
    ${PCLUB_OW}.PKG_CC_PREPAGO_WA_VT.ADMPSI_PREVENCPTO_CARGA(k_fecha,k_coderror,k_descerror);
    DBMS_OUTPUT.PUT_LINE(to_char(k_coderror) || '|' || k_descerror);                                        
  
end;
  /
  EXIT
EOP

 RETORNOS=-1 
 RETORNOS=$(ValidaErro $FILEACTPRE)
 echo $RETORNOS
}


#-----------------------------------------------------------------
#	FUNCIONES RECARGA
#-----------------------------------------------------------------
ValidarTmpVencidas() {
USUARIO=$1
PASSWOR=$2
BASEDAT=$3
FILEACTPRE=$4

sqlplus -s $USUARIO/$PASSWOR@$BASEDAT << EOP >$FILEACTPRE
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
    declare 

  k_coderror number;
  k_descerror varchar2(500);
  k_fecha varchar2(20);
  k_count number;
  k_count_cat number;
  begin
    
    ${PCLUB_OW}.PKG_CC_PREPAGO_WA_VT.ADMPSS_PREVENCPTO_VALI(k_coderror,k_descerror,k_fecha,k_count,k_count_cat);
    DBMS_OUTPUT.PUT_LINE(to_char(k_coderror) || '|' || k_descerror || '|' || k_fecha || '|' || to_char(k_count) || '|' || to_char(k_count_cat));
  
end;
  /
  EXIT
EOP

 RETORNOS=-1 
 RETORNOS=$(ValidaErro $FILEACTPRE)
 echo $RETORNOS
}



CategorizarLineasVencidas() {
USUARIO=$1
PASSWOR=$2
BASEDAT=$3
FILEACTPRE=$4

sqlplus -s $USUARIO/$PASSWOR@$BASEDAT << EOP >$FILEACTPRE
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
    declare 

  k_coderror number;
  k_descerror varchar2(500);
  k_fecha date;
  begin
    k_fecha:=to_date('$FECHAEJC','DD/MM/YYYY');
    ${PCLUB_OW}.PKG_CC_PREPAGO_WA_VT.ADMPSS_PREVENCPTO_CATEG(k_fecha,k_coderror,k_descerror);
   DBMS_OUTPUT.PUT_LINE(to_char(k_coderror) || '|' || k_descerror);                                        
  
end;
  /
  EXIT
EOP

 RETORNOS=-1 
 RETORNOS=$(ValidaErro $FILEACTPRE)
 echo $RETORNOS
}

ProcesarLineasVencidas(){
PROC=$1
FILE=$2
sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> $FILE
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
K_NUME_PROCES	NUMBER:=$PROC;
v_tmp		varchar2(10);
v_FECHA  	DATE;
v_CODERROR 	NUMBER;
v_DESCERROR  	VARCHAR2(200); 
v_NUMREGTOT  	NUMBER; 
v_NUMREGPRO  	NUMBER; 
v_NUMREGERR  	NUMBER;
k_fecha date;
BEGIN
v_tmp:=to_char(sysdate,'ddmmyyyy');
v_FECHA:=to_date(v_tmp,'ddmmyyyy');
k_fecha:=to_date('$FECHAEJC','DD/MM/YYYY');

${PCLUB_OW}.PKG_CC_PREPAGO_WA_VT.ADMPSS_PREVENCPTO_PROCE(k_fecha,K_NUME_PROCES, v_CODERROR, v_DESCERROR, v_NUMREGTOT, v_NUMREGPRO, v_NUMREGERR);

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
RETORNOS=-1 
RETORNOS=$(ValidaErro $FILE)
echo $RETORNOS		
}


############################################################
################ INICIO DE DESARROLLO SHELL ################
############################################################

NROPARAMETROS=$#

	
	if [ $NROPARAMETROS -eq 0 ]; then
		###########################################################
		####################---PROCESO PADRE---####################
		###########################################################
		
		HORAINICIOP=`date +'%H%M%S'`
		NROIDENTIFI=$(GetNumSecuencial)
		
		FILELOG=$DIRLOG/SH012_VCTOPTOLOGPADRE_$NROIDENTIFI.log #LOG  PARA EL PADRE
		FILEDATPADRE=$DIRTMP/SH012_VCTOPTODATPADRE_$NROIDENTIFI.dat #DATA PARA EL PADRE
		FILEVALCONNE=$DIRTMP/SH012_VCTOPTOCONEXIBD_$NROIDENTIFI.tmp
		#--------------------------------------------------------------------------
		FILELOGHIJ01=$DIRLOG/SH012_VCTOPTOFILOGHIJ01_$NROIDENTIFI.log #LOG  PARA EL HIJO01
		FILELOGHIJ02=$DIRLOG/SH012_VCTOPTOFILOGHIJ02_$NROIDENTIFI.log #LOG  PARA EL HIJO02
		FILELOGHIJ03=$DIRLOG/SH012_VCTOPTOFILOGHIJ03_$NROIDENTIFI.log #LOG  PARA EL HIJO03	
		FILELOGHIJO4=$DIRLOG/SH012_VCTOPTOFILOGHIJ04_$NROIDENTIFI.log #LOG  PARA EL HIJO04	
		FILELOGHIJO5=$DIRLOG/SH012_VCTOPTOFILOGHIJ05_$NROIDENTIFI.log #LOG  PARA EL HIJO05	
		FILELOGHIJO6=$DIRLOG/SH012_VCTOPTOFILOGHIJ06_$NROIDENTIFI.log #LOG  PARA EL HIJO06	
		FILELOGHIJO7=$DIRLOG/SH012_VCTOPTOFILOGHIJ07_$NROIDENTIFI.log #LOG  PARA EL HIJO07	
		FILELOGHIJO8=$DIRLOG/SH012_VCTOPTOFILOGHIJ08_$NROIDENTIFI.log #LOG  PARA EL HIJO08	
		FILELOGHIJO9=$DIRLOG/SH012_VCTOPTOFILOGHIJ09_$NROIDENTIFI.log #LOG  PARA EL HIJO09	
		FILELOGHIJO10=$DIRLOG/SH012_VCTOPTOFILOGHIJ010_$NROIDENTIFI.log #LOG  PARA EL HIJO010
		FILELOGHIJO11=$DIRLOG/SH012_VCTOPTOFILOGHIJ011_$NROIDENTIFI.log #LOG  PARA EL HIJO011	
		FILELOGHIJO12=$DIRLOG/SH012_VCTOPTOFILOGHIJ012_$NROIDENTIFI.log #LOG  PARA EL HIJO012	
		FILELOGHIJO13=$DIRLOG/SH012_VCTOPTOFILOGHIJ013_$NROIDENTIFI.log #LOG  PARA EL HIJO013
		FILELOGHIJO14=$DIRLOG/SH012_VCTOPTOFILOGHIJ014_$NROIDENTIFI.log #LOG  PARA EL HIJO014
		FILELOGHIJO15=$DIRLOG/SH012_VCTOPTOFILOGHIJ015_$NROIDENTIFI.log #LOG  PARA EL HIJO015
		FILELOGHIJO16=$DIRLOG/SH012_VCTOPTOFILOGHIJ016_$NROIDENTIFI.log #LOG  PARA EL HIJO016
		FILELOGHIJO17=$DIRLOG/SH012_VCTOPTOFILOGHIJ017_$NROIDENTIFI.log #LOG  PARA EL HIJO017
		FILELOGHIJO18=$DIRLOG/SH012_VCTOPTOFILOGHIJ018_$NROIDENTIFI.log #LOG  PARA EL HIJO018
		FILELOGHIJO19=$DIRLOG/SH012_VCTOPTOFILOGHIJ019_$NROIDENTIFI.log #LOG  PARA EL HIJO019
		FILELOGHIJO20=$DIRLOG/SH012_VCTOPTOFILOGHIJ020_$NROIDENTIFI.log #LOG  PARA EL HIJO020
		
	    clear 
		
		
		IniciShell 1 $FILELOG "00"
		
		#Verificando conexion con la base de datos
		IDEN_FILE_TMP=$(GetNumRandom )
		FILE_CONN_TMP=$DIRTMP/FILE_CONN_$IDEN_FILE_TMP.tmp
		pMessage "Validando Conexion $USER_BD $CLAVE_BD $SID_BD $FILE_CONN_TMP"
		RPTA_CONN=$(ValidConex $USER_BD $CLAVE_BD $SID_BD $FILE_CONN_TMP)
		cont1=$RPTA_CONN
		if [ $cont1 -eq 1 ]; then
			pMessage "Conexion a base de datos satisfactoria."
		else
			pMessage "Conexion a base de datos insatisfactoria."
		fi
		
		
		
		pMessageIni 1 $FILELOG "Inicio de Validacion de lineas que se encuentran vencidas."
		pMessageIni 1 $FILELOG "Se ejecuta el SP PKG_CC_PREPAGO.ADMPSS_PREVENCPTO_VALI del proceso"
		IDEN_FILE_VALTTMP=$(GetNumRandom )
		FILE_VALI_TMP=$DIRTMP/FILE_VALTMPVEN_$IDEN_FILE_VALTTMP.tmp
		RPTA_VALTMP=$( ValidarTmpVencidas $USER_BD $CLAVE_BD $SID_BD $FILE_VALI_TMP )
		pMessageIni 1 $FILELOG "FIN de Validacion de lineas que se encuentran vencidas."
		 
		if [ $RPTA_VALTMP -eq 1 ]; then
				TMPPRIMERALINEA=`head -1 $FILE_VALI_TMP`
				CODIGOMSG=`echo $TMPPRIMERALINEA | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}'`
				DESCMSG=`echo $TMPPRIMERALINEA | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $2}'`
				FECHAOBTVAL=`echo $TMPPRIMERALINEA | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $3}'`
				CANTVAL=`echo $TMPPRIMERALINEA | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $4}'`
				CANTVALCAT=`echo $TMPPRIMERALINEA | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $5}'`
				
				 if [ $CODIGOMSG -eq 1 ];then
					pMessageIni 1 $FILELOG "La tabla ADMPT_TMP_VENCIMIENTO_PUNTOS se encuentra con todos sus registros procesados."
					pMessageIni 1 $FILELOG "$DESCMSG"
					pMessageIni 1 $FILELOG "Fin del proceso padre."
					
					pMessageIni 1 $FILELOG "________________________________________________________________________"
					pMessageIni 1 $FILELOG "        FIN VENCER LOS PUNTOS  : PROCESO PADRE                         "  
					pMessageIni 1 $FILELOG "________________________________________________________________________"
					pMessageIni 1 $FILELOG "   FECHA Y HORA     | ${FECHAHORA}                             					"  
					pMessageIni 1 $FILELOG "   USUARIO          | $USER_SERV                                  	" 
					pMessageIni 1 $FILELOG "   SHELL            | $0                                       					" 
					pMessageIni 1 $FILELOG "   NUM. IP          | $IP_SERV      	  	                    				" 
					pMessageIni 1 $FILELOG "________________________________________________________________________"
					Send_Email "$IT_VENCIMIENTO" "$MSGE_IT_OPERADOR" "$DESCMSG" $FILELOG "1"
					exit
				 else
					if [ $CANTVAL -eq 0 ];then #si no hay registros pendientes de procesar.
							pMessageIni 1 $FILELOG "No se encontraron inconvenientes. Se procederá a cargar los registros vencidos a la tabla ADMPT_TMP_VENCIMIENTO_PUNTOS."
						
							#EJECUTAR EL SP QUE COPIA LOS REGISTROS A ADMPT_TMP_VENCIMIENTO_PUNTOS
							pMessageIni 1 $FILELOG "Inicio de Obtencion de lineas que se encuentran vencidas."
							pMessageIni 1 $FILELOG "Se ejecuta el SP PKG_CC_PREPAGO.ADMPSI_PREVENCPTO_CARGA del proceso $PROC"
							IDEN_FILE_LINVETMP=$(GetNumRandom )
							FILE_LINVEN_TMP=$DIRTMP/FILE_OBTLINVEN_$IDEN_FILE_LINVETMP.tmp
							RPTA_CARGLINVENC=$( ObtenerLineasVencidas $USER_BD $CLAVE_BD $SID_BD $FILE_LINVEN_TMP )
							pMessageIni 1 $FILELOG "FIN de Obtencion de lineas que se encuentran vencidas."
							
							if [ $RPTA_VALTMP -eq 1 ]; then
								TMPOBTPRIMERALINEA=`head -1 $FILE_LINVEN_TMP`
								CODIGOOBTERROR=`echo $TMPOBTPRIMERALINEA | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}'`
								DESCMSGOBT=`echo $TMPOBTPRIMERALINEA | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $2}'`
								if [ $CODIGOOBTERROR -eq 0 ]; then
									pMessageIni 1 $FILELOG "El proceso de carga termino de manera satisfactoria."
								else
									pMessageIni 1 $FILELOG "Ocurrio el siguiente error al realizar la carga de lineas vencidas: $DESCMSGOBT "
									
									pMessageIni 1 $FILELOG "________________________________________________________________________"
									pMessageIni 1 $FILELOG "        FIN VENCER LOS PUNTOS  : PROCESO PADRE                         "  
									pMessageIni 1 $FILELOG "________________________________________________________________________"
									pMessageIni 1 $FILELOG "   FECHA Y HORA     | ${FECHAHORA}                             					"  
									pMessageIni 1 $FILELOG "   USUARIO          | $USER_SERV                                  	" 
									pMessageIni 1 $FILELOG "   SHELL            | $0                                       					" 
									pMessageIni 1 $FILELOG "   NUM. IP          | $IP_SERV      	  	                    				" 
									pMessageIni 1 $FILELOG "________________________________________________________________________"
									Send_Email "$IT_VENCIMIENTO" "$MSGE_IT_OPERADOR" "$DESCMSGOBT" $FILELOG "1"
									exit
								fi;
								
								
							fi
							
							
							
							
							pMessageIni 1 $FILELOG "Inicio de categorizacion de lineas vencidas"
							pMessageIni 1 $FILELOG "Se ejecuta el SP PKG_CC_PREPAGO.ADMPSS_PREVENCPTO_CATEG del proceso $PROC"
							#Inicio de Categorización
							IDEN_FILE_TMP=$(GetNumRandom )
							FILE_PREREC_TMP=$DIRTMP/FILE_PRERE_$IDEN_FILE_TMP.tmp
							RPTA_CATPRE=$( CategorizarLineasVencidas $USER_BD $CLAVE_BD $SID_BD $FILE_PREREC_TMP )
							
							pMessageIni 1 $FILELOG "Fin de categorizacion del proceso $PROC"
					else
						FECHAEJC="$FECHAOBTVAL"
						pMessageIni 1 $FILELOG "Se encontro registros pendientes de procesar vencimiento de la fecha $FECHAEJC ."
						if [ $CANTVALCAT -eq 0 ];then #si no hay registros con el campo de categoria null
							RPTA_CATPRE="1"
							pMessageIni 1 $FILELOG "No existen regitros pendientes de categorizacion, se procedera a continuar con el proceso de vencimiento de puntos."
						else
							pMessageIni 1 $FILELOG "Existen lineas pendientes de categorizacion."
							pMessageIni 1 $FILELOG "Inicio de categorizacion de lineas vencidas"
							pMessageIni 1 $FILELOG "Se ejecuta el SP PKG_CC_PREPAGO.ADMPSS_PREVENCPTO_CATEG del proceso $PROC"
							#Inicio de Categorización
							IDEN_FILE_TMP=$(GetNumRandom )
							FILE_PREREC_TMP=$DIRTMP/FILE_PRERE_$IDEN_FILE_TMP.tmp
							RPTA_CATPRE=$( CategorizarLineasVencidas $USER_BD $CLAVE_BD $SID_BD $FILE_PREREC_TMP )
							
							pMessageIni 1 $FILELOG "Fin de categorizacion del proceso $PROC"
						fi
						
					fi
				 fi
		fi
		
		######################################
		if [ $NROLINEAS -ge 1 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 01 CON LOG : $FILELOGHIJ01"
			sh $DIRSHELL/SH012_VENCIMIENTO_PUNTOS.sh "01" 1 $FILELOGHIJ01 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 2 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 02 CON LOG : $FILELOGHIJ02"
			sh $DIRSHELL/SH012_VENCIMIENTO_PUNTOS.sh "02" 2 $FILELOGHIJ02 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 3 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 03 CON LOG : $FILELOGHIJ03"
			sh $DIRSHELL/SH012_VENCIMIENTO_PUNTOS.sh "03" 3 $FILELOGHIJ03 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 4 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 04 CON LOG : $FILELOGHIJO4"
			sh $DIRSHELL/SH012_VENCIMIENTO_PUNTOS.sh "04" 4 $FILELOGHIJO4 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 5 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 05 CON LOG : $FILELOGHIJO5"
			sh $DIRSHELL/SH012_VENCIMIENTO_PUNTOS.sh "05" 5 $FILELOGHIJO5 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 6 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 06 CON LOG : $FILELOGHIJO6"
			sh $DIRSHELL/SH012_VENCIMIENTO_PUNTOS.sh "06" 6 $FILELOGHIJO6 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 7 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 07 CON LOG : $FILELOGHIJO7"
			sh $DIRSHELL/SH012_VENCIMIENTO_PUNTOS.sh "07" 7 $FILELOGHIJO7 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 8 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 08 CON LOG : $FILELOGHIJO8"
			sh $DIRSHELL/SH012_VENCIMIENTO_PUNTOS.sh "08" 8 $FILELOGHIJO8 $RPTA_CATPRE $FECHAEJC &	
		fi;
			######################################
		if [ $NROLINEAS -ge 9 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 09 CON LOG : $FILELOGHIJO9"
			sh $DIRSHELL/SH012_VENCIMIENTO_PUNTOS.sh "09" 9 $FILELOGHIJO9 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 10 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 10 CON LOG : $FILELOGHIJO10"
			sh $DIRSHELL/SH012_VENCIMIENTO_PUNTOS.sh "10" 10 $FILELOGHIJO10 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 11 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 11 CON LOG : $FILELOGHIJO11"
			sh $DIRSHELL/SH012_VENCIMIENTO_PUNTOS.sh "11" 11 $FILELOGHIJO11 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 12 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 12 CON LOG : $FILELOGHIJO12"
			sh $DIRSHELL/SH012_VENCIMIENTO_PUNTOS.sh "12" 12 $FILELOGHIJO12 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 13 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 13 CON LOG : $FILELOGHIJO13"
			sh $DIRSHELL/SH012_VENCIMIENTO_PUNTOS.sh "13" 13 $FILELOGHIJO13 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 14 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 14 CON LOG : $FILELOGHIJO14"
			sh $DIRSHELL/SH012_VENCIMIENTO_PUNTOS.sh "14" 14 $FILELOGHIJO14 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 15 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 15 CON LOG : $FILELOGHIJO15"
			sh $DIRSHELL/SH012_VENCIMIENTO_PUNTOS.sh "15" 15 $FILELOGHIJO15 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 16 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 16 CON LOG : $FILELOGHIJO16"
			sh $DIRSHELL/SH012_VENCIMIENTO_PUNTOS.sh "16" 16 $FILELOGHIJO16 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 17 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 17 CON LOG : $FILELOGHIJO17"
			sh $DIRSHELL/SH012_VENCIMIENTO_PUNTOS.sh "17" 17 $FILELOGHIJO17 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 18 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 18 CON LOG : $FILELOGHIJO18"
			sh $DIRSHELL/SH012_VENCIMIENTO_PUNTOS.sh "18" 18 $FILELOGHIJO18 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 19 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 19 CON LOG : $FILELOGHIJO19"
			sh $DIRSHELL/SH012_VENCIMIENTO_PUNTOS.sh "19" 19 $FILELOGHIJO19 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 20 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 20 CON LOG : $FILELOGHIJO20"
			sh $DIRSHELL/SH012_VENCIMIENTO_PUNTOS.sh "20" 20 $FILELOGHIJO20 $RPTA_CATPRE $FECHAEJC &	
		fi;
		
		pMessageIni 1 $FILELOG "Fin del proceso padre."
		
	else
		###########################################################
		####################---PROCESO HIJOS---####################
		###########################################################
		
		HORCHI=`date +'%H%M%S'`
		IDENTI=$1
		PROCES=$2
		FILLOG=$3
		RPTA_CATPRE_H=$4 
		FECHAEJC=$5
		
		RTOTAL=0
		REXITO=0
		RERRAD=0
		##--------------------------
		IniciShell 0 $FILLOG "$IDENTI"
		##--------------------------
		pMessageIni 0 $FILLOG "Fecha para procesar $FECHAEJC"
		pMessageIni 0 $FILLOG "RPTA_CATPRE_H $IDENTI :  ${RPTA_CATPRE_H}"
		if [ $RPTA_CATPRE_H -eq 1 ]; then
		
				pMessageIni 0 $FILLOG "Se ejecuta el procedimiento de identificacion de lineas vencidas PKG_CC_PREPAGO.ADMPSS_PREVENCPTO_PROCE"	
				
				
				IDENTEMP=$(GetNumSecuencial)
				FILETMP=$DIRTMP/"SH012_VENCIMIENTO_PUNTOS_${IDENTI}_${IDENTEMP}.tmp"			
				ProcesarLineasVencidas $PROCES $FILETMP
				pMessageIni 0 $FILLOG "Se termina de ejecutar el procedimiento de identificacion de lineas vencidas PKG_CC_PREPAGO.ADMPSS_PREVENCPTO_PROCE"	
				
				
				pMessageIni 0 $FILLOG "Se valida la existencia de errores durante la ejecución"
				#VALIDAT_CTL1=`grep 'ORA-' ${DIRLOG}/${LOGFILE} | wc -l`
				VALIDAT_CTL1=`grep 'ORA-' $FILLOG | wc -l`
				
				if [ $VALIDAT_CTL1 -ne 0 ]; then
				
					pMessageIni 0 $FILLOG `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del procedure de vencimiento de puntos: ${PCLUB_OW}.PKG_CC_PREPAGO.ADMPSS_PREVENCPTO_PROCE. Contacte al administrador."$'\n' 
					echo  $'\n'"Error al ejecutar el procedure VENCIMIENTO DE PUNTOS: ${PCLUB_OW}.PKG_CC_PREPAGO.ADMPSS_PREVENCPTO_PROCE"| mail -s "VENCIMIENTO DE PUNTOS CLAROCLUB PREPAGO – error al ejecutar el procedure" $IT_VENCIMIENTO
					pMessageIni 0 $FILLOG "Termino subproceso vencimiento de Puntos ClaroClub Prepago"
					pMessageIni 0 $FILLOG "*******************************************************"
					pMessageIni 0 $FILLOG " FINALIZANDO SUBPROCESO VENCIMIENTOS DE PUNTOS CLAROCLUB PREPAGO........"
					pMessageIni 0 $FILLOG "`date +%Y-%m-%d@%H:%M:%S` Fin de subproceso $PROC"
					pMessageIni 0 $FILLOG "*******************************************************"
					echo "`date +%Y-%m-%d@%H:%M:%S` Fin de subproceso"$'\n'
					echo $'\n'
					echo "Ruta del Archivo log : " ${DIRLOG}/${LOGFILE}
					echo $'\n'
					ESTADO1=0
				fi
				
				FinalSubPShell $PROCES
		fi	
	fi	