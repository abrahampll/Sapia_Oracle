CREATE OR REPLACE TRIGGER PCLUB.T_UPD_FECHA_INI_PROMOCION
 BEFORE UPDATE OF  ADMPD_FEC_INI  ON PCLUB.ADMPT_PROMOCION  FOR EACH ROW
DECLARE K_SECUENCIAL NUMBER;
 BEGIN

    SELECT  AUDI_PROMOCION_SEC.NEXTVAL  INTO   K_SECUENCIAL
    FROM DUAL;

    INSERT INTO ADMPT_AUD_PROMOCION  VALUES (  K_SECUENCIAL
                                              ,:OLD.ADMPN_ID_PROMO
                                              ,:OLD.ADMPD_FEC_INI
                                              , NULL
                                              , :NEW.ADMPD_FEC_INI
                                              , NULL
                                              , SYSDATE
                                              ,:OLD.ADMPV_USU_REG
                                              , SYSDATE
                                              , USER
                                             );
 END T_UPD_FECHA_INI_PROMOCION;
/