CREATE OR REPLACE PACKAGE BODY PCLUB.PKG_CC_TRANSACCION IS
  PROCEDURE ADMPSS_CONSALDO(K_COD_CLIENTE     IN VARCHAR2,
                            K_TIPO_DOC        IN VARCHAR2,
                            K_NUM_DOC         IN VARCHAR2,
                            K_TIP_CLI         IN VARCHAR2,
                            K_CODERROR        OUT NUMBER,
                            K_MSJERROR        OUT VARCHAR2,
                            K_SALDO_PUNTOS    OUT NUMBER,
                            K_SALDO_PUNTOS_BONO OUT NUMBER,
                            K_SALDO_PUNTOS_CC OUT NUMBER,
                            K_SALDO_PUNTOS_IB OUT NUMBER,
                            K_CUR_LISTA         OUT SYS_REFCURSOR,
                            K_CUR_BONO          OUT SYS_REFCURSOR) IS

    /****************************************************************
    '* Nombre SP           :  ADMPSS_CONSALDO
    '* Propósito           :  Consulta segun el codigo o numero de documento y el tipo de cliente, los saldos total,IB, CC y devuelve un cursor con los productos permitidos segun el puntaje total
    '* Input               :  K_COD_CLIENTE , K_TIPO_DOC, K_NUM_DOC, K_TIP_CLI
    '* Output              :  K_CODERROR, K_MSJERROR, K_SALDO_PUNTOS, K_SALDO_PUNTOS_CC, K_SALDO_PUNTOS_IB, K_CUR_LISTA
    '* Creado por          :  (Venkizmet) Rossana Janampa
    '* Fec Creación        :
    '* Fec Actualización   :  22/09/2010
    '****************************************************************/

    CURSOR CUR_CLIENTE(tipo_doc VARCHAR2, num_doc VARCHAR2) IS
      SELECT admpv_cod_cli, admpv_cod_tpocl
        FROM PCLUB.admpt_cliente
       WHERE (admpv_tipo_doc = tipo_doc AND admpv_num_doc = num_doc)
         AND admpc_estado = 'A'
         AND ((admpv_cod_tpocl = '1' OR admpv_cod_tpocl = '2'));

    CURSOR CUR_CLIENTE_TIPO(tipo_doc VARCHAR2, num_doc VARCHAR2, tipo_clie VARCHAR2) IS
      SELECT admpv_cod_cli, admpv_cod_tpocl
        FROM PCLUB.admpt_cliente
       WHERE (admpv_tipo_doc = tipo_doc AND admpv_num_doc = num_doc)
         AND admpc_estado = 'A'
         AND admpv_cod_tpocl = tipo_clie;

    --Datos del Cursor (Tipo_cliente)
    CUR_COD_CLI PCLUB.admpt_cliente.admpv_cod_cli%TYPE;
    CUR_TIP_CLI PCLUB.admpt_cliente.admpv_cod_tpocl%TYPE;
    -- Variables
    V_TIP_DOC      PCLUB.admpt_cliente.admpv_tipo_doc%TYPE;
    V_NUM_DOC      PCLUB.admpt_cliente.admpv_num_doc%TYPE;
    V_TIP_CLIE     PCLUB.admpt_cliente.admpv_cod_tpocl%TYPE;
    V_SALDO_IB     NUMBER := 0;
    V_SALDO_CC     NUMBER := 0;
    V_SALDO_IB_AUX NUMBER := 0;
    V_SALDO_CC_AUX NUMBER := 0;
    V_SALDO_B_AUX   NUMBER := 0;
    V_SALDO_CLIBONO NUMBER := 0;
    NO_PARAMETROS EXCEPTION;
    nro_registrosCC NUMBER := 0;
    nro_registrosIB NUMBER := 0;
    C_CONSIDERA_IB  VARCHAR2(50); -- SSC 09112010 - Migracion Loyalty
    V_COD_CLI_IB    NUMBER;
    V_EST_IB        CHAR(1);
    V_EST_BLOQUEO CHAR(1);
    V_CODERROR NUMBER;
    V_DESCERROR VARCHAR2(300);
    EX_VALIDACION EXCEPTION;
  BEGIN

    K_SALDO_PUNTOS_CC := 0;
    K_SALDO_PUNTOS_IB := 0;
    K_SALDO_PUNTOS    := 0;
    K_SALDO_PUNTOS_BONO := 0;

    K_CODERROR := 0;

    /*
       Si el tipo de Cliente es Control se debera obtener la suma de los puntos cuya cuenta sea Control y Postpago
       Si el tipo de Cliente es Postpago se debera obtener la suma de los puntos cuya cuenta sea Control y Postpago
       Si el tipo de cliente es B2E solo se considerará los puntos cuyos cuentas sean B2E
       Si el tipo de cliente es Prepago solo se considerará los puntos cuyos cuentas sean Prepago
    */

    IF K_COD_CLIENTE IS NOT NULL AND K_TIP_CLI IS NOT NULL THEN
      /* La consulta se realiza por cuenta de cliente : SOLO PARA CLIENTES CLARO CLUB */
      BEGIN
        -- Con el código de cliente devuelve el tipo de documento y el numero de documento, debe devolver 0 ó 1 registro
        SELECT NVL(admpv_tipo_doc, 0),
               NVL(admpv_num_doc, 0),
               NVL(admpv_cod_tpocl, 0)
          INTO V_TIP_DOC, V_NUM_DOC, V_TIP_CLIE
          FROM PCLUB.admpt_cliente
         WHERE admpv_cod_cli = K_COD_CLIENTE
           AND admpc_estado = 'A';

        IF V_TIP_CLIE = '3' AND V_TIP_CLIE = K_TIP_CLI THEN
          BEGIN
            OPEN CUR_CLIENTE_TIPO(V_TIP_DOC, V_NUM_DOC, V_TIP_CLIE);
            FETCH CUR_CLIENTE_TIPO
              INTO CUR_COD_CLI, CUR_TIP_CLI;

            WHILE CUR_CLIENTE_TIPO%FOUND LOOP
              BEGIN
                SELECT NVL(admpn_saldo_cc, 0),
                       NVL(admpn_saldo_ib, 0),
                       NVL(admpc_estpto_ib, 0)
                  INTO V_SALDO_CC_AUX, V_SALDO_IB_AUX, V_EST_IB
                  FROM PCLUB.admpt_saldos_cliente
                 WHERE admpv_cod_cli = CUR_COD_CLI
                   AND admpc_estpto_cc = 'A';

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  V_SALDO_CC_AUX := 0;
                  V_SALDO_IB_AUX := 0;
              END;

              IF V_EST_IB <> 'A' THEN
                V_SALDO_IB_AUX := 0;
              END IF;

              V_SALDO_IB := V_SALDO_IB + V_SALDO_IB_AUX;
              V_SALDO_CC := V_SALDO_CC + V_SALDO_CC_AUX;

              FETCH CUR_CLIENTE_TIPO
                INTO CUR_COD_CLI, CUR_TIP_CLI;
            END LOOP;
            CLOSE CUR_CLIENTE_TIPO;

            --Obtengo el Saldo Bono del Cliente
            SELECT NVL(SUM(SB.ADMPN_SALDO),0)
              INTO V_SALDO_CLIBONO
              FROM PCLUB.ADMPT_SALDOS_BONO_CLIENTE SB
             WHERE SB.ADMPV_COD_CLI = K_COD_CLIENTE;

          END;
        ELSIF (V_TIP_CLIE = '4' or V_TIP_CLIE = '8') AND
           V_TIP_CLIE = K_TIP_CLI THEN
           BEGIN
            OPEN CUR_CLIENTE_TIPO(V_TIP_DOC, V_NUM_DOC, V_TIP_CLIE);
            FETCH CUR_CLIENTE_TIPO
              INTO CUR_COD_CLI, CUR_TIP_CLI;

            WHILE CUR_CLIENTE_TIPO%FOUND LOOP
              BEGIN
                SELECT NVL(admpn_saldo_cc, 0),
                       NVL(admpn_saldo_ib, 0),
                       NVL(admpc_estpto_ib, 0)
                  INTO V_SALDO_CC_AUX, V_SALDO_IB_AUX, V_EST_IB
                  FROM PCLUB.admpt_saldos_cliente
                 WHERE admpv_cod_cli = CUR_COD_CLI
                   AND admpc_estpto_cc = 'A';

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  V_SALDO_CC_AUX := 0;
                  V_SALDO_IB_AUX := 0;
              END;

              IF V_EST_IB <> 'A' THEN
                V_SALDO_IB_AUX := 0;
              END IF;

              V_SALDO_IB := V_SALDO_IB + V_SALDO_IB_AUX;
              V_SALDO_CC := V_SALDO_CC + V_SALDO_CC_AUX;

              FETCH CUR_CLIENTE_TIPO
                INTO CUR_COD_CLI, CUR_TIP_CLI;
            END LOOP;
            CLOSE CUR_CLIENTE_TIPO;
          END;
        ELSE
          IF (K_TIP_CLI = '2' AND (V_TIP_CLIE = '1' OR V_TIP_CLIE = '2')) OR
             (K_TIP_CLI = '1' AND (V_TIP_CLIE = '1' OR V_TIP_CLIE = '2')) THEN

            OPEN CUR_CLIENTE(V_TIP_DOC, V_NUM_DOC);
            FETCH CUR_CLIENTE
              INTO CUR_COD_CLI, CUR_TIP_CLI;

            WHILE CUR_CLIENTE%FOUND LOOP
              BEGIN
                -- Buscar en Saldos_cliente
                SELECT NVL(admpn_saldo_cc, 0),
                       NVL(admpn_saldo_ib, 0),
                       NVL(admpc_estpto_ib, 0)
                  INTO V_SALDO_CC_AUX, V_SALDO_IB_AUX, V_EST_IB
                  FROM PCLUB.admpt_saldos_cliente
                 WHERE admpv_cod_cli = CUR_COD_CLI
                   AND admpc_estpto_cc = 'A';

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  V_SALDO_CC_AUX := 0;
                  V_SALDO_IB_AUX := 0;
              END;

              IF V_EST_IB <> 'A' THEN
                V_SALDO_IB_AUX := 0;
              END IF;

              V_SALDO_IB := V_SALDO_IB + V_SALDO_IB_AUX;
              V_SALDO_CC := V_SALDO_CC + V_SALDO_CC_AUX;

              FETCH CUR_CLIENTE
                INTO CUR_COD_CLI, CUR_TIP_CLI;
            END LOOP;

            CLOSE CUR_CLIENTE;
          ELSE
            RAISE no_parametros;
          END IF;
        END IF;
      END;

    -- Realiza la validación del bloqueo
      PCLUB.PKG_CC_TRANSACCION.ADMPS_VALBLOQUEOBOLSA(V_TIP_DOC,V_NUM_DOC,V_TIP_CLIE,V_TIP_DOC,V_EST_BLOQUEO,V_CODERROR,V_DESCERROR);

      IF K_CODERROR <> 0 THEN
        RAISE EX_VALIDACION;
      END IF;

      IF V_EST_BLOQUEO = 'R' THEN
        V_CODERROR := 37;
        V_DESCERROR := 'Existe un canje en proceso. ';
      END IF;
      --------------------------------------
    ELSE
      /* la consulta se realiza por número de documento: Podria ser clientes IB o CLARO CLUB */
      IF (K_TIPO_DOC IS NOT NULL AND K_NUM_DOC IS NOT NULL) AND
         K_TIP_CLI IS NOT NULL THEN
        BEGIN
          -- Busca si el cliente es CC
          SELECT COUNT(1)
            INTO nro_registrosCC
            FROM PCLUB.admpt_cliente
           WHERE admpv_tipo_doc = K_TIPO_DOC
             AND admpv_num_doc = K_NUM_DOC
             AND admpc_estado = 'A'
             AND (admpv_cod_tpocl = K_TIP_CLI OR
                 (K_TIP_CLI = '1' AND
                 (admpv_cod_tpocl = '2' OR admpv_cod_tpocl = '1')) OR
                 (K_TIP_CLI = '2' AND
                 (admpv_cod_tpocl = '2' OR admpv_cod_tpocl = '1')));
          -- Busca si el cliente es IB
          SELECT COUNT(1)
            INTO nro_registrosIB
            FROM PCLUB.admpt_clienteib
           WHERE admpv_tipo_doc = K_TIPO_DOC
             AND admpv_num_doc = K_NUM_DOC
             AND admpc_estado <> 'B';

          IF nro_registrosCC = 0 AND nro_registrosIB = 0 THEN
            RAISE NO_PARAMETROS;
          END IF;

          IF (nro_registrosCC > 0 AND nro_registrosIB > 0) OR
             (nro_registrosCC > 0 AND nro_registrosIB = 0) THEN
            --SI cliente claro club. NO/SI, es cliente IB
            IF K_TIP_CLI = '3' THEN
              BEGIN
                OPEN CUR_CLIENTE_TIPO(K_TIPO_DOC, K_NUM_DOC, K_TIP_CLI);
                FETCH CUR_CLIENTE_TIPO
                  INTO CUR_COD_CLI, CUR_TIP_CLI;

                WHILE CUR_CLIENTE_TIPO%FOUND LOOP
                  BEGIN
                    --Obtengo su saldo ClaroClub
                    SELECT NVL(admpn_saldo_cc, 0),
                           NVL(admpn_saldo_ib, 0),
                           NVL(admpc_estpto_ib, 0)
                      INTO V_SALDO_CC_AUX, V_SALDO_IB_AUX, V_EST_IB
                      FROM PCLUB.admpt_saldos_cliente
                     WHERE admpv_cod_cli = CUR_COD_CLI
                       AND admpc_estpto_cc = 'A';

                    --Obtengo su Saldo Bono
                    SELECT NVL(SUM(SB.ADMPN_SALDO),0)
                      INTO V_SALDO_B_AUX
                      FROM PCLUB.ADMPT_SALDOS_BONO_CLIENTE SB
                     WHERE SB.ADMPV_COD_CLI = CUR_COD_CLI;

                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      V_SALDO_CC_AUX  := 0;
                      V_SALDO_IB_AUX  := 0;
                      V_SALDO_B_AUX := 0;
                  END;
                  IF V_EST_IB <> 'A' THEN
                    V_SALDO_IB_AUX := 0;
                  END IF;

                  V_SALDO_IB      := V_SALDO_IB + V_SALDO_IB_AUX;
                  V_SALDO_CC      := V_SALDO_CC + V_SALDO_CC_AUX;
                  V_SALDO_CLIBONO := V_SALDO_CLIBONO + V_SALDO_B_AUX;

                  FETCH CUR_CLIENTE_TIPO
                    INTO CUR_COD_CLI, CUR_TIP_CLI;
                END LOOP;
                CLOSE CUR_CLIENTE_TIPO;
              END;

            ELSIF (K_TIP_CLI = '4' OR K_TIP_CLI = '8') THEN
              BEGIN
                OPEN CUR_CLIENTE_TIPO(K_TIPO_DOC, K_NUM_DOC, K_TIP_CLI);
                FETCH CUR_CLIENTE_TIPO
                  INTO CUR_COD_CLI, CUR_TIP_CLI;

                WHILE CUR_CLIENTE_TIPO%FOUND LOOP
                  BEGIN
                    SELECT NVL(admpn_saldo_cc, 0),
                           NVL(admpn_saldo_ib, 0),
                           NVL(admpc_estpto_ib, 0)
                      INTO V_SALDO_CC_AUX, V_SALDO_IB_AUX, V_EST_IB
                      FROM PCLUB.admpt_saldos_cliente
                     WHERE admpv_cod_cli = CUR_COD_CLI
                       AND admpc_estpto_cc = 'A';

                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      V_SALDO_CC_AUX := 0;
                      V_SALDO_IB_AUX := 0;
                  END;
                  IF V_EST_IB <> 'A' THEN
                    V_SALDO_IB_AUX := 0;
                  END IF;

                  V_SALDO_IB := V_SALDO_IB + V_SALDO_IB_AUX;
                  V_SALDO_CC := V_SALDO_CC + V_SALDO_CC_AUX;

                  FETCH CUR_CLIENTE_TIPO
                    INTO CUR_COD_CLI, CUR_TIP_CLI;
                END LOOP;
                CLOSE CUR_CLIENTE_TIPO;
              END;
            ELSE
              IF (K_TIP_CLI = '2' OR K_TIP_CLI = '1') THEN
                BEGIN
                  OPEN CUR_CLIENTE(K_TIPO_DOC, K_NUM_DOC);
                  FETCH CUR_CLIENTE
                    INTO CUR_COD_CLI, CUR_TIP_CLI;

                  WHILE CUR_CLIENTE%FOUND LOOP
                    BEGIN
                      SELECT NVL(admpn_saldo_cc, 0),
                             NVL(admpn_saldo_ib, 0),
                             NVL(admpc_estpto_ib, 0)
                        INTO V_SALDO_CC_AUX, V_SALDO_IB_AUX, V_EST_IB
                        FROM PCLUB.admpt_saldos_cliente
                       WHERE admpv_cod_cli = CUR_COD_CLI
                         AND admpc_estpto_cc = 'A';
                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                        V_SALDO_CC_AUX := 0;
                        V_SALDO_IB_AUX := 0;
                    END;

                    IF V_EST_IB <> 'A' THEN
                      V_SALDO_IB_AUX := 0;
                    END IF;

                    V_SALDO_IB := V_SALDO_IB + V_SALDO_IB_AUX;
                    V_SALDO_CC := V_SALDO_CC + V_SALDO_CC_AUX;

                    FETCH CUR_CLIENTE
                      INTO CUR_COD_CLI, CUR_TIP_CLI;
                  END LOOP;
                END;
              ELSE
                RAISE no_parametros;
              END IF;
            END IF;
          ELSE
            -- NO, cliente claro club. SI, cliente IB if (nro_registrosCC=0 and nro_registrosIB>0) then
            IF K_TIP_CLI = 5 THEN
              V_SALDO_CC := 0;
              SELECT admpn_cod_cli_ib
                INTO V_COD_CLI_IB
                FROM PCLUB.admpt_clienteib
               WHERE admpv_tipo_doc = K_TIPO_DOC
                 AND admpv_num_doc = K_NUM_DOC
                 AND admpc_estado <> 'B';
              SELECT NVL(admpn_saldo_ib, 0)
                INTO V_SALDO_IB
                FROM PCLUB.admpt_saldos_cliente
               WHERE admpn_cod_cli_ib = V_COD_CLI_IB;
            ELSE
              RAISE NO_PARAMETROS;
            END IF;
          END IF;
        END;
        -- Realiza la validación del bloqueo
        PCLUB.PKG_CC_TRANSACCION.ADMPS_VALBLOQUEOBOLSA(K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,V_TIP_DOC,V_EST_BLOQUEO,V_CODERROR,V_DESCERROR);

        IF K_CODERROR <> 0 THEN
          RAISE EX_VALIDACION;
        END IF;

        IF V_EST_BLOQUEO = 'R' THEN
          V_CODERROR := 37;
          V_DESCERROR := 'Existe un canje en proceso. ';
        END IF;
        --------------------------------------
      ELSE
        RAISE NO_PARAMETROS;
      END IF;
    END IF;

    BEGIN
      SELECT ADMPV_VALOR
        INTO C_CONSIDERA_IB
        FROM PCLUB.ADMPT_PARAMSIST
       WHERE UPPER(ADMPV_DESC) = 'CONSIDERA_PUNTOS_IB';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        C_CONSIDERA_IB := 'SI';
    END;
    IF C_CONSIDERA_IB = 'NO' THEN
      V_SALDO_IB := 0;
    END IF;

    K_SALDO_PUNTOS_CC := V_SALDO_CC;
    K_SALDO_PUNTOS_IB := V_SALDO_IB;
    K_SALDO_PUNTOS    := K_SALDO_PUNTOS_CC + K_SALDO_PUNTOS_IB;
    --Saldo de Bonos
    K_SALDO_PUNTOS_BONO := NVL(V_SALDO_CLIBONO,0);

    IF K_TIP_CLI IS NOT NULL THEN
      -- Obtener Productos según el tipo de datos enviado en el parámetro
      OPEN K_CUR_LISTA FOR

        SELECT pr.admpv_id_procla AS ProdId,
               pr.admpv_desc      AS ProdDes,
               pr.admpv_campana   AS Campana,
               pr.admpn_puntos    AS Puntos,
               pr.admpn_pago      AS pago,
               t_pr.admpv_desc    AS t_pr,
               pr.admpn_cod_servc AS servcomercial,
               pr.admpn_mnt_recar AS montorecarga,
               pr.admpv_cod_paqdat AS codigo_paquete,
               t_pr.admpv_cod_tpopr AS Cod_t_pr
          FROM PCLUB.admpt_premio        pr,
               PCLUB.admpt_tipo_premio   t_pr,
               PCLUB.admpt_tipo_premclie t_pre_cli
         WHERE pr.admpv_cod_tpopr = t_pr.admpv_cod_tpopr
           AND pr.admpv_cod_tpopr = t_pre_cli.admpv_cod_tpopr
           AND t_pr.admpv_cod_tpopr = t_pr.admpv_cod_tpopr
           AND t_pre_cli.admpv_cod_tpocl = K_TIP_CLI
           AND pr.admpc_estado = 'A'
           AND pr.admpn_puntos <= K_SALDO_PUNTOS
           AND pr.admpv_id_procla not in (select admpv_id_procla
                                          from PCLUB.ADMPT_EXCPREMIO_TIPOCLIE
                                          where admpv_cod_tpocl=K_TIP_CLI)
		   AND PR.ADMPN_PUNTOS<>0
         ORDER BY t_pr.admpn_orden, pr.admpn_puntos DESC;

    END IF;

    --Obtiene el Saldo Bono de la línea consultada
    IF K_COD_CLIENTE IS NOT NULL THEN
      OPEN K_CUR_BONO FOR
        SELECT G.ADMPV_DESCRIPCION TIPPUNTO, SB.ADMPN_SALDO PUNTOS
          FROM ADMPT_SALDOS_BONO_CLIENTE SB
          LEFT OUTER JOIN ADMPT_GRUPO_TIPPREM G
            ON SB.ADMPN_GRUPO = G.ADMPN_GRUPO
         WHERE SB.ADMPV_COD_CLI = K_COD_CLIENTE;
    ELSE
      OPEN K_CUR_BONO FOR
        SELECT G.ADMPV_DESCRIPCION TIPPUNTO,
               SUM(NVL(SB.ADMPN_SALDO, 0)) PUNTOS
          FROM ADMPT_SALDOS_BONO_CLIENTE SB
          LEFT OUTER JOIN ADMPT_GRUPO_TIPPREM G
            ON SB.ADMPN_GRUPO = G.ADMPN_GRUPO
         WHERE SB.ADMPV_COD_CLI IN
               (SELECT ADMPV_COD_CLI
                  FROM admpt_cliente
                 WHERE admpv_tipo_doc = K_TIPO_DOC
                   AND admpv_num_doc = K_NUM_DOC
                   AND admpc_estado = 'A'
                   AND admpv_cod_tpocl = K_TIP_CLI)
         GROUP BY G.ADMPV_DESCRIPCION;
    END IF;

    /* *************************************************************************** */
  EXCEPTION
    WHEN NO_PARAMETROS THEN
      K_CODERROR := 41;
      K_MSJERROR := 'Ingresó datos incorrectos o datos insuficientes para realizar la consulta';

     OPEN K_CUR_LISTA FOR
       SELECT
       '' ProdId,
       '' ProdDes,
       '' Campana,
       '' Puntos,
       '' pago,
       '' t_pr,
       '' ServComercial,
       '' MontoRecarga,
       '' Codigo_Paquete,
       '' Cod_t_pr
       FROM DUAL;

      OPEN K_CUR_BONO FOR
        SELECT '' TIPPUNTO, '' PUNTOS FROM DUAL;

    WHEN NO_DATA_FOUND THEN
      IF V_TIP_DOC IS NULL OR V_NUM_DOC IS NULL OR V_TIP_CLIE IS NULL THEN
        K_CODERROR := 40;
        K_MSJERROR := 'No se encontró información para los datos ingresados';
      END IF;

     OPEN K_CUR_LISTA FOR
       SELECT
       '' ProdId,
       '' ProdDes,
       '' Campana,
       '' Puntos,
       '' pago,
       '' t_pr,
       '' ServComercial,
       '' MontoRecarga,
       '' Codigo_Paquete,
       '' Cod_t_pr
       FROM DUAL;

      OPEN K_CUR_BONO FOR
        SELECT '' TIPPUNTO, '' PUNTOS FROM DUAL;

    WHEN EX_VALIDACION THEN
      K_CODERROR := V_CODERROR;
      K_MSJERROR := V_DESCERROR;
    WHEN OTHERS THEN
      K_CODERROR := SQLCODE;
      K_MSJERROR := SUBSTR(SQLERRM, 1, 250);

     OPEN K_CUR_LISTA FOR
       SELECT
       '' ProdId,
       '' ProdDes,
       '' Campana,
       '' Puntos,
       '' pago,
       '' t_pr,
       '' ServComercial,
       '' MontoRecarga,
       '' Codigo_Paquete,
       '' Cod_t_pr
       FROM DUAL;

      OPEN K_CUR_BONO FOR
        SELECT '' TIPPUNTO, '' PUNTOS FROM DUAL;
END admpss_consaldo;

PROCEDURE ADMPSS_CONSALDO(  P_TIPO_DOC          IN PCLUB.admpt_cliente.admpv_tipo_doc%type,
                            P_NUM_DOC            IN PCLUB.admpt_cliente.admpv_num_doc%type,
                            P_SALDO_PUNTOS       OUT NUMBER,
                            P_COD_RESPUESTA      OUT NUMBER,
                            P_MENSAJE_RESPUESTA  OUT VARCHAR2) IS

    /****************************************************************
    '* Nombre SP           :  ADMPSS_CONSALDO
    '* Proposito           :
    '* Input               :  P_COD_CLIENTE , P_TIPO_DOC
    '* Output              :
    '* Creado por          :  Katherine Perez
    '* Fec Creacion        :
    '* Fec Actualizacion   :
    '****************************************************************/



    CURSOR CUR_CLIENTE(tipo_doc PCLUB.admpt_cliente.admpv_tipo_doc%type, num_doc PCLUB.admpt_cliente.admpv_num_doc%type) IS
      SELECT admpv_cod_cli, admpv_cod_tpocl
        FROM  admpt_cliente
       WHERE (admpv_tipo_doc = tipo_doc AND admpv_num_doc = num_doc)
         AND admpc_estado = 'A'
         AND ((admpv_cod_tpocl = '1' OR admpv_cod_tpocl = '2'));

    CURSOR CUR_CLIENTE_TIPO(tipo_doc PCLUB.admpt_cliente.admpv_tipo_doc%type, num_doc PCLUB.admpt_cliente.admpv_num_doc%type
    , tipo_clie PCLUB.admpt_cliente.admpv_cod_tpocl%type) IS
      SELECT admpv_cod_cli, admpv_cod_tpocl
        FROM  admpt_cliente
       WHERE (admpv_tipo_doc = tipo_doc AND admpv_num_doc = num_doc)
         AND admpc_estado = 'A'
         AND admpv_cod_tpocl = tipo_clie;

/* cursor agregado 18/09/16 */
       CURSOR CUR_CODIGOS_TIPOS(tipo_doc PCLUB.admpt_cliente.admpv_tipo_doc%type, num_doc PCLUB.admpt_cliente.admpv_num_doc%type) IS
      SELECT distinct admpv_cod_tpocl
        FROM  admpt_cliente
       WHERE (admpv_tipo_doc = tipo_doc AND admpv_num_doc = num_doc)
         AND admpc_estado = 'A';

/*cursor agregado  18/09/16 */

    --Datos del Cursor (Tipo_cliente)
    CUR_COD_CLI  PCLUB.admpt_cliente.admpv_cod_cli%TYPE;
    CUR_TIP_CLI  PCLUB.admpt_cliente.admpv_cod_tpocl%TYPE;
    -- Variables
    V_TIP_DOC       PCLUB.admpt_cliente.admpv_tipo_doc%TYPE;

    V_SALDO_IB     NUMBER := 0;
    V_SALDO_CC     NUMBER := 0;
    V_SALDO_IB_AUX NUMBER := 0;
    V_SALDO_CC_AUX NUMBER := 0;
    V_SALDO_B_AUX   NUMBER := 0;
    V_SALDO_CLIBONO NUMBER := 0;
    NO_PARAMETROS EXCEPTION;
    nro_registrosCC NUMBER := 0;
    nro_registrosIB NUMBER := 0;
    C_CONSIDERA_IB  VARCHAR2(50); -- SSC 09112010 - Migracion Loyalty
    V_COD_CLI_IB    PCLUB.admpt_clienteib.admpn_cod_cli_ib%type;
    V_EST_IB        CHAR(1);
    V_EST_BLOQUEO CHAR(1);
    V_CODERROR NUMBER;
    V_DESCERROR VARCHAR2(300);
    EX_VALIDACION EXCEPTION;

    K_TIP_CLI PCLUB.admpt_cliente.admpv_cod_tpocl%TYPE;
    V_TIPO_DOCUM PCLUB.admpt_tipo_doc.admpv_cod_tpdoc%type;
  BEGIN

  /*****          LINEAS  AGREGADAS       *********/

  -- PARAMETROS QUE SE DEBEN OBTENER
  --  K_COD_CLIENTE     IN VARCHAR2,
  --  K_TIP_CLI         IN VARCHAR2,

       -- data:   nroDoc= 42213500 tipoDoc=2
      /* cursor que guarda todos los codCliente y tipoCliente que se obtengan por el nroDoc y tipDoc*/
      -- luego realizar la logica existente para cada 1 de los codCliente y tipoCliente  y sumar
      -- los saldos puntos de cada codCliente.

  IF (P_TIPO_DOC IS NOT NULL AND P_NUM_DOC IS NOT NULL)THEN
    /**[INICIO] LINEAS AGREGADAS  18/09/2016 ****/


   IF P_TIPO_DOC= '001' THEN
      V_TIPO_DOCUM:=0;
   ELSE
      SELECT T.ADMPV_COD_TPDOC INTO V_TIPO_DOCUM FROM ADMPT_TIPO_DOC T
      WHERE T.ADMPV_EQU_FIJA=P_TIPO_DOC;

   END IF;

       P_COD_RESPUESTA:= 0;
       P_SALDO_PUNTOS:= 0;

    OPEN CUR_CODIGOS_TIPOS(V_TIPO_DOCUM, P_NUM_DOC);
    FETCH CUR_CODIGOS_TIPOS
    INTO K_TIP_CLI;

    IF CUR_CODIGOS_TIPOS%FOUND THEN
      WHILE CUR_CODIGOS_TIPOS%FOUND LOOP
      BEGIN
        V_SALDO_IB:= 0;
        V_SALDO_CC:= 0;
        V_SALDO_IB_AUX:= 0;
        V_SALDO_CC_AUX:= 0;
        V_SALDO_B_AUX:= 0;
        V_SALDO_CLIBONO := 0;
        nro_registrosCC:= 0;
        nro_registrosIB:= 0;

          /* la consulta se realiza por numero de documento: Podria ser clientes IB o CLARO CLUB */

          BEGIN
            -- Busca si el cliente es CC
            SELECT COUNT(1)INTO nro_registrosCC FROM  admpt_cliente
             WHERE admpv_tipo_doc = V_TIPO_DOCUM AND admpv_num_doc = P_NUM_DOC AND admpc_estado = 'A'
             AND (admpv_cod_tpocl = K_TIP_CLI OR (K_TIP_CLI = '1' AND (admpv_cod_tpocl = '2' OR admpv_cod_tpocl = '1')) OR
                                                 (K_TIP_CLI = '2' AND (admpv_cod_tpocl = '2' OR admpv_cod_tpocl = '1')));

          IF (nro_registrosCC > 0) THEN
            --SI cliente claro club. NO/SI, es cliente IB
            IF K_TIP_CLI = '3' THEN
              BEGIN
                OPEN CUR_CLIENTE_TIPO(V_TIPO_DOCUM, P_NUM_DOC, K_TIP_CLI);
                FETCH CUR_CLIENTE_TIPO
                INTO CUR_COD_CLI, CUR_TIP_CLI;

                WHILE CUR_CLIENTE_TIPO%FOUND LOOP
                  BEGIN
                  --Obtengo su saldo ClaroClub
                  SELECT NVL(admpn_saldo_cc, 0),
                       NVL(admpn_saldo_ib, 0),
                       NVL(admpc_estpto_ib, 0)
                    INTO V_SALDO_CC_AUX, V_SALDO_IB_AUX, V_EST_IB
                    FROM  admpt_saldos_cliente
                   WHERE admpv_cod_cli = CUR_COD_CLI
                     AND admpc_estpto_cc = 'A';

                  --Obtengo su Saldo Bono
                  SELECT NVL(SUM(SB.ADMPN_SALDO),0)
                    INTO V_SALDO_B_AUX
                    FROM  ADMPT_SALDOS_BONO_CLIENTE SB
                   WHERE SB.ADMPV_COD_CLI = CUR_COD_CLI;

                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    V_SALDO_CC_AUX  := 0;
                    V_SALDO_IB_AUX  := 0;
                    V_SALDO_B_AUX := 0;
                  END;

                  IF V_EST_IB <> 'A' THEN
                  V_SALDO_IB_AUX := 0;
                  END IF;

                  V_SALDO_IB      := V_SALDO_IB + V_SALDO_IB_AUX;
                  V_SALDO_CC      := V_SALDO_CC + V_SALDO_CC_AUX;
                  V_SALDO_CLIBONO := V_SALDO_CLIBONO + V_SALDO_B_AUX;

                  FETCH CUR_CLIENTE_TIPO
                  INTO CUR_COD_CLI, CUR_TIP_CLI;
                END LOOP;
                CLOSE CUR_CLIENTE_TIPO;

              END;

            ELSIF (K_TIP_CLI = '4' OR K_TIP_CLI = '8') THEN
              BEGIN
                OPEN CUR_CLIENTE_TIPO(V_TIPO_DOCUM, P_NUM_DOC, K_TIP_CLI);
                FETCH CUR_CLIENTE_TIPO
                  INTO CUR_COD_CLI, CUR_TIP_CLI;

                WHILE CUR_CLIENTE_TIPO%FOUND LOOP
                  BEGIN
                  SELECT NVL(admpn_saldo_cc, 0),
                       NVL(admpn_saldo_ib, 0),
                       NVL(admpc_estpto_ib, 0)
                    INTO V_SALDO_CC_AUX, V_SALDO_IB_AUX, V_EST_IB
                    FROM  admpt_saldos_cliente
                   WHERE admpv_cod_cli = CUR_COD_CLI
                     AND admpc_estpto_cc = 'A';

                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    V_SALDO_CC_AUX := 0;
                    V_SALDO_IB_AUX := 0;
                  END;
                  IF V_EST_IB <> 'A' THEN
                  V_SALDO_IB_AUX := 0;
                  END IF;

                  V_SALDO_IB := V_SALDO_IB + V_SALDO_IB_AUX;
                  V_SALDO_CC := V_SALDO_CC + V_SALDO_CC_AUX;

                  FETCH CUR_CLIENTE_TIPO
                  INTO CUR_COD_CLI, CUR_TIP_CLI;
                END LOOP;
                CLOSE CUR_CLIENTE_TIPO;
              END;
            ELSE
              IF (K_TIP_CLI = '2' OR K_TIP_CLI = '1') THEN
                BEGIN
                  OPEN CUR_CLIENTE(V_TIPO_DOCUM, P_NUM_DOC);
                  FETCH CUR_CLIENTE
                  INTO CUR_COD_CLI, CUR_TIP_CLI;

                  WHILE CUR_CLIENTE%FOUND LOOP
                  BEGIN
                    SELECT NVL(admpn_saldo_cc, 0),
                       NVL(admpn_saldo_ib, 0),
                       NVL(admpc_estpto_ib, 0)
                    INTO V_SALDO_CC_AUX, V_SALDO_IB_AUX, V_EST_IB
                    FROM  admpt_saldos_cliente
                     WHERE admpv_cod_cli = CUR_COD_CLI
                     AND admpc_estpto_cc = 'A';
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    V_SALDO_CC_AUX := 0;
                    V_SALDO_IB_AUX := 0;
                  END;

                  IF V_EST_IB <> 'A' THEN
                    V_SALDO_IB_AUX := 0;
                  END IF;

                  V_SALDO_IB := V_SALDO_IB + V_SALDO_IB_AUX;
                  V_SALDO_CC := V_SALDO_CC + V_SALDO_CC_AUX;

                  FETCH CUR_CLIENTE
                    INTO CUR_COD_CLI, CUR_TIP_CLI;
                  END LOOP;
                  CLOSE CUR_CLIENTE;
                END;
              ELSE
                RAISE no_parametros;
              END IF;
            END IF;
          ELSE
                -- NO, cliente claro club. SI, cliente IB if (nro_registrosCC=0 and nro_registrosIB>0) then
            IF K_TIP_CLI = 5 THEN
              -- Busca si el cliente es IB
                SELECT COUNT(1) INTO nro_registrosIB FROM  admpt_clienteib WHERE admpv_tipo_doc = V_TIPO_DOCUM
                 AND admpv_num_doc = P_NUM_DOC AND admpc_estado <> 'B';

                IF nro_registrosCC=0 AND nro_registrosIB>0 THEN
                    V_SALDO_CC := 0;
                    SELECT admpn_cod_cli_ib
                    INTO V_COD_CLI_IB
                    FROM  admpt_clienteib
                     WHERE admpv_tipo_doc = V_TIPO_DOCUM
                     AND admpv_num_doc = P_NUM_DOC
                     AND admpc_estado <> 'B';

                    SELECT NVL(admpn_saldo_ib, 0)
                    INTO V_SALDO_IB
                    FROM  admpt_saldos_cliente
                     WHERE admpn_cod_cli_ib = V_COD_CLI_IB;
                ELSE
                  RAISE NO_PARAMETROS;
                END IF;
            ELSE
              RAISE NO_DATA_FOUND;
            END IF;
          END IF;

          END; -- fin del begin !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!111

          ------ Realiza la validacion del bloqueo
           PKG_CC_TRANSACCION.ADMPS_VALBLOQUEOBOLSA(V_TIPO_DOCUM,P_NUM_DOC,K_TIP_CLI,V_TIP_DOC,V_EST_BLOQUEO,V_CODERROR,V_DESCERROR);

          IF P_COD_RESPUESTA <> 0 THEN
            RAISE EX_VALIDACION;
          END IF;

          IF V_EST_BLOQUEO = 'R' THEN
            V_CODERROR := 37;
            V_DESCERROR := 'Existe un canje en proceso. ';
          END IF;
          --------------------------------------

        BEGIN
          SELECT ADMPV_VALOR
          INTO C_CONSIDERA_IB
          FROM  ADMPT_PARAMSIST
           WHERE ADMPV_DESC = 'CONSIDERA_PUNTOS_IB';

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          C_CONSIDERA_IB := 'SI';
        END;

        IF C_CONSIDERA_IB = 'NO' THEN
          V_SALDO_IB := 0;
        END IF;

        P_SALDO_PUNTOS:= P_SALDO_PUNTOS+V_SALDO_CC + V_SALDO_IB+V_SALDO_CLIBONO;
        P_MENSAJE_RESPUESTA:= 'La transacción se realizó con éxito.';

      EXCEPTION
       WHEN NO_DATA_FOUND THEN
          P_COD_RESPUESTA := 40;
          P_MENSAJE_RESPUESTA := 'No se encontro informacion para los datos ingresados';
      END;

      FETCH CUR_CODIGOS_TIPOS
      INTO K_TIP_CLI;
      END LOOP;
      CLOSE CUR_CODIGOS_TIPOS;
    ELSE
          RAISE NO_DATA_FOUND;
    END IF;
  ELSE
      RAISE NO_PARAMETROS;
  END IF;


    /* *************************************************************************** */
  EXCEPTION
    WHEN NO_PARAMETROS THEN
         P_COD_RESPUESTA := 41;
         P_MENSAJE_RESPUESTA := 'Ingreso datos incorrectos o datos insuficientes para realizar la consulta';
    WHEN NO_DATA_FOUND THEN
         P_COD_RESPUESTA := 40;
         P_MENSAJE_RESPUESTA := 'No se encontro informacion para los datos ingresados';
    WHEN EX_VALIDACION THEN
         P_COD_RESPUESTA := V_CODERROR;
         P_MENSAJE_RESPUESTA := V_DESCERROR;
    WHEN OTHERS THEN
         P_COD_RESPUESTA := SQLCODE;
         P_MENSAJE_RESPUESTA := SUBSTR(SQLERRM, 1, 250);

END ADMPSS_CONSALDO;

PROCEDURE ADMPSS_CONSALDOBONO(K_COD_CLIENTE       IN VARCHAR2,
                                K_TIPO_DOC          IN VARCHAR2,
                                K_NUM_DOC           IN VARCHAR2,
                                K_TIP_CLI           IN VARCHAR2,
                                K_TIP_PRE           IN VARCHAR2,
                                K_CODERROR          OUT NUMBER,
                                K_MSJERROR          OUT VARCHAR2,
                                K_SALDO_PUNTOS      OUT NUMBER,
                                K_SALDO_PUNTOS_BONO OUT NUMBER,
                                K_SALDO_PUNTOS_CC   OUT NUMBER,
                                K_SALDO_PUNTOS_IB   OUT NUMBER,
                                K_SALDO_PUNTOS_B    OUT NUMBER,
                                K_CUR_LISTA         OUT SYS_REFCURSOR
                                /*K_CUR_BONO        OUT SYS_REFCURSOR*/) IS

    /****************************************************************
    '* Nombre SP           :  ADMPSS_CONSALDO
    '* Propósito           :  Consulta segun el codigo o numero de documento y el tipo de cliente, los saldos total,IB, CC y devuelve un cursor con los productos permitidos segun el puntaje total
    '* Input               :  K_COD_CLIENTE , K_TIPO_DOC, K_NUM_DOC, K_TIP_CLI
    '* Output              :  K_CODERROR, K_MSJERROR, K_SALDO_PUNTOS, K_SALDO_PUNTOS_CC, K_SALDO_PUNTOS_IB, K_CUR_LISTA
    '* Creado por          :  (Venkizmet) Rossana Janampa
    '* Fec Creación        :
    '* Fec Actualización   :  22/09/2010
    '****************************************************************/

    CURSOR CUR_CLIENTE(tipo_doc VARCHAR2, num_doc VARCHAR2) IS
      SELECT admpv_cod_cli, admpv_cod_tpocl
        FROM PCLUB.admpt_cliente
       WHERE (admpv_tipo_doc = tipo_doc AND admpv_num_doc = num_doc)
         AND admpc_estado = 'A'
         AND ((admpv_cod_tpocl = '1' OR admpv_cod_tpocl = '2'));

    CURSOR CUR_CLIENTE_TIPO(tipo_doc  VARCHAR2,
                            num_doc   VARCHAR2,
                            tipo_clie VARCHAR2) IS
      SELECT admpv_cod_cli, admpv_cod_tpocl
        FROM PCLUB.admpt_cliente
       WHERE (admpv_tipo_doc = tipo_doc AND admpv_num_doc = num_doc)
         AND admpc_estado = 'A'
         AND admpv_cod_tpocl = tipo_clie;

    --Datos del Cursor (Tipo_cliente)
    CUR_COD_CLI     PCLUB.admpt_cliente.admpv_cod_cli%TYPE;
    CUR_TIP_CLI     PCLUB.admpt_cliente.admpv_cod_tpocl%TYPE;
    -- Variables
    V_TIP_DOC       PCLUB.admpt_cliente.admpv_tipo_doc%TYPE;
    V_NUM_DOC       PCLUB.admpt_cliente.admpv_num_doc%TYPE;
    V_TIP_CLIE      PCLUB.admpt_cliente.admpv_cod_tpocl%TYPE;
    V_SALDO_B       NUMBER := 0;
    V_SALDO_IB      NUMBER := 0;
    V_SALDO_CC      NUMBER := 0;
    V_SALDO_IB_AUX  NUMBER := 0;
    V_SALDO_CC_AUX  NUMBER := 0;
    V_SALDO_CLIBONO NUMBER := 0;
    NO_PARAMETROS EXCEPTION;
    nro_registrosCC NUMBER := 0;
    nro_registrosIB NUMBER := 0;
    C_CONSIDERA_IB  VARCHAR2(50); -- SSC 09112010 - Migracion Loyalty
    V_COD_CLI_IB    NUMBER;
    V_EST_IB        CHAR(1);
    V_EST_BLOQUEO   CHAR(1);
    V_CODERROR      NUMBER;
    V_DESCERROR     VARCHAR2(300);
    EX_VALIDACION EXCEPTION;
  BEGIN

    K_SALDO_PUNTOS_CC   := 0;
    K_SALDO_PUNTOS_IB   := 0;
    K_SALDO_PUNTOS_B    := 0;
    K_SALDO_PUNTOS      := 0;
    K_SALDO_PUNTOS_BONO := 0;

    K_CODERROR := 0;

    /*
       Si el tipo de Cliente es Control se debera obtener la suma de los puntos cuya cuenta sea Control y Postpago
       Si el tipo de Cliente es Postpago se debera obtener la suma de los puntos cuya cuenta sea Control y Postpago
       Si el tipo de cliente es B2E solo se considerará los puntos cuyos cuentas sean B2E
       Si el tipo de cliente es Prepago solo se considerará los puntos cuyos cuentas sean Prepago
    */

    IF K_COD_CLIENTE IS NOT NULL AND K_TIP_CLI IS NOT NULL THEN
      /* La consulta se realiza por cuenta de cliente : SOLO PARA CLIENTES CLARO CLUB */
      BEGIN
        -- Con el código de cliente devuelve el tipo de documento y el numero de documento, debe devolver 0 ó 1 registro
        SELECT NVL(admpv_tipo_doc, 0),
               NVL(admpv_num_doc, 0),
               NVL(admpv_cod_tpocl, 0)
          INTO V_TIP_DOC, V_NUM_DOC, V_TIP_CLIE
          FROM PCLUB.admpt_cliente
         WHERE admpv_cod_cli = K_COD_CLIENTE
           AND admpc_estado = 'A';

        IF V_TIP_CLIE = '3' AND V_TIP_CLIE = K_TIP_CLI THEN
          BEGIN
            OPEN CUR_CLIENTE_TIPO(V_TIP_DOC, V_NUM_DOC, V_TIP_CLIE);
            FETCH CUR_CLIENTE_TIPO
              INTO CUR_COD_CLI, CUR_TIP_CLI;

            WHILE CUR_CLIENTE_TIPO%FOUND LOOP
              BEGIN
                SELECT NVL(admpn_saldo_cc, 0),
                       NVL(admpn_saldo_ib, 0),
                       NVL(admpc_estpto_ib, 0)
                  INTO V_SALDO_CC_AUX, V_SALDO_IB_AUX, V_EST_IB
                  FROM PCLUB.admpt_saldos_cliente
                 WHERE admpv_cod_cli = CUR_COD_CLI
                   AND admpc_estpto_cc = 'A';

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  V_SALDO_CC_AUX := 0;
                  V_SALDO_IB_AUX := 0;
              END;

              IF V_EST_IB <> 'A' THEN
                V_SALDO_IB_AUX := 0;
              END IF;

              V_SALDO_IB := V_SALDO_IB + V_SALDO_IB_AUX;
              V_SALDO_CC := V_SALDO_CC + V_SALDO_CC_AUX;

              FETCH CUR_CLIENTE_TIPO
                INTO CUR_COD_CLI, CUR_TIP_CLI;
            END LOOP;
            CLOSE CUR_CLIENTE_TIPO;

            --Obtengo el Saldo Bono Total del Cliente
            SELECT NVL(SUM(SB.ADMPN_SALDO),0)
              INTO V_SALDO_CLIBONO
            FROM PCLUB.ADMPT_SALDOS_BONO_CLIENTE SB
            WHERE SB.ADMPV_COD_CLI = K_COD_CLIENTE;

            --Obtengo el Saldo Bono del Cliente, por Tipo de Premio
            SELECT NVL(SUM(SB.ADMPN_SALDO),0)
              INTO V_SALDO_B
            FROM PCLUB.ADMPT_SALDOS_BONO_CLIENTE SB
            WHERE SB.ADMPV_COD_CLI = K_COD_CLIENTE
               AND SB.ADMPN_GRUPO = K_TIP_PRE;

          END;
        ELSIF (V_TIP_CLIE = '4' or V_TIP_CLIE = '8') AND
              V_TIP_CLIE = K_TIP_CLI THEN
          BEGIN
            OPEN CUR_CLIENTE_TIPO(V_TIP_DOC, V_NUM_DOC, V_TIP_CLIE);
            FETCH CUR_CLIENTE_TIPO
              INTO CUR_COD_CLI, CUR_TIP_CLI;

            WHILE CUR_CLIENTE_TIPO%FOUND LOOP
              BEGIN
                SELECT NVL(admpn_saldo_cc, 0),
                       NVL(admpn_saldo_ib, 0),
                       NVL(admpc_estpto_ib, 0)
                  INTO V_SALDO_CC_AUX, V_SALDO_IB_AUX, V_EST_IB
                FROM PCLUB.admpt_saldos_cliente
                WHERE admpv_cod_cli = CUR_COD_CLI
                   AND admpc_estpto_cc = 'A';

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  V_SALDO_CC_AUX := 0;
                  V_SALDO_IB_AUX := 0;
              END;

              IF V_EST_IB <> 'A' THEN
                V_SALDO_IB_AUX := 0;
              END IF;

              V_SALDO_IB := V_SALDO_IB + V_SALDO_IB_AUX;
              V_SALDO_CC := V_SALDO_CC + V_SALDO_CC_AUX;

              FETCH CUR_CLIENTE_TIPO
                INTO CUR_COD_CLI, CUR_TIP_CLI;
            END LOOP;
            CLOSE CUR_CLIENTE_TIPO;
          END;
        ELSE
          IF (K_TIP_CLI = '2' AND (V_TIP_CLIE = '1' OR V_TIP_CLIE = '2')) OR
             (K_TIP_CLI = '1' AND (V_TIP_CLIE = '1' OR V_TIP_CLIE = '2')) THEN

            OPEN CUR_CLIENTE(V_TIP_DOC, V_NUM_DOC);
            FETCH CUR_CLIENTE
              INTO CUR_COD_CLI, CUR_TIP_CLI;

            WHILE CUR_CLIENTE%FOUND LOOP
              BEGIN
                -- Buscar en Saldos_cliente
                SELECT NVL(admpn_saldo_cc, 0),
                       NVL(admpn_saldo_ib, 0),
                       NVL(admpc_estpto_ib, 0)
                  INTO V_SALDO_CC_AUX, V_SALDO_IB_AUX, V_EST_IB
                FROM PCLUB.admpt_saldos_cliente
                WHERE admpv_cod_cli = CUR_COD_CLI
                   AND admpc_estpto_cc = 'A';

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  V_SALDO_CC_AUX := 0;
                  V_SALDO_IB_AUX := 0;
              END;

              IF V_EST_IB <> 'A' THEN
                V_SALDO_IB_AUX := 0;
              END IF;

              V_SALDO_IB := V_SALDO_IB + V_SALDO_IB_AUX;
              V_SALDO_CC := V_SALDO_CC + V_SALDO_CC_AUX;

              FETCH CUR_CLIENTE
                INTO CUR_COD_CLI, CUR_TIP_CLI;
            END LOOP;

            CLOSE CUR_CLIENTE;
          ELSE
            RAISE no_parametros;
          END IF;
        END IF;
      END;

      -- Realiza la validación del bloqueo
      PCLUB.PKG_CC_TRANSACCION.ADMPS_VALBLOQUEOBOLSA(V_TIP_DOC,
                            V_NUM_DOC,
                            V_TIP_CLIE,
                            V_TIP_DOC,
                            V_EST_BLOQUEO,
                            V_CODERROR,
                            V_DESCERROR);

      IF K_CODERROR <> 0 THEN
        RAISE EX_VALIDACION;
      END IF;

      IF V_EST_BLOQUEO = 'R' THEN
        V_CODERROR  := 37;
        V_DESCERROR := 'Existe un canje en proceso. ';
      END IF;
      --------------------------------------
    ELSE
      /* la consulta se realiza por número de documento: Podria ser clientes IB o CLARO CLUB */
      IF (K_TIPO_DOC IS NOT NULL AND K_NUM_DOC IS NOT NULL) AND
         K_TIP_CLI IS NOT NULL THEN
        BEGIN
          -- Busca si el cliente es CC
          SELECT COUNT(1)
            INTO nro_registrosCC
            FROM PCLUB.admpt_cliente
           WHERE admpv_tipo_doc = K_TIPO_DOC
             AND admpv_num_doc = K_NUM_DOC
             AND admpc_estado = 'A'
             AND (admpv_cod_tpocl = K_TIP_CLI OR
                 (K_TIP_CLI = '1' AND
                 (admpv_cod_tpocl = '2' OR admpv_cod_tpocl = '1')) OR
                 (K_TIP_CLI = '2' AND
                 (admpv_cod_tpocl = '2' OR admpv_cod_tpocl = '1')));
          -- Busca si el cliente es IB
          SELECT COUNT(1)
            INTO nro_registrosIB
            FROM PCLUB.admpt_clienteib
           WHERE admpv_tipo_doc = K_TIPO_DOC
             AND admpv_num_doc = K_NUM_DOC
             AND admpc_estado <> 'B';

          IF nro_registrosCC = 0 AND nro_registrosIB = 0 THEN
            RAISE NO_PARAMETROS;
          END IF;

          IF (nro_registrosCC > 0 AND nro_registrosIB > 0) OR
             (nro_registrosCC > 0 AND nro_registrosIB = 0) THEN
            --SI cliente claro club. NO/SI, es cliente IB
            IF (K_TIP_CLI = '3' OR K_TIP_CLI = '4' OR K_TIP_CLI = '8') THEN
              BEGIN
                OPEN CUR_CLIENTE_TIPO(K_TIPO_DOC, K_NUM_DOC, K_TIP_CLI);
                FETCH CUR_CLIENTE_TIPO
                  INTO CUR_COD_CLI, CUR_TIP_CLI;

                WHILE CUR_CLIENTE_TIPO%FOUND LOOP
                  BEGIN
                    SELECT NVL(admpn_saldo_cc, 0),
                           NVL(admpn_saldo_ib, 0),
                           NVL(admpc_estpto_ib, 0)
                      INTO V_SALDO_CC_AUX, V_SALDO_IB_AUX, V_EST_IB
                      FROM PCLUB.admpt_saldos_cliente
                     WHERE admpv_cod_cli = CUR_COD_CLI
                       AND admpc_estpto_cc = 'A';

                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      V_SALDO_CC_AUX := 0;
                      V_SALDO_IB_AUX := 0;
                  END;
                  IF V_EST_IB <> 'A' THEN
                    V_SALDO_IB_AUX := 0;
                  END IF;

                  V_SALDO_IB := V_SALDO_IB + V_SALDO_IB_AUX;
                  V_SALDO_CC := V_SALDO_CC + V_SALDO_CC_AUX;

                  FETCH CUR_CLIENTE_TIPO
                    INTO CUR_COD_CLI, CUR_TIP_CLI;
                END LOOP;
                CLOSE CUR_CLIENTE_TIPO;
              END;
            ELSE
              IF (K_TIP_CLI = '2' OR K_TIP_CLI = '1') THEN
                BEGIN
                  OPEN CUR_CLIENTE(K_TIPO_DOC, K_NUM_DOC);
                  FETCH CUR_CLIENTE
                    INTO CUR_COD_CLI, CUR_TIP_CLI;

                  WHILE CUR_CLIENTE%FOUND LOOP
                    BEGIN
                      SELECT NVL(admpn_saldo_cc, 0),
                             NVL(admpn_saldo_ib, 0),
                             NVL(admpc_estpto_ib, 0)
                        INTO V_SALDO_CC_AUX, V_SALDO_IB_AUX, V_EST_IB
                        FROM PCLUB.admpt_saldos_cliente
                       WHERE admpv_cod_cli = CUR_COD_CLI
                         AND admpc_estpto_cc = 'A';
                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                        V_SALDO_CC_AUX := 0;
                        V_SALDO_IB_AUX := 0;
                    END;

                    IF V_EST_IB <> 'A' THEN
                      V_SALDO_IB_AUX := 0;
                    END IF;

                    V_SALDO_IB := V_SALDO_IB + V_SALDO_IB_AUX;
                    V_SALDO_CC := V_SALDO_CC + V_SALDO_CC_AUX;

                    FETCH CUR_CLIENTE
                      INTO CUR_COD_CLI, CUR_TIP_CLI;
                  END LOOP;
                END;
              ELSE
                RAISE no_parametros;
              END IF;
            END IF;
          ELSE
            -- NO, cliente claro club. SI, cliente IB if (nro_registrosCC=0 and nro_registrosIB>0) then
            IF K_TIP_CLI = 5 THEN
              V_SALDO_CC := 0;
              SELECT admpn_cod_cli_ib
                INTO V_COD_CLI_IB
                FROM PCLUB.admpt_clienteib
               WHERE admpv_tipo_doc = K_TIPO_DOC
                 AND admpv_num_doc = K_NUM_DOC
                 AND admpc_estado <> 'B';
              SELECT NVL(admpn_saldo_ib, 0)
                INTO V_SALDO_IB
                FROM PCLUB.admpt_saldos_cliente
               WHERE admpn_cod_cli_ib = V_COD_CLI_IB;
            ELSE
              RAISE NO_PARAMETROS;
            END IF;
          END IF;
        END;
        -- Realiza la validación del bloqueo
        PCLUB.PKG_CC_TRANSACCION.ADMPS_VALBLOQUEOBOLSA(K_TIPO_DOC,
                              K_NUM_DOC,
                              K_TIP_CLI,
                              V_TIP_DOC,
                              V_EST_BLOQUEO,
                              V_CODERROR,
                              V_DESCERROR);

        IF K_CODERROR <> 0 THEN
          RAISE EX_VALIDACION;
        END IF;

        IF V_EST_BLOQUEO = 'R' THEN
          V_CODERROR  := 37;
          V_DESCERROR := 'Existe un canje en proceso. ';
        END IF;
        --------------------------------------
      ELSE
        RAISE NO_PARAMETROS;
      END IF;
    END IF;

    BEGIN
      SELECT ADMPV_VALOR
        INTO C_CONSIDERA_IB
        FROM PCLUB.ADMPT_PARAMSIST
       WHERE UPPER(ADMPV_DESC) = 'CONSIDERA_PUNTOS_IB';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        C_CONSIDERA_IB := 'SI';
    END;
    IF C_CONSIDERA_IB = 'NO' THEN
      V_SALDO_IB := 0;
    END IF;

    K_SALDO_PUNTOS_CC   := V_SALDO_CC;
    K_SALDO_PUNTOS_IB   := V_SALDO_IB;
    K_SALDO_PUNTOS_B    := V_SALDO_B;
    K_SALDO_PUNTOS_BONO := V_SALDO_CLIBONO; --Saldo de Bonos
    K_SALDO_PUNTOS      := K_SALDO_PUNTOS_CC + K_SALDO_PUNTOS_IB +
                           K_SALDO_PUNTOS_B;

    IF K_TIP_CLI IS NOT NULL THEN
      -- Obtener Productos según el tipo de datos enviado en el parámetro
      OPEN K_CUR_LISTA FOR

        SELECT pr.admpv_id_procla   AS ProdId,
               pr.admpv_desc        AS ProdDes,
               pr.admpv_campana     AS Campana,
               pr.admpn_puntos      AS Puntos,
               pr.admpn_pago        AS pago,
               t_pr.admpv_desc      AS t_pr,
               pr.admpn_cod_servc   AS servcomercial,
               pr.admpn_mnt_recar   AS montorecarga,
               pr.admpv_cod_paqdat  AS codigo_paquete,
               t_pr.admpv_cod_tpopr AS Cod_t_pr
          FROM PCLUB.admpt_premio        pr,
               PCLUB.admpt_tipo_premio   t_pr,
               PCLUB.admpt_tipo_premclie t_pre_cli
         WHERE pr.admpv_cod_tpopr = t_pr.admpv_cod_tpopr
           AND pr.admpv_cod_tpopr = t_pre_cli.admpv_cod_tpopr
           AND t_pr.admpv_cod_tpopr = t_pr.admpv_cod_tpopr
           AND t_pr.ADMPN_GRUPO = K_TIP_PRE
           AND t_pre_cli.admpv_cod_tpocl = K_TIP_CLI
           AND pr.admpc_estado = 'A'
           AND pr.admpn_puntos <= K_SALDO_PUNTOS
           AND pr.admpv_id_procla not in
               (select admpv_id_procla
                  from PCLUB.ADMPT_EXCPREMIO_TIPOCLIE
                 where admpv_cod_tpocl = K_TIP_CLI)
           AND PR.ADMPN_PUNTOS <> 0
         ORDER BY t_pr.admpn_orden, pr.admpn_puntos DESC;

    END IF;

    --Obtiene el Saldo Bono de la línea consultada

    /*    IF K_COD_CLIENTE IS NOT NULL THEN
      OPEN K_CUR_BONO FOR
      SELECT G.ADMPV_DESCRIPCION TIPPUNTO, SB.ADMPN_SALDO PUNTOS
            FROM PCLUB.ADMPT_SALDOS_BONO_CLIENTE SB
            LEFT OUTER JOIN PCLUB.ADMPT_GRUPO_TIPPREM G
              ON SB.ADMPN_GRUPO = G.ADMPN_GRUPO
           WHERE SB.ADMPV_COD_CLI = K_COD_CLIENTE;
    ELSE
      OPEN K_CUR_BONO FOR
        SELECT '' TIPPUNTO, '' PUNTOS FROM DUAL;
    END IF;*/

    /* *************************************************************************** */
  EXCEPTION
    WHEN NO_PARAMETROS THEN
      K_CODERROR := 41;
      K_MSJERROR := 'Ingresó datos incorrectos o datos insuficientes para realizar la consulta';

      OPEN K_CUR_LISTA FOR
        SELECT '' ProdId,
               '' ProdDes,
               '' Campana,
               '' Puntos,
               '' pago,
               '' t_pr,
               '' ServComercial,
               '' MontoRecarga,
               '' Codigo_Paquete,
               '' Cod_t_pr
          FROM DUAL;

    /*OPEN K_CUR_BONO FOR
    SELECT '' TIPPUNTO, '' PUNTOS FROM DUAL;*/

    WHEN NO_DATA_FOUND THEN
      IF V_TIP_DOC IS NULL OR V_NUM_DOC IS NULL OR V_TIP_CLIE IS NULL THEN
        K_CODERROR := 40;
        K_MSJERROR := 'No se encontró información para los datos ingresados';
      END IF;

      OPEN K_CUR_LISTA FOR
        SELECT '' ProdId,
               '' ProdDes,
               '' Campana,
               '' Puntos,
               '' pago,
               '' t_pr,
               '' ServComercial,
               '' MontoRecarga,
               '' Codigo_Paquete,
               '' Cod_t_pr
          FROM DUAL;

    /*OPEN K_CUR_BONO FOR
    SELECT '' TIPPUNTO, '' PUNTOS FROM DUAL;*/

    WHEN EX_VALIDACION THEN
      K_CODERROR := V_CODERROR;
      K_MSJERROR := V_DESCERROR;
    WHEN OTHERS THEN
      K_CODERROR := SQLCODE;
      K_MSJERROR := SUBSTR(SQLERRM, 1, 250);

      OPEN K_CUR_LISTA FOR
        SELECT '' ProdId,
               '' ProdDes,
               '' Campana,
               '' Puntos,
               '' pago,
               '' t_pr,
               '' ServComercial,
               '' MontoRecarga,
               '' Codigo_Paquete,
               '' Cod_t_pr
          FROM DUAL;

    /*OPEN K_CUR_BONO FOR
    SELECT '' TIPPUNTO, '' PUNTOS FROM DUAL;*/
  END ADMPSS_CONSALDOBONO;

  PROCEDURE ADMPSS_CONSCLIENTE(
   K_COD_CLIENTE IN VARCHAR2,
   K_RESULTADO OUT SYS_REFCURSOR
  )
  IS
  BEGIN
    OPEN K_RESULTADO FOR
    SELECT  ADMPV_COD_CLI,
        ADMPV_NOM_CLI,
        ADMPV_APE_CLI
    FROM    PCLUB.ADMPT_CLIENTE
    WHERE   admpv_cod_cli  = K_COD_CLIENTE
    AND     admpc_estado ='A';

  END;
  PROCEDURE ADMPSS_CONSPROD(K_CODPROD       IN VARCHAR2,
                            K_PUNTOS        IN NUMBER,
                            K_CODERROR      OUT NUMBER,
                            K_MSJERROR      OUT VARCHAR2,
                            CursorProductos OUT SYS_REFCURSOR) IS

    --****************************************************************
    -- Nombre SP           :  ADMPSS_CONSPROD
    -- Propósito           :  Recuperar una lista de configuraciones por producto
    -- Input               :  K_CODPROD - Codigo del Producto
    --
    -- Output              :  CursorProducto con la lista de configuraciones por producto
    --
    -- Creado por          :  Sofia Khlebnikov
    -- Fec Creación        :  08/09/2010
    -- Fec Actualización   :
    --****************************************************************

    ERRORDATOS EXCEPTION;

  BEGIN
    IF (K_CODPROD IS NOT NULL) THEN
      BEGIN
        OPEN CursorProductos FOR
          SELECT p.ADMPV_ID_PROCLA,
                 p.ADMPV_DESC,
                 p.ADMPV_CAMPANA,
                 p.ADMPN_PUNTOS,
                 p.ADMPN_PAGO
            FROM PCLUB.ADMPT_PREMIO p
           WHERE p.ADMPV_ID_PROCLA = K_CODPROD
             AND p.ADMPC_ESTADO <> 'B';
      END;

    ELSE
      RAISE ERRORDATOS;

    END IF;

    K_CODERROR := 0; -- Correcto
    K_MSJERROR := '';

  EXCEPTION
    WHEN ERRORDATOS THEN
      K_CODERROR := 35;
      K_MSJERROR := 'El codigo del producto es obligatorio';

    WHEN OTHERS THEN
      K_CODERROR := SQLCODE;
      K_MSJERROR := SUBSTR(SQLERRM, 1, 400);

  END;

  PROCEDURE ADMPSS_CANJPROD(K_ID_SOLICITUD IN VARCHAR2,
                            K_COD_CLIENTE  IN VARCHAR2,
                            K_TIPO_DOC     IN VARCHAR2,
                            K_NUM_DOC      IN VARCHAR2,
                            K_PUNTOVENTA   IN VARCHAR2,
                            K_TIP_CLI      IN VARCHAR2,
                            K_COD_APLI     IN VARCHAR2,
                            K_CLAVE        IN VARCHAR2,
                            K_MSJSMSIN     IN VARCHAR2,
                            K_TICKET       IN VARCHAR2,
                            K_LISTA_PEDIDO IN LISTA_PEDIDO,
                            K_ID_LOYALTY   IN VARCHAR2,
                            K_ID_GPRS      IN VARCHAR2,
                            K_NUM_LINEA    IN     VARCHAR2,
                            K_COD_ASESOR       IN     VARCHAR2,
                            K_NOM_ASESOR       IN     VARCHAR2,
                            K_CODSEGMENTO  IN VARCHAR2,
                            K_USU_ASEG     IN VARCHAR2,
                            K_TIPCANJE     IN NUMBER,
                            K_TIPPRECANJE  IN NUMBER,
                            K_CODERROR     OUT NUMBER,
                            K_MSJERROR     OUT VARCHAR2,
                            K_SALDO        OUT NUMBER,
                            K_MSJSMS       OUT VARCHAR2,
                            K_LISTA_CANJE  OUT SYS_REFCURSOR) is
    --****************************************************************
    -- Nombre SP           :  ADMPSS_CANJPROD
    -- Propósito           :  Registrar un canje
    -- Input               :  K_ID_SOLICITUD - Numero interno generado por Claro
    --                        K_COD_CLIENTE - Codigo de Cliente
    --                        K_TIPO_DOC - Tipo de Documento
    --                        K_NUM_DOC - Numero de Documento
    --                        K_PUNTOVENTA - Punto de Venta desde donde se realiza el canje
    --                        K_TIP_CLI - Tipo de Cliente
    --                        K_COD_APLI - Código de Aplicación
    --                        K_CLAVE - Palabra Clave
    --                        K_MSJSMSIN - Mensaje SMS
    --                        K_LISTA_PEDIDO - Lista de Pedidos para el Canje
    --
    -- Output              :  K_CODERROR     --> Código de Error (si se presento)
    --                        K_MSJERROR     --> Mensaje de Error
    --                        K_SALDO        --> Saldo luego de registrar el canje
    --                        K_MSJSMS     --> Mensaje SMS
    -- Creado por          :  Rossana Janampa
    -- Fec Creación        :  27/09/2010
    -- Fec Actualización   :
    --****************************************************************

    V_COD_CANJE NUMBER;
    V_ID_KARDEX NUMBER;

    /* Campos para la Lista de Pedidos
    TYPE proidlist IS TABLE OF PCLUB.admpt_canje_detalle.admpv_id_procla%TYPE;
    TYPE campanalist IS TABLE OF PCLUB.admpt_premio.admpv_campana%TYPE;
    TYPE puntoslist IS TABLE OF PCLUB.admpt_canje_detalle.admpn_puntos%TYPE;
    TYPE pagolist IS TABLE OF PCLUB.admpt_canje_detalle.admpn_pago%TYPE;
    TYPE cantidadlist IS TABLE OF PCLUB.admpt_canje_detalle.admpn_cantidad%TYPE;
    TYPE tipopremiolist IS TABLE OF PCLUB.admpt_canje_detalle.admpv_cod_tpopr%TYPE;
    TYPE servcomerciallist IS TABLE OF PCLUB.admpt_canje_detalle.admpn_cod_servc%TYPE;
    TYPE montorecargalista IS TABLE OF PCLUB.admpt_canje_detalle.admpn_mnt_recar%TYPE;

    L_LP_PROID          proidlist;
    L_LP_CAMPANA        campanalist;
    L_LP_PUNTOS         puntoslist;
    L_LP_PAGO           pagolist;
    L_LP_CANTIDAD       cantidadlist;
    L_LP_TIPOPREMIO     tipopremiolist;
    L_LP_SERVCOMERCIAL  servcomerciallist;
    L_LP_MONTORECARGA   montorecargalista;
    */
    V_PEDIDO PEDIDO;

    V_SEC               NUMBER;
    V_DESC_PREMIO       VARCHAR2(150);
    V_PUNTOS_REQUERIDOS NUMBER := 0;
    V_NUM_DOC           VARCHAR2(20);

    V_SALDO NUMBER;
    NO_CLIENTE EXCEPTION;
    NO_LISTA_PEDIDO EXCEPTION;
    NO_SALDO EXCEPTION;
    NO_SALDO_CANJE EXCEPTION; --nuevo
    NO_DESC_PUNTOS EXCEPTION;
    NO_PARAMETROS EXCEPTION;
    NO_COD_APLICACION EXCEPTION;
    NO_SLD_KDX_ALINEADO EXCEPTION;
    NO_DATOS_VALIDOS EXCEPTION;
    V_CODERROR  NUMBER;
    V_ENCUESTA CHAR(1);
    V_COD_CPTO  NUMBER;
    V_DESCERROR VARCHAR2(400);
    EX_BLOQUEO EXCEPTION;
    EX_DESBLOQUEO EXCEPTION;
    NO_VALBLOQUEO EXCEPTION;
    NO_LIBERADO EXCEPTION;
    K_ESTADO CHAR(1);
    V_TIPO_DOC VARCHAR2(20);
    K_CODERROR_EX  NUMBER;
    K_MSJERROR_EX VARCHAR2(400);
    V_EXISTE    NUMBER;
    V_TIPO_DOC_B VARCHAR2(20);
    V_SEGMENTO     VARCHAR2(50) := K_CODSEGMENTO;
    V_NRODOCSEGM   VARCHAR2(21);
    V_LONDOCSEGM   NUMBER;
    V_NOMCLISEGM   VARCHAR2(400);
    V_MSJOKYSEGM   VARCHAR2(400);
    V_CODERRSEGM   NUMBER;
    V_MSJERRSEGM   VARCHAR2(400);
    V_CUR_SEGM     SYS_REFCURSOR;
    VC_CODSEGM     VARCHAR2(50);
    VC_DSCSEGM     VARCHAR2(50);
    VC_CODTCLIE    VARCHAR2(2);
    VC_DSCTCLIE    VARCHAR2(50);
    VC_CODTPREM    VARCHAR2(2);
    VC_DSCTPREM    VARCHAR2(50);
    VC_VALSEGM     VARCHAR2(50);
    VC_PTOSDSCTO   NUMBER;
    V_ARRVALSEGM   TAB_ARRAY;
    V_ARRPUNTOS    TAB_ARRAY;
    V_ARRPTOSDSCTO TAB_ARRAY;
  BEGIN
    /*
    Los puntos IB son los q se consumiran primero Tipo de punto 'I'
    los puntos Loyalty 'L' y ClaroClub 'C', se consumiran en ese orden
    */
    IF K_COD_CLIENTE IS NULL THEN
      RAISE NO_PARAMETROS;
    END IF;

    if K_COD_APLI is null then
      raise NO_COD_APLICACION;
    end if;

    V_TIPO_DOC_B := F_OBTENERTIPODOC(K_TIPO_DOC);
    /*Validamos que se trate de un Cliente válido*/
    SELECT count(1)
      INTO V_EXISTE
      FROM PCLUB.admpt_cliente
     WHERE admpv_cod_cli = K_COD_CLIENTE
       AND admpv_tipo_doc = V_TIPO_DOC_B
       AND admpv_num_doc = K_NUM_DOC
       AND admpc_estado = 'A';

IF V_EXISTE = 0 THEN
       K_CODERROR  := 49;
       RAISE NO_DATOS_VALIDOS;
     END IF;

    PCLUB.PKG_CC_TRANSACCION.ADMPSI_ES_CLIENTE_CJE(K_COD_CLIENTE,
                      K_TIPO_DOC,
                      K_NUM_DOC,
                      K_TIP_CLI,
                      K_TIPCANJE,
                      K_TIPPRECANJE,
                      V_SALDO,
                      K_CODERROR);
    IF K_CODERROR <> 0 THEN
      RAISE NO_CLIENTE;
    END IF;

    IF V_SALDO <= 0 THEN
      RAISE NO_SALDO;
    END IF;

    PCLUB.PKG_CC_TRANSACCION.ADMPI_BLOQUEOBOLSA(K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,K_COD_ASESOR,K_ESTADO,K_CODERROR,K_MSJERROR);

    IF K_CODERROR = 0 AND K_ESTADO = 'L' THEN
      PCLUB.PKG_CC_TRANSACCION.ADMPSS_VALIDASALDOKDX(K_COD_CLIENTE,
                      K_TIP_CLI,
                      K_CODERROR);
    ELSE
        IF K_CODERROR = 37 AND K_ESTADO = 'R' THEN
          RAISE NO_LIBERADO;
        ELSE
          RAISE EX_BLOQUEO;
        END IF;
    END IF;

IF K_CODERROR = 1 THEN
      RAISE NO_SLD_KDX_ALINEADO;
    END IF;

    -----  Obtiene la suma de puntos requeridos para comparar el saldo disponible con los puntos requeridos  -----
    --fetch K_LISTA_PEDIDO BULK COLLECT into L_LP_PROID, L_LP_CAMPANA, L_LP_PUNTOS, L_LP_PAGO, L_LP_CANTIDAD, L_LP_TIPOPREMIO, L_LP_SERVCOMERCIAL, L_LP_MONTORECARGA;

    IF K_LISTA_PEDIDO.COUNT = 0 THEN
      RAISE NO_LISTA_PEDIDO;
    END IF;

    --Si el punto de venta es MSM entonces obtener segmento
    IF ( K_PUNTOVENTA = 'SMS' OR K_PUNTOVENTA = 'IVR')THEN --cambio
      BEGIN
        V_NRODOCSEGM := RPAD(TRIM(K_NUM_DOC), 21, 'X');
        V_LONDOCSEGM := LENGTH(TRIM(K_NUM_DOC));

        dm.PKG_SEGMENTACION.SS_OBTENER_SEGMENTO@dbl_reptdm_d('D',
                                                             V_LONDOCSEGM,
                                                             V_NRODOCSEGM,
                                                             V_SEGMENTO,
                                                             V_NOMCLISEGM,
                                                             V_MSJOKYSEGM,
                                                             V_MSJOKYSEGM,
                                                             V_MSJOKYSEGM,
                                                             V_MSJOKYSEGM,
                                                             V_CODERRSEGM,
                                                             V_MSJERRSEGM);
        IF V_CODERRSEGM <> 0 THEN
          V_SEGMENTO := 'C';
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          V_SEGMENTO := 'C';
      END;
    END IF;

    FOR i IN K_LISTA_PEDIDO.FIRST .. K_LISTA_PEDIDO.LAST LOOP
      V_PEDIDO            := K_LISTA_PEDIDO(i);
      -- Si el punto de venta es MSM entonces obtener Valor Segmento
      IF ( K_PUNTOVENTA = 'SMS' OR K_PUNTOVENTA = 'IVR') THEN  --cambio
        BEGIN
          PCLUB.PKG_CC_MANTENIMIENTO.ADMPSS_LIST_DSCTO_SEG_TCLIE(V_SEGMENTO,
                                                           K_TIP_CLI,
                                                           V_PEDIDO.TipoPremio,
                                                           'A',
                                                           V_CUR_SEGM,
                                                           V_CODERRSEGM,
                                                           V_MSJERRSEGM);

          VC_VALSEGM   := 0;
          VC_PTOSDSCTO := V_PEDIDO.Puntos;
          IF V_CODERRSEGM = 0 THEN
            FETCH V_CUR_SEGM
              INTO VC_CODSEGM,
                   VC_DSCSEGM,
                   VC_CODTCLIE,
                   VC_DSCTCLIE,
                   VC_CODTPREM,
                   VC_DSCTPREM,
                   VC_VALSEGM,
                   VC_DSCTCLIE,
                   VC_DSCTCLIE;
            WHILE V_CUR_SEGM%FOUND LOOP
              FETCH V_CUR_SEGM
                INTO VC_CODSEGM,
                     VC_DSCSEGM,
                     VC_CODTCLIE,
                     VC_DSCTCLIE,
                     VC_CODTPREM,
                     VC_DSCTPREM,
                     VC_VALSEGM,
                     VC_DSCTCLIE,
                     VC_DSCTCLIE;
            END LOOP;
            VC_PTOSDSCTO := FLOOR((1 - VC_VALSEGM / 100) * V_PEDIDO.Puntos);
          END IF;

          V_PEDIDO.ValSegmento := VC_VALSEGM;
          V_PEDIDO.PuntosDscto := V_PEDIDO.Puntos - VC_PTOSDSCTO;
          V_PEDIDO.Puntos := VC_PTOSDSCTO;
          V_ARRVALSEGM(i) := V_PEDIDO.ValSegmento;
          V_ARRPTOSDSCTO(i) := V_PEDIDO.PuntosDscto;
          V_ARRPUNTOS(i) := V_PEDIDO.Puntos;
        EXCEPTION
          WHEN OTHERS THEN
            V_PEDIDO.ValSegmento := 0;
            V_PEDIDO.PuntosDscto := 0;
            V_ARRVALSEGM(i) := 0;
            V_ARRPTOSDSCTO(i) := 0;
            V_ARRPUNTOS(i) := V_PEDIDO.Puntos;
        END;
      END IF;
      V_PUNTOS_REQUERIDOS := V_PUNTOS_REQUERIDOS +
                             V_PEDIDO.Puntos * V_PEDIDO.Cantidad;
    END LOOP;

    IF V_PUNTOS_REQUERIDOS > V_SALDO THEN
      RAISE NO_SALDO_CANJE;
    END IF;

    -- Comienza el Canje, dato de entrada el codigo de cliente
    -- Parámetros
    SELECT NVL(PCLUB.admpt_canje_sq.NEXTVAL, '-1')
      INTO V_COD_CANJE
      FROM dual;
    IF K_NUM_DOC IS NULL THEN
      SELECT admpv_num_doc
        INTO V_NUM_DOC
        FROM PCLUB.admpt_cliente
       WHERE admpv_cod_cli = K_COD_CLIENTE
         AND admpc_estado = 'A';
    ELSE
      V_NUM_DOC := K_NUM_DOC;
    END IF;

    SAVEPOINT POINT_CANJE;
    -- Inserta entrada en la tabla CANJE
    INSERT INTO PCLUB.admpt_canje
      (admpv_id_canje,
       admpv_cod_cli,
       admpv_id_solic,
       admpv_pto_venta,
       admpd_fec_canje,
       admpv_hra_canje,
       admpv_num_doc,
       admpv_cod_tpocl,
       admpv_cod_aseso,
       admpv_nom_aseso,
       admpc_tpo_oper,
       admpv_cod_tipapl,
       admpv_clave,
       admpv_mensaje,
       admpv_ticket,
       admpv_id_loyalty,
       admpv_id_gprs,
       admpv_num_linea,
       ADMPV_CODSEGMENTO,
       ADMPV_USU_ASEG,
       ADMPN_TIPCANJE,
       ADMPN_TIPPREMCJE)
    values
      (V_COD_CANJE,
       K_COD_CLIENTE,
       K_ID_SOLICITUD,
       K_PUNTOVENTA,
       TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
       TO_CHAR(SYSDATE, 'HH:MI AM'),
       V_NUM_DOC,
       K_TIP_CLI,
       k_cod_asesor,
       k_nom_asesor,
       'C',
       K_COD_APLI,
       K_CLAVE,
       K_MSJSMSIN,
       K_TICKET,
       K_ID_LOYALTY,
       K_ID_GPRS,
       k_num_linea,
       V_SEGMENTO,
       K_USU_ASEG,
       K_TIPCANJE,
       K_TIPPRECANJE);

    -- Inserta entrada en la tabla CANJE_DETALLE
    V_SEC := 1;

    FOR i IN K_LISTA_PEDIDO.FIRST .. K_LISTA_PEDIDO.LAST LOOP
      V_PEDIDO := K_LISTA_PEDIDO(i);
      IF ( K_PUNTOVENTA = 'SMS' OR K_PUNTOVENTA = 'IVR') THEN --cambio
        V_PEDIDO.ValSegmento := V_ARRVALSEGM(i);
        V_PEDIDO.PuntosDscto := V_ARRPTOSDSCTO(i);
        V_PEDIDO.Puntos      := V_ARRPUNTOS(i);
      END IF;

      -- parámetros
      SELECT admpv_desc
        INTO V_DESC_PREMIO
        FROM PCLUB.admpt_premio
       WHERE admpv_id_procla = V_PEDIDO.ProdId
         AND admpv_cod_tpopr = V_PEDIDO.TipoPremio
         AND admpc_estado = 'A';

      -- Inserta en Canje Detalle
      INSERT INTO PCLUB.admpt_canje_detalle
        (admpv_id_canje,
         admpv_id_canjesec,
         admpv_id_procla,
         admpv_desc,
         admpv_nom_camp,
         admpn_puntos,
         admpn_pago,
         admpn_cantidad,
         admpv_cod_tpopr,
         admpn_cod_servc,
         admpn_mnt_recar,
           admpc_estado,
         admpv_cod_paqdat,
         ADMPN_VALSEGMENTO,
         ADMPN_PUNTOSDSCTO)
      VALUES
        (V_COD_CANJE,
         V_SEC,
         V_PEDIDO.ProdId,
         V_DESC_PREMIO,
         V_PEDIDO.Campana,
         V_PEDIDO.Puntos,
         V_PEDIDO.Pago,
         V_PEDIDO.Cantidad,
         V_PEDIDO.TipoPremio,
         V_PEDIDO.ServComercial,
         V_PEDIDO.MontoRecarga,
         'C',
         v_pedido.codpaqdat,
         V_PEDIDO.ValSegmento,
         V_PEDIDO.PuntosDscto);

      --Evalúo el Tipo de Canje que realizó

      IF K_TIPCANJE = 1 THEN
        PCLUB.PKG_CC_TRANSACCION.ADMPSI_DESC_PTOS_BONO(V_COD_CANJE,
                              V_SEC,
                              V_PEDIDO.Puntos * V_PEDIDO.Cantidad,
                              K_COD_CLIENTE,
                              K_TIPO_DOC,
                              K_NUM_DOC,
                              K_TIP_CLI,
                              K_TIPPRECANJE,
                              V_CODERROR,
                              V_DESCERROR);
      ELSE
        PCLUB.PKG_CC_TRANSACCION.admpsi_desc_puntos(V_COD_CANJE,
                         V_SEC,
                         V_PEDIDO.Puntos * V_PEDIDO.Cantidad,
                         K_COD_CLIENTE,
                         K_TIPO_DOC,
                         K_NUM_DOC,
                         K_TIP_CLI,
                         V_CODERROR,
                         V_DESCERROR);
      END IF;

      IF V_CODERROR > 0 THEN
        RAISE NO_DESC_PUNTOS;
      END IF;
      --
      V_SEC := V_SEC + 1;

    END LOOP;

    /* Insertar entrada en la tabla KARDEX */
  IF K_TIP_CLI='8' THEN
       SELECT NVL(admpv_cod_cpto, '-1')
        INTO V_COD_CPTO
        FROM PCLUB.admpt_concepto
       WHERE admpv_desc = 'CANJE TFI';
    ELSE
      SELECT NVL(admpv_cod_cpto, '-1')
        INTO V_COD_CPTO
        FROM PCLUB.admpt_concepto
       WHERE admpv_desc = 'CANJE';
    END IF;

    SELECT NVL(PCLUB.admpt_kardex_sq.NEXTVAL, '-1')
      INTO V_ID_KARDEX
      FROM dual;

    INSERT INTO PCLUB.admpt_kardex
      (admpn_id_kardex,
       admpn_cod_cli_ib,
       admpv_cod_cli,
       admpv_cod_cpto,
       admpd_fec_trans,
       admpn_puntos,
       admpv_nom_arch,
       admpc_tpo_oper,
       admpc_tpo_punto,
       admpn_sld_punto,
       admpc_estado)
    VALUES
      (V_ID_KARDEX,
       '',
       K_COD_CLIENTE,
       V_COD_CPTO,
       TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
       V_PUNTOS_REQUERIDOS * (-1),
       '',
       'S',
       'C', ---
       0,
       'C'); -- Consultar sobre el tipo de operacion

    /* Actualiza el canje */
    UPDATE PCLUB.admpt_canje
       SET admpn_id_kardex = V_ID_KARDEX
     WHERE admpv_id_canje = V_COD_CANJE;

    COMMIT;

    -------- Validar si se genera el Registro en ADMPT_MOVENCUESTA --------
    BEGIN
      SELECT ADMPC_ENCUESTA INTO V_ENCUESTA
      FROM  PCLUB.ADMPT_TIPO_CLIENTE
      WHERE ADMPV_COD_TPOCL = K_TIP_CLI;

      IF V_ENCUESTA = '1' THEN
        PCLUB.PKG_CC_ENCUESTA.ADMPSS_REGMOVENCUESTA(k_num_linea,k_cod_asesor,V_COD_CANJE,K_TIPO_DOC,K_NUM_DOC,K_COD_CLIENTE,V_CODERROR,V_DESCERROR);
        COMMIT;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
    END;

    /*  Obtener Saldo  */
    PCLUB.PKG_CC_TRANSACCION.ADMPSI_ES_CLIENTE(K_COD_CLIENTE,
                      K_TIPO_DOC,
                      K_NUM_DOC,
                      K_TIP_CLI,
                      V_SALDO,
                      K_CODERROR);

    K_SALDO := V_SALDO;

    /*  Lista de Canje  */
    OPEN K_LISTA_CANJE FOR
      SELECT cdet.admpv_id_procla   AS ProdId,
             pr.admpv_desc          AS ProdDes,
             cdet.admpv_nom_camp    AS Campana,
             cdet.admpn_puntos      AS Puntos,
             cdet.admpn_pago        AS Pago,
             cdet.admpn_cantidad    AS Cantidad,
             cdet.admpv_id_canje    AS IDCanje,
             cdet.admpv_id_canjesec AS IDCanjeSec,
             cdet.admpv_cod_tpopr   AS TipoPremio,
             cdet.admpn_cod_servc   AS ServComercial,
             cdet.admpn_mnt_recar   AS MontoRecarga,
             cdet.admpn_valsegmento AS ValSegmento,
             cdet.admpn_puntosdscto AS PuntosDscto
        FROM PCLUB.admpt_canje_detalle cdet, PCLUB.admpt_premio pr
       WHERE cdet.admpv_id_procla = pr.admpv_id_procla
         AND cdet.admpv_id_canje = V_COD_CANJE;

  EXCEPTION
    WHEN NO_PARAMETROS THEN
      K_CODERROR := 41;
      K_MSJERROR := 'Ingresó datos incorrectos o datos insuficientes para realizar la consulta';

        OPEN K_LISTA_CANJE FOR
        SELECT
        '' ProdId,
        '' ProdDes,
        '' Campana,
        '' Puntos,
        '' Pago,
        '' Cantidad,
        '' IDCanje,
        '' IDCanjeSec,
        '' TipoPremio,
        '' ServComercial,
        '' MontoRecarga,
        '' ValSegmento,
        '' PuntosDscto
        FROM DUAL;

    WHEN NO_CLIENTE THEN
      K_CODERROR := K_CODERROR;
      K_MSJERROR := 'El cliente no existe en el sistema CLAROCLUB';

        OPEN K_LISTA_CANJE FOR
        SELECT
        '' ProdId,
        '' ProdDes,
        '' Campana,
        '' Puntos,
        '' Pago,
        '' Cantidad,
        '' IDCanje,
        '' IDCanjeSec,
        '' TipoPremio,
        '' ServComercial,
        '' MontoRecarga,
        '' ValSegmento,
        '' PuntosDscto
        FROM DUAL;

    WHEN NO_DATOS_VALIDOS THEN
      K_CODERROR := K_CODERROR;
      K_MSJERROR := 'Incongruencia con los datos del Cliente';

        OPEN K_LISTA_CANJE FOR
        SELECT
        '' ProdId,
        '' ProdDes,
        '' Campana,
        '' Puntos,
        '' Pago,
        '' Cantidad,
        '' IDCanje,
        '' IDCanjeSec,
        '' TipoPremio,
        '' ServComercial,
        '' MontoRecarga,
        '' ValSegmento,
        '' PuntosDscto
        FROM DUAL;
    WHEN NO_SALDO THEN
      K_CODERROR := 52;
      K_MSJERROR := 'No Hay saldo disponible para realizar el canje';

        OPEN K_LISTA_CANJE FOR
        SELECT
        '' ProdId,
        '' ProdDes,
        '' Campana,
        '' Puntos,
        '' Pago,
        '' Cantidad,
        '' IDCanje,
        '' IDCanjeSec,
        '' TipoPremio,
        '' ServComercial,
        '' MontoRecarga,
        '' ValSegmento,
        '' PuntosDscto
        FROM DUAL;
    WHEN NO_SALDO_CANJE THEN
      K_CODERROR := 52;
      K_MSJERROR := 'No Hay saldo disponible para realizar el canje';

        OPEN K_LISTA_CANJE FOR
        SELECT
        '' ProdId,
        '' ProdDes,
        '' Campana,
        '' Puntos,
        '' Pago,
        '' Cantidad,
        '' IDCanje,
        '' IDCanjeSec,
        '' TipoPremio,
        '' ServComercial,
        '' MontoRecarga,
        '' ValSegmento,
        '' PuntosDscto
        FROM DUAL;

        PCLUB.PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,K_CODERROR_EX,K_MSJERROR_EX);

      IF K_CODERROR <> 0 THEN
        K_MSJERROR := K_MSJERROR || K_MSJERROR_EX;
      END IF;
    WHEN NO_LISTA_PEDIDO THEN
      K_CODERROR := '51';
      K_MSJERROR := 'La lista de pedido está vacía';

        OPEN K_LISTA_CANJE FOR
        SELECT
        '' ProdId,
        '' ProdDes,
        '' Campana,
        '' Puntos,
        '' Pago,
        '' Cantidad,
        '' IDCanje,
        '' IDCanjeSec,
        '' TipoPremio,
        '' ServComercial,
        '' MontoRecarga,
        '' ValSegmento,
        '' PuntosDscto
        FROM DUAL;
     ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,K_CODERROR_EX, K_MSJERROR_EX);
      IF K_CODERROR_EX <> 0 THEN
        K_MSJERROR := K_MSJERROR || K_MSJERROR_EX;
      END IF;
    when NO_COD_APLICACION then
      K_CODERROR := 41;
      K_MSJERROR := 'Ingresó datos incorrectos o datos insuficientes para realizar la consulta';

        OPEN K_LISTA_CANJE FOR
        SELECT
        '' ProdId,
        '' ProdDes,
        '' Campana,
        '' Puntos,
        '' Pago,
        '' Cantidad,
        '' IDCanje,
        '' IDCanjeSec,
        '' TipoPremio,
        '' ServComercial,
        '' MontoRecarga,
        '' ValSegmento,
        '' PuntosDscto
        FROM DUAL;
    when NO_DESC_PUNTOS then
      K_CODERROR := V_CODERROR;
      K_MSJERROR := V_DESCERROR;

      OPEN K_LISTA_CANJE FOR
      SELECT
        '' ProdId,
        '' ProdDes,
        '' Campana,
        '' Puntos,
        '' Pago,
        '' Cantidad,
        '' IDCanje,
        '' IDCanjeSec,
        '' TipoPremio,
        '' ServComercial,
        '' MontoRecarga,
        '' ValSegmento,
        '' PuntosDscto
        FROM DUAL;
      ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,K_CODERROR_EX,K_MSJERROR_EX);
      IF K_CODERROR_EX <> 0 THEN
        K_MSJERROR := K_MSJERROR || K_MSJERROR_EX;
      END IF;
when NO_SLD_KDX_ALINEADO then
      K_CODERROR := 61;
      K_MSJERROR := 'Ocurrió un error (Puntos CC)';
      --Puntos en el saldo y kardex no se encuentra alineados
      OPEN K_LISTA_CANJE FOR
     SELECT
        '' ProdId,
        '' ProdDes,
        '' Campana,
        '' Puntos,
        '' Pago,
        '' Cantidad,
        '' IDCanje,
        '' IDCanjeSec,
        '' TipoPremio,
        '' ServComercial,
        '' MontoRecarga,
        '' ValSegmento,
        '' PuntosDscto
        FROM DUAL;
     ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,K_CODERROR_EX,K_MSJERROR_EX);

      IF K_CODERROR_EX <> 0 THEN
        K_MSJERROR := K_MSJERROR || K_MSJERROR_EX;
      END IF;

    WHEN EX_BLOQUEO THEN  --NO_VALBLOQUEO THEN
      K_CODERROR := K_CODERROR;
      K_MSJERROR := 'Error en el bloqueo.';   --'Error en validación de bloqueo.';

        OPEN K_LISTA_CANJE FOR
        SELECT
        '' ProdId,
        '' ProdDes,
        '' Campana,
        '' Puntos,
        '' Pago,
        '' Cantidad,
        '' IDCanje,
        '' IDCanjeSec,
        '' TipoPremio,
        '' ServComercial,
        '' MontoRecarga,
        '' ValSegmento,
        '' PuntosDscto
        FROM DUAL;

    WHEN NO_LIBERADO THEN
      K_CODERROR := 37;--K_CODERROR;
      K_MSJERROR := 'Existe un canje en proceso.';

        OPEN K_LISTA_CANJE FOR
        SELECT
        '' ProdId,
        '' ProdDes,
        '' Campana,
        '' Puntos,
        '' Pago,
        '' Cantidad,
        '' IDCanje,
        '' IDCanjeSec,
        '' TipoPremio,
        '' ServComercial,
        '' MontoRecarga,
        '' ValSegmento,
        '' PuntosDscto
        FROM DUAL;
WHEN OTHERS THEN
      K_CODERROR := SQLCODE;
      K_MSJERROR := SUBSTR(SQLERRM, 1, 400);
      ROLLBACK TO POINT_CANJE;

       OPEN K_LISTA_CANJE FOR
        SELECT
        '' ProdId,
        '' ProdDes,
        '' Campana,
        '' Puntos,
        '' Pago,
        '' Cantidad,
        '' IDCanje,
        '' IDCanjeSec,
        '' TipoPremio,
        '' ServComercial,
        '' MontoRecarga,
        '' ValSegmento,
        '' PuntosDscto
        FROM DUAL;
      ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,K_CODERROR_EX,K_MSJERROR_EX);
      IF K_CODERROR_EX <> 0 THEN
        K_MSJERROR := K_MSJERROR || K_MSJERROR_EX;
      END IF;
  END admpss_canjprod;

  PROCEDURE ADMPSS_COPRCANJ(K_CODCLI     IN VARCHAR2,
                            K_TIPODOC    IN VARCHAR2,
                            K_NUMDOC     IN VARCHAR2,
                            K_PUNTOVNTA  IN VARCHAR2,
                            K_TIPOCLI    IN VARCHAR2,
                            K_FECINICIAL IN DATE,
                            K_FECFINAL   IN DATE,
                            K_CODERROR   OUT NUMBER,
                            K_MSJERROR   OUT VARCHAR2,
                            K_SLDPUNTOS  OUT NUMBER,
                            CursorCanje  OUT SYS_REFCURSOR) IS

    --****************************************************************
    -- Nombre SP           :  ADMPSS_COPRCANJ
    -- Propósito           :  Recuperar una lista de los productos canjeados
    -- Input               :  K_CODCLI - Código del Cliente, K_TIPODOC - Tipo del documento,K_NUMDOC - Número del documento,
    --                     :  K_PUNTOVNTA - Punto de venta, K_TIPOCLI - Tipo de cliente, K_FECINICIAL - Fecha inicial, K_FECFINAL - Fecha final
    --
    -- Output              :  K_CODERROR - Código del error, K_DESCERROR - Mensaje de error, K_SLDPUNTOS - Saldo de puntos, CURSORCANJE - Cursor con la lista de productos canjeados
    --
    -- Creado por          :  Sofia Khlebnikov
    -- Fec Creación        :  08/09/2010
    -- Fec Actualización   :  22/12/2010 - Stiven Saavedra
    --****************************************************************

    ERRORDATOS EXCEPTION;
    ERRORPARAM EXCEPTION;
    ERRORCANJE EXCEPTION;
    ERRORTIPOCLI EXCEPTION;
    ERRORCLI EXCEPTION;
    NO_DATA_CURSOR EXCEPTION;
    ERRORFECHA EXCEPTION;

    V_FECHAINI   DATE := K_FECINICIAL;
    V_FECHAFIN   DATE := K_FECFINAL;
    V_SALDOTOTAL NUMBER := 0;
    V_SALDOAUXCC NUMBER := 0;
    V_SALDOIB    NUMBER;
    V_TIPODOC    VARCHAR2(20);
    V_NUMDOC     VARCHAR2(20);

    C_CODCLI  VARCHAR2(40);
    C_TIPODOC VARCHAR2(20);
    C_NUMDOC  VARCHAR2(20);

    CURSOR CLIENTECC1(tipo_doc VARCHAR2, num_doc VARCHAR2, tipo_cli VARCHAR2) IS
      SELECT ADMPV_COD_CLI, ADMPV_TIPO_DOC, ADMPV_NUM_DOC

        FROM PCLUB.ADMPT_CLIENTE c

       WHERE ADMPV_TIPO_DOC = tipo_doc
         AND ADMPV_NUM_DOC = num_doc
         AND ADMPV_COD_TPOCL IN ('1', '2')
         AND ADMPC_ESTADO = 'A';

    CURSOR CLIENTECC2(tipo_doc VARCHAR2, num_doc VARCHAR2, tipo_cli VARCHAR2) IS
      SELECT ADMPV_COD_CLI, ADMPV_TIPO_DOC, ADMPV_NUM_DOC

        FROM PCLUB.ADMPT_CLIENTE c

       WHERE ADMPV_TIPO_DOC = tipo_doc
         AND ADMPV_NUM_DOC = num_doc
         AND ADMPV_COD_TPOCL = tipo_cli
         AND ADMPC_ESTADO = 'A';

  BEGIN

    IF (K_TIPOCLI IS NULL) THEN
      RAISE ERRORTIPOCLI;
    END IF;

    IF (K_FECINICIAL IS NULL OR K_FECFINAL IS NULL OR
       ABS(MONTHS_BETWEEN(K_FECFINAL, K_FECINICIAL)) > 4) THEN
      RAISE ERRORFECHA;
    END IF;

    IF (K_CODCLI IS NULL AND K_TIPODOC IS NULL AND K_NUMDOC IS NULL AND
       K_TIPOCLI IS NOT NULL) OR
       (K_CODCLI IS NULL AND K_TIPODOC IS NULL AND K_NUMDOC IS NOT NULL AND
       K_TIPOCLI IS NOT NULL) OR
       (K_CODCLI IS NULL AND K_TIPODOC IS NOT NULL AND K_NUMDOC IS NULL AND
       K_TIPOCLI IS NOT NULL) THEN
      RAISE ERRORPARAM;
    END IF;

    IF (K_CODCLI is not null and K_TIPODOC is null and K_NUMDOC is null and
       K_TIPOCLI is not null) THEN
      BEGIN
        -- 22122010 - Se modifica para que si es Post o Control no distinga el tipo de cliente
        IF (K_TIPOCLI = '1' or K_TIPOCLI = '2') THEN
          BEGIN
            SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
              INTO V_TIPODOC, V_NUMDOC
              FROM PCLUB.ADMPT_CLIENTE
             WHERE ADMPV_COD_CLI = K_CODCLI
               AND ADMPV_COD_TPOCL IN ('1', '2');
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              RAISE ERRORCLI;
          END;
        ELSE
          BEGIN
            SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
              INTO V_TIPODOC, V_NUMDOC
              FROM PCLUB.ADMPT_CLIENTE
             WHERE ADMPV_COD_CLI = K_CODCLI
               AND ADMPV_COD_TPOCL = K_TIPOCLI;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              RAISE ERRORCLI;
          END;
        END IF;
      END;

      IF (K_TIPOCLI = '1' OR K_TIPOCLI = '2') THEN
        OPEN CLIENTECC1(V_TIPODOC, V_NUMDOC, K_TIPOCLI);
      ELSE
        OPEN CLIENTECC2(V_TIPODOC, V_NUMDOC, K_TIPOCLI);
      END IF;
    END IF;

    IF (K_TIPODOC IS NOT NULL AND K_NUMDOC IS NOT NULL AND
       K_TIPOCLI IS NOT NULL) THEN
      IF (K_TIPOCLI = '1' OR K_TIPOCLI = '2') THEN

        OPEN CLIENTECC1(K_TIPODOC, K_NUMDOC, K_TIPOCLI);
      ELSE
        OPEN CLIENTECC2(K_TIPODOC, K_NUMDOC, K_TIPOCLI);

      END IF;
    END IF;

    IF (K_TIPOCLI = '1' OR K_TIPOCLI = '2') THEN

      BEGIN

        FETCH CLIENTECC1
          INTO C_CODCLI, C_TIPODOC, C_NUMDOC;

        IF (CLIENTECC1%rowcount = 0) THEN
          RAISE NO_DATA_CURSOR;
        END IF;

        WHILE CLIENTECC1 %FOUND LOOP
          BEGIN
            SELECT NVL(ADMPN_SALDO_CC, 0)
              INTO V_SALDOAUXCC
              FROM PCLUB.ADMPT_SALDOS_CLIENTE
             WHERE ADMPV_COD_CLI = C_CODCLI
               AND ADMPC_ESTPTO_CC = 'A';
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              V_SALDOAUXCC := 0;
          END;

          BEGIN
            SELECT NVL(ADMPN_SALDO_IB, 0)
              INTO V_SALDOIB
              FROM PCLUB.ADMPT_SALDOS_CLIENTE
             WHERE ADMPV_COD_CLI = C_CODCLI
               AND ADMPC_ESTPTO_IB = 'A';
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              V_SALDOIB := 0;
          END;

          BEGIN

            INSERT INTO PCLUB.ADMPT_PRCANJTMP
              SELECT c.ADMPV_COD_CLI,
                     c.ADMPV_PTO_VENTA,
                     c.ADMPD_FEC_CANJE,
                     c.ADMPV_HRA_CANJE,
                     cd.ADMPV_ID_PROCLA,
                     cd.ADMPN_PUNTOS,
                     NULL,
                     cd.ADMPN_PAGO,
                     trim(cd.ADMPN_CANTIDAD),
                     (CASE c.ADMPC_TPO_OPER
                     WHEN 'C' THEN
                           cd.ADMPV_ID_CANJE
                       ELSE
                        c.ADMPV_DEV_IDCANJE
                     END),
                     PCLUB.admpt_prcjtm_sq.NEXTVAL,
                     cd.ADMPV_ID_CANJESEC,
                     trim((CASE c.ADMPC_TPO_OPER
                            WHEN 'C' THEN
                             'C'
                            ELSE
                             cd.ADMPC_ESTADO
                          END)),
                     DECODE(cd.ADMPC_ESTADO, 'D', 0, 'C', cd.ADMPN_CANTIDAD),
                     tp.ADMPV_DESC,
                     trim(NVL(cd.ADMPN_COD_SERVC, 0)),
                     trim(NVL(cd.ADMPN_MNT_RECAR, 0)),
                     c.ADMPV_ID_LOYALTY,
                     c.ADMPV_ID_GPRS,
                     cd.admpv_cod_paqdat,
                     cd.admpv_codtxpaqdat,
                     tp.admpv_cod_tpopr
                FROM PCLUB.ADMPT_CANJE         c,
                     PCLUB.ADMPT_CANJE_DETALLE cd,
                     PCLUB.ADMPT_TIPO_PREMIO   tp
               WHERE c.ADMPV_COD_CLI = C_CODCLI
                 AND c.ADMPV_ID_CANJE = cd.ADMPV_ID_CANJE
                 AND cd.ADMPV_COD_TPOPR = tp.ADMPV_COD_TPOPR
                 AND c.ADMPD_FEC_CANJE BETWEEN V_FECHAINI AND V_FECHAFIN;

            COMMIT;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              NULL;
          END;

          V_SALDOTOTAL := V_SALDOTOTAL + V_SALDOAUXCC + V_SALDOIB;
          V_SALDOAUXCC := 0;
          V_SALDOIB    := 0;
          FETCH CLIENTECC1
            INTO C_CODCLI, C_TIPODOC, C_NUMDOC;

        END LOOP;

        CLOSE CLIENTECC1;

        K_SLDPUNTOS := V_SALDOTOTAL;
      END;

    ELSE

      BEGIN

        FETCH CLIENTECC2
          INTO C_CODCLI, C_TIPODOC, C_NUMDOC;

        IF (CLIENTECC2%rowcount = 0) THEN
          RAISE NO_DATA_CURSOR;
        END IF;

        WHILE CLIENTECC2 %FOUND LOOP
          BEGIN
            SELECT ADMPN_SALDO_CC
              INTO V_SALDOAUXCC
              FROM PCLUB.ADMPT_SALDOS_CLIENTE
             WHERE ADMPV_COD_CLI = C_CODCLI
               AND ADMPC_ESTPTO_CC = 'A';
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              V_SALDOAUXCC := 0;
          END;

          BEGIN
            SELECT ADMPN_SALDO_IB
              INTO V_SALDOIB
              FROM PCLUB.ADMPT_SALDOS_CLIENTE
             WHERE ADMPV_COD_CLI = C_CODCLI
               AND ADMPC_ESTPTO_IB = 'A';
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              V_SALDOIB := 0;
          END;

          BEGIN

            INSERT INTO PCLUB.ADMPT_PRCANJTMP
              SELECT c.ADMPV_COD_CLI,
                     c.ADMPV_PTO_VENTA,
                     c.ADMPD_FEC_CANJE,
                     c.ADMPV_HRA_CANJE,
                     cd.ADMPV_ID_PROCLA,
                     cd.ADMPN_PUNTOS,
                     NULL,
                     cd.ADMPN_PAGO,
                     trim(cd.ADMPN_CANTIDAD),
                     (CASE c.ADMPC_TPO_OPER
                       WHEN 'C' THEN
                        cd.ADMPV_ID_CANJE
                       ELSE
                        c.ADMPV_DEV_IDCANJE
                     END),
                     PCLUB.admpt_prcjtm_sq.NEXTVAL,
                     cd.ADMPV_ID_CANJESEC,
                     trim((CASE c.ADMPC_TPO_OPER
                            WHEN 'C' THEN
                             'C'
                            ELSE
                             cd.ADMPC_ESTADO
                          END)),
                     DECODE(cd.ADMPC_ESTADO, 'D', 0, 'C', cd.ADMPN_CANTIDAD),
                     tp.ADMPV_DESC,
                     trim(NVL(cd.ADMPN_COD_SERVC, NULL)),
                     trim(NVL(cd.ADMPN_MNT_RECAR, 0)),
                     c.ADMPV_ID_LOYALTY,
                     c.ADMPV_ID_GPRS,
                    cd.admpv_cod_paqdat,
                    cd.admpv_codtxpaqdat,
                    tp.admpv_cod_tpopr
                FROM PCLUB.ADMPT_CANJE         c,
                     PCLUB.ADMPT_CANJE_DETALLE cd,
                     PCLUB.ADMPT_TIPO_PREMIO   tp
               WHERE c.ADMPV_COD_CLI = C_CODCLI
                 AND c.ADMPV_ID_CANJE = cd.ADMPV_ID_CANJE
                 AND cd.ADMPV_COD_TPOPR = tp.ADMPV_COD_TPOPR
                 AND c.ADMPD_FEC_CANJE BETWEEN V_FECHAINI AND V_FECHAFIN;

            COMMIT;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              NULL;
          END;

          V_SALDOTOTAL := V_SALDOTOTAL + V_SALDOAUXCC + V_SALDOIB;
          V_SALDOAUXCC := 0;
          V_SALDOIB    := 0;
          FETCH CLIENTECC2
            INTO C_CODCLI, C_TIPODOC, C_NUMDOC;

        END LOOP;

        CLOSE CLIENTECC2;

        K_SLDPUNTOS := V_SALDOTOTAL;
      END;

    END IF;

    BEGIN
      OPEN CURSORCANJE FOR
        SELECT ADMPV_COD_CLI,
               ADMPV_PTO_VENTA,
               ADMPD_FEC_CANJE,
               ADMPV_HRA_CANJE,
               ADMPV_ID_PROCLA,
               ADMPN_PUNTOS,
               NULL,
               ADMPN_PAGO,
               trim(ADMPN_CANTIDAD),
               ADMPV_ID_CANJE,
               ADMPV_ID_CANJESEC,
               trim(ADMPC_ESTADO),
               ADMPN_DISPONIBLE,
               ADMPV_DESC_PRE,
               trim(NVL(ADMPN_COD_SERVC, NULL)),
               trim(NVL(ADMPN_MNT_RECAR, 0)),
               ADMPV_ID_LOYALTY,
               ADMPV_ID_GPRS,
               ADMPV_COD_TPOPR
          FROM PCLUB.ADMPT_PRCANJTMP
         ORDER BY ADMPD_FEC_CANJE DESC,
                  TO_DATE(TO_CHAR(ADMPD_FEC_CANJE, 'dd/mm/yyyy') || ' ' ||
                          SUBSTR((CASE
                                   WHEN SUBSTR(ADMPV_HRA_CANJE, 7, 2) = 'PM' AND
                                        SUBSTR(ADMPV_HRA_CANJE, 1, 2) <> '12' THEN
                                    TO_CHAR(TO_NUMBER(SUBSTR(ADMPV_HRA_CANJE, 1, 2)) + 12) ||
                                    SUBSTR(ADMPV_HRA_CANJE, 3, 3)
                                   ELSE
                                    ADMPV_HRA_CANJE
                                 END),
                                 1,
                                 5),
                          'dd/mm/yyyy hh24:mi') DESC,
                  ADMPV_ID_CANJE DESC,
                  ADMPV_ID_CANJESEC ASC;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE ERRORCANJE;

    END;

    DELETE PCLUB.ADMPT_PRCANJTMP;
    COMMIT;

    K_CODERROR := 0;
    K_MSJERROR := '';

  EXCEPTION

    WHEN ERRORPARAM THEN
      K_CODERROR := 49;
      K_MSJERROR := 'El código del cliente o el tipo de documento y el número de documento son obligatorios';

  OPEN cursorcanje FOR
  SELECT   '' admpv_cod_cli
    ,'' admpv_pto_venta
    ,'' admpd_fec_canje
    ,'' admpv_hra_canje
    ,'' admpv_id_procla
    ,'' admpn_puntos
    ,NULL
    ,'' admpn_pago
    ,''
    ,'' admpv_id_canje
    ,'' admpv_id_canjesec
    ,''
    ,'' admpn_disponible
    ,'' admpv_desc_pre
    ,''
    ,''
    ,'' admpv_id_loyalty
    ,'' admpv_id_gprs
    ,'' admpv_cod_tpopr
    FROM     DUAL;
    WHEN errordatos THEN
      k_coderror := 36;
      k_msjerror := 'El cliente no existe no se puede mostrar productos canjeados ';

      OPEN cursorcanje FOR
        SELECT   '' admpv_cod_cli
                ,'' admpv_pto_venta
                ,'' admpd_fec_canje
                ,'' admpv_hra_canje
                ,'' admpv_id_procla
                ,'' admpn_puntos
                ,NULL
                ,'' admpn_pago
                ,''
                ,'' admpv_id_canje
                ,'' admpv_id_canjesec
                ,''
                ,'' admpn_disponible
                ,'' admpv_desc_pre
                ,''
                ,''
                ,'' admpv_id_loyalty
                ,'' admpv_id_gprs
                ,'' admpv_cod_tpopr
        FROM     DUAL;
    WHEN errorcanje THEN
      k_coderror := 47;
      k_msjerror := 'El cliente no tiene registros de productos canjeados';

      OPEN cursorcanje FOR
        SELECT   '' admpv_cod_cli
                ,'' admpv_pto_venta
                ,'' admpd_fec_canje
                ,'' admpv_hra_canje
                ,'' admpv_id_procla
                ,'' admpn_puntos
                ,NULL
                ,'' admpn_pago
                ,''
                ,'' admpv_id_canje
                ,'' admpv_id_canjesec
                ,''
                ,'' admpn_disponible
                ,'' admpv_desc_pre
                ,''
                ,''
                ,'' admpv_id_loyalty
                ,'' admpv_id_gprs
                ,'' admpv_cod_tpopr
        FROM     DUAL;
    WHEN errortipocli THEN
      k_coderror := 53;
      k_msjerror := 'El tipo de cliente es obligatorio no se puede mostrar productos canjeados';

      OPEN cursorcanje FOR
        SELECT   '' admpv_cod_cli
                ,'' admpv_pto_venta
                ,'' admpd_fec_canje
                ,'' admpv_hra_canje
                ,'' admpv_id_procla
                ,'' admpn_puntos
                ,NULL
                ,'' admpn_pago
                ,''
                ,'' admpv_id_canje
                ,'' admpv_id_canjesec
                ,''
                ,'' admpn_disponible
                ,'' admpv_desc_pre
                ,''
                ,''
                ,'' admpv_id_loyalty
                ,'' admpv_id_gprs
                ,'' admpv_cod_tpopr
        FROM     DUAL;
    WHEN errorcli THEN
      k_coderror := 45;
      k_msjerror := 'Error en consulta de productos canjeados :No existe el documento para el cliente con codigo: ' || k_codcli;

      OPEN cursorcanje FOR
        SELECT   '' admpv_cod_cli
                ,'' admpv_pto_venta
                ,'' admpd_fec_canje
                ,'' admpv_hra_canje
                ,'' admpv_id_procla
                ,'' admpn_puntos
                ,NULL
                ,'' admpn_pago
                ,''
                ,'' admpv_id_canje
                ,'' admpv_id_canjesec
                ,''
                ,'' admpn_disponible
                ,'' admpv_desc_pre
                ,''
                ,''
                ,'' admpv_id_loyalty
                ,'' admpv_id_gprs
                ,'' admpv_cod_tpopr
        FROM     DUAL;
    WHEN no_data_cursor THEN
      k_coderror := 40;
      k_msjerror := 'No hay registros para el cliente con código: ' || k_codcli;

      OPEN cursorcanje FOR
        SELECT   '' admpv_cod_cli
                ,'' admpv_pto_venta
                ,'' admpd_fec_canje
                ,'' admpv_hra_canje
                ,'' admpv_id_procla
                ,'' admpn_puntos
                ,NULL
                ,'' admpn_pago
                ,''
                ,'' admpv_id_canje
                ,'' admpv_id_canjesec
                ,''
                ,'' admpn_disponible
                ,'' admpv_desc_pre
                ,''
                ,''
                ,'' admpv_id_loyalty
                ,'' admpv_id_gprs
                ,'' admpv_cod_tpopr
        FROM     DUAL;
    WHEN errorfecha THEN
      k_coderror := 41;
      k_msjerror := 'La fecha inicio y fin de ADMPSS_COPRCANJ son obligatorias/ El periodo de consulta no debe ser mayor de 4 meses';

      OPEN cursorcanje FOR
        SELECT   '' admpv_cod_cli
                ,'' admpv_pto_venta
                ,'' admpd_fec_canje
                ,'' admpv_hra_canje
                ,'' admpv_id_procla
                ,'' admpn_puntos
                ,NULL
                ,'' admpn_pago
                ,''
                ,'' admpv_id_canje
                ,'' admpv_id_canjesec
                ,''
                ,'' admpn_disponible
                ,'' admpv_desc_pre
                ,''
                ,''
                ,'' admpv_id_loyalty
                ,'' admpv_id_gprs
                ,'' admpv_cod_tpopr
        FROM     DUAL;
    WHEN OTHERS THEN
      K_CODERROR := SQLCODE;
      K_MSJERROR := SUBSTR(SQLERRM, 1, 400);

      OPEN cursorcanje FOR
        SELECT   '' admpv_cod_cli
                ,'' admpv_pto_venta
                ,'' admpd_fec_canje
                ,'' admpv_hra_canje
                ,'' admpv_id_procla
                ,'' admpn_puntos
                ,NULL
                ,'' admpn_pago
                ,''
                ,'' admpv_id_canje
                ,'' admpv_id_canjesec
                ,''
                ,'' admpn_disponible
                ,'' admpv_desc_pre
                ,''
                ,''
                ,'' admpv_id_loyalty
                ,'' admpv_id_gprs
                ,'' admpv_cod_tpopr
        FROM     DUAL;
  END;

  PROCEDURE ADMPSS_DEVPUNTS(K_ID_SOLICITUD IN VARCHAR2,
                            K_PUNTOVENTA   IN VARCHAR2,
                            K_LISTA_DEV    IN LISTA_DEVOLUCION,
                            K_PUNTOS       IN NUMBER,
                            K_CODERROR     OUT NUMBER,
                            K_MSJERROR     OUT VARCHAR2,
                            K_SALDO        OUT NUMBER) IS
    --****************************************************************
    -- Nombre SP           :  ADMPSS_DEVPUNTS
    -- Propósito           :  Registrar una devolución de un canje realizado
    -- Input               :  K_ID_SOLICITUD - Codigo del Producto
    --                        K_PUNTOVENTA
    --
    -- Output              :  K_LISTA_DEV    --> Lista de Productos que se registraron en la devolucion
    --                        K_CODERROR     --> Código de Error (si se presento)
    --                        K_MSJERROR     --> Mensaje de Error
    --                        K_SALDO        --> Saldo luego de registrar la devolucion
    -- Creado por          :  Rossana Janampa
    -- Fec Creación        :  27/09/2010
    -- Fec Actualización   :
    --****************************************************************

    /*
    TYPE idcanjelist IS TABLE OF PCLUB.admpt_canjedt_kardex.admpv_id_canje%TYPE;
    TYPE idcanjeseclist IS TABLE OF PCLUB.admpt_canjedt_kardex.admpv_id_canjesec%TYPE;
    TYPE cantidadlist IS TABLE OF PCLUB.admpt_canje_detalle.admpn_cantidad%TYPE;

    LDV_IDCANJE         idcanjelist;
    LDV_IDCANJESEC      idcanjeseclist;
    LDV_CANTIDAD        cantidadlist;
    */

    V_DEVOLUCION DEVOLUCION;

    C_CANJE_KARDEX_IDKARDEX NUMBER;
    C_CANJE_KARDEX_PUNTOS   NUMBER;

    CURSOR CANJE_KARDEX(idcanje NUMBER, idcanjesec NUMBER) IS
      SELECT admpn_id_kardex, admpn_puntos
        FROM PCLUB.admpt_canjedt_kardex
       WHERE admpv_id_canje = idcanje
         AND admpv_id_canjesec = idcanjesec;

    V_COD_CLIIB    PCLUB.admpt_clienteib.admpn_cod_cli_ib%TYPE;
    V_COD_CLI      PCLUB.admpt_cliente.admpv_cod_cli%TYPE;
    V_TIP_PTO      PCLUB.admpt_kardex.admpc_tpo_punto%TYPE;
    V_COD_CPTO     PCLUB.admpt_concepto.admpv_cod_cpto%TYPE;
    V_TPO_CLI      PCLUB.admpt_cliente.admpv_cod_tpocl%TYPE;
    V_TOTALPUNTOS  NUMBER := 0;
    V_ID_KARDEX    NUMBER;
    V_REGDEVOLENC  NUMBER := 0;
    V_CODERROR     NUMBER;
    V_CANJ_DET_EST CHAR(1);
    V_ID_CANJE     NUMBER;
    V_CODTPREMIO   VARCHAR2(4);
    V_TIPO_CLI     VARCHAR2(4);

    V_CANJ_COD_CLI PCLUB.admpt_cliente.admpv_cod_cli%TYPE;
    V_CANJ_NUM_DOC PCLUB.admpt_cliente.admpv_num_doc%TYPE;
    V_CANJ_TIP_CLI PCLUB.admpt_cliente.admpv_cod_tpocl%TYPE;

    V_ID_PROCLA    PCLUB.admpt_canje_detalle.admpv_id_procla%TYPE;
    V_PRO_DESC     PCLUB.admpt_canje_detalle.admpv_desc%TYPE;
    V_NOM_CAMP     PCLUB.admpt_canje_detalle.admpv_nom_camp%TYPE;
    V_PUNTOS       PCLUB.admpt_canje_detalle.admpn_puntos%TYPE;
    V_PAGO         PCLUB.admpt_canje_detalle.admpn_pago%TYPE;
    V_CANTIDAD     PCLUB.admpt_canje_detalle.admpn_cantidad%TYPE;
    V_COD_TIP_PR   PCLUB.admpt_canje_detalle.admpv_cod_tpopr%TYPE;
    V_COD_SERV     PCLUB.admpt_canje_detalle.admpn_cod_servc%TYPE;
    V_MNT_RECAR    PCLUB.admpt_canje_detalle.admpn_mnt_recar%TYPE;
    v_cod_paqdat   PCLUB.admpt_canje_detalle.admpv_cod_paqdat%TYPE;
    v_codtxpaqdat  PCLUB.admpt_canje_detalle.admpv_codtxpaqdat%TYPE;

    V_AUX_ID_CANJE NUMBER;
    V_FLAG_SALDO   NUMBER;

    NO_LISTA_DEV EXCEPTION;
    NO_DEVOLUCION EXCEPTION;

    V_CANJ_TIPCANJE  NUMBER;
    V_CANJ_TIPPRECJE NUMBER;
    V_TPO_PREMIO     NUMBER;
    V_VENTAID     VARCHAR2(40);
    V_TPO_PROC    VARCHAR2(2);
  BEGIN

    --FETCH K_LISTA_DEV BULK COLLECT INTO  LDV_IDCANJE, LDV_IDCANJESEC, LDV_CANTIDAD;

    IF K_LISTA_DEV.COUNT = 0 THEN
      RAISE NO_LISTA_DEV;
    END IF;

    --close K_LISTA_DEV;

    SAVEPOINT DEV_PUNTOS;

    -- Parámetros

    V_AUX_ID_CANJE := 0;
    V_FLAG_SALDO   := 0;

    FOR i IN K_LISTA_DEV.FIRST .. K_LISTA_DEV.LAST LOOP
      V_DEVOLUCION := K_LISTA_DEV(i);

      SELECT C.ADMPV_VENTAID, C.ADMPV_TPO_PROC
             INTO  V_VENTAID, V_TPO_PROC
      FROM  PCLUB.ADMPT_CANJE C
      WHERE C.ADMPV_ID_CANJE = V_DEVOLUCION.ID_CANJE;

      IF V_AUX_ID_CANJE != V_DEVOLUCION.ID_CANJE THEN

        IF V_FLAG_SALDO != 0 THEN
          -- se elimina la cabecera del canje si no se devolvio CERO puntos
          IF V_TOTALPUNTOS = 0 THEN
            DELETE FROM PCLUB.admpt_canje
             WHERE admpv_id_canje = V_ID_CANJE;
            --COMMIT;
            RAISE NO_DEVOLUCION;
          ELSE
            --Parámetros
          --Validamos el tipo de Cliente

          select admpv_cod_cli,NVL(admpv_cod_tpocl, '') INTO V_COD_CLI, V_TIPO_CLI
          from PCLUB.ADMPT_CANJE
          WHERE  ADMPV_ID_CANJE = V_DEVOLUCION.ID_CANJE;

          IF V_VENTAID IS NULL THEN
            IF V_TIPO_CLI = '8' THEN
              SELECT NVL(admpv_cod_cpto,'-1')
                     INTO V_COD_CPTO
              FROM PCLUB.admpt_concepto
              WHERE admpv_desc = 'DEVOLUCION CANJE TFI'
                    AND admpc_estado = 'A';
              /*SELECT NVL(PCLUB.admpt_kardex_sq.NEXTVAL, '-1')
                INTO V_ID_KARDEX
                FROM dual;*/
            ELSE
              SELECT admpv_cod_cpto
                   INTO V_COD_CPTO
              FROM PCLUB.admpt_concepto
              WHERE admpv_desc = 'DEVOLUCION DE CANJE'
                AND admpc_estado = 'A';
              /*SELECT NVL(PCLUB.admpt_kardex_sq.NEXTVAL, '-1')
                  INTO V_ID_KARDEX
                FROM dual;*/
            END IF;
          ELSE
                  SELECT admpv_cod_cpto
                      INTO V_COD_CPTO
                  FROM  PCLUB.admpt_concepto
                  WHERE admpv_desc = 'DEVOLUCION CANJE VENTA'
                        AND admpc_estado = 'A';
          END IF;

          SELECT NVL( admpt_kardex_sq.NEXTVAL, '-1')
                 INTO V_ID_KARDEX
          FROM dual;

          -- Inserta registro en Kardex por la suma de los puntos devueltos
          INSERT INTO PCLUB.admpt_kardex
              (admpn_id_kardex,
               admpn_cod_cli_ib,
               admpv_cod_cli,
               admpv_cod_cpto,
               admpd_fec_trans,
               admpn_puntos,
               admpv_nom_arch,
               admpc_tpo_oper,
               admpc_tpo_punto,
               admpn_sld_punto,
               admpc_estado)
          VALUES
              (V_ID_KARDEX,
               '',
               V_COD_CLI,
               V_COD_CPTO,
               TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
               V_TOTALPUNTOS,
               NULL,
               'E',
               NULL,
               0,
               'C');

            UPDATE PCLUB.admpt_canje
               SET admpn_id_kardex = V_ID_KARDEX
             WHERE admpv_id_canje = V_ID_CANJE;
            --COMMIT;
          END IF;
          V_TOTALPUNTOS := 0;
        END IF;
        V_FLAG_SALDO   := 1;
        V_AUX_ID_CANJE := V_DEVOLUCION.ID_CANJE;

        --parametros
        SELECT NVL(PCLUB.admpt_canje_sq.NEXTVAL, '-1') INTO V_ID_CANJE FROM dual;
        SELECT admpv_cod_cli,
               admpv_num_doc,
               admpv_cod_tpocl,
               ADMPN_TIPCANJE,
               ADMPN_TIPPREMCJE
          INTO V_CANJ_COD_CLI,
               V_CANJ_NUM_DOC,
               V_CANJ_TIP_CLI,
               V_CANJ_TIPCANJE,
               V_CANJ_TIPPRECJE
          FROM  PCLUB.admpt_canje
         WHERE admpv_id_canje = V_DEVOLUCION.ID_CANJE;
        -- Inserta un registro en Canje por la devolución

        INSERT INTO PCLUB.admpt_canje
          (admpv_id_canje,
           admpv_cod_cli,
           admpv_id_solic,
           admpv_pto_venta,
           admpd_fec_canje,
           admpv_hra_canje,
           admpv_num_doc,
           admpv_cod_tpocl,
           admpv_cod_aseso,
           admpv_nom_aseso,
           admpc_tpo_oper,
           admpn_id_kardex,
           ADMPV_DEV_IDCANJE,
           admpv_ventaid,
           admpv_TPO_PROC)
        VALUES
          (V_ID_CANJE,
           V_CANJ_COD_CLI,
           K_ID_SOLICITUD,
           K_PUNTOVENTA,
           TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
           TO_CHAR(SYSDATE, 'HH:MI AM'),
           V_CANJ_NUM_DOC,
           V_CANJ_TIP_CLI,
           '',
           '',
           'D',
           '',
           V_DEVOLUCION.id_canje,
           V_VENTAID,
           V_TPO_PROC); -- Se agrego el ID del Canje
      END IF;

      V_DEVOLUCION := K_LISTA_DEV(i);
      -- Verifica el estado del ITEM que se desea devolver
      SELECT admpc_estado
        INTO V_CANJ_DET_EST
        FROM PCLUB.admpt_canje_detalle
       WHERE admpv_id_canje = V_DEVOLUCION.id_canje
         AND admpv_id_canjesec = V_DEVOLUCION.ID_CANJESEC;

      IF V_CANJ_DET_EST = 'C' THEN
        -- si el tipo de operacion es 'D' es por q ya fue devuelto anteriormente
        OPEN CANJE_KARDEX(V_DEVOLUCION.id_canje, V_DEVOLUCION.ID_CANJESEC);
        FETCH CANJE_KARDEX
          INTO C_CANJE_KARDEX_IDKARDEX, C_CANJE_KARDEX_PUNTOS;
        WHILE CANJE_KARDEX%FOUND LOOP

        IF V_VENTAID IS NULL THEN
        --PROY-26366 Fidelizacion y ClaroPuntos Fase2 | Validacion para devolver la Cantidad de PUNTOS
         SELECT DECODE(NVL(K_PUNTOS,0), '0', C_CANJE_KARDEX_PUNTOS, K_PUNTOS) INTO C_CANJE_KARDEX_PUNTOS FROM DUAL;
        END IF;

          -- devuelve los puntos al kardex
          UPDATE PCLUB.admpt_kardex
             SET admpc_estado    = 'A',
                 admpn_sld_punto = C_CANJE_KARDEX_PUNTOS +
                                   (SELECT NVL(admpn_sld_punto, 0)
                                      FROM PCLUB.admpt_kardex
                                     WHERE admpn_id_kardex =
                                           C_CANJE_KARDEX_IDKARDEX)
           WHERE admpn_id_kardex = C_CANJE_KARDEX_IDKARDEX;

          -- devuelve los puntos al saldo_cliente segun el tipo de punto
          SELECT NVL(admpn_cod_cli_ib, 0),
                 NVL(admpv_cod_cli, 0),
                 NVL(admpc_tpo_punto, 0),
                 ADMPN_TIP_PREMIO
            INTO V_COD_CLIIB, V_COD_CLI, V_TIP_PTO, V_TPO_PREMIO
            FROM PCLUB.admpt_kardex
           WHERE admpn_id_kardex = C_CANJE_KARDEX_IDKARDEX;

          IF V_TIP_PTO = 'C' OR V_TIP_PTO = 'L' THEN
            UPDATE PCLUB.admpt_saldos_cliente
               SET admpn_saldo_cc  = C_CANJE_KARDEX_PUNTOS +
                                     (SELECT NVL(admpn_saldo_cc, 0)
                                        FROM PCLUB.admpt_saldos_cliente
                                       WHERE admpv_cod_cli = V_COD_CLI), --and admpn_cod_cli_ib=V_COD_CLIIB),
                   admpc_estpto_cc = 'A'
             WHERE admpv_cod_cli = V_COD_CLI; --and admpn_cod_cli_ib = V_COD_CLIIB;
          ELSIF V_TIP_PTO = 'I' THEN
              UPDATE PCLUB.admpt_saldos_cliente
                 SET admpn_saldo_ib  = C_CANJE_KARDEX_PUNTOS +
                                       (SELECT NVL(admpn_saldo_ib, 0)
                                          FROM PCLUB.admpt_saldos_cliente
                                         WHERE admpv_cod_cli = V_COD_CLI
                                           AND admpn_cod_cli_ib = V_COD_CLIIB),
                     admpc_estpto_ib = 'A'
               WHERE admpv_cod_cli = V_COD_CLI
                 AND admpn_cod_cli_ib = V_COD_CLIIB;
          ELSE
            IF V_TIP_PTO = 'B' THEN
              IF V_TPO_PREMIO = 0 THEN
                UPDATE PCLUB.admpt_saldos_cliente
                   SET admpn_saldo_cc  = C_CANJE_KARDEX_PUNTOS +
                                         (SELECT NVL(admpn_saldo_cc, 0)
                                            FROM PCLUB.admpt_saldos_cliente
                                           WHERE admpv_cod_cli = V_COD_CLI), --and admpn_cod_cli_ib=V_COD_CLIIB),
                       admpc_estpto_cc = 'A'
                 WHERE admpv_cod_cli = V_COD_CLI;
              ELSE
                UPDATE PCLUB.Admpt_Saldos_Bono_Cliente
                   SET ADMPN_SALDO  = C_CANJE_KARDEX_PUNTOS +
                                      (SELECT NVL(ADMPN_SALDO, 0)
                                         FROM PCLUB.Admpt_Saldos_Bono_Cliente
                                        WHERE ADMPV_COD_CLI = V_COD_CLI
                                          AND ADMPN_GRUPO = V_CANJ_TIPPRECJE),
                       ADMPV_ESTADO = 'A'
                 WHERE admpv_cod_cli = V_COD_CLI
                   AND ADMPN_GRUPO = V_CANJ_TIPPRECJE;

              END IF;
            END IF;
          END IF;
          V_TOTALPUNTOS := V_TOTALPUNTOS + C_CANJE_KARDEX_PUNTOS;
          FETCH CANJE_KARDEX
            INTO C_CANJE_KARDEX_IDKARDEX, C_CANJE_KARDEX_PUNTOS;
        END LOOP;

        -- Cambia el estado a 'D' Devuelto, al item en Canje Detalle
        UPDATE PCLUB.admpt_canje_detalle
           SET admpc_estado = 'D'
         WHERE admpv_id_canje = V_DEVOLUCION.id_canje
           AND admpv_id_canjesec = V_DEVOLUCION.ID_CANJESEC;

        /*Inserta la devolucion en canje detalle*/

        SELECT admpv_id_procla,
               admpv_desc,
               admpv_nom_camp,
               admpn_puntos,
               admpn_pago,
               admpn_cantidad,
               admpv_cod_tpopr,
               admpn_cod_servc,
               admpn_mnt_recar,
         admpv_cod_paqdat,
         admpv_codtxpaqdat
          INTO V_ID_PROCLA,
               V_PRO_DESC,
               V_NOM_CAMP,
               V_PUNTOS,
               V_PAGO,
               V_CANTIDAD,
               V_COD_TIP_PR,
               V_COD_SERV,
               V_MNT_RECAR,
         v_cod_paqdat,
         v_codtxpaqdat
          FROM PCLUB.admpt_canje_detalle
         WHERE admpv_id_canje = V_DEVOLUCION.id_canje
           AND admpv_id_canjesec = V_DEVOLUCION.ID_CANJESEC;

        INSERT INTO PCLUB.admpt_canje_detalle
          (admpv_id_canje,
           admpv_id_canjesec,
           admpv_id_procla,
           admpv_desc,
           admpv_nom_camp,
           admpn_puntos,
           admpn_pago,
           admpn_cantidad,
           admpv_cod_tpopr,
           admpn_cod_servc,
           admpn_mnt_recar,
           admpc_estado,
           admpv_cod_paqdat,
           admpv_codtxpaqdat)
        VALUES
          (V_ID_CANJE,
           V_DEVOLUCION.ID_CANJESEC,
           V_ID_PROCLA,
           V_PRO_DESC,
           V_NOM_CAMP,
           V_PUNTOS,
           V_PAGO,
           V_CANTIDAD,
           V_COD_TIP_PR,
           V_COD_SERV,
           V_MNT_RECAR,
           'D',
           v_cod_paqdat,
           v_codtxpaqdat);

      V_CODTPREMIO := '%' || V_COD_TIP_PR || '%';

      SELECT COUNT(1)
        INTO V_REGDEVOLENC
        FROM PCLUB.ADMPT_PARAMSIST
       WHERE ADMPV_DESC IN
             ('TIPO_PREMIO_SERVICIOS', 'TIPO_PREMIO_PRODUCTOS')
         AND ADMPV_VALOR LIKE V_CODTPREMIO;

      IF V_REGDEVOLENC > 0 THEN
        DELETE FROM PCLUB.ADMPT_MOVENCUESTA M
         WHERE M.ADMPN_IDCABENC =
               (SELECT C.ADMPN_IDCABENC
                  FROM PCLUB.ADMPT_CABENCUESTA C
                 WHERE C.ADMPN_ID_CANJE = V_DEVOLUCION.id_canje);

        DELETE FROM PCLUB.ADMPT_CABENCUESTA C
         WHERE C.ADMPN_ID_CANJE = V_DEVOLUCION.id_canje;
      END IF;

        CLOSE CANJE_KARDEX;
      END IF;
    END LOOP;

    -- se elimina la cabecera del canje si no se devolvio CERO puntos
    IF V_TOTALPUNTOS = 0 AND V_ID_PROCLA != 'BONRENESPE' AND
       K_LISTA_DEV.COUNT != 1 THEN
      DELETE FROM PCLUB.admpt_canje WHERE admpv_id_canje = V_ID_CANJE;
      --COMMIT;
      RAISE NO_DEVOLUCION;
    ELSE
      --Parámetros

	  select admpv_cod_cli,NVL(admpv_cod_tpocl, ''), ADMPV_VENTAID
                 INTO V_COD_CLI, V_TIPO_CLI, V_VENTAID
          from PCLUB.ADMPT_CANJE
          WHERE  ADMPV_ID_CANJE = V_ID_CANJE;
      IF V_VENTAID IS NULL THEN
        IF V_TIPO_CLI = '8' THEN
          SELECT admpv_cod_cpto
            INTO V_COD_CPTO
          FROM PCLUB.admpt_concepto
          WHERE admpv_desc = 'DEVOLUCION CANJE TFI'
                AND admpc_estado = 'A';
        ELSE
          SELECT admpv_cod_cpto
              INTO V_COD_CPTO
          FROM PCLUB.admpt_concepto
          WHERE admpv_desc = 'DEVOLUCION DE CANJE'
               AND admpc_estado = 'A';
        END IF;
      ELSE
              SELECT admpv_cod_cpto
                     INTO V_COD_CPTO
              FROM  PCLUB.admpt_concepto
              WHERE admpv_desc = 'DEVOLUCION CANJE VENTA'
                    AND admpc_estado = 'A';
       END IF;

      SELECT NVL(PCLUB.admpt_kardex_sq.NEXTVAL, '-1')
        INTO V_ID_KARDEX
        FROM dual;

      -- Inserta registro en Kardex por la suma de los puntos devueltos
      INSERT INTO PCLUB.admpt_kardex
        (admpn_id_kardex,
         admpn_cod_cli_ib,
         admpv_cod_cli,
         admpv_cod_cpto,
         admpd_fec_trans,
         admpn_puntos,
         admpv_nom_arch,
         admpc_tpo_oper,
         admpc_tpo_punto,
         admpn_sld_punto,
         admpc_estado)
      VALUES
        (V_ID_KARDEX,
         '',
         V_COD_CLI,
         V_COD_CPTO,
         TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
         V_TOTALPUNTOS,
         NULL,
         'E',
         NULL,
         0,
         'C');

      UPDATE PCLUB.admpt_canje
         SET admpn_id_kardex = V_ID_KARDEX
       WHERE admpv_id_canje = V_ID_CANJE;
      --COMMIT;
    END IF;

    /** saldo **/
    SELECT admpv_cod_tpocl
      INTO V_TPO_CLI
      FROM PCLUB.admpt_cliente
     WHERE admpv_cod_cli = V_CANJ_COD_CLI;
    admpsi_es_cliente(V_CANJ_COD_CLI,
                      NULL,
                      NULL,
                      V_TPO_CLI,
                      K_SALDO,
                      V_CODERROR);

    K_CODERROR := 0;
    K_MSJERROR := '';

  EXCEPTION
    WHEN NO_LISTA_DEV THEN
      K_CODERROR := 45;
      K_MSJERROR := 'La lista de devolución esta vacìa';

    WHEN NO_DEVOLUCION THEN
      K_CODERROR := 53;
      K_MSJERROR := 'No se realizo la devolucion porque los productos ya fueron devueltos.';

    WHEN OTHERS THEN
      K_CODERROR := SQLCODE;
      K_MSJERROR := SUBSTR(SQLERRM, 1, 400);
      ROLLBACK TO DEV_PUNTOS;
  END ADMPSS_DEVPUNTS;

  PROCEDURE ADMPSS_SALDOCLI(K_COD_CLIENTE  IN VARCHAR2,
                            K_TIPO_DOC     IN VARCHAR2,
                            K_NUM_DOC      IN VARCHAR2,
                            K_TIP_CLI      IN VARCHAR2,
                            K_CODERROR     OUT NUMBER,
                            K_MSJERROR     OUT VARCHAR2,
                            CUR_LISTASALDO OUT SYS_REFCURSOR) IS
    --*****************************
    -- Nombre SP           :  ADMPSS_SALDOCLI
    -- Propósito           :  Devuelve un cursor con la lista de saldos
    -- Input               :  K_CODCLIENTE- Codigo de Cliente
    --                        K_TIPO_DOC   - Tipo de Documento
    --                        K_NUM_DOC    - Numero de Documento
    --                        K_PUNTOVTA  - Punto de Venta
    --                        K_TIPOCLIENTE- Tipo de Cliente
    -- Output              :  K_CODERROR  - Codigo de Error
    --                        K_DESCERROR - Descripcion del Error
    --                        CUR_LISTASALDO- Cursor con la Lista de Saldos
    -- Creado por          :  (Venkizmet) Stiven Saavedra
    -- Fec Creación        :  17/09/2010
    -- Fec Actualización   :
    -- Errores             :
    --                        -1 El Tipo y Número de Documento o el Codigo de Cliente, son datos obligatorios para la Consulta.
    --                        -2 El Tipo de Cliente es un dato obligatorios para la Consulta.
    --                        -3 El Cliente no existe segun el Tipo de Cliente solicitado.
    --***************************************************************************************************************************--*****

    V_TIPODOC VARCHAR2(20);
    V_NUMDOC  VARCHAR2(20);
    V_REGCLI  NUMBER;

    ERRORDATOSDOC EXCEPTION;
    ERRORDATOSTIP EXCEPTION;
    ERRORDATOSCLI EXCEPTION;

  BEGIN
    -- Si los tres valores son nulos se considera un error
    IF (K_TIPO_DOC IS NULL) AND (K_NUM_DOC IS NULL) AND
       (K_COD_CLIENTE IS NULL) THEN
      RAISE ERRORDATOSDOC;
    END IF;

    -- Si el Cliente es nulo y el tipo o numero es nulo se muestra error
    IF ((K_TIPO_DOC IS NULL) OR (K_NUM_DOC IS NULL)) AND
       (K_COD_CLIENTE IS NULL) THEN
      RAISE ERRORDATOSDOC;
    END IF;

    IF (K_TIP_CLI IS NULL) THEN
      RAISE ERRORDATOSTIP;
    END IF;

    V_REGCLI := 0;

    -- Si solamente envio Codigo de Cliente
    IF ((K_TIPO_DOC IS NULL) OR (K_NUM_DOC IS NULL)) AND
       (K_COD_CLIENTE IS NOT NULL) THEN
      -- Si el tipo de Cliente es Postpago o Control agrupamos en una sola bolsa, en otro caso se controla por el tipo de --cliente como unico
      IF K_TIP_CLI = '1' OR K_TIP_CLI = '2' THEN
        SELECT COUNT(*)
          INTO V_REGCLI
          FROM ADMPT_CLIENTE
         WHERE admpv_cod_cli = K_COD_CLIENTE
           AND admpv_cod_tpocl IN ('1', '2');

        IF (V_REGCLI = 0) THEN
          RAISE ERRORDATOSCLI;
        END IF;

        SELECT admpv_tipo_doc, admpv_num_doc
          INTO V_TIPODOC, V_NUMDOC
          FROM ADMPT_CLIENTE
         WHERE admpv_cod_cli = K_COD_CLIENTE
           AND admpv_cod_tpocl IN ('1', '2');
      ELSE
        SELECT COUNT(*)
          INTO V_REGCLI
          FROM ADMPT_CLIENTE
         WHERE admpv_cod_cli = K_COD_CLIENTE
           AND admpv_cod_tpocl = K_TIP_CLI;

        IF (V_REGCLI = 0) THEN
          RAISE ERRORDATOSCLI;
        END IF;

        SELECT admpv_tipo_doc, admpv_num_doc
          INTO V_TIPODOC, V_NUMDOC
          FROM ADMPT_CLIENTE
         WHERE admpv_cod_cli = K_COD_CLIENTE
           AND admpv_cod_tpocl = K_TIP_CLI;

      END IF;
    ELSE
      -- Si envio tipo y numero de documento
      V_TIPODOC := K_TIPO_DOC;
      V_NUMDOC  := K_NUM_DOC;

      IF K_TIP_CLI = '1' OR K_TIP_CLI = '2' THEN
        SELECT COUNT(*)
          INTO V_REGCLI
          FROM ADMPT_CLIENTE
         WHERE admpv_tipo_doc = V_TIPODOC
           AND admpv_num_doc = V_NUMDOC
           AND admpv_cod_tpocl IN ('1', '2');

        IF (V_REGCLI = 0) THEN
          RAISE ERRORDATOSCLI;
        END IF;

      ELSE
        SELECT COUNT(*)
          INTO V_REGCLI
          FROM ADMPT_CLIENTE
         WHERE admpv_tipo_doc = V_TIPODOC
           AND admpv_num_doc = V_NUMDOC
           AND admpv_cod_tpocl = K_TIP_CLI;

        IF (V_REGCLI = 0) THEN
          RAISE ERRORDATOSCLI;
        END IF;

      END IF;

    END IF;

    -- Primero obtenemos todos los Clientes segun el tipo para mostrar los saldos
    IF (V_TIPODOC IS NOT NULL) AND (V_NUMDOC IS NOT NULL) THEN

      IF K_TIP_CLI = '1' OR K_TIP_CLI = '2' THEN

        OPEN CUR_LISTASALDO FOR
          SELECT admpv_cod_cli as K_CODCLIENTE,
                 admpv_desc as K_CATCLIENTE,
                 NVL((SELECT SUM(admpn_puntos)
                       FROM admpt_kardex
                      WHERE admpt_kardex.admpv_cod_cli =
                            ADMPT_CLIENTE.ADMPV_COD_CLI
                        AND admpc_tpo_oper = 'E'
                        AND admpn_puntos > 0),
                     0) as K_TOTACUM,
                 NVL((SELECT SUM(admpn_puntos)
                        FROM admpt_kardex
                       WHERE admpt_kardex.admpv_cod_cli =
                             ADMPT_CLIENTE.ADMPV_COD_CLI
                         AND admpc_tpo_oper = 'S') * -1,
                     0) as K_TOTCANJE,
                 NVL((SELECT NVL(admpn_saldo_cc, 0) + NVL(admpn_saldo_ib, 0)
                       FROM admpt_saldos_cliente
                      WHERE admpt_saldos_cliente.admpv_cod_cli =
                            ADMPT_CLIENTE.ADMPV_COD_CLI),
                     0) as K_SALDO,
                 NVL((SELECT NVL(admpn_saldo_cc, 0)
                       FROM admpt_saldos_cliente
                      WHERE admpt_saldos_cliente.admpv_cod_cli =
                            ADMPT_CLIENTE.ADMPV_COD_CLI),
                     0) as K_SALDOCC,
                 NVL((SELECT NVL(admpn_saldo_ib, 0)
                       FROM admpt_saldos_cliente
                      WHERE admpt_saldos_cliente.admpv_cod_cli =
                            ADMPT_CLIENTE.ADMPV_COD_CLI),
                     0) as K_SALDOIB
            FROM ADMPT_CLIENTE
            LEFT OUTER JOIN ADMPT_CAT_CLIENTE ON ADMPT_CLIENTE.admpn_cod_catcli =
                                                 ADMPT_CAT_CLIENTE.ADMPN_COD_CATCLI
                                             AND ADMPT_CLIENTE.ADMPV_COD_TPOCL =
                                                 ADMPT_CAT_CLIENTE.ADMPV_COD_TPOCL
           WHERE admpv_tipo_doc = V_TIPODOC
             AND admpv_num_doc = V_NUMDOC
             AND ADMPT_CLIENTE.admpv_cod_tpocl IN ('1', '2');

      ELSE

        OPEN CUR_LISTASALDO FOR
          SELECT admpv_cod_cli as K_CODCLIENTE,
                 admpv_desc as K_CATCLIENTE,
                 NVL((SELECT SUM(admpn_puntos)
                       FROM admpt_kardex
                      WHERE admpt_kardex.admpv_cod_cli =
                            ADMPT_CLIENTE.ADMPV_COD_CLI
                        AND admpc_tpo_oper = 'E'
                        AND admpn_puntos > 0),
                     0) as K_TOTACUM,
                 NVL((SELECT SUM(admpn_puntos)
                        FROM admpt_kardex
                       WHERE admpt_kardex.admpv_cod_cli =
                             ADMPT_CLIENTE.ADMPV_COD_CLI
                         AND admpc_tpo_oper = 'S') * -1,
                     0) as K_TOTCANJE,
                 NVL((SELECT NVL(admpn_saldo_cc, 0) + NVL(admpn_saldo_ib, 0)
                       FROM admpt_saldos_cliente
                      WHERE admpt_saldos_cliente.admpv_cod_cli =
                            ADMPT_CLIENTE.ADMPV_COD_CLI),
                     0) as K_SALDO,
                 NVL((SELECT NVL(admpn_saldo_cc, 0)
                       FROM admpt_saldos_cliente
                      WHERE admpt_saldos_cliente.admpv_cod_cli =
                            ADMPT_CLIENTE.ADMPV_COD_CLI),
                     0) as K_SALDOCC,
                 NVL((SELECT NVL(admpn_saldo_ib, 0)
                       FROM admpt_saldos_cliente
                      WHERE admpt_saldos_cliente.admpv_cod_cli =
                            ADMPT_CLIENTE.ADMPV_COD_CLI),
                     0) as K_SALDOIB
            FROM ADMPT_CLIENTE
            LEFT OUTER JOIN ADMPT_CAT_CLIENTE ON ADMPT_CLIENTE.admpn_cod_catcli =
                                                 ADMPT_CAT_CLIENTE.ADMPN_COD_CATCLI
                                             AND ADMPT_CLIENTE.ADMPV_COD_TPOCL =
                                                 ADMPT_CAT_CLIENTE.ADMPV_COD_TPOCL
           WHERE admpv_tipo_doc = V_TIPODOC
             AND admpv_num_doc = V_NUMDOC
             AND ADMPT_CLIENTE.admpv_cod_tpocl = K_TIP_CLI;

      END IF;
    END IF;

    K_CODERROR := 0;
    K_MSJERROR := '';

  EXCEPTION
    WHEN ERRORDATOSDOC THEN
      K_CODERROR := -1;
      K_MSJERROR := 'El Tipo y Número de Documento o el Codigo de Cliente, son datos obligatorios para la Consulta.';

      OPEN CUR_LISTASALDO FOR
          SELECT
           '' K_CODCLIENTE,
           '' K_CATCLIENTE,
            0 K_TOTACUM,
            0 K_TOTCANJE,
            0 K_SALDO,
            0 K_SALDOCC,
            0 K_SALDOIB
           FROM DUAL;

    WHEN ERRORDATOSTIP THEN
      K_CODERROR := -2;
      K_MSJERROR := 'El Tipo de Cliente es un dato obligatorios para la Consulta.';

      OPEN CUR_LISTASALDO FOR
          SELECT
           '' K_CODCLIENTE,
           '' K_CATCLIENTE,
            0 K_TOTACUM,
            0 K_TOTCANJE,
            0 K_SALDO,
            0 K_SALDOCC,
            0 K_SALDOIB
           FROM DUAL;

    WHEN ERRORDATOSCLI THEN
      K_CODERROR := -3;
      K_MSJERROR := 'El Cliente no existe segun el Tipo de Cliente solicitado.';

      OPEN CUR_LISTASALDO FOR
          SELECT
           '' K_CODCLIENTE,
           '' K_CATCLIENTE,
            0 K_TOTACUM,
            0 K_TOTCANJE,
            0 K_SALDO,
            0 K_SALDOCC,
            0 K_SALDOIB
           FROM DUAL;

    WHEN OTHERS THEN
      K_CODERROR := SQLCODE;
      K_MSJERROR := SUBSTR(SQLERRM, 1, 250);

      OPEN CUR_LISTASALDO FOR
          SELECT
           '' K_CODCLIENTE,
           '' K_CATCLIENTE,
            0 K_TOTACUM,
            0 K_TOTCANJE,
            0 K_SALDO,
            0 K_SALDOCC,
            0 K_SALDOIB
           FROM DUAL;

  END admpss_saldocli;

  PROCEDURE ADMPSS_SALDOBONOCLI(K_COD_CLIENTE  IN VARCHAR2,
                                K_TIP_CLI      IN VARCHAR2,
                                K_CODERROR     OUT NUMBER,
                                K_MSJERROR     OUT VARCHAR2,
                                CUR_LISTASALDO OUT SYS_REFCURSOR) IS

    V_REGCLI NUMBER;

    ERRORDATOSTIP EXCEPTION;
    ERRORDATOSCLI EXCEPTION;

  BEGIN
    -- Si los valores son nulos, se considera un error
    IF (K_COD_CLIENTE IS NULL) THEN
      RAISE ERRORDATOSCLI;
    END IF;

    IF (K_TIP_CLI IS NULL) THEN
      RAISE ERRORDATOSTIP;
    END IF;

    V_REGCLI := 0;

    -- Si solamente envió Código de Cliente
    IF (K_COD_CLIENTE IS NOT NULL) THEN
      IF K_TIP_CLI = '3' THEN
        SELECT COUNT(*)
          INTO V_REGCLI
          FROM PCLUB.ADMPT_CLIENTE
         WHERE admpv_cod_cli = K_COD_CLIENTE
           AND admpv_cod_tpocl = K_TIP_CLI;

        IF (V_REGCLI = 0) THEN
          RAISE ERRORDATOSCLI;
        END IF;

        OPEN CUR_LISTASALDO FOR
          SELECT G.ADMPN_GRUPO       GRUPO,
                 G.ADMPV_DESCRIPCION TIPPUNTO,
                 SB.ADMPN_SALDO      PUNTOS
            FROM PCLUB.ADMPT_SALDOS_BONO_CLIENTE SB
            LEFT OUTER JOIN ADMPT_GRUPO_TIPPREM G
              ON SB.ADMPN_GRUPO = G.ADMPN_GRUPO
           WHERE SB.ADMPV_COD_CLI = K_COD_CLIENTE;

      END IF;
    END IF;

    K_CODERROR := 0;
    K_MSJERROR := '';

  EXCEPTION
    WHEN ERRORDATOSTIP THEN
      K_CODERROR := -2;
      K_MSJERROR := 'El Tipo de Cliente es un dato obligatorio para la Consulta.';

      OPEN CUR_LISTASALDO FOR
        SELECT '' TIPPUNTO, 0 PUNTOS FROM DUAL;

    WHEN ERRORDATOSCLI THEN
      K_CODERROR := -3;
      K_MSJERROR := 'El Cliente no existe segun el Tipo de Cliente solicitado.';

      OPEN CUR_LISTASALDO FOR
        SELECT '' TIPPUNTO, 0 PUNTOS FROM DUAL;

    WHEN OTHERS THEN
      K_CODERROR := SQLCODE;
      K_MSJERROR := SUBSTR(SQLERRM, 1, 250);

      OPEN CUR_LISTASALDO FOR
        SELECT '' TIPPUNTO, 0 PUNTOS FROM DUAL;

  END ADMPSS_SALDOBONOCLI;

  PROCEDURE ADMPSS_DATOSCLI(K_TIPO_DOC  IN VARCHAR2,
                            K_NUM_DOC   IN VARCHAR2,
                            K_TIPOLINEA IN VARCHAR2,
                            K_CODERROR  OUT NUMBER,
                            K_MSJERROR  OUT VARCHAR2,
                            CURSORCLI   OUT SYS_REFCURSOR) IS

    --****************************************************************
    -- Nombre SP           :  ADMPSS_DATOSCLI
    -- Propósito           :  Devuelve en un cursor con los datos de los clientes y su saldo
    -- Input               :  K_TIPO_DOC Tipo de Documento
    --                        K_NUM_DOC Numero de Documento
    --                        K_TIPOLINEA Tipo de Linea
    --
    -- Output              :  CURSORCLI
    -- Creado por          :  (Venkizmet) Sofia Khlebnikov
    -- Fec Creación        :  27/09/2010
    -- Fec Actualización   :
    --****************************************************************

    ERRORDATOS EXCEPTION;
    ERRORTIPOCLI EXCEPTION;

    V_CODTIPOCLI VARCHAR2(2);
    V_CODCLI     VARCHAR2(40);
    V_NOMCLI     VARCHAR2(30);
    V_APECLI     VARCHAR2(30);
    V_TIPOCLI    VARCHAR2(2);

    V_PUNTCANJ NUMBER;
    V_PUNTDEV  NUMBER;

    CURSOR CLIENTES1(tipo_doc VARCHAR2, num_doc VARCHAR2) IS
      SELECT ADMPV_COD_CLI, ADMPV_NOM_CLI, ADMPV_APE_CLI, ADMPV_COD_TPOCL
        FROM PCLUB.admpt_cliente
       WHERE ADMPC_ESTADO IN ('A')
         AND ADMPV_TIPO_DOC = tipo_doc
         AND ADMPV_NUM_DOC = num_doc
         AND ADMPV_COD_TPOCL IN ('1', '2');

    CURSOR CLIENTES2(tipo_doc VARCHAR2, num_doc VARCHAR2, cod_tipo_cli VARCHAR2) IS
      SELECT ADMPV_COD_CLI, ADMPV_NOM_CLI, ADMPV_APE_CLI
        FROM PCLUB.admpt_cliente
       WHERE ADMPC_ESTADO IN ('A')
         AND ADMPV_TIPO_DOC = tipo_doc
         AND ADMPV_NUM_DOC = num_doc
         AND ADMPV_COD_TPOCL = cod_tipo_cli;

  BEGIN

    IF (K_TIPOLINEA = 'IB' OR K_TIPOLINEA = 'ib') THEN
      BEGIN
        OPEN CURSORCLI FOR
          SELECT ADMPN_COD_CLI_IB AS COD_CLIENTE,
                 'IB' AS COD_TIPO_CLIENTE,
                 ADMPV_NOM_CLI || ' ' || ADMPV_APE_CLI AS NOMBRE_CLIENTE,
                 0 AS PUNTOS_CANJEADOS
            FROM PCLUB.ADMPT_CLIENTEIB
           WHERE ADMPV_TIPO_DOC = K_TIPO_DOC
             AND ADMPV_NUM_DOC = K_NUM_DOC
             AND ADMPC_ESTADO = 'A';
      END;
    ELSE
      BEGIN
        BEGIN
          SELECT ADMPV_COD_TPOCL
            INTO V_CODTIPOCLI
            FROM PCLUB.ADMPT_TIPO_CLIENTE
           WHERE UPPER(ADMPV_DESC) = K_TIPOLINEA
              OR LOWER(ADMPV_DESC) = K_TIPOLINEA;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RAISE ERRORTIPOCLI;
        END;

        IF (V_CODTIPOCLI = '1' OR V_CODTIPOCLI = '2') THEN

          BEGIN

            OPEN CLIENTES1(K_TIPO_DOC, K_NUM_DOC);
            FETCH CLIENTES1
              INTO V_CODCLI, V_NOMCLI, V_APECLI, V_TIPOCLI;

            WHILE CLIENTES1 %FOUND LOOP

              BEGIN
                SELECT NVL(SUM(ADMPN_PUNTOS), 0)
                  INTO V_PUNTCANJ
                  FROM PCLUB.ADMPT_KARDEX
                 WHERE ADMPV_COD_CLI = V_CODCLI
                   AND ADMPV_COD_CPTO =
                       (SELECT ADMPV_COD_CPTO
                          FROM PCLUB.ADMPT_CONCEPTO
                         WHERE ADMPV_DESC = 'CANJE')
                   AND ADMPC_ESTADO = 'C';

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  V_PUNTCANJ := 0;
              END;

              BEGIN
                SELECT NVL(SUM(ADMPN_PUNTOS), 0)
                  INTO V_PUNTDEV
                  FROM PCLUB.ADMPT_KARDEX
                 WHERE ADMPV_COD_CLI = V_CODCLI
                   AND ADMPV_COD_CPTO =
                       (SELECT ADMPV_COD_CPTO
                          FROM PCLUB.ADMPT_CONCEPTO
                         WHERE ADMPV_DESC = 'DEVOLUCION DE CANJE');

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  V_PUNTDEV := 0;

              END;

              INSERT INTO PCLUB.ADMPT_DATOSCLITMP
                (ADMPV_COD_CLI,
                 ADMPV_COD_TPOCL,
                 ADMPV_NOMBRE,
                 ADMPN_PUNTOS_CANJ)
              VALUES
                (V_CODCLI,
                 V_TIPOCLI,
                 V_NOMCLI || ' ' || V_APECLI,
                 (-1) * (V_PUNTCANJ - V_PUNTDEV));

              COMMIT;

              FETCH CLIENTES1
                INTO V_CODCLI, V_NOMCLI, V_APECLI, V_TIPOCLI;
            END LOOP;
            CLOSE CLIENTES1;

          END;

        ELSE

          BEGIN

            OPEN CLIENTES2(K_TIPO_DOC, K_NUM_DOC, V_CODTIPOCLI);
            FETCH CLIENTES2
              INTO V_CODCLI, V_NOMCLI, V_APECLI;

            WHILE CLIENTES2 %FOUND LOOP

              BEGIN
                SELECT SUM(ADMPN_PUNTOS)
                  INTO V_PUNTCANJ
                  FROM PCLUB.ADMPT_KARDEX
                 WHERE ADMPV_COD_CLI = V_CODCLI
                   AND ADMPV_COD_CPTO =
                       (SELECT ADMPV_COD_CPTO
                          FROM PCLUB.ADMPT_CONCEPTO
                         WHERE ADMPV_DESC = 'CANJE')
                   AND ADMPC_ESTADO = 'C';

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  V_PUNTCANJ := 0;
              END;

              BEGIN
                SELECT SUM(ADMPN_PUNTOS)
                  INTO V_PUNTDEV
                  FROM PCLUB.ADMPT_KARDEX
                 WHERE ADMPV_COD_CLI = V_CODCLI
                   AND ADMPV_COD_CPTO =
                       (SELECT ADMPV_COD_CPTO
                          FROM PCLUB.ADMPT_CONCEPTO
                         WHERE ADMPV_DESC = 'DEVOLUCION DE CANJE');

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  V_PUNTDEV := 0;

              END;

              INSERT INTO PCLUB.ADMPT_DATOSCLITMP
                (ADMPV_COD_CLI,
                 ADMPV_COD_TPOCL,
                 ADMPV_NOMBRE,
                 ADMPN_PUNTOS_CANJ)
              VALUES
                (V_CODCLI,
                 V_CODTIPOCLI,
                 V_NOMCLI || ' ' || V_APECLI,
                 (-1) * (V_PUNTCANJ - V_PUNTDEV));

              COMMIT;

              FETCH CLIENTES2
                INTO V_CODCLI, V_NOMCLI, V_APECLI;
            END LOOP;
            CLOSE CLIENTES2;

          END;

        END IF;

        OPEN CURSORCLI FOR
          SELECT ADMPV_COD_CLI     AS COD_CLIENTE,
                 ADMPV_COD_TPOCL   AS COD_TIPO_CLIENTE,
                 ADMPV_NOMBRE      AS NOMBRE_CLIENTE,
                 ADMPN_PUNTOS_CANJ AS PUNTOS_CANJEADOS
            FROM PCLUB.ADMPT_DATOSCLITMP
           ORDER BY ADMPV_COD_CLI;
      END;
    END IF;

    DELETE ADMPT_DATOSCLITMP;
    COMMIT;

    K_CODERROR := 0;
    K_MSJERROR := '';

  EXCEPTION
    WHEN ERRORDATOS THEN
      NULL;

      OPEN CURSORCLI FOR
      SELECT
      '' COD_CLIENTE,
      '' COD_TIPO_CLIENTE,
      '' NOMBRE_CLIENTE,
      '' PUNTOS_CANJEADOS
      FROM DUAL;

    WHEN ERRORTIPOCLI THEN
      NULL;

      OPEN CURSORCLI FOR
      SELECT
      '' COD_CLIENTE,
      '' COD_TIPO_CLIENTE,
      '' NOMBRE_CLIENTE,
      '' PUNTOS_CANJEADOS
      FROM DUAL;

    WHEN OTHERS THEN
      NULL;

      OPEN CURSORCLI FOR
      SELECT
      '' COD_CLIENTE,
      '' COD_TIPO_CLIENTE,
      '' NOMBRE_CLIENTE,
      '' PUNTOS_CANJEADOS
      FROM DUAL;

  END;

  PROCEDURE ADMPSS_DETMOV(K_COD_CLIENTE IN VARCHAR2,
                          K_TIPO_DOC    IN VARCHAR2,
                          K_NUM_DOC     IN VARCHAR2,
                          K_TIP_CLI     IN VARCHAR2,
                          K_FECHA_INI   IN DATE,
                          K_FECHA_FIN   IN DATE,
                          K_CODERROR    OUT NUMBER,
                          K_MSJERROR    OUT VARCHAR2,
                          CURSORDATOS   OUT SYS_REFCURSOR) IS

    --****************************************************************
    -- Nombre SP           :  ADMPSS_DETMOV
    -- Propósito           :  Devuelve en un cursor con los movimientos realizados por el cliente
    -- Input               :  K_COD_CLIENTE Codigo de Cliente
    --                        K_TIPO_DOC Tipo de Documento
    --                        K_NUM_DOC Numero de Documento
    --                        K_TIPOLINEA Tipo de Linea
    --
    -- Output              :  CURSORDATOS
    -- Creado por          :  (Venkizmet) Sofia Khlebnikov
    -- Fec Creación        :  27/09/2010
    -- Fec Actualización   :
    --****************************************************************

    ERRORDATOS EXCEPTION;
    ERRORTIPOCLI EXCEPTION;
    ERRORPARAM EXCEPTION;
    ERRORFECHA EXCEPTION;
    NO_DATA_CURSOR EXCEPTION;

    V_TIPODOC VARCHAR2(20);
    V_NUMDOC  VARCHAR2(20);

    V_CODCLI VARCHAR2(40);

    CURSOR CLIENTECC1(tipo_doc VARCHAR2, num_doc VARCHAR2, tipo_cli VARCHAR2) IS
      SELECT ADMPV_COD_CLI

        FROM PCLUB.ADMPT_CLIENTE c

       WHERE ADMPV_TIPO_DOC = tipo_doc
         AND ADMPV_NUM_DOC = num_doc
         AND ADMPV_COD_TPOCL IN ('1', '2')
         AND ADMPC_ESTADO = 'A';

    CURSOR CLIENTECC2(tipo_doc VARCHAR2, num_doc VARCHAR2, tipo_cli VARCHAR2) IS
      SELECT ADMPV_COD_CLI

        FROM PCLUB.ADMPT_CLIENTE c

       WHERE ADMPV_TIPO_DOC = tipo_doc
         AND ADMPV_NUM_DOC = num_doc
         AND ADMPV_COD_TPOCL = tipo_cli
         AND ADMPC_ESTADO = 'A';

  BEGIN

    IF (K_TIP_CLI IS NULL) THEN
      RAISE ERRORTIPOCLI;
    END IF;

    IF (K_FECHA_INI IS NULL OR K_FECHA_FIN IS NULL OR
       ABS(MONTHS_BETWEEN(K_FECHA_INI, K_FECHA_FIN)) > 4) THEN
      RAISE ERRORFECHA;
    END IF;

    IF (K_COD_CLIENTE IS NULL AND K_TIPO_DOC IS NULL AND K_NUM_DOC IS NULL AND
       K_TIP_CLI IS NOT NULL) OR
       (K_COD_CLIENTE IS NULL AND K_TIPO_DOC IS NULL AND
       K_NUM_DOC IS NOT NULL AND K_TIP_CLI IS NOT NULL) OR
       (K_COD_CLIENTE IS NULL AND K_TIPO_DOC IS NOT NULL AND
       K_NUM_DOC IS NULL AND K_TIP_CLI IS NOT NULL) THEN
      RAISE ERRORPARAM;
    END IF;

    IF (K_COD_CLIENTE IS NOT NULL AND K_TIPO_DOC IS NULL AND
       K_NUM_DOC IS NULL AND K_TIP_CLI IS NOT NULL) THEN
      BEGIN
        SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
          INTO V_TIPODOC, V_NUMDOC
          FROM PCLUB.ADMPT_CLIENTE
         WHERE ADMPV_COD_CLI = K_COD_CLIENTE
           AND ADMPV_COD_TPOCL = K_TIP_CLI;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE ERRORDATOS;
      END;

      IF (K_TIP_CLI = '1' OR K_TIP_CLI = '2') THEN

        OPEN CLIENTECC1(V_TIPODOC, V_NUMDOC, K_TIP_CLI);
      ELSE
        OPEN CLIENTECC2(V_TIPODOC, V_NUMDOC, K_TIP_CLI);

      END IF;
    END IF;

    IF (K_TIPO_DOC IS NOT NULL AND K_NUM_DOC IS NOT NULL AND
       K_TIP_CLI IS NOT NULL) THEN
      IF (K_TIP_CLI = '1' OR K_TIP_CLI = '2') THEN

        OPEN CLIENTECC1(K_TIPO_DOC, K_NUM_DOC, K_TIP_CLI);
      ELSE
        OPEN CLIENTECC2(K_TIPO_DOC, K_NUM_DOC, K_TIP_CLI);

      END IF;
    END IF;

    IF (K_TIP_CLI = '1' OR K_TIP_CLI = '2') THEN

      BEGIN
        FETCH CLIENTECC1
          INTO V_CODCLI;

        IF (CLIENTECC1%rowcount = 0) THEN
          RAISE NO_DATA_CURSOR;
        END IF;

        WHILE CLIENTECC1 %FOUND LOOP

          BEGIN
            INSERT INTO PCLUB.ADMPT_DETMOVTMP
              SELECT DECODE(k.ADMPC_TPO_OPER, 'E', 'ABONO', 'S', 'CARGO'),
                     c.ADMPV_DESC,
                     k.ADMPN_PUNTOS,
                     k.ADMPD_FEC_TRANS
                FROM PCLUB.ADMPT_KARDEX k, PCLUB.ADMPT_CONCEPTO c
               WHERE k.ADMPV_COD_CLI = V_CODCLI
                 AND c.ADMPV_COD_CPTO = k.ADMPV_COD_CPTO;
            COMMIT;

          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;

          FETCH CLIENTECC1
            INTO V_CODCLI;

        END LOOP;
        CLOSE CLIENTECC1;

      END;

    ELSE

      BEGIN
        FETCH CLIENTECC2
          INTO V_CODCLI;

        IF (CLIENTECC2%rowcount = 0) THEN
          RAISE NO_DATA_CURSOR;
        END IF;

        WHILE CLIENTECC2 %FOUND LOOP

          BEGIN
            INSERT INTO PCLUB.ADMPT_DETMOVTMP
              SELECT DECODE(k.ADMPC_TPO_OPER, 'E', 'ABONO', 'S', 'CARGO'),
                     c.ADMPV_DESC,
                     k.ADMPN_PUNTOS,
                     k.ADMPD_FEC_TRANS
                FROM PCLUB.ADMPT_KARDEX k, PCLUB.ADMPT_CONCEPTO c
               WHERE k.ADMPV_COD_CLI = V_CODCLI
                 AND c.ADMPV_COD_CPTO = k.ADMPV_COD_CPTO;
            COMMIT;

          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;

          FETCH CLIENTECC2
            INTO V_CODCLI;

        END LOOP;
        CLOSE CLIENTECC2;

      END;

    END IF;

    OPEN CURSORDATOS FOR
      SELECT * FROM ADMPT_DETMOVTMP;

    DELETE ADMPT_DETMOVTMP;
    COMMIT;

    K_CODERROR := 0;
    K_MSJERROR := '';

  EXCEPTION

    WHEN ERRORTIPOCLI THEN
      K_CODERROR := 44;
      K_MSJERROR := 'El tipo de cliente es obligatorio no se puede mostrar detalle de acumulación de puntos';

      OPEN CURSORDATOS FOR
      SELECT
      '' ADMPV_MOTIVO,
      '' ADMPV_CONCEPTO,
      '' ADMPN_PUNTOS,
      '' ADMPD_FEC_TRANS
      FROM DUAL;

    WHEN ERRORPARAM THEN
      K_CODERROR := 49;
      K_MSJERROR := 'El código del cliente o el tipo de documento y el número de documento son obligatorios';

      OPEN CURSORDATOS FOR
      SELECT
      '' ADMPV_MOTIVO,
      '' ADMPV_CONCEPTO,
      '' ADMPN_PUNTOS,
      '' ADMPD_FEC_TRANS
      FROM DUAL;

    WHEN ERRORDATOS THEN
      K_CODERROR := 45;
      K_MSJERROR := 'No existe el documento para el cliente con codigo: ' || K_COD_CLIENTE;

      OPEN CURSORDATOS FOR
      SELECT
      '' ADMPV_MOTIVO,
      '' ADMPV_CONCEPTO,
      '' ADMPN_PUNTOS,
      '' ADMPD_FEC_TRANS
      FROM DUAL;


    WHEN NO_DATA_CURSOR THEN
      K_CODERROR := 40;
      K_MSJERROR := 'No hay registros para el cliente con código: ' ||
                    K_COD_CLIENTE || ' tipo documento: ' || K_TIPO_DOC ||
                    ' numero documento: ' || K_NUM_DOC;

      OPEN CURSORDATOS FOR
      SELECT
      '' ADMPV_MOTIVO,
      '' ADMPV_CONCEPTO,
      '' ADMPN_PUNTOS,
      '' ADMPD_FEC_TRANS
      FROM DUAL;

    WHEN ERRORFECHA THEN
      K_CODERROR := 41;
      K_MSJERROR := 'La fecha inicio y fin de ADMPSS_DETMOV son obligatorias/ El periodo de consulta no debe ser mayor de 4 meses';

      OPEN CURSORDATOS FOR
      SELECT
      '' ADMPV_MOTIVO,
      '' ADMPV_CONCEPTO,
      '' ADMPN_PUNTOS,
      '' ADMPD_FEC_TRANS
      FROM DUAL;

    WHEN OTHERS THEN
      K_CODERROR := SQLCODE;
      K_MSJERROR := SUBSTR(SQLERRM, 1, 400);

      OPEN CURSORDATOS FOR
      SELECT
      '' ADMPV_MOTIVO,
      '' ADMPV_CONCEPTO,
      '' ADMPN_PUNTOS,
      '' ADMPD_FEC_TRANS
      FROM DUAL;


  END;

  PROCEDURE ADMPSI_ES_CLIENTE(K_COD_CLIENTE IN VARCHAR2,
                              K_TIPO_DOC    IN VARCHAR2,
                              K_NUM_DOC     IN VARCHAR2,
                              K_TIP_CLI     IN VARCHAR2,
                              K_SALDO       OUT NUMBER,
                              K_CODERROR    OUT NUMBER) IS

    --****************************************************************
    -- Nombre SP           :  ADMPSI_ES_CLIENTE
    -- Propósito           :  Devuelve el saldo del cliente y el indicador de error
    -- Input               :  K_COD_CLIENTE Codigo de Cliente
    --                        K_TIPO_DOC Tipo de Documento
    --                        K_NUM_DOC Numero de Documento
    --                        K_TIPOLINEA Tipo de Linea
    --
    -- Output              :  K_SALDO
    --                        K_CODERROR
    -- Creado por          :  (Venkizmet) Rossana Janampa
    -- Fec Creación        :  27/09/2010
    -- Fec Actualización   :  08/04/2013
    --****************************************************************
    -- Variables
    V_TIP_DOC      PCLUB.admpt_cliente.admpv_tipo_doc%TYPE;
    V_NUM_DOC      PCLUB.admpt_cliente.admpv_num_doc%TYPE;
    V_TIP_CLIE     PCLUB.admpt_cliente.admpv_cod_tpocl%TYPE;
    V_SALDO_IB     NUMBER := 0;
    V_SALDO_CC     NUMBER := 0;
    NO_PARAMETROS EXCEPTION;
    nro_registrosCC NUMBER := 0;
    nro_registrosIB NUMBER := 0;
    --K_MSJERROR         VARCHAR2(400);
    V_COD_CLI_IB NUMBER;

  BEGIN

    IF K_COD_CLIENTE IS NOT NULL AND K_TIP_CLI IS NOT NULL THEN
      /* La consulta se realiza por cuenta de cliente : SOLO PARA CLIENTES CLARO CLUB */
      BEGIN
        -- Con el código de cliente devuelve el tipo de documento y el numero de documento, debe devolver 0 ó 1 registro
        SELECT NVL(admpv_tipo_doc, 0),
               NVL(admpv_num_doc, 0),
               NVL(admpv_cod_tpocl, 0)
          INTO V_TIP_DOC, V_NUM_DOC, V_TIP_CLIE
          FROM admpt_cliente
         WHERE admpv_cod_cli = K_COD_CLIENTE
           AND admpc_estado = 'A';

        IF (V_TIP_CLIE = '3' OR V_TIP_CLIE = '4'OR V_TIP_CLIE = '8') AND
            V_TIP_CLIE = K_TIP_CLI THEN
            BEGIN
                 SELECT SUM(NVL(SC.ADMPN_SALDO_CC, 0)),SUM(CASE WHEN NVL(SC.ADMPC_ESTPTO_IB, 0) = 'A' THEN
                                                       NVL(SC.ADMPN_SALDO_IB, 0)
                                                       ELSE
                                                       0
                                                       END)
                 INTO V_SALDO_IB,V_SALDO_CC
                 FROM ADMPT_CLIENTE C INNER JOIN ADMPT_SALDOS_CLIENTE SC
                 ON C.ADMPV_COD_CLI = SC.ADMPV_COD_CLI
                 WHERE (C.ADMPV_TIPO_DOC = V_TIP_DOC AND C.ADMPV_NUM_DOC = V_NUM_DOC)
                 AND C.ADMPC_ESTADO = 'A'
                 AND C.ADMPV_COD_TPOCL = V_TIP_CLIE
                 AND SC.ADMPC_ESTPTO_CC = 'A';

                 IF V_SALDO_CC IS NULL THEN
                    V_SALDO_CC := 0;
                 END IF;
                 IF V_SALDO_IB IS NULL THEN
                    V_SALDO_IB := 0;
                 END IF;
             EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                  V_SALDO_IB := 0;
                  V_SALDO_CC := 0;
             END;
        ELSE
          IF (K_TIP_CLI = '2' AND (V_TIP_CLIE = '1' OR V_TIP_CLIE = '2')) OR
             (K_TIP_CLI = '1' AND (V_TIP_CLIE = '1' OR V_TIP_CLIE = '2')) THEN

              BEGIN
                   SELECT SUM(NVL(SC.ADMPN_SALDO_CC, 0)),SUM(CASE WHEN NVL(SC.ADMPC_ESTPTO_IB, 0) = 'A' THEN
                                                         NVL(SC.ADMPN_SALDO_IB, 0)
                                                         ELSE
                                                             0
                                                         END)
                   INTO V_SALDO_IB,V_SALDO_CC
                   FROM ADMPT_CLIENTE C INNER JOIN ADMPT_SALDOS_CLIENTE SC
                   ON C.ADMPV_COD_CLI = SC.ADMPV_COD_CLI
                   WHERE (C.ADMPV_TIPO_DOC = V_TIP_DOC AND C.ADMPV_NUM_DOC = V_NUM_DOC)
                   AND C.ADMPC_ESTADO = 'A'
                   AND (C.ADMPV_COD_TPOCL = 1 OR C.ADMPV_COD_TPOCL = 2)
                   AND SC.ADMPC_ESTPTO_CC = 'A';

                   IF V_SALDO_CC IS NULL THEN
                      V_SALDO_CC := 0;
                   END IF;
                   IF V_SALDO_IB IS NULL THEN
                      V_SALDO_IB := 0;
                   END IF;
               EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                      V_SALDO_IB := 0;
                      V_SALDO_CC := 0;
               END;
          ELSE
            RAISE no_parametros;
          END IF;
        END IF;
      END;

    ELSE
      /* la consulta se realiza por número de documento: Podria ser clientes IB o CLARO CLUB */
      IF (K_TIPO_DOC IS NOT NULL AND K_NUM_DOC IS NOT NULL) AND
         K_TIP_CLI IS NOT NULL THEN
        BEGIN
          -- Busca si el cliente es CC
          SELECT COUNT(*)
            INTO nro_registrosCC
            FROM admpt_cliente
           WHERE admpv_tipo_doc = K_TIPO_DOC
             AND admpv_num_doc = K_NUM_DOC
             AND admpc_estado = 'A'
             AND (admpv_cod_tpocl = K_TIP_CLI OR
                 (K_TIP_CLI = '1' AND
                 (admpv_cod_tpocl = '2' OR admpv_cod_tpocl = '1')) OR
                 (K_TIP_CLI = '2' AND
                 (admpv_cod_tpocl = '2' OR admpv_cod_tpocl = '1')));
          -- Busca si el cliente es IB
          SELECT COUNT(*)
            INTO nro_registrosIB
            FROM admpt_clienteib
           WHERE admpv_tipo_doc = K_TIPO_DOC
             AND admpv_num_doc = K_NUM_DOC
             AND admpc_estado <> 'B';

          IF nro_registrosCC = 0 AND nro_registrosIB = 0 THEN
            RAISE NO_PARAMETROS;
          END IF;

          IF (nro_registrosCC > 0 AND nro_registrosIB > 0) OR
             (nro_registrosCC > 0 AND nro_registrosIB = 0) THEN
            --SI cliente claro club. NO/SI, es cliente IB
            IF (K_TIP_CLI = '3' OR K_TIP_CLI = '4' OR K_TIP_CLI = '8') THEN
              BEGIN
                   SELECT SUM(NVL(SC.ADMPN_SALDO_CC, 0)),SUM(CASE WHEN NVL(SC.ADMPC_ESTPTO_IB, 0) = 'A' THEN
                                                         NVL(SC.ADMPN_SALDO_IB, 0)
                                                         ELSE
                                                          0
                                                         END)
                   INTO V_SALDO_IB,V_SALDO_CC
                   FROM ADMPT_CLIENTE C INNER JOIN ADMPT_SALDOS_CLIENTE SC
                   ON C.ADMPV_COD_CLI = SC.ADMPV_COD_CLI
                   WHERE (C.ADMPV_TIPO_DOC = K_TIPO_DOC AND C.ADMPV_NUM_DOC = K_NUM_DOC)
                   AND C.ADMPC_ESTADO = 'A'
                   AND C.ADMPV_COD_TPOCL = K_TIP_CLI
                   AND SC.ADMPC_ESTPTO_CC = 'A';

                   IF V_SALDO_CC IS NULL THEN
                      V_SALDO_CC := 0;
                   END IF;
                   IF V_SALDO_IB IS NULL THEN
                      V_SALDO_IB := 0;
                   END IF;
                EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                      V_SALDO_IB := 0;
                      V_SALDO_CC := 0;
                END;
            ELSE
              IF (K_TIP_CLI = '2' OR K_TIP_CLI = '1') THEN
                BEGIN
                     SELECT SUM(NVL(SC.ADMPN_SALDO_CC, 0)),SUM(CASE WHEN NVL(SC.ADMPC_ESTPTO_IB, 0) = 'A' THEN
                                                           NVL(SC.ADMPN_SALDO_IB, 0)
                                                           ELSE
                                                            0
                                                           END)
                     INTO V_SALDO_IB,V_SALDO_CC
                     FROM ADMPT_CLIENTE C INNER JOIN ADMPT_SALDOS_CLIENTE SC
                     ON C.ADMPV_COD_CLI = SC.ADMPV_COD_CLI
                     WHERE (C.ADMPV_TIPO_DOC = K_TIPO_DOC AND C.ADMPV_NUM_DOC = K_NUM_DOC)
                     AND C.ADMPC_ESTADO = 'A'
                     AND (C.ADMPV_COD_TPOCL = 1 OR C.ADMPV_COD_TPOCL = 2)
                     AND SC.ADMPC_ESTPTO_CC = 'A';

                     IF V_SALDO_CC IS NULL THEN
                        V_SALDO_CC := 0;
                     END IF;
                     IF V_SALDO_IB IS NULL THEN
                        V_SALDO_IB := 0;
                     END IF;
                EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                      V_SALDO_IB := 0;
                      V_SALDO_CC := 0;
                END;
              ELSE
                RAISE no_parametros;
              END IF;
            END IF;
          ELSE
            -- NO, cliente claro club. SI, cliente IB if (nro_registrosCC=0 and nro_registrosIB>0) then
            IF K_TIP_CLI = 5 THEN
              V_SALDO_CC := 0;
              SELECT admpn_cod_cli_ib
                INTO V_COD_CLI_IB
                FROM admpt_clienteib
               WHERE admpv_tipo_doc = K_TIPO_DOC
                 AND admpv_num_doc = K_NUM_DOC
                 AND admpc_estado <> 'B';
              SELECT NVL(admpn_saldo_ib, 0)
                INTO V_SALDO_IB
                FROM admpt_saldos_cliente
               WHERE admpn_cod_cli_ib = V_COD_CLI_IB;
            ELSE
              RAISE NO_PARAMETROS;
            END IF;
          END IF;
        END;
      ELSE
        RAISE NO_PARAMETROS;
      END IF;
    END IF;

    K_SALDO := V_SALDO_CC + V_SALDO_IB;

    /* *************************************************************************** */
  EXCEPTION
    WHEN NO_PARAMETROS THEN
      K_CODERROR := 41;
      -- K_MSJERROR:='Ingresó datos incorrectos o datos insuficientes para realizar la consulta';

    WHEN NO_DATA_FOUND THEN
      IF V_TIP_DOC IS NULL OR V_NUM_DOC IS NULL OR V_TIP_CLIE IS NULL THEN
        K_CODERROR := 40;
        --K_MSJERROR:='No se encontró información para los datos ingresados';
      END IF;

    WHEN OTHERS THEN
      K_CODERROR := SQLCODE;
      --  K_MSJERROR:=SUBSTR( SQLERRM ,1,250);

  END ADMPSI_ES_CLIENTE;

PROCEDURE ADMPSI_ES_CLIENTE_CJE(K_COD_CLIENTE IN VARCHAR2,
                                    K_TIPO_DOC    IN VARCHAR2,
                                    K_NUM_DOC     IN VARCHAR2,
                                    K_TIP_CLI     IN VARCHAR2,
                                    K_TIPCANJE    IN NUMBER,
                                    K_TIPPRECANJE IN NUMBER,
                                    K_SALDO       OUT NUMBER,
                                    K_CODERROR    OUT NUMBER) IS

      --****************************************************************
      -- Nombre SP           :  ADMPSI_ES_CLIENTE
      -- Propósito           :  Devuelve el saldo del cliente y el indicador de error
      -- Input               :  K_COD_CLIENTE Codigo de Cliente
      --                        K_TIPO_DOC Tipo de Documento
      --                        K_NUM_DOC Numero de Documento
      --                        K_TIPOLINEA Tipo de Linea
      --
      -- Output              :  K_SALDO
      --                        K_CODERROR
      -- Creado por          :  (Venkizmet) Rossana Janampa
      -- Fec Creación        :  27/09/2010
      -- Fec Actualización   :  08/04/2013
      --****************************************************************
      -- Variables
      V_TIP_DOC  admpt_cliente.admpv_tipo_doc%TYPE;
      V_NUM_DOC  admpt_cliente.admpv_num_doc%TYPE;
      V_TIP_CLIE admpt_cliente.admpv_cod_tpocl%TYPE;
      V_SALDO_IB NUMBER := 0;
      V_SALDO_CC NUMBER := 0;
      V_SALDO_B  NUMBER := 0;
      NO_PARAMETROS EXCEPTION;
      nro_registrosCC NUMBER := 0;
      nro_registrosIB NUMBER := 0;
      --K_MSJERROR         VARCHAR2(400);
      V_COD_CLI_IB NUMBER;

    BEGIN

      IF K_COD_CLIENTE IS NOT NULL AND K_TIP_CLI IS NOT NULL THEN
        /* La consulta se realiza por cuenta de cliente : SOLO PARA CLIENTES CLARO CLUB */
        BEGIN
          -- Con el código de cliente devuelve el tipo de documento y el numero de documento, debe devolver 0 ó 1 registro
          SELECT NVL(admpv_tipo_doc, 0),
                 NVL(admpv_num_doc, 0),
                 NVL(admpv_cod_tpocl, 0)
            INTO V_TIP_DOC, V_NUM_DOC, V_TIP_CLIE
            FROM PCLUB.admpt_cliente
           WHERE admpv_cod_cli = K_COD_CLIENTE
             AND admpc_estado = 'A';

          IF (V_TIP_CLIE = '3' OR V_TIP_CLIE = '4' OR V_TIP_CLIE = '8') AND
             V_TIP_CLIE = K_TIP_CLI THEN
            IF V_TIP_CLIE = '3' THEN
              IF K_TIPCANJE = 1 THEN
                BEGIN
                  SELECT SUM(NVL(SC.ADMPN_SALDO_CC, 0)),
                         SUM(CASE
                               WHEN NVL(SC.ADMPC_ESTPTO_IB, 0) = 'A' THEN
                                NVL(SC.ADMPN_SALDO_IB, 0)
                               ELSE
                                0
                             END)
                    INTO V_SALDO_IB, V_SALDO_CC
                    FROM PCLUB.ADMPT_CLIENTE C
                   INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTE SC
                      ON C.ADMPV_COD_CLI = SC.ADMPV_COD_CLI
                   WHERE (C.ADMPV_TIPO_DOC = V_TIP_DOC AND
                         C.ADMPV_NUM_DOC = V_NUM_DOC)
                     AND C.ADMPC_ESTADO = 'A'
                     AND C.ADMPV_COD_TPOCL = V_TIP_CLIE
                     AND SC.ADMPC_ESTPTO_CC = 'A';

                  SELECT NVL(SUM(SB.ADMPN_SALDO), 0)
                    INTO V_SALDO_B
                    FROM PCLUB.ADMPT_SALDOS_BONO_CLIENTE SB
                   WHERE SB.ADMPV_COD_CLI = K_COD_CLIENTE
                     AND SB.ADMPN_GRUPO = K_TIPPRECANJE;

                  IF V_SALDO_CC IS NULL THEN
                    V_SALDO_CC := 0;
                  END IF;
                  IF V_SALDO_IB IS NULL THEN
                    V_SALDO_IB := 0;
                  END IF;
                  IF V_SALDO_B IS NULL THEN
                    V_SALDO_B := 0;
                  END IF;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    V_SALDO_IB := 0;
                    V_SALDO_CC := 0;
                    V_SALDO_B  := 0;
                END;
              ELSE
                BEGIN
                  SELECT SUM(NVL(SC.ADMPN_SALDO_CC, 0)),
                         SUM(CASE
                               WHEN NVL(SC.ADMPC_ESTPTO_IB, 0) = 'A' THEN
                                NVL(SC.ADMPN_SALDO_IB, 0)
                               ELSE
                                0
                             END)
                    INTO V_SALDO_IB, V_SALDO_CC
                    FROM PCLUB.ADMPT_CLIENTE C
                   INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTE SC
                      ON C.ADMPV_COD_CLI = SC.ADMPV_COD_CLI
                   WHERE (C.ADMPV_TIPO_DOC = V_TIP_DOC AND
                         C.ADMPV_NUM_DOC = V_NUM_DOC)
                     AND C.ADMPC_ESTADO = 'A'
                     AND C.ADMPV_COD_TPOCL = V_TIP_CLIE
                     AND SC.ADMPC_ESTPTO_CC = 'A';

                  IF V_SALDO_CC IS NULL THEN
                    V_SALDO_CC := 0;
                  END IF;
                  IF V_SALDO_IB IS NULL THEN
                    V_SALDO_IB := 0;
                  END IF;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    V_SALDO_IB := 0;
                    V_SALDO_CC := 0;
                END;
              END IF;
            ELSE
              BEGIN
                SELECT SUM(NVL(SC.ADMPN_SALDO_CC, 0)),
                       SUM(CASE
                             WHEN NVL(SC.ADMPC_ESTPTO_IB, 0) = 'A' THEN
                              NVL(SC.ADMPN_SALDO_IB, 0)
                             ELSE
                              0
                           END)
                  INTO V_SALDO_IB, V_SALDO_CC
                  FROM PCLUB.ADMPT_CLIENTE C
                 INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTE SC
                    ON C.ADMPV_COD_CLI = SC.ADMPV_COD_CLI
                 WHERE (C.ADMPV_TIPO_DOC = V_TIP_DOC AND
                       C.ADMPV_NUM_DOC = V_NUM_DOC)
                   AND C.ADMPC_ESTADO = 'A'
                   AND C.ADMPV_COD_TPOCL = V_TIP_CLIE
                   AND SC.ADMPC_ESTPTO_CC = 'A';

                IF V_SALDO_CC IS NULL THEN
                  V_SALDO_CC := 0;
                END IF;
                IF V_SALDO_IB IS NULL THEN
                  V_SALDO_IB := 0;
                END IF;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  V_SALDO_IB := 0;
                  V_SALDO_CC := 0;
              END;
            END IF;

          ELSE
            IF (K_TIP_CLI = '2' AND (V_TIP_CLIE = '1' OR V_TIP_CLIE = '2')) OR
               (K_TIP_CLI = '1' AND (V_TIP_CLIE = '1' OR V_TIP_CLIE = '2')) THEN

              BEGIN
                SELECT SUM(NVL(SC.ADMPN_SALDO_CC, 0)),
                       SUM(CASE
                             WHEN NVL(SC.ADMPC_ESTPTO_IB, 0) = 'A' THEN
                              NVL(SC.ADMPN_SALDO_IB, 0)
                             ELSE
                              0
                           END)
                  INTO V_SALDO_IB, V_SALDO_CC
                  FROM PCLUB.ADMPT_CLIENTE C
                 INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTE SC
                    ON C.ADMPV_COD_CLI = SC.ADMPV_COD_CLI
                 WHERE (C.ADMPV_TIPO_DOC = V_TIP_DOC AND
                       C.ADMPV_NUM_DOC = V_NUM_DOC)
                   AND C.ADMPC_ESTADO = 'A'
                   AND (C.ADMPV_COD_TPOCL = 1 OR C.ADMPV_COD_TPOCL = 2)
                   AND SC.ADMPC_ESTPTO_CC = 'A';

                IF V_SALDO_CC IS NULL THEN
                  V_SALDO_CC := 0;
                END IF;
                IF V_SALDO_IB IS NULL THEN
                  V_SALDO_IB := 0;
                END IF;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  V_SALDO_IB := 0;
                  V_SALDO_CC := 0;
              END;
            ELSE
              RAISE no_parametros;
            END IF;
          END IF;
        END;

      ELSE
        /* la consulta se realiza por número de documento: Podria ser clientes IB o CLARO CLUB */
        IF (K_TIPO_DOC IS NOT NULL AND K_NUM_DOC IS NOT NULL) AND
           K_TIP_CLI IS NOT NULL THEN
          BEGIN
            -- Busca si el cliente es CC
            SELECT COUNT(1)
              INTO nro_registrosCC
              FROM PCLUB.admpt_cliente
             WHERE admpv_tipo_doc = K_TIPO_DOC
               AND admpv_num_doc = K_NUM_DOC
               AND admpc_estado = 'A'
               AND (admpv_cod_tpocl = K_TIP_CLI OR
                   (K_TIP_CLI = '1' AND
                   (admpv_cod_tpocl = '2' OR admpv_cod_tpocl = '1')) OR
                   (K_TIP_CLI = '2' AND
                   (admpv_cod_tpocl = '2' OR admpv_cod_tpocl = '1')));
            -- Busca si el cliente es IB
            SELECT COUNT(1)
              INTO nro_registrosIB
              FROM PCLUB.admpt_clienteib
             WHERE admpv_tipo_doc = K_TIPO_DOC
               AND admpv_num_doc = K_NUM_DOC
               AND admpc_estado <> 'B';

            IF nro_registrosCC = 0 AND nro_registrosIB = 0 THEN
              RAISE NO_PARAMETROS;
            END IF;

            IF (nro_registrosCC > 0 AND nro_registrosIB > 0) OR
               (nro_registrosCC > 0 AND nro_registrosIB = 0) THEN
              --SI cliente claro club. NO/SI, es cliente IB
              IF (K_TIP_CLI = '3' OR K_TIP_CLI = '4' OR K_TIP_CLI = '8') THEN
                BEGIN
                  SELECT SUM(NVL(SC.ADMPN_SALDO_CC, 0)),
                         SUM(CASE
                               WHEN NVL(SC.ADMPC_ESTPTO_IB, 0) = 'A' THEN
                                NVL(SC.ADMPN_SALDO_IB, 0)
                               ELSE
                                0
                             END)
                    INTO V_SALDO_IB, V_SALDO_CC
                    FROM PCLUB.ADMPT_CLIENTE C
                   INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTE SC
                      ON C.ADMPV_COD_CLI = SC.ADMPV_COD_CLI
                   WHERE (C.ADMPV_TIPO_DOC = K_TIPO_DOC AND
                         C.ADMPV_NUM_DOC = K_NUM_DOC)
                     AND C.ADMPC_ESTADO = 'A'
                     AND C.ADMPV_COD_TPOCL = K_TIP_CLI
                     AND SC.ADMPC_ESTPTO_CC = 'A';

                  IF V_SALDO_CC IS NULL THEN
                    V_SALDO_CC := 0;
                  END IF;
                  IF V_SALDO_IB IS NULL THEN
                    V_SALDO_IB := 0;
                  END IF;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    V_SALDO_IB := 0;
                    V_SALDO_CC := 0;
                END;
              ELSE
                IF (K_TIP_CLI = '2' OR K_TIP_CLI = '1') THEN
                  BEGIN
                    SELECT SUM(NVL(SC.ADMPN_SALDO_CC, 0)),
                           SUM(CASE
                                 WHEN NVL(SC.ADMPC_ESTPTO_IB, 0) = 'A' THEN
                                  NVL(SC.ADMPN_SALDO_IB, 0)
                                 ELSE
                                  0
                               END)
                      INTO V_SALDO_IB, V_SALDO_CC
                      FROM PCLUB.ADMPT_CLIENTE C
                     INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTE SC
                        ON C.ADMPV_COD_CLI = SC.ADMPV_COD_CLI
                     WHERE (C.ADMPV_TIPO_DOC = K_TIPO_DOC AND
                           C.ADMPV_NUM_DOC = K_NUM_DOC)
                       AND C.ADMPC_ESTADO = 'A'
                       AND (C.ADMPV_COD_TPOCL = 1 OR C.ADMPV_COD_TPOCL = 2)
                       AND SC.ADMPC_ESTPTO_CC = 'A';

                    IF V_SALDO_CC IS NULL THEN
                      V_SALDO_CC := 0;
                    END IF;
                    IF V_SALDO_IB IS NULL THEN
                      V_SALDO_IB := 0;
                    END IF;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      V_SALDO_IB := 0;
                      V_SALDO_CC := 0;
                  END;
                ELSE
                  RAISE no_parametros;
                END IF;
              END IF;
            ELSE
              -- NO, cliente claro club. SI, cliente IB if (nro_registrosCC=0 and nro_registrosIB>0) then
              IF K_TIP_CLI = 5 THEN
                V_SALDO_CC := 0;
                SELECT admpn_cod_cli_ib
                  INTO V_COD_CLI_IB
                  FROM PCLUB.admpt_clienteib
                 WHERE admpv_tipo_doc = K_TIPO_DOC
                   AND admpv_num_doc = K_NUM_DOC
                   AND admpc_estado <> 'B';
                SELECT NVL(admpn_saldo_ib, 0)
                  INTO V_SALDO_IB
                  FROM PCLUB.admpt_saldos_cliente
                 WHERE admpn_cod_cli_ib = V_COD_CLI_IB;
              ELSE
                RAISE NO_PARAMETROS;
              END IF;
            END IF;
          END;
        ELSE
          RAISE NO_PARAMETROS;
        END IF;
      END IF;

      K_SALDO := V_SALDO_CC + V_SALDO_IB + V_SALDO_B;

      /* *************************************************************************** */
    EXCEPTION
      WHEN NO_PARAMETROS THEN
        K_CODERROR := 41;
        -- K_MSJERROR:='Ingresó datos incorrectos o datos insuficientes para realizar la consulta';

      WHEN NO_DATA_FOUND THEN
        IF V_TIP_DOC IS NULL OR V_NUM_DOC IS NULL OR V_TIP_CLIE IS NULL THEN
          K_CODERROR := 40;
          --K_MSJERROR:='No se encontró información para los datos ingresados';
        END IF;

      WHEN OTHERS THEN
        K_CODERROR := SQLCODE;
        --  K_MSJERROR:=SUBSTR( SQLERRM ,1,250);

    END ADMPSI_ES_CLIENTE_CJE;

  PROCEDURE ADMPSI_DESC_PUNTOS(K_ID_CANJE    NUMBER,
                               K_SEC         NUMBER,
                               K_PUNTOS      NUMBER,
                               K_COD_CLIENTE IN VARCHAR2,
                               K_TIPO_DOC    IN VARCHAR2,
                               K_NUM_DOC     IN VARCHAR2,
                               K_TIP_CLI     IN VARCHAR2,
                               K_CODERROR    OUT NUMBER,
                               K_MSJERROR    OUT VARCHAR2) IS

    --****************************************************************
    -- Nombre SP           :  ADMPSI_DESC_PUNTOS
    -- Propósito           :  Descuenta puntos para Canje segun FIFO y el requerimento definido
    -- Input               :  K_ID_CANJE Identificador del canje
    --                        K_SEC Secuencial del Detalle
    --                        K_PUNTOS Total de Puntos a descontar
    --                        K_COD_CLIENTE Codigo de Cliente
    --                        K_TIPO_DOC Tipo de Documento
    --                        K_NUM_DOC Numero de Documento
    --                        K_TIP_CLI Tipo de Cliente
    --
    -- Output              :  K_CODERROR
    --                        K_MSJERROR
    -- Creado por          :  (Venkizmet) Rossana Janampa
    -- Fec Creación        :  27/09/2010
    -- Fec Actualización   :  08/04/2013
    --****************************************************************

    V_PUNTOS_REQUERIDOS NUMBER := 0;

    LK_TPO_PUNTO  CHAR(1);
    LK_ID_KARDEX  NUMBER;
    LK_SLD_PUNTOS NUMBER;
    LK_COD_CLI    VARCHAR2(40);
    LK_COD_CLIIB  NUMBER;
    LK_TPO_PREMIO NUMBER;

    /* Cursor 1 */
    CURSOR LISTA_KARDEX_1 IS
      SELECT ka.admpc_tpo_punto,
             ka.admpn_id_kardex,
             ka.admpn_sld_punto,
             ka.admpv_cod_cli,
             admpn_cod_cli_ib,
             ka.admpn_tip_premio
        FROM admpt_kardex ka
       WHERE ka.admpc_estado = 'A'
         AND ka.admpc_tpo_oper = 'E'
         AND ka.admpn_sld_punto > 0
         AND ka.admpd_fec_trans <=
             TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') --'17/09/2010'
         AND (KA.ADMPN_TIP_PREMIO IS NULL OR KA.ADMPN_TIP_PREMIO=0)
         AND ka.admpv_cod_cli IN
             (SELECT CC2.ADMPV_COD_CLI
                FROM admpt_cliente CC2,
                     (SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
                        FROM admpt_cliente
                       WHERE ADMPV_COD_CLI = K_COD_CLIENTE
                         AND ADMPV_COD_TPOCL = K_TIP_CLI
                         AND admpc_estado = 'A') CC1 /*Obtiene el numero de doc y su tipo*/
               WHERE CC2.ADMPV_TIPO_DOC = CC1.ADMPV_TIPO_DOC
                 AND CC2.ADMPV_NUM_DOC = CC1.ADMPV_NUM_DOC
                 AND CC2.ADMPV_COD_TPOCL = K_TIP_CLI
                 AND CC2.admpc_estado = 'A') /*Selecciona todos los codigos que cumplen con la condicion*/
                 ORDER BY DECODE(admpc_tpo_punto, 'B', 1, 2), admpn_id_kardex ASC;

    /* Cursor 2 */

    CURSOR LISTA_KARDEX_2 IS
      SELECT ka.admpc_tpo_punto,
             ka.admpn_id_kardex,
             ka.admpn_sld_punto,
             ka.admpv_cod_cli,
             admpn_cod_cli_ib
        FROM admpt_kardex ka
       WHERE ka.admpc_estado = 'A'
         AND ka.admpc_tpo_oper = 'E'
         AND ka.admpn_sld_punto > 0
         AND ka.admpd_fec_trans <=
             TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') --'17/09/2010'
         AND ka.admpv_cod_cli IN
             (SELECT CC2.ADMPV_COD_CLI
                FROM admpt_cliente CC2
               WHERE CC2.ADMPV_TIPO_DOC = K_TIPO_DOC
                 AND CC2.ADMPV_NUM_DOC = K_NUM_DOC
                 AND CC2.ADMPV_COD_TPOCL = K_TIP_CLI
                  OR CC2.ADMPV_COD_TPOCL IN ('1', '2')
                 AND CC2.admpc_estado = 'A') /*Selecciona todos los codigos que cumplen con la condicion*/
       ORDER BY DECODE(admpc_tpo_punto, 'I', 1, 'L', 2, 'C', 3),
                admpn_id_kardex ASC;

    /* Cursor 3 */
    CURSOR LISTA_KARDEX_3 IS
      SELECT ka.admpc_tpo_punto,
             ka.admpn_id_kardex,
             ka.admpn_sld_punto,
             ka.admpv_cod_cli,
             admpn_cod_cli_ib
        FROM admpt_kardex ka
       WHERE ka.admpc_estado = 'A'
         AND ka.admpc_tpo_oper = 'E'
         AND ka.admpn_sld_punto > 0
         AND ka.admpd_fec_trans <=
             TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') --'17/09/2010'
         AND ka.admpv_cod_cli IN
             (SELECT CC2.ADMPV_COD_CLI
                FROM admpt_cliente CC2,
                     (SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
                        FROM admpt_cliente
                       WHERE ADMPV_COD_CLI = K_COD_CLIENTE
                         AND (ADMPV_COD_TPOCL = K_TIP_CLI OR
                             ADMPV_COD_TPOCL IN ('1', '2'))
                         AND admpc_estado = 'A') CC1 /*Obtiene el numero de doc y su tipo*/
               WHERE CC2.ADMPV_TIPO_DOC = CC1.ADMPV_TIPO_DOC
                 AND CC2.ADMPV_NUM_DOC = CC1.ADMPV_NUM_DOC
                 AND (CC2.ADMPV_COD_TPOCL = K_TIP_CLI OR
                     ADMPV_COD_TPOCL IN ('1', '2'))
                 AND CC2.admpc_estado = 'A') /*Selecciona todos los codigos que cumplen con la condicion*/
       ORDER BY DECODE(admpc_tpo_punto, 'I', 1, 'L', 2, 'C', 3),
                admpn_id_kardex ASC;

  BEGIN
    /*
    Los puntos IB son los q se consumiran primero Tipo de punto 'I'
    los puntos Loyalty 'L' y ClaroClub 'C', se consumiran en ese orden
    */
    K_CODERROR := 0;
    K_MSJERROR := '';

    V_PUNTOS_REQUERIDOS := K_PUNTOS;

    -- Comienza el Canje, dato de entrada el codigo de cliente
    IF K_COD_CLIENTE IS NOT NULL THEN
      IF K_TIP_CLI = '3' OR K_TIP_CLI = '4' OR K_TIP_CLI = '8'  THEN
        -- Clientes Prepago o B2E
        OPEN LISTA_KARDEX_1;
        FETCH LISTA_KARDEX_1
          INTO LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB, LK_TPO_PREMIO;
        WHILE LISTA_KARDEX_1%FOUND AND V_PUNTOS_REQUERIDOS > 0 LOOP
          IF LK_SLD_PUNTOS <= V_PUNTOS_REQUERIDOS THEN

            -- Actualiza Kardex
            UPDATE admpt_kardex
               SET admpn_sld_punto = 0, admpc_estado = 'C'
             WHERE admpn_id_kardex = LK_ID_KARDEX;

            -- Inserta Canje_kardex
            INSERT INTO PCLUB.admpt_canjedt_kardex
              (admpv_id_canje,
               admpn_id_kardex,
               admpv_id_canjesec,
               admpn_puntos)
            VALUES
              (K_ID_CANJE, LK_ID_KARDEX, K_SEC, LK_SLD_PUNTOS);

            -- Actualiza Saldos_cliente
            IF LK_TPO_PUNTO = 'C' OR LK_TPO_PUNTO = 'L' THEN
              /* Punto Claro Club */
               UPDATE admpt_saldos_cliente
               SET admpn_saldo_cc = -LK_SLD_PUNTOS + NVL(admpn_saldo_cc, 0)
               WHERE admpv_cod_cli = LK_COD_CLI;
            ELSIF LK_TPO_PUNTO = 'B' THEN
               IF LK_TPO_PREMIO = 0 THEN
                    /* Puntos Bonos para cualquier canje*/
                    UPDATE PCLUB.admpt_saldos_cliente
                     SET admpn_saldo_cc = -LK_SLD_PUNTOS +
                                          NVL(admpn_saldo_cc, 0)
                   WHERE admpv_cod_cli = LK_COD_CLI;
               END IF;
            ELSE
              /* Punto IB*/
              IF LK_TPO_PUNTO = 'I' THEN
                 UPDATE admpt_saldos_cliente
                 SET admpn_saldo_ib = -LK_SLD_PUNTOS + NVL(admpn_saldo_ib, 0)
                 WHERE admpn_cod_cli_ib = LK_COD_CLIIB;
              END IF;
            END IF;

            V_PUNTOS_REQUERIDOS := V_PUNTOS_REQUERIDOS - LK_SLD_PUNTOS;

          ELSE
            IF LK_SLD_PUNTOS > V_PUNTOS_REQUERIDOS THEN

              -- Actualiza Kardex
              UPDATE admpt_kardex
                 SET admpn_sld_punto = LK_SLD_PUNTOS - V_PUNTOS_REQUERIDOS
               WHERE admpn_id_kardex = LK_ID_KARDEX;

              -- Inserta Canje_kardex
              INSERT INTO PCLUB.admpt_canjedt_kardex
                (admpv_id_canje,
                 admpn_id_kardex,
                 admpv_id_canjesec,
                 admpn_puntos)
              VALUES
                (K_ID_CANJE, LK_ID_KARDEX, K_SEC, V_PUNTOS_REQUERIDOS);

              -- Actualiza Saldos_cliente
              IF LK_TPO_PUNTO = 'C' OR LK_TPO_PUNTO = 'L' THEN
                /* Punto Claro Club */
                 UPDATE admpt_saldos_cliente
                 SET admpn_saldo_cc = -V_PUNTOS_REQUERIDOS + NVL(admpn_saldo_cc, 0)
                 WHERE admpv_cod_cli = LK_COD_CLI;
              ELSIF LK_TPO_PUNTO = 'B' THEN
                  IF LK_TPO_PREMIO = 0 THEN
                    /* Puntos Bonos para cualquier canje*/
                    UPDATE PCLUB.admpt_saldos_cliente
                       SET admpn_saldo_cc = -V_PUNTOS_REQUERIDOS +
                                            NVL(admpn_saldo_cc, 0)
                     WHERE admpv_cod_cli = LK_COD_CLI;
                  END IF;
              ELSE
                /* Punto IB*/
                IF LK_TPO_PUNTO = 'I' THEN
                    UPDATE admpt_saldos_cliente
                    SET admpn_saldo_ib = -V_PUNTOS_REQUERIDOS + NVL(admpn_saldo_ib, 0)
                    WHERE admpn_cod_cli_ib = LK_COD_CLIIB;
                END IF;
              END IF;
              V_PUNTOS_REQUERIDOS := 0;

            END IF;
          END IF;
          FETCH LISTA_KARDEX_1
            INTO LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB, LK_TPO_PREMIO;
        END LOOP;
        CLOSE LISTA_KARDEX_1;
      ELSE
        IF K_TIP_CLI = '1' OR K_TIP_CLI = '2' THEN
          OPEN LISTA_KARDEX_3;
          FETCH LISTA_KARDEX_3
            INTO LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB;
          WHILE LISTA_KARDEX_3%FOUND AND V_PUNTOS_REQUERIDOS > 0 LOOP
            IF LK_SLD_PUNTOS <= V_PUNTOS_REQUERIDOS THEN
              -- Actualiza Kardex
              UPDATE admpt_kardex
                 SET admpn_sld_punto = 0, admpc_estado = 'C'
               WHERE admpn_id_kardex = LK_ID_KARDEX;

              -- Inserta Canje_kardex
              INSERT INTO PCLUB.admpt_canjedt_kardex
                (admpv_id_canje,
                 admpn_id_kardex,
                 admpv_id_canjesec,
                 admpn_puntos)
              VALUES
                (K_ID_CANJE, LK_ID_KARDEX, K_SEC, LK_SLD_PUNTOS);

              -- Actualiza Saldos_cliente
              IF LK_TPO_PUNTO = 'C' OR LK_TPO_PUNTO = 'L' THEN
                /* Punto Claro Club */
                 UPDATE admpt_saldos_cliente
                 SET admpn_saldo_cc = -LK_SLD_PUNTOS + NVL(admpn_saldo_cc, 0)
                 WHERE admpv_cod_cli = LK_COD_CLI;
              ELSE
                /* Punto IB*/
                IF LK_TPO_PUNTO = 'I' THEN
                   UPDATE admpt_saldos_cliente
                   SET admpn_saldo_ib = -LK_SLD_PUNTOS + NVL(admpn_saldo_ib, 0)
                   WHERE admpn_cod_cli_ib = LK_COD_CLIIB;
                END IF;
              END IF;
              V_PUNTOS_REQUERIDOS := V_PUNTOS_REQUERIDOS - LK_SLD_PUNTOS;

            ELSE
              IF LK_SLD_PUNTOS > V_PUNTOS_REQUERIDOS THEN

                UPDATE admpt_kardex
                   SET admpn_sld_punto = LK_SLD_PUNTOS - V_PUNTOS_REQUERIDOS
                 WHERE admpn_id_kardex = LK_ID_KARDEX;
                -- Inserta Canje_kardex
                INSERT INTO PCLUB.admpt_canjedt_kardex
                  (admpv_id_canje,
                   admpn_id_kardex,
                   admpv_id_canjesec,
                   admpn_puntos)
                VALUES
                  (K_ID_CANJE, LK_ID_KARDEX, K_SEC, V_PUNTOS_REQUERIDOS);

                -- Actualiza Saldos_cliente
                IF LK_TPO_PUNTO = 'C' OR LK_TPO_PUNTO = 'L' THEN
                  /* Punto Claro Club */
                   UPDATE admpt_saldos_cliente
                   SET admpn_saldo_cc = -V_PUNTOS_REQUERIDOS + NVL(admpn_saldo_cc, 0)
                   WHERE admpv_cod_cli = LK_COD_CLI;
                ELSE
                  /* Punto IB*/
                  IF LK_TPO_PUNTO = 'I' THEN
                     UPDATE admpt_saldos_cliente
                     SET admpn_saldo_ib = -V_PUNTOS_REQUERIDOS + NVL(admpn_saldo_ib, 0)
                     WHERE admpn_cod_cli_ib = LK_COD_CLIIB;
                  END IF;
                END IF;
                V_PUNTOS_REQUERIDOS := 0;
              END IF;
            END IF;
            FETCH LISTA_KARDEX_3
              INTO LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB;
          END LOOP;
          CLOSE LISTA_KARDEX_3;
        ELSE
          IF K_TIP_CLI = '5' THEN
            -- CLIENTES IB que no tienen cuenta en CLARO CLUB
            NULL;
            -- Aun no definido
          END IF;
        END IF;
      END IF;
    ELSE
      -- Comienza el Canje, dato de entrada el tipo de doc y el num de doc
      IF K_COD_CLIENTE IS NULL AND K_TIPO_DOC IS NOT NULL AND
         K_NUM_DOC IS NOT NULL THEN
        OPEN LISTA_KARDEX_2;
        FETCH LISTA_KARDEX_2
          INTO LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB;
        WHILE LISTA_KARDEX_2%FOUND AND V_PUNTOS_REQUERIDOS > 0 LOOP
          IF LK_SLD_PUNTOS <= V_PUNTOS_REQUERIDOS THEN
            -- Actualiza Kardex
            UPDATE admpt_kardex
               SET admpn_sld_punto = 0, admpc_estado = 'C'
             WHERE admpn_id_kardex = LK_ID_KARDEX;
            -- Inserta Canje_kardex
            INSERT INTO PCLUB.admpt_canjedt_kardex
              (admpv_id_canje,
               admpn_id_kardex,
               admpv_id_canjesec,
               admpn_puntos)
            VALUES
              (K_ID_CANJE, LK_ID_KARDEX, K_SEC, LK_SLD_PUNTOS);

            -- Actualiza Saldos_cliente
            IF LK_TPO_PUNTO = 'C' OR LK_TPO_PUNTO = 'L' THEN
              /* Punto Claro Club */
              UPDATE admpt_saldos_cliente
              SET admpn_saldo_cc = -LK_SLD_PUNTOS + NVL(admpn_saldo_cc, 0)
              WHERE admpv_cod_cli = LK_COD_CLI;
            ELSE
              /* Punto IB*/
              IF LK_TPO_PUNTO = 'I' THEN
                 UPDATE admpt_saldos_cliente
                 SET admpn_saldo_ib = -LK_SLD_PUNTOS + NVL(admpn_saldo_ib, 0)
                 WHERE admpn_cod_cli_ib = LK_COD_CLIIB;
              END IF;
            END IF;
            V_PUNTOS_REQUERIDOS := V_PUNTOS_REQUERIDOS - LK_SLD_PUNTOS;
          ELSE
            IF LK_SLD_PUNTOS > V_PUNTOS_REQUERIDOS THEN

              UPDATE admpt_kardex
                 SET admpn_sld_punto = LK_SLD_PUNTOS - V_PUNTOS_REQUERIDOS
               WHERE admpn_id_kardex = LK_ID_KARDEX;

              -- Inserta Canje_kardex
              INSERT INTO PCLUB.admpt_canjedt_kardex
                (admpv_id_canje,
                 admpn_id_kardex,
                 admpv_id_canjesec,
                 admpn_puntos)
              VALUES
                (K_ID_CANJE, LK_ID_KARDEX, K_SEC, V_PUNTOS_REQUERIDOS);

              -- Actualiza Saldos_cliente
              IF LK_TPO_PUNTO = 'C' OR LK_TPO_PUNTO = 'L' THEN
                /* Punto Claro Club */
                 UPDATE admpt_saldos_cliente
                 SET admpn_saldo_cc = -V_PUNTOS_REQUERIDOS + NVL(admpn_saldo_cc, 0)
                 WHERE admpv_cod_cli = LK_COD_CLI;
              ELSE
                /* Punto IB*/
                IF LK_TPO_PUNTO = 'I' THEN
                   UPDATE admpt_saldos_cliente
                   SET admpn_saldo_ib = -V_PUNTOS_REQUERIDOS + NVL(admpn_saldo_ib, 0)
                   WHERE admpn_cod_cli_ib = LK_COD_CLIIB;
                END IF;
              END IF;
              V_PUNTOS_REQUERIDOS := 0;
            END IF;
          END IF;
          FETCH LISTA_KARDEX_2
            INTO LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB;
        END LOOP;
        CLOSE LISTA_KARDEX_2;

      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR := SQLCODE;
      K_MSJERROR := SUBSTR(SQLERRM, 1, 400);

  END ADMPSI_DESC_PUNTOS;

  PROCEDURE ADMPSI_DESC_PTOS_BONO(K_ID_CANJE    NUMBER,
                                  K_SEC         NUMBER,
                                  K_PUNTOS      NUMBER,
                                  K_COD_CLIENTE IN VARCHAR2,
                                  K_TIPO_DOC    IN VARCHAR2,
                                  K_NUM_DOC     IN VARCHAR2,
                                  K_TIP_CLI     IN VARCHAR2,
                                  K_GRUPO       IN NUMBER,
                                  K_CODERROR    OUT NUMBER,
                                  K_MSJERROR    OUT VARCHAR2) IS

    V_PUNTOS_REQUERIDOS NUMBER := 0;

    LK_TPO_PUNTO  CHAR(1);
    LK_ID_KARDEX  NUMBER;
    LK_SLD_PUNTOS NUMBER;
    LK_COD_CLI    VARCHAR2(40);
    LK_COD_CLIIB  NUMBER;
    LK_TPO_PREMIO NUMBER;

    /* Cursor 1 */
    CURSOR LISTA_KARDEX_1 IS

      SELECT A.admpc_tpo_punto,
             A.admpn_id_kardex,
             A.admpn_sld_punto,
             A.admpv_cod_cli,
             A.admpn_cod_cli_ib,
             A.admpn_tip_premio
        FROM (

              SELECT ka.admpc_tpo_punto,
                      ka.admpn_id_kardex,
                      ka.admpn_sld_punto,
                      ka.admpv_cod_cli,
                      ka.admpn_cod_cli_ib,
                      ka.admpn_tip_premio
              FROM PCLUB.admpt_kardex ka
              WHERE ka.admpc_estado = 'A'
                 and (ka.admpn_tip_premio is null or ka.admpn_tip_premio = 0)
                 AND ka.admpc_tpo_oper = 'E'
                 AND ka.admpn_sld_punto > 0
                 AND ka.admpd_fec_trans <=
                     TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') --'17/09/2010'
                 AND ka.admpv_cod_cli IN
                     (SELECT CC2.ADMPV_COD_CLI
                        FROM PCLUB.admpt_cliente CC2,
                             (SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
                              FROM PCLUB.admpt_cliente
                              WHERE ADMPV_COD_CLI = K_COD_CLIENTE
                                 AND ADMPV_COD_TPOCL = K_TIP_CLI
                                 AND admpc_estado = 'A') CC1 /*Obtiene el numero de doc y su tipo*/
                       WHERE CC2.ADMPV_TIPO_DOC = CC1.ADMPV_TIPO_DOC
                         AND CC2.ADMPV_NUM_DOC = CC1.ADMPV_NUM_DOC
                         AND CC2.ADMPV_COD_TPOCL = K_TIP_CLI
                         AND CC2.admpc_estado = 'A')
              UNION ALL
              SELECT ka.admpc_tpo_punto,
                     ka.admpn_id_kardex,
                     ka.admpn_sld_punto,
                     ka.admpv_cod_cli,
                     ka.admpn_cod_cli_ib,
                     ka.admpn_tip_premio
                FROM PCLUB.admpt_kardex ka
               WHERE ka.admpc_estado = 'A'
                 AND ka.admpc_tpo_punto = 'B'
                 AND ka.admpn_tip_premio = K_GRUPO
                 AND ka.admpc_tpo_oper = 'E'
                 AND ka.admpn_sld_punto > 0
                 AND ka.admpd_fec_trans <=
                     TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') --'17/09/2010'
                 AND ka.admpv_cod_cli = K_COD_CLIENTE) A
       ORDER BY DECODE(A.admpc_tpo_punto, 'B', 1, 2), A.admpn_id_kardex ASC;

  BEGIN
    /*
    Los puntos Bono son los q se consumiran primero. Tipo de punto 'B'
    */
    K_CODERROR := 0;
    K_MSJERROR := '';

    V_PUNTOS_REQUERIDOS := K_PUNTOS;

    -- Comienza el Canje, dato de entrada el codigo de cliente
    IF K_COD_CLIENTE IS NOT NULL THEN
      IF K_TIP_CLI = '3' THEN
        -- Clientes Prepago
        OPEN LISTA_KARDEX_1;
        FETCH LISTA_KARDEX_1
          INTO LK_TPO_PUNTO,
               LK_ID_KARDEX,
               LK_SLD_PUNTOS,
               LK_COD_CLI,
               LK_COD_CLIIB,
               LK_TPO_PREMIO;
        WHILE LISTA_KARDEX_1%FOUND AND V_PUNTOS_REQUERIDOS > 0 LOOP
          IF LK_SLD_PUNTOS <= V_PUNTOS_REQUERIDOS THEN

            -- Actualiza Kardex
            UPDATE PCLUB.admpt_kardex
               SET admpn_sld_punto = 0, admpc_estado = 'C'
             WHERE admpn_id_kardex = LK_ID_KARDEX;
            -- Inserta Canje_kardex
            INSERT INTO PCLUB.admpt_canjedt_kardex
              (admpv_id_canje,
               admpn_id_kardex,
               admpv_id_canjesec,
               admpn_puntos)
            VALUES
              (K_ID_CANJE, LK_ID_KARDEX, K_SEC, LK_SLD_PUNTOS);

            -- Actualiza Saldos_cliente
            IF LK_TPO_PUNTO = 'C' OR LK_TPO_PUNTO = 'L' THEN
              /* Punto Claro Club */
              UPDATE PCLUB.admpt_saldos_cliente
                 SET admpn_saldo_cc = -LK_SLD_PUNTOS +
                                      NVL(admpn_saldo_cc, 0)
               WHERE admpv_cod_cli = LK_COD_CLI;

            ELSIF LK_TPO_PUNTO = 'I' THEN
              /* Punto IB*/
              UPDATE PCLUB.admpt_saldos_cliente
                 SET admpn_saldo_ib = -LK_SLD_PUNTOS +
                                      NVL(admpn_saldo_ib, 0)
               WHERE admpn_cod_cli_ib = LK_COD_CLIIB;
            ELSE
              IF LK_TPO_PUNTO = 'B' THEN
                IF LK_TPO_PREMIO = 0 THEN
                  /* Puntos Bonos para cualquier canje*/
                  UPDATE PCLUB.admpt_saldos_cliente
                     SET admpn_saldo_cc = -LK_SLD_PUNTOS +
                                          NVL(admpn_saldo_cc, 0)
                   WHERE admpv_cod_cli = LK_COD_CLI;
                ELSE
                  /* Puntos Bonos para canjes de ciertos premios*/
                  UPDATE PCLUB.admpt_saldos_bono_cliente
                     SET ADMPN_SALDO = -LK_SLD_PUNTOS + NVL(ADMPN_SALDO, 0)
                   WHERE ADMPV_COD_CLI = LK_COD_CLI
                     AND ADMPN_GRUPO = K_GRUPO;
                END IF;
              END IF;
            END IF;

            V_PUNTOS_REQUERIDOS := V_PUNTOS_REQUERIDOS - LK_SLD_PUNTOS;

          ELSE
            IF LK_SLD_PUNTOS > V_PUNTOS_REQUERIDOS THEN

              -- Actualiza Kardex
              UPDATE PCLUB.admpt_kardex
                 SET admpn_sld_punto = LK_SLD_PUNTOS - V_PUNTOS_REQUERIDOS
               WHERE admpn_id_kardex = LK_ID_KARDEX;

              -- Inserta Canje_kardex
              INSERT INTO PCLUB.admpt_canjedt_kardex
                (admpv_id_canje,
                 admpn_id_kardex,
                 admpv_id_canjesec,
                 admpn_puntos)
              VALUES
                (K_ID_CANJE, LK_ID_KARDEX, K_SEC, V_PUNTOS_REQUERIDOS);

              -- Actualiza Saldos_cliente
              IF LK_TPO_PUNTO = 'C' OR LK_TPO_PUNTO = 'L' THEN
                /* Punto Claro Club */
                UPDATE PCLUB.admpt_saldos_cliente
                   SET admpn_saldo_cc = -V_PUNTOS_REQUERIDOS +
                                        NVL(admpn_saldo_cc, 0)
                 WHERE admpv_cod_cli = LK_COD_CLI;
              ELSIF LK_TPO_PUNTO = 'I' THEN
                /* Punto IB*/
                UPDATE PCLUB.admpt_saldos_cliente
                   SET admpn_saldo_ib = -V_PUNTOS_REQUERIDOS +
                                        NVL(admpn_saldo_ib, 0)
                 WHERE admpn_cod_cli_ib = LK_COD_CLIIB;
              ELSE
                IF LK_TPO_PUNTO = 'B' THEN
                  IF LK_TPO_PREMIO = 0 THEN
                    /* Puntos Bonos para cualquier canje*/
                    UPDATE PCLUB.admpt_saldos_cliente
                       SET admpn_saldo_cc = -V_PUNTOS_REQUERIDOS +
                                            NVL(admpn_saldo_cc, 0)
                     WHERE admpv_cod_cli = LK_COD_CLI;
                  ELSE
                    /* Puntos Bonos para canjes de ciertos premios*/
                    UPDATE PCLUB.admpt_saldos_bono_cliente
                       SET ADMPN_SALDO = -V_PUNTOS_REQUERIDOS +
                                         NVL(ADMPN_SALDO, 0)
                     WHERE ADMPV_COD_CLI = LK_COD_CLI
                       AND ADMPN_GRUPO = K_GRUPO;
                  END IF;
                END IF;
              END IF;

              V_PUNTOS_REQUERIDOS := 0;

            END IF;
          END IF;
          FETCH LISTA_KARDEX_1
            INTO LK_TPO_PUNTO,
                 LK_ID_KARDEX,
                 LK_SLD_PUNTOS,
                 LK_COD_CLI,
                 LK_COD_CLIIB,
                 LK_TPO_PREMIO;
        END LOOP;
        CLOSE LISTA_KARDEX_1;
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR := SQLCODE;
      K_MSJERROR := SUBSTR(SQLERRM, 1, 400);

  END ADMPSI_DESC_PTOS_BONO;

  PROCEDURE ADMPSS_CONPERREN(K_SEGMENTO       IN VARCHAR2,
                             CURSORPERIODOSEG OUT SYS_REFCURSOR) IS

    --****************************************************************
    -- Nombre SP           :  ADMPSS_CONPERREN
    -- Propósito           :  Retorna los Periodos por Segmento
    --
    -- Input               :  K_SEGMENTO
    --
    -- Output              :  Cursor con los Periodos por Segmento
    --
    -- Creado por          :  Stiven Saavedra
    -- Fec Creación        :  05/10/2010
    -- Fec Actualización   :
    --****************************************************************

  BEGIN
    OPEN CURSORPERIODOSEG FOR
      SELECT DISTINCT ADMPT_PERIODO.ADMPV_COD_PER AS codigo,
                      ADMPT_PERIODO.ADMPV_DSC_PER AS descripcion
        FROM PCLUB.ADMPT_PERIODO
       INNER JOIN PCLUB.ADMPT_BON_RENOVESPEC ON ADMPT_PERIODO.ADMPV_COD_PER =
                                                ADMPT_BON_RENOVESPEC.ADMPV_COD_PER
       WHERE ADMPV_COD_SEGM =
             (SELECT ADMPV_COD_SEGM
                FROM PCLUB.ADMPT_SEGMENTO
               WHERE ADMPV_VAL_SIAC = K_SEGMENTO)
       ORDER BY TO_NUMBER(ADMPT_PERIODO.ADMPV_COD_PER) ASC;

  END ADMPSS_CONPERREN;

  PROCEDURE ADMPSS_CONPLANREN(K_SEGMENTO    IN VARCHAR2,
                              K_PERIODO     IN VARCHAR2,
                              CURSORPLANSEG OUT SYS_REFCURSOR) IS

    --****************************************************************
    -- Nombre SP           :  ADMPSS_CONPLANREN
    -- Propósito           :  Retorna los planes por Segmento
    --
    -- Input               :  K_SEGMENTO
    --                        K_PERIODO
    --
    -- Output              :  Cursor con los Planes por Segmento y Periodo
    --
    -- Creado por          :  Stiven Saavedra
    -- Fec Creación        :  27/09/2010
    -- Fec Actualización   :
    --****************************************************************

  BEGIN
    OPEN CURSORPLANSEG FOR
      SELECT DISTINCT ADMPT_TIPO_PLAN.ADMPN_COD_PLAN AS codigo,
                      ADMPT_TIPO_PLAN.ADMPV_DES_PLAN AS descripcion
        FROM PCLUB.ADMPT_TIPO_PLAN
       INNER JOIN PCLUB.ADMPT_BON_RENOVESPEC ON ADMPT_TIPO_PLAN.ADMPN_COD_PLAN =
                                                ADMPT_BON_RENOVESPEC.ADMPN_COD_PLAN
       WHERE ADMPV_COD_SEGM =
             (SELECT ADMPV_COD_SEGM
                FROM PCLUB.ADMPT_SEGMENTO
               WHERE ADMPV_VAL_SIAC = K_SEGMENTO)
         AND ADMPV_COD_PER = K_PERIODO
       ORDER BY TO_NUMBER(ADMPT_TIPO_PLAN.ADMPN_COD_PLAN) ASC;

  END ADMPSS_CONPLANREN;

  PROCEDURE ADMPSS_CONEQUREN(K_SEGMENTO     IN VARCHAR2,
                             K_PERIODO      IN VARCHAR2,
                             K_PLAN         IN NUMBER,
                             CURSOREQUIPSEG OUT SYS_REFCURSOR) IS

    --****************************************************************
    -- Nombre SP           :  ADMPSS_CONEQUREN
    -- Propósito           :  Retorna los Equipos por Segmento
    --
    -- Input               :  K_SEGMENTO
    --
    -- Output              :  Cursor con los Equipos por Segmento
    --
    -- Creado por          :  Stiven Saavedra
    -- Fec Creación        :  27/09/2010
    -- Fec Actualización   :
    --****************************************************************

  BEGIN
    OPEN CURSOREQUIPSEG FOR
      SELECT DISTINCT ADMPT_EQUIPO.ADMPV_COD_EQU AS codigo,
                      ADMPT_EQUIPO.ADMPV_DSC_EQU AS descripcion
        FROM PCLUB.ADMPT_EQUIPO
       INNER JOIN PCLUB.ADMPT_BON_RENOVESPEC ON ADMPT_EQUIPO.ADMPV_COD_EQU =
                                                ADMPT_BON_RENOVESPEC.ADMPV_COD_EQU
       WHERE ADMPV_COD_SEGM =
             (SELECT ADMPV_COD_SEGM
                FROM PCLUB.ADMPT_SEGMENTO
               WHERE ADMPV_VAL_SIAC = K_SEGMENTO)
         AND ADMPV_COD_PER = K_PERIODO
         AND ADMPN_COD_PLAN = K_PLAN
       ORDER BY ADMPT_EQUIPO.ADMPV_COD_EQU ASC;

  END ADMPSS_CONEQUREN;

  PROCEDURE ADMPSS_CONBONREN(K_SEGMENTO IN VARCHAR2,
                             K_PERIODO  IN VARCHAR2,
                             K_PLAN     IN NUMBER,
                             K_EQUIPO   IN VARCHAR2,
                             K_BONMONTO OUT NUMBER,
                             K_BONPUNTO OUT NUMBER) IS

    --****************************************************************
    -- Nombre SP           :  ADMPSS_CONBONREN
    -- Propósito           :  Retorna el bono en Soles y Puntos de acuerdo al segmento, periodo, plan y equipo.
    --
    -- Input               :  K_SEGMENTO
    --
    -- Output              :  Cursor con el bono en soles y puntos
    --
    -- Creado por          :  Stiven Saavedra
    -- Fec Creación        :  27/09/2010
    -- Fec Actualización   :
    --****************************************************************

    C_VALOR_PUNTO NUMBER;
    C_VALOR       VARCHAR2(50);
    C_MONTO       NUMBER;

  BEGIN

    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS=''. ''';

    BEGIN
      SELECT ADMPV_VALOR
        INTO C_VALOR
        FROM PCLUB.ADMPT_PARAMSIST
       WHERE ADMPV_DESC = 'PUNTO_CC_BONOREN_ESPECIAL';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        C_VALOR_PUNTO := 1;
    END;

    C_VALOR_PUNTO := ROUND(TO_NUMBER(C_VALOR), 6);

    BEGIN
      SELECT ADMPN_MONTO
        INTO C_MONTO
        FROM PCLUB.ADMPT_BON_RENOVESPEC
       WHERE ADMPV_COD_PER = K_PERIODO
         AND ADMPV_COD_SEGM =
             (SELECT ADMPV_COD_SEGM
                FROM PCLUB.ADMPT_SEGMENTO
               WHERE ADMPV_VAL_SIAC = K_SEGMENTO)
         AND ADMPV_COD_EQU = K_EQUIPO
         AND ADMPN_COD_PLAN = K_PLAN;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        C_MONTO := 0;
    END;

    K_BONMONTO := C_MONTO;
    K_BONPUNTO := CEIL(C_MONTO / C_VALOR_PUNTO);

  END ADMPSS_CONBONREN;

  PROCEDURE ADMPSS_DELBONREN(K_SEGMENTO IN VARCHAR2,
                             K_PERIODO  IN VARCHAR2,
                             K_CODERROR OUT NUMBER,
                             K_DSCERROR OUT VARCHAR2) IS
    --****************************************************************
    -- Nombre SP           :  ADMPSS_REGBONREN
    -- Propósito           :  Elimina registros en la tabla ADMPT_BON_RENOVESPEC.
    --
    -- Input               :  K_SEGMENTO
    --
    -- Output              :  Cursor con el bono en soles y puntos
    --
    -- Creado por          :  Stiven Saavedra
    -- Fec Creación        :  27/09/2010
    -- Fec Actualización   :
    --****************************************************************

  BEGIN

    DELETE FROM PCLUB.ADMPT_BON_RENOVESPEC
     WHERE admpv_cod_per = K_PERIODO
       AND admpv_cod_segm =
           (SELECT ADMPV_COD_SEGM
              FROM PCLUB.ADMPT_SEGMENTO
             WHERE ADMPV_VAL_SIAC = K_SEGMENTO);

    K_CODERROR := 0;
    K_DSCERROR := '';

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR := SQLCODE;
      K_DSCERROR := SUBSTR(SQLERRM, 1, 400);

  END ADMPSS_DELBONREN;

  PROCEDURE ADMPSS_REGBONREN(K_SEGMENTO IN VARCHAR2,
                             K_PERIODO  IN VARCHAR2,
                             K_PLAN     IN NUMBER,
                             K_EQUIPO   IN VARCHAR2,
                             K_BONMONTO IN NUMBER,
                             K_USUARIO  IN VARCHAR2,
                             K_CODERROR OUT NUMBER,
                             K_DSCERROR OUT VARCHAR2) IS
    --****************************************************************
    -- Nombre SP           :  ADMPSS_REGBONREN
    -- Propósito           :  Inserta registro en la tabla ADMPT_BON_RENOVESPEC.
    --
    -- Input               :  K_SEGMENTO, K_PERIODO, K_PLAN, K_EQUIPO, K_BONMONTO, K_USUARIO
    --
    -- Output              :  K_CODERROR, K_DSCERROR
    --
    -- Creado por          :  Stiven Saavedra
    -- Fec Creación        :  29/09/2010
    -- Fec Actualización   :
    --****************************************************************

    C_SEGMENTO VARCHAR2(2);

  BEGIN

    -- Obtenemos el Segmento con su equivalente del SIAC
    SELECT admpv_cod_segm
      INTO C_SEGMENTO
      FROM PCLUB.ADMPT_SEGMENTO
     WHERE admpv_val_siac = K_SEGMENTO;

    -- Insertamos en la tabla principal
    INSERT INTO PCLUB.ADMPT_BON_RENOVESPEC
      (id_fila,
       admpv_cod_per,
       admpv_cod_segm,
       admpv_cod_equ,
       admpn_cod_plan,
       admpn_monto,
       ADMPV_USUARIO,
       ADMPD_FEC_REG)
    VALUES
      (PCLUB.ADMPT_BONESP_SQ.NEXTVAL,
       K_PERIODO,
       C_SEGMENTO,
       K_EQUIPO,
       K_PLAN,
       K_BONMONTO,
       K_USUARIO,
       SYSDATE);

    K_CODERROR := 0;
    K_DSCERROR := '';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      K_CODERROR := -1;
      K_DSCERROR := 'No se encuentra registrado el Segmento del SIAC en la BD del Sistema de Administracion de Puntos.';

    WHEN OTHERS THEN
      K_CODERROR := SQLCODE;
      K_DSCERROR := SUBSTR(SQLERRM, 1, 400);

  END ADMPSS_REGBONREN;

  PROCEDURE ADMPSS_CONBONBIE(K_TELEFONO IN VARCHAR2,
                             K_ESTADO   OUT VARCHAR2,
                             K_FECENT   OUT DATE) IS
    --****************************************************************
    -- Nombre SP           :  ADMPSS_CONBONBIE
    -- Propósito           :  Retorna la fecha que se le entrego el Bono de Bienvenida al Cliente
    --
    -- Input               :  K_TELEFONO Numero de Telefono
    --
    -- Output              :  K_ESTADO P, el bono está Pendiente de activación, E; el bono ya fue brindado en la fecha --indicada por el campo ADMPD_FEC_PRO
    --                        K_FECENT Fecha de Entrega
    --
    -- Creado por          :  Stiven Saavedra
    -- Fec Creación        :  27/09/2010
    -- Fec Actualización   :
    --****************************************************************

    V_PLAN_CODE_SERV NUMBER(4);
    V_PLAN_CODE_PQ   NUMBER;
    V_ESTADO         CHAR(1);
    V_FECHAPROC      DATE;
    V_BONO           NUMBER;

    CURSOR C_BONOBIENVENIDA IS
      SELECT ADMPC_ESTADO, ADMPD_FEC_PRO
        FROM PCLUB.ADMPT_SERV_PEND
       WHERE TRIM(ADMPV_NUM_LINEA) = TRIM(K_TELEFONO)
         AND ADMPN_SN_CODE = V_PLAN_CODE_SERV
         AND ADMPN_SP_CODE = V_PLAN_CODE_PQ
         AND ADPMV_ACCION = '1' -- Activa el Servicio
       ORDER BY ADMPN_ID_FILA ASC;

  BEGIN

    SELECT NVL(admpv_valor, '-1')
      INTO V_PLAN_CODE_SERV
      FROM PCLUB.admpt_paramsist
     WHERE admpv_desc = 'COD_SERV_BONO_ACTIVACION_TC';
    SELECT NVL(admpv_valor, '-1')
      INTO V_PLAN_CODE_PQ
      FROM PCLUB.admpt_paramsist
     WHERE admpv_desc = 'COD_PAQU_BONO_ACTIVACION_TC';

    OPEN C_BONOBIENVENIDA;
    FETCH C_BONOBIENVENIDA
      INTO V_ESTADO, V_FECHAPROC;

    V_BONO := 1;

    IF (C_BONOBIENVENIDA%rowcount = 0) THEN
      V_BONO := 0;
    END IF;

    IF V_BONO > 0 THEN
      -- Encontro registro
      K_ESTADO := V_ESTADO;
      IF K_ESTADO = 'P' THEN
        K_FECENT := NULL;
      ELSE
        K_FECENT := V_FECHAPROC;
      END IF;
    ELSE
      K_ESTADO := NULL;
      K_FECENT := NULL;
    END IF;

    CLOSE C_BONOBIENVENIDA;

  END ADMPSS_CONBONBIE;

  PROCEDURE ADMPSS_REPCANJE(K_COD_CLIENTE     IN CHAR,
                            K_FCH_INICIO      IN DATE,
                            K_FCH_FIN         IN DATE,
                            CURSORREPORTCANJE OUT SYS_REFCURSOR) IS

    --****************************************************************
    -- Nombre SP           :  ADMPSS_REPCANJE
    -- Propósito           :  Reportar los canjes del cliente según un rango de fechas
    --
    -- Input               :  K_COD_CLIENTE
    --                        K_FCH_INICIO
    --                        K_FCH_FIN
    --
    -- Output              :  CURSORREPORTCANJE
    --
    -- Creado por          :  Luis De la Fuente - Cosapisoft
    -- Fec Creaci?n        :  15/10/2010
    -- Fec Actualizaci?n   :
    --****************************************************************
  BEGIN
    IF K_FCH_INICIO <= K_FCH_FIN THEN
      OPEN CURSORREPORTCANJE FOR
        SELECT A.ADMPV_ID_CANJE AS ID_CANJE,
               TO_DATE(A.ADMPD_FEC_CANJE, 'DD/MM/YYYY') AS FECHA_CANJE,
               A.ADMPV_HRA_CANJE AS HORA_CANJE,
               A.ADMPV_COD_CLI AS CUENTA,
               C.ADMPV_NUM_DOC AS DNI,
               (SELECT TC.ADMPV_DESC
                  FROM ADMPT_TIPO_CLIENTE TC
                 WHERE TC.ADMPV_COD_TPOCL = A.ADMPV_COD_TPOCL) AS TIPO_CLIENTE,
               A.ADMPV_PTO_VENTA AS PUNTO_VENTA,
               A.ADMPV_COD_ASESO AS CODIGO_ASESOR,
               A.ADMPV_NOM_ASESO AS NOMBRE_ASESOR,
               CASE A.ADMPC_TPO_OPER
                 WHEN 'C' THEN
                  'CANJE'
                 ELSE
                  'DEVOLUCION'
               END AS TIPO_MOVIMIENTO,
               (SELECT TP.ADMPV_DESC
                  FROM ADMPT_TIPO_PREMIO TP
                 WHERE TP.ADMPV_COD_TPOPR = D.ADMPV_COD_TPOPR) AS TIPO_PREMIO,
               D.ADMPV_ID_PROCLA AS ID_PRODUCTO,
               D.ADMPV_DESC AS DESCRIPCION_DEL_PRODUCTO,
               D.ADMPN_PUNTOS AS PUNTOS_CANJEADOS,
               D.ADMPN_CANTIDAD AS CANTIDAD,
               D.ADMPV_NOM_CAMP AS NOMBRE_CAMPAÑA,
               D.ADMPV_ID_CANJESEC
          FROM ADMPT_CANJE A, ADMPT_CANJE_DETALLE D, ADMPT_CLIENTE C
         WHERE C.ADMPV_COD_CLI = A.ADMPV_COD_CLI
           AND A.ADMPV_ID_CANJE = D.ADMPV_ID_CANJE
           AND A.ADMPD_FEC_CANJE >= K_FCH_INICIO
           AND A.ADMPD_FEC_CANJE <= K_FCH_FIN
           AND A.ADMPV_COD_CLI = K_COD_CLIENTE
         ORDER BY A.ADMPD_FEC_CANJE,
                  A.ADMPV_HRA_CANJE,
                  D.ADMPV_ID_CANJESEC ASC;
    ELSE
      OPEN CURSORREPORTCANJE FOR
        SELECT A.ADMPV_ID_CANJE AS ID_CANJE,
               TO_DATE(A.ADMPD_FEC_CANJE, 'DD/MM/YYYY') AS FECHA_CANJE,
               A.ADMPV_HRA_CANJE AS HORA_CANJE,
               A.ADMPV_COD_CLI AS CUENTA,
               C.ADMPV_NUM_DOC AS DNI,
               (SELECT TC.ADMPV_DESC
                  FROM ADMPT_TIPO_CLIENTE TC
                 WHERE TC.ADMPV_COD_TPOCL = A.ADMPV_COD_TPOCL) AS TIPO_CLIENTE,
               A.ADMPV_PTO_VENTA AS PUNTO_VENTA,
               A.ADMPV_COD_ASESO AS CODIGO_ASESOR,
               A.ADMPV_NOM_ASESO AS NOMBRE_ASESOR,
               CASE A.ADMPC_TPO_OPER
                 WHEN 'C' THEN
                  'CANJE'
                 ELSE
                  'DEVOLUCION'
               END AS TIPO_MOVIMIENTO,
               (SELECT TP.ADMPV_DESC
                  FROM ADMPT_TIPO_PREMIO TP
                 WHERE TP.ADMPV_COD_TPOPR = D.ADMPV_COD_TPOPR) AS TIPO_PREMIO,
               D.ADMPV_ID_PROCLA AS ID_PRODUCTO,
               D.ADMPV_DESC AS DESCRIPCION_DEL_PRODUCTO,
               D.ADMPN_PUNTOS AS PUNTOS_CANJEADOS,
               D.ADMPN_CANTIDAD AS CANTIDAD,
               D.ADMPV_NOM_CAMP AS NOMBRE_CAMPAÑA,
               D.ADMPV_ID_CANJESEC
          FROM ADMPT_CANJE A, ADMPT_CANJE_DETALLE D, ADMPT_CLIENTE C
         WHERE C.ADMPV_COD_CLI = A.ADMPV_COD_CLI
           AND A.ADMPV_ID_CANJE = D.ADMPV_ID_CANJE
           AND A.ADMPD_FEC_CANJE >= K_FCH_INICIO
           AND A.ADMPD_FEC_CANJE <= K_FCH_FIN
           AND A.ADMPV_COD_CLI = K_COD_CLIENTE
         ORDER BY A.ADMPD_FEC_CANJE,
                  A.ADMPV_HRA_CANJE,
                  D.ADMPV_ID_CANJESEC ASC;
    END IF;

  END ADMPSS_REPCANJE;

  PROCEDURE LISTADO_SEGMENTOS(CURSOR_SALIDA OUT K_REF_CURSOR) IS
  BEGIN
    OPEN CURSOR_SALIDA FOR
      SELECT S.ADMPV_COD_SEGM, S.ADMPV_DSC_SEGM
        FROM ADMPT_SEGMENTO S
       ORDER BY S.ADMPV_COD_SEGM ASC;
  END LISTADO_SEGMENTOS;

  PROCEDURE LISTADO_PERIODOS(CURSOR_SALIDA OUT K_REF_CURSOR) IS
  BEGIN
    OPEN CURSOR_SALIDA FOR
      SELECT P.ADMPV_COD_PER, P.ADMPV_DSC_PER
        FROM ADMPT_PERIODO P
       ORDER BY P.ADMPV_COD_PER ASC;
  END LISTADO_PERIODOS;

  PROCEDURE ADMPSS_REGTABLETEMP(P_COUNT  IN INTEGER,
                                P_INSERT IN VARCHAR2,
                                P_RETURN OUT VARCHAR2,
                                P_MSGERR OUT VARCHAR2) IS
    --****************************************************************
    -- Nombre SP           :  ADMPSS_REGTABLETEMP
    -- Propósito           :  Registrar bonos de renovación en tabla temporal admpt_data_temp
    --
    -- Input               :  P_COUNT
    --                        P_INSERT
    --
    -- Output              :  P_RETURN
    --                        P_MSGERR
    --
    -- Creado por          :  Jordan Torres - T12647
    -- Fec Creación        :  28/10/2010
    -- Fec Actualización   :
    --****************************************************************
    V_CADENA VARCHAR2(4096);
    V_COUNT  INTEGER;
  BEGIN
    V_COUNT  := P_COUNT - 1;
    V_CADENA := 'insert into admpt_data_temp (';
    FOR i IN 0 .. V_COUNT LOOP
      IF i = 0 THEN
        V_CADENA := V_CADENA || ' campo_' || i;
      ELSE
        V_CADENA := V_CADENA || ', campo_' || i;
      END IF;
    END LOOP;
    V_CADENA := V_CADENA || ') values (' || P_INSERT || ')';
    EXECUTE IMMEDIATE V_CADENA;
    COMMIT;
    P_RETURN := '0';
    P_MSGERR := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
      P_RETURN := '1';
      IF sqlcode = -984 THEN
        P_MSGERR := 'ALERTA: LOS VALORES DEBEN SER NÚMERICOS. ';
        RETURN;
      END IF;
      P_MSGERR := SQLERRM;
  END ADMPSS_REGTABLETEMP;

/*
 PROCEDURE ADMPSS_PROCTABLETEMP(P_COUNTCOLUMN IN INTEGER,
                                 P_SEGMENTO    IN VARCHAR2,
                                 P_PERIODO     IN VARCHAR2,
                                 P_USUARIO     IN VARCHAR2,
                                 P_RETURN      OUT VARCHAR2,
                                 P_MSGERR      OUT VARCHAR2) IS
*/
    --****************************************************************
    -- Nombre SP           :  ADMPSS_PROCTABLETEMP
    -- Propósito           :  Procesar bonos por renovación desde tabla temporal admpt_data_temp habia tabla --admpt_bon_renovespec
    --
    -- Input               :  P_COUNTCOLUMN
    --                        P_SEGMENTO
    --                        P_PERIODO
    --                        P_USUARIO
    --
    -- Output              :  P_RETURN
    --                        P_MSGERR
    --
    -- Creado por          :  Jordan Torres - T12647
    -- Fec Creación        :  28/10/2010
    -- Fec Actualización   :
    --****************************************************************

 /*   TYPE temp_table IS TABLE OF VARCHAR2(8) INDEX BY BINARY_INTEGER;
    tTablePlan       temp_table;
    tTablePlan_noReg temp_table;
    v_equipo         VARCHAR2(20);
    v_plan           VARCHAR2(10);
    v_monto          NUMBER;
    v_cadena         VARCHAR2(512);
    v_return         NUMBER;
    v_msgerr         VARCHAR2(1024);
    v_maxcolumn      NUMBER;
    v_conta_plan     NUMBER;
    v_conta_equi     NUMBER;
    v_no_data_plan   VARCHAR2(1024);
    v_no_data_equi   VARCHAR2(1024);
    v_falta_planes   NUMBER;
    v_falta_equipo   NUMBER;
    CURSOR c_temp IS
      SELECT a.*, ROWNUM v_rownum
        FROM (SELECT f.*, ROWID v_rowid
                FROM admpt_data_temp f
               ORDER BY campo_0 asc) a;*/

/*  BEGIN
    EXECUTE IMMEDIATE 'delete from admpt_bon_renovespec where admpv_cod_per = ''' ||
                      P_PERIODO || ''' and admpv_cod_segm = ''' ||
                      P_SEGMENTO || '''';
    commit;
    v_no_data_plan := 'Códigos Planes No Registrados: ';
    v_no_data_equi := 'Códigos Equipos No Registrados: ';
    v_falta_planes := 0;
    v_falta_equipo := 0;
    FOR c IN c_temp LOOP
      v_equipo := c.campo_0;
      v_plan   := NULL;
      v_monto  := NULL;
      v_cadena := NULL;
      IF c.v_rownum = 1 THEN
        FOR i IN 1 .. P_COUNTCOLUMN LOOP
          v_cadena := 'select c.campo_' || i ||
                      ' from admpt_data_temp c where rowid = ''' ||
                      c.v_rowid || '''';
          EXECUTE IMMEDIATE v_cadena
            INTO v_plan;

          IF TO_NUMBER(V_PLAN) < 0 THEN
            p_return := '1';
            p_msgerr := 'ALERTA: NO SE PERMITEN VALORES NEGATIVOS.';
            RETURN;
          END IF;

          IF v_plan IS NOT NULL THEN
            tTablePlan(i) := v_plan;
          ELSE
            v_maxcolumn := i - 1;
            EXIT;
          END IF;
        END LOOP;
      ELSE

        SELECT COUNT(1)
          INTO v_conta_equi
          FROM ADMPT_BON_RENOVESPEC abr
         WHERE abr.admpv_cod_per = P_PERIODO
           and abr.admpv_cod_segm = P_SEGMENTO
           and abr.admpv_cod_equ = v_equipo;

        IF v_conta_equi = 0 THEN

          SELECT COUNT(1)
            INTO v_conta_equi
            FROM admpt_equipo ae
           WHERE ae.admpv_cod_equ = v_equipo;
          IF v_conta_equi = 0 THEN
            v_no_data_equi := v_no_data_equi || ',' || v_equipo;
            v_falta_equipo := 1;
          ELSE
            FOR j IN 1 .. v_maxcolumn LOOP

              SELECT COUNT(1)
                INTO v_conta_plan
                FROM ADMPT_BON_RENOVESPEC abr
               WHERE abr.admpv_cod_per = P_PERIODO
                 and abr.admpv_cod_segm = P_SEGMENTO
                 and abr.admpn_cod_plan = tTablePlan(j)
                 and abr.admpv_cod_equ = v_equipo;

              IF v_conta_plan = 0 THEN
                SELECT COUNT(1)
                  INTO v_conta_plan
                  FROM admpt_tipo_plan tp
                 WHERE tp.admpn_cod_plan = tTablePlan(j);
                IF v_conta_plan = 0 THEN
                  BEGIN
                    IF tTablePlan_noReg(j) IS NOT NULL THEN
                      NULL;
                    END IF;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      v_no_data_plan := v_no_data_plan || ',' ||
                                        tTablePlan(j);
                      tTablePlan_noReg(j) := tTablePlan(j);
                      v_falta_planes := 1;
                  END;
                ELSE
                  v_cadena := 'select c.campo_' || j ||
                              ' from admpt_data_temp c where rowid = ''' ||
                              c.v_rowid || '''';
                  EXECUTE IMMEDIATE v_cadena
                    INTO v_monto;

                  IF TO_NUMBER(v_monto) < 0 THEN
                    p_return := '1';
                    p_msgerr := 'ALERTA: NO SE PERMITEN VALORES NEGATIVOS.';
                    RETURN;
                  END IF;

                  pkg_cc_transaccion.admpss_regbonren(P_SEGMENTO,
                                                      P_PERIODO,
                                                      tTablePlan(j),
                                                      v_equipo,
                                                      v_monto,
                                                      P_USUARIO,
                                                      v_return,
                                                      v_msgerr);
                  IF v_return <> 0 THEN
                    p_return := v_return;
                    p_msgerr := v_msgerr;
                    RETURN;
                  END IF;
                END IF;
              END IF;

            END LOOP;
          END IF;
        END IF;
      END IF;
    END LOOP;
    COMMIT;
    EXECUTE IMMEDIATE 'truncate table admpt_data_temp';
    IF v_falta_planes = 1 THEN
      p_return := 19;
      p_msgerr := v_no_data_plan;
    END IF;
    IF v_falta_equipo = 1 THEN
      p_return := 19;
      p_msgerr := v_no_data_equi || ' ' || p_msgerr;
    END IF;
    IF v_falta_planes = 0 AND v_falta_equipo = 0 THEN
      p_return := 0;
      p_msgerr := 'El Archivo se cargo con éxito en la BD.';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_return := '1';
      p_msgerr := SQLERRM;
  END ADMPSS_PROCTABLETEMP;*/


  /*PROCEDURE ADMPSS_CONSBONOS(P_SEGMENTO IN VARCHAR2,P_PERIODO IN VARCHAR2,
                             P_RETURN OUT VARCHAR2,P_MSGERR OUT VARCHAR2,CURSOR_SALIDA OUT K_REF_CURSOR) IS
  --****************************************************************
  -- Nombre SP           :  ADMPSS_CONSBONOS
  -- Propósito           :  Consultar bonos por renovación
  --
  -- Input               :  P_SEGMENTO
  --                        P_PERIODO
  --
  -- Output              :  P_RETURN
  --                        P_MSGERR
  --                        CURSOR_SALIDA
  --
  -- Creado por          :  Jordan Torres - T12647
  -- Fec Creación        :  28/10/2010
  -- Fec Actualización   :
  --****************************************************************
  v_sep           VARCHAR2(7);
  v_cadena_1      VARCHAR2(32760);
  v_cadena_2      VARCHAR2(128);
  v_cadena_3      VARCHAR2(128);
  v_cadena_4      VARCHAR2(128);
  v_cadena_5      VARCHAR2(1024);
  v_cadena_6      VARCHAR2(128);
  v_cadena_7      VARCHAR2(128);
  v_cadena_8      VARCHAR2(16380);
  v_cadena_9      VARCHAR2(16380);
  v_countcolumn   NUMBER;
  v_no_planes     EXCEPTION;
  BEGIN
      v_sep := CHR(124)||CHR(124)||'''|'''||CHR(124)||CHR(124);
      EXECUTE IMMEDIATE 'update admpt_paramsist set admpv_valor = '''||P_SEGMENTO||''' where admpc_cod_param = '''||'101'||'''';
      EXECUTE IMMEDIATE 'update admpt_paramsist set admpv_valor = '''||P_PERIODO||''' where admpc_cod_param = '''||'102'||'''';
      COMMIT;
      v_cadena_1 := 'select '''||'EQUIPOS RENOVACION ESPECIAL'||'''';
      v_cadena_2 := '(select trim(des_plan) from v_plan where fila = ';
      v_cadena_3 := ')';
      v_cadena_4 := ' column_value from dual union all select e.des_equ ';
      v_cadena_5 := '(select to_char(r.admpn_monto) from admpt_bon_renovespec r where r.admpv_cod_equ = e.cod_equ and r.admpv_cod_segm = '||P_SEGMENTO||' and r.admpv_cod_per = '||P_PERIODO||' and r.admpn_cod_plan = (select vp.cod_plan from v_plan vp where vp.fila = ';
      v_cadena_6 := '))';
      v_cadena_7 := ' from v_equipo e';
      SELECT MAX(fila) INTO v_countcolumn FROM v_plan;
      IF v_countcolumn IS NULL THEN
         RAISE v_no_planes;
      END IF;
      FOR i IN 1 .. v_countcolumn LOOP
          v_cadena_8 := v_cadena_8||v_sep||v_cadena_2||i||v_cadena_3;
      END LOOP;
          v_cadena_1 := v_cadena_1||v_cadena_8||v_cadena_4;
      FOR i IN 1 .. v_countcolumn LOOP
          v_cadena_9 := v_cadena_9||v_sep||v_cadena_5||i||v_cadena_6;
      END LOOP;
          v_cadena_1 := v_cadena_1||v_cadena_9||v_cadena_7;
      OPEN CURSOR_SALIDA FOR
      v_cadena_1;
      p_return := '0';
      p_msgerr := 'OK';
  EXCEPTION
      WHEN v_no_planes THEN
           OPEN CURSOR_SALIDA FOR SELECT NULL COLUMN_VALUE FROM dual;
           p_return := '1';
           p_msgerr := 'No Existe datos sobre la consulta ingresada.';
      WHEN OTHERS THEN
           OPEN CURSOR_SALIDA FOR SELECT NULL COLUMN_VALUE FROM dual;
           p_return := '2';
           p_msgerr := SQLERRM;
  END ADMPSS_CONSBONOS;
  */
  PROCEDURE ADMPSS_TIPPRE(K_CUR_LISTA OUT SYS_REFCURSOR) AS
  BEGIN

    OPEN K_CUR_LISTA FOR
      SELECT T.ADMPV_COD_TPOPR CODIGO, T.ADMPV_DESC DESCRIPCION
        FROM ADMPT_TIPO_PREMIO T
       WHERE T.ADMPC_ESTADO = 'A';

  END ADMPSS_TIPPRE;

 PROCEDURE ADMPSS_GRUPTIPPRE(K_CUR_LISTA OUT SYS_REFCURSOR) AS
  BEGIN

    OPEN K_CUR_LISTA FOR
      SELECT G.ADMPN_GRUPO CODIGO, G.ADMPV_DESCRIPCION DESCRIPCION
        FROM PCLUB.ADMPT_GRUPO_TIPPREM G
       WHERE G.ADMPN_GRUPO <> 0;

  END ADMPSS_GRUPTIPPRE;

FUNCTION splitcad(p_in_string VARCHAR2, p_delim VARCHAR2)
RETURN tab_array
  /*
        Proposito            : Separacion de parametros enviados en un cadena por un determinante
        Parametros          : p_in_string   Cadena que contiene los parametros concatenados
                                p_delim         Caracter delimitador
        Fecha Creacion      : 09:30 a.m. 02/02/2012
        Fecha Modificacion  : 09:30 a.m. 02/02/2012
        Usuario Crea        : Henry Herrera Ch.
        Usuario Modifica    : Henry Herrera Ch.
        Version             : 1.0
     -----------------------------------------------------------------------
  */
  IS
    i         NUMBER := 0;
    pos       NUMBER := 0;
    lv_str    VARCHAR2(200) := ltrim(p_in_string);
    Arreglo   tab_array;
    cValor    varchar2(200);
  BEGIN
    pos :=  INSTR(lv_str,p_delim ,1 ,1);
    WHILE (pos != 0 or  pos != null)
    LOOP
      i := i + 1;
      --Capturando valores para el arreglo
      cValor:=SUBSTR(lv_str, 1, pos - 1);
      if cValor='|' or cValor is NULL then
         Arreglo(i) :='NULL';
      else
         Arreglo(i) :=cValor;
      end if;

      lv_str     :=SUBSTR(lv_str, pos + 1, LENGTH(lv_str));
      pos        :=INSTR(lv_str ,p_delim  ,1 ,1);

      IF pos = 0 THEN
        --Capturando valor para el primer elemento
        Arreglo(i + 1) := lv_str;
      END IF;
    END LOOP;

    RETURN Arreglo;
  END splitcad;


  PROCEDURE admpss_actcanje(k_idcanje            IN     VARCHAR2
                           ,k_lista_idprocla     IN     VARCHAR2
                           ,k_lista_codtxpaq     IN     VARCHAR2
                           ,k_msjsms             IN     VARCHAR2
                           ,k_exito                 OUT NUMBER
                           ,k_coderror              OUT NUMBER
                           ,k_descerror             OUT VARCHAR2)
  /*
         Proposito                : Procedimiento para la actualizacion de canje y sus detalles
        Parametros            : K_IDCANJE                 Identificador de canje
                                      K_LISTA_IDPROCLA     Lista de parametros que contiene la llave  en detalle
                                      K_LISTA_CODTXPAQ   Lista de parametros que contiene el valor del campo en detalle
                                      K_MSJSMS                   Descripcion que se actualizara en Canje
                                      K_EXITO                      Valor enteror factor de exito  1 exito caso contrario error
                                      K_CODERROR              Informacion del codigo de error
                                      K_DESCERROR              Descripcion del error
        Fecha Creacion        : 12:30 a.m. 02/02/2012
        Fecha Modificacion  : 12:30 a.m. 02/02/2012
        Usuario Crea          : Henry Herrera Ch.
        Usuario Modifica     : Henry Herrera Ch.
        Version                   : 1.0
     -----------------------------------------------------------------------*\
  */
  IS
    strcamp        pclub.pkg_cc_transaccion.tab_array;
    strllave       pclub.pkg_cc_transaccion.tab_array;
    V_COD_CLI     VARCHAR2(40);
    V_COD_TPOCL   VARCHAR2(2);
    V_TIPO_DOC    VARCHAR2(20);
    V_NUM_DOC     VARCHAR2(20);
    K_CODERROR_EX  NUMBER;
    K_DESCERROR_EX VARCHAR2(400);
  BEGIN
    strcamp := pkg_cc_transaccion.splitcad(k_lista_codtxpaq, '|');
    strllave := pkg_cc_transaccion.splitcad(k_lista_idprocla, '|');

    IF strcamp.COUNT = strllave.COUNT THEN
      UPDATE   admpt_canje
      SET      admpv_mensaje = k_msjsms, admpd_fec_mod = CURRENT_DATE
      WHERE    admpv_id_canje = k_idcanje;

      --Si la cantidad de valores es igual a la cantidad de llaves procede
      FOR i IN 1 .. strllave.COUNT
      LOOP
          UPDATE   admpt_canje_detalle
          SET      admpv_codtxpaqdat = DECODE(TRIM(strcamp(i)),'NULL',NULL,TRIM(strcamp(i)))
                  ,admpd_fec_mod = CURRENT_DATE
          WHERE    admpv_id_canje = k_idcanje
               AND TRIM(admpv_id_procla) = TRIM(strllave(i));
      END LOOP;
      k_exito := 1;
      k_coderror := 0;

      SELECT ADMPV_COD_CLI,ADMPV_COD_TPOCL INTO V_COD_CLI,V_COD_TPOCL
      FROM ADMPT_CANJE WHERE ADMPV_ID_CANJE = k_idcanje ;

      SELECT ADMPV_TIPO_DOC,ADMPV_NUM_DOC INTO V_TIPO_DOC,V_NUM_DOC
      FROM ADMPT_CLIENTE
      WHERE ADMPV_COD_CLI = V_COD_CLI ;

      ADMPU_LIBBLOQUEOBOLSA(V_TIPO_DOC,V_NUM_DOC,V_COD_TPOCL,K_CODERROR_EX,K_DESCERROR_EX);

      IF K_CODERROR_EX <> 0 THEN
        k_coderror := K_CODERROR_EX;
        K_DESCERROR := K_DESCERROR || 'Error en SP ADMPU_LIBBLOQUEOBOLSA: ' || K_DESCERROR_EX;
        k_exito := 0;
      END IF;
     COMMIT;
    ELSE
      k_coderror := -99;
      k_descerror := 'No coinciden el numero de elementos en los parametros K_LISTA_IDPROCLA y K_LISTA_CODTXPAQ';
      k_exito := 0;
    END IF;
    --COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      k_coderror := -2;
      k_descerror := 'Ocurrió un error';
      k_exito := 0;
      ROLLBACK;
  END admpss_actcanje;


 PROCEDURE admpss_eliminarcanje(k_idcanje           IN     VARCHAR2
                                ,k_exito            OUT NUMBER
                                ,k_coderror         OUT NUMBER
                                ,k_descerror        OUT VARCHAR2)
  /*-----------------------------------------------------------------------
         Proposito                : Procedimiento para elimiar un canje
        Parametros            : K_IDCANJE                 Identificador de canje
                                K_EXITO                      Valor enteror factor de exito  1 exito caso contrario error
                                K_CODERROR              Informacion del codigo de error
                                K_DESCERROR              Descripcion del error
        Fecha Creacion      : 12:30 a.m. 02/02/2012
        Fecha Modificacion  : 12:30 a.m. 02/02/2012
        Usuario Crea        : Henry Herrera Ch.
        Usuario Modifica    : Henry Herrera Ch.
        Version                   : 1.0
     -----------------------------------------------------------------------
     */
  IS
    nulo_idcanje   EXCEPTION;
    no_existe      EXCEPTION;
    K_CODERROR_EX  NUMBER;
    K_DESCERROR_EX VARCHAR2(400);

    --Informacion de Canje Detalle Kardex
    CURSOR cursor_canj_kard
    IS
      SELECT   admpn_id_kardex, admpn_puntos
      FROM     PCLUB.admpt_canjedt_kardex
      WHERE    admpv_id_canje = TO_NUMBER(k_idcanje);

    c_id_kardex    NUMBER; --para capturar informacion de detalle kardex
    c_puntos       NUMBER; --para capturar informacion  de detalle kardex

    V_COD_CLIIB    PCLUB.admpt_clienteib.admpn_cod_cli_ib%TYPE;
    V_COD_CLI      PCLUB.admpt_cliente.admpv_cod_cli%TYPE;
    --v_cod_cli      VARCHAR2(40); --codigo de cliente
    v_tpo_punto    VARCHAR2(2); --Tipo de puntos
    v_id_kardex    NUMBER; --Identificador de kardex
    v_count_c      NUMBER; --Numero de registros
    V_TIPO_DOC     VARCHAR(20);
    V_NUM_DOC      VARCHAR2(20);
    V_TIPO_CLIE    VARCHAR2(2);
    V_TIPCANJE    NUMBER;
    v_tipprecanje NUMBER;
    V_TPO_PREMIO  NUMBER;
  BEGIN
    k_exito := 1;

    --Si se envio el identificador de canje
    IF ((k_idcanje IS NULL) OR (REPLACE(k_idcanje, ' ', '') IS NULL)) THEN
      RAISE nulo_idcanje;
      k_exito := 0;
    ELSE
      -- Cuantos registros tiene el mismo identificador de canje ( puede ser individual o paquete)
      SELECT   COUNT(1)
      INTO     v_count_c
      FROM     PCLUB.admpt_canje
      WHERE    admpv_id_canje = TO_NUMBER(k_idcanje);

      --Si no hay registros  (puede que no exista registros o puede ser que se paso un codigo incorrecto)
      IF v_count_c = 0 THEN
        RAISE no_existe;
        k_exito := 0;
        k_coderror := 99;
        k_descerror := 'No existen registro a eliminar con el identificador canje proporcionado';
      ELSE
        --Si existen registros  extraemos la informacion del cliente
        /*
        SELECT   admpv_cod_cli
        INTO     v_cod_cli
        FROM     PCLUB.admpt_canje
        WHERE    admpv_id_canje = TO_NUMBER(k_idcanje);
        */

        SELECT   ca.admpv_num_doc,cl.admpv_tipo_doc,ca.admpv_cod_tpocl
        INTO     V_NUM_DOC, V_TIPO_DOC,V_TIPO_CLIE
        FROM     PCLUB.admpt_canje ca
        inner join PCLUB.admpt_cliente cl on (cl.admpv_cod_cli=ca.admpv_cod_cli)
        WHERE    admpv_id_canje = TO_NUMBER(k_idcanje);

        --Procesando los detalle kardex encontrados y sumando puntos
        OPEN cursor_canj_kard;

        LOOP
          FETCH cursor_canj_kard
          INTO     c_id_kardex, c_puntos;

          EXIT WHEN cursor_canj_kard%NOTFOUND;

          --Actualizando el Kardex
          UPDATE   PCLUB.admpt_kardex
          SET      admpc_estado = 'A'
                  ,admpn_sld_punto =
                     c_puntos
                     + (SELECT   NVL(admpn_sld_punto, 0)
                        FROM     PCLUB.admpt_kardex
                        WHERE    admpn_id_kardex = c_id_kardex)
                  ,admpd_fec_mod = CURRENT_DATE
          WHERE    admpn_id_kardex = c_id_kardex;

          v_tpo_punto := NULL;

          /*
          SELECT   admpc_tpo_punto
          INTO     v_tpo_punto
          FROM     PCLUB.admpt_kardex
          WHERE    admpn_id_kardex = c_id_kardex;
          */

           SELECT NVL(admpn_cod_cli_ib, 0),
                 NVL(admpv_cod_cli, 0),
                 NVL(admpc_tpo_punto, 0),
                 ADMPN_TIP_PREMIO
            INTO V_COD_CLIIB, V_COD_CLI, V_TPO_PUNTO, V_TPO_PREMIO
            FROM PCLUB.admpt_kardex
          WHERE    admpn_id_kardex = c_id_kardex;

         IF V_TIPCANJE = 1 THEN
            IF v_tpo_punto = 'I' THEN
              ---Para el tipo de cliente IB
              UPDATE PCLUB.admpt_saldos_cliente
                 SET admpc_estpto_ib = 'A',
                     admpn_saldo_ib  = c_puntos +
                                       (SELECT NVL(admpn_saldo_ib, 0)
                                          FROM PCLUB.admpt_saldos_cliente
                                         WHERE admpv_cod_cli = V_COD_CLI
                                           AND admpn_cod_cli_ib = V_COD_CLIIB)
               WHERE admpv_cod_cli = V_COD_CLI
                 AND admpn_cod_cli_ib = V_COD_CLIIB;
            ELSIF V_TPO_PUNTO = 'C' OR V_TPO_PUNTO = 'L' THEN
              --Para el tipo de cliente Claro Club ...
              UPDATE PCLUB.admpt_saldos_cliente
                 SET admpc_estpto_cc = 'A',
                     admpn_saldo_cc  = c_puntos +
                                       (SELECT NVL(admpn_saldo_cc, 0)
                                          FROM PCLUB.admpt_saldos_cliente
                                         WHERE admpv_cod_cli = v_cod_cli)
               WHERE admpv_cod_cli = v_cod_cli;

            ELSIF V_TPO_PUNTO = 'B' THEN
              IF V_TPO_PREMIO = 0 THEN
                UPDATE PCLUB.admpt_saldos_cliente
                   SET admpc_estpto_cc = 'A',
                       admpn_saldo_cc  = c_puntos +
                                         (SELECT NVL(admpn_saldo_cc, 0)
                                            FROM PCLUB.admpt_saldos_cliente
                                           WHERE admpv_cod_cli = v_cod_cli)
                 WHERE admpv_cod_cli = v_cod_cli;
              ELSE
                UPDATE PCLUB.admpt_saldos_bono_cliente
                   SET ADMPN_SALDO = c_puntos +
                                     (SELECT NVL(ADMPN_SALDO, 0)
                                        FROM PCLUB.admpt_saldos_bono_cliente
                                       WHERE ADMPV_COD_CLI = v_cod_cli
                                         and admpn_grupo = v_tipprecanje)
                 WHERE admpv_cod_cli = v_cod_cli
                   and admpn_grupo = v_tipprecanje;
              END IF;

            END IF;

          ELSE

          IF v_tpo_punto = 'I' THEN
            ---Para el tipo de cliente IB
            UPDATE PCLUB.admpt_saldos_cliente
            SET      admpc_estpto_ib = 'A'
                    ,admpn_saldo_ib =
                       c_puntos
                       + (SELECT   NVL(admpn_saldo_ib, 0)
                          FROM     PCLUB.admpt_saldos_cliente
                          WHERE admpv_cod_cli = V_COD_CLI
                                           AND admpn_cod_cli_ib = V_COD_CLIIB)
            WHERE admpv_cod_cli = V_COD_CLI
            AND admpn_cod_cli_ib = V_COD_CLIIB;
            ELSE
              --V_TPO_PUNTO='C' O 'L' O 'B'
            --Para el tipo de cliente Claro Club ...
            UPDATE   PCLUB.admpt_saldos_cliente
            SET      admpc_estpto_cc = 'A'
                    ,admpn_saldo_cc =
                       c_puntos
                       + (SELECT   NVL(admpn_saldo_cc, 0)
                          FROM     PCLUB.admpt_saldos_cliente
                          WHERE    admpv_cod_cli = v_cod_cli)
            WHERE    admpv_cod_cli = v_cod_cli;
          END IF;
          END IF;
        END LOOP;

        CLOSE cursor_canj_kard;

        DELETE   PCLUB.admpt_canjedt_kardex
        WHERE    admpv_id_canje = TO_NUMBER(k_idcanje);

       --Eliminamos la informacion del detalle canje
        DELETE   PCLUB.admpt_canje_detalle
        WHERE    admpv_id_canje = TO_NUMBER(k_idcanje);

        SELECT   admpn_id_kardex
        INTO     v_id_kardex
        FROM     PCLUB.admpt_canje
        WHERE    admpv_id_canje = TO_NUMBER(k_idcanje);

        DELETE FROM PCLUB.ADMPT_MOVENCUESTA M
        WHERE M.ADMPN_IDCABENC = (SELECT C.ADMPN_IDCABENC
                               FROM PCLUB.ADMPT_CABENCUESTA C
                               WHERE C.ADMPN_ID_CANJE = k_idcanje);

        DELETE FROM PCLUB.ADMPT_CABENCUESTA C  WHERE  C.ADMPN_ID_CANJE = k_idcanje;

        DELETE   PCLUB.admpt_canje
        WHERE    admpv_id_canje = TO_NUMBER(k_idcanje);

       IF v_id_kardex IS NOT NULL THEN
          DELETE   PCLUB.admpt_kardex
          WHERE    admpn_id_kardex = v_id_kardex;
        END IF;

        PCLUB.PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(V_TIPO_DOC,V_NUM_DOC,V_TIPO_CLIE,K_CODERROR_EX,K_DESCERROR_EX);

        IF K_CODERROR_EX <> 0 THEN
          k_coderror := K_CODERROR_EX;
          K_DESCERROR := K_DESCERROR || 'Error en SP ADMPU_LIBBLOQUEOBOLSA: ' || K_DESCERROR_EX;
          k_exito := 0;
        END IF;

        COMMIT;

        k_coderror := 0;
        k_descerror := ' ';
      END IF;
    END IF;
  EXCEPTION
    WHEN nulo_idcanje THEN
      k_exito := 0;
      k_coderror := -1;
      k_descerror := 'El identificador del registro de canje es obligatorio.';
      ROLLBACK;
    --Si no existe registro no es factor para realizar un rollback
    WHEN no_existe THEN
      k_exito := 0;
      k_coderror := -99;
      k_descerror := 'No existe registros de canje a ser eliminados.';
    WHEN OTHERS THEN
      k_exito := 0;
      k_coderror := -1;
      k_descerror := SUBSTR(SQLERRM, 1, 250);
  END admpss_eliminarcanje;

  PROCEDURE admpss_valida_devolucion(k_cod_cliente     IN     VARCHAR2
                                    ,k_id_canje        IN     VARCHAR2
                                    ,k_fecha_devol     IN     DATE
                                    ,k_exito              OUT NUMBER
                                    ,k_coderror           OUT NUMBER
                                    ,k_descerror          OUT VARCHAR2)
  IS
    v_regcli       NUMBER;
    v_regclicanje  NUMBER;
    v_regclicanjedev NUMBER;
    v_fechacanje     DATE;
    errordatos     EXCEPTION;
    errordatoscanje EXCEPTION;
    errordatoscli  EXCEPTION;
    devolucionexiste EXCEPTION;
    errorfechadev  EXCEPTION;
    canjenoexiste  EXCEPTION;
    fechadevincorrec EXCEPTION;
  BEGIN
    IF (k_cod_cliente IS NULL) OR (k_id_canje IS NULL) OR (k_fecha_devol IS NULL) THEN
      RAISE errordatos;
    END IF;

    BEGIN
      SELECT   COUNT(ROWID)
      INTO     v_regcli
      FROM     admpt_cliente
      WHERE    admpv_cod_cli = k_cod_cliente AND admpc_estado = 'A';

      IF (v_regcli = 0) THEN
        RAISE errordatoscli;
      END IF;
    END;

    IF (v_regcli = 1) THEN
      BEGIN
        SELECT   COUNT(ROWID)
        INTO     v_regclicanje
        FROM     admpt_canje
        WHERE    admpv_cod_cli = k_cod_cliente AND admpv_id_canje = k_id_canje AND admpc_tpo_oper = 'C';
      EXCEPTION
        WHEN OTHERS THEN
          v_regclicanje := -1;
      END;

      IF v_regclicanje = 0 THEN
        RAISE canjenoexiste;
      ELSIF v_regclicanje = -1 THEN
        RAISE errordatoscanje;
      ELSIF v_regclicanje = 1 THEN
        /*BEGIN
          SELECT   COUNT(ROWID)
          INTO     v_regclicanjedev
          FROM     admpt_canje
          WHERE    admpv_cod_cli = k_cod_cliente AND admpv_dev_idcanje = k_id_canje;
        EXCEPTION
          WHEN OTHERS THEN
            v_regclicanjedev := -1;
        END;*/

     /*   IF v_regclicanjedev = 0 THEN*/

          SELECT   CA.admpd_fec_canje
          INTO     v_fechacanje
          FROM     admpt_canje CA
          WHERE    CA.admpv_cod_cli = k_cod_cliente
          AND CA.admpv_id_canje = k_id_canje
          AND CA.admpc_tpo_oper = 'C';

          IF trunc(k_fecha_devol) = trunc(v_fechacanje) THEN
            k_exito := 1;
            k_coderror := 0; -- Correcto
            k_descerror := ' ';
          ELSE
            RAISE fechadevincorrec;
          END IF;
      /*  ELSIF v_regclicanjedev = 1 THEN
          RAISE devolucionexiste;
        END IF;*/
      END IF;
    END IF;
  EXCEPTION
    WHEN errordatos THEN
      k_exito := 0;
      k_coderror := -1;
      k_descerror := 'EL Codigo de Cliente y Codigo de Canje o la Fecha de Devolución del Canje, son datos obligatorios para la Consulta';
    WHEN errordatoscli THEN
      k_exito := 0;
      k_coderror := -2;
      k_descerror := 'El Cliente no existe según el Codigo de Cliente solicitado o No Esta Activo.';
    WHEN errordatoscanje THEN
      k_exito := 0;
      k_coderror := -3;
      k_descerror := 'El código de Canje es inválido';
    WHEN canjenoexiste THEN
      k_exito := 0;
      k_coderror := -4;
      k_descerror := 'El Número de Canje : ' || k_id_canje || ' No Existe o Es una Devolución';
    WHEN devolucionexiste THEN
      k_exito := 0;
      k_coderror := -5;
      k_descerror := 'El Número de Canje : ' || k_id_canje || ' Ya fue Devuelto';
    WHEN fechadevincorrec THEN
      k_exito := 0;
      k_coderror := -6;
      k_descerror := 'La Fecha de Devolución es Diferente a la Fecha del Canje';
    WHEN errorfechadev THEN
      k_exito := 0;
      k_coderror := -7;
      k_descerror := 'Fecha Inválida';
    WHEN OTHERS THEN
      k_exito := 0;
      k_coderror := SQLCODE;
      k_descerror := SUBSTR(SQLERRM, 1, 250);
  END admpss_valida_devolucion;

PROCEDURE ADMPSS_VALIDASALDOKDX(
                            K_COD_CLIENTE  IN VARCHAR2,
                            K_TIP_CLI      IN VARCHAR2,
                            K_CODERROR     OUT NUMBER
) AS
  V_SALDO  NUMBER;
    V_SALDO_CLIBONO NUMBER;
    V_SALDO_CLI     NUMBER;
  V_SALDOKDX  NUMBER;
  V_TIP_DOC VARCHAR2(20);
  V_NUM_DOC VARCHAR2(20);

   --incidencia
  V_BONO_KDX_0 NUMBER;
  V_BONO_SLD_0 NUMBER;

    V_BONO_KDX_1 NUMBER;
  V_BONO_SLD_1 NUMBER;

  V_BONO_KDX_2 NUMBER;
  V_BONO_SLD_2 NUMBER;
--incidencia

  BEGIN
  K_CODERROR:=0;
  V_SALDO:=0;
  V_SALDOKDX:=0;

    IF K_TIP_CLI = 3 THEN
      --Obtengo la Suma del Saldo Cliente
      SELECT SUM(NVL(S.ADMPN_SALDO_CC, 0) + NVL(S.ADMPN_SALDO_IB, 0))
        INTO V_SALDO_CLI
        FROM PCLUB.ADMPT_SALDOS_CLIENTE S
       WHERE S.ADMPV_COD_CLI IN
             (SELECT CC2.ADMPV_COD_CLI
                FROM PCLUB.admpt_cliente CC2,
                     (SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
                        FROM PCLUB.admpt_cliente
                       WHERE ADMPV_COD_CLI = K_COD_CLIENTE
                         AND ADMPV_COD_TPOCL = K_TIP_CLI
                         AND admpc_estado = 'A') CC1 /*Obtiene el numero de doc y su tipo*/
               WHERE CC2.ADMPV_TIPO_DOC = CC1.ADMPV_TIPO_DOC
                 AND CC2.ADMPV_NUM_DOC = CC1.ADMPV_NUM_DOC
                 AND CC2.ADMPV_COD_TPOCL = K_TIP_CLI
                 AND CC2.admpc_estado = 'A');

      --Obtengo la Suma de Saldo Cliente Bono
      SELECT NVL(SUM(NVL(SB.ADMPN_SALDO, 0)),0)
        INTO V_SALDO_CLIBONO
        FROM PCLUB.ADMPT_SALDOS_BONO_CLIENTE SB
       WHERE SB.ADMPV_COD_CLI IN
             (SELECT CC2.ADMPV_COD_CLI
                FROM PCLUB.admpt_cliente CC2,
                     (SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
                        FROM PCLUB.admpt_cliente
                       WHERE ADMPV_COD_CLI = K_COD_CLIENTE
                         AND ADMPV_COD_TPOCL = K_TIP_CLI
                         AND admpc_estado = 'A') CC1 /*Obtiene el numero de doc y su tipo*/
               WHERE CC2.ADMPV_TIPO_DOC = CC1.ADMPV_TIPO_DOC
                 AND CC2.ADMPV_NUM_DOC = CC1.ADMPV_NUM_DOC
                 AND CC2.ADMPV_COD_TPOCL = K_TIP_CLI
                 AND CC2.admpc_estado = 'A');

      --Sumo los Saldos de Cliente y Cliente Bono
      V_SALDO := V_SALDO_CLI + V_SALDO_CLIBONO;

      SELECT NVL(SUM(NVL(K.ADMPN_SLD_PUNTO, 0)), 0)
        INTO V_SALDOKDX
        FROM PCLUB.ADMPT_KARDEX K
       WHERE K.ADMPV_COD_CLI IN
             (SELECT CC2.ADMPV_COD_CLI
                FROM PCLUB.admpt_cliente CC2,
                     (SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
                        FROM PCLUB.admpt_cliente
                       WHERE ADMPV_COD_CLI = K_COD_CLIENTE
                         AND ADMPV_COD_TPOCL = K_TIP_CLI
                         AND admpc_estado = 'A') CC1 /*Obtiene el numero de doc y su tipo*/
               WHERE CC2.ADMPV_TIPO_DOC = CC1.ADMPV_TIPO_DOC
                 AND CC2.ADMPV_NUM_DOC = CC1.ADMPV_NUM_DOC
                 AND CC2.ADMPV_COD_TPOCL = K_TIP_CLI
                 AND CC2.admpc_estado = 'A')
         AND K.ADMPC_ESTADO = 'A';

          --VALIDACION PUNTOS BONO incidencia

         /*   SELECT NVL(SUM(NVL(KS.ADMPN_SLD_PUNTO,0)),0) INTO V_BONO_KDX_0 FROM PCLUB.ADMPT_KARDEX KS
          WHERE KS.ADMPV_COD_CLI=K_COD_CLIENTE
          AND KS.ADMPC_TPO_PUNTO='B'
          AND KS.ADMPC_ESTADO='A'
          AND KS.ADMPN_TIP_PREMIO=0;


          SELECT NVL(SUM(S.ADMPN_SALDO),0) INTO V_BONO_SLD_0
          FROM PCLUB.ADMPT_SALDOS_BONO_CLIENTE S
          WHERE S.ADMPV_COD_CLI=K_COD_CLIENTE
          AND S.ADMPN_GRUPO=0;*/


         SELECT NVL(SUM(NVL(KS.ADMPN_SLD_PUNTO,0)),0) INTO V_BONO_KDX_1 FROM PCLUB.ADMPT_KARDEX KS
          WHERE KS.ADMPV_COD_CLI=K_COD_CLIENTE
          AND KS.ADMPC_TPO_PUNTO='B'
          AND KS.ADMPC_ESTADO='A'
          AND KS.ADMPN_TIP_PREMIO=1;


          SELECT NVL(SUM(S.ADMPN_SALDO),0) INTO V_BONO_SLD_1
          FROM PCLUB.ADMPT_SALDOS_BONO_CLIENTE S
          WHERE S.ADMPV_COD_CLI=K_COD_CLIENTE
          AND S.ADMPN_GRUPO=1;


          SELECT NVL(SUM(NVL(KS.ADMPN_SLD_PUNTO,0)),0) INTO V_BONO_KDX_2 FROM PCLUB.ADMPT_KARDEX KS
          WHERE KS.ADMPV_COD_CLI=K_COD_CLIENTE
          AND KS.ADMPC_TPO_PUNTO='B'
          AND KS.ADMPC_ESTADO='A'
          AND KS.ADMPN_TIP_PREMIO=2;


          SELECT NVL(SUM(S.ADMPN_SALDO),0) INTO V_BONO_SLD_2
          FROM PCLUB.ADMPT_SALDOS_BONO_CLIENTE S
          WHERE S.ADMPV_COD_CLI=K_COD_CLIENTE
          AND S.ADMPN_GRUPO=2;

         --VALIDACION PUNTOS BONO incidencia



    ELSIF K_TIP_CLI = 8 THEN
  SELECT SUM(NVL(S.ADMPN_SALDO_CC,0)+NVL(S.ADMPN_SALDO_IB,0))
  INTO V_SALDO
  FROM PCLUB.ADMPT_SALDOS_CLIENTE S
  WHERE S.ADMPV_COD_CLI IN
  (SELECT CC2.ADMPV_COD_CLI
                FROM PCLUB.admpt_cliente CC2,
                     (SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
                        FROM PCLUB.admpt_cliente
                       WHERE ADMPV_COD_CLI = K_COD_CLIENTE
                         AND ADMPV_COD_TPOCL = K_TIP_CLI
                         AND admpc_estado = 'A') CC1 /*Obtiene el numero de doc y su tipo*/
               WHERE CC2.ADMPV_TIPO_DOC = CC1.ADMPV_TIPO_DOC
                 AND CC2.ADMPV_NUM_DOC = CC1.ADMPV_NUM_DOC
                 AND CC2.ADMPV_COD_TPOCL = K_TIP_CLI
                 AND CC2.admpc_estado = 'A');

  SELECT NVL(SUM(NVL(K.ADMPN_SLD_PUNTO,0)),0)
  INTO V_SALDOKDX
  FROM PCLUB.ADMPT_KARDEX K
  WHERE K.ADMPV_COD_CLI IN
  (SELECT CC2.ADMPV_COD_CLI
                FROM PCLUB.admpt_cliente CC2,
                     (SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
                        FROM PCLUB.admpt_cliente
                       WHERE ADMPV_COD_CLI = K_COD_CLIENTE
                         AND ADMPV_COD_TPOCL = K_TIP_CLI
                         AND admpc_estado = 'A') CC1 /*Obtiene el numero de doc y su tipo*/
               WHERE CC2.ADMPV_TIPO_DOC = CC1.ADMPV_TIPO_DOC
                 AND CC2.ADMPV_NUM_DOC = CC1.ADMPV_NUM_DOC
                 AND CC2.ADMPV_COD_TPOCL = K_TIP_CLI
                 AND CC2.admpc_estado = 'A')
                 AND K.ADMPC_ESTADO='A';
                 --AND K.ADMPC_TPO_OPER='E'
                 --AND K.ADMPN_SLD_PUNTO>0;
ELSE

SELECT SUM(NVL(S.ADMPN_SALDO_CC,0)+NVL(S.ADMPN_SALDO_IB,0))
  INTO V_SALDO
  FROM PCLUB.ADMPT_SALDOS_CLIENTE S
  WHERE S.ADMPV_COD_CLI IN
  (SELECT CC2.ADMPV_COD_CLI
                FROM PCLUB.admpt_cliente CC2,
                     (SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
                        FROM PCLUB.admpt_cliente
                       WHERE ADMPV_COD_CLI = K_COD_CLIENTE
                         AND ADMPV_COD_TPOCL  IN (1,2)
                         AND admpc_estado = 'A') CC1 /*Obtiene el numero de doc y su tipo*/
               WHERE CC2.ADMPV_TIPO_DOC = CC1.ADMPV_TIPO_DOC
                 AND CC2.ADMPV_NUM_DOC = CC1.ADMPV_NUM_DOC
                 AND CC2.ADMPV_COD_TPOCL IN (1,2)
                 AND CC2.admpc_estado = 'A');

  SELECT NVL(SUM(NVL(K.ADMPN_SLD_PUNTO,0)),0)
  INTO V_SALDOKDX
  FROM PCLUB.ADMPT_KARDEX K
  WHERE K.ADMPV_COD_CLI IN
  (SELECT CC2.ADMPV_COD_CLI
                FROM PCLUB.admpt_cliente CC2,
                     (SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
                        FROM PCLUB.admpt_cliente
                       WHERE ADMPV_COD_CLI = K_COD_CLIENTE
                         AND ADMPV_COD_TPOCL  IN (1,2)
                         AND admpc_estado = 'A') CC1 /*Obtiene el numero de doc y su tipo*/
               WHERE CC2.ADMPV_TIPO_DOC = CC1.ADMPV_TIPO_DOC
                 AND CC2.ADMPV_NUM_DOC = CC1.ADMPV_NUM_DOC
                 AND CC2.ADMPV_COD_TPOCL  IN (1,2)
                 AND CC2.admpc_estado = 'A')
                 AND K.ADMPC_ESTADO='A';
                 --AND K.ADMPC_TPO_OPER='E'
                 --AND K.ADMPN_SLD_PUNTO>0;

END IF;

  IF V_SALDO<>V_SALDOKDX THEN
     K_CODERROR:=1;

     --incidencia
     ELSE

    IF K_TIP_CLI = 3 THEN
       /*IF V_BONO_KDX_0 <>  V_BONO_SLD_0 THEN
         K_CODERROR:=1;
       ELSE*/
         IF V_BONO_KDX_1<> V_BONO_SLD_1 THEN
            K_CODERROR:=1;
         ELSE
           IF V_BONO_KDX_2<>V_BONO_SLD_2 THEN
             K_CODERROR:=1;
           END IF;
         END IF;
      /* END IF;   */
    END IF;
  END IF;

EXCEPTION
      WHEN OTHERS THEN
     K_CODERROR:=1;
END ADMPSS_VALIDASALDOKDX;

PROCEDURE ADMPSS_ACT_INTERACT(k_idcanje    IN VARCHAR2,
                              k_id_inter  IN VARCHAR2,
                              k_exito     OUT NUMBER,
                              k_coderror  OUT NUMBER,
                              k_descerror OUT VARCHAR2) IS
  nulo_idcanje   EXCEPTION;
  BEGIN
    K_EXITO := 1;
    K_CODERROR := 0;
    K_DESCERROR:=' ';

    IF ((k_idcanje IS NULL) OR (REPLACE(k_idcanje, ' ', '') IS NULL)) THEN
      RAISE nulo_idcanje;
      K_EXITO := 0;
    ELSE

      UPDATE   PCLUB.admpt_canje
      SET      ADMPV_INTERACTID=K_ID_INTER
      WHERE    admpv_id_canje = k_idcanje;
      /*COMMIT;*/
    END IF;
   EXCEPTION
    WHEN nulo_idcanje THEN
      K_EXITO := 0;
      K_CODERROR := -1;
      K_DESCERROR := 'El identificador del registro de canje es obligatorio.';
      ROLLBACK;
    WHEN OTHERS THEN
      K_CODERROR := 1;
      K_DESCERROR :=SUBSTR(SQLERRM, 1, 250);
      K_EXITO := 0;
      ROLLBACK;
  END ADMPSS_ACT_INTERACT;

PROCEDURE ADMPSS_PRODUCTOSCANJE_MV(K_TIPDOC IN VARCHAR2,
                                   K_NUMDOC IN VARCHAR2,
                                   K_TIPCLIE IN VARCHAR2,
                                   K_FECINI IN VARCHAR2,
                                   K_FECFIN IN VARCHAR2,
                                   K_CODERROR OUT NUMBER,
                                   K_DESCERROR OUT VARCHAR2,
                                   CUR_CANJE OUT SYS_REFCURSOR) IS
STM_SQL VARCHAR2(5000);
EX_ERROR EXCEPTION;
BEGIN

K_CODERROR := 0;
K_DESCERROR := '';

IF K_TIPDOC IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR:='El tipo de doc. no es válido';
    RAISE EX_ERROR;
END IF;
IF K_NUMDOC IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR:='El numero de doc. no es válido';
    RAISE EX_ERROR;
END IF;
IF K_TIPCLIE IS NULL OR K_TIPCLIE  not in ('2','3','4','8') THEN
    K_CODERROR := 4;
    K_DESCERROR:='El tipo de cliente  no es válido';
    RAISE EX_ERROR;
END IF;

STM_SQL:='SELECT C.ADMPV_VENTAID ID_VENTA, C.ADMPV_ID_CANJE CANJE, C.ADMPV_COD_TPOCL TIP_CLIE,C.ADMPV_ID_CANJE NRO_CANJE,C.ADMPV_PTO_VENTA PTO_VENTA, D.ADMPV_DSC_DOCUM TIPO_DOC,F.ADMPV_NUM_DOC NRO_DOC,
        TO_CHAR(C.ADMPD_FEC_CANJE,''DD/MM/YYYY'') FECHA_CANJE,C.ADMPC_TPO_OPER TIPO_OPER
      FROM  PCLUB.ADMPT_CLIENTE F, PCLUB.ADMPT_CANJE C,  PCLUB.ADMPT_TIPO_DOC D
      WHERE C.ADMPV_COD_CLI=F.ADMPV_COD_CLI
      AND F.ADMPV_TIPO_DOC='''|| K_TIPDOC ||'''
      AND D.ADMPV_COD_TPDOC=F.ADMPV_TIPO_DOC
      AND F.ADMPV_NUM_DOC='''|| K_NUMDOC ||'''
      AND F.ADMPV_COD_TPOCL='''|| K_TIPCLIE ||''' ';

IF K_FECINI IS NOT NULL AND K_FECFIN IS NOT NULL THEN
     STM_SQL := STM_SQL || ' AND C.ADMPD_FEC_CANJE BETWEEN TO_DATE('''||K_FECINI||''',''DD/MM/YYYY'') AND TO_DATE('''||K_FECFIN||''',''DD/MM/YYYY'')';
END IF;

OPEN CUR_CANJE FOR STM_SQL;

BEGIN
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM  PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR=K_CODERROR;
EXCEPTION WHEN OTHERS THEN
    K_DESCERROR:='ERROR';
END;

EXCEPTION WHEN EX_ERROR THEN
       BEGIN
          SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
          FROM  PCLUB.ADMPT_ERRORES_CC
          WHERE ADMPN_COD_ERROR=K_CODERROR;
       EXCEPTION WHEN OTHERS THEN
          K_DESCERROR:='ERROR';
       END;
 WHEN OTHERS THEN
 K_CODERROR:=1;
 K_DESCERROR:=SUBSTR(SQLERRM, 1, 250);
END ADMPSS_PRODUCTOSCANJE_MV;

PROCEDURE ADMPSS_CONSTANCIACANJE_MV(K_IDCANJE IN NUMBER,
                                    K_CTO_ATEN OUT VARCHAR2,
                                    K_TIP_DOC OUT VARCHAR2,
                                    K_NUM_DOC OUT VARCHAR2,
                                    K_FEC OUT VARCHAR2,
                                    K_CSO_INT OUT VARCHAR2,
                                    K_NOTAS OUT VARCHAR2,
                                    K_NOMBRE OUT VARCHAR2,
                                    K_TIPCLIE OUT VARCHAR2,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2,
                                    CUR_CANJE OUT SYS_REFCURSOR) IS
EX_ERROR EXCEPTION;
V_COUNT_C NUMBER;
BEGIN
K_CODERROR:=0;
K_DESCERROR:=' ';

IF K_IDCANJE IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR:='El numero de canje no es válido';
    RAISE EX_ERROR;
END IF;
-- Cuantos registros tiene el mismo identificador de canje ( puede ser individual o paquete)
      SELECT   COUNT(*)
      INTO     V_COUNT_C
      FROM      PCLUB.ADMPT_CANJE
      WHERE    ADMPV_ID_CANJE = TO_NUMBER(K_IDCANJE);

      --Si no hay registros  (puede que no exista registros o puede ser que se paso un codigo incorrecto)
      IF V_COUNT_C = 0 THEN
        K_CODERROR := 28;
        K_DESCERROR := 'Canje = '|| K_IDCANJE;
        RAISE EX_ERROR;
      END IF;

      SELECT C.ADMPV_PTO_VENTA,
             D.ADMPV_DSC_DOCUM,
             F.ADMPV_NUM_DOC,
             TO_CHAR(C.ADMPD_FEC_CANJE, 'DD/MM/YYYY'),
             C.ADMPV_INTERACTID,
             '',
             F.ADMPV_APE_CLI || ' ' || F.ADMPV_NOM_CLI NOMBRE,
             T.ADMPV_TIPO TIPO

        INTO K_CTO_ATEN,
             K_TIP_DOC,
             K_NUM_DOC,
             K_FEC,
             K_CSO_INT,
             K_NOTAS,
             K_NOMBRE,
             K_TIPCLIE
        FROM PCLUB.ADMPT_CLIENTE F
             INNER JOIN PCLUB.ADMPT_CANJE          C ON (C.ADMPV_COD_CLI  = F.ADMPV_COD_CLI)
             INNER JOIN PCLUB.ADMPT_TIPO_DOC       D ON (F.ADMPV_TIPO_DOC = D.ADMPV_COD_TPDOC)
             INNER JOIN PCLUB.ADMPT_TIPO_CLIENTE   T ON (F.ADMPV_COD_TPOCL = T.ADMPV_COD_TPOCL)
        WHERE C.ADMPV_ID_CANJE =K_IDCANJE ;

      --SOLO CAMBIAR LA CANJE_DETALLE X FIJA
      OPEN CUR_CANJE FOR
      SELECT D.ADMPV_ID_CANJESEC CANJE_SEC,D.ADMPV_ID_PROCLA ID_PRODUCTO,P.ADMPV_DESC PRODUCTO,
             D.ADMPN_PUNTOS PUNTOS,D.ADMPN_CANTIDAD CANTIDAD,T.ADMPV_DESC DESCRIP,D.ADMPN_MNT_RECAR MONTO,
             D.ADMPN_PAGO PAGO
      FROM  PCLUB.ADMPT_CANJE_DETALLE D, PCLUB.ADMPT_PREMIO P, PCLUB.ADMPT_TIPO_PREMIO T
      WHERE D.ADMPV_ID_PROCLA=P.ADMPV_ID_PROCLA
      AND P.ADMPV_COD_TPOPR=T.ADMPV_COD_TPOPR
      AND D.ADMPV_ID_CANJE=K_IDCANJE;
     BEGIN
            SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
            FROM  PCLUB.ADMPT_ERRORES_CC
            WHERE ADMPN_COD_ERROR=K_CODERROR;
     EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='ERROR';
     END;

EXCEPTION
        WHEN EX_ERROR THEN
                 BEGIN
                        SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
                        FROM  PCLUB.ADMPT_ERRORES_CC
                        WHERE ADMPN_COD_ERROR=K_CODERROR;
                 EXCEPTION WHEN OTHERS THEN
                    K_DESCERROR:='ERROR';
                 END;
                 WHEN OTHERS THEN
                 K_CODERROR:=1;
                 K_DESCERROR:=SUBSTR(SQLERRM, 1, 250);
END ADMPSS_CONSTANCIACANJE_MV;

--****************************************************************
-- Nombre Function     :  F_OBTENERTIPODOC
-- Propósito           :  Obtiene el tipo de documento
-- Input               :  K_TIPODOC
-- Output              :  V_TIPODOC
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  26/02/2013
-- Fec Actualización   :
--****************************************************************

FUNCTION F_OBTENERTIPODOC(K_TIPO_DOC IN VARCHAR2) RETURN VARCHAR2 IS
 V_TIPO_DOC VARCHAR2(20);
BEGIN

  SELECT ADMPV_COD_TPDOC INTO V_TIPO_DOC
  FROM PCLUB.ADMPT_TIPO_DOC
  WHERE UPPER(ADMPV_EQU_DWH) = UPPER(K_TIPO_DOC)
        OR UPPER(ADMPV_COD_TPDOC) = UPPER(K_TIPO_DOC);

  RETURN V_TIPO_DOC;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END F_OBTENERTIPODOC;

--****************************************************************
-- Nombre Function     :  F_OBTENER_TBCLIENTE
-- Propósito           :  Obtiene el tipo de Bolsa(Fija o Móvil)
-- Input               :  K_TIPCLIE
-- Output              :  V_TIPCLIE
-- Fec Creación        :  28/05/2013
--****************************************************************

FUNCTION F_OBTENER_TBCLIENTE(K_TIPCLIE IN VARCHAR2) RETURN VARCHAR2 IS
 V_TIPCLIE VARCHAR2(20);
BEGIN

  SELECT ADMPC_TBLCLIENTE INTO V_TIPCLIE
  FROM  PCLUB.ADMPT_TIPO_CLIENTE
  WHERE ADMPV_COD_TPOCL = K_TIPCLIE;

  RETURN V_TIPCLIE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END F_OBTENER_TBCLIENTE;

--****************************************************************
-- Nombre SP           :  ADMPI_BLOQUEOBOLSA
-- Propósito           :  Permite Registrar el bloqueo de bolsa
-- Input               :  K_TIPO_DOC
--                        K_NUM_DOC
--                        K_TIPO_CLIE
--                        K_USUARIO
-- Output              :  K_ESTADO
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  25/02/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE ADMPI_BLOQUEOBOLSA(K_TIPO_DOC IN VARCHAR2,
                             K_NUM_DOC IN VARCHAR2,
                             K_TIPO_CLIE IN VARCHAR2,
                             K_USUARIO IN VARCHAR2,
                             K_ESTADO OUT CHAR,
                             K_CODERROR OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2) IS
--V_CONT NUMBER;
V_TIPO_DOC VARCHAR2(20);
V_TIPO_DOC_B VARCHAR2(20);
V_TB_CLIE  CHAR(1);
V_CONT_CM  NUMBER;
V_CONT_CF  NUMBER;
CURSOR CUR_TIPO_CLIE IS
SELECT ADMPV_COD_TPOCL
FROM PCLUB.ADMPT_TIPO_CLIENTE
WHERE ADMPC_ESTADO = 'A'
      AND ADMPV_PRVENTA IS NOT NULL;
V_TIPO_CLIE VARCHAR2(2);
EX_VALIDACION EXCEPTION;
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_TIPO_DOC  IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese un tipo de documento. '; RAISE EX_ERROR;
    WHEN K_NUM_DOC   IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese un número de documento. '; RAISE EX_ERROR;
    WHEN K_TIPO_CLIE IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese un tipo de cliente. '; RAISE EX_ERROR;
    WHEN K_TIPO_CLIE < 0     THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese un tipo de cliente válido. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  V_TIPO_DOC_B := F_OBTENERTIPODOC(K_TIPO_DOC);

  IF V_TIPO_DOC_B IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR := 'El tipo de documento no fue encontrado. ';
    RAISE EX_ERROR;
  END IF;

  IF K_TIPO_CLIE <> 0 THEN

      V_TB_CLIE := F_OBTENER_TBCLIENTE(K_TIPO_CLIE);

      IF V_TB_CLIE IS NULL THEN
        K_CODERROR := 4;
        K_DESCERROR := 'El tipo de Cliente ingresado, no es válido. ';
        RAISE EX_ERROR;
      ELSE
        IF V_TB_CLIE = 'M' THEN
            SELECT COUNT(1) INTO V_CONT_CM FROM PCLUB.ADMPT_CLIENTE
            WHERE ADMPV_TIPO_DOC = V_TIPO_DOC_B
            AND ADMPV_NUM_DOC = K_NUM_DOC
            AND ADMPC_ESTADO = 'A';

            IF V_CONT_CM = 0 THEN
              K_CODERROR := 4;
              K_DESCERROR := 'El Cliente no se encuentra registrado en ClaroClub. ';
              RAISE EX_ERROR;
            END IF;

        ELSIF V_TB_CLIE = 'F' THEN
            SELECT COUNT(1) INTO V_CONT_CF FROM PCLUB.ADMPT_CLIENTEFIJA
            WHERE ADMPV_TIPO_DOC = V_TIPO_DOC_B
            AND ADMPV_NUM_DOC = K_NUM_DOC
            AND ADMPC_ESTADO = 'A';

            IF V_CONT_CF = 0 THEN
              K_CODERROR := 4;
              K_DESCERROR := 'El Cliente no se encuentra registrado en ClaroClub. ';
              RAISE EX_ERROR;
            END IF;

        END IF;
      END IF;
  ELSE
    SELECT COUNT(1) INTO V_CONT_CM FROM PCLUB.ADMPT_CLIENTE
    WHERE ADMPV_TIPO_DOC = V_TIPO_DOC_B
    AND ADMPV_NUM_DOC = K_NUM_DOC
    AND ADMPC_ESTADO = 'A';

    SELECT COUNT(1) INTO V_CONT_CF FROM PCLUB.ADMPT_CLIENTEFIJA
    WHERE ADMPV_TIPO_DOC = V_TIPO_DOC_B
    AND ADMPV_NUM_DOC = K_NUM_DOC
    AND ADMPC_ESTADO = 'A';

    IF V_CONT_CM = 0 AND V_CONT_CF = 0 THEN
      K_CODERROR := 4;
      K_DESCERROR := 'El Cliente no se encuentra registrado en ClaroClub. ';
      RAISE EX_ERROR;
    END IF;
  END IF;

  ADMPS_VALBLOQUEOBOLSA(K_TIPO_DOC,K_NUM_DOC,K_TIPO_CLIE,V_TIPO_DOC,K_ESTADO,K_CODERROR,K_DESCERROR);

  IF K_CODERROR <> 0 THEN
    RAISE EX_VALIDACION;
  END IF;

  IF K_ESTADO = 'R' THEN
    K_CODERROR := 37;
    K_DESCERROR := 'Existe un canje en proceso. ';
    RAISE EX_ERROR;
  END IF;

  IF K_ESTADO = 'L' THEN
    IF K_TIPO_CLIE = 0 THEN
      OPEN CUR_TIPO_CLIE;
      FETCH CUR_TIPO_CLIE INTO V_TIPO_CLIE;

      WHILE CUR_TIPO_CLIE%FOUND LOOP
        INSERT INTO PCLUB.ADMPT_CLIE_ESTADO_BOLSA (ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_COD_TPOCL,ADMPC_ESTADO,ADMPV_USU_REG,ADMPD_FEC_REG)
        VALUES(V_TIPO_DOC,K_NUM_DOC,V_TIPO_CLIE,'R',K_USUARIO,SYSDATE());
        FETCH CUR_TIPO_CLIE INTO V_TIPO_CLIE;
      END LOOP;
      CLOSE CUR_TIPO_CLIE;
    ELSE
      INSERT INTO PCLUB.ADMPT_CLIE_ESTADO_BOLSA (ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_COD_TPOCL,ADMPC_ESTADO,ADMPV_USU_REG,ADMPD_FEC_REG)
      VALUES(V_TIPO_DOC,K_NUM_DOC,K_TIPO_CLIE,'R',K_USUARIO,SYSDATE());
    END IF;
  END IF;

  COMMIT;

EXCEPTION
  WHEN EX_ERROR THEN
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
      FROM PCLUB.ADMPT_ERRORES_CC
      WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION WHEN OTHERS THEN
      K_DESCERROR := '';
    END;
  WHEN EX_VALIDACION THEN
    K_CODERROR := K_CODERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR = K_CODERROR;
END ADMPI_BLOQUEOBOLSA;

--****************************************************************
-- Nombre SP           :  ADMPU_LIBBLOQUEOBOLSA
-- Propósito           :  Permite actualizar el bloqueo de bolsa
-- Input               :  K_TIPO_DOC
--                        K_NUM_DOC
--                        K_TIPO_CLIE
--                        K_USUARIO
-- Output              :  K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  25/02/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC IN VARCHAR2,
                                K_NUM_DOC IN VARCHAR2,
                                K_TIPO_CLIE IN VARCHAR2,
                                --K_USUARIO IN VARCHAR2,
                                K_CODERROR OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2) IS
V_CONT NUMBER;
V_TIPO_DOC VARCHAR(20);
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_TIPO_DOC  IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese un tipo de documento. '; RAISE EX_ERROR;
    WHEN K_NUM_DOC   IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese un número de documento. '; RAISE EX_ERROR;
    WHEN K_TIPO_CLIE IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese un tipo de cliente. '; RAISE EX_ERROR;
    WHEN K_TIPO_CLIE < 0     THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese un tipo de cliente válido. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  V_TIPO_DOC := F_OBTENERTIPODOC(K_TIPO_DOC);

  IF V_TIPO_DOC IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR := 'El tipo de documento no fue encontrado. ';
    RAISE EX_ERROR;
  END IF;

  IF K_TIPO_CLIE = 0 THEN
    DELETE FROM  PCLUB.ADMPT_CLIE_ESTADO_BOLSA A
    WHERE A.ADMPV_TIPO_DOC = V_TIPO_DOC
        AND A.ADMPV_NUM_DOC = K_NUM_DOC
        AND EXISTS
        ( SELECT 1 FROM PCLUB.ADMPT_TIPO_CLIENTE B
          WHERE B.ADMPV_PRVENTA IS NOT NULL
          AND  A.ADMPV_COD_TPOCL=B.ADMPV_COD_TPOCL);
  ELSE
    SELECT COUNT(ADMPV_COD_TPOCL) INTO V_CONT
    FROM PCLUB.ADMPT_TIPO_CLIENTE
    WHERE ADMPV_COD_TPOCL = K_TIPO_CLIE;

    IF V_CONT < 1 THEN
      K_CODERROR := 4;
      K_DESCERROR := 'El tipo de cliente no fue encontrado. ';
      RAISE EX_ERROR;
    END IF;

    DELETE FROM PCLUB.ADMPT_CLIE_ESTADO_BOLSA
    WHERE ADMPV_TIPO_DOC = V_TIPO_DOC
          AND ADMPV_NUM_DOC = K_NUM_DOC
          AND ADMPV_COD_TPOCL = K_TIPO_CLIE;
  END IF;

  --COMMIT;

EXCEPTION
  WHEN EX_ERROR THEN
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
      FROM PCLUB.ADMPT_ERRORES_CC
      WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION WHEN OTHERS THEN
      K_DESCERROR := '';
    END;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR = K_CODERROR;
END ADMPU_LIBBLOQUEOBOLSA;

--****************************************************************
-- Nombre SP           :  ADMPS_VALBLOQUEOBOLSA
-- Propósito           :  Permite Validar el bloqueo de bolsa
-- Input               :  K_TIPO_DOC
--                        K_NUM_DOC
--                        K_TIPO_CLIE
-- Output              :  K_ESTADO
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  25/02/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE ADMPS_VALBLOQUEOBOLSA(K_TIPO_DOC IN VARCHAR2,
                                K_NUM_DOC IN VARCHAR2,
                                K_TIPO_CLIE IN VARCHAR2,
                                K_TIPO_DOC2 OUT VARCHAR2,
                                K_ESTADO OUT CHAR,
                                K_CODERROR OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2) IS
V_CONT NUMBER := 0;
V_CONT_PRVTA NUMBER := 0;
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_TIPO_DOC  IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese un tipo de documento. '; RAISE EX_ERROR;
    WHEN K_NUM_DOC   IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese un número de documento. '; RAISE EX_ERROR;
    WHEN K_TIPO_CLIE IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese un tipo de cliente. '; RAISE EX_ERROR;
    WHEN K_TIPO_CLIE < 0     THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese un tipo de cliente válido. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  K_TIPO_DOC2 := F_OBTENERTIPODOC(K_TIPO_DOC);

  IF K_TIPO_DOC2 IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR := 'El tipo de documento no fue encontrado. ';
    RAISE EX_ERROR;
  END IF;

  IF K_TIPO_CLIE > 0 THEN
    SELECT COUNT(1) INTO V_CONT
    FROM PCLUB.ADMPT_TIPO_CLIENTE
    WHERE ADMPV_COD_TPOCL = K_TIPO_CLIE;

    IF V_CONT < 1 THEN
      K_CODERROR := 4;
      K_DESCERROR := 'El tipo de cliente no fue encontrado. ';
      RAISE EX_ERROR;
    END IF;
  END IF;

  IF K_TIPO_CLIE = 0 THEN
    SELECT COUNT(1) INTO V_CONT
    FROM  PCLUB.ADMPT_CLIE_ESTADO_BOLSA A, PCLUB.ADMPT_TIPO_CLIENTE B
    WHERE A.ADMPV_COD_TPOCL=B.ADMPV_COD_TPOCL
    AND B.ADMPV_PRVENTA IS NOT NULL
    AND ADMPV_TIPO_DOC = K_TIPO_DOC2
    AND ADMPV_NUM_DOC = K_NUM_DOC;
  ELSE
    SELECT COUNT(1) INTO V_CONT
    FROM PCLUB.ADMPT_CLIE_ESTADO_BOLSA
    WHERE ADMPV_TIPO_DOC = K_TIPO_DOC2
          AND ADMPV_NUM_DOC = K_NUM_DOC
          AND ADMPV_COD_TPOCL = K_TIPO_CLIE;
  END IF;

  IF V_CONT = 0 THEN
    K_ESTADO := 'L';
  ELSE
    K_ESTADO := 'R';
  END IF;

EXCEPTION
  WHEN EX_ERROR THEN
  BEGIN
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR = K_CODERROR;
  EXCEPTION WHEN OTHERS THEN
    K_DESCERROR := '';
  END;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR = K_CODERROR;
END ADMPS_VALBLOQUEOBOLSA;

PROCEDURE ADMPSS_VALIDA_CANJEPTOS(K_TIPO_DOC    IN VARCHAR2,
                                    K_NUM_DOC     IN VARCHAR2,
                                    K_COD_CLIENTE IN VARCHAR2,
                                    K_TIP_CLI     IN VARCHAR2,
                                    K_TIPCANJE    IN NUMBER,
                                    K_TIPPRECANJE IN NUMBER,
                                    K_PTOS_TOT    IN NUMBER,
                                    K_SALDOPTO    OUT NUMBER,
                                    K_CODERROR    OUT NUMBER,
                                    K_MSJERROR    OUT VARCHAR2) IS

    -- Variables
    V_SALDO_IB      NUMBER := 0;
    V_SALDO_CC      NUMBER := 0;
    V_SALDO_CLIBONO NUMBER := 0;
    NO_CLIENTE EXCEPTION;
    NO_SALDO EXCEPTION;
    EX_ERROR EXCEPTION;
    NO_DATOS_VALIDOS EXCEPTION;
    V_SALDO    NUMBER := 0;
    V_EXISTE   NUMBER;
    V_TIPO_DOC VARCHAR2(100);

  BEGIN

    CASE
      WHEN K_TIPO_DOC IS NULL THEN
        K_CODERROR := 4;
        K_MSJERROR := 'Ingrese el tipo de documento. ';
        RAISE EX_ERROR;
      WHEN K_NUM_DOC IS NULL THEN
        K_CODERROR := 4;
        K_MSJERROR := 'Ingrese el número de documento. ';
        RAISE EX_ERROR;
      WHEN K_COD_CLIENTE IS NULL THEN
        K_CODERROR := 4;
        K_MSJERROR := 'Ingrese el código de Cliente. ';
        RAISE EX_ERROR;
      WHEN K_TIP_CLI IS NULL THEN
        K_CODERROR := 4;
        K_MSJERROR := 'Ingrese el tipo de Cliente. ';
        RAISE EX_ERROR;
      WHEN K_PTOS_TOT IS NULL THEN
        K_CODERROR := 4;
        K_MSJERROR := 'Ingrese el total de puntos a canjear. ';
        RAISE EX_ERROR;
      WHEN (K_TIPCANJE IS NOT NULL AND K_TIPPRECANJE IS NULL) THEN
        K_CODERROR := 4;
        K_MSJERROR := 'Ingrese el tipo de premio a canjear. ';
        RAISE EX_ERROR;
      ELSE
        K_CODERROR := 0;
        K_MSJERROR := ' ';
    END CASE;

    BEGIN

      --Obtengo el Tipo de Documento
      V_TIPO_DOC := F_OBTENERTIPODOC(K_TIPO_DOC);

      /*Validamos que se trate de un Cliente válido*/
      SELECT count(1)
        INTO V_EXISTE
        FROM PCLUB.admpt_cliente
       WHERE admpv_cod_cli = K_COD_CLIENTE
         AND admpv_tipo_doc = V_TIPO_DOC
         AND admpv_num_doc = K_NUM_DOC
         AND admpc_estado = 'A';

      IF V_EXISTE = 0 THEN
        K_CODERROR := 49;
        RAISE NO_DATOS_VALIDOS;
      END IF;

      --Primero valido que exista el Cliente en ClaroClub
      SELECT COUNT(1)
        INTO V_EXISTE
        FROM PCLUB.admpt_cliente
       WHERE admpv_cod_cli = K_COD_CLIENTE
         AND ADMPV_COD_TPOCL = K_TIP_CLI
         AND admpc_estado = 'A';

      IF V_EXISTE = 0 THEN
        K_CODERROR := 6;
        RAISE NO_CLIENTE;
      ELSE
        --Prepago
        IF K_TIP_CLI = '3' THEN
          IF K_TIPCANJE = 1 THEN
            BEGIN
              SELECT SUM(NVL(SC.ADMPN_SALDO_CC, 0)),
                     SUM(CASE
                           WHEN NVL(SC.ADMPC_ESTPTO_IB, 0) = 'A' THEN
                            NVL(SC.ADMPN_SALDO_IB, 0)
                           ELSE
                            0
                         END)
                INTO V_SALDO_IB, V_SALDO_CC
                FROM PCLUB.ADMPT_CLIENTE C
               INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTE SC
                  ON C.ADMPV_COD_CLI = SC.ADMPV_COD_CLI
               WHERE (C.ADMPV_TIPO_DOC = V_TIPO_DOC AND
                     C.ADMPV_NUM_DOC = K_NUM_DOC)
                 AND C.ADMPC_ESTADO = 'A'
                 AND C.ADMPV_COD_TPOCL = K_TIP_CLI
                 AND SC.ADMPC_ESTPTO_CC = 'A';

              IF V_SALDO_CC IS NULL THEN
                V_SALDO_CC := 0;
              END IF;
              IF V_SALDO_IB IS NULL THEN
                V_SALDO_IB := 0;
              END IF;

              --Obtengo la Suma de Saldo Cliente Bono
              SELECT NVL(SUM(SB.ADMPN_SALDO), 0)
                INTO V_SALDO_CLIBONO
                FROM PCLUB.ADMPT_SALDOS_BONO_CLIENTE SB
               WHERE SB.ADMPV_COD_CLI = K_COD_CLIENTE
                 AND SB.ADMPN_GRUPO = K_TIPPRECANJE;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                V_SALDO_IB      := 0;
                V_SALDO_CC      := 0;
                V_SALDO_CLIBONO := 0;
            END;
          ELSE
            BEGIN
              SELECT SUM(NVL(SC.ADMPN_SALDO_CC, 0)),
                     SUM(CASE
                           WHEN NVL(SC.ADMPC_ESTPTO_IB, 0) = 'A' THEN
                            NVL(SC.ADMPN_SALDO_IB, 0)
                           ELSE
                            0
                         END)
                INTO V_SALDO_IB, V_SALDO_CC
                FROM PCLUB.ADMPT_CLIENTE C
               INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTE SC
                  ON C.ADMPV_COD_CLI = SC.ADMPV_COD_CLI
               WHERE (C.ADMPV_TIPO_DOC = V_TIPO_DOC AND
                     C.ADMPV_NUM_DOC = K_NUM_DOC)
                 AND C.ADMPC_ESTADO = 'A'
                 AND C.ADMPV_COD_TPOCL = K_TIP_CLI
                 AND SC.ADMPC_ESTPTO_CC = 'A';

              IF V_SALDO_CC IS NULL THEN
                V_SALDO_CC := 0;
              END IF;
              IF V_SALDO_IB IS NULL THEN
                V_SALDO_IB := 0;
              END IF;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                V_SALDO_IB := 0;
                V_SALDO_CC := 0;
            END;
          END IF;
        ELSIF K_TIP_CLI = '8' THEN
          BEGIN
            SELECT SUM(NVL(SC.ADMPN_SALDO_CC, 0)),
                   SUM(CASE
                         WHEN NVL(SC.ADMPC_ESTPTO_IB, 0) = 'A' THEN
                          NVL(SC.ADMPN_SALDO_IB, 0)
                         ELSE
                          0
                       END)
              INTO V_SALDO_IB, V_SALDO_CC
              FROM PCLUB.ADMPT_CLIENTE C
             INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTE SC
                ON C.ADMPV_COD_CLI = SC.ADMPV_COD_CLI
             WHERE (C.ADMPV_TIPO_DOC = V_TIPO_DOC AND
                   C.ADMPV_NUM_DOC = K_NUM_DOC)
               AND C.ADMPC_ESTADO = 'A'
               AND C.ADMPV_COD_TPOCL = K_TIP_CLI
               AND SC.ADMPC_ESTPTO_CC = 'A';

            IF V_SALDO_CC IS NULL THEN
              V_SALDO_CC := 0;
            END IF;
            IF V_SALDO_IB IS NULL THEN
              V_SALDO_IB := 0;
            END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              V_SALDO_IB := 0;
              V_SALDO_CC := 0;
          END;
        ELSE
          --Postpago
          IF (K_TIP_CLI = '2' OR K_TIP_CLI = '1') THEN
            BEGIN
              SELECT SUM(NVL(SC.ADMPN_SALDO_CC, 0)),
                     SUM(CASE
                           WHEN NVL(SC.ADMPC_ESTPTO_IB, 0) = 'A' THEN
                            NVL(SC.ADMPN_SALDO_IB, 0)
                           ELSE
                            0
                         END)
                INTO V_SALDO_IB, V_SALDO_CC
                FROM PCLUB.ADMPT_CLIENTE C
               INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTE SC
                  ON C.ADMPV_COD_CLI = SC.ADMPV_COD_CLI
               WHERE (C.ADMPV_TIPO_DOC = V_TIPO_DOC AND
                     C.ADMPV_NUM_DOC = K_NUM_DOC)
                 AND C.ADMPC_ESTADO = 'A'
                 AND (C.ADMPV_COD_TPOCL = 1 OR C.ADMPV_COD_TPOCL = 2)
                 AND SC.ADMPC_ESTPTO_CC = 'A';

              IF V_SALDO_CC IS NULL THEN
                V_SALDO_CC := 0;
              END IF;
              IF V_SALDO_IB IS NULL THEN
                V_SALDO_IB := 0;
              END IF;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                V_SALDO_IB := 0;
                V_SALDO_CC := 0;
            END;
          END IF;
        END IF;
      END IF;

    END;

    V_SALDO    := V_SALDO_CC + V_SALDO_IB + V_SALDO_CLIBONO;
    K_SALDOPTO := V_SALDO;

    --Validamos que los puntos que desea canjear no sean mayores que su saldo
    IF K_PTOS_TOT = V_SALDO OR K_PTOS_TOT < V_SALDO THEN
      K_CODERROR := 0;
      K_MSJERROR := '';
    ELSE
      K_CODERROR := 24;
      RAISE NO_SALDO;
    END IF;

    /* *************************************************************************** */
  EXCEPTION
    WHEN EX_ERROR THEN
      BEGIN
        SELECT ADMPV_DES_ERROR || K_MSJERROR
          INTO K_MSJERROR
          FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_MSJERROR := 'ERROR';
      END;
    WHEN NO_SALDO THEN
      BEGIN
        SELECT ADMPV_DES_ERROR
          INTO K_MSJERROR
          FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_MSJERROR := 'ERROR';
      END;
    WHEN NO_CLIENTE THEN
      BEGIN
        SELECT ADMPV_DES_ERROR
          INTO K_MSJERROR
          FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_MSJERROR := 'ERROR';
      END;
    WHEN NO_DATOS_VALIDOS THEN
      K_CODERROR := K_CODERROR;
      K_MSJERROR := 'Incongruencia con los datos del Cliente';
    WHEN OTHERS THEN
      K_CODERROR := SQLCODE;
      K_MSJERROR := SUBSTR(SQLERRM, 1, 400);

  END ADMPSS_VALIDA_CANJEPTOS;

	PROCEDURE ADMPU_ACT_MASIVA(Tx_CODE     IN VARCHAR2,
                           K_USUARIO   IN VARCHAR2,
                           K_CODERROR  OUT NUMBER,
                           K_DESCERROR OUT VARCHAR2,
                           K_TOT_REG   OUT NUMBER,
                           K_TOT_PRO   OUT NUMBER,
                           K_TOT_ERR   OUT NUMBER) IS
  --****************************************************************
  -- Nombre SP           :  ADMPU_ACT_DATOSCLIE
  -- Propósito           :  Actualizacion de Clientes Postpago y Prepago
  --
  -- Input               :  Tx_CODE - Tipo de Linea
  --
  -- Output              :  K_CODERROR - Codigo de Error o Exito
  --                        K_DESCERROR - Descripcion del Error (si se presento)
  -- Creado por          :  Evelyn Sosa Cabillas
  -- Fec Creacion        :  11/10/2013
  --****************************************************************
  --VARIABLES PARA LOS CURSORES
  --C_SEC        NUMBER;
  C_COD_CLI    VARCHAR2(50);
  C_PHONE      VARCHAR2(20); -- SOLO PREPAGO
  C_FIRST_NAME VARCHAR2(50);
  C_LAST_NAME  VARCHAR2(50);

  C_TIPO_DOC     VARCHAR2(60); --SOLO CURSOR POST
  C_TIPO_DOC_PRE VARCHAR2(60); --SOLO CURSOR PRE
  C_TIPO_CODE    VARCHAR2(60);
  C_NUM_DOC      VARCHAR2(60);
  TIPO_DOC_CC    VARCHAR2(60);

  ERRORDATONUM EXCEPTION;
  ERRORDATOFIRST_NAME EXCEPTION;
  ERRORDATOLAST_NAME EXCEPTION;
  EX_ERROR EXCEPTION;
  EXISTE_CLI NUMBER;
  EXISTE_DOC  NUMBER;
  --V_COUNT_ERR NUMBER;
  V_CODERROR  NUMBER;
  V_DESCERROR VARCHAR2(100);

  --Cursor para postpago
  CURSOR CURSORACTCLIENTEPREP IS
    SELECT i.PHONE,
           c.X_FIRST_NAME,
           c.X_LAST_NAME,
           i.X_TIPO_CODE,
           c.x_document_number,
           c.x_Type_DocumenT
      FROM SA.table_interact@DBL_CLARIFY i, SA.TABLE_X_PLUS_INTER@DBL_CLARIFY c
     WHERE i.OBJID = c.X_PLUS_INTER2INTERACT
       AND I.S_REASON_1 = 'PREPAGO'
       AND I.S_REASON_2 = 'VARIACIÓN - ESTADO DE LA LÍNEA/CLIENTE'
       AND I.S_REASON_3 = 'REGISTRO / ACTUALIZACIÓN DE DATOS'
       AND I.X_SUBCLASE_CODE = '109516'
       AND I.CREATE_DATE > TRUNC(SYSDATE - 1)
       AND I.CREATE_DATE < TRUNC(SYSDATE)
     ORDER BY I.PHONE, I.OBJID;

  --Cursor para prepago
  CURSOR CURSORACTCLIENTEPOST IS
    SELECT i.PHONE,
           c.X_FIRST_NAME,
           c.X_LAST_NAME,
           i.X_TIPO_CODE,
           c.x_document_number,
           CASE
             WHEN LENGTH(c.X_DOCUMENT_NUMBER) = '8' THEN
              'DNI'
             ELSE
              'RUC'
           END AS TIPO_DOC
      FROM SA.table_interact@DBL_CLARIFY i, SA.TABLE_X_PLUS_INTER@DBL_CLARIFY c
     WHERE i.OBJID = c.X_PLUS_INTER2INTERACT
       AND I.S_REASON_1 = 'POSTPAGO'
       AND I.S_REASON_2 = 'VARIACIÓN - ESTADO DE LA LÍNEA/CLIENTE'
       AND I.S_REASON_3 = 'CAMBIO DE NOMBRE'
       AND I.X_SUBCLASE_CODE = '123415'
       AND I.CREATE_DATE > TRUNC(SYSDATE - 1)
       AND I.CREATE_DATE < TRUNC(SYSDATE)
     ORDER BY I.PHONE, I.OBJID;

BEGIN
  K_CODERROR  := 0;
  K_DESCERROR := '';
  K_TOT_PRO   := 0;
  K_TOT_ERR   := 0;
  K_TOT_REG   := 0;
  V_CODERROR  := 0;

  IF Tx_CODE IS NULL THEN
    K_CODERROR  := 4;
    K_DESCERROR := ' No se Ingreso el codigo de Transaccion';
  END IF;

EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT= ''DD/MM/RRRR'' ';

  IF Tx_CODE = '2' THEN --Postpago
    OPEN CURSORACTCLIENTEPOST;

    FETCH CURSORACTCLIENTEPOST INTO C_PHONE,C_FIRST_NAME,C_LAST_NAME,C_TIPO_CODE,C_NUM_DOC,C_TIPO_DOC;

    IF (CURSORACTCLIENTEPOST%rowcount > 0) THEN

      WHILE CURSORACTCLIENTEPOST%FOUND LOOP
        TIPO_DOC_CC := F_OBTENERTIPODOC(C_TIPO_DOC);
        CASE
          WHEN C_NUM_DOC IS NULL THEN
            V_CODERROR  := 4;
            V_DESCERROR := 'El número de documento es null';
          WHEN C_FIRST_NAME IS NULL THEN
            V_CODERROR  := 4;
            V_DESCERROR := 'El nombre del cliente es null';
          WHEN C_LAST_NAME IS NULL THEN
            V_CODERROR  := 4;
            V_DESCERROR := 'El apellido del cliente es null';
         ELSE
            V_CODERROR  := 0;
            V_DESCERROR := '';
        END CASE;
      IF V_CODERROR = 4 THEN
				 C_COD_CLI:=NULL;
         INSERT INTO PCLUB.admpt_imp_actclientes_post(admpn_seq,
                                               admpv_cod_cliente,
                                               admpv_first_name,
                                               admpv_last_name,
                                               admpv_tipo_doc,
                                               admpv_tipo_linea,
                                               admpv_cod_error,
                                               admpv_msje_error,
                                               admpd_fec_reg,
                                               admpv_num_doc,
                                               admpv_num_phone)
         VALUES (ADMPT_IMP_ACTCLIENTES_POST_SQ.NEXTVAL,
                C_COD_CLI,
                C_FIRST_NAME,
                C_LAST_NAME,
                C_TIPO_DOC,
                C_TIPO_CODE,
                V_CODERROR,
                V_DESCERROR,
                SYSDATE,
                C_NUM_DOC,
                C_PHONE);
      ELSE
        EXISTE_DOC := 0;
        EXISTE_CLI:=0;
        --sacamos el cod id del cliente DE DWH
        --BEGIN
          /*SELECT COUNT(1)INTO EXISTE_DOC
          FROM  ADMPT_CLIENTE
          WHERE ADMPV_NUM_DOC=C_NUM_DOC;*/
            select count (A.CUSTCODE) into EXISTE_CLI
            from DM.ods_postpago_contratos@dbl_reptdm_d a
            where a.idestadoultmod in (1, 3)
            and a.msisdn = '51' || C_PHONE;

        IF EXISTE_CLI = 0  THEN
          V_CODERROR  := 4;
          V_DESCERROR := 'EL cliente no existe en DWH';
          --insertar
					 C_COD_CLI:=NULL;
           INSERT INTO PCLUB.admpt_imp_actclientes_post (admpn_seq,
                                                      admpv_cod_cliente,
                                                      admpv_first_name,
                                                      admpv_last_name,
                                                      admpv_tipo_doc,
                                                      admpv_tipo_linea,
                                                      admpv_cod_error,
                                                      admpv_msje_error,
                                                      admpd_fec_reg,
                                                      admpv_num_doc,
                                                      admpv_num_phone)
              VALUES(ADMPT_IMP_ACTCLIENTES_POST_SQ.NEXTVAL,
                     C_COD_CLI,
                     C_FIRST_NAME,
                     C_LAST_NAME,
                     C_TIPO_DOC,
                     C_TIPO_CODE,
                     V_CODERROR,
                     V_DESCERROR,
                     SYSDATE,
                     C_NUM_DOC,
                     C_PHONE);
             commit;
        ELSE

          select A.CUSTCODE into C_COD_CLI
            from DM.ods_postpago_contratos@dbl_reptdm_d a
            where a.idestadoultmod in (1, 3)
            and a.msisdn = '51' || C_PHONE;

          --validar si existe en claro club la cuenta Y Ey esta activa
          SELECT COUNT(1)INTO EXISTE_DOC
          FROM  PCLUB.ADMPT_CLIENTE
          WHERE ADMPV_COD_CLI=C_COD_CLI
          AND ADMPC_ESTADO='A';

          IF EXISTE_DOC = 0 THEN
             V_CODERROR  := 4;
             V_DESCERROR := 'El Cliente no existe en ClaroClub.';
             --V_COUNT_ERR := V_COUNT_ERR + 1;
           --insertar
              INSERT INTO PCLUB.admpt_imp_actclientes_post (admpn_seq,
                                                      admpv_cod_cliente,
                                                      admpv_first_name,
                                                      admpv_last_name,
                                                      admpv_tipo_doc,
                                                      admpv_tipo_linea,
                                                      admpv_cod_error,
                                                      admpv_msje_error,
                                                      admpd_fec_reg,
                                                      admpv_num_doc,
                                                      admpv_num_phone)
              VALUES(ADMPT_IMP_ACTCLIENTES_POST_SQ.NEXTVAL,
                     C_COD_CLI,
                     C_FIRST_NAME,
                     C_LAST_NAME,
                     C_TIPO_DOC,
                     C_TIPO_CODE,
                     V_CODERROR,
                     V_DESCERROR,
                     SYSDATE,
                     C_NUM_DOC,
                     C_PHONE);
             commit;
           ELSE
              UPDATE PCLUB.ADMPT_CLIENTE c
              SET ADMPV_NOM_CLI  = C_FIRST_NAME,
                 ADMPV_APE_CLI  = C_LAST_NAME,
                 ADMPV_TIPO_DOC = TIPO_DOC_CC,
                 ADMPV_NUM_DOC = C_NUM_DOC,
                 c.admpd_fec_mod=sysdate,
                 c.admpv_usu_mod= K_USUARIO
              WHERE ADMPV_COD_CLI = C_COD_CLI;
              commit;
              INSERT INTO PCLUB.admpt_imp_actclientes_post (admpn_seq,
                                                      admpv_cod_cliente,
                                                      admpv_first_name,
                                                      admpv_last_name,
                                                      admpv_tipo_doc,
                                                      admpv_tipo_linea,
                                                      admpd_fec_reg,
                                                      admpv_num_doc,
                                                      admpv_num_phone)
              VALUES(ADMPT_IMP_ACTCLIENTES_POST_SQ.NEXTVAL,
                     C_COD_CLI,
                     C_FIRST_NAME,
                     C_LAST_NAME,
                     C_TIPO_DOC,
                     C_TIPO_CODE,
                     SYSDATE,
                     C_NUM_DOC,
                     C_PHONE);
             commit;
              K_TOT_REG:= K_TOT_REG + 1;
             END IF;

      --FETCH CURSORACTCLIENTEPOST INTO C_COD_CLI,C_FIRST_NAME,C_LAST_NAME,
      -- C_TIPO_CODE,C_NUM_DOC,C_TIPO_DOC;
         END IF;
        END IF;
       FETCH CURSORACTCLIENTEPOST INTO C_PHONE,C_FIRST_NAME,C_LAST_NAME,C_TIPO_CODE,C_NUM_DOC,C_TIPO_DOC;
      END LOOP;
    -- select count(1) into K_TOT_PRO from admpt_imp_actclientes_post p where TRUNC(p.admpd_fec_reg)=TRUNC(sysdate);
      SELECT COUNT(1) into K_TOT_PRO
      FROM  PCLUB.ADMPT_IMP_ACTCLIENTES_POST P WHERE P.ADMPD_FEC_REG >=trunc(SYSDATE)
      and  P.ADMPD_FEC_REG <=TO_DATE((TRUNC(SYSDATE)||' 23:59:59'),'dd/mm/yyyy hh24:mi:ss');
     K_TOT_ERR:=K_TOT_PRO-K_TOT_REG;
    ELSE
      K_CODERROR:=36;
      K_DESCERROR:='No hay datos ha Procesar';
    END IF;

    CLOSE CURSORACTCLIENTEPOST;



  ELSIF Tx_CODE = '3' THEN --Prepago

    OPEN CURSORACTCLIENTEPREP;
    FETCH CURSORACTCLIENTEPREP INTO C_PHONE,C_FIRST_NAME,C_LAST_NAME,C_TIPO_CODE,C_NUM_DOC,C_TIPO_DOC_PRE;

    IF (CURSORACTCLIENTEPREP%rowcount > 0) THEN
      WHILE CURSORACTCLIENTEPREP%FOUND LOOP

          /*K_TOT_REG   := K_TOT_REG + 1;
          V_COUNT_ERR := 0;*/
          TIPO_DOC_CC := F_OBTENERTIPODOC(C_TIPO_DOC_PRE);
        CASE
          WHEN C_PHONE IS NULL THEN
            --V_COUNT_ERR := V_COUNT_ERR + 1;
            V_CODERROR  := 4;
            V_DESCERROR := 'El número de linea es null';
          WHEN C_FIRST_NAME IS NULL THEN
            --V_COUNT_ERR := V_COUNT_ERR + 1;
            V_CODERROR  := 4;
            V_DESCERROR := 'El nombre del cliente es null';
          WHEN C_LAST_NAME IS NULL THEN
            --V_COUNT_ERR := V_COUNT_ERR + 1;
            V_CODERROR  := 4;
            V_DESCERROR := 'El apellido del cliente es null';
          WHEN C_NUM_DOC IS NULL THEN
            --V_COUNT_ERR := V_COUNT_ERR + 1;
            V_CODERROR  := 4;
            V_DESCERROR := 'El numero documento del cliente es null';
          WHEN C_TIPO_DOC_PRE IS NULL THEN
            --V_COUNT_ERR := V_COUNT_ERR + 1;
            V_CODERROR  := 4;
            V_DESCERROR := 'El tipo de documento del cliente es null';
          ELSE
            V_CODERROR  := 0;
            V_DESCERROR := '';
        END CASE;

      IF V_CODERROR = 4 THEN
        INSERT INTO PCLUB.admpt_imp_actclientes_pre(admpn_seq,
                                              admpv_cod_cliente,
                                              admpv_first_name,
                                              admpv_last_name,
                                              admpv_tipo_linea,
                                              admpv_num_doc,
                                              admpv_tipo_doc,
                                              admpv_cod_error,
                                              admpv_msje_error,
                                              admpd_fec_reg,
                                              admpv_num_phone)
        VALUES(ADMPT_IMP_ACTCLIENTES_PRE_SQ.NEXTVAL,
               C_PHONE,
               C_FIRST_NAME,
               C_LAST_NAME,
               C_TIPO_CODE,
               C_NUM_DOC,
               C_TIPO_DOC_PRE,
               V_CODERROR,
               V_DESCERROR,
               SYSDATE,
               C_PHONE);
        commit;
       ELSE
        --Verificamos si la Linea existe
           EXISTE_DOC := 0;
        --BEGIN
            SELECT COUNT(1)
            INTO EXISTE_DOC
            FROM PCLUB.ADMPT_CLIENTE
            WHERE ADMPV_COD_CLI = C_PHONE
            AND ADMPC_ESTADO='A'
            AND admpv_cod_tpocl='3';
        /*EXCEPTION
          WHEN NO_DATA_FOUND THEN
            EXISTE_DOC := 0;
        END;*/
            IF EXISTE_DOC = 0 THEN
               V_CODERROR  := 4;
               V_DESCERROR := 'El Cliente no existe en ClaroClub.';
               --insert
               INSERT INTO PCLUB.admpt_imp_actclientes_pre (admpn_seq,
                                                      admpv_cod_cliente,
                                                      admpv_first_name,
                                                      admpv_last_name,
                                                      admpv_tipo_linea,
                                                      admpv_num_doc,
                                                      admpv_tipo_doc,
                                                      admpv_cod_error,
                                                      admpv_msje_error,
                                                      admpd_fec_reg,
                                                      admpv_num_phone)
               VALUES (ADMPT_IMP_ACTCLIENTES_PRE_SQ.NEXTVAL,
                      C_PHONE,
                      C_FIRST_NAME,
                      C_LAST_NAME,
                      C_TIPO_CODE,
                      C_NUM_DOC,
                      C_TIPO_DOC_PRE,
                      V_CODERROR,
                      V_DESCERROR,
                      SYSDATE,
											C_PHONE);
               commit;
             ELSE

               UPDATE PCLUB.ADMPT_CLIENTE
               SET ADMPV_NUM_DOC  = C_NUM_DOC,
                   ADMPV_NOM_CLI  = C_FIRST_NAME,
                   ADMPV_APE_CLI  = C_LAST_NAME,
                   ADMPV_TIPO_DOC = TIPO_DOC_CC,
                   admpd_fec_mod=sysdate,
                   admpv_usu_mod= K_USUARIO
               WHERE ADMPV_COD_CLI = C_PHONE;
               commit;

               INSERT INTO PCLUB.admpt_imp_actclientes_pre (admpn_seq,
                                                      admpv_cod_cliente,
                                                      admpv_first_name,
                                                      admpv_last_name,
                                                      admpv_tipo_linea,
                                                      admpv_num_doc,
                                                      admpv_tipo_doc,
                                                      admpd_fec_reg,
                                                      admpv_num_phone)
                                               VALUES (ADMPT_IMP_ACTCLIENTES_PRE_SQ.NEXTVAL,
                                                      C_PHONE,
                                                      C_FIRST_NAME,
                                                      C_LAST_NAME,
                                                      C_TIPO_CODE,
                                                      C_NUM_DOC,
                                                      C_TIPO_DOC_PRE,
                                                      SYSDATE,
                                                      C_PHONE);
                                                      K_TOT_REG:= K_TOT_REG + 1;
              commit;
           END IF;
        END IF;

        --FETCH CURSORACTCLIENTEPREP INTO C_SEC,C_PHONE,C_FIRST_NAME,C_LAST_NAME,C_TIPO_CODE,C_NUM_DOC,C_TIPO_DOC_PRE;
         FETCH CURSORACTCLIENTEPREP INTO C_PHONE,C_FIRST_NAME,C_LAST_NAME,C_TIPO_CODE,C_NUM_DOC,C_TIPO_DOC_PRE;
      END LOOP;
      --select count(1) into K_TOT_PRO from admpt_imp_actclientes_pre p where TRUNC(p.admpd_fec_reg)=TRUNC(sysdate);
      SELECT COUNT(1) into K_TOT_PRO
      FROM  PCLUB.admpt_imp_actclientes_pre P WHERE P.ADMPD_FEC_REG >=trunc(SYSDATE)
      and  P.ADMPD_FEC_REG <=TO_DATE((TRUNC(SYSDATE)||' 23:59:59'),'dd/mm/yyyy hh24:mi:ss');

     K_TOT_ERR:=K_TOT_PRO-K_TOT_REG;
    ELSE
      K_CODERROR:=36;
      K_DESCERROR:='No hay datos ha Procesar';
    END IF;
    CLOSE CURSORACTCLIENTEPREP;
  END IF;

END ADMPU_ACT_MASIVA;


 PROCEDURE ADMPU_ACT_DATOSCLIE( K_TIPCLIENTE IN VARCHAR2,
                               K_COD_CLIENTE IN VARCHAR2,
                               K_NUM_DOC IN VARCHAR2,
                               K_TIPODOC IN VARCHAR2,
                               K_FIRST_NAME IN VARCHAR2,
                               K_LAST_NAME IN VARCHAR2,
                               K_USUARIO IN VARCHAR2,
                               K_CODERROR OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2) IS
  --****************************************************************
  -- Nombre SP           :  ADMPU_ACT_DATOSCLIE
  -- Propósito           :  Actualizacion de Clientes Postpago y Prepago
  --
  -- Input               :  K_TIPO_LINEA - Tipo de Linea
  --                        K_COD_CLIENTE - Codigo cliente
  --                        K_FIRST_NAME  - Nombre Cliente
  --                        K_LAST_NAME   - Apellido Cliente
  -- Output              :  K_CODERROR - Codigo de Error o Exito
  --                        K_DESCERROR - Descripcion del Error (si se presento)
  -- Creado por          :  Evelyn Sosa Cabillas
  -- Fec Creacion        :  15/10/2013
  --****************************************************************
  TIPO_DOC_CC VARCHAR2(11);
  ERRORDATONUM EXCEPTION;
  ERRORDATOFIRST_NAME EXCEPTION;
  ERRORDATOLAST_NAME EXCEPTION;
  EX_ERROR EXCEPTION;
  EXISTE_COD NUMBER;
  V_CONT NUMBER;

BEGIN
   K_CODERROR := 0;
   K_DESCERROR := '';

    IF K_TIPCLIENTE IS NULL THEN
      K_CODERROR :=4;
      K_DESCERROR := 'No se Ingreso el tipo de línea';
    END IF;

      IF (K_TIPCLIENTE = '1' OR K_TIPCLIENTE = '2') THEN --Postpago
       IF (LENGTH(K_NUM_DOC)<>'8' and LENGTH(K_NUM_DOC)< 8)  THEN
              K_CODERROR := 4;
              K_DESCERROR := 'Numero de DNI no válido para este cliente.';
              RAISE EX_ERROR;
       END IF;
       IF (LENGTH(K_NUM_DOC)> 8 AND (LENGTH(K_NUM_DOC)<>'11'))  THEN
              K_CODERROR := 4;
              K_DESCERROR := 'Numero de RUC no válido para este cliente.';
              RAISE EX_ERROR;
       END IF;
   END IF;

   CASE  WHEN K_TIPCLIENTE IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el tipo de cliente';RAISE EX_ERROR;
           WHEN K_COD_CLIENTE IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el código de cliente';RAISE EX_ERROR;
           WHEN K_FIRST_NAME IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el nombre del cliente';RAISE EX_ERROR;
           WHEN K_LAST_NAME IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese los apellidos del cliente';RAISE EX_ERROR;
           WHEN K_NUM_DOC IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el número de documento';RAISE EX_ERROR;
           ELSE
            K_CODERROR  := 0;
            K_DESCERROR := '';
   END CASE;

     SELECT COUNT(1)
        INTO V_CONT
        FROM  PCLUB.ADMPT_TIPO_CLIENTE
     WHERE ADMPV_COD_TPOCL = K_TIPCLIENTE;

      IF V_CONT < 1 THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'El tipo de cliente no fue encontrado. ';
        RAISE EX_ERROR;
      END IF;

      SELECT COUNT(1)
        INTO EXISTE_COD
        FROM PCLUB.ADMPT_CLIENTE
       WHERE ADMPV_COD_CLI = K_COD_CLIENTE
         AND ADMPV_COD_TPOCL = K_TIPCLIENTE
         AND ADMPC_ESTADO = 'A';

      IF EXISTE_COD = 0 THEN
        K_CODERROR := 52;
        RAISE EX_ERROR;
      END IF;

      IF (K_TIPCLIENTE = '1' OR K_TIPCLIENTE = '2') THEN --Postpago
            IF LENGTH(K_NUM_DOC)='8' THEN
               TIPO_DOC_CC:=2;
              ELSIF LENGTH(K_NUM_DOC)='11' THEN
                TIPO_DOC_CC:=0;
                 ELSE
                 K_CODERROR := 4;
                K_DESCERROR := 'Tipo de documento no válido para este cliente.';
                RAISE EX_ERROR;
            END IF;
       ELSE
            IF (K_TIPODOC IS NULL OR TRIM(K_TIPODOC)='')THEN
                K_CODERROR := 4;
                K_DESCERROR := 'Ingrese el tipo de documento';
                RAISE EX_ERROR;
            ELSE
                TIPO_DOC_CC := F_OBTENERTIPODOC(K_TIPODOC);
                IF TIPO_DOC_CC IS NULL THEN
                  K_CODERROR  := 4;
                  K_DESCERROR := 'El tipo de documento no fue encontrado. ';
                  RAISE EX_ERROR;
                END IF;
            END IF;
       END IF;

       UPDATE PCLUB.ADMPT_CLIENTE
          SET ADMPV_NOM_CLI  = K_FIRST_NAME,
              ADMPV_APE_CLI  = K_LAST_NAME,
              ADMPV_NUM_DOC  = K_NUM_DOC,
              ADMPV_TIPO_DOC = TIPO_DOC_CC,
              ADMPV_USU_MOD  = K_USUARIO,
              ADMPD_FEC_MOD  = SYSDATE
        WHERE ADMPV_COD_CLI = K_COD_CLIENTE;

       COMMIT;

        SELECT ADMPV_DES_ERROR || K_DESCERROR
          INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;

 EXCEPTION

   WHEN EX_ERROR THEN
     BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
      FROM PCLUB.ADMPT_ERRORES_CC
      WHERE ADMPN_COD_ERROR = K_CODERROR;
      ROLLBACK;
     END;
   WHEN OTHERS THEN
      K_CODERROR  := -1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM  PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
 END ADMPU_ACT_DATOSCLIE;

 /****************************************************************
       * NOMBRE SP          :  ADMPSI_VALIDA_CLIENTE
       * PROPOSITO          :  DEVOLVER LA VALIDACION SI ESTA REGISTRADO EN CLARO CLUB SEA CLIENTE FIJO O MOVIL
       * INPUT              :  K_TIP_CLIMOVFIJA  -  Codigo de tipo cliente movil (0) o fija (1)
       *                       K_COD_CLIENTE     -  Codigo de cliente
       *                       K_TIPO_DOC        -  Codigo de tipo de documento
       *                       K_NUM_DOC         -  Numero de documento
       *                       K_TIP_CLI         -  Codigo de tipo de linea
       * OUTPUT             :  K_ES_CLIENTE      -  Codigo de validacion si es cliente (1: es cliente, 0: no es cliente)
       *                       K_CODERROR        -  Devuelve el código de validación o error
       *                       K_DESCERROR       -  Devuelve el mensaje de validación o error
       * CREADO POR         :  BRANDON RAY GONZALES CHACCARA
       * FEC CREACION       :  03/06/2016
       * FEC ACTUALIZACION  :
       ****************************************************************/
 procedure ADMPSI_VALIDA_CLIENTE (K_TIP_CLIMOVFIJA  IN  NUMBER,
                                        K_COD_CLIENTE     IN  VARCHAR2,
                                        K_TIPO_DOC        IN  VARCHAR2,
                                        K_NUM_DOC         IN  VARCHAR2,
                                        K_TIP_CLI         IN  VARCHAR2,
                                        K_ES_CLIENTE      OUT NUMBER,
                                        K_CODERROR        OUT NUMBER,
                                        K_DESCERROR       OUT VARCHAR2)

       AS
       -- declaracion de variables
       V_CANT_MOVIL NUMBER;
       V_CANT_FIJA NUMBER;

       BEGIN
          IF (K_TIP_CLIMOVFIJA = 0) THEN
             IF (K_TIPO_DOC IS NOT NULL AND K_NUM_DOC IS NOT NULL) THEN

                SELECT COUNT(1) INTO V_CANT_MOVIL FROM PCLUB.ADMPT_CLIENTE C
                    WHERE C.ADMPV_TIPO_DOC = K_TIPO_DOC
                          AND C.ADMPV_NUM_DOC = K_NUM_DOC;

                IF (V_CANT_MOVIL = 0) THEN
                   K_ES_CLIENTE := 0;
                   K_CODERROR := 0;
                   K_DESCERROR := 'NO ES CLIENTE';
                ELSE
                   K_ES_CLIENTE := 1;
                   K_CODERROR := 0;
                   K_DESCERROR := 'ES CLIENTE';
                END IF;
             ELSE
                   K_CODERROR := 1;
                   K_DESCERROR := 'LOS PARAMETROS DE BUSQUEDA NO DEBEN SER VACIOS';
             END IF;

          ELSIF (K_TIP_CLIMOVFIJA = 1) THEN
             IF (K_TIPO_DOC IS NOT NULL AND K_NUM_DOC IS NOT NULL) THEN

                SELECT COUNT(1) INTO V_CANT_FIJA FROM PCLUB.ADMPT_CLIENTEFIJA CF
                    WHERE CF.ADMPV_TIPO_DOC = K_TIPO_DOC
                          AND CF.ADMPV_NUM_DOC = K_NUM_DOC;

                IF (V_CANT_FIJA = 0) THEN
                    K_ES_CLIENTE := 0;
                    K_CODERROR := 0;
                    K_DESCERROR := 'NO ES CLIENTE';
                ELSE
                    K_ES_CLIENTE := 1;
                    K_CODERROR := 0;
                    K_DESCERROR := 'ES CLIENTE';
                END IF;
             ELSE
                    K_CODERROR := 1;
                    K_DESCERROR := 'LOS PARAMETROS DE BUSQUEDA NO DEBEN SER VACIOS';
             END IF;
          ELSE
             K_CODERROR := 2;
             K_DESCERROR := 'EL CODIGO DE TIPO DE CLIENTE NO EXISTE';
          END IF;

       EXCEPTION
          WHEN OTHERS THEN
               K_CODERROR := -1;
               K_DESCERROR := SQLCODE || ' : ' || SQLERRM;

       END ADMPSI_VALIDA_CLIENTE;

PROCEDURE ADMPSS_ESTADOCTACC(K_TIPODOC IN VARCHAR2,
                              K_NRODOC IN VARCHAR2,
                              K_FECHAINI IN DATE,
                              K_FECHAFIN IN DATE,
                              CURSORESTADOCTA OUT SYS_REFCURSOR,
                              K_CODERROR  OUT NUMBER,
                              K_DESCERROR OUT VARCHAR2) IS

 -- P_TIPOCLIENTE VARCHAR(20);

  BEGIN

  --  IF K_TIPOCLIENTE='2' THEN
       OPEN CURSORESTADOCTA FOR
--Movil
         SELECT DISTINCT
           K.ADMPV_COD_CLI AS CODCLIENTE,
           '' AS SERVICIO,
           CO.ADMPV_DESC AS CONCEPTO,
           DECODE(SIGN(NVL(K.ADMPN_PUNTOS,0)),-1, NVL(K.ADMPN_PUNTOS,0)*-1,NVL(K.ADMPN_PUNTOS,0)) AS PUNTOS,
           CASE K.ADMPC_TPO_PUNTO WHEN 'C' THEN 'CLARO' WHEN 'I' THEN 'INTERBANK' ELSE 'CLARO' END AS TIPOPUNTO,
           CASE K.ADMPC_TPO_OPER WHEN 'E' THEN 'ENTRADA' ELSE 'SALIDA' END  AS TIPOOPER,
           K.ADMPD_FEC_TRANS AS FECHAASIG,
           DECODE(K.ADMPC_TPO_OPER,'E',ADD_MONTHS(K.ADMPD_FEC_TRANS,18),NULL) AS FECHA_VIG
         FROM PCLUB.ADMPT_CLIENTE C
         INNER JOIN PCLUB.ADMPT_KARDEX K
         ON C.ADMPV_COD_CLI=K.ADMPV_COD_CLI
         INNER JOIN PCLUB.ADMPT_CONCEPTO CO
         ON K.ADMPV_COD_CPTO=CO.ADMPV_COD_CPTO
         WHERE C.ADMPV_TIPO_DOC=K_TIPODOC
           AND C.ADMPV_NUM_DOC=K_NRODOC
           AND C.ADMPC_ESTADO='A'
           AND K.ADMPD_FEC_TRANS>=K_FECHAINI
           AND K.ADMPD_FEC_TRANS <K_FECHAFIN+1

         UNION ALL
--Fija
         SELECT DISTINCT
           C.ADMPV_COD_CLI AS CODCLIENTE,
           TS.ADMPV_DESC AS SERVICIO,
           CO.ADMPV_DESC AS CONCEPTO,
           DECODE(SIGN(NVL(K.ADMPN_PUNTOS,0)),-1, NVL(K.ADMPN_PUNTOS,0)*-1,NVL(K.ADMPN_PUNTOS,0)) AS PUNTOS,
           CASE K.ADMPC_TPO_PUNTO WHEN 'C' THEN 'CLARO' WHEN 'I' THEN 'INTERBANK' ELSE 'CLARO' END AS TIPOPUNTO,
           CASE K.ADMPC_TPO_OPER WHEN 'E' THEN 'ENTRADA' ELSE 'SALIDA' END  AS TIPOOPER,
           K.ADMPD_FEC_TRANS AS FECHAASIG,
           DECODE(K.ADMPC_TPO_OPER,'E',ADD_MONTHS(K.ADMPD_FEC_TRANS,18),NULL) AS FECHA_VIG
           FROM PCLUB.ADMPT_CLIENTEFIJA C
           INNER JOIN PCLUB.ADMPT_CLIENTEPRODUCTO P
           ON C.ADMPV_COD_CLI=P.ADMPV_COD_CLI
           INNER JOIN PCLUB.ADMPT_KARDEXFIJA K
           ON P.ADMPV_COD_CLI_PROD=K.ADMPV_COD_CLI_PROD
           INNER JOIN PCLUB.ADMPT_CONCEPTO CO
           ON K.ADMPV_COD_CPTO=CO.ADMPV_COD_CPTO
           INNER JOIN PCLUB.ADMPT_TIPOSERV_DTH_HFC TS
           ON TS.ADMPV_SERVICIO=P.ADMPV_SERVICIO
         WHERE C.ADMPV_TIPO_DOC=K_TIPODOC
           AND C.ADMPV_NUM_DOC=K_NRODOC
           AND C.ADMPC_ESTADO='A'
           AND K.ADMPD_FEC_TRANS>=K_FECHAINI
           AND K.ADMPD_FEC_TRANS <K_FECHAFIN+1;
       --END IF;

      K_CODERROR  := 0;
    K_DESCERROR := 'OK';

      EXCEPTION
      WHEN OTHERS THEN
      OPEN CURSORESTADOCTA FOR SELECT '' REGDES, '' PROVDES  FROM DUAL;
      K_CODERROR := 1;
      K_DESCERROR := SUBSTR('ERROR : ' || SQLERRM,1,250);

  END ADMPSS_ESTADOCTACC;


  PROCEDURE ADMPSS_PAQUETES_CANJEADOS (PI_CODCLI IN VARCHAR2, --CUST_CODE O LINEA
                                      PI_FECHAINI IN VARCHAR2,
                                      PI_FECHAFIN IN VARCHAR2, --dd/mm/yyyy
                                      PO_DATOS OUT SYS_REFCURSOR,
                                      PO_CODERROR  OUT NUMBER,
                                      PO_DESERROR  OUT VARCHAR2) IS

EX_VALIDACION EXCEPTION;
VAL VARCHAR2(50);
BEGIN
    IF (TRIM(PI_CODCLI) IS NULL) OR (PI_FECHAINI IS NULL OR PI_FECHAFIN IS NULL) THEN
      RAISE EX_VALIDACION;
    END IF;
    --CAPTURA DATA NO FOUND
    SELECT C.ADMPV_COD_CLI INTO VAL FROM ADMPT_CANJE C
    INNER JOIN ADMPT_CANJE_DETALLE D ON D.ADMPV_ID_CANJE = C.ADMPV_ID_CANJE
    INNER JOIN ADMPT_PREMIO P ON P.ADMPV_ID_PROCLA = D.ADMPV_ID_PROCLA
    WHERE (P.ADMPV_ID_PROCLA LIKE 'U_%' or P.ADMPV_ID_PROCLA LIKE '%MILLA%')
    AND P.ADMPV_COD_TPOPR IN ('24','25','26','27','35')
    AND C.ADMPV_COD_CLI IN (PI_CODCLI)
    AND C.ADMPD_FEC_CANJE BETWEEN TO_DATE(TRIM(PI_FECHAINI),'dd/mm/yyyy') AND TO_DATE(TRIM(PI_FECHAFIN),'dd/mm/yyyy') AND ROWNUM = 1;

     --CAPTURA DATA NO FOUND

    OPEN PO_DATOS FOR SELECT D.ADMPV_DESC AS DES_PROD,D.ADMPN_PUNTOS AS MONTO_PAGADO,'CLARO PUNTOS' AS FORMA_PAGO, 'CLARO PUNTOS' AS CANAL, C.ADMPD_FEC_CANJE AS FECHA,C.ADMPV_HRA_CANJE AS HORA, P.ADMPV_ID_PROCLA AS COD_PROD FROM ADMPT_CANJE C
    INNER JOIN ADMPT_CANJE_DETALLE D ON D.ADMPV_ID_CANJE = C.ADMPV_ID_CANJE
    INNER JOIN ADMPT_PREMIO P ON P.ADMPV_ID_PROCLA = D.ADMPV_ID_PROCLA
    WHERE
    (P.ADMPV_ID_PROCLA LIKE 'U_%' or P.ADMPV_ID_PROCLA LIKE '%MILLA%') 
    AND P.ADMPV_COD_TPOPR IN ('24','25','26','27','35')
    AND C.ADMPV_COD_CLI IN (PI_CODCLI)
    AND C.ADMPD_FEC_CANJE BETWEEN TO_DATE(TRIM(PI_FECHAINI),'dd/mm/yyyy') AND TO_DATE(TRIM(PI_FECHAFIN),'dd/mm/yyyy')
    ORDER BY C.ADMPD_FEC_CANJE ASC;
    PO_CODERROR  := 0;
    PO_DESERROR := 'OK';
EXCEPTION
    WHEN EX_VALIDACION THEN
         OPEN PO_DATOS FOR SELECT '' AS DES_PROD,'' AS MONTO_PAGADO,'' AS FORMA_PAGO, '' AS CANAL, '' AS FECHA, '' AS HORA, '' AS COD_PROD FROM DUAL;
         PO_CODERROR  := 2;
         PO_DESERROR := 'FALTA PARAMETRO';
    WHEN NO_DATA_FOUND THEN
         OPEN PO_DATOS FOR SELECT '' AS DES_PROD,'' AS MONTO_PAGADO,'' AS FORMA_PAGO, '' AS CANAL, '' AS FECHA, '' AS HORA, '' AS COD_PROD FROM DUAL;
         PO_CODERROR := 1;
         PO_DESERROR := 'NO EXISTE DATA';
    WHEN OTHERS THEN
         OPEN PO_DATOS FOR SELECT '' AS DES_PROD,'' AS MONTO_PAGADO,'' AS FORMA_PAGO, '' AS CANAL, '' AS FECHA, '' AS HORA, '' AS COD_PROD FROM DUAL;
         PO_CODERROR := SQLCODE;
         PO_DESERROR := SUBSTR(SQLERRM, 1, 250);


END ADMPSS_PAQUETES_CANJEADOS;


PROCEDURE ADMPSS_PAQ_DATOS_CANJEADOS (PI_LINEA IN VARCHAR2,
                              PI_FECHAINI IN VARCHAR2,
                              PI_FECHAFIN IN VARCHAR2, --dd/mm/yyyy
                              PO_DATOS OUT SYS_REFCURSOR,
                              PO_CODERROR  OUT NUMBER,
                              PO_DESERROR  OUT VARCHAR2) IS

EX_VALIDACION EXCEPTION;
VAL VARCHAR2(50);
BEGIN
    IF (TRIM(PI_LINEA) IS NULL) OR (PI_FECHAINI IS NULL OR PI_FECHAFIN IS NULL) THEN
      RAISE EX_VALIDACION;
    END IF;
    --CAPTURA DATA NO FOUND
    SELECT C.ADMPV_COD_CLI INTO VAL FROM ADMPT_CANJE C
    INNER JOIN ADMPT_CANJE_DETALLE D ON D.ADMPV_ID_CANJE = C.ADMPV_ID_CANJE
    INNER JOIN ADMPT_PREMIO P ON P.ADMPV_ID_PROCLA = D.ADMPV_ID_PROCLA
    WHERE P.ADMPV_COD_TPOPR IN ('26')
    AND C.ADMPV_NUM_LINEA IN (PI_LINEA)
    AND C.ADMPD_FEC_CANJE BETWEEN TO_DATE(TRIM(PI_FECHAINI),'dd/mm/yyyy') AND TO_DATE(TRIM(PI_FECHAFIN),'dd/mm/yyyy') AND ROWNUM = 1;

     --CAPTURA DATA NO FOUND

    OPEN PO_DATOS FOR SELECT D.ADMPV_DESC AS DES_PROD,P.ADMPV_ID_PROCLA COD_PROD,
    C.ADMPD_FEC_CANJE AS FECHA,
    C.ADMPV_HRA_CANJE AS HORA,
    P.ADMPV_CLAVE,
    P.ADMPV_COD_PAQDAT
    FROM ADMPT_CANJE C
    INNER JOIN ADMPT_CANJE_DETALLE D ON D.ADMPV_ID_CANJE = C.ADMPV_ID_CANJE
    INNER JOIN ADMPT_PREMIO P ON P.ADMPV_ID_PROCLA = D.ADMPV_ID_PROCLA
    WHERE P.ADMPV_COD_TPOPR IN ('26')
    AND C.ADMPV_NUM_LINEA IN (PI_LINEA)
    AND C.ADMPD_FEC_CANJE BETWEEN TO_DATE(TRIM(PI_FECHAINI),'dd/mm/yyyy') AND TO_DATE(TRIM(PI_FECHAFIN),'dd/mm/yyyy')
    ORDER BY C.ADMPD_FEC_CANJE ASC;
    PO_CODERROR  := 0;
    PO_DESERROR := 'OK';
EXCEPTION
    WHEN EX_VALIDACION THEN
         OPEN PO_DATOS FOR SELECT '' AS DES_PROD,'' AS MONTO_PAGADO,'' AS FORMA_PAGO, '' AS CANAL, '' AS FECHA, '' AS HORA FROM DUAL;
         PO_CODERROR  := 2;
         PO_DESERROR := 'FALTA PARAMETRO';
    WHEN NO_DATA_FOUND THEN
         OPEN PO_DATOS FOR SELECT '' AS DES_PROD,'' AS MONTO_PAGADO,'' AS FORMA_PAGO, '' AS CANAL, '' AS FECHA, '' AS HORA FROM DUAL;
         PO_CODERROR := 1;
         PO_DESERROR := 'NO EXISTE DATA';
    WHEN OTHERS THEN
         OPEN PO_DATOS FOR SELECT '' AS DES_PROD,'' AS MONTO_PAGADO,'' AS FORMA_PAGO, '' AS CANAL, '' AS FECHA, '' AS HORA FROM DUAL;
         PO_CODERROR := SQLCODE;
         PO_DESERROR := SUBSTR(SQLERRM, 1, 250);


END ADMPSS_PAQ_DATOS_CANJEADOS;

PROCEDURE ADMPSS_CANJPROD_EVEN (K_ID_SOLICITUD IN VARCHAR2,
                            K_COD_CLIENTE  IN VARCHAR2,
                            K_TIPO_DOC     IN VARCHAR2,
                            K_NUM_DOC      IN VARCHAR2,
                            K_PUNTOVENTA   IN VARCHAR2,
                            K_TIP_CLI      IN VARCHAR2,
                            K_COD_APLI     IN VARCHAR2,
                            K_CLAVE        IN VARCHAR2,
                            K_KEYWORD       IN VARCHAR2,
                            K_NUM_LINEA    IN     VARCHAR2,
                            K_COD_ASESOR       IN     VARCHAR2,
                            K_NOM_ASESOR       IN     VARCHAR2,
                            K_TIPCANJE     IN NUMBER,
                            K_TIPPRECANJE  IN NUMBER,
                            K_MENSAJE      IN VARCHAR2,
                            K_CODERROR     OUT NUMBER,
                            K_MSJERROR     OUT VARCHAR2,
                            K_CANJE        OUT VARCHAR2)

  --****************************************************************
    -- Nombre SP           :  ADMPSS_CANJPROD_EVEN
    -- Proposito           :  Registrar el Canje de un Evento
    -- Creado por          :
    -- Fec Creacion        :  11/08/2017
    -- Fec Actualizacion   :
    --****************************************************************

IS
    V_COD_CANJE NUMBER;
    V_ID_KARDEX NUMBER;
    V_SEC               NUMBER;
    V_DESC_PREMIO       VARCHAR2(150);
    V_PUNTOS_REQUERIDOS NUMBER := 0;
    V_NUM_DOC           VARCHAR2(20);
    V_SALDO NUMBER;
    NO_CLIENTE EXCEPTION;
    NO_EVENTO EXCEPTION;
    NO_SALDO EXCEPTION;
    NO_SALDO_CANJE EXCEPTION;
    NO_DESC_PUNTOS EXCEPTION;
    NO_PARAMETROS EXCEPTION;
    NO_COD_APLICACION EXCEPTION;
    NO_SLD_KDX_ALINEADO EXCEPTION;
    NO_DATOS_VALIDOS EXCEPTION;
    V_CODERROR  NUMBER;
    V_COD_CPTO  NUMBER;
    V_DESCERROR VARCHAR2(400);
    EX_BLOQUEO EXCEPTION;
    EX_DESBLOQUEO EXCEPTION;
    NO_VALBLOQUEO EXCEPTION;
    NO_LIBERADO EXCEPTION;
    K_ESTADO CHAR(1);
    K_CODERROR_EX  NUMBER;
    K_MSJERROR_EX VARCHAR2(400);
    V_EXISTE    NUMBER;
    V_TIPO_DOC_B VARCHAR2(20);
    V_CAMPANA    VARCHAR2(150);
    V_PAGO   NUMBER;
    V_TIPOPREMIO   VARCHAR2(2);
    V_SERVCOMERCIAL   NUMBER;
    V_MONTORECARGA   NUMBER;
    V_CODPAGDAT   VARCHAR2(50);
    V_PRODID   VARCHAR2(15);

  BEGIN

    IF K_COD_CLIENTE IS NULL THEN
      RAISE NO_PARAMETROS;
    END IF;

    if K_COD_APLI is null then
      raise NO_COD_APLICACION;
    end if;

    V_TIPO_DOC_B := F_OBTENERTIPODOC(K_TIPO_DOC);

    SELECT count(1)
      INTO V_EXISTE
      FROM PCLUB.admpt_cliente
     WHERE admpv_cod_cli = K_COD_CLIENTE
       AND admpv_tipo_doc = V_TIPO_DOC_B
       AND admpv_num_doc = K_NUM_DOC
       AND admpc_estado = 'A';

     IF V_EXISTE = 0 THEN
       K_CODERROR  := 49;
       RAISE NO_DATOS_VALIDOS;
     END IF;

     SELECT ap.ADMPV_ID_PROCLA,ap.ADMPN_PUNTOS,ap.admpv_desc,ap.ADMPV_CAMPANA,
           ap.ADMPN_PAGO,ap.ADMPV_COD_TPOPR,ap.ADMPN_COD_SERVC,
           ap.ADMPN_MNT_RECAR,ap.ADMPV_COD_PAQDAT
    INTO     V_PRODID,V_PUNTOS_REQUERIDOS, V_DESC_PREMIO, V_CAMPANA,
             V_PAGO,V_TIPOPREMIO,V_SERVCOMERCIAL,V_MONTORECARGA,
             V_CODPAGDAT
    FROM     PCLUB.admpt_premio ap LEFT JOIN PCLUB.SYSFT_EVENTO se
             ON ap.admpv_id_procla =se.ADMPV_ID_PROCLA and ap.admpc_estado = 'A'
    WHERE    UPPER(se.SYEVV_PALABRA_CLAVE) = UPPER(K_KEYWORD) 
             AND TRUNC(SYSDATE) >= TRUNC(SE.SYEVD_FECINI_EVENTO)           
             AND TRUNC(SYSDATE) <= TRUNC(SE.SYEVD_FECFIN_EVENTO);

    IF V_PRODID IS NULL THEN
      RAISE NO_EVENTO;
    END IF;
    
    IF V_PUNTOS_REQUERIDOS > 0 THEN
    PCLUB.PKG_CC_TRANSACCION.ADMPSI_ES_CLIENTE_CJE(K_COD_CLIENTE,
                      K_TIPO_DOC,
                      K_NUM_DOC,
                      K_TIP_CLI,
                      K_TIPCANJE,
                      K_TIPPRECANJE,
                      V_SALDO,
                      K_CODERROR);
    IF K_CODERROR <> 0 THEN
      RAISE NO_CLIENTE;
    END IF;

    IF V_SALDO <= 0 THEN
      RAISE NO_SALDO;
    END IF;

      IF V_PUNTOS_REQUERIDOS > V_SALDO THEN
        RAISE NO_SALDO_CANJE;
      END IF;
    END IF;

    PCLUB.PKG_CC_TRANSACCION.ADMPI_BLOQUEOBOLSA(K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,K_COD_ASESOR,K_ESTADO,K_CODERROR,K_MSJERROR);

    IF K_CODERROR = 0 AND K_ESTADO = 'L' THEN
      PCLUB.PKG_CC_TRANSACCION.ADMPSS_VALIDASALDOKDX(K_COD_CLIENTE,
                      K_TIP_CLI,
                      K_CODERROR);
    ELSE
        IF K_CODERROR = 37 AND K_ESTADO = 'R' THEN
          RAISE NO_LIBERADO;
        ELSE
          RAISE EX_BLOQUEO;
        END IF;
    END IF;

    IF K_CODERROR = 1 THEN
      RAISE NO_SLD_KDX_ALINEADO;
    END IF;

    SELECT NVL(PCLUB.admpt_canje_sq.NEXTVAL, '-1')
      INTO V_COD_CANJE
      FROM dual;
    IF K_NUM_DOC IS NULL THEN
      SELECT admpv_num_doc
        INTO V_NUM_DOC
        FROM PCLUB.admpt_cliente
       WHERE admpv_cod_cli = K_COD_CLIENTE
         AND admpc_estado = 'A';
    ELSE
      V_NUM_DOC := K_NUM_DOC;
    END IF;

    INSERT INTO PCLUB.admpt_canje
      (admpv_id_canje,
       admpv_cod_cli,
       admpv_id_solic,
       admpv_pto_venta,
       admpd_fec_canje,
       admpv_hra_canje,
       admpv_num_doc,
       admpv_cod_tpocl,
       admpv_cod_aseso,
       admpv_nom_aseso,
       admpc_tpo_oper,
       admpv_cod_tipapl,
       admpv_clave,
       admpv_mensaje,
       admpv_ticket,
       admpv_id_loyalty,
       admpv_id_gprs,
       admpv_num_linea,
       ADMPV_CODSEGMENTO,
       ADMPV_USU_ASEG,
       ADMPN_TIPCANJE,
       ADMPN_TIPPREMCJE,
	   ADMPD_FEC_MOD)
    values
      (V_COD_CANJE,
       K_COD_CLIENTE,
       K_ID_SOLICITUD,
       K_PUNTOVENTA,
       TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
       TO_CHAR(SYSDATE, 'HH:MI AM'),
       V_NUM_DOC,
       K_TIP_CLI,
       k_cod_asesor,
       k_nom_asesor,
       'C',
       K_COD_APLI,
       K_CLAVE,
       K_MENSAJE,
       NULL,
       NULL,
       NULL,
       k_num_linea,
       NULL,
       '',
       K_TIPCANJE,
       K_TIPPRECANJE,
	   SYSDATE);

    V_SEC := 1;

      INSERT INTO PCLUB.admpt_canje_detalle
        (admpv_id_canje,
         admpv_id_canjesec,
         admpv_id_procla,
         admpv_desc,
         admpv_nom_camp,
         admpn_puntos,
         admpn_pago,
         admpn_cantidad,
         admpv_cod_tpopr,
         admpn_cod_servc,
         admpn_mnt_recar,
           admpc_estado,
         admpv_cod_paqdat,
         ADMPN_VALSEGMENTO,
         ADMPN_PUNTOSDSCTO,
         ADMPD_FEC_MOD)
      VALUES
        (V_COD_CANJE,
         V_SEC,
         V_PRODID,
         V_DESC_PREMIO,
         V_CAMPANA,
         V_PUNTOS_REQUERIDOS,
         V_PAGO,
         1,
         V_TIPOPREMIO,
         V_SERVCOMERCIAL,
         0,
         'C',
         V_CODPAGDAT,
         NULL,
         0,
         SYSDATE);

      /**Descuento del Saldo del Cliente**/
      IF K_TIPCANJE = 1 THEN
        PCLUB.PKG_CC_TRANSACCION.ADMPSI_DESC_PTOS_BONO(V_COD_CANJE,
                              V_SEC,
                              V_PUNTOS_REQUERIDOS,
                              K_COD_CLIENTE,
                              K_TIPO_DOC,
                              K_NUM_DOC,
                              K_TIP_CLI,
                              K_TIPPRECANJE,
                              V_CODERROR,
                              V_DESCERROR);
      ELSE
        PCLUB.PKG_CC_TRANSACCION.admpsi_desc_puntos(V_COD_CANJE,
                         V_SEC,
                         V_PUNTOS_REQUERIDOS,
                         K_COD_CLIENTE,
                         K_TIPO_DOC,
                         K_NUM_DOC,
                         K_TIP_CLI,
                         V_CODERROR,
                         V_DESCERROR);
      END IF;

      IF V_CODERROR > 0 THEN
        RAISE NO_DESC_PUNTOS;
      END IF;

      SELECT NVL(admpv_cod_cpto, '-1')
        INTO V_COD_CPTO
        FROM PCLUB.admpt_concepto
       WHERE admpv_desc = 'CANJE';

    SELECT NVL(PCLUB.admpt_kardex_sq.NEXTVAL, '-1')
      INTO V_ID_KARDEX
      FROM dual;

    INSERT INTO PCLUB.admpt_kardex
      (admpn_id_kardex,
       admpn_cod_cli_ib,
       admpv_cod_cli,
       admpv_cod_cpto,
       admpd_fec_trans,
       admpn_puntos,
       admpv_nom_arch,
       admpc_tpo_oper,
       admpc_tpo_punto,
       admpn_sld_punto,
       admpc_estado)
    VALUES
      (V_ID_KARDEX,
       '',
       K_COD_CLIENTE,
       V_COD_CPTO,
       TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
       V_PUNTOS_REQUERIDOS * (-1),
       '',
       'S',
       'C',
       0,
       'C');

    UPDATE PCLUB.admpt_canje
       SET admpn_id_kardex = V_ID_KARDEX
     WHERE admpv_id_canje = V_COD_CANJE;

    COMMIT;

  K_CANJE := V_COD_CANJE;

  EXCEPTION
    WHEN NO_PARAMETROS THEN
      ROLLBACK;
      K_CODERROR := 41;
      K_MSJERROR := 'Ingreso datos incorrectos o datos insuficientes para realizar la consulta';

    WHEN NO_CLIENTE THEN
      ROLLBACK;
      K_CODERROR := K_CODERROR;
      K_MSJERROR := 'El cliente no existe en el sistema CLAROCLUB';

    WHEN NO_DATOS_VALIDOS THEN
      K_CODERROR := K_CODERROR;
      K_MSJERROR := 'Incongruencia con los datos del Cliente';
      ROLLBACK;

    WHEN NO_SALDO THEN
      ROLLBACK;
      K_CODERROR := 52;
      K_MSJERROR := 'No Hay saldo disponible para realizar el canje';

    WHEN NO_SALDO_CANJE THEN
      ROLLBACK;
      K_CODERROR := 52;
      K_MSJERROR := 'No Hay saldo disponible para realizar el canje';

        PCLUB.PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,K_CODERROR_EX,K_MSJERROR_EX);

      IF K_CODERROR <> 0 THEN
        K_MSJERROR := K_MSJERROR || K_MSJERROR_EX;
      END IF;

    WHEN NO_EVENTO THEN
            ROLLBACK;
      K_CODERROR := '51';
      K_MSJERROR := 'No se envio Codigo del Evento';

     ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,K_CODERROR_EX, K_MSJERROR_EX);
      IF K_CODERROR_EX <> 0 THEN
        K_MSJERROR := K_MSJERROR || K_MSJERROR_EX;
      END IF;

    WHEN NO_COD_APLICACION then
            ROLLBACK;
      K_CODERROR := 41;
      K_MSJERROR := 'Ingreso datos incorrectos o datos insuficientes para realizar la consulta';

    WHEN NO_DESC_PUNTOS then
            ROLLBACK;
      K_CODERROR := V_CODERROR;
      K_MSJERROR := V_DESCERROR;

      ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,K_CODERROR_EX,K_MSJERROR_EX);
      IF K_CODERROR_EX <> 0 THEN
        K_MSJERROR := K_MSJERROR || K_MSJERROR_EX;
      END IF;
when NO_SLD_KDX_ALINEADO then
       ROLLBACK;
      K_CODERROR := 61;
      K_MSJERROR := 'Ocurrio un error (Puntos CC)';

     ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,K_CODERROR_EX,K_MSJERROR_EX);

      IF K_CODERROR_EX <> 0 THEN
        K_MSJERROR := K_MSJERROR || K_MSJERROR_EX;
      END IF;

    WHEN EX_BLOQUEO THEN
         ROLLBACK;
      K_CODERROR := K_CODERROR;
      K_MSJERROR := 'Error en el bloqueo.';

    WHEN NO_LIBERADO THEN
       ROLLBACK;
      K_CODERROR := 37;
      K_MSJERROR := 'Existe un canje en proceso.';

WHEN OTHERS THEN
      K_CODERROR := SQLCODE;
      K_MSJERROR := SUBSTR(SQLERRM, 1, 400);

      ROLLBACK;

      ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,K_CODERROR_EX,K_MSJERROR_EX);
      IF K_CODERROR_EX <> 0 THEN
        K_MSJERROR := K_MSJERROR || K_MSJERROR_EX;
      END IF;
  END ADMPSS_CANJPROD_EVEN;

PROCEDURE ADMPSS_CLIENTE_CLAROCLUB
            (PI_TIP_DOC       IN VARCHAR2,
             PI_NUM_DOC       IN VARCHAR2,
             PO_CUR_CLI       OUT SYS_REFCURSOR,
             PO_COD_ERR       OUT VARCHAR2,
             PO_DES_ERR       OUT VARCHAR2) is

nCOUNT NUMBER;
nCOUNTM NUMBER;
nCOUNTF NUMBER;

BEGIN

    IF LENGTH(TRIM(PI_TIP_DOC)) <= 0 OR PI_TIP_DOC IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_TIP_DOC';
      RETURN;
    END IF;

    IF LENGTH(TRIM(PI_NUM_DOC)) <= 0 OR PI_NUM_DOC IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_NUM_DOC';
      RETURN;
    END IF;

    SELECT COUNT(*) INTO nCOUNTM FROM PCLUB.ADMPT_CLIENTE A
    WHERE A.ADMPV_TIPO_DOC = PI_TIP_DOC AND A.ADMPV_NUM_DOC = PI_NUM_DOC;

    SELECT COUNT(*) INTO nCOUNTF FROM PCLUB.ADMPT_CLIENTEFIJA A
    WHERE A.ADMPV_TIPO_DOC = PI_TIP_DOC AND A.ADMPV_NUM_DOC = PI_NUM_DOC;

    nCOUNT := NVL(nCOUNTM,0) + NVL(nCOUNTF,0);

    IF nCOUNT = 0 THEN
      PO_COD_ERR := '2';
      PO_DES_ERR := 'No se ha encontrado cliente';
      RETURN;
    END IF;

    OPEN PO_CUR_CLI FOR
    SELECT A.ADMPV_COD_CLI codCliente, A.ADMPV_TIPO_DOC tipoDoc, A.ADMPV_NUM_DOC numDoc,
    A.ADMPV_NOM_CLI nomCliente, A.ADMPV_APE_CLI apeCliente, A.ADMPV_COD_TPOCL tipoCliente,
    A.ADMPC_ESTADO estadoCliente, A.ADMPV_EMAIL emailCliente,
    C.ADMPV_DSC_DOCUM descTipoDoc, B.ADMPV_TIPO tipoServicio, B.ADMPV_DESC descTipoCliente
    FROM PCLUB.ADMPT_CLIENTE A
    LEFT JOIN PCLUB.ADMPT_TIPO_CLIENTE B
    ON B.ADMPV_COD_TPOCL = A.ADMPV_COD_TPOCL
    LEFT JOIN PCLUB.ADMPT_TIPO_DOC C
    ON C.ADMPV_COD_TPDOC = A.ADMPV_TIPO_DOC
    WHERE A.ADMPV_TIPO_DOC = PI_TIP_DOC AND A.ADMPV_NUM_DOC = PI_NUM_DOC
    UNION
    SELECT F.ADMPV_COD_CLI codCliente, F.ADMPV_TIPO_DOC tipoDoc, F.ADMPV_NUM_DOC numDoc,
    F.ADMPV_NOM_CLI nomCliente, F.ADMPV_APE_CLI apeCliente, F.ADMPV_COD_TPOCL tipoCliente,
    F.ADMPC_ESTADO estadoCliente, F.ADMPV_EMAIL emailCliente,
    C.ADMPV_DSC_DOCUM descTipoDoc, T.ADMPV_TIPO tipoServicio, T.ADMPV_DESC descTipoCliente
    FROM PCLUB.ADMPT_CLIENTEFIJA F
    INNER JOIN PCLUB.ADMPT_TIPO_CLIENTE  T
    ON (F.ADMPV_COD_TPOCL = T.ADMPV_COD_TPOCL)
    LEFT JOIN PCLUB.ADMPT_TIPO_DOC C
    ON C.ADMPV_COD_TPDOC = F.ADMPV_TIPO_DOC
    WHERE F.ADMPV_TIPO_DOC = PI_TIP_DOC AND F.ADMPV_NUM_DOC = PI_NUM_DOC;

    PO_COD_ERR := '0';
    PO_DES_ERR   := 'OK';

EXCEPTION
   WHEN OTHERS THEN
     OPEN PO_CUR_CLI FOR
     SELECT '' codCliente, '' tipoDoc, '' numDoc, '' nomCliente, '' apeCliente, '' tipoCliente,
     '' estadoCliente, '' emailCliente, '' descTipoDoc, '' tipoServicio, '' descTipoCliente FROM DUAL;
     PO_COD_ERR := '-1';
     PO_DES_ERR := 'ERROR => ' || TO_CHAR(SQLCODE) || ' : ' || SQLERRM;

END ADMPSS_CLIENTE_CLAROCLUB;

END PKG_CC_TRANSACCION;
/