-- Create table
create table PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO
(
  SYPEN_IDENTIFICADOR    NUMBER not null,
  SYPEV_LINEA            VARCHAR2(20),
  SYPEV_DOCUMENTO        VARCHAR2(30),
  SYPEV_PLAN_TARIFA_COD  VARCHAR2(30),
  SYPEV_PLAN_TARIFA_DESC VARCHAR2(50),
  SYPEV_TIPO_OPERACION   VARCHAR2(30),
  SYPEV_EQUIPO_COD       VARCHAR2(30),
  SYPEV_EQUIPO_DESC      VARCHAR2(50),
  SYPED_FEC_VENTA        DATE not null,
  SYPED_FEC_ACTIVACION   DATE,
  SYPEV_CAMPANA_COD      VARCHAR2(30),
  SYPEV_CAMPANA_DESC     VARCHAR2(50),
  SYPEV_LISTA_PRECIO     VARCHAR2(30),
  SYPEV_PRECIO_EQUIPO    VARCHAR2(30),
  SYPEV_REGION_ACTIV     VARCHAR2(30),
  SYPEV_DEP_ACTIV        VARCHAR2(50),
  SYPEV_CUSTOMERID       VARCHAR2(30),
  SYPEV_COID             VARCHAR2(80),
  SYPEV_NOMBRE_CLIENTE   VARCHAR2(500),
  SYPEN_MILLAS           NUMBER not null,
  SYPEC_ESTADO           CHAR(1) default 'P',
  SYPED_FEC_REG          DATE default SYSDATE not null,
  SYPEV_USU_REG          VARCHAR2(30) not null,
  SYPED_FEC_MOD          DATE,
  SYPEV_USU_MOD          VARCHAR2(30),
  SYLCN_IDENTIFICADOR    NUMBER
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
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPEN_IDENTIFICADOR
  is 'Id secuencial unico del registro';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPEV_LINEA
  is 'Numero de línea';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPEV_DOCUMENTO
  is 'Numero de documento';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPEV_PLAN_TARIFA_COD
  is 'Codigo de plan de tarifa';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPEV_PLAN_TARIFA_DESC
  is 'Descripcion de plan de tarifa';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPEV_TIPO_OPERACION
  is 'Tipo de Operación';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPEV_EQUIPO_COD
  is 'Codigo de equipo';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPEV_EQUIPO_DESC
  is 'Descripcion de equipo';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPED_FEC_VENTA
  is 'Fecha de venta';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPED_FEC_ACTIVACION
  is 'Fecha de activacion';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPEV_CAMPANA_COD
  is 'Codigo de campaña SAP';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPEV_CAMPANA_DESC
  is 'Descripcion de campaña SAP';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPEV_LISTA_PRECIO
  is 'Lista de precio';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPEV_PRECIO_EQUIPO
  is 'Precio equipo';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPEV_REGION_ACTIV
  is 'Region de activación';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPEV_DEP_ACTIV
  is 'Departamento de activación';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPEV_CUSTOMERID
  is 'Identificador de cliente';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPEV_COID
  is 'Codigo de contrato';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPEV_NOMBRE_CLIENTE
  is 'Nombre de cliente';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPEN_MILLAS
  is 'Millas';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPEC_ESTADO
  is 'Estado de registro.P (Pendiente); F (Finalizado)';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPED_FEC_REG
  is 'Fecha de Registro';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPEV_USU_REG
  is 'Usuario de Registro';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPED_FEC_MOD
  is 'Fecha de Registro modificado';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYPEV_USU_MOD
  is 'Usuario de Registro modificado';
comment on column PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO.SYLCN_IDENTIFICADOR
  is 'FK de la PK de la tabla SYSFT_LATAM_CAMPANA';
-- Create/Recreate indexes 
create unique index IDX_TELF_FEC on PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO (SYPEV_LINEA, TO_CHAR(SYPED_FEC_VENTA,'YYYYMMDD'), SYLCN_IDENTIFICADOR)
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
