
CREATE OR REPLACE TRIGGER PCLUB.UPD_CUPONERA
BEFORE UPDATE ON PCLUB.ADMPT_CUPONERA REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
BEGIN
:NEW.ADMPD_FEC_MOD := SYSDATE;
END UPD_CUPONERA;
/