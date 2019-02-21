-- Create table
create table fidelidad.CPRET_MSG_ENVIOSMS
(
  CPREN_ID          NUMBER not null,
  CPREV_DESCRIPCION VARCHAR2(200),
  CPRED_FECHAREG    DATE,
  CPREV_USUARIOREG  VARCHAR2(20),
  CPRED_FECHAMOD    DATE,
  CPREV_USUARIOMOD  VARCHAR2(20)
)
tablespace TBSFIDE_DATA
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
comment on column fidelidad.CPRET_MSG_ENVIOSMS.CPREN_ID
  is 'ID';
comment on column fidelidad.CPRET_MSG_ENVIOSMS.CPREV_DESCRIPCION
  is 'Mensaje';
-- Create/Recreate primary, unique and foreign key constraints 
alter table fidelidad.CPRET_MSG_ENVIOSMS
  add constraint PK_CPRET_MSG_ENVIOSMS primary key (CPREN_ID)
  using index 
  tablespace TBSFIDE_INDX
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
create table fidelidad.CPRET_CONFIG_SMS
(
  CPREN_CODIGO      NUMBER not null,
  CPREV_DESCRIPCION VARCHAR2(30),
  CPREV_VALOR       VARCHAR2(500),
  CPREV_GRUPO       VARCHAR2(20),
  CPREC_ESTADO      CHAR(1),
  CPREV_OPCION      VARCHAR2(100),
  CPRED_FECHAREG    DATE,
  CPREV_USUARIOREG  VARCHAR2(20),
  CPRED_FECHAMOD    DATE,
  CPREV_USUARIOMOD  VARCHAR2(20)
)
tablespace TBSFIDE_DATA
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
comment on column fidelidad.CPRET_CONFIG_SMS.CPREN_CODIGO
  is 'Correlativo configuración';
comment on column fidelidad.CPRET_CONFIG_SMS.CPREV_DESCRIPCION
  is 'Identificador de la configuración';
comment on column fidelidad.CPRET_CONFIG_SMS.CPREV_VALOR
  is 'Valor de la configuración';
comment on column fidelidad.CPRET_CONFIG_SMS.CPREV_GRUPO
  is 'Grupo que corresponde a la configuración';
comment on column fidelidad.CPRET_CONFIG_SMS.CPREC_ESTADO
  is 'Estado de la configuración';
-- Create/Recreate primary, unique and foreign key constraints 
alter table fidelidad.CPRET_CONFIG_SMS
  add constraint PK_CPRET_CONFIG_SMS primary key (CPREN_CODIGO)
  using index 
  tablespace TBSFIDE_INDX
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
create table fidelidad.CPRET_MOVCHURN
(
  CPREN_ID            NUMBER not null,
  CPREV_TICKET        VARCHAR2(30),
  CPREV_TELEFONO      VARCHAR2(20),
  CPREV_TIPOTELEF     VARCHAR2(1),
  CPREV_MENSAJE       VARCHAR2(500),
  CPREN_IDINTERACT    NUMBER,
  CPRED_FECH_PROG_SMS DATE,
  CPREV_ESTADO        VARCHAR2(1),
  CPREV_ESTADO_INTER  VARCHAR2(1),
  CPRED_FECH_REAL_SMS DATE,
  CPRED_FECHAREG      DATE,
  CPREV_USUARIOREG    VARCHAR2(20),
  CPRED_FECHAMOD      DATE,
  CPREV_USUARIOMOD    VARCHAR2(20),
  CPREV_NOMARCHIVO    VARCHAR2(100),
  CPREV_PERIODO       VARCHAR2(6)
)
tablespace TBSFIDE_DATA
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
comment on column fidelidad.CPRET_MOVCHURN.CPREN_ID
  is 'ID';
comment on column fidelidad.CPRET_MOVCHURN.CPREV_TICKET
  is 'Nro. Ticket';
comment on column fidelidad.CPRET_MOVCHURN.CPREV_TELEFONO
  is 'Telefono';
comment on column fidelidad.CPRET_MOVCHURN.CPREV_TIPOTELEF
  is 'Tipo Teléfono M: Móvil / T: TFI';
comment on column fidelidad.CPRET_MOVCHURN.CPREV_MENSAJE
  is 'Mensaje a enviar por SMS';
comment on column fidelidad.CPRET_MOVCHURN.CPREN_IDINTERACT
  is 'ID Interaccion';
comment on column fidelidad.CPRET_MOVCHURN.CPRED_FECH_PROG_SMS
  is 'Fecha Programada para envío sms';
comment on column fidelidad.CPRET_MOVCHURN.CPREV_ESTADO
  is 'Estado';
comment on column fidelidad.CPRET_MOVCHURN.CPREV_ESTADO_INTER
  is 'Estado de actualización de Interacción';
comment on column fidelidad.CPRET_MOVCHURN.CPRED_FECH_REAL_SMS
  is 'Fecha real de envío sms';
comment on column fidelidad.CPRET_MOVCHURN.CPRED_FECHAREG
  is 'Fecha de Registro';
comment on column fidelidad.CPRET_MOVCHURN.CPREV_USUARIOREG
  is 'Usuario de Registro';
comment on column fidelidad.CPRET_MOVCHURN.CPRED_FECHAMOD
  is 'Fecha de modificación';
comment on column fidelidad.CPRET_MOVCHURN.CPREV_USUARIOMOD
  is 'Usuario de modificación';
comment on column fidelidad.CPRET_MOVCHURN.CPREV_PERIODO
  is 'Periodo';
-- Create/Recreate primary, unique and foreign key constraints 
alter table fidelidad.CPRET_MOVCHURN
  add constraint PK_CPRET_MOVCHURN primary key (CPREN_ID)
  using index 
  tablespace TBSFIDE_INDX
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
create table fidelidad.CPRET_TMP_MOVCHURN
(
  CPREN_SEC           VARCHAR2(30) not null,
  CPREV_TICKET        VARCHAR2(30),
  CPREV_TELEFONO      VARCHAR2(20),
  CPRED_FECH_REAL_SMS DATE,
  CPREN_IDINTERACT    NUMBER
)
tablespace TBSFIDE_DATA
  pctfree 10
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
comment on column fidelidad.CPRET_TMP_MOVCHURN.CPREN_SEC
  is 'Secuencial';
comment on column fidelidad.CPRET_TMP_MOVCHURN.CPREV_TICKET
  is 'Numero del ticket';
comment on column fidelidad.CPRET_TMP_MOVCHURN.CPREV_TELEFONO
  is 'Numero de telefono';
comment on column fidelidad.CPRET_TMP_MOVCHURN.CPRED_FECH_REAL_SMS
  is 'Fecha real de envio de SMS';
comment on column fidelidad.CPRET_TMP_MOVCHURN.CPREN_IDINTERACT
  is 'ID de interaccion';
  
  
-- Create table
create table fidelidad.CPRET_TMP_REP_MOVCHURN
(
  CPREN_SEC           VARCHAR2(30) not null,
  CPREV_TICKET        VARCHAR2(30),
  CPREV_TELEFONO      VARCHAR2(20),
  CPREN_IDINTERACT    NUMBER,
  CPREV_TIPOTELEF     VARCHAR2(1),
  CPREV_ESTADO        VARCHAR2(1),
  CPREV_ESTADO_INTER  VARCHAR2(1),
  CPREV_FECH_PROG_SMS DATE,
  CPREV_MSJE          VARCHAR2(500)
)
tablespace TBSFIDE_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
  
  
-- Index
create index fidelidad.IDX_CPRET_MOVCHURN_01 on fidelidad.CPRET_MOVCHURN(CPREV_PERIODO)
  tablespace TBSFIDE_INDX
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
  
