#! /bin/ksh
#*************************************************************
#* DESCRIPCION           : VENCIMIENTO DE PUNTOS              *
#* EJECUCION             : Control-D                          *
#* AUTOR                 : E77210: JCGutierrezT               *
#* FECHA                 : 19/06/2012   VERSION : v1.0        *
#* FECHA MOD .           :                                    *
#*************************************************************

#Iniciación de Variables
# Inicializacion de Variables
. /home/usrclaroclub/CLAROCLUB/Interno/DTH/Bin/.varset
. /home/usrclaroclub/CLAROCLUB/Interno/DTH/Bin/.passet
. /home/usrclaroclub/CLAROCLUB/Interno/DTH/Bin/.mailset
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
FILELOG=$DIRLOGDTH/SH008_VENCPTOS_$FECHA.log
ARCHSHELL=SH008_VENCPTOS.sh

# Inicio
demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "*************************************" 
pMessage "Iniciando proceso               " 
pMessage "Fecha y Hora : $demora               "
pMessage "*************************************" 

echo "Ruta Shell: $DIR_DTH_SHELL/$ARCHSHELL"

	
pMessage "Se procede a ejecutar el SP PKG_CC_PTOSFIJA.SH008_VENCPTOS"
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
k_usuario varchar2(50);		
k_tip_cli varchar2(2);	
	
BEGIN
		
	
		k_usuario:='USRVTOPTO';
		k_tip_cli:='6';
							
		$PCLUB_OW.PKG_CC_PTOSFIJA.ADMPSI_PREVENCPTO(k_tip_cli,k_usuario,k_coderror,k_descerror);
	
	dbms_output.put_line('Codigo de error: ' || k_coderror || '|Mensaje de error: ' || k_descerror );
	
	IF k_coderror<>0 THEN
		dbms_output.put_line('SP2-');
	END IF;
EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
        
END;		

	
/
exit
EOP

VALIDA_EJEC_SP=`grep 'ORA-' ${FILELOG} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B=`grep 'SP2-' ${FILELOG} | wc -l | sed 's/ //g'`

if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
    pMessage "Hubo un error durante la ejeción del SP PKG_CC_PTOSFIJA.ADMPSI_PREVENCPTO" 
    pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de VENCIMIENTO DE PUNTOS DTH – Se encontraron errores" 
    echo "Buen día, ocurrio un problema al ejecutar el SP de PKG_CC_PTOSFIJA.ADMPSI_PREVENCPTO." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "VENCIMIENTO DE PUNTOS DTH – Se encontraron errores" $IT_MAIL 		
    pMessage "Se envió correo Fecha y Hora: $demora"    
	exit
fi

pMessage "Ejecución de SP fue satisfactorio"

pMessage "Termino subproceso VENCIMIENTO DE PUNTOS ClaroClub "
pMessage "********** FINALIZANDO PROCESO ********** " 
pMessage "Fin de proceso "
pMessage "************************************" 
pMessage "Ruta del Archivo log : ${FILELOG}" 
pMessage "*************************************" 
exit