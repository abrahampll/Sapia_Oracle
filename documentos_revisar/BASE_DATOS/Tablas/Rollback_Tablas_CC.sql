drop table PCLUB.ADMPT_SMS_TELEFONOS;
drop table PCLUB.ADMPT_MENSAJE;

ALTER TABLE PCLUB.ADMPT_CLIENTE DROP COLUMN ADMPV_USU_REG;
ALTER TABLE PCLUB.ADMPT_CLIENTE DROP COLUMN ADMPV_USU_MOD;
ALTER TABLE PCLUB.ADMPT_CLIENTE DROP COLUMN ADMPD_FEC_SMS;
ALTER TABLE PCLUB.ADMPT_CLIENTE DROP COLUMN ADMPV_EST_SMS;
ALTER TABLE PCLUB.ADMPT_CLIENTE DROP COLUMN ADMPV_TIPIFICACION;
