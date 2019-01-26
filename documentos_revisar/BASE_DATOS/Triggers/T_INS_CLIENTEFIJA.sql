
CREATE OR REPLACE TRIGGER PCLUB.T_INS_CLIENTEFIJA
BEFORE INSERT ON PCLUB.ADMPT_CLIENTEFIJA REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
BEGIN
:NEW.ADMPD_FEC_REG := SYSDATE;
END T_INS_CLIENTEFIJA;
/