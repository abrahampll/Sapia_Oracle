-- Create table
create table PCLUB.ADMPT_TIPOSERVICIO
(
  ADMPV_COD_TPOCL VARCHAR2(2) not null,
  ADMPV_SERVICIO  VARCHAR2(20) not null,
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
comment on column PCLUB.ADMPT_TIPOSERVICIO.ADMPV_COD_TPOCL
  is 'Código de Tipo Cliente  ejm: (7)   HFC Postpago';
comment on column PCLUB.ADMPT_TIPOSERVICIO.ADMPV_SERVICIO
  is 'Código de servicio :  Cable, telefonía fija, internet, telefonía móvil';
comment on column PCLUB.ADMPT_TIPOSERVICIO.ADMPV_DESC
  is 'Descripción de servicio';
comment on column PCLUB.ADMPT_TIPOSERVICIO.ADMPN_PRIORIDAD
  is 'Prioridad';
comment on column PCLUB.ADMPT_TIPOSERVICIO.ADMPD_FEC_REG
  is 'Auditoría';
comment on column PCLUB.ADMPT_TIPOSERVICIO.ADMPD_FEC_MOD
  is 'Auditoría';
comment on column PCLUB.ADMPT_TIPOSERVICIO.ADMPV_USU_REG
  is 'Auditoría';
comment on column PCLUB.ADMPT_TIPOSERVICIO.ADMPV_USU_MOD
  is 'Auditoría';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_TIPOSERVICIO
  add constraint PK_COD_TPOCL primary key (ADMPV_COD_TPOCL, ADMPV_SERVICIO)
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
