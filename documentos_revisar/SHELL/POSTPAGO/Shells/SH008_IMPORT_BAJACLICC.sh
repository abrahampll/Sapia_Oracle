#! /bin/ksh
#*************************************************************
#* DESCRIPCION           : Importacion de Baja de clientes - Claro Club                                    *
#* EJECUCION             : Control-D                                                          *
#* AUTOR                 : E75818  -  Luis De la Fuente                                   *
#* FECHA                 : 26/10/2010   VERSION : v1.0                        *
#* FECHA MOD .           :                         *
#*************************************************************

#Iniciaci�n de Variables
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
CONTROL=$DIRCONTROLPOST/importaBajacliCC.ctl
BAD=$DIRBADPOST/importaBajacliCC_BAD_$FECHA.bad
FILELOG=$DIRLOGPOST/SH008_BAJACLICC_$FECHA.log
CTL_LOG=$DIRLOGPOST/CTL008_LOG_$FECHA.log
ARCHNAME=BONUS_BAJA_CLIENTES_${FARCH}.CBA
#ARCHTMP=importaBajacliCC_UP_LOG_${FECHA}.log
ARCHPRMT2=$1
RUTANAME=$DIRENTRADAPOST
#ARCHSHELL=SH008_SP_ADMPSI_BAJACLI.sh

if [ "$1" = "" ] ; then
	ARCHPRMT=""
else
	ARCHPRMT1=${1#*BONUS_BAJA_CLIENTES_}
	ARCHPRMT=BONUS_BAJA_CLIENTES_$ARCHPRMT1
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
	CANT_DATA=`cat  $DIRENTRADAPOST/$ARCHNAME | wc -l | sed 's/ //g'`
else
	FILEDATA=`find $ARCHPRMT2`
	CANT_DATA=`cat  $ARCHPRMT2 | wc -l | sed 's/ //g'`
fi

#Capturando nombre de archivo y la fecha de este

if [ "$ARCHPRMT" = "" ] ; then
	ARCHFECHA=${ARCHNAME:20:8}
	ARCHNAMEF=$ARCHNAME
else
	ARCHNAMEF=$ARCHPRMT
	ARCHFECHA=${ARCHPRMT:20:8}
fi

echo "$ARCHNAMEF"

NOMARCH="'"${ARCHNAMEF}"'"
FECHATMP="'"${ARCHFECHA}"'"

dos2unix ${FILEDATA}

TMP=$DIRLOGPOST/TEMPDATA08.tmp
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
   pMessage "A continuaci�n se enviar� un correo a $IT_MAIL con el asunto de El Archivo de baja de clientes no se encuentra en la ruta" 
   echo "Buen d�a, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $DIRENTRADAPOST." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo de Baja de clientes no se encuentra en la ruta." $IT_MAIL 
   pMessage "Ruta del Archivo log : " $FILELOG
   echo $'\n'
   exit -1
fi
   
if [ $CANT_DATA = 0 ] ; then
	pMessage "Hora y Fecha: $demora"
	pMessage "Ninguno de estos archivos tiene data $ARCHNAME" 
	pMessage "A continuaci�n se enviar� un correo a $IT_MAIL con el asunto de El Archivo de baja de clientes se encuentra vacio." 
	echo "Buen d�a, los siguientes archivos $ARCHNAME en la carpeta de ORIGEN no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "El Archivo de Baja de clientes se encuentra vacio" $IT_MAIL
	pMessage "Se envi� correo Fecha y Hora: $demora"
	exit -1
fi



TEMP_FILE=TEMP01_${FECHA}.TMP

ARCHPRMT2=${FILEDATA#*BONUS_BAJA_CLIENTES_}
ARCHPRMT3=BONUS_BAJA_CLIENTES_$ARCHPRMT2

while read FIELD02
do
	echo "${FIELD02}|${ARCHPRMT2:0:8}|${ARCHPRMT3}" >> $DIRLOGPOST/$TEMP_FILE	
done < $FILEDATA

pMessage "Se procede a importar los datos del archivo de entrada a la tabla de baja de clientes"
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

rm -f $CTL_LOG

pMessage "El proceso de importacion culmino satisfactoriamente"

cp $FILEDATA $DIRBACKUPPOST
		
if [ "$ARCHPRMT" = "" ] ; then
	ARCHPRMT=""
	#sh $DIR_POST_SHELL/$ARCHSHELL
else
	ARCHPRMT=${FILEDATA}
	#sh $DIR_POST_SHELL/$ARCHSHELL ${FILEDATA}
fi

#---

#ARCHPRMT=$1
ARCHNAME=BONUS_BAJA_CLIENTES_${FARCH}.CBA
#ARCHTMP=importaBajacliCC_SP_LOG_${FECHA}.log
#ARCHSHELL=SH008_SP_ADMPSI_EBAJACLI.sh
#FILELOG=$DIRLOGPOST/importaBajacliCC_LOG_$FECHA.log

####Proceso####
# Finf file: Variables para corroborar que el archivo existe en la ruta

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
ARCHPRMT1=${ARCHPRMT#*BONUS_BAJA_CLIENTES_}
FECHAARCH=${ARCHPRMT1:0:8}
fi
echo "$FECHAARCH"
FECHATMP="'"${FECHAARCH}"'"
#Flujo corroborar archivos

if [ "$FINDFILE" = "" ] ; then
   pMessage " $demora: Error: No se encontro el archivo de datos..."$'\n'
   pMessage "Termino proceso"
   pMessage "************************************" 
   pMessage " FINALIZANDO PROCESO..............." 
   pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso " 
   pMessage "************************************" 
   pMessage "No existe ninguno de estos archivos $ARCHNAME" 
   pMessage "A continuaci�n se enviar� un correo a $IT_MAIL con el asunto de El Archivo de Baja de clientes no se encuentra en la ruta" 
   echo "Buen d�a, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $DIRENTRADAPOST." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo de Baja de clientes no se encuentra en la ruta." $IT_MAIL 
   pMessage "Ruta del Archivo log : " $FILELOG
   echo $'\n'
   exit -1
fi
   
if [ $CANT_DATA = 0 ] ; then
	pMessage "Hora y Fecha: $demora"
	pMessage "Ninguno de estos archivos tiene data $ARCHNAME" 
	pMessage "A continuaci�n se enviar� un correo a $IT_MAIL con el asunto de El Archivo de Baja de clientes se encuentra vacio." 
	echo "Buen d�a, los siguientes archivos $ARCHNAME en la carpeta de ORIGEN no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "El Archivo de Baja de clientes se encuentra vacio" $IT_MAIL
	pMessage "Se envi� correo Fecha y Hora: $demora"
	exit -1
fi

pMessage "Se ejecuta el SP pkg_cc_procacumula.admpsi_bajaclic"
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
		$PCLUB_OW.pkg_cc_procacumula.admpsi_bajaclic(v_fecha,k_coderror,
						k_descerror,
						k_numregtot,
						k_numregpro,
						k_numregerr);
	end;
		
	dbms_output.put_line('Codigo de error: ' || k_coderror || '|Mensaje de error: ' || k_descerror || '|N� total de registros: ' || k_numregtot || '|N� de registros procesados: ' || k_numregpro || '|N� de registros con errores: ' || k_numregerr);
		
 END;
	
/
exit
EOP

VALIDA_EJEC_SP=`grep 'ORA-' ${FILELOG} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B=`grep 'SP2-' ${FILELOG} | wc -l | sed 's/ //g'`

if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
    pMessage "Hora y Fecha: $demora"
    pMessage "Hubo un error durante la ejeci�n del SP pkg_cc_procacumula.admpsi_bajaclic" 
    pMessage "A continuaci�n se enviar� un correo a $IT_MAIL con el asunto de IMPORTACION DE Baja de clientes � Se encontraron errores" 
    echo "Buen d�a, ocurrio un problema al ejecutar el SP de pkg_cc_procacumula.admpsi_bajaclic." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "IMPORTACION DE Baja de clientes � Se encontraron errores" $IT_MAIL 		
    pMessage "Se envi� correo Fecha y Hora: $demora"    
	exit
fi
    
pMessage "Ejecuci�n de SP fue satisfactorio"

if [ "$ARCHPRMT" = "" ] ; then
	ARCHPRMT=""
	#sh $DIR_POST_SHELL/$ARCHSHELL
else
	ARCHPRMT=${FINDFILE}
	#sh $DIR_POST_SHELL/$ARCHSHELL ${FINDFILE}
fi
	
#---

ARCHNAME=BONUS_BAJA_CLIENTES_${FARCH}.CBA
ARCHERR=BONUS_BAJA_CLIENTES_${FARCH}
ARCHERR2=BONUS_BAJA_CLIENTES_param_${FARCH}
ARCHPRMT=$1
#ARCHSHELL=SH008_EJECUTASPEBAJACLI.sh
#FILELOG=$DIRLOGPOST/importaRentcontCC_LOG_$FECHA.log

####Proceso####
# Finf file: Variables para corroborar que el archivo existe en la ruta

if [ "$ARCHPRMT" = "" ] ; then
	FINDFILE=`find $DIRENTRADAPOST/$ARCHNAME`
	FINDBKP=`find $DIRBACKUPPOST/$ARCHNAME`
else
	FINDFILE2=`find $ARCHPRMT`
fi

if [ "$ARCHPRMT" = "" ] ; then
	FECHAARCH=$FARCH
else
	ARCHPRMT1=${ARCHPRMT#*BONUS_BAJA_CLIENTES_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi

#Flujo corroborar archivos

if [ "$FINDFILE" = "" ] && [ "$FINDBKP" = "" ] && [ "$FINDFILE2" = "" ] ; then
	pMessage "Hora y Fecha: $demora"
	pMessage "No existe ninguno de estos archivos $ARCHNAME" 
	pMessage "A continuaci�n se enviar� un correo a $IT_MAIL con el asunto de El Archivo de Baja de clientes no se encuentra en la ruta" 
	echo "Buen d�a, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $DIRORIGEN." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo de Baja de clientes no se encuentra en la ruta." $IT_MAIL 
	pMessage "Se envi� correo Fecha y Hora: $demora"
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

#Ejecucion del shell 

#sh $DIR_POST_SHELL/$ARCHSHELL ${DIRFALLOSPOST}/${FILEERR} ${FECHAARCH}

#---
pMessage "Se ejecuta el SP pkg_cc_procacumula.admpsi_ebajaclic y se exportan los datos obtenidos"
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
  cursorbajcli ty_cursor;  
  c_cod_cli VARCHAR2(40);  
  c_fec_baj DATE;    
  c_cod_error  CHAR(3);
  c_msje_error varchar2(400);
  v_fecha date;
  
  BEGIN
  
  dbms_output.enable(NULL);
  
   SELECT TO_DATE('${FECHAARCH}','YYYYMMDD') INTO v_fecha FROM DUAL;
   
    $PCLUB_OW.pkg_cc_procacumula.admpsi_ebajaclic(v_fecha,cursorbajcli);
   
  LOOP
  
  fetch cursorbajcli into c_cod_cli,c_fec_baj,c_cod_error,c_msje_error;
  exit when cursorbajcli%notfound;
  
  DBMS_OUTPUT.put_line(c_cod_cli || '|' || c_fec_baj || '|' ||  c_cod_error || '|' || c_msje_error||'\n');
  
  END LOOP;
  
  CLOSE cursorbajcli;
  
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
    pMessage "Hora y Fecha: $demora"
    pMessage "Hubo un error durante la ejeci�n del SP pkg_cc_procacumula.admpsi_ebajaclic"        
	exit
fi
       
pMessage "Ejecuci�n de SP fue satisfactorio"
	   	   
#if [ "$ARCHPRMT" = "" ] ; then
#   mv ${FILERMV2} $DIRPROCPOST
#else
#   mv ${ARCHPRMT} $DIRPROCPOST
#fi	  
	   
#---

pMessage "Se finaliz� el proceso de Ejecuci�n de Baja de clientes" 


#---

pMessage "Fin de todo el Proceso de Migracion de Baja de clientes"

exit
