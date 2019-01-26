#! /bin/ksh
#*********************************************************************
#* DESCRIPCION           : Importacion Baja de Puntos - HFC          *
#* EJECUCION             : Control-D                                 *
#* AUTOR                 : Carlos Carrillo Orellano                  *
#* FECHA                 : 01/03/2016   VERSION : v1.0               *
#* FECHA MOD .           :                                           *
#*********************************************************************
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
# Funcion encarga de verificar el archivo respuesta de un proceso de base de datos
# y validar si contiene o no errores

  FILENAME=$1
  RETORNOS=1
  
  if [ -e $FILENAME ]; then
    VALIDA_ORA=`grep 'ORA-' $FILENAME | wc -l`
    VALIDA_SP2=`grep 'SP2-' $FILENAME | wc -l` 
      if [ $VALIDA_ORA -gt 0 ] || [ $VALIDA_SP2 -gt 0 ]; then
        RETORNOS=-1
      fi
  else
    RETORNOS=-1
  fi
  
  echo $RETORNOS
}
InicioShell(){
pMessage "-------------------------------------------------------------------"
pMessage "|                   INICIANDO ELIMINAR HISTORICO                  |"
pMessage "-------------------------------------------------------------------"
pMessage "   Fecha y Hora   |      `date +'%d-%m-%Y %H:%M:%S'`               "
pMessage "   Usuario        |      $USER_SERV                                "
pMessage "   Shell          |      $ARCHSHELL                                "
pMessage "   Ip             |      $IP_SERV      	  	                     "
pMessage "-------------------------------------------------------------------"
}
FinalShell(){
pMessage "-----------------------------------------------------------------"
pMessage "|               FINALIZANDO ELIMINAR HISTORICO                  |"
pMessage "-----------------------------------------------------------------"
pMessage "   Fecha y Hora   |      `date +'%d-%m-%Y %H:%M:%S'`             "
pMessage "   Usuario        |      $USER_SERV                              "
pMessage "   Shell          |      $ARCHSHELL                              "
pMessage "   Ip             |      $IP_SERV      	  	                   "
pMessage "-----------------------------------------------------------------"
}

# Rutas y Variables
FECHA=`date +%Y%m%d_%H%M%S`
FARCH=`date +%Y%m%d`
FECHADMY=`date +"%d/%m/%Y"`
demora=`date +"%Y-%m-%d %H:%M:%S"`
FILELOG=$DIRLOGHFC/SH001_PROC_ELIMINARHIST_$FECHA.log

ARCHSHELL=SH001_ELIMINA_HIST.sh
USER_SERV=`whoami`
IP_SERV=`cat /etc/sysconfig/network-scripts/ifcfg-eth0|grep IPADDR|sed 's/^[A-Z].*=//'`

# Inicio
InicioShell
####Proceso####
	
	FECHAARCH=$FARCH
	FECHATMP="'"${FECHAARCH}"'"
	
	pMessage "Se ejecuta el SP PKG_CTL_CCLUB.ADMPSD_CTL_CANJES"
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
	
			
	BEGIN
	
		begin

		$PCLUB_OW.PKG_CTL_CCLUB.ADMPSD_CTL_CANJES(6,k_coderror,k_descerror);
		
		end;
			
		dbms_output.put_line('Codigo de error: ' || k_coderror || '|Mensaje de error: ' || k_descerror);
		
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
		pMessage "Hubo un error durante la ejecucion del SP PKG_CTL_CCLUB.ADMPSD_CTL_CANJES" 
		pMessage "A continuacion se enviara un correo a $IT_MAIL con el asunto" $'\n' " ELIMINAR DATOS HISTORICOS. Se encontraron errores." 
		echo "Buen dia, ocurrio un problema al ejecutar el SP de PKG_CTL_CCLUB.ADMPSD_CTL_CANJES." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "HFC-POSTPAGO: ELIMINAR HISTORICO" $IT_MAIL 		
		pMessage "Se envio correo Fecha y Hora: $demora"
		FinalShell
		exit
	fi

	pMessage "Ejecución de SP ADMPSD_CTL_CANJES fue satisfactorio"	
	


FinalShell
exit