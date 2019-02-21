-- Create table
create table PCLUB.SYSFT_LATAM_SOCIO
(
  SYLSN_IDENTIFICADOR  NUMBER not null,
  SYLSV_ID_SOCIO_LATAM VARCHAR2(50) not null,
  SYLSC_DIG_VERIFICA   CHAR(1) not null,
  SYLSV_APE_SOC        VARCHAR2(30) not null,
  SYLSV_NOM_SOC        VARCHAR2(30) not null,
  SYLSV_TIP_DOC_LATAM  VARCHAR2(20) not null,
  SYLSV_NUM_DOC        VARCHAR2(30) not null,
  SYLSC_ESTADO         CHAR(1) default 'A' not null,
  SYLSD_FEC_REG        DATE default sysdate not null,
  SYLSV_USU_REG        VARCHAR2(20) not null,
  SYLSD_FEC_MOD        DATE,
  SYLSV_USU_MOD        VARCHAR2(20)
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
comment on column PCLUB.SYSFT_LATAM_SOCIO.SYLSN_IDENTIFICADOR
  is 'Id secuencial unico del registro';
comment on column PCLUB.SYSFT_LATAM_SOCIO.SYLSV_ID_SOCIO_LATAM
  is 'Id socio Latam';
comment on column PCLUB.SYSFT_LATAM_SOCIO.SYLSC_DIG_VERIFICA
  is 'Digito verificador';
comment on column PCLUB.SYSFT_LATAM_SOCIO.SYLSV_APE_SOC
  is 'Apellido de Socio Latam
';
comment on column PCLUB.SYSFT_LATAM_SOCIO.SYLSV_NOM_SOC
  is 'Nombre de Socio Latam
';
comment on column PCLUB.SYSFT_LATAM_SOCIO.SYLSV_TIP_DOC_LATAM
  is 'Tipo de Documento Latam
';
comment on column PCLUB.SYSFT_LATAM_SOCIO.SYLSV_NUM_DOC
  is 'Numero de Documento
';
comment on column PCLUB.SYSFT_LATAM_SOCIO.SYLSC_ESTADO
  is 'Estado de registro.A (Activo); I (Inactivo)
';
comment on column PCLUB.SYSFT_LATAM_SOCIO.SYLSD_FEC_REG
  is 'Fecha de Registro
';
comment on column PCLUB.SYSFT_LATAM_SOCIO.SYLSV_USU_REG
  is 'Usuario de Registro
';
comment on column PCLUB.SYSFT_LATAM_SOCIO.SYLSD_FEC_MOD
  is 'Fecha de Modificación
';
comment on column PCLUB.SYSFT_LATAM_SOCIO.SYLSV_USU_MOD
  is 'Usuario de Modificación
';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.SYSFT_LATAM_SOCIO
  add constraint PK_SLS primary key (SYLSN_IDENTIFICADOR)
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
create index IDX_ID_SOC on PCLUB.SYSFT_LATAM_SOCIO (SYLSV_ID_SOCIO_LATAM)
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
create index IDX_TIPDOC_NUM_DOC on PCLUB.SYSFT_LATAM_SOCIO (SYLSV_TIP_DOC_LATAM, SYLSV_NUM_DOC)
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
