
CREATE OR REPLACE TRIGGER PCLUB.T_INS_TMP_PROM_DTH_HFC
BEFORE INSERT ON PCLUB.ADMPT_TMP_PROM_DTH_HFC REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
BEGIN
:NEW.ADMPD_FEC_REG := SYSDATE;
END T_INS_TMP_PROM_DTH_HFC;
/
