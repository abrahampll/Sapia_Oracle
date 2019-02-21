-- Create table
create table PCLUB.ADMPT_CAMPANHA
(
  ADMPN_ID_CAMP     NUMBER not null,
  ADMPV_DESCRIPCION VARCHAR2(100),
  ADMPD_FEC_INI     DATE,
  ADMPD_FEC_FIN     DATE,
  ADMPV_ESTADO      VARCHAR2(2),
  ADMPD_FEC_REG     DATE,
  ADMPD_FEC_MOD     DATE,
  ADMPV_USU_REG     VARCHAR2(20),
  ADMPV_USU_MOD     VARCHAR2(20)
)
TABLESPACE PCLUB_DATA
PCTUSED    40
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           );
-- Add comments to the columns 
comment on column PCLUB.ADMPT_CAMPANHA.ADMPN_ID_CAMP
  is 'Identificador de la tabla';
comment on column PCLUB.ADMPT_CAMPANHA.ADMPV_DESCRIPCION
  is 'Descripcion de la Campaña';
comment on column PCLUB.ADMPT_CAMPANHA.ADMPD_FEC_INI
  is 'Fecha de Inicio de Vigencia de la Campaña';
comment on column PCLUB.ADMPT_CAMPANHA.ADMPD_FEC_FIN
  is 'Fecha de Fin de Vigencia de la Campaña';
comment on column PCLUB.ADMPT_CAMPANHA.ADMPV_ESTADO
  is 'Estado de la Campaña';
comment on column PCLUB.ADMPT_CAMPANHA.ADMPD_FEC_REG
  is 'CAMPO AUDITORIA FECHA REGISTRO';
comment on column PCLUB.ADMPT_CAMPANHA.ADMPD_FEC_MOD
  is 'CAMPO AUDITORIA FECHA ACTUALIZACION';
comment on column PCLUB.ADMPT_CAMPANHA.ADMPV_USU_REG
  is 'CAMPO AUDITORIA USUARIO REGISTRO';
comment on column PCLUB.ADMPT_CAMPANHA.ADMPV_USU_MOD
  is 'CAMPO AUDITORIA USUARIO ACTUALIZACION';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_CAMPANHA
  add constraint PK_ID_CAMPANHA primary key (ADMPN_ID_CAMP)
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
  create index PCLUB.IDX_ADMPT_CAMPANHA_01 on PCLUB.ADMPT_CAMPANHA (ADMPN_ID_CAMP, ADMPV_ESTADO)
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
 create table PCLUB.ADMPT_CAMPANHA_DET
(
  ADMPN_ID_CAMDET NUMBER not null,
  ADMPN_ID_CAMP   NUMBER not null,
  ADMPV_COD_TPOCL VARCHAR2(2) not null,
  ADMPN_VALOR     NUMBER not null,
  ADMPC_ESTADO    CHAR(1) not null,
  ADMPD_FEC_REG   DATE,
  ADMPD_FEC_MOD   DATE,
  ADMPV_USU_REG   VARCHAR2(20),
  ADMPV_USU_MOD   VARCHAR2(20)
)
TABLESPACE PCLUB_DATA
PCTUSED    40
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           );
-- Add comments to the columns 
comment on column PCLUB.ADMPT_CAMPANHA_DET.ADMPN_ID_CAMDET
  is 'Identificador de la tabla';
comment on column PCLUB.ADMPT_CAMPANHA_DET.ADMPN_ID_CAMP
  is 'Identificador de la Tabla Campaña';
comment on column PCLUB.ADMPT_CAMPANHA_DET.ADMPV_COD_TPOCL
  is 'Codigo Cliente';
comment on column PCLUB.ADMPT_CAMPANHA_DET.ADMPN_VALOR
  is 'Factor Multiplicidad';
comment on column PCLUB.ADMPT_CAMPANHA_DET.ADMPC_ESTADO
  is 'A: Activo / B: Baja';
comment on column PCLUB.ADMPT_CAMPANHA_DET.ADMPD_FEC_REG
  is 'CAMPO AUDITORIA FECHA REGISTRO';
comment on column PCLUB.ADMPT_CAMPANHA_DET.ADMPD_FEC_MOD
  is 'CAMPO AUDITORIA FECHA ACTUALIZACION';
comment on column PCLUB.ADMPT_CAMPANHA_DET.ADMPV_USU_REG
  is 'CAMPO AUDITORIA USUARIO REGISTRO';
comment on column PCLUB.ADMPT_CAMPANHA_DET.ADMPV_USU_MOD
  is 'CAMPO AUDITORIA USUARIO ACTUALIZACION';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_CAMPANHA_DET
  add constraint PK_ADMPN_ID_CAMP primary key (ADMPN_ID_CAMP, ADMPV_COD_TPOCL)
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
  create index PCLUB.IDX_CAMPANHA_DET_02 on PCLUB.ADMPT_CAMPANHA_DET (ADMPN_ID_CAMP, ADMPC_ESTADO)
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
create table PCLUB.ADMPT_CLIE_ESTADO_BOLSA
(
  ADMPV_TIPO_DOC  VARCHAR2(20) not null,
  ADMPV_NUM_DOC   VARCHAR2(20) not null,
  ADMPV_COD_TPOCL VARCHAR2(2) not null,
  ADMPC_ESTADO    CHAR(1),
  ADMPV_USU_REG   VARCHAR2(20),
  ADMPD_FEC_REG   DATE not null,
  ADMPV_USU_MOD   VARCHAR2(20),
  ADMPD_FEC_MOD   DATE
)
TABLESPACE PCLUB_DATA
PCTUSED    40
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           );
-- Add comments to the columns 
comment on column PCLUB.ADMPT_CLIE_ESTADO_BOLSA.ADMPV_COD_TPOCL
  is 'Tipo de Cliente : 2 (PostPago/Control), 3 (PrePago)';
comment on column PCLUB.ADMPT_CLIE_ESTADO_BOLSA.ADMPC_ESTADO
  is 'Estado de la Cuenta :  L (LIBERADO) / R (RESERVADO)';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_CLIE_ESTADO_BOLSA
  add constraint PK_ADMPT_CLIE_ESTADO_BOLSA primary key (ADMPV_TIPO_DOC, ADMPV_NUM_DOC, ADMPV_COD_TPOCL)
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
create table PCLUB.ADMPT_PROCESO
(
  ADMPV_IDPROC  VARCHAR2(20) not null,
  ADMPV_DESC    VARCHAR2(200) not null,
  ADMPV_ESTADO  CHAR(1),
  ADMPD_FEC_REG DATE,
  ADMPV_USU_REG VARCHAR2(20),
  ADMPD_FEC_MOD DATE,
  ADMPV_USU_MOD VARCHAR2(20)
)
TABLESPACE PCLUB_DATA
PCTUSED    40
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           );
-- Add comments to the columns 
comment on column PCLUB.ADMPT_PROCESO.ADMPV_IDPROC
  is 'IDENTIFICADO';
comment on column PCLUB.ADMPT_PROCESO.ADMPV_DESC
  is 'DESCRIPCION PROCESO';
comment on column PCLUB.ADMPT_PROCESO.ADMPV_ESTADO
  is 'A: ACTIVO / B:BAJA';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_PROCESO
  add constraint PK_ADMPT_PROCESO primary key (ADMPV_IDPROC)
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

  -- Create/Recreate primary, unique and foreign key constraints 
  create index PCLUB.IDX_ADMPT_CLIENTEPRODUCTO_01 on PCLUB.ADMPT_CLIENTEPRODUCTO (ADMPV_COD_CLI)
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
  
    -- Create/Recreate primary, unique and foreign key constraints 
  create index PCLUB.IDX_DETALLEFIJA_01 on PCLUB.ADMPT_CANJE_DETALLEFIJA(ADMPV_ID_CANJE)
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
  
  -- Create/Recreate primary, unique and foreign key constraints 
  create index PCLUB.IDX_KARDEXFIJA_02 on PCLUB.ADMPT_KARDEXFIJA(ADMPV_ID_CANJE)
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
  
 -- Update tables
ALTER TABLE PCLUB.ADMPT_CANJE  
ADD ( ADMPV_USU_REG     VARCHAR2(10),
      ADMPV_USU_MOD     VARCHAR2(10),
      ADMPV_TPO_PROC    VARCHAR2(2),
      ADMPV_VENTAID     VARCHAR2(40),
      ADMPN_SOLESVTA    NUMBER,
      ADMPN_ID_CAMP     NUMBER,
      ADMPN_SALDO       NUMBER);

ALTER TABLE PCLUB.ADMPT_TIPO_CLIENTE 
ADD ( ADMPV_PRVENTA VARCHAR2(2),
      ADMPC_TBLCLIENTE CHAR(1));


ALTER TABLE PCLUB.ADMPT_CANJEFIJA  
ADD ( ADMPV_TPO_PROC      VARCHAR2(2),
      ADMPV_VENTAID       VARCHAR2(40),
      ADMPN_SOLESVTA      NUMBER,
      ADMPN_ID_CAMP       NUMBER,
      ADMPN_SALDO         NUMBER);
	  
	  
  -- Create/Recreate primary, unique and foreign key constraints 
  create index PCLUB.IDX_ADMPT_CANJE_01 ON PCLUB.ADMPT_CANJE(ADMPV_ID_CANJE, ADMPV_COD_TPOCL, ADMPV_VENTAID)
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
	  

