update PCLUB.cc_config_sms 
set    CONFV_VALOR = 'USRFIDE'
where  CONFN_CODIGO in (8, 9);

update PCLUB.cc_config_sms 
set    CONFV_VALOR = 'ehuerta@claro.com.pe'
where  CONFN_CODIGO = 26;

commit;