
CREATE OR REPLACE TRIGGER PCLUB.T_INS_CLIENTEPRODUCTO
BEFORE INSERT ON PCLUB.ADMPT_CLIENTEPRODUCTO REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
BEGIN
:NEW.ADMPD_FEC_REG := SYSDATE;
END T_INS_CLIENTEPRODUCTO;
/