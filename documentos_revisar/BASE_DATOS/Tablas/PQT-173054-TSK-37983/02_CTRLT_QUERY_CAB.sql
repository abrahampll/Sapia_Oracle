create table PCLUB.CTRLT_QUERY_CAB
(
  CTRLV_CAMPO  VARCHAR2(100),
  CTRLV_NOMBRE VARCHAR2(100),
  CTRLN_FLAG   NUMBER,
  CTRLN_ORDEN  NUMBER,
  CTRLV_USUREG VARCHAR2(30) default USER,
  CTRLD_FECREG DATE default SYSDATE
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