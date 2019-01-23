#OPERADORES#
if [ $VALOG1 -gt 0 ]; then #MAYOR QUE#
if [ $VALOG1 -ne 0 ]; then #NO IGUAL#
if [ $VALOG1 -eq 0 ]; then #IGUAL#
if [ $VALOG1 -lt 0 ]; then #MENOR QUE#
if [ $VALOG1 -le 0 ]; then #MENOR O IGUAL#
 
#ARCHIVOS#
if [ -a ${LISTAR_SERIE} ] #Se comprueba si el fichero de datos que se va a utilizar existe
if [ -n $file ]; then #comprobamos que la cadena del nombre no este vacía
if [ -f $file ]; then #No es un directorio
if [ -s $file ]; then #El fichero existe y no está vacio.
if [ -d $RUTADESTINO ];then #Es directorio
if [ ! -f $FL_PROCEWS ]; then #Negación
if [ -e  $RUTARPT/$DIRIPSACT ]; then #Existe archivo?

#*******************************BUCLES*******************************#
#ELIMINA ARCHIVO#
rm -f ${RUTARPT}/${ARCH_SEGUIMIENTO}
find $RUTALOG -name "*.log" -mtime +${VARDEPURALOG} -exec rm -f {} \;
find ./ -atime +30 -name '*.log' -exec rm -f {} \;

#BORRA ARCHIVO LOG CADA 6 MESES DE ANTIGUEDAD
find ${DIRLOG} -name "*.log" -ctime +180 -exec rm -f {} \; 								

#ELIMINAR ARCHIVO SEGUN NOMBRE TAMAÑO Y TIEMPO, TAMBIEN REALIZA BACKUP
#TIME=tiempo del último acceso
find $RUTALOG -maxdepth 1 -name $ARCHIVO'*' -and -size +$SIZE -and -mtime +$TIME |xargs mv -t $DIRLOGBCK

#ELIMINA TODOS LOS ARCHIVOS#
rm *.*

#CUENTA CANTIDAD DE ARCHIVOS#
cuentaArchivos=$(find -maxdepth 1 -type f -exec ls '{}' \; | wc -l)

#RECORRER ARCHIVOS#
for file in $( find $strRutaDir -type f -name '*.tmp' | sort)
do
    if [ -f $file ] ; then
       rm $file
    fi
done

#UNIFICAR UN GRUPO DE ARCHIVOS
for filename in `ls -1 *.OUT`
do lote=`echo ${filename} | awk 'BEGIN {FS="."} {printf $1}'`; 
	while read line
	   do
	   echo ${lote} ${line} >>${RUTAPROCESO}/OUT_MASIVO.dat
	  done <${filename}
done

#RECORRE ARCHIVO#
cargaFile=`cat $RUTAFILERANGO/$RANGOSFILE | sed 's/|/|/g'| sed 's/ /#?/g'`
for clineav in $cargaFile
do 
   V_CICLO_R=`echo $clineav | awk 'BEGIN{FS="|"}{ printf $1}'`
   if [ $DIA -eq $V_CICLO_R ] ; then
        VALIDAR=0
	   break
   else
        VALIDAR=1		
   fi   
done

#RECORRIDO CLASICO#
for (( CONTADOR=1 ; CONTADOR<=$PAR_P_NINTENTOS ; CONTADOR++ ))
do
done

#RECORRE CONTENIDO ARCHIVO#
while read TRAMA
do
	CODREPROCESO=`echo $TRAMA | awk 'BEGIN{FS="|"} {print $1}'`
	ENTIDADSIC=`echo $TRAMA | awk 'BEGIN{FS="|"} {print $2}'`
	if [ ${CODREPROCESO} -eq 0 ]; then
		pSeguimientoOAC ${RUTARPT}/${ARCH_SEGUIMIENTO}
	else
		pSeguimientoOAC ${RUTARPT}/${ARCH_SEGUIMIENTO}	
	fi
	
done < ${RUTARPT}/${ARCHPROCREPRO}

#FOR CON NÚMEROS#
for i in {1..20}
do
   echo "Inicio de Ejecucion de hilo 0$i con log : $FILELOGHIJO"
done
#*******************************BUCLES*******************************#


#*******************************GREP******************************#
#BUSQUEDA DE PALABRA RETORNA 1 SI ENCUENTRA SINO 0#
VALID_jar1=`grep -i -c 'Exception' ${RUTARPT}/${TABXML}`
VALID_jar2=`grep -i -c 'java:' ${RUTARPT}/${TABXML}`
VALID_jar3=`grep -i -c 'Invalid' ${RUTARPT}/${TABXML}`
VALID_jar4=`grep -i -c 'corrupt' ${RUTARPT}/${TABXML}`

#BUSCA Y CUENTA CUANTOS PARALABRAS EXISTEN EN ARCHIVO#
VALIDAT_CTL1=`grep 'ORA-' $FILLOG | wc -l`

#BUSCAR POR PATRON Y LUEGO ELIMINA Y ENVIA ARCHIVO#
grep "DRA-|" ${RUTARPT}/${ARCHTBDRA_TOTAL}|sed 's/DRA-|//g'>${RUTARPT}/${ARCHTBDRA_CAB}
grep "PAG-|" ${RUTARPT}/${ARCHTBDRA_TOTAL}|sed 's/PAG-|//g'>${RUTARPT}/${ARCHTBDRA_DET}

#POSICIONES DE CADENAS#
S_SEPARADOR="========================================="
S_SEPRADOR1=`grep -n "$S_SEPARADOR" $RUTA_LOG/$FILE_TOTAL  | awk ' BEGIN{ FS=":" } { print $1 }' | sed -n 1p | sed 's/ //g'`
S_SEPRADOR2=`grep -n "$S_SEPARADOR" $RUTA_LOG/$FILE_TOTAL  | awk ' BEGIN{ FS=":" } { print $1 }' | sed -n 2p | sed 's/ //g'`
INICIO_1=1
let FIN_1=$S_SEPRADOR1-1
let INICIO_2=$S_SEPRADOR1+1
let FIN_2=$S_SEPRADOR2-1
let INICIO_3=$S_SEPRADOR2+1
FIN_3=`wc -l $RUTA_LOG/$FILE_TOTAL |  awk ' { print $1 }' | sed 's/ //g'`

cat $RUTA_LOG/$FILE_TOTAL | sed -n ${INICIO_1},${FIN_1}p > $DIR_PVU/$FILE_CONT
cat $RUTA_LOG/$FILE_TOTAL | sed -n ${INICIO_2},${FIN_2}p > $DIR_PVU/$FILE_DET
cat $RUTA_LOG/$FILE_TOTAL | sed -n ${INICIO_3},${FIN_3}p > $DIR_PVU/$FILE_SER
#EXTRAE ARCHIVOS CON CIERTO NOMBRE Y EXTENCION#
ls -ltra HUR_* | grep csv | awk '{print $9}' > "${RUTALOG}"/"${ARCH_TEMP4}"

#EXTRAE SOLO NOMBRE DE ARCHIVO#
NOMBRE_ARCHIVO="${ListaAnul##*/}"


#BUSCAR ARCHIVOS CON CIERTO NOMBRE Y PONERLOS EN LISTAS PARA DESPUES RECORRERLAS
find ${RUTADATA} -name "${EXT_FIJA}*.${XTARCH}" -exec echo {} \; > "${RUTALOG}"/"${TMPLISTFIJA}"
find ${RUTADATA} -name "${EXT_MOV}*.${XTARCH}" -exec echo {} \; > "${RUTALOG}"/"${TMPLISTMOVIL}"
find ${RUTADATA} -name "${EXT_LDI_FIJA}*.${XTARCH}" -exec echo {} \; > "${RUTALOG}"/"${TMPLISTLDIFIJA}" #MZA 18.06.2014
find ${RUTADATA} -name "${EXT_LDI_MOVIL}*.${XTARCH}" -exec echo {} \; > "${RUTALOG}"/"${TMPLISTLDIMOVIL}" #MZA 18.06.2014

#EXTRAE DIRECTORIO DE ARCHIVO
DIRTEMP=`basename  $TRAMA | awk 'BEGIN{FS="."} {print $1}'`
		
#VALIDA FECHA#		
if ! echo $fecha | grep -q '[0-2][0-9]/[0-1][0-9]/[1-2][0-9][0-9][0-9]'; then
	return 0 #Formato de fecha invalido
fi		

#BUSCA DATO#
VAL_SQL1=`echo $1 | grep 'ORA-[0-9]' | wc -l`
VAL_SQL2=`echo $1 | grep 'SP2-[0-9]' | wc -l`
#*******************************GREP******************************#



#CADENA CONVERSION ARRAY#
OIFS="$IFS"
IFS=';'
read -a LINEASINACTIVAS <<< "${RUC_CONLINEAS_INACTIVAS}"
IFS="$OIFS"

for TELEFMOTIVO in "${LINEASINACTIVAS[@]}"
	do
		VARIABLE_TELEFONO=''
		VARIABLE_MOTIVO=''
		VARIABLE_TELEFONO=`echo $TELEFMOTIVO | awk '{split($0,TELE1,":");  print TELE1[1] }'`
		VARIABLE_MOTIVO=`echo $TELEFMOTIVO | awk '{split($0,MOTIVO2,":");  print MOTIVO2[2] }'`
		pMessage "Linea no se encuentra activa LINEA: $VARIABLE_TELEFONO, RUC: $RUC  MOTIVO: $VARIABLE_MOTIVO"
done

#RENOMBRAR Y MOVER ARCHIVO#
mv $NUMEROSEC.zip ${CONSTANTE_FECHA}$NUMEROSEC.zip
mv $RUTARPT/*.csv $LSTHOME/OUT
mv $RUTARPT/*.zip $LSTHOME/OUT
mv "${RUTADWH}"/${ARCHTRANS} "${RUTADATA}"
mv -f ${ORIGEN}/ITSAP-IT$FECHA.TXT ${DESTINO}/ITSAP-IT$FECHAT.TXT

#COPIAR#
cp "${RUTADWH}"/${ARCHTRANS} "${RUTAPROC}"
cp -r $DIRSALIDA/*.tmp $DIRSALIDAOUT
cp -p ${RUTAINPUT}/${FFILES2} ${RUTABKP}/${FECHA}/${FFILES3}

#CADENA CONTENIDA EN OTRA CADENA#
POSICION1=`awk -v a="${PRMT_ARCH}" -v b="${NOMB_ARCH}" 'BEGIN{print index(a,b)}' `
POSICION2=`awk -v a="${PRMT_ARCH}" -v b="${EXTE_ARCH}" 'BEGIN{print index(a,b)}' `

#OBTENER PRIMER REGISTRO#
REGISTRO=`head -1 ${FILE_REGNOPROC}`

#OBTENER PRIMER REGISTRO#
REGISTRO=`cat ${FILE_REGNOPROC} | tail -1`

#SELECCIONAR ULTIMA LINEA
tail -n1 SL197717072501_1

#ELIMINAR ULTIMA LINEA
sed '$d' SL197717072501_1

#FORMATO UNIX
dos2unix ${RUTARPT}/ARCHIVO
chmod 750 ${RUTARPT}/ARCHIVO

#SPLIT CADENA CON RANGOS#
P_TELEFONO1=`echo ${TELEFONOS:0:2400}`
P_TELEFONO2=`echo ${TELEFONOS:2400:2400}`

#CONTAR CARACTERES EN CADENA#
SIZERUTA=${#RUTAFILE}
`expr length $TELEFONO`

#OPERACIONES MATEMATICAS#
NEWNROLIN=`expr $NROLINEAS / 3`
NEWNROLIN=`expr $NEWNROLIN + 2`

#CORTAR CARACTERES#
_hour_1=`echo "$1" | cut -c1-2`
_mins_1=`echo "$1" | cut -c3-4`
_secs_1=`echo "$1" | cut -c5-6`

#CORTAR CADENA POR SEPARADOR#
ADJUNTO="NUEVO~DOS"
archivo=`echo $ADJUNTO|cut -d'~' -f2`

#CORTAR CADENA
VALID_PROCESO=`expr substr "$VALID_LPROCESO" 1 12`

#COMANDOS ESPECIALES#
export NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
export LANG="es_ES.UTF-8"

#LISTAR ARCHIVOS#
ls -1 "${RUTADWH}" > "${RUTASH}"/"${ARCH_TEMP1}"

#*****************************************************LENGUAJE_AWK**********************************************#
#PONER SALTO DE LINEA EN LA ULTIMA#
awk '{printf("%s\r\n",$0)}' ${DIRLOG}/${LOGNAME} > ${DIRLOG}/${FILELOG}
#COMPARAR MONTOS DE ARCHIVO, RETORNA 1 / 0#
echo "$MONTO $CERO" | awk '{print($1 < $2)}'
#EXTRAE DATO SEGUN FILTRO#
lista_fuentes=${DIRLOG}/${ARCHIVO}
ARCHIVO_SQL=`cat $lista_fuentes | awk ' BEGIN{FS="|"} ( $1==FILTRO ) { print $2 }' FILTRO=$FUENTE`
RUTA_ORIGEN=`cat $lista_fuentes | awk ' BEGIN{FS="|"} ( $1==FILTRO ) { print $3 }' FILTRO=$FUENTE`
RUTA_PROCESADOS=`cat $lista_fuentes | awk ' BEGIN{FS="|"} ( $1==FILTRO ) { print $4 }' FILTRO=$FUENTE`
#EXTRAE DATO INFORMACIÓN DEL ARCHIVO#
FECHA_GENERACION=`stat $RUTA_ORIGEN/$ARCHIVO_ORIGINAL | grep "Change" | awk 'BEGIN{FS=" "} {print $2,$3}' | cut -f1 -d.`
#*****************************************************LENGUAJE_AWK**********************************************#


#***********************************FTP*******************************#
#PONER ARCHIVO#
echo "open $PHOST " > SH_FTP1.ftp
echo "user $PUSUARIO $PPASS " >> SH_FTP1.ftp
echo "cd ${PRUTAR}/${OPERADOR}" >> SH_FTP1.ftp
echo "lcd ${DIRRPT} " >> SH_FTP1.ftp
echo "asc" >> SH_FTP1.ftp
echo "mput $FILE_RPT3 " >> SH_FTP1.ftp	
echo "bye" >> SH_FTP1.ftp
ftp -inv < SH_FTP1.ftp > $DIRLOG/$FILE_FTP
rm -f SH_FTP1.ftp 

#EXTRAER ARCHIVO#
TEMP_FTP=put_APP_RES.ftp
echo "open $IP_DIMG" > $TEMP_FTP
echo "user $US_DIMG $PW_DIMG" >> $TEMP_FTP
echo "cd $ORIG_DIMG" >> $TEMP_FTP
echo "lcd $RUTAFILE" >> $TEMP_FTP
echo "bin" >> $TEMP_FTP
echo "mget *" >> $TEMP_FTP
echo "mdelete *" >> $TEMP_FTP
echo "bye" >> $TEMP_FTP
ftp -ni < $TEMP_FTP >>  $RUTALOG/$FILELOG

#FTP CON EXPECT PARA TRASLADOS ENTRE DOS SERVIDORES DE DIFERENTES RED#
expect ${DIR_EXPEC}/SH01_4PLAY.exp ${FILE_TELFNS} >> ${FILE_SSH}
#***********************************FTP*******************************#

#EJECUCION JAR#
java -jar ClienteEbsOperacionesINWS.jar "${WSOperacionesIN}" "${FECHA_HORA}" "" "${IP_SERVID}" "${CMD_IN_ULT_PERIODO}" "${Telefono51}" "${CODAPLICA}" > $LogOperacionINWS

#FUNCIONES#
#QUITAR ESPACIO EN VARIABLES#
V_EMAILS=`echo $V_EMAILS | tr -d ' '`
#CORTAR EL ARCHIVO CIERTA CANTIDAD Y GUARDARLO EN#
split -l 1000 $RUTATMP/$F_RESENVIOOK  $RUTATMP/"split$NPRO"/arch_

#COMPRIMIR Y DESCOMPRIMIR# 
unzip ${RUTA_TEMP_DAC}/${ARCHIVO_DAC} >>${DIRLOG}/unzip_$$.txt
zip $ARCHFIJAZIP $ARCHFIJA>$RUTALOG/zip.txt
zip ${FILE_FINAL_ZIP} ${FILE_CLIENTE} > /dev/null
gzip -f ${DIRHISTORICO}/${TABLA}_${FECHAACT}.dat

#ENVIO CORREO#
cat $RUTALOG/$LOG_PROCESO2 | mail -s "Observaciones - Registro de las lineas en la Base de Datos de VAS (SMT_ENVIO - SMT_DENVIO) -- $FECHMAIL // $SHELL2 || LOG" $OPERADOR_TI
#CORREO_VERIFICACION [CORREO CON COPIA OCULTA]#
#ADJUNTO [ARCHIVO A ENVIAR]#
#EMAIL="Empresas Despacho <"${IT_OPERADOR_AMP}">" EN EL CORREO SE VISUALIZA EL NOMBRE DEL REMITENTE IGUAL A "Empresas Despacho"#
export EMAIL="Empresas Despacho <"${IT_OPERADOR_AMP}">" ; mutt  -s "Claro - Listado de Planes y Equipos SEC:"$NUMEROSEC -a $ADJUNTO -b $CORREO_VERIFICACION $V_EMAILS  < body.txt
export EMAIL="Empresas Despacho <"${IT_OPERADOR_AMP}">" ; mutt  -s "Claro - Listado de Planes y Equipos SEC:"$NUMEROSEC -a $ADJUNTO $CORREO_VERIFICACION < body.txt

ADJ=adjunto2.txt
CUER=cuerpo2.txt
cat $CUER $ADJ | mail -s "Log del Proceso " $OPERADOR_TI

#DIRECTORIOS#
mkdir $RUTADESTINO/"$IDCON"


#CARGAS SQLLOADER#
sqlldr ${USRSISACT}/${PWDSISACT}@${BDSISACT} control=${RUTACTL}/${NAMECTL1} data="${RUTARPT}/${ARCHSAP}" bad=${RUTABAD}/${BADCTL1} log=${RUTALOG}/${LOGCTL1} bindsize=20000000 readsize=20000000 rows=20000000 skip=0 2>${RUTALOG}/${LOGSYSCTL1}
sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$DIRCTL/$CONTROL2 data=$DIRDOCUMENTOS/$FIELD003 bad=$DIRLOG/$CTLBAD2 log=$DIRLOG/$CTLLOG2 bindsize=200000 readsize=200000 rows=1000 skip=0

#************************************BASE DE DATOS*******************************#
#PRIMER FORMA#
NROLOTEPROCESO=`sqlplus -s ${USROAC}/${PWDUSROAC}@${BDUSROAC} <<EOP
WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET SERVEROUTPUT ON;
SET ARRAYSIZE 5000;
SET FLUSH ON;
SET BUFFER 500000000;
SET HEADING OFF;
SET FEEDBACK OFF;
SET TIMING OFF;
SET SPACE 0;
SET LINESIZE 4000;
SET ECHO OFF;
SET TERMOUT ON;
SET SERVEROUTPUT ON SIZE 50000;
SET UNDERLINE OFF;
SET VERIFY OFF;
SET NEWPAGE NONE;
CLEAR BUFFER

ALTER SESSION SET NLS_NUMERIC_CHARACTERS='.,';
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY HH24:MI:SS';
DECLARE
   NROLOTEPROCESO VARCHAR2(50);
BEGIN
   SELECT ${OWNUSROAC3}.${PKG_CONCILIACION}.CPAGFUN_SEQ_LOTEPROC
   INTO   NROLOTEPROCESO
   FROM   DUAL;
   DBMS_OUTPUT.PUT_LINE(TRIM(NROLOTEPROCESO));
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('ERROR:' || SQLCODE || ': ' || SQLERRM);
END;
/
EXIT;
EOP`

#SEGUNDA FORMA#
sqlplus -s ${USROAC}/${PWDUSROAC}@${BDUSROAC} <<EOP >${1}
WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET SERVEROUTPUT ON;
SET ARRAYSIZE 5000;
SET FLUSH ON;
SET BUFFER 500000000;
SET HEADING OFF;
SET FEEDBACK OFF;
SET TIMING OFF;
SET SPACE 0;
SET LINESIZE 4000;
SET ECHO OFF;
SET TERMOUT ON;
SET SERVEROUTPUT ON SIZE 50000;
SET UNDERLINE OFF;
SET VERIFY OFF;
SET NEWPAGE NONE;
CLEAR BUFFER

ALTER SESSION SET NLS_NUMERIC_CHARACTERS='.,';
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY HH24:MI:SS';

DECLARE
   PI_LOTE         NUMBER := '${2}';
   PO_CODERROR     NUMBER;
   PO_MSGERR       VARCHAR2(100);
BEGIN
   -- Call the procedure
   ${OWNUSROAC3}.${PKG_CONCILIACION}.CPAGSI_REG_CAJAS_ENTID(
                                             PI_LOTE,
                                             PO_CODERROR,
                                             PO_MSGERR);
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('ERROR PROCESO: INSERTAR EN LA TABLA DE ${OWNUSROAC3}.CPAGT_RES_CAJA_ENTIDAD' ||
                           ', COD_RPTA_BD: ' || TO_CHAR(PO_CODERROR) ||
                           ', MSG_RPTA_BD: ' || PO_MSGERR);
END;
/
EXIT
EOP

#TERCERA FORMA#
#LINESIZE (ANCHO DEL ARCHIVO)#
sqlplus -S ${USER_PVU}/${PASSWORD_PVU}@${BD_PVU} <<EOP > ${RUC_LINEAS}
WHENEVER SQLERROR EXIT SQL.SQLCODE;
 SET pagesize 0
 SET linesize 10000
 SET SPACE 0
 SET feedback off
 SET trimspool on
 SET termout off
 SET heading off
 SET verify off
 SET serveroutput on size 1000000
 SET echo off

DECLARE

TYPE CurPVU IS REF CURSOR;
C_CURSOR CurPVU;

V_RUCLINEAS CLOB;
BEGIN

$OWNER_PVU.sisact_pkg_despacho_corp.SISACTSS_CONS_TEL_REPORTE(C_CURSOR);

LOOP
	FETCH C_CURSOR INTO V_RUCLINEAS;
	EXIT WHEN C_CURSOR%NOTFOUND;
	dbms_output.put_line(V_RUCLINEAS);                                           
	
END LOOP;
CLOSE C_CURSOR;

EXCEPTION
    when OTHERS then
      dbms_output.put_line('Error: '||TO_CHAR(SQLCODE)||' Msg: '||SQLERRM);
 
END;
/

EXIT
EOP

#CUARTA FORMA#
USER=${USER_SANS}
PASSW=${PASS_SANS}
DB=${DB_SANS}
PROCESO=${CUENTA_01}
IDXSPO=${DIR_TEMPO}/CHURNPP_rep$PROCESO.txt
IDXSQL=${DIR_TEMPO}/CHURNPP_sql.sql

# -- Genera Documentos pendientes de proceso
echo "set pagesize 0"                                     									>  ${IDXSQL}
echo "set line 80"                                        									>> ${IDXSQL}
echo "spool ${IDXSPO}"                                    									>> ${IDXSQL}
echo "SELECT ST.CODIG, COUNT(ST.CODIG) AS REGISTROS, $PROCESO "  							>> ${IDXSQL}
echo "FROM SANS.ZNS_NRO_SIMCARDS NS "                     									>> ${IDXSQL}
echo "INNER JOIN ZNS_STAT_NRO_TEL ST ON NS.STNRI_IDSTAT_NRO_TEL = ST.STNRI_IDSTAT_NRO_TEL "	>> ${IDXSQL}
echo "GROUP BY ST.CODIG "                                  									>> ${IDXSQL}
echo "HAVING ST.CODIG IN ('006','022');"                 									>> ${IDXSQL}
echo "spool off"                                          									>> ${IDXSQL}
echo "exit"                                               									>> ${IDXSQL}
sqlplus -S ${USER}/${PASSW}@${DB} @${IDXSQL}

echo Fin del shell $0
exit

#QUINTA FORMA LANZANDO UN ARCHIVO.SQL CON PARAMETROS (C:\Users\SMT\Desktop\SHELL\SHELLS_EJEMPLOS\DENIS)
f_get_previos(){

V_PREVIOS=`sqlplus -s $CONEX_BD <<EOF
@../sql/sql_get_previos.sql "$OWNER" "$TABLA_WRK" "$CODIGO"
EOF
`

if [ $V_PREVIOS = "NADA" ];then
	V_REQS=0
else
	V_REQS=`echo $V_PREVIOS | awk 'BEGIN {FS=","} ; END {print NF}'`
fi

}
#************************************BASE DE DATOS*******************************#

#AGREGAR CABEZARIO#
echo "CADENA, COD. PDV, PUNTO DE VENTA, DEPARTAMENTO, DISTRITO, COD. POSTAL, COD.MATERIAL, MATERIAL, SERIE, TIPO DE DOA, TIPO DE CAFME, OBSERVACIONES, FECHA DE REGISTRO DE DOA/CAFME" > $ARCH_TEMP2_SED
cat ${ARCH_TEMP1} >> $ARCH_TEMP2_SED


#TAMAÑO ARCHIVO#
TAMAGNO_ARCHIVO=`echo $(du -hs $RUTA_ORIGEN/$ARCHIVO_ORIGINAL) | awk 'BEGIN{FS=" "} {print $1}'`


#PARAMETROS#
$#
$1
$2

#**********************************COMANDO SED***********************************#
#AGREGA UNA COLUMNA FINAL EN EL ARCHIVO#
pFormateoArchANU () {
rm -f ${RUTARPT}/${ARCHANUFIN}
ls -1 ${RUTARPT}/${ARCHANU}>${RUTALOG}/LISTA_ARCHANULACIONES.TXT
while read ListaAnul
do
	ARCHIVO_ANU=${RUTARPT}/temporal.csv
	NOMBRE_ARCHIVO="${ListaAnul##*/}"
	cat ${ListaAnul} > ${ARCHIVO_ANU}
	sed -i s/$/,"$NOMBRE_ARCHIVO"/ "${ARCHIVO_ANU}"	
	sed 1d "${ARCHIVO_ANU}" >> ${RUTARPT}/${ARCHANUFIN}
	rm -f ${ARCHIVO_ANU}
done < ${RUTALOG}/LISTA_ARCHANULACIONES.TXT

rm -f ${RUTALOG}/LISTA_ARCHANULACIONES.TXT

}
#**********************************COMANDO SED***********************************#
#AGREGAMOS TEXTO EN LA PRIMERA LINEA
sed -i '1i'"${TEXTO}" ${FILENAME}

#*****************************OBTENER EJECUCIONES*******************************#
HORAINICIOP=`date +'%H%M%S'`
NROIDENTIFI=$(GetNumSecuencial)
#*****************************OBTENER EJECUCIONES*******************************#

#ELIMINAR PRIMER REGISTRO
sed '1d' mi_fichero.txt

##ayudara en algo
#SELECCIONAR ULTIMA LINEA
tail -n1 SL197717072501_1 > linea.txt

#ELIMINAR ULTIMA LINEA
sed '$d' SL197717072501_1 > final.txt

cat linea.txt | tr -d '\n' >> final.txt

