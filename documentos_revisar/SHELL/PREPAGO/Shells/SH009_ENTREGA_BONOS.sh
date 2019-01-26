#!/bin/sh -x
###########################################################
#PROGRAMA         : SH009_ENTREGA_BONO.SH
#DESCRIPCIÓN      : PROCESO PARA ENTREGA DE BONOS 
#FECHA CREACIÓN   : 19/12/2013
#USUARIO CREACIÓN : LUIS HENRY HERRERA CHICANA
###########################################################

. /home/usrclaroclub/CLAROCLUB/Interno/Prepago/Bin/.varset
. $HOME_PREPAGO/Bin/.passet
. $HOME_PREPAGO/Bin/.mailset

#VARIABLES
FECHAHORA=`date +'%Y-%m-%d %H:%M:%S'`
USER_SERV=`whoami`
NUIP_SERV=`cat /etc/sysconfig/network-scripts/ifcfg-eth0|grep IPADDR|sed 's/^[A-Z].*=//'`
ASUNTO_MAIL="STATUS ENTREGA DE BONOS"

#FUNCIONES
GetNumSecuencial(){
 echo `date +'%Y%m%d%H%M%S%N'`
}

pMessage(){   
	LOGFILE=$1
	LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
  echo "[$LOGDATE] $2"  >> $LOGFILE
}

ValidConex() {
#Procedimiento para validar conexion a base de datos
#  1 hay conexion
# -1 No existe conexion
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

IniciShell(){
  FILLOGM=$1
	NROPROC=$2
	pMessage $FILLOGM "________________________________________________________________________"
	pMessage $FILLOGM "            INICIANDO ENTREGA DE BONOS : $NROPROC                       "  
	pMessage $FILLOGM "________________________________________________________________________"
	pMessage $FILLOGM "   FECHA Y HORA     |          ${FECHAHORA}                             "  
	pMessage $FILLOGM "   USUARIO          |          $USER_SERV                               " 
	pMessage $FILLOGM "   SHELL            |          $0                                       " 
	pMessage $FILLOGM "   NUM. IP          |          $NUIP_SERV      	  	                   " 
	pMessage $FILLOGM "________________________________________________________________________"
}

FinalShell() {
  #Presentacion de  salida
	FILLOGM=$1
	HORAINI=$2
	NROPROC=$3
  FECHAHORA=`date +'%Y-%m-%d %H:%M:%S'`
  HORAFIN=`date +'%H%M%S'`
  INTERVA=$(InterlTime $HORAINI $HORAFIN)
	pMessage $FILLOGM "________________________________________________________________________" 
	pMessage $FILLOGM "        FINALIZAR ENTREGA DE BONOS : $NROPROC                           " 
	pMessage $FILLOGM "________________________________________________________________________"
	pMessage $FILLOGM "    FECHA Y HORA     |        ${FECHAHORA}                              " 
	pMessage $FILLOGM "    USUARIO          |        $USER_SERV	                               " 
	pMessage $FILLOGM "    SHELL            |        $0               	                       " 
	pMessage $FILLOGM "    NUM. IP          |        $NUIP_SERV     			                     " 
	pMessage $FILLOGM "    Tiempo Ejecutado |        $INTERVA       			                     " 
	pMessage $FILLOGM "________________________________________________________________________"
}

InterlTime() {

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

CopFileLog(){
  #Copia el contenido de un archivo al log con su formato de fecha y hora
  File1=$1		# Archivo Origen
  File2=$2
  echo " " >> $File1
  if [ -e $File1 ];  then
		while read linea 
		do
			LOGDATE=`date +"%d-%m-%Y %H:%M:%S"` #Este formato debe ser unico del 
			echo "[$LOGDATE] $linea " >>$File2
		done < $File1
  fi
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

EXEC_OBTENER_LINEAS(){
USER=$1
PASS=$2
BASE=$3
NPRO=$4
FILE=$5
sqlplus -s $USER/$PASS@$BASE <<EOP> $FILE
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
  NPROC  NUMERIC:=$NPRO;
  NERRO   NUMERIC;
  V_SEQ   NUMBER;
  V_TELEF VARCHAR2(20);
  V_IDBON  NUMBER;
  V_DBONO VARCHAR2(20);
  DESCR  VARCHAR2(250);
  CURS_REGIS  CURSOREF;
	BEGIN
	$PCLUB_OW.PKG_CC_BONOS.ADMPSS_LINEAS_NOPROC_BONO(NPROC,CURS_REGIS,NERRO,DESCR);
  IF NERRO !=0 THEN
		DBMS_OUTPUT.PUT_LINE(TO_CHAR(NERRO) ||'|' || DESCR);
  ELSE
		LOOP  
			FETCH CURS_REGIS INTO  V_SEQ, V_TELEF,V_IDBON,V_DBONO;
			EXIT WHEN CURS_REGIS%NOTFOUND;
			IF V_IDBON IS NULL THEN
				DBMS_OUTPUT.PUT_LINE(NVL(TO_CHAR(V_SEQ),'') || '|' || V_TELEF || '|' || NVL(TO_CHAR(V_IDBON),'') || '|' || NVL(TO_CHAR(V_DBONO),'') || '|' || '2|' );
			ELSE
				DBMS_OUTPUT.PUT_LINE(NVL(TO_CHAR(V_SEQ),'') || '|' || V_TELEF || '|' || NVL(TO_CHAR(V_IDBON),'') || '|' || NVL(TO_CHAR(V_DBONO),'') || '|' || '1|' );
			END IF;
		END LOOP;
  END IF;
	CLOSE CURS_REGIS; 
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

EXEC_REPARTO_DATOSL(){
FILEDATA=$1
FILEDA01=$2
FILEDA02=$3
FILEDA03=$4
IDENTIFI=$5
RETORNA=0
if [ -f $FILEDATA ]; then
	NROLINEAS=`wc -l $FILEDATA | awk '{print $1}'`
	if [ $NROLINEAS -gt 0 ] ; then
	  cd $DIRTMP
		NEWNROLIN=`expr $NROLINEAS / 3`
		MODULOPER=`expr $NROLINEAS % 3`
		#Para considerar que tome todo los registros debemos tomar la 
		#siguiente logica si no es exacta la divicion tomar el modulo
		if [ $MODULOPER -ne 0 ]; then
		 NEWNROLIN=`expr $NEWNROLIN + 2`
		fi
		split -dl $NEWNROLIN $FILEDATA "DATOS_${IDENTIFI}_"
		cd $DIRSHELL
		if [ -f "$DIRTMP/DATOS_${IDENTIFI}_00" ]; then
			mv "$DIRTMP/DATOS_${IDENTIFI}_00" $FILEDA01
			#sed '/^$/d' $FILEDA01 > $FILEDA01               #Eliminar lineas en blanco si los tuviera
			RETORNA=1
		fi
		if [ -f "$DIRTMP/DATOS_${IDENTIFI}_01" ]; then
			mv "$DIRTMP/DATOS_${IDENTIFI}_01" $FILEDA02
			#sed '/^$/d' $FILEDA02 > $FILEDA02
			RETORNA=1
		fi
		if [ -f "$DIRTMP/DATOS_${IDENTIFI}_02" ]; then
			mv "$DIRTMP/DATOS_${IDENTIFI}_02" $FILEDA03
			#sed '/^$/d' $FILEDA03 > $FILEDA03
			RETORNA=1
		fi
	fi
else
 RETORNA=-1
fi
echo $RETORNA
}

EXEC_ENTREGA_BONOSL(){
USER=$USER_BD 
PASS=$CLAVE_BD 
BASE=$SID_BD
SEQ=$1
TELF=$2
IDBO=$3
DEBO=$4
TIPO=$5
FILE=$6
PRIV=$7

sqlplus -s $USER/$PASS@$BASE <<EOP> $FILE
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
  V_SEQ  NUMBER:='$SEQ';
  V_LINEA  VARCHAR2(20):='$TELF';
  V_USERS  VARCHAR2(20):='$PRIV';
  V_MENSA  VARCHAR2(200);
  V_CODER  VARCHAR2(200);
  V_DESER  VARCHAR2(200);
  V_TENTR  NUMERIC:='$TIPO';
BEGIN
  IF V_TENTR = 2 THEN
		$PCLUB_OW.PKG_CC_BONOS.ADMPSI_PROC_ENTREGA_BONO(NULL,'$DEBO',V_SEQ, V_LINEA ,V_USERS, V_MENSA,V_CODER,V_DESER);
		DBMS_OUTPUT.PUT_LINE(TO_CHAR(V_CODER) || '|'|| V_DESER || '|'|| V_MENSA);
  ELSIF V_TENTR = 1 THEN
    $PCLUB_OW.PKG_CC_BONOS.ADMPSI_PROC_ENTREGA_BONO('$IDBO',NULL,V_SEQ, V_LINEA,V_USERS,V_MENSA,V_CODER,V_DESER);
		DBMS_OUTPUT.PUT_LINE(TO_CHAR(V_CODER) || '|'|| V_DESER || '|'|| V_MENSA);
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

#############################################################################################
########################################## M A I N ########################################## 
#############################################################################################

NROPARAMETROS=$#
if [ $NROPARAMETROS -eq 0 ]; then
	
	#PROCESO PADRE
	HORAINICIOP=`date +'%H%M%S'`
	NROIDENTIFI=$(GetNumSecuencial)
	FILELOGPADRE=$DIRLOG/SH009_LOGPADRE_$NROIDENTIFI.log #LOG  PARA EL PADRE
	FILEDATPADRE=$DIRTMP/SH009_DATPADRE_$NROIDENTIFI.dat #DATA PARA EL PADRE
	FILEVALCONNE=$DIRTMP/SH009_CONEXIBD_$NROIDENTIFI.tmp
	
	FILELOGHIJ01=$DIRLOG/SH009_LOGHIJ01_$NROIDENTIFI.log #LOG  PARA EL HIJO01
	FILEDATHIJ01=$DIRTMP/SH009_DATHIJ01_$NROIDENTIFI.dat #DATA 
	FILEBUHIJO01=$DIRTMP/SH009_OKSHIJ01_$NROIDENTIFI.tmp #PROCESADO
	FILEERHIJO01=$DIRTMP/SH009_ERRHIJ01_$NROIDENTIFI.tmp #ERRADO
	
	FILELOGHIJ02=$DIRLOG/SH009_LOGHIJ02_$NROIDENTIFI.log #LOG  PARA EL HIJO02
	FILEDATHIJ02=$DIRTMP/SH009_DATHIJ02_$NROIDENTIFI.dat #DATA 
	FILEBUHIJO02=$DIRTMP/SH009_OKSHIJ02_$NROIDENTIFI.tmp #PROCESADO
	FILEERHIJO02=$DIRTMP/SH009_ERRHIJ02_$NROIDENTIFI.tmp #ERRADO
	
	FILELOGHIJO3=$DIRLOG/SH009_LOGHIJ03_$NROIDENTIFI.log #LOG  PARA EL HIJO03	
	FILEDATHIJ03=$DIRTMP/SH009_DATHIJ03_$NROIDENTIFI.dat #DATA 
	FILEBUHIJO03=$DIRTMP/SH009_ERRHIJ03_$NROIDENTIFI.tmp #PROCESADO
	FILEERHIJO03=$DIRTMP/SH009_OKSHIJ03_$NROIDENTIFI.tmp #ERRADO
	
	IniciShell $FILELOGPADRE "00"
	STADOCONEX01=$(ValidConex $USER_BD $CLAVE_BD $SID_BD $FILEVALCONNE )                  #Estado conexion 
	if [ $STADOCONEX01 -eq -1 ] ; then
		pMessage $FILELOGPADRE "No existe conectividad con la base de datos"
		FinalShell $FILELOGPADRE $HORAINICIOP "00"
		Send_Email "$IT_SOAP" "$ASUNTO_MAIL" "No existe conectividad con la base de datos" "$FILELOGPADRE"
		exit
	fi
	
	STADOOBTENE=$(EXEC_OBTENER_LINEAS $USER_BD $CLAVE_BD $SID_BD $NROPROCES $FILEDATPADRE)
	if [ $STADOOBTENE -eq -1 ]; then
		pMessage $FILELOGPADRE "Error al generar la información de las linea a entregar el bono"
		FinalShell $FILELOGPADRE $HORAINICIOP "00"
		Send_Email "$IT_SOAP" "$ASUNTO_MAIL" "Error al generar la información de las linea a entregar el bono" "$FILELOGPADRE"
		exit
	fi
	
	#sed '/^$/d' $FILEDATPADRE >> $FILEDATPADRE               #Eliminar lineas en blanco si los tuviera
	NROLINEAS=`wc -l $FILEDATPADRE | awk '{print $1}'`
	if [ $NROLINEAS -eq 0 ]; then
		pMessage $FILELOGPADRE "No se puede ejecutar no existe información a procesar"
		FinalShell $FILELOGPADRE $HORAINICIOP "00"
		Send_Email "$IT_SOAP" "$ASUNTO_MAIL" "No se puede ejecutar no existe información a procesar" "$FILELOGPADRE"
	fi
	
	STADOOBTDAT=$(EXEC_REPARTO_DATOSL $FILEDATPADRE $FILEDATHIJ01 $FILEDATHIJ02 $FILEDATHIJ03 NROIDENTIFI)
	if [ $STADOOBTDAT -ne 1 ]; then
		pMessage $FILELOGPADRE "Error al generar segmentación de información para los procesos en paralelo"
		FinalShell $FILELOGPADRE $HORAINICIOP "00"
		Send_Email "$IT_SOAP" "$ASUNTO_MAIL" "Error al generar segmentación de información para los procesos en paralelo" "$FILELOGPADRE"
		exit
	else
	  #PROCESOS EN PARALELO PARA LOS TRES(3) HIJOS 
		pMessage $FILELOGPADRE "PROCESANDO HIJO 01 CON LOG : $FILELOGHIJ01"
		sh $DIRSHELL/SH009_ENTREGA_BONOS.sh "01" $FILELOGHIJ01 $FILEDATHIJ01 $FILEBUHIJO01 $FILEERHIJO01 &
		pMessage $FILELOGPADRE "PROCESANDO HIJO 02 CON LOG : $FILELOGHIJ02"
		sh $DIRSHELL/SH009_ENTREGA_BONOS.sh "02" $FILELOGHIJ02 $FILEDATHIJ02 $FILEBUHIJO02 $FILEERHIJO02 &
		pMessage $FILELOGPADRE "PROCESANDO HIJO 03 CON LOG : $FILELOGHIJO3"
		sh $DIRSHELL/SH009_ENTREGA_BONOS.sh "03" $FILELOGHIJO3 $FILEDATHIJ03 $FILEBUHIJO03 $FILEERHIJO03 &
		
		pMessage $FILELOGPADRE "FIN DE PROCESO"
		FinalShell $FILELOGPADRE $HORAINICIOP "00"
		Send_Email "$IT_SOAP" "$ASUNTO_MAIL" "FIN DE PROCESO" "$FILELOGPADRE"
	fi	
else
	#PROCESO HIJOS
	HORCHI=`date +'%H%M%S'`
	IDENTI=$1
	FILLOG=$2
	FILDAT=$3
	FILOKS=$4
	FILERR=$5
	####################################################################################
	IniciShell $FILLOG "$IDENTI"
	if [ -f $FILDAT ]; then
		NROLINEAS=`wc -l $FILDAT | awk '{print $1}'`
		if [ $NROLINEAS -gt 0 ]; then
			
			if [ ! -f $FILOKS ]; then
				# echo "LISTADO DE LINEAS CON ENTREGA DE BONOS" > $FILOKS
				 echo " " > $FILOKS
			fi
			
			# if [ ! -f $FILERR ]; then
				# echo "LISTADO DE LINEAS SIN ENTREGA DE BONOS" > $FILERR
				# echo " " >> $FILERR
			# fi
			SWFLAGOK=0
			SWFLAGER=0
			while read REGISTRO
			do
				IDENTEMP=$(GetNumSecuencial)
				SEQ=`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}'`
				TELEFONO=`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $2}'`
				IDENBONO=`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $3}'`
				DESCBONO=`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $4}'`
				TIPOENTR=`echo $REGISTRO | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $5}'`
				FILETMPO=$DIRTMP/"SH009_${IDENTI}_${TELEFONO}_${IDENTEMP}.tmp"
				if [ "$TELEFONO" != "" ]; then
					#Artificio para no pasar en blanco porque si no el nro de parametros en igual a menos 1
					echo "$SEQ|$TELEFONO|$IDENBONO|$DESCBONO" >> $FILOKS
					if [ $TIPOENTR -eq 1 ]; then
						#DESCBONO es nulo pero hay que enviar valor si o si por eso XX para que no se pierda el nro de parametros
						STADOBONOEN=$(EXEC_ENTREGA_BONOSL $SEQ $TELEFONO $IDENBONO 'XX' $TIPOENTR $FILETMPO $USER_BONOS)
					elif [ $TIPOENTR -eq 2 ]; then
						#IDENBONO es nulo pero hay que enviar valor si o si por eso XX para que no se pierda el nro de parametros
						STADOBONOEN=$(EXEC_ENTREGA_BONOSL $SEQ $TELEFONO 'XX' $DESCBONO $TIPOENTR $FILETMPO $USER_BONOS)
					fi
					if [ $STADOBONOEN -ne 1 ]; then
						SWFLAGER=1
						echo "$SEQ|$TELEFONO|$IDENBONO|$DESCBONO" >> $FILERR
					else
						if [ -f $FILETMPO ]; then
							PRIMERALINEA=`head -1 $FILETMPO`
							OPERACIONTRA=`echo $PRIMERALINEA | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}'`
							if [ $OPERACIONTRA -ne 0 ]; then
								SWFLAGER=1
								#echo "$SEQ|$TELEFONO|$IDENBONO|$DESCBONO" >> $FILERR
							else
								SWFLAGOK=1
								#echo "$SEQ|$TELEFONO|$IDENBONO|$DESCBONO" >> $FILOKS
							fi
						else
							SWFLAGER=1
							#echo "$SEQ|$TELEFONO|$IDENBONO|$DESCBONO" >> $FILERR
						fi
					fi
				fi #Telefono debe ser diferente de vacios
				
				#ELIMINACION DE ARCHIVO TEMPORAL POR LINEA
				if [ -f $FILETMPO ]; then
					rm $FILETMPO
				fi
			done < $FILDAT
			########################################################
			#RESUMENES
			########################################################
			if [ $SWFLAGOK -eq 1 ]; then
				$(CopFileLog $FILOKS $FILLOG)
			fi
			if [ $SWFLAGER -eq 1 ]; then
				$(CopFileLog $FILERR $FILLOG)
			fi
			FinalShell $FILLOG $HORCHI "$IDENTI"
			Send_Email "$IT_SOAP" "$ASUNTO_MAIL PROCESO $IDENTI" "FIN DE PROCESO $IDENTI" "$FILLOG"
			exit
		else
			pMessage $FILLOG "Error el archivo se fuente de datos se encuentra vació"
			FinalShell $FILLOG $HORCHI "$IDENTI"
			Send_Email "$IT_SOAP" "$ASUNTO_MAIL PROCESO $IDENTI" "Error el archivo se fuente de datos se encuentra vació" "$FILLOG"
			exit
		fi
	else
		pMessage $FILLOG "Error no existe archivo fuente de datos para procesar información"
		FinalShell $FILLOG $HORCHI "$IDENTI"
		Send_Email "$IT_SOAP" "$ASUNTO_MAIL PROCESO $IDENTI" "Error no existe archivo fuente de datos para procesar información" "$FILLOG"
		exit
	fi
	####################################################################################	
fi
exit



