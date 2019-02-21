CREATE INDEX PCLUB.IX_TMP_PRESINRECARGA_01 On PCLUB.ADMPT_TMP_PRESINRECARGA (LENGTH(ADMPV_COD_CLI))  
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
  
CREATE INDEX PCLUB.IX_TMP_PRESINRECARGA_02 On PCLUB.ADMPT_TMP_PRESINRECARGA (ADMPV_CODERROR)  
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
  
CREATE INDEX PCLUB.IX_TMP_PRESINRECARGA_03 On PCLUB.ADMPT_TMP_PRESINRECARGA (ADMPN_SEC)  
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
  
CREATE INDEX PCLUB.IX_TMP_PRESINRECARGA_04 On PCLUB.ADMPT_TMP_PRESINRECARGA (ADMPV_COD_CLI)  
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
  
CREATE INDEX PCLUB.IX_TMP_PRESINRECARGA_05 On PCLUB.ADMPT_TMP_PRESINRECARGA (ADMPV_COD_CLI, '1')  
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
  
CREATE INDEX PCLUB.IX_TMP_PRESINRECARGA_06 On PCLUB.ADMPT_TMP_PRESINRECARGA (ADMPN_CATEGORIA)  
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
  
CREATE INDEX PCLUB.IX_PREDESAFIL_NORECAR_001 On PCLUB.ADMPT_TMP_PREDESAFIL_NORECAR (ADMPV_NOMARCHIVO)  
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
  
CREATE INDEX PCLUB.IX_PREDESAFIL_NORECAR_002 On PCLUB.ADMPT_TMP_PREDESAFIL_NORECAR (ADMPC_ESTADO)  
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
  
CREATE INDEX PCLUB.IX_PREDESAFIL_NORECAR_003 On PCLUB.ADMPT_TMP_PREDESAFIL_NORECAR (LENGTH(ADMPV_COD_CLI))  
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
  
CREATE INDEX PCLUB.IX_PREDESAFIL_NORECAR_004 On PCLUB.ADMPT_TMP_PREDESAFIL_NORECAR (ADMPV_CODERROR)  
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
  
CREATE INDEX PCLUB.IX_PREDESAFIL_NORECAR_005 On PCLUB.ADMPT_TMP_PREDESAFIL_NORECAR (ADMPN_SEC)  
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
  
CREATE INDEX PCLUB.IX_PREDESAFIL_NORECAR_006 On PCLUB.ADMPT_TMP_PREDESAFIL_NORECAR (ADMPV_COD_CLI)  
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
  
CREATE INDEX PCLUB.IX_PREDESAFIL_NORECAR_007 On PCLUB.ADMPT_TMP_PREDESAFIL_NORECAR (ADMPV_COD_CLI, '1')  
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
  
CREATE INDEX PCLUB.IX_PREDESAFIL_NORECAR_008 On PCLUB.ADMPT_TMP_PREDESAFIL_NORECAR (ADMPN_CATEGORIA)  
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
  