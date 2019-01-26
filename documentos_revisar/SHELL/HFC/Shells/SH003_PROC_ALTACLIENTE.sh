#! /bin/ksh
#*****************************************************************
#* DESCRIPCION           : Importacion de Alta de clientes - HFC *
#* EJECUCION             :                                       *
#* AUTOR                 : Carlos Carrillo Orellano              *
#* FECHA                 : 10-05-2015   VERSION : v1.0           *
#* FECHA MOD .           :                         				 *
#*****************************************************************
clear
#Iniciación de Variables
# Inicializacion de Variables
RUTA_INI=/home/usrclaroclub/CLAROCLUB/Interno/HFC
. $RUTA_INI/Bin/.varset
. $RUTA_INI/Bin/.passet
. $RUTA_INI/Bin/.mailset

# Rutas
FECHA=`date +%Y%m%d_%H%M%S`
FARCH=`date +%Y%m%d`
FECHADMY=`date +"%d/%m/%Y"`
Demora=`date +"%Y-%m-%d %H:%M:%S"`
demora=`date +"%Y-%m-%d %H:%M:%S"`
### Archivo Alta Cliente ###
CONTROL=$DIRCONTROLHFC/importaAltaClienteHFC.ctl
BAD=$DIRFALLOSHFC/importaAltaClienteHFC_BAD_$FECHA.bad
CTL_LOG=$DIRLOGHFC/CTL003_AC_LOG_$FECHA.log
### Archivo Alta Cliente ###

### Archivo Alta Servicio ###
CONTROL_AS=$DIRCONTROLHFC/importaAltaClienteServicioHFC.ctl
BAD_AS=$DIRFALLOSHFC/importaAltaClienteServicioHFC_BAD_$FECHA.bad
CTL_LOG_AS=$DIRLOGHFC/CTL003_AS_LOG_$FECHA.log
### Archivo Alta Servicio ###

FILELOG=$DIRLOGHFC/SH003_PROC_ALTACLIENTE_$FECHA.log
RUTANAME=$DIRENTRADAHFC_DOC_ALTA
ARCHNAME=ALTA_CLIENTE_CC_${FARCH}.CCL
ARCHSHELL=SH003_PROC_ALTACLIENTE.sh
USER_SERV=`whoami`
IP_SERV=`cat /etc/sysconfig/network-scripts/ifcfg-eth0|grep IPADDR|sed 's/^[A-Z].*=//'`

pMessage () {   
   LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
   echo "($LOGDATE) $*" 
   echo "($LOGDATE) $*"  >> $FILELOG
}
ValidaErro() {
# Funcion encarga de verificar si el archivo existe
  FILENAME=$1
  RETORNOS=1
  
  if [ ! -e $FILENAME ]; then  
    RETORNOS=-1
  fi
  
  echo $RETORNOS
}
EjecutarSpBorrarAC() {
# Función que se encarga de borrar los registros de la tabla Alta Cliente.
	
	NAME=$1
		
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
	v_fecha date;
	BEGIN
				
	   SELECT TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD'),'YYYYMMDD') INTO v_fecha FROM DUAL;   
				
		begin
			$PCLUB_OW.PKG_CC_PTOSFIJA.ADMPSI_ELIMINA_ALTACLIENTE_HFC('7',v_fecha,'$NAME',k_coderror,k_descerror);
			if k_coderror=0 then
			   dbms_output.put_line('Codigo de error: ' || k_coderror || '|Mensaje de error: ' || k_descerror );
			end if;
		end;
			
		IF k_coderror<>0 THEN
			dbms_output.put_line('SP2-');
		END IF;
		
	END;	
	/
	exit
EOP

VALIDA_EJEC_SP_A=`grep 'ORA-' ${FILELOG} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_Z=`grep 'SP2-' ${FILELOG} | wc -l | sed 's/ //g'`

if [ ${VALIDA_EJEC_SP_A} -ne 0 ] || [ ${VALIDA_EJEC_SP_Z} -ne 0 ] ; then
	pMessage "Hubo un error durante la ejeción del SP PKG_CC_PTOSFIJA.ADMPSI_ELIMINA_ALTACLIENTE_HFC" 
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de IMPORTACION DE ALTA DE clientes – Se encontraron errores" 
	echo "Buen día, ocurrio un problema al ejecutar el SP de PKG_CC_PTOSFIJA.ADMPSI_ELIMINA_ALTACLIENTE_HFC." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "HFC-POSTPAGO: ELIMINAR LOS REGISTROS DE ALTA DE CLIENTES – Se encontraron errores" $IT_MAIL >> $FILELOG	
fi
	pMessage "Se elimino los clientes que se registraron en la tabla Temporal Alta Cliente."
}
InicioShell(){
pMessage "-------------------------------------------------------------------"
pMessage "|             INICIANDO ALTA DE CLIENTE Y PRODUCTOS               |"
pMessage "-------------------------------------------------------------------"
pMessage "   Fecha y Hora   |      `date +'%d-%m-%Y %H:%M:%S'`               "
pMessage "   Usuario        |      $USER_SERV                                "
pMessage "   Shell          |      $ARCHSHELL                                "
pMessage "   Ip             |      $IP_SERV      	  	                     "
pMessage "-------------------------------------------------------------------"
}
FinalShell(){
pMessage "-----------------------------------------------------------------"
pMessage "|            FINALIZANDO ALTA DE CLIENTE Y PRODUCTOS            |"
pMessage "-----------------------------------------------------------------"
pMessage "   Fecha y Hora   |      `date +'%d-%m-%Y %H:%M:%S'`             "
pMessage "   Usuario        |      $USER_SERV                              "
pMessage "   Shell          |      $ARCHSHELL                              "
pMessage "   Ip             |      $IP_SERV      	  	                   "
pMessage "-----------------------------------------------------------------"
}

# Inicio
InicioShell
####Proceso####

### Archivo Alta Cliente ###
FILEDATA=$RUTANAME/$ARCHNAME
### Archivo Alta Cliente ###

# Importar Clientes #
RETORNOS=$(ValidaErro $FILEDATA)
if [ $RETORNOS -ne 1 ] ; then   
   pMessage "Error: No se encontro el archivo de datos proceso alta clientes..."  
   pMessage "No existe ninguno de estos archivos $ARCHNAME" 
   pMessage "A continuacion se enviara un correo a $IT_MAIL con el asunto de El Archivo de Alta de " $'\n' "clientes no se encuentra en la ruta $RUTANAME." 
   echo "Buen dia, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "HFC-POSTPAGO: El Archivo de Alta de clientes no se encuentra en la ruta $RUTANAME." $IT_MAIL 
   pMessage "Ruta del Archivo log : " $FILELOG
   FinalShell
   exit
   
else

	CANT_DATA=`cat  $RUTANAME/$ARCHNAME | wc -l | sed 's/ //g'`	
	if [ $CANT_DATA = 0 ] ; then
		pMessage "Ninguno de estos archivos tiene data $ARCHNAME" 
		pMessage "A continuacion se enviara un correo a $IT_MAIL con el asunto de El Archivo de Alta de " $'\n'"clientes se encuentra vacio."
		echo "Buen dia, los siguientes archivos $ARCHNAME en la carpeta de origen $RUTANAME no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "HFC-POSTPAGO: El Archivo de Alta de clientes se encuentra vacio" $IT_MAIL
		pMessage "Se envio correo Fecha y Hora: $demora"
		FinalShell
		exit
	fi

	pMessage "Se convierte el archivo de entrada $ARCHNAME al formato UNIX"
	dos2unix ${FILEDATA}

	ARCHIVOTEMP=$DIRLOGHFC/TEMPDATA01.tmp
	echo "" >> ${FILEDATA}
	cat ${FILEDATA} | sed '/^$/d' > $ARCHIVOTEMP
	cat $ARCHIVOTEMP > ${FILEDATA} 	
	
	sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$CONTROL data=$ARCHIVOTEMP bad=$BAD log=$CTL_LOG bindsize=200000 readsize=200000 rows=1000 skip=0
	rm -f $ARCHIVOTEMP
			
	VALIDAT_CTL=`grep 'ORA-' $CTL_LOG | wc -l`    
	if [ $VALIDAT_CTL -ne 0 ] 
					then
		pMessage "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n'
		pMessage "Verifique el log para mayor detalle $FILELOG"$'\n'		
		pMessage "************************************"		
		pMessage "Ruta del Archivo log : " $CTL_LOG
		FinalShell
		exit
	fi

	# Actualiza Nombre #
	pMessage "Actualizamos el nombre del archivo Alta de Clientes."
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

v_file VARCHAR2(150):='$ARCHNAME';

BEGIN

	UPDATE $PCLUB_OW.ADMPT_TMP_ALTACLIENTE_SVR SET ADMPV_NOM_ARCH = '$ARCHNAME' WHERE ADMPV_TIP_CLIENTE = '7' AND ADMPD_FEC_OPER = TO_DATE('$FECHADMY','dd/mm/YYYY');	
    
EXCEPTION
    WHEN OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
END;
/

EXIT
EOP
	pMessage "Se termino la actualizacion del nombre del archivo del archivo Alta de Clientes."
	# Actualiza Nombre #
	
	cp $FILEDATA $DIRPROCHFC_PROALT

	pMessage "El proceso de importacion Alta Cliente culmino satisfactoriamente"
		
	FINDFILE=`find $FILEDATA`
	FINDBKP=`find $DIRPROCHFC_PROALT/$ARCHNAME`	
	FECHAARCH=$FARCH

	#Flujo corroborar archivos	
	if [ "$FINDFILE" = "" ] && [ "$FINDBKP" = "" ] ; then
		pMessage "Hora y Fecha: $demora"
		pMessage "No existe archivos para el procesamiento: $ARCHNAME" 
		pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Alta de clientes no se encuentra en la ruta $DIRPROCHFC_PROALT." 
		echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "HFC-POSTPAGO: El Archivo de Alta de clientes no se encuentra en la ruta $DIRPROCHFC_PROALT." $IT_MAIL
		FinalShell
		exit
	fi

	#borramos el archivo de la carpeta de documentos
	if [ "$FINDBKP" != "" ] ; then
		rm -f $FILEDATA
		pMessage "El archivo de entrada fue copiado en $FINDBKP"	
	fi
	
fi
# Importar Clientes #


# Importar Servicios #
ARCHNAME_AS=ALTA_SERVICIO_CC_${FARCH}.CCL
FILEDATA_AS=$RUTANAME/$ARCHNAME_AS

RETORNOS2=$(ValidaErro ${FILEDATA_AS})
if [ $RETORNOS2 -ne 1 ] ; then
   Demora=`date +"%Y-%m-%d %H:%M:%S"`
   pMessage "Error: No se encontro el archivo de datos para cargar los servicios ..."   
   echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME_AS en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "HFC-POSTPAGO: El Archivo de Alta de clientes no se encuentra en la ruta $RUTANAME." $IT_MAIL 
   pMessage "Ruta del Archivo log : " $FILELOG  
   pMessage "Se procede a eliminar los datos en la tabla Alta de Cliente."      
   EjecutarSpBorrarAC ${ARCHNAME}
   FinalShell
   exit
else
   
    CANT_DATA_AS=`cat  $RUTANAME/$ARCHNAME_AS | wc -l | sed 's/ //g'`	
	if [ $CANT_DATA_AS = 0 ] ; then
		pMessage "Ninguno de estos archivos tiene data $ARCHNAME_AS" 
		pMessage "A continuacion se enviara un correo a $IT_MAIL con el asunto de El Archivo de Alta de " $'\n'"Servicios se encuentra vacio."
		echo "Buen dia, los siguientes archivos $ARCHNAME_AS en la carpeta de ORIGEN no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "HFC-POSTPAGO: El Archivo de Alta de Servicios se encuentra vacio." $IT_MAIL
		pMessage "Se envio correo Fecha y Hora: $demora"
		pMessage "Se procede a eliminar los datos en la tabla Alta de Cliente."
		EjecutarSpBorrarAC ${ARCHNAME}   
		FinalShell
		exit
	fi

	pMessage "Se convierte el archivo de entrada $ARCHNAME_AS al formato UNIX"
	dos2unix ${FILEDATA_AS}
	
	TMP_AS=$DIRLOGHFC/TEMPDATA02.tmp
	echo "" >> ${FILEDATA_AS}
	cat ${FILEDATA_AS} | sed '/^$/d' > $TMP_AS
	cat $TMP_AS > ${FILEDATA_AS}
			
	sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$CONTROL_AS data=$TMP_AS bad=$BAD_AS log=$CTL_LOG_AS bindsize=200000 readsize=200000 rows=1000 skip=0    
	rm -f $TMP_AS
	
	VALIDAT_CTL_AS=`grep 'ORA-' $CTL_LOG_AS | wc -l`		
	if [ $VALIDAT_CTL_AS -ne 0 ] 
						then
		pMessage "ERROR en la ejecucion del control $CONTROL_AS. Contacte al administrador."$'\n'
		pMessage "Verifique el log para mayor detalle $FILELOG"$'\n'	
		pMessage "Ruta del Archivo log : " $CTL_LOG_AS
		pMessage "Se procede a eliminar los datos en la tabla Alta de Cliente."
		EjecutarSpBorrarAC ${ARCHNAME}
		FinalShell
		exit
	fi

	cp $FILEDATA_AS $DIRPROCHFC_PROALT
	
	pMessage "El proceso de importacion de Servicios culmino satisfactoriamente"
	
	FINDFILE_AS=`find $FILEDATA_AS`
	FINDBKP_AS=`find $DIRPROCHFC_PROALT/$ARCHNAME_AS`	
	if [ "$FINDFILE_AS" = "" ] && [ "$FINDBKP_AS" = "" ] ; then
		pMessage "Hora y Fecha: $demora"
		pMessage "No existe archivos para el procesamiento: $ARCHNAME_AS" 
		pMessage "A continuacion se enviara un correo a $IT_MAIL con el asunto de El Archivo de Alta de " $'\n'"Servicios no se encuentra en la ruta $DIRPROCHFC_PROALT." 
		echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME_AS en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "DTH-POSTPAGO: El Archivo de Alta de Servicios no se encuentra en la ruta $DIRPROCHFC_PROALT." $IT_MAIL 
		FinalShell
		exit
	fi
	
	#borramos el archivo de la carpeta de documentos
	if [ "$FINDBKP_AS" != "" ] ; then
		rm -f $FILEDATA_AS
		pMessage "El archivo de entrada fue copiado en $FINDBKP_AS"	
	fi
	

	# Importar Clientes #
	FECHAARCH=$FARCH		
	FECHATMP="'"${FECHAARCH}"'"
	# Importar Clientes #

	# Actualiza Nombre #
	pMessage "Actualizamos el nombre del archivo en los servicios."
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

BEGIN

	UPDATE $PCLUB_OW.ADMPT_TMP_ALTACLIENTESERV_SVR SET ADMPV_NOM_ARCH = '$ARCHNAME_AS' WHERE ADMPV_TIP_CLIENTE = '7' AND ADMPD_FEC_OPER = TO_DATE('$FECHADMY','dd/mm/YYYY');

EXCEPTION
    WHEN OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
END;
/

EXIT
EOP
	pMessage "Se termino la actualizacion del nombre del archivo de los servicios."
	# Actualiza Nombre #

	pMessage "Se procede a ejecutar el SP PKG_CC_PTOSFIJA.ADMPSI_ALTACLIENTE_SVR"

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
k_numcliexi number;
k_numclidup number;
k_numreg number;
v_fecha date;
v_usuario varchar2(13);
		
BEGIN
		
SELECT TO_DATE($FECHATMP,'YYYYMMDD') INTO v_fecha FROM DUAL;
v_usuario:='$VARUSUHFC';

    begin
		$PCLUB_OW.PKG_CC_PTOSFIJA.ADMPSI_ALTACLIENTE_SVR('7',v_fecha,v_usuario,k_coderror,k_descerror,
						k_numregtot,
						k_numregpro,
                                                k_numcliexi,
                                                k_numclidup,
						k_numreg,
						k_numregerr);
	end;
		
	dbms_output.put_line('Codigo de error: ' || k_coderror || '|Mensaje de error: ' || k_descerror || '|Nº total de registros: ' || k_numregtot || '|Nº de registros procesados: ' || k_numregpro );
	dbms_output.put_line('Nº de Clientes Existentes: ' || k_numcliexi || '|Nº de Clientes Duplicados: ' || k_numclidup || '|Nº de Clientes Registrados: ' || k_numreg || '|Nº de registros con errores: ' || k_numregerr );
	
	IF k_coderror<>0 THEN
		dbms_output.put_line('SP2-');
	END IF;
	IF k_numregerr<>0 THEN
	    dbms_output.put_line('ERR1-');
	END IF;
	
END;	
/
exit
EOP
    
	VALIDA_EJEC_SP=`grep 'ORA-' ${FILELOG} | wc -l | sed 's/ //g'`
	VALIDA_EJEC_SP_B=`grep 'SP2-' ${FILELOG} | wc -l | sed 's/ //g'`

	if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
		pMessage "Hubo un error durante la ejecucion del SP PKG_CC_PTOSFIJA.ADMPSI_ALTACLIENTE_SVR" 
		pMessage "A continuacion se enviara un correo a $IT_MAIL con el asunto de IMPORTACION DE ALTA DE clientes – Se encontraron errores" 
		echo "Buen dia, ocurrio un problema al ejecutar el SP de PKG_CC_PTOSFIJA.ADMPSI_ALTACLIENTE_SVR." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "HFC-POSTPAGO: IMPORTACION DE ALTA DE CLIENTES Y SERVICIOS – Se encontraron errores" $IT_MAIL >> $FILELOG
		FinalShell		
		exit
	fi
	pMessage "Ejecucion de SP fue satisfactorio"

	VALIDA_EJEC_SP_ERR=`grep 'ERR1-' ${FILELOG} | wc -l | sed 's/ //g'`
	if [ ${VALIDA_EJEC_SP_ERR} -ne 0 ] ; then
		pMessage "Hubo registros que se procesaron con errores." 
		pMessage "A continuacion se enviara un correo a $IT_MAIL con el asunto de IMPORTACION DE ALTA DE clientes – Se encontraron registros procesados con errores"
		echo "Buen dia, no se procesaron todos los registros con exito al ejecutar el SP de PKG_CC_PTOSFIJA.ADMPSI_ALTACLIENTE_SVR." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "HFC-POSTPAGO: IMPORTACION DE ALTA DE CLIENTES Y SERVICIOS – Se encontraron errores" $IT_MAIL >> $FILELOG		
	fi

	pMessage "Se finalizo el proceso de Ejecucion de ALTA DE CLIENTES Y SERVICIOS EN HFC de forma exitosa."
	FinalShell
	
fi
		
exit
