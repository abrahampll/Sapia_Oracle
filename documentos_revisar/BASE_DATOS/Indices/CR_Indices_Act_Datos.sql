-- Create/Act_Postpago
create index PCLUB.IDX_ACTCLIENTES_POST_01 on PCLUB.ADMPT_IMP_ACTCLIENTES_POST (ADMPD_FEC_REG)
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

-- Create/Act_Prepago
create index PCLUB.IDX_ACTCLIENTES_PREP_01 on PCLUB.ADMPT_IMP_ACTCLIENTES_PRE (ADMPD_FEC_REG)
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