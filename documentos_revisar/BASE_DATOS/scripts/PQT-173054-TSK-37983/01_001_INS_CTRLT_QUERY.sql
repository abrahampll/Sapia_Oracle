insert into pclub.ctrlt_query
  (CTRLB_QUERY, CTRLN_FLAG, CTRLV_TITULO, CTRLV_ESTADO)
values
  (q'{SELECT PA.ADMPC_COD_PARAM as CODIGO,
        NULL FECHA_INS,
        1 FLAG,
        PA.ADMPV_DESC,
        PA.ADMPV_VALOR
FROM PCLUB.ADMPT_PARAMSIST PA}',
   1,
   'PARAMETROS',
   '1');

commit;