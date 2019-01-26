create index IDX_CANJE_LINEA on ADMPT_CANJE (admpv_num_linea)
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 2M
    next 1M
    minextents 1
    maxextents unlimited
  );
  