/* ADMPT_BONO */

create table PCLUB.ADMPT_BONO
(
  ADMPV_BONO        VARCHAR2(20) not null,
  ADMPN_ID_BONO_PRE NUMBER,
  ADMPV_MENSAJE     VARCHAR2(40),
  ADMPC_ESTADO      CHAR(1),
  ADMPD_FEC_REG     DATE,
  ADMPV_USU_REG     VARCHAR2(20),
  ADMPD_FEC_MOD     DATE,
  ADMPV_USU_MOD     VARCHAR2(20),
  ADMPV_DESCBONO    VARCHAR2(150)
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
comment on column PCLUB.ADMPT_BONO.ADMPV_BONO
  is 'Id Bono';
comment on column PCLUB.ADMPT_BONO.ADMPN_ID_BONO_PRE
  is 'ID del Bono, enviado por Prepago';
comment on column PCLUB.ADMPT_BONO.ADMPV_MENSAJE
  is 'Valor del Mensaje de la ADMPT_MENSAJE';
comment on column PCLUB.ADMPT_BONO.ADMPC_ESTADO
  is 'Estado del Bono A: Activo / B: Baja';
comment on column PCLUB.ADMPT_BONO.ADMPV_DESCBONO
  is 'Descripción del Bono';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_BONO
  add constraint PK_ADMPT_BONO primary key (ADMPV_BONO)
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

/* ADMPT_BONO_CONFIG */
  
create table PCLUB.ADMPT_BONO_CONFIG
(
  ADMPV_BONO      VARCHAR2(20) not null,
  ADMPV_COD_TPOPR VARCHAR2(2) not null,
  ADMPN_PUNTOS    NUMBER,
  ADMPN_DIASVIGEN NUMBER,
  ADMPV_COD_CPTO  VARCHAR2(3),
  ADMPC_ESTADO    CHAR(1),
  ADMPD_FEC_REG   DATE,
  ADMPV_USU_REG   VARCHAR2(20),
  ADMPD_FEC_MOD   DATE,
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
comment on column PCLUB.ADMPT_BONO_CONFIG.ADMPV_BONO
  is 'Id Bono';
comment on column PCLUB.ADMPT_BONO_CONFIG.ADMPV_COD_TPOPR
  is '0: se puede usar para cualquier canje';
comment on column PCLUB.ADMPT_BONO_CONFIG.ADMPN_PUNTOS
  is 'Puntos a configurar';
comment on column PCLUB.ADMPT_BONO_CONFIG.ADMPN_DIASVIGEN
  is 'Dias de vigencia de los puntos';
comment on column PCLUB.ADMPT_BONO_CONFIG.ADMPV_COD_CPTO
  is 'Concepto a ingresar en el kárdex';
comment on column PCLUB.ADMPT_BONO_CONFIG.ADMPC_ESTADO
  is 'Estado A: Activo/ B: Baja';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_BONO_CONFIG
  add constraint PK_ADMPT_BONO_CONFIG primary key (ADMPV_BONO, ADMPV_COD_TPOPR)
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
alter table PCLUB.ADMPT_BONO_CONFIG
  add constraint FK_ADMPT_BONO foreign key (ADMPV_BONO)
  references PCLUB.ADMPT_BONO (ADMPV_BONO);
  
/* ADMPT_BONO_KARDEX */
  
create table PCLUB.ADMPT_BONO_KARDEX
(
  ADMPN_ID_KARDEX    NUMBER NOT NULL,
  ADMPV_BONO         VARCHAR2(40),
  ADMPV_LINEA        VARCHAR2(40),
  ADMPD_FEC_ENTBONO  DATE,
  ADMPD_FEC_VENCBONO DATE,
  ADMPD_FEC_REG      DATE,
  ADMPV_USU_REG      VARCHAR2(40),
  ADMPD_FEC_MOD      DATE,
  ADMPV_USU_MOD      VARCHAR2(40),
  ADMPN_PUNTOS       NUMBER,
  ADMPN_DIASVIGEN    NUMBER,
  ADMPV_COD_TPOPR    VARCHAR2(2),
  ADMPV_TIPO_DOC     VARCHAR2(20),
  ADMPV_NUM_DOC      VARCHAR2(20)
)
tablespace PCLUB_DATA
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 3M
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Add comments to the columns 
comment on column PCLUB.ADMPT_BONO_KARDEX.ADMPN_ID_KARDEX
  is 'Id Kárdex';
comment on column PCLUB.ADMPT_BONO_KARDEX.ADMPV_BONO
  is 'Bono';
comment on column PCLUB.ADMPT_BONO_KARDEX.ADMPV_LINEA
  is 'Línea';
comment on column PCLUB.ADMPT_BONO_KARDEX.ADMPD_FEC_ENTBONO
  is 'Fecha entrega del bono';
comment on column ADMPT_BONO_KARDEX.ADMPD_FEC_VENCBONO
  is 'Fecha de vencimiento del bono';
comment on column PCLUB.ADMPT_BONO_KARDEX.ADMPN_PUNTOS
  is 'Puntos';
comment on column PCLUB.ADMPT_BONO_KARDEX.ADMPN_DIASVIGEN
  is 'Días de vigencia';
comment on column PCLUB.ADMPT_BONO_KARDEX.ADMPV_COD_TPOPR
  is 'Tipo de Premios 1: Servicio/ 2 Dscto Equipo';
comment on column PCLUB.ADMPT_BONO_KARDEX.ADMPV_TIPO_DOC
  is 'Tipo documento';
comment on column PCLUB.ADMPT_BONO_KARDEX.ADMPV_NUM_DOC
  is 'Nro documento';
  
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_BONO_KARDEX
  add constraint PK_ADMPT_BONO_KARDEX primary key (ADMPN_ID_KARDEX)
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

  /* ADMPT_SALDOS_BONO_CLIENTE */
  
create table PCLUB.ADMPT_SALDOS_BONO_CLIENTE
(
  ADMPN_ID_SALDOBON NUMBER not null,
  ADMPV_COD_CLI     VARCHAR2(40),
  ADMPN_SALDO       NUMBER,
  ADMPN_GRUPO       NUMBER,
  ADMPV_ESTADO      CHAR(1),
  ADMPV_USU_REG     VARCHAR2(20),
  ADMPD_FEC_REG     DATE,
  ADMPV_USU_MOD     VARCHAR2(20),
  ADMPD_FEC_MOD     DATE
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
comment on column PCLUB.ADMPT_SALDOS_BONO_CLIENTE.ADMPN_ID_SALDOBON
  is 'Correlativo';
comment on column PCLUB.ADMPT_SALDOS_BONO_CLIENTE.ADMPV_COD_CLI
  is 'Codigo Cliente ClaroClub';
comment on column PCLUB.ADMPT_SALDOS_BONO_CLIENTE.ADMPN_SALDO
  is 'Saldo Total por Tipo premio';
comment on column PCLUB.ADMPT_SALDOS_BONO_CLIENTE.ADMPN_GRUPO
  is 'Tipo Premio Agrupado';
comment on column PCLUB.ADMPT_SALDOS_BONO_CLIENTE.ADMPV_ESTADO
  is 'Estado';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_SALDOS_BONO_CLIENTE
  add constraint PK_ADMPT_SALDOS_BONO_CLIENTE primary key (ADMPN_ID_SALDOBON)
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
  
/* ADMPT_BONOPREP_ERR */

create table PCLUB.ADMPT_BONOPREP_ERR
(
  ADMPN_ID          NUMBER not null,
  ADMPN_TELEF       VARCHAR2(20),
  ADMPN_ID_BONO_PRE NUMBER,
  ADMPV_CODERR      VARCHAR2(3),
  ADMPV_DESCERR     VARCHAR2(200),
  ADMPD_FEC_REG     DATE,
  ADMPV_USU_REG     VARCHAR2(20),
  ADMPD_FEC_MOD     DATE,
  ADMPV_USU_MOD     VARCHAR2(20),
  ADMPV_BONO        VARCHAR2(20)
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
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_BONOPREP_ERR
  add constraint PK_ADMPT_BONOPREP_ERR primary key (ADMPN_ID)
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

/* ADMPT_IMP_BONOFIDEL_PRE */

create table PCLUB.ADMPT_IMP_BONOFIDEL_PRE
(
  ADMPN_SEC          NUMBER not null,
  ADMPV_NOMARCHIVO   VARCHAR2(50) not null,
  ADMPC_TIPO_FIDEL   CHAR(1) not null,
  ADMPV_LINEA        VARCHAR2(20),
  ADMPV_TIPO_DOCU    VARCHAR2(20),
  ADMPV_NRO_DOCU     VARCHAR2(20),
  ADMPV_NOMBRES      VARCHAR2(80),
  ADMPV_APELLIDOS    VARCHAR2(80),
  ADMPV_SEXO         VARCHAR2(10),
  ADMPV_EST_CIVIL    VARCHAR2(20),
  ADMPV_EMAIL        VARCHAR2(100),
  ADMPV_DPTO         VARCHAR2(50),
  ADMPV_PROVINCIA    VARCHAR2(50),
  ADMPV_DISTRITO     VARCHAR2(200),
  ADMPD_FEC_ACTIVA   DATE,
  ADMPC_ESTADOSMS    CHAR(1),
  ADMPV_CODERROR     VARCHAR2(10),
  ADMPV_MSJERROR     VARCHAR2(250),
  ADMPD_FEC_OPERA    DATE,
  ADMPD_FEC_REG      DATE,
  ADMPD_USU_REG      VARCHAR2(20),
  ADMPD_FEC_MOD      DATE,
  ADMPD_USU_MOD      VARCHAR2(20),
  ADMPD_FEC_ENVIOSMS DATE
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
comment on column PCLUB.ADMPT_IMP_BONOFIDEL_PRE.ADMPN_SEC
  is 'SECUENCIAL';
comment on column PCLUB.ADMPT_IMP_BONOFIDEL_PRE.ADMPV_NOMARCHIVO
  is 'NOMBRE ARCHIVO PROCESAR';
comment on column PCLUB.ADMPT_IMP_BONOFIDEL_PRE.ADMPC_TIPO_FIDEL
  is 'TIPO DE FIDELIDAD: (M):6MESES / (A):12MESES';
comment on column PCLUB.ADMPT_IMP_BONOFIDEL_PRE.ADMPC_ESTADOSMS
  is 'P:PENDIENTE ENVIO / E:ENVIADO SMS/ N:NO SE ENVIA';
comment on column PCLUB.ADMPT_IMP_BONOFIDEL_PRE.ADMPD_FEC_OPERA
  is 'FECHA CORTA DD/MM/YYYY';
comment on column PCLUB.ADMPT_IMP_BONOFIDEL_PRE.ADMPD_FEC_REG
  is 'FECHA HORA MINUTOS';
comment on column PCLUB.ADMPT_IMP_BONOFIDEL_PRE.ADMPD_FEC_MOD
  is 'FECHA HORA MINUTOS';
comment on column PCLUB.ADMPT_IMP_BONOFIDEL_PRE.ADMPD_FEC_ENVIOSMS
  is 'FECHA DE ENVIO SMS';


/* ADMPT_TMP_BONOFIDEL_PRE */

create table PCLUB.ADMPT_TMP_BONOFIDEL_PRE
(
  ADMPN_SEC        NUMBER not null,
  ADMPV_NOMARCHIVO VARCHAR2(50),
  ADMPC_TIPO_FIDEL CHAR(1),
  ADMPV_LINEA      VARCHAR2(20),
  ADMPV_TIPO_DOCU  VARCHAR2(20),
  ADMPV_NRO_DOCU   VARCHAR2(20),
  ADMPV_NOMBRES    VARCHAR2(80),
  ADMPV_APELLIDOS  VARCHAR2(80),
  ADMPV_SEXO       VARCHAR2(10),
  ADMPV_EST_CIVIL  VARCHAR2(20),
  ADMPV_EMAIL      VARCHAR2(100),
  ADMPV_DPTO       VARCHAR2(50),
  ADMPV_PROVINCIA  VARCHAR2(50),
  ADMPV_DISTRITO   VARCHAR2(200),
  ADMPD_FEC_ACTIVA DATE,
  ADMPC_ESTADO     CHAR(1),
  ADMPC_ESTADOSMS  CHAR(1),
  ADMPV_CODERROR   VARCHAR2(10),
  ADMPV_MSJERROR   VARCHAR2(250),
  ADMPD_FEC_OPERA  DATE,
  ADMPD_FEC_REG    DATE
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
comment on column PCLUB.ADMPT_TMP_BONOFIDEL_PRE.ADMPN_SEC
  is 'SECUENCIAL';
comment on column PCLUB.ADMPT_TMP_BONOFIDEL_PRE.ADMPV_NOMARCHIVO
  is 'NOMBRE ARCHIVO PROCESAR';
comment on column PCLUB.ADMPT_TMP_BONOFIDEL_PRE.ADMPC_TIPO_FIDEL
  is 'TIPO DE FIDELIDAD: (M):6MESES / (A):12MESES';
comment on column PCLUB.ADMPT_TMP_BONOFIDEL_PRE.ADMPC_ESTADO
  is 'P:PROCESADO';
comment on column PCLUB.ADMPT_TMP_BONOFIDEL_PRE.ADMPC_ESTADOSMS
  is 'P:PENDIENTE ENVIO / E:ENVIADO SMS';
comment on column PCLUB.ADMPT_TMP_BONOFIDEL_PRE.ADMPD_FEC_OPERA
  is 'FECHA CORTA DD/MM/YYYY';
comment on column PCLUB.ADMPT_TMP_BONOFIDEL_PRE.ADMPD_FEC_REG
  is 'FECHA HORA MINUTOS';


  
/* ADMPT_GRUPO_TIPPREM */
  
create table PCLUB.ADMPT_GRUPO_TIPPREM
(
  ADMPN_GRUPO       NUMBER,
  ADMPV_DESCRIPCION VARCHAR2(100)
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
  
/* ADMPT_TMP_ALTA_XRECARGA_PRE */

create table PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE
(
  ADMPN_SEQ        NUMBER not null,
  ADMPV_NOMARCHIVO VARCHAR2(50) not null,
  ADMPV_LINEA      VARCHAR2(20),
  ADMPV_TIPO_DOCU  VARCHAR2(20),
  ADMPV_NRO_DOCU   VARCHAR2(20),
  ADMPV_NOMBRES    VARCHAR2(50),
  ADMPV_APELLIDOS  VARCHAR2(50),
  ADMPV_SEXO       VARCHAR2(10),
  ADMPV_EST_CIVIL  VARCHAR2(20),
  ADMPV_EMAIL      VARCHAR2(50),
  ADMPV_DPTO       VARCHAR2(50),
  ADMPV_PROVINCIA  VARCHAR2(50),
  ADMPV_DISTRITO   VARCHAR2(50),
  ADMPD_FEC_ACTIVA DATE,
  ADMPC_ESTADO     CHAR(1),
  ADMPC_ESTADOSMS  CHAR(1),
  ADMPV_CODERROR   VARCHAR2(10),
  ADMPV_MSJERROR   VARCHAR2(100),
  ADMPD_FEC_OPERA  DATE,
  ADMPD_FEC_REG    DATE
)
tablespace PCLUB_DATA
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 768K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Add comments to the columns 
comment on column PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE.ADMPN_SEQ
  is 'SECUENCIAL';
comment on column PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE.ADMPV_NOMARCHIVO
  is 'NOMBRE ARCHIVO PROCESAR';
comment on column PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE.ADMPC_ESTADO
  is 'P:PROCESADO';
comment on column PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE.ADMPC_ESTADOSMS
  is 'P:PENDIENTE ENVIO / E:ENVIADO SMS';
comment on column PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE.ADMPD_FEC_OPERA
  is 'FECHA CORTA DD/MM/YYYY';
comment on column PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE.ADMPD_FEC_REG
  is 'FECHA HORA MINUTOS';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE
  add constraint PK_ADMPT_TMP_ALTA_XRECARGA_PRE primary key (ADMPN_SEQ, ADMPV_NOMARCHIVO)
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
  
/* ADMPT_IMP_ALTA_XRECARGA_PRE */

create table PCLUB.ADMPT_IMP_ALTA_XRECARGA_PRE
(
  ADMPN_SEQ          NUMBER not null,
  ADMPV_NOMARCHIVO   VARCHAR2(50) not null,
  ADMPV_LINEA        VARCHAR2(20),
  ADMPV_TIPO_DOCU    VARCHAR2(20),
  ADMPV_NRO_DOCU     VARCHAR2(20),
  ADMPV_NOMBRES      VARCHAR2(50),
  ADMPV_APELLIDOS    VARCHAR2(50),
  ADMPV_SEXO         VARCHAR2(10),
  ADMPV_EST_CIVIL    VARCHAR2(20),
  ADMPV_EMAIL        VARCHAR2(50),
  ADMPV_DPTO         VARCHAR2(50),
  ADMPV_PROVINCIA    VARCHAR2(50),
  ADMPV_DISTRITO     VARCHAR2(50),
  ADMPD_FEC_ACTIVA   DATE,
  ADMPC_ESTADO       CHAR(1),
  ADMPC_ESTADOSMS    CHAR(1),
  ADMPV_CODERROR     VARCHAR2(10),
  ADMPV_MSJERROR     VARCHAR2(100),
  ADMPD_FEC_OPERA    DATE,
  ADMPD_FEC_REG      DATE,
  ADMPD_USU_REG      VARCHAR2(20),
  ADMPD_FEC_MOD      DATE,
  ADMPD_USU_MOD      VARCHAR2(20),
  ADMPD_FEC_ENVIOSMS DATE
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
comment on column PCLUB.ADMPT_IMP_ALTA_XRECARGA_PRE.ADMPN_SEQ
  is 'SECUENCIAL';
comment on column PCLUB.ADMPT_IMP_ALTA_XRECARGA_PRE.ADMPV_NOMARCHIVO
  is 'NOMBRE ARCHIVO PROCESAR';
comment on column PCLUB.ADMPT_IMP_ALTA_XRECARGA_PRE.ADMPC_ESTADO
  is 'P:PROCESADO';
comment on column PCLUB.ADMPT_IMP_ALTA_XRECARGA_PRE.ADMPC_ESTADOSMS
  is 'P:PENDIENTE ENVIO / E:ENVIADO SMS';
comment on column PCLUB.ADMPT_IMP_ALTA_XRECARGA_PRE.ADMPD_FEC_OPERA
  is 'FECHA CORTA DD/MM/YYYY';
comment on column PCLUB.ADMPT_IMP_ALTA_XRECARGA_PRE.ADMPD_FEC_REG
  is 'FECHA HORA MINUTOS';
comment on column PCLUB.ADMPT_IMP_ALTA_XRECARGA_PRE.ADMPD_FEC_MOD
  is 'FECHA HORA MINUTOS';
comment on column PCLUB.ADMPT_IMP_ALTA_XRECARGA_PRE.ADMPD_FEC_ENVIOSMS
  is 'FECHA DE ENVIO SMS';