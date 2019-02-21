create index PCLUB.IDX_CODCLI_TPOCL on PCLUB.ADMPT_CLIENTE (ADMPV_COD_CLI, ADMPV_COD_TPOCL)
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
