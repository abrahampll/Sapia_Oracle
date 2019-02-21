drop table PCLUB.ADMPT_CANJE cascade constraints;

drop table PCLUB.ADMPT_CANJEDT_KARDEX cascade constraints;

drop table PCLUB.ADMPT_TIPO_PREMCLIE cascade constraints;

drop table PCLUB.ADMPT_DETACUTMP cascade constraints;

drop table PCLUB.ADMPT_PRCANJTMP cascade constraints;

drop table PCLUB.ADMPT_DETMOVTMP cascade constraints;

drop table PCLUB.ADMPT_DATOSCLITMP cascade constraints;

drop table PCLUB.admpt_data_temp cascade constraints;

drop table pclub.ADMPT_PERIODO cascade constraints;

drop table pclub.ADMPT_BON_RENOVESPEC cascade constraints;

drop table pclub.ADMPT_EQUIPO cascade constraints;

drop table pclub.ADMPT_EQUIPO cascade constraints;

drop table pclub.ADMPT_SEGMENTO cascade constraints;

drop table pclub.ADMPT_CANJE_DETALLE cascade constraints; 

-- Creamos la tabla de Canje
create table PCLUB.ADMPT_CANJE 
( 
  ADMPN_ID_FILA   NUMBER not null, 
  ADMPV_ID_CANJE  VARCHAR2(18) not null, 
  ADMPV_COD_CLI   VARCHAR2(40) not null, 
  ADMPV_ID_SOLIC  VARCHAR2(12), 
  ADMPV_PTO_VENTA VARCHAR2(10), 
  ADMPD_FEC_CANJE DATE, 
  ADMPV_HRA_CANJE VARCHAR2(5), 
  ADMPV_NUM_LINEA VARCHAR2(20), 
  ADMPV_NUM_DOC   VARCHAR2(20), 
  ADMPV_COD_TPOCL VARCHAR2(2), 
  ADMPV_COD_ASESO VARCHAR2(16), 
  ADMPV_NOM_ASESO VARCHAR2(60), 
  ADMPC_TPO_OPER  CHAR(1) 
) 
tablespace PCLUB_DATA 
  pctfree 10 
  initrans 1 
  maxtrans 255 
  storage 
  ( 
    initial 64K 
    minextents 1 
    maxextents unlimited 
  ); 
alter table PCLUB.ADMPT_CANJE 
  add constraint PK_ADMPT_CANJE primary key (ADMPN_ID_FILA) 
  using index  
  tablespace PCLUB_DATA 
  pctfree 10 
  initrans 2 
  maxtrans 255 
  storage 
  ( 
    initial 64K 
    minextents 1 
    maxextents unlimited 
  ); 
alter table PCLUB.ADMPT_CANJE 
  add foreign key (ADMPV_COD_CLI) 
  references PCLUB.ADMPT_CLIENTE (ADMPV_COD_CLI);

-- Create table
create table PCLUB.ADMPT_CANJE_DETALLE
(
  ADMPV_ID_CANJE    VARCHAR2(18) not null,
  ADMPV_ID_CANJESEC VARCHAR2(10) not null,
  ADMPN_ID_FILA     NUMBER not null,
  ADMPV_ID_PROCLA   VARCHAR2(15) not null,
  ADMPV_DESC        VARCHAR2(50),
  ADMPV_NOM_CAMP    VARCHAR2(200),
  ADMPN_PUNTOS      NUMBER,
  ADMPN_PAGO        NUMBER,
  ADMPN_CANTIDAD    NUMBER,
  ADMPV_COD_TPOPR   VARCHAR2(2),
  ADMPN_COD_SERVC   NUMBER,
  ADMPN_MNT_RECAR   NUMBER,
  ADMPC_ESTADO      CHAR(1)
)
tablespace PCLUB_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64
    minextents 1
    maxextents unlimited
  );
-- Create/Recreate primary, unique and foreign key constraints 
alter table PCLUB.ADMPT_CANJE_DETALLE
  add constraint PK_ADMPT_CANJE_DETALLE primary key (ADMPV_ID_CANJE, ADMPV_ID_CANJESEC)
  using index 
  tablespace PCLUB_DATA
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
  
create table PCLUB.ADMPT_CANJEDT_KARDEX 
( 
  ADMPV_ID_CANJE    VARCHAR2(18) not null, 
  ADMPN_ID_KARDEX   NUMBER not null, 
  ADMPV_ID_CANJESEC VARCHAR2(10) not null, 
  ADMPN_PUNTOS      NUMBER 
) 
tablespace PCLUB_DATA 
  pctfree 10 
  initrans 1 
  maxtrans 255 
  storage 
  ( 
    initial 64K 
    minextents 1 
    maxextents unlimited 
  );


DROP PACKAGE PCLUB.PKG_CC_TRANSACCION;

DROP SEQUENCE PCLUB.ADMPT_DTACTM_SQ;

DROP SEQUENCE PCLUB.ADMPT_PRCJTM_SQ;

DROP SEQUENCE PCLUB.ADMPT_BONESP_SQ;