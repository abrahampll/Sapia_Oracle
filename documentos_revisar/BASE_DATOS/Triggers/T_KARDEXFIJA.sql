
CREATE OR REPLACE TRIGGER PCLUB.T_KARDEXFIJA
BEFORE UPDATE ON PCLUB.ADMPT_KARDEXFIJA REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
BEGIN
:NEW.ADMPD_FEC_MOD := SYSDATE;
END T_KARDEXFIJA;
/