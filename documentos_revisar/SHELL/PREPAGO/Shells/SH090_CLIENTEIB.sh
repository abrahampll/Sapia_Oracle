#!/bin/sh -x
#*************************************************************
#* PROGRAMA              : SH090_ADMPSI_ENT_BON_PRE.sh
#* DESCRIPCION           : Actualizar los puntos ganados por el cliente IB asociado a una línea prepago desde el primer envió de información realizado por Interbank.
#* EJECUCION             : Control-M
#* FECHA                 : 25/07/2011
#* VERSION               : 1.0
#*************************************************************
#clear

# Inicializacion de Variables
HOME_GAT=/home/usrclaroclub/CLAROCLUB/Interno/Prepago
. $HOME_GAT/Bin/.varset
. $HOME_GAT/Bin/.mailset
. $HOME_GAT/Bin/.passet

cd ${DIRSHELL}

#-----------------------------------------------------------------
#	FUNCION PARA MANEJO DEL LOG
#-----------------------------------------------------------------
pMessage () {   
   LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
   echo "($LOGDATE) $*" 
   echo "($LOGDATE) $*"  >> $DIRLOG/$FILELOG
} # pMessage	

NAME_SHELL=SH090_ADMPSI_ENT_BON_PRE
NPROCESO=$$
HOST=`hostname`
NRO_IP=`cat /etc/hosts | grep $HOST | awk '{print $1}'`
USUARIO=`whoami`
VALIDTIME=`date +%Y%m%d`
FECHALOG=`date +%Y%m%d_%H%M%S`
FECHA_TRACKLOG=`date +%Y%m`
FCORREO=`date +%d/%m/%Y' '%H:%M:%S`
FECHA_HORA=`date +"%d-%m-%Y %H:%M:%S"`
#**************** ARCHIVOS GENERALES ************************
FILELOG=LOG_SH090_ADMPSI_ENT_BON_PRE_$FECHALOG.log
FILEAUD=AUD_SH090_ADMPSI_ENT_BON_PRE_$FECHA_TRACKLOG.log
#********************* VARIABLES RAUTONX ********************
ARCH_TEMP2R=TEMP_ADMPSI_ENT_BON_PRE.txt


#*******PROCESO DE ASOCIAR CLIENTES CC Y CLIENTES IB****************
#demora3=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "************************************* " 
pMessage "Iniciando Proceso                     " 
pMessage "Fecha y Hora  : ${FECHA_HORA}         " 
pMessage "Usuario :  ${USUARIO}               " 
pMessage "Shell : ${NAME_SHELL}                     " 
pMessage "Ip : ${NRO_IP}                       " 
pMessage "*************************************"$'\n' 

pMessage "Se inicia la ejecucion del procedimiento almacenado ${PCLUB_OW}.PKG_CLAROCLUB.ADMPSI_ENT_BON_PRE"$'\n'	

sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> ${DIRLOG}/${ARCH_TEMP2R}
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

K_CODERROR  NUMBER;
K_DESCERROR VARCHAR2(50);
K_NUMREGTOT NUMBER;
K_NUMREGPRO NUMBER;
K_NUMREGERR NUMBER;

BEGIN

$PCLUB_OW.PKG_CLAROCLUB.ADMPSI_ENT_BON_PRE(K_CODERROR,K_DESCERROR,K_NUMREGTOT,K_NUMREGPRO,K_NUMREGERR);
											 
dbms_output.put_line('Codigo error: '||K_CODERROR);
dbms_output.put_line('Descripcion error: '||K_DESCERROR);
dbms_output.put_line('Total Registros: '||K_NUMREGTOT);
dbms_output.put_line('Total Procesados: '||K_NUMREGPRO);
dbms_output.put_line('Total Errores: '||K_NUMREGERR);
 
EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
 
END;
/

EXIT
EOP


cat ${DIRLOG}/${ARCH_TEMP2R} 
cat ${DIRLOG}/${ARCH_TEMP2R} >> ${DIRLOG}/${FILELOG}


VALIDA_RESULT_EXO1_A=`grep 'ORA-' ${DIRLOG}/${ARCH_TEMP2R} | wc -l | sed 's/ //g'`
VALIDA_RESULT_EXO2_A=`grep 'SP2-' ${DIRLOG}/${ARCH_TEMP2R} | wc -l | sed 's/ //g'`

if [ ${VALIDA_RESULT_EXO1_A} -ne 0 ] || [ ${VALIDA_RESULT_EXO2_A} -ne 0 ] ; then

    pMessage $'\n'"`date +%H:%M:%S` | ERROR en la ejecucion del procedure de CLAROCLUB PREPAGO: ${PCLUB_OW}.PKG_CLAROCLUB.ADMPSI_ENT_BON_PRE. Por favor verificar el siguiente archivo: $DIRLOG/$ARCH_TEMP2R" >> $DIRLOG/$FILELOG
    echo $'\n'"`date +%H:%M:%S` | Problemas en la ejecucion del procedimiento almacenado ${PCLUB_OW}.PKG_CLAROCLUB.ADMPSI_ENT_BON_PRE segun la rutina PL/SQL. Por favor verificar el siguiente archivo: $DIRLOG/$ARCH_TEMP2R"
    echo $'\n'"Error al ejecutar el procedure de CLAROCLUB PREPAGO: ${PCLUB_OW}.PKG_CLAROCLUB.ADMPSI_ENT_BON_PRE. Por favor, verificar el sig. archivo:"$'\n'"$DIRLOG/$ARCH_TEMP2R"$'\n'$'\n'"FECHA: ${FCORREO}"$'\n'$'\n'"NRO. PROCESO : ${NPROCESO}"$'\n'$'\n'"FUENTE : TIM-FTP1"| mail -s "Error al ejecutar el procedure de CLAROCLUB PREPAGO – error al Actualizar los puntos ganados por el cliente IB asociado a una línea prepago" $IT_OPERADOR
    
else
	
	echo $'\n'
	pMessage "Termino ejecucion del procedimiento exitosamente. Se actualizaron los puntos ganados por el cliente IB asociado a una línea prepago desde el primer envió de información realizado por Interbank"$'\n'
	rm -f ${DIRLOG}/${ARCH_TEMP2R}
fi

pMessage "**********************************************************" 
pMessage "Fin de proceso "
pMessage "Ruta del Archivo log : ${DIRLOG}/${FILELOG}" 
pMessage "**********************************************************" 
			
exit
