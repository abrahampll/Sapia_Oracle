#! /bin/ksh
#*********************************************************************
#* DESCRIPCION           : Validación Asignación Ptos Prepago        *
#* EJECUCION             : Control-D                                 *
#* AUTOR                 : Carlos Carrillo Orellano                  *
#* FECHA                 : 29/05/2015   VERSION : v1.0               *
#* FECHA MOD .           :                                           *
#*********************************************************************
clear
#Iniciación de Variables
# Inicializacion de Variables
HOME_GAT=/home/usrclaroclub/CLAROCLUB/Interno/Prepago
. $HOME_GAT/Bin/.varset
. $HOME_GAT/Bin/.mailset
. $HOME_GAT/Bin/.passet 

# Rutas y variables
FECHA=`date +%Y%m%d_%H%M%S`
FARCH=`date +%Y%m%d`
FECHADMY=`date +"%d/%m/%Y"`
Demora=`date +"%Y-%m-%d %H:%M:%S"`
demora=`date +"%Y-%m-%d %H:%M:%S"`	
BAD=$DIRLOG/validarProcesoPtosRecarga_BAD_$FECHA.bad
FILELOG=$DIRLOG/SH010_RECARGA_VALPROREC_$FECHA.log
ARCHSHELL=SH010_RECARGA_VALPROREC.sh
USER_SERV=`whoami`
IP_SERV=`cat /etc/sysconfig/network-scripts/ifcfg-eth0|grep IPADDR|sed 's/^[A-Z].*=//'`

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
pMessage "|       INICIANDO VALIDACION PROCESAMIENTO PUNTOS PREPAGO         |"
pMessage "-------------------------------------------------------------------"
pMessage "   Fecha y Hora   |      `date +'%d-%m-%Y %H:%M:%S'`               "
pMessage "   Usuario        |      $USER_SERV                                "
pMessage "   Shell          |      $ARCHSHELL                                "
pMessage "   Ip             |      $IP_SERV      	  	                     "
pMessage "-------------------------------------------------------------------"
}
FinalShell(){
pMessage "-----------------------------------------------------------------"
pMessage "|     FINALIZANDO VALIDACION PROCESAMIENTO PUNTOS PREPAGO       |"
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
	
FECHAARCH=$FARCH
FECHATMP="'"${FECHAARCH}"'"
ESTADO="0"

pMessage "Se ejecuta el SP PKG_CC_PREPAGO_WA.ADMPSI_RECARGAVAL_PRO"
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
	
	k_resultado number;	
	k_coderror number;
	k_descerror varchar2(400);	
				
	BEGIN
	
		begin

		$PCLUB_OW.PKG_CC_PREPAGO_WA.ADMPSI_RECARGAVAL_PRO(k_resultado,k_coderror,k_descerror);
		
		end;
		
		dbms_output.put_line('Número Resultado: ' || k_resultado || '|Codigo de error: ' || k_coderror || '|Mensaje de error: ' || k_descerror);
		
		IF k_coderror<>0 THEN
			dbms_output.put_line('SP2-');
		END IF;
		IF k_resultado<>0 THEN
			dbms_output.put_line('SP3-');
		END IF;
		
		END;
		
	/
	exit
EOP

	VALIDA_EJEC_SP=`grep 'ORA-' ${FILELOG} | wc -l | sed 's/ //g'`
	VALIDA_EJEC_SP_B=`grep 'SP2-' ${FILELOG} | wc -l | sed 's/ //g'`
	ESTADO=`grep 'SP3-' ${FILELOG} | wc -l | sed 's/ //g'`
		
	if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
		pMessage "Hora y Fecha: $demora"
		pMessage "Hubo un error durante la ejecucion del SP PKG_CC_PREPAGO_WA.ADMPSI_RECARGAVAL_PRO" 
		pMessage "A continuacion se enviara un correo a $T_OPERADOR con el asunto de PROCESO ENTREGA DE PUNTOS PREPAGO" 
		echo "Buen dia, ocurrio un problema al ejecutar el SP de PKG_CC_PREPAGO_WA.ADMPSI_RECARGAVAL_PRO." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "PREPAGO: VERIFICACION DE PROCESO PREPAGO" $T_OPERADOR
		pMessage "Se envio correo Fecha y Hora: $demora"
		FinalShell
		exit
	fi
	
	
	if [ ${ESTADO} -eq "1" ] ; then		
		pMessage "Aun se encuentra procesando la Entrega de Puntos Prepago." 
		pMessage "A continuacion se enviara un correo a $T_OPERADOR con el asunto PROCESO ENTREGA DE PUNTOS PREPAGO" 
		echo "Buen dia, se sigue procesando el SP de PKG_CC_PREPAGO_WA.ADMPSI_PRERECAR del Shell SH010_RECARGA." $' \n'  "Gracias." $'\n'  | mail -s "PREPAGO: VERIFICACION DE PROCESO ENTREGA DE PUNTOS POR RECARGA" $T_OPERADOR
		pMessage "Se envio correo Fecha y Hora: $demora"
	fi
	
	pMessage "Se termino el proceso de Puntos por Recarga y se elimino los datos de la tabla temporal."
	pMessage "Ejecución de SP ADMPSI_RECARGAVAL_PRO fue satisfactorio"
	FinalShell

exit