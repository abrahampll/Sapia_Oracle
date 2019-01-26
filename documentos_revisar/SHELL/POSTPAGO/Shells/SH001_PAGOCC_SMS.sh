#! /bin/ksh
#*************************************************************
#* DESCRIPCION           : Pagos - Claro Club SMS                                   *
#* EJECUCION             : Control-D                                                          *
#* AUTOR                 : E76350 -  Luis De la Fuente                                   *
#* FECHA                 : 23/11/2011   VERSION : v1.0                        *
#* FECHA MOD .           :                         *
#*************************************************************

#Iniciación de Variables
# Inicializacion de Variables

HOME=/home/usrclaroclub/CLAROCLUB/Interno/Postpago
. $HOME/Bin/.varset
. $HOME/Bin/.mailset
. $HOME/Bin/.passet 

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
FILELOG=$DIRLOGPOST/SH001_IMPPAGO_SMS_$FECHA.log
VAR_COUNT=0
contador=1
ARCHPRMT2=$1
RUTANAME=$DIRENTRADAPOST
MENSAJES_CARGO=MENSAJES_CARGO_$FECHA.txt
USUARIO=`whoami`
HOST=`hostname`
IP_AUDIT=`cat /etc/hosts | grep $HOST | awk '{print $1}'`

demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "*************************************" 
pMessage "Iniciando proceso de Envio SMS              " 
pMessage "Fecha y Hora : $demora               " 
pMessage "*************************************" 

pMessage "Obtenemos el mensaje para Cargo fijo"

sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOF >> ${RUTANAME}/${MENSAJES_CARGO}
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
k_flag varchar2(10);
k_mensaje varchar2(1000);
k_coderror number;
k_descerror varchar2(40);
begin
k_flag:='CARGFIJO';

  $PCLUB_OW.pkg_cc_envio_sms.admpss_obtenermensaje_post(k_flag,
                                              k_mensaje,
                                              k_coderror,
                                              k_descerror);
                                              
DBMS_OUTPUT.put_line(k_mensaje);  

  EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
end;
/
exit 
EOF

dos2unix ${RUTANAME}/${MENSAJES_CARGO}


CANT_SMS2=`cat ${RUTANAME}/${MENSAJES_CARGO} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SPSMS2=`grep 'ORA-' ${RUTANAME}/${MENSAJES_CARGO} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_BSMS2=`grep 'SP2-' ${RUTANAME}/${MENSAJES_CARGO} | wc -l | sed 's/ //g'`
    
if [ $CANT_SMS2 = 0 ] ; then
	pMessage "El archivo ${RUTANAME}/${MENSAJES_CARGO} esta vacio, no existen datos para procesar"
    pMessage "Ruta del Archivo log : " $FILELOG	
	exit
fi

if [ ${VALIDA_EJEC_SPSMS2} -ne 0 ] || [ ${VALIDA_EJEC_SP_BSMS2} -ne 0 ] ; then	
    pMessage "Hubo un error durante la importacion del mensaje para cargo fijo"
    pMessage "Ruta del Archivo log : " $FILELOG	    
	exit
fi

pMessage "Cantidad de descripcion mensaje: $CANT_SMS2"

while read FIELD03
do
MENSAJE_C=`echo $FIELD03 | awk 'BEGIN{FS="|"} {print $1}' `
done < ${RUTANAME}/${MENSAJES_CARGO}



ARCHCC_C=$RUTANAME/cctelefonos_cf_$FECHA.txt

sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOF >> ${ARCHCC_C}
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
  k_proceso:='CARGO FIJO';
  $PCLUB_OW.pkg_cc_envio_sms.admpss_obtener_telefonos(k_proceso,
                                            k_estado,
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
CANT_DATA6=`cat ${ARCHCC_C} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP7=`grep 'ORA-' ${ARCHCC_C} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B7=`grep 'SP2-' ${ARCHCC_C} | wc -l | sed 's/ //g'`

if [ $CANT_DATA6 = 0 ] ; then
	pMessage "El archivo $ARCHCC_C esta vacio, no existen datos para procesar"
    pMessage "Ruta del Archivo log : " $FILELOG	   	
fi

if [ ${VALIDA_EJEC_SP7} -ne 0 ] || [ ${VALIDA_EJEC_SP_B7} -ne 0 ] ; then	
    pMessage "Hubo un error al querer obtener los telefonos para cf"       
	pMessage "Ruta del Archivo log : " $FILELOG	
	exit
fi

while [ $VAR_COUNT -lt $CANT_DATA6 ]
do
pMessage "Empieza el proceso de envio de SMS por cargo fijo"

ARCHCC2_C=$RUTANAME/cctelefonos2_cf_$FECHA.txt

sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOF >> ${ARCHCC2_C}
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
  k_estado:='T';
  k_flag:='2';
  k_proceso:='CARGO FIJO';
  $PCLUB_OW.pkg_cc_envio_sms.admpss_obtener_telefonos(k_proceso,
                                            k_estado,
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

CANT_DATA8=`cat ${ARCHCC2_C} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP8=`grep 'ORA-' ${ARCHCC2_C} | wc -l | sed 's/ //g'`
VALIDA_EJEC_SP_B8=`grep 'SP2-' ${ARCHCC2_C} | wc -l | sed 's/ //g'`

if [ $CANT_DATA8 = 0 ] ; then
	pMessage "El archivo $ARCHCC2_C esta vacio, no existen datos para procesar"
    pMessage "Ruta del Archivo log : " $FILELOG	  
fi

if [ ${VALIDA_EJEC_SP8} -ne 0 ] || [ ${VALIDA_EJEC_SP_B8} -ne 0 ] ; then	
    pMessage "Hubo un error al querer obtener los telefonos de cargo fijo"    
	pMessage "Ruta del Archivo log : " $FILELOG	
	exit
fi

pMessage "Cantidad de telefonos a enviar SMS: $CANT_DATA8"

while read FIELD06
do
TELEFONOFINAL=`echo $FIELD06 | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}' `


TELEFONOLISTA=$TELEFONOLISTA","$TELEFONOFINAL


done < ${ARCHCC2_C}


$RUTA_JAVA/java -jar $RUTA_JAR/EnviaSMS.jar $FARCH $IP_AUDIT $USUARIO ${MENSAJE_C}  $IDENTIFICADOR $TELEFONOLISTA ${RUTAWS}
TELEFONOLISTA=""


rm -f ${ARCHCC2_C}



VAR_COUNT=`expr $VAR_COUNT + $CANT_DATA8`
contador=`expr $contador + 1`
done

rm -f ${RUTANAME}/${MENSAJES_CARGO}
rm -f $ARCHCC_C

pMessage "Se finalizó el proceso de envio de SMS por cargo fijo" 

pMessage "Fin de todo el proceso"
exit