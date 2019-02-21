-- Create table
create table USPROCPCLUB.tmp_procpp_BIR
(
  CODPROMO VARCHAR2(5),
  MSISDN VARCHAR2(20)
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
