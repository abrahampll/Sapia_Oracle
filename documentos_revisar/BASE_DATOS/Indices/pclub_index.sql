create index IDX_KAR_FECTRA on PCLUB.ADMPT_KARDEX(ADMPD_FEC_TRANS)
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

create index IDX_PARAM_UPDESC on PCLUB.ADMPT_PARAMSIST(UPPER(ADMPV_DESC))   
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
      