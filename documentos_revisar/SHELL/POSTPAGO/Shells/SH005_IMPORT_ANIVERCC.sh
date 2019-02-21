#! /bin/ksh
#*************************************************************
#* DESCRIPCION           : Importacion de Puntos por Aniversario                                    *
#* EJECUCION             : Control-D                                                          *
#* AUTOR                 : Maomed Alexandr Chocce C.                                   *
#* FECHA                 : 03/11/2010   VERSION : v1.0                        *
#* FECHA MOD .           :                         *
#*************************************************************

#Iniciación de Variables
# Inicializacion de Variables
. /home/usrclaroclub/CLAROCLUB/Interno/Postpago/Bin/.varset
. /home/usrclaroclub/CLAROCLUB/Interno/Postpago/Bin/.passet
. /home/usrclaroclub/CLAROCLUB/Interno/Postpago/Bin/.mailset
#-----------------------------------------------------------------
#	FUNCION PARA MANEJO DEL LOG
#-----------------------------------------------------------------
pMessage () {   
   LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
   echo "($LOGDATE) $*" 
   echo "($LOGDATE) $*"  >> $FILELOG
} # pMessage	


# Rutas
FECHA=`date +%Y%m%d_%H%M%S`
FARCH=`date +%Y%m%d`
CONTROL=$DIRCONTROLPOST/importaPuntosAnivers.ctl
BAD=$DIRBADPOST/importaPuntosAnivers_BAD_$FECHA.bad
FILELOG=$DIRLOGPOST/SH005_PUNTOSANIV_$FECHA.log
#FILELOG2=TMPimportaPuntosAnivers_LOG_$FECHA.log
CTL_LOG=$DIRLOGPOST/CTL005_LOG_$FECHA.log
ARCHNAME=ANIVERSARIO_$FARCH.CCL

if [ "$1" = "" ] ; then
	ARCHPRMT=""
else
	ARCHPRMT1=${1#*ANIVERSARIO_}
	ARCHPRMT=ANIVERSARIO_$ARCHPRMT1
fi

RUTANAME=$DIRENTRADAPOST
#ARCHSHELL=SH005_SP_ADMPSI_ANIVER.sh


# Inicio
demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "*************************************" 
pMessage "Iniciando proceso               " 
pMessage "Fecha y Hora : $demora               "
pMessage "*************************************" 

####Proceso####
# File Data: Se buscara el archivo(con su ruta) ya sea ingresado desde el programa o buscarlo en la carpeta de Origen

if [ "$ARCHPRMT" = "" ] ; then
	FILEDATA=`find $RUTANAME/$ARCHNAME`
	CANT_DATA=`cat  $RUTANAME/$ARCHNAME | wc -l | sed 's/ //g'`
	ARCHFECHA=${ARCHNAME:12:8}
	ARCHNAMEF=$ARCHNAME
else
	FILEDATA=`find $RUTANAME/$ARCHPRMT`
	CANT_DATA=`cat  $RUTANAME/$ARCHPRMT | wc -l | sed 's/ //g'`
	ARCHNAMEF=$ARCHPRMT
	ARCHFECHA=${ARCHPRMT:12:8}
fi

dos2unix ${FILEDATA}

TMP=$DIRLOGPOST/TEMPDATA05.tmp
echo "" >> ${FILEDATA}
cat ${FILEDATA} | sed '/^$/d' > $TMP
cat $TMP > ${FILEDATA}
		
rm -f $TMP

if [ "$FILEDATA" = "" ] ; then
   Demora=`date +"%Y-%m-%d %H:%M:%S"`
   pMessage "Error: No se encontro el archivo de datos..." 
   pMessage "Termino proceso"
   pMessage "************************************" 
   pMessage " FINALIZANDO PROCESO..............." 
   pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso " 
   pMessage "************************************" 
   pMessage "No existe ninguno de estos archivos $ARCHNAME" 
   pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Aniversario no se encuentra en la ruta" 
   echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo de Aniversario no se encuentra en la ruta." $IT_MAIL 
   pMessage "Ruta del Archivo log : " $FILELOG
   echo $'\n'
   exit -1
fi

if [ $CANT_DATA = 0 ] ; then
	pMessage "Ninguno de estos archivos tiene data $ARCHNAME" 
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Aniversario se encuentra vacio." 
	echo "Buen día, los siguientes archivos $ARCHNAME en la carpeta de ORIGEN no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "El Archivo de Aniversario se encuentra vacio" $IT_MAIL
	pMessage "Se envió correo Fecha y Hora: $demora"
	exit -1
fi


TEMP_FILE=TEMP01_${FECHA}.TMP

ARCHPRMT2=${FILEDATA#*ANIVERSARIO_}
ARCHPRMT3=ANIVERSARIO_$ARCHPRMT2

while read FIELD02
do
	echo "${FIELD02}|${ARCHPRMT2:0:8}|${ARCHPRMT3}" >> $DIRLOGPOST/$TEMP_FILE	
done < $FILEDATA

pMessage "Se procede a importar los datos del archivo de entrada a la tabla de aniversario"
sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$CONTROL data=$DIRLOGPOST/$TEMP_FILE bad=$BAD log=$CTL_LOG bindsize=200000 readsize=200000 rows=1000 skip=0

rm -f $DIRLOGPOST/$TEMP_FILE

VALIDAT_CTL=`grep 'ORA-' $CTL_LOG | wc -l`		
if [ $VALIDAT_CTL -ne 0 ]
    then
    pMessage "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n'
    pMessage "FECHA $Demora - Verifique el log para mayor detalle $FILELOG"$'\n'
    pMessage `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n' 
    pMessage "Termino proceso"
    pMessage "************************************" 
    pMessage " FINALIZANDO PROCESO..............." 
    pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso " 
    pMessage "************************************" 
    pMessage "Ruta del Archivo log : " $FILELOG
    echo $'\n'
	exit -1
fi

pMessage "El proceso de importacion culmino satisfactoriamente"

rm -f $CTL_LOG
	
cp $FILEDATA $DIRBACKUPPOST
echo "Ruta Shell: $DIR_POST_SHELL/$ARCHSHELL"
echo "$ARCHPRMT"
		
if [ "$ARCHPRMT" = "" ] ; then
	ARCHNAME2=""
	#sh $DIR_POST_SHELL/$ARCHSHELL
else		
	ARCHNAME2=$FILEDATA
	#sh $DIR_POST_SHELL/$ARCHSHELL $FILEDATA
fi

#---

ARCHNAME=ANIVERSARIO_$FARCH.CCL
#ARCHNAME2=$1
#ARCH_TEMP=aniversario_log_$FARCH.txt
#ARCHSHELL=SH005_SP_ADMPSI_EANIVER.sh
#FILELOG=$DIRLOGPOST/importaAniversario_LOG_$FECHA.log


if [ "$ARCHNAME2" = "" ] ; then
	FINDFILE=`find $DIRENTRADAPOST/$ARCHNAME`
	CANT_DATA=`cat  $DIRENTRADAPOST/$ARCHNAME | wc -l | sed 's/ //g'`
else
	FINDFILE=`find $ARCHNAME2`
	CANT_DATA=`cat $ARCHNAME2 | wc -l | sed 's/ //g'`
fi

if [ "$ARCHNAME2" = "" ] ; then
	FECHAARCH=$FARCH
else
	ARCHPRMT1=${ARCHNAME2#*ANIVERSARIO_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi

echo "$FECHAARCH"
FECHATMP="'"${FECHAARCH}"'"
#Flujo corroborar archivos

if [ "$FINDFILE" = "" ]; then
   pMessage " $demora: Error: No se encontro el archivo de datos..." 
   pMessage "Termino proceso"
   pMessage "************************************" 
   pMessage " FINALIZANDO PROCESO..............." 
   pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso " 
   pMessage "************************************" 
   pMessage "No existe ninguno de estos archivos $ARCHNAME" 
   pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Aniversario no se encuentra en la ruta" 
   echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $DIRORIGEN." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo de Aniversario no se encuentra en la ruta." $IT_MAIL 
   pMessage "Ruta del Archivo log : " $FILELOG
   echo $'\n'
   exit -1
fi

if [ $CANT_DATA = 0 ] ; then
	pMessage "Ninguno de estos archivos tiene data $ARCHNAME" 
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Aniversario se encuentra vacio." 
	echo "Buen día, los siguientes archivos $ARCHNAME en la carpeta de ORIGEN no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "El Archivo de Aniversario se encuentra vacio" $IT_MAIL
	pMessage "Se envió correo Fecha y Hora: $demora"
	exit -1
fi
	
pMessage "Se procede a ejecutar el SP PKG_CC_PROCACUMULA.admpsi_anivers"
sqlplus -s $USER_BD/$CLAVE_BD@$SID_BD <<EOP  >> ${FILELOG}
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
		
v_fecha 	date;		
k_coderror  number;
k_descerror varchar2(400);
k_numregtot number;
k_numregpro number;
k_numregerr number;
				
BEGIN
		
	SELECT TO_DATE($FECHATMP,'YYYYMMDD') INTO v_fecha FROM DUAL;
	begin
							
		$PCLUB_OW.PKG_CC_PROCACUMULA.admpsi_anivers(v_fecha,k_coderror,
						k_descerror,
						k_numregtot,
						k_numregpro,
						k_numregerr);
	end;
		
	dbms_output.put_line('Codigo de error: ' || k_coderror || '|Mensaje de error: ' || k_descerror || '|Nº total de registros: ' || k_numregtot || '|Nº de registros procesados: ' || k_numregpro || '|Nº de registros con errores: ' || k_numregerr);
		
    END;
	
/
exit
EOP

VALIDA_EJEC_SP=`grep 'ORA-' ${FILELOG} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B=`grep 'SP2-' ${FILELOG} | wc -l | sed 's/ //g'`

if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
    pMessage "Hubo un error durante la ejeción del SP pkg_cc_procacumula.admpsi_anivers" 
    pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de IMPORTACION DE PUNTOS POR ANIVERSARIO – Se encontraron errores" 
    echo "Buen día, ocurrio un problema al ejecutar el SP de pkg_cc_procacumula.admpsi_anivers." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "IMPORTACION DE PUNTOS POR ANIVERSARIO – Se encontraron errores" $IT_MAIL 		
    pMessage "Se envió correo Fecha y Hora: $demora"    
	exit
fi

pMessage "Ejecución de SP fue satisfactorio"

if [ "$ARCHNAME2" = "" ] ; then
	ARCHNAME2=""
	#sh $DIR_POST_SHELL/$ARCHSHELL
else
	ARCHNAME2=${FINDFILE}
	#sh $DIR_POST_SHELL/$ARCHSHELL ${FINDFILE}
fi

#---

ARCHNAME=ANIVERSARIO_${FARCH}.CCL
ARCHERR=ANIVERSARIO_${FARCH}
ARCHERR2=ANIVERSARIO_param_${FARCH}
ARCHNAME2=$1
#ARCHSHELL=SH005_EJECUTASPEANIVER.sh
#FILELOG=$DIRLOGPOST/importaErrorPuntosAniversario_LOG_$FECHA.log


if [ "$ARCHNAME2" = "" ] ; then
	FINDFILE=`find $DIRENTRADAPOST/$ARCHNAME`
	FINDBKP=`find $DIRBACKUPPOST/$ARCHNAME`
else
	FINDFILE2=`find $ARCHNAME2`
fi

if [ "$ARCHNAME2" = "" ] ; then
	STRINGRUTA=$ARCHNAME
	FECHAARCH=${FARCH}
else
	STRINGRUTA=$ARCHNAME2
	ARCHPRMT1=${STRINGRUTA#*ANIVERSARIO_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi


if [ "$FINDFILE" = "" ] && [ "$FINDBKP" = "" ] && [ "$FINDFILE2" = "" ] ; then
	pMessage "Hora y Fecha: $demora"
	pMessage "No existe el archivo $ARCHNAME "
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Aniversario no se encuentra en la ruta."
	echo "Buen día, no se encontro el siguiente archivo $ARCHNAME en la carpeta de $DIRENTRADAPOST." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo de Aniversario no se encuentra en la ruta." $IT_MAIL 
	pMessage "Se envió correo Fecha y Hora: $demora"
	exit
fi

#Verificamos que archivo se encuentra en la carpeta de backup
		
if [ "$ARCHNAME2" != "" ] ; then
		FILEERR=${ARCHERR2}.ERR        
		FILERMV2=$ARCHNAME2             
else
	FILEERR=${ARCHERR}.err
	FILERMV=$DIRBACKUPPOST/$ARCHNAME
	FILERMV2=$DIRENTRADAPOST/$ARCHNAME        
fi
			
#Ejecucion del shell
	
#sh $DIR_POST_SHELL/$ARCHSHELL ${DIRFALLOSPOST}/${FILEERR} ${FECHAARCH}

#---
pMessage "Se procede a ejecutar el SP pkg_cc_procacumula.admpsi_eanivers y exportar los datos obtenidos"
sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> ${DIRFALLOSPOST}/${FILEERR}
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
  
  type ty_cursor is ref cursor;
  CURSORANIVER ty_cursor;
  c_cod_cli VARCHAR2(40);
  c_periodo	VARCHAR2(6);
  c_cod_error char(2);
  c_msje_error varchar2(400);
  v_fecha date;
  
  BEGIN
  
  dbms_output.enable(NULL);
  
  SELECT TO_DATE(${FECHAARCH},'YYYYMMDD') INTO v_fecha FROM DUAL;
  begin
    $PCLUB_OW.pkg_cc_procacumula.admpsi_eanivers(v_fecha,CURSORANIVER);
   end;
   
  LOOP
  
  fetch CURSORANIVER into c_cod_cli,c_periodo,c_cod_error,c_msje_error;
  exit when CURSORANIVER%notfound;
  
  DBMS_OUTPUT.put_line(c_cod_cli || '|' || c_periodo || '|' ||  c_cod_error || '|' || c_msje_error );
  
  END LOOP;
  
  CLOSE CURSORANIVER;
  
  EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
  END;
/
EXIT

EOP


#---

	
CANT_DATA=`cat ${DIRFALLOSPOST}/${FILEERR} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP=`grep 'ORA-' ${DIRFALLOSPOST}/${FILEERR} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B=`grep 'SP2-' ${DIRFALLOSPOST}/${FILEERR} | wc -l | sed 's/ //g'`
    
if [ $CANT_DATA = 0 ] ; then
	pMessage "El archivo no trajo datos, asi que no se podra generar en la carpeta destino"
	rm ${DIRFALLOSPOST}/${FILEERR}
else
	pMessage "Se ha generado el archivo ${DIRFALLOSPOST}/${FILEERR}"
fi

if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
	cat ${DIRFALLOSPOST}/${FILEERR} 
    pMessage "Hubo un error durante la ejeción del SP pkg_cc_procacumula.admpsi_eanivers"        
	exit
fi

pMessage "Ejecución de SP fue satisfactorio"
		   
#if [ "$ARCHNAME2" = "" ] ; then
#	mv ${FILERMV2} $DIRPROCPOST

#else
#	mv ${ARCHNAME2} $DIRPROCPOST
#fi	  
	   
pMessage "Se finalizó el proceso de Ejecución de EANIVERS" 

#---

pMessage "Se finalizó el proceso de Ejecución de ANIVERSARIO" 

#---

pMessage "Fin de todo el Proceso de Aniversario"

exit
