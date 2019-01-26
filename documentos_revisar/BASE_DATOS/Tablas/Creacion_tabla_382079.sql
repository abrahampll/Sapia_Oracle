-- Create table
create table PCLUB.ADMPT_ALINEACION_PREP
(
  FECHA DATE
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
create table PCLUB.TMP_CLI_ALL
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
create table PCLUB.TMP_CLI_NOEXISTE_SALDO
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
create table PCLUB.ADMPT_KARDEX_CLIE
(
  ADMPV_COD_CLI VARCHAR2(40),
  ADMPV_SALDO_K NUMBER default 0
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
create table PCLUB.ADMPT_CLIE_ALIN_PREP
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
  