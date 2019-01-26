CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_ACLIENTE_SVR_001 ON PCLUB.ADMPT_TMP_ALTACLIENTE_SVR (ADMPV_CUSTCODE)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_ACLIENTE_SVR_002 ON PCLUB.ADMPT_TMP_ALTACLIENTE_SVR (ADMPV_TIP_CLIENTE)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_ACLIENTE_SVR_003 ON PCLUB.ADMPT_TMP_ALTACLIENTE_SVR (ADMPV_TIPO_DOC)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_ACLIENTE_SVR_004 ON PCLUB.ADMPT_TMP_ALTACLIENTE_SVR (ADMPV_NUM_DOC)
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
CREATE INDEX PCLUB.IX_ADMPT_TMP_ACLIENTE_SVR_005 ON PCLUB.ADMPT_TMP_ALTACLIENTE_SVR (ADMPV_TIP_CLIENTE, ADMPD_FEC_OPER)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_IMP_ACLIESERV_SVR_001 ON PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR (ADMPV_TIP_CLIENTE)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_IMP_ACLIESERV_SVR_002 ON PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR (ADMPD_FEC_OPER)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_IMP_ACLIESERV_SVR_003 ON PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR (ADMPV_MSJE_ERROR)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_PAGO_FACT_001 ON PCLUB.ADMPT_TMP_PAGO_FACT (ADMPV_TIPO_SERV)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_PAGO_FACT_002 ON PCLUB.ADMPT_TMP_PAGO_FACT (ADMPV_CUSTCODE)
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
CREATE INDEX PCLUB.IX_ADMPT_TMP_PAGO_FACT_003 ON PCLUB.ADMPT_TMP_PAGO_FACT (ADMPV_MSJE_ERROR)
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
CREATE INDEX PCLUB.IX_ADMPT_TMP_ANIV_CC_001 ON PCLUB.ADMPT_TMP_ANIV_CC (ADMPV_MSJE_ERROR)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_ANIV_CC_002 ON PCLUB.ADMPT_TMP_ANIV_CC (ADMPD_FEC_OPER)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_ANIV_CC_003 ON PCLUB.ADMPT_TMP_ANIV_CC (ADMPV_TIP_CLIENTE)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_ANIV_CC_004 ON PCLUB.ADMPT_TMP_ANIV_CC (ADMPN_PUNTOS)
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
  
CREATE INDEX PCLUB.IDX_CONCEPTO_02 ON PCLUB.ADMPT_CONCEPTO (TRIM(UPPER(ADMPV_DESC)))
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
  
CREATE INDEX PCLUB.IX_ADMPT_CLIENTEPRODUCTO_02 ON PCLUB.ADMPT_CLIENTEPRODUCTO (SUBSTR(ADMPV_COD_CLI_PROD,0,22))
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
  
CREATE BITMAP INDEX PCLUB.IDX_CLIENTEFIJA_001 ON PCLUB.ADMPT_CLIENTEFIJA (ADMPC_ESTADO)
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
  
CREATE INDEX PCLUB.IX_ADMPT_CLIENTEFIJA_001 ON PCLUB.ADMPT_SALDOS_CLIENTEFIJA (SUBSTR(ADMPV_COD_CLI_PROD,0,22))
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
  
CREATE BITMAP INDEX PCLUB.IX_ADMPT_CLIENTEFIJA_002 ON PCLUB.ADMPT_SALDOS_CLIENTEFIJA (ADMPC_ESTPTO_CC)
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
  
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_CPLAN_HFCB_001 ON PCLUB.ADMPT_TMP_CAMBIOPLAN_HFCB (ADMPV_MSJE_ERROR)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_CPLAN_HFCB_002 ON PCLUB.ADMPT_TMP_CAMBIOPLAN_HFCB (ADMPD_FEC_OPER)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_CPLAN_HFCB_003 ON PCLUB.ADMPT_TMP_CAMBIOPLAN_HFCB (ADMPV_TIP_CLIENTE)
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
CREATE INDEX PCLUB.IX_ADMPT_TMP_CPLAN_HFCB_004 ON PCLUB.ADMPT_TMP_CAMBIOPLAN_HFCB (ADMPV_CUSTCODE)
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
  
  
CREATE INDEX PCLUB.IX_ADMPT_CTL_CANJES_001 ON PCLUB.ADMPT_CTL_CANJES (ADMPD_FEC_REG)
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
  
  
CREATE INDEX PCLUB.IX_ADMPT_ALTACLIENTE_RPT_001 on PCLUB.ADMPT_TMP_ALTACLIENTE_RPT (ADMPD_FEC_OPER, ADMPV_CUSTCODE, ADMPV_TIP_CLIENTE, ADMPV_COD_ERROR)
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
CREATE INDEX PCLUB.IX_ADMPT_ALTACLIENTE_RPT_002 on PCLUB.ADMPT_TMP_ALTACLIENTE_RPT (ADMPD_FEC_OPER, ADMPV_CUSTCODE, ADMPV_TIP_CLIENTE)
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
CREATE INDEX PCLUB.IX_ADMPT_ALTACLIENTE_RPT_003 on PCLUB.ADMPT_TMP_ALTACLIENTE_RPT (ADMPV_TIP_CLIENTE, ADMPV_CUSTCODE)
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
  
  
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_ACLIENTE_RPT_001 ON PCLUB.ADMPT_TMP_ALTACLIENTE_RPT (ADMPV_CUSTCODE)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_ACLIENTE_RPT_002 ON PCLUB.ADMPT_TMP_ALTACLIENTE_RPT (ADMPV_TIP_CLIENTE)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_ACLIENTE_RPT_003 ON PCLUB.ADMPT_TMP_ALTACLIENTE_RPT (ADMPV_TIPO_DOC)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_ACLIENTE_RPT_004 ON PCLUB.ADMPT_TMP_ALTACLIENTE_RPT (ADMPV_NUM_DOC)
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
CREATE INDEX PCLUB.IX_ADMPT_TMP_ACLIENTE_RPT_005 ON PCLUB.ADMPT_TMP_ALTACLIENTE_RPT (ADMPV_TIP_CLIENTE, ADMPD_FEC_OPER)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_ACLIENTE_RPT_006 ON PCLUB.ADMPT_TMP_ALTACLIENTE_RPT (ADMPV_COD_ERROR)
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
  
  
CREATE INDEX PCLUB.IX_ADMPT_TMP_ACLIESRV_RPT_001 ON PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT (ADMPV_CUSTCODE||'_'||ADMPV_TIPO_SERV)
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
CREATE INDEX PCLUB.IX_ADMPT_TMP_ACLIESRV_RPT_002 ON PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT (ADMPV_TIP_CLIENTE, ADMPD_FEC_OPER)
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
CREATE INDEX PCLUB.IX_ADMPT_TMP_ACLIESRV_RPT_003 ON PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT (ADMPV_CUSTCODE)
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
CREATE INDEX PCLUB.IX_ADMPT_ALTACLISRV_RPT_001 on PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT (ADMPD_FEC_OPER, ADMPV_CUSTCODE, ADMPV_TIP_CLIENTE, ADMPV_COD_ERROR)
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
CREATE INDEX PCLUB.IX_ADMPT_ALTACLISRV_RPT_002 on PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT (ADMPD_FEC_OPER, ADMPV_CUSTCODE, ADMPV_TIP_CLIENTE)
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
CREATE INDEX PCLUB.IX_ADMPT_ALTACLISRV_RPT_003 ON PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT (ADMPV_TIP_CLIENTE, ADMPV_CUSTCODE)
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


  
CREATE BITMAP INDEX PCLUB.IX_ADMPT_IMP_ACLIESERV_RPT_001 ON PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT (ADMPV_TIP_CLIENTE)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_IMP_ACLIESERV_RPT_002 ON PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT (ADMPD_FEC_OPER)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_IMP_ACLIESERV_RPT_003 ON PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT (ADMPV_MSJE_ERROR)
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


  
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_PAGOFACT_RPT_001 ON PCLUB.ADMPT_TMP_PAGOFACT_RPT (ADMPV_TIPO_SERV)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_PAGOFACT_RPT_002 ON PCLUB.ADMPT_TMP_PAGOFACT_RPT (ADMPV_CUSTCODE)
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
CREATE INDEX PCLUB.IX_ADMPT_TMP_PAGOFACT_RPT_003 ON PCLUB.ADMPT_TMP_PAGOFACT_RPT (ADMPV_MSJE_ERROR)
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

  
CREATE INDEX PCLUB.IX_ADMPT_TMP_ANIV_RPT_001 ON PCLUB.ADMPT_TMP_ANIV_RPT (ADMPV_MSJE_ERROR)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_ANIV_RPT_002 ON PCLUB.ADMPT_TMP_ANIV_RPT (ADMPD_FEC_OPER)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_ANIV_RPT_003 ON PCLUB.ADMPT_TMP_ANIV_RPT (ADMPV_TIP_CLIENTE)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_ANIV_RPT_004 ON PCLUB.ADMPT_TMP_ANIV_RPT (ADMPN_PUNTOS)
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
CREATE INDEX PCLUB.IX_ADMPT_TMP_ANIV_RPT_005 ON PCLUB.ADMPT_TMP_ANIV_RPT (ADMPD_FEC_OPER, ADMPV_CUSTCODE, ADMPV_TIP_CLIENTE, ADMPC_COD_ERROR)
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
CREATE INDEX PCLUB.IX_ADMPT_TMP_ANIV_RPT_006 ON PCLUB.ADMPT_TMP_ANIV_RPT (ADMPD_FEC_OPER, ADMPV_CUSTCODE, ADMPV_TIP_CLIENTE)
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
CREATE INDEX PCLUB.IX_ADMPT_TMP_ANIV_RPT_007 ON PCLUB.ADMPT_TMP_ANIV_RPT (ADMPV_TIP_CLIENTE, ADMPV_CUSTCODE)
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
