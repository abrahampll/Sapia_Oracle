-- Create table
create table PCLUB.ADMPT_NO_CLIENTE
(
  ADMPV_COD_CLI    VARCHAR2(40) not null,
  ADMPV_COD_SEGCLI VARCHAR2(2),
  ADMPN_COD_CATCLI NUMBER,
  ADMPV_TIPO_DOC   VARCHAR2(20),
  ADMPV_NUM_DOC    VARCHAR2(20),
  ADMPV_NOM_CLI    VARCHAR2(80),
  ADMPV_APE_CLI    VARCHAR2(200),
  ADMPC_SEXO       CHAR(1),
  ADMPV_EST_CIVIL  VARCHAR2(20),
  ADMPV_EMAIL      VARCHAR2(100),
  ADMPV_PROV       VARCHAR2(50),
  ADMPV_DEPA       VARCHAR2(40),
  ADMPV_DIST       VARCHAR2(200),
  ADMPD_FEC_ACTIV  DATE,
  ADMPC_ESTADO     CHAR(1),
  ADMPV_COD_TPOCL  VARCHAR2(2),
  ADMPD_FEC_REG    DATE,
  ADMPD_FEC_MOD    DATE,
  ADMPV_USU_REG    VARCHAR2(20),
  ADMPV_USU_MOD    VARCHAR2(20)
)
tablespace PCLUB_DATA
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 8M
    minextents 1
    maxextents unlimited
  );
-- Add comments to the columns 
comment on column PCLUB.ADMPT_NO_CLIENTE.ADMPV_COD_CLI
  is 'Código Cliente Formato: TipoDoc.NroDoc.TipoCliente';
comment on column PCLUB.ADMPT_NO_CLIENTE.ADMPV_COD_SEGCLI
  is 'Segmento del Cliente';
comment on column PCLUB.ADMPT_NO_CLIENTE.ADMPN_COD_CATCLI
  is 'Categoría del Cliente por default es 2 Normal';
comment on column PCLUB.ADMPT_NO_CLIENTE.ADMPV_TIPO_DOC
  is 'Tipo Documento';
comment on column PCLUB.ADMPT_NO_CLIENTE.ADMPV_NUM_DOC
  is 'Nro. Documento';
comment on column PCLUB.ADMPT_NO_CLIENTE.ADMPV_NOM_CLI
  is 'Nombre del Cliente';
comment on column PCLUB.ADMPT_NO_CLIENTE.ADMPV_APE_CLI
  is 'Apellido del Cliente';
comment on column PCLUB.ADMPT_NO_CLIENTE.ADMPC_SEXO
  is 'Sexo';
comment on column PCLUB.ADMPT_NO_CLIENTE.ADMPV_EST_CIVIL
  is 'Estado civil';
comment on column PCLUB.ADMPT_NO_CLIENTE.ADMPV_EMAIL
  is 'Email';
comment on column PCLUB.ADMPT_NO_CLIENTE.ADMPV_PROV
  is 'Provincia';
comment on column PCLUB.ADMPT_NO_CLIENTE.ADMPV_DEPA
  is 'Departamento';
comment on column PCLUB.ADMPT_NO_CLIENTE.ADMPV_DIST
  is 'Distrito';
comment on column PCLUB.ADMPT_NO_CLIENTE.ADMPD_FEC_ACTIV
  is 'Fecha  Registro a Claro Club';
comment on column PCLUB.ADMPT_NO_CLIENTE.ADMPC_ESTADO
  is 'Estado del Cliente A: Activo / B: Baja';
comment on column PCLUB.ADMPT_NO_CLIENTE.ADMPV_COD_TPOCL
  is 'Tipo Cliente (7) HFC Postpago';
comment on column PCLUB.ADMPT_NO_CLIENTE.ADMPD_FEC_REG
  is 'Auditoría';
comment on column PCLUB.ADMPT_NO_CLIENTE.ADMPD_FEC_MOD
  is 'Auditoría';
comment on column PCLUB.ADMPT_NO_CLIENTE.ADMPV_USU_REG
  is 'Auditoría';
comment on column PCLUB.ADMPT_NO_CLIENTE.ADMPV_USU_MOD
  is 'Auditoría';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_NO_CLIENTE
  add constraint PK_NO_CLIENTE primary key (ADMPV_COD_CLI)
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
