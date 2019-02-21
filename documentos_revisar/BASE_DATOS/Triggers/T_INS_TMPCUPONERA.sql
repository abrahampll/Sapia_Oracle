CREATE OR REPLACE TRIGGER PCLUB.T_INS_TMPCUPONERA
BEFORE INSERT ON PCLUB.ADMPT_TMP_CUPONERA REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
WHEN (
new.ADMPN_FILA  IS NULL
      )
BEGIN
  SELECT PCLUB.ADMPT_TMPCUPONERA_SQ.NEXTVAL
  INTO   :new.ADMPN_FILA
  FROM   dual;
END;
/
