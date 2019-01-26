create table PCLUB.ADMPT_LOY_CANJE
(
  ADMPV_ID_CANJE   VARCHAR2(20),
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPV_PTOVTA     VARCHAR2(10),
  ADMPD_FECHA      DATE,
  ADMPV_HORA       VARCHAR2(5),
  ADMPV_TIPO       VARCHAR2(1),
  ADMPV_MSJE_ERROR VARCHAR2(400),
  ADMPV_ESTADO     VARCHAR2(1)
)
tablespace PCLUB_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

create table PCLUB.ADMPT_LOY_CANJEDET
(
  ADMPV_ID_CANJE   VARCHAR2(20),
  ADMPV_SECUENC    VARCHAR2(10),
  ADMPV_ID_PROD    VARCHAR2(15),
  ADMPV_DES_PROD   VARCHAR2(50),
  ADMPV_CAMPANA    VARCHAR2(200),
  ADMPN_PUNTOS     NUMBER,
  ADMPN_MONTO      NUMBER,
  ADMPN_CANTIDAD   NUMBER,
  ADMPV_TPOPREM    VARCHAR2(1),
  ADMPN_CODSERV    NUMBER,
  ADMPN_MNTREC     NUMBER,
  ADMPV_IDTRANS    VARCHAR2(18),
  ADMPV_MSJE_ERROR VARCHAR2(400),
  ADMPV_ESTADO     VARCHAR2(1)
)
tablespace PCLUB_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

create table PCLUB.ADMPT_LOY_CLIENTE
(
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPN_CATCLI     NUMBER,
  ADMPV_TIP_DOC    VARCHAR2(20),
  ADMPV_NUM_DOC    VARCHAR2(20),
  ADMPV_NOM_CLI    VARCHAR2(80),
  ADMPV_SEXO       VARCHAR2(1),
  ADMPV_ESTCIV     VARCHAR2(20),
  ADMPV_EMAIL      VARCHAR2(100),
  ADMPV_PROV       VARCHAR2(30),
  ADMPV_DEP        VARCHAR2(40),
  ADMPV_DIST       VARCHAR2(200),
  ADMPV_FECACT     DATE,
  ADMPV_CIC_FAC    VARCHAR2(2),
  ADMPV_MSJE_ERROR VARCHAR2(400),
  ADMPV_ESTADO     VARCHAR2(1),
  ADMPV_APE_CLI    VARCHAR2(80)
)
tablespace PCLUB_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

create index PCLUB.IDX_LOY_CLIENTE_ESTADO on PCLUB.ADMPT_LOY_CLIENTE (ADMPV_ESTADO)
  tablespace PCLUB_DATA
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 192K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index PCLUB.IDX_LOY_CLIENTE_SEXO on PCLUB.ADMPT_LOY_CLIENTE (ADMPV_SEXO)
  tablespace PCLUB_DATA
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 128K
    next 1M
    minextents 1
    maxextents unlimited
  );


create table PCLUB.ADMPT_LOY_MOVTOS
(
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPV_MOTIVO     VARCHAR2(100),
  ADMPD_FECHA      DATE,
  ADMPN_PUNTOS     NUMBER,
  ADMPV_TIPOPE     VARCHAR2(1),
  ADMPN_SLDPUNTOS  NUMBER,
  ADMPV_IDTRANS    VARCHAR2(18) not null,
  ADMPV_MSJE_ERROR VARCHAR2(400),
  ADMPV_ESTADO     VARCHAR2(1) not null
)
tablespace PCLUB_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

alter table PCLUB.ADMPT_LOY_MOVTOS
  add constraint PK_LOYMVTOS_TRANS primary key (ADMPV_IDTRANS, ADMPV_ESTADO)
  using index 
  tablespace PCLUB_DATA
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

create table PCLUB.ADMPT_LOY_SALDOS
(
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPN_SALDO_CC   NUMBER,
  ADMPV_MSJE_ERROR VARCHAR2(400),
  ADMPV_ESTADO     VARCHAR2(1)
)
tablespace PCLUB_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

create index PCLUB.IDX_LOY_SALDO_CLI on PCLUB.ADMPT_LOY_SALDOS (ADMPV_COD_CLI)
  tablespace PCLUB_DATA
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 21M
    next 1M
    minextents 1
    maxextents unlimited
  );


create table PCLUB.ADMPT_LOY_DETMOVSAL
(
  ADMPV_ID_CONSUMO     VARCHAR2(20),
  ADMPV_SEC            NUMBER,
  ADMPN_ID_ACUMULACION VARCHAR2(18),
  ADMPN_PUNTOS         NUMBER,
  ADMPV_MSJE_ERROR     VARCHAR2(400),
  ADMPV_ESTADO         VARCHAR2(1)
)
tablespace PCLUB_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );


-- Para DWH
create table PCLUB.ADMPT_CAT_CONCEPTO
(
  ADMPV_COD_CAT VARCHAR2(2) not null,
  ADMPV_DSC_CAT VARCHAR2(100),
  ADMPV_ESTADO  CHAR(1)
)
tablespace PCLUB_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

alter table PCLUB.ADMPT_CAT_CONCEPTO
  add constraint PK_ADMPT_CAT_CONCEPTO primary key (ADMPV_COD_CAT)
  using index 
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

create table PCLUB.ADMPT_DETCAT_CONCEPTO
(
  ADMPV_COD_CAT  VARCHAR2(2),
  ADMPV_COD_CPTO VARCHAR2(2)
)
tablespace PCLUB_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
alter table PCLUB.ADMPT_DETCAT_CONCEPTO
  add constraint FK_ADMPT_CATCON_CAT_CONCETO foreign key (ADMPV_COD_CAT)
  references PCLUB.ADMPT_CAT_CONCEPTO (ADMPV_COD_CAT);
alter table PCLUB.ADMPT_DETCAT_CONCEPTO
  add constraint FK_ADMPT_CONC_CAT_CONCETO foreign key (ADMPV_COD_CPTO)
  references PCLUB.ADMPT_CONCEPTO (ADMPV_COD_CPTO);
  
create table PCLUB.ADMPT_SALDO_CLI_DES
(
  ADMPN_ID_SALDO   NUMBER not null,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPN_COD_CLI_IB NUMBER,
  ADMPN_SALDO_CC   NUMBER,
  ADMPN_SALDO_IB   NUMBER,
  ADMPC_ESTPTO_CC  CHAR(1),
  ADMPC_ESTPTO_IB  CHAR(1)
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

alter table PCLUB.ADMPT_SALDO_CLI_DES
  add constraint PK_ADMPT_SALDO_CLI_DES primary key (ADMPN_ID_SALDO)
  disable;
