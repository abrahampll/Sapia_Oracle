-- Create table
create table PCLUB.ADMPT_ENCUESTA
(
  ADMPN_IDENC   NUMBER not null,
  ADMPV_NOMBRE  VARCHAR2(100) not null,
  ADMPD_FECINI  DATE,
  ADMPD_FECFIN  DATE,
  ADMPC_ESTADO  CHAR(1),
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
comment on column PCLUB.ADMPT_ENCUESTA.ADMPN_IDENC is 'Correlativo Encuesta';
comment on column PCLUB.ADMPT_ENCUESTA.ADMPV_NOMBRE is 'Nombre de la Encuesta';
comment on column PCLUB.ADMPT_ENCUESTA.ADMPD_FECINI is 'Fecha Inicio de la Encuesta';
comment on column PCLUB.ADMPT_ENCUESTA.ADMPD_FECFIN is 'Fecha fin de la Encuesta';
comment on column PCLUB.ADMPT_ENCUESTA.ADMPC_ESTADO is 'A: ACTIVO / B: BAJA';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_ENCUESTA
  add constraint PK_ADMPT_ENCUESTA primary key (ADMPN_IDENC)
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
-- Create/Recreate check constraints 
alter table PCLUB.ADMPT_ENCUESTA
  add constraint CKC_ENCUESTA_ESTADO
  check (ADMPC_ESTADO IN ('A','B'));

-- Create table
create table PCLUB.ADMPT_PREGUNTA
(
  ADMPN_IDPREGUNTA NUMBER not null,
  ADMPN_IDENC      NUMBER not null,
  ADMPV_PREGUNTA   VARCHAR2(200) not null,
  ADMPV_ORDEN      NUMBER,
  ADMPC_ESTADO     CHAR(1),
  ADMPD_FEC_REG    DATE,
  ADMPV_USU_REG    VARCHAR2(20),
  ADMPD_FEC_MOD    DATE,
  ADMPV_USU_MOD    VARCHAR2(20)
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
comment on column PCLUB.ADMPT_PREGUNTA.ADMPN_IDPREGUNTA is 'Correlativo Pregunta';
comment on column PCLUB.ADMPT_PREGUNTA.ADMPN_IDENC is 'ID Encuesta';
comment on column PCLUB.ADMPT_PREGUNTA.ADMPV_PREGUNTA is 'Detalle Prregunta';
comment on column PCLUB.ADMPT_PREGUNTA.ADMPV_ORDEN is 'Orden';
comment on column PCLUB.ADMPT_PREGUNTA.ADMPC_ESTADO is 'A: ACTIVO / B: BAJA';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_PREGUNTA
  add constraint PK_ADMPT_PREGUNTA primary key (ADMPN_IDPREGUNTA)
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
alter table PCLUB.ADMPT_PREGUNTA
  add constraint FK_PREGUNTA_ENCUESTA foreign key (ADMPN_IDENC)
  references PCLUB.ADMPT_ENCUESTA (ADMPN_IDENC);
-- Create/Recreate check constraints 
alter table PCLUB.ADMPT_PREGUNTA
  add constraint CKC_PREGUNTA_ESTADO
  check (ADMPC_ESTADO IN('A','B'));

-- Create table
create table PCLUB.ADMPT_RESPUESTA
(
  ADMPN_IDRESP     NUMBER not null,
  ADMPN_IDPREGUNTA NUMBER not null,
  ADMPV_OPCION     VARCHAR2(5),
  ADMPV_RESPUESTA  VARCHAR2(20) not null,
  ADMPC_ESTADO     CHAR(1),
  ADMPD_FEC_REG    DATE,
  ADMPV_USU_REG    VARCHAR2(20),
  ADMPD_FEC_MOD    DATE,
  ADMPV_USU_MOD    VARCHAR2(20)
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
comment on column PCLUB.ADMPT_RESPUESTA.ADMPN_IDRESP is 'Correlativo Respuesta';
comment on column PCLUB.ADMPT_RESPUESTA.ADMPN_IDPREGUNTA is 'ID Pregunta';
comment on column PCLUB.ADMPT_RESPUESTA.ADMPV_OPCION is 'Opción de Respuesta';
comment on column PCLUB.ADMPT_RESPUESTA.ADMPV_RESPUESTA is 'Detalle de Respuesta';
comment on column PCLUB.ADMPT_RESPUESTA.ADMPC_ESTADO is 'A: ACTIVO / B: BAJA';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_RESPUESTA
  add constraint PK_ADMPT_RESPUESTA primary key (ADMPN_IDRESP)
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
alter table PCLUB.ADMPT_RESPUESTA
  add constraint FK_ADMPT_RESPUESTA_PREGUNTA foreign key (ADMPN_IDPREGUNTA)
  references PCLUB.ADMPT_PREGUNTA (ADMPN_IDPREGUNTA);
-- Create/Recreate check constraints 
alter table PCLUB.ADMPT_RESPUESTA
  add constraint CKC_RESPUESTA_ESTADO
  check (ADMPC_ESTADO IN('A','B'));

-- Create table
create table PCLUB.ADMPT_CABENCUESTA
(
  ADMPN_IDCABENC   NUMBER not null,
  ADMPV_TELEFONO   VARCHAR2(20),
  ADMPN_IDENC      NUMBER,
  ADMPC_ESTADO     CHAR(1),
  ADMPD_FECINIENC  DATE,
  ADMPD_FECENVIO   DATE,
  ADMPD_FECCANCEL  DATE,
  ADMPN_ID_CANJE   NUMBER,
  ADMPV_TIPO_DOC   VARCHAR2(20),
  ADMPV_NUM_DOC    VARCHAR2(20),
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPC_TIPO_CANJE CHAR(1),
  ADMPD_FECFINENC  DATE,
  ADMPV_USU_REG    VARCHAR2(20),
  ADMPD_FEC_REG    DATE,
  ADMPV_USU_MOD    VARCHAR2(20),
  ADMPD_FEC_MOD    DATE
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
comment on column PCLUB.ADMPT_CABENCUESTA.ADMPN_IDCABENC is 'Código de Cabecera Encuesta';
comment on column PCLUB.ADMPT_CABENCUESTA.ADMPV_TELEFONO is 'Número Celular';
comment on column PCLUB.ADMPT_CABENCUESTA.ADMPN_IDENC is 'Código de Encuesta';
comment on column PCLUB.ADMPT_CABENCUESTA.ADMPC_ESTADO is 'P (Pendiente), Enviada (E), F (Finalizada), C (Cancelada)';
comment on column PCLUB.ADMPT_CABENCUESTA.ADMPD_FECINIENC is 'Fecha Inicio Encuesta';
comment on column PCLUB.ADMPT_CABENCUESTA.ADMPD_FECENVIO is 'Fecha de Envio de SMS al Cliente';
comment on column PCLUB.ADMPT_CABENCUESTA.ADMPD_FECCANCEL is 'Fecha de Cancelacion';
comment on column PCLUB.ADMPT_CABENCUESTA.ADMPN_ID_CANJE is 'Código del Canje';
comment on column PCLUB.ADMPT_CABENCUESTA.ADMPV_TIPO_DOC is 'Código del Tipo de Documento';
comment on column PCLUB.ADMPT_CABENCUESTA.ADMPV_NUM_DOC is 'Número del Documento';
comment on column PCLUB.ADMPT_CABENCUESTA.ADMPV_COD_CLI is 'Código del Cliente';
comment on column PCLUB.ADMPT_CABENCUESTA.ADMPC_TIPO_CANJE is 'Tipo de Canje Realizado: S - Servicios (sms,recarga,on-net,paq Datos),  E - Equipo';
comment on column PCLUB.ADMPT_CABENCUESTA.ADMPD_FECFINENC is 'Fecha Finalización de la Encuesta';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_CABENCUESTA
  add constraint PK_ADMPT_CABENCUESTA primary key (ADMPN_IDCABENC)
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
alter table PCLUB.ADMPT_CABENCUESTA
  add constraint FK_CABENCUESTA_CANJE foreign key (ADMPN_ID_CANJE)
  references PCLUB.ADMPT_CANJE (ADMPV_ID_CANJE);
alter table PCLUB.ADMPT_CABENCUESTA
  add constraint FK_CABENCUESTA_ENCUESTA foreign key (ADMPN_IDENC)
  references PCLUB.ADMPT_ENCUESTA (ADMPN_IDENC);
alter table PCLUB.ADMPT_CABENCUESTA
  add constraint FK_CABENCUESTA_TIPO_DOC foreign key (ADMPV_TIPO_DOC)
  references PCLUB.ADMPT_TIPO_DOC (ADMPV_COD_TPDOC);
-- Create/Recreate check constraints 
alter table PCLUB.ADMPT_CABENCUESTA
  add constraint CHK_CABENCUESTA_01
  check (ADMPC_ESTADO IN ('P','E','F','C'));
alter table PCLUB.ADMPT_CABENCUESTA
  add constraint CHK_CABENCUESTA_02
  check (ADMPC_TIPO_CANJE IN ('S','E'));

-- Create table
create table PCLUB.ADMPT_MOVENCUESTA
(
  ADMPN_IDMOV       NUMBER not null,
  ADMPV_TELEFONO    VARCHAR2(20),
  ADMPN_IDENC       NUMBER,
  ADMPN_IDPREGUNTA  NUMBER,
  ADMPN_IDRESP      NUMBER,
  ADMPD_FECGEN      DATE,
  ADMPD_FECENVIO    DATE,
  ADMPD_FECRESP     DATE,
  ADMPC_ESTADO_PRE  CHAR(1),
  ADMPV_DETALLE_MSJ VARCHAR2(300),
  ADMPN_IDCABENC    NUMBER not null,
  ADMPV_USU_REG     VARCHAR2(20),
  ADMPD_FEC_REG     DATE,
  ADMPV_USU_MOD     VARCHAR2(20),
  ADMPD_FEC_MOD     DATE
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
comment on column PCLUB.ADMPT_MOVENCUESTA.ADMPN_IDMOV is 'Código del Movimiento';
comment on column PCLUB.ADMPT_MOVENCUESTA.ADMPV_TELEFONO is 'Número del Celular';
comment on column PCLUB.ADMPT_MOVENCUESTA.ADMPN_IDENC is 'Código de Encuesta';
comment on column PCLUB.ADMPT_MOVENCUESTA.ADMPN_IDPREGUNTA is 'Código de Pregunta';
comment on column PCLUB.ADMPT_MOVENCUESTA.ADMPN_IDRESP is 'Código de Respuesta';
comment on column PCLUB.ADMPT_MOVENCUESTA.ADMPD_FECGEN is 'Fecha de Generación de Registro';
comment on column PCLUB.ADMPT_MOVENCUESTA.ADMPD_FECENVIO is 'Fecha de Envio de SMS al Cliente';
comment on column PCLUB.ADMPT_MOVENCUESTA.ADMPD_FECRESP is 'Fecha de Respuesta de Cliente';
comment on column PCLUB.ADMPT_MOVENCUESTA.ADMPC_ESTADO_PRE is 'P (Pendiente), Enviada (E), R (Respondida)';
comment on column PCLUB.ADMPT_MOVENCUESTA.ADMPV_DETALLE_MSJ is 'Describe la Pregunta con sus Opciones de Respuesta';
comment on column PCLUB.ADMPT_MOVENCUESTA.ADMPN_IDCABENC is 'Código de Cabecera de Encuesta';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_MOVENCUESTA
  add constraint PK_ADMPT_MOVENCUESTA primary key (ADMPN_IDMOV)
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
alter table PCLUB.ADMPT_MOVENCUESTA
  add constraint FK_MOVENCUESTA_CABENCUESTA foreign key (ADMPN_IDCABENC)
  references PCLUB.ADMPT_CABENCUESTA (ADMPN_IDCABENC);
alter table PCLUB.ADMPT_MOVENCUESTA
  add constraint FK_MOVENCUESTA_PREGUNTA foreign key (ADMPN_IDPREGUNTA)
  references PCLUB.ADMPT_PREGUNTA (ADMPN_IDPREGUNTA);
alter table PCLUB.ADMPT_MOVENCUESTA
  add constraint FK_MOVENCUESTA_RESPUESTA foreign key (ADMPN_IDRESP)
  references PCLUB.ADMPT_RESPUESTA (ADMPN_IDRESP);
-- Create/Recreate check constraints 
alter table PCLUB.ADMPT_MOVENCUESTA
  add constraint CHK_MOVENCUESTA_01
  check (ADMPC_ESTADO_PRE IN ('P','E','R'));
  
alter table PCLUB.ADMPT_TIPO_CLIENTE add ADMPC_ENCUESTA CHAR(1);
comment on column PCLUB.ADMPT_TIPO_CLIENTE.ADMPC_ENCUESTA is 'Si se envia encuesta (1:Si Otro valor:No)';
