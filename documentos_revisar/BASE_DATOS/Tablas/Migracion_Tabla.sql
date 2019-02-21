-- Eliminar Dependencias
ALTER TABLE PCLUB.ADMPT_CANJE
DROP CONSTRAINT FK_ADMPT_CANJE_KARDEX;

ALTER TABLE PCLUB.ADMPT_CANJEDT_KARDEX
DROP CONSTRAINT FK_ADMPT_CANJEDT_KADX_KARDEX;

-- Agregar campo a tabla ADMPT_BONO_KARDEX
ALTER TABLE PCLUB.ADMPT_BONO_KARDEX ADD FECCORTA VARCHAR(10) DEFAULT(TO_CHAR(SYSDATE,'MM/YYYY'));

-- Agregar campo a tabla ADMPT_TMP_PRERECARGA
ALTER TABLE PCLUB.ADMPT_TMP_PRERECARGA ADD ADMPV_CATEGORIA NUMBER;
ALTER TABLE PCLUB.ADMPT_TMP_PRERECARGA ADD ADMPV_ERROR NUMBER;
ALTER TABLE PCLUB.ADMPT_TMP_PRERECARGA ADD ADMPV_MSJE_ERROR VARCHAR2(400);


--Creacion de tabla ADMPT_KARDEX_MIG
CREATE TABLE PCLUB.ADMPT_KARDEX_MIG 
   (  
  ADMPN_ID_KARDEX NUMBER NOT NULL ENABLE, 
  ADMPN_COD_CLI_IB NUMBER, 
  ADMPV_COD_CLI VARCHAR2(40), 
  ADMPV_COD_CPTO VARCHAR2(3), 
  ADMPD_FEC_TRANS DATE, 
  ADMPN_PUNTOS NUMBER, 
  ADMPV_NOM_ARCH VARCHAR2(150), 
  ADMPC_TPO_OPER CHAR(1), 
  ADMPC_TPO_PUNTO CHAR(1), 
  ADMPN_SLD_PUNTO NUMBER, 
  ADMPC_ESTADO CHAR(1), 
  ADMPV_IDTRANSLOY VARCHAR2(18), 
  ADMPD_FEC_REG DATE, 
  ADMPD_FEC_MOD DATE, 
  ADMPV_DESC_PROM VARCHAR2(200), 
  ADMPN_TIP_PREMIO NUMBER, 
  ADMPD_FEC_VCMTO DATE, 
  ADMPV_USU_REG VARCHAR2(20), 
  ADMPV_USU_MOD VARCHAR2(20), 
  ADMPD_FEC_MIG DATE, 
  ADMPV_USU_MIG VARCHAR2(20)
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
  
  
  ALTER TABLE PCLUB.ADMPT_KARDEX_MIG ADD CONSTRAINT PK_ADMPT_KARDEX_MIG
  PRIMARY KEY
  (ADMPN_ID_KARDEX)
  USING INDEX
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
               );
         
  ALTER TABLE PCLUB.ADMPT_KARDEX_MIG ADD CONSTRAINT FK_ADMPT_KARDEX_CONCEPTO_MIG 
  FOREIGN KEY 
  (ADMPV_COD_CPTO) 
  REFERENCES PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO);
 
 
 
 
  CREATE INDEX PCLUB.ADMPI_COD_CLI_MIG ON PCLUB.ADMPT_KARDEX_MIG (ADMPV_COD_CLI) 
  PCTFREE 10 
  INITRANS 2 
  MAXTRANS 255 
  COMPUTE STATISTICS 
  STORAGE(
      INITIAL 65536 
      NEXT 1048576 
      MINEXTENTS 1 
      MAXEXTENTS 2147483645
      PCTINCREASE 0 
      FREELISTS 1 
      FREELIST GROUPS 1 
      BUFFER_POOL DEFAULT)
  TABLESPACE PCLUB_INDX ;
 
  CREATE INDEX PCLUB.ADMPI_FEC_TRANS_MIG ON PCLUB.ADMPT_KARDEX_MIG (ADMPD_FEC_TRANS) 
  PCTFREE 10 
  INITRANS 2 
  MAXTRANS 255 
  COMPUTE STATISTICS 
  STORAGE(
      INITIAL 65536 
      NEXT 1048576 
      MINEXTENTS 1 
      MAXEXTENTS 2147483645
      PCTINCREASE 0 
      FREELISTS 1 
      FREELIST GROUPS 1 
      BUFFER_POOL DEFAULT)
  TABLESPACE PCLUB_INDX ;
  
  CREATE INDEX PCLUB.ADMPI_FEC_MIG ON PCLUB.ADMPT_KARDEX_MIG (ADMPD_FEC_MIG) 
  PCTFREE 10 
  INITRANS 2 
  MAXTRANS 255 
  COMPUTE STATISTICS 
  STORAGE(
      INITIAL 65536 
      NEXT 1048576 
      MINEXTENTS 1 
      MAXEXTENTS 2147483645
      PCTINCREASE 0 
      FREELISTS 1 
      FREELIST GROUPS 1 
      BUFFER_POOL DEFAULT)
  TABLESPACE PCLUB_INDX ;
 
  CREATE INDEX PCLUB.ADMPI_TIPO_OPER_MIG ON PCLUB.ADMPT_KARDEX_MIG (ADMPC_TPO_OPER) 
  PCTFREE 10 
  INITRANS 2 
  MAXTRANS 255 
  COMPUTE STATISTICS 
  STORAGE(
      INITIAL 65536 
      NEXT 1048576 
      MINEXTENTS 1 
      MAXEXTENTS 2147483645
      PCTINCREASE 0 
      FREELISTS 1 
      FREELIST GROUPS 1 
      BUFFER_POOL DEFAULT)
  TABLESPACE PCLUB_INDX ;
 
  CREATE INDEX PCLUB.IDX_ADMPT_KARDEX_01_MIG ON PCLUB.ADMPT_KARDEX_MIG (ADMPC_TPO_PUNTO, ADMPD_FEC_VCMTO, ADMPC_ESTADO) 
  PCTFREE 10 
  INITRANS 2 
  MAXTRANS 255 
  COMPUTE STATISTICS 
  STORAGE(
      INITIAL 65536 
      NEXT 1048576 
      MINEXTENTS 1 
      MAXEXTENTS 2147483645
      PCTINCREASE 0 
      FREELISTS 1 
      FREELIST GROUPS 1 
      BUFFER_POOL DEFAULT)
  TABLESPACE PCLUB_INDX ;
  
  
  COMMENT ON COLUMN PCLUB.ADMPT_KARDEX_MIG.ADMPN_COD_CLI_IB IS 'Codigo de Cliente IBK';
  COMMENT ON COLUMN PCLUB.ADMPT_KARDEX_MIG.ADMPV_COD_CLI IS 'Codigo de Cliente';
  COMMENT ON COLUMN PCLUB.ADMPT_KARDEX_MIG.ADMPC_TPO_OPER IS 'E=Entrada, S=Salida';
  COMMENT ON COLUMN PCLUB.ADMPT_KARDEX_MIG.ADMPC_TPO_PUNTO IS 'I=Interbank , C=Claroclub, L=Loyalty';
  COMMENT ON COLUMN PCLUB.ADMPT_KARDEX_MIG.ADMPC_ESTADO IS 'V =
A =
C =
';
  COMMENT ON COLUMN PCLUB.ADMPT_KARDEX_MIG.ADMPN_TIP_PREMIO IS '1: Servicios / 2: Descuento de Equipos';
  COMMENT ON COLUMN PCLUB.ADMPT_KARDEX_MIG.ADMPD_FEC_VCMTO IS 'Fecha de Vencimiento de los puntos';