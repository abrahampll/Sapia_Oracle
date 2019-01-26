CREATE INDEX PCLUB.IX_ADMPT_TMP_CLIENTE_PRE_001 On PCLUB.ADMPT_TMP_CLIENTE_PRE (ADMPN_REGPROC, ADMPN_CATEGORIA)  
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
 