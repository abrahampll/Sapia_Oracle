#! /bin/ksh
#*************************************************************
#* DESCRIPCION           : Actualizacion BAJA CANJE - SOT   SGA - HFC*
#* EJECUCION             :                                      *
#* AUTOR                 : JCGT                                 *
#* FECHA                 : 25-08-2012   VERSION : v1.0          *
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

FECHA=`date +%Y%m%d_%H%M%S`
FARCH=`date +%Y%m%d`
FILELOG=$DIRLOGHFC/SH008_PROC_BAJACANJE_$FECHA.log
RUTANAME=$DIR_ENT_CANJE
ARCHNAME=BAJACANJESOT_$FECHA.CCL

# Inicio
demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "*************************************" 
pMessage "Iniciando proceso              " 
pMessage "Fecha y Hora : $demora               " 
pMessage "*************************************" 
pMessage $'\n'"Iniciando proceso ....$demora"$'\n'
pMessage "procesando..."




sqlplus -s $USER_BD_SGA/$CLAVE_BD_SGA@$SID_BD_SGA <<EOP  >> ${RUTANAME}/${ARCHNAME}
WHENEVER SQLERROR EXIT SQL.SQLCODE;
 SET pagesize 0
 SET linesize 30000
 SET SPACE 0
 SET feedback off
 SET trimspool on
 SET termout off
 SET heading off
 SET verify off
 SET serveroutput on size 1000000
 SET buffer       500000000;
 SET echo off

 DECLARE 

cod_msje number;
des_msje varchar2(300);
fecha date;

BEGIN

select sysdate into fecha
from dual;

$PCLUB_SGA.PQ_CANJE_PREMIO.p_genera_baja_premio(fecha,cod_msje,des_msje);


IF cod_msje<>0 THEN
        DBMS_OUTPUT.PUT_LINE('SP2-'||des_msje);
END IF;

EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SUBSTR(SQLERRM,200));
END;
/
EXIT

EOP
    
VALIDA_EJEC_SGA=`grep 'ORA-' ${RUTANAME}/${ARCHNAME} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_SGA=`grep 'SP2-' ${RUTANAME}/${ARCHNAME} | wc -l | sed 's/ //g'`

if [ ${VALIDA_EJEC_SGA} -ne 0 ] || [ ${VALIDA_EJEC_SP_SGA} -ne 0 ] ; then
    pMessage "Hubo un error durante la ejeción del SP ATCCORP.PQ_CANJE_PREMIO.p_genera_baja_premio - BD SGA" 
    pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de BAJA DE CANJES – Se encontraron errores" 
	#Debemos avisar al SOA DEL SGA?, DEBEMOS CONSIDERAR SU CORREO DENTRO DEL MAILSET
    echo "Buen día, ocurrio un problema al ejecutar el SP de ATCCORP.PQ_CANJE_PREMIO.p_genera_baja_premio." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "HFC: Baja de Canje – Se encontraron errores" $IT_MAIL >> $FILELOG		
    exit
fi

pMessage "Ejecución de SP fue satisfactorio"

pMessage "Se finalizó el proceso de Ejecución de p_genera_baja_premio"

pMessage "Se finalizó el proceso de Ejecución de BAJA DE CANJES"

pMessage "Fin de todo el Proceso de BAJA DE CANJES"

exit
