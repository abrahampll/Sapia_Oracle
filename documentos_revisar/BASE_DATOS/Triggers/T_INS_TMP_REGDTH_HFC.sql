
CREATE OR REPLACE TRIGGER PCLUB.T_INS_TMP_REGDTH_HFC
BEFORE INSERT ON PCLUB.ADMPT_TMP_REGDTH_HFC REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
BEGIN
:NEW.ADMPD_FEC_REG := SYSDATE;
END T_INS_TMP_REGDTH_HFC;
/