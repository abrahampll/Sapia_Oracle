-- Create table
create table PCLUB.SYSFT_LATAM_CANJE_KM_CC
(
  SYLCKCN_ID_CANJE      NUMBER not null,
  SYLCKCN_ID_LOTE       NUMBER,
  SYLCKCN_ID_GRP_CANJE  NUMBER,
  SYLCKCV_LINEA         VARCHAR2(20),
  SYLCKCV_CORREO        VARCHAR2(100),
  SYLCKCC_TIP_REG_LATAM CHAR(1) default 'C',
  SYLCKCV_NUMCTA_LATAM  VARCHAR2(20),
  SYLCKCV_ID_PROG_LATAM VARCHAR2(5),
  SYLCKCV_FEC_CANJE     VARCHAR2(15) default to_char(sysdate, 'yyyymmdd hh24miss'),
  SYLCKCD_FEC_CANJE     DATE default sysdate,
  SYLCKCN_KM_LATAM      NUMBER,
  SYLCKCN_CC            NUMBER,
  SYLCKCV_NOM_CLI       VARCHAR2(20),
  SYLCKCV_CTA_SOC_LATAM VARCHAR2(12),
  SYLCKCV_LOCATIONID    VARCHAR2(10),
  SYLCKCV_LOCATIONDESC  VARCHAR2(30),
  SYLCKCV_CORRELATIVO   VARCHAR2(12),
  SYLCKCV_DIAS          VARCHAR2(3),
  SYLCKCV_COD_APLI      VARCHAR2(3),
  SYLCKCV_TIPO_CANJE    CHAR(2),
  SYLCKCC_ESTADO        CHAR(1) default 'P',
  SYLCKCC_EST_CANJE     CHAR(1) default '0',
  SYLCKCV_COD_ERR_LATAM VARCHAR2(10),
  SYLEKCD_FEC_REG       DATE default sysdate,
  SYLEKCV_USU_REG       VARCHAR2(10),
  SYLEKCD_FEC_MOD       DATE,
  SYLEKCV_USU_MOD       VARCHAR2(10)
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
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCN_ID_CANJE
  is 'Sequencial unico
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCN_ID_LOTE
  is 'Identificador de Lote
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCN_ID_GRP_CANJE
  is 'Id de Grupo de Canje que se realizo en CC
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCV_LINEA
  is 'Linea de donde viene el canje 
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCV_CORREO
  is 'Correo de donde viene el canje (Mi Claro)
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCC_TIP_REG_LATAM
  is 'C = crédito
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCV_NUMCTA_LATAM
  is 'Vacio
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCV_ID_PROG_LATAM
  is 'Código de acumulación asignado por LAN
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCV_FEC_CANJE
  is 'Fecha del Canje en string
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCD_FEC_CANJE
  is 'Fecha del Canje en date
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCN_KM_LATAM
  is 'KM Latam a canjear
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCN_CC
  is 'Claro Puntos a canjear
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCV_NOM_CLI
  is 'Nombre de viajero frecuente (El formato debe APELLIDO/NOMBRE)
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCV_CTA_SOC_LATAM
  is 'Codigo Latam del cliente (incluir codigo verificador al final)
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCV_LOCATIONID
  is 'Vacio
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCV_LOCATIONDESC
  is 'Vacio
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCV_CORRELATIVO
  is 'Correlativo por Lote, completar con ceros (12 digitos)
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCV_DIAS
  is 'Vacio
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCV_COD_APLI
  is 'Codigo de Aplicativo que realiza el registro en la tabla
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCV_TIPO_CANJE
  is 'Tipo de registro: CK (de CC A KM); KC(de KM A CC)
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCC_ESTADO
  is 'Estado de registro: P (Pendiente); E (Enviado); F (Finalizado)
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCC_EST_CANJE
  is 'Estado de canje: 0 (OK); 1 (Error)
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLCKCV_COD_ERR_LATAM
  is 'Código error enviado por Latam
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLEKCD_FEC_REG
  is 'Fecha de Registro
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLEKCV_USU_REG
  is 'Usuario de Registro
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLEKCD_FEC_MOD
  is 'Fecha de Modificación
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC.SYLEKCV_USU_MOD
  is 'Usuario de Modificación
';
-- Create/Recreate indexes 
create index IDX_CORREO on PCLUB.SYSFT_LATAM_CANJE_KM_CC (SYLCKCV_CORREO)
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
create index IDX_EST on PCLUB.SYSFT_LATAM_CANJE_KM_CC (SYLCKCC_ESTADO)
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
create index IDX_EST_IDCNJ on PCLUB.SYSFT_LATAM_CANJE_KM_CC (SYLCKCC_ESTADO, SYLCKCN_ID_CANJE)
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
create index IDX_EST_TIPCNJ on PCLUB.SYSFT_LATAM_CANJE_KM_CC (SYLCKCC_ESTADO, SYLCKCV_TIPO_CANJE)
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
create index IDX_FEC on PCLUB.SYSFT_LATAM_CANJE_KM_CC (SYLCKCD_FEC_CANJE)
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
create index IDX_IDCNJ on PCLUB.SYSFT_LATAM_CANJE_KM_CC (SYLCKCN_ID_CANJE)
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
create index IDX_IDLOT on PCLUB.SYSFT_LATAM_CANJE_KM_CC (SYLCKCN_ID_LOTE)
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
create index IDX_IDLOT_TIPCNJ on PCLUB.SYSFT_LATAM_CANJE_KM_CC (SYLCKCN_ID_LOTE, SYLCKCV_TIPO_CANJE)
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
create index IDX_LIN on PCLUB.SYSFT_LATAM_CANJE_KM_CC (SYLCKCV_LINEA)
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
create index IDX_REP on PCLUB.SYSFT_LATAM_CANJE_KM_CC (SYLCKCV_TIPO_CANJE, SYLCKCV_LINEA, SYLCKCV_CORREO, SYLCKCD_FEC_CANJE, SYLCKCC_ESTADO, SYLCKCV_CTA_SOC_LATAM)
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
create index IDX_SOC on PCLUB.SYSFT_LATAM_CANJE_KM_CC (SYLCKCV_CTA_SOC_LATAM)
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
create index IDX_SOC_CC_FEC on PCLUB.SYSFT_LATAM_CANJE_KM_CC (SYLCKCV_CTA_SOC_LATAM, SYLCKCN_CC, SYLCKCD_FEC_CANJE)
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
create index IDX_SOC_KM_FEC on PCLUB.SYSFT_LATAM_CANJE_KM_CC (SYLCKCV_CTA_SOC_LATAM, SYLCKCN_KM_LATAM, SYLCKCD_FEC_CANJE)
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
create index IDX_TIPCNJ on PCLUB.SYSFT_LATAM_CANJE_KM_CC (SYLCKCV_TIPO_CANJE)
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
  
