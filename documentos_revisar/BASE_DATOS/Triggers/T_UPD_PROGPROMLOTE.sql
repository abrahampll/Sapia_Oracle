CREATE OR REPLACE TRIGGER FIDELIDAD.T_UPD_PROGPROMLOTE
BEFORE UPDATE ON FIDELIDAD.SFYRT_PROGPROMLOTE REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
BEGIN
:NEW.PPLTD_FECMOD := SYSDATE;
END T_UPD_PROGPROMLOTE;
/