create index PCLUB.IDX_CC_FIDELIDAD_01 on PCLUB.CC_FIDELIDAD(CCFIDC_VAL_BL)
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