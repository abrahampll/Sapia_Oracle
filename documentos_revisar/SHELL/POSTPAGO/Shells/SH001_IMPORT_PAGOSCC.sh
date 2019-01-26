#! /bin/ksh
#*************************************************************
#* DESCRIPCION           : Importacion de Pagos - Claro Club                                    *
#* EJECUCION             : Control-D                                                          *
#* AUTOR                 : E75818  -  Luis De la Fuente                                   *
#* FECHA                 : 26/10/2010   VERSION : v1.0                        *
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
CONTROL=$DIRCONTROLPOST/importaPagoCC.ctl
BAD=$DIRBADPOST/importaPago_BAD_$FECHA.bad
FILELOG=$DIRLOGPOST/SH001_IMPPAGO_$FECHA.log
CTL_LOG=$DIRLOGPOST/CTL001_LOG_$FECHA.log
ARCHNAME=BONUS_PAGOS_${FARCH}.CAC
ARCHPRMT2=$1
RUTANAME=$DIRENTRADAPOST


if [ "$1" = "" ] ; then
	ARCHPRMT=""
else
	ARCHPRMT1=${1#*BONUS_PAGOS_}
	ARCHPRMT=BONUS_PAGOS_$ARCHPRMT1
fi


# Inicio
demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "*************************************" 
pMessage "Iniciando proceso de Importación              " 
pMessage "Fecha y Hora : $demora               " 
pMessage "*************************************" 

####Proceso####
# File Data: Se buscara el archivo(con su ruta) ya sea ingresado desde el programa o buscarlo en la carpeta de Origen

if [ "$ARCHPRMT" = "" ] ; then
	FILEDATA=`find $RUTANAME/$ARCHNAME`
	CANT_DATA=`cat  $DIRENTRADAPOST/$ARCHNAME | wc -l | sed 's/ //g'`
else
	FILEDATA=`find $ARCHPRMT2`
	CANT_DATA=`cat  $ARCHPRMT2 | wc -l | sed 's/ //g'`
fi

#Capturando nombre de archivo y la fecha de este

if [ "$ARCHPRMT" = "" ] ; then
	ARCHFECHA=${ARCHNAME:12:8}
	ARCHNAMEF=$ARCHNAME
else
	ARCHNAMEF=$ARCHPRMT
	ARCHFECHA=${ARCHPRMT:12:8}
fi

FECHATMP="'"${ARCHFECHA}"'"

dos2unix ${FILEDATA}

TMP=$DIRLOGPOST/TEMPDATA01.tmp
echo "" >> ${FILEDATA}
cat ${FILEDATA} | sed '/^$/d' > $TMP
cat $TMP > ${FILEDATA}
		
rm -f $TMP

if [ "$FILEDATA" = "" ] ; then
   Demora=`date +"%Y-%m-%d %H:%M:%S"`
   pMessage " $demora: Error: No se encontro el archivo de datos..." 
   pMessage "Termino proceso"
   pMessage "************************************" 
   pMessage " FINALIZANDO PROCESO..............." 
   pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso " 
   pMessage "************************************" 
   pMessage "No existe ninguno de estos archivos $ARCHNAME" 
   pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de pagos no se encuentra en la ruta" 
   echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $DIRENTRADAPOST." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo de pagos no se encuentra en la ruta." $IT_MAIL 
   pMessage "Ruta del Archivo log : " $FILELOG
   echo $'\n'
   exit -1
fi

if [ $CANT_DATA = 0 ] ; then
	pMessage "Hora y Fecha: $demora"
	pMessage "Ninguno de estos archivos tiene data $ARCHNAME" 
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de pagos se encuentra vacio." 
	echo "Buen día, los siguientes archivos $ARCHNAME en la carpeta de ORIGEN no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "El Archivo de pagos se encuentra vacio" $IT_MAIL
	pMessage "Se envió correo Fecha y Hora: $demora"
	exit -1
fi

TEMP_FILE=TEMP01_${FECHA}.TMP

ARCHPRMT2=${FILEDATA#*BONUS_PAGOS_}
ARCHPRMT3=BONUS_PAGOS_$ARCHPRMT2

while read FIELD02
do
	echo "${FIELD02}|${ARCHPRMT2:0:8}|${ARCHPRMT3}" >> $DIRLOGPOST/$TEMP_FILE	
done < $FILEDATA

pMessage "Se procede a importar los datos del archivo de entrada a la tabla de pagos"
sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$CONTROL data=$DIRLOGPOST/$TEMP_FILE bad=$BAD log=$CTL_LOG bindsize=200000 readsize=200000 rows=1000 skip=0

rm -f $DIRLOGPOST/$TEMP_FILE

VALIDAT_CTL=`grep 'ORA-' $CTL_LOG | wc -l`
		
if [ $VALIDAT_CTL -ne 0 ] ;
    then
    pMessage "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n'
    pMessage "FECHA $Demora - Verifique el log para mayor detalle $FILELOG"$'\n'
    pMessage `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n' 
	echo "Buen día, ocurrio un error al momento de importar los datos a la tabla de pagos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "Error al importar datos" $IT_MAIL
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
		
if [ "$ARCHPRMT" = "" ] ; then
	ARCHPRMT=""	
else		
	ARCHPRMT=${FILEDATA}	
fi



ARCHNAME=BONUS_PAGOS_${FARCH}.CAC

if [ "$ARCHPRMT" = "" ] ; then
	FINDFILE=`find $DIRENTRADAPOST/$ARCHNAME`
	CANT_DATA=`cat  $DIRENTRADAPOST/$ARCHNAME | wc -l | sed 's/ //g'`
else
	FINDFILE=`find $ARCHPRMT`
	CANT_DATA=`cat  $ARCHPRMT | wc -l | sed 's/ //g'`
fi

#Capturando la fecha
if [ "$ARCHPRMT" = "" ] ; then
	FECHAARCH=$FARCH
else
	ARCHPRMT1=${ARCHPRMT#*BONUS_PAGOS_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi

FECHATMP="'"${FECHAARCH}"'"
#Flujo corroborar archivos

if [ "$FINDFILE" = "" ] ; then
   pMessage " $demora: Error: No se encontro el archivo de datos..." 
   pMessage "Termino proceso"
   pMessage "************************************" 
   pMessage " FINALIZANDO PROCESO..............." 
   pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso " 
   pMessage "************************************" 
   pMessage "No existe ninguno de estos archivos $ARCHNAME" 
   pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de pagos no se encuentra en la ruta" 
   echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $DIRENTRADAPOST." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo de pagos no se encuentra en la ruta." $IT_MAIL 
   pMessage "Ruta del Archivo log : " $FILELOG
   echo $'\n'
   exit -1
fi

if [ $CANT_DATA = 0 ] ; then
	pMessage "Hora y Fecha: $demora"
	pMessage "Ninguno de estos archivos tiene data $ARCHNAME" 
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de pagos se encuentra vacio." 
	echo "Buen día, los siguientes archivos $ARCHNAME en la carpeta de ORIGEN no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "El Archivo de pagos se encuentra vacio" $IT_MAIL
	pMessage "Se envió correo Fecha y Hora: $demora"
	exit -1
fi

pMessage "Se ejecuta el SP pkg_cc_procacumula.admpsi_pago"
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
		
k_coderror number;
k_descerror varchar2(400);
k_numregtot number;
k_numregpro number;
k_numregerr number;
v_fecha date;
		
BEGIN
		
SELECT TO_DATE($FECHATMP,'YYYYMMDD') INTO v_fecha FROM DUAL;		

    begin

	$PCLUB_OW.pkg_cc_procacumula.admpsi_pago(v_fecha,k_coderror,
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
    pMessage "Hora y Fecha: $demora"
    pMessage "Hubo un error durante la ejeción del SP pkg_cc_procacumula.admpsi_pago" 
    pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de IMPORTACION DE PAGOS – Se encontraron errores" 
    echo "Buen día, ocurrio un problema al ejecutar el SP de pkg_cc_procacumula.admpsi_pago." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "IMPORTACION DE PAGOS – Se encontraron errores" $IT_MAIL 		
    pMessage "Se envió correo Fecha y Hora: $demora"    
	exit
fi

pMessage "Ejecución de SP fue satisfactorio"

if [ "$ARCHPRMT" = "" ] ; then
	ARCHPRMT=""
	
else
	ARCHPRMT=${FINDFILE}
	
fi

#---

ARCHNAME=BONUS_PAGOS_${FARCH}.CAC
ARCHERR=BONUS_PAGOS_${FARCH}
ARCHERR2=BONUS_PAGOS_param_${FARCH}
ARCHPRMT=$1


####Proceso####
# Finf file: Variables para corroborar que el archivo existe en la ruta

if [ "$ARCHPRMT" = "" ] ; then
	FINDFILE=`find $DIRENTRADAPOST/$ARCHNAME`
	FINDBKP=`find $DIRBACKUPPOST/$ARCHNAME`
else
	FINDFILE2=`find $ARCHPRMT`
fi

if [ "$ARCHPRMT" = "" ] ; then
	STRINGRUTA=$ARCHNAME
	FECHAARCH=$FARCH
else
	STRINGRUTA=$ARCHPRMT
	ARCHPRMT1=${STRINGRUTA#*BONUS_PAGOS_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi

#Flujo corroborar archivos

if [ "$FINDFILE" = "" ] && [ "$FINDBKP" = "" ] && [ "$FINDFILE2" = "" ] ; then
	pMessage "Hora y Fecha: $demora"
	pMessage "No existe ninguno de estos archivos $ARCHNAME" 
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de pagos no se encuentra en la ruta" 
	echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $DIRENTRADAPOST." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo de pagos no se encuentra en la ruta." $IT_MAIL 
	pMessage "Se envió correo Fecha y Hora: $demora"
	exit
fi

#Verificamos que archivo se encuentra en la carpeta de backup
	
if [ "$ARCHPRMT" != "" ] ; then
		FILEERR=${ARCHERR2}.ERR        
		FILERMV2=$ARCHPRMT              
else
	FILEERR=${ARCHERR}.err
	FILERMV=$DIRBACKUPPOST/$ARCHNAME
	FILERMV2=$DIRENTRADAPOST/$ARCHNAME        
fi




pMessage "Se ejecuta el SP pkg_cc_procacumula.admpss_epago y se exporta los datos obtenidos"
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
  cursorpago ty_cursor; 
  c_cod_cli VARCHAR2(40);
  c_periodo VARCHAR2(6);
  c_diasvenc NUMBER;
  c_cgofijo NUMBER;
  c_mntadic NUMBER;
  c_acgofij NUMBER;
  c_sgacgofij CHAR(1);
  c_ajuadic NUMBER;
  c_sgaajuadi CHAR(1);
  c_mntint NUMBER;
  c_cod_error varchar2(3);
  c_msje_error varchar2(400);
  v_fecha date;
  
  BEGIN
  
  dbms_output.enable(NULL);
  
   SELECT TO_DATE('${FECHAARCH}','YYYYMMDD') INTO v_fecha FROM DUAL;
   
    $PCLUB_OW.pkg_cc_procacumula.admpss_epago(v_fecha,cursorpago);
   
  LOOP
  
  fetch cursorpago into c_cod_cli,c_periodo,c_diasvenc,c_cgofijo,c_mntadic,c_acgofij,c_sgacgofij,c_ajuadic,c_sgaajuadi,c_mntint,c_cod_error,c_msje_error;
  exit when cursorpago%notfound;
  
  DBMS_OUTPUT.put_line(c_cod_cli || '|' || c_periodo || '|' || c_diasvenc || '|' ||c_cgofijo || '|' || c_mntadic || '|' || c_acgofij || '|' || c_sgacgofij || '|' || c_ajuadic || '|' || c_sgaajuadi || '|' || c_mntint || '|' || c_cod_error || '|' || c_msje_error);
  
  END LOOP;
  
  CLOSE cursorpago;
  
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
	pMessage "El proceso no trajo errores en ${DIRFALLOSPOST}/${FILEERR}, asi que no se podra generar en la carpeta Fallos"
	rm ${DIRFALLOSPOST}/${FILEERR}
else
	pMessage "Se ha generado el archivo ${DIRFALLOSPOST}/${FILEERR}"
fi
    
if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
	cat  ${DIRFALLOSPOST}/${FILEERR} >>  $FILELOG
    pMessage "Hora y Fecha: $demora"
    pMessage "Hubo un error durante la ejeción del SP pkg_cc_procacumula.admpsi_epago"  
	echo "Buen día, Hubo un error durante la ejeción del SP pkg_cc_procacumula.admpsi_epago." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "Claro Club - Importacion de Pagos." $IT_MAIL 
	
	exit
fi

pMessage "Ejecución de SP admpss_epago fue satisfactorio"


	   
pMessage "Se finalizó el proceso de Ejecución de EPAGO"



pMessage "Se finalizó el proceso de Ejecución de PAGO"


				
pMessage "Fin de todo el Proceso de Migracion de Pagos"

exit
