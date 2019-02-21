#! /bin/ksh
#*************************************************************
#* DESCRIPCION           : Importacion de Pagos - Claro Club DTH                                   *
#* EJECUCION             :                                                         *
#* AUTOR                 :                                    *
#* FECHA                 : 15/05/2012   VERSION : v1.0                        *
#* FECHA MOD .           :                         *
#*************************************************************

#Iniciaci�n de Variables
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
CONTROL=$DIRCONTROLDTH/importaPPagoDTH.ctl
BAD=$DIRFALLOSDTH/importaPago_BAD_$FECHA.bad
FILELOG=$DIRLOGDTH/SH002_PROC_PAGOS_$FECHA.log
CTL_LOG=$DIRLOGDTH/CTL002_LOG_$FECHA.log

ARCHPRMT2=$1
RUTANAME=$DIR_ENT_PAGOS


if [ "$APLIC_OAC" = "0" ] ; then
	ARCHNAME=PAGOS_DTH_${FARCH}.CCL
else
	ARCHNAME=PAGOS_DTH_${FARCH}.OAC
fi


if [ "$1" = "" ] ; then
	ARCHPRMT=""
else
	ARCHPRMT1=${1#*PAGOS_DTH_}
	ARCHPRMT=PAGOS_DTH_$ARCHPRMT1
fi


# Inicio
demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "*************************************" 
pMessage "Iniciando proceso de Importaci�n              " 
pMessage "Fecha y Hora : $demora               " 
pMessage "*************************************" 

####Proceso####


# File Data: Se buscara el archivo(con su ruta) ya sea ingresado desde el programa o buscarlo en la carpeta de Origen

if [ "$ARCHPRMT" = "" ] ; then
	FILEDATA=`find $RUTANAME/$ARCHNAME`
	CANT_DATA=`cat  $RUTANAME/$ARCHNAME | wc -l | sed 's/ //g'`
else
	FILEDATA=`find $RUTANAME/$ARCHPRMT2`
	CANT_DATA=`cat  $RUTANAME/$ARCHPRMT2 | wc -l | sed 's/ //g'`
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
   pMessage "A continuaci�n se enviar� un correo a $IT_MAIL con el asunto de El Archivo de pagos no se encuentra en la ruta" 
   echo "Buen d�a, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "DTH-POSTPAGO: El Archivo de pagos no se encuentra en la ruta." $IT_MAIL 
   pMessage "Ruta del Archivo log : " $FILELOG
   echo $'\n'
   exit -1
fi

if [ $CANT_DATA = 0 ] ; then
	pMessage "Hora y Fecha: $demora"
	pMessage "Ninguno de estos archivos tiene data $ARCHNAME" 
	pMessage "A continuaci�n se enviar� un correo a $IT_MAIL con el asunto de El Archivo de pagos se encuentra vacio." 
	echo "Buen d�a, los siguientes archivos $ARCHNAME en la carpeta de ORIGEN no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "DTH-POSTPAGO: El Archivo de pagos se encuentra vacio" $IT_MAIL
	pMessage "Se envi� correo Fecha y Hora: $demora"
	exit -1
fi

pMessage "Se convierte el archivo de entrada al formato UNIX"
dos2unix ${FILEDATA}

TMP=$DIRLOGDTH/TEMPDATA02.tmp
echo "" >> ${FILEDATA}
cat ${FILEDATA} | sed '/^$/d' > $TMP
cat $TMP > ${FILEDATA}
		
rm -f $TMP

TEMP_FILE=TEMP02_${FECHA}.TMP

ARCHPRMT2=${FILEDATA#*PAGOS_DTH_}
ARCHPRMT3=PAGOS_DTH_$ARCHPRMT2

while read FIELD02
do
	echo "${FIELD02}|${ARCHPRMT2:0:8}|${ARCHPRMT3}" >> $DIRLOGDTH/$TEMP_FILE	
done < $FILEDATA

pMessage "Se procede a importar los datos del archivo de entrada a la tabla de pagos"
sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$CONTROL data=$DIRLOGDTH/$TEMP_FILE bad=$BAD log=$CTL_LOG bindsize=200000 readsize=200000 rows=1000 skip=0

rm -f $DIRLOGDTH/$TEMP_FILE

VALIDAT_CTL=`grep 'ORA-' $CTL_LOG | wc -l`
		
if [ $VALIDAT_CTL -ne 0 ] ;
    then
    pMessage "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n'
    pMessage "FECHA $Demora - Verifique el log para mayor detalle $FILELOG"$'\n'
    pMessage `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n' 
	#echo "Buen d�a, ocurrio un error al momento de importar los datos a la tabla de pagos.Archivo BAD: $BAD" $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "DTH-POSTPAGO: Error BSCS." $IT_MAIL
    BAD_ZIP=importaPago_BAD_$FECHA.zip
	BAD_NOM=importaPago_BAD_$FECHA.bad
	cd $DIRFALLOSDTH
	zip $BAD_ZIP $BAD_NOM
	(echo "Buen d�a, ocurrio un error al momento de importar los datos a la tabla de pagos. Se adjunta el archivo BAD." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n' ; uuencode $BAD_ZIP $BAD_ZIP) | mail -s "DTH-POSTPAGO: Error DATA BSCS." $IT_MAIL
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

#rm -f $CTL_LOG 

pMessage "El proceso de importacion culmino satisfactoriamente"
	
cp $FILEDATA $DIR_PROC_PAGOS

#Capturando la fecha
if [ "$ARCHPRMT" = "" ] ; then
	FECHAARCH=$FARCH
else
	ARCHPRMT1=${ARCHPRMT#*PAGOS_DTH_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi

FECHATMP="'"${FECHAARCH}"'"
#Flujo corroborar archivos

pMessage "Se ejecuta el SP PKG_CC_PTOSFIJA.ADMPSI_FACTURADTH"
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

    begin

	$PCLUB_OW.PKG_CC_PTOSFIJA.ADMPSI_FACTURADTH(v_fecha,'USRFACDTH',k_coderror,
						k_descerror,
						k_numregtot,
						k_numregpro,
						k_numregerr);
	end;
		
	dbms_output.put_line('Codigo de error: ' || k_coderror || '|Mensaje de error: ' || k_descerror || '|N� total de registros: ' || k_numregtot || '|N� de registros procesados: ' || k_numregpro || '|N� de registros con errores: ' || k_numregerr);
	
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
    pMessage "Hubo un error durante la ejeci�n del SP PKG_CC_PTOSFIJA.ADMPSI_FACTURADTH" 
    pMessage "A continuaci�n se enviar� un correo a $IT_MAIL con el asunto de IMPORTACION DE PAGOS � Se encontraron errores" 
    echo "Buen d�a, ocurrio un problema al ejecutar el SP de PKG_CC_PTOSFIJA.ADMPSI_FACTURADTH." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "DTH-POSTPAGO: IMPORTACION DE PAGOS " $IT_MAIL 		
    pMessage "Se envi� correo Fecha y Hora: $demora"    
	exit
fi

pMessage "Ejecuci�n de SP fue satisfactorio"


ARCHERR=PAGOS_DTH_${FARCH}
ARCHERR2=PAGOS_DTH_param_${FARCH}


####Proceso####
# Finf file: Variables para corroborar que el archivo existe en la ruta

if [ "$ARCHPRMT" = "" ] ; then
	FINDFILE=`find $RUTANAME/$ARCHNAME`
	FINDBKP=`find $DIR_PROC_PAGOS/$ARCHNAME`
	STRINGRUTA=$ARCHNAME
	FECHAARCH=$FARCH
else
	FINDFILE2=`find $RUTANAME/$ARCHPRMT`
	STRINGRUTA=$ARCHPRMT
	ARCHPRMT1=${STRINGRUTA#*PAGOS_DTH_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi



#Flujo corroborar archivos

if [ "$FINDFILE" = "" ] && [ "$FINDBKP" = "" ] && [ "$FINDFILE2" = "" ] ; then
	pMessage "Hora y Fecha: $demora"
	pMessage "No existe ninguno de estos archivos $ARCHNAME" 
	pMessage "A continuaci�n se enviar� un correo a $IT_MAIL con el asunto de El Archivo de pagos no se encuentra en la ruta" 
	echo "Buen d�a, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "DTH-POSTPAGO: El Archivo de pagos no se encuentra en la ruta." $IT_MAIL 
	pMessage "Se envi� correo Fecha y Hora: $demora"
	exit
fi

#borramos el archivo de la carpeta de documentos
if [ "$FINDBKP" != "" ] ; then
	rm -f $FILEDATA	 
	pMessage "El archivo de entrada fue copiado en $FINDBKP"	
fi


if [ "$ARCHPRMT" != "" ] ; then
	FILEERR=${ARCHERR2}.ERR         
else
	FILEERR=${ARCHERR}.ERR      
fi

#eliminar errores de ejecuciones anteriores en el mismo dia
rm -f ${DIR_ERR_PAGOS}/${FILEERR}

pMessage "Se ejecuta el SP PKG_CC_PTOSFIJA.ADMPSI_EFACTURADTH y se exporta los datos obtenidos"
sqlplus -S $USER_BD/$CLAVE_BD@$SID_BD <<EOP >> ${DIR_ERR_PAGOS}/${FILEERR}
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
  c_diasvenc NUMBER;
  c_cgofijo NUMBER;
  c_cod_error varchar2(3);
  c_msje_error varchar2(400);
  v_fecha date;
  
  BEGIN
  
  dbms_output.enable(NULL);
  
   SELECT TO_DATE('${FECHAARCH}','YYYYMMDD') INTO v_fecha FROM DUAL;
   
    $PCLUB_OW.PKG_CC_PTOSFIJA.ADMPSI_EFACTURADTH(v_fecha,cursorpago);
   
  LOOP
  fetch cursorpago into c_cod_cli,c_diasvenc,c_cgofijo,c_msje_error;
  exit when cursorpago%notfound;
  
  DBMS_OUTPUT.put_line(c_cod_cli || '|' || c_diasvenc || '|'  || c_cgofijo || '|' || c_msje_error);
  
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
	
CANT_DATA=`cat ${DIR_ERR_PAGOS}/${FILEERR} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP=`grep 'ORA-' ${DIR_ERR_PAGOS}/${FILEERR} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B=`grep 'SP2-' ${DIR_ERR_PAGOS}/${FILEERR} | wc -l | sed 's/ //g'`
    
if [ $CANT_DATA = 0 ] ; then
	pMessage "El proceso no trajo errores en ${DIR_ERR_PAGOS}/${FILEERR}, asi que no se podra generar en la carpeta Fallos"
	#rm ${DIR_ERR_PAGOS}/${FILEERR}
else
	pMessage "Se ha generado el archivo ${DIR_ERR_PAGOS}/${FILEERR}"
fi
    
if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
	cat  ${DIR_ERR_PAGOS}/${FILEERR} >>  $FILELOG
    pMessage "Hora y Fecha: $demora"
    pMessage "Hubo un error durante la ejeci�n del SP PKG_CC_PTOSFIJA.ADMPSI_EFACTURADTH"  
	echo "Buen d�a, Hubo un error durante la ejeci�n del SP PKG_CC_PTOSFIJA.ADMPSI_FACTURADTH." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "DTH-POSTPAGO: Importacion de Pagos." $IT_MAIL 
	exit
else
	if [ $CANT_DATA != 0 ] ; then
		pMessage "A continuaci�n se enviar� un correo a $IT_MAIL con el asunto de Errores en el proceso de facturacion" 
		FILEERR_ZIP=PAGOS_DTH_$FARCH.zip
		cd $DIR_ERR_PAGOS
		zip $FILEERR_ZIP $FILEERR
		(echo "Buen d�a, se encontraron $CANT_DATA errores. Revisar la ruta ${DIR_ERR_PAGOS}/${FILEERR}." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  ; uuencode $FILEERR_ZIP $FILEERR_ZIP) | mail -s "DTH-POSTPAGO : Facturacion - Errores en el proceso de facturacion." $IT_MAIL
		rm -f $FILEERR_ZIP
		exit
	fi	
fi

pMessage "Ejecuci�n de SP admpss_epago fue satisfactorio"
   
pMessage "Se finaliz� el proceso de Ejecuci�n de ADMPSI_EFACTURADTH"

pMessage "Se finaliz� el proceso de Ejecuci�n de ADMPSI_FACTURADTH"
				
pMessage "Fin de todo el Proceso de Migracion de Pagos"

exit