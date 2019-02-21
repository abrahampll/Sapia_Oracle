-- Create table
create table PCLUB.ADMPT_PROC_CANJE
(
  ADMPV_IDPROC    VARCHAR2(20) not null,
  ADMPV_COD_TPOCL VARCHAR2(2) not null,
  ADMPV_PRIORIDAD NUMBER,
  ADMV_USR_REG    VARCHAR2(40),
  ADMV_USR_MOD    VARCHAR2(40),
  ADMD_FEC_REG    DATE,
  ADMD_FEC_MOD    DATE
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
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_PROC_CANJE
  add constraint PK_ADMPT_PROC_CANJE primary key (ADMPV_IDPROC, ADMPV_COD_TPOCL)
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