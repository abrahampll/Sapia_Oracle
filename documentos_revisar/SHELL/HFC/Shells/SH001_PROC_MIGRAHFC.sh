#! /bin/ksh
#*************************************************************
#* DESCRIPCION           : Importacion de Alta de clientes - HFC*
#* EJECUCION             :                                      *
#* AUTOR                 : JCGT                                 *
#* FECHA                 : 13-04-2012   VERSION : v1.0          *
#* FECHA MOD .           :                         				*
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
CONTROL=$DIRCONTROLHFC/importaAltacliHFC.ctl
BAD=$DIRFALLOSHFC/importaAltacliHFC_BAD_$FECHA.bad
FILELOG=$DIRLOGHFC/SH001_PROC_MIGRAHFC_$FECHA.log
CTL_LOG=$DIRLOGHFC/CTL001_LOG_$FECHA.log
ARCHSP=SH001_PROC_MIGRAHFC_EXITO_$FECHA.log
ARCHBKP=BONUS_ALTA_CLIENTES_BKP_$FECHA.log
ARCHPRMT2=$1
RUTANAME=$DIR_ENT_CAMBTITU
ARCHSHELL=SH001_PROC_MIGRAHFC.sh

if [ "$1" = "" ] ; then
	ARCHPRMT=""
	ARCHNAME=BONUS_ALTA_CLIENTES_${FARCH}.CCL
else
	ARCHNAME=$1
	ARCHPRMT1=${1#*BONUS_ALTA_CLIENTES_}
	ARCHPRMT=BONUS_ALTA_CLIENTES_$ARCHPRMT1
fi

# Inicio
demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "*************************************" 
pMessage "Iniciando proceso              " 
pMessage "Fecha y Hora : $demora               " 
pMessage "*************************************" 
pMessage $'\n'"Iniciando proceso ....$demora"$'\n'
pMessage "procesando..."

#creacion del archivo de migracion - SGA

# echo "${RUTANAME}/${ARCHNAME}"

# sqlplus -s $USER_BD_SGA/$CLAVE_BD_SGA@$SID_BD_SGA <<EOP  >> ${RUTANAME}/${ARCHSP}
# WHENEVER SQLERROR EXIT SQL.SQLCODE;
 # SET pagesize 0
 # SET linesize 30000
 # SET SPACE 0
 # SET feedback off
 # SET trimspool on
 # SET termout off
 # SET heading off
 # SET verify off
 # SET serveroutput on size 1000000
 # SET buffer       500000000;
 # SET echo off

 # DECLARE 
# type gc_salida is ref cursor;
# ac_salida gc_salida;
# cod_msje number;
# des_msje varchar2(300);

# BEGIN

# $PCLUB_SGA.PQ_CANJE_PREMIO.P_MIGRACION_CLAROCLUB(ac_salida,cod_msje,des_msje);
   
# if cod_msje<>0 then
        # DBMS_OUTPUT.PUT_LINE('SP2-');
# end if;

# EXCEPTION WHEN OTHERS THEN
    # DBMS_OUTPUT.PUT_LINE(SUBSTR(SQLERRM,200));
# END;
# /
# EXIT

# EOP
    
# VALIDA_EJEC_SGA=`grep 'ORA-' ${RUTANAME}/${ARCHSP} | wc -l | sed 's/ //g'`
# VALIDA_EJEC_SP_SGA=`grep 'SP2-' ${RUTANAME}/${ARCHSP} | wc -l | sed 's/ //g'`

# if [ ${VALIDA_EJEC_SGA} -ne 0 ] || [ ${VALIDA_EJEC_SP_SGA} -ne 0 ] ; then
    # pMessage "Hubo un error durante la ejeción del SP ATCCORP.PQ_CANJE_PREMIO.P_MIGRACION_CLAROCLUB - BD SGA" 
    # pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de MIGRACION DE clientes – Se encontraron errores" 
    # echo "Buen día, ocurrio un problema al ejecutar el SP de ATCCORP.PQ_CANJE_PREMIO.P_MIGRACION_CLAROCLUB." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "HFC: MIGRACION DE CLIENTES – Se encontraron errores" $IT_MAIL >> $FILELOG		
    # exit
# fi

# pMessage "Ejecución de SP PQ_CANJE_PREMIO.P_MIGRACION_CLAROCLUB fue satisfactorio"

# sqlplus -s $USER_BD_SGA/$CLAVE_BD_SGA@$SID_BD_SGA <<EOP  >> ${RUTANAME}/${ARCHNAME}
# WHENEVER SQLERROR EXIT SQL.SQLCODE;
 # SET ECHO OFF
# SET HEADING OFF
# SET NEWPAGE NONE
# SET UNDERLINE OFF
# SET PAGESIZE 0
# SET TERMOUT OFF
# SET VERIFY OFF
# SET TRIMSPOOL ON
# SET LINE 30000
# set buffer       500000000;
# SET FEEDBACK OFF

# spool ${RUTANAME}/${ARCHBKP};


	  # select  trim(a.codclaroclub) ||'|'||
               # (select tipsrv from inssrv where codinssrv = a.codinssrv) ||'|'||
               # trim(v.tipdide) ||'|'||
               # trim(v.ntdide) ||'|'||
               # replace( decode(trim(v.nomclires),
                      # null,
                      # decode(trim(v.nombre), null, null, trim(v.nombre)),
                      # trim(v.nomclires)),'|',' ') ||'|'||
               # replace(decode(decode(trim(v.nomclires),
                             # null,
                             # decode(trim(v.nombre),
                                    # null,
                                    # null,
                                    # trim(v.nombre)),
                             # trim(v.nomclires)),
                      # null,
                      # trim(v.nomcli),
                      # decode(trim(v.apepatcli) || ' ' || trim(v.apematcli),
                             # ' ',
                             # decode(trim(v.apepat) || ' ' || trim(v.apmat),
                                    # ' ',
                                    # trim(v.nomcli),
                                    # trim(v.apepat) || ' ' || trim(v.apmat)),
                             # trim(v.apepatcli) || ' ' || trim(v.apematcli))),'|',' ') ||'|'||
               # '' ||'|'||
               # '' ||'|'||
               # replace((select numcomcli
                  # from vtamedcomcli
                 # where codcli = v.codcli
                   # and idmedcom = '008'),'|','')||'|'||
               # u.nompvc ||'|'||
               # u.nomest ||'|'||
               # u.nomdst ||'|'||
               # to_char(a.fecactserv, 'dd/mm/yyyy') 
          # from $PCLUB_SGA.atc_registro_claroclub a,
               # vtatabcli                      v,
               # v_ubicaciones                  u
         # where a.estado = 5
           # and a.transferencia = 1
           # and v.codcli = a.codcli
           # and v.codubi = u.codubi(+);
           

# spool off;
# EXIT

# EOP

# VALIDA_EJEC_SQL_SGA=`grep 'ORA-' ${RUTANAME}/${ARCHNAME} | wc -l | sed 's/ //g'`
# VALIDA_EJEC_SQL_SGA=`grep 'SP2-' ${RUTANAME}/${ARCHNAME} | wc -l | sed 's/ //g'`

# if [ ${VALIDA_EJEC_SQL_SGA} -ne 0 ] || [ ${VALIDA_EJEC_SQL_SGA} -ne 0 ] ; then
    # pMessage "Hubo un error durante la consulta de datos para la migracion - BD SGA" 
    # pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de MIGRACION DE clientes – Se encontraron errores" 
    # echo "Buen día, ocurrio un problema al ejecutar la consulta de datos para la migracion - BD SGA." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "HFC: MIGRACION DE CLIENTES – Se encontraron errores" $IT_MAIL >> $FILELOG		
    # exit
# fi
# ####Proceso####
# # File Data: Se buscara el archivo(con su ruta) desde el programa 

# FILEDATA=`find $RUTANAME/$ARCHNAME`
# CANT_DATA=`cat  $RUTANAME/$ARCHNAME | wc -l | sed 's/ //g'`

# echo "$RUTANAME/$ARCHNAME"

# if [ "$FILEDATA" = "" ] ; then
   # Demora=`date +"%Y-%m-%d %H:%M:%S"`
   # pMessage "Error: No se encontro el archivo de datos..."$'\n'
   # pMessage "Termino proceso" 
   # pMessage "************************************" 
   # pMessage " FINALIZANDO PROCESO..............." 
   # pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso " 
   # pMessage "************************************" 
   # pMessage "No existe ninguno de estos archivos $ARCHNAME" 
   # pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de MIGRACION de clientes no se encuentra en la ruta" 
   # echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $DIRENTRADAHFC." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "HFC: El Archivo de MIGRACION de clientes no se encuentra en la ruta." $IT_MAIL 
   # pMessage "Ruta del Archivo log : " $FILELOG
   # exit -1
# fi
  
# if [ $CANT_DATA = 0 ] ; then
	# pMessage "Ninguno de estos archivos tiene data $ARCHNAME" 
	# pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de MIGRACION de clientes se encuentra vacio."
	# echo "Buen día, los siguientes archivos $ARCHNAME en la carpeta de ORIGEN no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "HFC: El Archivo de MIGRACION de clientes se encuentra vacio" $IT_MAIL
	# pMessage "Se envió correo Fecha y Hora: $demora"
	# exit -1
# fi

# pMessage " Se creo el archivo de migracion..............." 

# rm -f $RUTANAME/$ARCHBKP
# #Capturando nombre de archivo y la fecha de este

# if [ "$ARCHPRMT" = "" ] ; then
	# ARCHFECHA=${ARCHNAME:20:8}
	# ARCHNAMEF=$ARCHNAME
# else
	# ARCHNAMEF=$ARCHPRMT
	# ARCHFECHA=${ARCHPRMT:20:8}
# fi

# NOMARCH="'"${ARCHNAMEF}"'"
# FECHATMP="'"${ARCHFECHA}"'"

# echo "Archivo: $NOMARCH"
# echo "Fecha : $FECHATMP"
	
# pMessage "Se convierte el archivo de entrada al formato UNIX"
# dos2unix ${FILEDATA}

# TMP=$DIRLOGHFC/TEMPDATA01.tmp
# echo "" >> ${FILEDATA}
# cat ${FILEDATA} | sed '/^$/d' > $TMP
# cat $TMP > ${FILEDATA}
		
# rm -f $TMP
	
# TEMP_FILE=TEMP01_${FECHA}.TMP

# ARCHPRMT2=${FILEDATA#*BONUS_ALTA_CLIENTES_}
# ARCHPRMT3=BONUS_ALTA_CLIENTES_$ARCHPRMT2

# while read FIELD02
# do
	# echo "${FIELD02}|${ARCHPRMT2:0:8}|${ARCHPRMT3}" >> $DIRLOGHFC/$TEMP_FILE	
# done < $FILEDATA

# pMessage "Se procede a importar los datos del archivo de entrada a la tabla de alta de clientes"

# sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$CONTROL data=$DIRLOGHFC/$TEMP_FILE bad=$BAD log=$CTL_LOG 

# #rm -f $DIRLOGHFC/$TEMP_FILE
        
# VALIDAT_CTL=`grep 'ORA-' $CTL_LOG | wc -l`		
# if [ $VALIDAT_CTL -ne 0 ]
                # then
    # pMessage "ERROR en la ejecucion del control $CONTROL - Migracion de Clientes. Contacte al administrador."$'\n'
    # pMessage "Verifique el log para mayor detalle $FILELOG"$'\n'
    # pMessage "Termino proceso" 
    # pMessage "************************************"
    # pMessage " FINALIZANDO PROCESO..............."
    # pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso "
    # pMessage "************************************"
    # pMessage "Ruta del Archivo log : " $FILELOG
    # exit -1
# fi

# rm -f $CTL_LOG
	
pMessage "El proceso de importacion culmino satisfactoriamente"
	
cp $FILEDATA $DIR_PROC_CAMBTITU


#Capturando la fecha

if [ "$ARCHPRMT" = "" ] ; then
	FECHAARCH=$FARCH
else
	ARCHPRMT1=${ARCHPRMT#*BONUS_ALTA_CLIENTES_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi

echo "$FECHAARCH"
FECHATMP="'"${FECHAARCH}"'"
#Flujo corroborar archivos

pMessage "Se procede a ejecutar el SP PKG_CC_PTOSFIJA.ADMPSI_MIGRACLIENTEHFC"

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
		$PCLUB_OW.PKG_CC_PTOSFIJA.ADMPSI_MIGRACLIENTEHFC(v_fecha,'USRMIGHFC',k_coderror,
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
    pMessage "Hubo un error durante la ejeción del SP PKG_CC_PTOSFIJA.ADMPSI_MIGRACLIENTEHFC" 
    pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de MIGRACION DE clientes – Se encontraron errores" 
    echo "Buen día, ocurrio un problema al ejecutar el SP de PKG_CC_PTOSFIJA.ADMPSI_MIGRACLIENTEHFC." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "HFC: MIGRACION DE ALTA DE clientes – Se encontraron errores" $IT_MAIL >> $FILELOG		
    exit
fi

pMessage "Ejecución de SP fue satisfactorio"
       

ARCHERR=BONUS_ALTA_CLIENTES_${FARCH}
ARCHERR2=BONUS_ALTA_CLIENTES_param_${FARCH}


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
	ARCHPRMT1=${STRINGRUTA#*BONUS_ALTA_CLIENTES_}
	FECHAARCH=${ARCHPRMT1:0:8}
fi
#Flujo corroborar archivos

if [ "$FINDFILE" = "" ] && [ "$FINDBKP" = "" ] && [ "$FINDFILE2" = "" ] ; then
	pMessage "Hora y Fecha: $demora"
	pMessage "No existe ninguno de estos archivos $ARCHNAME" 
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Alta de clientes no se encuentra en la ruta" 
	echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "HFC: El Archivo de MIGRACION de clientes no se encuentra en la ruta." $IT_MAIL 
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
rm -f ${DIR_ERR_CAMBTITU}/${FILEERR}

pMessage "Se procede a ejecutar el SP PKG_CC_PTOSFIJA.ADMPSI_EMIGRACLIENTEHFC y exportar los datos obtenidos"

sqlplus -s $USER_BD/$CLAVE_BD@$SID_BD <<EOP  >> ${DIR_ERR_CAMBTITU}/${FILEERR}

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
   
    $PCLUB_OW.PKG_CC_PTOSFIJA.ADMPSI_EMIGRACLIENTEHFC(v_fecha,cursoraltaclic);
   
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
	
CANT_DATA=`cat ${DIR_ERR_CAMBTITU}/${FILEERR} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP=`grep 'ORA-' ${DIR_ERR_CAMBTITU}/${FILEERR} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B=`grep 'SP2-' ${DIR_ERR_CAMBTITU}/${FILEERR} | wc -l | sed 's/ //g'`
    
if [ $CANT_DATA = 0 ] ; then
	pMessage "El archivo no trajo datos, asi que no se podra generar en la carpeta destino"	
else
	pMessage "Se ha generado el archivo ${DIRFALLOSHFC}/${FILEERR}"	
fi

if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
	cat ${DIR_ERR_CAMBTITU}/${FILEERR} >> $FILELOG
    pMessage "Hubo un error durante la ejeción del SP PKG_CC_PTOSFIJA.ADMPSI_EMIGRACLIENTEHFC"
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto Ocurrio un Error durante la ejecucion" 
	echo "Buen día, se encontraron errores durante la ejecución del SP PKG_CC_PTOSFIJA.ADMPSI_EMIGRACLIENTEHFC ." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "MIGRACION HFC: Ocurrio un Error durante la ejecucion." $IT_MAIL 	
	exit
else
	if [ $CANT_DATA != 0 ] ; then
		pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de Errores en el registro de clientes" 
		echo "Buen día, se encontraron $CANT_DATA errores. Revisar la ruta ${DIR_ERR_CAMBTITU}/${FILEERR} ." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "MIGRACION HFC: Errores en el registro de clientes." $IT_MAIL 	
		exit
	fi	
fi

pMessage "Ejecución de SP fue satisfactorio"

pMessage "Se finalizó el proceso de Ejecución de ADMPSI_EMIGRACLIENTEHFC"

pMessage "Se finalizó el proceso de Ejecución de MIGRACION DE clientes"

pMessage "Fin de todo el Proceso de Migracion de Alta de clientes"

exit
