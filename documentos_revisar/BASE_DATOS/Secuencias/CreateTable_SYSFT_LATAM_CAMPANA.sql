-- Create table
create table PCLUB.SYSFT_LATAM_CAMPANA
(
  SYLCN_IDENTIFICADOR NUMBER,
  SYLCV_COD_CAMPANA   VARCHAR2(20),
  SYLCV_DESCRIPCION   VARCHAR2(100),
  SYLCD_FECHA_INI     DATE,
  SYLCD_FECHA_FIN     DATE,
  SYLCC_ESTADO        CHAR(1),
  SYLCD_FEC_REG       DATE default SYSDATE,
  SYLCV_USU_REG       VARCHAR2(30),
  SYLCD_FEC_MOD       DATE,
  SYLCV_USU_MOD       VARCHAR2(30)
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
comment on column PCLUB.SYSFT_LATAM_CAMPANA.SYLCN_IDENTIFICADOR
  is 'Id secuencial unico del registro';
comment on column PCLUB.SYSFT_LATAM_CAMPANA.SYLCV_COD_CAMPANA
  is 'Codigo de la campaña';
comment on column PCLUB.SYSFT_LATAM_CAMPANA.SYLCV_DESCRIPCION
  is 'Descripcion de la campaña';
comment on column PCLUB.SYSFT_LATAM_CAMPANA.SYLCD_FECHA_INI
  is 'Fecha inicio de la campaña';
comment on column PCLUB.SYSFT_LATAM_CAMPANA.SYLCD_FECHA_FIN
  is 'Fecha fin de la campaña';
comment on column PCLUB.SYSFT_LATAM_CAMPANA.SYLCC_ESTADO
  is 'Estado de registro.A (Activo); I (Inactivo)';
comment on column PCLUB.SYSFT_LATAM_CAMPANA.SYLCD_FEC_REG
  is 'Fecha de Registro';
comment on column PCLUB.SYSFT_LATAM_CAMPANA.SYLCV_USU_REG
  is 'Usuario de Registro';
comment on column PCLUB.SYSFT_LATAM_CAMPANA.SYLCD_FEC_MOD
  is 'Fecha de Registro modificado';
comment on column PCLUB.SYSFT_LATAM_CAMPANA.SYLCV_USU_MOD
  is 'Usuario de Registro modificado';
