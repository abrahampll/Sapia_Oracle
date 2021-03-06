INSERT INTO PCLUB.ADMPT_CONCEPTO VALUES('129','ANIVERSARIO HFC','A','','','C','HFC','','1');
INSERT INTO PCLUB.ADMPT_PARAMSIST VALUES('30','PUNTOS_ANIVERSARIO_HFC',50);
COMMIT;

DROP TABLE PCLUB.ADMPT_TMP_PROM_DTH_HFC;
CREATE TABLE PCLUB.ADMPT_TMP_PROM_DTH_HFC
(
  ADMPV_COD_CLI    VARCHAR2(40),
  ADMPN_PUNTOS     NUMBER,
  ADMPV_SERVICIO   VARCHAR2(20),
  ADMPV_MESVENCI   NUMBER,
  ADMPV_PERIODO    VARCHAR2(6),
  ADMPV_NOM_PROMO  VARCHAR2(150),
  ADMPD_FEC_REG    DATE,
  ADMPD_FEC_OPER   DATE,
  ADMPV_NOM_ARCH   VARCHAR2(150),
  ADMPC_COD_ERROR  CHAR(3),
  ADMPV_MSJE_ERROR VARCHAR2(400),
  ADMPN_SEQ        NUMBER,
  ADMPV_COD_TPOCL  VARCHAR2(2)
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

CREATE OR REPLACE TRIGGER PCLUB.T_INS_TMP_PROM_DTH_HFC
BEFORE INSERT ON PCLUB.ADMPT_TMP_PROM_DTH_HFC REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
BEGIN
:NEW.ADMPD_FEC_REG := SYSDATE;
END T_INS_TMP_PROM_DTH_HFC;
/

ALTER TABLE PCLUB.ADMPT_IMP_PROM_DTH_HFC ADD ADMPV_MESVENCI NUMBER;


INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (130,'VENCIMIENTO DE PUNTOS HFC - PROMO 01 MES','A','1','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (131,'VENCIMIENTO DE PUNTOS HFC - PROMO 02 MES','A','2','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (132,'VENCIMIENTO DE PUNTOS HFC - PROMO 03 MES','A','3','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (133,'VENCIMIENTO DE PUNTOS HFC - PROMO 04 MES','A','4','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (134,'VENCIMIENTO DE PUNTOS HFC - PROMO 05 MES','A','5','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (135,'VENCIMIENTO DE PUNTOS HFC - PROMO 06 MES','A','6','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (136,'VENCIMIENTO DE PUNTOS HFC - PROMO 07 MES','A','7','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (137,'VENCIMIENTO DE PUNTOS HFC - PROMO 08 MES','A','8','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (138,'VENCIMIENTO DE PUNTOS HFC - PROMO 09 MES','A','9','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (139,'VENCIMIENTO DE PUNTOS HFC - PROMO 10 MES','A','10','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (140,'VENCIMIENTO DE PUNTOS HFC - PROMO 11 MES','A','11','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (141,'VENCIMIENTO DE PUNTOS HFC - PROMO 12 MES','A','12','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (142,'VENCIMIENTO DE PUNTOS HFC - PROMO 13 MES','A','13','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (143,'VENCIMIENTO DE PUNTOS HFC - PROMO 14 MES','A','14','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (144,'VENCIMIENTO DE PUNTOS HFC - PROMO 15 MES','A','15','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (145,'VENCIMIENTO DE PUNTOS HFC - PROMO 16 MES','A','16','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (146,'VENCIMIENTO DE PUNTOS HFC - PROMO 17 MES','A','17','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (147,'VENCIMIENTO DE PUNTOS HFC - PROMO 18 MES','A','18','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (148,'VENCIMIENTO DE PUNTOS HFC - PROMO 19 MES','A','19','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (149,'VENCIMIENTO DE PUNTOS HFC - PROMO 20 MES','A','20','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (150,'VENCIMIENTO DE PUNTOS HFC - PROMO 21 MES','A','21','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (151,'VENCIMIENTO DE PUNTOS HFC - PROMO 22 MES','A','22','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (152,'VENCIMIENTO DE PUNTOS HFC - PROMO 23 MES','A','23','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (153,'VENCIMIENTO DE PUNTOS HFC - PROMO 24 MES','A','24','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (154,'VENCIMIENTO DE PUNTOS HFC - PROMO 25 MES','A','25','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (155,'VENCIMIENTO DE PUNTOS HFC - PROMO 26 MES','A','26','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (156,'VENCIMIENTO DE PUNTOS HFC - PROMO 27 MES','A','27','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (157,'VENCIMIENTO DE PUNTOS HFC - PROMO 28 MES','A','28','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (158,'VENCIMIENTO DE PUNTOS HFC - PROMO 29 MES','A','29','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (159,'VENCIMIENTO DE PUNTOS HFC - PROMO 30 MES','A','30','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (160,'VENCIMIENTO DE PUNTOS HFC - PROMO 31 MES','A','31','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (161,'VENCIMIENTO DE PUNTOS HFC - PROMO 32 MES','A','32','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (162,'VENCIMIENTO DE PUNTOS HFC - PROMO 33 MES','A','33','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (163,'VENCIMIENTO DE PUNTOS HFC - PROMO 34 MES','A','34','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (164,'VENCIMIENTO DE PUNTOS HFC - PROMO 35 MES','A','35','C','HFC - PROMO','1');
INSERT INTO PCLUB.ADMPT_CONCEPTO(ADMPV_COD_CPTO,ADMPV_DESC,ADMPC_ESTADO,ADMPN_PER_CADU,ADMPC_TPO_PUNTO,ADMPV_TPO_CPTO,ADMPC_TPO_OPER) VALUES (165,'VENCIMIENTO DE PUNTOS HFC - PROMO 36 MES','A','36','C','HFC - PROMO','1');
COMMIT;


INSERT INTO PCLUB.ADMPT_TIPO_PREMCLIE VALUES('30','7');
COMMIT;

/


