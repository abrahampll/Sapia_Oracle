CREATE OR REPLACE TRIGGER FIDELIDAD.T_UPD_PROGPROMCLIENTE
BEFORE UPDATE ON FIDELIDAD.SFYRT_PROGPROMCLIENTE REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
BEGIN
:NEW.PPCLD_FECMOD := SYSDATE;
END T_UPD_PROGPROMCLIENTE;
/