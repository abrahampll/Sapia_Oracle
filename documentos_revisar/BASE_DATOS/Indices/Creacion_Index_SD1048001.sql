CREATE INDEX PCLUB.IX_ADMPT_SALDOS_CLIEFIJA_003 ON PCLUB.ADMPT_SALDOS_CLIENTEFIJA (SUBSTR(ADMPV_COD_CLI_PROD,0,INSTR(ADMPV_COD_CLI_PROD,'_')-1))
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
  CREATE INDEX PCLUB.IX_ADMPT_SALDOS_CLIEFIJA_004 ON PCLUB.ADMPT_SALDOS_CLIENTEFIJA (SUBSTR(ADMPV_COD_CLI_PROD,1,INSTR(ADMPV_COD_CLI_PROD,'_')-1))
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
  create index PCLUB.IX_ADMPT_CLIENTEPRODUCTO_03 on PCLUB.ADMPT_CLIENTEPRODUCTO (SUBSTR(ADMPV_COD_CLI_PROD,0,INSTR(ADMPV_COD_CLI_PROD,'_')-1))
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
create index PCLUB.IX_ADMPT_CLIENTEPRODUCTO_04 on PCLUB.ADMPT_CLIENTEPRODUCTO (SUBSTR(ADMPV_COD_CLI_PROD,1,INSTR(ADMPV_COD_CLI_PROD,'_')-1))
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