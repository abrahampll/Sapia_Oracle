-- Create table
create table PCLUB.SYSFT_LATAM_ERROR_ACREDITA
(
  SYLEAN_ID      NUMBER not null,
  SYLEAV_COD_ERR VARCHAR2(10) not null,
  SYLEAV_DES_ERR VARCHAR2(300) not null,
  SYLEAC_EST     CHAR(1) default 'A' not null,
  SYLEAD_FEC_REG DATE default sysdate not null,
  SYLEAV_USU_REG VARCHAR2(10) not null,
  SYLEAD_FEC_MOD DATE,
  SYLEAV_USU_MOD VARCHAR2(10)
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
comment on column PCLUB.SYSFT_LATAM_ERROR_ACREDITA.SYLEAN_ID
  is 'Identificador unico de registro
';
comment on column PCLUB.SYSFT_LATAM_ERROR_ACREDITA.SYLEAV_COD_ERR
  is 'Codigo de error enviado por Latam
';
comment on column PCLUB.SYSFT_LATAM_ERROR_ACREDITA.SYLEAV_DES_ERR
  is 'Descripción de error enviado por Latam
';
comment on column PCLUB.SYSFT_LATAM_ERROR_ACREDITA.SYLEAC_EST
  is 'Estado de registro.A (Activo); I (Inactivo)
';
comment on column PCLUB.SYSFT_LATAM_ERROR_ACREDITA.SYLEAD_FEC_REG
  is 'Fecha de Registro
';
comment on column PCLUB.SYSFT_LATAM_ERROR_ACREDITA.SYLEAV_USU_REG
  is 'Usuario de Registro
';
comment on column PCLUB.SYSFT_LATAM_ERROR_ACREDITA.SYLEAD_FEC_MOD
  is 'Fecha de Modificación
';
comment on column PCLUB.SYSFT_LATAM_ERROR_ACREDITA.SYLEAV_USU_MOD
  is 'Usuario de Modificación
';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.SYSFT_LATAM_ERROR_ACREDITA
  add constraint PK_SLEA primary key (SYLEAN_ID)
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
