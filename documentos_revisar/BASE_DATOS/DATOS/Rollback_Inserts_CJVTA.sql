delete PCLUB.admpt_concepto
where admpv_cod_cpto = '82';

delete PCLUB.admpt_paramsist
where admpc_cod_param = '227';

delete PCLUB.admpt_paramsist
where admpc_cod_param = '228';

delete PCLUB.admpt_premio
where ADMPV_ID_PROCLA = 'U_DSCEQUIPO';

DELETE FROM PCLUB.ADMPT_ERRORES_CC WHERE ADMPN_COD_ERROR IN (37,40,41,49);

commit;
