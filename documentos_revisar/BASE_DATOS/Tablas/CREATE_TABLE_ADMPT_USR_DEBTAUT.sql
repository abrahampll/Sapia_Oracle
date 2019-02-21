-- Create table
create table PCLUB.ADMPT_USR_DEBTAUT
( 
  USR_DEBTAUT_ID NUMBER,
  ADMPV_COD_CLI  VARCHAR2(40),
  USER_REG       VARCHAR2(10),
  FEC_REG        DATE,
  USER_MOD       VARCHAR2(10),
  FEC_MOD        DATE  
)
TABLESPACE PCLUB_DATA
PCTUSED    40
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           );
    
-- Add comments to the columns 
comment on column PCLUB.ADMPT_USR_DEBTAUT.ADMPV_COD_CLI
  is 'Codigo de Cliente';
comment on column PCLUB.ADMPT_USR_DEBTAUT.USER_REG
  is 'Usuario registrador';
comment on column PCLUB.ADMPT_USR_DEBTAUT.FEC_REG
  is 'Fecha de registro';
comment on column PCLUB.ADMPT_USR_DEBTAUT.USER_MOD
  is 'Usuario modificador';
comment on column PCLUB.ADMPT_USR_DEBTAUT.FEC_MOD
  is 'Fecha de modificacion';
comment on column PCLUB.ADMPT_USR_DEBTAUT.USR_DEBTAUT_ID
  is 'Correlativo';
  
alter table PCLUB.ADMPT_USR_DEBTAUT
  add constraint PK_USR_DEBTAUT_ID primary key (USR_DEBTAUT_ID)
  using index 
  TABLESPACE PCLUB_INDX
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
  
  CREATE INDEX PCLUB.IDX_CLI_DEBTAUT ON PCLUB.ADMPT_USR_DEBTAUT(ADMPV_COD_CLI)
      TABLESPACE PCLUB_INDX
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