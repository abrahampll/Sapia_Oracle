CREATE OR REPLACE PACKAGE BODY pclub.PKG_CC_ENVIO_SMS is

PROCEDURE ADMPSS_TIPIFICACIONES_MICLARO(K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2, CUR_TIPI OUT SYS_REFCURSOR)IS
--****************************************************************
-- Nombre SP           :  ADMPSI_TIPIFICACIONES_MICLARO
-- Propósito           :  obtener los numeros para guardar tipificaciones
-- Input               :  
-- Output              :  K_CODERROR
--                        K_DESCERROR
--                        CUR_SMS                         
-- Creado por          :  Deysi Galvez
-- Fec Creación        :  17/11/2011
-- Fec Actualización   :
--****************************************************************
BEGIN
    
    OPEN CUR_TIPI FOR 
      SELECT DISTINCT S.ADMPV_COD_CLI
      FROM ADMPT_CLIENTE S
      WHERE (S.ADMPD_FEC_SMS IS NULL OR S.ADMPD_FEC_SMS = '')
      AND (S.ADMPV_EST_SMS IS NULL OR S.ADMPV_EST_SMS = '')
      AND S.ADMPD_FEC_REG >= TRUNC(SYSDATE)
      AND S.ADMPV_USU_REG = 'USRMICLARO'
      AND (S.ADMPV_TIPIFICACION IS NULL OR S.ADMPV_TIPIFICACION = '');
      
      UPDATE ADMPT_CLIENTE S
      SET S.ADMPV_TIPIFICACION = 'USRTIPI',
          S.ADMPD_FEC_MOD = SYSDATE
      WHERE (S.ADMPD_FEC_SMS IS NULL OR S.ADMPD_FEC_SMS = '')
      AND (S.ADMPV_EST_SMS IS NULL OR S.ADMPV_EST_SMS = '')
      AND S.ADMPD_FEC_REG >= TRUNC(SYSDATE)
      AND S.ADMPV_USU_REG = 'USRMICLARO'
      AND (S.ADMPV_TIPIFICACION IS NULL OR S.ADMPV_TIPIFICACION = '');
      
      COMMIT; 
      
K_CODERROR := 0;
K_DESCERROR := 'OK';

EXCEPTION
    WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);
     ROLLBACK;   
END ADMPSS_TIPIFICACIONES_MICLARO;

PROCEDURE ADMPSS_COUNT_SMSMICLARO(K_COUNT OUT NUMBER,K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2)
IS
BEGIN
     SELECT COUNT(DISTINCT S.ADMPV_COD_CLI) INTO K_COUNT
     FROM ADMPT_CLIENTE S
     WHERE (S.ADMPD_FEC_SMS IS NULL OR S.ADMPD_FEC_SMS = '')
     AND (S.ADMPV_EST_SMS IS NULL OR S.ADMPV_EST_SMS = '')
     AND S.ADMPD_FEC_REG >= TRUNC(SYSDATE)
     AND S.ADMPV_USU_REG = 'USRMICLARO'
     AND NOT EXISTS (SELECT substr(msisdn,5) as telefono 
                            FROM reporte_blist_telefonos@dbl_reptdm_d
                            where substr(msisdn,3) = S.ADMPV_COD_CLI
                            and UPPER(tipo_telefono) = 'MOVIL');
     K_CODERROR:= 0;
     K_DESCERROR:='OK';
EXCEPTION
    WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);       
END ADMPSS_COUNT_SMSMICLARO;

PROCEDURE ADMPSS_ENVIOSMS_MICLARO(K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2, CUR_SMS OUT SYS_REFCURSOR)IS
--****************************************************************
-- Nombre SP           :  ADMPSI_ENVIOSMS_MICLARO
-- Propósito           :  obtener los numeros a quienes se les va a enviar sms
-- Input               :  
-- Output              :  K_CODERROR
--                        K_DESCERROR
--                        CUR_SMS                         
-- Creado por          :  Deysi Galvez
-- Fec Creación        :  17/11/2011
-- Fec Actualización   :
--****************************************************************
BEGIN
    
    OPEN CUR_SMS FOR 
    SELECT DISTINCT S.ADMPV_COD_CLI,(SELECT REPLACE(ADMPV_DESCRIPCION,' ',';') 
                                     FROM ADMPT_MENSAJE 
                                     WHERE ADMPV_VALOR = 'MICLARO') AS MENSAJE
    FROM ADMPT_CLIENTE S
    WHERE (S.ADMPD_FEC_SMS IS NULL OR S.ADMPD_FEC_SMS = '')
    AND (S.ADMPV_EST_SMS IS NULL OR S.ADMPV_EST_SMS = '')
    AND S.ADMPD_FEC_REG >= TRUNC(SYSDATE)
    AND S.ADMPV_USU_REG = 'USRMICLARO'
    AND NOT EXISTS (SELECT substr(msisdn,5) as telefono 
                            FROM reporte_blist_telefonos@dbl_reptdm_d
                            where substr(msisdn,3) = S.ADMPV_COD_CLI
                            and UPPER(tipo_telefono) = 'MOVIL')
    AND ROWNUM <= 100;
    
    UPDATE ADMPT_CLIENTE S
    SET S.ADMPV_EST_SMS = 'ENVIADO',
        S.ADMPD_FEC_SMS = SYSDATE,
        S.ADMPV_USU_MOD = 'USRMICLARO',
        S.ADMPD_FEC_MOD = SYSDATE
    WHERE (S.ADMPD_FEC_SMS IS NULL OR S.ADMPD_FEC_SMS = '')
    AND (S.ADMPV_EST_SMS IS NULL OR S.ADMPV_EST_SMS = '')
    AND S.ADMPD_FEC_REG >= TRUNC(SYSDATE)
    AND S.ADMPV_USU_REG = 'USRMICLARO'
    AND NOT EXISTS (SELECT substr(msisdn,5) as telefono 
                            FROM reporte_blist_telefonos@dbl_reptdm_d
                            where substr(msisdn,3) = S.ADMPV_COD_CLI
                            and UPPER(tipo_telefono) = 'MOVIL')
      AND ROWNUM <= 100;
    
    COMMIT;
    
K_CODERROR := 0;
K_DESCERROR := 'OK';

EXCEPTION
    WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);
     ROLLBACK;   
END ADMPSS_ENVIOSMS_MICLARO;

PROCEDURE ADMPSI_CARGA_PREP_DOL(K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2)IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_CARGA_PREP_DOL
  -- Propósito           :  Registrar todos los clientes prepago que realizaron el DOL. 
  -- Creado por          :  Deysi Galvez
  -- Fec Creación        :  17/11/2011
  -- Fec Actualización   :
  --****************************************************************
V_NROCORRELATIVO       NUMBER;
V_PUNTOS               NUMBER;
V_EXIST                NUMBER;
V_ERROR                VARCHAR2(400);
V_FEC_INI              DATE;
V_FEC_FIN              DATE;
V_FEC_NOW              DATE;
V_FEC_AYER             DATE;

CURSOR CUR_INTERACCIONES is
  select distinct I.PHONE
  from table_interact@dbl_clarify i
  where i.s_reason_1='PREPAGO'
  AND i.s_reason_2='VARIACIÓN - ESTADO DE LA LÍNEA/CLIENTE'
  AND i.s_reason_3='DOL'
  AND i.create_date>= trunc(SYSDATE-1) 
  AND i.create_date< trunc(SYSDATE) ;
BEGIN

     FOR A IN CUR_INTERACCIONES LOOP 
          --Valido que no exista otro registro igual
          SELECT NVL(COUNT(*),0) INTO V_EXIST
          FROM ADMPT_SMS_TELEFONOS
          WHERE ADMPV_TELEFONO=A.PHONE
          AND ADMPV_USUARIO_REG = 'USRDOL'
          AND ADMPV_NOMBRE_PROCESO = 'DOL'
          AND ADMPV_FECHA_REG>=TRUNC(SYSDATE); 
          --Inserto en la tabla ADMPT_IMP_CARGAPREP_DOL
          IF V_EXIST = 0 THEN
            INSERT INTO ADMPT_SMS_TELEFONOS
            (ADMPV_TELEFONO,ADMPC_ESTADO,ADMPV_NOMBRE_PROCESO,
            ADMPV_USUARIO_REG,ADMPV_FECHA_REG)
            VALUES(A.PHONE,'R','DOL','USRDOL',SYSDATE);
          END IF;
      END LOOP;
      COMMIT;
K_CODERROR := 0;
K_DESCERROR := 'OK';
EXCEPTION
    WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);   
END ADMPSI_CARGA_PREP_DOL;

PROCEDURE ADMPSS_COUNT_SMS(K_PROCESO IN VARCHAR2,K_USUARIO IN VARCHAR2,K_COUNT OUT NUMBER,K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2) IS
--****************************************************************
-- Nombre SP           :  ADMPSS_COUNT_SMS
-- Propósito           :  obtener la cantidad de usuarios a los que 
--						  se va a enviar SMS
-- Output              :  K_CODERROR
--                        K_DESCERROR
--                        CUR_SMS                         
-- Fec Creación        :  18/11/2011
--****************************************************************
BEGIN
    SELECT COUNT(DISTINCT S.ADMPV_TELEFONO) INTO K_COUNT
    FROM ADMPT_SMS_TELEFONOS S
    WHERE (S.ADMPD_FECHA_SMS IS NULL OR S.ADMPD_FECHA_SMS = '')
    AND (S.ADMPV_ESTADO_SMS IS NULL OR S.ADMPV_ESTADO_SMS = '')
    AND S.ADMPV_FECHA_REG >= TRUNC(SYSDATE)
    AND S.ADMPC_ESTADO = 'R'
    AND S.ADMPV_NOMBRE_PROCESO = K_PROCESO
    AND S.ADMPV_USUARIO_REG = K_USUARIO
    AND NOT EXISTS (SELECT substr(msisdn,5) as telefono 
                            FROM reporte_blist_telefonos@dbl_reptdm_d
                            where substr(msisdn,3) = S.ADMPV_TELEFONO
                            and UPPER(tipo_telefono) = 'MOVIL');

    K_CODERROR:= 0;
    K_DESCERROR:= 'OK';
EXCEPTION
    WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);       
END ADMPSS_COUNT_SMS;


PROCEDURE ADMPSI_ENVIOSMS_PROCESOS(K_PROCESO IN VARCHAR2,K_USUARIO IN VARCHAR2,K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2, CUR_SMS OUT SYS_REFCURSOR)IS
--****************************************************************
-- Nombre SP           :  ADMPSI_ENVIOSMS_PREP_DOL
-- Propósito           :  obtener los numeros a quienes se les va a enviar sms
-- Output              :  K_CODERROR
--                        K_DESCERROR
--                        CUR_SMS                         
-- Fec Creación        :  18/11/2011
--****************************************************************
BEGIN

    OPEN CUR_SMS FOR 
    SELECT DISTINCT S.ADMPV_TELEFONO,(SELECT REPLACE(ADMPV_DESCRIPCION,' ',';') 
                                     FROM ADMPT_MENSAJE 
                                     WHERE ADMPV_VALOR=K_PROCESO) AS MENSAJE
    FROM ADMPT_SMS_TELEFONOS S
    WHERE (S.ADMPD_FECHA_SMS IS NULL OR S.ADMPD_FECHA_SMS = '')
    AND (S.ADMPV_ESTADO_SMS IS NULL OR S.ADMPV_ESTADO_SMS = '')
    AND S.ADMPV_FECHA_REG >= TRUNC(SYSDATE)
    AND S.ADMPC_ESTADO = 'R'
    AND S.ADMPV_NOMBRE_PROCESO = K_PROCESO
    AND S.ADMPV_USUARIO_REG = K_USUARIO
    AND NOT EXISTS (SELECT substr(msisdn,5) as telefono 
                            FROM reporte_blist_telefonos@dbl_reptdm_d
                            where substr(msisdn,3) = S.ADMPV_TELEFONO
                            and UPPER(tipo_telefono) = 'MOVIL')
    AND ROWNUM <= 100;
    
    UPDATE ADMPT_SMS_TELEFONOS S
    SET S.ADMPV_ESTADO_SMS = 'ENVIADO',
        S.ADMPD_FECHA_SMS = SYSDATE,
        S.ADMPV_USUARIO_MOD = K_USUARIO,
        S.ADMPC_ESTADO = 'P',
        S.ADMPV_FECHA_MOD = SYSDATE
    WHERE (S.ADMPD_FECHA_SMS IS NULL OR S.ADMPD_FECHA_SMS = '')
    AND (S.ADMPV_ESTADO_SMS IS NULL OR S.ADMPV_ESTADO_SMS = '')
    AND S.ADMPV_FECHA_REG >= TRUNC(SYSDATE)
    AND S.ADMPC_ESTADO = 'R'
    AND S.ADMPV_NOMBRE_PROCESO = K_PROCESO
    AND S.ADMPV_USUARIO_REG = K_USUARIO
    AND NOT EXISTS (SELECT substr(msisdn,5) as telefono 
                            FROM reporte_blist_telefonos@dbl_reptdm_d
                            where substr(msisdn,3) = S.ADMPV_TELEFONO
                            and UPPER(tipo_telefono) = 'MOVIL')
      AND ROWNUM <=100;
    
    COMMIT;
    
    K_CODERROR:= 0;
    K_DESCERROR:= 'OK';
EXCEPTION
    WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);
     ROLLBACK;   
END ADMPSI_ENVIOSMS_PROCESOS;

PROCEDURE ADMPSS_OBTENERMENSAJE_POST(K_FLAG IN VARCHAR2,K_MENSAJE OUT VARCHAR2,K_CODERROR  OUT NUMBER,K_DESCERROR OUT VARCHAR2)
is
BEGIN

  SELECT REPLACE(M.ADMPV_DESCRIPCION,' ',';') || '|' INTO K_MENSAJE FROM ADMPT_MENSAJE M
  WHERE M.ADMPV_VALOR=K_FLAG;

   K_CODERROR:=1;
   K_DESCERROR := 'OK';
 EXCEPTION
   WHEN OTHERS THEN
 K_CODERROR:=-1;
   K_DESCERROR := SQLERRM;
   
end ADMPSS_OBTENERMENSAJE_POST;

PROCEDURE ADMPSS_OBTENER_TELEFONOS(K_PROCESO IN VARCHAR2, K_ESTADO IN CHAR,K_FLAG IN CHAR,K_RESULTADO OUT NUMBER,K_DESRESULTADO OUT VARCHAR2, CURSORTELEFONOS out SYS_REFCURSOR)
    IS
    CURSOR ACT_TELEFONOSALT_CONT IS
        SELECT A.ADMPV_TELEFONO  FROM
         ADMPT_SMS_TELEFONOS A
         WHERE A.ADMPC_ESTADO=K_ESTADO 
         AND A.ADMPD_FECHA_SMS IS NULL 
         AND A.ADMPV_NOMBRE_PROCESO=K_PROCESO--'ALTA DE CONTRATO' 
         AND A.ADMPV_ESTADO_SMS='PENDIENTE' 
         AND A.ADMPV_FECHA_REG>=TRUNC(SYSDATE)
         AND ROWNUM < 101;
 
BEGIN
 
      IF K_FLAG = '1' THEN
            OPEN CURSORTELEFONOS FOR
            SELECT B.ADMPV_TELEFONO  FROM
             ADMPT_SMS_TELEFONOS B
             WHERE B.ADMPC_ESTADO=K_ESTADO 
             AND B.ADMPV_NOMBRE_PROCESO=K_PROCESO 
             AND B.ADMPV_ESTADO_SMS='PENDIENTE'
             AND B.ADMPV_FECHA_REG>=TRUNC(SYSDATE);
             
             UPDATE ADMPT_SMS_TELEFONOS
             SET ADMPC_ESTADO='T'
             WHERE ADMPC_ESTADO=K_ESTADO 
             AND ADMPV_NOMBRE_PROCESO=K_PROCESO 
             AND ADMPV_ESTADO_SMS='PENDIENTE'
             AND ADMPV_FECHA_REG>=TRUNC(SYSDATE);
         
      ELSE --K_FLAG = '2' THEN
            IF K_FLAG = '2' THEN
                OPEN CURSORTELEFONOS FOR
                SELECT T.ADMPV_TELEFONO  || '|' FROM
                ADMPT_SMS_TELEFONOS T
                WHERE T.ADMPC_ESTADO=K_ESTADO AND
                NOT EXISTS
                        (SELECT SUBSTR(MSISDN,5) FROM REPORTE_BLIST_TELEFONOS@DBL_REPTDM_D where SUBSTR(MSISDN,3) = t.admpv_telefono and UPPER(tipo_telefono) = 'MOVIL')
                AND T.ADMPD_FECHA_SMS IS NULL 
                AND T.ADMPV_NOMBRE_PROCESO=K_PROCESO 
                AND T.ADMPV_ESTADO_SMS='PENDIENTE' 
                AND T.ADMPV_FECHA_REG>=TRUNC(SYSDATE)
                AND ROWNUM < 101;
                 
                FOR E IN ACT_TELEFONOSALT_CONT LOOP   
                    UPDATE ADMPT_SMS_TELEFONOS T 
                    SET T.ADMPC_ESTADO='P', 
                    T.ADMPD_FECHA_SMS=SYSDATE, 
                    T.ADMPV_ESTADO_SMS='ENVIADO',
                    T.ADMPV_USUARIO_MOD='USRCCLUB',
                    T.ADMPV_FECHA_MOD=SYSDATE
                    WHERE T.ADMPV_TELEFONO = E.ADMPV_TELEFONO 
                    AND T.ADMPV_NOMBRE_PROCESO=K_PROCESO 
                    AND T.ADMPV_ESTADO_SMS='PENDIENTE'
                    AND T.ADMPV_FECHA_REG>=TRUNC(SYSDATE);      
                END LOOP;

              END IF;
      END IF;   
      
      COMMIT; 
      K_RESULTADO:=1;
      K_DESRESULTADO := 'OK'; 
      
  EXCEPTION
   WHEN OTHERS THEN
   K_RESULTADO:=-1;
   K_DESRESULTADO := SQLERRM;
  
end ADMPSS_OBTENER_TELEFONOS;

END PKG_CC_ENVIO_SMS;
/
