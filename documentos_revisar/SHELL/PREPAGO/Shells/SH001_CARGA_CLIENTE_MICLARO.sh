#*************************************************************
#Programa      :  SH001_CARGA_CLIENTE_MICLARO.sh
#Autor         :  Deysi Galvez Medrano
#Descripcion   :  Registra lineas prepago activas
#FECHA_HORA    :  09/08/2011
#MODIFICADO	   :  23/11/2011
#*************************************************************
clear
# Inicializacion de Variables
HOME=/home/usrclaroclub/CLAROCLUB/Interno/Prepago
. $HOME/Bin/.varset
. $HOME/Bin/.mailset
. $HOME/Bin/.passet 

cd ${DIRSHELL}
#-----------------------------------------------------------------
#	FUNCION PARA MANEJO DEL LOG
#-----------------------------------------------------------------
pMessage () {
LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
echo "($LOGDATE) $*" 
echo "($LOGDATE) $*"  >> $DIRLOG/$LOGFILE
}

NPROCESO=$$
FECHA=`date +%d%m%Y`
FECHA_HORA=`date +%Y%m%d%H%M%S`
HORA=`date +%H%M%S`
HOST=`hostname`
IP_SERV=`cat /etc/hosts | grep -v '#' | grep ${HOST} | awk '{print $1}'`
USER_SERV=`whoami`
SHELL=SH001_CARGA_CLIENTE_MICLARO.sh
LOGFILE=LOG_CARGA_MICLARO_${FECHA_HORA}.log
ARCH_TEMP=TEM_Conexion_MICLARO_$FECHALOG.log
ARCH_TEMP_1=TEM_Conexion_CLARIFY_$FECHALOG.log

demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "************************************* " 
pMessage "Iniciando proceso                     " 
pMessage "Fecha y Hora : ${FECHA_HORA}          " 
pMessage "Usuario :  ${USER_SERV}               " 
pMessage "Shell : ${SHELL}                      " 
pMessage "Ip : ${IP_SERV}                       " 
pMessage "*************************************"$'\n' 

pMessage "Se ejecuta el SP PKG_CC_PREPAGO.ADMPSI_CARGA_MICLARO para el proceso de CARGA CLIENTE MICLARO"	

sqlplus -s ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> ${DIRLOG}/${ARCH_TEMP}
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

V_FECHA  		DATE;
V_CODERROR 		NUMBER;
V_DESCERROR  	VARCHAR2(200); 
V_NUMREGTOT  	NUMBER; 
V_NUMREGPRO  	NUMBER; 
V_NUMREGERR  	NUMBER;
BEGIN

dbms_output.enable(NULL);

SELECT trunc(sysdate - 1) INTO v_FECHA FROM DUAL;

$PCLUB_OW.PKG_CC_PREPAGO.ADMPSI_CARGA_MICLARO(V_FECHA, V_CODERROR, V_DESCERROR, V_NUMREGTOT, V_NUMREGPRO, V_NUMREGERR);
 
dbms_output.put_line('Indicador: '||v_CODERROR);
dbms_output.put_line('Descripcion: '||v_DESCERROR);
dbms_output.put_line('Total Registros: '||v_NUMREGTOT);
dbms_output.put_line('Total Procesados: '||v_NUMREGPRO);
dbms_output.put_line('Total Errores: '||v_NUMREGERR);  
   
EXCEPTION
    when OTHERS then
      dbms_output.put_line(': '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
 
END;
/

EXIT
EOP

pMessage "Se valida la ejecución del procedimiento"	
VALIDAT_ORA=`grep 'ORA-' ${DIRLOG}/${ARCH_TEMP} | wc -l`
VALIDAT_SP=`grep 'SP2-' ${DIRLOG}/${ARCH_TEMP} | wc -l | sed 's/ //g'`

if [ ${VALIDAT_ORA} -ne 0 ] || [ ${VALIDAT_SP} -ne 0 ] ;
	then
	pMessage "Problemas en la ejecucion del SP : ${PCLUB_OW}.PKG_CC_PREPAGO.ADMPSI_CARGA_MICLARO, Por favor verificar el siguiente archivo: ${DIRLOG}/${ARCH_TEMP}"    
    echo $'\n'": PROBLEMAS EN LA EJECUCION DEL PROCEDIMIENTO ALMACENADO ... SEGUN LA RUTINA PL/SQL, POR FAVOR VERIFICAR EL SIGUIENTE ARCHIVO:"$'\n'$'\n'"${DIRLOG}/${ARCH_TEMP}"$'\n'" FECHA: ${FECHA}"$'\n'$'\n'"NRO. PROCESO : ${NPROCESO}"$'\n'$'\n'"FUENTE: TIM-FTP1 "| mail -s "CARGA DE CLIENTES MICLARO . Se encontraron errores" $IT_OPERADOR	
	
fi

ARCH_TIPI=TIPI_SH001_$FECHATRAMA.txt
TMP_TIPI=$DIRSALIDA/$ARCH_TIPI

pMessage "Obteniendo los números para la tipificacion"

sqlplus -s ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> $TMP_TIPI
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

v_CODERROR 		NUMBER;
v_DESCERROR  	VARCHAR2(200); 
TYPE TY_CURSOR  IS REF CURSOR;
CUR_TIPI 		TY_CURSOR;

K_TELEFONO		VARCHAR2(40);
BEGIN

dbms_output.enable(NULL);

$PCLUB_OW.PKG_CC_ENVIO_SMS.ADMPSS_TIPIFICACIONES_MICLARO(v_CODERROR, v_DESCERROR, CUR_TIPI);
 
LOOP  
  FETCH CUR_TIPI INTO  K_TELEFONO;
  EXIT WHEN CUR_TIPI%NOTFOUND;
  
  DBMS_OUTPUT.PUT_LINE(K_TELEFONO);
  
END LOOP;
  
 CLOSE CUR_TIPI; 
  
EXCEPTION
    when OTHERS then
      dbms_output.put_line(': '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
 
END;
/

EXIT
EOP

pMessage "Salio del SP"

VALIDA_ORA_TIPI=`grep 'ORA-' $TMP_TIPI | wc -l | sed 's/ //g'`
VALIDA_SP_TIPI=`grep 'SP2-' $TMP_TIPI | wc -l | sed 's/ //g'`
    
    
if [ ${VALIDA_ORA_TIPI} -ne 0 ] || [ ${VALIDA_SP_TIPI} -ne 0 ] ; then
	
    pMessage "Hora y Fecha: $FECHA_HORA"
    pMessage "Problemas en la ejecucion del SP : $PCLUB_OW.PKG_CC_PREPAGO.ADMPSS_TIPIFICACIONES_MICLARO, Por favor verificar el siguiente archivo: ${TMP_TIPI}"   
	echo $'\n'": PROBLEMAS EN EL REGISTRO TIPIFICACION... SEGUN LA RUTINA PL/SQL, POR FAVOR VERIFICAR EL SIGUIENTE ARCHIVO:"$'\n'$'\n'"${TMP_TIPI}"$'\n'" FECHA: ${FECHA}"| mail -s "EN EL PROCESO DE NROS PARA LA TIPIFICACION" $IT_OPERADOR
	
	exit
fi

dos2unix $TMP_TIPI

while read FIELDTIPI
do

TELEFONO_T=`echo $FIELDTIPI | sed 's/\\r//g'|awk '{print $1}' `

sqlplus -s ${USER_BD_CLFY}/${CLAVE_BD_CLFY}@${SID_BD_CLFY} <<EOP >> ${DIRLOG}/${ARCH_TEMP_1}
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

V_TELEFONO		VARCHAR(20);
V_TIPO  		VARCHAR2(100); 
V_CLASE  		VARCHAR2(100); 
V_SUBCLASE  	VARCHAR2(100); 
V_METODO		VARCHAR2(100); 
V_TIPO_INTER	VARCHAR2(100); 
V_AGENTE		VARCHAR2(100); 
V_USR_PROCESO	VARCHAR2(100); 
V_NOTAS			VARCHAR2(255); 
V_INTERACCION	VARCHAR2(40);
V_FLAG_ERROR	VARCHAR2(40);
V_MENSAJES		VARCHAR2(255);

BEGIN

V_TELEFONO := $TELEFONO_T;
V_TIPO := '$TIPO_CLFY';
V_CLASE := '$CLASE_CLFY';
V_SUBCLASE := '$SUB_CLASE_CLFY';
V_METODO := '$METODO_CLFY';
V_TIPO_INTER := '$TIPO_INTER_CLFY';
V_AGENTE := '$AGENTE_CLFY';
V_USR_PROCESO := '$PROCESO_CLFY';
V_NOTAS := '$NOTAS_CLFY';

$CLFY_OW.PCK_INTERACT_CLFY.SP_CREATE_INTERACT('','','',V_TELEFONO,V_TIPO,V_CLASE,V_SUBCLASE,V_METODO,V_TIPO_INTER,V_AGENTE,V_USR_PROCESO,0,V_NOTAS,'0','Ninguno',V_INTERACCION,V_FLAG_ERROR,V_MENSAJES);

dbms_output.put_line('Interaccion: '||V_INTERACCION);
dbms_output.put_line('Flag : '||V_FLAG_ERROR); 
 
   
EXCEPTION
    when OTHERS then
      dbms_output.put_line(': '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
 
END;
/

EXIT
EOP

VALIDA_ORA_CLFY=`grep 'ORA-' ${DIRLOG}/${ARCH_TEMP_1} | wc -l | sed 's/ //g'`
VALIDA_SP_CLFY=`grep 'SP2-' ${DIRLOG}/${ARCH_TEMP_1} | wc -l | sed 's/ //g'`
    
    
if [ ${VALIDA_ORA_CLFY} -ne 0 ] || [ ${VALIDA_SP_CLFY} -ne 0 ] ; then
	
    pMessage "Hora y Fecha: $FECHA_HORA"
    pMessage "Problemas en la ejecucion del SP : $CLFY_OW.PCK_INTERACT_CLFY.SP_CREATE_INTERACT, Por favor verificar el siguiente archivo: ${DIRLOG}/${ARCH_TEMP_1}"   
	echo $'\n'": PROBLEMAS EN EL REGISTRO DE TIPIFICACIONES.. SEGUN LA RUTINA PL/SQL, POR FAVOR VERIFICAR EL SIGUIENTE ARCHIVO:"$'\n'$'\n'"${DIRLOG}/${ARCH_TEMP_1}"$'\n'" FECHA: ${FECHA}"| mail -s " EN EL PROCESO DE REGISTRO DE TIPIFICACION" $IT_OPERADOR
	
	exit
fi

done < $TMP_TIPI

rm -f $TMP_TIPI

pMessage "Culmino el proceso de Carga MICLARO"
pMessage "Fin del proceso"
