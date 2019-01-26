#! /bin/ksh
#*************************************************************
#* DESCRIPCION           : Importacion de Puntos de Promocion                                    *
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
CONTROL=$DIRCONTROLPOST/importaPuntosPromo.ctl
BAD=$DIRBADPOST/importaPuntosPromo_BAD_$FECHA.bad
FILELOG=$DIRLOGPOST/SH004_PUNTOSPROMO_$FECHA.log
#FILELOG2=TMPimportaPuntosPromo_LOG_$FECHA.log
CTL_LOG=$DIRLOGPOST/CTL004_LOG_$FECHA.log
ARCHNAME=IDPROMOCION_$FARCH.CCL

if [ "$1" = "" ] ; then
	ARCHPRMT=""
else
	ARCHPRMT1=${1#*IDPROMOCION_}
	ARCHPRMT=IDPROMOCION_$ARCHPRMT1
fi
RUTANAME=$DIRENTRADAPOST
ARCHSHELL=SH004_SP_ADMPSI_PROMO.sh


# Inicio
demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "*************************************" 
pMessage "Iniciando proceso               " 
pMessage "Fecha y Hora : $demora               " 
pMessage "*************************************"
pMessage $'\n'"Iniciando proceso .... "

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

TMP=$DIRLOGPOST/TEMPDATA04.tmp
echo "" >> ${FILEDATA}
cat ${FILEDATA} | sed '/^$/d' > $TMP
cat $TMP > ${FILEDATA}
		
rm -f $TMP

if [ "$FILEDATA" = "" ] ; then
   Demora=`date +"%Y-%m-%d %H:%M:%S"`
   pMessage "Error: No se encontro el archivo de datos..."$'\n'
   pMessage "Termino proceso">>  $FILELOG
   pMessage "************************************"
   pMessage " FINALIZANDO PROCESO..............." 
   pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso " 
   pMessage "************************************" 
   pMessage "No existe ninguno de estos archivos $ARCHNAME" 
   pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Promociones no se encuentra en la ruta" 
   echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo de Promociones no se encuentra en la ruta." $IT_MAIL 
   pMessage "Ruta del Archivo log : " $FILELOG
   exit
fi

if [ $CANT_DATA = 0 ] ; then
	pMessage "Ninguno de estos archivos tiene data $ARCHNAME" 
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Promociones se encuentra vacio." 
	echo "Buen día, los siguientes archivos $ARCHNAME en la carpeta de ORIGEN no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "El Archivo de Promociones se encuentra vacio" $IT_MAIL
	pMessage "Se envió correo Fecha y Hora: $demora"
	exit
fi

TEMP_FILE=TEMP01_${FECHA}.TMP

ARCHPRMT2=${FILEDATA#*IDPROMOCION_}
ARCHPRMT3=IDPROMOCION_$ARCHPRMT2

while read FIELD02
do
	echo "${FIELD02}|${ARCHPRMT2:0:8}|${ARCHPRMT3}" >> $DIRLOGPOST/$TEMP_FILE	
done < $FILEDATA

pMessage "Se procede a importar los datos del archivo de entrada a la tabla de promociones"
sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$CONTROL data=$DIRLOGPOST/$TEMP_FILE bad=$BAD log=$CTL_LOG bindsize=200000 readsize=200000 rows=1000 skip=0

rm -f $DIRLOGPOST/$TEMP_FILE

VALIDAT_CTL=`grep 'ORA-' $CTL_LOG | wc -l`
		
if [ $VALIDAT_CTL -ne 0 ] ; then                        
	pMessage "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n'
    pMessage " Verifique el log para mayor detalle $FILELOG"$'\n'
    pMessage "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n' 
	pMessage "Termino proceso"
    pMessage "************************************" 
    pMessage " FINALIZANDO PROCESO..............." 
    pMessage "************************************" 
    pMessage "Ruta del Archivo log : " $FILELOG
    echo $'\n'
	exit
fi

pMessage "El proceso de importacion culmino satisfactoriamente"

rm -f $CTL_LOG
	
pMessage "Termino de Cargar los Registros a la tabla de Promociones..."$'\n'

cp $FILEDATA $DIRBACKUPPOST
echo "$ARCHPRMT"
		
if [ "$ARCHPRMT" = "" ] ; then
	ARCHNAME2=""
	#sh $DIR_POST_SHELL/$ARCHSHELL
else		
	ARCHNAME2=$FILEDATA
	#sh $DIR_POST_SHELL/$ARCHSHELL $FILEDATA
fi

#--

ARCHNAME=IDPROMOCION_${FARCH}.CCL
ARCHNAME2=$1
#ARCH_TEMP=idpromocion_log_${FECHA}.log
#ARCHSHELL=SH004_SP_ADMPSI_EPROMO.sh
#FILELOG=$DIRLOGPOST/importaPromocion_LOG_$FECHA.log


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
ARCHPRMT1=${ARCHNAME2#*IDPROMOCION_}
FECHAARCH=${ARCHPRMT1:0:8}
fi

echo "$FECHAARCH"
FECHATMP="'"${FECHAARCH}"'"
#Flujo corroborar archivos

if [ "$FINDFILE" = "" ]; then
   pMessage "Error: No se encontro el archivo de datos..."$'\n'
   pMessage "Termino proceso"
   pMessage "************************************" 
   pMessage " FINALIZANDO PROCESO..............." 
   pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso " 
   pMessage "************************************" 
   pMessage "No existe ninguno de estos archivos $ARCHNAME" 
   pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Promociones no se encuentra en la ruta" 
   echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $DIRENTRADAPOST." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo de Promociones no se encuentra en la ruta." $IT_MAIL 
   pMessage "Ruta del Archivo log : " $FILELOG
   echo $'\n'
   exit -1
fi

if [ $CANT_DATA = 0 ] ; then
	pMessage "Ninguno de estos archivos tiene data $ARCHNAME"
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Promociones se encuentra vacio."
	echo "Buen día, los siguientes archivos $ARCHNAME en la carpeta de ORIGEN no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "El Archivo de Promociones se encuentra vacio" $IT_MAIL
	pMessage "Se envió correo Fecha y Hora: $demora"
	exit -1
fi

pMessage "Se procede a ejecutar el SP PKG_CC_PROCACUMULA.admpsi_promoc"
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
						
		$PCLUB_OW.PKG_CC_PROCACUMULA.admpsi_promoc(v_fecha,k_coderror,
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
    pMessage "Hubo un error durante la ejecución del SP pkg_cc_procacumula.admpsi_promoc"
    pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de IMPORTACION DE PUNTOS POR PROMOCION – Se encontraron errores" 
    echo "Buen día, ocurrio un problema al ejecutar el SP de pkg_cc_procacumula.admpsi_promoc." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "IMPORTACION DE PUNTOS POR PROMOCION – Se encontraron errores" $IT_MAIL >> $FILELOG		
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

ARCHNAME=IDPROMOCION_${FARCH}.CCL
ARCHERR=IDPROMOCION_${FARCH}
ARCHERR2=IDPROMOCION_param_${FARCH}
ARCHNAME2=$1
#ARCHSHELL=SH004_EJECUTASPEPROMO.sh
#FILELOG=$DIRLOGPOST/importaErrorPuntosPromocion_LOG_$FECHA.log

####Proceso####
# Finf file: Variables para corroborar que el archivo existe en la ruta

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
	ARCHPRMT1=${STRINGRUTA#*IDPROMOCION_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi

#Flujo corroborar archivos

if [ "$FINDFILE" = "" ] && [ "$FINDBKP" = "" ] && [ "$FINDFILE2" = "" ] ; then
	pMessage "No existe el archivo $ARCHNAME "
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Importación de Puntos por Promoción no se encuentra en la ruta."
	echo "Buen día, no se encontro el siguiente archivo $ARCHNAME en la carpeta de $DIRENTRADAPOST." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo de Importación de Puntos por Promoción no se encuentra en la ruta." $IT_MAIL 
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

pMessage "Se procede a ejecutar el SP pkg_cc_procacumula.admpsi_epromoc y exportar los datos que devuelve"

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
  cursorprompto ty_cursor;
  c_cod_cli VARCHAR2(40);
  c_nom_prom VARCHAR2(150);
  c_periodo	VARCHAR2(6);
  c_contr NUMBER;
  c_fec_reg DATE;
  c_horamin VARCHAR2(5);
  c_puntos NUMBER;
  c_cod_error char(3);
  c_msje_error varchar2(100);
  v_fecha date;
  
BEGIN
  
  dbms_output.enable(NULL);
  
   SELECT TO_DATE(${FECHAARCH},'YYYYMMDD') INTO v_fecha FROM DUAL;
   
   $PCLUB_OW.pkg_cc_procacumula.admpsi_epromoc(v_fecha,cursorprompto);
   
  LOOP
  
  fetch cursorprompto into c_cod_cli,c_nom_prom,c_periodo,c_contr,c_fec_reg,c_horamin,c_puntos,c_cod_error,c_msje_error;
  exit when cursorprompto%notfound;
  
  DBMS_OUTPUT.put_line(c_cod_cli || '|' || c_nom_prom || '|' || c_periodo || '|' || c_contr || '|' || c_fec_reg || '|' || c_horamin || '|' || c_puntos || '|' ||  c_cod_error || '|' || c_msje_error );
  
  END LOOP;
  
  CLOSE cursorprompto;
  
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
	cat ${DIRFALLOSPOST}/${FILEERR} >> $FILELOG
    pMessage "Hubo un error durante la ejeción del SP pkg_cc_procacumula.admpsi_epromoc"        
	exit
fi

pMessage "Ejecución de SP fue satisfactorio"    

#if [ "$ARCHNAME2" = "" ] ; then
#	mv ${FILERMV2} $DIRPROCPOST
	#rm ${FILERMV2}	
	#rm ${FILERMV2}
#else
	
#	mv ${ARCHNAME2} $DIRPROCPOST
#fi	  
	   
pMessage "Se finalizó el proceso de Ejecución de EPROMOC"


#---

pMessage "Se finalizó el proceso de Ejecución de PROMOCION"

#--


pMessage "Fin de todo el Proceso de Promocion"


exit
