create index PCLUB.IDX_ADMPT_CANJE_02 on PCLUB.ADMPT_CANJE (ADMPV_VENTAID)
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
  
create index PCLUB.IDX_CANJEFIJA_02 on PCLUB.ADMPT_CANJEFIJA (ADMPV_VENTAID)
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
