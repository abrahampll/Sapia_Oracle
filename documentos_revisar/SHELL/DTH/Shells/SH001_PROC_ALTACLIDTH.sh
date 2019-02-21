#! /bin/ksh
#*************************************************************
#* DESCRIPCION           : Importacion de Alta de clientes - DTH*
#* EJECUCION             :                                      *
#* AUTOR                 : JCGT                                 *
#* FECHA                 : 13-08-2012   VERSION : v1.0          *
#* FECHA MOD .           :                         				*
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
CONTROL=$DIRCONTROLDTH/importaAltacliDTH.ctl
BAD=$DIRFALLOSDTH/importaAltacliDTH_BAD_$FECHA.bad
FILELOG=$DIRLOGDTH/SH001_PROC_ALTACLIDTH_$FECHA.log
CTL_LOG=$DIRLOGDTH/CTL001_LOG_$FECHA.log

ARCHPRMT2=$1
RUTANAME=$DIR_ENT_ALTA
ARCHSHELL=SH001_PROC_ALTACLIDTH.sh

if [ "$1" = "" ] ; then
	ARCHPRMT=""
    ARCHNAME=ALTA_DTH_${FARCH}.CCL
else
    ARCHNAME=$1
	ARCHPRMT1=${1#*ALTA_DTH_}
	ARCHPRMT=ALTA_DTH_$ARCHPRMT1
fi

# Inicio
demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "*************************************" 
pMessage "Iniciando proceso              " 
pMessage "Fecha y Hora : $demora               " 
pMessage "*************************************" 
pMessage $'\n'"Iniciando proceso ....$demora"$'\n'
pMessage "procesando..."
####Proceso####
# File Data: Se buscara el archivo(con su ruta) ya sea ingresado desde el programa o buscarlo en la carpeta de Origen

if [ "$ARCHPRMT" = "" ] ; then
	FILEDATA=`find $RUTANAME/$ARCHNAME`
	CANT_DATA=`cat  $RUTANAME/$ARCHNAME | wc -l | sed 's/ //g'`
else
	FILEDATA=`find $RUTANAME/$ARCHPRMT2`
	CANT_DATA=`cat  $RUTANAME/$ARCHPRMT2 | wc -l | sed 's/ //g'`
fi

#COMPROBANDO LA EXISTENCIA Y SI EXISTEN DATOS

if [ "$FILEDATA" = "" ] ; then
   Demora=`date +"%Y-%m-%d %H:%M:%S"`
   pMessage "Error: No se encontro el archivo de datos..."$'\n'
   pMessage "Termino proceso" 
   pMessage "************************************" 
   pMessage " FINALIZANDO PROCESO..............." 
   pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso " 
   pMessage "************************************" 
   pMessage "No existe ninguno de estos archivos $ARCHNAME" 
   pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Alta de clientes no se encuentra en la ruta" 
   echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "DTH-POSTPAGO: El Archivo de Alta de clientes no se encuentra en la ruta." $IT_MAIL 
   pMessage "Ruta del Archivo log : " $FILELOG
   exit -1
fi
  
if [ $CANT_DATA = 0 ] ; then
	pMessage "Ninguno de estos archivos tiene data $ARCHNAME" 
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Alta de clientes se encuentra vacio."
	echo "Buen día, los siguientes archivos $ARCHNAME en la carpeta de ORIGEN no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "DTH-POSTPAGO: El Archivo de Alta de clientes se encuentra vacio" $IT_MAIL
	pMessage "Se envió correo Fecha y Hora: $demora"
	exit -1
fi
	
	
if [ "$ARCHPRMT" = "" ] ; then
	ARCHFECHA=${ARCHNAME:20:8}
	ARCHNAMEF=$ARCHNAME
else
	ARCHNAMEF=$ARCHPRMT
	ARCHFECHA=${ARCHPRMT:20:8}
fi

NOMARCH="'"${ARCHNAMEF}"'"
FECHATMP="'"${ARCHFECHA}"'"

echo "Archivo: $NOMARCH"
echo "Fecha : $FECHATMP"
	
pMessage "Se convierte el archivo de entrada al formato UNIX"
dos2unix ${FILEDATA}

TMP=$DIRLOGDTH/TEMPDATA01.tmp
echo "" >> ${FILEDATA}
cat ${FILEDATA} | sed '/^$/d' > $TMP
cat $TMP > ${FILEDATA}
		
rm -f $TMP
	

# TEMP_FILE=TEMP01_${FECHA}.TMP
TEMP_FILE=TEMP01_${FECHA}.TMP

ARCHPRMT2=${FILEDATA#*ALTA_DTH_}
ARCHPRMT3=ALTA_DTH_$ARCHPRMT2

while read FIELD02
do
	echo "${FIELD02}|${ARCHPRMT2:0:8}|${ARCHPRMT3}" >> $DIRLOGDTH/$TEMP_FILE	
done < $FILEDATA

pMessage "Se procede a importar los datos del archivo de entrada a la tabla de alta de clientes"
sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$CONTROL data=$DIRLOGDTH/$TEMP_FILE bad=$BAD log=$CTL_LOG bindsize=200000 readsize=200000 rows=1000 skip=0

rm -f $DIRLOGDTH/$TEMP_FILE
        
VALIDAT_CTL=`grep 'ORA-' $CTL_LOG | wc -l`		
if [ $VALIDAT_CTL -ne 0 ]
                then
    pMessage "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n'
    pMessage "Verifique el log para mayor detalle $FILELOG"$'\n'
	pMessage `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n' 
	#echo "Buen día, ocurrio un error al momento de importar los datos a la tabla de Alta. Archivo BAD: $BAD" $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "DTH-POSTPAGO: Error BSCS." $IT_MAIL
    BAD_ZIP=importaAltacliDTH_BAD_$FECHA.zip
	BAD_NOM=importaAltacliDTH_BAD_$FECHA.bad
	cd $DIRFALLOSDTH
	zip $BAD_ZIP $BAD_NOM
	(echo "Buen día, ocurrio un error al momento de importar los datos a la tabla de Alta. Se adjunta el archivo BAD." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n' ; uuencode $BAD_ZIP $BAD_ZIP) | mail -s "DTH-POSTPAGO: Error DATA BSCS." $IT_MAIL
    rm -f $BAD_ZIP
	cd $DIR_DTH_SHELL
	#pMessage "Termino proceso" 
    pMessage "************************************"
    #pMessage " FINALIZANDO PROCESO..............."
    #pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso "
    pMessage "************************************"
    pMessage "Ruta del Archivo log : " $CTL_LOG
    #exit -1
fi

#rm -f $CTL_LOG
	
pMessage "El proceso de importacion culmino satisfactoriamente"
	
cp $FILEDATA $DIR_PROC_ALTA

#Capturando la fecha

if [ "$ARCHPRMT" = "" ] ; then
	FECHAARCH=$FARCH
else
	ARCHPRMT1=${ARCHPRMT#*ALTA_DTH_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi

echo "$FECHAARCH"
FECHATMP="'"${FECHAARCH}"'"

pMessage "Se procede a ejecutar el SP PKG_CC_PTOSFIJA.ADMPSI_ALTACLIENTEDTH"

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
		$PCLUB_OW.PKG_CC_PTOSFIJA.ADMPSI_ALTACLIENTEDTH(v_fecha,'USRREGDTH',k_coderror,
						k_descerror,
						k_numregtot,
						k_numregpro,
						k_numregerr);
	end;
		
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
    pMessage "Hubo un error durante la ejeción del SP PKG_CC_PTOSFIJA.ADMPSI_ALTACLIENTEDTH" 
    pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de IMPORTACION DE ALTA DE clientes – Se encontraron errores" 
    echo "Buen día, ocurrio un problema al ejecutar el SP de PKG_CC_PTOSFIJA.ADMPSI_ALTACLIENTEDTH." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "DTH-POSTPAGO: IMPORTACION DE ALTA DE clientes – Se encontraron errores" $IT_MAIL >> $FILELOG		
    exit
fi

pMessage "Ejecución de SP fue satisfactorio"
       

ARCHERR=ALTA_DTH_${FARCH}
ARCHERR2=ALTA_DTH_param_${FARCH}


if [ "$ARCHPRMT" = "" ] ; then
	FINDFILE=`find $RUTANAME/$ARCHNAME`
	FINDBKP=`find $DIR_PROC_ALTA/$ARCHNAME`
	STRINGRUTA=$ARCHNAME
	FECHAARCH=$FARCH
else
	FINDFILE2=`find $RUTANAME/$ARCHPRMT`
	STRINGRUTA=$ARCHPRMT
	ARCHPRMT1=${STRINGRUTA#*ALTA_DTH_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi

#Flujo corroborar archivos

if [ "$FINDFILE" = "" ] && [ "$FINDBKP" = "" ] && [ "$FINDFILE2" = "" ] ; then
	pMessage "Hora y Fecha: $demora"
	pMessage "No existe archivos para el procesamiento: $ARCHNAME" 
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Alta de clientes no se encuentra en la ruta" 
	echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "DTH-POSTPAGO: El Archivo de Alta de clientes no se encuentra en la ruta." $IT_MAIL 
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
	
#borra si existiese un log de alguna ejecucion anterior enviada el mismo dia
rm -f ${DIR_ERR_ALTA}/${FILEERR}

echo $FECHATMP

pMessage "Se procede a ejecutar el SP PKG_CC_PTOSFIJA.ADMPSI_EALTACLIENTEDTH y exportar los datos obtenidos"

sqlplus -s $USER_BD/$CLAVE_BD@$SID_BD <<EOP  >> ${DIR_ERR_ALTA}/${FILEERR}

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
  cursoraltaclic ty_cursor;           
  c_tipo_doc VARCHAR2(20);
  c_num_doc VARCHAR2(20);   
  c_cod_cli VARCHAR2(40);   
  c_fec_act VARCHAR2(10);    
  c_msje_error varchar2(400);
  v_fecha date;
  
  BEGIN
  
  dbms_output.enable(NULL);
  
   SELECT TO_DATE($FECHATMP,'YYYYMMDD') INTO v_fecha FROM DUAL;
   
    $PCLUB_OW.PKG_CC_PTOSFIJA.ADMPSI_EALTACLIENTEDTH(v_fecha,cursoraltaclic);
   
  LOOP
  
  fetch cursoraltaclic into c_cod_cli,c_tipo_doc,c_num_doc,c_msje_error,c_fec_act;
  exit when cursoraltaclic%notfound;
  
  DBMS_OUTPUT.put_line(c_tipo_doc || '|' || c_num_doc || '|' || c_fec_act || '|' || c_cod_cli || '|' || c_msje_error);
  
  END LOOP;
  
  CLOSE cursoraltaclic;
  
  EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
  END;
/
EXIT
EOP

#---
	
CANT_DATA=`cat ${DIR_ERR_ALTA}/${FILEERR} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP=`grep 'ORA-' ${DIR_ERR_ALTA}/${FILEERR} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B=`grep 'SP2-' ${DIR_ERR_ALTA}/${FILEERR} | wc -l | sed 's/ //g'`
    
if [ $CANT_DATA = 0 ] ; then
	pMessage "El archivo no trajo datos, asi que no se podra generar en la carpeta destino"
	#rm ${DIR_ERR_ALTA}/${FILEERR}
else
	pMessage "Se ha generado el archivo ${DIR_ERR_ALTA}/${FILEERR}"
fi

if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
	cat ${DIR_ERR_ALTA}/${FILEERR} >> $FILELOG
    pMessage "Hubo un error durante la ejeción del SP PKG_CC_PTOSFIJA.ADMPSI_EALTACLIENTEDTH"        
	echo "Buen día, Hubo un error durante la ejecución del SP PKG_CC_PTOSFIJA.ADMPSI_EALTACLIENTEDTH." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "DTH-POSTPAGO: Alta de clientes." $IT_MAIL 	
	exit
else
	if [ $CANT_DATA != 0 ] ; then
		pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de Errores en el proceso de baja" 
		FILEERR_ZIP=ALTA_DTH_$FARCH.zip
		cd $DIR_ERR_ALTA
		zip $FILEERR_ZIP $FILEERR
		(echo "Buen día, se encontraron $CANT_DATA errores. Revisar la ruta ${DIR_ERR_ALTA}/${FILEERR}." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  ; uuencode $FILEERR_ZIP $FILEERR_ZIP) | mail -s "DTH-POSTPAGO : Errores en el proceso de alta." $IT_MAIL
		rm -f $FILEERR_ZIP
		exit
	fi	
fi

pMessage "Ejecución de SP fue satisfactorio"
	   
pMessage "Se finalizó el proceso de Ejecución de ADMPSI_EALTACLIENTEDTH"

pMessage "Se finalizó el proceso de Ejecución de ALTA DE clientes"

pMessage "Fin de todo el Proceso de Migracion de Alta de clientes"

exit
