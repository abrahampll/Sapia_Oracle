
CREATE TABLE PCLUB.ADMPT_SEGMENTOCUPONERA
(
  ADMPN_COD_SEG      NUMBER,
  ADMPV_DESCRIPCION  VARCHAR2(20 BYTE),
  ADMPD_FEC_REG      DATE CONSTRAINT CST_FEC_REG_SEGMENTOCUPONERA NOT NULL,
  ADMPD_FEC_MOD      DATE,
  ADMPV_USU_REG      VARCHAR2(20 BYTE),
  ADMPV_USU_MOD      VARCHAR2(20 BYTE)
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

COMMENT ON COLUMN PCLUB.ADMPT_SEGMENTOCUPONERA.ADMPN_COD_SEG IS 'Codigo identificador del segmento, secuencial.';

COMMENT ON COLUMN PCLUB.ADMPT_SEGMENTOCUPONERA.ADMPV_DESCRIPCION IS 'Descripcion del segmento, configurable por el usuario';

COMMENT ON COLUMN PCLUB.ADMPT_SEGMENTOCUPONERA.ADMPD_FEC_REG IS 'Fecha inicial de registro.';

COMMENT ON COLUMN PCLUB.ADMPT_SEGMENTOCUPONERA.ADMPD_FEC_MOD IS 'Fecha de modificaci�n del registro.';

COMMENT ON COLUMN PCLUB.ADMPT_SEGMENTOCUPONERA.ADMPV_USU_REG IS 'Usuario que insert� el registro.';

COMMENT ON COLUMN PCLUB.ADMPT_SEGMENTOCUPONERA.ADMPV_USU_MOD IS 'Usuario que modific� el registro.';

CREATE UNIQUE INDEX PCLUB.IDX_CODSEG_SEGMENTOCUPONERA ON PCLUB.ADMPT_SEGMENTOCUPONERA
(ADMPN_COD_SEG)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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


ALTER TABLE PCLUB.ADMPT_SEGMENTOCUPONERA ADD (
  CONSTRAINT PK_SEGMENTOCUPONERA
  PRIMARY KEY
  (ADMPN_COD_SEG)
  USING INDEX PCLUB.IDX_CODSEG_SEGMENTOCUPONERA);


CREATE TABLE PCLUB.ADMPT_CLIENTECUPONERA
(
  ADMPN_COD_CLI     NUMBER,
  ADMPV_TIPO_DOC    VARCHAR2(20 BYTE),
  ADMPV_NUM_DOC     VARCHAR2(20 BYTE),
  ADMPV_NOM_CLI     VARCHAR2(80 BYTE),
  ADMPV_APE_CLI     VARCHAR2(200 BYTE),
  ADMPV_EMAIL       VARCHAR2(100 BYTE),
  ADMPC_ESTADO      VARCHAR2(2 BYTE),
  ADMPD_FEC_REG     DATE CONSTRAINT CST_FECREG_CLIENTECUPONERA NOT NULL,
  ADMPD_FEC_MOD     DATE,
  ADMPV_USU_REG     VARCHAR2(20 BYTE),
  ADMPV_USU_MOD     VARCHAR2(20 BYTE),
  ADMPN_COD_SEG     NUMBER,
  ADMPV_ESTADO_CON  VARCHAR2(2 BYTE)
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

COMMENT ON COLUMN PCLUB.ADMPT_CLIENTECUPONERA.ADMPN_COD_CLI IS 'Codigo identificador del cliente, secuencial.';

COMMENT ON COLUMN PCLUB.ADMPT_CLIENTECUPONERA.ADMPV_TIPO_DOC IS 'Tipo de documento del cliente.';

COMMENT ON COLUMN PCLUB.ADMPT_CLIENTECUPONERA.ADMPV_NUM_DOC IS 'Numero de documento del cliente.';

COMMENT ON COLUMN PCLUB.ADMPT_CLIENTECUPONERA.ADMPV_NOM_CLI IS 'Nombre  del cliente.';

COMMENT ON COLUMN PCLUB.ADMPT_CLIENTECUPONERA.ADMPV_APE_CLI IS 'Apellido del cliente.';

COMMENT ON COLUMN PCLUB.ADMPT_CLIENTECUPONERA.ADMPV_EMAIL IS 'Email del cliente.';

COMMENT ON COLUMN PCLUB.ADMPT_CLIENTECUPONERA.ADMPC_ESTADO IS 'Estado actual del cliente, indica si puede realizar transacciones.';

COMMENT ON COLUMN PCLUB.ADMPT_CLIENTECUPONERA.ADMPD_FEC_MOD IS 'Fecha en que se modific� el registro.';

COMMENT ON COLUMN PCLUB.ADMPT_CLIENTECUPONERA.ADMPV_USU_REG IS 'Usuario que inserto el registro.';

COMMENT ON COLUMN PCLUB.ADMPT_CLIENTECUPONERA.ADMPV_USU_MOD IS 'Usuario que modific� el registro.';

COMMENT ON COLUMN PCLUB.ADMPT_CLIENTECUPONERA.ADMPN_COD_SEG IS 'Codigo de Segmento del cliente.';

COMMENT ON COLUMN PCLUB.ADMPT_CLIENTECUPONERA.ADMPV_ESTADO_CON IS 'Estado para realizar las consultas.';


CREATE UNIQUE INDEX PCLUB.IDX_COD_CLI_CUP ON PCLUB.ADMPT_CLIENTECUPONERA
(ADMPN_COD_CLI)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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


CREATE INDEX PCLUB.IDX_NDOC_CLIECUP ON PCLUB.ADMPT_CLIENTECUPONERA
(ADMPV_NUM_DOC)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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


CREATE INDEX PCLUB.IDX_TDOC_CLICUP ON PCLUB.ADMPT_CLIENTECUPONERA
(ADMPV_TIPO_DOC)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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

ALTER TABLE PCLUB.ADMPT_CLIENTECUPONERA ADD (
  CONSTRAINT PK_CLIENTECUPONERA
  PRIMARY KEY
  (ADMPN_COD_CLI)
  USING INDEX PCLUB.IDX_COD_CLI_CUP);

ALTER TABLE PCLUB.ADMPT_CLIENTECUPONERA ADD (
  CONSTRAINT FK_CODSEG_CLIENTECUPONERA 
  FOREIGN KEY (ADMPN_COD_SEG) 
  REFERENCES PCLUB.ADMPT_SEGMENTOCUPONERA (ADMPN_COD_SEG));


CREATE TABLE PCLUB.ADMPT_CLIENTECUPONERALOG
(
  ADMPV_TIPO_DOC    VARCHAR2(20 BYTE),
  ADMPV_NUM_DOC     VARCHAR2(20 BYTE),
  ADMPV_NOM_CLI     VARCHAR2(80 BYTE),
  ADMPV_APE_CLI     VARCHAR2(200 BYTE),
  ADMPV_EMAIL       VARCHAR2(100 BYTE),
  ADMPC_ESTADO      CHAR(1 BYTE),
  ADMPD_FEC_REG     DATE CONSTRAINT CST_FECREG_CLIENTECUPLOG NOT NULL,
  ADMPV_USU_REG     VARCHAR2(20 BYTE),
  ADMPV_COD_SEG     VARCHAR2(2 BYTE),
  ADMPV_ORIGEN      VARCHAR2(200 BYTE),
  ADMPV_DESC_ERROR  VARCHAR2(300 BYTE),
  ADMPV_PROCESO     VARCHAR2(100 BYTE)
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

COMMENT ON COLUMN PCLUB.ADMPT_CLIENTECUPONERALOG.ADMPV_TIPO_DOC IS 'Tipo de documento del cliente.';

COMMENT ON COLUMN PCLUB.ADMPT_CLIENTECUPONERALOG.ADMPV_NUM_DOC IS 'Numero de documento del cliente.';

COMMENT ON COLUMN PCLUB.ADMPT_CLIENTECUPONERALOG.ADMPV_NOM_CLI IS 'Nombre del cliente.';

COMMENT ON COLUMN PCLUB.ADMPT_CLIENTECUPONERALOG.ADMPV_APE_CLI IS 'Apellido del cliente.';

COMMENT ON COLUMN PCLUB.ADMPT_CLIENTECUPONERALOG.ADMPV_EMAIL IS 'Email del cliente';

COMMENT ON COLUMN PCLUB.ADMPT_CLIENTECUPONERALOG.ADMPC_ESTADO IS 'Estado de registro del cliente, ''N'' = no realizado,''R'' = realizado.';

COMMENT ON COLUMN PCLUB.ADMPT_CLIENTECUPONERALOG.ADMPV_COD_SEG IS 'Codigo de segmento del cliente';

COMMENT ON COLUMN PCLUB.ADMPT_CLIENTECUPONERALOG.ADMPV_ORIGEN IS 'Desde donde se realiz� el registro.';

COMMENT ON COLUMN PCLUB.ADMPT_CLIENTECUPONERALOG.ADMPV_DESC_ERROR IS 'Mensaje de error si es que no se realiz�.';


CREATE TABLE PCLUB.ADMPT_TMP_ALTAMASIVACUPONERA
(
  ADMPV_TIPO_DOC   VARCHAR2(20 BYTE),
  ADMPV_NUM_DOC    VARCHAR2(20 BYTE),
  ADMPV_NOM_CLI    VARCHAR2(80 BYTE),
  ADMPV_APE_CLI    VARCHAR2(200 BYTE),
  ADMPV_EMAIL      VARCHAR2(100 BYTE),
  ADMPN_COD_SEG    NUMBER,
  ADMPV_NOM_ARCH   VARCHAR2(100 BYTE),
  ADMPD_FEC_PROC   DATE,
  ADMPN_SEQ        NUMBER,
  ADMPV_DES_ERROR  VARCHAR2(200 BYTE),
  ADMPN_COD_ERROR  NUMBER,
  ADMPV_SEG        VARCHAR2(2 BYTE)
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

CREATE TABLE PCLUB.ADMPT_AUX_ALTAMASIVACUPONERA
(
  ADMPV_TIPO_DOC  VARCHAR2(20 BYTE),
  ADMPV_NUM_DOC   VARCHAR2(20 BYTE),
  ADMPV_NOM_CLI   VARCHAR2(80 BYTE),
  ADMPV_APE_CLI   VARCHAR2(200 BYTE),
  ADMPV_EMAIL     VARCHAR2(100 BYTE),
  ADMPN_COD_SEG   NUMBER,
  ADMPV_NOM_ARCH  VARCHAR2(100 BYTE),
  ADMPD_FEC_PROC  DATE,
  ADMPN_SEQ       NUMBER
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


CREATE TABLE PCLUB.ADMPT_IMP_ALTAMASIVACUPONERA
(
  ADMPN_FILA       NUMBER,
  ADMPV_TIPO_DOC   VARCHAR2(20 BYTE),
  ADMPV_NUM_DOC    VARCHAR2(20 BYTE),
  ADMPV_NOM_CLI    VARCHAR2(80 BYTE),
  ADMPV_APE_CLI    VARCHAR2(200 BYTE),
  ADMPV_EMAIL      VARCHAR2(100 BYTE),
  ADMPV_SEG        VARCHAR2(2 BYTE),
  ADMPV_NOM_ARCH   VARCHAR2(100 BYTE),
  ADMPD_FEC_PROC   DATE,
  ADMPN_SEQ        NUMBER,
  ADMPV_DES_ERROR  VARCHAR2(200 BYTE),
  ADMPN_COD_ERROR  NUMBER
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

CREATE TABLE PCLUB.ADMPT_ESTABLECIMIENTO
(
  ADMPV_COD_ESTABL  VARCHAR2(10 BYTE),
  ADMPV_NOM_ESTABL  VARCHAR2(100 BYTE),
  ADMPD_FEC_REG     DATE CONSTRAINT CST_FECREG_ESTABLECIMIENTO NOT NULL,
  ADMPD_FEC_MOD     DATE,
  ADMPV_USU_REG     VARCHAR2(20 BYTE),
  ADMPV_USU_MOD     VARCHAR2(20 BYTE),
  ADMPV_ESTADO      VARCHAR2(2 BYTE)
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

COMMENT ON COLUMN PCLUB.ADMPT_ESTABLECIMIENTO.ADMPV_COD_ESTABL IS 'C�digo �nico de establecimiento, el cliente registra este dato.';

COMMENT ON COLUMN PCLUB.ADMPT_ESTABLECIMIENTO.ADMPV_NOM_ESTABL IS 'Nombre del establecimiento.';

COMMENT ON COLUMN PCLUB.ADMPT_ESTABLECIMIENTO.ADMPD_FEC_REG IS 'Fecha en que se insert� el registro.';

COMMENT ON COLUMN PCLUB.ADMPT_ESTABLECIMIENTO.ADMPD_FEC_MOD IS 'Fecha en que se modific� el registro.';

COMMENT ON COLUMN PCLUB.ADMPT_ESTABLECIMIENTO.ADMPV_USU_REG IS 'Usuario que insert� el registro.';

COMMENT ON COLUMN PCLUB.ADMPT_ESTABLECIMIENTO.ADMPV_USU_MOD IS 'Usuario que modific� el registro.';
            
CREATE UNIQUE INDEX PCLUB.IDX_CODEST_ESTABLECIMIENTO ON PCLUB.ADMPT_ESTABLECIMIENTO
(ADMPV_COD_ESTABL)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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

ALTER TABLE PCLUB.ADMPT_ESTABLECIMIENTO ADD (
  CONSTRAINT PK_ESTABLECIMIENTO
  PRIMARY KEY
  (ADMPV_COD_ESTABL)
  USING INDEX PCLUB.IDX_CODEST_ESTABLECIMIENTO);

 
CREATE TABLE PCLUB.ADMPT_TELEFONOCUPONERA
(
  ADMPN_COD_TELEFONO  NUMBER,
  ADMPV_NUM_TELEFONO  VARCHAR2(20 BYTE),
  ADMPV_COD_ESTABL    VARCHAR2(10 BYTE),
  ADMPD_FEC_REG       DATE CONSTRAINT CST_FECREG_TELEFONOCUPONERA NOT NULL,
  ADMPD_FEC_MOD       DATE,
  ADMPV_USU_REG       VARCHAR2(20 BYTE),
  ADMPV_USU_MOD       VARCHAR2(20 BYTE),
  ADMPV_DIR_ESTABL    VARCHAR2(200 BYTE)
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

COMMENT ON COLUMN PCLUB.ADMPT_TELEFONOCUPONERA.ADMPN_COD_TELEFONO IS 'C�digo secuencial de telefono.';

COMMENT ON COLUMN PCLUB.ADMPT_TELEFONOCUPONERA.ADMPV_NUM_TELEFONO IS 'Numero de telefono.';

COMMENT ON COLUMN PCLUB.ADMPT_TELEFONOCUPONERA.ADMPV_COD_ESTABL IS 'Codigo de establecimiento.';

COMMENT ON COLUMN PCLUB.ADMPT_TELEFONOCUPONERA.ADMPV_DIR_ESTABL IS 'Direcci�n de establecimiento, al cual se le asigna el telefono.';

CREATE UNIQUE INDEX PCLUB.IDX_CODTEL_TELCUP ON PCLUB.ADMPT_TELEFONOCUPONERA
(ADMPN_COD_TELEFONO)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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


CREATE INDEX PCLUB.IDX_TELEF_CLICUP ON PCLUB.ADMPT_TELEFONOCUPONERA
(ADMPV_NUM_TELEFONO)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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


ALTER TABLE PCLUB.ADMPT_TELEFONOCUPONERA ADD (
  CONSTRAINT PK_TELEFONOCUPONERA
  PRIMARY KEY
  (ADMPN_COD_TELEFONO)
  USING INDEX PCLUB.IDX_CODTEL_TELCUP);

ALTER TABLE PCLUB.ADMPT_TELEFONOCUPONERA ADD (
  CONSTRAINT FK_CODEST_TELEFONOCUPONERA 
  FOREIGN KEY (ADMPV_COD_ESTABL) 
  REFERENCES PCLUB.ADMPT_ESTABLECIMIENTO (ADMPV_COD_ESTABL));



CREATE TABLE PCLUB.ADMPT_CUPONERA
(
    ADMPN_COD_CUP  NUMBER,
  ADMPV_NOM_CUP  VARCHAR2(100 BYTE),
  ADMPD_FEC_INI  DATE,
  ADMPD_FEC_FIN  DATE,
  ADMPD_FEC_REG  DATE CONSTRAINT CST_FECREG_CUPONERA NOT NULL,
  ADMPD_FEC_MOD  DATE,
  ADMPV_USU_REG  VARCHAR2(20 BYTE),
  ADMPV_USU_MOD  VARCHAR2(20 BYTE),
  ADMPC_ESTADO   CHAR(1 BYTE)
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

COMMENT ON COLUMN PCLUB.ADMPT_CUPONERA.ADMPN_COD_CUP IS 'Codigo secuencial �nico de la cuponera.';

COMMENT ON COLUMN PCLUB.ADMPT_CUPONERA.ADMPV_NOM_CUP IS 'Nombre de la cuponera.';

COMMENT ON COLUMN PCLUB.ADMPT_CUPONERA.ADMPD_FEC_INI IS 'Fecha de inicio de la cuponera';

COMMENT ON COLUMN PCLUB.ADMPT_CUPONERA.ADMPD_FEC_FIN IS 'Fecha de fin de la cuponera.';

COMMENT ON COLUMN PCLUB.ADMPT_CUPONERA.ADMPC_ESTADO IS 'P: Programado A: Activado B: Baja';



CREATE INDEX PCLUB.IDX_ADMPT_FEC_FIN_CUP ON PCLUB.ADMPT_CUPONERA
(ADMPD_FEC_FIN)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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


CREATE INDEX PCLUB.IDX_ADMPT_FEC_INI_CUP ON PCLUB.ADMPT_CUPONERA
(ADMPD_FEC_INI)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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


CREATE UNIQUE INDEX PCLUB.IDX_CODCUP_CUPONERA ON PCLUB.ADMPT_CUPONERA
(ADMPN_COD_CUP)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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

ALTER TABLE PCLUB.ADMPT_CUPONERA ADD (
  CONSTRAINT PK_CUPONERA
  PRIMARY KEY
  (ADMPN_COD_CUP)
  USING INDEX PCLUB.IDX_CODCUP_CUPONERA);

CREATE TABLE PCLUB.ADMPT_TMP_CUPONERA
(
  ADMPV_DESC_OFERTA  VARCHAR2(200 BYTE),
  ADMPV_CUPON        NUMBER,
  ADMPN_CUPONERA     NUMBER,
  ADMPD_FEC_PROC     DATE,
  ADMPV_USU_REG      VARCHAR2(20 BYTE),
  ADMPV_COD_ERROR    NUMBER,
  ADMPV_DESC_ERROR   VARCHAR2(300 BYTE),
  ADMPN_SEQ          NUMBER,
  ADMPV_COD_SEG      VARCHAR2(2 BYTE),
  ADMPV_COD_EST      VARCHAR2(10 BYTE),
  ADMPN_NRO_REDEN    NUMBER,
  ADMPN_FILA         NUMBER,
  ADMPN_SEG          NUMBER
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



CREATE TABLE PCLUB.ADMPT_CUPON
(
 ADMPN_COD_CUPON   NUMBER,
  ADMPV_DESC_CUPON  VARCHAR2(80 BYTE),
  ADMPD_FEC_REG     DATE CONSTRAINT CST_FECREG_CUPON NOT NULL,
  ADMPD_FEC_MOD     DATE,
  ADMPV_USU_REG     VARCHAR2(20 BYTE),
  ADMPV_USU_MOD     VARCHAR2(20 BYTE),
  ADMPN_COD_SEG     NUMBER,
  ADMPV_COD_ESTABL  VARCHAR2(10 BYTE),
  ADMPN_COD_CUP     NUMBER
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

COMMENT ON COLUMN PCLUB.ADMPT_CUPON.ADMPN_COD_CUPON IS 'Codigo identificador �nico del cup�n.';

COMMENT ON COLUMN PCLUB.ADMPT_CUPON.ADMPV_DESC_CUPON IS 'Descripci�n del cup�n.';

COMMENT ON COLUMN PCLUB.ADMPT_CUPON.ADMPN_COD_SEG IS 'C�digo de segmento del cliente.';

COMMENT ON COLUMN PCLUB.ADMPT_CUPON.ADMPV_COD_ESTABL IS 'Codigo de establecimiento asignado para el cupon.';


CREATE UNIQUE INDEX PCLUB.IDX_CODCUP_CUPON ON PCLUB.ADMPT_CUPON
(ADMPN_COD_CUPON)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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



ALTER TABLE PCLUB.ADMPT_CUPON ADD (
  CONSTRAINT PK_CUPON
  PRIMARY KEY
  (ADMPN_COD_CUPON)
  USING INDEX PCLUB.IDX_CODCUP_CUPON);

ALTER TABLE PCLUB.ADMPT_CUPON ADD (
  CONSTRAINT FK_CODCUP_CUPON 
  FOREIGN KEY (ADMPN_COD_CUP) 
  REFERENCES PCLUB.ADMPT_CUPONERA (ADMPN_COD_CUP),
  CONSTRAINT FK_CODEST_CUPON 
  FOREIGN KEY (ADMPV_COD_ESTABL) 
  REFERENCES PCLUB.ADMPT_ESTABLECIMIENTO (ADMPV_COD_ESTABL),
  CONSTRAINT FK_CODSEG_CUPON 
  FOREIGN KEY (ADMPN_COD_SEG) 
  REFERENCES PCLUB.ADMPT_SEGMENTOCUPONERA (ADMPN_COD_SEG));

CREATE TABLE PCLUB.ADMPT_OFERTA
(
 ADMPN_COD_OFERTA   NUMBER,
  ADMPV_NOM_OFERTA   VARCHAR2(10 BYTE),
  ADMPV_DESCRIPCION  VARCHAR2(200 BYTE),
  ADMPD_FEC_REG      DATE CONSTRAINT CST_FECREG_OFERTA NOT NULL,
  ADMPD_FEC_MOD      DATE,
  ADMPV_USU_REG      VARCHAR2(20 BYTE),
  ADMPV_USU_MOD      VARCHAR2(20 BYTE),
  ADMPN_COD_CUPON    NUMBER,
  ADMPN_NRO_RED      NUMBER,
  ADMPN_REDENCIONES  NUMBER,
  ADMPC_ESTADO       CHAR(1 BYTE)
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

COMMENT ON COLUMN PCLUB.ADMPT_OFERTA.ADMPN_COD_OFERTA IS 'Codigo identificador secuencial de la oferta.';

COMMENT ON COLUMN PCLUB.ADMPT_OFERTA.ADMPV_NOM_OFERTA IS 'Numero de oferta por establecimiento y segmento.';

COMMENT ON COLUMN PCLUB.ADMPT_OFERTA.ADMPV_DESCRIPCION IS 'Descripci�n de la oferta.';

COMMENT ON COLUMN PCLUB.ADMPT_OFERTA.ADMPN_COD_CUPON IS 'C�digo de cupon asociado a la oferta.';

CREATE UNIQUE INDEX PCLUB.IDX_CODOFER_OFERTA ON PCLUB.ADMPT_OFERTA
(ADMPN_COD_OFERTA)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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


ALTER TABLE PCLUB.ADMPT_OFERTA ADD (
  CONSTRAINT PK_OFERTA
  PRIMARY KEY
  (ADMPN_COD_OFERTA)
  USING INDEX PCLUB.IDX_CODOFER_OFERTA);

ALTER TABLE PCLUB.ADMPT_OFERTA ADD (
  CONSTRAINT FK_CODCUP_OFERTA 
  FOREIGN KEY (ADMPN_COD_CUPON) 
  REFERENCES PCLUB.ADMPT_CUPON (ADMPN_COD_CUPON));


CREATE TABLE PCLUB.ADMPT_CONSULTACUPONERA
(
  ADMPV_NUM_MOVIL  VARCHAR2(20 BYTE),
  ADMPN_COD_CLI    NUMBER,
  ADMPV_COD_EST    VARCHAR2(10 BYTE),
  ADMPV_FEC_CON    DATE,
  ADMPV_DESC_MSJE  VARCHAR2(200 BYTE),
  ADMPV_USU_REG    VARCHAR2(20 BYTE),
  ADMPD_FEC_REG    DATE,
  ADMPV_TIPO_DOC   VARCHAR2(10 BYTE),
  ADMPN_COD_SEG    NUMBER,
  ADMPN_COD_CON    NUMBER
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

COMMENT ON COLUMN PCLUB.ADMPT_CONSULTACUPONERA.ADMPV_NUM_MOVIL IS 'Numero desde el que se realiza la consulta.';

COMMENT ON COLUMN PCLUB.ADMPT_CONSULTACUPONERA.ADMPN_COD_CLI IS 'Numero de doc. a consultar.';

COMMENT ON COLUMN PCLUB.ADMPT_CONSULTACUPONERA.ADMPV_COD_EST IS 'Codigo de establecimiento.';

COMMENT ON COLUMN PCLUB.ADMPT_CONSULTACUPONERA.ADMPV_FEC_CON IS 'Fecha y hora de consulta';

COMMENT ON COLUMN PCLUB.ADMPT_CONSULTACUPONERA.ADMPV_DESC_MSJE IS 'Descripcion de respuesta para la consulta.';


CREATE INDEX PCLUB.IDX_COD_CLI_CONSULTACUP ON PCLUB.ADMPT_CONSULTACUPONERA
(ADMPN_COD_CLI)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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


CREATE UNIQUE INDEX PCLUB.IDX_CODCON_CONSULTACUP ON PCLUB.ADMPT_CONSULTACUPONERA
(ADMPN_COD_CON)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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


CREATE INDEX PCLUB.IDX_FEC_CON_CONSULTACUP ON PCLUB.ADMPT_CONSULTACUPONERA
(ADMPV_FEC_CON)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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


ALTER TABLE PCLUB.ADMPT_CONSULTACUPONERA ADD (
  CONSTRAINT PK_ADMPT_CONSULTACUP
  PRIMARY KEY
  (ADMPN_COD_CON)
  USING INDEX PCLUB.IDX_CODCON_CONSULTACUP);



CREATE TABLE PCLUB.ADMPT_MOVIMIENTOCUPONERA
(
    ADMPV_NUM_MOVIL   VARCHAR2(20 BYTE),
  ADMPN_COD_CLI     NUMBER,
  ADMPV_NUM_OFERTA  VARCHAR2(4 BYTE),
  ADMPV_COD_EST     VARCHAR2(10 BYTE),
  ADMPV_DESC_MSJE   VARCHAR2(200 BYTE),
  ADMPV_ESTADO      VARCHAR2(2 BYTE),
  ADMPV_COD_OFERTA  NUMBER,
  ADMPD_FEC_MOV     DATE,
  ADMPN_COD_CUP     NUMBER,
  ADMPN_COD_CUPON   NUMBER,
  ADMPV_USU_REG     VARCHAR2(20 BYTE),
  ADMPD_FEC_REG     DATE,
  ADMPN_COD_MOV     NUMBER CONSTRAINT CST_CODMOV_MOVCUPONERA NOT NULL
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

COMMENT ON COLUMN PCLUB.ADMPT_MOVIMIENTOCUPONERA.ADMPV_NUM_MOVIL IS 'Numero desde el cual se hace efectiva la promocion.';

COMMENT ON COLUMN PCLUB.ADMPT_MOVIMIENTOCUPONERA.ADMPN_COD_CLI IS 'Numero de documento del que consume la oferta.';

COMMENT ON COLUMN PCLUB.ADMPT_MOVIMIENTOCUPONERA.ADMPV_NUM_OFERTA IS 'Numero de oferta.';

COMMENT ON COLUMN PCLUB.ADMPT_MOVIMIENTOCUPONERA.ADMPV_COD_EST IS 'C�digo de establecimiento';

COMMENT ON COLUMN PCLUB.ADMPT_MOVIMIENTOCUPONERA.ADMPV_DESC_MSJE IS 'Descripcion de mensaje enviado.';

COMMENT ON COLUMN PCLUB.ADMPT_MOVIMIENTOCUPONERA.ADMPV_ESTADO IS 'Estado de si se realizo o no la oferta.';


CREATE UNIQUE INDEX PCLUB.IDX_CODMOV_MOVCUPONERA ON PCLUB.ADMPT_MOVIMIENTOCUPONERA
(ADMPN_COD_MOV)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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


CREATE INDEX PCLUB.IDX_CUPONERA_MOVCUPONERA ON PCLUB.ADMPT_MOVIMIENTOCUPONERA
(ADMPN_COD_CUP)
LOGGING
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
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


ALTER TABLE PCLUB.ADMPT_MOVIMIENTOCUPONERA ADD (
  CONSTRAINT PK_ADMPT_MOVCUPONERA
  PRIMARY KEY
  (ADMPN_COD_MOV)
  USING INDEX PCLUB.IDX_CODMOV_MOVCUPONERA);

ALTER TABLE PCLUB.ADMPT_MOVIMIENTOCUPONERA ADD (
  CONSTRAINT FK_CODOFER_MOVCUPONERA 
  FOREIGN KEY (ADMPV_COD_OFERTA) 
  REFERENCES PCLUB.ADMPT_OFERTA (ADMPN_COD_OFERTA));


CREATE TABLE PCLUB.ADMPT_TMP_CAMBIOSEG
(
  ADMPV_TIPO_DOC   VARCHAR2(20 BYTE),
  ADMPV_NUM_DOC    VARCHAR2(20 BYTE),
  ADMPV_SEG        VARCHAR2(2 BYTE),
  ADMPN_COD_SEG    NUMBER,
  ADMPV_NOM_ARCH   VARCHAR2(100 BYTE),
  ADMPD_FEC_PROC   DATE,
  ADMPN_SEQ        NUMBER,
  ADMPV_DES_ERROR  VARCHAR2(200 BYTE),
  ADMPN_COD_ERROR  NUMBER
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


CREATE TABLE PCLUB.ADMPT_AUX_CAMBIOSEG
(
  ADMPV_TIPO_DOC  VARCHAR2(20 BYTE),
  ADMPV_NUM_DOC   VARCHAR2(20 BYTE),
  ADMPV_NOM_ARCH  VARCHAR2(100 BYTE),
  ADMPD_FEC_PROC  DATE,
  ADMPN_SEQ       NUMBER
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



CREATE TABLE PCLUB.ADMPT_IMP_CAMBIOSEG
(
  ADMPN_FILA       NUMBER,
  ADMPV_TIPO_DOC   VARCHAR2(20 BYTE),
  ADMPV_NUM_DOC    VARCHAR2(20 BYTE),
  ADMPV_SEG        VARCHAR2(2 BYTE),
  ADMPN_COD_SEG    NUMBER,
  ADMPV_NOM_ARCH   VARCHAR2(100 BYTE),
  ADMPD_FEC_PROC   DATE,
  ADMPN_SEQ        NUMBER,
  ADMPV_DES_ERROR  VARCHAR2(200 BYTE),
  ADMPN_COD_ERROR  NUMBER
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


--MODIFICA LA TABLA TIPOS 
ALTER TABLE PCLUB.ADMPT_TIPOS
ADD  ADMPV_RUTA VARCHAR2(200);