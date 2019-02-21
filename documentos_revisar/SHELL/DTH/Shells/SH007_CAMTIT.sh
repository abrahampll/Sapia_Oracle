#! /bin/ksh
#*************************************************************
#* DESCRIPCION           : CAMBIO TITULARIDAD - Claro Club DTH  *     
#* EJECUCION             : Control-D        					*                    
#* AUTOR                 : E77113 Susana Ramos		                    *             
#* FECHA                 : 13/09/2012  VERSION : v1.0           *
#* FECHA MOD .           :                                      *
#*************************************************************
#Iniciación de Variables
# Inicializacion de Variables
. /home/usrclaroclub/CLAROCLUB/Interno/DTH/Bin/.varset
. /home/usrclaroclub/CLAROCLUB/Interno/DTH/Bin/.passet
. /home/usrclaroclub/CLAROCLUB/Interno/DTH/Bin/.mailset
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

CONTROL=$DIRCONTROLDTH/importaCamTitDTH.ctl
BAD=$DIRFALLOSDTH/importaCAMTIT_BAD_$FECHA.bad
FILELOG=$DIRLOGDTH/SH007_CAMTIT_$FECHA.log
CTL_LOG=$DIRLOGDTH/CTL007_LOG_$FECHA.log
ARCHNAME=CAMTIT_DTH_${FARCH}.CCL
ARCHPRMT2=$1
RUTANAME=$DIR_ENT_CAMBTITU

if [ "$1" = "" ] ; then
	ARCHPRMT=""
else
	ARCHPRMT1=${1#*CAMTIT_DTH_}
	ARCHPRMT=CAMTIT_DTH_$ARCHPRMT1
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
   pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Cambio de Titularidad DTH no se encuentra en la ruta" 
   echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo de Cambio de Titularidad DTH no se encuentra en la ruta." $IT_MAIL 
   pMessage "Ruta del Archivo log : " $FILELOG
   echo $'\n'
   exit -1
fi

if [ $CANT_DATA = 0 ] ; then
	pMessage "Hora y Fecha: $demora"
	pMessage "Ninguno de estos archivos tiene data $ARCHNAME" 
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Cambio de Titularidad DTH se encuentra vacio." 
	echo "Buen día, los siguientes archivos $ARCHNAME en la carpeta de ORIGEN no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "El Archivo de Cambio de Titularidad DTH se encuentra vacio" $IT_MAIL
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

TMP=$DIRLOGDTH/TEMPDATA01.tmp
echo "" >> ${FILEDATA}
cat ${FILEDATA} | sed '/^$/d' > $TMP
cat $TMP > ${FILEDATA}

rm -f $TMP


TEMP_FILE=TEMP07_${FECHA}.TMP

ARCHPRMT2=${FILEDATA#*CAMTIT_DTH_}
ARCHPRMT3=CAMTIT_DTH_$ARCHPRMT2

while read FIELD02
do
	echo "${FIELD02}|${ARCHPRMT3}|${ARCHPRMT2:0:8}" >> $DIRLOGDTH/$TEMP_FILE
done < $FILEDATA

pMessage "Se procede a importar los datos del archivo de entrada a la tabla de Cambio de Titularidad DTH"
sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$CONTROL data=$DIRLOGDTH/$TEMP_FILE bad=$BAD log=$CTL_LOG bindsize=200000 readsize=200000 rows=1000 skip=0

rm -f $DIRLOGDTH/$TEMP_FILE

VALIDAT_CTL=`grep 'ORA-' $CTL_LOG | wc -l`

if [ $VALIDAT_CTL -ne 0 ] ;
    then
    pMessage "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n'
    pMessage "FECHA $Demora - Verifique el log para mayor detalle $FILELOG"$'\n'
    pMessage `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n' 
	#echo "Buen día, ocurrio un error al momento de importar los datos a la tabla de Cambio de Titularidad DTH. Archivo BAD: $BAD" $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "DTH: Error BSCS." $IT_MAIL
    BAD_ZIP=importaCAMTIT_BAD_$FECHA.zip
	BAD_NOM=importaCAMTIT_BAD_$FECHA.bad
	cd $DIRFALLOSDTH
	zip $BAD_ZIP $BAD_NOM
	(echo "Buen día, ocurrio un error al momento de importar los datos a la tabla de Cambio de Titularidad. Se adjunta el archivo BAD." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n' ; uuencode $BAD_ZIP $BAD_ZIP) | mail -s "DTH-POSTPAGO: Error DATA BSCS." $IT_MAIL
    rm -f $BAD_ZIP
	cd $DIR_DTH_SHELL	
	#pMessage "Termino proceso"
    pMessage "************************************" 
    #pMessage " FINALIZANDO PROCESO..............." 
    #pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso " 
    pMessage "************************************" 
    pMessage "Ruta del Archivo log : " $CTL_LOG
    echo $'\n'
	#exit -1
fi

pMessage "El proceso de importacion culmino satisfactoriamente"

#rm -f $CTL_LOG 


cp $FILEDATA $DIR_PROC_CAMBTITU


#Capturando la fecha
if [ "$ARCHPRMT" = "" ] ; then
	FECHAARCH=$FARCH
else
	ARCHPRMT1=${ARCHPRMT#*CAMTIT_DTH_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi

FECHATMP="'"${FECHAARCH}"'"



pMessage "Se procede a ejecutar el SP PKG_CC_PTOSFIJA.ADMPSI_CAMBIOTITULAR_DTH"
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
		
k_coderror  number;
k_descerror varchar2(400);
k_numregtot number;
k_numregpro number;
k_numregerr number;
v_fecha 	date;	
		
BEGIN
		
  SELECT TO_DATE($FECHATMP,'YYYYMMDD') INTO v_fecha FROM DUAL;

  $PCLUB_OW.PKG_CC_PTOSFIJA.ADMPSI_CAMBIOTITULAR_DTH('USRCTITDTH', v_fecha,k_numregtot,k_numregpro,k_numregerr,k_coderror,k_descerror);

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
    pMessage "Hubo un error durante la ejeción del SP PKG_CC_PTOSFIJA.ADMPSI_CAMBIOTITULAR_DTH" 
    pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de Cambio de Titularidad DTH – Se encontraron errores" 
    echo "Buen día, ocurrio un problema al ejecutar el SP de PKG_CC_PTOSFIJA.ADMPSI_CAMBIOTITULAR_DTH." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "DTH : CAMBIO DE TITULARIDAD DTH." $IT_MAIL 		
    pMessage "Se envió correo Fecha y Hora: $demora"    
	exit
fi

pMessage "Ejecución de SP fue satisfactorio"

if [ "$ARCHPRMT" = "" ] ; then
	ARCHPRMT=""
else
	ARCHPRMT=${FINDFILE}
fi

ARCHNAME=CAMTIT_DTH_${FARCH}.CCL
ARCHERR=CAMTIT_DTH_${FARCH}
ARCHERR2=CAMTIT_DTH_param_${FARCH}
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
	ARCHPRMT1=${STRINGRUTA#*CAMTIT_DTH_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi

#Flujo corroborar archivos

if [ "$FINDFILE" = "" ] && [ "$FINDBKP" = "" ] && [ "$FINDFILE2" = "" ] ; then
	pMessage "Hora y Fecha: $demora"
	pMessage "No existe ninguno de estos archivos $ARCHNAME" 
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Cambio de Titularidad DTH no se encuentra en la ruta" 
	echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo de Cambio de Titularidad DTH no se encuentra en la ruta." $IT_MAIL 
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

pMessage "Se ejecuta el SP PKG_CC_PTOSFIJA.ADMPSI_ECAMBIOTITULAR_DTH y se exporta los datos obtenidos"
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
  cursorfiledth ty_cursor;
  TYPE REG IS RECORD
  (
    COD_CLI_PROD VARCHAR2(40),
    NUM_DOC      VARCHAR2(20),
    NOM_ARCH     VARCHAR2(150),
    FEC_OPER     DATE,
    MSJE_ERROR   VARCHAR2(400));
    LINEA REG;
    v_fecha date;	
  
  BEGIN
  
  dbms_output.enable(NULL);
   SELECT TO_DATE($FECHATMP,'YYYYMMDD') INTO v_fecha FROM DUAL;
   $PCLUB_OW.PKG_CC_PTOSFIJA.ADMPSI_ECAMBIOTITULAR_DTH(v_fecha,cursorfiledth);
  LOOP
  
  fetch cursorfiledth into LINEA;
  exit when cursorfiledth%notfound;
  
  DBMS_OUTPUT.put_line(LINEA.COD_CLI_PROD || '|'|| LINEA.NUM_DOC || '|' || LINEA.MSJE_ERROR);
  
  END LOOP;
  
  CLOSE cursorfiledth;
  
  EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
  END;
/	
EXIT
EOP

CANT_DATA=`cat ${DIR_ERR_CAMBTITU}/${FILEERR} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP=`grep 'ORA-' ${DIR_ERR_CAMBTITU}/${FILEERR} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B=`grep 'SP2-' ${DIR_ERR_CAMBTITU}/${FILEERR} | wc -l | sed 's/ //g'`
    
if [ $CANT_DATA = 0 ] ; then
	pMessage "El proceso no trajo errores en ${DIR_ERR_CAMBTITU}/${FILEERR}, asi que no se podra generar en la carpeta Fallos"
	#rm  -f ${DIR_ERR_CAMBTITU}/${FILEERR}
else
	pMessage "Se ha generado el archivo ${DIR_ERR_CAMBTITU}/${FILEERR}"
fi
    
if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
	cat  ${DIR_ERR_CAMBTITU}/${FILEERR} >>  $FILELOG
    pMessage "Hora y Fecha: $demora"
    pMessage "Hubo un error durante la ejeción del SP PKG_CC_PTOSFIJA.ADMPSI_ECAMBIOTITULAR_DTH"  
	echo "Buen día, Hubo un error durante la ejeción del SP PKG_CC_PTOSFIJA.ADMPSI_ECAMBIOTITULAR_DTH." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "DTH-POSTPAGO : Cambio de Titularidad." $IT_MAIL 
	exit
else
	if [ $CANT_DATA != 0 ] ; then
		pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de Errores en el registro de clientes" 
		FILEERR_ZIP=CAMTIT_DTH_$FARCH.zip
		cd $DIR_ERR_CAMBTITU
		zip $FILEERR_ZIP $FILEERR
		(echo "Buen día, se encontraron $CANT_DATA errores. Revisar la ruta ${DIR_ERR_CAMBTITU}/${FILEERR}." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  ; uuencode $FILEERR_ZIP $FILEERR_ZIP) | mail -s "DTH-POSTPAGO : Cambio Titular - Errores en el registro de clientes." $IT_MAIL
		rm -f $FILEERR_ZIP		
		exit
	fi
fi

pMessage "Ejecución de SP ADMPSI_ECAMBIOTITULAR_DTH fue satisfactorio"
pMessage "Se finalizó el proceso de Ejecución de ECAMBIOTITULAR_DTH"
pMessage "Se finalizó el proceso de Ejecución de CAMBIOTITULAR_DTH"
pMessage "Fin de todo el Proceso de Migracion de Cambio de Titularidad DTH"

exit