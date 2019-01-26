-- Create table
create table USRSRVCC.ADMPT_ERRORES
(
  ERRON_ID   NUMBER not null,
  ERROV_DESC VARCHAR2(200) not null
)
tablespace PCLUB_DATA
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 8K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the columns 
comment on column USRSRVCC.ADMPT_ERRORES.ERRON_ID is 'Código Error';
comment on column USRSRVCC.ADMPT_ERRORES.ERROV_DESC is 'Descripción del Error';
-- Create/Recreate primary, unique and foreign key constraints 
alter table USRSRVCC.ADMPT_ERRORES
  add constraint PK_ADMPT_ERRORES primary key (ERRON_ID)
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
create table USRSRVCC.ADMPT_TIPO_DOC
(
  TDOCV_ID      VARCHAR2(20) not null,
  TDOCV_DESC    VARCHAR2(50) not null,
  TDOCV_ABREV   VARCHAR2(20),
  TDOCC_ESTADO  CHAR(1) not null,
  TDOCV_USU_REG VARCHAR2(20),
  TDOCD_FEC_REG DATE,
  TDOCV_USU_MOD VARCHAR2(20),
  TDOCD_FEC_MOD DATE
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
comment on column USRSRVCC.ADMPT_TIPO_DOC.TDOCV_ID is 'Código Tipo Documento';
comment on column USRSRVCC.ADMPT_TIPO_DOC.TDOCV_DESC is 'Descripción del Tipo de Documento';
comment on column USRSRVCC.ADMPT_TIPO_DOC.TDOCV_ABREV is 'Abreviatura del Tipo de Documento';
comment on column USRSRVCC.ADMPT_TIPO_DOC.TDOCC_ESTADO is 'Estado del Tipo de Documento (A/B)';
-- Create/Recreate primary, unique and foreign key constraints 
alter table USRSRVCC.ADMPT_TIPO_DOC
  add constraint PK_ADMPT_TIPO_DOC primary key (TDOCV_ID)
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
create table USRSRVCC.ADMPT_TIPOPREMIO
(
  TPREV_ID      VARCHAR2(2) not null,
  TPREV_DESC    VARCHAR2(200) not null,
  TPREC_ESTADO  CHAR(1) not null,
  TPREV_USU_REG VARCHAR2(20),
  TPRED_FEC_REG DATE,
  TPREV_USU_MOD VARCHAR2(20),
  TPRED_FEC_MOD DATE
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
comment on column USRSRVCC.ADMPT_TIPOPREMIO.TPREV_ID is 'Código Tipo Premio';
comment on column USRSRVCC.ADMPT_TIPOPREMIO.TPREV_DESC is 'Descripción del Tipo de Premio';
comment on column USRSRVCC.ADMPT_TIPOPREMIO.TPREC_ESTADO is 'Estado del Tipo de Premio (A: activo / B: Baja)';
-- Create/Recreate primary, unique and foreign key constraints 
alter table USRSRVCC.ADMPT_TIPOPREMIO
  add constraint PK_ADMPT_TIPOPREMIO primary key (TPREV_ID)
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
create table USRSRVCC.ADMPT_PREMIO
(
  PREMV_ID        VARCHAR2(15) not null,
  TPREV_ID        VARCHAR2(2) not null,
  PREMV_DESC      VARCHAR2(150) not null,
  PREMC_ESTADO    CHAR(1) not null,
  PREMV_USU_REG   VARCHAR2(20),
  PREMD_FEC_REG   DATE,
  PREMV_USU_MOD   VARCHAR2(20),
  PREMD_FEC_MOD   DATE
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
comment on column USRSRVCC.ADMPT_PREMIO.PREMV_ID is 'Codigo del Premio';
comment on column USRSRVCC.ADMPT_PREMIO.TPREV_ID is 'Codigo del Tipo de Premio';
comment on column USRSRVCC.ADMPT_PREMIO.PREMV_DESC is 'Descripción del Premio';
comment on column USRSRVCC.ADMPT_PREMIO.PREMC_ESTADO is 'Estado del Premio (A: Activo / B: Baja)';
-- Create/Recreate primary, unique and foreign key constraints 
alter table USRSRVCC.ADMPT_PREMIO
  add constraint PK_ADMPT_PREMIO primary key (PREMV_ID)
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
alter table USRSRVCC.ADMPT_PREMIO
  add constraint FK_PREMIO_TIPOPREMIO foreign key (TPREV_ID)
  references USRSRVCC.ADMPT_TIPOPREMIO (TPREV_ID);

-- Create table
create table USRSRVCC.ADMPT_MOV_SERV
(
  MOVSN_ID        NUMBER not null,
  PREMV_ID        VARCHAR2(15) not null,
  MOVSD_FEC_TRANS DATE not null,
  MOVSV_LINEA     VARCHAR2(20) not null,
  TDOCV_ID        VARCHAR2(20),
  MOVSV_NUMDOC    VARCHAR2(20),
  MOVSC_ESTPROC   CHAR(1),
  MOVSV_ESTDESC   VARCHAR2(200),
  MOVSV_USU_REG   VARCHAR2(20),
  MOVSD_FEC_REG   DATE,
  MOVSV_USU_MOD   VARCHAR2(20),
  MOVSD_FEC_MOD   DATE,
  CLIEV_ID		  VARCHAR2(10)
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
comment on column USRSRVCC.ADMPT_MOV_SERV.MOVSN_ID is 'Correlativo';
comment on column USRSRVCC.ADMPT_MOV_SERV.PREMV_ID is 'Codigo Premio';
comment on column USRSRVCC.ADMPT_MOV_SERV.MOVSD_FEC_TRANS is 'Fecha  Transaccion';
comment on column USRSRVCC.ADMPT_MOV_SERV.MOVSV_LINEA is 'Linea al cual se entrega el bono';
comment on column USRSRVCC.ADMPT_MOV_SERV.TDOCV_ID is 'Tipo documento de la linea';
comment on column USRSRVCC.ADMPT_MOV_SERV.MOVSV_NUMDOC is 'Numero de documento de la linea';
comment on column USRSRVCC.ADMPT_MOV_SERV.MOVSC_ESTPROC is 'Estado del Proceso ( 0: OK / 1: Error)';
comment on column USRSRVCC.ADMPT_MOV_SERV.MOVSV_ESTDESC is 'Descripción del estado en caso de error';
comment on column USRSRVCC.ADMPT_MOV_SERV.CLIEV_ID is 'Código cliente';
-- Create/Recreate primary, unique and foreign key constraints 
alter table USRSRVCC.ADMPT_MOV_SERV
  add constraint PK_ADMPT_MOV_SERV primary key (MOVSN_ID)
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
alter table USRSRVCC.ADMPT_MOV_SERV
  add constraint FK_MOV_SERV_PREMIO foreign key (PREMV_ID)
  references USRSRVCC.ADMPT_PREMIO (PREMV_ID);
alter table USRSRVCC.ADMPT_MOV_SERV
  add constraint FK_MOV_SERV_TIPO_DOC foreign key (TDOCV_ID)
  references USRSRVCC.ADMPT_TIPO_DOC (TDOCV_ID);
  
  
create table USRSRVCC.ADMPT_CLIENTE
(
  CLIEV_ID      VARCHAR2(10) not null,
  CLIEV_NOMBRE  VARCHAR2(250),
  CLIEC_ESTADO  CHAR(1),
  CLIEV_USU_REG VARCHAR2(20),
  CLIED_FEC_REG DATE,
  CLIEV_USU_MOD VARCHAR2(20),
  CLIED_FEC_MOD DATE
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
comment on column USRSRVCC.ADMPT_CLIENTE.CLIEV_ID
  is 'Código Cliente';
comment on column USRSRVCC.ADMPT_CLIENTE.CLIEV_NOMBRE
  is 'Nombre Cliente';
comment on column USRSRVCC.ADMPT_CLIENTE.CLIEC_ESTADO
  is 'Estado Cliente';
-- Create/Recreate primary, unique and foreign key constraints 
alter table USRSRVCC.ADMPT_CLIENTE
  add constraint PK_ADMPT_CLIENTE primary key (CLIEV_ID)
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
