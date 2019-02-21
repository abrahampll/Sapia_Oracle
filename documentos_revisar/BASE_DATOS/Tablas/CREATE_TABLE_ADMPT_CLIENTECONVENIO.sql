-- Create table
create table PCLUB.ADMPT_CLIENTECONVENIO
(
  ADMPV_COD_CLI_CONV VARCHAR2(40) not null,
  ADMPV_COD_CLI      VARCHAR2(40) not null,
  ADMPV_CONVENIO     VARCHAR2(20),
  ADMPV_ESTADO_CONV  VARCHAR2(2),
  ADMPD_FEC_REG      DATE,
  ADMPV_USU_REG      VARCHAR2(20),
  ADMPD_FEC_MOD      DATE,
  ADMPV_USU_MOD      VARCHAR2(20),
  ADMPV_CICL_FACT    VARCHAR2(2)
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
comment on column PCLUB.ADMPT_CLIENTECONVENIO.ADMPV_COD_CLI_CONV
  is 'Código del convenio relacionado a un cliente';
comment on column PCLUB.ADMPT_CLIENTECONVENIO.ADMPV_COD_CLI
  is 'Código del Cliente';
comment on column PCLUB.ADMPT_CLIENTECONVENIO.ADMPV_CONVENIO
  is 'Código de los convenios';
comment on column PCLUB.ADMPT_CLIENTECONVENIO.ADMPV_ESTADO_CONV
  is 'Estado del convenio';
comment on column PCLUB.ADMPT_CLIENTECONVENIO.ADMPD_FEC_REG
  is 'Auditoría';
comment on column PCLUB.ADMPT_CLIENTECONVENIO.ADMPV_USU_REG
  is 'Auditoría';
comment on column PCLUB.ADMPT_CLIENTECONVENIO.ADMPD_FEC_MOD
  is 'Auditoría';
comment on column PCLUB.ADMPT_CLIENTECONVENIO.ADMPV_USU_MOD
  is 'Auditoría';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_CLIENTECONVENIO
  add constraint PK_CLIENTECONVENIO primary key (ADMPV_COD_CLI_CONV)
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
alter table PCLUB.ADMPT_CLIENTECONVENIO
  add constraint FK_NO_CLIENTE foreign key (ADMPV_COD_CLI)
  references PCLUB.ADMPT_NO_CLIENTE (ADMPV_COD_CLI);
