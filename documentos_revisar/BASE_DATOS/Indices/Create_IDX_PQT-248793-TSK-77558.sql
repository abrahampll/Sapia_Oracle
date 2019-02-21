-- Create/Recreate indexes-----
create index PCLUB.IX_ADMPT_IMP_REGDTH_HFC_001 on PCLUB.ADMPT_IMP_REGDTH_HFC (admpv_cod_tpocl, admpd_fec_oper)
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
  

CREATE INDEX PCLUB.IX_ADMPT_TMP_PAGO_CC_002 On PCLUB.ADMPT_TMP_PAGO_CC (ADMPV_COD_CLI , ADMPV_PERIODO)  
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
  
CREATE INDEX PCLUB.IX_ADMPT_AUX_PAGO_CC_001 On PCLUB.ADMPT_AUX_PAGO_CC (ADMPV_COD_CLI)  
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

CREATE INDEX PCLUB.IX_ADMPT_AUX_PAGO_CC_002 On PCLUB.ADMPT_AUX_PAGO_CC (ADMPD_FEC_OPER)  
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
    
CREATE INDEX PCLUB.IX_ADMPT_SMS_TELEFONOS_001 On PCLUB.ADMPT_SMS_TELEFONOS (ADMPV_COD_CLIENTE)  
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
  
CREATE INDEX PCLUB.IX_ADMPT_IMP_PAGO_CC_002 On PCLUB.ADMPT_IMP_PAGO_CC (ADMPD_FEC_OPER)  
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

create index PCLUB.IX_ADMPT_TMP_ALTACLI_TFI_003 on PCLUB.ADMPT_TMP_ALTACLI_TFI (ADMPD_FEC_OPER, ADMPV_TIPO_CLI)
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

create index PCLUB.IX_ADMPT_IMP_ALTACLI_TFI_002 on PCLUB.ADMPT_IMP_ALTACLI_TFI  (ADMPV_TIPO_CLI)
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


create index PCLUB.IX_ADMPT_AUX_ALTACLI_TFI_002 on PCLUB.ADMPT_AUX_ALTACLI_TFI (ADMPV_COD_CLI)
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

create index PCLUB.IX_ADMPT_AUX_ALTACLI_CC_001 on PCLUB.ADMPT_AUX_ALTACLI_CC(ADMPV_COD_CLI)
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

create index PCLUB.IX_ADMPT_TMP_ALTACLI_CC_001 on PCLUB.ADMPT_TMP_ALTACLI_CC(ADMPD_FEC_OPER)
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