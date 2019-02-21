
  create index IDX_ADMPD_FEC_ACTIV on PCLUB.ADMPT_CLIENTE(ADMPD_FEC_ACTIV)
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
  
  create index IDX_ADMPV_COD_CLIIB on PCLUB.ADMPT_CLIENTEIB(ADMPV_COD_CLI)
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
  
  create index IDX_ADMPV_COD_CLI_CA on PCLUB.ADMPT_CANJE(ADMPV_COD_CLI)
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
  
  create index IDX_ADMPD_FEC_OPER_RE on PCLUB.ADMPT_IMP_PRESINRECARGA(ADMPD_FEC_OPER)
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
  
  create index IDX_ADMPD_FEC_OPER_BA on PCLUB.ADMPT_TMP_PREBAJA(ADMPD_FEC_OPER)
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
  
  create index FK_ADMP_TMP_PRE_CARGAIN on ADMPT_TMP_PRECARGAIN (ADMPV_TIPO_DOC, ADMPV_NUM_DOC)
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
  
  create index FK_ADMP_TMP_PRE_CARGAIN1 on ADMPT_TMP_PRECARGAIN (ADMPV_NUM_DOC)
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
  
