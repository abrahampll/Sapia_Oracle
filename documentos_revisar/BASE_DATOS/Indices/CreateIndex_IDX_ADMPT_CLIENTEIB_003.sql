create index PCLUB.IDX_ADMPT_CLIENTEIB_003 on PCLUB.ADMPT_CLIENTEIB (ADMPD_FEC_ACT, ADMPN_BONO_ACT, ADMPC_ESTADO)
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
