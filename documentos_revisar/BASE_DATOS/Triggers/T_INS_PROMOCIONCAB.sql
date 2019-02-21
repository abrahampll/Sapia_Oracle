CREATE OR REPLACE TRIGGER FIDELIDAD.T_INS_PROMOCIONCAB
BEFORE INSERT ON FIDELIDAD.SFYRT_PROMOCIONCAB REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
BEGIN
:NEW.PROMD_FECREG := SYSDATE;
END T_INS_PROMOCIONCAB;
/