CREATE TABLE PCLUB.ADMPT_TMP_VTOBONO
(
  ADMPV_COD_CLI VARCHAR2(40) not null,
  ADMPN_TIP_PRE NUMBER not null,
  ADMPV_COD_CTO NUMBER not null,
  ADMPN_SLD_PTO NUMBER,
  ADMPC_EST_BON NUMBER,
  ADMPC_TYP_BON VARCHAR2(20),
  ADMPV_USU_REG VARCHAR2(20),
  ADMPD_FEC_REG DATE,
  ADMPV_USU_MOD VARCHAR2(20),
  ADMPD_FEC_MOD DATE
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

	
CREATE TABLE PCLUB.ADMPT_TMP_FIDELIDAD
(
  ADMPV_COD_CLI VARCHAR2(40) not null,
  ADMPN_TIP_PRE NUMBER not null,
  ADMPV_COD_CTO NUMBER not null,
  ADMPN_SLD_PTO NUMBER,
  ADMPN_PROCESO NUMBER,
  ADMPC_EST_REG CHAR(1),
  ADMPV_USU_REG VARCHAR2(20),
  ADMPD_FEC_REG DATE
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
	
	
-- ADD/MODIFY COLUMNS PCLUB.ADMPT_BONO
ALTER TABLE PCLUB.ADMPT_BONO ADD ADMPV_TYPEBONO VARCHAR2(2);
	
-- ADD COMMENTS TO THE COLUMNS 
comment on column PCLUB.ADMPT_TMP_VTOBONO.ADMPV_COD_CLI   is 'Referencia a una linea telefonica o codigo de cliente a dar de baja los bonos';
comment on column PCLUB.ADMPT_TMP_VTOBONO.ADMPN_TIP_PRE	  is 'Referencia al tipo de premio que puede hacer canje este bono';
comment on column PCLUB.ADMPT_TMP_VTOBONO.ADMPV_COD_CTO	  is 'Referencia al tipo de bono a dar de baja que puede ser de fidelidad o no fidelidad';
comment on column PCLUB.ADMPT_TMP_VTOBONO.ADMPN_SLD_PTO	  is 'Referencia a la cantidad de puntos a dar de baja';
comment on column PCLUB.ADMPT_TMP_VTOBONO.ADMPC_EST_BON	  is 'Referencia al estado que se encuentra el bono';
comment on column PCLUB.ADMPT_TMP_VTOBONO.ADMPC_TYP_BON	  is 'Referencia al tipo de Bono a dar de Baja';
comment on column PCLUB.ADMPT_TMP_VTOBONO.ADMPV_USU_REG	  is 'Referencia al usuario que registra la transaccion';
comment on column PCLUB.ADMPT_TMP_VTOBONO.ADMPD_FEC_REG	  is 'Referencia a la fecha de creacion de la transaccion';
comment on column PCLUB.ADMPT_TMP_VTOBONO.ADMPV_USU_MOD	  is 'Referencia al usuario que modifica la transaccion';
comment on column PCLUB.ADMPT_TMP_VTOBONO.ADMPD_FEC_MOD	  is 'Referencia al usuario que modifica la transaccion';

-- ADD COMMENTS TO THE COLUMNS 
comment on column PCLUB.ADMPT_BONO.ADMPV_TYPEBONO  is 'Referencia al tipo de Bono (F) Fidelizacion';


create table PCLUB.ADMPT_IMP_VTOBONO
(
  admpv_cod_cli VARCHAR2(40) not null,
  admpn_tip_pre NUMBER not null,
  admpv_cod_cto NUMBER not null,
  admpn_sld_pto NUMBER,
  admpc_est_bon NUMBER,
  admpc_typ_bon VARCHAR2(20),
  admpv_usu_reg VARCHAR2(20),
  admpd_fec_reg DATE,
  admpv_usu_mod VARCHAR2(20),
  admpd_fec_mod DATE
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
comment on column PCLUB.ADMPT_IMP_VTOBONO.admpv_cod_cli
  is 'Referencia a una linea telefonica o codigo de cliente a dar de baja los bonos';
comment on column PCLUB.ADMPT_IMP_VTOBONO.admpn_tip_pre
  is 'Referencia al tipo de premio que puede hacer canje este bono';
comment on column PCLUB.ADMPT_IMP_VTOBONO.admpv_cod_cto
  is 'Referencia al tipo de bono a dar de baja que puede ser de fidelidad o no fidelidad';
comment on column PCLUB.ADMPT_IMP_VTOBONO.admpn_sld_pto
  is 'Referencia a la cantidad de puntos a dar de baja';
comment on column PCLUB.ADMPT_IMP_VTOBONO.admpc_est_bon
  is 'Referencia al estado que se encuentra el bono';
comment on column PCLUB.ADMPT_IMP_VTOBONO.admpc_typ_bon
  is 'Referencia al tipo de Bono a dar de Baja';
comment on column PCLUB.ADMPT_IMP_VTOBONO.admpv_usu_reg
  is 'Referencia al usuario que registra la transaccion';
comment on column PCLUB.ADMPT_IMP_VTOBONO.admpd_fec_reg
  is 'Referencia a la fecha de creacion de la transaccion';
comment on column PCLUB.ADMPT_IMP_VTOBONO.admpv_usu_mod
  is 'Referencia al usuario que modifica la transaccion';
comment on column PCLUB.ADMPT_IMP_VTOBONO.admpd_fec_mod
  is 'Referencia al usuario que modifica la transaccion';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_IMP_VTOBONO
  add constraint PK_VTOBONO_01 primary key (ADMPV_COD_CLI, ADMPN_TIP_PRE, ADMPV_COD_CTO)
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