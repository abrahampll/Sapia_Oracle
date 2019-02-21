CREATE OR REPLACE TRIGGER fidelidad.T_UPD_CONFIG_SMS
BEFORE UPDATE ON fidelidad.CPRET_CONFIG_SMS REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
BEGIN
:NEW.CPRED_FECHAMOD := SYSDATE;
END T_UPD_CONFIG_SMS;
/