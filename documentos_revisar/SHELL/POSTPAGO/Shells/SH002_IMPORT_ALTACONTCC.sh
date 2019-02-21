#! /bin/ksh
#*************************************************************
#* DESCRIPCION           : Importacion de Alta de Contratos - Claro Club                                    *
#* EJECUCION             : Control-D                                                          *
#* AUTOR                 : E75818  -  Luis De la Fuente                                   *
#* FECHA                 : 26/10/2010   VERSION : v1.0                        *
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
CONTROL=$DIRCONTROLPOST/importaAltacontCC.ctl
BAD=$DIRBADPOST/importaAltacontCC_BAD_$FECHA.bad
FILELOG=$DIRLOGPOST/SH002_ALTACONTCC_$FECHA.log
CTL_LOG=$DIRLOGPOST/CTL002_LOG_$FECHA.log
ARCHNAME=BONUS_ALTA_CONTRATOS_${FARCH}.CAL
contadorTotal=0
contadorOk=0
contadorError=0
#ARCHTMP=importaAltacontCC_UP_LOG_${FECHA}.log
ARCHPRMT2=$1
RUTANAME=$DIRENTRADAPOST
#ARCHSHELL=SH002_SP_ADMPSI_ALTACONT.sh


if [ "$1" = "" ] ; then
	ARCHPRMT=""
else
	ARCHPRMT1=${1#*BONUS_ALTA_CONTRATOS_}
	ARCHPRMT=BONUS_ALTA_CONTRATOS_$ARCHPRMT1
fi

# Inicio
demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "*************************************" 
pMessage "Iniciando proceso de Importación              " 
pMessage "Fecha y Hora : $demora               " 
pMessage "*************************************" 
pMessage $'\n'"Iniciando proceso ....$demora"$'\n'
pMessage "procesando..."

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

pMessage "Se obtiene el nombre del archivo y la fecha que contiene"
if [ "$ARCHPRMT" = "" ] ; then
	ARCHFECHA=${ARCHNAME:21:8}
	ARCHNAMEF=$ARCHNAME
else
	ARCHNAMEF=$ARCHPRMT
	ARCHFECHA=${ARCHPRMT:21:8}
fi

FECHATMP="'"${ARCHFECHA}"'"



if [ "$FILEDATA" = "" ] ; then
   Demora=`date +"%Y-%m-%d %H:%M:%S"`
   echo " $demora: Error: No se encontro el archivo de datos..."$'\n'
   echo " $demora: Error: No se encontro el archivo de datos..."
   pMessage "Termino proceso"
   pMessage "************************************" 
   pMessage " FINALIZANDO PROCESO..............." 
   pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso " 
   pMessage "************************************" 
   pMessage "No existe ninguno de estos archivos $ARCHNAME" 
   pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Alta de contratos no se encuentra en la ruta" 
   echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $DIRENTRADAPOST." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo de Alta de Contratos no se encuentra en la ruta." $IT_MAIL 
   echo "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso"$'\n'
   echo $'\n'
   pMessage "Ruta del Archivo log : " $FILELOG
   echo $'\n'
   exit -1
fi

if [ $CANT_DATA = 0 ] ; then
	pMessage "Ninguno de estos archivos tiene data $ARCHNAME" 
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Alta de contratos se encuentra vacio."
	echo "Buen día, los siguientes archivos $ARCHNAME en la carpeta de ORIGEN no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "El Archivo de Alta de Contratos se encuentra vacio" $IT_MAIL
	exit -1
fi

pMessage "se convierte el archivo a formato UNIX"
dos2unix ${FILEDATA}

TMP=$DIRLOGPOST/TEMPDATA02.tmp
echo "" >> ${FILEDATA}
cat ${FILEDATA} | sed '/^$/d' > $TMP
cat $TMP > ${FILEDATA}
		
rm -f $TMP
	
TEMP_FILE=TEMP01_${FECHA}.TMP

ARCHPRMT2=${FILEDATA#*BONUS_ALTA_CONTRATOS_}
ARCHPRMT3=BONUS_ALTA_CONTRATOS_$ARCHPRMT2

while read FIELD02
do
	echo "${FIELD02}|${ARCHPRMT2:0:8}|${ARCHPRMT3}" >> $DIRLOGPOST/$TEMP_FILE	
done < $FILEDATA

pMessage "Se procede a importar los datos del archivo de entrada a la tabla de alta de contratos"
sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$CONTROL data=$DIRLOGPOST/$TEMP_FILE bad=$BAD log=$CTL_LOG bindsize=200000 readsize=200000 rows=1000 skip=0

rm -f $DIRLOGPOST/$TEMP_FILE
	
VALIDAT_CTL=`grep 'ORA-' $CTL_LOG | wc -l`
		
if [ $VALIDAT_CTL -ne 0 ]
then
    pMessage "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n'
    pMessage "FECHA $Demora - Verifique el log para mayor detalle $FILELOG"$'\n'
    pMessage "Termino proceso"
    pMessage "************************************" 
    pMessage " FINALIZANDO PROCESO..............." 
    pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso " 
    pMessage "************************************" 
    pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso"$'\n'
    pMessage $'\n'
    pMessage "Ruta del Archivo log : " $FILELOG
	exit -1
fi

pMessage "El proceso de importacion culmino satisfactoriamente"
rm -f $CTL_LOG

Demora=`date +"%Y-%m-%d %H:%M:%S"`
pMessage "$Demora: Termino de Cargar los Registros a la tabla de Alta de contratos... " 	
cp $FILEDATA $DIRBACKUPPOST
echo "$ARCHPRMT"
		
if [ "$ARCHPRMT" = "" ] ; then
	ARCHPRMT=""
	#sh $DIR_POST_SHELL/$ARCHSHELL
else		
	ARCHPRMT=${FILEDATA}	
fi


ARCHNAME=BONUS_ALTA_CONTRATOS_${FARCH}.CAL
ARCHPRMT=$1


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
	ARCHPRMT1=${ARCHPRMT#*BONUS_ALTA_CONTRATOS_}
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
   pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Alta de contratos no se encuentra en la ruta" 
   echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $DIRENTRADAPOST." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo de Alta de contratos no se encuentra en la ruta." $IT_MAIL 
   echo "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso"$'\n'
   echo $'\n'
   pMessage "Ruta del Archivo log : " $FILELOG
   echo $'\n'
   exit -1
fi

if [ $CANT_DATA = 0 ] ; then
	pMessage "Ninguno de estos archivos tiene data $ARCHNAME" 
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Alta de contratos se encuentra vacio." 
	echo "Buen día, los siguientes archivos $ARCHNAME en la carpeta de ORIGEN no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "El Archivo de Alta de contratos se encuentra vacio" $IT_MAIL
	exit -1
fi

pMessage "Se procede a ejecutar el Sp pkg_cc_procacumula.admpsi_altacont"
sqlplus -s $USER_BD/$CLAVE_BD@$SID_BD <<EOF  >> ${FILELOG}
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
		$PCLUB_OW.pkg_cc_procacumula.admpsi_altacont(v_fecha,k_coderror,
						k_descerror,
						k_numregtot,
						k_numregpro,
						k_numregerr);
	end;
		
	dbms_output.put_line('Codigo de error: ' || k_coderror || '|Mensaje de error: ' || k_descerror || '|Nº total de registros: ' || k_numregtot || '|Nº de registros procesados: ' || k_numregpro || '|Nº de registros con errores: ' || k_numregerr);
		
END;
	
/
exit
EOF

VALIDA_EJEC_SP=`grep 'ORA-' ${FILELOG} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B=`grep 'SP2-' ${FILELOG} | wc -l | sed 's/ //g'`

if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
    pMessage "Hubo un error durante la ejeción del SP pkg_cc_procacumula.admpsi_altacont"
    pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de IMPORTACION DE ALTA DE CONTRATOS – Se encontraron errores" 
    echo "Buen día, ocurrio un problema al ejecutar el SP de pkg_cc_procacumula.admpsi_altacontc." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "IMPORTACION DE ALTA DE CONTRATOS – Se encontraron errores" $IT_MAIL >> $FILELOG		
	exit
fi
pMessage "Ejecución de SP fue satisfactorio"
	
if [ "$ARCHPRMT" = "" ] ; then
	ARCHPRMT=""
	#sh $DIR_POST_SHELL/$ARCHSHELL
else
	ARCHPRMT=${FINDFILE}
	#sh $DIR_POST_SHELL/$ARCHSHELL ${FINDFILE}
fi

#---

ARCHNAME=BONUS_ALTA_CONTRATOS_${FARCH}.CAL
ARCHERR=BONUS_ALTA_CONTRATOS_${FARCH}
ARCHERR2=BONUS_ALTA_CONTRATOS_param_${FARCH}
ARCHPRMT=$1

####Proceso####
# Finf file: Variables para corroborar que el archivo existe en la ruta

if [ "$ARCHPRMT" = "" ] ; then
FINDFILE=`find $DIRENTRADAPOST/$ARCHNAME`
FINDBKP=`find $DIRBACKUPPOST/$ARCHNAME`
else
FINDFILE2=`find $ARCHPRMT`
fi

if [ "$ARCHPRMT" = "" ] ; then
STRINGRUTA=$ARCHNAME
FECHAARCH=$FARCH
else
STRINGRUTA=$ARCHPRMT
ARCHPRMT1=${STRINGRUTA#*BONUS_ALTA_CONTRATOS_}
FECHAARCH=${ARCHPRMT1:0:8}
fi

#Flujo corroborar archivos

if [ "$FINDFILE" = "" ] && [ "$FINDBKP" = "" ] && [ "$FINDFILE2" = "" ] ; then
	echo "Hora y Fecha: $demora"
	echo "No existe ninguno de estos archivos $ARCHNAME" 
	echo "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Alta de contratos no se encuentra en la ruta" 
	echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $DIRENTRADAPOST." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo de Alta de contratos no se encuentra en la ruta." $IT_MAIL 
	echo "Se envió correo Fecha y Hora: $demora"
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
pMessage "Se procede exportar los datos obetenidos del SP pkg_cc_procacumula.admpsi_ealtacont"
sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOF >> ${DIRFALLOSPOST}/${FILEERR}
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
  cursoraltacont ty_cursor;	   
  c_cod_cli VARCHAR2(40);
  c_cod_contr NUMBER;
  c_fch_act DATE;
  c_nom_camp VARCHAR2(200);
  c_plntarif VARCHAR2(50);
  c_vigacue VARCHAR2(100);  
  c_cod_error varchar2(3);
  c_msje_error varchar2(400);
  v_fecha date;
  
  BEGIN
  
  dbms_output.enable(NULL);
  
   SELECT TO_DATE(${FECHAARCH},'YYYYMMDD') INTO v_fecha FROM DUAL;
   
    $PCLUB_OW.pkg_cc_procacumula.admpsi_ealtacont(v_fecha,cursoraltacont);
   
  LOOP
  
  fetch cursoraltacont into c_cod_cli,c_cod_contr,c_fch_act,c_nom_camp,c_plntarif,c_vigacue,c_cod_error,c_msje_error;
  exit when cursoraltacont%notfound;
  
  DBMS_OUTPUT.put_line(c_cod_cli || '|' || c_cod_contr || '|' || c_fch_act || '|' ||c_nom_camp || '|' || c_plntarif || '|' || c_vigacue || '|' ||  c_cod_error || '|' || c_msje_error||'\n');
  
  END LOOP;
  
  CLOSE cursoraltacont;
  
  EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
  END;
/

EXIT
EOF

#---
	
CANT_DATA2=`cat ${DIRFALLOSPOST}/${FILEERR} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP2=`grep 'ORA-' ${DIRFALLOSPOST}/${FILEERR} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B2=`grep 'SP2-' ${DIRFALLOSPOST}/${FILEERR} | wc -l | sed 's/ //g'`
    
if [ $CANT_DATA2 = 0 ] ; then
	pMessage "El proceso no trajo errores en ${DIRFALLOSPOST}/${FILEERR}, asi que no se podra generar en la carpeta Fallos"
	rm ${DIRFALLOSPOST}/${FILEERR}
	pMessage "Ruta del Archivo log : " $FILELOG
else
	pMessage "Se ha generado el archivo ${DIRFALLOSPOST}/${FILEERR}"
fi

if [ ${VALIDA_EJEC_SP2} -ne 0 ] || [ ${VALIDA_EJEC_SP_B2} -ne 0 ] ; then
	cat ${DIRFALLOSPOST}/${FILEERR} >> ${FILELOG}
    pMessage "Hubo un error durante la ejeción del SP pkg_cc_procacumula.admpsi_ealtacontc"    
	exit
fi

pMessage "Ejecución de SP admpsi_ealtacont fue satisfactorio"

ARCHCC=$RUTANAME/cctelefonos_$FECHA.txt

sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOF >> ${ARCHCC}
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
 
 declare
k_estado char(1);
k_flag char(1);
k_resultado number;
k_desresultado varchar2(10);
k_proceso varchar2(100);
type ty_cursor is ref cursor;
CURSORTELEFONOS ty_cursor;
v_telefonos varchar2(800);
 begin
  k_estado:='R';
  k_flag:='1';
  k_proceso:='ALTA DE CONTRATO';
   $PCLUB_OW.pkg_cc_envio_sms.admpss_obtener_telefonos(k_proceso,k_estado,
                                            k_flag,
                                            k_resultado,
                                            k_desresultado,
                                            CURSORTELEFONOS);
											  

LOOP
  
  fetch CURSORTELEFONOS into v_telefonos;
  exit when CURSORTELEFONOS%notfound;
  
  DBMS_OUTPUT.put_line(v_telefonos);
  
  END LOOP;
  
  CLOSE CURSORTELEFONOS;
  
  EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
end;
/
exit 
 
EOF

CANT_DATA7=`cat ${ARCHCC} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP7=`grep 'ORA-' ${ARCHCC} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B7=`grep 'SP2-' ${ARCHCC} | wc -l | sed 's/ //g'`

if [ $CANT_DATA7 = 0 ] ; then
	pMessage "El archivo $ARCHCC esta vacio, no existen datos para procesar"
    pMessage "Ruta del Archivo log : " $FILELOG	
    exit	
fi

if [ ${VALIDA_EJEC_SP7} -ne 0 ] || [ ${VALIDA_EJEC_SP_B7} -ne 0 ] ; then	
    pMessage "Hubo un error al querer obtener los telefonos"     
	pMessage "Ruta del Archivo log : " $FILELOG	
	exit
fi

pMessage "Cantidad de telefonos a procesar: $CANT_DATA7"

while read FIELD01
do
TELEFONO=`echo $FIELD01 | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}' `

CLFYARCH=$RUTANAME/clfyarch_$FECHA.txt


sqlplus -S ${USER_BD_CLFY}/${CLAVE_BD_CLFY}@${SID_BD_CLFY} <<EOP >> ${CLFYARCH}
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
p_phone varchar2(40);
p_tipo varchar2(40);
p_clase varchar2(40);
p_subclase varchar2(40);
p_metodo_contacto varchar2(40);
p_tipo_inter varchar2(40);
p_agente varchar2(40);
p_usr_proceso  varchar2(40);
p_notas varchar2(500);
p_resultado varchar2(40);
id_interaccion varchar2(40);
flag_creacion varchar2(40);
msg_text varchar2(800);

BEGIN

p_phone := '${TELEFONO}';
p_tipo := '$TIPOINT';
p_clase := '$CLASEINT';
p_subclase := '$SBCLASEINT';
p_agente := '$PUSERINT';
p_usr_proceso := '$PUSERINT';
p_metodo_contacto := 'Teléfono';
p_resultado := 'Ninguno';
p_notas := '$NOTASINT';
p_tipo_inter := 'Entrante';

  BEGIN
  $CLFY_OW.pck_interact_clfy.sp_create_interact('',
                                       '',
                                       '',
                                       p_phone,
                                       p_tipo,
                                       p_clase,
                                       p_subclase,
                                       p_metodo_contacto,
                                       p_tipo_inter,
                                       p_agente,
                                       p_usr_proceso,
                                       0,
                                       p_notas,
                                       '0',
                                       p_resultado,
                                       id_interaccion,
                                       flag_creacion,
                                       msg_text);
                                       END;
									   
dbms_output.put_line(id_interaccion || '|' || flag_creacion || '|' || msg_text);

EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);

END;
/
exit
EOP

CANT_DATA8=`cat ${CLFYARCH} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP8=`grep 'ORA-' ${CLFYARCH} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B8=`grep 'SP2-' ${CLFYARCH} | wc -l | sed 's/ //g'`

if [ $CANT_DATA8 = 0 ] ; then
	pMessage "El archivo $CLFYARCH esta vacio, no existen datos para procesar"
    pMessage "Ruta del Archivo log : " $FILELOG		
fi

if [ ${VALIDA_EJEC_SP8} -ne 0 ] || [ ${VALIDA_EJEC_SP_B8} -ne 0 ] ; then	
    pMessage "Hubo un error al querer insertar una interacción para el telefono $TELEFONOFINAL"    
	pMessage "Ruta del Archivo log : " $FILELOG	
	exit
fi

pMessage "Cantidad de registros en ${CLFYARCH}: $CANT_DATA8"

while read FIELD06
do
INTERACTID=`echo $FIELD06 | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}' `
FLAGINT=`echo $FIELD06 | awk 'BEGIN{FS="|"} {print $2}' `
MSGTEXT=`echo $FIELD06 | awk 'BEGIN{FS="|"} {print $3}' `
done < $CLFYARCH
pMessage "Se generó la siguiente interacción para el telefono $TELEFONOFINAL, nº Interacción: $INTERACTID"
if [ "$FLAGINT" = "OK" ] ; then
contadorOk=`expr $contadorOk + 1`
fi

if [ "$FLAGINT" = "NO OK" ] ; then
contadorError=`expr $contadorError + 1`
fi

rm -f $CLFYARCH
contadorTotal=`expr $contadorTotal + 1`
done < $ARCHCC
pMessage "Cantidad Total de interaciones procesadas: $contadorTotal"
pMessage "Cantidad de interacciones generadas: $contadorOk"
pMessage "Cantidad de interacciones generadas con error: $contadorError"

rm -f $ARCHCC
pMessage "Se finalizó el proceso de Ejecución de EALTACONT"

#---

pMessage "Se finalizó el proceso de Ejecución de ALTA DE CONTRATOS" 
	
#---

pMessage "Fin de todo el Proceso de Migracion de Alta de contratos"
	
exit
