create table PCLUB.ADMPT_TMP_ALTACLIENTE_SVR
(
  ADMPN_SEQ         NUMBER,
  ADMPV_TIP_CLIENTE VARCHAR2(2),
  ADMPV_CUSTCODE    VARCHAR2(40),
  ADMPV_TIPO_DOC    VARCHAR2(20),
  ADMPV_NUM_DOC     VARCHAR2(20),
  ADMPV_NOM_CLI     VARCHAR2(80),
  ADMPV_APE_CLI     VARCHAR2(80),
  ADMPC_SEXO        CHAR(1),
  ADMPV_EST_CIVIL   VARCHAR2(20),
  ADMPV_EMAIL       VARCHAR2(80),
  ADMPV_PROV        VARCHAR2(30),
  ADMPV_DEPA        VARCHAR2(40),
  ADMPV_DIST        VARCHAR2(200),
  ADMPD_FEC_ACT     DATE,
  ADMPV_CICL_FACT   VARCHAR2(20),
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

comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_SVR.ADMPN_SEQ is 'Secuencial';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_SVR.ADMPV_TIP_CLIENTE is 'Tipo de Cliente';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_SVR.ADMPV_CUSTCODE is 'CustCode BSCS';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_SVR.ADMPV_TIPO_DOC is 'Tipo Documento';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_SVR.ADMPV_NUM_DOC is 'Número Documento';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_SVR.ADMPV_NOM_CLI is 'Nombre del cliente';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_SVR.ADMPV_APE_CLI is 'Apellido del cliente';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_SVR.ADMPC_SEXO is 'Sexo';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_SVR.ADMPV_EST_CIVIL is 'Estado Civil';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_SVR.ADMPV_EMAIL is 'Email';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_SVR.ADMPV_PROV is 'Provincia';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_SVR.ADMPV_DEPA is 'Departamento';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_SVR.ADMPV_DIST is 'Distrito';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_SVR.ADMPD_FEC_ACT is 'Fecha Activación';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_SVR.ADMPV_CICL_FACT is 'Ciclo de Facturación';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_SVR.ADMPD_FEC_OPER is 'Fecha de Operación';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_SVR.ADMPV_NOM_ARCH is 'Nombre del archivo';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_SVR.ADMPV_COD_ERROR is 'Codigo de Error';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_SVR.ADMPV_MSJE_ERROR is 'Mensaje de Error';




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




create table PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR
(
  ADMPN_SEQ_SERV      NUMBER,
  ADMPV_TIP_CLIENTE   VARCHAR2(2),
  ADMPV_CUSTCODE      VARCHAR2(40),
  ADMPV_TIPO_DOC      VARCHAR2(20),
  ADMPV_NUM_DOC       VARCHAR2(20),
  ADMPV_NOM_CLI       VARCHAR2(80),
  ADMPV_APE_CLI       VARCHAR2(80),
  ADMPC_SEXO          CHAR(1),
  ADMPV_EST_CIVIL     VARCHAR2(20),
  ADMPV_EMAIL         VARCHAR2(80),
  ADMPV_PROV          VARCHAR2(30),
  ADMPV_DEPA          VARCHAR2(40),
  ADMPV_DIST          VARCHAR2(200),
  ADMPD_FEC_ACT       DATE,
  ADMPV_CICL_FACT     VARCHAR2(2),
  ADMPV_TIPO_SERV     VARCHAR2(20),
  ADMPV_COD_CLI       VARCHAR2(40),
  ADMPD_FEC_OPER      DATE,
  ADMPV_NOM_ARCH_CLI  VARCHAR2(150),
  ADMPV_NOM_ARCH_SERV VARCHAR2(150),
  ADMPV_COD_ERROR     CHAR(3),
  ADMPV_MSJE_ERROR    VARCHAR2(400)
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
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR.ADMPN_SEQ_SERV is 'Secuencial';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR.ADMPV_TIP_CLIENTE is 'Tipo Cliente';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR.ADMPV_CUSTCODE is 'CustCode';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR.ADMPV_TIPO_DOC is 'Tipo Documento';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR.ADMPV_NUM_DOC is 'Número Documento';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR.ADMPV_NOM_CLI is 'Nombre del cliente';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR.ADMPV_APE_CLI is 'Apellido del Cliente';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR.ADMPC_SEXO is 'Sexo';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR.ADMPV_EST_CIVIL is 'Estado Civil';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR.ADMPV_EMAIL is 'Email';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR.ADMPV_PROV is 'Provincia';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR.ADMPV_DEPA is 'Departamento';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR.ADMPV_DIST is 'Distrito';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR.ADMPD_FEC_ACT is 'Fecha Activación';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR.ADMPV_CICL_FACT is 'Ciclo de Facturación';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR.ADMPV_TIPO_SERV is 'Tipo de servicio';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR.ADMPV_COD_CLI is 'Código del cliente';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR.ADMPD_FEC_OPER is 'Fecha Operación';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR.ADMPV_NOM_ARCH_CLI is 'Nombre del archivo del cliente ';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR.ADMPV_NOM_ARCH_SERV is 'Nombre del archivo del servicio';  
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR.ADMPV_COD_ERROR is 'Codigo de Error';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_SVR.ADMPV_MSJE_ERROR is 'Mensaje de Error';




create table PCLUB.ADMPT_TMP_PAGO_FACT
(
  ADMPV_TIP_CLIENTE VARCHAR2(2),
  ADMPV_CUSTCODE    VARCHAR2(40),
  ADMPV_TIPO_SERV   VARCHAR2(4),
  ADMPV_PERIODO_ANIO VARCHAR2(4),
  ADMPV_PERIODO_MES  VARCHAR2(2),
  ADMPN_MNT_CGOFIJ  NUMBER,
  ADMPN_DIAS_VENC   NUMBER,
  ADMPD_FEC_OPER    DATE,
  ADMPV_NOM_ARCH    VARCHAR2(150),
  ADMPN_PUNTOS      NUMBER,
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
comment on column PCLUB.ADMPT_TMP_PAGO_FACT.ADMPV_TIP_CLIENTE is 'Tipo Cliente';  
comment on column PCLUB.ADMPT_TMP_PAGO_FACT.ADMPV_CUSTCODE is 'CustCode';
comment on column PCLUB.ADMPT_TMP_PAGO_FACT.ADMPV_TIPO_SERV is 'Tipo de servicio';
comment on column PCLUB.ADMPT_TMP_PAGO_FACT.ADMPV_PERIODO_ANIO is 'Año Periodo';
comment on column PCLUB.ADMPT_TMP_PAGO_FACT.ADMPV_PERIODO_MES is 'Mes Periodo';
comment on column PCLUB.ADMPT_TMP_PAGO_FACT.ADMPN_MNT_CGOFIJ is 'Monto del Cargo Fijo';
comment on column PCLUB.ADMPT_TMP_PAGO_FACT.ADMPN_DIAS_VENC is 'Dias Vencimiento';
comment on column PCLUB.ADMPT_TMP_PAGO_FACT.ADMPD_FEC_OPER is 'Fecha Operación';
comment on column PCLUB.ADMPT_TMP_PAGO_FACT.ADMPV_NOM_ARCH is 'Nombre del archivo';
comment on column PCLUB.ADMPT_TMP_PAGO_FACT.ADMPN_PUNTOS is 'Puntos';
comment on column PCLUB.ADMPT_TMP_PAGO_FACT.ADMPC_COD_ERROR is 'Codigo de Error';
comment on column PCLUB.ADMPT_TMP_PAGO_FACT.ADMPV_MSJE_ERROR is 'Mensaje de Error';
comment on column PCLUB.ADMPT_TMP_PAGO_FACT.ADMPN_SEQ is 'Numero Sequencia';


create table PCLUB.ADMPT_IMP_PAGO_FACT
(
  ADMPV_TIP_CLIENTE VARCHAR2(2),
  ADMPV_CUSTCODE    VARCHAR2(40),
  ADMPV_TIPO_SERV   VARCHAR2(4),
  ADMPV_PERIODO_ANIO VARCHAR2(4),
  ADMPV_PERIODO_MES VARCHAR2(2),
  ADMPN_MNT_CGOFIJ  NUMBER,
  ADMPN_DIAS_VENC   NUMBER,
  ADMPD_FEC_OPER    DATE,
  ADMPV_NOM_ARCH    VARCHAR2(150),
  ADMPN_PUNTOS      NUMBER,
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
comment on column PCLUB.ADMPT_IMP_PAGO_FACT.ADMPV_TIP_CLIENTE is 'Tipo Cliente';
comment on column PCLUB.ADMPT_IMP_PAGO_FACT.ADMPV_CUSTCODE is 'CustCode';
comment on column PCLUB.ADMPT_IMP_PAGO_FACT.ADMPV_TIPO_SERV is 'Tipo de servicio';
comment on column PCLUB.ADMPT_IMP_PAGO_FACT.ADMPV_PERIODO_ANIO is 'Periodo Año';
comment on column PCLUB.ADMPT_IMP_PAGO_FACT.ADMPV_PERIODO_MES is 'Periodo Mes';
comment on column PCLUB.ADMPT_IMP_PAGO_FACT.ADMPN_MNT_CGOFIJ is 'Monto del Cargo Fijo';
comment on column PCLUB.ADMPT_IMP_PAGO_FACT.ADMPN_DIAS_VENC is 'Dias Vencimiento';
comment on column PCLUB.ADMPT_IMP_PAGO_FACT.ADMPD_FEC_OPER is 'Fecha Operación';
comment on column PCLUB.ADMPT_IMP_PAGO_FACT.ADMPV_NOM_ARCH is 'Nombre del archivo';
comment on column PCLUB.ADMPT_IMP_PAGO_FACT.ADMPN_PUNTOS is 'Puntos';
comment on column PCLUB.ADMPT_IMP_PAGO_FACT.ADMPC_COD_ERROR is 'Codigo de Error';
comment on column PCLUB.ADMPT_IMP_PAGO_FACT.ADMPV_MSJE_ERROR is 'Mensaje de Error';
comment on column PCLUB.ADMPT_IMP_PAGO_FACT.ADMPN_SEQ is 'Numero Sequencia';


create table PCLUB.ADMPT_TMP_ANIV_CC
(
  ADMPV_TIP_CLIENTE VARCHAR2(2),
  ADMPV_CUSTCODE    VARCHAR2(40),
  ADMPV_CODCLI      VARCHAR2(100),
  ADMPV_MSISDN      VARCHAR2(100),
  ADMPV_TIPO_DOC    VARCHAR2(20),
  ADMPV_NUM_DOC     VARCHAR2(20),
  ADMPD_FEC_OPER    DATE,
  ADMPV_NOM_ARCH    VARCHAR2(150),
  ADMPN_PUNTOS      NUMBER,
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
  
comment on column PCLUB.ADMPT_TMP_ANIV_CC.ADMPV_TIP_CLIENTE is 'Tipo Cliente';
comment on column PCLUB.ADMPT_TMP_ANIV_CC.ADMPV_CUSTCODE is 'CustCode';
comment on column PCLUB.ADMPT_TMP_ANIV_CC.ADMPV_CODCLI is 'Codigo Cliente';
comment on column PCLUB.ADMPT_TMP_ANIV_CC.ADMPV_MSISDN is 'Codigo DN';
comment on column PCLUB.ADMPT_TMP_ANIV_CC.ADMPV_TIPO_DOC is 'Tipo Documento';
comment on column PCLUB.ADMPT_TMP_ANIV_CC.ADMPV_NUM_DOC is 'Numero Documento';
comment on column PCLUB.ADMPT_TMP_ANIV_CC.ADMPD_FEC_OPER is 'Fecha Operación';
comment on column PCLUB.ADMPT_TMP_ANIV_CC.ADMPV_NOM_ARCH is 'Nombre del archivo';
comment on column PCLUB.ADMPT_TMP_ANIV_CC.ADMPN_PUNTOS is 'Puntos';
comment on column PCLUB.ADMPT_TMP_ANIV_CC.ADMPC_COD_ERROR is 'Codigo de Error';
comment on column PCLUB.ADMPT_TMP_ANIV_CC.ADMPV_MSJE_ERROR is 'Mensaje de Error';
comment on column PCLUB.ADMPT_TMP_ANIV_CC.ADMPN_SEQ is 'Numero Sequencia';


create table PCLUB.ADMPT_IMP_ANIV_CC
(
  ADMPV_TIP_CLIENTE VARCHAR2(2),
  ADMPV_CUSTCODE    VARCHAR2(40),
  ADMPV_CODCLI      VARCHAR2(100),
  ADMPV_MSISDN      VARCHAR2(100),
  ADMPV_TIPO_DOC    VARCHAR2(20),
  ADMPV_NUM_DOC     VARCHAR2(20),
  ADMPD_FEC_OPER    DATE,
  ADMPV_NOM_ARCH    VARCHAR2(150),
  ADMPN_PUNTOS      NUMBER,
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
  
comment on column PCLUB.ADMPT_IMP_ANIV_CC.ADMPV_TIP_CLIENTE is 'Tipo Cliente';
comment on column PCLUB.ADMPT_IMP_ANIV_CC.ADMPV_CUSTCODE is 'CustCode';
comment on column PCLUB.ADMPT_IMP_ANIV_CC.ADMPV_CODCLI is 'Codigo Cliente';
comment on column PCLUB.ADMPT_IMP_ANIV_CC.ADMPV_MSISDN is 'Codigo DN';
comment on column PCLUB.ADMPT_IMP_ANIV_CC.ADMPV_TIPO_DOC is 'Tipo Documento';
comment on column PCLUB.ADMPT_IMP_ANIV_CC.ADMPV_NUM_DOC is 'Numero Documento';
comment on column PCLUB.ADMPT_IMP_ANIV_CC.ADMPD_FEC_OPER is 'Fecha Operación';
comment on column PCLUB.ADMPT_IMP_ANIV_CC.ADMPV_NOM_ARCH is 'Nombre del archivo';
comment on column PCLUB.ADMPT_IMP_ANIV_CC.ADMPN_PUNTOS is 'Puntos';
comment on column PCLUB.ADMPT_IMP_ANIV_CC.ADMPC_COD_ERROR is 'Codigo de Error';
comment on column PCLUB.ADMPT_IMP_ANIV_CC.ADMPV_MSJE_ERROR is 'Mensaje de Error';
comment on column PCLUB.ADMPT_IMP_ANIV_CC.ADMPN_SEQ is 'Numero Sequencia';

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


CREATE TABLE PCLUB.ADMPT_TMP_CAMBIOPLAN_HFCB
(
  ADMPV_TIP_CLIENTE VARCHAR2(2),
  ADMPV_TIPO_DOC    VARCHAR2(20),
  ADMPV_NUM_DOC     VARCHAR2(20),
  ADMPV_CUSTCODE    VARCHAR2(40),
  ADMPV_TIPO_SERV   VARCHAR2(20),
  ADMPD_FEC_CAM     DATE,
  ADMPC_TO          CHAR(1),
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

comment on column PCLUB.ADMPT_TMP_CAMBIOPLAN_HFCB.ADMPV_TIP_CLIENTE is 'Tipo Cliente';  
comment on column PCLUB.ADMPT_TMP_CAMBIOPLAN_HFCB.ADMPV_TIPO_DOC is 'Tipo Cliente';
comment on column PCLUB.ADMPT_TMP_CAMBIOPLAN_HFCB.ADMPV_NUM_DOC is 'Numero Documento';
comment on column PCLUB.ADMPT_TMP_CAMBIOPLAN_HFCB.ADMPV_CUSTCODE is 'CustCode';
comment on column PCLUB.ADMPT_TMP_CAMBIOPLAN_HFCB.ADMPV_TIPO_SERV is 'Tipo de Servicio';
comment on column PCLUB.ADMPT_TMP_CAMBIOPLAN_HFCB.ADMPD_FEC_CAM is 'Fecha Cambio';
comment on column PCLUB.ADMPT_TMP_CAMBIOPLAN_HFCB.ADMPC_TO is 'Tipo Operacion. Con valores U=UPGRADE D=DOWNGRADE';
comment on column PCLUB.ADMPT_TMP_CAMBIOPLAN_HFCB.ADMPD_FEC_OPER is 'Fecha Operación';
comment on column PCLUB.ADMPT_TMP_CAMBIOPLAN_HFCB.ADMPV_NOM_ARCH is 'Nombre del archivo';
comment on column PCLUB.ADMPT_TMP_CAMBIOPLAN_HFCB.ADMPC_COD_ERROR is 'Codigo de Error';
comment on column PCLUB.ADMPT_TMP_CAMBIOPLAN_HFCB.ADMPV_MSJE_ERROR is 'Mensaje de Error';
comment on column PCLUB.ADMPT_TMP_CAMBIOPLAN_HFCB.ADMPN_SEQ is 'Numero Sequencia';


CREATE TABLE PCLUB.ADMPT_IMP_CAMBIOPLAN_HFCB
(
  ADMPV_TIP_CLIENTE VARCHAR2(2),
  ADMPV_TIPO_DOC    VARCHAR2(20),
  ADMPV_NUM_DOC     VARCHAR2(20),
  ADMPV_CUSTCODE    VARCHAR2(40),
  ADMPV_TIPO_SERV   VARCHAR2(20),
  ADMPD_FEC_CAM     DATE,
  ADMPC_TO          CHAR(1),
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

comment on column PCLUB.ADMPT_IMP_CAMBIOPLAN_HFCB.ADMPV_TIP_CLIENTE is 'Tipo Cliente';  
comment on column PCLUB.ADMPT_IMP_CAMBIOPLAN_HFCB.ADMPV_TIPO_DOC is 'Tipo Cliente';
comment on column PCLUB.ADMPT_IMP_CAMBIOPLAN_HFCB.ADMPV_NUM_DOC is 'Numero Documento';
comment on column PCLUB.ADMPT_IMP_CAMBIOPLAN_HFCB.ADMPV_CUSTCODE is 'CustCode';
comment on column PCLUB.ADMPT_IMP_CAMBIOPLAN_HFCB.ADMPV_TIPO_SERV is 'Tipo de Servicio';
comment on column PCLUB.ADMPT_IMP_CAMBIOPLAN_HFCB.ADMPD_FEC_CAM is 'Fecha Cambio';
comment on column PCLUB.ADMPT_IMP_CAMBIOPLAN_HFCB.ADMPC_TO is 'Tipo Operacion. Con valores U=UPGRADE D=DOWNGRADE';
comment on column PCLUB.ADMPT_IMP_CAMBIOPLAN_HFCB.ADMPD_FEC_OPER is 'Fecha Operación';
comment on column PCLUB.ADMPT_IMP_CAMBIOPLAN_HFCB.ADMPV_NOM_ARCH is 'Nombre del archivo';
comment on column PCLUB.ADMPT_IMP_CAMBIOPLAN_HFCB.ADMPC_COD_ERROR is 'Codigo de Error';
comment on column PCLUB.ADMPT_IMP_CAMBIOPLAN_HFCB.ADMPV_MSJE_ERROR is 'Mensaje de Error';
comment on column PCLUB.ADMPT_IMP_CAMBIOPLAN_HFCB.ADMPN_SEQ is 'Numero Sequencia';

CREATE TABLE PCLUB.ADMPT_CTL_CANJES
(
  admpv_num_doc          varchar2(20) not null,
  admpv_cod_cli          varchar2(40),
  admpv_cod_cli_prod     varchar2(40),
  admpv_servicio         varchar2(20),
  admpc_proc_sysfirt     char(1),
  admpc_proc_eai         char(1),
  admpc_proc_reg_sot     char(1),
  admpc_proc_ejec_sot    char(1),
  admpc_proc_act_est_eai char(1),
  admpc_proc_act_bscs    char(1),
  admpc_proc_reg_extorno char(1),
  admpv_msje_error       varchar2(250),
  admpd_fec_reg          date,
  admpv_usu_reg          varchar2(50)
)
tablespace PCLUB_DATA
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the columns 
comment on column PCLUB.ADMPT_CTL_CANJES.admpv_num_doc
  is 'Número de DNI del cliente';
comment on column PCLUB.ADMPT_CTL_CANJES.admpv_cod_cli
  is 'Código del Cliente';
comment on column PCLUB.ADMPT_CTL_CANJES.admpv_cod_cli_prod
  is 'Código de Cliente producto';
comment on column PCLUB.ADMPT_CTL_CANJES.admpv_servicio
  is 'Código de servicio';
comment on column PCLUB.ADMPT_CTL_CANJES.admpc_proc_sysfirt
  is 'Flag indicador de error en la invocación al WS desde SYSFIRT.
Valores posibles:
0: Proceso OK
1: Error en el Proceso 
';
comment on column PCLUB.ADMPT_CTL_CANJES.admpc_proc_eai
  is 'Flag indicador de error en el registro en EAI.
Valores posibles:
0: Proceso OK
1: Error en el Proceso
';
comment on column PCLUB.ADMPT_CTL_CANJES.admpc_proc_reg_sot
  is 'Flag indicador de error en el registro de la SOT.
Valores posibles:
0: Proceso OK
1: Error en el Proceso
';
comment on column PCLUB.ADMPT_CTL_CANJES.admpc_proc_ejec_sot
  is 'Flag indicador de error en la ejecución de la SOT.
Valores posibles:
0: Proceso OK
1: Error en el Proceso
';
comment on column PCLUB.ADMPT_CTL_CANJES.admpc_proc_act_est_eai
  is 'Flag indicador de error en la actualización de estado de request en EAI.
Valores posibles:
0: Proceso OK
1: Error en el Proceso
';
comment on column PCLUB.ADMPT_CTL_CANJES.admpc_proc_act_bscs
  is 'Flag indicador de error en la actualización del servicio en BSCS.
Valores posibles:
0: Proceso OK
1: Error en el Proceso
';
comment on column PCLUB.ADMPT_CTL_CANJES.admpc_proc_reg_extorno
  is 'Flag indicador de error en el registro de extorno de puntos.
Valores posibles:
0: Proceso OK
1: Error en el Proceso
';
comment on column PCLUB.ADMPT_CTL_CANJES.admpv_msje_error
  is 'Mensaje de error ';
comment on column PCLUB.ADMPT_CTL_CANJES.admpd_fec_reg
  is 'Fecha de registro';
comment on column PCLUB.ADMPT_CTL_CANJES.admpv_usu_reg
  is 'Usuario de registro';
  
  -- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_CTL_CANJES
  add constraint PK_ADMPV_NUM_DOC primary key (ADMPV_NUM_DOC)
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
  
CREATE TABLE PCLUB.ADMPT_TMP_ALTACLIENTE_RPT
(
  ADMPN_SEQ         NUMBER,
  ADMPV_TIP_CLIENTE VARCHAR2(2),
  ADMPV_CUSTCODE    VARCHAR2(40),
  ADMPV_TIPO_DOC    VARCHAR2(20),
  ADMPV_NUM_DOC     VARCHAR2(20),
  ADMPV_NOM_CLI     VARCHAR2(80),
  ADMPV_APE_CLI     VARCHAR2(80),
  ADMPC_SEXO        CHAR(1),
  ADMPV_EST_CIVIL   VARCHAR2(20),
  ADMPV_EMAIL       VARCHAR2(80),
  ADMPV_PROV        VARCHAR2(30),
  ADMPV_DEPA        VARCHAR2(40),
  ADMPV_DIST        VARCHAR2(200),
  ADMPD_FEC_ACT     DATE,
  ADMPV_CICL_FACT   VARCHAR2(20),
  ADMPD_FEC_OPER    DATE,
  ADMPV_NOM_ARCH    VARCHAR2(150),
  ADMPV_COD_ERROR   CHAR(3) default ('-1'),
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
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_RPT.ADMPN_SEQ is 'Secuencial';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_RPT.ADMPV_TIP_CLIENTE is 'Tipo de Cliente';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_RPT.ADMPV_CUSTCODE is 'CustCode BSCS';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_RPT.ADMPV_TIPO_DOC is 'Tipo Documento';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_RPT.ADMPV_NUM_DOC is 'Número Documento';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_RPT.ADMPV_NOM_CLI is 'Nombre del cliente';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_RPT.ADMPV_APE_CLI is 'Apellido del cliente';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_RPT.ADMPC_SEXO is 'Sexo';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_RPT.ADMPV_EST_CIVIL is 'Estado Civil';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_RPT.ADMPV_EMAIL is 'Email';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_RPT.ADMPV_PROV is 'Provincia';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_RPT.ADMPV_DEPA is 'Departamento';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_RPT.ADMPV_DIST is 'Distrito';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_RPT.ADMPD_FEC_ACT is 'Fecha Activación';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_RPT.ADMPV_CICL_FACT is 'Ciclo de Facturación';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_RPT.ADMPD_FEC_OPER is 'Fecha de Operación';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_RPT.ADMPV_NOM_ARCH is 'Nombre del archivo';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_RPT.ADMPV_COD_ERROR is 'Codigo de Error';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTE_RPT.ADMPV_MSJE_ERROR is 'Mensaje de Error';

CREATE TABLE PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT
(
  ADMPN_SEQ         NUMBER,
  ADMPV_TIP_CLIENTE VARCHAR2(2),
  ADMPV_CUSTCODE    VARCHAR2(40),
  ADMPV_TIPO_SERV   VARCHAR2(20),
  ADMPD_FEC_OPER    DATE,
  ADMPV_NOM_ARCH    VARCHAR2(150),
  ADMPV_COD_ERROR   CHAR(3) default ('-1'),
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
comment on column PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT.ADMPN_SEQ is 'Secuencial';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT.ADMPV_TIP_CLIENTE is 'Tipo de Cliente';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT.ADMPV_CUSTCODE is 'CustCode BSCS';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT.ADMPV_TIPO_SERV is 'Tipo Servicio';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT.ADMPD_FEC_OPER is 'Fecha Operación';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT.ADMPV_NOM_ARCH is 'Nombre de archivo';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT.ADMPV_COD_ERROR is 'Codigo de Error';
comment on column PCLUB.ADMPT_TMP_ALTACLIENTESERV_RPT.ADMPV_MSJE_ERROR is 'Mensaje de Error';


CREATE TABLE PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT
(
  ADMPN_SEQ_SERV      NUMBER,
  ADMPV_TIP_CLIENTE   VARCHAR2(2),
  ADMPV_CUSTCODE      VARCHAR2(40),
  ADMPV_TIPO_DOC      VARCHAR2(20),
  ADMPV_NUM_DOC       VARCHAR2(20),
  ADMPV_NOM_CLI       VARCHAR2(80),
  ADMPV_APE_CLI       VARCHAR2(80),
  ADMPC_SEXO          CHAR(1),
  ADMPV_EST_CIVIL     VARCHAR2(20),
  ADMPV_EMAIL         VARCHAR2(80),
  ADMPV_PROV          VARCHAR2(30),
  ADMPV_DEPA          VARCHAR2(40),
  ADMPV_DIST          VARCHAR2(200),
  ADMPD_FEC_ACT       DATE,
  ADMPV_CICL_FACT     VARCHAR2(2),
  ADMPV_TIPO_SERV     VARCHAR2(20),
  ADMPV_COD_CLI       VARCHAR2(40),
  ADMPD_FEC_OPER      DATE,
  ADMPV_NOM_ARCH_CLI  VARCHAR2(150),
  ADMPV_NOM_ARCH_SERV VARCHAR2(150),
  ADMPV_COD_ERROR     CHAR(3),
  ADMPV_MSJE_ERROR    VARCHAR2(400)
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
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT.ADMPN_SEQ_SERV is 'Secuencial';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT.ADMPV_TIP_CLIENTE is 'Tipo Cliente';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT.ADMPV_CUSTCODE is 'CustCode';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT.ADMPV_TIPO_DOC is 'Tipo Documento';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT.ADMPV_NUM_DOC is 'Número Documento';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT.ADMPV_NOM_CLI is 'Nombre del cliente';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT.ADMPV_APE_CLI is 'Apellido del Cliente';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT.ADMPC_SEXO is 'Sexo';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT.ADMPV_EST_CIVIL is 'Estado Civil';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT.ADMPV_EMAIL is 'Email';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT.ADMPV_PROV is 'Provincia';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT.ADMPV_DEPA is 'Departamento';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT.ADMPV_DIST is 'Distrito';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT.ADMPD_FEC_ACT is 'Fecha Activación';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT.ADMPV_CICL_FACT is 'Ciclo de Facturación';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT.ADMPV_TIPO_SERV is 'Tipo de servicio';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT.ADMPV_COD_CLI is 'Código del cliente';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT.ADMPD_FEC_OPER is 'Fecha Operación';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT.ADMPV_NOM_ARCH_CLI is 'Nombre del archivo del cliente ';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT.ADMPV_NOM_ARCH_SERV is 'Nombre del archivo del servicio';  
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT.ADMPV_COD_ERROR is 'Codigo de Error';
comment on column PCLUB.ADMPT_IMP_ALTACLIENTESERV_RPT.ADMPV_MSJE_ERROR is 'Mensaje de Error';


CREATE TABLE PCLUB.ADMPT_TMP_ANIV_RPT
(
  ADMPV_TIP_CLIENTE  VARCHAR2(2),
  ADMPV_CUSTCODE     VARCHAR2(40),
  ADMPD_FEC_OPER     DATE,
  ADMPV_NOM_ARCH     VARCHAR2(150),
  ADMPN_PUNTOS       NUMBER,
  ADMPC_COD_ERROR    CHAR(3) default ('-1'),
  ADMPV_MSJE_ERROR   VARCHAR2(400),
  ADMPN_SEQ          NUMBER
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
comment on column PCLUB.ADMPT_TMP_ANIV_RPT.ADMPV_TIP_CLIENTE is 'Tipo Cliente';
comment on column PCLUB.ADMPT_TMP_ANIV_RPT.ADMPV_CUSTCODE is 'CustCode';
comment on column PCLUB.ADMPT_TMP_ANIV_RPT.ADMPD_FEC_OPER is 'Fecha Operación';
comment on column PCLUB.ADMPT_TMP_ANIV_RPT.ADMPV_NOM_ARCH is 'Nombre del archivo';
comment on column PCLUB.ADMPT_TMP_ANIV_RPT.ADMPN_PUNTOS is 'Puntos';
comment on column PCLUB.ADMPT_TMP_ANIV_RPT.ADMPC_COD_ERROR is 'Codigo de Error';
comment on column PCLUB.ADMPT_TMP_ANIV_RPT.ADMPV_MSJE_ERROR is 'Mensaje de Error';
comment on column PCLUB.ADMPT_TMP_ANIV_RPT.ADMPN_SEQ is 'Numero Sequencia';


CREATE TABLE PCLUB.ADMPT_IMP_ANIV_RPT
(
  ADMPV_TIP_CLIENTE  VARCHAR2(2),
  ADMPV_CUSTCODE     VARCHAR2(40),
  ADMPD_FEC_OPER     DATE,
  ADMPV_NOM_ARCH     VARCHAR2(150),
  ADMPN_PUNTOS       NUMBER,
  ADMPC_COD_ERROR    CHAR(3),
  ADMPV_MSJE_ERROR   VARCHAR2(400),
  ADMPN_SEQ          NUMBER
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
comment on column PCLUB.ADMPT_IMP_ANIV_RPT.ADMPV_TIP_CLIENTE is 'Tipo Cliente';
comment on column PCLUB.ADMPT_IMP_ANIV_RPT.ADMPV_CUSTCODE is 'CustCode';
comment on column PCLUB.ADMPT_IMP_ANIV_RPT.ADMPD_FEC_OPER is 'Fecha Operación';
comment on column PCLUB.ADMPT_IMP_ANIV_RPT.ADMPV_NOM_ARCH is 'Nombre del archivo';
comment on column PCLUB.ADMPT_IMP_ANIV_RPT.ADMPN_PUNTOS is 'Puntos';
comment on column PCLUB.ADMPT_IMP_ANIV_RPT.ADMPC_COD_ERROR is 'Codigo de Error';
comment on column PCLUB.ADMPT_IMP_ANIV_RPT.ADMPV_MSJE_ERROR is 'Mensaje de Error';
comment on column PCLUB.ADMPT_IMP_ANIV_RPT.ADMPN_SEQ is 'Numero Sequencia';


CREATE TABLE PCLUB.ADMPT_TMP_PAGOFACT_RPT
(
  ADMPV_TIP_CLIENTE VARCHAR2(2),
  ADMPV_CUSTCODE    VARCHAR2(40),
  ADMPV_TIPO_SERV   VARCHAR2(4),
  ADMPV_PERIODO_ANIO     VARCHAR2(4),
  ADMPV_PERIODO_MES     VARCHAR2(2),
  ADMPN_DIAS_VENC   NUMBER,
  ADMPN_MNT_CGOFIJ  NUMBER,
  ADMPD_FEC_OPER    DATE,
  ADMPV_NOM_ARCH    VARCHAR2(150),
  ADMPV_PERIODO     VARCHAR2(6),
  ADMPN_PUNTOS      NUMBER,
  ADMPC_COD_ERROR   CHAR(3) default ('-1'),
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
comment on column PCLUB.ADMPT_TMP_PAGOFACT_RPT.ADMPV_TIP_CLIENTE is 'Tipo Cliente';  
comment on column PCLUB.ADMPT_TMP_PAGOFACT_RPT.ADMPV_CUSTCODE is 'CustCode';
comment on column PCLUB.ADMPT_TMP_PAGOFACT_RPT.ADMPV_TIPO_SERV is 'Tipo de servicio';
comment on column PCLUB.ADMPT_TMP_PAGOFACT_RPT.ADMPV_PERIODO_ANIO is 'Año de Periodo';
comment on column PCLUB.ADMPT_TMP_PAGOFACT_RPT.ADMPV_PERIODO_MES is 'Mes de Periodo';
comment on column PCLUB.ADMPT_TMP_PAGOFACT_RPT.ADMPN_DIAS_VENC is 'Dias Vencimiento';
comment on column PCLUB.ADMPT_TMP_PAGOFACT_RPT.ADMPN_MNT_CGOFIJ is 'Monto del Cargo Fijo';
comment on column PCLUB.ADMPT_TMP_PAGOFACT_RPT.ADMPD_FEC_OPER is 'Fecha Operación';
comment on column PCLUB.ADMPT_TMP_PAGOFACT_RPT.ADMPV_NOM_ARCH is 'Nombre del archivo';
comment on column PCLUB.ADMPT_TMP_PAGOFACT_RPT.ADMPV_PERIODO is 'Periodo';
comment on column PCLUB.ADMPT_TMP_PAGOFACT_RPT.ADMPN_PUNTOS is 'Puntos';
comment on column PCLUB.ADMPT_TMP_PAGOFACT_RPT.ADMPC_COD_ERROR is 'Codigo de Error';
comment on column PCLUB.ADMPT_TMP_PAGOFACT_RPT.ADMPV_MSJE_ERROR is 'Mensaje de Error';
comment on column PCLUB.ADMPT_TMP_PAGOFACT_RPT.ADMPN_SEQ is 'Numero Sequencia';


CREATE TABLE PCLUB.ADMPT_IMP_PAGOFACT_RPT
(
  ADMPV_TIP_CLIENTE VARCHAR2(2),
  ADMPV_CUSTCODE    VARCHAR2(40),
  ADMPV_TIPO_SERV   VARCHAR2(4),
  ADMPV_PERIODO_ANIO     VARCHAR2(4),
  ADMPV_PERIODO_MES     VARCHAR2(2),
  ADMPN_DIAS_VENC   NUMBER,
  ADMPN_MNT_CGOFIJ  NUMBER,
  ADMPD_FEC_OPER    DATE,
  ADMPV_NOM_ARCH    VARCHAR2(150),
  ADMPV_PERIODO     VARCHAR2(6),
  ADMPN_PUNTOS      NUMBER,
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
comment on column PCLUB.ADMPT_IMP_PAGOFACT_RPT.ADMPV_TIP_CLIENTE is 'Tipo Cliente';
comment on column PCLUB.ADMPT_IMP_PAGOFACT_RPT.ADMPV_CUSTCODE is 'CustCode';
comment on column PCLUB.ADMPT_IMP_PAGOFACT_RPT.ADMPV_TIPO_SERV is 'Tipo de servicio';
comment on column PCLUB.ADMPT_IMP_PAGOFACT_RPT.ADMPV_PERIODO_ANIO is 'Año de Periodo';
comment on column PCLUB.ADMPT_IMP_PAGOFACT_RPT.ADMPV_PERIODO_MES is 'Mes de Periodo';
comment on column PCLUB.ADMPT_IMP_PAGOFACT_RPT.ADMPN_DIAS_VENC is 'Dias Vencimiento';
comment on column PCLUB.ADMPT_IMP_PAGOFACT_RPT.ADMPN_MNT_CGOFIJ is 'Monto del Cargo Fijo';
comment on column PCLUB.ADMPT_IMP_PAGOFACT_RPT.ADMPD_FEC_OPER is 'Fecha Operación';
comment on column PCLUB.ADMPT_IMP_PAGOFACT_RPT.ADMPV_NOM_ARCH is 'Nombre del archivo';
comment on column PCLUB.ADMPT_IMP_PAGOFACT_RPT.ADMPV_PERIODO is 'Periodo';
comment on column PCLUB.ADMPT_IMP_PAGOFACT_RPT.ADMPN_PUNTOS is 'Puntos';
comment on column PCLUB.ADMPT_IMP_PAGOFACT_RPT.ADMPC_COD_ERROR is 'Codigo de Error';
comment on column PCLUB.ADMPT_IMP_PAGOFACT_RPT.ADMPV_MSJE_ERROR is 'Mensaje de Error';
comment on column PCLUB.ADMPT_IMP_PAGOFACT_RPT.ADMPN_SEQ is 'Numero Sequencia';
 

CREATE TABLE PCLUB.ADMPT_AUX_PAGO_RPT
(
  ADMPV_COD_CLI_PROD VARCHAR2(40),
  ADMPV_PERIODO      VARCHAR2(6),
  ADMPD_FEC_OPER     DATE,
  ADMPV_NOM_ARCH     VARCHAR2(150)
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
comment on column PCLUB.ADMPT_AUX_PAGO_RPT.ADMPV_COD_CLI_PROD is 'Codigo Producto';
comment on column PCLUB.ADMPT_AUX_PAGO_RPT.ADMPV_PERIODO is 'Periodo';
comment on column PCLUB.ADMPT_AUX_PAGO_RPT.ADMPD_FEC_OPER is 'Fecha Operación';
comment on column PCLUB.ADMPT_AUX_PAGO_RPT.ADMPV_NOM_ARCH is 'Nombre del archivo';
  
/
