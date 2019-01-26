CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_ACLIESERV_SVR_001 ON PCLUB.ADMPT_TMP_ALTACLIENTESERV_SVR (ADMPV_CUSTCODE)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_ACLIESERV_SVR_002 ON PCLUB.ADMPT_TMP_ALTACLIENTESERV_SVR (ADMPV_TIPO_SERV)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_ACLIESERV_SVR_003 ON PCLUB.ADMPT_TMP_ALTACLIENTESERV_SVR (ADMPD_FEC_OPER)
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
CREATE INDEX PCLUB.IX_ADMPT_TMP_ACLIESRV_SVR_002 ON PCLUB.ADMPT_TMP_ALTACLIENTESERV_SVR (ADMPV_TIP_CLIENTE, ADMPD_FEC_OPER)
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
CREATE INDEX PCLUB.IX_ADMPT_TMP_ALTACLIESERV_001 ON PCLUB.ADMPT_TMP_ALTACLIENTESERV_SVR (ADMPV_CUSTCODE||'_'||ADMPV_TIPO_SERV)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_BAJA_CC_001 ON PCLUB.ADMPT_TMP_BAJA_CC (ADMPV_MSJE_ERROR)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_BAJA_CC_002 ON PCLUB.ADMPT_TMP_BAJA_CC (ADMPD_FEC_OPER)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_BAJA_CC_003 ON PCLUB.ADMPT_TMP_BAJA_CC (ADMPV_TIP_CLIENTE)
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
CREATE INDEX PCLUB.IX_ADMPT_TMP_BAJA_CC_004 ON PCLUB.ADMPT_TMP_BAJA_CC (ADMPV_CUSTCODE)
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