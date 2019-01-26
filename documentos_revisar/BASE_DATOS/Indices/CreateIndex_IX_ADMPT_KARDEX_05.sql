create index PCLUB.IX_ADMPT_KARDEX_05 on PCLUB.ADMPT_KARDEX (ADMPD_FEC_TRANS, ADMPC_TPO_PUNTO, ADMPC_TPO_OPER, ADMPV_COD_CPTO, ADMPC_ESTADO, ADMPV_COD_CLI)
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
