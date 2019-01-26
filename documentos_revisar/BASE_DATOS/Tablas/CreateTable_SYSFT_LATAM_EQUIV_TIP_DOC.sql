-- Create table
create table PCLUB.SYSFT_LATAM_EQUIV_TIP_DOC
(
  SYLEN_IDENTIFICADOR  NUMBER not null,
  SYLEV_ID_TIPO_DOC_CC VARCHAR2(15) not null,
  SYLEV_TIPO_DOC_LATAM VARCHAR2(15) not null,
  SYLEV_DESC_DOC_LATAM VARCHAR2(15) not null,
  SYLEC_EST            CHAR(1) default 'A' not null,
  SYLED_FEC_REG        DATE default SYSDATE not null,
  SYLEV_USU_REG        VARCHAR2(10) not null,
  SYLED_FEC_MOD        DATE,
  SYLEV_USU_MOD        VARCHAR2(10)
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
comment on column PCLUB.SYSFT_LATAM_EQUIV_TIP_DOC.SYLEN_IDENTIFICADOR
  is 'Id unico del registro
';
comment on column PCLUB.SYSFT_LATAM_EQUIV_TIP_DOC.SYLEV_ID_TIPO_DOC_CC
  is 'Tipo de documento de claro club Tabla referencia
';
comment on column PCLUB.SYSFT_LATAM_EQUIV_TIP_DOC.SYLEV_TIPO_DOC_LATAM
  is 'Tipo de documento de claro club
';
comment on column PCLUB.SYSFT_LATAM_EQUIV_TIP_DOC.SYLEV_DESC_DOC_LATAM
  is 'Descripcion de tipo de documento 
';
comment on column PCLUB.SYSFT_LATAM_EQUIV_TIP_DOC.SYLEC_EST
  is 'Estado de registro.A (Activo); I (Inactivo)
';
comment on column PCLUB.SYSFT_LATAM_EQUIV_TIP_DOC.SYLED_FEC_REG
  is 'Fecha de Registro
';
comment on column PCLUB.SYSFT_LATAM_EQUIV_TIP_DOC.SYLEV_USU_REG
  is 'Usuario de Registro
';
comment on column PCLUB.SYSFT_LATAM_EQUIV_TIP_DOC.SYLED_FEC_MOD
  is 'Fecha de Modificación
';
comment on column PCLUB.SYSFT_LATAM_EQUIV_TIP_DOC.SYLEV_USU_MOD
  is 'Usuario de Modificación
';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.SYSFT_LATAM_EQUIV_TIP_DOC
  add constraint PK_SLETD primary key (SYLEN_IDENTIFICADOR)
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
-- Create/Recreate indexes 
create index IDX_TIP_DOC on PCLUB.SYSFT_LATAM_EQUIV_TIP_DOC (SYLEV_ID_TIPO_DOC_CC)
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
