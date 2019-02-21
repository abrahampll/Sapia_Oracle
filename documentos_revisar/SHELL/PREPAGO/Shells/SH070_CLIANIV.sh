#!/bin/sh -x
#*************************************************************
#Programa      :  SH070_CLIANIV
#Autor         :  Jorge Andres Thomburne Vidales 
#Descripcion   :  Exporta datos de los clientes que han cumplido
#		       	   aniversario desde su activacion
#		       
#FECHA_HORA    :  10/01/2010
#.
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

FECHA=`date +%Y%m%d`

FECHA_HORA=`date +%Y%m%d%H%M%S`
HORA=`date +%H%M%S`

MES_DIA=`date +%m%d`
MES=`date +%m`
DIA=`date +%d`
ANO=`date +%Y`

# ip de TIM-FTP1
HOST=`hostname`
IP_SERV=`cat /etc/hosts | grep -v '#' | grep ${HOST} | awk '{print $1}'`
#usuario
USER_SERV=`whoami`
SHELL=SH070_CLIANIV.sh
FILEDATA=ANIV_INPUT_${FECHA_HORA}.TXT
FILELOG=SH070_CLIANIV_${FECHA_HORA}.log

demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "************************************* " 
pMessage "Iniciando proceso                     " 
pMessage "Fecha y Hora  : ${FECHA_HORA}         " 
pMessage "Usuario :  ${USER_SERV}               " 
pMessage "Shell : ${SHELL}                      " 
pMessage "Ip : ${IP_SERV}                       " 
pMessage "*************************************"$'\n' 


pMessage "DATOS UTILIZADOS"
pMessage "MES_DIA : $MES_DIA "
pMessage "MES : $MES "
pMessage "DIA : $DIA "
pMessage "ANO : $ANO "

pMessage "Se invoca al IF WHERE MES_DIA = (0101 y 0103 o 1223)"

if [ $MES_DIA -ge "0101" ] && [ $MES_DIA -le "0103" ] || [ $MES_DIA -gt "1223" ] ; then

pMessage "Se ejecuta el SELECT - CUMPLE FUNCION IF $MES_DIA "	
	
	if [ $MES_DIA -ge "0101" ] && [ $MES_DIA -le "0103" ] ; then
	pMessage "Entro al if"
	sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP 
	WHENEVER SQLERROR EXIT SQL.SQLCODE;
	 SET pagesize 0
	 SET linesize 400
	 SET SPACE 0
	 SET feedback off
	 SET trimspool on
	 SET termout off
	 SET heading off
	 SET verify off
	 SET echo off
	 SET serveroutput on size 1000000
	 SPOOL ${DIRSALIDA}/${FILEDATA}

	  SELECT ADMPV_COD_CLI ||'|'||to_char(ADMPD_FEC_ACTIV,'ddmmyyyy')
	  FROM $PCLUB_OW.ADMPT_CLIENTE
	  WHERE TO_CHAR(ADMPD_FEC_ACTIV,'MMDD') BETWEEN '1224'AND '1231'
	  AND '$ANO'-TO_CHAR(ADMPD_FEC_ACTIV,'YYYY')>1
	  AND ADMPV_COD_TPOCL='3'
	  AND ADMPC_ESTADO='A'
	  union all
	  SELECT ADMPV_COD_CLI ||'|'||to_char(ADMPD_FEC_ACTIV,'ddmmyyyy')
	  FROM $PCLUB_OW.ADMPT_CLIENTE
	  WHERE TO_CHAR(ADMPD_FEC_ACTIV,'MMDD') BETWEEN '0101' AND '0103'
	  AND '$ANO'-TO_CHAR(ADMPD_FEC_ACTIV,'YYYY')>=1
	  AND ADMPV_COD_TPOCL='3'
	  AND ADMPC_ESTADO='A';
	  select '' from dual;
	  /
	SPOOL OFF;
	
	EXIT
EOP

else
pMessage "Se ejecuta el SELECT - CUMPLE FUNCION ELSE"	

 sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP 	
WHENEVER SQLERROR EXIT SQL.SQLCODE;
 SET pagesize 0
 SET linesize 400
 SET SPACE 0
 SET feedback off
 SET trimspool on
 SET termout off
 SET heading off
 SET verify off
 SET echo off
 SET serveroutput on size 1000000
 SPOOL ${DIRSALIDA}/${FILEDATA}

SELECT ADMPV_COD_CLI ||'|'||to_char(ADMPD_FEC_ACTIV,'ddmmyyyy')
      FROM $PCLUB_OW.ADMPT_CLIENTE
      WHERE TO_CHAR(ADMPD_FEC_ACTIV,'MMDD') BETWEEN '1224'AND '1231'
      AND '$ANO'-TO_CHAR(ADMPD_FEC_ACTIV,'YYYY')>=1
      AND ADMPV_COD_TPOCL='3'
      AND ADMPC_ESTADO='A'
      union all
      SELECT ADMPV_COD_CLI ||'|'||to_char(ADMPD_FEC_ACTIV,'ddmmyyyy')
      FROM $PCLUB_OW.ADMPT_CLIENTE
      WHERE TO_CHAR(ADMPD_FEC_ACTIV,'MMDD') BETWEEN '0101' AND '0103'
      AND '$ANO'-TO_CHAR(ADMPD_FEC_ACTIV,'YYYY')>=1
      AND ADMPV_COD_TPOCL='3'
      AND ADMPC_ESTADO='A';
	  select '' from dual;
/
SPOOL OFF;

EXIT
EOP

fi
      

else
	pMessage "ENTRA AL ELSE año : $ANO : mes_dia : $MES_DIA"
	
            if [ $MES_DIA -gt "0103" ] && [ $MES_DIA -lt "1224" ] ; then
			pMessage "Se ejecuta el else donde el mes_dia = 1224 o mesdia = 0103"
				if [ $DIA -lt "04" ]; then
				pMessage "Se ejecuta cuando el dia es 04"
					MES_FIN=$MES
					MES_INI=`expr ${MES} - 1`
					sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP
WHENEVER SQLERROR EXIT SQL.SQLCODE;
 SET pagesize 0
 SET linesize 400
 SET SPACE 0
 SET feedback off
 SET trimspool on
 SET termout off
 SET heading off
 SET verify off
 SET echo off
 SET serveroutput on size 1000000
 SPOOL ${DIRSALIDA}/${FILEDATA}
      SELECT ADMPV_COD_CLI ||'|'||to_char(ADMPD_FEC_ACTIV,'ddmmyyyy')
      FROM $PCLUB_OW.ADMPT_CLIENTE
      WHERE TO_CHAR(ADMPD_FEC_ACTIV,'MMDD') BETWEEN  to_char(to_date(to_char($MES_INI,'00')||'24','mmdd'),'mmdd') AND $MES_FIN||'03'
      AND '$ANO'-TO_CHAR(ADMPD_FEC_ACTIV,'YYYY')>=1
      AND ADMPV_COD_TPOCL='3'
      AND ADMPC_ESTADO='A';
	  select '' from dual;
/
SPOOL OFF;

EXIT
EOP
				fi 
pMessage "Se ejecuta cuando el dia es 23"  
				
				if [ $DIA -gt "23" ]; then
					MES_INI=$MES
					MES_FIN=`expr ${MES} + 1`
					sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP 
WHENEVER SQLERROR EXIT SQL.SQLCODE;
 SET pagesize 0
 SET linesize 400
 SET SPACE 0
 SET feedback off
 SET trimspool on
 SET termout off
 SET heading off
 SET verify off
 SET echo off
 SET serveroutput on size 1000000
 SPOOL ${DIRSALIDA}/${FILEDATA}
	  SELECT ADMPV_COD_CLI ||'|'||to_char(ADMPD_FEC_ACTIV,'ddmmyyyy')
      FROM $PCLUB_OW.ADMPT_CLIENTE
      WHERE TO_CHAR(ADMPD_FEC_ACTIV,'MMDD') BETWEEN  '$MES_INI'||'24' AND to_char(to_date(to_char(${MES_FIN},'00')||'03','mmdd'),'mmdd')
      AND '$ANO'-TO_CHAR(ADMPD_FEC_ACTIV,'YYYY')>=1
      AND ADMPV_COD_TPOCL='3'
      AND ADMPC_ESTADO='A';
	  select '' from dual;
/
SPOOL OFF

EXIT
EOP
				fi
      pMessage "Se ejecuta cuando el dia : dia = es 03 y 14"      
				if [ $DIA -gt "03" ] && [ $DIA -lt "14" ]; then
					MES_INI=$MES
					MES_FIN=$MES
					sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP 
WHENEVER SQLERROR EXIT SQL.SQLCODE;
 SET pagesize 0
 SET linesize 400
 SET SPACE 0
 SET feedback off
 SET trimspool on
 SET termout off
 SET heading off
 SET verify off
 SET echo off
 SET serveroutput on size 1000000
 SPOOL ${DIRSALIDA}/${FILEDATA}
	  SELECT ADMPV_COD_CLI ||'|'||to_char(ADMPD_FEC_ACTIV,'ddmmyyyy')
      FROM $PCLUB_OW.ADMPT_CLIENTE
      WHERE TO_CHAR(ADMPD_FEC_ACTIV,'MMDD') BETWEEN '$MES_INI'||'04' AND '$MES_FIN'||'13'
      AND '$ANO'-TO_CHAR(ADMPD_FEC_ACTIV,'YYYY')>=1
      AND ADMPV_COD_TPOCL='3'
      AND ADMPC_ESTADO='A';
	  select '' from dual;
/
SPOOL OFF
EXIT
EOP
				fi
      pMessage "Se ejecuta cuando el dia es 13 y 24" 
				if [ $DIA -gt "13" ] && [ $DIA -lt "24" ]; then	
					MES_INI=$MES
					MES_FIN=$MES
 sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOF
 WHENEVER SQLERROR EXIT SQL.SQLCODE;
 SET pagesize 0
 SET linesize 400
 SET SPACE 0
 SET feedback off
 SET trimspool on
 SET termout off
 SET heading off
 SET verify off
 SET echo off
 SET serveroutput on size 1000000
 SPOOL ${DIRSALIDA}/${FILEDATA}
SELECT ADMPV_COD_CLI ||'|'||to_char(ADMPD_FEC_ACTIV,'ddmmyyyy')
      FROM $PCLUB_OW.ADMPT_CLIENTE
      WHERE TO_CHAR(ADMPD_FEC_ACTIV,'MMDD') BETWEEN '$MES_INI'||'14' AND '$MES_FIN'||'23'
      AND '$ANO'-TO_CHAR(ADMPD_FEC_ACTIV,'YYYY')>=1
      AND ADMPV_COD_TPOCL='3'
      AND ADMPC_ESTADO='A';
	  select '' from dual;
/
SPOOL OFF
EXIT;
EOF
				
		fi
	fi
fi
      pMessage "llega al tmp" 
#script utilizado para anular el problema del reconocimiento de la ultima linea 
#de archivos de texto
TMP1=${DIRLOG}/TEMPDATA1.tmp
	echo "" >> ${DIRSALIDA}/${FILEDATA}
	cat ${DIRSALIDA}/${FILEDATA} | sed '/^$/d' > $TMP1
	cat $TMP1 > ${DIRSALIDA}/${FILEDATA}

	rm -f $TMP1
	
pMessage "Se valida la existencia de errores durante la ejecución"
VALIDAT_CTL=`grep 'ORA-' ${DIRSALIDA}/${FILEDATA} | wc -l`
if [ $VALIDAT_CTL -ne 0 ]
	then
	
	cat ${DIRSALIDA}/${FILEDATA} >> ${DIRLOG}/${FILELOG}
	
	pMessage `date +"%Y-%m-%d %H:%M:%S"` "ERROR en la ejecucion del pl/sql del Shell de CLIENTES DE ANIVERSARIO CLAROCLUB PREPAGO : ${PCLUB_OW}.PKG_CC_PREPAGO.ADMPSS_PREGENANIV. Contacte al administrador."$'\n' 
    echo  $'\n'"Error al ejecutar el pl/sql del Shell CLIENTES DE ANIVERSARIO CLAROCLUB PREPAGO : ${PCLUB_OW}.PKG_CC_PREPAGO.ADMPSS_PREGENANIV"| mail -s "CLIENTES DE ANIVERSARIO CLAROCLUB PREPAGO – error al exportar datos" $IT_OPERADOR
	pMessage "Termino proceso"
	pMessage "************************************" 
	pMessage " FINALIZANDO PROCESO..............."
	pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso " 
	pMessage "************************************" 
	echo "`date +%Y-%m-%d@%H:%M:%S` Fin de proceso"$'\n'
	echo $'\n'
	echo "Ruta del Archivo log : " ${DIRLOG}/${FILELOG}
	echo $'\n'
	exit	
fi

pMessage "Termino proceso"
pMessage "********** FINALIZANDO PROCESO ********** " 
pMessage "Fin de proceso "
pMessage "************************************" 
pMessage "Ruta del Archivo log : ${DIRLOG}/${FILELOG}" 
pMessage "" 


			
exit