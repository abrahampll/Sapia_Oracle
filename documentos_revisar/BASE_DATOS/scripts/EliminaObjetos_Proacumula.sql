drop table PCLUB.ADMPT_TMP_PAGO_CC cascade constraints;

create table PCLUB.ADMPT_TMP_PAGO_CC
(
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPV_PERIODO    VARCHAR2(6),
  ADMPN_DIAS_VENC  NUMBER,
  ADMPN_MNT_CGOFIJ NUMBER,
  ADMPN_MNT_ADIC   NUMBER,
  ADMPN_ACGOFIJ    NUMBER,
  ADMPC_SGACGOFIJ  CHAR(1),
  ADMPN_AJUADIC    NUMBER,
  ADMPC_SGAJUADI   CHAR(1),
  ADMPD_FEC_OPER   DATE,
  ADMPV_NOM_ARCH   VARCHAR2(150),
  ADMPN_PUNTOS     NUMBER,
  ADMPC_COD_ERROR  CHAR(3),
  ADMPV_MSJE_ERROR VARCHAR2(250)
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


drop table PCLUB.ADMPT_IMP_PAGO_CC cascade constraints;

create table PCLUB.ADMPT_IMP_PAGO_CC
(
  ADMPN_ID_FILA    NUMBER not null,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPV_PERIODO    VARCHAR2(6),
  ADMPN_DIAS_VENC  NUMBER,
  ADMPN_MNT_CGOFIJ NUMBER,
  ADMPN_MNT_ADIC   NUMBER,
  ADMPN_ACGOFIJ    NUMBER,
  ADMPC_SGACGOFIJ  CHAR(1),
  ADMPN_AJUADIC    NUMBER,
  ADMPC_SGAJUADI   CHAR(1),
  ADMPD_FEC_OPER   DATE,
  ADMPV_NOM_ARCH   VARCHAR2(150),
  ADMPN_PUNTOS     NUMBER
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
alter table PCLUB.ADMPT_IMP_PAGO_CC
  add constraint PK_ADMPT_IMP_PAGO_CC primary key (ADMPN_ID_FILA)
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


drop table PCLUB.ADMPT_IMP_ALTACON_CC cascade constraints;

create table PCLUB.ADMPT_IMP_ALTACON_CC
(
  ADMPN_ID_FILA   NUMBER not null,
  ADMPV_COD_CLI   VARCHAR2(40),
  ADMPN_COD_CONTR NUMBER(22),
  ADMPD_FCH_ACT   DATE,
  ADMPV_NOM_CAMP  VARCHAR2(200),
  ADMPV_PLNTARIF  VARCHAR2(50),
  ADMPV_VIGACUE   VARCHAR2(100),
  ADMPD_FEC_OPER  DATE,
  ADMPV_NOM_ARCH  VARCHAR2(150)
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
alter table PCLUB.ADMPT_IMP_ALTACON_CC
  add constraint PK_ADMPT_IMP_ALTACON_CC primary key (ADMPN_ID_FILA)
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



-- Alta de Clientes
drop table PCLUB.ADMPT_TMP_ALTACLI_CC cascade constraints;


create table PCLUB.ADMPT_TMP_ALTACLI_CC
(
  ADMPV_TIPO_DOC   VARCHAR2(20),
  ADMPV_NUM_DOC    VARCHAR2(20),
  ADMPV_NOM_CLI    VARCHAR2(30),
  ADMPV_APE_CLI    VARCHAR2(30),
  ADMPC_SEXO       CHAR(1),
  ADMPV_EST_CIVIL  VARCHAR2(20),
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPV_EMAIL      VARCHAR2(80),
  ADMPV_PROV       VARCHAR2(30),
  ADMPV_DEPA       VARCHAR2(40),
  ADMPV_DIST       VARCHAR2(200),
  ADMPD_FEC_ACT    DATE,
  ADMPV_CICL_FACT  VARCHAR2(2),
  ADMPD_FEC_OPER   DATE,
  ADMPV_NOM_ARCH   VARCHAR2(150),
  ADMPV_COD_ERROR  CHAR(3),
  ADMPV_MSJE_ERROR VARCHAR2(250)
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


drop table PCLUB.ADMPT_IMP_ALTACLI_CC cascade constraints;

create table PCLUB.ADMPT_IMP_ALTACLI_CC
(
  ADMPN_ID_FILA   NUMBER not null,
  ADMPV_TIPO_DOC  VARCHAR2(20),
  ADMPV_NUM_DOC   VARCHAR2(20),
  ADMPV_NOM_CLI   VARCHAR2(30),
  ADMPV_APE_CLI   VARCHAR2(30),
  ADMPC_SEXO      CHAR(1),
  ADMPV_EST_CIVIL VARCHAR2(20),
  ADMPV_COD_CLI   VARCHAR2(40),
  ADMPV_EMAIL     VARCHAR2(80),
  ADMPV_PROV      VARCHAR2(30),
  ADMPV_DEPA      VARCHAR2(40),
  ADMPV_DIST      VARCHAR2(200),
  ADMPD_FEC_ACT   DATE,
  ADMPV_CICL_FACT VARCHAR2(2),
  ADMPD_FEC_OPER  DATE,
  ADMPV_NOM_ARCH  VARCHAR2(150)
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
alter table PCLUB.ADMPT_IMP_ALTACLI_CC
  add constraint PK_ADMPT_IMP_ALTACLI_CC primary key (ADMPN_ID_FILA)
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



drop table PCLUB.ADMPT_AUX_PROM cascade constraints;

create table PCLUB.ADMPT_AUX_PROM
(
  ADMPV_COD_CLI  VARCHAR2(40),
  ADMPV_NOM_PROM VARCHAR2(150),
  ADMPN_PUNTOS   NUMBER,
  ADMPD_FEC_OPER DATE,
  ADMPV_NOM_ARCH VARCHAR2(150)
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


drop table PCLUB.ADMPT_TMP_PROM cascade constraints;

reate table PCLUB.ADMPT_TMP_PROM
(
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPV_NOM_PROM   VARCHAR2(150),
  ADMPV_PERIODO    VARCHAR2(6),
  ADMPN_CONTR      NUMBER,
  ADMPD_FEC_REG    DATE,
  ADMPV_HORAMIN    VARCHAR2(5),
  ADMPN_PUNTOS     NUMBER,
  ADMPD_FEC_OPER   DATE,
  ADMPV_NOM_ARCH   VARCHAR2(150),
  ADMPC_COD_ERROR  CHAR(2),
  ADMPV_MSJE_ERROR VARCHAR2(100)
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


drop table PCLUB.ADMPT_IMP_PROM cascade constraints;

create table PCLUB.ADMPT_IMP_PROM
(
  ADMPN_ID_FILA    NUMBER not null,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPV_NOM_PROM   VARCHAR2(150),
  ADMPV_PERIODO    VARCHAR2(6),
  ADMPN_CONTR      NUMBER,
  ADMPD_FEC_REG    DATE,
  ADMPV_HORAMIN    VARCHAR2(5),
  ADMPN_PUNTOS     NUMBER,
  ADMPD_FEC_OPER   DATE,
  ADMPV_NOM_ARCH   VARCHAR2(150),
  ADMPC_COD_ERROR  CHAR(2),
  ADMPV_MSJE_ERROR VARCHAR2(100)
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
alter table PCLUB.ADMPT_IMP_PROM
  add constraint PK_ADMPT_IMP_PROMON primary key (ADMPN_ID_FILA)
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



-- cambio de Titular
drop table PCLUB.ADMPT_TMP_CMBTIT_CC cascade constraints;

create table PCLUB.ADMPT_TMP_CMBTIT_CC
(
  ADMPV_TIPO_DOC   VARCHAR2(20),
  ADMPV_NUM_DOC    VARCHAR2(20),
  ADMPV_NOM_CLI    VARCHAR2(30),
  ADMPV_APE_CLI    VARCHAR2(30),
  ADMPC_SEXO       CHAR(1),
  ADMPV_EST_CIVIL  VARCHAR2(20),
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPV_EMAIL      VARCHAR2(80),
  ADMPV_PROV       VARCHAR2(30),
  ADMPV_DEPA       VARCHAR2(40),
  ADMPV_DIST       VARCHAR2(200),
  ADMPD_FEC_ACT    DATE,
  ADMPV_CICL_FACT  VARCHAR2(2),
  ADMPD_FEC_OPER   DATE,
  ADMPV_NOM_ARCH   VARCHAR2(150),
  ADMPC_COD_ERROR  CHAR(2),
  ADMPV_MSJE_ERROR VARCHAR2(100)
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


drop table PCLUB.ADMPT_IMP_CMBTIT_CC cascade constraints;

create table PCLUB.ADMPT_IMP_CMBTIT_CC
(
  ADMPN_ID_FILA    NUMBER not null,
  ADMPV_TIPO_DOC   VARCHAR2(20),
  ADMPV_NUM_DOC    VARCHAR2(20),
  ADMPV_NOM_CLI    VARCHAR2(30),
  ADMPV_APE_CLI    VARCHAR2(30),
  ADMPC_SEXO       CHAR(1),
  ADMPV_EST_CIVIL  VARCHAR2(20),
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPV_EMAIL      VARCHAR2(80),
  ADMPV_PROV       VARCHAR2(30),
  ADMPV_DEPA       VARCHAR2(40),
  ADMPV_DIST       VARCHAR2(200),
  ADMPD_FEC_ACT    DATE,
  ADMPV_CICL_FACT  VARCHAR2(2),
  ADMPD_FEC_OPER   DATE,
  ADMPV_NOM_ARCH   VARCHAR2(150),
  ADMPC_COD_ERROR  CHAR(2),
  ADMPV_MSJE_ERROR VARCHAR2(100)
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
alter table PCLUB.ADMPT_IMP_CMBTIT_CC
  add constraint PK_ADMPT_IMP_CMBTIT_CC primary key (ADMPN_ID_FILA)
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



drop table PCLUB.ADMPT_IMP_RENCONT_CC cascade constraints;

create table PCLUB.ADMPT_IMP_RENCONT_CC
(
  ADMPN_ID_FILA   NUMBER not null,
  ADMPV_COD_CLI   VARCHAR2(40),
  ADMPD_FEC_REN   DATE,
  ADMPV_NUM_LINEA VARCHAR2(20),
  ADMPN_COD_CONTR NUMBER(22),
  ADMPD_FEC_OPER  DATE,
  ADMPV_NOM_ARCH  VARCHAR2(150)
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
alter table PCLUB.ADMPT_IMP_RENCONT_CC
  add constraint PK_ADMPT_IMP_RENCONT_CC primary key (ADMPN_ID_FILA)
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


drop table PCLUB.ADMPT_IMP_BAJACLI_CC cascade constraints;

create table PCLUB.ADMPT_IMP_BAJACLI_CC
(
  ADMPN_ID_FILA  NUMBER not null,
  ADMPV_COD_CLI  VARCHAR2(40),
  ADMPD_FCH_BAJA DATE,
  ADMPD_FEC_OPER DATE,
  ADMPV_NOM_ARCH VARCHAR2(150)
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
alter table PCLUB.ADMPT_IMP_BAJACLI_CC
  add constraint PK_ADMPT_IMP_BAJACLI_CC primary key (ADMPN_ID_FILA)
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


drop table PCLUB.ADMPT_IMP_NOFACT_CC cascade constraints;

create table PCLUB.ADMPT_IMP_NOFACT_CC
(
  ADMPN_ID_FILA  NUMBER not null,
  ADMPV_COD_CLI  VARCHAR2(40),
  ADMPD_FCH_PROC DATE,
  ADMPD_FEC_OPER DATE,
  ADMPV_NOM_ARCH VARCHAR2(150)
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
alter table PCLUB.ADMPT_IMP_NOFACT_CC
  add constraint PK_ADMPT_IMP_NOFACT_CC primary key (ADMPN_ID_FILA)
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

drop table PCLUB.ADMPT_IMP_PRXRCON_CC cascade constraints;

create table PCLUB.ADMPT_IMP_PRXRCON_CC
(
  ADMPN_ID_FILA   NUMBER not null,
  ADMPV_COD_CLI   VARCHAR2(40),
  ADMPC_TIPO      CHAR(1),
  ADMPN_COD_CONTR NUMBER(22),
  ADMPD_FEC_OPER  DATE,
  ADMPV_NOM_ARCH  VARCHAR2(150)
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
alter table PCLUB.ADMPT_IMP_PRXRCON_CC
  add constraint PK_ADMPT_IMP_PRXRCON_CC primary key (ADMPN_ID_FILA)
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


drop table PCLUB.ADMPT_EXP_PROXRCO_CC cascade constraints;


create table PCLUB.ADMPT_EXP_PROXRCO_CC
(
  ADMPN_ID_FILA   NUMBER not null,
  ADMPV_COD_CLI   VARCHAR2(40),
  ADMPC_TIPO      CHAR(1),
  ADMPN_COD_CONTR NUMBER(22),
  ADMPN_PUNTOS    NUMBER,
  ADMPN_EQUIV     NUMBER,
  ADMPD_FEC_OPER  DATE,
  ADMPV_NOM_ARCH  VARCHAR2(150)
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
alter table PCLUB.ADMPT_EXP_PROXRCO_CC
  add constraint PK_ADMPT_EXP_PROXRCO_CC primary key (ADMPN_ID_FILA)
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

drop table PCLUB.ADMPT_AUX_REGULARIZA cascade constraints;


create table PCLUB.ADMPT_AUX_REGULARIZA
(
  ADMPV_COD_CLI   VARCHAR2(40),
  ADMPV_NOM_REGUL VARCHAR2(150),
  ADMPN_PUNTOS    NUMBER,
  ADMPD_FEC_OPER  DATE,
  ADMPV_NOM_ARCH  VARCHAR2(150)
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


drop table PCLUB.ADMPT_TMP_REGULARIZA cascade constraints;

create table PCLUB.ADMPT_TMP_REGULARIZA
(
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPV_NOM_REGUL  VARCHAR2(150),
  ADMPV_PERIODO    VARCHAR2(6),
  ADMPN_COD_CONTR  NUMBER(22),
  ADMPD_FEC_REG    DATE,
  ADMPV_HOR_MIN    VARCHAR2(5),
  ADMPN_PUNTOS     NUMBER,
  ADMPD_FEC_OPER   DATE,
  ADMPV_NOM_ARCH   VARCHAR2(150),
  ADMPC_COD_ERROR  CHAR(2),
  ADMPV_MSJE_ERROR VARCHAR2(100)
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



drop table PCLUB.ADMPT_IMP_REGULARIZA cascade constraints;

create table PCLUB.ADMPT_IMP_REGULARIZA
(
  ADMPN_ID_FILA    NUMBER not null,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPV_NOM_REGUL  VARCHAR2(150),
  ADMPV_PERIODO    VARCHAR2(6),
  ADMPN_COD_CONTR  NUMBER(22),
  ADMPD_FEC_REG    DATE,
  ADMPV_HOR_MIN    VARCHAR2(5),
  ADMPN_PUNTOS     NUMBER,
  ADMPD_FEC_OPER   DATE,
  ADMPV_NOM_ARCH   VARCHAR2(150),
  ADMPC_COD_ERROR  CHAR(2),
  ADMPV_MSJE_ERROR VARCHAR2(100)
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
alter table PCLUB.ADMPT_IMP_REGULARIZA
  add constraint PK_ADMPT_IMP_REGULARIZA primary key (ADMPN_ID_FILA)
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


drop table PCLUB.ADMPT_AUX_PAGO_CC cascade constraints;
drop table PCLUB.ADMPT_AUX_ALTACON_CC cascade constraints;
drop table PCLUB.ADMPT_TMP_ALTACON_CC cascade constraints;
drop table PCLUB.ADMPT_AUX_ALTACLI_CC cascade constraints;
drop table PCLUB.ADMPT_TMP_ANIV cascade constraints;
drop table PCLUB.ADMPT_AUX_ANIV cascade constraints;
drop table PCLUB.ADMPT_IMP_ANIV cascade constraints;
drop table PCLUB.ADMPT_AUX_CMBTIT_CC cascade constraints;

DROP PACKAGE PCLUB.PKG_CC_PROCACUMULA;

DROP SEQUENCE pclub.ADMPT_PAGOCC_SQ;
DROP SEQUENCE pclub.ADMPT_ALTACONT_SQ;
DROP SEQUENCE pclub.ADMPT_ALTACLI_SQ;
DROP SEQUENCE pclub.ADMPT_PROM_SQ;
DROP SEQUENCE pclub.ADMPT_ANIV_SQ;
DROP SEQUENCE pclub.ADMPT_CAMBIOTT_SQ;
DROP SEQUENCE pclub.ADMPT_RENCONT_SQ;
DROP SEQUENCE pclub.admpt_baja_sq;
DROP SEQUENCE pclub.admpt_nofac_sq;
DROP SEQUENCE pclub.ADMPT_PRXRCON_SQ;
DROP SEQUENCE pclub.Admpt_Expproxren_Sq;
DROP SEQUENCE pclub.ADMPT_REGULA_SQ;
