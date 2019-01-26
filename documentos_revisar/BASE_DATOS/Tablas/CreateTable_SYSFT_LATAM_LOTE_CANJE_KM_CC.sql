-- Create table
create table PCLUB.SYSFT_LATAM_LOTE_CANJE_KM_CC
(
  SYLLCKCN_ID_LOTE       NUMBER not null,
  SYLLCKCC_TIP_REG_LATAM CHAR(1) default '1',
  SYLLCKCV_ID_COMPANY    VARCHAR2(5),
  SYLLCKCV_ID_ARCHIVO    VARCHAR2(9),
  SYLLCKCV_FEC_CREA_ARCH VARCHAR2(15) default to_char(sysdate, 'yyyymmdd hh24miss'),
  SYLLCKCD_FEC_CREA_ARCH DATE default sysdate,
  SYLLCKCN_CANT_REG      NUMBER,
  SYLLCKCN_CANT_REG_RET  NUMBER,
  SYLLCKCV_NOM_ARCHIVO   VARCHAR2(30),
  SYLLCKCC_ESTADO        CHAR(1) default 'P',
  SYLLCKCC_EST           CHAR(1) default 'A',
  SYLLCKCD_FEC_REG       DATE default sysdate,
  SYLLCKCV_USU_REG       VARCHAR2(10),
  SYLLCKCD_FEC_MOD       DATE,
  SYLLCKCV_USU_MOD       VARCHAR2(10)
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
comment on column PCLUB.SYSFT_LATAM_LOTE_CANJE_KM_CC.SYLLCKCN_ID_LOTE
  is 'Identificador de Lote
';
comment on column PCLUB.SYSFT_LATAM_LOTE_CANJE_KM_CC.SYLLCKCC_TIP_REG_LATAM
  is 'Valor del Tipo de Registro Latam
';
comment on column PCLUB.SYSFT_LATAM_LOTE_CANJE_KM_CC.SYLLCKCV_ID_COMPANY
  is 'Código que identifica la compañía socia entregado por Latam
';
comment on column PCLUB.SYSFT_LATAM_LOTE_CANJE_KM_CC.SYLLCKCV_ID_ARCHIVO
  is 'Identificador de archivo, XYZCR0001(primeros 3 dígitos  corresponden a los últimos caracteres del Company ID y los últimos dígitos son el correlativo correspondiente al nombre del archivo).
';
comment on column PCLUB.SYSFT_LATAM_LOTE_CANJE_KM_CC.SYLLCKCV_FEC_CREA_ARCH
  is 'Fecha Creacion Archivo en string
';
comment on column PCLUB.SYSFT_LATAM_LOTE_CANJE_KM_CC.SYLLCKCD_FEC_CREA_ARCH
  is 'Fecha Creacion Archivo en date
';
comment on column PCLUB.SYSFT_LATAM_LOTE_CANJE_KM_CC.SYLLCKCN_CANT_REG
  is 'Cantidad de registros que van en el archivo
';
comment on column PCLUB.SYSFT_LATAM_LOTE_CANJE_KM_CC.SYLLCKCN_CANT_REG_RET
  is 'Cantidad de registros que retorna LATAM
';
comment on column PCLUB.SYSFT_LATAM_LOTE_CANJE_KM_CC.SYLLCKCV_NOM_ARCHIVO
  is 'Nombre del archivo
';
comment on column PCLUB.SYSFT_LATAM_LOTE_CANJE_KM_CC.SYLLCKCC_ESTADO
  is 'Estado del archivo: P (Pendiente); E (Enviado); F (Finalizado)
';
comment on column PCLUB.SYSFT_LATAM_LOTE_CANJE_KM_CC.SYLLCKCC_EST
  is 'Estado de registro.A (Activo); I (Inactivo)
';
comment on column PCLUB.SYSFT_LATAM_LOTE_CANJE_KM_CC.SYLLCKCD_FEC_REG
  is 'Fecha de Registro
';
comment on column PCLUB.SYSFT_LATAM_LOTE_CANJE_KM_CC.SYLLCKCV_USU_REG
  is 'Usuario de Registro
';
comment on column PCLUB.SYSFT_LATAM_LOTE_CANJE_KM_CC.SYLLCKCD_FEC_MOD
  is 'Fecha de Modificación
';
comment on column PCLUB.SYSFT_LATAM_LOTE_CANJE_KM_CC.SYLLCKCV_USU_MOD
  is 'Usuario de Modificación
';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.SYSFT_LATAM_LOTE_CANJE_KM_CC
  add constraint PK_SLLCKC primary key (SYLLCKCN_ID_LOTE)
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
create index IDX_IDLOT_EST on PCLUB.SYSFT_LATAM_LOTE_CANJE_KM_CC (SYLLCKCN_ID_LOTE, SYLLCKCC_ESTADO)
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
