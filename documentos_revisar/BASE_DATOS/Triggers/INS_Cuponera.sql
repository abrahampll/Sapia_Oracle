

CREATE OR REPLACE TRIGGER PCLUB.INS_CUPONERA
BEFORE INSERT ON PCLUB.ADMPT_CUPONERA REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
BEGIN
:NEW.ADMPD_FEC_REG := SYSDATE;
END INS_CUPONERA;
/
