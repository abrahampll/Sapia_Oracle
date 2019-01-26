CREATE OR REPLACE PACKAGE BODY PCLUB.PKG_CC_PROMOCION is


FUNCTION ADMFF_TIPODOC(K_ADMPV_TIPO_DOC IN ADMPT_CLIENTE.ADMPV_TIPO_DOC%TYPE,
                       K_ADMPV_NUM_DOC  IN ADMPT_CLIENTE.ADMPV_NUM_DOC%TYPE)
  RETURN NUMBER IS
  --Funcion que retrona si el tipo de Documento es DNI y RUC y exista, apartir del numero de documento y tipo de documento
  K_RPTA NUMBER; --Respuesta a la funcion  1 existe el cliente y 0  el cliente No existe
  K_CONT NUMBER; --Almacena el numero de registros
BEGIN

  K_CONT := 0; --Iniciando la variable  a 0
  K_RPTA := 1; --Inicializamos como todo verdad 1
  -----------------------------------
  SELECT NVL(COUNT(1), 0)
    INTO K_CONT
    FROM ADMPT_CLIENTE
   WHERE ADMPV_TIPO_DOC = K_ADMPV_TIPO_DOC
     AND ADMPV_NUM_DOC = K_ADMPV_NUM_DOC
     AND ADMPC_ESTADO = 'A';

  IF (K_CONT = 0) THEN
    --Si el contador de registro nos entrega un valor 0 no exite registro buscado
    K_RPTA := 0; -- No existe registro
  END IF;

  RETURN(K_RPTA);
EXCEPTION
  WHEN OTHERS THEN
    K_RPTA := 0;
    RETURN(K_RPTA);

END ADMFF_TIPODOC;

FUNCTION ADMFF_MOVIMIENTOS(K_ADMPV_TIPO_DOC IN ADMPT_CLIENTE.ADMPV_TIPO_DOC%TYPE,
                           K_ADMPV_NUM_DOC  IN ADMPT_CLIENTE.ADMPV_NUM_DOC%TYPE)
  RETURN NUMBER IS
  K_RPTA       NUMBER; --Valor de retorno de la funcion
  K_CONT       NUMBER; --Contador de registros
  K_MAX_PREMIO NUMBER;
BEGIN
  K_CONT := 0; --Iniciando la variable  a 0
  K_RPTA := 1; --Inicializamos como todo verdad 1
  ------------------------------------------------
  SELECT NVL(COUNT(1), 0)
    INTO K_CONT
    FROM ADMPT_MOV_PROMOCION
   WHERE admpv_tipo_doc = K_ADMPV_TIPO_DOC
     AND admpv_num_doc = K_ADMPV_NUM_DOC;

  SELECT NVL(admpv_valor, '')
    INTO K_MAX_PREMIO
    FROM ADMPT_PARAMSIST P
   WHERE P.ADMPV_DESC = 'MAX_PREMIO_PROMO';

  IF (K_CONT >= K_MAX_PREMIO) THEN
    K_RPTA := 2;
  END IF;
  RETURN(K_RPTA);

EXCEPTION
  WHEN OTHERS THEN
    K_RPTA := 3;
    RETURN(K_RPTA);
END ADMFF_MOVIMIENTOS;

PROCEDURE ADMPSS_MOV_PROMOCION(K_ID_CANJE        IN VARCHAR2,
                               K_ADMPV_NUM_DOC   IN VARCHAR2,
                               K_ADMPV_TIPO_DOC  IN VARCHAR2,
                               K_ADMPN_ID_PROMO  IN NUMBER,
                               K_ADMPN_ID_RULETA IN VARCHAR2,
                               K_ADMPV_TPOLINEA  IN VARCHAR2,
                               K_ADMPV_ASESOR    IN VARCHAR2,
                               K_ADMPV_CAC       IN VARCHAR2,
                               K_ADMPV_NUM_LINEA IN VARCHAR2,
                               K_ADMPV_USUARIO   IN VARCHAR2,
                               K_ADMPV_COID      IN VARCHAR2,
                               K_EXITOTRANS      OUT NUMBER,
                               K_CODERROR        OUT NUMBER,
                               K_DESCERROR       OUT VARCHAR2) IS
  K_ADMPN_ID_MOVIMIENTO ADMPT_MOV_PROMOCION.ADMPN_CORRELATIVO%TYPE;
BEGIN
  ------------------------------------------------
  --Extracion del identificador del registro
  /*  SELECT NVL(MAX(TO_NUMBER(ADMPN_CORRELATIVO)), 0) + 1
  INTO K_ADMPN_ID_MOVIMIENTO
  FROM ADMPT_MOV_PROMOCION;*/
  SELECT NVL(ADMPN_CORRELATIVO.NEXTVAL, '-1')
    INTO K_ADMPN_ID_MOVIMIENTO
    FROM DUAL;
  ------------------------------------------------
  --Inicializando la variable de retorno
  K_EXITOTRANS := 0;
  K_CODERROR   := 0;
  K_DESCERROR  := '';
  ------------------------------------------------
  --Se reitro campos de usuario modifica y fecha de modificacion
  INSERT INTO ADMPT_MOV_PROMOCION
    (admpn_correlativo,
     admpn_id_canje,
     admpn_id_promo,
     admpv_id_ruleta,
     admpv_tipo_linea,
     admpv_asesor,
     admpv_cac,
     admpv_num_linea,
     admpv_num_doc,
     admpv_tipo_doc,
     admpd_fec_reg,
     admpv_usu_reg,
     admpv_coid)
  VALUES
    (K_ADMPN_ID_MOVIMIENTO,
     K_ID_CANJE,
     K_ADMPN_ID_PROMO,
     K_ADMPN_ID_RULETA,
     K_ADMPV_TPOLINEA,
     K_ADMPV_ASESOR,
     K_ADMPV_CAC,
     K_ADMPV_NUM_LINEA,
     K_ADMPV_NUM_DOC,
     K_ADMPV_TIPO_DOC,
     sysdate,
     K_ADMPV_USUARIO,
     K_ADMPV_COID);
  ------------------------------------------------
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    K_CODERROR  := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
  WHEN OTHERS THEN
    K_CODERROR  := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
    ------------------------------------------------
    IF K_CODERROR <> 0 THEN
      IF UPPER(K_DESCERROR) LIKE '%VIOLATED%' THEN
            K_EXITOTRANS := 2;
      ELSE
      K_EXITOTRANS := 1;
      END IF;
    ELSE
      K_EXITOTRANS := 0;
    END IF;

END ADMPSS_MOV_PROMOCION;

PROCEDURE ADMPSS_MOV_PROMOCION_ERR(K_ID_CANJE        IN VARCHAR2,
                               K_ADMPV_NUM_DOC   IN VARCHAR2,
                               K_ADMPV_TIPO_DOC  IN VARCHAR2,
                               K_ADMPN_ID_PROMO  IN NUMBER,
                               K_ADMPN_ID_RULETA IN VARCHAR2,
                               K_ADMPV_TPOLINEA  IN VARCHAR2,
                               K_ADMPV_ASESOR    IN VARCHAR2,
                               K_ADMPV_CAC       IN VARCHAR2,
                               K_ADMPV_NUM_LINEA IN VARCHAR2,
                               K_ADMPV_USUARIO   IN VARCHAR2,
                               K_ADMPV_COID      IN VARCHAR2,
                               K_EXITOTRANS      OUT NUMBER,
                               K_CODERROR        OUT NUMBER,
                               K_DESCERROR       OUT VARCHAR2) IS
  K_ADMPN_ID_MOVIMIENTO ADMPT_MOV_PROMOCION.ADMPN_CORRELATIVO%TYPE;
BEGIN
  ------------------------------------------------
    SELECT NVL(ADMPT_MOV_PROMOCION_ERR_SQ.NEXTVAL, '-1')
    INTO K_ADMPN_ID_MOVIMIENTO
    FROM DUAL;
  ------------------------------------------------
  --Inicializando la variable de retorno
  K_EXITOTRANS := 0;
  K_CODERROR   := 0;
  K_DESCERROR  := '';
  ------------------------------------------------
  --Se reitro campos de usuario modifica y fecha de modificacion
  INSERT INTO ADMPT_MOV_PROMOCION_ERR
    (admpn_correlativo,
     admpn_id_canje,
     admpn_id_promo,
     admpv_id_ruleta,
     admpv_tipo_linea,
     admpv_asesor,
     admpv_cac,
     admpv_num_linea,
     admpv_num_doc,
     admpv_tipo_doc,
     admpd_fec_reg,
     admpv_usu_reg,
     admpv_coid)
  VALUES
    (K_ADMPN_ID_MOVIMIENTO,
     K_ID_CANJE,
     K_ADMPN_ID_PROMO,
     K_ADMPN_ID_RULETA,
     K_ADMPV_TPOLINEA,
     K_ADMPV_ASESOR,
     K_ADMPV_CAC,
     K_ADMPV_NUM_LINEA,
     K_ADMPV_NUM_DOC,
     K_ADMPV_TIPO_DOC,
     sysdate,
     K_ADMPV_USUARIO,
     K_ADMPV_COID);
  ------------------------------------------------
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    K_CODERROR  := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
  WHEN OTHERS THEN
    K_CODERROR  := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
    ------------------------------------------------
    IF K_CODERROR <> 0 THEN
      K_EXITOTRANS := 1;
    ELSE
      K_EXITOTRANS := 0;
    END IF;

END ADMPSS_MOV_PROMOCION_ERR;

PROCEDURE ADMPSS_OBTENER_IDRULETA(K_ADMPV_TIPO_DOC IN ADMPT_TIPO_DOC.ADMPV_EQU_DWH%TYPE,
                                  K_ADMPV_NUM_DOC  IN ADMPT_CLIENTE.ADMPV_NUM_DOC%TYPE,
                                  K_ADMPV_USUARIO  IN VARCHAR2,
                                  K_ID_CANJE       IN VARCHAR2,
                                  K_ADMPV_COID     IN VARCHAR2,
                                  K_ID_RULETA      OUT VARCHAR2,
                                  K_MENSAJE        OUT VARCHAR2,
                                  K_CODERROR       OUT NUMBER,
                                  K_DESCERROR      OUT VARCHAR2)

 IS
  K_VAL_TIPODOC     NUMBER;
  K_VAL_MOVIMIENTOS NUMBER;
  K_ADMPN_ID_PROMO  NUMBER;
  K_COUNT_CANJE     NUMBER;
  K_COUNT_CANJE2    number;
  K_ADMPV_ASESOR    VARCHAR2(100);
  K_ADMPV_CAC       VARCHAR2(100);
  K_ADMPV_COD_TPOCL VARCHAR2(2);
  K_ADMPV_NUM_LINEA VARCHAR2(20);
  V_EXITO           NUMBER;
  V_MENSAJE         VARCHAR2(200);

  ERROR_REGISTRAR EXCEPTION;
  NO_EXISTE_DOCUM EXCEPTION;
  K_CODERROR_REG  NUMBER;
  K_DESCERROR_REG VARCHAR2(200);
  K_DESCERROR_REG1 VARCHAR2(200);
  K_ID_DOCUMENTO  NUMBER;
  K_NO_DOCUMENTO  NUMBER;

BEGIN
  K_CODERROR  := 0;
  K_DESCERROR := '';

  --Agregado por Henry Herrera 10:15 a.m. 20/04/2012
  SELECT COUNT(1) INTO K_NO_DOCUMENTO
  FROM   ADMPT_TIPO_DOC TD
  WHERE  LOWER(TD.ADMPV_EQU_DWH) LIKE '%' || LOWER(K_ADMPV_TIPO_DOC) || '%';

  K_NO_DOCUMENTO:=NVL(K_NO_DOCUMENTO,0);
  IF K_NO_DOCUMENTO = 0 THEN
     RAISE NO_EXISTE_DOCUM;
  END IF;

  --Agregado por Henry Herrera 10:15 a.m. 20/04/2012
  SELECT TD.ADMPV_COD_TPDOC INTO   K_ID_DOCUMENTO
  FROM   ADMPT_TIPO_DOC TD
  WHERE  LOWER(TD.ADMPV_EQU_DWH) LIKE '%' || LOWER(K_ADMPV_TIPO_DOC) || '%';


  --Validar que se trate de Tipo de Documento: DNI o CE
  IF K_ID_DOCUMENTO = '2' OR K_ID_DOCUMENTO = '4' THEN
  --IF K_ADMPV_TIPO_DOC = '2' OR K_ADMPV_TIPO_DOC = '4' THEN
    K_VAL_TIPODOC := ADMFF_TIPODOC(K_ID_DOCUMENTO, K_ADMPV_NUM_DOC);              --Agregado por Henry Herrera 10:15 a.m. 20/04/2012
    --K_VAL_TIPODOC := ADMFF_TIPODOC(K_ADMPV_TIPO_DOC, K_ADMPV_NUM_DOC);          --comentado por Henry Herrera 10:15 a.m. 20/04/2012

    IF K_VAL_TIPODOC = 1 THEN
      K_VAL_MOVIMIENTOS := ADMFF_MOVIMIENTOS(K_ID_DOCUMENTO, K_ADMPV_NUM_DOC);    --Agregado por Henry Herrera 10:15 a.m. 20/04/2012
      --K_VAL_MOVIMIENTOS := ADMFF_MOVIMIENTOS(K_ADMPV_TIPO_DOC, K_ADMPV_NUM_DOC);--comentado por Henry Herrera 10:15 a.m. 20/04/2012
      IF K_VAL_MOVIMIENTOS = 1 THEN
        --Obtenemos el ID de la promocion vigente
        BEGIN
          select admpn_id_promo
            INTO K_ADMPN_ID_PROMO
            from admpt_promocion
           where admpv_estado = 'A'
             and admpd_fec_ini <= TRUNC(sysdate)
             and admpd_fec_fin >= TRUNC(sysdate);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            K_DESCERROR      := 'No existe una promoción Activa y Vigente';
            K_CODERROR       := 1;
            K_ADMPN_ID_PROMO := null;
            K_ID_RULETA      := null;
            K_MENSAJE        := null;
            RETURN;
          WHEN TOO_MANY_ROWS THEN
            K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
            K_CODERROR  := 1;
            K_ID_RULETA := null;
            K_MENSAJE   := null;
            RETURN;
          WHEN OTHERS THEN
            K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
            K_CODERROR  := 1;
            K_ID_RULETA := null;
            K_MENSAJE   := null;
            RETURN;
        END;
        --Validamos qie exista el canje
        SELECT NVL(COUNT(*), 0)
          INTO K_COUNT_CANJE
          FROM ADMPT_CANJE
         WHERE ADMPV_ID_CANJE = K_ID_CANJE
           AND ADMPV_NUM_DOC = K_ADMPV_NUM_DOC
           AND ADMPC_TPO_OPER = 'C';

        IF K_COUNT_CANJE > 0 THEN
          --Validamos que no exista el canje en la tabla movimientos promocion
          SELECT NVL(COUNT(*), 0)
            INTO K_COUNT_CANJE2
            FROM admpt_mov_promocion
           WHERE admpn_id_canje = K_ID_CANJE
             and admpn_id_promo = K_ADMPN_ID_PROMO;

          IF K_COUNT_CANJE2 = 0 THEN
            --Obtnemos los valores del Canje
            SELECT admpv_cod_tpocl,
                   admpv_cod_aseso,
                   admpv_pto_venta,
                   admpv_num_linea
              INTO K_ADMPV_COD_TPOCL,
                   K_ADMPV_ASESOR,
                   K_ADMPV_CAC,
                   K_ADMPV_NUM_LINEA
              FROM ADMPT_CANJE C
             WHERE C.ADMPV_ID_CANJE = K_ID_CANJE;

            --Obtenemos el ID de la Ruleta
            BEGIN
              /*SELECT admpv_id_ruleta
                INTO K_ID_RULETA
                FROM ADMPT_ALFANUMERICO
               WHERE (admpv_estado IS NULL OR admpv_estado <> 'U')
                 AND admpn_id_promo = K_ADMPN_ID_PROMO
                 AND ROWNUM < 2;*/

                 SELECT admpv_id_ruleta
                 INTO K_ID_RULETA
                 FROM (
                  select T.ADMPN_CORRELATIVO/2 AS NUM,t.admpv_id_ruleta
                  from admpt_alfanumerico t
                  WHERE (admpv_estado IS NULL OR admpv_estado <> 'U')
                  AND admpn_id_promo = K_ADMPN_ID_PROMO
                  AND ROWNUM<(select dbms_random.value(1,100000)  num from dual)
                  ORDER BY 1 DESC
                  ) WHERE ROWNUM<2 ;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                K_DESCERROR := 'No existe un Alfanumérico disponible';
                K_CODERROR  := 1;
                K_ID_RULETA := null;
                K_MENSAJE   := null;
                RETURN;
              WHEN OTHERS THEN
                K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
                K_CODERROR  := 1;
                K_ID_RULETA := null;
                K_MENSAJE   := null;
                RETURN;
            END;
            --Insertamos en la Tabla Movimientos
            BEGIN
              --Agregado  por Henry Herrera 10:15 a.m. 20/04/2012
              ADMPSS_MOV_PROMOCION(K_ID_CANJE,
                                   K_ADMPV_NUM_DOC,
                                   K_ID_DOCUMENTO,
                                   K_ADMPN_ID_PROMO,
                                   K_ID_RULETA,
                                   K_ADMPV_COD_TPOCL,
                                   K_ADMPV_ASESOR,
                                   K_ADMPV_CAC,
                                   K_ADMPV_NUM_LINEA,
                                   K_ADMPV_USUARIO,
                                   K_ADMPV_COID,
                                   V_EXITO,
                                   K_CODERROR_REG,
                                   K_DESCERROR_REG);


              IF V_EXITO > 0 THEN
                IF V_EXITO=2 THEN
                    BEGIN
                        SELECT admpv_id_ruleta
                         INTO K_ID_RULETA
                         FROM (
                          select T.ADMPN_CORRELATIVO/2 AS NUM,t.admpv_id_ruleta
                          from admpt_alfanumerico t
                          WHERE (admpv_estado IS NULL OR admpv_estado <> 'U')
                          AND admpn_id_promo = K_ADMPN_ID_PROMO
                          AND ROWNUM<(select dbms_random.value(1,100000)  num from dual)
                          ORDER BY 1 DESC
                          ) WHERE ROWNUM<2 ;

                         ADMPSS_MOV_PROMOCION(K_ID_CANJE,
                                       K_ADMPV_NUM_DOC,
                                       K_ID_DOCUMENTO,
                                       K_ADMPN_ID_PROMO,
                                       K_ID_RULETA,
                                       K_ADMPV_COD_TPOCL,
                                       K_ADMPV_ASESOR,
                                       K_ADMPV_CAC,
                                       K_ADMPV_NUM_LINEA,
                                       K_ADMPV_USUARIO,
                                       K_ADMPV_COID,
                                       V_EXITO,
                                       K_CODERROR_REG,
                                       K_DESCERROR_REG);

                         IF V_EXITO = 0 THEN
                           UPDATE ADMPT_ALFANUMERICO
                             SET admpv_estado = 'U'
                           WHERE admpv_id_ruleta = K_ID_RULETA
                             AND admpn_id_promo = K_ADMPN_ID_PROMO;

                             SELECT NVL(admpv_descripcion,'')
                              INTO V_MENSAJE
                              FROM ADMPT_MENSAJE M
                              WHERE M.ADMPV_VALOR='PROMOCIONRULETA';

                              --Se genera el mensaje que sera enviado al Cliente
                              K_MENSAJE := REPLACE(V_MENSAJE, '{1}', K_ID_RULETA);

                              COMMIT;
                          ELSE
                              ROLLBACK;

                              ADMPSS_MOV_PROMOCION_ERR(K_ID_CANJE,
                                       K_ADMPV_NUM_DOC,
                                       K_ID_DOCUMENTO,
                                       K_ADMPN_ID_PROMO,
                                       K_ID_RULETA,
                                       K_ADMPV_COD_TPOCL,
                                       K_ADMPV_ASESOR,
                                       K_ADMPV_CAC,
                                       K_ADMPV_NUM_LINEA,
                                       K_ADMPV_USUARIO,
                                       K_ADMPV_COID,
                                       V_EXITO,
                                       K_CODERROR_REG,
                                       K_DESCERROR_REG1);
                           COMMIT;
                              K_DESCERROR := K_DESCERROR_REG;
                              K_CODERROR  := 1;
                              K_ID_RULETA := null;
                              K_MENSAJE   := null;
                          END IF;
                      EXCEPTION
                          WHEN OTHERS THEN
                          K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
                          K_CODERROR  := 1;
                          K_ID_RULETA := null;
                          K_MENSAJE   := null;
                          ROLLBACK;
                      END;

                ELSE
                RAISE ERROR_REGISTRAR;
                END IF;
              ELSE

                --Actualizo el estado del Alfanumerico
                UPDATE ADMPT_ALFANUMERICO
                   SET admpv_estado = 'U'
                 WHERE admpv_id_ruleta = K_ID_RULETA
               AND admpn_id_promo = K_ADMPN_ID_PROMO;

                COMMIT;
                --Obtenemos el mensaje
                SELECT NVL(admpv_descripcion,'')
                INTO V_MENSAJE
                FROM ADMPT_MENSAJE M
                WHERE M.ADMPV_VALOR='PROMOCIONRULETA';

                --Se genera el mensaje que sera enviado al Cliente
                K_MENSAJE := REPLACE(V_MENSAJE, '{1}', K_ID_RULETA);

              END IF;
            EXCEPTION
              WHEN ERROR_REGISTRAR THEN
                K_DESCERROR := K_DESCERROR_REG;
                K_CODERROR  := 1;
                K_ID_RULETA := null;
                K_MENSAJE   := null;
                ROLLBACK;
              WHEN OTHERS THEN
                K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
                K_CODERROR  := 1;
                K_ID_RULETA := null;
                K_MENSAJE   := null;
                ROLLBACK;
            END;
          ELSE
            K_DESCERROR := 'Ya se asignó un ID Ruleta para el canje indicado';
            K_CODERROR  := 1;
            K_ID_RULETA := null;
            K_MENSAJE   := null;
          END IF;

        ELSE
          K_DESCERROR := 'El ID Canje no es válido';
          K_CODERROR  := 1;
          K_ID_RULETA := null;
          K_MENSAJE   := null;
        END IF;

      ELSIF K_VAL_MOVIMIENTOS = 2 THEN
        K_DESCERROR := 'El Cliente realizó más movimientos de los permitidos';
        K_CODERROR  := 1;
        K_ID_RULETA := null;
        K_MENSAJE   := null;
      END IF;

    ELSE
      K_DESCERROR := 'El Cliente no existe';
      K_CODERROR  := 1;
      K_ID_RULETA := null;
      K_MENSAJE   := null;
    END IF;

  ELSE
    K_DESCERROR := 'Tipo de documento no válido';
    K_CODERROR  := 1;
    K_ID_RULETA := null;
    K_MENSAJE   := null;
  END IF;

EXCEPTION
  WHEN NO_EXISTE_DOCUM THEN
    K_DESCERROR:='No se encuentra documento';
    K_CODERROR  := 1;
    K_ID_RULETA := null;
    K_MENSAJE   := null;
  WHEN OTHERS THEN
    K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
    K_CODERROR  := 1;
    K_ID_RULETA := null;
    K_MENSAJE   := null;
    ROLLBACK;
END ADMPSS_OBTENER_IDRULETA;

PROCEDURE ADMPSS_PROCESAR_PREMIO(K_ADMPV_ID_RULETA  IN VARCHAR2,
                                 K_ADMPN_ID_PREMIO  IN ADMPT_PREMIO_PROMO.ADMPN_ID_PREMIO%TYPE,
                                 K_ADMPV_USUARIO    IN VARCHAR2,
                                 K_ADMPV_NUM_LINEA  OUT VARCHAR2,
                                 K_ADMPV_TIPO_LINEA OUT VARCHAR2,
                                 K_ADMPN_MNRECARGA  OUT NUMBER,
                                 K_ADMPV_CODSERV    OUT VARCHAR2,
                                 K_ADMPV_ENV_SMS    OUT VARCHAR2,
                                 K_ADMPV_SMS_MSJ    OUT VARCHAR2,
                                 K_ADMPN_ID_TPREMIO OUT NUMBER,
                                 K_ADMPV_COID       OUT VARCHAR2,
                                 K_CODERROR         OUT NUMBER,
                                 K_DESCERROR        OUT VARCHAR2)

 IS
  V_ID_KARDEX        NUMBER;
  V_COD_CPTO         NUMBER;
  K_ADMPN_PUNTOS     NUMBER;
  K_COUNT_MOVRUL     NUMBER;
  K_ADMPV_COD_CLI    VARCHAR2(200);
  K_ADMPN_ID_PROMO   NUMBER;
  K_CANT_PROMO       NUMBER;
  K_DES_PROMO        VARCHAR2(200);
  V_ADMPV_SMS_MSJ    VARCHAR2(200);
  V_ADMPV_PREMIO_SMS VARCHAR2(200);

BEGIN
  K_ADMPV_NUM_LINEA  := null;
  K_ADMPV_TIPO_LINEA := null;
  K_ADMPN_MNRECARGA  := null;
  K_ADMPV_CODSERV    := null;
  K_ADMPV_ENV_SMS    := null;
  K_ADMPV_SMS_MSJ    := null;
  K_ADMPN_ID_TPREMIO := null;
  K_CODERROR         := 0;
  K_DESCERROR        := '';

  --Detalle de la Promocion a la que pertenece el idPremio
  BEGIN
    SELECT admpn_id_promo
      INTO K_ADMPN_ID_PROMO
      FROM ADMPT_PREMIO_PROMO
     WHERE ADMPN_ID_PREMIO = K_ADMPN_ID_PREMIO;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      K_CODERROR  := 1;
      K_DESCERROR := 'No existen datos del ID Premio indicado';
      return;
    WHEN OTHERS THEN
      K_CODERROR  := 1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
      return;
  END;

  SELECT NVL(COUNT(*), 0)
    INTO K_CANT_PROMO
    FROM ADMPT_PROMOCION
   WHERE admpn_id_promo = K_ADMPN_ID_PROMO
     AND admpv_estado = 'A'
     and admpd_fec_ini <= TRUNC(sysdate)
     and admpd_fec_fin >= TRUNC(sysdate);

  IF K_CANT_PROMO > 0 THEN
    --OBTENGO LOS DATOS DEL CLIENTE
    BEGIN
      SELECT ADMPV_COD_CLI, ADMPV_NUM_LINEA, admpv_cod_tpocl
        INTO K_ADMPV_COD_CLI, K_ADMPV_NUM_LINEA, K_ADMPV_TIPO_LINEA
        FROM ADMPT_CANJE
       WHERE ADMPV_ID_CANJE =
             (SELECT ADMPN_ID_CANJE
                FROM ADMPT_MOV_PROMOCION
               WHERE ADMPV_ID_RULETA = K_ADMPV_ID_RULETA
                 and admpn_id_promo = K_ADMPN_ID_PROMO);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        K_CODERROR  := 1;
        K_DESCERROR := 'No existen datos con el ID Ruleta ingresado';
        return;
      WHEN OTHERS THEN
        K_CODERROR  := 1;
        K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
        return;
    END;

    --Validamos que no se haya procesado el premio para el ID Ruleta señalado

    SELECT NVL(COUNT(*), 0)
      INTO K_COUNT_MOVRUL
      FROM admpt_mov_promocion
     WHERE admpv_id_ruleta = K_ADMPV_ID_RULETA
       and admpn_id_promo = K_ADMPN_ID_PROMO
       and (admpv_id_premio = '' or admpv_id_premio is null);

  /**/

    IF K_COUNT_MOVRUL > 0 THEN
      --ACTUALIZAR EN LA TABLA DE MOVIMIENTOS
      UPDATE ADMPT_MOV_PROMOCION
         SET ADMPV_ID_PREMIO  = K_ADMPN_ID_PREMIO,
             admpd_fec_premio = SYSDATE,
             admpv_usu_mod    = K_ADMPV_USUARIO,
             admpd_fec_mod    = SYSDATE
       WHERE ADMPV_ID_RULETA = K_ADMPV_ID_RULETA
         and admpn_id_promo = K_ADMPN_ID_PROMO;
      COMMIT;
      --Obtengo datos del premio
      BEGIN
        SELECT ADMPN_ID_TPREMIO,
               ADMPN_PUNTOS,
               ADMPN_MNRECARGA,
               ADMPV_CODSERV,
               ADMPV_PREMIO_SMS
          INTO K_ADMPN_ID_TPREMIO,
               K_ADMPN_PUNTOS,
               K_ADMPN_MNRECARGA,
               K_ADMPV_CODSERV,
               V_ADMPV_PREMIO_SMS
          FROM ADMPT_PREMIO_PROMO
         WHERE ADMPN_ID_PREMIO = K_ADMPN_ID_PREMIO
           and admpn_id_promo = K_ADMPN_ID_PROMO;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          K_CODERROR         := 1;
          K_DESCERROR        := 'No existen datos del ID Premio indicado';
          K_ADMPV_NUM_LINEA  := null;
          K_ADMPV_TIPO_LINEA := null;
          K_ADMPN_MNRECARGA  := null;
          K_ADMPV_SMS_MSJ    := null;
          K_ADMPV_ENV_SMS    := null;
          return;
        WHEN OTHERS THEN
          K_CODERROR         := 1;
          K_DESCERROR        := SUBSTR(SQLERRM, 1, 400);
          K_ADMPV_NUM_LINEA  := null;
          K_ADMPV_TIPO_LINEA := null;
          K_ADMPN_MNRECARGA  := null;
          K_ADMPV_SMS_MSJ    := null;
          K_ADMPV_ENV_SMS    := null;
          return;
      END;
      --Obtengo el parametro K_ADMPV_ENV_SMS
      SELECT nvl(admpv_env_sms, null)
        INTO K_ADMPV_ENV_SMS
        FROM ADMPT_TIP_PREMIOPROMO
       WHERE admpn_id_tpremio = K_ADMPN_ID_TPREMIO;

      --Obtengo el codigo de Contrato
      SELECT NVL(admpv_coid,null)
      INTO K_ADMPV_COID
      FROM admpt_mov_promocion
     WHERE admpv_id_ruleta = K_ADMPV_ID_RULETA
       and admpn_id_promo = K_ADMPN_ID_PROMO;

      IF K_ADMPN_ID_TPREMIO = 1 THEN
        IF K_ADMPV_TIPO_LINEA = '1' OR K_ADMPV_TIPO_LINEA = '2' THEN
          --Obtengo el Codigo de concepto para Postpago
          SELECT NVL(ADMPV_COD_CPTO, '-1')
            INTO V_COD_CPTO
            FROM ADMPT_CONCEPTO
           WHERE ADMPV_DESC = 'PROMOCIONES CC';
        ELSIF K_ADMPV_TIPO_LINEA = '3' THEN
          --Obtengo el Codigo de concepto para Prepago
          SELECT NVL(ADMPV_COD_CPTO, '-1')
            INTO V_COD_CPTO
            FROM ADMPT_CONCEPTO
           WHERE ADMPV_DESC = 'PROMO PREPAGO';
        END IF;
        --obtengo la descripcion de la promocion
        SELECT admpv_promocion
          INTO K_DES_PROMO
          FROM ADMPT_PROMOCION
         WHERE admpn_id_promo = K_ADMPN_ID_PROMO;
        --Inserto un registro en la tabla Kardex
        SELECT NVL(ADMPT_KARDEX_SQ.NEXTVAL, '-1')
          INTO V_ID_KARDEX
          FROM DUAL;
        INSERT INTO ADMPT_KARDEX
          (ADMPN_ID_KARDEX,
           ADMPN_COD_CLI_IB,
           ADMPV_COD_CLI,
           ADMPV_COD_CPTO,
           ADMPD_FEC_TRANS,
           ADMPN_PUNTOS,
           ADMPV_NOM_ARCH,
           ADMPC_TPO_OPER,
           ADMPC_TPO_PUNTO,
           ADMPN_SLD_PUNTO,
           ADMPC_ESTADO,
           ADMPV_DESC_PROM)
        VALUES
          (V_ID_KARDEX,
           '',
           K_ADMPV_COD_CLI,
           V_COD_CPTO,
           TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
           K_ADMPN_PUNTOS,
           NULL,
           'E',
           'C',
           K_ADMPN_PUNTOS,
           'A',
           K_DES_PROMO);
        --Actualizo en la tabla Saldos
        UPDATE ADMPT_SALDOS_CLIENTE
           SET ADMPN_SALDO_CC = K_ADMPN_PUNTOS +
                                (SELECT NVL(ADMPN_SALDO_CC, 0)
                                   FROM ADMPT_SALDOS_CLIENTE
                                  WHERE ADMPV_COD_CLI = K_ADMPV_COD_CLI)
         WHERE ADMPV_COD_CLI = K_ADMPV_COD_CLI;
        COMMIT;

        --Obtengo el parametro K_ADMPV_SMS_MSJ
        SELECT nvl(admpv_sms_msj, NULL)
          INTO V_ADMPV_SMS_MSJ
          FROM ADMPT_TIP_PREMIOPROMO
         WHERE admpn_id_tpremio = K_ADMPN_ID_TPREMIO;
        IF V_ADMPV_SMS_MSJ is not null THEN
          K_ADMPV_SMS_MSJ := REPLACE(V_ADMPV_SMS_MSJ, '{1}', K_ADMPN_PUNTOS);
        ELSE
          K_ADMPV_SMS_MSJ := null;
        END IF;
      ELSIF K_ADMPN_ID_TPREMIO = 2 THEN
        --Obtengo el parametro K_ADMPV_SMS_MSJ
        SELECT nvl(admpv_sms_msj, NULL)
          INTO V_ADMPV_SMS_MSJ
          FROM ADMPT_TIP_PREMIOPROMO
         WHERE admpn_id_tpremio = K_ADMPN_ID_TPREMIO;
        IF V_ADMPV_SMS_MSJ IS NOT NULL THEN
          K_ADMPV_SMS_MSJ := REPLACE(V_ADMPV_SMS_MSJ,
                                     '{1}',
                                     V_ADMPV_PREMIO_SMS);
        ELSE
          K_ADMPV_SMS_MSJ := null;
        END IF;
      END IF;
    ELSE
      K_CODERROR         := 1;
      K_DESCERROR        := 'Ya se entregó el Premio para el ID Ruleta indicado';
      K_ADMPV_NUM_LINEA  := null;
      K_ADMPV_TIPO_LINEA := null;
      K_ADMPN_MNRECARGA  := null;
      K_ADMPV_SMS_MSJ    := null;
      K_ADMPV_ENV_SMS    := null;
      return;
    END IF;
  ELSE
    K_CODERROR         := 1;
    K_DESCERROR        := 'El ID Premio pertenece a una Promoción no vigente';
    K_ADMPV_NUM_LINEA  := null;
    K_ADMPV_TIPO_LINEA := null;
    K_ADMPN_MNRECARGA  := null;
    K_ADMPV_SMS_MSJ    := null;
    K_ADMPV_ENV_SMS    := null;
    return;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR         := 1;
    K_DESCERROR        := SUBSTR(SQLERRM, 1, 400);
    K_ADMPV_NUM_LINEA  := null;
    K_ADMPV_TIPO_LINEA := null;
    K_ADMPN_MNRECARGA  := null;
    K_ADMPV_SMS_MSJ    := null;
    K_ADMPV_ENV_SMS    := null;
    ROLLBACK;

END ADMPSS_PROCESAR_PREMIO;

PROCEDURE ADMPSS_REVOKE_PREMIO(K_ADMPV_ID_RULETA IN VARCHAR2,
                               K_ADMPV_USUARIO   IN VARCHAR2,
                               K_CODERROR        OUT NUMBER,
                               K_DESCERROR       OUT VARCHAR2)

 IS
  K_ADMPN_ID_PROMO NUMBER;
  K_CANT_PROMO     NUMBER;
  V_EXISTE         NUMBER;

BEGIN
  K_CODERROR  := 0;
  K_DESCERROR := '';

  --Obtengo el ID Promo del ID Ruleta enviado
  SELECT NVL(ADMPN_ID_PROMO, null)
    INTO K_ADMPN_ID_PROMO
    FROM ADMPT_MOV_PROMOCION
   WHERE ADMPV_ID_RULETA = K_ADMPV_ID_RULETA;

  --Valido que la promoción este vigente
  SELECT NVL(COUNT(*), 0)
    INTO K_CANT_PROMO
    FROM ADMPT_PROMOCION
   WHERE admpn_id_promo = K_ADMPN_ID_PROMO
     AND admpv_estado = 'A'
     and admpd_fec_ini <= TRUNC(sysdate)
     and admpd_fec_fin >= TRUNC(sysdate);

  IF K_CANT_PROMO > 0 THEN
    SELECT NVL(count(*), 0)
      INTO V_EXISTE
      FROM ADMPT_MOV_PROMOCION
     WHERE ADMPV_ID_RULETA = K_ADMPV_ID_RULETA
       and admpn_id_promo = K_ADMPN_ID_PROMO;

    IF V_EXISTE > 0 THEN
      --ACTUALIZAR EN LA TABLA DE MOVIMIENTOS
      UPDATE ADMPT_MOV_PROMOCION
         SET ADMPV_ID_PREMIO  = '',
             admpd_fec_premio = null,
             admpv_usu_mod    = K_ADMPV_USUARIO,
             admpd_fec_mod    = SYSDATE
       WHERE ADMPV_ID_RULETA = K_ADMPV_ID_RULETA
         and admpn_id_promo = K_ADMPN_ID_PROMO;
      COMMIT;
    ELSE
      K_CODERROR  := 1;
      K_DESCERROR := 'No existen datos con el ID Ruleta ingresado';
    END IF;
  ELSE
    K_CODERROR  := 1;
    K_DESCERROR := 'El ID Ruleta que desea devolver no pertenece a una promoción Vigente';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR  := 1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
    ROLLBACK;

END ADMPSS_REVOKE_PREMIO;

PROCEDURE ADMPSS_REVOKE_IDRULETA(K_ADMPV_ID_RULETA IN VARCHAR2,
                                 K_CODERROR        OUT NUMBER,
                                 K_DESCERROR       OUT VARCHAR2)

 IS
  K_ADMPN_ID_PROMO NUMBER;
  K_CANT_PROMO     NUMBER;
  V_EXISTE         NUMBER;

BEGIN
  K_CODERROR  := 0;
  K_DESCERROR := '';

  --Obtengo el ID Promo del ID Ruleta enviado
  SELECT NVL(ADMPN_ID_PROMO, null)
    INTO K_ADMPN_ID_PROMO
    FROM ADMPT_MOV_PROMOCION
   WHERE ADMPV_ID_RULETA = K_ADMPV_ID_RULETA;

  --Valido que la promoción este vigente
  SELECT NVL(COUNT(*), 0)
    INTO K_CANT_PROMO
    FROM ADMPT_PROMOCION
   WHERE admpn_id_promo = K_ADMPN_ID_PROMO
     AND admpv_estado = 'A'
     and admpd_fec_ini <= TRUNC(sysdate)
     and admpd_fec_fin >= TRUNC(sysdate);

  IF K_CANT_PROMO > 0 THEN
    SELECT NVL(count(*), 0)
      INTO V_EXISTE
      FROM ADMPT_MOV_PROMOCION
     WHERE ADMPV_ID_RULETA = K_ADMPV_ID_RULETA
       and admpn_id_promo = K_ADMPN_ID_PROMO;

    IF V_EXISTE > 0 THEN
      --ACTUALIZAR EN LA TABLA DE MOVIMIENTOS
      DELETE FROM ADMPT_MOV_PROMOCION
       WHERE ADMPV_ID_RULETA = K_ADMPV_ID_RULETA
         and admpn_id_promo = K_ADMPN_ID_PROMO;

      --Actualizo el estado del Alfanumerico
      UPDATE ADMPT_ALFANUMERICO
         SET admpv_estado = ''
       WHERE admpv_id_ruleta = K_ADMPV_ID_RULETA
         AND admpn_id_promo = K_ADMPN_ID_PROMO;
      COMMIT;
    ELSE
      K_CODERROR  := 1;
      K_DESCERROR := 'No existen datos con el ID Ruleta ingresado';
    END IF;
  ELSE
    K_CODERROR  := 1;
    K_DESCERROR := 'El ID Ruleta que desea devolver no pertenece a una promoción Vigente';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR  := 1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
    ROLLBACK;

END ADMPSS_REVOKE_IDRULETA;

PROCEDURE ADMPSS_LISTAR_PREMIOS_PROMO(P_RESULTADO OUT K_REF_CURSOR) IS
BEGIN
  OPEN P_RESULTADO FOR
    SELECT pp.admpn_id_premio CodPremio, pp.admpv_despremio Descripcion
      FROM ADMPT_PREMIO_PROMO pp, admpt_promocion p
     where pp.admpn_id_promo = p.admpn_id_promo
       and p.admpv_estado = 'A'
       and p.admpd_fec_fin >= TRUNC(sysdate)
     order BY admpn_id_premio;
END;

--------------------------------------------------------------------
--------------------------------------------------------------------

PROCEDURE ADMPSS_VALIDARPROMOCION(K_ADMPN_ID_PROMO OUT NUMBER,
                                  K_CODERROR       OUT NUMBER,
                                  K_DESCERROR      OUT VARCHAR2) IS
  --------------------------------------------------------------------------
  --  Nombre          :   ADMPSS_VALIDARPROMOCION
  --  Proposito       :   Obtener la promocion actual y validar esta misma
  --                  :
  --  Version         : 1.0
  --  Fecha Creacion  : 05/04/2012
  --  Autor           : Henry Herrera
  --------------------------------------------------------------------------
  K_FECHA  DATE;
  K_CUENTA NUMBER;
BEGIN
  K_CODERROR  := 0;
  K_DESCERROR := '';
  K_FECHA     := trunc(SYSDATE);

  SELECT COUNT(1)
    INTO K_CUENTA
    FROM ADMPT_PROMOCION
   WHERE ADMPV_ESTADO = 'A'
     AND K_FECHA >= ADMPD_FEC_INI
     AND K_FECHA <= ADMPD_FEC_FIN;

  IF K_CUENTA = 1 THEN
    SELECT ADMPN_ID_PROMO
      INTO K_ADMPN_ID_PROMO
      FROM ADMPT_PROMOCION
     WHERE ADMPV_ESTADO = 'A'
       AND K_FECHA >= ADMPD_FEC_INI
       AND K_FECHA <= ADMPD_FEC_FIN;
  ELSIF K_CUENTA > 1 THEN
    K_CODERROR  := 1;
    K_DESCERROR := 'Existen mucha promociones activas para la fecha';
  ELSIF K_CUENTA = 0 THEN
    K_CODERROR  := 1;
    K_DESCERROR := 'No existen promociones activas para la fecha indicadas';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR  := 1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 400);

END;

PROCEDURE ADMPSS_STATUS_PROVINCIA(K_ADMPV_NUM_LINEA IN VARCHAR2,
                                  K_TIP_LINEA       IN VARCHAR2,
                                  K_USUARIOPROMO    OUT VARCHAR2,
                                  K_ESPROVINCIA     OUT NUMBER,
                                  K_CODERROR        OUT NUMBER,
                                  K_DESCERROR       OUT VARCHAR2) IS
  --------------------------------------------------------------------------
  ----  Nombre        :   ADMPSS_STATUS_PROVINCIA
  --  Proposito       :   Validar si el numero de linea es provicia o lima
  --                  :
  --  Version         : 1.0
  --  Fecha Creacion  : 05/04/2012
  --  Autor           : Henry Herrera
  --------------------------------------------------------------------------
  NO_EXISTE_DATAWARE EXCEPTION;
  NO_EXISTE_DEPARTAM EXCEPTION;
  NO_EXISTE_NOMBRECL EXCEPTION;
  CANTIDA      NUMBER;
  K_NUEVO_TIPO NUMBER;

BEGIN
  K_CODERROR  := 0;
  K_DESCERROR := '';
  --Convercion de tipo de linea
  IF K_TIP_LINEA = 1 THEN
    K_NUEVO_TIPO := 2; --CLIENTE CONTROL
  ELSIF K_TIP_LINEA = 2 THEN
    K_NUEVO_TIPO := 3; --CLIENTES POSTPAGO
  ELSIF K_TIP_LINEA = 3 THEN
    K_NUEVO_TIPO := 1; --CLIENTES PREPAGO
  END IF;

  SELECT COUNT(1)
    INTO CANTIDA
    FROM dm.ods_base_abonados@dbl_reptdm_d
   --WHERE SUBSTR(msisdn, 3) = K_ADMPV_NUM_LINEA
   WHERE msisdn = '51'||K_ADMPV_NUM_LINEA
     AND IDSEGMENTO = K_NUEVO_TIPO
     AND ROWNUM < 2;

  CANTIDA := NVL(CANTIDA, 0);

  IF CANTIDA = 0 THEN
    RAISE NO_EXISTE_DATAWARE;
  END IF;

  SELECT IDDEPARTAMENTO, NOMBRES
    INTO K_ESPROVINCIA, K_USUARIOPROMO
    FROM dm.ods_base_abonados@dbl_reptdm_d
   --WHERE SUBSTR(msisdn, 3) = K_ADMPV_NUM_LINEA
   WHERE msisdn = '51'||K_ADMPV_NUM_LINEA
     AND IDSEGMENTO = K_NUEVO_TIPO
     AND ROWNUM < 2;

  K_USUARIOPROMO := NVL(K_USUARIOPROMO, '');
  IF (NVL(K_USUARIOPROMO, 'X') = 'X') THEN
    RAISE NO_EXISTE_NOMBRECL;
  END IF;

  --Verificamos si existe el departamento su descripcion
  SELECT COUNT(1)
    INTO CANTIDA
    FROM dm.dw_sus_d_departamento@dbl_reptdm_d
   WHERE IDDEPARTAMENTO = K_ESPROVINCIA;

  IF CANTIDA = 0 THEN
    RAISE NO_EXISTE_DEPARTAM;
  END IF;

  IF K_ESPROVINCIA <> 11 THEN
    K_ESPROVINCIA := 1;
  ELSE
    K_ESPROVINCIA := 0;
  END IF;

EXCEPTION
  WHEN NO_EXISTE_DEPARTAM THEN
    K_CODERROR     := 1;
    K_DESCERROR    := 'No existe el departamento o no tiene descripción';
    K_USUARIOPROMO := NULL;
    K_ESPROVINCIA  := NULL;
  WHEN NO_EXISTE_NOMBRECL THEN
    K_CODERROR     := 1;
    K_DESCERROR    := 'No existe nombre del cliente, se encuentra vacio es null';
    K_USUARIOPROMO := NULL;
    K_ESPROVINCIA  := NULL;
  WHEN NO_EXISTE_DATAWARE THEN
    K_CODERROR     := 1;
    K_DESCERROR    := 'El numero de linea no se encuentra en la base de datos';
    K_USUARIOPROMO := NULL;
    K_ESPROVINCIA  := NULL;
  WHEN OTHERS THEN
    K_CODERROR    := SQLCODE;
    K_DESCERROR   := SUBSTR(SQLERRM, 1, 400);
    K_ESPROVINCIA := -1;
END;



FUNCTION ADMPSS_EXISTE_MOVIMIENTO(K_ADMPN_ALFANUMERICO VARCHAR2,
                                  K_ADMPN_ID_PROMO     NUMBER)
  RETURN NUMBER IS
  --------------------------------------------------------------------------
  --  Nombre          :   ADMPSS_EXISTE_MOVIMIENTO
  --  Proposito       :   Validar si el alfanumero existe en los movimientos segun la promocion
  --                  :
  --  Version         : 1.0
  --  Fecha Creacion  : 05/04/2012
  --  Autor           : Henry Herrera
  --------------------------------------------------------------------------
  CANTIDAD NUMBER;
BEGIN
  --------------------------------
  --Si la cantidad es mayor que 0 es porque el movimiento existe
  --caso contrario el movimiento no existe y no se procede al los premios
  --------------------------------
  SELECT COUNT(1)
    INTO CANTIDAD
    FROM ADMPT_MOV_PROMOCION
   WHERE ADMPV_ID_RULETA = K_ADMPN_ALFANUMERICO
     AND ADMPN_ID_PROMO = K_ADMPN_ID_PROMO;
  --------------------------------
  CANTIDAD := NVL(CANTIDAD, 0);
  --------------------------------
  RETURN CANTIDAD;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END;



PROCEDURE ADMPSS_GET_LINEA(   K_ADMPN_ALFANUMERICO IN  VARCHAR2
                           ,  K_ADMPN_ID_PROMO     IN  NUMBER
                           ,  K_NUM_LINEA          OUT VARCHAR2
                           ,  K_TIP_LINEA          OUT VARCHAR2
                           ,  K_CODE_CONTRATO      OUT VARCHAR2
                           ,  K_CODERROR           OUT NUMBER
                           ,  K_DESCERROR          OUT VARCHAR2)  IS
--------------------------------------------------------------------------
--  Nombre          :   ADMPSS_GET_LINEA
--  Proposito       :   Obteniendo el numero de linea y tipo de linea dado el correlativo
--                  :
--  Version         : 1.0
--  Fecha Creacion  : 05/04/2012
--  Autor           : Henry Herrera
--------------------------------------------------------------------------
NO_EXISTE_MOVIMIENT    EXCEPTION;     --No se encuentra registrado en los movimientos
NO_EXISTE_NUM_LINEA    EXCEPTION;     --El numero de linea es vacio o nula
NO_EXISTE_TIP_LINEA    EXCEPTION;     --El tipo de linea es direferente postpago, prepago, nulo
NO_EXISTE_COD_CONTRATO EXCEPTION;     --No existe codigo de contrato
CANTIDAD    NUMBER;

BEGIN
  K_CODERROR:=0;
  K_DESCERROR:=0;
  --------------------------------
  SELECT COUNT(1)INTO CANTIDAD
  FROM   ADMPT_MOV_PROMOCION
  WHERE     ADMPV_ID_RULETA = K_ADMPN_ALFANUMERICO
        AND ADMPN_ID_PROMO  = K_ADMPN_ID_PROMO;
  Cantidad:=NVL(Cantidad,0);
  --------------------------------
  IF CANTIDAD =0 THEN
    RAISE NO_EXISTE_MOVIMIENT;
  END IF;
  --------------------------------
  SELECT   ADMPV_NUM_LINEA
          ,ADMPV_TIPO_LINEA
          ,ADMPV_COID
          INTO
           K_NUM_LINEA
          ,K_TIP_LINEA
          ,K_CODE_CONTRATO
  FROM   ADMPT_MOV_PROMOCION
  WHERE     ADMPV_ID_RULETA = K_ADMPN_ALFANUMERICO
        AND ADMPN_ID_PROMO  = K_ADMPN_ID_PROMO;
  --------------------------------
  K_NUM_LINEA:=TRIM(NVL(K_NUM_LINEA,''));
  K_TIP_LINEA:=TRIM(NVL(K_TIP_LINEA,''));
  --------------------------------
  IF LENGTH(K_NUM_LINEA)=0 THEN
     RAISE NO_EXISTE_NUM_LINEA;
  END IF;
  --------------------------------
  IF LENGTH(K_TIP_LINEA)>0 THEN
    IF NOT (K_TIP_LINEA='1' OR K_TIP_LINEA='2' OR K_TIP_LINEA='3') THEN
      RAISE  NO_EXISTE_TIP_LINEA;
    END IF;
  ELSE
   RAISE  NO_EXISTE_TIP_LINEA;
  END IF;

  IF K_TIP_LINEA=2 THEN
    IF( NVL(K_CODE_CONTRATO,'X')='X' ) THEN
       RAISE NO_EXISTE_COD_CONTRATO;
    END IF;
  END IF;

  EXCEPTION
     --Validando si existe movimiento
    WHEN NO_EXISTE_COD_CONTRATO THEN
       K_CODERROR:=1;
       K_DESCERROR:='No se encuentra el codigo de contrato o es un campo vacio';
       K_NUM_LINEA:=NULL;
       K_TIP_LINEA:=NULL;
       K_CODE_CONTRATO:=NULL;
    WHEN NO_EXISTE_MOVIMIENT THEN
      K_CODERROR:=1;
      K_DESCERROR:='No se registro este movimiento';
      K_NUM_LINEA:=NULL;
      K_TIP_LINEA:=NULL;
      K_CODE_CONTRATO:=NULL;
    --Validando el tipo de linea
    WHEN NO_EXISTE_TIP_LINEA THEN
      K_CODERROR:=1;
      K_DESCERROR:='La linea no tiene un tipo postpago o prepago';
      K_NUM_LINEA:=NULL;
      K_TIP_LINEA:=NULL;
      K_CODE_CONTRATO:=NULL;
    --Validando el numero de linea
    WHEN NO_EXISTE_NUM_LINEA THEN
      K_CODERROR:=1;
      K_DESCERROR:='El numero de linea se encuentra vacio';
      K_NUM_LINEA:=NULL;
      K_TIP_LINEA:=NULL;
      K_CODE_CONTRATO:=NULL;
    --En caso cualquier otro no estudiado
    WHEN OTHERS THEN
      K_CODERROR:=1;
      K_DESCERROR:=SUBSTR(SQLERRM,1,400);
      K_NUM_LINEA:=NULL;
      K_TIP_LINEA:=NULL;
      K_CODE_CONTRATO:=NULL;
END;

PROCEDURE ADMPSS_GET_NOT_PREMIOS (   K_ADMPV_ALFANUMERICO  IN VARCHAR2
                                   , K_CURPREMIOS         OUT PKG_CC_PROMOCION.VAR_CURPREMIOS
                                   , K_USUARIOPROMO       OUT VARCHAR2
                                   , K_CODERROR           OUT NUMBER
                                   , K_DESCERROR          OUT VARCHAR2
                                  ) IS
--------------------------------------------------------------------------
--  Nombre          :   ADMPSS_GET_NOT_PREMIOS
--  Proposito       :   Dado un codigo alfanumerico de una promosion entregar los
--                  :   premios que nos deberia corresponderle
--  Version         : 1.0
--  Fecha Creacion  : 05/04/2012
--  Autor           : Henry Herrera
--------------------------------------------------------------------------
  NO_EXISTE_MOVIMIENTO EXCEPTION;   --Existe movimiento
  NO_ERRORS_NUMERLINEA EXCEPTION;   --Error al procesar la linea
  NO_STATUS_PROVINCIAS EXCEPTION;   --Excepcion en valicion se linea provincia
  NO_EXISTE_PROMOCIONS EXCEPTION;   --Error al obtener la promocion activa
  NO_EXISTE_CONTRATOSS EXCEPTION;   --Numero de contrato
  ES_PROVIN   NUMBER;               --Es provincia o lima
  EX_MOVIMI   NUMBER;               --Existe movimiento
  K_NUM_LINEA VARCHAR2(30);
  K_TIP_LINEA VARCHAR2(20);
  K_ADMPN_ID_PROMO  NUMBER;
  K_CODE_CONTRATO   VARCHAR2(200);
  K_LISTA_PREMIO   VARCHAR2(400);
  K_QUERY_EXE      VARCHAR2(4000);
BEGIN
    K_CODERROR:=0;
    K_ADMPN_ID_PROMO:=0;
    K_USUARIOPROMO:='';
    K_LISTA_PREMIO:='';
    --------------------------------
    --Validar la promocion vigente
    K_CODERROR:=0;K_DESCERROR:='';
    ADMPSS_VALIDARPROMOCION(K_ADMPN_ID_PROMO,K_CODERROR,K_DESCERROR);
    IF K_CODERROR <> 0 THEN
      RAISE NO_EXISTE_PROMOCIONS;
    END IF;

   --------------------------------
   --Validando si existe el movimiento
   EX_MOVIMI:=ADMPSS_EXISTE_MOVIMIENTO(K_ADMPV_ALFANUMERICO,K_ADMPN_ID_PROMO);
   IF  EX_MOVIMI = 0 THEN
      RAISE NO_EXISTE_MOVIMIENTO;
   END IF;
   --------------------------------
   --Obteniendo el numero telefonico
   K_CODERROR:=0;K_DESCERROR:='';
   ADMPSS_GET_LINEA( K_ADMPV_ALFANUMERICO,K_ADMPN_ID_PROMO,K_NUM_LINEA,K_TIP_LINEA, K_CODE_CONTRATO, K_CODERROR,K_DESCERROR);
   IF K_CODERROR <> 0 THEN
    RAISE NO_ERRORS_NUMERLINEA;
   END IF;
   --------------------------------
   --Validamos si la linea es de provincia o lima
   K_CODERROR:=0;K_DESCERROR:='';
   ADMPSS_STATUS_PROVINCIA(K_NUM_LINEA,K_TIP_LINEA,K_USUARIOPROMO,ES_PROVIN,K_CODERROR,K_DESCERROR);
   IF K_CODERROR <> 0 THEN
      RAISE NO_STATUS_PROVINCIAS;
   END IF;
   --------------------------------
   --PROCESO PRINCIPAL
   --------------------------------
   --Verificando el servicio
    IF K_TIP_LINEA='2' THEN
        -------------------------------------------------
        K_LISTA_PREMIO:=ADMFF_PREMIO_SERVICIO(K_ADMPN_ID_PROMO,K_CODE_CONTRATO);
        -------------------------------------------------
        IF ES_PROVIN = 1 THEN  --Linea Postpago Provincia
              K_QUERY_EXE:= 'SELECT   ADMPN_ID_PREMIO
                                     ,ADMPV_DESPREMIO
                             FROM  ADMPT_PREMIO_PROMO
                             WHERE ADMPN_ID_PROMO = ' || TO_CHAR(K_ADMPN_ID_PROMO)
                             || ' AND ADMPN_ID_TPREMIO IN (
                                                      SELECT ADMPN_ID_TPREMIO
                                                      FROM   ADMPT_TIP_PREMIOPROMO
                                                      WHERE  ADMPN_APPROVINCIA=''N''
                                                      )
                            UNION
                            SELECT   ADMPN_ID_PREMIO
                                    ,ADMPV_DESPREMIO
                            FROM  ADMPT_PREMIO_PROMO
                            WHERE ADMPN_ID_PROMO = ' || TO_CHAR(K_ADMPN_ID_PROMO)
                            ||  ' AND ADMPN_ID_PREMIO IN (' || COALESCE(K_LISTA_PREMIO,'NULL' ) || ')';

        ELSIF( ES_PROVIN = 0 ) THEN --Linea Postpago Lima
            K_QUERY_EXE:= ' SELECT   ADMPN_ID_PREMIO
                                    ,ADMPV_DESPREMIO
                            FROM  ADMPT_PREMIO_PROMO
                            WHERE ADMPN_ID_PROMO = ' || K_ADMPN_ID_PROMO
                            ||   ' AND ADMPN_ID_PREMIO IN ('|| COALESCE(K_LISTA_PREMIO,'NULL')||')';

        END IF;

    ELSIF(K_TIP_LINEA='3') THEN
           IF ES_PROVIN = 1 THEN   --Linea Prepago Provincia
              K_QUERY_EXE:= ' SELECT  ADMPN_ID_PREMIO
                                     ,ADMPV_DESPREMIO
                              FROM   ADMPT_PREMIO_PROMO
                              WHERE  ADMPN_ID_PROMO = ' || TO_CHAR(K_ADMPN_ID_PROMO)
                              ||     ' AND ADMPN_ID_TPREMIO IN (
                                                              SELECT ADMPN_ID_TPREMIO
                                                              FROM   ADMPT_TIP_PREMIOPROMO
                                                              WHERE  ADMPN_APPROVINCIA=''N''
                                                             )';
           ELSIF( ES_PROVIN = 0 ) THEN --Linea Prepago Lima
              K_QUERY_EXE:= 'SELECT  '''' ADMPN_ID_PREMIO
                                    ,'''' ADMPV_DESPREMIO
                             FROM   DUAL
                             WHERE  1=2';
           END IF;

    ELSIF(K_TIP_LINEA='1' ) THEN  --Linea Control Provincia
          IF ES_PROVIN = 1 THEN
            K_QUERY_EXE:= ' SELECT  ADMPN_ID_PREMIO
                                   ,ADMPV_DESPREMIO
                            FROM   ADMPT_PREMIO_PROMO
                            WHERE  ADMPN_ID_PROMO = ' || TO_CHAR(K_ADMPN_ID_PROMO)
                             ||   ' AND ADMPN_ID_TPREMIO IN (
                                                            SELECT ADMPN_ID_TPREMIO
                                                            FROM   ADMPT_TIP_PREMIOPROMO
                                                            WHERE  ADMPN_APPROVINCIA=''N''
                                                            UNION
                                                            SELECT ADMPN_ID_TPREMIO
                                                            FROM   ADMPT_TIP_PREMIOPROMO
                                                            WHERE  ADMPN_ID_TPREMIO=2
                                                            )';
          ELSIF(ES_PROVIN = 0) THEN --Linea Control Lima

              K_QUERY_EXE:= 'SELECT  ADMPN_ID_PREMIO
                                    ,ADMPV_DESPREMIO
                             FROM   ADMPT_PREMIO_PROMO
                             WHERE  ADMPN_ID_PROMO = ' || TO_CHAR(K_ADMPN_ID_PROMO)
                             ||   ' AND ADMPN_ID_TPREMIO IN (
                                                              SELECT ADMPN_ID_TPREMIO
                                                              FROM   ADMPT_TIP_PREMIOPROMO
                                                              WHERE  ADMPN_ID_TPREMIO=2
                                                            )';
          END IF;

    END IF;
    --DBMS_OUTPUT.PUT_LINE( K_QUERY_EXE);
    OPEN K_CURPREMIOS FOR K_QUERY_EXE;

    EXCEPTION
      WHEN  NO_EXISTE_PROMOCIONS  THEN
         K_CODERROR :=K_CODERROR;
         K_DESCERROR:=K_DESCERROR;
         K_USUARIOPROMO:=NULL;
         OPEN K_CURPREMIOS FOR
         SELECT  '' ADMPN_ID_PREMIO
                ,'' ADMPV_DESPREMIO
         FROM    DUAL
         WHERE   1=2;
      WHEN  NO_EXISTE_MOVIMIENTO  THEN
         K_CODERROR :=1;
         K_DESCERROR:='No se existe el alfanumerico  en la registro de movimientos';
         K_USUARIOPROMO:=NULL;
         OPEN K_CURPREMIOS FOR
         SELECT  '' ADMPN_ID_PREMIO
                ,'' ADMPV_DESPREMIO
         FROM    DUAL
         WHERE   1=2;
      WHEN NO_STATUS_PROVINCIAS THEN
         K_CODERROR :=K_CODERROR;
         K_DESCERROR:=K_DESCERROR;
         K_USUARIOPROMO:=NULL;
         OPEN K_CURPREMIOS FOR
         SELECT  '' ADMPN_ID_PREMIO
         ,'' ADMPV_DESPREMIO
         FROM    DUAL
         WHERE   1=2;
      WHEN  NO_ERRORS_NUMERLINEA  THEN
         K_CODERROR :=K_CODERROR;
         K_DESCERROR:=K_DESCERROR;
         K_USUARIOPROMO:=NULL;
         OPEN K_CURPREMIOS FOR
         SELECT  '' ADMPN_ID_PREMIO
                ,'' ADMPV_DESPREMIO
         FROM    DUAL
         WHERE   1=2;
      WHEN NO_EXISTE_CONTRATOSS THEN
         K_CODERROR :=K_CODERROR;
         K_DESCERROR:=K_DESCERROR;
         K_USUARIOPROMO:=NULL;
         OPEN K_CURPREMIOS FOR
         SELECT  '' ADMPN_ID_PREMIO
                ,'' ADMPV_DESPREMIO
         FROM    DUAL
         WHERE   1=2;
      WHEN OTHERS THEN
        K_CODERROR :=SQLCODE;
         K_DESCERROR:=SUBSTR(SQLERRM,1,400);
         K_USUARIOPROMO:=NULL;
         OPEN K_CURPREMIOS FOR
         SELECT  '' ADMPN_ID_PREMIO
                ,'' ADMPV_DESPREMIO
         FROM    DUAL
         WHERE   1=2;

END;




FUNCTION ADMFF_PREMIO_SERVICIO(K_ADMPN_ID_PROMO IN NUMBER,
                               K_CODIG_CONTRATO IN VARCHAR2)
  RETURN VARCHAR2
--------------------------------------------------------------------------
  --  Nombre          :   ADMPSS_GET_COD_CONTRATO
  --  Proposito       :   Procedimiento para saber si los sercios aplicados a una promocion son
  --                  :   validos para su entrega esto a fin de reunion un listado de premios
  --  Version         : 1.0
  --  Fecha Creacion  : 05/04/2012
  --  Autor           : Henry Herrera
  --------------------------------------------------------------------------

 IS
  CURSOR C IS
    SELECT ADMPN_ID_PREMIO, ADMPV_DESPREMIO, ADMPV_CODSERV
      FROM ADMPT_PREMIO_PROMO
     WHERE ADMPN_ID_PROMO = K_ADMPN_ID_PROMO
       AND ADMPN_ID_TPREMIO IN
           (SELECT ADMPN_ID_TPREMIO
              FROM ADMPT_TIP_PREMIOPROMO
             WHERE ADMPV_DESCR_TP LIKE '%SERVICIO%');
  K_ESTADO VARCHAR2(30);
  K_ERROR  NUMBER;
  K_MESSG  VARCHAR2(400);
  Valores  varchar2(400);
BEGIN
  Valores := '';
  FOR i IN c LOOP
    K_ESTADO := 0;
    K_ERROR  := 0;
    K_MESSG  := '';
    tim.PKG_CATALOGO_SERVICIOS.CONSULTA_SERVICIO_COMERCIAL@DBL_BSCS(K_CODIG_CONTRATO,
                                                                i.ADMPV_CODSERV,
                                                                K_ESTADO,
                                                                K_ERROR,
                                                                K_MESSG);
    IF K_ESTADO = 'A' THEN
      if NVL(Valores, 'X') = 'X' THEN
        Valores := i.ADMPN_ID_PREMIO;
      else
        Valores := Valores || ',' || i.ADMPN_ID_PREMIO;
      end if;
    END IF;
  END LOOP;
  RETURN Valores;
END;


END PKG_CC_PROMOCION;
/