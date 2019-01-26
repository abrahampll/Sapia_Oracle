-- Recargas Prepago
create table PCLUB.ADMPT_TMP_PRERECARGA
(
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPN_MONTO      NUMBER,
  ADMPD_FEC_ULTREC DATE,
  ADMPD_FEC_OPER   DATE
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

create table PCLUB.ADMPT_AUX_PRERECARGA
(
  ADMPV_COD_CLI VARCHAR2(40),
  ADMPN_MONTO   NUMBER
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
  
create table PCLUB.ADMPT_IMP_PRERECARGA
(
  ADMPN_ID_FILA    NUMBER not null,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPD_FEC_ULTREC DATE,
  ADMPN_MONTO      NUMBER,
  ADMPD_FEC_OPER   DATE,
  ADMPV_MSJE_ERROR VARCHAR2(400)
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

alter table PCLUB.ADMPT_IMP_PRERECARGA
  add primary key (ADMPN_ID_FILA)
  using index 
  tablespace PCLUB_DATA
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
 
 
 -- Puntos por Aniversario
create table PCLUB.ADMPT_TMP_PREANIVERS
(
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPD_FEC_ANIV   DATE,
  ADMPD_FEC_OPER   DATE,
  ADMPV_MSJE_ERROR VARCHAR2(400)
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
  
 create table PCLUB.ADMPT_AUX_PREANIVERS
(
  ADMPV_COD_CLI  VARCHAR2(40),
  ADMPD_FEC_ANIV DATE
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
  
create table PCLUB.ADMPT_IMP_PREANIVERS
(
  ADMPN_ID_FILA    NUMBER not null,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPD_FEC_ANIV   DATE,
  ADMPD_FEC_OPER   DATE,
  ADMPD_FEC_TRANS  DATE,
  ADMPV_MSJE_ERROR VARCHAR2(400)
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

alter table PCLUB.ADMPT_IMP_PREANIVERS
  add constraint PK_ADMPT_IMP_PREANIVERS primary key (ADMPN_ID_FILA)
  using index 
  tablespace PCLUB_DATA
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
  
 -- Clientes que no tienen recarga en meses
 
 create table PCLUB.ADMPT_TMP_PRESINRECARGA
(
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPD_FEC_OPER   DATE,
  ADMPV_MSJE_ERROR VARCHAR2(400)
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
  
  create table PCLUB.ADMPT_AUX_PRESINRECARGA
(
  ADMPV_COD_CLI VARCHAR2(40)
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
  
 create table PCLUB.ADMPT_IMP_PRESINRECARGA
(
  ADMPN_ID_FILA    NUMBER,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPD_FEC_OPER   DATE,
  ADMPD_FEC_TRANS  DATE,
  ADMPV_MSJE_ERROR VARCHAR2(400)
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
  

-- Activaciones de Clientes Prepago
create table PCLUB.ADMPT_IMP_PREACTIV
(
  ADMPN_ID_FILA    NUMBER not null,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPD_FEC_OPER   DATE,
  ADMPV_MSJE_ERROR VARCHAR2(400)
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

alter table PCLUB.ADMPT_IMP_PREACTIV
  add primary key (ADMPN_ID_FILA)
  using index 
  tablespace PCLUB_DATA
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
  
-- Alta de Clientes Prepago
create table PCLUB.ADMPT_IMP_PREALTAC
(
  ADMPN_ID_FILA    NUMBER not null,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPV_TIPO_DOC   VARCHAR2(20),
  ADMPV_NUM_DOC    VARCHAR2(20),
  ADMPV_NOM_CLI    VARCHAR2(80),
  ADMPV_APE_CLI    VARCHAR2(80),
  ADMPC_SEXO       VARCHAR2(1),
  ADMPV_EST_CIVIL  VARCHAR2(20),
  ADMPV_EMAIL      VARCHAR2(80),
  ADMPV_PROV       VARCHAR2(30),
  ADMPV_DEPA       VARCHAR2(40),
  ADMPV_DIST       VARCHAR2(200),
  ADMPD_FEC_ACTIV  DATE,
  ADMPD_FEC_OPER   DATE,
  ADMPV_MSJE_ERROR VARCHAR2(400)
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

alter table PCLUB.ADMPT_IMP_PREALTAC
  add primary key (ADMPN_ID_FILA)
  using index 
  tablespace PCLUB_DATA
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
  
  -- Cambio de Titular
create table PCLUB.ADMPT_IMP_PRECMBTIT
(
  ADMPN_ID_FILA    NUMBER not null,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPV_TIPO_DOC   VARCHAR2(20),
  ADMPV_NUM_DOC    VARCHAR2(20),
  ADMPV_NOM_CLI    VARCHAR2(80),
  ADMPV_APE_CLI    VARCHAR2(80),
  ADMPC_SEXO       VARCHAR2(1),
  ADMPV_EST_CIVIL  VARCHAR2(20),
  ADMPV_EMAIL      VARCHAR2(80),
  ADMPV_PROV       VARCHAR2(30),
  ADMPV_DEPA       VARCHAR2(40),
  ADMPV_DIST       VARCHAR2(200),
  ADMPD_FEC_ACTIV  DATE,
  ADMPD_FEC_OPER   DATE,
  ADMPV_MSJE_ERROR VARCHAR2(400)
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

alter table PCLUB.ADMPT_IMP_PRECMBTIT
  add primary key (ADMPN_ID_FILA)
  using index 
  tablespace PCLUB_DATA
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
  
 -- Baja clientes Prepago
 
 create table PCLUB.ADMPT_TMP_PREBAJA
(
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPD_FEC_BAJA   DATE,
  ADMPD_FEC_OPER   DATE,
  ADMPV_MSJE_ERROR VARCHAR2(400)
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

  create table PCLUB.ADMPT_AUX_PREBAJA
(
  ADMPV_COD_CLI  VARCHAR2(40),
  ADMPD_FEC_BAJA DATE,
  ADMPD_FEC_OPER DATE
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
  
  create table PCLUB.ADMPT_IMP_PREBAJA
(
  ADMPN_ID_FILA    NUMBER not null,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPD_FEC_OPER   DATE,
  ADMPV_MSJE_ERROR VARCHAR2(400),
  ADMPD_FEC_BAJA   DATE,
  ADMPD_FEC_TRANS  DATE
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

alter table PCLUB.ADMPT_IMP_PREBAJA
  add constraint PK_ADMPT_IMP_PREBAJA primary key (ADMPN_ID_FILA)
  using index 
  tablespace PCLUB_DATA
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
  
  -- Migraciones de pre a post
create table PCLUB.ADMPT_IMP_PREPREPOS
(
  ADMPN_ID_FILA    NUMBER not null,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPD_FEC_MIG    DATE,
  ADMPD_FEC_OPER   DATE,
  ADMPV_MSJE_ERROR VARCHAR2(400)
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

alter table PCLUB.ADMPT_IMP_PREPREPOS
  add primary key (ADMPN_ID_FILA)
  using index 
  tablespace PCLUB_DATA
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
  
  -- Migraciones de post a pre
create table PCLUB.ADMPT_IMP_PREPOSPRE
(
  ADMPN_ID_FILA    NUMBER not null,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPD_FEC_MIG    DATE,
  ADMPD_FEC_OPER   DATE,
  ADMPV_MSJE_ERROR VARCHAR2(400)
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

alter table PCLUB.ADMPT_IMP_PREPOSPRE
  add primary key (ADMPN_ID_FILA)
  using index 
  tablespace PCLUB_DATA
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
  
  -- Carga Inicial de Clientes Prepago
create table PCLUB.ADMPT_TMP_PRECARGAIN
(
  ADMPV_TIPO_DOC   VARCHAR2(20),
  ADMPV_NUM_DOC    VARCHAR2(20),
  ADMPD_FEC_OPER   DATE,
  ADMPV_MSJE_ERROR VARCHAR2(400)
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
 
create table PCLUB.ADMPT_AUX_PRECARGAIN
(
  ADMPV_COD_CLI   VARCHAR2(40),
  ADMPD_FEC_ACTIV DATE,
  ADMPD_FEC_OPER  DATE
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
  
create table PCLUB.ADMPT_IMP_PRECARGAIN
(
  ADMPV_TIPO_DOC   VARCHAR2(20),
  ADMPV_NUM_DOC    VARCHAR2(20),
  ADMPD_FEC_OPER   DATE,
  ADMPV_MSJE_ERROR VARCHAR2(400)
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
  
 -- Puntos por Promociones
create table PCLUB.ADMPT_TMP_PREPROMO
(
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPV_NOM_PROMO  VARCHAR2(100),
  ADMPV_PERIODO    VARCHAR2(6),
  ADMPN_PUNTOS     NUMBER,
  ADMPV_NOM_ARCH   VARCHAR2(100),
  ADMPD_FEC_OPER   DATE,
  ADMPV_MSJE_ERROR VARCHAR2(400),
  ADMPN_SEQ        NUMBER
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
 
create table PCLUB.ADMPT_AUX_PREPROMO
(
  ADMPV_COD_CLI   VARCHAR2(40),
  ADMPV_NOM_PROMO VARCHAR2(100),
  ADMPV_PERIODO   VARCHAR2(6),
  ADMPN_PUNTOS    NUMBER,
  ADMPV_NOM_ARCH  VARCHAR2(100)
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
  
create table PCLUB.ADMPT_IMP_PREPROMO
(
  ADMPN_ID_FILA    NUMBER not null,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPV_NOM_PROMO  VARCHAR2(100),
  ADMPV_PERIODO    VARCHAR2(6),
  ADMPN_PUNTOS     NUMBER,
  ADMPV_NOM_ARCH   VARCHAR2(100),
  ADMPD_FEC_OPER   DATE,
  ADMPV_MSJE_ERROR VARCHAR2(400),
  ADMPD_FEC_TRANS  DATE,
  ADMPN_SEQ        NUMBER
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

alter table PCLUB.ADMPT_IMP_PREPROMO
  add primary key (ADMPN_ID_FILA)
  using index 
  tablespace PCLUB_DATA
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
  
  
  -- Tipos de Aplicaciones
create table PCLUB.ADMPT_TIPO_APLIC
(
  ADMPV_COD_TIPAPL VARCHAR2(2) not null,
  ADMPV_DES_TIPAPL VARCHAR2(100),
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

alter table PCLUB.ADMPT_TIPO_APLIC
  add constraint PK_ADMPT_TIPO_APLIC primary key (ADMPV_COD_TIPAPL)
  using index 
  tablespace PCLUB_DATA
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
  
  
create table PCLUB.ADMPT_IMP_ENT_BON_PRE
(
  ADMPN_ID_FILA    NUMBER,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPD_FEC_OPER   DATE,
  ADMPD_FEC_TRANS  DATE,
  ADMPV_MSJE_ERROR VARCHAR2(400),
  ADMPD_COD_CLI_IB VARCHAR2(40),
  ADMPD_NUM_DOC    VARCHAR2(40)
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


create table PCLUB.ADMPT_IMP_PRECARGACLI
(
  ADMPV_TIPO_DOC VARCHAR2(20),
  ADMPV_NUM_DOC  VARCHAR2(20),
  ADMPV_MSISDN   VARCHAR2(20),
  ADMPD_FEC_OPER DATE
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
