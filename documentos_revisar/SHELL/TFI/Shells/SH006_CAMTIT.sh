#!/bin/sh -x
#*************************************************************
#Programa      :  SH006_CAMTIT.sh
#Autor         :  Roxana Chero
#Descripcion   :  Proceso encargado de dar de baja puntos, por cambio de titularidad.     	   	       
#FECHA_HORA    :  08/04/2013
#*************************************************************
#clear

# Inicializacion de Variables
. /home/usrclaroclub/CLAROCLUB/Interno/TFI/Bin/.varset
. /home/usrclaroclub/CLAROCLUB/Interno/TFI/Bin/.passet
. /home/usrclaroclub/CLAROCLUB/Interno/TFI/Bin/.mailset

cd ${DIRSHELL}

#-----------------------------------------------------------------
#	FUNCION PARA MANEJO DEL LOG
#-----------------------------------------------------------------
pMessage () {   
   LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
   echo "($LOGDATE) $*" 
   echo "($LOGDATE) $*"  >> $DIRLOG/$FILELOG
} # pMessage	

FECHA=`date +%Y%m%d`
FECHA_HORA=`date +%Y%m%d%H%M%S`
HORA=`date +%H%M%S`

# ip de TIM-FTP1
HOST=`hostname`
IP_SERV=`cat /etc/hosts | grep -v '#' | grep ${HOST} | awk '{print $1}'`
#usuario
USER_SERV=`whoami`
SHELL=SH006_CAMTIT.sh
FILELOG=SH006_CAMTIT_${FECHA_HORA}.log
FILEERR=SH006_CAMTIT_${FECHA_HORA}.ERR

demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "************************************* " 
pMessage "Iniciando proceso                     " 
pMessage "Fecha y Hora  : ${FECHA_HORA}         " 
pMessage "Usuario :  ${USER_SERV}               " 
pMessage "Shell : ${SHELL}                      " 
pMessage "Ip : ${IP_SERV}                       " 
pMessage "*************************************"$'\n' 


pMessage "Se ejecuta el SP PKG_CC_PTOSTFI.ADMPSI_TFICMBTIT para el proceso de Cambio de Titularidad"	
#sh SH062_EJECUTA_SP.sh ${DIRLOG}/${FILELOG}

sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> ${DIRLOG}/${FILELOG}
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

K_FEC_PRO  DATE;
K_CODERROR  NUMBER; 
K_DESCERROR  VARCHAR2(100);
K_TOT_REG  NUMBER;
K_TOT_PRO  NUMBER;
K_TOT_ERR  NUMBER;

BEGIN


SELECT (sysdate - 1) INTO K_FEC_PRO FROM DUAL;

$PCLUB_OW.PKG_CC_PTOSTFI.ADMPSI_TFICMBTIT(K_FEC_PRO,K_CODERROR,K_DESCERROR,K_TOT_REG,K_TOT_PRO,K_TOT_ERR);

--dbms_output.put_line('Fecha sIN : '|| to_char(K_FEC_PRO));	
dbms_output.put_line('Fecha: '||to_char(K_FEC_PRO,'dd/mm/yyyy'));	
dbms_output.put_line('Codigo : '||K_CODERROR);	
dbms_output.put_line('Mensaje : '||K_DESCERROR);	
dbms_output.put_line('Total de Registros: '||K_TOT_REG);	
dbms_output.put_line('Total Procesados: '||K_TOT_PRO);	
dbms_output.put_line('Total con errores: '||K_TOT_ERR);		

EXCEPTION
    when OTHERS then
      dbms_output.put_line(': '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
 
END;
/

EXIT
EOP

pMessage "Se valida la existencia de errores durante la ejecución"

VALIDA_EJEC_SP=`grep 'ORA-' ${DIRLOG}/${FILELOG} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B=`grep 'SP2-' ${DIRLOG}/${FILELOG} | wc -l | sed 's/ //g'`

if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
    pMessage "Hubo un durante la ejecución del SP PKG_CC_PTOSTFI.ADMPSI_TFICMBTIT" 
    pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de CAMBIO DE TITULARIDAD DE CLIENTES TFI . Se encontraron errores." 
    echo "Buen día, ocurrio un problema al ejecutar el SP de PKG_CC_PTOSTFI.ADMPSI_TFICMBTIT." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "CAMBIO DE TITULARIDAD DE CLIENTES TFI . Se encontraron errores" $IT_MAIL >> $FILELOG		
    exit
fi
pMessage "Ejecución de SP fue satisfactorio"

pMessage "Se procede a ejecutar el SP PKG_CC_PTOSTFI.ADMPSI_ETFICMBTIT"

sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> ${DIRERR_CAMTITU}/${FILEERR}

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
  cursorCambTitu ty_cursor;		
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
  c_fec_act DATE;  
  c_msje_error varchar2(400);
  v_fecha date;
  
  BEGIN
  
  dbms_output.enable(NULL);
  
  $PCLUB_OW.PKG_CC_PTOSTFI.ADMPSI_ETFICMBTIT(trunc(sysdate),cursorCambTitu);
   
  LOOP
  
  fetch cursorCambTitu into c_cod_cli,c_tipo_doc,c_num_doc,c_nom_cli,c_ape_cli,c_sexo,c_est_civil,c_email,c_depa,c_prov,c_dist,c_fec_act,c_msje_error;
  exit when cursorCambTitu%notfound;
  
  DBMS_OUTPUT.put_line(c_cod_cli || '|' || c_tipo_doc || '|' || c_num_doc || '|' ||c_nom_cli || '|' || c_ape_cli || '|' || c_sexo || '|' || c_est_civil || '|' || c_email || '|' || c_depa || '|' || c_prov || '|' || c_dist || '|' || c_fec_act || '|' || c_msje_error);
  
  END LOOP;
  
  CLOSE cursorCambTitu;
  
  EXCEPTION
    when OTHERS then
      dbms_output.put_line(': '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
  END;
/
EXIT

EOP

#---
	
CANT_DATA=`cat ${DIRERR_CAMTITU}/${FILEERR} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP=`grep 'ORA-' ${DIRERR_CAMTITU}/${FILEERR} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B=`grep 'SP2-' ${DIRERR_CAMTITU}/${FILEERR} | wc -l | sed 's/ //g'`
    
if [ $CANT_DATA = 0 ] ; then
	pMessage "El archivo no trajo datos, asi que no se podra generar en la carpeta destino."
	rm ${DIRERR_CAMTITU}/${FILEERR}
else
	pMessage "Se ha generado el archivo ${DIRERR_CAMTITU}/${FILEERR}"
fi

if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
	cat ${DIRERR_CAMTITU}/${FILEERR} >> ${DIRLOG}/${FILELOG}
    pMessage "Hubo un durante la ejecución del SP PKG_CC_PTOSTFI.ADMPSI_EALTACLI_TFI"     	
	exit
fi

pMessage "Ejecución de SP fue satisfactorio"

pMessage "Termino proceso"
pMessage "********** FINALIZANDO PROCESO ********** " 
pMessage "Fin de proceso "
pMessage "************************************" 
pMessage "Ruta del Archivo log : ${DIRLOG}/${FILELOG}" 
pMessage "" 
			
exit

