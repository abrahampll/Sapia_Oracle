-- Create table
create table PCLUB.SYSFT_LATAM_PLANES_MILLAS
(
  SYLPMN_IDENTIFICADOR NUMBER not null,
  SYLCN_IDENTIFICADOR  NUMBER not null,
  SYMPV_PLAN           VARCHAR2(50) not null,
  SYMPV_MODELO         VARCHAR2(50) not null,
  SYMPN_MILLAS         NUMBER not null,
  SYMPC_ESTADO         CHAR(1) not null,
  SYMPD_FEC_REG        DATE default SYSDATE,
  SYMPV_USU_REG        VARCHAR2(30),
  SYMPD_FEC_MOD        DATE,
  SYMPV_USU_MOD        VARCHAR2(30)
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
comment on column PCLUB.SYSFT_LATAM_PLANES_MILLAS.SYLPMN_IDENTIFICADOR
  is 'Id secuencial unico del registro';
comment on column PCLUB.SYSFT_LATAM_PLANES_MILLAS.SYLCN_IDENTIFICADOR
  is 'Id secuencial de la tabla SYSFT_LATAM_CAMPANA';
comment on column PCLUB.SYSFT_LATAM_PLANES_MILLAS.SYMPV_PLAN
  is 'Plan';
comment on column PCLUB.SYSFT_LATAM_PLANES_MILLAS.SYMPV_MODELO
  is 'Modelo de equipo';
comment on column PCLUB.SYSFT_LATAM_PLANES_MILLAS.SYMPN_MILLAS
  is 'Millas';
comment on column PCLUB.SYSFT_LATAM_PLANES_MILLAS.SYMPC_ESTADO
  is 'Estado de registro. A=ACTIVO; I=INACTIVO';
comment on column PCLUB.SYSFT_LATAM_PLANES_MILLAS.SYMPD_FEC_REG
  is 'Fecha de Registro';
comment on column PCLUB.SYSFT_LATAM_PLANES_MILLAS.SYMPV_USU_REG
  is 'Usuario de Registro';
comment on column PCLUB.SYSFT_LATAM_PLANES_MILLAS.SYMPD_FEC_MOD
  is 'Fecha de Registro modificado';
comment on column PCLUB.SYSFT_LATAM_PLANES_MILLAS.SYMPV_USU_MOD
  is 'Usuario de Registro modificado';
