CREATE OR REPLACE TRIGGER PCLUB.T_UPD_CAMPANHA
BEFORE UPDATE ON PCLUB.ADMPT_CAMPANHA REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
BEGIN
:NEW.ADMPD_FEC_MOD := SYSDATE;
END T_UPD_CAMPANHA;
/