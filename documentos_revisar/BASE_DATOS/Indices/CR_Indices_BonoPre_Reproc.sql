-- Create/Recreate indexes 
create index PCLUB.IDX_ADMPT_BONOPREP_ERR_01 on PCLUB.ADMPT_BONOPREP_ERR (ADMPV_ESTADO)
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
  
