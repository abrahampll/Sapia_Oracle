while true
do
   v_hora=`date +"%H"`
   v_minuto=`date +"%M"`
   v_segundo=`date +"%S"`

   if [ $v_hora -eq 17 ] && [ $v_minuto -eq 39 ];
   then
        sh SH001_PROC_ALTACLIDTH.sh
		sh SH002_PROC_PAGOS.sh
		sh SH003_PROC_BAJADTH.sh
   else
    echo 'NO'
   fi
   sleep 60
done
