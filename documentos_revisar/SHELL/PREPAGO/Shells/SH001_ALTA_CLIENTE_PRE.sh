#!/bin/sh -x
#*************************************************************
#Programa      :  SH001_ALTA_CLIENTE_PRE.sh
#Autor         :  Roxana Chero
#Descripcion   :  Registrar las nuevas líneas de los Clientes Prepago, en ClaroClub.     
#FECHA_HORA    :  24/06/2013
#*************************************************************

#Iniciación de Variables
# Inicializacion de Variables

. /home/usrclaroclub/CLAROCLUB/Interno/Prepago/Bin/.varset
. /home/usrclaroclub/CLAROCLUB/Interno/Prepago/Bin/.passet
. /home/usrclaroclub/CLAROCLUB/Interno/Prepago/Bin/.mailset

#-----------------------------------------------------------------
#	FUNCIÓN PARA MANEJO DEL LOG
#-----------------------------------------------------------------
pMessage () {   
   LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
   echo "($LOGDATE) $*" 
   echo "($LOGDATE) $*"  >> $FILELOG
} # pMessage	

# Rutas
HOST=`hostname`
IP_SERV=`cat /etc/hosts | grep -v '#' | grep ${HOST} | awk '{print $1}'`
#usuario
USER_SERV=`whoami`
SHELL=SH001_ALTA_CLIENTE_PRE.sh

FECHA=`date +%Y%m%d_%H%M%S`
FARCH=`date +%Y%m%d`
CONTROL=$DIRCTL/CTL001_ALTA_CLIENTE_PRE.ctl
BAD=$DIRFALLOS/CTL001_ALTA_CLIENTE_PRE_BAD_$FECHA.bad
FILELOG=$DIRLOG/SH001_ALTA_CLIENTE_PRE_$FECHA.log
CTL_LOG=$DIRLOG/CTL001_ALTA_CLIENTE_PRE_LOG_$FECHA.log
ARCHNAME=ALTA_CLIENTE_PRE_${FARCH}.CCL
ARCHPRMT2=$1
RUTANAME=$DIRDOCUMENTOS

if [ "$1" = "" ] ; then
	ARCHPRMT=""
else
	ARCHPRMT1=${1#*ALTA_CLIENTE_PRE_}
	ARCHPRMT=ALTA_CLIENTE_PRE_$ARCHPRMT1
fi

# Inicio
demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "************************************* " 
pMessage "Iniciando proceso                     " 
pMessage "Fecha y Hora : ${FECHA}               " 
pMessage "Usuario :  ${USER_SERV}               " 
pMessage "Shell : ${SHELL}                      " 
pMessage "Ip : ${IP_SERV}                       " 
pMessage "*************************************"$'\n' 

####Proceso####
# File Data: Se buscará el archivo(con su ruta) en la carpeta de Origen

if [ "$ARCHPRMT" = "" ] ; then
	FILEDATA=`find $RUTANAME/$ARCHNAME`
	CANT_DATA=`cat  $DIRDOCUMENTOS/$ARCHNAME | wc -l | sed 's/ //g'`
else
	FILEDATA=`find $ARCHPRMT2`
	CANT_DATA=`cat  $ARCHPRMT2 | wc -l | sed 's/ //g'`
fi

#Capturando nombre de archivo y la fecha del archivo

if [ "$ARCHPRMT" = "" ] ; then
	ARCHFECHA=${ARCHNAME:17:8}
	ARCHNAMEF=$ARCHNAME
else
	ARCHNAMEF=$ARCHPRMT
	ARCHFECHA=${ARCHPRMT:17:8}
fi

NOMARCH="'"${ARCHNAMEF}"'"
FECHATMP="'"${ARCHFECHA}"'"

echo "Archivo: $NOMARCH"
echo "Fecha : $FECHATMP"

if [ "$FILEDATA" = "" ] ; then
   Demora=`date +"%Y-%m-%d %H:%M:%S"`
   pMessage "Error: No se encontró el archivo de datos..."$'\n'
   pMessage "Terminó proceso" 
   pMessage "************************************" 
   pMessage " FINALIZANDO PROCESO..............." 
   pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso " 
   pMessage "************************************" 
   pMessage "No existe el archivo $ARCHNAME" 
   pMessage "A continuación se enviará un correo a $IT_OPERADOR con el asunto de El Archivo para registrar las nuevas líneas de los Clientes Prepago no se encuentra en la ruta." 
   echo "Buen día, no se encontró el siguiente archivo $ARCHNAME en la carpeta de $DIRDOCUMENTOS." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo para registrar las nuevas líneas de los Clientes Prepago no se encuentra en la ruta" $IT_OPERADOR 
   pMessage "Ruta del Archivo log : " $FILELOG
   exit -1
fi
  
if [ $CANT_DATA = 0 ] ; then
	pMessage "El archivo $ARCHNAME no tiene data. " 
	pMessage "A continuación se enviará un correo a $IT_OPERADOR con el asunto de El Archivo para registrar las nuevas líneas de los Clientes Prepago se encuentra vacío."
	echo "Buen día, el siguiente archivo $ARCHNAME , colocado en la carpeta de ORIGEN, no contiene datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "El Archivo para registrar las nuevas líneas de los Clientes Prepago se encuentra vacío" $IT_OPERADOR
	pMessage "Se envió correo. Fecha y Hora: $demora"
	exit -1
fi
	
pMessage "Se convierte el archivo de entrada al formato UNIX"
dos2unix ${FILEDATA}

TMP=$DIRLOG/TEMPDATA03.tmp
echo "" >> ${FILEDATA}
cat ${FILEDATA} | sed '/^$/d' > $TMP
cat $TMP > ${FILEDATA}
		
rm -f $TMP
	

# TEMP_FILE=TEMP01_${FECHA}.TMP
TEMP_FILE=TEMP01_${FECHA}.TMP

ARCHPRMT2=${FILEDATA#*ALTA_CLIENTE_PRE_}
ARCHPRMT3=ALTA_CLIENTE_PRE_$ARCHPRMT2

while read FIELD02
do
	echo "${FIELD02}|${ARCHPRMT2:0:8}|${ARCHPRMT3}" >> $DIRLOG/$TEMP_FILE	
done < $FILEDATA

pMessage "Se procede a importar los datos del archivo de entrada, a la tabla de alta de clientes Prepago."
sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$CONTROL data=$DIRLOG/$TEMP_FILE bad=$BAD log=$CTL_LOG bindsize=200000 readsize=200000 rows=1000 skip=0

rm -f $DIRLOG/$TEMP_FILE
        
VALIDAT_CTL=`grep 'ORA-' $CTL_LOG | wc -l`		
if [ $VALIDAT_CTL -ne 0 ] ; then
    pMessage "ERROR en la ejecución del control $CONTROL. Contacte al administrador."$'\n'
    pMessage "Verifique el log para mayor detalle $FILELOG"$'\n'
    pMessage "Terminó proceso" 
    pMessage "************************************"
    pMessage " FINALIZANDO PROCESO..............."
    pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso "
    pMessage "************************************"
    pMessage "Ruta del Archivo log : " $FILELOG
    #exit -1
fi

rm -f $CTL_LOG

if [ $VALIDAT_CTL -ne 0 ] ; then
   pMessage "El proceso de importación culminó pero con algunos errores."
else				
   pMessage "El proceso de importación culminó satisfactoriamente."
fi

cp $FILEDATA $DIRPROCESADO
echo "$ARCHPRMT"
	
if [ "$ARCHPRMT" = "" ] ; then
	ARCHPRMT=""
else		
	ARCHPRMT=${FILEDATA}
fi

#---

ARCHNAME=ALTA_CLIENTE_PRE_${FARCH}.CCL
ARCHPRMT=$1

if [ "$ARCHPRMT" = "" ] ; then
	FINDFILE=`find $DIRDOCUMENTOS/$ARCHNAME`
	CANT_DATA=`cat  $DIRDOCUMENTOS/$ARCHNAME | wc -l | sed 's/ //g'`
else
	FINDFILE=`find $ARCHPRMT`
	CANT_DATA=`cat  $ARCHPRMT | wc -l | sed 's/ //g'`
fi

#Capturando la fecha

if [ "$ARCHPRMT" = "" ] ; then
	FECHAARCH=$FARCH
else
	ARCHPRMT1=${ARCHPRMT#*ALTA_CLIENTE_PRE_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi

echo "$FECHAARCH"
FECHATMP="'"${FECHAARCH}"'"
#Flujo corroborar archivos

if [ "$FINDFILE" = "" ] ; then
   pMessage " $demora: Error: No se encontró el archivo de datos..."$'\n'
   pMessage "Termino proceso" 
   pMessage "************************************" 
   pMessage " FINALIZANDO PROCESO..............." 
   pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso " 
   pMessage "************************************" 
   pMessage "No existe el archivo $ARCHNAME" 
   pMessage "A continuación se enviará un correo a $IT_OPERADOR con el asunto de El Archivo para registrar las nuevas líneas de los Clientes Prepago no se encuentra en la ruta." 
   pMessage "Buen día, no se encontró el siguiente archivo $ARCHNAME en la carpeta de $DIRDOCUMENTOS." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo para registrar las nuevas líneas de los Clientes Prepago no se encuentra en la ruta" $IT_OPERADOR 
   pMessage "Ruta del Archivo log : " $FILELOG
   exit -1
fi

if [ $CANT_DATA = 0 ] ; then
	pMessage "El archivo $ARCHNAME no tiene data."
	pMessage "A continuación se enviará un correo a $IT_OPERADOR con el asunto de El Archivo para registrar las nuevas líneas de los Clientes Prepago se encuentra vacío."
	echo "Buen día, el siguiente archivo $ARCHNAME , colocado en la carpeta de ORIGEN, no contiene datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "El Archivo para registrar las nuevas líneas de los Clientes Prepago se encuentra vacío" $IT_OPERADOR
	exit -1
fi

pMessage "Se procede a ejecutar el SP PKG_CC_PTOSTFI.ADMPSI_REGLINEAS"

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

v_tmp			varchar2(10);
v_FECHA  		DATE;
v_CODERROR 		NUMBER;
v_DESCERROR  	VARCHAR2(200); 
v_NUMREGTOT  	NUMBER; 
v_NUMREGPRO  	NUMBER; 
v_NUMREGERR  	NUMBER;

BEGIN

SELECT TO_DATE($FECHATMP,'YYYYMMDD') INTO v_fecha FROM DUAL;	

$PCLUB_OW.PKG_CC_PTOSTFI.ADMPSI_REGLINEAS(v_fecha,$TIPO_CLI ,v_CODERROR, v_DESCERROR, v_NUMREGTOT, v_NUMREGPRO, v_NUMREGERR);
											 
dbms_output.put_line('Indicador: '||v_CODERROR);
dbms_output.put_line('Descripcion: '||v_DESCERROR);
dbms_output.put_line('Total Registros: '||v_NUMREGTOT);
dbms_output.put_line('Total Procesados: '||v_NUMREGPRO);
dbms_output.put_line('Total Errores: '||v_NUMREGERR);
 
EXCEPTION 
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
 
END;
/

EXIT
EOP
    
VALIDA_EJEC_SP=`grep 'ORA-' ${FILELOG} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B=`grep 'SP2-' ${FILELOG} | wc -l | sed 's/ //g'`

if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
    pMessage "Hubo un error durante la ejecución del SP PKG_CC_PTOSTFI.ADMPSI_REGLINEAS" 
    pMessage "A continuación se enviará un correo a $IT_OPERADOR con el asunto de Se encontraron errores en el Registro de nuevas líneas de los Clientes Prepago" 
    echo "Buen día, ocurrió un problema al ejecutar el SP PKG_CC_PTOSTFI.ADMPSI_REGLINEAS." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "Se encontraron errores en el Registro de nuevas líneas de los Clientes Prepago." $IT_OPERADOR >> $FILELOG		
    exit
fi

pMessage "Ejecución de SP fue satisfactoria."


if [ "$ARCHPRMT" = "" ] ; then
	ARCHPRMT=""
else
	ARCHPRMT=${FINDFILE}
fi
#---

ARCHNAME=ALTA_CLIENTE_PRE_${FARCH}.CCL
ARCHERR=ALTA_CLIENTE_PRE_${FECHA}
ARCHERR2=ALTA_CLIENTE_PRE_param_${FARCH}
ARCHPRMT=$1

if [ "$ARCHPRMT" = "" ] ; then
	FINDFILE=`find $DIRDOCUMENTOS/$ARCHNAME`
	FINDBKP=`find $DIRPROCESADO/$ARCHNAME`
else
	FINDFILE2=`find $ARCHPRMT`
fi

if [ "$ARCHPRMT" = "" ] ; then
	STRINGRUTA=$ARCHNAME
	FECHAARCH=$FARCH
else
	STRINGRUTA=$ARCHPRMT
	ARCHPRMT1=${STRINGRUTA#*ALTA_CLIENTE_PRE_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi
#Flujo corroborar archivos

if [ "$FINDFILE" = "" ] && [ "$FINDBKP" = "" ] && [ "$FINDFILE2" = "" ] ; then
	pMessage "Hora y Fecha: $demora"
	pMessage "No existe el archivo $ARCHNAME" 
	pMessage "A continuación se enviará un correo a $IT_OPERADOR con el asunto de El Archivo para registrar las nuevas líneas de los Clientes Prepago no se encuentra en la ruta." 
	echo "Buen día, no se encontró el siguiente archivo $ARCHNAME en la carpeta de $DIRDOCUMENTOS." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo para registrar las nuevas líneas de los Clientes Prepago no se encuentra en la ruta" $IT_OPERADOR 
	exit
fi

#Verificamos que archivo se encuentra en la carpeta de backup
	
if [ "$ARCHPRMT" != "" ] ; then
	FILEERR=${ARCHERR2}.ERR        
	FILERMV2=$ARCHPRMT            
else
	FILEERR=${ARCHERR}.err
	FILERMV=$DIRPROCESADO/$ARCHNAME
	FILERMV2=$DIRDOCUMENTOS/$ARCHNAME        
fi
	
#---

pMessage "Se procede a ejecutar el SP PKG_CC_PTOSTFI.ADMPSI_EALTACLI"

sqlplus -S $USER_BD/$CLAVE_BD@$SID_BD <<EOP  >> ${DIRERROR}/${FILEERR}
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
  c_tipo_doc VARCHAR2(20);
  c_num_doc VARCHAR2(20);
  c_nom_cli VARCHAR2(80);
  c_ape_cli VARCHAR2(80);
  c_sexo CHAR(1);
  c_est_civil VARCHAR2(20);  
  c_email VARCHAR2(80);  
  c_depa varchar2(40);
  c_prov VARCHAR2(30);  
  c_dist VARCHAR2(200);  
  c_fec_oper DATE;  
  c_nom_arch VARCHAR2(150);
  c_cod_error  CHAR(3);
  c_msje_error varchar2(400);
  v_fecha date;
  
  BEGIN
  
  dbms_output.enable(NULL);
  
   SELECT TO_DATE(${FECHAARCH},'YYYYMMDD') INTO v_fecha FROM DUAL;
   
   $PCLUB_OW.PKG_CC_PTOSTFI.ADMPSI_EALTACLI(v_fecha, $TIPO_CLI, cursoraltaclic);
   
  LOOP
  
  fetch cursoraltaclic into c_cod_cli,c_tipo_doc,c_num_doc,c_nom_cli,c_ape_cli,c_sexo,c_est_civil,c_email,c_depa,c_prov,c_dist,c_fec_oper,c_nom_arch,c_cod_error,c_msje_error;
  exit when cursoraltaclic%notfound;
  
  DBMS_OUTPUT.put_line(c_cod_cli || '|' || c_tipo_doc || '|' || c_num_doc || '|' ||c_nom_cli || '|' || c_ape_cli || '|' || c_sexo || '|' || c_est_civil || '|' || c_email || '|' || c_depa || '|' || c_prov || '|' || c_dist || '|' || c_fec_oper || '|' || c_nom_arch || '|' || c_cod_error || '|' || c_msje_error);
  
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
	
CANT_DATA=`cat ${DIRERROR}/${FILEERR} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP=`grep 'ORA-' ${DIRERROR}/${FILEERR} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B=`grep 'SP2-' ${DIRERROR}/${FILEERR} | wc -l | sed 's/ //g'`
    
if [ $CANT_DATA = 0 ] ; then
	rm ${DIRERROR}/${FILEERR}
else
	pMessage "Se ha generado el archivo ${DIRERROR}/${FILEERR}"
fi

if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
	cat ${DIRERROR}/${FILEERR} >> $FILELOG
    pMessage "Hubo un error durante la ejecución del SP PKG_CC_PTOSTFI.ADMPSI_EALTACLI"     	
	exit
fi


rm ${DIRDOCUMENTOS}/${ARCHNAME}

pMessage "Ejecución de SP fue satisfactoria."
	   	   	   
pMessage "Se finalizó el proceso de Ejecución de Registro de nuevas líneas Prepago"
exit

