create index PCLUB.IX_PARAM_001 on PCLUB.T_ADMPT_PARAM (PARN_NUM_ARCH)
  tablespace PCLUB_DATA
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

