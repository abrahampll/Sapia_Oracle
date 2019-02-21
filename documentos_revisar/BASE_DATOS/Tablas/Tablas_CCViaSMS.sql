-- Create table
create table PCLUB.ADMPT_REGCLIENTECC
(
  admpn_id_reg     NUMBER not null,
  admpv_cod_cli    VARCHAR2(40),
  admpd_fech_envio DATE,
  admpv_resultado  VARCHAR2(10),
  admpv_mensaje    VARCHAR2(2000),
  admpd_fec_reg    DATE,
  admpv_usu_reg    VARCHAR2(40),
  admpd_fec_mod    DATE,
  admpv_usu_mod    VARCHAR2(40)
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
alter table PCLUB.ADMPT_REGCLIENTECC
  add primary key (admpn_id_reg)
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

------------------------------------

-- Create table
create table PCLUB.ADMPT_IMP_CCVIASMS
(
  ADMPV_TIPO_DOC    VARCHAR2(20),
  ADMPV_NUM_DOC     VARCHAR2(20),
  ADMPV_MSISDN      VARCHAR2(20),
  ADMPV_MSJE_ERROR  VARCHAR2(200),
  ADMPV_USER_REG    VARCHAR2(20),
  ADMPD_FEC_REG     DATE,
  ADMPN_CORRELATIVO NUMBER
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