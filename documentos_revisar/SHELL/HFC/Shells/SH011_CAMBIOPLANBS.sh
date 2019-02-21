#! /bin/ksh
#****************************************************************************
#* DESCRIPCION           : Importacion de Puntos por Cambio de Plan  - HFC  *
#* EJECUCION             : Control-D                                        *
#* AUTOR                 : Carlos Carrillo Orellano                         *
#* FECHA                 : 17/02/2016   VERSION : v1.0                      *
#* FECHA MOD .           :                                                  *
#****************************************************************************
clear
#Iniciación de Variables
# Inicializacion de Variables
HOME_INTHFC=/home/usrclaroclub/CLAROCLUB/Interno/HFC
. $HOME_INTHFC/Bin/.varset
. $HOME_INTHFC/Bin/.passet
. $HOME_INTHFC/Bin/.mailset

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
InicioShell(){
pMessage "-------------------------------------------------------------------"
pMessage "|                    INICIANDO CAMBIO DE PLAN                     |"
pMessage "-------------------------------------------------------------------"
pMessage "   Fecha y Hora   |      `date +'%d-%m-%Y %H:%M:%S'`               "
pMessage "   Usuario        |      $USER_SERV                                "
pMessage "   Shell          |      $ARCHSHELL                                "
pMessage "   Ip             |      $IP_SERV      	  	                     "
pMessage "-------------------------------------------------------------------"
}
FinalShell(){
pMessage "-----------------------------------------------------------------"
pMessage "|                 FINALIZANDO CAMBIO DE PLAN                    |"
pMessage "-----------------------------------------------------------------"
pMessage "   Fecha y Hora   |      `date +'%d-%m-%Y %H:%M:%S'`             "
pMessage "   Usuario        |      $USER_SERV                              "
pMessage "   Shell          |      $ARCHSHELL                              "
pMessage "   Ip             |      $IP_SERV      	  	                   "
pMessage "-----------------------------------------------------------------"
}


# Rutas y variables
FECHA=`date +%Y%m%d_%H%M%S`
FARCH=`date +%Y%m%d`
FECHADMY=`date +"%d/%m/%Y"`
demora=`date +"%Y-%m-%d %H:%M:%S"`
CONTROL=$DIRCONTROLHFC/importaCambioPlanHFCB.ctl
CTL_LOG=$DIRLOGHFC/CTL011_CAMPLABSCS_LOG_$FECHA.log
BAD=$DIRBADHFC/importaPuntosCambioPlanBSCS_BAD_$FECHA.bad
FILELOG=$DIRLOGHFC/SH011_PROC_CAMBIOPLANBSCS_$FECHA.log

ARCHNAME=CAMBIO_PLAN_CC_$FARCH.CCL
RUTANAME=$DIRENTRADAHFC_DOC_CAMPL
ARCHSHELL=SH011_CAMBIOPLANBS.sh
USER_SERV=`whoami`
IP_SERV=`cat /etc/sysconfig/network-scripts/ifcfg-eth0|grep IPADDR|sed 's/^[A-Z].*=//'`

# Inicio
InicioShell
####Proceso####

FILEDATA=$RUTANAME/$ARCHNAME
RETORNOS=$(ValidaErro $FILEDATA)

if [ $RETORNOS -ne 1 ] ; then   
   pMessage "Error: No se encontro el archivo de datos, proceso de puntos por Cambio de Plan..."  
   pMessage "No existe ninguno de estos archivos $ARCHNAME" 
   pMessage "A continuacion se enviara un correo a $IT_MAIL con el asunto de Puntos por Cambio de Plan BSCS no se encuentra en la ruta $RUTANAME." 
   echo "Buen dia, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "HFC_BSCS-POSTPAGO: El Archivo de Puntos por Cambio de Plan no se encuentra en la ruta $RUTANAME." $IT_MAIL 
   pMessage "Ruta del Archivo log : " $FILELOG
   FinalShell
   exit
else

	CANT_DATA=`cat  $RUTANAME/$ARCHNAME | wc -l | sed 's/ //g'`	
	if [ $CANT_DATA = 0 ] ; then
		pMessage "Ninguno de estos archivos tiene data $ARCHNAME" 
		pMessage "A continuacion se enviara un correo a $IT_MAIL con el asunto: El Archivo de Puntos por Cambio de Plan BSCS se encuentra vacio."
		echo "Buen dia, los siguientes archivos $ARCHNAME en la carpeta de ORIGEN no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "HFC_BSCS-POSTPAGO: El Archivo de Puntos por Cambio de Plan se encuentra vacio." $IT_MAIL
		pMessage "Se envio correo Fecha y Hora: $demora"
		FinalShell
		exit
	fi
	
	pMessage "Se convierte el archivo de entrada al formato UNIX"
	dos2unix ${FILEDATA}
	
	TMP=$DIRTMPHFC/TEMPDATA01.tmp
	echo "" >> ${FILEDATA}
	cat ${FILEDATA} | sed '/^$/d' > $TMP
	cat $TMP > ${FILEDATA}
	
	pMessage "Se procede a importar los datos del archivo de entrada a la tabla de Cambio de Plan"
	sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$CONTROL data=$TMP bad=$BAD log=$CTL_LOG bindsize=200000 readsize=200000 rows=1000 skip=0
	rm -f $TMP
	
	VALIDAT_CTL=`grep 'ORA-' $CTL_LOG | wc -l`		
	if [ $VALIDAT_CTL -ne 0 ] ; then
		pMessage "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n'
		pMessage "Verifique el log para mayor detalle $FILELOG"$'\n'		
		pMessage "Ruta del Archivo log : " $CTL_LOG
		FinalShell
		exit
	fi
	
	cp $FILEDATA $DIRPROCHFC_PROCAP #Copia a Ruta de Cambio de Plan
	
	pMessage "El proceso de importacion culmino satisfactoriamente"
	
	pMessage "Actualizamos el nombre del archivo."
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

		UPDATE $PCLUB_OW.ADMPT_TMP_CAMBIOPLAN_HFCB SET ADMPV_NOM_ARCH = '$ARCHNAME' WHERE ADMPV_TIP_CLIENTE = '7' AND ADMPD_FEC_OPER = TO_DATE('$FECHADMY','dd/mm/YYYY');

	EXCEPTION
		WHEN OTHERS then
		  dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
	END;
	/

	EXIT
EOP

	pMessage "Se termino la actualizacion del nombre del archivo."

	FECHAARCH=$FARCH
	FECHATMP="'"${FECHAARCH}"'"
	
	pMessage "Se ejecuta el SP PKG_CC_PTOSFIJA.ADMPSI_CAMBIOPLAN_HFCB"
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
	v_usuario varchar2(13);
			
	BEGIN
			
	SELECT TO_DATE($FECHATMP,'YYYYMMDD') INTO v_fecha FROM DUAL;
	v_usuario:='$VARUSUCPHFCB';

		begin

		$PCLUB_OW.PKG_CC_PTOSFIJA.ADMPSI_CAMBIOPLAN_HFCB('7',v_fecha,v_usuario,k_coderror,
							k_descerror,
							k_numregtot,
							k_numregpro,
							k_numregerr);
		end;
			
		dbms_output.put_line('Codigo de error: ' || k_coderror || '|Mensaje de error: ' || k_descerror || '|Nº total de registros: ' || k_numregtot || '|Nº de registros procesados: ' || k_numregpro || '|Nº de registros con errores: ' || k_numregerr);
		
		IF k_coderror<>0 THEN
			dbms_output.put_line('SP2-');
		END IF;
	        IF k_numregerr<>0 THEN
			dbms_output.put_line('ERRCAMP-');
		END IF;
		
		END;
		
	/
	exit
EOP

	VALIDA_EJEC_SP=`grep 'ORA-' ${FILELOG} | wc -l | sed 's/ //g'`
	VALIDA_EJEC_SP_B=`grep 'SP2-' ${FILELOG} | wc -l | sed 's/ //g'`

	if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
		pMessage "Hora y Fecha: $demora"
		pMessage "Hubo un error durante la ejecucion del SP PKG_CC_PTOSFIJA.ADMPSI_CAMBIOPLAN_HFCB" 
		pMessage "A continuacion se enviara un correo a $IT_MAIL con el asunto de PUNTOS POR CAMBIO DE PLAN HFC. Se encontraron errores." 
		echo "Buen dia, ocurrio un problema al ejecutar el SP de PKG_CC_PTOSFIJA.ADMPSI_CAMBIOPLAN_HFCB." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "HFC_BSCS-POSTPAGO: PUNTOS POR CAMBIO DE PLAN HFC" $IT_MAIL 		
		pMessage "Se envio correo Fecha y Hora: $demora"
		FinalShell
		exit
	fi

    VALIDA_EJEC_SP_ERR=`grep 'ERRCAMP-' ${FILELOG} | wc -l | sed 's/ //g'`
	if [ ${VALIDA_EJEC_SP_ERR} -ne 0 ] ; then		
		pMessage "Hora y Fecha: $demora"
		pMessage "Hubo registros que se procesaron con errores en la ejecucion del SP PKG_CC_PTOSFIJA.ADMPSI_CAMBIOPLAN_HFCB" 
		pMessage "A continuacion se enviara un correo a $IT_MAIL con el asunto de PUNTOS POR CAMBIO DE PLAN HFC. Se encontraron registros con errores." 
		echo "Buen dia, hubo registros procesados con errores al ejecutar el SP de PKG_CC_PTOSFIJA.ADMPSI_CAMBIOPLAN_HFCB." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "HFC_BSCS-POSTPAGO: PUNTOS POR CAMBIO DE PLAN HFC" $IT_MAIL 		
		pMessage "Se envio correo Fecha y Hora: $demora"		
	fi

	pMessage "Ejecución de SP fue satisfactorio"
	
	FINDFILE=`find $FILEDATA`
	FINDBKP=`find $DIR_PROC_CAMP/$ARCHNAME`	
	FECHAARCH=$FARCH

	#Flujo corroborar archivos	
	if [ "$FINDFILE" = "" ] && [ "$FINDBKP" = "" ] ; then
		pMessage "Hora y Fecha: $demora"
		pMessage "No existe archivos para el procesamiento: $ARCHNAME" 
		pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Puntos por Cambio De Plan no se encuentra en la ruta" 
		echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $DIR_PROC_CAMP." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "HFC_BSCS-POSTPAGO: El Archivo de Cambio de Plan no se encuentra en la ruta $DIR_PROC_CAMP." $IT_MAIL
		FinalShell
		exit
	fi

	#borramos el archivo de la carpeta de documentos
	if [ "$FINDBKP" != "" ] ; then
		rm -f $FILEDATA #Borrar Archivo de Carga
		pMessage "El archivo de entrada fue copiado en $FINDBKP"	
	fi
	
	pMessage "Ejecución del proceso de CAMBIO DE PLAN en HFC fue satisfactorio"	
	
fi

FinalShell
exit
