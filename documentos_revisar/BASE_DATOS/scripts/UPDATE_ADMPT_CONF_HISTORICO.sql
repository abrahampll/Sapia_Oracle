-------UPDATE ---ADMPT_CONF_HISTORICO---------------------------
update PCLUB.ADMPT_CONF_HISTORICO 
set ESTADO_EJECUCION='0' 
where ID_ESTADO_PROC=1;--a solicitud del soap
commit;
