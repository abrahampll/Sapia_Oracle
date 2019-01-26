-- Create table
create table FIDELIDAD.SFYRT_PARAMSIST
(
  PRMSN_ID    NUMBER not null,
  PRMSV_DESC  VARCHAR2(50),
  PRMSV_VALOR VARCHAR2(50)
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
comment on column FIDELIDAD.SFYRT_PARAMSIST.PRMSN_ID
  is 'ID';
comment on column FIDELIDAD.SFYRT_PARAMSIST.PRMSV_DESC
  is 'Descripción Parametro';
comment on column FIDELIDAD.SFYRT_PARAMSIST.PRMSV_VALOR
  is 'Valor del Parametro';
-- Create/Recreate primary, unique and foreign key constraints 
alter table FIDELIDAD.SFYRT_PARAMSIST
  add constraint PK_PARAMSIST primary key (PRMSN_ID)
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

create table FIDELIDAD.SFYRT_TIPOS
(
  TIPON_ID      NUMBER not null,
  TIPOV_DESC    VARCHAR2(150),
  TIPOV_ABREV   VARCHAR2(20),
  TIPOV_VALOR   VARCHAR2(20),
  TIPON_ORDEN   NUMBER,
  TIPOC_ACTIVO  CHAR(1),
  CPTON_ID      NUMBER,
  TIPON_IDGRUPO NUMBER,
  TIPOV_USUREG  VARCHAR2(15),
  TIPOD_FECREG  DATE,
  TIPOV_USUMOD  VARCHAR2(15),
  TIPOD_FECMOD  DATE
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
comment on column FIDELIDAD.SFYRT_TIPOS.TIPON_ID
  is 'ID Tipos';
comment on column FIDELIDAD.SFYRT_TIPOS.TIPOV_DESC
  is 'Descripción del Tipo';
comment on column FIDELIDAD.SFYRT_TIPOS.TIPOV_ABREV
  is 'Abreviatura del Tipo';
comment on column FIDELIDAD.SFYRT_TIPOS.TIPOV_VALOR
  is 'Valor del Tipo';
comment on column FIDELIDAD.SFYRT_TIPOS.TIPON_ORDEN
  is 'Número de Orden';
comment on column FIDELIDAD.SFYRT_TIPOS.TIPOC_ACTIVO
  is '0:INACTIVO / 1:ACTIVO';
comment on column FIDELIDAD.SFYRT_TIPOS.CPTON_ID
  is 'ID Conceptos';
comment on column FIDELIDAD.SFYRT_TIPOS.TIPON_IDGRUPO
  is 'ID Tipos Grupo';
-- Create/Recreate primary, unique and foreign key constraints 
alter table FIDELIDAD.SFYRT_TIPOS
  add constraint PK_TIPOS primary key (TIPON_ID)
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
alter table FIDELIDAD.SFYRT_TIPOS
  add constraint FK_TIPOS_TIPOS foreign key (TIPON_IDGRUPO)
  references FIDELIDAD.SFYRT_TIPOS (TIPON_ID);
-- Create/Recreate check constraints 
alter table FIDELIDAD.SFYRT_TIPOS
  add constraint CKC_TIPOS_ACTIVO
  check (TIPOC_ACTIVO IN ('0','1'));
  
/* SFYRT_CONCEPTOS */
  
create table FIDELIDAD.SFYRT_CONCEPTOS
(
  CPTON_ID      NUMBER not null,
  CPTOV_DESC    VARCHAR2(100),
  CPTOC_ORDDESC CHAR(1),
  CPTOC_ACTIVO  CHAR(1),
  CPTON_IDGRUPO NUMBER,
  CPTOV_USUREG  VARCHAR2(15),
  CPTOD_FECREG  DATE,
  CPTOV_USUMOD  VARCHAR2(15),
  CPTOD_FECMOD  DATE
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
comment on column FIDELIDAD.SFYRT_CONCEPTOS.CPTON_ID
  is 'ID Concepto';
comment on column FIDELIDAD.SFYRT_CONCEPTOS.CPTOV_DESC
  is 'Descripción Concepto';
comment on column FIDELIDAD.SFYRT_CONCEPTOS.CPTOC_ORDDESC
  is '0:NO /1:SI (Si los tipos se orden por el campo DESC)';
comment on column FIDELIDAD.SFYRT_CONCEPTOS.CPTOC_ACTIVO
  is '0:INACTIVO / 1:ACTIVO';
comment on column FIDELIDAD.SFYRT_CONCEPTOS.CPTON_IDGRUPO
  is 'ID Concepto Grupo';
-- Create/Recreate primary, unique and foreign key constraints 
alter table FIDELIDAD.SFYRT_CONCEPTOS
  add constraint PK_CONCEPTOS primary key (CPTON_ID)
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
alter table FIDELIDAD.SFYRT_CONCEPTOS
  add constraint FK_CONCEPTOS_CONCEPTOS foreign key (CPTON_IDGRUPO)
  references FIDELIDAD.SFYRT_CONCEPTOS (CPTON_ID);
-- Create/Recreate check constraints 
alter table FIDELIDAD.SFYRT_CONCEPTOS
  add constraint CKC_CONCEPTOS_ACTIVO
  check (CPTOC_ACTIVO IN ('0','1'));
alter table FIDELIDAD.SFYRT_CONCEPTOS
  add constraint CKC_CONCEPTOS_ORDDESC
  check (CPTOC_ORDDESC IN ('0','1'));

  /* SFYRT_PROMOCIONCAB */
create table FIDELIDAD.SFYRT_PROMOCIONCAB
(
  PROMN_ID         NUMBER not null,
  PROMV_DESC       VARCHAR2(200) not null,
  TIPON_IDTIPO     NUMBER,
  TIPON_IDORIGEN   NUMBER,
  TIPON_IDVIGENCIA NUMBER,
  PROMD_FECINI     DATE,
  PROMD_FECFIN     DATE,
  PROMV_USUREG     VARCHAR2(15),
  PROMD_FECREG     DATE,
  PROMV_USUMOD     VARCHAR2(15),
  PROMD_FECMOD     DATE
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
comment on column FIDELIDAD.SFYRT_PROMOCIONCAB.PROMN_ID
  is 'ID de la Promoción';
comment on column FIDELIDAD.SFYRT_PROMOCIONCAB.PROMV_DESC
  is 'Descripción de la Promoción';
comment on column FIDELIDAD.SFYRT_PROMOCIONCAB.TIPON_IDTIPO
  is 'ID del Tipo de Promoción';
comment on column FIDELIDAD.SFYRT_PROMOCIONCAB.TIPON_IDORIGEN
  is 'ID del Origen de la Promoción';
comment on column FIDELIDAD.SFYRT_PROMOCIONCAB.TIPON_IDVIGENCIA
  is 'ID del Tipo de Vigencia de la Promoción';
comment on column FIDELIDAD.SFYRT_PROMOCIONCAB.PROMD_FECINI
  is 'Fecha Inicio de la Promoción';
comment on column FIDELIDAD.SFYRT_PROMOCIONCAB.PROMD_FECFIN
  is 'Fecha Término de la Promoción';
-- Create/Recreate primary, unique and foreign key constraints 
alter table FIDELIDAD.SFYRT_PROMOCIONCAB
  add constraint PK_PROMOCIONCAB primary key (PROMN_ID)
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

/* SFYRT_PROMOCIONSERVICIO */

create table FIDELIDAD.SFYRT_PROMOCIONSERVICIO
(
  PROSN_ID          NUMBER not null,
  PROMN_ID          NUMBER,
  PROSV_ETIQUETA    VARCHAR2(15),
  PROSV_DESCRIPCION VARCHAR2(100),
  PROSV_USUREG      VARCHAR2(15),
  PROSD_FECREG      DATE,
  PROSV_USUMOD      VARCHAR2(15),
  PROSD_FECMOD      DATE
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
comment on column FIDELIDAD.SFYRT_PROMOCIONSERVICIO.PROSN_ID
  is 'ID Promoción Servicio';
comment on column FIDELIDAD.SFYRT_PROMOCIONSERVICIO.PROMN_ID
  is 'ID Promoción';
comment on column FIDELIDAD.SFYRT_PROMOCIONSERVICIO.PROSV_ETIQUETA
  is 'ID Etiqueta';
comment on column FIDELIDAD.SFYRT_PROMOCIONSERVICIO.PROSV_DESCRIPCION
  is 'Descripción de la Etiqueta';
-- Create/Recreate primary, unique and foreign key constraints 
alter table FIDELIDAD.SFYRT_PROMOCIONSERVICIO
  add constraint PK_PROMOCIONSERVICIO primary key (PROSN_ID)
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
alter table FIDELIDAD.SFYRT_PROMOCIONSERVICIO
  add constraint PK_PROMOCIONSERVICIO_PROMCAB foreign key (PROMN_ID)
  references FIDELIDAD.SFYRT_PROMOCIONCAB (PROMN_ID);

/* SFYRT_PROGPROMCLIENTE */

create table FIDELIDAD.SFYRT_PROGPROMCLIENTE
(
  PPCLN_ID             NUMBER not null,
  PPCLV_SID            VARCHAR2(20),
  PPCLV_CODCLI         VARCHAR2(20),
  PPCLV_NOMCLI         VARCHAR2(200),
  PPCLD_FECTRX         DATE,
  PPCLN_IDSOTALTA      NUMBER,
  PPCLD_FECSOTALTAGEN  DATE,
  PPCLD_FECSOTALTA     DATE,
  PPCLV_OBSERVALTA     VARCHAR2(4000),
  PPCLN_IDSOTBAJA      NUMBER,
  PPCLD_FECSOTBAJAGEN  DATE,
  PPCLD_FECSOTBAJAPROG DATE,
  PPCLD_FECSOTBAJA     DATE,
  PPCLV_OBSERVBAJA     VARCHAR2(4000),
  PPCLN_REINTENTOS     NUMBER,
  PPCLV_TIPOSERV       VARCHAR2(50),
  PPCLV_ESTADOSERV     VARCHAR2(50),
  PPLTN_ID             NUMBER not null,
  TIPON_IDESTADO       NUMBER,
  PPCLV_USUREG         VARCHAR2(15),
  PPCLD_FECREG         DATE,
  PPCLV_USUMOD         VARCHAR2(15),
  PPCLD_FECMOD         DATE
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
comment on column FIDELIDAD.SFYRT_PROGPROMCLIENTE.PPCLN_ID
  is 'ID Secuencial';
comment on column FIDELIDAD.SFYRT_PROGPROMCLIENTE.PPCLV_SID
  is 'SID Cliente';
comment on column FIDELIDAD.SFYRT_PROGPROMCLIENTE.PPCLV_CODCLI
  is 'ID Cliente';
comment on column FIDELIDAD.SFYRT_PROGPROMCLIENTE.PPCLV_NOMCLI
  is 'Nombre Cliente';
comment on column FIDELIDAD.SFYRT_PROGPROMCLIENTE.PPCLD_FECTRX
  is 'Fecha transacción fecha corta';
comment on column FIDELIDAD.SFYRT_PROGPROMCLIENTE.PPCLN_IDSOTALTA
  is 'ID de la SOT de alta';
comment on column FIDELIDAD.SFYRT_PROGPROMCLIENTE.PPCLD_FECSOTALTAGEN
  is 'Fecha generación SOT de alta';
comment on column FIDELIDAD.SFYRT_PROGPROMCLIENTE.PPCLD_FECSOTALTA
  is 'Fecha atención de la SOT de alta';
comment on column FIDELIDAD.SFYRT_PROGPROMCLIENTE.PPCLV_OBSERVALTA
  is 'Observación en la SOT de alta';
comment on column FIDELIDAD.SFYRT_PROGPROMCLIENTE.PPCLN_IDSOTBAJA
  is 'ID de la SOT de baja';
comment on column FIDELIDAD.SFYRT_PROGPROMCLIENTE.PPCLD_FECSOTBAJAGEN
  is 'Fecha generación SOT de baja';
comment on column FIDELIDAD.SFYRT_PROGPROMCLIENTE.PPCLD_FECSOTBAJAPROG
  is 'Fecha de baja programada del Servicio';
comment on column FIDELIDAD.SFYRT_PROGPROMCLIENTE.PPCLD_FECSOTBAJA
  is 'Fecha atención de la SOT de baja';
comment on column FIDELIDAD.SFYRT_PROGPROMCLIENTE.PPCLV_OBSERVBAJA
  is 'Observación en la SOT de baja';
comment on column FIDELIDAD.SFYRT_PROGPROMCLIENTE.PPCLN_REINTENTOS
  is 'Número de reintentos';
comment on column FIDELIDAD.SFYRT_PROGPROMCLIENTE.PPCLV_TIPOSERV
  is 'Tipo de servicio';
comment on column FIDELIDAD.SFYRT_PROGPROMCLIENTE.PPCLV_ESTADOSERV
  is 'Estado del servicio';
comment on column FIDELIDAD.SFYRT_PROGPROMCLIENTE.PPLTN_ID
  is 'ID del lote';
comment on column FIDELIDAD.SFYRT_PROGPROMCLIENTE.TIPON_IDESTADO
  is 'ID del estado del proceso de atención';
-- Create/Recreate primary, unique and foreign key constraints 
alter table FIDELIDAD.SFYRT_PROGPROMCLIENTE
  add constraint PK_PROGPROMCLIENTE primary key (PPCLN_ID)
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

/* SFYRT_PROGPROMLOTE */

create table FIDELIDAD.SFYRT_PROGPROMLOTE
(
  PPLTN_ID         NUMBER not null,
  PPLTV_DESC       VARCHAR2(200) not null,
  PPLTV_NOMBREARCH VARCHAR2(200),
  PPLTD_FECTRX     DATE,
  PROMN_ID         NUMBER not null,
  TIPON_IDORIGEN   NUMBER not null,
  TIPON_IDESTADO   NUMBER not null,
  PPLTV_USUREG     VARCHAR2(15),
  PPLTD_FECREG     DATE,
  PPLTV_USUMOD     VARCHAR2(15),
  PPLTD_FECMOD     DATE
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
comment on column FIDELIDAD.SFYRT_PROGPROMLOTE.PPLTN_ID
  is 'ID del lote';
comment on column FIDELIDAD.SFYRT_PROGPROMLOTE.PPLTV_DESC
  is 'Descripción del lote';
comment on column FIDELIDAD.SFYRT_PROGPROMLOTE.PPLTV_NOMBREARCH
  is 'Nombre del archivo';
comment on column FIDELIDAD.SFYRT_PROGPROMLOTE.PPLTD_FECTRX
  is 'Fecha corta de registro';
comment on column FIDELIDAD.SFYRT_PROGPROMLOTE.PROMN_ID
  is 'ID de la promoción';
comment on column FIDELIDAD.SFYRT_PROGPROMLOTE.TIPON_IDORIGEN
  is 'ID del origen de la promoción SGA/BSCS';
comment on column FIDELIDAD.SFYRT_PROGPROMLOTE.TIPON_IDESTADO
  is 'ID del estado';
-- Create/Recreate primary, unique and foreign key constraints 
alter table FIDELIDAD.SFYRT_PROGPROMLOTE
  add constraint PK_PROGPROMLOTE primary key (PPLTN_ID)
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
alter table FIDELIDAD.SFYRT_PROGPROMLOTE
  add constraint FK_PROGPROMLOTE_PROMCAB foreign key (PROMN_ID)
  references FIDELIDAD.SFYRT_PROMOCIONCAB (PROMN_ID);
  
/* SFYRT_AUDPROMOCIONCAB */
  
create table FIDELIDAD.SFYRT_AUDPROMOCIONCAB
(
  ADPCN_ID         NUMBER not null,
  ADPCC_PROCESO    CHAR(1) not null,
  ADPCV_DESC       VARCHAR2(200) not null,
  ADPCD_FECINI     DATE,
  ADPCD_FECFIN     DATE,
  PROMN_ID         NUMBER not null,
  TIPON_IDTIPO     NUMBER,
  TIPON_IDORIGEN   NUMBER,
  TIPON_IDVIGENCIA NUMBER,
  ADPCV_USUREG     VARCHAR2(15),
  ADPCD_FECREG     DATE
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
comment on column FIDELIDAD.SFYRT_AUDPROMOCIONCAB.ADPCN_ID
  is 'ID de la Auditoría de la Promoción';
comment on column FIDELIDAD.SFYRT_AUDPROMOCIONCAB.ADPCC_PROCESO
  is 'Proceso (I:Insertar/A:Actualizar)';
comment on column FIDELIDAD.SFYRT_AUDPROMOCIONCAB.ADPCV_DESC
  is 'Descripción de la Promoción';
comment on column FIDELIDAD.SFYRT_AUDPROMOCIONCAB.ADPCD_FECINI
  is 'Fecha Inicio de la Promoción';
comment on column FIDELIDAD.SFYRT_AUDPROMOCIONCAB.ADPCD_FECFIN
  is 'Fecha Término de la Promoción';
comment on column FIDELIDAD.SFYRT_AUDPROMOCIONCAB.PROMN_ID
  is 'ID de la Promoción';
comment on column FIDELIDAD.SFYRT_AUDPROMOCIONCAB.TIPON_IDTIPO
  is 'ID del Tipo de Promoción';
comment on column FIDELIDAD.SFYRT_AUDPROMOCIONCAB.TIPON_IDORIGEN
  is 'ID del Origen de la Promoción';
comment on column FIDELIDAD.SFYRT_AUDPROMOCIONCAB.TIPON_IDVIGENCIA
  is 'ID del Tipo de Vigencia de la Promoción';
-- Create/Recreate primary, unique and foreign key constraints 
alter table FIDELIDAD.SFYRT_AUDPROMOCIONCAB
  add constraint PK_AUDPROMOCIONCAB primary key (ADPCN_ID)
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
alter table FIDELIDAD.SFYRT_AUDPROMOCIONCAB
  add constraint FK_AUDPROMOCIONCAB_PROMOCIONCA foreign key (PROMN_ID)
  references FIDELIDAD.SFYRT_PROMOCIONCAB (PROMN_ID);
-- Create/Recreate check constraints 
alter table FIDELIDAD.SFYRT_AUDPROMOCIONCAB
  add constraint CK_AUDPROMOCIONCAB_PROCESO
  check (ADPCC_PROCESO IN ('I','A'));
  
/* SFYRT_AUDPROMOCIONSERVICIO */

create table FIDELIDAD.SFYRT_AUDPROMOCIONSERVICIO
(
  ADPSN_ID          NUMBER,
  ADPSC_PROCESO     CHAR(1),
  ADPSV_ETIQUETA    VARCHAR2(15),
  ADPSV_DESCRIPCION VARCHAR2(100),
  ADPCN_ID          NUMBER,
  PROSN_ID          NUMBER not null,
  ADPSV_USUREG      VARCHAR2(15),
  ADPSD_FECREG      DATE
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
comment on column FIDELIDAD.SFYRT_AUDPROMOCIONSERVICIO.ADPSN_ID
  is 'ID Auditoría Promoción Servicio';
comment on column FIDELIDAD.SFYRT_AUDPROMOCIONSERVICIO.ADPSC_PROCESO
  is 'Proceso (I:Insertar/A:Actualizar/C:Consultar)';
comment on column FIDELIDAD.SFYRT_AUDPROMOCIONSERVICIO.ADPSV_ETIQUETA
  is 'ID Etiqueta';
comment on column FIDELIDAD.SFYRT_AUDPROMOCIONSERVICIO.ADPSV_DESCRIPCION
  is 'Descripción de la Etiqueta';
comment on column FIDELIDAD.SFYRT_AUDPROMOCIONSERVICIO.ADPCN_ID
  is 'ID Auditoría Promoción';
comment on column FIDELIDAD.SFYRT_AUDPROMOCIONSERVICIO.PROSN_ID
  is 'ID Promoción Servicio';
-- Create/Recreate primary, unique and foreign key constraints 
alter table FIDELIDAD.SFYRT_AUDPROMOCIONSERVICIO
  add constraint PK_AUDPROMOCIONSERVICIO primary key (ADPSN_ID)
  disable;
alter table FIDELIDAD.SFYRT_AUDPROMOCIONSERVICIO
  add constraint FK_AUDPROMOCIONSERV_AUDPROMCAB foreign key (ADPCN_ID)
  references FIDELIDAD.SFYRT_AUDPROMOCIONCAB (ADPCN_ID)
  disable;
-- Create/Recreate check constraints 
alter table FIDELIDAD.SFYRT_AUDPROMOCIONSERVICIO
  add constraint CK_AUDPROMOCIONSERVICIO_PROCES
  check (ADPSC_PROCESO IN ('I','A','C'));  
  
/* SFYRT_AUDPROGPROMLOTE */

create table FIDELIDAD.SFYRT_AUDPROGPROMLOTE
(
  ADPLN_ID         NUMBER not null,
  ADPLC_PROCESO    CHAR(1) not null,
  ADPLV_DESC       VARCHAR2(200) not null,
  ADPLV_NOMBREARCH VARCHAR2(200),
  ADPLN_REGVALIDO  NUMBER,
  ADPLN_REGERROR   NUMBER,
  ADPLN_REGTOTAL   NUMBER,
  PPLTN_ID         NUMBER not null,
  PROMN_ID         NUMBER not null,
  TIPON_IDORIGEN   NUMBER not null,
  TIPON_IDESTADO   NUMBER not null,
  ADPLV_USUREG     VARCHAR2(15),
  ADPLD_FECREG     DATE
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
comment on column FIDELIDAD.SFYRT_AUDPROGPROMLOTE.ADPLN_ID
  is 'ID de la Auditoría del Lote';
comment on column FIDELIDAD.SFYRT_AUDPROGPROMLOTE.ADPLC_PROCESO
  is 'Proceso (I:Insertar/A:Actualizar)';
comment on column FIDELIDAD.SFYRT_AUDPROGPROMLOTE.ADPLV_DESC
  is 'Descripción del lote';
comment on column FIDELIDAD.SFYRT_AUDPROGPROMLOTE.ADPLV_NOMBREARCH
  is 'Nombre del archivo';
comment on column FIDELIDAD.SFYRT_AUDPROGPROMLOTE.ADPLN_REGVALIDO
  is 'Total registros válidos';
comment on column FIDELIDAD.SFYRT_AUDPROGPROMLOTE.ADPLN_REGERROR
  is 'Total registros errados';
comment on column FIDELIDAD.SFYRT_AUDPROGPROMLOTE.ADPLN_REGTOTAL
  is 'Total registros';
comment on column FIDELIDAD.SFYRT_AUDPROGPROMLOTE.PPLTN_ID
  is 'ID del lote';
comment on column FIDELIDAD.SFYRT_AUDPROGPROMLOTE.PROMN_ID
  is 'ID de la promoción';
comment on column FIDELIDAD.SFYRT_AUDPROGPROMLOTE.TIPON_IDORIGEN
  is 'ID del origen de la promoción SGA/BSCS';
comment on column FIDELIDAD.SFYRT_AUDPROGPROMLOTE.TIPON_IDESTADO
  is 'ID del estado';
-- Create/Recreate primary, unique and foreign key constraints 
alter table FIDELIDAD.SFYRT_AUDPROGPROMLOTE
  add constraint PK_AUDPROGPROMLOTE primary key (ADPLN_ID)
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
-- Create/Recreate check constraints 
alter table FIDELIDAD.SFYRT_AUDPROGPROMLOTE
  add constraint CK_AUDPROGPROMLOTE_PROCESO
  check (ADPLC_PROCESO IN ('I','A'));

 
/* SFYRT_ERRORES */
  
create table FIDELIDAD.SFYRT_ERRORES
(
  SFYRN_COD_ERROR NUMBER not null,
  SFYRV_DES_ERROR VARCHAR2(200)
)
tablespace TBSFIDE_DATA
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
-- Create/Recreate primary, unique and foreign key constraints 
alter table FIDELIDAD.SFYRT_ERRORES
  add constraint PK_SFYRN_COD_ERROR primary key (SFYRN_COD_ERROR)
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
  
  