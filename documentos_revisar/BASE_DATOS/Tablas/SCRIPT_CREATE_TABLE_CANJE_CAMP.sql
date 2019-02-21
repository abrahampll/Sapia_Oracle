-- Create table
create table PCLUB.SYSFT_CAMPANA
(
  SYCAN_IDENTIFICADOR NUMBER not null,
  SYCAV_DESCRIPCION   VARCHAR2(50) not null,
  SYCAD_FEC_INICAMP   DATE not null,
  SYCAD_FEC_FINCAMP   DATE not null,
  SYCAV_USUARIO_REG   VARCHAR2(30) not null,
  SYCAD_FEC_REG       DATE not null,
  SYCAV_USUARIO_MOD   VARCHAR2(30),
  SYCAD_FEC_MOD       DATE
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
-- Add comments to the columns 
comment on column PCLUB.SYSFT_CAMPANA.SYCAN_IDENTIFICADOR
  is 'Id unico del registro';
comment on column PCLUB.SYSFT_CAMPANA.SYCAV_DESCRIPCION
  is 'Descripción de la campaña';
comment on column PCLUB.SYSFT_CAMPANA.SYCAD_FEC_INICAMP
  is 'Fecha inicial de la campaña';
comment on column PCLUB.SYSFT_CAMPANA.SYCAD_FEC_FINCAMP
  is 'Fecha final de la campaña';
comment on column PCLUB.SYSFT_CAMPANA.SYCAV_USUARIO_REG
  is 'Usuario que inserto el registro';
comment on column PCLUB.SYSFT_CAMPANA.SYCAD_FEC_REG
  is 'Fecha de registro';
comment on column PCLUB.SYSFT_CAMPANA.SYCAV_USUARIO_MOD
  is 'Usuario que actualizo el registro';
comment on column PCLUB.SYSFT_CAMPANA.SYCAD_FEC_MOD
  is 'Fecha de modificación de registro';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.SYSFT_CAMPANA
  add constraint PKS_SYCAN_IDENTIFICADOR primary key (SYCAN_IDENTIFICADOR)
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

-- Create table
create table PCLUB.SYSFT_EVENTO
(
  SYEVN_IDENTIFICADOR NUMBER not null,
  SYCAN_IDENTIFICADOR NUMBER not null,
  SYEVV_DESCRIPCION   VARCHAR2(50) not null,
  SYEVD_FECINI_EVENTO DATE not null,
  SYEVD_FECFIN_EVENTO DATE not null,
  SYEVV_PALABRA_CLAVE VARCHAR2(15) not null,
  SYEVN_PUNTOSCLARO   NUMBER not null,
  SYEVN_MONTO_PAGO    NUMBER(10,2),
  SYEVV_USUARIO_REG   VARCHAR2(30) not null,
  SYEVD_FEC_REG       DATE not null,
  SYEVV_USUARIO_MOD   VARCHAR2(30),
  SYEVD_FEC_MOD       DATE,
  ADMPV_ID_PROCLA     VARCHAR2(15)
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
-- Add comments to the columns 
comment on column PCLUB.SYSFT_EVENTO.SYEVN_IDENTIFICADOR
  is 'Id unico del registro';
comment on column PCLUB.SYSFT_EVENTO.SYCAN_IDENTIFICADOR
  is 'Identificador de la tabla PCLUB.SYSFT_CAMPANA';
comment on column PCLUB.SYSFT_EVENTO.SYEVV_DESCRIPCION
  is 'Descripción del evento';
comment on column PCLUB.SYSFT_EVENTO.SYEVD_FECINI_EVENTO
  is 'Fecha inicial del evento';
comment on column PCLUB.SYSFT_EVENTO.SYEVD_FECFIN_EVENTO
  is 'Fecha final del evento';
comment on column PCLUB.SYSFT_EVENTO.SYEVV_PALABRA_CLAVE
  is 'Palabra clave del codigo de canje';
comment on column PCLUB.SYSFT_EVENTO.SYEVN_PUNTOSCLARO
  is 'Monto soles';
comment on column PCLUB.SYSFT_EVENTO.SYEVV_USUARIO_REG
  is 'Usuario que inserto el registro';
comment on column PCLUB.SYSFT_EVENTO.SYEVD_FEC_REG
  is 'Fecha de registro';
comment on column PCLUB.SYSFT_EVENTO.SYEVV_USUARIO_MOD
  is 'Usuario que actualizo el registro';
comment on column PCLUB.SYSFT_EVENTO.SYEVD_FEC_MOD
  is 'Fecha de modificación de registro';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.SYSFT_EVENTO
  add constraint PK_SYEVN_IDENTIFICADOR primary key (SYEVN_IDENTIFICADOR)
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
alter table PCLUB.SYSFT_EVENTO
  add constraint FK_ADMPV_ID_PROCLA foreign key (ADMPV_ID_PROCLA)
  references PCLUB.ADMPT_PREMIO (ADMPV_ID_PROCLA);
alter table PCLUB.SYSFT_EVENTO
  add constraint FK_SYCAN_IDENTIFICADOR foreign key (SYCAN_IDENTIFICADOR)
  references PCLUB.SYSFT_CAMPANA (SYCAN_IDENTIFICADOR); 


-- Create table
create table PCLUB.SYSFT_COD_CANJE
(
  SYCCN_IDENTIFICADOR NUMBER not null,
  SYEVN_IDENTIFICADOR NUMBER not null,
  SYCCC_ESTADO        CHAR(1) not null,
  SYCCV_CODIGO_CANJE  VARCHAR2(30) not null,
  SYCCV_USUARIO_REG   VARCHAR2(30) not null,
  SYCCD_FEC_REG       DATE not null,
  SYCCV_USUARIO_MOD   VARCHAR2(30),
  SYCCD_FEC_MOD       DATE,
  SYCCV_DESC_TIPODOC  VARCHAR2(30),
  SYCCV_NUMDOC        VARCHAR2(30),
  SYCCV_NOMBRE_TIT    VARCHAR2(80),
  SYCCV_LINEA         VARCHAR2(63),
  SYCCV_TIPO_PROD     VARCHAR2(30)
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
-- Add comments to the columns 
comment on column PCLUB.SYSFT_COD_CANJE.SYCCN_IDENTIFICADOR
  is 'Id unico del registro';
comment on column PCLUB.SYSFT_COD_CANJE.SYEVN_IDENTIFICADOR
  is 'Identificador de la tabla PCLUB.SYSFT_EVENTO';
comment on column PCLUB.SYSFT_COD_CANJE.SYCCC_ESTADO
  is 'Estado actual del codigo: ACTIVO=0, BLOQUEADO=1, VENCIDO=2';
comment on column PCLUB.SYSFT_COD_CANJE.SYCCV_CODIGO_CANJE
  is 'Codigo para realizar el canje ';
comment on column PCLUB.SYSFT_COD_CANJE.SYCCV_USUARIO_REG
  is 'Usuario que inserto el registro';
comment on column PCLUB.SYSFT_COD_CANJE.SYCCD_FEC_REG
  is 'Fecha de registro';
comment on column PCLUB.SYSFT_COD_CANJE.SYCCV_USUARIO_MOD
  is 'Usuario que modifico el registro';
comment on column PCLUB.SYSFT_COD_CANJE.SYCCD_FEC_MOD
  is 'Fecha de modificación de registro';
comment on column PCLUB.SYSFT_COD_CANJE.SYCCV_DESC_TIPODOC
  is 'Descripcion del tipo de documento';
comment on column PCLUB.SYSFT_COD_CANJE.SYCCV_NUMDOC
  is 'Numero del documento';
comment on column PCLUB.SYSFT_COD_CANJE.SYCCV_NOMBRE_TIT
  is 'Nombre del titular';
comment on column PCLUB.SYSFT_COD_CANJE.SYCCV_LINEA
  is 'Linea';
comment on column PCLUB.SYSFT_COD_CANJE.SYCCV_TIPO_PROD
  is 'Tipo de Producto (Prepago, Postago, etc)';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.SYSFT_COD_CANJE
  add constraint PK_SYCCN_IDENTIFICADOR primary key (SYCCN_IDENTIFICADOR)
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
alter table PCLUB.SYSFT_COD_CANJE
  add constraint UQ_SYSFT_COD_CANJE_001 unique (SYEVN_IDENTIFICADOR, SYCCV_CODIGO_CANJE)
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
alter table PCLUB.SYSFT_COD_CANJE
  add constraint FK0_SYEVN_IDENTIFICADOR foreign key (SYEVN_IDENTIFICADOR)
  references PCLUB.SYSFT_EVENTO (SYEVN_IDENTIFICADOR);
  

