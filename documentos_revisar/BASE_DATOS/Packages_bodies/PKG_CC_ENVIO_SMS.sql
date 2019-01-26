CREATE OR REPLACE PACKAGE BODY PCLUB.PKG_CC_ENVIO_SMS is

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
     FROM PCLUB.ADMPT_CLIENTE S
     WHERE (S.ADMPD_FEC_SMS IS NULL OR S.ADMPD_FEC_SMS = '')
     AND (S.ADMPV_EST_SMS IS NULL OR S.ADMPV_EST_SMS = '')
     AND S.ADMPD_FEC_REG >= TRUNC(SYSDATE)
     AND S.ADMPV_USU_REG = 'USRMICLARO'
     AND NOT EXISTS (SELECT substr(msisdn,5) as telefono
                            FROM dm.reporte_blist_telefonos@dbl_reptdm_d
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
    FROM PCLUB.ADMPT_CLIENTE S
    WHERE (S.ADMPD_FEC_SMS IS NULL OR S.ADMPD_FEC_SMS = '')
    AND (S.ADMPV_EST_SMS IS NULL OR S.ADMPV_EST_SMS = '')
    AND S.ADMPD_FEC_REG >= TRUNC(SYSDATE)
    AND S.ADMPV_USU_REG = 'USRMICLARO'
    AND NOT EXISTS (SELECT substr(msisdn,5) as telefono
                            FROM dm.reporte_blist_telefonos@dbl_reptdm_d
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
                            FROM dm.reporte_blist_telefonos@dbl_reptdm_d
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
  where /*i.s_reason_1='PREPAGO'
  AND i.s_reason_2='VARIACIÓN - ESTADO DE LA LÍNEA/CLIENTE'
  AND i.s_reason_3='DOL'*/
  i.x_subclase_code in ('109511')
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
--              se va a enviar SMS
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
                            FROM dm.reporte_blist_telefonos@dbl_reptdm_d
                            --where substr(msisdn,3) = S.ADMPV_TELEFONO
                            where msisdn = '51'||S.ADMPV_TELEFONO
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
                            FROM dm.reporte_blist_telefonos@dbl_reptdm_d
                            --where substr(msisdn,3) = S.ADMPV_TELEFONO
                            where msisdn = '51'||S.ADMPV_TELEFONO
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
                            FROM dm.reporte_blist_telefonos@dbl_reptdm_d
                            --where substr(msisdn,3) = S.ADMPV_TELEFONO
                            where msisdn = '51'||S.ADMPV_TELEFONO
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

PROCEDURE ADMPSS_OBTENER_TELEFONOS(K_PROCESO IN VARCHAR2, K_ESTADO IN CHAR, K_FLAG IN CHAR,K_RESULTADO OUT NUMBER,K_DESRESULTADO OUT VARCHAR2, CURSORTELEFONOS out SYS_REFCURSOR)
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
                        --(SELECT SUBSTR(MSISDN,5) FROM dm.REPORTE_BLIST_TELEFONOS@DBL_REPTDM_D where SUBSTR(MSISDN,3) = t.admpv_telefono and UPPER(tipo_telefono) = 'MOVIL')
                        (SELECT SUBSTR(MSISDN,5) FROM dm.REPORTE_BLIST_TELEFONOS@DBL_REPTDM_D where MSISDN = '51'||t.admpv_telefono and UPPER(tipo_telefono) = 'MOVIL')
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

--****************************************************************
-- Nombre SP           :  ADMPSS_OBTENER_MENSAJE
-- Propósito           :  Obtiene el mensaje de la tabla ADMPT_MENSAJE
-- Input               :  K_FLAG      --Identificador del mensaje
-- Output              :  K_MENSAJE   --Descripción del mensaje
--                        K_CODERROR  --Código de error o éxito
--                        K_DESCERROR --Descripción del error
-- Creado por          :  Oscar Paucar Pérez
-- Fec Creación        :  31/07/2013
--****************************************************************
PROCEDURE ADMPSS_OBTENER_MENSAJE(K_FLAG IN VARCHAR2,
                                 K_MENSAJE OUT VARCHAR2,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_FLAG IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el identificador del mensaje.'; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  BEGIN
    SELECT REPLACE(M.ADMPV_DESCRIPCION,' ',';') || '|' INTO K_MENSAJE 
    FROM PCLUB.ADMPT_MENSAJE M
    WHERE M.ADMPV_VALOR = K_FLAG;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      K_CODERROR := 51;
      K_DESCERROR := 'No está registrado el mensaje.';
      RAISE EX_ERROR;
  END;

EXCEPTION
  WHEN EX_ERROR THEN
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR EN SP ADMPSS_OBTENER_MENSAJE. ';
    END;  
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSS_OBTENER_MENSAJE;

--****************************************************************
-- Nombre SP           :  ADMPSS_OBTENER_TELEF_SMS
-- Propósito           :  Obtiene los números de teléfono para enviar SMS
-- Input               :  K_PROCESO    --Proceso
--                        K_CANTREG    --Cantidad de registros
--                        K_ADICIONAL1 --Parámetro adicional
--                        K_ADICIONAL2 --Parámetro adicional
-- Output              :  K_CUR_LISTA  --Lista de consulta
--                        K_CODERROR   --Código de error o éxito
--                        K_DESCERROR  --Descripción del error
-- Creado por          :  Oscar Paucar Pérez
-- Fec Creación        :  01/08/2013
--****************************************************************
PROCEDURE ADMPSS_OBTENER_TELEF_SMS(K_PROCESO IN VARCHAR2,
                                   K_CANTREG IN NUMBER,
                                   K_ADICIONAL1 IN VARCHAR2,
                                   K_ADICIONAL2 IN VARCHAR2,
                                   K_CUR_LISTA OUT SYS_REFCURSOR,
                                   K_CODERROR OUT NUMBER,
                                   K_DESCERROR OUT VARCHAR2) IS

EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_PROCESO IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el proceso.'; RAISE EX_ERROR;
    WHEN K_CANTREG IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese la cantidad de registros.'; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  IF K_PROCESO = 'BONO' THEN 
    OPEN K_CUR_LISTA FOR
    SELECT ADMPN_SEC AS SECUENCIA,
           ADMPV_LINEA AS TELEFONO 
    FROM (SELECT I.ADMPN_SEC,
                 I.ADMPV_LINEA
          FROM PCLUB.ADMPT_IMP_BONOFIDEL_PRE I
          WHERE I.ADMPC_TIPO_FIDEL = K_ADICIONAL1
                AND I.ADMPV_NOMARCHIVO = K_ADICIONAL2
                AND I.ADMPV_CODERROR IS NULL
                AND I.ADMPC_ESTADOSMS = 'P'
          ORDER BY I.ADMPN_SEC)
    WHERE ROWNUM <= K_CANTREG;
  END IF;
  
  IF K_PROCESO = 'RECARGAS' THEN 
    OPEN K_CUR_LISTA FOR
    SELECT ADMPN_SEQ AS SECUENCIA,
           ADMPV_LINEA AS TELEFONO 
    FROM (SELECT I.ADMPN_SEQ,
                 I.ADMPV_LINEA
          FROM PCLUB.ADMPT_IMP_ALTA_XRECARGA_PRE I
          WHERE I.ADMPV_NOMARCHIVO = K_ADICIONAL2
                AND I.ADMPV_CODERROR IS NULL
                AND I.ADMPC_ESTADOSMS = 'P'
          ORDER BY I.ADMPN_SEQ)
    WHERE ROWNUM <= K_CANTREG;
  END IF;

EXCEPTION
  WHEN EX_ERROR THEN
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR EN SP ADMPSS_OBTENER_TELEF_SMS. ';
    END;
    OPEN K_CUR_LISTA FOR
    SELECT '' SECUENCIA,
           '' TELEFONO
    FROM DUAL
    WHERE 1 = 0;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    OPEN K_CUR_LISTA FOR
    SELECT '' SECUENCIA,
           '' TELEFONO
    FROM DUAL
    WHERE 1 = 0;    
END ADMPSS_OBTENER_TELEF_SMS;


--****************************************************************
-- Nombre SP           :  ADMPSU_IMP_BLACKLIST
-- Propósito           :  Actualiza el campo ESTADOSMS
-- Input               :  K_PROCESO    --Proceso
--                        K_ADICIONAL1 --Parámetro adicional
--                        K_ADICIONAL2 --Parámetro adicional
--                        K_USUARIO    --Usuario del proceso
-- Output              :  K_NUMREG     --Total de registros de teléfonos
--                        K_CODERROR   --Código de error o éxito
--                        K_DESCERROR  --Descripción del error
-- Creado por          :  Oscar Paucar Pérez
-- Fec Creación        :  01/08/2013
--****************************************************************
PROCEDURE ADMPSU_IMP_BLACKLIST(K_PROCESO IN VARCHAR2,
                               K_ADICIONAL1 IN VARCHAR2,
                               K_ADICIONAL2 IN VARCHAR2,
                               K_USUARIO IN VARCHAR2,
                               K_NUMREG OUT NUMBER,
                               K_CODERROR OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2) IS

PRAGMA AUTONOMOUS_TRANSACTION;
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_PROCESO IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el proceso.'; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  IF K_PROCESO = 'BONO' THEN 
    UPDATE PCLUB.ADMPT_IMP_BONOFIDEL_PRE
    SET ADMPC_ESTADOSMS = 'N',
        ADMPD_USU_MOD = K_USUARIO,
        ADMPD_FEC_MOD = SYSDATE
    WHERE ADMPC_TIPO_FIDEL = K_ADICIONAL1
          AND ADMPV_NOMARCHIVO = K_ADICIONAL2
          AND ADMPV_CODERROR IS NULL
          AND ADMPC_ESTADOSMS = 'P'
          AND '51'||ADMPV_LINEA IN (SELECT MSISDN 
                                    FROM dm.reporte_blist_telefonos@dbl_reptdm_d
                                    WHERE UPPER(tipo_telefono) = 'MOVIL');

    COMMIT;

    SELECT COUNT(1) INTO K_NUMREG
    FROM PCLUB.ADMPT_IMP_BONOFIDEL_PRE I
    WHERE I.ADMPC_TIPO_FIDEL = K_ADICIONAL1
          AND I.ADMPV_NOMARCHIVO = K_ADICIONAL2
          AND I.ADMPV_CODERROR IS NULL
          AND I.ADMPC_ESTADOSMS = 'P';
  END IF;

  IF K_PROCESO = 'RECARGAS' THEN 
    UPDATE PCLUB.ADMPT_IMP_ALTA_XRECARGA_PRE
    SET ADMPC_ESTADOSMS = 'N',
        ADMPD_USU_MOD = K_USUARIO,
        ADMPD_FEC_MOD = SYSDATE
    WHERE ADMPV_NOMARCHIVO = K_ADICIONAL2
          AND ADMPV_CODERROR IS NULL
          AND ADMPC_ESTADOSMS = 'P'
          AND '51'||ADMPV_LINEA IN (SELECT MSISDN 
                                    FROM dm.reporte_blist_telefonos@dbl_reptdm_d
                                    WHERE UPPER(tipo_telefono) = 'MOVIL');

    COMMIT;

    SELECT COUNT(1) INTO K_NUMREG
    FROM PCLUB.ADMPT_IMP_ALTA_XRECARGA_PRE I
    WHERE I.ADMPV_NOMARCHIVO = K_ADICIONAL2
          AND I.ADMPV_CODERROR IS NULL
          AND I.ADMPC_ESTADOSMS = 'P';
  END IF;

    IF K_PROCESO = 'BONO_REPROCESO' THEN
    
      UPDATE PCLUB.ADMPT_BONOPREP_ERR
         SET ADMPV_ESTADO  = 'N',
             ADMPV_USU_MOD = K_USUARIO,
             ADMPD_FEC_MOD = SYSDATE
       WHERE ADMPV_ESTADO = 'P'
         AND (ADMPN_ID_BONO_PRE = K_ADICIONAL1 OR ADMPV_BONO = K_ADICIONAL2)
         AND EXISTS (SELECT MSISDN
                FROM dm.reporte_blist_telefonos@dbl_reptdm_d
               WHERE UPPER(tipo_telefono) = 'MOVIL'
                 AND MSISDN = ADMPN_TELEF);
    
      COMMIT;
    
      SELECT COUNT(1)
        INTO K_NUMREG
        FROM PCLUB.ADMPT_BONOPREP_ERR I
       WHERE I.ADMPV_ESTADO = 'P'
         AND (ADMPN_ID_BONO_PRE = K_ADICIONAL1 OR ADMPV_BONO = K_ADICIONAL2);
    
    END IF;

EXCEPTION
  WHEN EX_ERROR THEN
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR EN SP ADMPSU_IMP_BLACKLIST. ';
    END;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSU_IMP_BLACKLIST;


--****************************************************************
-- Nombre SP           :  ADMPSU_IMP_ESTADOSMS
-- Propósito           :  Actualiza el campo ESTADOSMS
-- Input               :  K_PROCESO    --Proceso
--                        K_CANTREG    --Cantidad de registros
--                        K_ADICIONAL1 --Parámetro adicional
--                        K_ADICIONAL2 --Parámetro adicional
--                        K_USUARIO    --Usuario del proceso
-- Output              :  K_CODERROR  --Código de error o éxito
--                        K_DESCERROR --Descripción del error
-- Creado por          :  Oscar Paucar Pérez
-- Fec Creación        :  01/08/2013
--****************************************************************
PROCEDURE ADMPSU_IMP_ESTADOSMS(K_PROCESO IN VARCHAR2,
                               K_CANTREG IN NUMBER,
                               K_ADICIONAL1 IN VARCHAR2,
                               K_ADICIONAL2 IN VARCHAR2,
                               K_USUARIO IN VARCHAR2,
                               K_CODERROR OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2) IS

EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_PROCESO IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el proceso.'; RAISE EX_ERROR;
    WHEN K_CANTREG IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese la cantidad de registros.'; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  IF K_PROCESO = 'BONO' THEN 
    MERGE INTO PCLUB.ADMPT_IMP_BONOFIDEL_PRE I
    USING (SELECT ADMPN_SEC
           FROM (SELECT B.ADMPN_SEC 
                 FROM PCLUB.ADMPT_IMP_BONOFIDEL_PRE B
                 WHERE B.ADMPC_TIPO_FIDEL = K_ADICIONAL1
                       AND B.ADMPV_NOMARCHIVO = K_ADICIONAL2
                       AND B.ADMPV_CODERROR IS NULL
                       AND B.ADMPC_ESTADOSMS = 'P'
                 ORDER BY B.ADMPN_SEC)
           WHERE ROWNUM <= K_CANTREG
          ) Q
    ON (I.ADMPN_SEC = Q.ADMPN_SEC)
    WHEN MATCHED THEN
      UPDATE 
      SET I.ADMPC_ESTADOSMS = 'E',
          I.ADMPD_FEC_ENVIOSMS = SYSDATE,
          I.ADMPD_USU_MOD = K_USUARIO,
          I.ADMPD_FEC_MOD = SYSDATE;
    
    COMMIT;
  END IF;

  IF K_PROCESO = 'RECARGAS' THEN 
    MERGE INTO PCLUB.ADMPT_IMP_ALTA_XRECARGA_PRE I
    USING (SELECT ADMPN_SEQ
           FROM (SELECT B.ADMPN_SEQ
                 FROM PCLUB.ADMPT_IMP_ALTA_XRECARGA_PRE B
                 WHERE B.ADMPV_NOMARCHIVO = K_ADICIONAL2
                       AND B.ADMPV_CODERROR IS NULL
                       AND B.ADMPC_ESTADOSMS = 'P'
                 ORDER BY B.ADMPN_SEQ)
           WHERE ROWNUM <= K_CANTREG
          ) Q
    ON (I.ADMPN_SEQ = Q.ADMPN_SEQ)
    WHEN MATCHED THEN
      UPDATE 
      SET I.ADMPC_ESTADOSMS = 'E',
          I.ADMPD_FEC_ENVIOSMS = SYSDATE,
          I.ADMPD_USU_MOD = K_USUARIO,
          I.ADMPD_FEC_MOD = SYSDATE;
    
    COMMIT;
  END IF;

EXCEPTION
  WHEN EX_ERROR THEN
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR EN SP ADMPSU_IMP_ESTADOSMS. ';
    END;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSU_IMP_ESTADOSMS;

  PROCEDURE ADMPSS_OBT_TELEF_SMS_BONO(K_IDBONO    IN VARCHAR2,
                                      K_BONO      IN VARCHAR2,
                                      K_CANTREG   IN NUMBER,
                                      K_CUR_LISTA OUT SYS_REFCURSOR,
                                      K_CODERROR  OUT NUMBER,
                                      K_DESCERROR OUT VARCHAR2) IS
  
    EX_ERROR EXCEPTION;
  BEGIN
  
    CASE
      WHEN (K_IDBONO IS NULL AND K_BONO IS NULL) THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese un Identificador de Bono o Descripción de Bono válido. ';
        RAISE EX_ERROR;
      WHEN K_CANTREG IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese la cantidad de registros.';
        RAISE EX_ERROR;
      ELSE
        K_CODERROR  := 0;
        K_DESCERROR := '';
    END CASE;
  
    OPEN K_CUR_LISTA FOR
      SELECT ADMPN_ID AS SECUENCIA, ADMPN_TELEF AS TELEFONO
        FROM (SELECT E.ADMPN_ID, E.ADMPN_TELEF
                FROM PCLUB.ADMPT_BONOPREP_ERR E
               WHERE E.ADMPV_ESTADO = 'P'
                 AND E.ADMPD_FEC_ENVIOSMS IS NULL
                 AND (E.ADMPN_ID_BONO_PRE = K_IDBONO OR
                     E.ADMPV_BONO = K_BONO)
               ORDER BY E.ADMPN_ID)
       WHERE ROWNUM <= K_CANTREG;
  
  EXCEPTION
    WHEN EX_ERROR THEN
      BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR
          INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_DESCERROR := 'ERROR EN SP ADMPSS_OBT_TELEF_SMS_BONO. ';
      END;
      OPEN K_CUR_LISTA FOR
        SELECT '' SECUENCIA, '' TELEFONO FROM DUAL WHERE 1 = 0;
    WHEN OTHERS THEN
      K_CODERROR  := -1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      OPEN K_CUR_LISTA FOR
        SELECT '' SECUENCIA, '' TELEFONO FROM DUAL WHERE 1 = 0;
  END ADMPSS_OBT_TELEF_SMS_BONO;

  PROCEDURE ADMPSS_OBT_TIPOSBONO(K_CUR_LISTA OUT SYS_REFCURSOR,
                                 K_CODERROR  OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2) IS
  
    EX_ERROR EXCEPTION;
  BEGIN
  
    K_CODERROR := 0;
  
    OPEN K_CUR_LISTA FOR
      SELECT B.ADMPN_ID_BONO_PRE, B.ADMPV_BONO, B.ADMPV_MENSAJE
        FROM PCLUB.ADMPT_BONO B
       WHERE B.ADMPC_ESTADO = 'A'
       ORDER BY B.ADMPV_BONO;
  
  EXCEPTION
    WHEN EX_ERROR THEN
      BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR
          INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_DESCERROR := 'ERROR EN SP ADMPSS_OBT_TIPOSBONO. ';
      END;
      OPEN K_CUR_LISTA FOR
        SELECT '' SECUENCIA, '' TELEFONO FROM DUAL WHERE 1 = 0;
    WHEN OTHERS THEN
      K_CODERROR  := -1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      OPEN K_CUR_LISTA FOR
        SELECT '' SECUENCIA, '' TELEFONO FROM DUAL WHERE 1 = 0;
  END ADMPSS_OBT_TIPOSBONO;

  PROCEDURE ADMPSU_ACT_ESTADOSMS_BONO(K_CANTREG   IN NUMBER,
                                      K_IDBONO    IN VARCHAR2,
                                      K_BONO      IN VARCHAR2,
                                      K_USUARIO   IN VARCHAR2,
                                      K_CODERROR  OUT NUMBER,
                                      K_DESCERROR OUT VARCHAR2) IS
  
    EX_ERROR EXCEPTION;
  BEGIN
  
    CASE
      WHEN (K_IDBONO IS NULL AND K_BONO IS NULL) THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese un Identificador de Bono o Descripción de Bono válido. ';
        RAISE EX_ERROR;
      WHEN K_CANTREG IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese la cantidad de registros.';
        RAISE EX_ERROR;
      ELSE
        K_CODERROR  := 0;
        K_DESCERROR := '';
    END CASE;
  
    MERGE INTO PCLUB.ADMPT_BONOPREP_ERR I
    USING (SELECT ADMPN_ID
             FROM (SELECT B.ADMPN_ID
                     FROM PCLUB.ADMPT_BONOPREP_ERR B
                    WHERE B.ADMPV_ESTADO = 'P'
                      AND B.ADMPD_FEC_ENVIOSMS IS NULL
                      AND (B.ADMPN_ID_BONO_PRE = K_IDBONO OR
                          B.ADMPV_BONO = K_BONO)
                    ORDER BY B.ADMPN_ID)
            WHERE ROWNUM <= K_CANTREG) Q
    ON (I.ADMPN_ID = Q.ADMPN_ID)
    WHEN MATCHED THEN
      UPDATE
         SET I.ADMPV_ESTADO       = 'S',
             I.ADMPD_FEC_ENVIOSMS = SYSDATE,
             I.ADMPD_FEC_PROC     = SYSDATE;
    COMMIT;
  
  EXCEPTION
    WHEN EX_ERROR THEN
      BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR
          INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_DESCERROR := 'ERROR EN SP ADMPSU_ACT_ESTADOSMS_BONO. ';
      END;
    WHEN OTHERS THEN
      K_CODERROR  := -1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
  END ADMPSU_ACT_ESTADOSMS_BONO;

END PKG_CC_ENVIO_SMS;
/
