ALTER TABLE PCLUB.ADMPT_TMP_CMBTIT_CC 
MODIFY(ADMPV_NOM_CLI  VARCHAR2(80),
       ADMPV_APE_CLI  VARCHAR2(80));
COMMIT;

ALTER TABLE PCLUB.ADMPT_AUX_CMBTIT_CC
MODIFY(ADMPV_NOM_CLI  VARCHAR2(80),
       ADMPV_APE_CLI  VARCHAR2(80));
COMMIT;

ALTER TABLE PCLUB.ADMPT_IMP_CMBTIT_CC
MODIFY(ADMPV_NOM_CLI  VARCHAR2(80),
       ADMPV_APE_CLI  VARCHAR2(80));
COMMIT;
