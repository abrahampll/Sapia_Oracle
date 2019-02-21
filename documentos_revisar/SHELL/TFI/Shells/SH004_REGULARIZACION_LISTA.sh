#! /bin/ksh
#*************************************************************
#* DESCRIPCION           : Recorre Directorio Regularización TFI
#* EJECUCION             : Control-D                            
#* AUTOR                 : Susana Ramos G.                                 
#* FECHA                 : 05/04/2013   VERSION : v1.1       
#* FECHA MOD .           :                         
#*************************************************************

# Inicialización de Variables
. /home/usrclaroclub/CLAROCLUB/Interno/TFI/Bin/.varset
. /home/usrclaroclub/CLAROCLUB/Interno/TFI/Bin/.passet
. /home/usrclaroclub/CLAROCLUB/Interno/TFI/Bin/.mailset
#-----------------------------------------------------------------
#	FUNCION PARA MANEJO DEL LOG
#-----------------------------------------------------------------
pMessage () {   
  LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
  echo "($LOGDATE) $*" 
  echo "($LOGDATE) $*"  >> $FILELOG
} 

FARCH=`date +%Y%m%d`
FILELOG=$DIRLOG/SH004_REGULARIZACION_LISTA_$FARCH.log
FILERR=$DIRERR_REGUL/PROC_LISTA_ARC_REGUL_$FARCH.ERR

pMessage "******INICIO PROCESO REGULARIZACION*******" 
pMessage "Inicio de Shell  Recorre Archivos    "
pMessage "Directorio Archivo                   "
pMessage "*************************************" 

DIREC=$DIRENT_REGUL

echo "$DIREC"

for file in $(find $DIREC -type f -iname "*.dat" | sort)
do
    echo $file
	archivo=`echo $file | awk 'BEGIN{FS="Regularizacion/"} {printf $2 }'`
    if [ "$file" = "" ] ;    then
		AVISO=ARCHIVO-VACIO
	   echo $AVISO
	else
	    AVISO=OK
		echo $AVISO
	   pMessage "SUBPROCESO - Ejecuta la secuencia con los datos:" 		
	   pMessage "SH004_REGULARIZACION.sh $file $archivo $DIREC $FILELOG " 	
	   sh SH004_REGULARIZACION.sh $file $archivo $DIREC $FILELOG
    fi
done

if [ "$AVISO" = "" ] ; then
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Regularización TFI no se encuentra en la ruta : $DIREC" 
   	echo "Buen día, no se encontraon los archivos *.dat en la ruta  establecida : $DIREC " $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo de Regularización TFI no se encuentra en la ruta." $IT_MAIL 
else
	FECHATMP="'"${FARCH}"'"
	FILEERR=REGUL_TFI_$FARCH.ERR   
	
	#rm -f ${DIRERR_REGUL}/${FILEERR}
	
	pMessage "Se ejecuta el SP PKG_CC_PTOSTFI.ADMPSS_EREGULARIZA_TFI y se exporta los datos obtenidos"
	sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> ${DIRERR_REGUL}/${FILEERR}
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
	  cursorregultfi ty_cursor; 
	  c_cod_cli VARCHAR2(40);
	  c_nompromo VARCHAR2(200);
	  c_periodo VARCHAR2(6);
	  c_puntos NUMBER;
	  c_des_error VARCHAR2(200);
	  c_cod_error number(3);
	  c_msje_error varchar2(400);
	  v_fecha date;
	  v_nom_arch varchar2(150);
	  
	  BEGIN
	  
	  dbms_output.enable(NULL);
 
       SELECT TO_DATE($FECHATMP,'YYYYMMDD') INTO v_fecha FROM DUAL;
		$PCLUB_OW.PKG_CC_PTOSTFI.ADMPSS_EREGULARIZA_TFI(v_fecha,c_cod_error,c_msje_error,cursorregultfi);
	   
	  LOOP
	  
	  fetch cursorregultfi into c_cod_cli,c_nompromo,c_periodo,c_puntos,v_nom_arch,c_des_error;
	  
	  exit when cursorregultfi%notfound;
	  
	  DBMS_OUTPUT.put_line(c_cod_cli || '|' || c_nompromo || '|' || c_periodo || '|'  || c_puntos || '|'  || v_nom_arch || '|' || c_des_error);
	  
	  END LOOP;
	  
	  CLOSE cursorregultfi;
	  
	  EXCEPTION
		when OTHERS then
		  dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
	  END;
	/
	EXIT
EOP

	CANT_DATA=`cat ${DIRERR_REGUL}/${FILEERR} | wc -l | sed 's/ //g'`
	VALIDA_EJEC_SP=`grep 'ORA-' ${DIRERR_REGUL}/${FILEERR} | wc -l | sed 's/ //g'`
	VALIDA_EJEC_SP_B=`grep 'SP2-' ${DIRERR_REGUL}/${FILEERR} | wc -l | sed 's/ //g'`
		
	if [ $CANT_DATA = 0 ] ; then
		pMessage "El proceso no trajo errores en ${DIRERR_REGUL}/${FILEERR}, asi que no se podrá generar en la carpeta Fallos"
		rm -f ${DIRERR_REGUL}/${FILEERR}
	else
		pMessage "Se ha generado el archivo ${DIRERR_REGUL}/${FILEERR}"
	fi
		
	if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then			
		cat  ${DIRERR_REGUL}/${FILEERR} >>  $FILELOG
		pMessage "FINALIZANDO PROCESO..............."
		pMessage "Hubo un error durante la ejeción del SP PKG_CC_PTOSTFI.ADMPSS_EREGULARIZA_TFI"  
		echo "Buen día, Hubo un error durante la ejeción del SP PKG_CC_PTOSTFI.ADMPSS_EREGULARIZA_TFI." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "Claro Club - Importación de Puntos por Regularización." $IT_MAIL 
		exit -1
	fi
	
#cat  ${DIRERR_REGUL}/${FILEERR} >>  $FILEERRPR
#rm -f ${DIRERR_REGUL}/${FILEERR}

fi

pMessage "******FIN PROCESO REGULARIZACION*******"  
pMessage "**********************************"
pMessage "**********************************" 

exit