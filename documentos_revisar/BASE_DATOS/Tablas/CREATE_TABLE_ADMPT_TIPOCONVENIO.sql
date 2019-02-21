-- Create table
create table PCLUB.ADMPT_TIPOCONVENIO
(
  ADMPV_CONVENIO  VARCHAR2(20) not null,
  ADMPV_COD_TPOCL VARCHAR2(2) not null,
  ADMPV_DESC      VARCHAR2(50),
  ADMPN_PRIORIDAD NUMBER,
  ADMPD_FEC_REG   DATE,
  ADMPD_FEC_MOD   DATE,
  ADMPV_USU_REG   VARCHAR2(20),
  ADMPV_USU_MOD   VARCHAR2(20)
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
comment on column PCLUB.ADMPT_TIPOCONVENIO.ADMPV_CONVENIO
  is 'Código de convenio';
comment on column PCLUB.ADMPT_TIPOCONVENIO.ADMPV_COD_TPOCL
  is 'Código de Tipo Cliente  ejm: (7)   HFC Postpago';
comment on column PCLUB.ADMPT_TIPOCONVENIO.ADMPV_DESC
  is 'Descripción de convenio';
comment on column PCLUB.ADMPT_TIPOCONVENIO.ADMPN_PRIORIDAD
  is 'Prioridad';
comment on column PCLUB.ADMPT_TIPOCONVENIO.ADMPD_FEC_REG
  is 'Auditoría';
comment on column PCLUB.ADMPT_TIPOCONVENIO.ADMPD_FEC_MOD
  is 'Auditoría';
comment on column PCLUB.ADMPT_TIPOCONVENIO.ADMPV_USU_REG
  is 'Auditoría';
comment on column PCLUB.ADMPT_TIPOCONVENIO.ADMPV_USU_MOD
  is 'Auditoría';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_TIPOCONVENIO
  add constraint PK_TIPO_CONVENIO primary key (ADMPV_CONVENIO, ADMPV_COD_TPOCL)
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