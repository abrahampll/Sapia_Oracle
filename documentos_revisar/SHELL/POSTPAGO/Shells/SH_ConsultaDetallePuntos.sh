#! /bin/ksh
#*************************************************************
#* DESCRIPCION           : Consulta detalle de puntos - Claro Club                                    *
#* EJECUCION             : Control-D                                                          *
#* AUTOR                 : T14689                            *
#* FECHA                 : 27/09/2011   VERSION : v1.0                        *
#* FECHA MOD .           :                         *
#*************************************************************

#Iniciación de Variables
# Inicializacion de Variables
. /home/usrclaroclub/CLAROCLUB/Interno/Postpago/Bin/.varset
. /home/usrclaroclub/CLAROCLUB/Interno/Postpago/Bin/.passet
. /home/usrclaroclub/CLAROCLUB/Interno/Postpago/Bin/.mailset

#-----------------------------------------------------------------
#	FUNCION PARA MANEJO DEL LOG
#-----------------------------------------------------------------
pMessage () {   
   LOGDATE=`date +"%d-%m-%Y %H:%M:%S"`
   echo "($LOGDATE) $*" 
   echo "($LOGDATE) $*"  >> $FILELOG
   
} # pMessage

FARCH=`date +%Y%m%d`

# Rutas
REPORT=$1
FILELOG=$DIRLOGPOST/ConsultaDetallePuntos_$FARCH.log
ARCHSAL=$DIRLOGPOST/ConsultaDetallePuntos_$FARCH.TXT

#sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> ${ARCHSAL}
sqlplus -S ${USER_BD}/${CLAVE_BD}@${SID_BD} <<EOP >> ${ARCHSAL}
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

#SPOOL $ARCHSAL

declare
type CUR_C IS REF CURSOR;
c1 CUR_C;
lc_doc varchar2(20);
ln_idkardex int;
lc_cuenta varchar2(40);
lc_cpto varchar2(200);
lc_desccpto varchar2(50);
ld_fechatrans date;
ln_puntos int;
ln_largodesc int;
ln_largodesc_kd int;
ln_dif int;
lc_cadena varchar2(200);
ln_largocuenta int;
ln_largocuenta1 int;
ln_dif1 int;
lc_cadena1 varchar2(200);

begin
  lc_doc := '16726087';

open c1 for
  select c.admpv_cod_cli,c.admpv_nom_cli
  from pclub.admpt_cliente c where c.admpv_num_doc = lc_doc;

loop
FETCH c1 INTO lc_cuenta,lc_cpto;
EXIT WHEN c1%NOTFOUND;

-- controla longitud del Concepto
  select max(length(c.admpv_nom_cli))
    into ln_largodesc
    from pclub.admpt_cliente c where c.admpv_num_doc = lc_doc;

  select length(lc_cuenta)
    into ln_largodesc_kd
    from dual;

if ln_largodesc_kd<ln_largodesc then
   ln_dif := ln_largodesc-ln_largodesc_kd;
   lc_cadena := '';

     while ln_dif>0 loop
        lc_cadena := lc_cadena||' ';
        ln_dif := ln_dif-1;
     end loop;
   lc_desccpto := lc_desccpto||lc_cadena;
end if;
--

-- controla longitud de la Cuenta
  select max(length(c.admpv_cod_cli))
    into ln_largocuenta
    from pclub.admpt_cliente c where c.admpv_num_doc = lc_doc;

  select length(lc_cuenta)
    into ln_largocuenta1
    from dual;

if ln_largocuenta1<ln_largocuenta then
   ln_dif1 := ln_largocuenta-ln_largocuenta1;
   lc_cadena1 := '';

     while ln_dif1>0 loop
        lc_cadena1 := lc_cadena1||' ';
        ln_dif1 := ln_dif1-1;
     end loop;
   lc_cuenta := lc_cuenta||lc_cadena1;
end if;
--

    dbms_output.put_line(lc_desccpto || '| ' || lc_cuenta || '| ' || ld_fechatrans || '| ' || ln_puntos);

end loop;
close c1;
end;
/
#SPOOL OFF;

EXIT
EOP

pMessage "Termino proceso"
pMessage "********** FINALIZANDO PROCESO ********** " 
pMessage "Fin de proceso "
pMessage "************************************" 
pMessage "Ruta del Archivo log : ${DIRLOG}/${FILELOG}" 
pMessage "" 


exit