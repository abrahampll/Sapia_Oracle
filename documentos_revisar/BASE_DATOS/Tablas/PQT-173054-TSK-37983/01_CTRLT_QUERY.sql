create table PCLUB.CTRLT_QUERY
(
  CTRLB_QUERY    CLOB,
  CTRLN_FLAG     NUMBER,
  CTRLD_FECREG   DATE default SYSDATE,
  CTRLV_USUREG   VARCHAR2(30) default USER,
  CTRLV_SCNPRE   VARCHAR2(20),
  CTRLV_SCNPOST  VARCHAR2(20),
  CTRLV_TITULO   VARCHAR2(100),
  CTRLN_FLAGEXEC NUMBER,
  CTRLV_ESTADO   VARCHAR2(1)
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