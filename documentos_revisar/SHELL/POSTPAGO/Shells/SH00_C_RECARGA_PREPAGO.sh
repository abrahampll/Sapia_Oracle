#!/bin/sh 

. /home/usrclaroclub/CLAROCLUB/Interno/Postpago/Bin/.mailset
. /home/usrclaroclub/CLAROCLUB/Interno/Postpago/Bin/.passet
. /home/usrclaroclub/CLAROCLUB/Interno/Postpago/Bin/.varset

FILE_PATRO="RECARGA_"         
FILE_FECHA=`date +%d%m%Y`
FILE_EXTEN='.TXT'
FILE=${FILE_PATRO}${FILE_FECHA}*${FILE_EXTEN}

DIRDOC=/home/usrclaroclub/CLAROCLUB/Interno/Prepago/Procesados
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
 
 FILCTRL=$FILCTRL/CTL_RECARGA.ctl  #archivo control 
 FILEERR=$FILEERR/FILERR_${SECUENCI}.TMP
 FILELOG=$FILELOG/FILLOG_${SECUENCI}.LOG
 
 while read FIELD01
 do
		lINEA=`echo $FIELD01 | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $1}' `
		RECARGA=`echo $FIELD01 | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $2}' `
		FECHA=`echo $FIELD01 | sed 's/\\r//g'|awk 'BEGIN{FS="|"} {print $3}' `		
		echo "$lINEA|$RECARGA|$FECHA" >> $FILETEMP
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



