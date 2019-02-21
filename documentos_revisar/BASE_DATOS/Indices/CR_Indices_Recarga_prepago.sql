create index PCLUB.IDX_ADMPT_IMP_PRERECARGA_01 on PCLUB.ADMPT_IMP_PRERECARGA (ADMPV_COD_CLI, ADMPD_FEC_OPER)
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
  
  create index PCLUB.IDX_ADMPT_TMP_PRERECARGA_01 on PCLUB.ADMPT_TMP_PRERECARGA (ADMPV_COD_CLI, ADMPD_FEC_OPER)
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
