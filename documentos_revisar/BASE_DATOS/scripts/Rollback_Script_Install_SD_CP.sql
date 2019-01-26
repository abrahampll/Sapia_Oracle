DROP TABLE PCLUB.ADMPT_TMP_ALTACLIENTESERV_SVR;
DROP TABLE PCLUB.ADMPT_TMP_BAJA_CC;
DROP TABLE PCLUB.ADMPT_IMP_BAJA_CC;

create table PCLUB.ADMPT_TMP_ALTACLIENTESERV_SVR
(
  ADMPN_SEQ         NUMBER,
  ADMPV_TIP_CLIENTE VARCHAR2(2),
  ADMPV_CUSTCODE    VARCHAR2(40),
  ADMPV_TIPO_SERV   VARCHAR2(20),
  ADMPD_FEC_OPER    DATE,
  ADMPV_NOM_ARCH    VARCHAR2(150),
  ADMPV_COD_ERROR   CHAR(3),
  ADMPV_MSJE_ERROR  VARCHAR2(400)
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

comment on column PCLUB.ADMPT_TMP_ALTACLIENTESERV_SVR.ADMPN_SEQ is 'Secuencial';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTESERV_SVR.ADMPV_TIP_CLIENTE is 'Tipo de Cliente';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTESERV_SVR.ADMPV_CUSTCODE is 'CustCode BSCS';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTESERV_SVR.ADMPV_TIPO_SERV is 'Tipo Servicio';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTESERV_SVR.ADMPD_FEC_OPER is 'Fecha Operación';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTESERV_SVR.ADMPV_NOM_ARCH is 'Nombre de archivo';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTESERV_SVR.ADMPV_COD_ERROR is 'Codigo de Error';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTESERV_SVR.ADMPV_MSJE_ERROR is 'Mensaje de Error';

create table PCLUB.ADMPT_TMP_BAJA_CC
(
  ADMPV_TIP_CLIENTE VARCHAR2(2),
  ADMPV_CUSTCODE    VARCHAR2(40),
  ADMPD_FEC_BAJA    DATE,
  ADMPD_FEC_OPER    DATE,
  ADMPV_NOM_ARCH    VARCHAR2(150),
  ADMPC_COD_ERROR   CHAR(3),
  ADMPV_MSJE_ERROR  VARCHAR2(400),
  ADMPN_SEQ         NUMBER
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
  
comment on column PCLUB.ADMPT_TMP_BAJA_CC.ADMPV_TIP_CLIENTE is 'Tipo Cliente';
comment on column PCLUB.ADMPT_TMP_BAJA_CC.ADMPV_CUSTCODE is 'CustCode';
comment on column PCLUB.ADMPT_TMP_BAJA_CC.ADMPD_FEC_BAJA is 'Fecha Baja';
comment on column PCLUB.ADMPT_TMP_BAJA_CC.ADMPD_FEC_OPER is 'Fecha Operación';
comment on column PCLUB.ADMPT_TMP_BAJA_CC.ADMPV_NOM_ARCH is 'Nombre del archivo';
comment on column PCLUB.ADMPT_TMP_BAJA_CC.ADMPC_COD_ERROR is 'Codigo de Error';
comment on column PCLUB.ADMPT_TMP_BAJA_CC.ADMPV_MSJE_ERROR is 'Mensaje de Error';
comment on column PCLUB.ADMPT_TMP_BAJA_CC.ADMPN_SEQ is 'Numero Sequencia';


create table PCLUB.ADMPT_IMP_BAJA_CC
(
  ADMPV_TIP_CLIENTE VARCHAR2(2),
  ADMPV_CUSTCODE    VARCHAR2(40),
  ADMPD_FEC_BAJA    DATE,
  ADMPD_FEC_OPER    DATE,
  ADMPV_NOM_ARCH    VARCHAR2(150),
  ADMPC_COD_ERROR   CHAR(3),
  ADMPV_MSJE_ERROR  VARCHAR2(400),
  ADMPN_SEQ         NUMBER
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
  
comment on column PCLUB.ADMPT_IMP_BAJA_CC.ADMPV_TIP_CLIENTE is 'Tipo Cliente';
comment on column PCLUB.ADMPT_IMP_BAJA_CC.ADMPV_CUSTCODE is 'CustCode';
comment on column PCLUB.ADMPT_IMP_BAJA_CC.ADMPD_FEC_BAJA is 'Fecha Baja';
comment on column PCLUB.ADMPT_IMP_BAJA_CC.ADMPD_FEC_OPER is 'Fecha Operación';
comment on column PCLUB.ADMPT_IMP_BAJA_CC.ADMPV_NOM_ARCH is 'Nombre del archivo';
comment on column PCLUB.ADMPT_IMP_BAJA_CC.ADMPC_COD_ERROR is 'Codigo de Error';
comment on column PCLUB.ADMPT_IMP_BAJA_CC.ADMPV_MSJE_ERROR is 'Mensaje de Error';
comment on column PCLUB.ADMPT_IMP_BAJA_CC.ADMPN_SEQ is 'Numero Sequencia';


CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_ACLIESERV_SVR_001 ON PCLUB.ADMPT_TMP_ALTACLIENTESERV_SVR (ADMPV_CUSTCODE)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_ACLIESERV_SVR_002 ON PCLUB.ADMPT_TMP_ALTACLIENTESERV_SVR (ADMPV_TIPO_SERV)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_ACLIESERV_SVR_003 ON PCLUB.ADMPT_TMP_ALTACLIENTESERV_SVR (ADMPD_FEC_OPER)
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
CREATE INDEX PCLUB.IX_ADMPT_TMP_ACLIESRV_SVR_002 ON PCLUB.ADMPT_TMP_ALTACLIENTESERV_SVR (ADMPV_TIP_CLIENTE, ADMPD_FEC_OPER)
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
CREATE INDEX PCLUB.IX_ADMPT_TMP_ALTACLIESERV_001 ON PCLUB.ADMPT_TMP_ALTACLIENTESERV_SVR (ADMPV_CUSTCODE||'_'||ADMPV_TIPO_SERV)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_BAJA_CC_001 ON PCLUB.ADMPT_TMP_BAJA_CC (ADMPV_MSJE_ERROR)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_BAJA_CC_002 ON PCLUB.ADMPT_TMP_BAJA_CC (ADMPD_FEC_OPER)
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
CREATE BITMAP INDEX PCLUB.IX_ADMPT_TMP_BAJA_CC_003 ON PCLUB.ADMPT_TMP_BAJA_CC (ADMPV_TIP_CLIENTE)
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
CREATE INDEX PCLUB.IX_ADMPT_TMP_BAJA_CC_004 ON PCLUB.ADMPT_TMP_BAJA_CC (ADMPV_CUSTCODE)
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


