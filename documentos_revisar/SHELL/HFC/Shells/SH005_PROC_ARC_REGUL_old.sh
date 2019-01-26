#! /bin/ksh
#*************************************************************
#* DESCRIPCION           : Puntos por Regularizacion HFC
#* EJECUCION             : Control-D                            
#* AUTOR                 :                                   
#* FECHA                 : 28/05/2012   VERSION : v1.0       
#* FECHA MOD .           :                         
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

# Rutas
FECHA=`date +%Y%m%d_%H%M%S`
FARCH=`date +%Y%m%d`
FECHAARCH=$FARCH
PERIODO=${FECHAARCH:0:6}

#Llama al parametro del Shell original
ListaArchivodat=$1
NomArchivo=$2
RutaArchivo=$3

CONTROL=$DIRCONTROLHFC/importaPRegHFC.ctl
BAD=$DIRFALLOSHFC/importaPRegHFC_BAD_$FECHA.bad
FILELOG=$DIRLOGHFC/SH005_PROC_ARC_REGUL_$FECHA.log
CTL_LOG=$DIRLOGHFC/CTL005_LOG_$FECHA.log

ARCHNAME=$ListaArchivodat
RUTANAME=$RutaArchivo
FILELOGPR=$4

# Inicio
demora=`date +"%d-%m-%Y %H:%M:%S"`
pMessage "*************************************" 
pMessage "Iniciando subproceso de Regularizacion" 
pMessage "Fecha y Hora : $demora               " 
pMessage "*************************************" 
pMessage "ARCHNAME: $ARCHNAME"
echo $ARCHNAME
echo $RUTANAME

FILEDATA=`find $ARCHNAME`
CANT_DATA=`cat  $ARCHNAME | wc -l | sed 's/ //g'`

if [ "$FILEDATA" = "" ] ; then
   Demora=`date +"%Y-%m-%d %H:%M:%S"`
   pMessage " $demora: Error: No se encontro el archivo de datos..." 
   pMessage "No existe ninguno de estos archivos $ARCHNAME" 
   pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Regularizacion HFC no se encuentra en la ruta" 
   echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "El Archivo de Regularizacion HFC no se encuentra en la ruta." $IT_MAIL 
   #pMessage "Ruta del Archivo log : " $FILELOG
   pMessage "Termino subproceso"
   pMessage "************************************" 
   pMessage "************************************" 
   cat $FILELOG >> $FILELOGPR
   rm -f $FILELOG   
   echo $'\n'
   exit -1
fi

if [ $CANT_DATA = 0 ] ; then
	pMessage "Hora y Fecha: $demora"
	pMessage "Ninguno de estos archivos tiene data $ARCHNAME" 
	pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Regularizacion HFC se encuentra vacio." 
	echo "Buen día, los siguientes archivos $ARCHNAME en la carpeta de ORIGEN no contienen datos." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "El Archivo de Regularizacion HFC se encuentra vacio" $IT_MAIL
	pMessage "Se envió correo Fecha y Hora: $demora"
	pMessage "Termino subproceso"
	pMessage "************************************" 	    
	pMessage "************************************" 
	cat $FILELOG >> $FILELOGPR
	rm -f $FILELOG
	exit -1
fi


dos2unix ${FILEDATA}

TMP=$DIRLOGHFC/TEMPDATA05.tmp
echo "" >> ${FILEDATA}
cat ${FILEDATA} | sed '/^$/d' > $TMP
cat $TMP > ${FILEDATA}
		
rm -f $TMP


TEMP_FILE=TEMP05_${FECHA}.TMP
contador=1
numregistros=`cat  $ARCHNAME | wc -l | sed 's/ //g'`
numregistros=`expr $numregistros - 1`

promo=`cat $ARCHNAME | sed 's/\\r//g'|awk 'BEGIN{FS="PROMOCION:"} {printf $2}'`
user=`cat $ARCHNAME | sed 's/\\r//g'|awk 'BEGIN{FS="USUARIO:"} {printf $2}'`
echo $ARCHNAME
echo $promo
echo $user
if [ "$promo" == "" ] || [ "$user" == "" ] ; then
   pMessage " $demora: Error: Los Datos de Promocion/Usuario No son Correctos..." 
   pMessage "Termino subproceso"
   pMessage "************************************" 
   pMessage " FINALIZANDO SUBPROCESO..............." 
   pMessage "`date +%Y-%m-%d@%H:%M:%S` Fin de subproceso " 
   pMessage "************************************" 
   pMessage "Los Datos del Archivo $NomArchivo no esta en forma Correcta .." 
   pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Regularizacion HFC no se encuentra en forma Correcta" 
   pMessage "Termino subproceso"
   pMessage "************************************" 	    
   pMessage "************************************"
   cat $FILELOG >> $FILELOGPR
   rm -f $FILELOG   
   exit -1
else
   ARCHIVO=`echo $ARCHNAME | awk 'BEGIN{FS="Regularizacion/"} {printf $2 }'`
   TIPOCLIE="7"
   while read FIELD03
   do
	if  [ ${contador} != ${numregistros} ] ; then
			echo "${FIELD03}|${PERIODO}|${promo}|${ARCHIVO}|${TIPOCLIE}|${FECHAARCH}" >> $DIRLOGHFC/$TEMP_FILE
		contador=`expr $contador + 1`
	fi
	
  done < $FILEDATA
  
	FILEDATATEMP=`find $DIRLOGHFC/$TEMP_FILE`
	CANT_DATATEMP=`cat  $DIRLOGHFC/$TEMP_FILE | wc -l | sed 's/ //g'`

	if [ "$FILEDATATEMP" = "" ] || [ $CANT_DATATEMP = 0 ] ; then
	   pMessage "Fin de Subproceso " 
	   pMessage "************************************" 
	   pMessage "El archivo con nombre $ARCHNAME no contiene datos válidos a procesar" 
	   pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Regularizacion HFC no contiene datos validos" 
	   echo "Buen día, el archivo $NomArchivo en la carpeta $RUTANAME no contiene datos validos a procesar." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "HFC : El Archivo de Regularizacion HFC no contiene datos validos." $IT_MAIL 
	   #pMessage "Ruta del Archivo log : " $FILELOG
	   pMessage "Termino subproceso"
	   pMessage "************************************" 	    
	   pMessage "************************************" 
	   cat $FILELOG >> $FILELOGPR
	   rm -f $FILELOG
	   echo $'\n'
	   exit -1
	fi	
	
	pMessage "Se procede a importar los datos del archivo de entrada a la tabla de Regularizacion HFC"
	sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$CONTROL data=$DIRLOGHFC/$TEMP_FILE bad=$BAD log=$CTL_LOG bindsize=200000 readsize=200000 rows=1000 skip=0
	
        rm -f $DIRLOGHFC/$TEMP_FILE

	VALIDAT_CTL=`grep 'ORA-' $CTL_LOG | wc -l`

	if [ $VALIDAT_CTL -ne 0 ] ;
		then
		pMessage "ERROR en la ejecucion del control $CONTROL. Contacte al administrador."$'\n'
		pMessage "Verifique el log para mayor detalle $CTL_LOG"$'\n'
		echo "Buen día, ocurrio un error al momento de importar los datos del $NomArchivo  a la tabla de regularizacion HFC." $'\n' "Favor de atender este inconveniente" $'\n' " Gracias." $'\n'  | mail -s "Error al importar datos" $IT_MAIL
		cat $CTL_LOG >> $FILELOG
		rm -f $CTL_LOG 
		pMessage "Termino subproceso"
		pMessage "************************************" 
	        pMessage "************************************" 
		cat $FILELOG >> $FILELOGPR
		rm -f $FILELOG
		echo $'\n'
		exit -1
	fi

	pMessage "El proceso de importacion culmino satisfactoriamente"
	
        rm -f $CTL_LOG 
	
        cp $FILEDATA $DIR_PROC_REGUL
			
	ARCHPRMT=$ARCHNAME
		
	PERIODO=${FECHAARCH:0:6}
	FECHATMP="'"${FECHAARCH}"'"


        pMessage "Se procede a ejecutar el SP PKG_CC_PTOSFIJA.ADMPSI_REGDTH_HFC"

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
			
	k_tipcli    varchar2(2)	;
	v_fecha 	date;	
	v_usuario   varchar2(50);
	k_coderror  number;
	k_descerror varchar2(400);
	k_numregtot number;
	k_numregpro number;
	k_numregerr number;
					
	BEGIN
			
		SELECT TO_DATE($FECHATMP,'YYYYMMDD') INTO v_fecha FROM DUAL;
		SELECT '$user' INTO v_usuario FROM DUAL;
		
		begin
					
			$PCLUB_OW.PKG_CC_PTOSFIJA.ADMPSI_REGDTH_HFC('7',v_usuario,v_fecha,'$NomArchivo',
															k_coderror,k_descerror,
															k_numregtot,k_numregpro,k_numregerr);
		exception
		when OTHERS then
				dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
		end;
		dbms_output.put_line('Codigo de error: ' || k_coderror || '|Mensaje de error: ' || k_descerror || '|Nº total de registros: ' || k_numregtot || '|Nº de registros procesados: ' || k_numregpro || '|Nº de registros con errores: ' || k_numregerr);
		
END;
	
/
exit
EOP


	VALIDA_EJEC_SP=`grep 'ORA-' ${FILELOG} | wc -l | sed 's/ //g'`
	VALIDA_EJEC_SP_B=`grep 'SP2-' ${FILELOG} | wc -l | sed 's/ //g'`

	if [ ${VALIDA_EJEC_SP} -ne 0 ] || [ ${VALIDA_EJEC_SP_B} -ne 0 ] ; then
		pMessage "Hora y Fecha: $demora"
		pMessage "Hubo un error durante la ejeción del SP PKG_CC_PTOSFIJA.ADMPSI_REGTH_DTH" 
		pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de IMPORTACION DE PUNTOS POR REGULARIZACION HFC – Se encontraron errores" 
		echo "Buen día, ocurrio un problema al ejecutar el SP de PKG_CC_PTOSFIJA.ADMPSI_REGTH_DTH." $' \n' "Favor de atender este inconveniente" $'\n' "Gracias." $'\n'  | mail -s "IMPORTACION DE PUNTOS POR REGULARIZACION HFC – Se encontraron errores" $IT_MAIL 		
		pMessage "Se envió correo Fecha y Hora: $demora" 		
		pMessage "Termino subproceso"
	        pMessage "************************************" 	    
		pMessage "************************************" 
		cat $FILELOG >> $FILELOGPR
		rm -f $FILELOG			
		exit -1
	fi
	
	FINDFILE=`find $ARCHNAME`
	FINDBKP=`find $DIR_PROC_REGUL/$NomArchivo`
	
	if [ "$FINDFILE" = "" ] && [ "$FINDBKP" = "" ] ; then
		pMessage "Hora y Fecha: $demora"
		pMessage "No existe ninguno de estos archivos $ARCHNAME" 
		pMessage "A continuación se enviará un correo a $IT_MAIL con el asunto de El Archivo de Regularizacion HFC no se encuentra en la ruta" 
		echo "Buen día, no se encontraron los siguientes archivos $ARCHNAME en la carpeta de $RUTANAME." $'\n' "Favor de atender este inconveniente" $'\n' "Gracias."$'\n'  | mail -s "DTH: REGULARIZACION, no se encuentra el archivo." $IT_MAIL 
		pMessage "Se envió correo Fecha y Hora: $demora"    
		pMessage "Termino subproceso"
	    pMessage "************************************" 	    
		pMessage "************************************"
		cat $FILELOG >> $FILELOGPR
		rm -f $FILELOG		
		exit -1
	fi
  
	#borramos el archivo de la carpeta de documentos
	if [ "$FINDBKP" != "" ] ; then
		rm -f $FILEDATA	 
		pMessage "El archivo de entrada fue copiado en $FINDBKP"	
fi
 
fi

pMessage "Termino subproceso Asignacion de Puntos por Regularizacion HFC ClaroClub"
pMessage "********** FINALIZANDO SUBPROCESO ********** " 
pMessage "Fin de subproceso "
pMessage "************************************" 
#pMessage "Ruta del Archivo log : ${FILELOG}" 
pMessage "*************************************" 
cat $FILELOG >> $FILELOGPR
rm -f $FILELOG
exit

