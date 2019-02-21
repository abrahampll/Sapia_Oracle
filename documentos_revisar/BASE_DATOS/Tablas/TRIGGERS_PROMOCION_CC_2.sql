CREATE OR REPLACE TRIGGER PCLUB.T_UPD_FECHA_FIN_PROMOCION
 BEFORE UPDATE OF  ADMPD_FEC_FIN  ON PCLUB.ADMPT_PROMOCION  FOR EACH ROW
DECLARE K_SECUENCIAL NUMBER;
 BEGIN
    SELECT  PCLUB.AUDI_PROMOCION_SEC.NEXTVAL  INTO   K_SECUENCIAL
    FROM DUAL;  
    INSERT INTO PCLUB.ADMPT_AUD_PROMOCION  VALUES (    K_SECUENCIAL
                                              , :OLD.ADMPN_ID_PROMO
                                              ,  NULL
                                              , :OLD.ADMPD_FEC_FIN  
                                              ,  NULL
                                              , :NEW.ADMPD_FEC_FIN
                                              ,  SYSDATE
                                              , :OLD.ADMPV_USU_REG
                                              ,  SYSDATE
                                              , USER
                                             );
 END T_UPD_FECHA_FIN_PROMOCION;
/