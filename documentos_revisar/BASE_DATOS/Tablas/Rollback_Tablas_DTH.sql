ALTER TABLE PCLUB.ADMPT_AUX_PROM_DTH_HFC  
DROP COLUMN ADMPN_PTOS_ORI;
ALTER TABLE PCLUB.ADMPT_AUX_REGDTH_HFC  
DROP COLUMN ADMPN_PTOS_ORI;


ALTER TABLE PCLUB.ADMPT_IMP_PROM_DTH_HFC  
DROP COLUMN ADMPN_PTOS_ORI;
ALTER TABLE PCLUB.ADMPT_IMP_REGDTH_HFC  
DROP COLUMN ADMPN_PTOS_ORI;


DROP TABLE PCLUB.ADMPT_TMP_CAMBTIT_DTH CASCADE CONSTRAINTS;

DROP TABLE PCLUB.ADMPT_AUX_CAMBTIT_DTH CASCADE CONSTRAINTS;

ALTER TABLE PCLUB.ADMPT_IMP_CAMBTIT_DTH
 DROP PRIMARY KEY CASCADE;

DROP TABLE PCLUB.ADMPT_IMP_CAMBTIT_DTH CASCADE CONSTRAINTS;

DROP TABLE PCLUB.ADMPT_TMP_ALTACLI_DTH CASCADE CONSTRAINTS;

DROP TABLE PCLUB.ADMPT_AUX_ALTACLI_DTH CASCADE CONSTRAINTS;

ALTER TABLE PCLUB.ADMPT_IMP_ALTACLI_DTH
 DROP PRIMARY KEY CASCADE;

DROP TABLE PCLUB.ADMPT_IMP_ALTACLI_DTH CASCADE CONSTRAINTS;

DROP TABLE PCLUB.ADMPT_TMP_BAJACLI_DTH CASCADE CONSTRAINTS;

DROP TABLE PCLUB.ADMPT_AUX_BAJACLI_DTH CASCADE CONSTRAINTS;

ALTER TABLE PCLUB.ADMPT_IMP_BAJACLI_DTH
 DROP PRIMARY KEY CASCADE;

DROP TABLE PCLUB.ADMPT_IMP_BAJACLI_DTH CASCADE CONSTRAINTS;

DROP TABLE PCLUB.ADMPT_TMP_PAGO_DTH CASCADE CONSTRAINTS;

DROP TABLE PCLUB.ADMPT_AUX_PAGO_DTH CASCADE CONSTRAINTS;

ALTER TABLE PCLUB.ADMPT_IMP_PAGO_DTH
 DROP PRIMARY KEY CASCADE;

DROP TABLE PCLUB.ADMPT_IMP_PAGO_DTH CASCADE CONSTRAINTS;

DROP TABLE PCLUB.ADMPT_TMP_ANIVERSDTH CASCADE CONSTRAINTS;

DROP TABLE PCLUB.ADMPT_AUX_ANIVERSDTH CASCADE CONSTRAINTS;

ALTER TABLE PCLUB.ADMPT_IMP_ANIVERSDTH
 DROP PRIMARY KEY CASCADE;

DROP TABLE PCLUB.ADMPT_IMP_ANIVERSDTH CASCADE CONSTRAINTS;
