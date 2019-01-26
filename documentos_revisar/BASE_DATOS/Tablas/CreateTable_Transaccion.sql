--Indice para Clientes
create index IDX_TDOC_NDOC on PCLUB.ADMPT_CLIENTE (ADMPV_TIPO_DOC, ADMPV_NUM_DOC)
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

---------------------------------------------  

create table PCLUB.admpt_data_temp
(
  campo_0  number,
  campo_1  number,
  campo_2  number,
  campo_3  number,
  campo_4  number,
  campo_5  number,
  campo_6  number,
  campo_7  number,
  campo_8  number,
  campo_9  number,
  campo_10 number,
  campo_11 number,
  campo_12 number,
  campo_13 number,
  campo_14 number,
  campo_15 number,
  campo_16 number,
  campo_17 number,
  campo_18 number,
  campo_19 number,
  campo_20 number,
  campo_21 number,
  campo_22 number,
  campo_23 number,
  campo_24 number,
  campo_25 number,
  campo_26 number,
  campo_27 number,
  campo_28 number,
  campo_29 number,
  campo_30 number,
  campo_31 number,
  campo_32 number,
  campo_33 number,
  campo_34 number,
  campo_35 number,
  campo_36 number,
  campo_37 number,
  campo_38 number,
  campo_49 number,
  campo_51 number,
  campo_52 number,
  campo_53 number,
  campo_54 number,
  campo_55 number,
  campo_56 number,
  campo_57 number,
  campo_58 number,
  campo_59 number
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
  

-- Periodo para el bono de renovacion especial
create table pclub.ADMPT_PERIODO
(
  ADMPV_COD_PER VARCHAR2(3) not null,
  ADMPV_DSC_PER VARCHAR2(50)
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
alter table pclub.ADMPT_PERIODO
  add constraint PK_ADMPT_PERIODO primary key (ADMPV_COD_PER)
  using index 
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );


create table pclub.ADMPT_BON_RENOVESPEC
(
  ID_FILA        NUMBER not null,
  ADMPV_COD_PER  VARCHAR2(3),
  ADMPV_COD_SEGM VARCHAR2(2),
  ADMPV_COD_EQU  VARCHAR2(20),
  ADMPN_COD_PLAN NUMBER,
  ADMPN_MONTO    NUMBER,
  ADMPV_USUARIO  VARCHAR2(100),
  ADMPD_FEC_REG  DATE
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
alter table pclub.ADMPT_BON_RENOVESPEC
  add constraint PK_ADMPT_BON_RENOVESPEC primary key (ID_FILA)
  using index 
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );


create table pclub.ADMPT_EQUIPO
(
  ADMPV_COD_EQU VARCHAR2(20) not null,
  ADMPV_DSC_EQU VARCHAR2(100)
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
alter table pclub.ADMPT_EQUIPO
  add constraint PK_ADMPT_EQUIPO primary key (ADMPV_COD_EQU)
  using index 
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );


create table pclub.ADMPT_SEGMENTO
(
  ADMPV_COD_SEGM VARCHAR2(2) not null,
  ADMPV_DSC_SEGM VARCHAR2(50),
  ADMPV_VAL_SIAC VARCHAR2(5)
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
alter table pclub.ADMPT_SEGMENTO
  add constraint PK_ADMPT_SEGMENTO primary key (ADMPV_COD_SEGM)
  using index 
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );


-- Create table
create table pclub.ADMPT_TIPO_PREMCLIE
(
  ADMPV_COD_TPOPR VARCHAR2(2) not null,
  ADMPV_COD_TPOCL VARCHAR2(2) not null
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

-- Create/Recreate primary, unique and foreign key constraints 
alter table pclub.ADMPT_TIPO_PREMCLIE
  add constraint PK_ADMPT_TIPO_PREMCLIE primary key (ADMPV_COD_TPOPR, ADMPV_COD_TPOCL)
  using index 
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

-- Create table
drop table PCLUB.ADMPT_CANJE cascade constraints;


create table pclub.ADMPT_CANJE
(
  ADMPV_ID_CANJE  NUMBER not null,
  ADMPV_COD_CLI   VARCHAR2(40) not null,
  ADMPV_ID_SOLIC  VARCHAR2(20),
  ADMPV_PTO_VENTA VARCHAR2(10),
  ADMPD_FEC_CANJE DATE,
  ADMPV_HRA_CANJE VARCHAR2(8),
  ADMPV_NUM_DOC   VARCHAR2(20),
  ADMPV_COD_TPOCL VARCHAR2(2),
  ADMPV_COD_ASESO VARCHAR2(16),
  ADMPV_NOM_ASESO VARCHAR2(60),
  ADMPC_TPO_OPER  CHAR(1),
  ADMPN_ID_KARDEX NUMBER,
  ADMPV_ID_LOYALTY VARCHAR2(20),
  ADMPV_DEV_IDCANJE NUMBER
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

-- Detalle de Canje
drop table PCLUB.ADMPT_CANJE_DETALLE cascade constraints;

create table pclub.ADMPT_CANJE_DETALLE
(
  ADMPV_ID_CANJE    NUMBER not null,
  ADMPV_ID_CANJESEC NUMBER not null,
  ADMPV_ID_PROCLA   VARCHAR2(15) not null,
  ADMPV_DESC        VARCHAR2(50),
  ADMPV_NOM_CAMP    VARCHAR2(200),
  ADMPN_PUNTOS      NUMBER,
  ADMPN_PAGO        NUMBER,
  ADMPN_CANTIDAD    NUMBER,
  ADMPV_COD_TPOPR   VARCHAR2(2),
  ADMPN_COD_SERVC   NUMBER,
  ADMPN_MNT_RECAR   NUMBER,
  ADMPC_ESTADO      CHAR(1),
  ADMPV_ID_LOYALTY  VARCHAR2(20)
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
alter table pclub.ADMPT_CANJE_DETALLE
  add constraint PK_ADMPT_CANJE_DETALLE primary key (ADMPV_ID_CANJE, ADMPV_ID_CANJESEC)
  using index 
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
alter table pclub.admpt_canje_detalle modify admpv_desc varchar2(150);
-- Create/Recreate primary, unique and foreign key constraints 
alter table pclub.ADMPT_CANJE
  add constraint PK_ADMPT_CANJE primary key (ADMPV_ID_CANJE)
  using index 
  tablespace PCLUB_INDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
alter table pclub.ADMPT_CANJE
  add constraint FK_ADMPT_CANJE_KARDEX foreign key (ADMPN_ID_KARDEX)
  references pclub.ADMPT_KARDEX (ADMPN_ID_KARDEX);
alter table pclub.ADMPT_CANJE
  add foreign key (ADMPV_COD_CLI)
  references pclub.ADMPT_CLIENTE (ADMPV_COD_CLI);

-- Create table
drop table pclub.ADMPT_CANJEDT_KARDEX cascade constraints;


create table pclub.ADMPT_CANJEDT_KARDEX
(
  ADMPV_ID_CANJE    NUMBER not null,
  ADMPN_ID_KARDEX   NUMBER not null,
  ADMPV_ID_CANJESEC NUMBER not null,
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

-- Create/Recreate primary, unique and foreign key constraints 
alter table pclub.ADMPT_CANJEDT_KARDEX
  add constraint FK_ADMPT_CANJEDT_KADX_CANJDET foreign key (ADMPV_ID_CANJE, ADMPV_ID_CANJESEC)
  references pclub.ADMPT_CANJE_DETALLE (ADMPV_ID_CANJE, ADMPV_ID_CANJESEC);
alter table pclub.ADMPT_CANJEDT_KARDEX
  add constraint FK_ADMPT_CANJEDT_KADX_KARDEX foreign key (ADMPN_ID_KARDEX)
  references pclub.ADMPT_KARDEX (ADMPN_ID_KARDEX);

-- Detalle de canje
alter table pclub.ADMPT_CANJE_DETALLE
  add constraint FK_ADMPT_CANJE_DETALLE_CANJE foreign key (ADMPV_ID_CANJE)
  references pclub.ADMPT_CANJE (ADMPV_ID_CANJE) on delete cascade;


-- Create 
create global temporary table pclub.ADMPT_DETACUTMP
(
  ADMPN_ID_FILA    NUMBER not null,
  ADMPV_PERIODO    VARCHAR2(6),
  ADMPN_DIAS_VENC  NUMBER,
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPN_MNT_CGOFIJ NUMBER,
  ADMPN_ACGOFIJ    NUMBER,
  ADMPN_MNT_ADIC   NUMBER,
  ADMPN_AJUADIC    NUMBER,
  ADMPN_PUNTOS     NUMBER,
  ADMPD_FEC_TRANS  DATE,
  ADMPV_CONCEPTO   VARCHAR2(50)
);

create global temporary table pclub.ADMPT_PRCANJTMP
(
  ADMPV_COD_CLI     VARCHAR2(40),
  ADMPV_PTO_VENTA   VARCHAR2(10),
  ADMPD_FEC_CANJE   DATE,
  ADMPV_HRA_CANJE   VARCHAR2(8),
  ADMPV_ID_PROCLA   VARCHAR2(15),
  ADMPN_PUNTOS      NUMBER,
  ADMPV_MONEDA      VARCHAR2(8),
  ADMPN_PAGO        NUMBER,
  ADMPN_CANTIDAD    NUMBER,
  ADMPV_ID_CANJE    NUMBER,
  ADMPN_ID_FILA     NUMBER,
  ADMPV_ID_CANJESEC NUMBER,
  ADMPC_ESTADO      CHAR(1),
  ADMPN_DISPONIBLE  NUMBER,
  ADMPV_DESC_PRE    VARCHAR2(50),
  ADMPN_COD_SERVC   NUMBER,
  ADMPN_MNT_RECAR   NUMBER
) ON COMMIT PRESERVE ROWS ;

-- Create table
create global temporary table pclub.ADMPT_DETMOVTMP
(
  ADMPV_MOTIVO    VARCHAR2(20),
  ADMPV_CONCEPTO  VARCHAR2(100),
  ADMPN_PUNTOS    NUMBER,
  ADMPD_FEC_TRANS DATE
)ON COMMIT PRESERVE ROWS ;


-- Create table
create global temporary table pclub.ADMPT_DATOSCLITMP
(
  ADMPV_COD_CLI     VARCHAR2(40),
  ADMPV_COD_TPOCL   VARCHAR2(2),
  ADMPV_NOMBRE      VARCHAR2(100),
  ADMPN_PUNTOS_CANJ NUMBER
)ON COMMIT PRESERVE ROWS ;



-- Create sequence 
create sequence pclub.ADMPT_DTACTM_SQ
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 20;


-- Create sequence 
create sequence pclub.ADMPT_PRCJTM_SQ
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 20;


-- Create sequence 
create sequence pclub.ADMPT_BONESP_SQ
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 20;

--Alter Table
alter table pclub.ADMPT_PRCANJTMP add ADMPV_ID_LOYALTY varchar2(20);
