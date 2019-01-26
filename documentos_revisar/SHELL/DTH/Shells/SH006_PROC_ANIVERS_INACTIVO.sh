#! /bin/ksh
#*************************************************************
#* DESCRIPCION           : Importacion de Aniversario - Claro Club DTH                                   *
#* EJECUCION             :                                                         *
#* AUTOR                 :                                    *
#* FECHA                 : 15/05/2012   VERSION : v1.0                        *
#* FECHA MOD .           :                         *
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
CONTROL=$DIRCONTROLDTH/importaPAniversarioDTH.ctl
BAD=$DIRFALLOSDTH/importaPAniversario_BAD_$FECHA.bad
FILELOG=$DIRLOGDTH/SH006_PROC_ANIVERS_$FECHA.log
CTL_LOG=$DIRLOGDTH/CTL006_LOG_$FECHA.log
ARCHNAME=ANIVERS_DTH_${FARCH}.CCL
ARCHPRMT2=$1
RUTANAME=$DIR_ENT_ANIVERS


if [ "$1" = "" ] ; then
	ARCHPRMT=""
else
	ARCHPRMT1=${1#*ANIVERS_DTH_}
	ARCHPRMT=ANIVERS_DTH_$ARCHPRMT1
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
   pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de ANIVERSARIO no se encuentra en la ruta" 
   echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "DTH-POSTPAGO: El Archivo de ANIVERSARIO no se encuentra en la ruta." $IT_MAIL 
   pMessage "Ruta del Archivo log : " $FILELOG
   echo $'\n'
   exit -1
fi

if [ $CANT_DATA = 0 ] ; then
	pMessage "Hora y Fecha: $demora"
	pMessage "Ninguno de estos archivos tiene data $ARCHNAME" 
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de ANIVERSARIO se encuentra vacio." 
	echo "Buen día, los siguientes archivos $ARCHNAME en la carpeta de ORIGEN no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "DTH-POSTPAGO: El Archivo de ANIVERSARIO se encuentra vacio" $IT_MAIL
	pMessage "Se envió correo Fecha y Hora: $demora"
	exit -1
fi

pMessage "Se convierte el archivo de entrada al formato UNIX"
dos2unix ${FILEDATA}

TMP=$DIRLOGDTH/TEMPDATA06.tmp
echo "" >> ${FILEDATA}
cat ${FILEDATA} | sed '/^$/d' > $TMP
cat $TMP > ${FILEDATA}
		
rm -f $TMP

TEMP_FILE=TEMP06_${FECHA}.TMP

ARCHPRMT2=${FILEDATA#*ANIVERS_DTH_}
ARCHPRMT3=ANIVERS_DTH_$ARCHPRMT2

while read FIELD02
do
	echo "${FIELD02}|${ARCHPRMT2:0:8}|${ARCHPRMT3}" >> $DIRLOGDTH/$TEMP_FILE	
done < $FILEDATA

pMessage "Se procede a importar los datos del archivo de entrada a la tabla de ANIVERSARIO"
sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$CONTROL data=$DIRLOGDTH/$TEMP_FILE bad=$BAD log=$CTL_LOG bindsize=200000 readsize=200000 rows=1000 skip=0

rm -f $DIRLOGDTH/$TEMP_FILE

VALIDAT_CTL=`grep 'ORA-' $CTL_LOG | wc -l`
		
if [ $VALIDAT_CTL -ne 0 ] ;
    then
    pMessage "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n'
    pMessage "FECHA $Demora - Verifique el log para mayor detalle $FILELOG"$'\n'
    pMessage `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n' 
	#echo "Buen día, ocurrio un error al momento de importar los datos a la tabla de Aniversario. Archivo BAD: $BAD ." $'\n' "Favor de atender este inconveniente." $'\n' " Gracias." $'\n'  | mail -s "DTH-POSTPAGO: Error BSCS" $IT_MAIL
    BAD_ZIP=importaPAniversario_BAD_$FECHA.zip
	BAD_NOM=importaPAniversario_BAD_$FECHA.bad
	cd $DIRFALLOSDTH
	zip $BAD_ZIP $BAD_NOM
	(echo "Buen día, ocurrio un error al momento de importar los datos a la tabla de Aniversario. Se adjunta el archivo BAD." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n' ; uuencode $BAD_ZIP $BAD_ZIP) | mail -s "DTH-POSTPAGO: Error DATA BSCS." $IT_MAIL
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
	
cp $FILEDATA $DIR_PROC_ANIVERS

#Capturando la fecha
if [ "$ARCHPRMT" = "" ] ; then
	FECHAARCH=$FARCH
else
	ARCHPRMT1=${ARCHPRMT#*ANIVERS_DTH_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi

FECHATMP="'"${FECHAARCH}"'"
#Flujo corroborar archivos

pMessage "Se ejecuta el SP PKG_CC_PTOSFIJA.ADMPSI_ANIVERSARIO"
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

	$PCLUB_OW.PKG_CC_PTOSFIJA.ADMPSI_ANIVERSARIO(v_fecha,'USRFACDTH',k_coderror,k_descerror,k_numregtot,k_numregpro,k_numregerr);
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
    pMessage "Hora y Fecha: $demora"
    pMessage "Hubo un error durante la ejeción del SP PKG_CC_PTOSFIJA.ADMPSI_ANIVERSARIO" 
    pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de IMPORTACION DE ANIVERSARIO – Se encontraron errores" 
    echo "Buen día, ocurrio un problema al ejecutar el SP de PKG_CC_PTOSFIJA.ADMPSI_ANIVERSARIO." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "DTH-POSTPAGO: IMPORTACION DE ANIVERSARIO " $IT_MAIL 		
    pMessage "Se envió correo Fecha y Hora: $demora"    
	exit
fi

pMessage "Ejecución de SP fue satisfactorio"

ARCHERR=ANIVERS_DTH_${FARCH}
ARCHERR2=ANIVERS_DTH_param_${FARCH}


####Proceso####
# Finf file: Variables para corroborar que el archivo existe en la ruta

if [ "$ARCHPRMT" = "" ] ; then
	FINDFILE=`find $RUTANAME/$ARCHNAME`
	FINDBKP=`find $DIR_PROC_ANIVERS/$ARCHNAME`
	STRINGRUTA=$ARCHNAME
	FECHAARCH=$FARCH
else
	FINDFILE2=`find $RUTANAME/$ARCHPRMT`
	STRINGRUTA=$ARCHPRMT
	ARCHPRMT1=${STRINGRUTA#*ANIVERS_DTH_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi



#Flujo corroborar archivos

if [ "$FINDFILE" = "" ] && [ "$FINDBKP" = "" ] && [ "$FINDFILE2" = "" ] ; then
	pMessage "Hora y Fecha: $demora"
	pMessage "No existe ninguno de estos archivos $ARCHNAME" 
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Aniversario no se encuentra en la ruta" 
	echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "DTH-POSTPAGO: El Archivo de Aniversario no se encuentra en la ruta." $IT_MAIL 
	pMessage "Se envió correo Fecha y Hora: $demora"
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
rm -f ${DIR_ERR_ANIVERS}/${FILEERR}

pMessage "Se ejecuta el SP PKG_CC_PTOSFIJA.ADMPSI_EANIVERSARIO y se exporta los datos obtenidos"
sqlplus -S $USER_BD/$CLAVE_BD@$SID_BD <<EOP >> ${DIR_ERR_ANIVERS}/${FILEERR}
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
  c_tip_doc varchar2(10);
   c_num_doc varchar2(20);
  c_fec_oper varchar2(12);
  c_des_error varchar2(400);
  v_fecha date;
  
  BEGIN
  
  dbms_output.enable(NULL);
  
   SELECT TO_DATE('${FECHAARCH}','YYYYMMDD') INTO v_fecha FROM DUAL;
   
    $PCLUB_OW.PKG_CC_PTOSFIJA.ADMPSI_EANIVERSARIO(v_fecha,cursorpago);
   
  LOOP
  fetch cursorpago into c_cod_cli,c_tip_doc,c_num_doc,c_fec_oper,c_des_error;
  exit when cursorpago%notfound;
  
  DBMS_OUTPUT.put_line(c_cod_cli || '|' || c_tip_doc || '|'  || c_num_doc|| '|'  || c_fec_oper || '|'  || c_des_error);
  
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
	
CANT_DATA=`cat ${DIR_ERR_ANIVERS}/${FILEERR} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP=`grep 'ORA-' ${DIR_ERR_ANIVERS}/${FILEERR} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B=`grep 'SP2-' ${DIR_ERR_ANIVERS}/${FILEERR} | wc -l | sed 's/ //g'`
    
if [ $CANT_DATA = 0 ] ; then
	pMessage "El proceso no trajo errores en ${DIR_ERR_ANIVERS}/${FILEERR}, asi que no se podra generar en la carpeta Fallos"
	#rm ${DIR_ERR_ANIVERS}/${FILEERR}
else
	pMessage "Se ha generado el archivo ${DIR_ERR_ANIVERS}/${FILEERR}"
fi
    
if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
	cat  ${DIR_ERR_ANIVERS}/${FILEERR} >>  $FILELOG
    pMessage "Hora y Fecha: $demora"
    pMessage "Hubo un error durante la ejeción del SP PKG_CC_PTOSFIJA.ADMPSI_EANIVERSARIO"  
	echo "Buen día, Hubo un error durante la ejeción del SP PKG_CC_PTOSFIJA.ADMPSI_EANIVERSARIO." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "DTH-POSTPAGO: Importacion de ANIVERSARIO." $IT_MAIL 
	exit
else
	if [ $CANT_DATA != 0 ] ; then
		pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de Errores en el proceso de aniversario" 
		FILEERR_ZIP=ANIVERS_DTH_$FARCH.zip
		cd $DIR_ERR_ANIVERS
		zip $FILEERR_ZIP $FILEERR
		(echo "Buen día, se encontraron $CANT_DATA errores. Revisar la ruta ${DIR_ERR_ANIVERS}/${FILEERR}." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  ; uuencode $FILEERR_ZIP $FILEERR_ZIP) | mail -s "DTH-POSTPAGO : Aniversario - Errores en el proceso de aniversario." $IT_MAIL
		rm -f $FILEERR_ZIP		
		exit
	fi	
fi

pMessage "Ejecución de SP ADMPSI_EANIVERSARIO fue satisfactorio"

pMessage "Se finalizó el proceso de Ejecución de ADMPSI_EANIVERSARIO"

pMessage "Se finalizó el proceso de Ejecución de ADMPSI_ANIVERSARIO"

pMessage "Fin de todo el Proceso de Migracion de ANIVERSARIO"

exit
