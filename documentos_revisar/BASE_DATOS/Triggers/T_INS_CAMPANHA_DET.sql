CREATE OR REPLACE TRIGGER PCLUB.T_INS_CAMPANHA_DET
BEFORE INSERT ON PCLUB.ADMPT_CAMPANHA_DET
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
BEGIN
:NEW.ADMPD_FEC_REG := SYSDATE;
END T_INS_CAMPANHA_DET;
/