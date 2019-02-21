-- Create/Recreate indexes 
create index PCLUB.IDX_ADMPT_CANJEDT_KARDEX on PCLUB.ADMPT_CANJEDT_KARDEX (ADMPN_ID_KARDEX)
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
create index PCLUB.IDX_ADMPT_ID_CANJE on PCLUB.ADMPT_CANJEDT_KARDEX (ADMPV_ID_CANJE)
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
  
  create index PCLUB.IDX_ADMPT_CANJE_DETALLE  on PCLUB.ADMPT_CANJE_DETALLE (  ADMPV_ID_CANJE)
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
  

  
