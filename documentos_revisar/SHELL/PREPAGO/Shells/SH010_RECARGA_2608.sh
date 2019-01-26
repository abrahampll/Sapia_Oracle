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



VerificarActualizarSaldos(){
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
K_NUME_PROCES  NUMBER:=$PROC;
v_CODERROR   NUMBER;
v_DESCERROR    VARCHAR2(200); 

k_count NUMBER;
BEGIN

${PCLUB_OW}.PKG_CC_PREPAGO_WA.ADMPSI_PRERECAR_CONF(K_NUME_PROCES, k_count, v_CODERROR, v_DESCERROR);

DBMS_OUTPUT.PUT_LINE(to_char(v_CODERROR) || '|' || v_DESCERROR || '|' || to_char(k_count));

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
		
		FILELOGHIJO21=$DIRLOG/SH010_FILOGHIJ021_$NROIDENTIFI.log #LOG  PARA EL HIJO021
		FILELOGHIJO22=$DIRLOG/SH010_FILOGHIJ022_$NROIDENTIFI.log #LOG  PARA EL HIJO022
		FILELOGHIJO23=$DIRLOG/SH010_FILOGHIJ023_$NROIDENTIFI.log #LOG  PARA EL HIJO023
		FILELOGHIJO24=$DIRLOG/SH010_FILOGHIJ024_$NROIDENTIFI.log #LOG  PARA EL HIJO024
		FILELOGHIJO25=$DIRLOG/SH010_FILOGHIJ025_$NROIDENTIFI.log #LOG  PARA EL HIJO025
		FILELOGHIJO26=$DIRLOG/SH010_FILOGHIJ026_$NROIDENTIFI.log #LOG  PARA EL HIJO026
		FILELOGHIJO27=$DIRLOG/SH010_FILOGHIJ027_$NROIDENTIFI.log #LOG  PARA EL HIJO027
		FILELOGHIJO28=$DIRLOG/SH010_FILOGHIJ028_$NROIDENTIFI.log #LOG  PARA EL HIJO028
		FILELOGHIJO29=$DIRLOG/SH010_FILOGHIJ029_$NROIDENTIFI.log #LOG  PARA EL HIJO029
		FILELOGHIJO30=$DIRLOG/SH010_FILOGHIJ030_$NROIDENTIFI.log #LOG  PARA EL HIJO030
		FILELOGHIJO31=$DIRLOG/SH010_FILOGHIJ031_$NROIDENTIFI.log #LOG  PARA EL HIJO031
		FILELOGHIJO32=$DIRLOG/SH010_FILOGHIJ032_$NROIDENTIFI.log #LOG  PARA EL HIJO032
		FILELOGHIJO33=$DIRLOG/SH010_FILOGHIJ033_$NROIDENTIFI.log #LOG  PARA EL HIJO033
		FILELOGHIJO34=$DIRLOG/SH010_FILOGHIJ034_$NROIDENTIFI.log #LOG  PARA EL HIJO034
		FILELOGHIJO35=$DIRLOG/SH010_FILOGHIJ035_$NROIDENTIFI.log #LOG  PARA EL HIJO035
		FILELOGHIJO36=$DIRLOG/SH010_FILOGHIJ036_$NROIDENTIFI.log #LOG  PARA EL HIJO036
		FILELOGHIJO37=$DIRLOG/SH010_FILOGHIJ037_$NROIDENTIFI.log #LOG  PARA EL HIJO037
		FILELOGHIJO38=$DIRLOG/SH010_FILOGHIJ038_$NROIDENTIFI.log #LOG  PARA EL HIJO038
		FILELOGHIJO39=$DIRLOG/SH010_FILOGHIJ039_$NROIDENTIFI.log #LOG  PARA EL HIJO039
		FILELOGHIJO40=$DIRLOG/SH010_FILOGHIJ040_$NROIDENTIFI.log #LOG  PARA EL HIJO040
		FILELOGHIJO41=$DIRLOG/SH010_FILOGHIJ041_$NROIDENTIFI.log #LOG  PARA EL HIJO041
		FILELOGHIJO42=$DIRLOG/SH010_FILOGHIJ042_$NROIDENTIFI.log #LOG  PARA EL HIJO042
		FILELOGHIJO43=$DIRLOG/SH010_FILOGHIJ043_$NROIDENTIFI.log #LOG  PARA EL HIJO043
		FILELOGHIJO44=$DIRLOG/SH010_FILOGHIJ044_$NROIDENTIFI.log #LOG  PARA EL HIJO044
		FILELOGHIJO45=$DIRLOG/SH010_FILOGHIJ045_$NROIDENTIFI.log #LOG  PARA EL HIJO045
		FILELOGHIJO46=$DIRLOG/SH010_FILOGHIJ046_$NROIDENTIFI.log #LOG  PARA EL HIJO046
		FILELOGHIJO47=$DIRLOG/SH010_FILOGHIJ047_$NROIDENTIFI.log #LOG  PARA EL HIJO047
		FILELOGHIJO48=$DIRLOG/SH010_FILOGHIJ048_$NROIDENTIFI.log #LOG  PARA EL HIJO048
		FILELOGHIJO49=$DIRLOG/SH010_FILOGHIJ049_$NROIDENTIFI.log #LOG  PARA EL HIJO049
		FILELOGHIJO50=$DIRLOG/SH010_FILOGHIJ050_$NROIDENTIFI.log #LOG  PARA EL HIJO050
		FILELOGHIJO51=$DIRLOG/SH010_FILOGHIJ051_$NROIDENTIFI.log #LOG  PARA EL HIJO051
		FILELOGHIJO52=$DIRLOG/SH010_FILOGHIJ052_$NROIDENTIFI.log #LOG  PARA EL HIJO052
		FILELOGHIJO53=$DIRLOG/SH010_FILOGHIJ053_$NROIDENTIFI.log #LOG  PARA EL HIJO053
		FILELOGHIJO54=$DIRLOG/SH010_FILOGHIJ054_$NROIDENTIFI.log #LOG  PARA EL HIJO054
		FILELOGHIJO55=$DIRLOG/SH010_FILOGHIJ055_$NROIDENTIFI.log #LOG  PARA EL HIJO055
		FILELOGHIJO56=$DIRLOG/SH010_FILOGHIJ056_$NROIDENTIFI.log #LOG  PARA EL HIJO056
		FILELOGHIJO57=$DIRLOG/SH010_FILOGHIJ057_$NROIDENTIFI.log #LOG  PARA EL HIJO057
		FILELOGHIJO58=$DIRLOG/SH010_FILOGHIJ058_$NROIDENTIFI.log #LOG  PARA EL HIJO058
		FILELOGHIJO59=$DIRLOG/SH010_FILOGHIJ059_$NROIDENTIFI.log #LOG  PARA EL HIJO059
		FILELOGHIJO60=$DIRLOG/SH010_FILOGHIJ060_$NROIDENTIFI.log #LOG  PARA EL HIJO060
		
		
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
		pMessageIni 1 $FILELOG "Se ejecuta el SP PKG_CC_PREPAGO.ADMPSI_FECHAFALTA_PRO del proceso"
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
							pMessageIni 1 $FILELOG "Se ejecuta el SP PKG_CC_PREPAGO.ADMPSS_CATEG_PRERECARGA del proceso $PROC"
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
							pMessageIni 1 $FILELOG "Se ejecuta el SP PKG_CC_PREPAGO.ADMPSS_CATEG_PRERECARGA del proceso $PROC"
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
		
		
		######################################
		if [ $NROLINEAS -ge 21 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 21 CON LOG : $FILELOGHIJO21"
			sh $DIRSHELL/SH010_RECARGA.sh "21" 21 $FILELOGHIJO21 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 22 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 22 CON LOG : $FILELOGHIJO22"
			sh $DIRSHELL/SH010_RECARGA.sh "22" 22 $FILELOGHIJO22 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 23 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 23 CON LOG : $FILELOGHIJO23"
			sh $DIRSHELL/SH010_RECARGA.sh "23" 23 $FILELOGHIJO23 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 24 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 24 CON LOG : $FILELOGHIJO24"
			sh $DIRSHELL/SH010_RECARGA.sh "24" 24 $FILELOGHIJO24 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 25 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 25 CON LOG : $FILELOGHIJO25"
			sh $DIRSHELL/SH010_RECARGA.sh "25" 25 $FILELOGHIJO25 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 26 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 26 CON LOG : $FILELOGHIJO26"
			sh $DIRSHELL/SH010_RECARGA.sh "26" 26 $FILELOGHIJO26 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 27 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 27 CON LOG : $FILELOGHIJO27"
			sh $DIRSHELL/SH010_RECARGA.sh "27" 27 $FILELOGHIJO27 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 28 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 28 CON LOG : $FILELOGHIJO28"
			sh $DIRSHELL/SH010_RECARGA.sh "28" 28 $FILELOGHIJO28 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 29 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 29 CON LOG : $FILELOGHIJO29"
			sh $DIRSHELL/SH010_RECARGA.sh "29" 29 $FILELOGHIJO29 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 30 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 30 CON LOG : $FILELOGHIJO30"
			sh $DIRSHELL/SH010_RECARGA.sh "30" 30 $FILELOGHIJO30 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 31 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 31 CON LOG : $FILELOGHIJO31"
			sh $DIRSHELL/SH010_RECARGA.sh "31" 31 $FILELOGHIJO31 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 32 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 32 CON LOG : $FILELOGHIJO32"
			sh $DIRSHELL/SH010_RECARGA.sh "32" 32 $FILELOGHIJO32 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 33 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 33 CON LOG : $FILELOGHIJO33"
			sh $DIRSHELL/SH010_RECARGA.sh "33" 33 $FILELOGHIJO33 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 34 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 34 CON LOG : $FILELOGHIJO34"
			sh $DIRSHELL/SH010_RECARGA.sh "34" 34 $FILELOGHIJO34 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 35 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 35 CON LOG : $FILELOGHIJO35"
			sh $DIRSHELL/SH010_RECARGA.sh "35" 35 $FILELOGHIJO35 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 36 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 36 CON LOG : $FILELOGHIJO36"
			sh $DIRSHELL/SH010_RECARGA.sh "36" 36 $FILELOGHIJO36 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 37 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 37 CON LOG : $FILELOGHIJO37"
			sh $DIRSHELL/SH010_RECARGA.sh "37" 37 $FILELOGHIJO37 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 38 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 38 CON LOG : $FILELOGHIJO38"
			sh $DIRSHELL/SH010_RECARGA.sh "38" 38 $FILELOGHIJO38 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 39 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 39 CON LOG : $FILELOGHIJO39"
			sh $DIRSHELL/SH010_RECARGA.sh "39" 39 $FILELOGHIJO39 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 40 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 40 CON LOG : $FILELOGHIJO40"
			sh $DIRSHELL/SH010_RECARGA.sh "40" 40 $FILELOGHIJO40 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 41 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 41 CON LOG : $FILELOGHIJO41"
			sh $DIRSHELL/SH010_RECARGA.sh "41" 41 $FILELOGHIJO41 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 42 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 42 CON LOG : $FILELOGHIJO42"
			sh $DIRSHELL/SH010_RECARGA.sh "42" 42 $FILELOGHIJO42 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 43 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 43 CON LOG : $FILELOGHIJO43"
			sh $DIRSHELL/SH010_RECARGA.sh "43" 43 $FILELOGHIJO43 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 44 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 44 CON LOG : $FILELOGHIJO44"
			sh $DIRSHELL/SH010_RECARGA.sh "44" 44 $FILELOGHIJO44 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 45 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 45 CON LOG : $FILELOGHIJO45"
			sh $DIRSHELL/SH010_RECARGA.sh "45" 45 $FILELOGHIJO45 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 46 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 46 CON LOG : $FILELOGHIJO46"
			sh $DIRSHELL/SH010_RECARGA.sh "46" 46 $FILELOGHIJO46 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 47 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 47 CON LOG : $FILELOGHIJO47"
			sh $DIRSHELL/SH010_RECARGA.sh "47" 47 $FILELOGHIJO47 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 48 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 48 CON LOG : $FILELOGHIJO48"
			sh $DIRSHELL/SH010_RECARGA.sh "48" 48 $FILELOGHIJO48 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 49 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 49 CON LOG : $FILELOGHIJO49"
			sh $DIRSHELL/SH010_RECARGA.sh "49" 49 $FILELOGHIJO49 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 50 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 50 CON LOG : $FILELOGHIJO50"
			sh $DIRSHELL/SH010_RECARGA.sh "50" 50 $FILELOGHIJO50 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 51 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 51 CON LOG : $FILELOGHIJO51"
			sh $DIRSHELL/SH010_RECARGA.sh "51" 51 $FILELOGHIJO51 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 52 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 52 CON LOG : $FILELOGHIJO52"
			sh $DIRSHELL/SH010_RECARGA.sh "52" 52 $FILELOGHIJO52 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 53 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 53 CON LOG : $FILELOGHIJO53"
			sh $DIRSHELL/SH010_RECARGA.sh "53" 53 $FILELOGHIJO53 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 54 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 54 CON LOG : $FILELOGHIJO54"
			sh $DIRSHELL/SH010_RECARGA.sh "54" 54 $FILELOGHIJO54 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 55 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 55 CON LOG : $FILELOGHIJO55"
			sh $DIRSHELL/SH010_RECARGA.sh "55" 55 $FILELOGHIJO55 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 56 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 56 CON LOG : $FILELOGHIJO56"
			sh $DIRSHELL/SH010_RECARGA.sh "56" 56 $FILELOGHIJO56 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 57 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 57 CON LOG : $FILELOGHIJO57"
			sh $DIRSHELL/SH010_RECARGA.sh "57" 57 $FILELOGHIJO57 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 58 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 58 CON LOG : $FILELOGHIJO58"
			sh $DIRSHELL/SH010_RECARGA.sh "58" 58 $FILELOGHIJO58 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 59 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 59 CON LOG : $FILELOGHIJO59"
			sh $DIRSHELL/SH010_RECARGA.sh "59" 59 $FILELOGHIJO59 $RPTA_CATPRE $FECHAEJC &
		fi;
		######################################
		if [ $NROLINEAS -ge 60 ]; then
			pMessageIni 1 $FILELOG "PROCESANDO HIJO 60 CON LOG : $FILELOGHIJO60"
			sh $DIRSHELL/SH010_RECARGA.sh "60" 60 $FILELOGHIJO60 $RPTA_CATPRE $FECHAEJC &
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
		
				pMessageIni 0 $FILLOG "Se ejecuta el procedimiento de carga PKG_CC_PREPAGO.ADMPSI_PRERECAR"	
					
				IDENTEMP=$(GetNumSecuencial)
				FILETMP=$DIRTMP/"SH010_RECARGA_${IDENTI}_${IDENTEMP}.tmp"			
				EXECPREREC $PROCES $FILETMP
				pMessageIni 0 $FILLOG "Se termina de ejecutar el procedimiento de carga PKG_CC_PREPAGO.ADMPSI_PRERECAR"	
				
				
				pMessageIni 0 $FILLOG "Se valida la existencia de errores durante la ejecución"				
				VALIDAT_CTL1=`grep 'ORA-' $FILLOG | wc -l`
				
				IDENTEMP=$(GetNumSecuencial)
				FILETMPVAL=$DIRTMP/"SH010_RECARGA_VERIF_${IDENTI}_${IDENTEMP}.tmp"	
				
				pMessageIni 0 $FILLOG "Verificando si se termino de procesar la recarga del proceso $PROCES"	
				VerificarActualizarSaldos $PROCES $FILETMPVAL
				
				TMPVALIDPRIMLIN=`head -1 $FILETMPVAL`
				CODIGOOBT_ERROR=`echo $TMPVALIDPRIMLIN | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}'`
				DESCMSG_OBT=`echo $TMPVALIDPRIMLIN | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $2}'`
				COUNT_OBT=`echo $TMPVALIDPRIMLIN | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $3}'`
				
				pMessageIni 0 $FILLOG "VALIDACION PROCESO RECARGA"
				pMessageIni 0 $FILLOG "CODIGO ERROR: $CODIGOOBT_ERROR"
				pMessageIni 0 $FILLOG "MENSAJE ERROR: $DESCMSG_OBT"
				pMessageIni 0 $FILLOG "CANT REG PENDIENTES: $COUNT_OBT"
				
				if [ $CODIGOOBT_ERROR -eq 0 ]; then
					pMessageIni 0 $FILLOG "Se realizo la verificacion del procesamiento de recarga del proceso $PROCES"	
					if [ $COUNT_OBT -eq 0 ]; then
						pMessageIni 0 $FILLOG "Se procesaron todos los registros correctamente $PROCES"	
					else
					    pMessageIni 0 $FILLOG "No se realizo la recarga de todos los registros del proceso $PROCES"	
						pMessageIni 0 $FILLOG "Se procedera a realizar la recarga de los registros pendientes del proceso $PROCES"
						
						sh $DIRSHELL/SH010_RECARGA.sh $PROCES $PROCES $FILLOG 1 $FECHAEJC &
						exit
					fi
			    else
				    pMessageIni 0 $FILLOG "Sucedio el siguiente error en el proceso de verificacion del proceso $PROCES :"	
					pMessageIni 0 $FILLOG "Error: $DESCMSG_OBT"
				fi
				
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