create index PCLUB.IDX_CCLI_TPTO_EST_FT on PCLUB.ADMPT_KARDEX (ADMPV_COD_CLI, ADMPC_TPO_PUNTO, ADMPC_ESTADO, ADMPD_FEC_TRANS)
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
  )local ;
