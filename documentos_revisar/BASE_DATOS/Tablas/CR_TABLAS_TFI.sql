-- Create table
create table PCLUB.ADMPT_AUX_ALTACLI_TFI
(
  ADMPV_COD_CLI  VARCHAR2(40),
  ADMPV_TIPO_DOC VARCHAR2(20),
  ADMPV_NUM_DOC  VARCHAR2(20),
  ADMPV_NOM_CLI  VARCHAR2(80),
  ADMPV_APE_CLI  VARCHAR2(80),
  ADMPD_FEC_OPER DATE,
  ADMPV_NOM_ARCH VARCHAR2(150)
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
  
-- Create table
create table PCLUB.ADMPT_AUX_ANIVERSTFI
(
  ADMPV_COD_CLI  VARCHAR2(40),
  ADMPD_FEC_ANIV DATE,
  ADMPD_FEC_OPER DATE
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
  
 -- Create table
create table PCLUB.ADMPT_AUX_BAJACLI_TFI
(
  ADMPV_COD_CLI  VARCHAR2(40),
  ADMPD_FEC_BAJA DATE,
  ADMPD_FEC_OPER DATE
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

 -- Create table
create table PCLUB.ADMPT_AUX_PROMOCIONTFI
(
  ADMPV_COD_CLI   VARCHAR2(40),
  ADMPN_PUNTOS    NUMBER,
  ADMPV_PERIODO   VARCHAR2(6),
  ADMPV_NOM_PROMO VARCHAR2(150),
  ADMPD_FEC_REG   DATE,
  ADMPD_FEC_OPER  DATE,
  ADMPV_NOM_ARCH  VARCHAR2(150)
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

 -- Create table
create table PCLUB.ADMPT_AUX_RECARGATFI
(
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPN_MONTO      NUMBER,
  ADMPD_FEC_ULTREC DATE,
  ADMPD_FEC_OPER   DATE
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

 -- Create table
create table PCLUB.ADMPT_AUX_REGULARIZATFI
(
  ADMPV_COD_CLI   VARCHAR2(40),
  ADMPN_PUNTOS    NUMBER,
  ADMPV_PERIODO   VARCHAR2(6),
  ADMPV_NOM_REGUL VARCHAR2(150),
  ADMPD_FEC_REG   DATE,
  ADMPD_FEC_OPER  DATE,
  ADMPV_NOM_ARCH  VARCHAR2(150)
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

 -- Create table
create table PCLUB.ADMPT_AUX_SINRECARGATFI
(
  ADMPV_COD_CLI  VARCHAR2(40),
  ADMPD_FEC_OPER DATE
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

 -- Create table
create table PCLUB.ADMPT_IMP_ALTACLI_TFI
(
  ADMPN_ID_FILA    NUMBER not null,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPV_TIPO_DOC   VARCHAR2(20),
  ADMPV_NUM_DOC    VARCHAR2(20),
  ADMPV_NOM_CLI    VARCHAR2(80),
  ADMPV_APE_CLI    VARCHAR2(80),
  ADMPC_SEXO       CHAR(1),
  ADMPV_EST_CIVIL  VARCHAR2(20),
  ADMPV_EMAIL      VARCHAR2(80),
  ADMPV_DEPA       VARCHAR2(40),
  ADMPV_PROV       VARCHAR2(30),
  ADMPV_DIST       VARCHAR2(200),
  ADMPD_FEC_OPER   DATE,
  ADMPV_NOM_ARCH   VARCHAR2(150),
  ADMPV_COD_ERROR  CHAR(3),
  ADMPV_MSJE_ERROR VARCHAR2(400),
  ADMPD_FCH_TRANS  DATE,
  ADMPN_SEQ        NUMBER
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
alter table PCLUB.ADMPT_IMP_ALTACLI_TFI
  add constraint PK_ADMPT_IMP_ALTACLI_TFI primary key (ADMPN_ID_FILA)
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
create table PCLUB.ADMPT_IMP_ANIVERSTFI
(
  ADMPN_ID_FILA    NUMBER not null,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPD_FEC_ANIV   DATE,
  ADMPD_FEC_OPER   DATE,
  ADMPD_FEC_TRANS  DATE,
  ADMPV_MSJE_ERROR VARCHAR2(400),
  ADMPV_NOM_ARCH   VARCHAR2(150)
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
alter table PCLUB.ADMPT_IMP_ANIVERSTFI
  add constraint PK_ADMPT_IMP_ANIVERSTFI primary key (ADMPN_ID_FILA)
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
create table PCLUB.ADMPT_IMP_BAJACLI_TFI
(
  ADMPN_ID_FILA    NUMBER not null,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPD_FEC_BAJA   DATE,
  ADMPD_FEC_OPER   DATE,
  ADMPD_FEC_TRANS  DATE,
  ADMPV_MSJE_ERROR VARCHAR2(400),
  ADMPV_NOM_ARCH   VARCHAR2(150)
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
alter table PCLUB.ADMPT_IMP_BAJACLI_TFI
  add constraint PK_ADMPT_IMP_BAJACLI_TFI primary key (ADMPN_ID_FILA)
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
create table PCLUB.ADMPT_IMP_PROMOCIONTFI
(
  ADMPN_ID_FILA    NUMBER not null,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPV_NOM_PROMO  VARCHAR2(150),
  ADMPV_PERIODO    VARCHAR2(6),
  ADMPN_PUNTOS     NUMBER,
  ADMPD_FEC_OPER   DATE,
  ADMPV_NOM_ARCH   VARCHAR2(150),
  ADMPC_COD_ERROR  CHAR(3),
  ADMPV_MSJE_ERROR VARCHAR2(400),
  ADMPD_FEC_TRANS  DATE,
  ADMPN_PTOS_ORI   NUMBER
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
alter table PCLUB.ADMPT_IMP_PROMOCIONTFI
  add constraint PK_ADMPT_IMP_PROMOCIONTFI primary key (ADMPN_ID_FILA)
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
create table PCLUB.ADMPT_IMP_RECARGATFI
(
  ADMPN_ID_FILA    NUMBER not null,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPD_FEC_ULTREC DATE,
  ADMPN_MONTO      NUMBER,
  ADMPD_FEC_OPER   DATE,
  ADMPD_FEC_TRANS  DATE,
  ADMPV_MSJE_ERROR VARCHAR2(400),
  ADMPV_NOM_ARCH   VARCHAR2(150)
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
alter table PCLUB.ADMPT_IMP_RECARGATFI
  add constraint PK_ADMPT_IMP_RECARGATFI primary key (ADMPN_ID_FILA)
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
create table PCLUB.ADMPT_IMP_REGULARIZATFI
(
  ADMPN_ID_FILA    NUMBER not null,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPV_NOM_REGUL  VARCHAR2(150),
  ADMPV_PERIODO    VARCHAR2(6),
  ADMPN_PUNTOS     NUMBER,
  ADMPD_FEC_OPER   DATE,
  ADMPV_NOM_ARCH   VARCHAR2(150),
  ADMPC_COD_ERROR  CHAR(3),
  ADMPV_MSJE_ERROR VARCHAR2(400),
  ADMPD_FEC_TRANS  DATE,
  ADMPN_PTOS_ORI   NUMBER
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
alter table PCLUB.ADMPT_IMP_REGULARIZATFI
  add constraint PK_ADMPT_IMP_REGULARIZATFI primary key (ADMPN_ID_FILA)
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
create table PCLUB.ADMPT_IMP_SINRECARGATFI
(
  ADMPN_ID_FILA    NUMBER not null,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPD_FEC_OPER   DATE,
  ADMPD_FEC_TRANS  DATE,
  ADMPV_MSJE_ERROR VARCHAR2(400),
  ADMPV_NOM_ARCH   VARCHAR2(150)
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
alter table PCLUB.ADMPT_IMP_SINRECARGATFI
  add constraint PK_ADMPT_IMP_SINRECARGATFI primary key (ADMPN_ID_FILA)
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
create table PCLUB.ADMPT_IMP_TFICMBTIT
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
  ADMPV_MSJE_ERROR VARCHAR2(400),
  ADMPV_COD_ERROR  VARCHAR2(3)
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
alter table PCLUB.ADMPT_IMP_TFICMBTIT
  add constraint PK_ADMPT_IMP_TFICMBTIT primary key (ADMPN_ID_FILA)
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
create table PCLUB.ADMPT_TMP_ALTACLI_TFI
(
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPV_TIPO_DOC   VARCHAR2(20),
  ADMPV_NUM_DOC    VARCHAR2(20),
  ADMPV_NOM_CLI    VARCHAR2(80),
  ADMPV_APE_CLI    VARCHAR2(80),
  ADMPC_SEXO       CHAR(1),
  ADMPV_EST_CIVIL  VARCHAR2(20),
  ADMPV_EMAIL      VARCHAR2(80),
  ADMPV_DEPA       VARCHAR2(40),
  ADMPV_PROV       VARCHAR2(30),
  ADMPV_DIST       VARCHAR2(200),
  ADMPD_FEC_OPER   DATE,
  ADMPV_NOM_ARCH   VARCHAR2(150),
  ADMPV_COD_ERROR  CHAR(3),
  ADMPV_MSJE_ERROR VARCHAR2(400),
  ADMPN_SEQ        NUMBER
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

 -- Create table
create table PCLUB.ADMPT_TMP_ANIVERSTFI
(
  ADMPV_COD_CLI  VARCHAR2(40),
  ADMPD_FEC_ANIV DATE,
  ADMPD_FEC_OPER DATE
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

 -- Create table
create table PCLUB.ADMPT_TMP_BAJACLI_TFI
(
  ADMPV_COD_CLI  VARCHAR2(40),
  ADMPD_FEC_BAJA DATE,
  ADMPD_FEC_OPER DATE
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

 -- Create table
create table PCLUB.ADMPT_TMP_PROMOCIONTFI
(
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPN_PUNTOS     NUMBER,
  ADMPV_PERIODO    VARCHAR2(6),
  ADMPV_NOM_PROMO  VARCHAR2(150),
  ADMPD_FEC_REG    DATE,
  ADMPD_FEC_OPER   DATE,
  ADMPV_NOM_ARCH   VARCHAR2(150),
  ADMPC_COD_ERROR  CHAR(3),
  ADMPV_MSJE_ERROR VARCHAR2(400),
  ADMPN_SEQ        NUMBER
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

 -- Create table
create table PCLUB.ADMPT_TMP_RECARGATFI
(
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPN_MONTO      NUMBER,
  ADMPD_FEC_ULTREC DATE,
  ADMPD_FEC_OPER   DATE
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

-- Create table
create table PCLUB.ADMPT_TMP_REGULARIZATFI
(
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPN_PUNTOS     NUMBER,
  ADMPV_PERIODO    VARCHAR2(6),
  ADMPV_NOM_REGUL  VARCHAR2(150),
  ADMPD_FEC_REG    DATE,
  ADMPD_FEC_OPER   DATE,
  ADMPV_NOM_ARCH   VARCHAR2(150),
  ADMPC_COD_ERROR  CHAR(3),
  ADMPV_MSJE_ERROR VARCHAR2(400),
  ADMPN_SEQ        NUMBER
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

 -- Create table
create table PCLUB.ADMPT_TMP_SINRECARGATFI
(
  ADMPV_COD_CLI  VARCHAR2(40),
  ADMPD_FEC_OPER DATE
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

 -- Update table
alter table PCLUB.ADMPT_CANJE add ADMPV_INTERACTID VARCHAR2(40);
alter table PCLUB.ADMPT_CANJE modify ADMPV_COD_TIPAPL VARCHAR2(3);
alter table PCLUB.ADMPT_TIPO_CLIENTE add ADMPV_TIPO VARCHAR2(20);
