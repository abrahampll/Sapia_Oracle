insert into pclub.ctrlt_query
  (CTRLB_QUERY, CTRLN_FLAG, CTRLV_TITULO, CTRLV_ESTADO)
values
  (q'{SELECT BO.ADMPV_BONO || '-' || CO.ADMPV_COD_TPOPR AS CODIGO,
       NULL FECHA_INS,
       3 FLAG,
       BO.ADMPV_BONO,
       BO.ADMPN_ID_BONO_PRE,
       BO.ADMPV_MENSAJE,
       BO.ADMPC_ESTADO,
       BO.ADMPD_FEC_REG,
       BO.ADMPV_USU_REG,
       BO.ADMPD_FEC_MOD,
       BO.ADMPV_USU_MOD,
       BO.ADMPV_DESCBONO,
       CO.ADMPV_BONO ADMPV_BONO_CONF,
       CO.ADMPV_COD_TPOPR,
       CO.ADMPN_PUNTOS,
       CO.ADMPN_DIASVIGEN,
       CO.ADMPV_COD_CPTO,
       CO.ADMPC_ESTADO,
       CO.ADMPD_FEC_REG,
       CO.ADMPV_USU_REG,
       CO.ADMPD_FEC_MOD,
       CO.ADMPV_USU_MOD
  FROM PCLUB.ADMPT_BONO BO, PCLUB.ADMPT_BONO_CONFIG CO
 WHERE BO.ADMPV_BONO = CO.ADMPV_BONO}',
   3,
   'BONOS',
   '1');

commit;