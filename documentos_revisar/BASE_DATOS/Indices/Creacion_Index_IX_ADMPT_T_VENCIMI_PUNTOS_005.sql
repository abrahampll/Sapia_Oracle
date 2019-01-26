CREATE INDEX PCLUB.IX_ADMPT_T_VENCIMI_PUNTOS_005 On PCLUB.ADMPT_TMP_VENCIMIENTO_PUNTOS (ADMPV_COD_CLI)  
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
