-- Create table
create table PCLUB.TMP_DESAFILI_PRE
(
  ADMPV_COD_CLI VARCHAR2(40)
)
tablespace PCLUB_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
  
-- Create table
create table PCLUB.ADMPT_TMP_PREDESAFIL_NORECAR
(
  ADMPN_SEC        NUMBER not null,
  ADMPV_NOMARCHIVO VARCHAR2(50) not null,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPV_MSJE_ERROR VARCHAR2(400),
  ADMPD_FEC_OPER   DATE,
  ADMPD_FEC_REG    DATE,
  ADMPN_CATEGORIA  NUMBER default (-1),
  ESPRE            NUMBER default (0),
  ADMPV_CODERROR   VARCHAR2(10) default ('-1'),
  ADMPC_ESTADO     CHAR(1) default ('N')
)
tablespace PCLUB_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
  