-- Create table
create table PCLUB.CC_BLACKLIST_FIDELIDAD
(
  BLCKV_TELEFONO VARCHAR2(11) not null,
  BLCKD_FECHA    DATE,
  BLCKV_SEGMENTO VARCHAR2(2)
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
comment on column PCLUB.CC_BLACKLIST_FIDELIDAD.BLCKV_TELEFONO
  is 'Número de línea formato internacional';
comment on column PCLUB.CC_BLACKLIST_FIDELIDAD.BLCKD_FECHA
  is 'Fecha de Registro';
comment on column PCLUB.CC_BLACKLIST_FIDELIDAD.BLCKV_SEGMENTO
  is 'Segmento Desafiliado';


-- Create table
create table PCLUB.CC_CONFIG_SMS
(
  CONFN_CODIGO      NUMBER,
  CONFV_DESCRIPCION VARCHAR2(30),
  CONFV_VALOR       VARCHAR2(500),
  CONFV_GRUPO       VARCHAR2(10),
  CONFV_ESTADO      CHAR(1),
  CONFV_OPCION      VARCHAR2(100)
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
comment on column PCLUB.CC_CONFIG_SMS.CONFN_CODIGO
  is 'Codigo Parámetro';
comment on column PCLUB.CC_CONFIG_SMS.CONFV_DESCRIPCION
  is 'Descripción de Parámetro';
comment on column PCLUB.CC_CONFIG_SMS.CONFV_VALOR
  is 'Valor de Parámetro';
comment on column PCLUB.CC_CONFIG_SMS.CONFV_GRUPO
  is 'Agrupación de Parámetros según significado';
comment on column PCLUB.CC_CONFIG_SMS.CONFV_ESTADO
  is 'Estado (0: Desactivo, 1: Activo)';
comment on column PCLUB.CC_CONFIG_SMS.CONFV_OPCION
  is 'Opcion donde se va usar';


  -- Create table
create table PCLUB.CC_FIDELIDAD
(
  CCFIDV_TELEFONO VARCHAR2(11) not null,
  CCFIDV_SEGMENTO VARCHAR2(2),
  CCFIDD_FECHA    DATE
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
comment on column PCLUB.CC_FIDELIDAD.CCFIDV_TELEFONO
  is 'Número de línea formato internacional';
comment on column PCLUB.CC_FIDELIDAD.CCFIDV_SEGMENTO
  is 'Código de Segmento';
comment on column PCLUB.CC_FIDELIDAD.CCFIDD_FECHA
  is 'Fecha de Registro';
-- Create/Recreate primary, unique and foreign key constraints
alter table PCLUB.CC_FIDELIDAD
  add constraint PK_FID_TELEFONO primary key (CCFIDV_TELEFONO)
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
-- Create/Recreate indexes
create index IDX1_SEGMENTO on PCLUB.CC_FIDELIDAD (CCFIDV_SEGMENTO)
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


  -- Create table
create table PCLUB.CC_SEGMENTO_FIDELIDAD
(
  SEGMV_CODIGO      VARCHAR2(2) not null,
  SEGMV_DESCRIPCION VARCHAR2(30)
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
comment on column PCLUB.CC_SEGMENTO_FIDELIDAD.SEGMV_CODIGO
  is 'Código del Segmento';
comment on column PCLUB.CC_SEGMENTO_FIDELIDAD.SEGMV_DESCRIPCION
  is 'Descripción del Segmento';
-- Create/Recreate primary, unique and foreign key constraints
alter table PCLUB.CC_SEGMENTO_FIDELIDAD
  add constraint PK_SEGM_CODIGO unique (SEGMV_CODIGO)
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


  -- Create table
create table PCLUB.CC_BENEFICIO_FIDELIDAD
(
  BENEV_CODIGO      VARCHAR2(2) not null,
  BENEV_DESCRIPCION VARCHAR2(30)
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
comment on column PCLUB.CC_BENEFICIO_FIDELIDAD.BENEV_CODIGO
  is 'Código del Beneficio';
comment on column PCLUB.CC_BENEFICIO_FIDELIDAD.BENEV_DESCRIPCION
  is 'Descripción del Beneficio';
-- Create/Recreate primary, unique and foreign key constraints
alter table PCLUB.CC_BENEFICIO_FIDELIDAD
  add constraint PK_BENF_CODIGO unique (BENEV_CODIGO)
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


  -- Create table
create table PCLUB.CC_SEGMENTO_BENEFICIO
(
  SEGMV_CODIGO VARCHAR2(2),
  BENEV_CODIGO VARCHAR2(2),
  SEBEC_ESTADO CHAR(1)
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
comment on column PCLUB.CC_SEGMENTO_BENEFICIO.SEGMV_CODIGO
  is 'Código del Segmento';
comment on column PCLUB.CC_SEGMENTO_BENEFICIO.BENEV_CODIGO
  is 'Código del Beneficio';
comment on column PCLUB.CC_SEGMENTO_BENEFICIO.SEBEC_ESTADO
  is 'Estado (0: Desactivo, 1: Activo)';
-- Create/Recreate primary, unique and foreign key constraints
alter table PCLUB.CC_SEGMENTO_BENEFICIO
  add constraint FK1_BENEF_CODIGO foreign key (BENEV_CODIGO)
  references PCLUB.CC_BENEFICIO_FIDELIDAD (BENEV_CODIGO);
alter table PCLUB.CC_SEGMENTO_BENEFICIO
  add constraint FK1_SEGM_CODIGO foreign key (SEGMV_CODIGO)
  references PCLUB.CC_SEGMENTO_FIDELIDAD (SEGMV_CODIGO);
-- Create/Recreate indexes
create index IDX_SEGM_CODIGO on PCLUB.CC_SEGMENTO_BENEFICIO (SEGMV_CODIGO)
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


  -- Create table
create table PCLUB.CC_WHITELIST_FIDELIDAD
(
  WHITV_TELEFONO        VARCHAR2(11) not null,
  WHITV_SEGMENTO        VARCHAR2(2),
  WHITV_SEGM_ANT        VARCHAR2(2),
  WHITC_ESTADO          CHAR(1),
  WHITD_FECHA           DATE,
  WHITC_SMS             CHAR(1),
  WHITD_FECHA_AFILACION DATE
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
comment on column PCLUB.CC_WHITELIST_FIDELIDAD.WHITV_TELEFONO
  is 'Número de línea formato internacional';
comment on column PCLUB.CC_WHITELIST_FIDELIDAD.WHITV_SEGMENTO
  is 'Código de Segmento Nuevo';
comment on column PCLUB.CC_WHITELIST_FIDELIDAD.WHITV_SEGM_ANT
  is 'Código de Segmento Anterior';
comment on column PCLUB.CC_WHITELIST_FIDELIDAD.WHITC_ESTADO
  is 'Estado (0:Registro, 1:Afiliación/Desafiliación)';
comment on column PCLUB.CC_WHITELIST_FIDELIDAD.WHITD_FECHA
  is 'Fecha de Registro/Modificación';
comment on column PCLUB.CC_WHITELIST_FIDELIDAD.WHITC_SMS
  is 'Flag Envío SMS';
comment on column PCLUB.CC_WHITELIST_FIDELIDAD.WHITD_FECHA_AFILACION
  is 'Fecha de afilaciony actualización';
-- Create/Recreate primary, unique and foreign key constraints
alter table PCLUB.CC_WHITELIST_FIDELIDAD
  add constraint PK_WHLT_TELEFONO unique (WHITV_TELEFONO)
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
alter table PCLUB.CC_WHITELIST_FIDELIDAD
  add constraint FK_SEGM_CODIGO foreign key (WHITV_SEGMENTO)
  references PCLUB.CC_SEGMENTO_FIDELIDAD (SEGMV_CODIGO)
  disable;
-- Create/Recreate indexes
create index IDX0_WHITELIST on PCLUB.CC_WHITELIST_FIDELIDAD (WHITV_SEGMENTO, WHITC_ESTADO)
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

