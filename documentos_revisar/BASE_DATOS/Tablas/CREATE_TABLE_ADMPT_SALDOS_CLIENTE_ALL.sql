-- Create table
create table PCLUB.ADMPT_SALDOS_CLIENTE_ALL
(
  ADMPN_ID_SALDO          NUMBER not null,
  ADMPN_COD_CLI_CONV      VARCHAR2(40) not null,
  ADMPV_COD_CLI_PROD      VARCHAR2(40) not null,
  ADMPN_SALDO_CC          NUMBER,
  ADMPC_ESTPTO_CC         CHAR(1),
  ADMPD_FEC_REG           DATE,
  ADMPD_FEC_MOD           DATE,
  ADMPN_ALIN_SALDO_CC     NUMBER,
  ADMPN_ALIN_FECHA_CC     DATE,
  ADMPN_ALIN_FECHA_IB     DATE,
  ADMPN_SALDO_CC_ANTERIOR NUMBER,
  ADMPN_SALDO_IB_ANTERIOR NUMBER
)
tablespace PCLUB_DATA
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Add comments to the columns 
comment on column PCLUB.ADMPT_SALDOS_CLIENTE_ALL.ADMPN_ID_SALDO
  is 'Código de Saldo';
comment on column PCLUB.ADMPT_SALDOS_CLIENTE_ALL.ADMPN_COD_CLI_CONV
  is 'Código de cliente por convenio';
comment on column PCLUB.ADMPT_SALDOS_CLIENTE_ALL.ADMPV_COD_CLI_PROD
  is 'Código de cliente por producto';
comment on column PCLUB.ADMPT_SALDOS_CLIENTE_ALL.ADMPN_SALDO_CC
  is 'Saldo de Claro Club';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_SALDOS_CLIENTE_ALL
  add constraint PK_SALDOS_CLIENTE primary key (ADMPN_ID_SALDO)
  using index 
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
