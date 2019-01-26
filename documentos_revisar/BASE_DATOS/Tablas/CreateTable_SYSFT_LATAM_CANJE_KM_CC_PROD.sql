-- Create table
create table PCLUB.SYSFT_LATAM_CANJE_KM_CC_PROD
(
  SYLCKCPN_ID_GRP_CANJE      NUMBER not null,
  SYLCKCPN_ITEM              NUMBER not null,
  SYLCKCPN_ID_CANJE          NUMBER,
  SYLCKCPV_TIPO_DOC          VARCHAR2(20),
  SYLCKCPV_NUM_DOC           VARCHAR2(20),
  SYLCKCPV_COD_TPOCL         VARCHAR2(2),
  SYLCKCPV_TIPO_CLI          VARCHAR2(20),
  SYLCKCPC_TBL_CLI           CHAR(1),
  SYLCKCPC_ESTADO            CHAR(1) default 'P',
  SYLCKCPD_FEC_REG           DATE default sysdate,
  SYLCKCPV_USU_REG           VARCHAR2(10),
  SYLCKCPD_FEC_MOD           DATE,
  SYLCKCPV_USU_MOD           VARCHAR2(10)
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
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC_PROD.SYLCKCPN_ID_GRP_CANJE
  is 'Identificador de Grupo de Canje
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC_PROD.SYLCKCPN_ITEM
  is 'Correlativo de Grupo
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC_PROD.SYLCKCPN_ID_CANJE
  is 'Identificador del Canje
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC_PROD.SYLCKCPV_TIPO_DOC
  is 'Tipo de Documento del Cliente
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC_PROD.SYLCKCPV_NUM_DOC
  is 'Numero de Documento del Cliente
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC_PROD.SYLCKCPV_COD_TPOCL
  is 'Codigo de Tipo de Cliente
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC_PROD.SYLCKCPV_TIPO_CLI
  is 'Descripción de Tipo de Cliente
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC_PROD.SYLCKCPC_TBL_CLI
  is 'TBL_CLI de tabla admpt_tipo_cliente (M Movil / F Fija)
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC_PROD.SYLCKCPC_ESTADO
  is 'Estado de registro: P (Pendiente); F (Finalizado)
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC_PROD.SYLCKCPD_FEC_REG
  is 'Fecha de Registro
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC_PROD.SYLCKCPV_USU_REG
  is 'Usuario de Registro
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC_PROD.SYLCKCPD_FEC_MOD
  is 'Fecha de Modificación
';
comment on column PCLUB.SYSFT_LATAM_CANJE_KM_CC_PROD.SYLCKCPV_USU_MOD
  is 'Usuario de Modificación
';
-- Create/Recreate indexes 
create index IDX_GRP on PCLUB.SYSFT_LATAM_CANJE_KM_CC_PROD (SYLCKCPN_ID_GRP_CANJE)
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
create index IDX_GRP_ITEM on PCLUB.SYSFT_LATAM_CANJE_KM_CC_PROD (SYLCKCPN_ID_GRP_CANJE, SYLCKCPN_ITEM)
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
  
