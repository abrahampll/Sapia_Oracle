CREATE OR REPLACE TRIGGER PCLUB.T_PREMIO_PROMO BEFORE
INSERT ON PCLUB.ADMPT_PREMIO_PROMO FOR EACH ROW
WHEN (	NEW.ADMPN_ID_PREMIO  IS NULL )
BEGIN
  SELECT PCLUB.ADMPT_PREMIO_PROMO_SQ.NEXTVAL
  INTO   :NEW.ADMPN_ID_PREMIO
  FROM   DUAL;
END;
/