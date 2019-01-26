-- Create table Aux
create table pclub.ADMPT_AUX_CARGAMICLARO
(
  ADMPV_TIPO_DOC VARCHAR2(20),
  ADMPV_NUM_DOC  VARCHAR2(20),
  ADMPV_MSISDN   VARCHAR2(20),
  ADMPD_FECHA    DATE
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

-- Create table IMP
create table pclub.ADMPT_IMP_CARGAMICLARO
(
  ADMPV_TIPO_DOC  VARCHAR2(20),
  ADMPV_NUM_DOC   VARCHAR2(20),
  ADMPV_MSISDN    VARCHAR2(20),
  ADMPD_FEC_OPER  DATE,
  ADMPN_COD_ERROR NUMBER
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
  
-- Create table
create table pclub.ADMPT_ERRORES_CC
(
  ADMPN_COD_ERROR NUMBER not null,
  ADMPV_DES_ERROR VARCHAR2(200)
)
tablespace PCLUB_DATA
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 8K
    minextents 1
    maxextents unlimited
  );
-- Create/Recreate primary, unique and foreign key constraints 
alter table pclub.ADMPT_ERRORES_CC
  add constraint K_COD_ERROR primary key (ADMPN_COD_ERROR)
  using index 
  tablespace PCLUB_DATA
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