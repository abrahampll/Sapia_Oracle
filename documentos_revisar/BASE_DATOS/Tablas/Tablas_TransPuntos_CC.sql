-- Create table ADMPT_TRANSFERENCIA
create table PCLUB.ADMPT_TRANSFERENCIA
(
  ADMPN_ID_TRANSCLARO NUMBER not null,
  ADMPV_ID_TRANSBONUS VARCHAR2(40),
  ADMPV_TIPO_DOC      VARCHAR2(20),
  ADMPV_NUM_DOC       VARCHAR2(20),
  ADMPV_BOLSA         VARCHAR2(20),
  ADMPV_TIPO          CHAR(1),
  ADMPN_PUNTOS        NUMBER,
  ADMPV_PTO_VENTA     VARCHAR2(40),
  ADMPV_ASESOR        VARCHAR2(20),
  ADMPV_ESTADO        VARCHAR2(10),
  ADMPD_FECHA         DATE,
  ADMPV_RESP_LOYALTY  VARCHAR2(200),
  ADMPV_RESP_CLARO    VARCHAR2(200),
  ADMPV_COMENTARIO    VARCHAR2(300),
  ADMPV_NOTAS         VARCHAR2(3500),
  ADMPV_ORIGEN        VARCHAR2(20)
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

create table PCLUB.ADMPT_TRANS_KARDEX
(
  ADMPN_ID_TRANSCLARO NUMBER not null,
  ADMPN_ID_KARDEX     NUMBER not null,
  ADMPN_PUNTOS        NUMBER,
  ADMPN_FECHA         DATE,
  ADMPV_TPO_KARDEX    CHAR(1) not null
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
alter table PCLUB.ADMPT_TRANSFERENCIA 
  add constraint PK_ADMPT_TRANSFERENCIA primary key (ADMPN_ID_TRANSCLARO)
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

alter table PCLUB.ADMPT_TRANS_KARDEX
  add primary key (ADMPN_ID_TRANSCLARO, ADMPN_ID_KARDEX)
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
  
alter table PCLUB.ADMPT_TRANS_KARDEX
  add constraint FK_ADMPT_TRANS_KARDEX_TRANSFE 
  foreign key (ADMPN_ID_TRANSCLARO)
  references PCLUB.ADMPT_TRANSFERENCIA (ADMPN_ID_TRANSCLARO);
  

create index PCLUB.IDX_TRANS_CLARO on PCLUB.ADMPT_TRANS_KARDEX(ADMPN_ID_TRANSCLARO)
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

-- Create/Recreate sequences and triggers 
CREATE SEQUENCE PCLUB.ADMPT_TRANSFERENCIA_SQ
  START WITH 1
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;

CREATE OR REPLACE TRIGGER PCLUB.TG_TRANSFERENCIA BEFORE
INSERT ON PCLUB.admpt_transferencia FOR EACH ROW
WHEN (
		new.ADMPN_ID_TRANSCLARO  IS NULL
      )
BEGIN
  SELECT PCLUB.ADMPT_TRANSFERENCIA_SQ.NEXTVAL
  INTO   :new.ADMPN_ID_TRANSCLARO
  FROM   dual;
END;