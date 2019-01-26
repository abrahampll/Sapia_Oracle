#! /bin/ksh
#*************************************************************
#* DESCRIPCION           : Importacion de Pagos - Claro Club HFC *
#* EJECUCION             :                                       *
#* AUTOR                 : E77210: JCGutierrezT                  *
#* FECHA                 : 15/05/2012   VERSION : v1.0           *
#* FECHA MOD .           :                                       *
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
CONTROL=$DIRCONTROLHFC/importaPagoHFC.ctl
BAD=$DIRFALLOSHFC/importaPago_BAD_$FECHA.bad
FILELOG=$DIRLOGHFC/SH001_PROC_PAGOS_$FECHA.log
CTL_LOG=$DIRLOGHFC/CTL001_LOG_$FECHA.log
ARCHNAME=BONUS_PAGOS_$FARCH.CAC
ARCHPRMT2=$1
RUTANAME=$DIR_ENT_PAGOS


if [ "$1" = "" ] ; then
	ARCHPRMT=""
else
	ARCHPRMT1=${1#*BONUS_PAGOS_}
	ARCHPRMT=BONUS_PAGOS_$ARCHPRMT1
	ARCHNAME=$ARCHPRMT2
fi


# Inicio
demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "*************************************" 
pMessage "Iniciando proceso de Importación              " 
pMessage "Fecha y Hora : $demora               " 
pMessage "*************************************" 

####Proceso####
####PROCESO SGA#####
pMessage "Se ejecuta el SP PARA LA CREACION DEL ARCHIVO PAGOS"
sqlplus -s $USER_BD_SGA/$CLAVE_BD_SGA@$SID_BD_SGA <<EOP  >> ${RUTANAME}/${ARCHNAME}
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
TYPE gc_salida IS REF CURSOR;
TYPE DET IS RECORD
(COD_CLI VARCHAR2(40),
 PERIODO VARCHAR2(6),
 DIAS number,
 MONTO number);
LINEA  DET;
listacursor gc_salida;  
fecha        date;
resultado    NUMBER;
mensaje      VARCHAR2(5000);
       
BEGIN 


select sysdate-1 into fecha
from dual;
  
$PCLUB_SGA.pq_canje_premio.p_reg_pagos_hfc(fecha,resultado,mensaje);  
IF resultado = -1 then
   DBMS_OUTPUT.PUT_LINE('ORA1-'||mensaje);  
END IF;
                       
$PCLUB_SGA.pq_canje_premio.p_obt_pagos_hfc(fecha,listacursor,resultado,mensaje);
IF resultado = -1 then
   DBMS_OUTPUT.PUT_LINE('ORA2-'||mensaje);  
END IF;

  LOOP  
  FETCH listacursor INTO LINEA;
  EXIT WHEN listacursor%NOTFOUND;  
  DBMS_OUTPUT.PUT_LINE(LINEA.COD_CLI||'|'||LINEA.PERIODO||'|'||LINEA.DIAS||'|'||LINEA.MONTO);  
  END LOOP;
  
  CLOSE listacursor;
EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
        
END;
/
exit
EOP

VALIDA_EJEC_SP=`grep 'ORA-' ${RUTANAME}/${ARCHNAME} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B=`grep 'SP2-' ${RUTANAME}/${ARCHNAME} | wc -l | sed 's/ //g'`
VALIDA_ADV_SP=`find ${RUTANAME}/${ARCHNAME}`

if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
    pMessage "Hubo un error durante la ejecución del SP pq_canje_premio.p_obt_pagos_hfc" 
    pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de CC HFC - ARCHIVO SGA – Se encontraron errores" 
    echo "Buen día, ocurrio un problema al ejecutar el SP de SGA." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "CC HFC - ARCHIVO SGA – Se encontraron errores" $IT_MAIL 		
    pMessage "Se envió correo Fecha y Hora: $demora"    
	exit
fi

if [ "$VALIDA_ADV_SP" = "" ] ; then
    pMessage "Termino la ejecución del SP PKG_SIAC. Pero no hay datos procesados por SGA " 
    pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de CC HFC - ARCHIVO SIAC " 
    echo "No existen datos al ejecutar el SP ATCCORP.pq_canje_premio.p_obt_pagos_hfc." $' \n' "Favor de verificar este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "CC HFC - ARCHIVO SGA– ADVERTENCIA" $IT_MAIL 		
    pMessage "Se envió correo Fecha y Hora: $demora"    
	exit
fi

####PROCESO SGA#####

pMessage "Termino el proceso de generacion de archivo ${RUTANAME}/${ARCHNAME}"

# File Data: Se buscara el archivo(con su ruta) ya sea ingresado desde el programa o buscarlo en la carpeta de Origen

if [ "$ARCHPRMT" = "" ] ; then
	FILEDATA=`find $RUTANAME/$ARCHNAME`
	CANT_DATA=`cat  $RUTANAME/$ARCHNAME | wc -l | sed 's/ //g'`
else
	FILEDATA=`find $ARCHPRMT2`
	CANT_DATA=`cat  $ARCHPRMT2 | wc -l | sed 's/ //g'`
fi

if [ "$FILEDATA" = "" ] ; then
   demora=`date +"%Y-%m-%d %H:%M:%S"`
   pMessage " $demora: Error: No se encontro el archivo de datos..." 
   pMessage "Termino proceso"
   pMessage "************************************" 
   pMessage " FINALIZANDO PROCESO..............." 
   pMessage "************************************" 
   pMessage "No existe ninguno el archivo $ARCHNAME" 
   pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de pagos no se encuentra en la ruta" 
   echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo de pagos no se encuentra en la ruta." $IT_MAIL 
   pMessage "Ruta del Archivo log : " $FILELOG
   echo $'\n'
   exit -1
fi

if [ $CANT_DATA = 0 ] ; then
	pMessage "Hora y Fecha: $demora"
	pMessage "Ningún  archivo tiene data $ARCHNAME" 
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de pagos se encuentra vacio." 
	echo "Buen día, los siguientes archivos $ARCHNAME en la carpeta de ORIGEN no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "El Archivo de pagos se encuentra vacio" $IT_MAIL
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

TEMP_FILE=TEMP01_${FECHA}.TMP

ARCHPRMT2=${FILEDATA#*BONUS_PAGOS_}
ARCHPRMT3=BONUS_PAGOS_$ARCHPRMT2

while read FIELD02
do
	echo "${FIELD02}|${ARCHPRMT2:0:8}|${ARCHPRMT3}" >> $DIRLOGHFC/$TEMP_FILE	
done < $FILEDATA

pMessage "Se procede a importar los datos del archivo de entrada a la tabla de pagos"
sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$CONTROL data=$DIRLOGHFC/$TEMP_FILE bad=$BAD log=$CTL_LOG bindsize=200000 readsize=200000 rows=1000 skip=0

rm -f $DIRLOGHFC/$TEMP_FILE

VALIDAT_CTL=`grep 'ORA-' $CTL_LOG | wc -l`
		
if [ $VALIDAT_CTL -ne 0 ] ;
    then
    pMessage "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n'
    pMessage "Verifique el log para mayor detalle $CTL_LOG"$'\n'
    pMessage "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n' 
	echo "Buen día, ocurrio un error al momento de importar los datos a la tabla de pagos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "HFC - PAGOS : Error al importar datos" $IT_MAIL
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
	

cp $FILEDATA $DIR_PROC_PAGOS		


#Capturando la fecha
if [ "$ARCHPRMT" = "" ] ; then
	FECHAARCH=$FARCH
else
	ARCHPRMT1=${ARCHPRMT#*BONUS_PAGOS_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi

FECHATMP="'"${FECHAARCH}"'"
#Flujo corroborar archivos


pMessage "Se ejecuta el SP PKG_DTH_PREPAGO.ADMPSI_FACTURAHFC"
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

	$PCLUB_OW.PKG_CC_PTOSFIJA.ADMPSI_FACTURAHFC(v_fecha,'USRFACHFC',k_coderror,
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
    pMessage "FINALIZANDO PROCESO..............."
    pMessage "Hubo un error durante la ejeción del SP PKG_CC_PTOSFIJA.ADMPSI_FACTURAHFC" 
    pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de IMPORTACION DE PAGOS – Se encontraron errores" 
    echo "Buen día, ocurrio un problema al ejecutar el SP de PKG_CC_PTOSFIJA.ADMPSI_FACTURAHFC." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "HFC - IMPORTACION DE PAGOS." $IT_MAIL 		
    pMessage "Se envió correo Fecha y Hora: $demora"    
	exit
fi

pMessage "Ejecución de SP fue satisfactorio"


ARCHNAME=BONUS_PAGOS_${FARCH}.CAC
ARCHERR=BONUS_PAGOS_${FARCH}
ARCHERR2=BONUS_PAGOS_param_${FARCH}
ARCHPRMT=$1


####Proceso####
# Finf file: Variables para corroborar que el archivo existe en la ruta

if [ "$ARCHPRMT" = "" ] ; then
	FINDFILE=`find $RUTANAME/$ARCHNAME`
	FINDBKP=`find $DIR_PROC_PAGOS/$ARCHNAME`
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
	pMessage "FINALIZANDO PROCESO..............."
	pMessage "No existe ninguno de estos archivos $ARCHNAME" 
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de pagos no se encuentra en la ruta" 
	echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "HFC - PAGOS: El Archivo de pagos no se encuentra en la ruta." $IT_MAIL 
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


rm -f ${DIR_ERR_PAGOS}/${FILEERR}

pMessage "Se ejecuta el SP PKG_CC_PTOSFIJA.ADMPSI_EFACTURAHFC y se exporta los datos obtenidos"
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
  c_periodo VARCHAR2(6);
  c_diasvenc NUMBER;
  c_mntint NUMBER;
  c_cod_error varchar2(3);
  c_msje_error varchar2(400);
  v_fecha date;
  
  BEGIN
  
  dbms_output.enable(NULL);
  
   SELECT TO_DATE('${FECHAARCH}','YYYYMMDD') INTO v_fecha FROM DUAL;
   
    $PCLUB_OW.PKG_CC_PTOSFIJA.ADMPSI_EFACTURAHFC(v_fecha,cursorpago);
   
  LOOP
  
  fetch cursorpago into c_cod_cli,c_periodo,c_diasvenc,c_mntint,c_cod_error,c_msje_error;
  exit when cursorpago%notfound;
  
  DBMS_OUTPUT.put_line(c_cod_cli || '|' || c_periodo || '|' || c_diasvenc || '|'  || c_mntint || '|' || c_cod_error || '|' || c_msje_error);
  
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
	#rm -f ${DIR_ERR_PAGOS}/${FILEERR}
else
	pMessage "Se ha generado el archivo ${DIRFALLOSHFC}/${FILEERR}"
fi
    
if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
	cat  ${DIR_ERR_PAGOS}/${FILEERR} >>  $FILELOG
    pMessage "FINALIZANDO PROCESO..............."
    pMessage "Hubo un error durante la ejeción del SP PKG_CC_PTOSFIJA.ADMPSI_EFACTURAHFC"  
	echo "Buen día, Hubo un error durante la ejeción del SP PKG_CC_PTOSFIJA.ADMPSI_EFACTURAHFC." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "HFC: Importacion de Pagos." $IT_MAIL 
	exit
else
	if [ $CANT_DATA != 0 ] ; then
		pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de Errores en el registro de clientes" 
		echo "Buen día, se encontraron $CANT_DATA errores. Revisar la ruta ${DIR_ERR_PAGOS}/${FILEERR} ." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "HFC: Errores en la facturacion de clientes." $IT_MAIL 	
		exit
	fi	
fi

pMessage "Ejecución de SP admpss_epago fue satisfactorio"

pMessage "Se finalizó el proceso de Ejecución de EPAGO"

pMessage "Se finalizó el proceso de Ejecución de PAGOS"

pMessage "Fin de todo el Proceso de Migracion de Pagos"

exit
