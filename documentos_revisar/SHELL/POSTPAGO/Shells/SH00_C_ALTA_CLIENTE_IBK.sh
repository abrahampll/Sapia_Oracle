#!/bin/sh 

. /home/usrclaroclub/CLAROCLUB/Interno/Postpago/Bin/.mailset
. /home/usrclaroclub/CLAROCLUB/Interno/Postpago/Bin/.passet
. /home/usrclaroclub/CLAROCLUB/Interno/Postpago/Bin/.varset

FILE_PATRO="IBACTCANMOR_"
#FILE_FECHA=`date +%Y%m%d`
FILE_FECHA=`(date +%Y%m%d --date='-1 day')`
FILE_EXTEN='.DIA.TXT'
FILE=${FILE_PATRO}${FILE_FECHA}${FILE_EXTEN}

DIRDOC=/home/usrclaroclub/CLAROCLUB/Externo/ProgramaRecompensasIB/Procesado/Entrada
FILCTRL=/home/usrclaroclub/CLAROCLUB/Interno/Postpago/Ctl
FILEERR=/home/usrclaroclub/CLAROCLUB/Interno/Postpago/Error
FILELOG=/home/usrclaroclub/CLAROCLUB/Interno/Postpago/Logs
FILEDAT=""


GetNumSecuencial(){
 echo `date +'%Y%m%d%H%M%S%N'`
}

GENERAR_FILE(){
 FILEDATA=$1
 SECUENCI=$(GetNumSecuencial)
 FILETEMP="FILETMP_${SECUENCI}.TMP"
 
 FILCTRL=$FILCTRL/CTL_ALTA_CLIENTE.ctl  #archivo control 
 FILEERR=$FILEERR/FILERR_${SECUENCI}.TMP
 FILELOG=$FILELOG/FILLOG_${SECUENCI}.LOG
 
 while read FIELD01
 do
		CODCLIENTE=`echo $FIELD01 | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $8}' `
		DNICLIENTE=`echo $FIELD01 | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $3}' `
		TIPOPER=`echo $FIELD01 | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}' `
		FECREG=`echo $FIELD01 | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $9}' `
		NOMBREFILE=$FILE
		echo "3|5|AFILIACION LINEAS IBK|$CODCLIENTE|$DNICLIENTE||$TIPOPER|$FECREG|$NOMBREFILE" >> $FILETEMP
 done < $FILEDATA
 
 sqlldr $USER_BD/$CLAVE_BD@$SID_BD control=$FILCTRL data=$FILETEMP bad=$FILEERR log=$FILELOG bindsize=200000 readsize=200000 rows=1000 skip=0
 
}



for file in $(ls $DIRDOC/$FILE)
do
	if [ "$file" != "" ] && [ -e $file ]; then
	  GENERAR_FILE $file
	fi
done
rm -f $FILETEMP


sh -x /home/usrclaroclub/CLAROCLUB/Interno/Postpago/Shells/SH00_C_ALTA_CLIENTE_POSTPAGO.sh