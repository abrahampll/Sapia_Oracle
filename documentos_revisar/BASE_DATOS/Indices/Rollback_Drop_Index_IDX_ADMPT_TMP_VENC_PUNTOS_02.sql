create bitmap index PCLUB.IDX_ADMPT_TMP_VENC_PUNTOS_02 on PCLUB.ADMPT_TMP_VENCIMIENTO_PUNTOS (ADMPN_REGPROC)
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
