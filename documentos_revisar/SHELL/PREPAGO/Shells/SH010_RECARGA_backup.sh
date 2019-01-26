#!/bin/sh -x
#*************************************************************
#Programa      :  SH010_RECARGA
#Autor         :  Victor Hugo Zambrano D.
#Descripcion   :  Asignacion de puntos por Aniversario y 
#		  Recargas, y descuento de puntos por falta de recarga
#		       	   
#FECHA_HORA    :  24/01/2010
#FECHA_MODIF   :  02/03/2015
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
HORA=`date +%H%M%S`
FECHAEJC=`date +%d/%m/%Y`

# ip de TIM-FTP1
HOST=`hostname`
IP_SERV=`cat /etc/hosts | grep -v '#' | grep ${HOST} | awk '{print $1}'`

#usuario
USER_SERV=`whoami`
DATAFILE1=RECARGA_*.TXT
LOGFILE=SH010_PUNTOS_RECARGA_PREPAGO_${FECHA_HORA}.log

CONTROL1=CTL081_PUNTOSRECARGA.ctl
CTLLOG1=SH010_CTL_PUNTOSRECARGA_${FECHA_HORA}.log
CTLBAD1=CTL10_BAD.txt
ESTADO1=1

LISTA1=lista81.tmp

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
	pMessageIni $TYPEOUT $FILLOGM "        INICIAR  VENCER LOS PUNTOS BONO : $NROPROC                      "  
	pMessageIni $TYPEOUT $FILLOGM "________________________________________________________________________"
	pMessageIni $TYPEOUT $FILLOGM "   FECHA Y HORA     | ${FECHAHORA}                             					"  
	pMessageIni $TYPEOUT $FILLOGM "   USUARIO          | $USER_SERV                               					" 
	pMessageIni $TYPEOUT $FILLOGM "   SHELL            | $0                                       					" 
	pMessageIni $TYPEOUT $FILLOGM "   NUM. IP          | $IP_SERV      	  	                    				" 
	pMessageIni $TYPEOUT $FILLOGM "________________________________________________________________________"
}
FinalSubPShell() {
  NROPROC=$1
  pMessageIni $TYPEOUT $FILLOGM "Termino subproceso Asignacion de Puntos por Recargas ClaroClub Prepago" 
  pMessageIni $TYPEOUT $FILLOGM "________________________________________________________________________"
  pMessageIni $TYPEOUT $FILLOGM "                  FINALIZANDO SUBPROCESO $NROPROC  				     "
  pMessageIni $TYPEOUT $FILLOGM "Fin de subproceso $NROPROC" 
  pMessageIni $TYPEOUT $FILLOGM "________________________________________________________________________"
  pMessageIni $TYPEOUT $FILLOGM "Ruta del Archivo log : ${FILLOGM}" 
  pMessageIni $TYPEOUT $FILLOGM "________________________________________________________________________"
  pMessageIni $TYPEOUT $FILLOGM "Envio de correo por fin de subproceso $NROPROC"
  Send_Email "$IT_RECARGA" "$MSGE_IT_OPERADOR" "$MAIL_CUERPO" $FILLOGM "$NROPROC"
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
DIA=`date +%d`
DIA=`expr $DIA + 0`
#Validar los días que están configurado en la tabla pclub.t_admpt_param con el dia de hoy (DIA)
cont1=`sqlplus -s ${USER_BD}/${CLAVE_BD}@${SID_BD}<<FIN 
set pagesize 0 feedback off verify off heading off echo off
select count(*) from dual
where nvl($DIA,0) in (select parn_dia_ejec 
							   from PCLUB.T_ADMPT_PARAM
							   where parn_num_arch=1);
exit;
FIN`


echo $cont1
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


#-----------------------------------------------------------------
#	FUNCIONES RECARGA
#-----------------------------------------------------------------
ActualizaPreRecarga() {
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
    $PCLUB_OW.PKG_CC_PREPAGO_WA.ADMPSS_CATEG_PRERECARGA(k_fecha, k_coderror, k_descerror);
   DBMS_OUTPUT.PUT_LINE(to_char(k_coderror) || '|' || k_descerror);                                        
  
end;
  /
  EXIT
EOP

 RETORNOS=-1 
 RETORNOS=$(ValidaErro $FILEACTPRE)
 echo $RETORNOS
}

EXECPREREC(){
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
v_USUARIO	varchar2(13);

BEGIN
v_tmp:=to_char(sysdate,'ddmmyyyy');

v_FECHA:=to_date('$FECHAEJC','DD/MM/YYYY');
v_USUARIO:='$USURECARGA';
					 
$PCLUB_OW.PKG_CC_PREPAGO_WA.ADMPSI_PRERECAR(v_USUARIO, v_FECHA, K_NUME_PROCES, v_CODERROR, v_DESCERROR, v_NUMREGTOT, v_NUMREGPRO, v_NUMREGERR);
						 
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

ValidarTmp(){

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
  
	K_FECHA DATE;
	K_CANTSIN_PROC NUMBER;
	K_CANTSIN_CATE NUMBER;
	K_CODERROR NUMBER;
	K_DESCERROR VARCHAR2(500);
  
	begin
    
		${PCLUB_OW}.PKG_CC_PREPAGO_WA.ADMPSI_FECHAFALTA_PRO(K_FECHA,K_CANTSIN_PROC,K_CANTSIN_CATE,K_CODERROR,K_DESCERROR);
		DBMS_OUTPUT.PUT_LINE(to_char(K_CODERROR) || '|' || K_DESCERROR || '|' || to_char(K_FECHA,'DD/MM/YYYY') || '|' || to_char(K_CANTSIN_PROC) || '|' || to_char(K_CANTSIN_CATE));
  
	end;
  /
  EXIT
EOP

 RETORNOS=-1 
 RETORNOS=$(ValidaErro $FILEACTPRE)
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
		
		FILELOG=$DIRLOG/SH010_LOGPADRE_$NROIDENTIFI.log #LOG  PARA EL PADRE
		FILEDATPADRE=$DIRTMP/SH010_FIDATPADRE_$NROIDENTIFI.dat #DATA PARA EL PADRE
		FILEVALCONNE=$DIRTMP/SH010_FICONEXIBD_$NROIDENTIFI.tmp
		#--------------------------------------------------------------------------
		FILELOGHIJ01=$DIRLOG/SH010_FILOGHIJ01_$NROIDENTIFI.log #LOG  PARA EL HIJO01
		FILELOGHIJ02=$DIRLOG/SH010_FILOGHIJ02_$NROIDENTIFI.log #LOG  PARA EL HIJO02
		FILELOGHIJ03=$DIRLOG/SH010_FILOGHIJ03_$NROIDENTIFI.log #LOG  PARA EL HIJO03	
		FILELOGHIJO4=$DIRLOG/SH010_FILOGHIJ04_$NROIDENTIFI.log #LOG  PARA EL HIJO04	
		FILELOGHIJO5=$DIRLOG/SH010_FILOGHIJ05_$NROIDENTIFI.log #LOG  PARA EL HIJO05	
		FILELOGHIJO6=$DIRLOG/SH010_FILOGHIJ06_$NROIDENTIFI.log #LOG  PARA EL HIJO06	
		FILELOGHIJO7=$DIRLOG/SH010_FILOGHIJ07_$NROIDENTIFI.log #LOG  PARA EL HIJO07	
		FILELOGHIJO8=$DIRLOG/SH010_FILOGHIJ08_$NROIDENTIFI.log #LOG  PARA EL HIJO08	
		FILELOGHIJO9=$DIRLOG/SH010_FILOGHIJ09_$NROIDENTIFI.log #LOG  PARA EL HIJO09	
		FILELOGHIJO10=$DIRLOG/SH010_FILOGHIJ010_$NROIDENTIFI.log #LOG  PARA EL HIJO010
		FILELOGHIJO11=$DIRLOG/SH010_FILOGHIJ011_$NROIDENTIFI.log #LOG  PARA EL HIJO011	
		FILELOGHIJO12=$DIRLOG/SH010_FILOGHIJ012_$NROIDENTIFI.log #LOG  PARA EL HIJO012	
		FILELOGHIJO13=$DIRLOG/SH010_FILOGHIJ013_$NROIDENTIFI.log #LOG  PARA EL HIJO013
		FILELOGHIJO14=$DIRLOG/SH010_FILOGHIJ014_$NROIDENTIFI.log #LOG  PARA EL HIJO014
		FILELOGHIJO15=$DIRLOG/SH010_FILOGHIJ015_$NROIDENTIFI.log #LOG  PARA EL HIJO015
		FILELOGHIJO16=$DIRLOG/SH010_FILOGHIJ016_$NROIDENTIFI.log #LOG  PARA EL HIJO016
		FILELOGHIJO17=$DIRLOG/SH010_FILOGHIJ017_$NROIDENTIFI.log #LOG  PARA EL HIJO017
		FILELOGHIJO18=$DIRLOG/SH010_FILOGHIJ018_$NROIDENTIFI.log #LOG  PARA EL HIJO018
		FILELOGHIJO19=$DIRLOG/SH010_FILOGHIJ019_$NROIDENTIFI.log #LOG  PARA EL HIJO019
		FILELOGHIJO20=$DIRLOG/SH010_FILOGHIJ020_$NROIDENTIFI.log #LOG  PARA EL HIJO020
		
	    clear 
		
		
		IniciShell 1 $FILELOG "00"
		
		ValidConex
		
		if [ $cont1 -eq 1 ]; then		
			pMessageIni 1 $FILELOG "Busca archivos a procesar segun la estructura predefinida"
			cd ${DIRDOCUMENTOS}
			
			
			ls ${DATAFILE1} > ${DIRLOG}/${LISTA1}

			pMessage="Cantidad Lectura de Datos RECARGA_DDMMYYHH24MI: $FILEBODY1"
			pMessageIni 1 $FILELOG "wc -l ${DIRLOG}/${LISTA1} | awk '{print $1}'"
			FILEBODY1=`wc -l ${DIRLOG}/${LISTA1} | awk '{print $1}'`
		
			if [ "$FILEBODY1" = "0" ] ; then
				pMessage " Error: No se encontraron archivos a procesar : "
				pMessage "${DIRDOCUMENTOS}/RECARGA_DDMMYYHH24MI.TXT"
				echo $'\n'"No se encontraron archivos a procesar : ${DIRDOCUMENTOS}/RECARGA_DDMMYYHH24MI.TXT"| mail -s "ASIGNACION DE PUNTOS POR RECARGAS CLAROCLUB PREPAGO – Se encontraron errores" $IT_OPERADOR
				pMessage "Termino subproceso Asignacion de Puntos por Recargas ClaroClub Prepago"
				pMessage "************************************"
				pMessage " FINALIZANDO PROCESO ASIGNACION DE PUNTOS POR RECARGAS CLAROCLUB PREPAGO.............."
				pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de subproceso "
				pMessage "************************************"
				echo "`date +%Y-%m-%d@%H:%M:%S` Fin de subproceso"$'\n'
				echo $'\n'
				echo "Ruta del Archivo log : " $DIRLOG/$LOGFILE
				echo $'\n'
				ESTADO1=0
			fi
		fi
		
		
		pMessageIni 1 $FILELOG "Inicio de Validacion de puntos por recarga."
		pMessageIni 1 $FILELOG "Se ejecuta el SP PKG_CC_PREPAGO_WA.ADMPSI_FECHAFALTA_PRO del proceso"
		IDEN_FILE_VALTTMP=$(GetNumRandom )
		FILE_VALI_TMP=$DIRTMP/FILE_VALRECARGA_$IDEN_FILE_VALTTMP.tmp		
		RPTA_VALTMP=$( ValidarTmp $USER_BD $CLAVE_BD $SID_BD $FILE_VALI_TMP )
		pMessageIni 1 $FILELOG "Final de Validacion de puntos por recarga."		
		
		if [ $RPTA_VALTMP -eq 1 ]; then
				TMPPRIMERALINEA=`head -1 $FILE_VALI_TMP`
				CODIGOMSG=`echo $TMPPRIMERALINEA | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}'`
				DESCMSG=`echo $TMPPRIMERALINEA | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $2}'`	
				FECHAOBTVAL=`echo $TMPPRIMERALINEA | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $3}'`
				CANTVAL=`echo $TMPPRIMERALINEA | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $4}'`
				CANTVALCAT=`echo $TMPPRIMERALINEA | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $5}'`
										
				if [ $CODIGOMSG -eq 1 ];then				
				
						pMessageIni 1 $FILELOG "La tabla ADMPT_TMP_PRERECARGA se encuentra con todos sus registros procesados."
						pMessageIni 1 $FILELOG "$DESCMSG"
						pMessageIni 1 $FILELOG "Fin del proceso padre."
						
						pMessageIni 1 $FILELOG "_________________________________________________________________"
						pMessageIni 1 $FILELOG "        FIN ENTREGA PUNTOS POR RECARGA  : PROCESO PADRE          "  
						pMessageIni 1 $FILELOG "_________________________________________________________________"
						pMessageIni 1 $FILELOG "   FECHA Y HORA     | ${FECHAHORA}                               "  
						pMessageIni 1 $FILELOG "   USUARIO          | $USER_SERV                                 " 
						pMessageIni 1 $FILELOG "   SHELL            | $0                        				 " 
						pMessageIni 1 $FILELOG "   NUM. IP          | $IP_SERV      	  	                     " 
						pMessageIni 1 $FILELOG "_________________________________________________________________"
						Send_Email "$T_OPERADOR" "$MSGE_IT_OPERADOR" "$DESCMSG" $FILELOG "1"
						exit
											
				else
					if [ $CANTVAL -eq 0 ];then #si no hay registros pendientes de procesar.
						pMessageIni 1 $FILELOG "No se encontraron inconvenientes. Se procedera a cargar los registros a la tabla ADMPT_TMP_PRERECARGA."
					
						while read FIELD001
						do
								
								#conversion de formato a unix
								dos2unix ${DIRDOCUMENTOS}/${FIELD001}
								
								#script utilizado para anular el problema del reconocimiento de la ultima linea 
								#de archivos de texto
								TMP1=${DIRLOG}/TEMPDATA1.tmp
								echo "" >> ${DIRDOCUMENTOS}/${FIELD001}
								cat ${DIRDOCUMENTOS}/${FIELD001} | sed '/^$/d' > $TMP1
								cat $TMP1 > ${DIRDOCUMENTOS}/${FIELD001}

								rm -f $TMP1

								cd ${DIRSHELL}
								
								sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$DIRCTL/$CONTROL1 data=$DIRDOCUMENTOS/$FIELD001 bad=$DIRLOG/$CTLBAD1 log=$DIRLOG/$CTLLOG1 bindsize=200000 readsize=200000 rows=1000 skip=0
								
								mv ${DIRDOCUMENTOS}/${FIELD001} ${DIRPROCESADO}/${FIELD001}

						done < ${DIRLOG}/${LISTA1}

						rm -f ${DIRLOG}/${LISTA1}
	
						if [ $ESTADO1 -eq 1 ] ; then
						
							pMessageIni 1 $FILELOG "Inicio de categorizacion"
							pMessageIni 1 $FILELOG "Se ejecuta el SP PKG_CC_PREPAGO_WA.ADMPSS_CATEG_PRERECARGA del proceso $PROC"
							#Inicio de Categorización
							IDEN_FILE_TMP=$(GetNumRandom )
							FILE_PREREC_TMP=$DIRTMP/FILE_PRERE_$IDEN_FILE_TMP.tmp
							RPTA_CATPRE=$( ActualizaPreRecarga $USER_BD $CLAVE_BD $SID_BD $FILE_PREREC_TMP )
							
							pMessageIni 1 $FILELOG "Fin de categorizacion del proceso $PROC"
						fi
		
					else
						FECHAEJC="$FECHAOBTVAL"
						pMessageIni 1 $FILELOG "Se encontro registros pendientes de procesar la entrega de puntos de la fecha $FECHAEJC."
											
						if [ $CANTVALCAT -eq 0 ];then #si no hay registros con el campo de categoria null
							RPTA_CATPRE="1"
							pMessageIni 1 $FILELOG "No existen regitros pendientes de categorizacion, se procedera a continuar con el proceso de asignacion de puntos por recarga."
						else
							pMessageIni 1 $FILELOG "Existen lineas pendientes de categorizacion."
							pMessageIni 1 $FILELOG "Inicio de categorizacion de lineas vencidas"
							pMessageIni 1 $FILELOG "Se ejecuta el SP PKG_CC_PREPAGO_WA.ADMPSS_CATEG_PRERECARGA del proceso $PROC"
							#Inicio de Categorización
							IDEN_FILE_TMP=$(GetNumRandom )
							FILE_PREREC_TMP=$DIRTMP/FILE_PRERE_$IDEN_FILE_TMP.tmp
							RPTA_CATPRE=$( ActualizaPreRecarga $USER_BD $CLAVE_BD $SID_BD $FILE_PREREC_TMP )
							
							pMessageIni 1 $FILELOG "Fin de categorizacion del proceso $PROC"
						fi
						
					fi
				 fi
		fi
		
		######################################
		if [ $NROLINEAS -ge 1 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 01 CON LOG : $FILELOGHIJ01"
			sh $DIRSHELL/SH010_RECARGA.sh "01" 1 $FILELOGHIJ01 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 2 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 02 CON LOG : $FILELOGHIJ02"
			sh $DIRSHELL/SH010_RECARGA.sh "02" 2 $FILELOGHIJ02 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 3 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 03 CON LOG : $FILELOGHIJ03"
			sh $DIRSHELL/SH010_RECARGA.sh "03" 3 $FILELOGHIJ03 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 4 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 04 CON LOG : $FILELOGHIJO4"
			sh $DIRSHELL/SH010_RECARGA.sh "04" 4 $FILELOGHIJO4 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 5 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 05 CON LOG : $FILELOGHIJO5"
			sh $DIRSHELL/SH010_RECARGA.sh "05" 5 $FILELOGHIJO5 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 6 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 06 CON LOG : $FILELOGHIJO6"
			sh $DIRSHELL/SH010_RECARGA.sh "06" 6 $FILELOGHIJO6 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 7 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 07 CON LOG : $FILELOGHIJO7"
			sh $DIRSHELL/SH010_RECARGA.sh "07" 7 $FILELOGHIJO7 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 8 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 08 CON LOG : $FILELOGHIJO8"
			sh $DIRSHELL/SH010_RECARGA.sh "08" 8 $FILELOGHIJO8 $RPTA_CATPRE $FECHAEJC &	
		fi;
			######################################
		if [ $NROLINEAS -ge 9 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 09 CON LOG : $FILELOGHIJO9"
			sh $DIRSHELL/SH010_RECARGA.sh "09" 9 $FILELOGHIJO9 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 10 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 10 CON LOG : $FILELOGHIJO10"
			sh $DIRSHELL/SH010_RECARGA.sh "10" 10 $FILELOGHIJO10 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 11 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 11 CON LOG : $FILELOGHIJO11"
			sh $DIRSHELL/SH010_RECARGA.sh "11" 11 $FILELOGHIJO11 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 12 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 12 CON LOG : $FILELOGHIJO12"
			sh $DIRSHELL/SH010_RECARGA.sh "12" 12 $FILELOGHIJO12 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 13 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 13 CON LOG : $FILELOGHIJO13"
			sh $DIRSHELL/SH010_RECARGA.sh "13" 13 $FILELOGHIJO13 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 14 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 14 CON LOG : $FILELOGHIJO14"
			sh $DIRSHELL/SH010_RECARGA.sh "14" 14 $FILELOGHIJO14 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 15 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 15 CON LOG : $FILELOGHIJO15"
			sh $DIRSHELL/SH010_RECARGA.sh "15" 15 $FILELOGHIJO15 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 16 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 16 CON LOG : $FILELOGHIJO16"
			sh $DIRSHELL/SH010_RECARGA.sh "16" 16 $FILELOGHIJO16 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 17 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 17 CON LOG : $FILELOGHIJO17"
			sh $DIRSHELL/SH010_RECARGA.sh "17" 17 $FILELOGHIJO17 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 18 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 18 CON LOG : $FILELOGHIJO18"
			sh $DIRSHELL/SH010_RECARGA.sh "18" 18 $FILELOGHIJO18 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 19 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 19 CON LOG : $FILELOGHIJO19"
			sh $DIRSHELL/SH010_RECARGA.sh "19" 19 $FILELOGHIJO19 $RPTA_CATPRE $FECHAEJC &	
		fi;
		######################################
		if [ $NROLINEAS -ge 20 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 20 CON LOG : $FILELOGHIJO20"
			sh $DIRSHELL/SH010_RECARGA.sh "20" 20 $FILELOGHIJO20 $RPTA_CATPRE $FECHAEJC &	
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
		
		pMessageIni 0 $FILLOG "RPTA_CATPRE_H $IDENTI :  ${RPTA_CATPRE_H}"
		if [ $RPTA_CATPRE_H -eq 1 ]; then
		
				pMessageIni 0 $FILLOG "Se ejecuta el procedimiento de carga PKG_CC_PREPAGO_WA.ADMPSI_PRERECAR"	
					
				IDENTEMP=$(GetNumSecuencial)
				FILETMP=$DIRTMP/"SH010_RECARGA_${IDENTI}_${IDENTEMP}.tmp"			
				EXECPREREC $PROCES $FILETMP
				pMessageIni 0 $FILLOG "Se termina de ejecutar el procedimiento de carga PKG_CC_PREPAGO_WA.ADMPSI_PRERECAR"	
				
				
				pMessageIni 0 $FILLOG "Se valida la existencia de errores durante la ejecución"				
				VALIDAT_CTL1=`grep 'ORA-' $FILLOG | wc -l`
				
				if [ $VALIDAT_CTL1 -ne 0 ]; then
				
					pMessageIni 0 $FILLOG `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del procedure de ASIGNACION DE PUNTOS POR	RECARGAS CLAROCLUB PREPAGO: ${PCLUB_OW}.PKG_CC_PREPAGOVH.ADMPSI_PRERECAR. Contacte al administrador."$'\n' 
					echo  $'\n'"Error al ejecutar el procedure ASIGNACION DE PUNTOS POR RECARGAS CLAROCLUB PREPAGO: ${PCLUB_OW}.PKG_CC_PREPAGOVH.ADMPSI_PRERECAR"| mail -s "ASIGNACION DE PUNTOS POR RECARGAS CLAROCLUB PREPAGO – error al ejecutar el procedure" $IT_OPERADOR
					pMessageIni 0 $FILLOG "Termino subproceso Asignacion de Puntos por Recargas ClaroClub Prepago"
					pMessageIni 0 $FILLOG "*******************************************************"
					pMessageIni 0 $FILLOG " FINALIZANDO SUBPROCESO ASIGNACION DE PUNTOS POR RECARGAS CLAROCLUB PREPAGO........"
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