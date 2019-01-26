-- Create table
create table PCLUB.ADMPT_AUX_PREPOSPRE
(
  ADMPN_ID_FILA     NUMBER,
  ADMPV_COD_CLI    	VARCHAR2(40),
  ADMPD_FEC_MIG 	DATE,
  ADMPD_FEC_OPER    DATE,
  ADMPV_TELEFONO VARCHAR2(40)
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

-- Create table
create table PCLUB.ADMPT_AUX_PREPREPOS
(
  ADMPN_ID_FILA     NUMBER,
  ADMPV_COD_CLI    	VARCHAR2(40),
  ADMPD_FEC_MIG 	DATE,
  ADMPD_FEC_OPER    DATE,
  ADMPV_CUENTA	    VARCHAR2(100)
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

--TABLE ADMPT_IMP_PREPOSPRE
ALTER TABLE PCLUB.ADMPT_IMP_PREPOSPRE ADD ADMPV_TELEFONO VARCHAR2(40);

--TABLE ADMPT_IMP_PREPREPOS
ALTER TABLE PCLUB.ADMPT_IMP_PREPREPOS ADD ADMPV_CUENTA VARCHAR2(100);