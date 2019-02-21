-- Create table
create table PCLUB.ADMPT_CONTRATOS
(
  admpv_codigocontrato VARCHAR2(40) not null,
  admpn_familia        NUMBER,
  admpv_numerolinea    VARCHAR2(20),
  admpn_tecnologia     NUMBER,
  admpn_tipotelefonia  NUMBER,
  admpv_casoespecial   VARCHAR2(50),
  admpv_tipoproducto   VARCHAR2(1),
  admpv_estado         VARCHAR2(1),
  admpd_fechacreacion  DATE default sysdate,
  admpd_fechamodifica  DATE
)
tablespace PCLUB_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 2M
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table PCLUB.ADMPT_CONTRATOS
  is 'Contratos de Afiliaciones';
-- Add comments to the columns 
comment on column PCLUB.ADMPT_CONTRATOS.admpv_codigocontrato
  is 'Codigo de Contrato';
comment on column PCLUB.ADMPT_CONTRATOS.admpn_familia
  is 'Codigo de Familia (1=Móvil, 2=TV, 3=Internet, 4=Telefonía)';
comment on column PCLUB.ADMPT_CONTRATOS.admpv_numerolinea
  is 'Numero de la línea';
comment on column PCLUB.ADMPT_CONTRATOS.admpn_tecnologia
  is 'Código de Tecnologia (1=HFC, 2=LTE-TDD, 3=DTH)';
comment on column PCLUB.ADMPT_CONTRATOS.admpn_tipotelefonia
  is 'Código Tipo de telefonia (1=TFI, 2=TPI)';
comment on column PCLUB.ADMPT_CONTRATOS.admpv_casoespecial
  is 'Caso Especial (aplica para B2E)';
comment on column PCLUB.ADMPT_CONTRATOS.admpv_tipoproducto
  is 'Código Tipo de Producto (1=Prepago, 2=Postpago)';
comment on column PCLUB.ADMPT_CONTRATOS.admpv_estado
  is 'Estado del Registro';
comment on column PCLUB.ADMPT_CONTRATOS.admpd_fechacreacion
  is 'Fecha de Creación de Registro';
comment on column PCLUB.ADMPT_CONTRATOS.admpd_fechamodifica
  is 'Fecha de Modificación de Registro';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_CONTRATOS
  add constraint PK_CONTRATOS_CODIGOCONTRATO primary key (ADMPV_CODIGOCONTRATO)
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
-- Grant/Revoke object privileges 
grant select, insert, update, references, alter, index on PCLUB.ADMPT_CONTRATOS to USRPCLUB;