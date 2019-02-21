-- Create table
create table PCLUB.ADMPT_KARDEX_ALL
(
  ADMPN_ID_KARDEX    NUMBER not null,
  ADMPN_COD_CLI_CONV VARCHAR2(40) not null,
  ADMPV_COD_CLI_PROD VARCHAR2(40) not null,
  ADMPV_COD_CPTO     VARCHAR2(3),
  ADMPD_FEC_TRANS    DATE,
  ADMPN_PUNTOS       NUMBER,
  ADMPV_NOM_ARCH     VARCHAR2(150),
  ADMPC_TPO_OPER     CHAR(1),
  ADMPC_TPO_PUNTO    CHAR(1),
  ADMPN_SLD_PUNTO    NUMBER,
  ADMPC_ESTADO       CHAR(1),
  ADMPV_IDTRANSLOY   VARCHAR2(18),
  ADMPD_FEC_REG      DATE,
  ADMPD_FEC_MOD      DATE,
  ADMPV_DESC_PROM    VARCHAR2(200),
  ADMPN_TIP_PREMIO   NUMBER,
  ADMPD_FEC_VCMTO    DATE,
  ADMPV_USU_REG      VARCHAR2(20),
  ADMPV_USU_MOD      VARCHAR2(20)
)
tablespace PCLUB_DATA
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Add comments to the columns 
comment on column PCLUB.ADMPT_KARDEX_ALL.ADMPN_ID_KARDEX
  is 'Id del Kardex';
comment on column PCLUB.ADMPT_KARDEX_ALL.ADMPN_COD_CLI_CONV
  is 'Código de cliente por convenio';
comment on column PCLUB.ADMPT_KARDEX_ALL.ADMPV_COD_CLI_PROD
  is 'Código de cliente por producto';
comment on column PCLUB.ADMPT_KARDEX_ALL.ADMPV_COD_CPTO
  is 'Código de concepto';
comment on column PCLUB.ADMPT_KARDEX_ALL.ADMPD_FEC_TRANS
  is 'Fecha de transacción';
comment on column PCLUB.ADMPT_KARDEX_ALL.ADMPN_PUNTOS
  is 'puntos (entrada / salida)';
comment on column PCLUB.ADMPT_KARDEX_ALL.ADMPV_NOM_ARCH
  is 'Nombre de archivo';
comment on column PCLUB.ADMPT_KARDEX_ALL.ADMPC_TPO_OPER
  is 'Tipo de operación';
comment on column PCLUB.ADMPT_KARDEX_ALL.ADMPC_TPO_PUNTO
  is 'Tipo de punto';
comment on column PCLUB.ADMPT_KARDEX_ALL.ADMPN_SLD_PUNTO
  is 'Saldo de puntos';
comment on column PCLUB.ADMPT_KARDEX_ALL.ADMPC_ESTADO
  is 'Estado del punto';
comment on column PCLUB.ADMPT_KARDEX_ALL.ADMPV_IDTRANSLOY
  is 'Id de la transacción en loyalti';
comment on column PCLUB.ADMPT_KARDEX_ALL.ADMPD_FEC_REG
  is 'Fecha de registro';
comment on column PCLUB.ADMPT_KARDEX_ALL.ADMPD_FEC_MOD
  is 'Fecha de modificación';
comment on column PCLUB.ADMPT_KARDEX_ALL.ADMPV_DESC_PROM
  is 'Descripción de la promoción';
comment on column PCLUB.ADMPT_KARDEX_ALL.ADMPN_TIP_PREMIO
  is 'Tipo de premio';
comment on column PCLUB.ADMPT_KARDEX_ALL.ADMPD_FEC_VCMTO
  is 'Fecha de vencimiento';
comment on column PCLUB.ADMPT_KARDEX_ALL.ADMPV_USU_REG
  is 'Usuario que registra';
comment on column PCLUB.ADMPT_KARDEX_ALL.ADMPV_USU_MOD
  is 'Usuario que modifica';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_KARDEX_ALL
  add constraint PK_ADMPT_KARDEX_ALL primary key (ADMPN_ID_KARDEX)
  using index 
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
