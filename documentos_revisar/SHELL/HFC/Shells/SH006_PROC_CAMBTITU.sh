#! /bin/ksh
#*************************************************************
#* DESCRIPCION           : CAMBIO TITULARIDAD - Claro Club HFC  *
#* EJECUCION             :                                      *
#* AUTOR                 : E77210: JCGutierrezT                 *
#* FECHA                 : 15/06/2012   VERSION : v1.0          *
#* FECHA MOD .           :                                      *
#*************************************************************

#Iniciación de Variables
# Inicializacion de Variables
. /home/usrclaroclub/CLAROCLUB/Interno/HFC/Bin/.varset
. /home/usrclaroclub/CLAROCLUB/Interno/HFC/Bin/.passet
. /home/usrclaroclub/CLAROCLUB/Interno/HFC/Bin/.mailset
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
CONTROL=$DIRCONTROLHFC/importaCamTituHFC.ctl
BAD=$DIRFALLOSHFC/importaCamTitu_BAD_$FECHA.bad
FILELOG=$DIRLOGHFC/SH006_CAMBTITU_$FECHA.log
CTL_LOG=$DIRLOGHFC/CTL006_LOG_$FECHA.log
ARCHNAME=CAMBIO_TITU_${FARCH}.CAC
ARCHPRMT2=$1
RUTANAME=$DIR_ENT_CAMBTITU


if [ "$1" = "" ] ; then
	ARCHPRMT=""
else
	ARCHPRMT1=${1#*CAMBIO_TITU_}
	ARCHPRMT=CAMBIO_TITU_$ARCHPRMT1
fi


# Inicio
demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "*************************************" 
pMessage "Iniciando proceso de Importación     " 
pMessage "Fecha y Hora : $demora               " 
pMessage "*************************************" 

####Proceso####


# File Data: Se buscara el archivo(con su ruta) ya sea ingresado desde el programa o buscarlo en la carpeta de Origen

if [ "$ARCHPRMT" = "" ] ; then
	FILEDATA=`find $RUTANAME/$ARCHNAME`
	CANT_DATA=`cat $RUTANAME/$ARCHNAME | wc -l | sed 's/ //g'`
else
	FILEDATA=`find $ARCHPRMT2`
	CANT_DATA=`cat $ARCHPRMT2 | wc -l | sed 's/ //g'`
fi

if [ "$FILEDATA" = "" ] ; then
   Demora=`date +"%Y-%m-%d %H:%M:%S"`
   pMessage " $demora: Error: No se encontro el archivo de datos..." 
   pMessage "Termino proceso"
   pMessage "************************************" 
   pMessage " FINALIZANDO PROCESO..............." 
   pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso " 
   pMessage "************************************" 
   pMessage "No existe ninguno de estos archivos $ARCHNAME" 
   pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Cambio de Titularidad no se encuentra en la ruta" 
   echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo de Cambio de Titularidad no se encuentra en la ruta." $IT_MAIL 
   pMessage "Ruta del Archivo log : " $FILELOG
   echo $'\n'
   exit -1
fi

if [ $CANT_DATA = 0 ] ; then
	pMessage "Hora y Fecha: $demora"
	pMessage "Ninguno de estos archivos tiene data $ARCHNAME" 
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Cambio de Titularidad se encuentra vacio." 
	echo "Buen día, los siguientes archivos $ARCHNAME en la carpeta de ORIGEN no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "El Archivo de Cambio de Titularidad se encuentra vacio" $IT_MAIL
	pMessage "Se envió correo Fecha y Hora: $demora"
	exit -1
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

TMP=$DIRLOGHFC/TEMPDATA01.tmp
echo "" >> ${FILEDATA}
cat ${FILEDATA} | sed '/^$/d' > $TMP
cat $TMP > ${FILEDATA}
		
rm -f $TMP


TEMP_FILE=TEMP06_${FECHA}.TMP

ARCHPRMT2=${FILEDATA#*CAMBIO_TITU_}
ARCHPRMT3=CAMBIO_TITU_$ARCHPRMT2

while read FIELD02
do
	echo "${FIELD02}|${ARCHPRMT2:0:8}|${ARCHPRMT3}" >> $DIRLOGHFC/$TEMP_FILE	
done < $FILEDATA

pMessage "Se procede a importar los datos del archivo de entrada a la tabla de Cambio de Titularidad"
sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$CONTROL data=$DIRLOGHFC/$TEMP_FILE bad=$BAD log=$CTL_LOG bindsize=200000 readsize=200000 rows=1000 skip=0

rm -f $DIRLOGHFC/$TEMP_FILE

VALIDAT_CTL=`grep 'ORA-' $CTL_LOG | wc -l`
		
if [ $VALIDAT_CTL -ne 0 ] ;
    then
    pMessage "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n'
    pMessage "FECHA $Demora - Verifique el log para mayor detalle $FILELOG"$'\n'
    pMessage `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n' 
	echo "Buen día, ocurrio un error al momento de importar los datos a la tabla de Cambio de Titularidad." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "HFC: Cambio de titularidad." $IT_MAIL
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
	

cp $FILEDATA $DIR_PROC_CAMBTITU
		

#Capturando la fecha
if [ "$ARCHPRMT" = "" ] ; then
	FECHAARCH=$FARCH
else
	ARCHPRMT1=${ARCHPRMT#*CAMBIO_TITU_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi

FECHATMP="'"${FECHAARCH}"'"



pMessage "Se ejecuta el SP PKG_CC_PTOSFIJA.ADMPSI_CAMBIOTITULAR_HFC"
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
k_usuario varchar2(40);
v_fecha date;
		
BEGIN
		
SELECT TO_DATE($FECHATMP,'YYYYMMDD') INTO v_fecha FROM DUAL;		

$PCLUB_OW.PKG_CC_PTOSFIJA.ADMPSI_CAMBIOTITULAR_HFC(v_fecha,k_numregtot,k_numregerr,k_numregpro,k_coderror,k_descerror);

		
dbms_output.put_line('Codigo de error: ' || k_coderror || '|Mensaje de error: ' || k_descerror || '|Nº total de registros: ' || k_numregtot || '|Nº de registros procesados: ' || k_numregpro || '|Nº de registros con errores: ' || k_numregerr);
IF k_coderror<>0 THEN
		dbms_output.put_line('SP2-');
END IF;		
END;
	
/
exit
EOP

VALIDA_EJEC_SP=`grep 'ORA-' ${FILELOG} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B=`grep 'SP2-' ${FILELOG} | wc -l | sed 's/ //g'`

if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
    pMessage "Hora y Fecha: $demora"
    pMessage "Hubo un error durante la ejeción del SP PKG_CC_PTOSFIJA.ADMPSI_CAMBIOTITULAR_HFC" 
    pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de Cambio Titular – Se encontraron errores" 
    echo "Buen día, ocurrio un problema al ejecutar el SP de PKG_CC_PTOSFIJA.ADMPSI_CAMBIOTITULAR_HFC." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "HCF : CAMBIO TITULARIDAD." $IT_MAIL 		
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

ARCHNAME=CAMBIO_TITU_${FARCH}.CAC
ARCHERR=CAMBIO_TITU_${FARCH}
ARCHERR2=CAMBIO_TITU_param_${FARCH}
ARCHPRMT=$1


####Proceso####
# Finf file: Variables para corroborar que el archivo existe en la ruta

if [ "$ARCHPRMT" = "" ] ; then
	FINDFILE=`find $RUTANAME/$ARCHNAME`
	FINDBKP=`find $DIR_PROC_CAMBTITU/$ARCHNAME`
else
	FINDFILE2=`find $ARCHPRMT`
fi

if [ "$ARCHPRMT" = "" ] ; then
	STRINGRUTA=$ARCHNAME
	FECHAARCH=$FARCH
else
	STRINGRUTA=$ARCHPRMT
	ARCHPRMT1=${STRINGRUTA#*CAMBIO_TITU_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi

#Flujo corroborar archivos

if [ "$FINDFILE" = "" ] && [ "$FINDBKP" = "" ] && [ "$FINDFILE2" = "" ] ; then
	pMessage "Hora y Fecha: $demora"
	pMessage "No existe ninguno de estos archivos $ARCHNAME" 
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Cambio de Titularidad no se encuentra en la ruta" 
	echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo de Cambio de Titularidad no se encuentra en la ruta." $IT_MAIL 
	pMessage "Se envió correo Fecha y Hora: $demora"
	exit
fi

#borramos el archivo de la carpeta de documentos
if [ "$FINDBKP" != "" ] ; then
	rm -f $FILEDATA	 
	pMessage "El archivo de entrada fue copiado en $FINDBKP"	
fi

#Verificamos que archivo se encuentra en la carpeta de backup	
if [ "$ARCHPRMT" != "" ] ; then
	FILEERR=${ARCHERR2}.ERR         
else
	FILEERR=${ARCHERR}.ERR   
fi


rm -f ${DIR_ERR_CAMBTITU}/${FILEERR}

pMessage "Se ejecuta el SP PKG_CC_PTOSFIJA.ADMPSI_ECAMBIOTITULAR_HFC y se exporta los datos obtenidos"
sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> ${DIR_ERR_CAMBTITU}/${FILEERR}
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
  
  TYPE REG IS RECORD
( FILA  NUMBER,
 COD_CLI_PROD  VARCHAR2(40),
  ESTADO        VARCHAR2(6),
  TIP_DOC       VARCHAR2(40),
  NUM_DOC       VARCHAR2(40),
  NOM_CLI       VARCHAR2(150),
  APE_CLI       VARCHAR2(150),
  SEX           VARCHAR2(10),
  EST_CIV       VARCHAR2(10),
  EMAIL         VARCHAR2(150),
  PROV          VARCHAR2(50),
  DEPT          VARCHAR2(50),
  DIST          VARCHAR2(50),
  CIC_FAC       VARCHAR2(10),
  FEC_PRO       DATE,
  NRO_OPERACION   NUMBER,
  CODERROR NUMBER,
  DESERROR VARCHAR2(200));
  
  LINEA REG;
  v_fecha date;
  
  BEGIN
  
  dbms_output.enable(NULL);
  
   SELECT TO_DATE($FECHATMP,'YYYYMMDD') INTO v_fecha FROM DUAL;
   
    $PCLUB_OW.PKG_CC_PTOSFIJA.ADMPSI_ECAMBIOTITULAR_HFC(v_fecha,cursorpago);
   
  LOOP
  
  fetch cursorpago into LINEA;
  exit when cursorpago%notfound;
  
  DBMS_OUTPUT.put_line(LINEA.COD_CLI_PROD || '|' || LINEA.ESTADO || '|' || LINEA.TIP_DOC || '|'  || LINEA.NUM_DOC || '|' || LINEA.NRO_OPERACION || '|' || LINEA.DESERROR);
  
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
	
CANT_DATA=`cat ${DIR_ERR_CAMBTITU}/${FILEERR} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP=`grep 'ORA-' ${DIR_ERR_CAMBTITU}/${FILEERR} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B=`grep 'SP2-' ${DIR_ERR_CAMBTITU}/${FILEERR} | wc -l | sed 's/ //g'`
    
if [ $CANT_DATA = 0 ] ; then
	pMessage "El proceso no trajo errores en ${DIR_ERR_CAMBTITU}/${FILEERR}, asi que no se podra generar en la carpeta Fallos"
	#rm -f ${DIR_ERR_CAMBTITU}/${FILEERR}
else
	pMessage "Se ha generado el archivo ${DIR_ERR_CAMBTITU}/${FILEERR}"
fi
    
if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
	cat  ${DIR_ERR_CAMBTITU}/${FILEERR} >>  $FILELOG
    pMessage "Hora y Fecha: $demora"
    pMessage "Hubo un error durante la ejeción del SP PKG_CC_PTOSFIJA.ADMPSI_ECAMBIOTITULAR_HFC"  
	echo "Buen día, Hubo un error durante la ejeción del SP PKG_CC_PTOSFIJA.ADMPSI_ECAMBIOTITULAR_HFC." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "HFC : Cambio Titular ." $IT_MAIL 
	exit
else
	if [ $CANT_DATA != 0 ] ; then
		pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de Errores en el registro de clientes" 
		echo "Buen día, se encontraron $CANT_DATA errores. Revisar la ruta ${DIR_ERR_CAMBTITU}/${FILEERR} ." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "HFC : Cambio Titular - Errores en el registro de clientes." $IT_MAIL 	
		exit
	fi	
fi

pMessage "Ejecución de SP ADMPSI_ECAMBIOTITULAR_HFC fue satisfactorio"

pMessage "Se finalizó el proceso de Ejecución de CAMBTITU"

pMessage "Se finalizó el proceso de Ejecución de CAMBTITU"

pMessage "Fin de todo el Proceso de Migracion de CAMBTITU"

exit
