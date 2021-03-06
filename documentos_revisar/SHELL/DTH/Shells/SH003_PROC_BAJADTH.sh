#! /bin/ksh
#*************************************************************
#* DESCRIPCION           : Baja de Clientes - DTH               *
#* EJECUCION             : Control-D                                                          *
#* AUTOR                 :                                   *
#* FECHA                 : 03/11/2010   VERSION : v1.0                        *
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
CONTROL=$DIRCONTROLDTH/bajaClienteDTH.ctl
BAD=$DIRFALLOSDTH/bajaClienteDTH_BAD_$FECHA.bad
FILELOG=$DIRLOGDTH/SH003_PROC_BAJADTH_$FECHA.log
CTL_LOG=$DIRLOGDTH/CTL003_LOG_$FECHA.log
ARCHNAME=BAJA_DTH_$FARCH.CCL
RUTANAME=$DIR_ENT_BAJA
ARCHSHELL=SH003_PROC_BAJADTH.sh

if [ "$1" = "" ] ; then
	ARCHPRMT=""
else
	ARCHPRMT1=${1#*BAJA_DTH_}
	ARCHPRMT=BAJA_DTH_$ARCHPRMT1
fi


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

if [ "$FILEDATA" = "" ] ; then
   Demora=`date +"%Y-%m-%d %H:%M:%S"`
   pMessage "No se encontro el archivo de datos..." 
   pMessage "Termino proceso"
   pMessage "************************************" 
   pMessage " FINALIZANDO PROCESO..............." 
   pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso " 
   pMessage "************************************" 
   pMessage "No existe ninguno de estos archivos $ARCHNAME" 
   pMessage "A continuaci�n se enviar� un correo a $IT_MAIL con el asunto de El Archivo de Baja no se encuentra en la ruta" 
   echo "Buen d�a, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "DTH-POSTPAGO: El Archivo de Baja DTH no se encuentra en la ruta." $IT_MAIL 
   pMessage "Ruta del Archivo log : " $FILELOG
   echo $'\n'
   exit -1
fi

if [ $CANT_DATA = 0 ] ; then
	pMessage "Ninguno de estos archivos tiene data $ARCHNAME" 
	pMessage "A continuaci�n se enviar� un correo a $IT_MAIL con el asunto de El Archivo de Baja se encuentra vacio." 
	echo "Buen d�a, los siguientes archivos $ARCHNAME en la carpeta de ORIGEN no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "DTH-POSTPAGO: El Archivo de Baja DTH se encuentra vacio" $IT_MAIL
	pMessage "Se envi� correo Fecha y Hora: $demora"
	exit -1
fi

pMessage "Se convierte el archivo de entrada al formato UNIX"
dos2unix ${FILEDATA}

TMP=$DIRLOGDTH/TEMPDATA03.tmp
echo "" >> ${FILEDATA}
cat ${FILEDATA} | sed '/^$/d' > $TMP
cat $TMP > ${FILEDATA}
		
rm -f $TMP


TEMP_FILE=TEMP03_${FECHA}.TMP

ARCHPRMT2=${FILEDATA#*BAJA_DTH_}
ARCHPRMT3=BAJA_DTH_$ARCHPRMT2

while read FIELD02
do
	echo "${FIELD02}|${ARCHPRMT2:0:8}|${ARCHPRMT3}" >> $DIRLOGDTH/$TEMP_FILE	
done < $FILEDATA

pMessage "Se procede a importar los datos del archivo de entrada a la tabla de baja de clientes"
sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$CONTROL data=$DIRLOGDTH/$TEMP_FILE bad=$BAD log=$CTL_LOG bindsize=200000 readsize=200000 rows=1000 skip=0

rm -f $DIRLOGDTH/$TEMP_FILE

VALIDAT_CTL=`grep 'ORA-' $CTL_LOG | wc -l`		
if [ $VALIDAT_CTL -ne 0 ]
    then
    pMessage "en la ejecucion del control $CONTROL. Contacte al administrador."$'\n'
    pMessage "FECHA $Demora - Verifique el log para mayor detalle $FILELOG"$'\n'
    pMessage `date +"%Y-%m-%d %H:%M:%S"` "en la ejecucion del control $CONTROL. Contacte al administrador."$'\n' 
	#echo "Buen d�a, ocurrio un inconveniente al momento de importar los datos a la tabla de Baja. Archivo BAD: $BAD" $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "DTH-POSTPAGO: BSCS." $IT_MAIL
    BAD_ZIP=bajaClienteDTH_BAD_$FECHA.zip
	BAD_NOM=bajaClienteDTH_BAD_$FECHA.bad
	cd $DIRFALLOSDTH
	zip $BAD_ZIP $BAD_NOM
	(echo "Buen d�a, ocurrio un inconveniente al momento de importar los datos a la tabla de Baja. Se adjunta el archivo BAD." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n' ; uuencode $BAD_ZIP $BAD_ZIP) | mail -s "DTH-POSTPAGO: DATA BSCS." $IT_MAIL
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

cp $FILEDATA $DIR_PROC_BAJA

#Capturando la fecha	
if [ "$ARCHPRMT" = "" ] ; then
	FECHAARCH=$FARCH
else		
	ARCHPRMT1=${ARCHNAME2#*BAJA_DTH_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi


echo "$FECHAARCH"
FECHATMP="'"${FECHAARCH}"'"

	
pMessage "Se procede a ejecutar el SP PKG_CC_PTOSFIJA.ADMPSI_BAJACLICDTH"
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
k_usuario varchar2(50):='USRBAJDTH';				
BEGIN
		
	SELECT TO_DATE($FECHATMP,'YYYYMMDD') INTO v_fecha FROM DUAL;
	begin
							
		$PCLUB_OW.PKG_CC_PTOSFIJA.ADMPSI_BAJACLIENTEDTH(v_fecha,k_usuario,k_coderror,
						k_descerror,
						k_numregtot,
						k_numregpro,
						k_numregerr);
	end;
		
	dbms_output.put_line('Codigo: ' || k_coderror || '|Mensaje: ' || k_descerror || '|N� total de registros: ' || k_numregtot || '|N� de registros procesados: ' || k_numregpro || '|N� de registros con errores: ' || k_numregerr);
	
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
    pMessage "Hubo un durante la ejeci�n del SP PKG_CC_PTOSFIJA.ADMPSI_BAJACLIENTEDTH" 
    pMessage "A continuaci�n se enviar� un correo a $IT_MAIL con el asunto de BAJA DE CLIENTES � Se encontraron errores" 
    echo "Buen d�a, ocurrio un problema al ejecutar el SP de PKG_CC_PTOSFIJA.ADMPSI_BAJACLIENTEDTH." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "DTH-POSTPAGO: BAJA DE CLIENTES � Se encontraron errores" $IT_MAIL 		
    pMessage "Se envi� correo Fecha y Hora: $demora"    
	exit
fi

pMessage "Ejecuci�n de SP fue satisfactorio"

ARCHERR=BAJA_DTH_${FARCH}
ARCHERR2=BAJA_DTH_param_${FARCH}

if [ "$ARCHPRMT" = "" ] ; then
	FINDFILE=`find $RUTANAME/$ARCHNAME`
	FINDBKP=`find $DIR_PROC_BAJA/$ARCHNAME`
	STRINGRUTA=$ARCHNAME
	FECHAARCH=$FARCH
else
	FINDFILE2=`find $RUTANAME/$ARCHPRMT`
	STRINGRUTA=$ARCHPRMT
	ARCHPRMT1=${STRINGRUTA#*BAJA_DTH_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi

#Flujo corroborar archivos

if [ "$FINDFILE" = "" ] && [ "$FINDBKP" = "" ] && [ "$FINDFILE2" = "" ] ; then
	pMessage "Hora y Fecha: $demora"
	pMessage "No existe ninguno de estos archivos $ARCHNAME" 
	pMessage "A continuaci�n se enviar� un correo a $IT_MAIL con el asunto de El Archivo de Alta de clientes no se encuentra en la ruta" 
	echo "Buen d�a, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "DTH-POSTPAGO: El Archivo de Baja de clientes no se encuentra en la ruta." $IT_MAIL 
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

#---elimina el archivo de errores para las ejecuciones anteriores en el mismo dia
rm -f ${DIR_ERR_BAJA}/${FILEERR}

echo $FECHATMP

pMessage "Se procede a ejecutar el SP PKG_CC_PTOSFIJA.ADMPSI_EBAJACLIENTEDTH y exportar los datos obtenidos"

sqlplus -s $USER_BD/$CLAVE_BD@$SID_BD <<EOP  >> ${DIR_ERR_BAJA}/${FILEERR}

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
  c_cod_cli VARCHAR2(40);    
  c_fec_oper VARCHAR2(40);  
  c_fec_baja VARCHAR2(40);   
  c_msje_error varchar2(400);
  v_fecha date;
  
  BEGIN
  
  dbms_output.enable(NULL);
  
   SELECT TO_DATE($FECHATMP,'YYYYMMDD') INTO v_fecha FROM DUAL;
   
    $PCLUB_OW.PKG_CC_PTOSFIJA.ADMPSI_EBAJACLIENTEDTH(v_fecha,cursoraltaclic);
   
  LOOP
  
  fetch cursoraltaclic into c_cod_cli,c_fec_baja,c_fec_oper,c_msje_error;
  exit when cursoraltaclic%notfound;
  
  DBMS_OUTPUT.put_line(c_cod_cli || '|' || c_fec_baja || '|' || c_fec_oper || '|' || c_msje_error);
  
  END LOOP;
  
  CLOSE cursoraltaclic;
  
  EXCEPTION
    when OTHERS then
      dbms_output.put_line('problem: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
  END;
/
EXIT
EOP

#---
	
CANT_DATA=`cat ${DIR_ERR_BAJA}/${FILEERR} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP=`grep 'ORA-' ${DIR_ERR_BAJA}/${FILEERR} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B=`grep 'SP2-' ${DIR_ERR_BAJA}/${FILEERR} | wc -l | sed 's/ //g'`
    
if [ $CANT_DATA = 0 ] ; then
	pMessage "El archivo no trajo datos, asi que no se podra generar en la carpeta destino"
	#rm ${DIR_ERR_BAJA}/${FILEERR}
else
	pMessage "Se ha generado el archivo ${DIR_ERR_BAJA}/${FILEERR}"
fi

if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
	cat ${DIR_ERR_BAJA}/${FILEERR} >> $FILELOG
    pMessage "Hubo un  durante la ejecuci�n del SP PKG_CC_PTOSFIJA.ADMPSI_EBAJACLIENTEDTH"  
	echo "Buen d�a, Hubo un  durante la ejecuci�n del SP PKG_CC_PTOSFIJA.ADMPSI_EBAJACLIENTEDTH." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "DTH-POSTPAGO: Baja de clientes." $IT_MAIL 	
	exit
else
	if [ $CANT_DATA != 0 ] ; then
		pMessage "A continuaci�n se enviar� un correo a $IT_MAIL con el asunto de Errores en el proceso de baja" 
		FILEERR_ZIP=BAJA_DTH_$FARCH.zip
		cd $DIR_ERR_BAJA
		zip $FILEERR_ZIP $FILEERR
		(echo "Buen d�a, se encontraron $CANT_DATA errores. Revisar la ruta ${DIR_ERR_BAJA}/${FILEERR}." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  ; uuencode $FILEERR_ZIP $FILEERR_ZIP) | mail -s "DTH-POSTPAGO : Baja - Errores en el proceso de baja." $IT_MAIL
		rm -f $FILEERR_ZIP		
		exit
	fi	
fi

pMessage "Termino subproceso BAJA DE CLIENTES DTH ClaroClub "
pMessage "********** FINALIZANDO PROCESO ********** " 
pMessage "Fin de proceso "
pMessage "************************************" 
pMessage "Ruta del Archivo log : ${FILELOG}" 
pMessage "*************************************" 
exit