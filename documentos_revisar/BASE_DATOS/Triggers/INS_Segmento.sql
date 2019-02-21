
CREATE OR REPLACE TRIGGER PCLUB.INS_SEGMENTOCUPONERA
BEFORE INSERT ON PCLUB.ADMPT_SEGMENTOCUPONERA REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
BEGIN
:NEW.ADMPD_FEC_REG := SYSDATE;
END INS_SEGMENTOCUPONERA;
/