CREATE OR REPLACE TRIGGER PCLUB.T_INS_CABENCUESTA
BEFORE INSERT ON PCLUB.ADMPT_CABENCUESTA
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
BEGIN
:NEW.ADMPD_FEC_REG := SYSDATE;
END T_INS_CABENCUESTA;
/