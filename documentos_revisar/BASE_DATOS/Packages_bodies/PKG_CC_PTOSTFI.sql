CREATE OR REPLACE PACKAGE BODY PCLUB.PKG_CC_PTOSTFI IS

  PROCEDURE ADMPSI_PROMOCION_TFI(K_FECHA     IN DATE,
                                 K_NOM_ARCH  IN VARCHAR2,
                                 K_CODERROR  OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2,
                                 K_NUMREGTOT OUT NUMBER,
                                 K_NUMREGPRO OUT NUMBER,
                                 K_NUMREGERR OUT NUMBER) IS
    --****************************************************************
    -- Nombre SP           :  ADMPSI_PROMOCION_TFI
    -- Propósito           :  Debe entregar los puntos por Promoción para los clientes TFI indicados en el archivo
    -- Input               :  K_USUARIO  - Usuario
    --                        K_FECHA    - Fecha de Proceso
    --                        K_NOM_ARCH - Nombre de Archivo
    -- Output              :  K_CODERROR
    --                        K_DESCERROR
    --                        K_NUMREGTOT - Número Total de registros
    --                        K_NUMREGPRO - Número de Registros Procesados
    --                        K_NUMREGERR - Número de Registros con Error
    -- Creado por          :  Susana Ramos
    -- Fec Creación        :
    -- Fec Actualización   :  04/04/2013
    --****************************************************************
    NO_CONCEPTO EXCEPTION;
    NO_PARAMETROS EXCEPTION;
    V_COD_CPTO VARCHAR2(3);

    CURSOR CURSOR_TMP_PROMOCIONTFI IS
      SELECT C.ADMPV_COD_CLI,
             C.ADMPV_NOM_PROMO,
             C.ADMPV_PERIODO,
             CEIL(C.ADMPN_PUNTOS),
             C.ADMPV_NOM_ARCH,
             C.ADMPD_FEC_OPER,
             C.ADMPN_PUNTOS
        FROM PCLUB.ADMPT_TMP_PROMOCIONTFI C
       WHERE TRUNC(C.ADMPD_FEC_REG) = TRUNC(K_FECHA)
         AND C.ADMPV_NOM_ARCH = K_NOM_ARCH
         FOR UPDATE OF C.ADMPV_MSJE_ERROR;

    C_COD_CLI   VARCHAR2(40);
    C_NOM_PROMO VARCHAR2(100);
    C_PERIODO   VARCHAR2(6);
    C_PUNTOS    NUMBER;
    C_PTOS_ORI  NUMBER;
    C_NOM_ARCH  VARCHAR2(100);
    C_FEC_OPER  DATE;
    V_ERROR     VARCHAR2(400);
    V_COUNT     NUMBER;
    V_COUNT2    NUMBER;
    V_TPO_OPER  VARCHAR2(2);
    V_SLD_PUNTO NUMBER;
    EST_ERROR   NUMBER;
  BEGIN

    K_CODERROR  := 0;
    K_DESCERROR := ' ';

    IF K_FECHA IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR := K_DESCERROR || ' Parametro = K_FECHA';
      RAISE NO_PARAMETROS;
    END IF;

    BEGIN
      SELECT ADMPV_COD_CPTO
        INTO V_COD_CPTO
        FROM PCLUB.ADMPT_CONCEPTO
       WHERE ADMPV_DESC = 'PROMOCION TFI';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_COD_CPTO := NULL;
    END;

    IF V_COD_CPTO IS NULL THEN
      K_CODERROR  := 9;
      K_DESCERROR := 'Concepto = PROMOCION TFI';
      RAISE NO_CONCEPTO;
    END IF;

    BEGIN

      OPEN CURSOR_TMP_PROMOCIONTFI;
      FETCH CURSOR_TMP_PROMOCIONTFI
        INTO C_COD_CLI,
             C_NOM_PROMO,
             C_PERIODO,
             C_PUNTOS,
             C_NOM_ARCH,
             C_FEC_OPER,
             C_PTOS_ORI;
      WHILE CURSOR_TMP_PROMOCIONTFI%FOUND LOOP
        EST_ERROR := 0;
        IF (C_COD_CLI IS NULL) OR (REPLACE(C_COD_CLI, ' ', '') IS NULL) THEN
          EST_ERROR := 1;
          --MODIFICAR EL ERROR SI EL NUMERO TELEFONICO ESTA EN BLANCO O NULO A LA TABLA PCLUB.ADMPT_TMP_PROMOCIONTFI
          V_ERROR := 'El Codigo de Cliente es un dato obligatorio.';
          UPDATE PCLUB.ADMPT_TMP_PROMOCIONTFI
             SET ADMPV_MSJE_ERROR = V_ERROR
           WHERE CURRENT OF CURSOR_TMP_PROMOCIONTFI;
        ELSE
          SELECT COUNT(*)
            INTO V_COUNT
            FROM PCLUB.ADMPT_CLIENTE
           WHERE ADMPV_COD_CLI = C_COD_CLI;
          IF V_COUNT = 0 THEN
            EST_ERROR := 1;
            --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_PROMOCIONTFI SI CLIENTE NO EXISTE
            V_ERROR := 'Cliente No existe.';
            UPDATE PCLUB.ADMPT_TMP_PROMOCIONTFI
               SET ADMPV_MSJE_ERROR = V_ERROR
             WHERE CURRENT OF CURSOR_TMP_PROMOCIONTFI;
          ELSE
            SELECT COUNT(*)
              INTO V_COUNT2
              FROM PCLUB.ADMPT_CLIENTE
             WHERE ADMPV_COD_CLI = C_COD_CLI
               AND ADMPC_ESTADO = 'B';
            IF V_COUNT2 <> 0 THEN
              EST_ERROR := 1;
              --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_PROMOCIONTFI SI CLIENTE ESTA EN ESTADO DE BAJA
              V_ERROR := 'Cliente se encuentra de Baja no se le entregará la Promoción.';
              UPDATE PCLUB.ADMPT_TMP_PROMOCIONTFI
                 SET ADMPV_MSJE_ERROR = V_ERROR
               WHERE CURRENT OF CURSOR_TMP_PROMOCIONTFI;
            ELSE
              IF C_PUNTOS = 0 OR (C_PUNTOS IS NULL) OR
                 (REPLACE(C_PUNTOS, ' ', '') IS NULL) THEN
                EST_ERROR := 1;
                --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_PROMOCIONTFI CUANDO EL PUNTOS ES 0
                V_ERROR := 'El punto a Entregar debe ser Diferente de Cero/Nulo';
                UPDATE PCLUB.ADMPT_TMP_PROMOCIONTFI
                   SET ADMPV_MSJE_ERROR = V_ERROR
                 WHERE CURRENT OF CURSOR_TMP_PROMOCIONTFI;
              ELSIF C_PUNTOS < 1 THEN
                EST_ERROR := 1;
                --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_PROMOCIONTFI CUANDO EL PUNTOS ES NEGATIVO
                V_ERROR := 'El punto a Entregar No debe ser Negativo';
                UPDATE PCLUB.ADMPT_TMP_PROMOCIONTFI
                   SET ADMPV_MSJE_ERROR = V_ERROR
                 WHERE CURRENT OF CURSOR_TMP_PROMOCIONTFI;
              END IF;
            END IF;
          END IF;
        END IF;

        IF EST_ERROR = 0 THEN
          V_TPO_OPER  := 'E';
          V_SLD_PUNTO := C_PUNTOS;
          BEGIN
            ------------ACTUALIZAR EL SALDO DEL CLIENTE EN LA TABLA PCLUB.ADMPT_SALDOS_CLIENTE
            SELECT NVL(ADMPN_SALDO_CC, 0)
              INTO V_SLD_PUNTO
              FROM PCLUB.ADMPT_SALDOS_CLIENTE
             WHERE ADMPV_COD_CLI = C_COD_CLI;

            IF C_PUNTOS > 0 THEN
              IF V_SLD_PUNTO >= 0 THEN
                ----------------INSERTAR EN PCLUB.ADMPT_KARDEX----------------------------------
                INSERT INTO PCLUB.ADMPT_KARDEX
                  (ADMPN_ID_KARDEX,
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
                  (ADMPT_KARDEX_SQ.NEXTVAL,
                   C_COD_CLI,
                   V_COD_CPTO,
                   SYSDATE,
                   C_PUNTOS,
                   C_NOM_ARCH,
                   V_TPO_OPER,
                   'C',
                   C_PUNTOS,
                   'A',
                   C_NOM_PROMO);
                ----------------INSERTAR EN PCLUB.ADMPT_SALDOS_CLIENTE----------------------------------
                UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
                   SET ADMPN_SALDO_CC  = C_PUNTOS + NVL(ADMPN_SALDO_CC, 0),
                       ADMPC_ESTPTO_CC = 'A'
                 WHERE ADMPV_COD_CLI = C_COD_CLI;
              END IF;
            END IF;
            -------------INSERTAR EL REGISTRO CORRESPONDIENTE EN LA TABLA PCLUB.ADMPT_AUX_PROMOCIONTFI
            INSERT INTO PCLUB.ADMPT_AUX_PROMOCIONTFI
              (ADMPV_COD_CLI,
               ADMPV_NOM_PROMO,
               ADMPV_PERIODO,
               ADMPN_PUNTOS,
               ADMPV_NOM_ARCH)
            VALUES
              (C_COD_CLI, C_NOM_PROMO, C_PERIODO, C_PUNTOS, C_NOM_ARCH);
          END;
        END IF;
        FETCH CURSOR_TMP_PROMOCIONTFI
          INTO C_COD_CLI,
               C_NOM_PROMO,
               C_PERIODO,
               C_PUNTOS,
               C_NOM_ARCH,
               C_FEC_OPER,
               C_PTOS_ORI;
      END LOOP;
      CLOSE CURSOR_TMP_PROMOCIONTFI;
      COMMIT; --PROBAR COMENTANDO ESTE TROZO DE CODIGO
    END;

    INSERT INTO PCLUB.ADMPT_IMP_PROMOCIONTFI
      (ADMPN_ID_FILA,
       ADMPV_COD_CLI,
       ADMPV_NOM_PROMO,
       ADMPV_PERIODO,
       ADMPN_PUNTOS,
       ADMPV_NOM_ARCH,
       ADMPD_FEC_OPER,
       ADMPV_MSJE_ERROR,
       ADMPD_FEC_TRANS,
       ADMPN_PTOS_ORI)
      SELECT ADMPT_IMP_PROMOCIONTFI_SQ.NEXTVAL,
             T.ADMPV_COD_CLI,
             T.ADMPV_NOM_PROMO,
             T.ADMPV_PERIODO,
             CEIL(T.ADMPN_PUNTOS),
             T.ADMPV_NOM_ARCH,
             T.ADMPD_FEC_OPER,
             T.ADMPV_MSJE_ERROR,
             TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY HH:MI PM'),
                     'DD/MM/YYYY HH:MI PM'),
             T.ADMPN_PUNTOS
        FROM PCLUB.ADMPT_TMP_PROMOCIONTFI T
       WHERE TRUNC(T.ADMPD_FEC_REG) = TRUNC(K_FECHA)
         AND T.ADMPV_NOM_ARCH = K_NOM_ARCH;

    SELECT COUNT(*)
      INTO K_NUMREGTOT
      FROM PCLUB.ADMPT_TMP_PROMOCIONTFI
     WHERE TRUNC(ADMPD_FEC_REG) = TRUNC(K_FECHA)
       AND ADMPV_NOM_ARCH = K_NOM_ARCH; --ADMPD_FEC_OPER=K_FECHA ;
    SELECT COUNT(*)
      INTO K_NUMREGERR
      FROM PCLUB.ADMPT_TMP_PROMOCIONTFI
     WHERE TRUNC(ADMPD_FEC_REG) = TRUNC(K_FECHA)
       AND ADMPV_NOM_ARCH = K_NOM_ARCH --ADMPD_FEC_OPER=K_FECHA
       AND (ADMPV_MSJE_ERROR IS NOT NULL);

    SELECT COUNT(*) INTO K_NUMREGPRO FROM PCLUB.ADMPT_AUX_PROMOCIONTFI;

    -- Eliminamos los registros de la tabla temporal y auxiliar
    DELETE PCLUB.ADMPT_TMP_PROMOCIONTFI
     WHERE TRUNC(ADMPD_FEC_REG) = TRUNC(K_FECHA);
    DELETE PCLUB.ADMPT_AUX_PROMOCIONTFI;

    COMMIT;
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR';
    END;

  EXCEPTION
    WHEN NO_PARAMETROS THEN
      ROLLBACK;
      BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR
          INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_DESCERROR := 'ERROR';
      END;
    WHEN NO_CONCEPTO THEN
      ROLLBACK;
      BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR
          INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_DESCERROR := 'ERROR';
      END;
    WHEN OTHERS THEN
      ROLLBACK;
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

  END ADMPSI_PROMOCION_TFI;

  PROCEDURE ADMPSS_EPROMOCION_TFI(K_FECHA               IN DATE,
                                  K_CODERROR            OUT NUMBER,
                                  K_DESCERROR           OUT VARCHAR2,
                                  CURSOR_EPROMOCION_TFI OUT SYS_REFCURSOR) IS
    --****************************************************************
    -- Nombre SP           :  ADMPSS_EPROMOCION_TFI
    -- Propósito           :  Devuelve en un cursor solo los puntos por Promoción que no pudieron ser agregadas por algún error controlado
    -- Input               :  K_FECHA - Fecha de Proceso
    -- Output              :  CURSOR_EPROMOCION_TFI Cursor que Contiene Lista de Clientes con Registro de Puntos de Promocion que generaron Errores
    -- Creado por          :  Susana Ramos
    -- Fec Creación        :
    -- Fec Actualización   :  22/05/2012
    --****************************************************************
    NO_PARAMETROS EXCEPTION;
  BEGIN
    K_CODERROR := 0;
    IF K_FECHA IS NULL THEN
      RAISE NO_PARAMETROS;
    END IF;

    OPEN CURSOR_EPROMOCION_TFI FOR
      SELECT ADMPV_COD_CLI,
             ADMPV_NOM_PROMO,
             ADMPV_PERIODO,
             ADMPN_PUNTOS,
             ADMPV_NOM_ARCH,
             ADMPV_MSJE_ERROR
        FROM PCLUB.ADMPT_IMP_PROMOCIONTFI
       WHERE ADMPV_MSJE_ERROR IS NOT NULL
         AND ADMPD_FEC_OPER = K_FECHA;
  EXCEPTION
    WHEN NO_PARAMETROS THEN
      K_CODERROR  := 41;
      K_DESCERROR := 'Ingresó datos incorrectos o datos insuficientes para realizar la consulta';
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
  END ADMPSS_EPROMOCION_TFI;



PROCEDURE ADMPSI_REGISTRO_CLIENTETFI_CC (K_CODTPO_CLI IN VARCHAR2,K_TIPO_DOC IN VARCHAR2, 
                                         K_NRO_DOC IN VARCHAR2, K_USUARIO IN VARCHAR2,
                                         K_NUM_LINEA OUT VARCHAR2, K_CODERROR OUT NUMBER, 
                                         K_DESCERROR OUT VARCHAR2)
IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_REGISTRO_CLIENTETFI_CC
  -- Propósito           :  
  -- Input               :  K_CODTPO_CLI -- codigo de tipo de cliente 
  --                        K_TIPO_DOC --tipo de documento del cliente 
  --                        K_NRO_DOC --numero de documento del cliente
  --                        K_USUARIO -- nombre de usuario
  -- Output              :  K_NUM_LINEA
  --                        K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  Jorge Luis Ortiz Castillo
  -- Fec Creación        :  10/05/2013
  -- Fec Actualización   :  
  --****************************************************************
  
  V_NUM_LINEA VARCHAR2(20);
  V_TAM_NUM_LINEA NUMBER;

  V_COUNT NUMBER;
  V_ERROR NUMBER;
  V_COUNT_LINEAS NUMBER;
  V_COUNT_TC NUMBER;
  V_TDOC_DWH  VARCHAR2(50);
  V_COUNT_TPO_DOC NUMBER;
  V_COUNT_ERR NUMBER;

  CURSOR CUR_LINEASXCLITFI(TIPO_DOC VARCHAR2, NUM_DOC VARCHAR2) IS
    SELECT C.MSISDN, C.NOMBRES,
          C.APELLIDOS, C.TIPO_DOCUMENTO,
          C.NRO_DOCUMENTO, IDDEPARTAMENTO, 
          SEXO, C.FCH_ACTIVACION
    FROM dm.ods_base_abonados@dbl_reptdm_d C
    WHERE C.NRO_DOCUMENTO = NUM_DOC
         AND C.TIPO_DOCUMENTO = TIPO_DOC
         AND (C.IDSEGMENTO=7 OR C.IDSEGMENTO=8) 
         AND C.IDPLATAFORMA=1 
         AND (C.IDESTADO=2 OR C.IDESTADO=3)
    ORDER BY C.FCH_ACTIVACION ASC;

  CURSOR CUR_LINEASXCLIPRE(TIPO_DOC VARCHAR2, NUM_DOC VARCHAR2) IS
    SELECT C.MSISDN, C.NOMBRES,
          C.APELLIDOS, C.TIPO_DOCUMENTO,
          C.NRO_DOCUMENTO, IDDEPARTAMENTO, 
          SEXO, C.FCH_ACTIVACION
    FROM dm.ods_base_abonados@dbl_reptdm_d C
    WHERE C.NRO_DOCUMENTO = NUM_DOC
         AND C.TIPO_DOCUMENTO = TIPO_DOC
         AND C.IDSEGMENTO = 1
         AND C.IDPLATAFORMA = 1 
         AND (C.IDESTADO=2 OR C.IDESTADO=3)
    ORDER BY C.FCH_ACTIVACION ASC;

BEGIN
    V_COUNT_LINEAS := 0;
    V_ERROR := 0;
    K_NUM_LINEA := '';
    K_DESCERROR := '';
    V_COUNT_ERR :=0;
    
    IF K_CODTPO_CLI IS NULL THEN
      K_CODERROR := '4';
      K_DESCERROR := 'No ingresó Tipo de Cliente.';
      V_ERROR := V_ERROR + 1;
    END IF;
    
    IF K_CODTPO_CLI <> '3' AND K_CODTPO_CLI <> '8' THEN
      K_CODERROR := '4';
      K_DESCERROR := 'Tipo de Cliente no válido para esta transacción.';
      V_ERROR := V_ERROR + 1;
    END IF;
    
    IF K_TIPO_DOC IS NULL THEN
      K_CODERROR := '4';
      K_DESCERROR := 'No ingresó el Tipo de Documento.';
      V_ERROR := V_ERROR + 1;
    END IF;

   IF K_TIPO_DOC = '0' THEN
      K_CODERROR  := '4';
      K_DESCERROR := ' Tipo de documento no válido para el registro.';
      V_ERROR     := V_ERROR + 1;
    END IF;
    
    IF K_NRO_DOC IS NULL THEN
       K_CODERROR := '4';
       K_DESCERROR := 'No ingresó Número de Documento.';
       V_ERROR := V_ERROR + 1;
    END IF;

    SELECT COUNT(1) INTO V_COUNT_TPO_DOC
    FROM PCLUB.ADMPT_TIPO_DOC A
    WHERE A.ADMPV_COD_TPDOC=K_TIPO_DOC;
    
    IF V_COUNT_TPO_DOC = 0 THEN
       K_CODERROR := '4';
       K_DESCERROR := 'Tipo de Documento no válido.';
       V_ERROR := V_ERROR + 1;
    ELSE
      -- obtenemos la descripcion del Tpo. de Documento de CC en DWH
      SELECT NVL(A.ADMPV_EQU_DWH, NULL) INTO V_TDOC_DWH
      FROM PCLUB.ADMPT_TIPO_DOC A
      WHERE A.ADMPV_COD_TPDOC=K_TIPO_DOC;

      IF V_TDOC_DWH IS NULL THEN
         K_CODERROR := '43';
         K_DESCERROR := '';
         V_ERROR := V_ERROR + 1;
      ELSE
         IF K_TIPO_DOC=2 OR K_TIPO_DOC=0 THEN
            V_TDOC_DWH:=UPPER(V_TDOC_DWH);
         END IF;
      END IF;
    END IF;
    
    --LFA
    SELECT COUNT(1) INTO V_COUNT_TC 
    FROM PCLUB.ADMPT_TIPO_CLIENTE TC
    WHERE TC.ADMPV_COD_TPOCL=K_CODTPO_CLI;
    
    IF V_COUNT_TC=0 THEN
       K_CODERROR := '4';
       K_DESCERROR := 'Tipo cliente no existe.';
       V_ERROR := V_ERROR + 1;
    END IF;
          
    IF V_ERROR = 0 THEN
      -- verificamos si la descripcion del tipo de documento existe en CC
      IF K_CODTPO_CLI = '8' THEN --TFI PREPAGO

          -- validar que el numero y tipo de documento se encuentre en el DWH
        SELECT COUNT(C.MSISDN) INTO V_COUNT
        FROM dm.ods_base_abonados@dbl_reptdm_d C
                 WHERE C.TIPO_DOCUMENTO = V_TDOC_DWH
              AND C.NRO_DOCUMENTO = K_NRO_DOC
              AND (C.IDSEGMENTO = 7 OR C.IDSEGMENTO = 8) 
              AND C.IDPLATAFORMA = 1 
              AND (C.IDESTADO = 2 OR C.IDESTADO = 3);

        IF V_COUNT > 0 THEN
          
          SELECT NVL(COUNT(1),0) INTO V_COUNT
          FROM PCLUB.ADMPT_CLIENTE C
            WHERE C.ADMPV_TIPO_DOC = K_TIPO_DOC 
               AND C.ADMPV_NUM_DOC = K_NRO_DOC
                        AND C.ADMPV_COD_TPOCL = K_CODTPO_CLI
                        AND C.ADMPC_ESTADO = 'A';
                             
          -- Validar que el cliente se encuentra en CLAROCLUB con cualquier linea
          IF V_COUNT = 0 THEN
                       FOR R IN CUR_LINEASXCLITFI(V_TDOC_DWH,K_NRO_DOC) LOOP
                 BEGIN
                     -- obtenemos la longitud de caracteres de la linea
                     SELECT LENGTH(R.MSISDN) INTO V_TAM_NUM_LINEA
                     FROM DUAL;
                     
                     -- obtenemos el numero de la linea
                     V_NUM_LINEA := SUBSTR(R.MSISDN,3,V_TAM_NUM_LINEA);
                   
                    
                     -- Validar si la linea de DWH se encuentre en Claro Club
                   SELECT NVL(COUNT(1),0) INTO V_COUNT
                   FROM PCLUB.ADMPT_CLIENTE C
                     WHERE C.ADMPV_COD_CLI= V_NUM_LINEA 
                           AND C.ADMPV_COD_TPOCL = K_CODTPO_CLI  
						   AND C.ADMPC_ESTADO='A'; -- tipo de cliente TFI

                   IF V_COUNT = 0 THEN -- si la linea no existe en Claro Club

                      INSERT INTO PCLUB.ADMPT_CLIENTE(ADMPV_COD_CLI,ADMPV_COD_SEGCLI,
                                                ADMPN_COD_CATCLI,ADMPV_TIPO_DOC,
                                                ADMPV_NUM_DOC,ADMPV_NOM_CLI,
                                                ADMPV_APE_CLI,ADMPC_SEXO,
                                                ADMPV_EST_CIVIL,ADMPV_EMAIL,
                                                ADMPV_PROV,ADMPV_DEPA,
                                                ADMPV_DIST,ADMPD_FEC_ACTIV,
                                                ADMPV_CICL_FACT,ADMPC_ESTADO,
                                                ADMPV_COD_TPOCL,ADMPD_FEC_REG,
                                                ADMPV_USU_REG)
                        VALUES(V_NUM_LINEA, NULL,
                               '2', K_TIPO_DOC,
                             K_NRO_DOC,R.NOMBRES,
                               R.APELLIDOS, R.SEXO,
                             NULL,NULL,
                               NULL,R.IDDEPARTAMENTO,
                                         NULL,R.FCH_ACTIVACION,
                               NULL,'A',
                               K_CODTPO_CLI,SYSDATE,
                               K_USUARIO);
    
                        SELECT NVL(COUNT(1),0) INTO V_COUNT
                        FROM ADMPT_SALDOS_CLIENTE S
                        WHERE S.ADMPV_COD_CLI = V_NUM_LINEA;

      IF V_COUNT = 0 THEN
                    
                           INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE(ADMPN_ID_SALDO,ADMPV_COD_CLI,
                                                            ADMPN_COD_CLI_IB,ADMPN_SALDO_CC,
                                                            ADMPN_SALDO_IB,ADMPC_ESTPTO_CC,
                                                            ADMPC_ESTPTO_IB,ADMPD_FEC_REG)
                           VALUES(ADMPT_SLD_CL_SQ.NEXTVAL,V_NUM_LINEA,
                                  NULL,0,
                                  0,'A',
                                  NULL,SYSDATE);
                        ELSE
                           UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
                           SET ADMPN_SALDO_IB = 0,
                               ADMPN_SALDO_CC = 0
                           WHERE ADMPV_COD_CLI = V_NUM_LINEA;
                        END IF;
                        
                                  --COMMIT;
                        
                        V_COUNT_LINEAS := V_COUNT_LINEAS + 1;
                        
                        IF V_COUNT_LINEAS = 1 THEN
                          K_NUM_LINEA := V_NUM_LINEA;
                        END IF;
                               ELSE
                                    V_COUNT_ERR:=1;
                                    EXIT;   
                     END IF;
                   END;
               END LOOP;
                        
                       IF V_COUNT_ERR>0 THEN
                          K_CODERROR:='47';
                          ROLLBACK;
                       ELSE
               K_CODERROR := 0;
                          COMMIT;
                       END IF;
      ELSE
               K_CODERROR := 46; -- cliente ya existe
            END IF;
          
          ELSE
            K_CODERROR := 45;
            K_DESCERROR := '';--'No existen líneas TFI prepago para el cliente ingresado.';
                    --COMMIT;
          END IF;
        END IF; -- FIN K_CODTPO_CLI = '8'
        
        IF K_CODTPO_CLI = '3' THEN -- PREPAGO

        SELECT COUNT(C.MSISDN) INTO V_COUNT
        FROM dm.ods_base_abonados@dbl_reptdm_d C
                   WHERE C.TIPO_DOCUMENTO = V_TDOC_DWH
              AND C.NRO_DOCUMENTO = K_NRO_DOC
                AND C.IDSEGMENTO = 1
              AND C.IDPLATAFORMA = 1 
              AND (C.IDESTADO = 2 OR C.IDESTADO = 3);

        IF V_COUNT > 0 THEN
          
          SELECT NVL(COUNT(1),0) INTO V_COUNT
            FROM PCLUB.ADMPT_CLIENTE C
            WHERE C.ADMPV_TIPO_DOC = K_TIPO_DOC 
               AND C.ADMPV_NUM_DOC = K_NRO_DOC
                 AND C.ADMPV_COD_TPOCL = K_CODTPO_CLI 
				 AND C.ADMPC_ESTADO='A'; 
                             
            -- Validar que el cliente se encuentra en CLAROCLUB 
            -- con cualquier linea
          IF V_COUNT = 0 THEN
                             FOR R IN CUR_LINEASXCLIPRE(V_TDOC_DWH,K_NRO_DOC) LOOP
                 BEGIN
                     -- obtenemos la longitud de caracteres de la linea
                     SELECT LENGTH(R.MSISDN) INTO V_TAM_NUM_LINEA
                     FROM DUAL;
                     
                     -- obtenemos el numero de la linea
                     V_NUM_LINEA := SUBSTR(R.MSISDN,3,V_TAM_NUM_LINEA);
                   
                   -- Validar que la linea de DWH se encuentre en Claro Club
                   SELECT NVL(COUNT(1),0) INTO V_COUNT
                     FROM ADMPT_CLIENTE C
                     WHERE C.ADMPV_COD_CLI= V_NUM_LINEA 
                           AND C.ADMPV_COD_TPOCL = K_CODTPO_CLI  
						   AND C.ADMPC_ESTADO='A'; -- tipo de cliente PREPAGO

                   IF V_COUNT = 0 THEN -- si la linea no existe en Claro Club

                      INSERT INTO PCLUB.ADMPT_CLIENTE(ADMPV_COD_CLI,ADMPV_COD_SEGCLI,
                                                ADMPN_COD_CATCLI,ADMPV_TIPO_DOC,
                                                ADMPV_NUM_DOC,ADMPV_NOM_CLI,
                                                ADMPV_APE_CLI,ADMPC_SEXO,
                                                ADMPV_EST_CIVIL,ADMPV_EMAIL,
                                                ADMPV_PROV,ADMPV_DEPA,
                                                ADMPV_DIST,ADMPD_FEC_ACTIV,
                                                ADMPV_CICL_FACT,ADMPC_ESTADO,
                                                ADMPV_COD_TPOCL,ADMPD_FEC_REG,
                                                ADMPV_USU_REG)
                        VALUES(V_NUM_LINEA, NULL,
                               '2',K_TIPO_DOC,
                             K_NRO_DOC,R.NOMBRES,
                               R.APELLIDOS, R.SEXO,
                             NULL,NULL,
                               NULL,R.IDDEPARTAMENTO,
                                               NULL,R.FCH_ACTIVACION,
                             NULL,'A',
                               K_CODTPO_CLI,SYSDATE,
                             K_USUARIO);

                      SELECT NVL(COUNT(1),0) INTO V_COUNT
                      FROM PCLUB.ADMPT_SALDOS_CLIENTE S
                        WHERE S.ADMPV_COD_CLI = V_NUM_LINEA;

                      IF V_COUNT = 0 THEN
                         INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE(ADMPN_ID_SALDO,ADMPV_COD_CLI,
                                                          ADMPN_COD_CLI_IB,ADMPN_SALDO_CC,
                                                          ADMPN_SALDO_IB,ADMPC_ESTPTO_CC,
                                                          ADMPC_ESTPTO_IB,ADMPD_FEC_REG)
                           VALUES(ADMPT_SLD_CL_SQ.NEXTVAL,V_NUM_LINEA,
                                NULL,0,
                                0,'A',
                                NULL,SYSDATE);
                      ELSE
                         UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
                         SET ADMPN_SALDO_IB = 0,
                             ADMPN_SALDO_CC = 0
                           WHERE ADMPV_COD_CLI = V_NUM_LINEA;
                      END IF;
                      
                                        --COMMIT;
                        
                        V_COUNT_LINEAS := V_COUNT_LINEAS + 1;
                        
                        IF V_COUNT_LINEAS = 1 THEN
                          K_NUM_LINEA := V_NUM_LINEA;
                        END IF;
                                     ELSE
                                          V_COUNT_ERR:=1;
                                          EXIT;
                   END IF;
                 
                 END;
             END LOOP;
                      
                           IF V_COUNT_ERR>0 THEN
                              K_CODERROR:='47';
                              ROLLBACK;
                           ELSE
             K_CODERROR := 0;
                              COMMIT;
                           END IF;
          ELSE
               K_CODERROR := 46;
          END IF;
        ELSE
            K_CODERROR := 44;
            K_DESCERROR := '';--'No existen líneas prepago para el cliente ingresado.';
                    --COMMIT;
        END IF;
          
        END IF; -- FIN K_CODTPO_CLI = '3'
        
      --END IF; -- if V_COUNT = 0
           
    END IF; --V_ERROR = 0
    
    BEGIN
        SELECT E.ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
        FROM  PCLUB.ADMPT_ERRORES_CC E
        WHERE E.ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='';
    END;
    
EXCEPTION
    WHEN OTHERS THEN
     K_CODERROR:= SQLCODE;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);
     
     ROLLBACK;

END ADMPSI_REGISTRO_CLIENTETFI_CC;


  PROCEDURE ADMPSI_REGULARIZACION_TFI(K_FECHA     IN DATE,
                                      K_NOM_ARCH  IN VARCHAR2,
                                      K_CODERROR  OUT NUMBER,
                                      K_DESCERROR OUT VARCHAR2,
                                      K_NUMREGTOT OUT NUMBER,
                                      K_NUMREGPRO OUT NUMBER,
                                      K_NUMREGERR OUT NUMBER) IS
    --****************************************************************
    -- Nombre SP           :  ADMPSI_REGULARIZACION_TFI
    -- Propósito           :  Debe entregar los puntos por Regularización para los clientes TFI indicados en el archivo
    -- Input               :  K_USUARIO  - Usuario
    --                        K_FECHA    - Fecha de Proceso
    --                        K_NOM_ARCH - Nombre de Archivo
    -- Output              :  K_CODERROR
    --                        K_DESCERROR
    --                        K_NUMREGTOT - Número Total de registros
    --                        K_NUMREGPRO - Número de Registros Procesados
    --                        K_NUMREGERR - Número de Registros con Error
    -- Creado por          :  Susana Ramos
    -- Fec Creación        :
    -- Fec Actualización   :  04/04/2013
    --****************************************************************
    NO_CONCEPTO EXCEPTION;
    NO_PARAMETROS EXCEPTION;
    V_COD_CPTO VARCHAR2(3);

    CURSOR CURSOR_TMP_REGULARIZATFI IS
      SELECT C.ADMPV_COD_CLI,
             C.ADMPV_NOM_REGUL,
             C.ADMPV_PERIODO,
             CEIL(C.ADMPN_PUNTOS),
             C.ADMPV_NOM_ARCH,
             C.ADMPD_FEC_OPER,
             C.ADMPN_PUNTOS
        FROM PCLUB.ADMPT_TMP_REGULARIZATFI C
       WHERE TRUNC(C.ADMPD_FEC_REG) = TRUNC(K_FECHA)
         AND C.ADMPV_NOM_ARCH = K_NOM_ARCH
         FOR UPDATE OF C.ADMPV_MSJE_ERROR;

    C_COD_CLI   VARCHAR2(40);
    C_NOM_PROMO VARCHAR2(100);
    C_PERIODO   VARCHAR2(6);
    C_PUNTOS    NUMBER;
    C_PTOS_ORI  NUMBER;
    C_NOM_ARCH  VARCHAR2(100);
    C_FEC_OPER  DATE;
    V_ERROR     VARCHAR2(400);
    V_COUNT     NUMBER;
    V_COUNT2    NUMBER;
    V_TPO_OPER  VARCHAR2(2);
    V_SLD_PUNTO NUMBER;
    EST_ERROR   NUMBER;
  BEGIN

    K_CODERROR  := 0;
    K_DESCERROR := ' ';

    IF K_FECHA IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR := K_DESCERROR || ' Parametro = K_FECHA';
      RAISE NO_PARAMETROS;
    END IF;

    BEGIN
      SELECT ADMPV_COD_CPTO
        INTO V_COD_CPTO
        FROM PCLUB.ADMPT_CONCEPTO
       WHERE ADMPV_DESC = 'REGULARIZACION TFI';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_COD_CPTO := NULL;
    END;

    IF V_COD_CPTO IS NULL THEN
      K_CODERROR  := 9;
      K_DESCERROR := 'Concepto = REGULARIZACION TFI';
      RAISE NO_CONCEPTO;
    END IF;

    BEGIN

      OPEN CURSOR_TMP_REGULARIZATFI;
      FETCH CURSOR_TMP_REGULARIZATFI
        INTO C_COD_CLI,
             C_NOM_PROMO,
             C_PERIODO,
             C_PUNTOS,
             C_NOM_ARCH,
             C_FEC_OPER,
             C_PTOS_ORI;
      WHILE CURSOR_TMP_REGULARIZATFI%FOUND LOOP
        EST_ERROR := 0;
        IF (C_COD_CLI IS NULL) OR (REPLACE(C_COD_CLI, ' ', '') IS NULL) THEN
          EST_ERROR := 1;
          --MODIFICAR EL ERROR SI EL NUMERO TELEFONICO ESTA EN BLANCO O NULO A LA TABLA PCLUB.ADMPT_TMP_REGULARIZATFI
          V_ERROR := 'El Codigo de Cliente es un dato obligatorio.';
          UPDATE PCLUB.ADMPT_TMP_REGULARIZATFI
             SET ADMPV_MSJE_ERROR = V_ERROR
           WHERE CURRENT OF CURSOR_TMP_REGULARIZATFI;
        ELSE
          SELECT COUNT(*)
            INTO V_COUNT
            FROM PCLUB.ADMPT_CLIENTE
           WHERE ADMPV_COD_CLI = C_COD_CLI;
          IF V_COUNT = 0 THEN
            EST_ERROR := 1;
            --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_REGULARIZATFI SI CLIENTE NO EXISTE
            V_ERROR := 'Cliente No existe.';
            UPDATE PCLUB.ADMPT_TMP_REGULARIZATFI
               SET ADMPV_MSJE_ERROR = V_ERROR
             WHERE CURRENT OF CURSOR_TMP_REGULARIZATFI;
          ELSE
            SELECT COUNT(*)
              INTO V_COUNT2
              FROM PCLUB.ADMPT_CLIENTE
             WHERE ADMPV_COD_CLI = C_COD_CLI
               AND ADMPC_ESTADO = 'B';
            IF V_COUNT2 <> 0 THEN
              EST_ERROR := 1;
              --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_REGULARIZATFI SI CLIENTE ESTA EN ESTADO DE BAJA
              V_ERROR := 'Cliente se encuentra de Baja no se le entregará la Promoción.';
              UPDATE PCLUB.ADMPT_TMP_REGULARIZATFI
                 SET ADMPV_MSJE_ERROR = V_ERROR
               WHERE CURRENT OF CURSOR_TMP_REGULARIZATFI;
            ELSE
              IF C_PUNTOS = 0 OR (C_PUNTOS IS NULL) OR
                 (REPLACE(C_PUNTOS, ' ', '') IS NULL) THEN
                EST_ERROR := 1;
                --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_REGULARIZATFI CUANDO EL PUNTOS ES 0
                V_ERROR := 'El punto a Entregar debe ser Diferente de Cero/Nulo';
                UPDATE PCLUB.ADMPT_TMP_REGULARIZATFI
                   SET ADMPV_MSJE_ERROR = V_ERROR
                 WHERE CURRENT OF CURSOR_TMP_REGULARIZATFI;
              ELSIF C_PUNTOS < 1 THEN
                EST_ERROR := 1;
                --ACTUALIZAR EL MENSAJE DE ERROR EN LA TABLA PCLUB.ADMPT_TMP_REGULARIZATFI CUANDO EL PUNTOS ES NEGATIVO
                V_ERROR := 'El punto a Entregar No debe ser Negativo';
                UPDATE PCLUB.ADMPT_TMP_REGULARIZATFI
                   SET ADMPV_MSJE_ERROR = V_ERROR
                 WHERE CURRENT OF CURSOR_TMP_REGULARIZATFI;
              END IF;
            END IF;
          END IF;
        END IF;

        IF EST_ERROR = 0 THEN
          V_TPO_OPER  := 'E';
          V_SLD_PUNTO := C_PUNTOS;
          BEGIN
            ------------ACTUALIZAR EL SALDO DEL CLIENTE EN LA TABLA PCLUB.ADMPT_SALDOS_CLIENTE
            SELECT NVL(ADMPN_SALDO_CC, 0)
              INTO V_SLD_PUNTO
              FROM PCLUB.ADMPT_SALDOS_CLIENTE
             WHERE ADMPV_COD_CLI = C_COD_CLI;

            IF C_PUNTOS > 0 THEN
              IF V_SLD_PUNTO >= 0 THEN
                ----------------INSERTAR EN PCLUB.ADMPT_KARDEX----------------------------------
                INSERT INTO PCLUB.ADMPT_KARDEX
                  (ADMPN_ID_KARDEX,
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
                  (ADMPT_KARDEX_SQ.NEXTVAL,
                   C_COD_CLI,
                   V_COD_CPTO,
                   SYSDATE,
                   C_PUNTOS,
                   C_NOM_ARCH,
                   V_TPO_OPER,
                   'C',
                   C_PUNTOS,
                   'A',
                   C_NOM_PROMO);
                ----------------INSERTAR EN PCLUB.ADMPT_SALDOS_CLIENTE----------------------------------
                UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
                   SET ADMPN_SALDO_CC  = C_PUNTOS + NVL(ADMPN_SALDO_CC, 0),
                       ADMPC_ESTPTO_CC = 'A'
                 WHERE ADMPV_COD_CLI = C_COD_CLI;
              END IF;
            END IF;
            -------------INSERTAR EL REGISTRO CORRESPONDIENTE EN LA TABLA PCLUB.ADMPT_AUX_REGULARIZATFI
            INSERT INTO PCLUB.ADMPT_AUX_REGULARIZATFI
              (ADMPV_COD_CLI,
               ADMPV_NOM_REGUL,
               ADMPV_PERIODO,
               ADMPN_PUNTOS,
               ADMPV_NOM_ARCH)
            VALUES
              (C_COD_CLI, C_NOM_PROMO, C_PERIODO, C_PUNTOS, C_NOM_ARCH);
          END;
        END IF;
        FETCH CURSOR_TMP_REGULARIZATFI
          INTO C_COD_CLI,
               C_NOM_PROMO,
               C_PERIODO,
               C_PUNTOS,
               C_NOM_ARCH,
               C_FEC_OPER,
               C_PTOS_ORI;
      END LOOP;
      CLOSE CURSOR_TMP_REGULARIZATFI;
      COMMIT;
    END;

    INSERT INTO PCLUB.ADMPT_IMP_REGULARIZATFI
      (ADMPN_ID_FILA,
       ADMPV_COD_CLI,
       ADMPV_NOM_REGUL,
       ADMPV_PERIODO,
       ADMPN_PUNTOS,
       ADMPV_NOM_ARCH,
       ADMPD_FEC_OPER,
       ADMPV_MSJE_ERROR,
       ADMPD_FEC_TRANS,
       ADMPN_PTOS_ORI)
      SELECT ADMPT_IMP_REGULARIZATFI_SQ.NEXTVAL,
             T.ADMPV_COD_CLI,
             T.ADMPV_NOM_REGUL,
             T.ADMPV_PERIODO,
             CEIL(T.ADMPN_PUNTOS),
             T.ADMPV_NOM_ARCH,
             T.ADMPD_FEC_OPER,
             T.ADMPV_MSJE_ERROR,
             TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY HH:MI PM'),
                     'DD/MM/YYYY HH:MI PM'),
             T.ADMPN_PUNTOS
        FROM PCLUB.ADMPT_TMP_REGULARIZATFI T
       WHERE TRUNC(T.ADMPD_FEC_REG) = TRUNC(K_FECHA)
         AND T.ADMPV_NOM_ARCH = K_NOM_ARCH;

    SELECT COUNT(*)
      INTO K_NUMREGTOT
      FROM PCLUB.ADMPT_TMP_REGULARIZATFI
     WHERE TRUNC(ADMPD_FEC_REG) = TRUNC(K_FECHA)
       AND ADMPV_NOM_ARCH = K_NOM_ARCH; --ADMPD_FEC_OPER=K_FECHA ;
    SELECT COUNT(*)
      INTO K_NUMREGERR
      FROM PCLUB.ADMPT_TMP_REGULARIZATFI
     WHERE TRUNC(ADMPD_FEC_REG) = TRUNC(K_FECHA)
       AND ADMPV_NOM_ARCH = K_NOM_ARCH --ADMPD_FEC_OPER=K_FECHA
       AND (ADMPV_MSJE_ERROR IS NOT NULL);

    SELECT COUNT(*) INTO K_NUMREGPRO FROM PCLUB.ADMPT_AUX_REGULARIZATFI;

    -- Eliminamos los registros de la tabla temporal y auxiliar
    DELETE PCLUB.ADMPT_TMP_REGULARIZATFI
     WHERE TRUNC(ADMPD_FEC_REG) = TRUNC(K_FECHA);
    DELETE PCLUB.ADMPT_AUX_REGULARIZATFI;

    COMMIT;

    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR';
    END;

  EXCEPTION
    WHEN NO_PARAMETROS THEN
      ROLLBACK;
      BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR
          INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_DESCERROR := 'ERROR';
      END;
    WHEN NO_CONCEPTO THEN
      ROLLBACK;
      BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR
          INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_DESCERROR := 'ERROR';
      END;
    WHEN OTHERS THEN
      ROLLBACK;
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

  END ADMPSI_REGULARIZACION_TFI;

  PROCEDURE ADMPSS_EREGULARIZA_TFI(K_FECHA                IN DATE,
                                   K_CODERROR             OUT NUMBER,
                                   K_DESCERROR            OUT VARCHAR2,
                                   CURSOR_EREGULARIZA_TFI OUT SYS_REFCURSOR) IS
    --****************************************************************
    -- Nombre SP           :  ADMPSS_EREGULARIZA_TFI
    -- Propósito           :  Devuelve en un cursor solo los puntos por Promoción que no pudieron ser agregadas por algún error controlado
    -- Input               :  K_FECHA - Fecha de Proceso
    -- Output              :  CURSOR_EREGULARIZA_TFI Cursor que Contiene Lista de Clientes con Registro de Puntos de Promocion que generaron Errores
    -- Creado por          :  Susana Ramos
    -- Fec Creación        :
    -- Fec Actualización   :  22/05/2012
    --****************************************************************
    NO_PARAMETROS EXCEPTION;
  BEGIN
    K_CODERROR := 0;
    IF K_FECHA IS NULL THEN
      RAISE NO_PARAMETROS;
    END IF;

    OPEN CURSOR_EREGULARIZA_TFI FOR
      SELECT ADMPV_COD_CLI,
             ADMPV_NOM_REGUL,
             ADMPV_PERIODO,
             ADMPN_PUNTOS,
             ADMPV_NOM_ARCH,
             ADMPV_MSJE_ERROR
        FROM PCLUB.ADMPT_IMP_REGULARIZATFI
       WHERE ADMPV_MSJE_ERROR IS NOT NULL
         AND ADMPD_FEC_OPER = K_FECHA;
  EXCEPTION
    WHEN NO_PARAMETROS THEN
      K_CODERROR  := 41;
      K_DESCERROR := 'Ingresó datos incorrectos o datos insuficientes para realizar la consulta';
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
  END ADMPSS_EREGULARIZA_TFI;

  PROCEDURE ADMPSI_ALTACLI_TFI(K_FECHA     IN DATE,
                               K_CODERROR  OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2,
                               K_NUMREGTOT OUT NUMBER,
                               K_NUMREGPRO OUT NUMBER,
                               K_NUMREGERR OUT NUMBER) is
    --****************************************************************
    -- Nombre SP           :  ADMPSI_ALTA_CLIENTE
    -- Propósito           :  Dar de Alta como Clientes ClaroClub, a los Clientes TFI Prepago
    -- Input               :  K_FECHA
    -- Output              :  K_CODERROR
    --                        K_DESCERROR
    --                        K_NUMREGTOT
    --                        K_NUMREGPRO
    --                        K_NUMREGERR
    -- Creado por          :  Roxana Chero
    -- Fec Creación        :  04/04/2013
    --****************************************************************
    V_EXIST      NUMBER;
    V_CADENA     VARCHAR(50);
    V_REG_VALIDO CHAR(1);

    V_REGCLI     NUMBER;
    V_REGCLI2    NUMBER;
    C_NOMARCHIVO VARCHAR2(150);
    V_TIPODOC    VARCHAR2(20);
    C_TIPODOC    VARCHAR2(20);
    C_NUMDOC     VARCHAR2(20);
    C_NOMCLI     VARCHAR2(60);
    C_APECLI     VARCHAR2(60);
    C_SEXO       VARCHAR(1);
    C_ESTCIV     VARCHAR2(20);
    C_CODCLI     VARCHAR2(40);
    V_CODCLI     VARCHAR2(40);
    C_EMAIL      VARCHAR2(80);
    C_PROV       VARCHAR(30);
    C_DEPA       VARCHAR2(40);
    C_DIST       VARCHAR2(200);
    C_SEQ        NUMBER;
    /**********************/

    CURSOR ALTACLIENTES IS
      SELECT a.ADMPV_COD_CLI,
             a.ADMPV_TIPO_DOC,
             a.ADMPV_NUM_DOC,
             a.ADMPV_NOM_CLI,
             a.ADMPV_APE_CLI,
             a.ADMPC_SEXO,
             a.ADMPV_EST_CIVIL,
             a.ADMPV_EMAIL,
             a.ADMPV_DEPA,
             a.ADMPV_PROV,
             a.ADMPV_DIST,
             a.ADMPV_NOM_ARCH,
             a.admpn_seq
        FROM PCLUB.ADMPT_TMP_ALTACLI_TFI a
       WHERE a.ADMPD_FEC_OPER = K_FECHA
         AND (a.ADMPV_COD_ERROR IS NULL);

  BEGIN

    -- Validamos que se haya enviado un numero de telefono
    UPDATE PCLUB.ADMPT_TMP_ALTACLI_TFI
       SET ADMPV_COD_ERROR  = '50',
           ADMPV_MSJE_ERROR = 'El numero de telefono es un dato obligatorio.'
     WHERE ADMPV_COD_CLI = ''
        OR ADMPV_COD_CLI IS NULL;
    -- Validamos que se haya enviado el numero de documento
    UPDATE PCLUB.ADMPT_TMP_ALTACLI_TFI
       SET ADMPV_COD_ERROR  = '51',
           ADMPV_MSJE_ERROR = 'El numero de documento es un dato obligatorio.'
     WHERE (ADMPV_NUM_DOC = '' OR ADMPV_NUM_DOC IS NULL);

    -- Validamos que se haya enviado el tipo de documento
    UPDATE PCLUB.ADMPT_TMP_ALTACLI_TFI
       SET ADMPV_COD_ERROR  = '52',
           ADMPV_MSJE_ERROR = 'El tipo de documento es un dato obligatorio.'
     WHERE ADMPV_TIPO_DOC = ''
        OR ADMPV_TIPO_DOC IS NULL;

    -- Validamos que se haya enviado un tipo de documento valido
    UPDATE PCLUB.ADMPT_TMP_ALTACLI_TFI
       SET ADMPV_COD_ERROR  = '53',
           ADMPV_MSJE_ERROR = 'El tipo de documento no es aceptado.'
     WHERE NOT EXISTS
     (SELECT 1
              FROM PCLUB.ADMPT_TIPO_DOC TD
             WHERE UPPER(TD.ADMPV_EQU_DWH) = UPPER(ADMPV_TIPO_DOC));

    --Validamos que se ingrese un numero de DNI Valido
    UPDATE PCLUB.ADMPT_TMP_ALTACLI_TFI
       SET ADMPV_COD_ERROR  = '54',
           ADMPV_MSJE_ERROR = 'Numero de DNI no valido.'
     WHERE (UPPER(ADMPV_TIPO_DOC) = 'DNI' AND LENGTH(ADMPV_NUM_DOC) <> 8);

    --Validamos que no exista ya el cliente registrado en ClaroClub
    UPDATE PCLUB.ADMPT_TMP_ALTACLI_TFI
       SET ADMPV_COD_ERROR  = '33',
           ADMPV_MSJE_ERROR = 'El codigo de cliente ya existe.'
     WHERE EXISTS
     (SELECT 1
              FROM PCLUB.ADMPT_CLIENTE c
             WHERE c.ADMPV_COD_CLI = SUBSTR(ADMPV_COD_CLI, 3, 8));

    COMMIT;

    OPEN ALTACLIENTES;
    FETCH ALTACLIENTES
      INTO C_CODCLI,
           C_TIPODOC,
           C_NUMDOC,
           C_NOMCLI,
           C_APECLI,
           C_SEXO,
           C_ESTCIV,
           C_EMAIL,
           C_DEPA,
           C_PROV,
           C_DIST,
           C_NOMARCHIVO,
           C_SEQ;

    WHILE ALTACLIENTES %FOUND LOOP
      V_REG_VALIDO := 'V';
      V_REGCLI     := 0;

      SELECT COUNT(1)
        INTO V_REGCLI
        FROM PCLUB.ADMPT_AUX_ALTACLI_TFI
       WHERE ADMPV_TIPO_DOC = C_TIPODOC
         AND ADMPV_NUM_DOC = C_NUMDOC
         AND ADMPV_NOM_CLI = C_NOMCLI
         AND ADMPV_APE_CLI = C_APECLI
         AND ADMPV_COD_CLI = C_CODCLI
         AND ADMPD_FEC_OPER = K_FECHA
         AND NVL(ADMPV_NOM_ARCH, NULL) = C_NOMARCHIVO;

      IF (V_REGCLI = 0) THEN
        BEGIN
          -- Realizamos la conversión del tipo de documento
          SELECT ADMPV_COD_TPDOC
            INTO V_TIPODOC
            FROM PCLUB.ADMPT_TIPO_DOC A
           WHERE UPPER(A.ADMPV_EQU_DWH) = UPPER(C_TIPODOC);

          IF V_TIPODOC = '2' THEN
            --Validamos que el numero de DNI sea numerico

            SELECT translate(C_NUMDOC, '0123456789', '')
              into V_CADENA
              FROM dual;
            IF (V_CADENA IS NOT NULL OR TRIM(V_CADENA) <> '') THEN
              V_REG_VALIDO := 'F';

              UPDATE PCLUB.ADMPT_TMP_ALTACLI_TFI TF
                 SET ADMPV_COD_ERROR  = '60',
                     ADMPV_MSJE_ERROR = 'Numero de DNI no valido.'
               WHERE ADMPV_COD_CLI = C_CODCLI
                 AND ADMPV_TIPO_DOC = C_TIPODOC
                 AND ADMPV_NUM_DOC = C_NUMDOC;

            END IF;
          ELSE
            V_REG_VALIDO := 'V';

          END IF;

          IF V_REG_VALIDO = 'V' THEN
            --Conversion del Numero de Celular
            V_CODCLI := SUBSTR(C_CODCLI, 3, 8);

            SELECT COUNT(*)
              INTO V_REGCLI2
              FROM PCLUB.ADMPT_CLIENTE CLI
             WHERE CLI.ADMPV_COD_CLI = V_CODCLI
               AND CLI.ADMPC_ESTADO = 'A';

            IF V_REGCLI2 = 0 THEN
              -- insertar los clientes en la tabla de Clientes
              INSERT INTO PCLUB.ADMPT_CLIENTE H
                (H.ADMPV_COD_CLI,
                 H.ADMPV_COD_SEGCLI,
                 H.ADMPN_COD_CATCLI,
                 H.ADMPV_TIPO_DOC,
                 H.ADMPV_NUM_DOC,
                 H.ADMPV_NOM_CLI,
                 H.ADMPV_APE_CLI,
                 H.ADMPC_SEXO,
                 H.ADMPV_EST_CIVIL,
                 H.ADMPV_EMAIL,
                 H.ADMPV_PROV,
                 H.ADMPV_DEPA,
                 H.ADMPV_DIST,
                 H.ADMPD_FEC_ACTIV,
                 H.ADMPV_CICL_FACT,
                 H.ADMPC_ESTADO,
                 H.ADMPD_FEC_REG,
                 H.ADMPV_USU_REG,
                 H.ADMPV_COD_TPOCL)
              VALUES
                (V_CODCLI,
                 null,
                 2,
                 V_TIPODOC,
                 C_NUMDOC,
                 C_NOMCLI,
                 C_APECLI,
                 C_SEXO,
                 C_ESTCIV,
                 C_EMAIL,
                 C_PROV,
                 C_DEPA,
                 C_DIST,
                 SYSDATE,
                 null,
                 'A',
                 SYSDATE,
                 'USRALTATFI',
                 '8');

              --Inserto/actualizo saldos
              SELECT NVL(COUNT(*), 0)
                INTO V_EXIST
                FROM PCLUB.ADMPT_SALDOS_CLIENTE S
               WHERE S.ADMPV_COD_CLI = V_CODCLI;

              IF V_EXIST = 0 THEN
                INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE
                  (ADMPN_ID_SALDO,
                   ADMPV_COD_CLI,
                   ADMPN_COD_CLI_IB,
                   ADMPN_SALDO_CC,
                   ADMPN_SALDO_IB,
                   ADMPC_ESTPTO_CC,
                   ADMPC_ESTPTO_IB)
                VALUES
                  (ADMPT_SLD_CL_SQ.NEXTVAL,
                   V_CODCLI,
                   NULL,
                   0,
                   0,
                   'A',
                   NULL);
              ELSE
                UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
                   SET ADMPN_SALDO_IB = 0, ADMPN_SALDO_CC = 0
                 WHERE ADMPV_COD_CLI = V_CODCLI;
              END IF;
              ------------------------------------------------

              -- Insertamos en la auxiliar para los reprocesos
              INSERT INTO PCLUB.ADMPT_AUX_ALTACLI_TFI t
                (t.admpv_tipo_doc,
                 t.admpv_num_doc,
                 t.admpv_nom_cli,
                 t.admpv_ape_cli,
                 t.admpv_cod_cli,
                 t.admpd_fec_oper,
                 t.admpv_nom_arch)
              VALUES
                (C_TIPODOC,
                 C_NUMDOC,
                 C_NOMCLI,
                 C_APECLI,
                 C_CODCLI,
                 K_FECHA,
                 C_NOMARCHIVO);

            ELSE
              UPDATE PCLUB.ADMPT_TMP_ALTACLI_TFI AC
                 SET AC.ADMPV_COD_ERROR  = '33',
                     AC.ADMPV_MSJE_ERROR = 'El codigo de cliente ya existe.'
               WHERE ADMPV_COD_CLI = C_CODCLI
                 AND ADMPD_FEC_OPER = K_FECHA
                 AND NVL(ADMPV_NOM_ARCH, NULL) = C_NOMARCHIVO
                 AND ADMPN_SEQ = C_SEQ;
            END IF;
          END IF;

        END;
      ELSE

        UPDATE PCLUB.ADMPT_TMP_ALTACLI_TFI AC
           SET AC.ADMPV_COD_ERROR  = '12',
               AC.ADMPV_MSJE_ERROR = 'Registro ya procesado.'
         WHERE ADMPV_COD_CLI = C_CODCLI
           AND ADMPD_FEC_OPER = K_FECHA
           AND NVL(ADMPV_NOM_ARCH, NULL) = C_NOMARCHIVO
           AND ADMPN_SEQ = C_SEQ;

      END IF;

      FETCH ALTACLIENTES
        INTO C_CODCLI,
             C_TIPODOC,
             C_NUMDOC,
             C_NOMCLI,
             C_APECLI,
             C_SEXO,
             C_ESTCIV,
             C_EMAIL,
             C_DEPA,
             C_PROV,
             C_DIST,
             C_NOMARCHIVO,
             C_SEQ;

    END LOOP;

    -- Obtenemos los registros totales, procesados y con error
    SELECT COUNT(1)
      INTO K_NUMREGTOT
      FROM PCLUB.ADMPT_TMP_ALTACLI_TFI
     WHERE ADMPD_FEC_OPER = K_FECHA;
    SELECT COUNT(1)
      INTO K_NUMREGERR
      FROM PCLUB.ADMPT_TMP_ALTACLI_TFI
     WHERE ADMPD_FEC_OPER = K_FECHA
       AND (ADMPV_COD_ERROR IS NOT NULL);
    SELECT COUNT(1)
      INTO K_NUMREGPRO
      FROM PCLUB.ADMPT_AUX_ALTACLI_TFI
     WHERE (ADMPD_FEC_OPER = K_FECHA);

    -- Insertamos de la tabla temporal a la final
    INSERT INTO PCLUB.ADMPT_IMP_ALTACLI_TFI
      SELECT ADMPT_IMP_ALTACLITFI_SQ.nextval,
             ADMPV_COD_CLI,
             ADMPV_TIPO_DOC,
             ADMPV_NUM_DOC,
             ADMPV_NOM_CLI,
             ADMPV_APE_CLI,
             ADMPC_SEXO,
             ADMPV_EST_CIVIL,
             ADMPV_EMAIL,
             ADMPV_DEPA,
             ADMPV_PROV,
             ADMPV_DIST,
             ADMPD_FEC_OPER,
             ADMPV_NOM_ARCH,
             ADMPV_COD_ERROR,
             ADMPV_MSJE_ERROR,
             SYSDATE,
             ADMPN_SEQ,
             ADMPV_COD_NV_CLI,
             ADMPD_FEC_ACTIV,
             ADMPV_TIPO_CLI
        FROM PCLUB.ADMPT_TMP_ALTACLI_TFI
       WHERE admpd_fec_oper = K_FECHA;

    -- Eliminamos los registros de la tabla temporal y auxiliar
    DELETE PCLUB.ADMPT_AUX_ALTACLI_TFI WHERE ADMPD_FEC_OPER = K_FECHA;
    DELETE PCLUB.ADMPT_TMP_ALTACLI_TFI WHERE ADMPD_FEC_OPER = K_FECHA;

    COMMIT;

    K_CODERROR  := 0;
    K_DESCERROR := '';

  EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

  END ADMPSI_ALTACLI_TFI;

  PROCEDURE ADMPSI_REGLINEAS(K_FECHA     IN DATE,
                             K_TIPCLI    IN VARCHAR2,
                             K_CODERROR  OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2,
                             K_NUMREGTOT OUT NUMBER,
                             K_NUMREGPRO OUT NUMBER,
                             K_NUMREGERR OUT NUMBER) is
  --****************************************************************
  -- Nombre SP           :  ADMPSI_REGLINEAS_TFI
  -- Propósito           :  Registrar las nuevas líneas de los Clientes TFI/Prepago
  -- Input               :  K_FECHA
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  --                        K_NUMREGTOT
  --                        K_NUMREGPRO
  --                        K_NUMREGERR
  -- Creado por          :  Roxana Chero
  -- Fec Creación        :  24/06/2013
  --****************************************************************
  V_EXIST      NUMBER;
  V_CADENA     VARCHAR2(50);
  V_REG_VALIDO CHAR(1);
  V_REGEXICLI  NUMBER;

  V_REGCLI     NUMBER;
  V_REGCLI2    NUMBER;
  C_NOMARCHIVO VARCHAR2(150);
  V_TIPODOC    VARCHAR2(20);
  C_TIPODOC    VARCHAR2(20);
  C_NUMDOC     VARCHAR2(20);
  C_NOMCLI     VARCHAR2(100);
  C_APECLI     VARCHAR2(100);
  C_SEXO       VARCHAR2(20);
  C_ESTCIV     VARCHAR2(20);
  C_CODCLI     VARCHAR2(40);
  C_EMAIL      VARCHAR2(100);
  C_PROV       VARCHAR2(100);
  C_DEPA       VARCHAR2(100);
  C_DIST       VARCHAR2(200);
  C_SEQ        NUMBER;
  C_CODNVCLI   VARCHAR2(40);
  C_FEC_ACTIV  DATE;
  C_TIPO_CLI   VARCHAR2(3);
  /**********************/

  CURSOR ALTACLIENTES IS
    SELECT a.ADMPV_COD_CLI,
           a.ADMPV_TIPO_DOC,
           a.ADMPV_NUM_DOC,
           a.ADMPV_NOM_CLI,
           a.ADMPV_APE_CLI,
           a.ADMPC_SEXO,
           a.ADMPV_EST_CIVIL,
           a.ADMPV_EMAIL,
           a.ADMPV_DEPA,
           a.ADMPV_PROV,
           a.ADMPV_DIST,
           a.ADMPV_NOM_ARCH,
           a.admpn_seq,
           a.ADMPV_COD_NV_CLI,
           a.ADMPD_FEC_ACTIV,
           a.admpv_tipo_cli
      FROM PCLUB.ADMPT_TMP_ALTACLI_TFI a
     WHERE a.ADMPD_FEC_OPER = K_FECHA
       AND a.admpv_tipo_cli = K_TIPCLI
       AND a.ADMPV_COD_ERROR IS NULL;

BEGIN

  -- Validamos que se haya enviado un número de teléfono
  UPDATE PCLUB.ADMPT_TMP_ALTACLI_TFI
     SET ADMPV_COD_ERROR  = '50',
         ADMPV_MSJE_ERROR = 'El número de teléfono es un dato obligatorio.'
   WHERE (ADMPV_COD_CLI = '' OR ADMPV_COD_CLI IS NULL)
      AND ADMPV_TIPO_CLI = K_TIPCLI;
  -- Validamos que se haya enviado el número de documento
  UPDATE PCLUB.ADMPT_TMP_ALTACLI_TFI
     SET ADMPV_COD_ERROR  = '51',
         ADMPV_MSJE_ERROR = 'El número de documento es un dato obligatorio.'
   WHERE (ADMPV_NUM_DOC = '' OR ADMPV_NUM_DOC IS NULL)
     AND ADMPV_TIPO_CLI = K_TIPCLI;

  -- Validamos que se haya enviado el tipo de documento
  UPDATE PCLUB.ADMPT_TMP_ALTACLI_TFI
     SET ADMPV_COD_ERROR  = '52',
         ADMPV_MSJE_ERROR = 'El tipo de documento es un dato obligatorio.'
   WHERE (ADMPV_TIPO_DOC = '' OR ADMPV_TIPO_DOC IS NULL)
     AND ADMPV_TIPO_CLI = K_TIPCLI;
  
  -- Validamos que se haya enviado la fecha de activación
  UPDATE ADMPT_TMP_ALTACLI_TFI
     SET ADMPV_COD_ERROR  = '55',
         ADMPV_MSJE_ERROR = 'La fecha de activación es un dato obligatorio.'
   WHERE (ADMPD_FEC_ACTIV = '' OR ADMPD_FEC_ACTIV IS NULL)
     AND ADMPV_TIPO_CLI = K_TIPCLI;

  -- Validamos que se haya enviado un tipo de documento valido
  UPDATE PCLUB.ADMPT_TMP_ALTACLI_TFI
     SET ADMPV_COD_ERROR  = '53',
         ADMPV_MSJE_ERROR = 'El tipo de documento no es válido.'
   WHERE NOT EXISTS
   (SELECT 1
            FROM PCLUB.ADMPT_TIPO_DOC TD
           WHERE UPPER(TD.ADMPV_EQU_DWH) = UPPER(ADMPV_TIPO_DOC))
   AND ADMPV_TIPO_CLI = K_TIPCLI;

  --Validamos que se ingrese un numero de DNI Valido
  UPDATE PCLUB.ADMPT_TMP_ALTACLI_TFI
     SET ADMPV_COD_ERROR  = '54',
         ADMPV_MSJE_ERROR = 'Número de DNI no válido.'
   WHERE (UPPER(ADMPV_TIPO_DOC) = 'DNI' AND LENGTH(ADMPV_NUM_DOC) <> 8)
     AND ADMPV_TIPO_CLI = K_TIPCLI;

  --Validamos que no exista ya el cliente registrado en ClaroClub
  UPDATE PCLUB.ADMPT_TMP_ALTACLI_TFI
     SET ADMPV_COD_ERROR  = '33',
         ADMPV_MSJE_ERROR = 'El código de cliente ya existe.'
   WHERE EXISTS
   (SELECT 1
            FROM PCLUB.ADMPT_CLIENTE c
           WHERE c.ADMPV_COD_CLI = ADMPV_COD_NV_CLI)
     AND ADMPV_TIPO_CLI = K_TIPCLI;

  COMMIT;

  OPEN ALTACLIENTES;
  FETCH ALTACLIENTES
    INTO C_CODCLI,
         C_TIPODOC,
         C_NUMDOC,
         C_NOMCLI,
         C_APECLI,
         C_SEXO,
         C_ESTCIV,
         C_EMAIL,
         C_DEPA,
         C_PROV,
         C_DIST,
         C_NOMARCHIVO,
         C_SEQ,
         C_CODNVCLI,
         C_FEC_ACTIV,
         C_TIPO_CLI;

  WHILE ALTACLIENTES %FOUND LOOP
    V_REG_VALIDO := 'V';
    V_REGCLI     := 0;
  
    SELECT COUNT(1)
      INTO V_REGCLI
      FROM PCLUB.ADMPT_AUX_ALTACLI_TFI
     WHERE ADMPV_TIPO_DOC = C_TIPODOC
       AND ADMPV_NUM_DOC = C_NUMDOC
       AND ADMPV_NOM_CLI = C_NOMCLI
       AND ADMPV_APE_CLI = C_APECLI
       AND ADMPV_COD_CLI = C_CODCLI
       AND ADMPD_FEC_OPER = K_FECHA
       AND ADMPV_TIPO_CLI = C_TIPO_CLI
       AND NVL(ADMPV_NOM_ARCH, NULL) = C_NOMARCHIVO;
  
    IF (V_REGCLI = 0) THEN
      BEGIN
        -- Realizamos la conversión del tipo de documento
        SELECT ADMPV_COD_TPDOC
          INTO V_TIPODOC
          FROM PCLUB.ADMPT_TIPO_DOC A
         WHERE UPPER(A.ADMPV_EQU_DWH) = UPPER(C_TIPODOC);
      
        IF V_TIPODOC = '2' THEN
          --Validamos que el numero de DNI sea numerico
        
          SELECT translate(C_NUMDOC, '0123456789', '')
            into V_CADENA
            FROM dual;
          IF (V_CADENA IS NOT NULL OR TRIM(V_CADENA) <> '') THEN
            V_REG_VALIDO := 'F';
          
            UPDATE PCLUB.ADMPT_TMP_ALTACLI_TFI TF
               SET ADMPV_COD_ERROR  = '60',
                   ADMPV_MSJE_ERROR = 'Número de DNI no válido.'
             WHERE ADMPV_COD_CLI = C_CODCLI
               AND ADMPV_TIPO_DOC = C_TIPODOC
               AND ADMPV_NUM_DOC = C_NUMDOC
               AND ADMPV_TIPO_CLI = C_TIPO_CLI;
          
          END IF;
        ELSIF V_TIPODOC = '0' THEN
            V_REG_VALIDO := 'F';
            --Validamos que no se permita registrar clientes con Tipo de documento RUC
            UPDATE PCLUB.ADMPT_TMP_ALTACLI_TFI TF
               SET ADMPV_COD_ERROR  = '58',
                   ADMPV_MSJE_ERROR = 'El tipo de documento RUC, no es válido.'
             WHERE ADMPV_COD_CLI = C_CODCLI
               AND ADMPV_TIPO_DOC = C_TIPODOC
               AND ADMPV_NUM_DOC = C_NUMDOC
               AND ADMPV_TIPO_CLI = C_TIPO_CLI;
        ELSE
          V_REG_VALIDO := 'V';
        END IF;
      
        IF V_REG_VALIDO = 'V' THEN
          --Conversión del Número de Celular
          --V_CODCLI := SUBSTR(C_CODCLI, 3, 8);
        
          --validamos que exista el Cliente en ClaroClub
        
          SELECT COUNT(1)
            INTO V_REGEXICLI
            FROM PCLUB.ADMPT_CLIENTE CLI
           WHERE CLI.ADMPV_TIPO_DOC = V_TIPODOC
             AND CLI.ADMPV_NUM_DOC = C_NUMDOC
             AND CLI.ADMPV_COD_TPOCL = K_TIPCLI
             AND CLI.ADMPC_ESTADO = 'A';
        
          IF V_REGEXICLI = 0 THEN
            UPDATE PCLUB.ADMPT_TMP_ALTACLI_TFI AC
               SET AC.ADMPV_COD_ERROR  = '36',
                   AC.ADMPV_MSJE_ERROR = 'El Cliente no existe en ClaroClub.'
             WHERE ADMPV_COD_CLI = C_CODCLI
               AND ADMPV_TIPO_DOC = C_TIPODOC
               AND ADMPV_NUM_DOC = C_NUMDOC
               AND ADMPD_FEC_OPER = K_FECHA
               AND ADMPV_TIPO_CLI = K_TIPCLI
               AND NVL(ADMPV_NOM_ARCH, NULL) = C_NOMARCHIVO
               AND ADMPN_SEQ = C_SEQ;
          ELSE
          
            SELECT COUNT(1)
              INTO V_REGCLI2
              FROM PCLUB.ADMPT_CLIENTE CLI
             WHERE CLI.ADMPV_COD_CLI = C_CODNVCLI
               AND CLI.ADMPV_COD_TPOCL = K_TIPCLI
               AND CLI.ADMPC_ESTADO = 'A';
          
            IF V_REGCLI2 = 0 THEN
              -- insertar los clientes en la tabla de Clientes
              INSERT INTO PCLUB.ADMPT_CLIENTE H
                (H.ADMPV_COD_CLI,
                 H.ADMPV_COD_SEGCLI,
                 H.ADMPN_COD_CATCLI,
                 H.ADMPV_TIPO_DOC,
                 H.ADMPV_NUM_DOC,
                 H.ADMPV_NOM_CLI,
                 H.ADMPV_APE_CLI,
                 H.ADMPC_SEXO,
                 H.ADMPV_EST_CIVIL,
                 H.ADMPV_EMAIL,
                 H.ADMPV_PROV,
                 H.ADMPV_DEPA,
                 H.ADMPV_DIST,
                 H.ADMPD_FEC_ACTIV,
                 H.ADMPV_CICL_FACT,
                 H.ADMPC_ESTADO,
                 H.ADMPD_FEC_REG,
                 H.ADMPV_USU_REG,
                 H.ADMPV_COD_TPOCL)
              VALUES
                (C_CODNVCLI,
                 null,
                 2,
                 V_TIPODOC,
                 C_NUMDOC,
                 C_NOMCLI,
                 C_APECLI,
                 C_SEXO,
                 C_ESTCIV,
                 C_EMAIL,
                 C_PROV,
                 C_DEPA,
                 C_DIST,
                 C_FEC_ACTIV,
                 null,
                 'A',
                 SYSDATE,
                 'USRREGCLICC',
                 K_TIPCLI);
            
              --Inserto/actualizo saldos
              SELECT NVL(COUNT(1), 0)
                INTO V_EXIST
                FROM PCLUB.ADMPT_SALDOS_CLIENTE S
               WHERE S.ADMPV_COD_CLI = C_CODNVCLI;
            
              IF V_EXIST = 0 THEN
                INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE
                  (ADMPN_ID_SALDO,
                   ADMPV_COD_CLI,
                   ADMPN_COD_CLI_IB,
                   ADMPN_SALDO_CC,
                   ADMPN_SALDO_IB,
                   ADMPC_ESTPTO_CC,
                   ADMPC_ESTPTO_IB)
                VALUES
                  (ADMPT_SLD_CL_SQ.NEXTVAL,
                   C_CODNVCLI,
                   NULL,
                   0,
                   0,
                   'A',
                   NULL);
              ELSE
                UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
                   SET ADMPN_SALDO_IB = 0, ADMPN_SALDO_CC = 0
                 WHERE ADMPV_COD_CLI = C_CODNVCLI;
              END IF;
              ------------------------------------------------
            
              -- Insertamos en la auxiliar para los reprocesos
              INSERT INTO PCLUB.ADMPT_AUX_ALTACLI_TFI t
                (t.admpv_tipo_doc,
                 t.admpv_num_doc,
                 t.admpv_nom_cli,
                 t.admpv_ape_cli,
                 t.admpv_cod_cli,
                 t.admpd_fec_oper,
                 t.admpv_nom_arch,
                 t.admpv_tipo_cli)
              VALUES
                (C_TIPODOC,
                 C_NUMDOC,
                 C_NOMCLI,
                 C_APECLI,
                 C_CODCLI,
                 K_FECHA,
                 C_NOMARCHIVO,
                 C_TIPO_CLI);
            
            ELSE
              UPDATE PCLUB.ADMPT_TMP_ALTACLI_TFI AC
                 SET AC.ADMPV_COD_ERROR  = '33',
                     AC.ADMPV_MSJE_ERROR = 'El código de Cliente ya existe en ClaroClub.'
               WHERE ADMPV_COD_CLI = C_CODCLI
                 AND ADMPD_FEC_OPER = K_FECHA
                 AND ADMPV_TIPO_CLI = K_TIPCLI
                 AND NVL(ADMPV_NOM_ARCH, NULL) = C_NOMARCHIVO
                 AND ADMPN_SEQ = C_SEQ;
            END IF;
          
          END IF;
        
        END IF;
      
      END;
    ELSE
    
      UPDATE PCLUB.ADMPT_TMP_ALTACLI_TFI AC
         SET AC.ADMPV_COD_ERROR  = '12',
             AC.ADMPV_MSJE_ERROR = 'Registro ya procesado.'
       WHERE ADMPV_COD_CLI = C_CODCLI
         AND ADMPD_FEC_OPER = K_FECHA
         AND ADMPV_TIPO_CLI = K_TIPCLI
         AND NVL(ADMPV_NOM_ARCH, NULL) = C_NOMARCHIVO
         AND ADMPN_SEQ = C_SEQ;
    
    END IF;
  
    FETCH ALTACLIENTES
      INTO C_CODCLI,
           C_TIPODOC,
           C_NUMDOC,
           C_NOMCLI,
           C_APECLI,
           C_SEXO,
           C_ESTCIV,
           C_EMAIL,
           C_DEPA,
           C_PROV,
           C_DIST,
           C_NOMARCHIVO,
           C_SEQ,
           C_CODNVCLI,
           C_FEC_ACTIV,
           C_TIPO_CLI;
  
  END LOOP;

  -- Obtenemos los registros totales, procesados y con error
  SELECT COUNT(1)
    INTO K_NUMREGTOT
    FROM PCLUB.ADMPT_TMP_ALTACLI_TFI
   WHERE ADMPD_FEC_OPER = K_FECHA
     AND ADMPV_TIPO_CLI = K_TIPCLI;
  SELECT COUNT(1)
    INTO K_NUMREGERR
    FROM PCLUB.ADMPT_TMP_ALTACLI_TFI
   WHERE ADMPD_FEC_OPER = K_FECHA
     AND ADMPV_TIPO_CLI = K_TIPCLI
     AND (ADMPV_COD_ERROR IS NOT NULL);
  SELECT COUNT(1)
    INTO K_NUMREGPRO
    FROM PCLUB.ADMPT_AUX_ALTACLI_TFI
   WHERE ADMPD_FEC_OPER = K_FECHA
     AND ADMPV_TIPO_CLI = K_TIPCLI;

  -- Insertamos de la tabla temporal a la final
  INSERT INTO PCLUB.ADMPT_IMP_ALTACLI_TFI
    SELECT ADMPT_IMP_ALTACLITFI_SQ.nextval,
           ADMPV_COD_CLI,
           ADMPV_TIPO_DOC,
           ADMPV_NUM_DOC,
           ADMPV_NOM_CLI,
           ADMPV_APE_CLI,
           ADMPC_SEXO,
           ADMPV_EST_CIVIL,
           ADMPV_EMAIL,
           ADMPV_DEPA,
           ADMPV_PROV,
           ADMPV_DIST,
           ADMPD_FEC_OPER,
           ADMPV_NOM_ARCH,
           ADMPV_COD_ERROR,
           ADMPV_MSJE_ERROR,
           SYSDATE,
           ADMPN_SEQ,
           ADMPV_COD_NV_CLI,
           ADMPD_FEC_ACTIV,
           ADMPV_TIPO_CLI
      FROM PCLUB.ADMPT_TMP_ALTACLI_TFI
     WHERE admpd_fec_oper = K_FECHA
         AND ADMPV_TIPO_CLI = K_TIPCLI;

  -- Eliminamos los registros de la tabla temporal y auxiliar
  DELETE PCLUB.ADMPT_AUX_ALTACLI_TFI
     WHERE ADMPD_FEC_OPER = K_FECHA
       AND ADMPV_TIPO_CLI = K_TIPCLI;
    DELETE PCLUB.ADMPT_TMP_ALTACLI_TFI
     WHERE ADMPD_FEC_OPER = K_FECHA
       AND ADMPV_TIPO_CLI = K_TIPCLI;

  COMMIT;

  K_CODERROR  := 0;
  K_DESCERROR := '';

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR  := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
  
END ADMPSI_REGLINEAS;


  PROCEDURE ADMPSI_EALTACLI(K_FECHAPROC  IN DATE,
                            K_TIPCLI     IN VARCHAR2,
                            CURSORALTCLI out SYS_REFCURSOR) is
    --****************************************************************
    -- Nombre SP           :  ADMPSI_EALTACLI_TFI
    -- Propósito           :  Devuelve en un cursor solo con los registros con errores encontrados en el proceso de Alta de Clientes TFI Prepago
    -- Input               :  K_FECHAPROC, K_TIPCLI
    -- Output              :  CURSORREGPTO
    -- Fec Creación        :  11/04/2013
    --****************************************************************

  BEGIN

    OPEN CURSORALTCLI FOR
      SELECT TRIM(ADMPV_COD_CLI),
             TRIM(ADMPV_TIPO_DOC),
             TRIM(ADMPV_NUM_DOC),
             TRIM(ADMPV_NOM_CLI),
             TRIM(ADMPV_APE_CLI),
             TRIM(ADMPC_SEXO),
             TRIM(ADMPV_EST_CIVIL),
             TRIM(ADMPV_EMAIL),
             TRIM(ADMPV_DEPA),
             TRIM(ADMPV_PROV),
             TRIM(ADMPV_DIST),
             TO_DATE(TO_CHAR(ADMPD_FEC_OPER, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
             TRIM(ADMPV_NOM_ARCH),
             TRIM(ADMPV_COD_ERROR),
             TRIM(ADMPV_MSJE_ERROR)
        FROM PCLUB.ADMPT_IMP_ALTACLI_TFI
       WHERE ADMPD_FEC_OPER = K_FECHAPROC
         AND ADMPV_TIPO_CLI = K_TIPCLI
         AND ADMPV_COD_ERROR Is Not Null
         AND TRIM(ADMPV_MSJE_ERROR) <> ' '
       ORDER BY ADMPN_SEQ ASC;

  END ADMPSI_EALTACLI;

  PROCEDURE ADMPSI_TFICMBTIT(K_FEC_PRO   IN DATE,
                             K_CODERROR  OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2,
                             K_TOT_REG   OUT NUMBER,
                             K_TOT_PRO   OUT NUMBER,
                             K_TOT_ERR   OUT NUMBER) is
    --****************************************************************
    -- Nombre SP           :  ADMPSI_TFICMBTIT
    -- Propósito           :  Proceso de cambio de Titular de Clientes TFI Prepago
    -- Input               :  K_FEC_PRO Fecha de Proceso
    -- Output              :  K_CODERROR Codigo de Error o Exito
    --                        K_DESCERROR Descripcion del Error (si se presento)
    --                        K_TOT_REG Total de Registros
    --                        K_TOT_PRO Total de Procesados
    --                        K_TOT_ERR Total de Errados
    -- Creado por          :  Roxana Chero
    -- Fec Creacion        :  08/04/2013
    --****************************************************************

    TYPE CURCLARO_CAMBIOTITULAR IS REF CURSOR;
    C_CUR_CMBTITULAR CURCLARO_CAMBIOTITULAR;

    C_CODCLIENTE  VARCHAR2(40);
    V_SALDO_CLI   NUMBER;
    V_CODCONCEPTO VARCHAR2(2);
    V_IDKARDEX    NUMBER;
    V_IDSALDO     NUMBER;
    V_COD_NUEVO   NUMBER;
    V_REG         NUMBER;
    V_AUX         NUMBER;
    V_COD_CLINUE  VARCHAR(40);
    V_COD_SALDO   VARCHAR(40);
    C_TIPODOC     VARCHAR2(20);
    C_NUMDOC      VARCHAR2(20);
    C_NOMCLI      VARCHAR2(80);
    C_APECLI      VARCHAR2(80);
    C_SEXO        VARCHAR2(1);
    C_EST_CIVIL   VARCHAR2(20);
    C_EMAIL       VARCHAR2(80);
    C_PROV        VARCHAR2(30);
    C_DEPA        VARCHAR2(40);
    C_DIST        VARCHAR2(200);
    C_FECCMB      DATE;
    V_IDIMPCMB    NUMBER;
    V_PHONE       VARCHAR2(40);

    NO_PARAMETROS EXCEPTION;
  BEGIN

    IF K_FEC_PRO IS NULL THEN
      RAISE NO_PARAMETROS;
    END IF;

    BEGIN
      -- Obtenemos el codigo del Concepto
      SELECT NVL(ADMPV_COD_CPTO, NULL)
        INTO V_CODCONCEPTO
        FROM PCLUB.ADMPT_CONCEPTO
       WHERE UPPER(ADMPV_DESC) = 'CAMBIO TITULARIDAD TFI';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_CODCONCEPTO := null;
    END;

    K_TOT_PRO := 0;
    K_TOT_ERR := 0;
    K_TOT_REG := 0;

    DELETE FROM PCLUB.ADMPT_CLIENTE
    WHERE ADMPV_COD_CLI = '999999999999999999999';

  CamTituCC(K_FEC_PRO, C_CUR_CMBTITULAR);

    BEGIN
      FETCH C_CUR_CMBTITULAR
        INTO C_CODCLIENTE,
             C_NOMCLI,
             C_APECLI,
             C_TIPODOC,
             C_NUMDOC,
             C_SEXO,
             C_EST_CIVIL,
             C_EMAIL,
             C_PROV,
             C_DEPA,
             C_DIST,
             C_FECCMB;

      IF (C_CUR_CMBTITULAR%rowcount = 0) THEN
        K_TOT_REG := C_CUR_CMBTITULAR%rowcount;
      ELSE

        WHILE C_CUR_CMBTITULAR%FOUND LOOP
          -- Obtenemos el total de registros
          K_TOT_REG := K_TOT_REG + 1;

          --Realizamos la conversión de los codigos de Cliente
          V_PHONE := C_CODCLIENTE;
          IF SUBSTR(trim(V_PHONE), 1, 1) <> '0' THEN
            C_CODCLIENTE := '1' || V_PHONE;
          ELSE
            C_CODCLIENTE := SUBSTR(trim(V_PHONE), 2, 8);
          END IF;

          -- Realizamos las validaciones necesarias
          -- Verificamos si el Codigo de Cliente existe
          V_AUX := 0;
          BEGIN
            SELECT COUNT(*)
              INTO V_AUX
              FROM PCLUB.ADMPT_CLIENTE
             WHERE ADMPV_COD_CLI = C_CODCLIENTE;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              V_AUX := 0;
          END;

          IF V_AUX = 0 THEN
            K_TOT_ERR := K_TOT_ERR + 1;

            SELECT ADMPT_IMP_TFICMBTIT_SQ.NEXTVAL INTO V_IDIMPCMB FROM DUAL;

            INSERT INTO PCLUB.ADMPT_IMP_TFICMBTIT
              (ADMPN_ID_FILA,
               ADMPV_COD_CLI,
               ADMPV_TIPO_DOC,
               ADMPV_NUM_DOC,
               ADMPV_NOM_CLI,
               ADMPV_APE_CLI,
               ADMPC_SEXO,
               ADMPV_EST_CIVIL,
               ADMPV_EMAIL,
               ADMPV_PROV,
               ADMPV_DEPA,
               ADMPV_DIST,
               ADMPD_FEC_ACTIV,
               ADMPD_FEC_OPER,
               ADMPV_MSJE_ERROR)
            VALUES
              (V_IDIMPCMB,
               C_CODCLIENTE,
               C_TIPODOC,
               C_NUMDOC,
               C_NOMCLI,
               C_APECLI,
               C_SEXO,
               C_EST_CIVIL,
               C_EMAIL,
               C_PROV,
               C_DEPA,
               C_DIST,
               C_FECCMB,
               TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
               'El Codigo de Cliente NO existe. No se puede cambiar el titular.');
            COMMIT;

          ELSE
            K_TOT_PRO := K_TOT_PRO + 1;

            ----------------------------------------- Primero operamos con el cliente que se cambia de titular (origen) -------------------------------------------
            -- Obtenemos el saldo de la cuenta que cambia de titular
            BEGIN
              V_SALDO_CLI := 0.00;
              SELECT ADMPN_SALDO_CC
                INTO V_SALDO_CLI
                FROM PCLUB.ADMPT_SALDOS_CLIENTE
               WHERE ADMPV_COD_CLI = C_CODCLIENTE;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                V_SALDO_CLI := 0;
            END;

            -- Insertamos en el Kardex el movimiento sólo si el saldo es mayor que 0
            IF V_SALDO_CLI > 0 THEN
              SELECT admpt_kardex_sq.NEXTVAL INTO V_IDKARDEX FROM DUAL;

              INSERT INTO PCLUB.ADMPT_KARDEX
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
                 ADMPC_ESTADO)
              VALUES
                (V_IDKARDEX,
                 NULL,
                 C_CODCLIENTE,
                 V_CODCONCEPTO,
                 SYSDATE,
                 --TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
                 V_SALDO_CLI * -1,
                 '',
                 'S',
                 'C',
                 0,
                 'A');
            END IF;

            -- Actualizamos todos los movimientos de ingreso con 0
            UPDATE PCLUB.ADMPT_KARDEX
               SET ADMPN_SLD_PUNTO = 0, ADMPC_ESTADO = 'C'
             WHERE ADMPV_COD_CLI = C_CODCLIENTE
               AND ADMPC_TPO_OPER = 'E'
               AND ADMPC_TPO_PUNTO = 'C'
               AND ADMPN_SLD_PUNTO > 0;

            -- Ahora obtenemos el nuevo código del cliente origen
            V_COD_NUEVO  := 1;
            V_COD_CLINUE := '';

            WHILE V_COD_NUEVO > 0 LOOP
              V_COD_CLINUE := TRIM(C_CODCLIENTE) || '-' ||
                              TO_CHAR(V_COD_NUEVO);

              V_REG := 0;

              BEGIN
                SELECT COUNT(*)
                  INTO V_REG
                  FROM PCLUB.ADMPT_CLIENTE
                 WHERE ADMPV_COD_CLI = V_COD_CLINUE;

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  V_REG := 0;
              END;

              IF V_REG > 0 THEN
                V_COD_NUEVO := V_COD_NUEVO + 1;
              ELSE
                V_COD_NUEVO := 0;
              END IF;
            END LOOP;

            -- Debido a la FK primero se debe insertar el registro
            INSERT INTO PCLUB.ADMPT_CLIENTE
              (ADMPV_COD_CLI)
            VALUES
              ('999999999999999999999');

            UPDATE PCLUB.ADMPT_CANJE
               SET ADMPV_COD_CLI = '999999999999999999999'
             WHERE ADMPV_COD_CLI = C_CODCLIENTE;

            -- Ahora actualizamos los movimientos, saldos y código de cliente con el código obtenido
            UPDATE PCLUB.ADMPT_KARDEX
               SET ADMPV_COD_CLI = V_COD_CLINUE
             WHERE ADMPV_COD_CLI = C_CODCLIENTE;

            UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
               SET ADMPV_COD_CLI   = V_COD_CLINUE,
                   ADMPN_SALDO_CC  = 0,
                   ADMPC_ESTPTO_CC = 'B'
             WHERE ADMPV_COD_CLI = C_CODCLIENTE;

            UPDATE PCLUB.ADMPT_CLIENTE
               SET ADMPV_COD_CLI = V_COD_CLINUE, ADMPC_ESTADO = 'B'
             WHERE ADMPV_COD_CLI = C_CODCLIENTE;

            UPDATE PCLUB.ADMPT_CANJE
               SET ADMPV_COD_CLI = V_COD_CLINUE
             WHERE ADMPV_COD_CLI = '999999999999999999999';

            DELETE FROM PCLUB.ADMPT_CLIENTE
             WHERE ADMPV_COD_CLI = '999999999999999999999';

            BEGIN
              SELECT TC.ADMPV_COD_TPDOC
                INTO C_TIPODOC
                FROM PCLUB.ADMPT_TIPO_DOC TC
               WHERE UPPER(TRIM(TC.ADMPV_DSC_DOCUM)) =
                     UPPER(TRIM(C_TIPODOC));
            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;
            ----------------------------------------- Segundo operamos con el cliente que es el nuevo titular (destino) -------------------------------------------
            -- Debemos insertar los clientes en la tabla de Clientes
            INSERT INTO PCLUB.ADMPT_CLIENTE H
              (H.ADMPV_COD_CLI,
               H.ADMPV_COD_SEGCLI,
               H.ADMPN_COD_CATCLI,
               H.ADMPV_TIPO_DOC,
               H.ADMPV_NUM_DOC,
               H.ADMPV_NOM_CLI,
               H.ADMPV_APE_CLI,
               H.ADMPC_SEXO,
               H.ADMPV_EST_CIVIL,
               H.ADMPV_EMAIL,
               H.ADMPV_PROV,
               H.ADMPV_DEPA,
               H.ADMPV_DIST,
               H.ADMPD_FEC_ACTIV,
               H.ADMPV_CICL_FACT,
               H.ADMPC_ESTADO,
               H.ADMPD_FEC_REG,
               H.ADMPV_COD_TPOCL)
            VALUES
              (C_CODCLIENTE,
               null,
               '2',
               C_TIPODOC,
               C_NUMDOC,
               C_NOMCLI,
               C_APECLI,
               C_SEXO,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
               NULL,
               'A',
               SYSDATE,
               '8');

            BEGIN
              SELECT ADMPV_COD_CLI
                INTO V_COD_SALDO
                FROM PCLUB.ADMPT_SALDOS_CLIENTE
               WHERE ADMPV_COD_CLI = C_CODCLIENTE;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                /**Generar secuencial de Saldo*/
                SELECT admpt_sld_cl_sq.nextval INTO V_IDSALDO FROM DUAL;

                INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE
                  (admpn_id_saldo,
                   admpv_cod_cli,
                   admpn_cod_cli_ib,
                   admpn_saldo_cc,
                   admpn_saldo_ib,
                   admpc_estpto_cc,
                   admpc_estpto_ib)
                VALUES
                  (V_IDSALDO, C_CODCLIENTE, NULL, 0.00, 0.00, 'A', NULL);
            END;

            COMMIT;

          END IF;

          FETCH C_CUR_CMBTITULAR
            INTO C_CODCLIENTE,
                 C_NOMCLI,
                 C_APECLI,
                 C_TIPODOC,
                 C_NUMDOC,
                 C_SEXO,
                 C_EST_CIVIL,
                 C_EMAIL,
                 C_PROV,
                 C_DEPA,
                 C_DIST,
                 C_FECCMB;

        END LOOP;

      END IF;

    END;

    CLOSE C_CUR_CMBTITULAR;
    COMMIT;

    K_CODERROR  := 0;
    K_DESCERROR := '';

  EXCEPTION
    WHEN NO_PARAMETROS THEN
      K_CODERROR  := 41;
      K_DESCERROR := 'Ingresó datos incorrectos o datos insuficientes para realizar la consulta';
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

  END ADMPSI_TFICMBTIT;

  PROCEDURE ADMPSI_ETFICMBTIT(K_FECHAPROC    IN DATE,
                              cursorCambTitu out SYS_REFCURSOR) is
    --****************************************************************
    -- Nombre SP           :  ADMPSI_ETFICMBTIT
    -- Propósito           :  Proceso que devuelve los errores producidos por el cambio de Titular de Cuentas TFI Prepago
    -- Input               :  K_FEC_PRO Fecha de Proceso
    -- Output              :  CMBTIT_CUR Cursor con los errores encontrados en el proceso de cambio de titular
    -- Creado por          :  Roxana Chero
    -- Fec Creacion        :  10/04/2013
    --****************************************************************

  BEGIN
    OPEN cursorCambTitu FOR
      SELECT ADMPV_COD_CLI,
             ADMPV_TIPO_DOC,
             ADMPV_NUM_DOC,
             ADMPV_NOM_CLI,
             ADMPV_APE_CLI,
             ADMPC_SEXO,
             ADMPV_EST_CIVIL,
             ADMPV_EMAIL,
             ADMPV_DEPA,
             ADMPV_PROV,
             ADMPV_DIST,
             ADMPD_FEC_ACTIV,
             ADMPV_MSJE_ERROR
        FROM PCLUB.ADMPT_IMP_TFICMBTIT
       WHERE ADMPD_FEC_OPER = K_FECHAPROC
         AND ADMPV_MSJE_ERROR IS NOT NULL
       ORDER BY ADMPN_ID_FILA;
  END ADMPSI_ETFICMBTIT;

  procedure CamTituCC(K_FECHA IN DATE, CURSORCamTituCC out SYS_REFCURSOR) IS
    --****************************************************************
    -- Nombre SP           :  CamTituCC
    -- Propósito           :  Devuelve un cursor con la lista de clientes que han cambiado de titular.
    -- Input               :  K_FECHA
    -- Output              :  CURSORCamTituCC
    -- Creado por          :  Roxana Chero
    -- Fec Creación        :  08/04/2013
    --****************************************************************
  BEGIN
    OPEN CURSORCamTituCC FOR

      select I.PHONE,
             C.X_FIRST_NAME,
             C.X_LAST_NAME,
             C.X_TYPE_DOCUMENT,
             C.X_DOCUMENT_NUMBER,
             '' AS x_sex,
             '' AS x_marital_status,
             '' AS e_mail,
             '' AS s_city,
             '' AS x_department,
             '' AS x_address_3,
             I.CREATE_DATE
        from table_interact@DBL_CLARIFY i, TABLE_X_PLUS_INTER@DBL_CLARIFY c
       where i.OBJID = c.X_PLUS_INTER2INTERACT
         AND I.S_REASON_1 = 'FIJO'
         AND I.S_REASON_2 = 'VARIACIÓN'
         AND I.S_REASON_3 = 'CAMBIO TIT / USUARIO / REP. LEGAL'
         and to_char(i.create_date, 'DD/MM/YYYY') =
             to_char(K_FECHA, 'DD/MM/YYYY');

  END CamTituCC;

  procedure ADMPSI_TFIVENCPTO(K_CODERROR  OUT NUMBER,
                              K_DESCERROR OUT VARCHAR2) IS
    --****************************************************************
    -- Nombre SP           :  ADMPSI_PREVENCPTO
    -- Propósito           :  Obtiene y cancela los movimientos de ingreso al Kardex de las lineas TFI que ya tienen más tiempo de lo permitido y no fueron utilizados
    -- Output              :  K_CODERROR
    --                        K_DESCERROR
    -- Creado por          :  Roxana Chero
    -- Fec Creación        :  09/04/2013
    --****************************************************************
    NO_CONCEPTO EXCEPTION;

    /*SELECCIONAR LOS CONCEPTOS QUE CUMPLEN CON LO REQUERIDO*/

    CURSOR C_CONCEPTO IS
      SELECT ADMPV_COD_CPTO, ADMPN_PER_CADU, ADMPC_TPO_PUNTO
        FROM PCLUB.ADMPT_CONCEPTO
       WHERE ADMPN_PER_CADU > 0
         AND ADMPC_ESTADO = 'A'
         AND (ADMPC_TPO_PUNTO = 'C' or ADMPC_TPO_PUNTO = 'L')
         AND ADMPV_TPO_CPTO = 'TFI';

    C_CODCPTO   VARCHAR2(2);
    C_PER_CADU  NUMBER;
    C_TPO_PUNTO VARCHAR2(2);
    V_COD_CPTO  VARCHAR2(2);
    V_FECHA     DATE;
    V_COD_CLI   VARCHAR2(40);
    V_TPO_PUNTO VARCHAR2(2);
    TOTALPTOS   NUMBER;

    CURSOR C_CLIENTE IS
      SELECT K.ADMPV_COD_CLI, SUM(K.ADMPN_SLD_PUNTO), K.ADMPC_TPO_PUNTO
        FROM PCLUB.ADMPT_KARDEX K, PCLUB.ADMPT_CLIENTE C
       WHERE K.ADMPD_FEC_TRANS < V_FECHA
         AND K.ADMPV_COD_CPTO = C_CODCPTO
         AND C.ADMPV_COD_CLI = K.ADMPV_COD_CLI
         AND K.ADMPC_TPO_PUNTO = C_TPO_PUNTO
         AND K.ADMPN_SLD_PUNTO > 0
         AND K.ADMPC_TPO_OPER = 'E'
         AND C.ADMPV_COD_TPOCL = '8' --Cliente TFI
       GROUP BY K.ADMPV_COD_CLI, K.ADMPC_TPO_PUNTO;

  BEGIN
    BEGIN
      /*SE ALMACENA EL CODIGO DEL CONCEPTO 'VENCIMIENTO DE PUNTOS TFI'*/
      SELECT ADMPV_COD_CPTO
        INTO V_COD_CPTO
        FROM PCLUB.ADMPT_CONCEPTO
       WHERE ADMPV_DESC = 'VENCIMIENTO DE PUNTOS TFI';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_COD_CPTO := NULL;
    END;

    IF V_COD_CPTO IS NULL THEN
      RAISE NO_CONCEPTO;
    END IF;

    OPEN C_CONCEPTO;
    FETCH C_CONCEPTO
      INTO C_CODCPTO, C_PER_CADU, C_TPO_PUNTO;
    WHILE C_CONCEPTO%FOUND LOOP
      /*ALMACENAR FECHA LIMITE ADMITIDA*/
      V_FECHA := to_date(to_char(ADD_MONTHS(sysdate, -C_PER_CADU),
                                 'dd/mm/yyyy'),
                         'dd/mm/yyyy');
      OPEN C_CLIENTE;
      LOOP
        FETCH C_CLIENTE
          INTO V_COD_CLI, TOTALPTOS, V_TPO_PUNTO;
        EXIT WHEN C_CLIENTE%NOTFOUND;

        /*INSERTAR EN EL KARDEX UN NUEVO REGISTRO CON EL CLIENTE ALMACENADO Y TOTAL DE PUNTOS VENCIDOS*/
        INSERT INTO PCLUB.ADMPT_KARDEX
          (ADMPN_ID_KARDEX,
           ADMPV_COD_CLI,
           ADMPV_COD_CPTO,
           ADMPD_FEC_TRANS,
           ADMPN_PUNTOS,
           ADMPC_TPO_OPER,
           ADMPC_TPO_PUNTO,
           ADMPN_SLD_PUNTO,
           ADMPC_ESTADO)
        VALUES
          (ADMPT_KARDEX_SQ.NEXTVAL,
           V_COD_CLI,
           V_COD_CPTO,
           SYSDATE,
           TOTALPTOS * (-1),
           'S',
           'C',
           0,
           'A');

        IF ((V_TPO_PUNTO = 'L') OR (V_TPO_PUNTO = 'C')) THEN
          /*ACTUALIZAR LOS SALDOS DEL CLIENTE EN LA TABLA PCLUB.ADMPT_SALDOS_CLIENTE*/
          UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
             SET ADMPN_SALDO_CC =
                 ((TOTALPTOS * (-1)) +
                 (SELECT NVL(ADMPN_SALDO_CC, 0)
                     FROM PCLUB.ADMPT_SALDOS_CLIENTE
                    WHERE ADMPV_COD_CLI = V_COD_CLI))
           WHERE ADMPV_COD_CLI = V_COD_CLI;

        ELSIF V_TPO_PUNTO = 'I' THEN
          /*ACTUALIZAR LOS SALDOS DEL CLIENTE EN LA TABLA PCLUB.ADMPT_SALDOS_CLIENTE*/
          UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
             SET ADMPN_SALDO_IB =
                 ((TOTALPTOS * (-1)) +
                 (SELECT NVL(ADMPN_SALDO_IB, 0)
                     FROM PCLUB.ADMPT_SALDOS_CLIENTE
                    WHERE ADMPV_COD_CLI = V_COD_CLI))
           WHERE ADMPV_COD_CLI = V_COD_CLI;
        END IF;

        /*ACTUALIZAR EN LA TABLA KARDEX A LOS CLIENTES DE LOS MOVIMIENTOS VENCIDOS*/
        UPDATE PCLUB.ADMPT_KARDEX
           SET ADMPN_SLD_PUNTO = 0, ADMPC_ESTADO = 'C'
         WHERE ADMPD_FEC_TRANS < V_FECHA
           AND ADMPV_COD_CPTO = C_CODCPTO
           AND ADMPV_COD_CLI = V_COD_CLI
           AND ADMPN_SLD_PUNTO > 0
           AND ADMPC_TPO_OPER = 'E';
        COMMIT;

      END LOOP;
      CLOSE C_CLIENTE;
      FETCH C_CONCEPTO
        INTO C_CODCPTO, C_PER_CADU, C_TPO_PUNTO;
    END LOOP;
    CLOSE C_CONCEPTO;

    K_CODERROR  := 0;
    K_DESCERROR := ' ';

  EXCEPTION

    WHEN NO_CONCEPTO THEN
      K_CODERROR  := 55;
      K_DESCERROR := 'No se tiene registrado el parametro de VENCIMIENTO DE PUNTOS TFI (PCLUB.ADMPT_CONCEPTO).';
      ROLLBACK;

    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      ROLLBACK;

  END ADMPSI_TFIVENCPTO;

  --****************************************************************
  -- Nombre SP           :  ADMPSI_RECARGA
  -- Propósito           :  Inserta los puntos entregados por Recarga
  -- Input               :  K_FECHA
  --                     :  K_NOMBARCH
  -- Output              :  K_CODERROR Código de error o éxito
  --                        K_DESCERROR Descripción del error
  --                        K_NUMREGTOT Número total de registros
  --                        K_NUMREGPRO Número de registros procesador
  --                        K_NUMREGERR Número de registros errados
  -- Creado por          :  Oscar Paucar
  -- Fec Creación        :  04/04/2013
  -- Fec Actualización   :
  --****************************************************************

  PROCEDURE ADMPSI_RECARGA(K_FECHA     IN DATE,
                           K_NOMBARCH  IN VARCHAR2,
                           K_CODERROR  OUT NUMBER,
                           K_DESCERROR OUT VARCHAR2,
                           K_NUMREGTOT OUT NUMBER,
                           K_NUMREGPRO OUT NUMBER,
                           K_NUMREGERR OUT NUMBER) IS

    V_COD_CPTO  VARCHAR2(2);
    V_PUNTOS    NUMBER;
    V_FECHA     DATE := TRUNC(K_FECHA);
    V_FECSYS    DATE := TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'),
                                'DD/MM/YYYY');
    V_COD_TPOCL CHAR(1) := '8';
    EX_ERROR EXCEPTION;
  BEGIN

    CASE
      WHEN K_FECHA IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese la fecha';
        RAISE EX_ERROR;
      ELSE
        K_CODERROR  := 0;
        K_DESCERROR := '';
        K_NUMREGTOT := 0;
        K_NUMREGPRO := 0;
        K_NUMREGERR := 0;
    END CASE;

    BEGIN
      SELECT ADMPV_COD_CPTO
        INTO V_COD_CPTO
        FROM PCLUB.ADMPT_CONCEPTO
       WHERE UPPER(ADMPV_DESC) = 'RECARGAS TFI';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'No está registrado el concepto RECARGAS TFI (PCLUB.ADMPT_CONCEPTO)';
        RAISE EX_ERROR;
      WHEN TOO_MANY_ROWS THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Existen varios registros con el concepto RECARGAS TFI (PCLUB.ADMPT_CONCEPTO)';
        RAISE EX_ERROR;
    END;

    BEGIN
      SELECT ADMPV_VALOR
        INTO V_PUNTOS
        FROM PCLUB.ADMPT_PARAMSIST
       WHERE ADMPV_DESC = 'PUNTOS_RECARGA_TFI';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'No está registrado el parámetro PUNTOS_RECARGA_TFI (PCLUB.ADMPT_PARAMSIST)';
        RAISE EX_ERROR;
      WHEN TOO_MANY_ROWS THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Existen varios registros con el parámetro PUNTOS_RECARGA_TFI (PCLUB.ADMPT_PARAMSIST)';
        RAISE EX_ERROR;
    END;

    --SE LE ASIGNA EL ERROR SI EL CODIGO DEL CLIENTE ES NULO
    INSERT INTO PCLUB.ADMPT_IMP_RECARGATFI
      (ADMPN_ID_FILA,
       ADMPV_COD_CLI,
       ADMPD_FEC_ULTREC,
       ADMPN_MONTO,
       ADMPD_FEC_OPER,
       ADMPD_FEC_TRANS,
       ADMPV_MSJE_ERROR,
       ADMPV_NOM_ARCH)
      SELECT ADMPT_IMP_RECARGATFI_SQ.NEXTVAL,
             T.ADMPV_COD_CLI,
             T.ADMPD_FEC_ULTREC,
             T.ADMPN_MONTO,
             V_FECSYS,
             SYSDATE,
             'El código de cliente es un dato obligatorio.',
             K_NOMBARCH
        FROM PCLUB.ADMPT_TMP_RECARGATFI T
       WHERE T.ADMPD_FEC_OPER = V_FECHA
         AND ((T.ADMPV_COD_CLI IS NULL) OR
             (REPLACE(T.ADMPV_COD_CLI, ' ', '') IS NULL));

    --SE LE ASIGNA EL ERROR SI NO EXISTE EL CLIENTE EN LA TABLA PCLUB.ADMPT_CLIENTE
    MERGE INTO PCLUB.ADMPT_IMP_RECARGATFI I
    USING (SELECT T.ADMPV_COD_CLI AS ADMPV_COD_CLI,
                  T.ADMPD_FEC_OPER AS ADMPD_FEC_OPER,
                  MAX(T.ADMPD_FEC_ULTREC) AS ADMPD_FEC_ULTREC,
                  SUM(T.ADMPN_MONTO) AS ADMPN_MONTO
             FROM PCLUB.ADMPT_TMP_RECARGATFI T
             LEFT JOIN PCLUB.ADMPT_CLIENTE C
               ON T.ADMPV_COD_CLI = C.ADMPV_COD_CLI
              AND C.ADMPV_COD_TPOCL = V_COD_TPOCL
            WHERE T.ADMPD_FEC_OPER = V_FECHA
              AND ((T.ADMPV_COD_CLI IS NOT NULL) OR
                  (REPLACE(T.ADMPV_COD_CLI, ' ', '') IS NOT NULL))
              AND C.ADMPV_COD_CLI IS NULL
            GROUP BY T.ADMPV_COD_CLI, T.ADMPD_FEC_OPER) Q
    ON (I.ADMPV_COD_CLI = Q.ADMPV_COD_CLI AND I.ADMPD_FEC_OPER = Q.ADMPD_FEC_OPER)
    WHEN NOT MATCHED THEN
      INSERT
        (ADMPN_ID_FILA,
         ADMPV_COD_CLI,
         ADMPD_FEC_ULTREC,
         ADMPN_MONTO,
         ADMPD_FEC_OPER,
         ADMPD_FEC_TRANS,
         ADMPV_MSJE_ERROR,
         ADMPV_NOM_ARCH)
      VALUES
        (ADMPT_IMP_RECARGATFI_SQ.NEXTVAL,
         Q.ADMPV_COD_CLI,
         Q.ADMPD_FEC_ULTREC,
         Q.ADMPN_MONTO,
         V_FECSYS,
         SYSDATE,
         'El código de cliente no existe.',
         K_NOMBARCH);

    --SE LE ASIGNA EL ERROR SI EL CLIENTE ESTA DE BAJA
    MERGE INTO PCLUB.ADMPT_IMP_RECARGATFI I
    USING (SELECT T.ADMPV_COD_CLI AS ADMPV_COD_CLI,
                  T.ADMPD_FEC_OPER AS ADMPD_FEC_OPER,
                  MAX(T.ADMPD_FEC_ULTREC) AS ADMPD_FEC_ULTREC,
                  SUM(T.ADMPN_MONTO) AS ADMPN_MONTO
             FROM PCLUB.ADMPT_TMP_RECARGATFI T
            INNER JOIN PCLUB.ADMPT_CLIENTE C
               ON T.ADMPV_COD_CLI = C.ADMPV_COD_CLI
              AND C.ADMPV_COD_TPOCL = V_COD_TPOCL
              AND C.ADMPC_ESTADO = 'B'
            WHERE T.ADMPD_FEC_OPER = V_FECHA
            GROUP BY T.ADMPV_COD_CLI, T.ADMPD_FEC_OPER) Q
    ON (I.ADMPV_COD_CLI = Q.ADMPV_COD_CLI AND I.ADMPD_FEC_OPER = Q.ADMPD_FEC_OPER)
    WHEN NOT MATCHED THEN
      INSERT
        (ADMPN_ID_FILA,
         ADMPV_COD_CLI,
         ADMPD_FEC_ULTREC,
         ADMPN_MONTO,
         ADMPD_FEC_OPER,
         ADMPD_FEC_TRANS,
         ADMPV_MSJE_ERROR,
         ADMPV_NOM_ARCH)
      VALUES
        (ADMPT_IMP_RECARGATFI_SQ.NEXTVAL,
         Q.ADMPV_COD_CLI,
         Q.ADMPD_FEC_ULTREC,
         Q.ADMPN_MONTO,
         V_FECSYS,
         SYSDATE,
         'El cliente se encuentra de baja, no se le entregará puntos.',
         K_NOMBARCH);

    --SE LE ASIGNA EL ERROR SI EL MONTO EN EL CURSOR ES MENOR A 0
    MERGE INTO PCLUB.ADMPT_IMP_RECARGATFI I
    USING (SELECT T.ADMPV_COD_CLI AS ADMPV_COD_CLI,
                  T.ADMPD_FEC_OPER AS ADMPD_FEC_OPER,
                  MAX(T.ADMPD_FEC_ULTREC) AS ADMPD_FEC_ULTREC,
                  SUM(T.ADMPN_MONTO) AS ADMPN_MONTO
             FROM PCLUB.ADMPT_TMP_RECARGATFI T
            WHERE T.ADMPD_FEC_OPER = V_FECHA
              AND ((T.ADMPV_COD_CLI IS NOT NULL) OR
                  (REPLACE(T.ADMPV_COD_CLI, ' ', '') IS NOT NULL))
              AND NVL(T.ADMPN_MONTO,0) <= 0
            GROUP BY T.ADMPV_COD_CLI, T.ADMPD_FEC_OPER) Q
    ON (I.ADMPV_COD_CLI = Q.ADMPV_COD_CLI AND I.ADMPD_FEC_OPER = Q.ADMPD_FEC_OPER)
    WHEN NOT MATCHED THEN
      INSERT
        (ADMPN_ID_FILA,
         ADMPV_COD_CLI,
         ADMPD_FEC_ULTREC,
         ADMPN_MONTO,
         ADMPD_FEC_OPER,
         ADMPD_FEC_TRANS,
         ADMPV_MSJE_ERROR,
         ADMPV_NOM_ARCH)
      VALUES
        (ADMPT_IMP_RECARGATFI_SQ.NEXTVAL,
         Q.ADMPV_COD_CLI,
         Q.ADMPD_FEC_ULTREC,
         Q.ADMPN_MONTO,
         V_FECSYS,
         SYSDATE,
         'El monto de recarga debe ser mayor de 0.',
         K_NOMBARCH);

    --SE LE ASIGNA EL ERROR SI LA FECHA DE ULTIMA RECARGA ES MENOR A LA FECHA DE ACTIVACION
    MERGE INTO PCLUB.ADMPT_IMP_RECARGATFI I
    USING (SELECT T.ADMPV_COD_CLI AS ADMPV_COD_CLI,
                  T.ADMPD_FEC_OPER AS ADMPD_FEC_OPER,
                  MAX(T.ADMPD_FEC_ULTREC) AS ADMPD_FEC_ULTREC,
                  SUM(T.ADMPN_MONTO) AS ADMPN_MONTO
             FROM PCLUB.ADMPT_TMP_RECARGATFI T
            INNER JOIN PCLUB.ADMPT_CLIENTE C
               ON T.ADMPV_COD_CLI = C.ADMPV_COD_CLI
              AND C.ADMPV_COD_TPOCL = V_COD_TPOCL
              AND T.ADMPD_FEC_ULTREC < TRUNC(C.ADMPD_FEC_ACTIV)
            WHERE T.ADMPD_FEC_OPER = V_FECHA
            GROUP BY T.ADMPV_COD_CLI, T.ADMPD_FEC_OPER) Q
    ON (I.ADMPV_COD_CLI = Q.ADMPV_COD_CLI AND I.ADMPD_FEC_OPER = Q.ADMPD_FEC_OPER)
    WHEN NOT MATCHED THEN
      INSERT
        (ADMPN_ID_FILA,
         ADMPV_COD_CLI,
         ADMPD_FEC_ULTREC,
         ADMPN_MONTO,
         ADMPD_FEC_OPER,
         ADMPD_FEC_TRANS,
         ADMPV_MSJE_ERROR,
         ADMPV_NOM_ARCH)
      VALUES
        (ADMPT_IMP_RECARGATFI_SQ.NEXTVAL,
         Q.ADMPV_COD_CLI,
         Q.ADMPD_FEC_ULTREC,
         Q.ADMPN_MONTO,
         V_FECSYS,
         SYSDATE,
         'La fecha de última recarga no puede ser menor a la fecha de activación.',
         K_NOMBARCH);

    --INSERTA EN PCLUB.ADMPT_AUX_RECARGATFI LOS REGISTROS CORRECTOS
    MERGE INTO PCLUB.ADMPT_AUX_RECARGATFI A
    USING (SELECT T.ADMPV_COD_CLI AS ADMPV_COD_CLI,
                  T.ADMPD_FEC_OPER AS ADMPD_FEC_OPER,
                  MAX(T.ADMPD_FEC_ULTREC) AS ADMPD_FEC_ULTREC,
                  SUM(T.ADMPN_MONTO) AS ADMPN_MONTO
             FROM PCLUB.ADMPT_TMP_RECARGATFI T
             LEFT JOIN PCLUB.ADMPT_IMP_RECARGATFI I
               ON T.ADMPV_COD_CLI = I.ADMPV_COD_CLI
              AND T.ADMPD_FEC_OPER = I.ADMPD_FEC_OPER
            WHERE T.ADMPD_FEC_OPER = V_FECHA
              AND ((T.ADMPV_COD_CLI IS NOT NULL) OR
                  (REPLACE(T.ADMPV_COD_CLI, ' ', '') IS NOT NULL))
              AND I.ADMPD_FEC_OPER IS NULL
            GROUP BY T.ADMPV_COD_CLI, T.ADMPD_FEC_OPER) Q
    ON (A.ADMPV_COD_CLI = Q.ADMPV_COD_CLI AND A.ADMPD_FEC_OPER = Q.ADMPD_FEC_OPER)
    WHEN NOT MATCHED THEN
      INSERT
        (ADMPV_COD_CLI, ADMPD_FEC_ULTREC, ADMPN_MONTO, ADMPD_FEC_OPER)
      VALUES
        (Q.ADMPV_COD_CLI, Q.ADMPD_FEC_ULTREC, Q.ADMPN_MONTO, V_FECSYS);

    --INSERTA EN PCLUB.ADMPT_IMP_RECARGATFI LOS REGISTROS CORRECTOS
    MERGE INTO PCLUB.ADMPT_IMP_RECARGATFI I
    USING (SELECT T.ADMPV_COD_CLI AS ADMPV_COD_CLI,
                  T.ADMPD_FEC_OPER AS ADMPD_FEC_OPER,
                  MAX(T.ADMPD_FEC_ULTREC) AS ADMPD_FEC_ULTREC,
                  SUM(T.ADMPN_MONTO) AS ADMPN_MONTO
             FROM PCLUB.ADMPT_AUX_RECARGATFI T
            WHERE T.ADMPD_FEC_OPER = V_FECHA
            GROUP BY T.ADMPV_COD_CLI, T.ADMPD_FEC_OPER) Q
    ON (I.ADMPV_COD_CLI = Q.ADMPV_COD_CLI AND I.ADMPD_FEC_OPER = Q.ADMPD_FEC_OPER)
    WHEN NOT MATCHED THEN
      INSERT
        (ADMPN_ID_FILA,
         ADMPV_COD_CLI,
         ADMPD_FEC_ULTREC,
         ADMPN_MONTO,
         ADMPD_FEC_OPER,
         ADMPD_FEC_TRANS,
         ADMPV_NOM_ARCH)
      VALUES
        (ADMPT_IMP_RECARGATFI_SQ.NEXTVAL,
         Q.ADMPV_COD_CLI,
         Q.ADMPD_FEC_ULTREC,
         Q.ADMPN_MONTO,
         V_FECSYS,
         SYSDATE,
         K_NOMBARCH);

    IF V_PUNTOS <> 0 THEN
      --SI EL CODIGO DEL CLIENTE EXISTE, SE LLEGA A INSERTAR EN PCLUB.ADMPT_KARDEX
      INSERT INTO PCLUB.ADMPT_KARDEX
        (ADMPN_ID_KARDEX,
         ADMPV_COD_CLI,
         ADMPV_COD_CPTO,
         ADMPD_FEC_TRANS,
         ADMPN_PUNTOS,
         ADMPC_TPO_OPER,
         ADMPC_TPO_PUNTO,
         ADMPN_SLD_PUNTO,
         ADMPC_ESTADO,
         ADMPV_NOM_ARCH)
        SELECT ADMPT_KARDEX_SQ.NEXTVAL,
               T.ADMPV_COD_CLI,
               V_COD_CPTO,
               SYSDATE,
               FLOOR(NVL(T.ADMPN_MONTO, 0) / V_PUNTOS),
               'E',
               'C',
               FLOOR(NVL(T.ADMPN_MONTO, 0) / V_PUNTOS),
               'A',
               K_NOMBARCH
          FROM PCLUB.ADMPT_AUX_RECARGATFI T
         INNER JOIN PCLUB.ADMPT_CLIENTE C
            ON C.ADMPV_COD_CLI = T.ADMPV_COD_CLI
           AND C.ADMPV_COD_TPOCL = V_COD_TPOCL
         WHERE T.ADMPD_FEC_OPER = V_FECHA;

      --SI EL CODIGO DEL CLIENTE EXISTE EN PCLUB.ADMPT_SALDOS_CLIENTE, SE ACTUALIZA SINO SE INSERTA
      MERGE INTO PCLUB.ADMPT_SALDOS_CLIENTE S
      USING (SELECT A.ADMPV_COD_CLI AS ADMPV_COD_CLI,
                    FLOOR(NVL(A.ADMPN_MONTO, 0) / V_PUNTOS) AS PUNTOS
               FROM PCLUB.ADMPT_AUX_RECARGATFI A
              INNER JOIN PCLUB.ADMPT_CLIENTE C
                 ON A.ADMPV_COD_CLI = C.ADMPV_COD_CLI
                AND C.ADMPV_COD_TPOCL = V_COD_TPOCL
              WHERE A.ADMPD_FEC_OPER = V_FECHA) Q
      ON (S.ADMPV_COD_CLI = Q.ADMPV_COD_CLI)
      WHEN MATCHED THEN
        UPDATE SET S.ADMPN_SALDO_CC = S.ADMPN_SALDO_CC + Q.PUNTOS
      WHEN NOT MATCHED THEN
        INSERT
          (ADMPN_ID_SALDO, ADMPV_COD_CLI, ADMPN_SALDO_CC, ADMPC_ESTPTO_CC)
        VALUES
          (ADMPT_SLD_CL_SQ.NEXTVAL, Q.ADMPV_COD_CLI, Q.PUNTOS, 'A');
    END IF;

    SELECT COUNT(*)
      INTO K_NUMREGTOT
      FROM PCLUB.ADMPT_TMP_RECARGATFI
     WHERE ADMPD_FEC_OPER = V_FECHA;

    SELECT COUNT(*)
      INTO K_NUMREGPRO
      FROM PCLUB.ADMPT_AUX_RECARGATFI
     WHERE ADMPD_FEC_OPER = V_FECHA;

    K_NUMREGERR := K_NUMREGTOT - K_NUMREGPRO;

    DELETE PCLUB.ADMPT_TMP_RECARGATFI WHERE ADMPD_FEC_OPER = V_FECHA;

    DELETE PCLUB.ADMPT_AUX_RECARGATFI WHERE ADMPD_FEC_OPER = V_FECHA;

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
          K_CODERROR  := SQLCODE;
          K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      END;
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      ROLLBACK;

      DELETE PCLUB.ADMPT_TMP_RECARGATFI WHERE ADMPD_FEC_OPER = V_FECHA;
      COMMIT;
      DELETE PCLUB.ADMPT_AUX_RECARGATFI WHERE ADMPD_FEC_OPER = V_FECHA;
      COMMIT;
  END ADMPSI_RECARGA;

  --****************************************************************
  -- Nombre SP           :  ADMPSS_ERECARGA
  -- Propósito           :  Devuelve en un cursor los puntos por recarga con error
  -- Input               :  K_FECHA - Fecha de Proceso
  -- Output              :  CURSOR_ERRORES Cursor con errores
  --                        K_CODERROR Código de error o éxito
  --                        K_DESCERROR Descripción del error
  -- Creado por          :  Oscar Paucar
  -- Fec Creación        :
  -- Fec Actualización   :  10/04/2013
  --****************************************************************

  PROCEDURE ADMPSS_ERECARGA(K_FECHA       IN DATE,
                            K_CODERROR    OUT NUMBER,
                            K_DESCERROR   OUT VARCHAR2,
                            K_CUR_ERRORES OUT SYS_REFCURSOR) IS
    EX_ERROR EXCEPTION;
  BEGIN

    CASE
      WHEN K_FECHA IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese la fecha';
        RAISE EX_ERROR;
      ELSE
        K_CODERROR  := 0;
        K_DESCERROR := '';
    END CASE;

    OPEN K_CUR_ERRORES FOR
      SELECT ADMPN_ID_FILA,
             ADMPV_COD_CLI,
             ADMPD_FEC_ULTREC,
             ADMPN_MONTO,
             ADMPD_FEC_OPER,
             ADMPD_FEC_TRANS,
             ADMPV_MSJE_ERROR,
             ADMPV_NOM_ARCH
        FROM PCLUB.ADMPT_IMP_RECARGATFI
       WHERE ADMPD_FEC_OPER = K_FECHA
         AND ADMPV_MSJE_ERROR IS NOT NULL;

  EXCEPTION
    WHEN EX_ERROR THEN
      BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR
          INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_CODERROR  := SQLCODE;
          K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      END;
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
  END ADMPSS_ERECARGA;

  --****************************************************************
  -- Nombre SP           :  ADMPSI_ANIVERSARIO
  -- Propósito           :  Inserta los puntos entregados por Aniversario
  -- Input               :  K_FECHA
  --                     :  K_NOMBARCH
  -- Output              :  K_CODERROR Código de error o éxito
  --                        K_DESCERROR Descripción del error
  --                        K_NUMREGTOT Número total de registros
  --                        K_NUMREGPRO Número de registros procesador
  --                        K_NUMREGERR Número de registros errados
  -- Creado por          :  Oscar Paucar
  -- Fec Creación        :  08/04/2013
  -- Fec Actualización   :
  --****************************************************************

  PROCEDURE ADMPSI_ANIVERSARIO(K_FECHA     IN DATE,
                               K_NOMBARCH  IN VARCHAR2,
                               K_CODERROR  OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2,
                               K_NUMREGTOT OUT NUMBER,
                               K_NUMREGPRO OUT NUMBER,
                               K_NUMREGERR OUT NUMBER) IS

    V_COD_CPTO  VARCHAR2(2);
    V_PUNTOS    NUMBER;
    V_FECHA     DATE := TRUNC(K_FECHA);
    V_FECSYS    DATE := TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'),
                                'DD/MM/YYYY');
    V_FECSQL    CHAR(7) := TO_CHAR(K_FECHA, 'MM/YYYY');
    V_COD_TPOCL CHAR(1) := '8';
    EX_ERROR EXCEPTION;
  BEGIN

    CASE
      WHEN K_FECHA IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese la fecha';
        RAISE EX_ERROR;
      ELSE
        K_CODERROR  := 0;
        K_DESCERROR := '';
        K_NUMREGTOT := 0;
        K_NUMREGPRO := 0;
        K_NUMREGERR := 0;
    END CASE;

    BEGIN
      SELECT ADMPV_COD_CPTO
        INTO V_COD_CPTO
        FROM PCLUB.ADMPT_CONCEPTO
       WHERE UPPER(ADMPV_DESC) = 'ANIVERSARIO TFI';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'No está registrado el concepto ANIVERSARIO TFI (PCLUB.ADMPT_CONCEPTO)';
        RAISE EX_ERROR;
      WHEN TOO_MANY_ROWS THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Existen varios registros con el concepto ANIVERSARIO (PCLUB.ADMPT_CONCEPTO)';
        RAISE EX_ERROR;
    END;

    BEGIN
      SELECT ADMPV_VALOR
        INTO V_PUNTOS
        FROM PCLUB.ADMPT_PARAMSIST
       WHERE UPPER(ADMPV_DESC) = 'PUNTOS_ANIVERSARIO_TFI';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'No está registrado el parámetro PUNTOS_ANIVERSARIO_TFI (PCLUB.ADMPT_PARAMSIST)';
        RAISE EX_ERROR;
      WHEN TOO_MANY_ROWS THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Existen varios registros con el parámetro PUNTOS_ANIVERSARIO_TFI (PCLUB.ADMPT_CONCEPTO)';
        RAISE EX_ERROR;
    END;

    --SE LE ASIGNA EL ERROR SI EL CODIGO DEL CLIENTE ES NULO
    INSERT INTO PCLUB.ADMPT_IMP_ANIVERSTFI
      (ADMPN_ID_FILA,
       ADMPV_COD_CLI,
       ADMPD_FEC_ANIV,
       ADMPD_FEC_OPER,
       ADMPD_FEC_TRANS,
       ADMPV_MSJE_ERROR,
       ADMPV_NOM_ARCH)
      SELECT PCLUB.ADMPT_IMP_ANIVERSTFI_SQ.NEXTVAL,
             T.ADMPV_COD_CLI,
             T.ADMPD_FEC_ANIV,
             V_FECSYS,
             SYSDATE,
             'El código de cliente es un dato obligatorio.',
             K_NOMBARCH
        FROM PCLUB.ADMPT_TMP_ANIVERSTFI T
       WHERE T.ADMPD_FEC_OPER = V_FECHA
         AND ((T.ADMPV_COD_CLI IS NULL) OR
             (REPLACE(T.ADMPV_COD_CLI, ' ', '') IS NULL));

    --SE LE ASIGNA EL ERROR SI NO EXISTE EL CLIENTE EN LA TABLA PCLUB.ADMPT_CLIENTE
    MERGE INTO PCLUB.ADMPT_IMP_ANIVERSTFI I
    USING (SELECT T.ADMPV_COD_CLI AS ADMPV_COD_CLI,
                  T.ADMPD_FEC_OPER AS ADMPD_FEC_OPER,
                  MAX(T.ADMPD_FEC_ANIV) AS ADMPD_FEC_ANIV
             FROM PCLUB.ADMPT_TMP_ANIVERSTFI T
             LEFT JOIN PCLUB.ADMPT_CLIENTE C
               ON T.ADMPV_COD_CLI = C.ADMPV_COD_CLI
              AND C.ADMPV_COD_TPOCL = V_COD_TPOCL
            WHERE T.ADMPD_FEC_OPER = V_FECHA
              AND ((T.ADMPV_COD_CLI IS NOT NULL) OR
                  (REPLACE(T.ADMPV_COD_CLI, ' ', '') IS NOT NULL))
              AND C.ADMPV_COD_CLI IS NULL
            GROUP BY T.ADMPV_COD_CLI, T.ADMPD_FEC_OPER) Q
    ON (I.ADMPV_COD_CLI = Q.ADMPV_COD_CLI AND I.ADMPD_FEC_OPER = Q.ADMPD_FEC_OPER)
    WHEN NOT MATCHED THEN
      INSERT
        (ADMPN_ID_FILA,
         ADMPV_COD_CLI,
         ADMPD_FEC_ANIV,
         ADMPD_FEC_OPER,
         ADMPD_FEC_TRANS,
         ADMPV_MSJE_ERROR,
         ADMPV_NOM_ARCH)
      VALUES
        (PCLUB.ADMPT_IMP_ANIVERSTFI_SQ.NEXTVAL,
         Q.ADMPV_COD_CLI,
         Q.ADMPD_FEC_ANIV,
         V_FECSYS,
         SYSDATE,
         'El código de cliente no existe.',
         K_NOMBARCH);

    --SE LE ASIGNA EL ERROR SI EL CLIENTE ESTA DE BAJA
    MERGE INTO PCLUB.ADMPT_IMP_ANIVERSTFI I
    USING (SELECT T.ADMPV_COD_CLI AS ADMPV_COD_CLI,
                  T.ADMPD_FEC_OPER AS ADMPD_FEC_OPER,
                  MAX(T.ADMPD_FEC_ANIV) AS ADMPD_FEC_ANIV
             FROM PCLUB.ADMPT_TMP_ANIVERSTFI T
            INNER JOIN PCLUB.ADMPT_CLIENTE C
               ON T.ADMPV_COD_CLI = C.ADMPV_COD_CLI
              AND C.ADMPV_COD_TPOCL = V_COD_TPOCL
              AND C.ADMPC_ESTADO = 'B'
            WHERE T.ADMPD_FEC_OPER = V_FECHA
            GROUP BY T.ADMPV_COD_CLI, T.ADMPD_FEC_OPER) Q
    ON (I.ADMPV_COD_CLI = Q.ADMPV_COD_CLI AND I.ADMPD_FEC_OPER = Q.ADMPD_FEC_OPER)
    WHEN NOT MATCHED THEN
      INSERT
        (ADMPN_ID_FILA,
         ADMPV_COD_CLI,
         ADMPD_FEC_ANIV,
         ADMPD_FEC_OPER,
         ADMPD_FEC_TRANS,
         ADMPV_MSJE_ERROR,
         ADMPV_NOM_ARCH)
      VALUES
        (PCLUB.ADMPT_IMP_ANIVERSTFI_SQ.NEXTVAL,
         Q.ADMPV_COD_CLI,
         Q.ADMPD_FEC_ANIV,
         V_FECSYS,
         SYSDATE,
         'El cliente se encuentra de baja, no se le entregará puntos.',
         K_NOMBARCH);

    INSERT INTO PCLUB.ADMPT_IMP_ANIVERSTFI
      (ADMPN_ID_FILA,
       ADMPV_COD_CLI,
       ADMPD_FEC_ANIV,
       ADMPD_FEC_OPER,
       ADMPD_FEC_TRANS,
       ADMPV_MSJE_ERROR,
       ADMPV_NOM_ARCH)
      SELECT PCLUB.ADMPT_IMP_ANIVERSTFI_SQ.NEXTVAL,
             T.ADMPV_COD_CLI,
             T.ADMPD_FEC_ANIV,
             V_FECSYS,
             SYSDATE,
             'Ya se le asignó puntos por aniversario.',
             K_NOMBARCH
        FROM PCLUB.ADMPT_TMP_ANIVERSTFI T
       INNER JOIN PCLUB.ADMPT_CLIENTE C
          ON T.ADMPV_COD_CLI = C.ADMPV_COD_CLI
         AND C.ADMPV_COD_TPOCL = V_COD_TPOCL
         AND C.ADMPC_ESTADO = 'A'
       INNER JOIN PCLUB.ADMPT_KARDEX K
          ON T.ADMPV_COD_CLI = K.ADMPV_COD_CLI
         AND K.ADMPV_COD_CPTO = V_COD_CPTO
         AND TO_CHAR(K.ADMPD_FEC_TRANS, 'MM/YYYY') = V_FECSQL;

    --INSERTA EN PCLUB.ADMPT_AUX_ANIVERSTFI LOS REGISTROS CORRECTOS
    MERGE INTO PCLUB.ADMPT_AUX_ANIVERSTFI A
    USING (SELECT T.ADMPV_COD_CLI AS ADMPV_COD_CLI,
                  T.ADMPD_FEC_OPER AS ADMPD_FEC_OPER,
                  MAX(T.ADMPD_FEC_ANIV) AS ADMPD_FEC_ANIV
             FROM PCLUB.ADMPT_TMP_ANIVERSTFI T
             LEFT JOIN PCLUB.ADMPT_IMP_ANIVERSTFI I
               ON T.ADMPV_COD_CLI = I.ADMPV_COD_CLI
              AND T.ADMPD_FEC_OPER = I.ADMPD_FEC_OPER
            WHERE T.ADMPD_FEC_OPER = V_FECHA
              AND ((T.ADMPV_COD_CLI IS NOT NULL) OR
                  (REPLACE(T.ADMPV_COD_CLI, ' ', '') IS NOT NULL))
              AND I.ADMPD_FEC_OPER IS NULL
            GROUP BY T.ADMPV_COD_CLI, T.ADMPD_FEC_OPER) Q
    ON (A.ADMPV_COD_CLI = Q.ADMPV_COD_CLI AND A.ADMPD_FEC_OPER = Q.ADMPD_FEC_OPER)
    WHEN NOT MATCHED THEN
      INSERT
        (ADMPV_COD_CLI, ADMPD_FEC_ANIV, ADMPD_FEC_OPER)
      VALUES
        (Q.ADMPV_COD_CLI, Q.ADMPD_FEC_ANIV, V_FECSYS);

    --INSERTA EN PCLUB.ADMPT_IMP_ANIVERSTFI LOS REGISTROS CORRECTOS
    MERGE INTO PCLUB.ADMPT_IMP_ANIVERSTFI I
    USING (SELECT T.ADMPV_COD_CLI AS ADMPV_COD_CLI,
                  T.ADMPD_FEC_OPER AS ADMPD_FEC_OPER,
                  MAX(T.ADMPD_FEC_ANIV) AS ADMPD_FEC_ANIV
             FROM PCLUB.ADMPT_AUX_ANIVERSTFI T
            WHERE T.ADMPD_FEC_OPER = V_FECHA
            GROUP BY T.ADMPV_COD_CLI, T.ADMPD_FEC_OPER) Q
    ON (I.ADMPV_COD_CLI = Q.ADMPV_COD_CLI AND I.ADMPD_FEC_OPER = Q.ADMPD_FEC_OPER)
    WHEN NOT MATCHED THEN
      INSERT
        (ADMPN_ID_FILA,
         ADMPV_COD_CLI,
         ADMPD_FEC_ANIV,
         ADMPD_FEC_OPER,
         ADMPD_FEC_TRANS,
         ADMPV_NOM_ARCH)
      VALUES
        (PCLUB.ADMPT_IMP_ANIVERSTFI_SQ.NEXTVAL,
         Q.ADMPV_COD_CLI,
         Q.ADMPD_FEC_ANIV,
         V_FECSYS,
         SYSDATE,
         K_NOMBARCH);

    IF V_PUNTOS <> 0 THEN
      --SI EL CODIGO DEL CLIENTE EXISTE, SE LLEGA A MODIFICAR EN PCLUB.ADMPT_SALDOS_CLIENTE
      MERGE INTO PCLUB.ADMPT_SALDOS_CLIENTE S
      USING (SELECT A.ADMPV_COD_CLI AS ADMPV_COD_CLI
               FROM PCLUB.ADMPT_AUX_ANIVERSTFI A
               LEFT JOIN PCLUB.ADMPT_KARDEX K
                 ON A.ADMPV_COD_CLI = K.ADMPV_COD_CLI
                AND K.ADMPV_COD_CPTO = V_COD_CPTO
                AND TO_CHAR(K.ADMPD_FEC_TRANS, 'MM/YYYY') = V_FECSQL
              WHERE K.ADMPV_COD_CLI IS NULL) P
      ON (S.ADMPV_COD_CLI = P.ADMPV_COD_CLI)
      WHEN MATCHED THEN
        UPDATE SET S.ADMPN_SALDO_CC = S.ADMPN_SALDO_CC + V_PUNTOS;

      --SI EL CODIGO DEL CLIENTE EXISTE, SE LLEGA A INSERTAR EN PCLUB.ADMPT_KARDEX
      INSERT INTO PCLUB.ADMPT_KARDEX
        (ADMPN_ID_KARDEX,
         ADMPV_COD_CLI,
         ADMPV_COD_CPTO,
         ADMPD_FEC_TRANS,
         ADMPN_PUNTOS,
         ADMPC_TPO_OPER,
         ADMPC_TPO_PUNTO,
         ADMPN_SLD_PUNTO,
         ADMPC_ESTADO,
         ADMPV_NOM_ARCH)
        SELECT ADMPT_KARDEX_SQ.NEXTVAL,
               T.ADMPV_COD_CLI,
               V_COD_CPTO,
               SYSDATE,
               V_PUNTOS,
               'E',
               'C',
               V_PUNTOS,
               'A',
               K_NOMBARCH
          FROM PCLUB.ADMPT_AUX_ANIVERSTFI T
          LEFT JOIN PCLUB.ADMPT_KARDEX K
            ON T.ADMPV_COD_CLI = K.ADMPV_COD_CLI
           AND K.ADMPV_COD_CPTO = V_COD_CPTO
           AND TO_CHAR(K.ADMPD_FEC_TRANS, 'MM/YYYY') = V_FECSQL
         WHERE T.ADMPD_FEC_OPER = V_FECHA
           AND K.ADMPV_COD_CLI IS NULL;
    END IF;

    SELECT COUNT(*)
      INTO K_NUMREGTOT
      FROM PCLUB.ADMPT_TMP_ANIVERSTFI
     WHERE ADMPD_FEC_OPER = V_FECHA;

    SELECT COUNT(*)
      INTO K_NUMREGPRO
      FROM PCLUB.ADMPT_AUX_ANIVERSTFI
     WHERE ADMPD_FEC_OPER = V_FECHA;

    K_NUMREGERR := K_NUMREGTOT - K_NUMREGPRO;

    DELETE PCLUB.ADMPT_TMP_ANIVERSTFI WHERE ADMPD_FEC_OPER = V_FECHA;

    DELETE PCLUB.ADMPT_AUX_ANIVERSTFI WHERE ADMPD_FEC_OPER = V_FECHA;

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
          K_CODERROR  := SQLCODE;
          K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      END;
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      ROLLBACK;

      DELETE PCLUB.ADMPT_TMP_ANIVERSTFI WHERE ADMPD_FEC_OPER = V_FECHA;
      COMMIT;
      DELETE PCLUB.ADMPT_AUX_ANIVERSTFI WHERE ADMPD_FEC_OPER = V_FECHA;
      COMMIT;
  END ADMPSI_ANIVERSARIO;

  --****************************************************************
  -- Nombre SP           :  ADMPSS_EANIVERSARIO
  -- Propósito           :  Devuelve en un cursor los puntos por aniversario con error
  -- Input               :  K_FECHA - Fecha de Proceso
  -- Output              :  CURSOR_ERRORES Cursor con errores
  --                        K_CODERROR Código de error o éxito
  --                        K_DESCERROR Descripción del error
  -- Creado por          :  Oscar Paucar
  -- Fec Creación        :
  -- Fec Actualización   :  12/04/2013
  --****************************************************************

  PROCEDURE ADMPSS_EANIVERSARIO(K_FECHA       IN DATE,
                                K_CODERROR    OUT NUMBER,
                                K_DESCERROR   OUT VARCHAR2,
                                K_CUR_ERRORES OUT SYS_REFCURSOR) IS
    EX_ERROR EXCEPTION;
  BEGIN

    CASE
      WHEN K_FECHA IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese la fecha';
        RAISE EX_ERROR;
      ELSE
        K_CODERROR  := 0;
        K_DESCERROR := '';
    END CASE;

    OPEN K_CUR_ERRORES FOR
      SELECT ADMPN_ID_FILA,
             ADMPV_COD_CLI,
             ADMPD_FEC_ANIV,
             ADMPD_FEC_OPER,
             ADMPD_FEC_TRANS,
             ADMPV_MSJE_ERROR,
             ADMPV_NOM_ARCH
        FROM PCLUB.ADMPT_IMP_ANIVERSTFI
       WHERE ADMPD_FEC_OPER = K_FECHA
         AND ADMPV_MSJE_ERROR IS NOT NULL;

  EXCEPTION
    WHEN EX_ERROR THEN
      BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR
          INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_CODERROR  := SQLCODE;
          K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      END;
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
  END ADMPSS_EANIVERSARIO;

  --****************************************************************
  -- Nombre SP           :  ADMPSI_NO_RECARGA
  -- Propósito           :  Elimina los puntos por meses que no recarga.
  -- Input               :  K_FECHA
  --                     :  K_NOMBARCH
  -- Output              :  K_CODERROR Código de error o éxito
  --                        K_DESCERROR Descripción del error
  --                        K_NUMREGTOT Número total de registros
  --                        K_NUMREGPRO Número de registros procesador
  --                        K_NUMREGERR Número de registros errados
  -- Creado por          :  Oscar Paucar
  -- Fec Creación        :  10/04/2013
  -- Fec Actualización   :
  --****************************************************************

  PROCEDURE ADMPSI_NO_RECARGA(K_FECHA     IN DATE,
                              K_NOMBARCH  IN VARCHAR2,
                              K_CODERROR  OUT NUMBER,
                              K_DESCERROR OUT VARCHAR2,
                              K_NUMREGTOT OUT NUMBER,
                              K_NUMREGPRO OUT NUMBER,
                              K_NUMREGERR OUT NUMBER) IS

    V_COD_CPTO  VARCHAR2(2);
    V_FECHA     DATE := TRUNC(K_FECHA);
    V_FECSYS    DATE := TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'),
                                'DD/MM/YYYY');
    V_COD_TPOCL CHAR(1) := '8';
    EX_ERROR EXCEPTION;
  BEGIN

    CASE
      WHEN K_FECHA IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese la fecha';
        RAISE EX_ERROR;
      ELSE
        K_CODERROR  := 0;
        K_DESCERROR := '';
        K_NUMREGTOT := 0;
        K_NUMREGPRO := 0;
        K_NUMREGERR := 0;
    END CASE;

    BEGIN
      SELECT ADMPV_COD_CPTO
        INTO V_COD_CPTO
        FROM PCLUB.ADMPT_CONCEPTO
       WHERE UPPER(ADMPV_DESC) = 'SIN RECARGAS TFI';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'No está registrado el concepto SIN RECARGAS TFI (PCLUB.ADMPT_CONCEPTO)';
        RAISE EX_ERROR;
      WHEN TOO_MANY_ROWS THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Existen varios registros con el concepto SIN RECARGAS TFI (PCLUB.ADMPT_CONCEPTO)';
        RAISE EX_ERROR;
    END;

    --SE LE ASIGNA EL ERROR SI EL CODIGO DEL CLIENTE ES NULO
    INSERT INTO PCLUB.ADMPT_IMP_SINRECARGATFI
      (ADMPN_ID_FILA,
       ADMPV_COD_CLI,
       ADMPD_FEC_OPER,
       ADMPD_FEC_TRANS,
       ADMPV_MSJE_ERROR,
       ADMPV_NOM_ARCH)
      SELECT ADMPT_IMP_SINRECARGATFI_SQ.NEXTVAL,
             T.ADMPV_COD_CLI,
             V_FECSYS,
             SYSDATE,
             'El código de cliente es un dato obligatorio.',
             K_NOMBARCH
        FROM PCLUB.ADMPT_TMP_SINRECARGATFI T
       WHERE T.ADMPD_FEC_OPER = V_FECHA
         AND ((T.ADMPV_COD_CLI IS NULL) OR
             (REPLACE(T.ADMPV_COD_CLI, ' ', '') IS NULL));

    --SE LE ASIGNA EL ERROR SI NO EXISTE EL CLIENTE EN LA TABLA PCLUB.ADMPT_CLIENTE
    MERGE INTO PCLUB.ADMPT_IMP_SINRECARGATFI I
    USING (SELECT T.ADMPV_COD_CLI AS ADMPV_COD_CLI,
                  T.ADMPD_FEC_OPER AS ADMPD_FEC_OPER
             FROM PCLUB.ADMPT_TMP_SINRECARGATFI T
             LEFT JOIN PCLUB.ADMPT_CLIENTE C
               ON T.ADMPV_COD_CLI = C.ADMPV_COD_CLI
              AND C.ADMPV_COD_TPOCL = V_COD_TPOCL
            WHERE T.ADMPD_FEC_OPER = V_FECHA
              AND ((T.ADMPV_COD_CLI IS NOT NULL) OR
                  (REPLACE(T.ADMPV_COD_CLI, ' ', '') IS NOT NULL))
              AND C.ADMPV_COD_CLI IS NULL
            GROUP BY T.ADMPV_COD_CLI, T.ADMPD_FEC_OPER) Q
    ON (I.ADMPV_COD_CLI = Q.ADMPV_COD_CLI AND I.ADMPD_FEC_OPER = Q.ADMPD_FEC_OPER)
    WHEN NOT MATCHED THEN
      INSERT
        (ADMPN_ID_FILA,
         ADMPV_COD_CLI,
         ADMPD_FEC_OPER,
         ADMPD_FEC_TRANS,
         ADMPV_MSJE_ERROR,
         ADMPV_NOM_ARCH)
      VALUES
        (ADMPT_IMP_SINRECARGATFI_SQ.NEXTVAL,
         Q.ADMPV_COD_CLI,
         V_FECSYS,
         SYSDATE,
         'El código de cliente no existe.',
         K_NOMBARCH);

    --INSERTA EN PCLUB.ADMPT_AUX_SINRECARGATFI LOS REGISTROS CORRECTOS
    MERGE INTO PCLUB.ADMPT_AUX_SINRECARGATFI A
    USING (SELECT T.ADMPV_COD_CLI AS ADMPV_COD_CLI,
                  T.ADMPD_FEC_OPER AS ADMPD_FEC_OPER
             FROM PCLUB.ADMPT_TMP_SINRECARGATFI T
             LEFT JOIN PCLUB.ADMPT_IMP_SINRECARGATFI I
               ON T.ADMPV_COD_CLI = I.ADMPV_COD_CLI
              AND T.ADMPD_FEC_OPER = I.ADMPD_FEC_OPER
            WHERE T.ADMPD_FEC_OPER = V_FECHA
              AND ((T.ADMPV_COD_CLI IS NOT NULL) OR
                  (REPLACE(T.ADMPV_COD_CLI, ' ', '') IS NOT NULL))
              AND I.ADMPD_FEC_OPER IS NULL
            GROUP BY T.ADMPV_COD_CLI, T.ADMPD_FEC_OPER) Q
    ON (A.ADMPV_COD_CLI = Q.ADMPV_COD_CLI AND A.ADMPD_FEC_OPER = Q.ADMPD_FEC_OPER)
    WHEN NOT MATCHED THEN
      INSERT
        (ADMPV_COD_CLI, ADMPD_FEC_OPER)
      VALUES
        (Q.ADMPV_COD_CLI, V_FECSYS);

    --INSERTA EN PCLUB.ADMPT_IMP_SINRECARGATFI LOS REGISTROS CORRECTOS
    MERGE INTO PCLUB.ADMPT_IMP_SINRECARGATFI I
    USING (SELECT T.ADMPV_COD_CLI AS ADMPV_COD_CLI,
                  T.ADMPD_FEC_OPER AS ADMPD_FEC_OPER
             FROM PCLUB.ADMPT_AUX_SINRECARGATFI T
            WHERE T.ADMPD_FEC_OPER = V_FECHA
            GROUP BY T.ADMPV_COD_CLI, T.ADMPD_FEC_OPER) Q
    ON (I.ADMPV_COD_CLI = Q.ADMPV_COD_CLI AND I.ADMPD_FEC_OPER = Q.ADMPD_FEC_OPER)
    WHEN NOT MATCHED THEN
      INSERT
        (ADMPN_ID_FILA,
         ADMPV_COD_CLI,
         ADMPD_FEC_OPER,
         ADMPD_FEC_TRANS,
         ADMPV_NOM_ARCH)
      VALUES
        (ADMPT_IMP_SINRECARGATFI_SQ.NEXTVAL,
         Q.ADMPV_COD_CLI,
         V_FECSYS,
         SYSDATE,
         K_NOMBARCH);

    --SI EL CODIGO DEL CLIENTE EXISTE, SE LLEGA A INSERTAR EN PCLUB.ADMPT_KARDEX
    INSERT INTO PCLUB.ADMPT_KARDEX
      (ADMPN_ID_KARDEX,
       ADMPV_COD_CLI,
       ADMPV_COD_CPTO,
       ADMPD_FEC_TRANS,
       ADMPN_PUNTOS,
       ADMPC_TPO_OPER,
       ADMPC_TPO_PUNTO,
       ADMPN_SLD_PUNTO,
       ADMPC_ESTADO,
       ADMPV_NOM_ARCH)
      SELECT ADMPT_KARDEX_SQ.NEXTVAL,
             A.ADMPV_COD_CLI,
             V_COD_CPTO,
             SYSDATE,
             (NVL(S.ADMPN_SALDO_CC, 0) * (-1)),
             'S',
             'C',
             0,
             'A',
             K_NOMBARCH
        FROM PCLUB.ADMPT_AUX_SINRECARGATFI A
       INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTE S
          ON A.ADMPV_COD_CLI = S.ADMPV_COD_CLI
         AND S.ADMPN_SALDO_CC > 0
       WHERE A.ADMPD_FEC_OPER = V_FECHA;

    --ACTUALIZA SALDO EN PCLUB.ADMPT_KARDEX A CERO
    MERGE INTO PCLUB.ADMPT_KARDEX K
    USING (SELECT DISTINCT A.ADMPV_COD_CLI AS ADMPV_COD_CLI
             FROM PCLUB.ADMPT_AUX_SINRECARGATFI A
            INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTE S
               ON A.ADMPV_COD_CLI = S.ADMPV_COD_CLI
              AND S.ADMPN_SALDO_CC > 0
            WHERE A.ADMPD_FEC_OPER = V_FECHA) Q
    ON (K.ADMPV_COD_CLI = Q.ADMPV_COD_CLI)
    WHEN MATCHED THEN
      UPDATE
         SET K.ADMPN_SLD_PUNTO = 0
       WHERE K.ADMPC_TPO_OPER = 'E'
         AND K.ADMPC_TPO_PUNTO IN ('C', 'L')
         AND K.ADMPN_SLD_PUNTO > 0
         AND K.ADMPC_ESTADO = 'A';

    --ACTUALIZA SALDO EN TABLA PCLUB.ADMPT_SALDOS_CLIENTE A CERO
    UPDATE PCLUB.ADMPT_SALDOS_CLIENTE S
       SET S.ADMPN_SALDO_CC = 0, S.ADMPC_ESTPTO_CC = 'C'
     WHERE EXISTS (SELECT A.ADMPV_COD_CLI
              FROM PCLUB.ADMPT_AUX_SINRECARGATFI A
             WHERE A.ADMPV_COD_CLI = S.ADMPV_COD_CLI)
       AND S.ADMPN_SALDO_CC > 0;

    SELECT COUNT(*)
      INTO K_NUMREGTOT
      FROM PCLUB.ADMPT_TMP_SINRECARGATFI
     WHERE ADMPD_FEC_OPER = V_FECHA;

    SELECT COUNT(*)
      INTO K_NUMREGPRO
      FROM PCLUB.ADMPT_AUX_SINRECARGATFI
     WHERE ADMPD_FEC_OPER = V_FECHA;

    K_NUMREGERR := K_NUMREGTOT - K_NUMREGPRO;

    DELETE PCLUB.ADMPT_TMP_SINRECARGATFI WHERE ADMPD_FEC_OPER = V_FECHA;

    DELETE PCLUB.ADMPT_AUX_SINRECARGATFI WHERE ADMPD_FEC_OPER = V_FECHA;

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
          K_CODERROR  := SQLCODE;
          K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      END;
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      ROLLBACK;

      DELETE PCLUB.ADMPT_TMP_SINRECARGATFI WHERE ADMPD_FEC_OPER = V_FECHA;
      COMMIT;
      DELETE PCLUB.ADMPT_AUX_SINRECARGATFI WHERE ADMPD_FEC_OPER = V_FECHA;
      COMMIT;
  END ADMPSI_NO_RECARGA;

  --****************************************************************
  -- Nombre SP           :  ADMPSS_ENO_RECARGA
  -- Propósito           :  Devuelve en un cursor los puntos por no recarga con error
  -- Input               :  K_FECHA - Fecha de Proceso
  -- Output              :  CURSOR_ERRORES Cursor con errores
  --                        K_CODERROR Código de error o éxito
  --                        K_DESCERROR Descripción del error
  -- Creado por          :  Oscar Paucar
  -- Fec Creación        :
  -- Fec Actualización   :  12/04/2013
  --****************************************************************

  PROCEDURE ADMPSS_ENO_RECARGA(K_FECHA       IN DATE,
                               K_CODERROR    OUT NUMBER,
                               K_DESCERROR   OUT VARCHAR2,
                               K_CUR_ERRORES OUT SYS_REFCURSOR) IS
    EX_ERROR EXCEPTION;
  BEGIN

    CASE
      WHEN K_FECHA IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese la fecha';
        RAISE EX_ERROR;
      ELSE
        K_CODERROR  := 0;
        K_DESCERROR := '';
    END CASE;

    OPEN K_CUR_ERRORES FOR
      SELECT ADMPN_ID_FILA,
             ADMPV_COD_CLI,
             ADMPD_FEC_OPER,
             ADMPD_FEC_TRANS,
             ADMPV_MSJE_ERROR,
             ADMPV_NOM_ARCH
        FROM PCLUB.ADMPT_IMP_SINRECARGATFI
       WHERE ADMPD_FEC_OPER = K_FECHA
         AND ADMPV_MSJE_ERROR IS NOT NULL;

  EXCEPTION
    WHEN EX_ERROR THEN
      BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR
          INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_CODERROR  := SQLCODE;
          K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      END;
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
  END ADMPSS_ENO_RECARGA;

  --****************************************************************
  -- Nombre SP           :  ADMPSI_BAJACLIENTE
  -- Propósito           :  Actualiza el cliente con el estado BAJA.
  -- Input               :  K_FECHA
  --                     :  K_NOMBARCH
  -- Output              :  K_CODERROR Código de error o éxito
  --                        K_DESCERROR Descripción del error
  --                        K_NUMREGTOT Número total de registros
  --                        K_NUMREGPRO Número de registros procesador
  --                        K_NUMREGERR Número de registros errados
  -- Creado por          :  Oscar Paucar
  -- Fec Creación        :  10/04/2013
  -- Fec Actualización   :
  --****************************************************************

  PROCEDURE ADMPSI_BAJACLIENTE(K_FECHA     IN DATE,
                               K_NOMBARCH  IN VARCHAR2,
                               K_CODERROR  OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2,
                               K_NUMREGTOT OUT NUMBER,
                               K_NUMREGPRO OUT NUMBER,
                               K_NUMREGERR OUT NUMBER) IS

    CURSOR CUR_CLIENTE IS
      SELECT ADMPV_COD_CLI, ADMPD_FEC_BAJA
        FROM PCLUB.ADMPT_AUX_BAJACLI_TFI
       WHERE ADMPD_FEC_OPER = TRUNC(K_FECHA);
    C_COD_CLI     VARCHAR2(40);
    C_FEC_BAJA    DATE;
    V_CLIENTE_AUX VARCHAR2(40);
    V_REG         VARCHAR2(2);
    V_SALDO_CLI   NUMBER;
    V_COD_CPTO    VARCHAR2(2);
    V_COD_CPTO2   VARCHAR2(2);
    V_COD_NUEVO   NUMBER;
    V_COD_CLINUE  VARCHAR2(40);
    V_FECHA       DATE := TRUNC(K_FECHA);
    V_FECSYS      DATE := TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'),
                                  'DD/MM/YYYY');
    V_COD_TPOCL   CHAR(1) := '8';
    EX_ERROR EXCEPTION;
  BEGIN

    CASE
      WHEN K_FECHA IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese la fecha';
        RAISE EX_ERROR;
      ELSE
        K_CODERROR  := 0;
        K_DESCERROR := '';
        K_NUMREGTOT := 0;
        K_NUMREGPRO := 0;
        K_NUMREGERR := 0;
    END CASE;

    BEGIN
      SELECT ADMPV_COD_CPTO
        INTO V_COD_CPTO
        FROM PCLUB.ADMPT_CONCEPTO
       WHERE ADMPV_DESC = 'BAJA CLIENTE TFI';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'No está registrado el concepto BAJA CLIENTE TFI (PCLUB.ADMPT_CONCEPTO)';
        RAISE EX_ERROR;
      WHEN TOO_MANY_ROWS THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Existen varios registros con el concepto BAJA CLIENTE TFI (PCLUB.ADMPT_CONCEPTO)';
        RAISE EX_ERROR;
    END;

    BEGIN
      SELECT ADMPV_COD_CPTO
        INTO V_COD_CPTO2
        FROM PCLUB.ADMPT_CONCEPTO
       WHERE ADMPV_DESC = 'INGRESO POR BAJA CLIENTE TFI';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'No está registrado el concepto INGRESO POR BAJA CLIENTE TFI (PCLUB.ADMPT_CONCEPTO)';
        RAISE EX_ERROR;
      WHEN TOO_MANY_ROWS THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Existen varios registros con el concepto INGRESO POR BAJA CLIENTE TFI (PCLUB.ADMPT_CONCEPTO)';
        RAISE EX_ERROR;
    END;

    --SE LE ASIGNA EL ERROR SI EL CODIGO DEL CLIENTE ES NULO
    INSERT INTO PCLUB.ADMPT_IMP_BAJACLI_TFI
      (ADMPN_ID_FILA,
       ADMPV_COD_CLI,
       ADMPD_FEC_BAJA,
       ADMPD_FEC_OPER,
       ADMPD_FEC_TRANS,
       ADMPV_MSJE_ERROR,
       ADMPV_NOM_ARCH)
      SELECT ADMPT_IMP_BAJACLI_TFI_SQ.NEXTVAL,
             T.ADMPV_COD_CLI,
             T.ADMPD_FEC_BAJA,
             V_FECSYS,
             SYSDATE,
             'El código de cliente es un dato obligatorio.',
             K_NOMBARCH
        FROM PCLUB.ADMPT_TMP_BAJACLI_TFI T
       WHERE T.ADMPD_FEC_OPER = V_FECHA
         AND ((T.ADMPV_COD_CLI IS NULL) OR
             (REPLACE(T.ADMPV_COD_CLI, ' ', '') IS NULL));

    --SE LE ASIGNA EL ERROR SI NO EXISTE EL CLIENTE EN LA TABLA PCLUB.ADMPT_CLIENTE
    MERGE INTO PCLUB.ADMPT_IMP_BAJACLI_TFI I
    USING (SELECT T.ADMPV_COD_CLI AS ADMPV_COD_CLI,
                  T.ADMPD_FEC_OPER AS ADMPD_FEC_OPER,
                  MAX(T.ADMPD_FEC_BAJA) AS ADMPD_FEC_BAJA
             FROM PCLUB.ADMPT_TMP_BAJACLI_TFI T
             LEFT JOIN PCLUB.ADMPT_CLIENTE C
               ON T.ADMPV_COD_CLI = C.ADMPV_COD_CLI
              AND C.ADMPV_COD_TPOCL = V_COD_TPOCL
            WHERE T.ADMPD_FEC_OPER = V_FECHA
              AND ((T.ADMPV_COD_CLI IS NOT NULL) OR
                  (REPLACE(T.ADMPV_COD_CLI, ' ', '') IS NOT NULL))
              AND C.ADMPV_COD_CLI IS NULL
            GROUP BY T.ADMPV_COD_CLI, T.ADMPD_FEC_OPER) Q
    ON (I.ADMPV_COD_CLI = Q.ADMPV_COD_CLI AND I.ADMPD_FEC_OPER = Q.ADMPD_FEC_OPER)
    WHEN NOT MATCHED THEN
      INSERT
        (ADMPN_ID_FILA,
         ADMPV_COD_CLI,
         ADMPD_FEC_BAJA,
         ADMPD_FEC_OPER,
         ADMPD_FEC_TRANS,
         ADMPV_MSJE_ERROR,
         ADMPV_NOM_ARCH)
      VALUES
        (ADMPT_IMP_BAJACLI_TFI_SQ.NEXTVAL,
         Q.ADMPV_COD_CLI,
         Q.ADMPD_FEC_BAJA,
         V_FECSYS,
         SYSDATE,
         'El código de cliente no existe.',
         K_NOMBARCH);

    --INSERTA EN PCLUB.ADMPT_AUX_BAJACLI_TFI LOS REGISTROS CORRECTOS
    MERGE INTO PCLUB.ADMPT_AUX_BAJACLI_TFI A
    USING (SELECT T.ADMPV_COD_CLI AS ADMPV_COD_CLI,
                  T.ADMPD_FEC_OPER AS ADMPD_FEC_OPER,
                  MAX(T.ADMPD_FEC_BAJA) AS ADMPD_FEC_BAJA
             FROM PCLUB.ADMPT_TMP_BAJACLI_TFI T
             LEFT JOIN PCLUB.ADMPT_IMP_BAJACLI_TFI I
               ON T.ADMPV_COD_CLI = I.ADMPV_COD_CLI
              AND T.ADMPD_FEC_OPER = I.ADMPD_FEC_OPER
            WHERE T.ADMPD_FEC_OPER = V_FECHA
              AND ((T.ADMPV_COD_CLI IS NOT NULL) OR
                  (REPLACE(T.ADMPV_COD_CLI, ' ', '') IS NOT NULL))
              AND I.ADMPD_FEC_OPER IS NULL
            GROUP BY T.ADMPV_COD_CLI, T.ADMPD_FEC_OPER) Q
    ON (A.ADMPV_COD_CLI = Q.ADMPV_COD_CLI AND A.ADMPD_FEC_OPER = Q.ADMPD_FEC_OPER)
    WHEN NOT MATCHED THEN
      INSERT
        (ADMPV_COD_CLI, ADMPD_FEC_BAJA, ADMPD_FEC_OPER)
      VALUES
        (Q.ADMPV_COD_CLI, Q.ADMPD_FEC_BAJA, V_FECSYS);

    --INSERTA EN PCLUB.ADMPT_IMP_BAJACLI_TFI LOS REGISTROS CORRECTOS
    MERGE INTO PCLUB.ADMPT_IMP_BAJACLI_TFI I
    USING (SELECT T.ADMPV_COD_CLI AS ADMPV_COD_CLI,
                  T.ADMPD_FEC_OPER AS ADMPD_FEC_OPER,
                  MAX(T.ADMPD_FEC_BAJA) AS ADMPD_FEC_BAJA
             FROM PCLUB.ADMPT_AUX_BAJACLI_TFI T
            WHERE T.ADMPD_FEC_OPER = V_FECHA
            GROUP BY T.ADMPV_COD_CLI, T.ADMPD_FEC_OPER) Q
    ON (I.ADMPV_COD_CLI = Q.ADMPV_COD_CLI AND I.ADMPD_FEC_OPER = Q.ADMPD_FEC_OPER)
    WHEN NOT MATCHED THEN
      INSERT
        (ADMPN_ID_FILA,
         ADMPV_COD_CLI,
         ADMPD_FEC_BAJA,
         ADMPD_FEC_OPER,
         ADMPD_FEC_TRANS,
         ADMPV_NOM_ARCH)
      VALUES
        (ADMPT_IMP_BAJACLI_TFI_SQ.NEXTVAL,
         Q.ADMPV_COD_CLI,
         Q.ADMPD_FEC_BAJA,
         V_FECSYS,
         SYSDATE,
         K_NOMBARCH);

    OPEN CUR_CLIENTE;

    FETCH CUR_CLIENTE
      INTO C_COD_CLI, C_FEC_BAJA;
    WHILE CUR_CLIENTE%FOUND LOOP
      -- OBTENEMOS EL SALDO DE LA CUENTA QUE SE DA DE BAJA
      BEGIN
        SELECT ADMPN_SALDO_CC
          INTO V_SALDO_CLI
          FROM PCLUB.ADMPT_SALDOS_CLIENTE
         WHERE ADMPV_COD_CLI = C_COD_CLI;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_SALDO_CLI := 0;
      END;

      -- BUSCAMOS SI EL CLIENTE TIENE OTRO TELEFONO PREPAGO
      BEGIN
        V_CLIENTE_AUX := NULL;
        SELECT MIN(ADMPV_COD_CLI)
          INTO V_CLIENTE_AUX
          FROM PCLUB.ADMPT_CLIENTE,
               (SELECT TRIM(C.ADMPV_TIPO_DOC) AS TIPO_DOC,
                       TRIM(C.ADMPV_NUM_DOC) AS NUM_DOC
                  FROM PCLUB.ADMPT_CLIENTE C
                 WHERE C.ADMPV_COD_CLI = C_COD_CLI) TC
         WHERE ADMPV_COD_CLI <> C_COD_CLI
           AND ADMPV_TIPO_DOC = TC.TIPO_DOC
           AND ADMPV_NUM_DOC = TC.NUM_DOC
           AND ADMPV_COD_TPOCL = V_COD_TPOCL
           AND ADMPC_ESTADO = 'A';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_CLIENTE_AUX := NULL;
      END;

      IF V_CLIENTE_AUX IS NOT NULL THEN
        IF V_SALDO_CLI > 0 THEN
          --SE ACTUALIZA EL SALDO DEL CLIENTE EN LA TABLA PCLUB.ADMPT_SALDOS_CLIENTE
          UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
             SET ADMPN_SALDO_CC  = V_SALDO_CLI +
                                   (SELECT NVL(ADMPN_SALDO_CC, 0)
                                      FROM PCLUB.ADMPT_SALDOS_CLIENTE
                                     WHERE ADMPV_COD_CLI = V_CLIENTE_AUX),
                 ADMPC_ESTPTO_CC = 'A'
           WHERE ADMPV_COD_CLI = V_CLIENTE_AUX;

          --SE INSERTA EL REGISTRO DE INGRESO EN LA TABLA PCLUB.ADMPT_KARDEX
          INSERT INTO PCLUB.ADMPT_KARDEX
            (ADMPN_ID_KARDEX,
             ADMPV_COD_CLI,
             ADMPV_COD_CPTO,
             ADMPD_FEC_TRANS,
             ADMPN_PUNTOS,
             ADMPC_TPO_OPER,
             ADMPC_TPO_PUNTO,
             ADMPN_SLD_PUNTO,
             ADMPC_ESTADO,
             ADMPV_NOM_ARCH)
          VALUES
            (ADMPT_KARDEX_SQ.NEXTVAL,
             V_CLIENTE_AUX,
             V_COD_CPTO2,
             SYSDATE,
             V_SALDO_CLI,
             'E',
             'C',
             V_SALDO_CLI,
             'A',
             K_NOMBARCH);
        END IF;
      END IF;

      --SE INSERTA EL REGISTRO DE SALIDA EN LA TABLA PCLUB.ADMPT_KARDEX
      IF V_SALDO_CLI > 0 THEN
        INSERT INTO PCLUB.ADMPT_KARDEX
          (ADMPN_ID_KARDEX,
           ADMPV_COD_CLI,
           ADMPV_COD_CPTO,
           ADMPD_FEC_TRANS,
           ADMPN_PUNTOS,
           ADMPC_TPO_OPER,
           ADMPC_TPO_PUNTO,
           ADMPN_SLD_PUNTO,
           ADMPC_ESTADO,
           ADMPV_NOM_ARCH)
        VALUES
          (ADMPT_KARDEX_SQ.NEXTVAL,
           C_COD_CLI,
           V_COD_CPTO,
           SYSDATE,
           V_SALDO_CLI * (-1),
           'S',
           'C',
           0,
           'A',
           K_NOMBARCH);
      END IF;

      --SE ACTUALIZA LA TABLA PCLUB.ADMPT_KARDEX
      UPDATE PCLUB.ADMPT_KARDEX
         SET ADMPN_SLD_PUNTO = 0
       WHERE ADMPV_COD_CLI = C_COD_CLI
         AND ADMPC_TPO_PUNTO IN ('C', 'L')
         AND ADMPC_TPO_OPER = 'E'
         AND ADMPN_SLD_PUNTO > 0;

      --SE ACTUALIZA EN LA TABLA PCLUB.ADMPT_SALDOS_CLIENTE
      UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
         SET ADMPN_SALDO_CC = 0, ADMPC_ESTPTO_CC = 'B'
       WHERE ADMPV_COD_CLI = C_COD_CLI;

      V_COD_NUEVO := 1;
      BEGIN
        SELECT INSTR(C_COD_CLI, '-') INTO V_REG FROM DUAL;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_REG := 0;
      END;
      IF V_REG > 0 THEN
        SELECT CAST(SUBSTR(C_COD_CLI, V_REG + 1) AS SMALLINT) + 1
          INTO V_COD_NUEVO
          FROM DUAL;
      END IF;
      V_COD_CLINUE := TRIM(C_COD_CLI) || '-' || TO_CHAR(V_COD_NUEVO);

      UPDATE PCLUB.ADMPT_KARDEX
         SET ADMPV_COD_CLI = V_COD_CLINUE
       WHERE ADMPV_COD_CLI = C_COD_CLI;

      UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
         SET ADMPV_COD_CLI = V_COD_CLINUE
       WHERE ADMPV_COD_CLI = C_COD_CLI;

      UPDATE PCLUB.ADMPT_CANJE
         SET ADMPV_COD_CLI = V_COD_CLINUE
       WHERE ADMPV_COD_CLI = C_COD_CLI;

      --MODIFICAR EL ESTADO DEL CLIENTE PREPAGO, ESTADO B(BAJA), EN LA TABLA CLIENTE
      UPDATE PCLUB.ADMPT_CLIENTE C
         SET ADMPC_ESTADO = 'B', ADMPV_COD_CLI = V_COD_CLINUE
       WHERE ADMPV_COD_CLI = C_COD_CLI
         AND C.ADMPV_COD_TPOCL = V_COD_TPOCL;

      FETCH CUR_CLIENTE
        INTO C_COD_CLI, C_FEC_BAJA;
    END LOOP;
    CLOSE CUR_CLIENTE;

    SELECT COUNT(*)
      INTO K_NUMREGTOT
      FROM PCLUB.ADMPT_TMP_BAJACLI_TFI
     WHERE ADMPD_FEC_OPER = V_FECHA;

    SELECT COUNT(*)
      INTO K_NUMREGPRO
      FROM PCLUB.ADMPT_AUX_BAJACLI_TFI
     WHERE ADMPD_FEC_OPER = V_FECHA;

    K_NUMREGERR := K_NUMREGTOT - K_NUMREGPRO;

    DELETE PCLUB.ADMPT_TMP_BAJACLI_TFI WHERE ADMPD_FEC_OPER = V_FECHA;

    DELETE PCLUB.ADMPT_AUX_BAJACLI_TFI WHERE ADMPD_FEC_OPER = V_FECHA;

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
          K_DESCERROR := 'ERROR';
      END;
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      ROLLBACK;

      DELETE PCLUB.ADMPT_TMP_BAJACLI_TFI WHERE ADMPD_FEC_OPER = V_FECHA;
      COMMIT;
      DELETE PCLUB.ADMPT_AUX_BAJACLI_TFI WHERE ADMPD_FEC_OPER = V_FECHA;
      COMMIT;
  END ADMPSI_BAJACLIENTE;

  --****************************************************************
  -- Nombre SP           :  ADMPSS_EBAJACLIENTE
  -- Propósito           :  Devuelve en un cursor los clientes de baja con error
  -- Input               :  K_FECHA - Fecha de Proceso
  -- Output              :  CURSOR_ERRORES Cursor con errores
  --                        K_CODERROR Código de error o éxito
  --                        K_DESCERROR Descripción del error
  -- Creado por          :  Oscar Paucar
  -- Fec Creación        :
  -- Fec Actualización   :  12/04/2013
  --****************************************************************

  PROCEDURE ADMPSS_EBAJACLIENTE(K_FECHA       IN DATE,
                                K_CODERROR    OUT NUMBER,
                                K_DESCERROR   OUT VARCHAR2,
                                K_CUR_ERRORES OUT SYS_REFCURSOR) IS
    EX_ERROR EXCEPTION;
  BEGIN

    CASE
      WHEN K_FECHA IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese la fecha';
        RAISE EX_ERROR;
      ELSE
        K_CODERROR  := 0;
        K_DESCERROR := '';
    END CASE;

    OPEN K_CUR_ERRORES FOR
      SELECT ADMPN_ID_FILA,
             ADMPV_COD_CLI,
             ADMPD_FEC_BAJA,
             ADMPD_FEC_OPER,
             ADMPD_FEC_TRANS,
             ADMPV_MSJE_ERROR,
             ADMPV_NOM_ARCH
        FROM PCLUB.ADMPT_IMP_BAJACLI_TFI
       WHERE ADMPD_FEC_OPER = K_FECHA
         AND ADMPV_MSJE_ERROR IS NOT NULL;

  EXCEPTION
    WHEN EX_ERROR THEN
      BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR
          INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_CODERROR  := SQLCODE;
          K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      END;
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
  END ADMPSS_EBAJACLIENTE;

END PKG_CC_PTOSTFI;
/