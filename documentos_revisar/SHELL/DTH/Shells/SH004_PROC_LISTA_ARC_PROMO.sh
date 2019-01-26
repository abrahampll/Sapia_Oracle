#! /bin/ksh
#*************************************************************
#* DESCRIPCION           : Recorre Directorio Promocion DTH
#* EJECUCION             : Control-D                            
#* AUTOR                 :                                   
#* FECHA                 : 04/07/2012   VERSION : v1.1       
#* FECHA MOD .           :                         
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
} 

FARCH=`date +%Y%m%d`
FILELOG=$DIRLOGDTH/SH004_PROC_LISTA_ARC_PROMO_$FARCH.log
FILERR=$DIR_ERR_PROM/PROC_LISTA_ARC_PROMO_$FARCH.ERR

pMessage "******INICIO PROCESO PROMOCION*******" 
pMessage "Inicio de Shell  Recorre Archivos    "
pMessage "Directorio Archivo                   "
pMessage "*************************************" 

# FALTA PARAMETRIZAR PARA CLIENTE DTH Y HFC
#
#
#

DIREC=$DIR_ENT_PROM

echo "$DIREC"

for file in $(find $DIREC -type f -iname "*.dat" | sort)
do
    echo $file
	archivo=`echo $file | awk 'BEGIN{FS="Promocion/"} {printf $2 }'`
    if [ "$file" = "" ] ;    then
		AVISO=ARCHIVO-VACIO
	   echo $AVISO
	else
	    AVISO=OK
		echo $AVISO
	   pMessage "SUBPROCESO - Ejecuta la secuencia con los datos:" 		
	   pMessage "SH004_PROC_ARC_PROMO.sh $file $archivo $DIREC $FILELOG " 	
	   sh SH004_PROC_ARC_PROMO.sh $file $archivo $DIREC $FILELOG
    fi
done

if [ "$AVISO" = "" ] ; then
	pMessage "No hay archivos e la ruta establecida : $DIR_ENT_PROM " 	
else
	FECHATMP="'"${FARCH}"'"
	FILEERR=PROM_DTH_$FARCH.ERR   
	
	#rm -f ${DIR_ERR_PROM}/${FILEERR}
	
	pMessage "Se ejecuta el SP PKG_CC_PTOSFIJA.ADMPSI_EPROMDTH_HFC y se exporta los datos obtenidos"
	sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> ${DIR_ERR_PROM}/${FILEERR}
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
	  cursorpago ty_cursor; 
	  c_cod_cli VARCHAR2(40);
	  c_nompromo VARCHAR2(200);
	  c_periodo VARCHAR2(6);
	  c_puntos NUMBER;
	  c_des_error VARCHAR2(200);
	  c_cod_error number(3);
	  c_msje_error varchar2(400);
	  v_fecha date;
	  v_nom_arch varchar2(100);
	  
	  BEGIN
	  
	  dbms_output.enable(NULL);
	  
	   SELECT TO_DATE($FECHATMP,'YYYYMMDD') INTO v_fecha FROM DUAL;
	   
		$PCLUB_OW.PKG_CC_PTOSFIJA.ADMPSI_EPROMDTH_HFC('6',v_fecha,c_cod_error,c_msje_error,cursorpago);
	   
	  LOOP
	  
	  fetch cursorpago into c_cod_cli,c_nompromo,c_periodo,c_puntos,v_nom_arch,c_des_error;
	  exit when cursorpago%notfound;
	  
	  DBMS_OUTPUT.put_line(c_cod_cli || '|' || c_nompromo || '|' || c_periodo || '|'  || c_puntos || '|'  || v_nom_arch || '|' || c_des_error);
	  
	  END LOOP;
	  
	  CLOSE cursorpago;
	  
	  EXCEPTION
		when OTHERS then
		  dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
	  END;
/
EXIT
EOP

	
	CANT_DATA=`cat ${DIR_ERR_PROM}/${FILEERR} | wc -l | sed 's/ //g'`
	VALIDA_EJEC_SP=`grep 'ORA-' ${DIR_ERR_PROM}/${FILEERR} | wc -l | sed 's/ //g'`
	VALIDA_EJEC_SP_B=`grep 'SP2-' ${DIR_ERR_PROM}/${FILEERR} | wc -l | sed 's/ //g'`
		
	if [ $CANT_DATA = 0 ] ; then
		pMessage "El proceso no trajo errores en ${DIR_ERR_PROM}/${FILEERR}, asi que no se podra generar en la carpeta Fallos"
		#rm -f ${DIR_ERR_PAGOS}/${FILEERR}
	else
		pMessage "Se ha generado el archivo ${DIR_ERR_PROM}/${FILEERR}"
	fi
		
	if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then			
		cat  ${DIR_ERR_PROM}/${FILEERR} >>  $FILELOG
		pMessage "FINALIZANDO PROCESO..............."
		pMessage "Hubo un error durante la ejeción del SP PKG_CC_PTOSFIJA.ADMPSI_EPROMDTH_HFC"  
		echo "Buen día, Hubo un error durante la ejeción del SP PKG_CC_PTOSFIJA.ADMPSI_EPROMDTH_HFC." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "Claro Club - Importacion de Puntos por Promocion." $IT_MAIL 
		exit -1
	else
		if [ $CANT_DATA != 0 ] ; then
			pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de Errores en el registro de clientes" 
			FILEERR_ZIP=PROMOCION_DTH_$FARCH.zip
			cd $DIR_ERR_PROM
			zip $FILEERR_ZIP $FILEERR
			(echo "Buen día, se encontraron $CANT_DATA errores. Revisar la ruta ${DIR_ERR_PROM}/${FILEERR}." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  ; uuencode $FILEERR_ZIP $FILEERR_ZIP) | mail -s "DTH-POSTPAGO - Importacion de Puntos por Promocion." $IT_MAIL
			rm -f $FILEERR_ZIP		
			exit
		fi	
	fi
	
#cat  ${DIR_ERR_PROM}/${FILEERR} >>  $FILEERRPR
#rm -f ${DIR_ERR_PROM}/${FILEERR}

fi

pMessage "******FIN PROCESO PROMOCION*******" 
pMessage "**********************************"
pMessage "**********************************" 

exit