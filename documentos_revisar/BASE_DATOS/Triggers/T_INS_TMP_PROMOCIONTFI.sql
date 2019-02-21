CREATE OR REPLACE TRIGGER PCLUB.T_INS_TMP_PROMOCIONTFI
BEFORE INSERT ON PCLUB.ADMPT_TMP_PROMOCIONTFI
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
BEGIN
:NEW.ADMPD_FEC_REG := SYSDATE;
END T_INS_TMP_PROMOCIONTFI;
/