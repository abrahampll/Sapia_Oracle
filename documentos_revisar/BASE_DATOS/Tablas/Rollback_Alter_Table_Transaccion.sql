ALTER TABLE PCLUB.ADMPT_TIPO_PREMIO DROP COLUMN ADMPN_ORDEN;

ALTER TABLE PCLUB.ADMPT_TIPO_PREMCLIE DROP CONSTRAINT FK_ADMPT_TIPO_PREMCLIE_TIP_CLI;

ALTER TABLE PCLUB.ADMPT_TIPO_PREMCLIE DROP CONSTRAINT FK_ADMPT_TIPO_PREMCLIE_TIP_PRE;

ALTER TABLE PCLUB.ADMPT_KARDEX DROP CONSTRAINT FK_ADMPT_KARDEX_CONCEPTO;

ALTER TABLE PCLUB.ADMPT_PREMIO DROP COLUMN ADMPV_CAMPANA;

ALTER TABLE PCLUB.ADMPT_PREMIO DROP COLUMN ADMPV_CLAVE;

ALTER TABLE PCLUB.ADMPT_PREMIO DROP COLUMN ADMPN_MNTDCTO NUMBER;

ALTER TABLE PCLUB.ADMPT_PREMIO ADD DMPV_COD_TPOCL VARCHAR2(2); 

ALTER TABLE PCLUB.ADMPT_PREMIO DROP CONSTRAINT FK_ADMPT_PREMIO_TIPO_PREMIO;

ALTER TABLE PCLUB.ADMPT_PREMIO ADD ADMPV_DESC_X VARCHAR2(50); 

UPDATE ADMPT_PREMIO SET ADMPV_DESC_X = SUBSTR(ADMPV_DESC,0,50), ADMPV_DESC = NULL;

ALTER TABLE PCLUB.ADMPT_PREMIO MODIFY ADMPV_DESC VARCHAR2(50); 

UPDATE ADMPT_PREMIO SET ADMPV_DESC = ADMPV_DESC_X;

COMMIT;

ALTER TABLE PCLUB.ADMPT_PREMIO DROP COLUMN ADMPV_DESC_X;