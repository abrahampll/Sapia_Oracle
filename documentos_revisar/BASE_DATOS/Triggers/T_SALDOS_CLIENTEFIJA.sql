
CREATE OR REPLACE TRIGGER PCLUB.T_SALDOS_CLIENTEFIJA
BEFORE UPDATE ON PCLUB.ADMPT_SALDOS_CLIENTEFIJA REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
BEGIN
:NEW.ADMPD_FEC_MOD := SYSDATE;
END T_SALDOS_CLIENTEFIJA;
/