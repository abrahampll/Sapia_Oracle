CREATE OR REPLACE PACKAGE BODY PCLUB.PKG_CC_BONOS IS

--****************************************************************
-- Nombre SP           :  ADMPSI_ENTREGA_BONO
-- Propósito           :  Entregar los bonos de puntos por Alta
-- Input               :  K_IDENT     -- Código del Bono
--                        K_BONO      -- Descripción del Bono
--                        K_LINEA     -- Línea a la que se otorgará el bono
-- Output              :  K_MSJSMS
--                        K_PUNTOS
--                        K_VIGENCIA
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Roxana Chero
-- Fec Creación        :  18/07/2013
--****************************************************************
  PROCEDURE ADMPSI_ENTREGA_BONO(K_IDENT     IN NUMBER,
                                K_BONO      IN VARCHAR2,
                                K_LINEA     IN VARCHAR2,
                                K_USUARIO   IN VARCHAR2,
                                K_MSJSMS    OUT VARCHAR2,
                                K_CUR_BONO  OUT SYS_REFCURSOR,
                                K_CODERROR  OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2) IS
    V_DESCBONO       VARCHAR2(100);
    V_CODMSJSMS      VARCHAR2(100);
    K_CUR_BONOCONFIG SYS_REFCURSOR;
    V_CODERROR       NUMBER;
    V_DESCERROR      VARCHAR2(200);
    V_EXISTE_CC      NUMBER;
    V_EXITO          NUMBER;
    V_CODERROR_R     NUMBER;
    V_DESCERROR_R    VARCHAR2(100);
    V_BONO           VARCHAR2(100);
    V_PUNTOS         NUMBER;
    V_CONCEPTO       VARCHAR2(100);
    V_IDKARDEX       NUMBER;
    V_TIPDOC         VARCHAR2(40);
    V_NRODOC         VARCHAR2(100);
    V_DIAS           NUMBER;
    V_TIPOPREM       NUMBER;
    V_LINEA          VARCHAR2(50);
    V_FECVCMTO       VARCHAR2(50);
    V_MSJSMS         VARCHAR2(200);
    V_EXISTE_SLDO    NUMBER;
    V_COUNT_C        NUMBER;
    EX_ERROR EXCEPTION;
    EX_ERROR_REG EXCEPTION;
    EX_ERROR_OBT EXCEPTION;

  BEGIN

    K_CODERROR  := 0;
    K_DESCERROR := '';

    IF K_IDENT IS NULL AND K_BONO IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'Ingrese un Identificador de Bono o Descripción de Bono válido. ';
      RAISE EX_ERROR;
    END IF;

    IF TRIM(K_LINEA) IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'Ingrese un Número de Línea válido. ';
      RAISE EX_ERROR;
    END IF;

    IF K_USUARIO IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'Ingrese un Usuario válido. ';
      RAISE EX_ERROR;
    END IF;

    IF LENGTH(K_LINEA) <> 9 THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'Ingrese un Número de Línea válido. ';
      RAISE EX_ERROR;
    END IF;

    IF LENGTH(TRIM(TRANSLATE(K_LINEA, '0123456789', ' '))) > 0 THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'El valor de la línea debe ser numérico. ';
      RAISE EX_ERROR;
    END IF;

	--VALIDAMOS LA EXISTENCIA DEL BONO

    V_COUNT_C:=0;

    SELECT COUNT(1) INTO V_COUNT_C
    FROM 	PCLUB.ADMPT_KARDEX K INNER JOIN PCLUB.ADMPT_BONO_CONFIG F
          ON K.ADMPV_COD_CPTO=F.ADMPV_COD_CPTO
          INNER JOIN ADMPT_BONO B
          ON F.ADMPV_BONO=B.ADMPV_BONO
    WHERE K.ADMPV_COD_CLI=K_LINEA
          AND (B.ADMPN_ID_BONO_PRE = K_IDENT OR B.ADMPV_BONO=K_BONO)
          AND B.ADMPV_TYPEBONO IS NULL;

	/** SE AGREGO PARA VERIFICAR EN MIGRACION TB*/      
    IF V_COUNT_C=0 THEN
      SELECT COUNT(1) INTO V_COUNT_C 
      FROM 	ADMPT_KARDEX_MIG K INNER JOIN ADMPT_BONO_CONFIG F
            ON K.ADMPV_COD_CPTO=F.ADMPV_COD_CPTO
            INNER JOIN ADMPT_BONO B
            ON F.ADMPV_BONO=B.ADMPV_BONO
      WHERE K.ADMPV_COD_CLI=K_LINEA
            AND (B.ADMPN_ID_BONO_PRE = K_IDENT OR B.ADMPV_BONO=K_BONO)
            AND B.ADMPV_TYPEBONO IS NULL;
    END IF;
	
    IF V_COUNT_C>0 THEN
       K_CODERROR  := 54;
       RAISE EX_ERROR;
    END IF;

    --Obtenemos la Configuración de los bonos
    BEGIN
      PCLUB.PKG_CC_BONOS.ADMPSS_OBT_CONFIG(K_BONO,
                                           K_IDENT,
                                           V_DESCBONO,
                                           V_CODMSJSMS,
                                           K_CUR_BONOCONFIG,
                                           K_CODERROR,
                                           K_DESCERROR);
      V_MSJSMS := V_CODMSJSMS;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
        K_CODERROR  := -1;
        RAISE EX_ERROR;
    END;

    IF K_CODERROR <> 0 THEN
      RAISE EX_ERROR_OBT;
    ELSE

      --Obtenemos la configuración del Bono
      --Cursor de Configuración del Bono
      IF K_BONO IS NOT NULL AND K_IDENT IS NULL THEN
        OPEN K_CUR_BONO FOR
        SELECT G.ADMPV_DESCRIPCION PREMIO,
               BC.ADMPN_PUNTOS     PUNTOS,
               BC.ADMPN_DIASVIGEN  DIAS
        FROM PCLUB.ADMPT_BONO_CONFIG BC
         INNER JOIN PCLUB.ADMPT_BONO B
            ON BC.ADMPV_BONO = B.ADMPV_BONO
          LEFT OUTER JOIN PCLUB.ADMPT_GRUPO_TIPPREM G
            ON BC.ADMPV_COD_TPOPR = G.ADMPN_GRUPO
         WHERE B.ADMPV_BONO = K_BONO;
      ELSIF K_BONO IS NULL AND K_IDENT IS NOT NULL THEN
        OPEN K_CUR_BONO FOR
        SELECT G.ADMPV_DESCRIPCION PREMIO,
               BC.ADMPN_PUNTOS     PUNTOS,
               BC.ADMPN_DIASVIGEN  DIAS
          FROM PCLUB.ADMPT_BONO_CONFIG BC
         INNER JOIN PCLUB.ADMPT_BONO B
            ON BC.ADMPV_BONO = B.ADMPV_BONO
          LEFT OUTER JOIN PCLUB.ADMPT_GRUPO_TIPPREM G
            ON BC.ADMPV_COD_TPOPR = G.ADMPN_GRUPO
         WHERE B.ADMPN_ID_BONO_PRE = K_IDENT;
      END IF;

      --Validamos que la línea se encuentre registrada en ClaroClub
      SELECT COUNT(1)
        INTO V_EXISTE_CC
      FROM PCLUB.ADMPT_CLIENTE
      WHERE admpv_cod_cli = K_LINEA
         AND ADMPV_COD_TPOCL = 3
         AND admpc_estado = 'A';

      IF V_EXISTE_CC = 0 THEN
        --La línea no se encuentra en ClaroClub
        --Se procede a invocar al SP para registrar en ClaroClub
        V_LINEA := '51' || K_LINEA;
        PCLUB.PKG_CC_BONOS.ADMPSI_REG_LINEA(K_BONO,
                         K_IDENT,
                         K_USUARIO,
                         V_LINEA,
						 0,
                         V_EXITO,
                         V_TIPDOC,
                         V_NRODOC,
                         K_CODERROR,
                         K_DESCERROR);

        IF K_CODERROR <> 0 THEN
          RAISE EX_ERROR;
        END IF;
      ELSE
        --Verificamos si se el Cliente està configurado en la tabla Saldos Cliente
        SELECT NVL(COUNT(1), 0)
          INTO V_EXISTE_SLDO
        FROM PCLUB.ADMPT_SALDOS_CLIENTE S
        WHERE S.ADMPV_COD_CLI = K_LINEA;

        IF V_EXISTE_SLDO = 0 THEN
          INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE
            (ADMPN_ID_SALDO,
             ADMPV_COD_CLI,
             ADMPN_COD_CLI_IB,
             ADMPN_SALDO_CC,
             ADMPN_SALDO_IB,
             ADMPC_ESTPTO_CC,
             ADMPC_ESTPTO_IB,
             ADMPD_FEC_REG)
          VALUES
            (PCLUB.ADMPT_SLD_CL_SQ.NEXTVAL, K_LINEA, '', 0, 0, 'A', '', SYSDATE);

        END IF;

        --Obtenemos los datos del Cliente ClaroClub
        SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
          INTO V_TIPDOC, V_NRODOC
          FROM PCLUB.ADMPT_CLIENTE
         WHERE ADMPV_COD_CLI = K_LINEA
           AND ADMPC_ESTADO = 'A';
      END IF;

      --Ahora que ya existe en ClaroClub, se procede a entregar los puntos, para ello insertamos en el kárdex
      LOOP
        FETCH K_CUR_BONOCONFIG
          INTO V_BONO, V_PUNTOS, V_CONCEPTO, V_DIAS, V_TIPOPREM;
        EXIT WHEN K_CUR_BONOCONFIG%NOTFOUND;

        --Calculo la fecha de vencimiento:
        V_FECVCMTO := SYSDATE + V_DIAS;

        PCLUB.PKG_CC_BONOS.ADMPSI_ENTREGA_PTOS(K_LINEA,
                                               V_CONCEPTO,
                                               V_PUNTOS,
                                               V_FECVCMTO,
                                               V_TIPOPREM,
                                               '',
                                               K_USUARIO,
                                               V_IDKARDEX,
                                               V_CODERROR,
                                               V_DESCERROR);

        IF V_CODERROR = 0 THEN
          --Insertamos en la tabla histórica de Bono
          PCLUB.PKG_CC_BONOS.ADMPSI_REG_BONO_KARDEX(V_IDKARDEX,
                                                    V_BONO,
                                                    K_LINEA,
                                                    SYSDATE,
                                                    V_FECVCMTO,
                                                    V_PUNTOS,
                                                    V_DIAS,
                                                    V_TIPOPREM,
                                                    V_TIPDOC,
                                                    V_NRODOC,
                                                    K_USUARIO,
                                                    V_CODERROR_R,
                                                    V_DESCERROR_R);

          IF V_CODERROR_R <> 0 THEN
            K_CODERROR := V_CODERROR_R;
            RAISE EX_ERROR;
          END IF;
        ELSE
          K_CODERROR := V_CODERROR;
          RAISE EX_ERROR;
        END IF;

      END LOOP;
      CLOSE K_CUR_BONOCONFIG;

    END IF;

    --Obtengo el mensaje
    IF V_MSJSMS IS NOT NULL THEN
      SELECT NVL(ADMPV_DESCRIPCION, '')
        INTO K_MSJSMS
        FROM PCLUB.ADMPT_MENSAJE
       WHERE ADMPV_VALOR = V_MSJSMS;
    ELSE
      K_MSJSMS := '';
    END IF;

    BEGIN
      SELECT E.ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC E
       WHERE E.ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := '';
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
          K_DESCERROR := 'ERROR';
      END;
      OPEN K_CUR_BONO FOR
        SELECT '' PREMIO, '' PUNTOS, '' DIAS FROM DUAL;
      ROLLBACK;
    WHEN EX_ERROR_REG THEN
      BEGIN
        SELECT ADMPV_DES_ERROR
          INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_DESCERROR := 'ERROR';
      END;
      OPEN K_CUR_BONO FOR
        SELECT '' PREMIO, '' PUNTOS, '' DIAS FROM DUAL;
      ROLLBACK;
    WHEN EX_ERROR_OBT THEN
      K_CODERROR  := K_CODERROR;
      K_DESCERROR := K_DESCERROR;
      OPEN K_CUR_BONO FOR
        SELECT '' PREMIO, '' PUNTOS, '' DIAS FROM DUAL;
      ROLLBACK;
    WHEN NO_DATA_FOUND THEN
      K_CODERROR  := -1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
      OPEN K_CUR_BONO FOR
        SELECT '' PREMIO, '' PUNTOS, '' DIAS FROM DUAL;
      ROLLBACK;
    WHEN OTHERS THEN
      K_CODERROR  := -1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
      OPEN K_CUR_BONO FOR
        SELECT '' PREMIO, '' PUNTOS, '' DIAS FROM DUAL;
      ROLLBACK;

  END ADMPSI_ENTREGA_BONO;

PROCEDURE ADMPSI_REG_LINEA(K_BONO IN VARCHAR2,
                           K_IDENT IN NUMBER,
                           K_USUARIO   IN VARCHAR2,
                           K_NUM_LINEA  IN VARCHAR2,
                           K_PROC       IN NUMBER,
                           K_EXITOTRANS OUT NUMBER,
                           K_TIPDOC     OUT VARCHAR2,
                           K_NRODOC     OUT VARCHAR2,
                           K_CODERROR   OUT NUMBER,
                           K_DESCERROR  OUT VARCHAR2) IS

  V_EXISTE_DWH  NUMBER;
  V_EXISTE_SLDO NUMBER;
  V_TIPODOC     NUMBER;
  EX_ERROR EXCEPTION;

  V_NUM_LINEA  VARCHAR2(20);
  V_LINEA_CC   VARCHAR2(20);
  V_NOMBRES    VARCHAR2(100);
  V_APELLIDOS  VARCHAR2(100);
  V_TIP_DOC    VARCHAR2(50);
  V_NRO_DOC    VARCHAR2(50);
  V_IDDEPARTAM VARCHAR2(10);
  V_SEXO       VARCHAR2(20);
  V_FEC_ACT    VARCHAR2(20);
  V_DESCERROR  VARCHAR2(400);

BEGIN
  ------------------------------------------------
  --Inicializando las Variables de Retorno
  K_EXITOTRANS := 0;
  K_CODERROR   := 0;
  K_DESCERROR  := '';
  ------------------------------------------------

  --Validamos que el Cliente exista en DWH
  SELECT COUNT(C.MSISDN)
    INTO V_EXISTE_DWH
    FROM dm.ods_base_abonados@dbl_reptdm_d C
   WHERE C.MSISDN = K_NUM_LINEA
     AND C.IDSEGMENTO = 1
     AND C.IDPLATAFORMA = 1
     AND (C.IDESTADO = 2 OR C.IDESTADO = 3);

  IF V_EXISTE_DWH = 0 THEN
    IF K_PROC = 0 THEN
    --Se inserta en la tabla de errores:
      INSERT INTO PCLUB.ADMPT_BONOPREP_ERR
    (admpn_id,
     admpn_telef,
     admpn_id_bono_pre,
     admpv_coderr,
     admpv_descerr,
     admpd_fec_reg,
     admpv_usu_reg,
     admpv_bono)
  VALUES
    (PCLUB.ADMPT_BONOPREP_ERR_SQ.NEXTVAL,
     K_NUM_LINEA,
     K_IDENT,
     2,
     V_DESCERROR,
     SYSDATE,
     K_USUARIO,
     K_BONO);
     commit;
    END IF;
    --Se especifica en el mensaje de error que el Cliene no existe en DWH
    K_CODERROR := 2;
    RAISE EX_ERROR;
  ELSE
    --Se obtiene los datos de la Base de Abonados de DWH,
    --y se procede a insertar en ClaroClub
    SELECT BA.MSISDN,
           BA.NOMBRES,
           BA.APELLIDOS,
           BA.TIPO_DOCUMENTO,
           BA.NRO_DOCUMENTO,
           BA.IDDEPARTAMENTO,
           BA.SEXO,
           BA.FCH_ACTIVACION
      INTO V_NUM_LINEA,
           V_NOMBRES,
           V_APELLIDOS,
           V_TIP_DOC,
           V_NRO_DOC,
           V_IDDEPARTAM,
           V_SEXO,
           V_FEC_ACT
      FROM dm.ods_base_abonados@dbl_reptdm_d BA
     WHERE BA.MSISDN = K_NUM_LINEA
       AND BA.IDSEGMENTO = 1
       AND BA.IDPLATAFORMA = 1
       AND (BA.IDESTADO = 2 OR BA.IDESTADO = 3);

    -- Realizamos la conversión del tipo de documento
    SELECT NVL(ADMPV_COD_TPDOC, '')
      INTO V_TIPODOC
      FROM PCLUB.ADMPT_TIPO_DOC
     WHERE UPPER(ADMPV_EQU_DWH) = UPPER(V_TIP_DOC);

    --Obtenemos la línea que será ingresada a ClaroClub
    V_LINEA_CC := SUBSTR(K_NUM_LINEA, 3, 9);
    --Insertamos en la base de datos de ClaroClub
    INSERT INTO PCLUB.ADMPT_CLIENTE
      (ADMPV_COD_CLI,
       ADMPV_COD_SEGCLI,
       ADMPN_COD_CATCLI,
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
       ADMPV_CICL_FACT,
       ADMPC_ESTADO,
       ADMPV_COD_TPOCL,
       ADMPD_FEC_REG,
       ADMPV_USU_REG)
    VALUES
      (V_LINEA_CC,
       NULL,
       '2',
       V_TIPODOC,
       V_NRO_DOC,
       V_NOMBRES,
       V_APELLIDOS,
       V_SEXO,
       NULL,
       NULL,
       NULL,
       V_IDDEPARTAM,
       NULL,
       V_FEC_ACT,
       NULL,
       'A',
       '3',
       SYSDATE,
       'USR_ENT_BONO');
    --Insertamos el Saldo del Cliente

    SELECT NVL(COUNT(1), 0)
      INTO V_EXISTE_SLDO
      FROM PCLUB.ADMPT_SALDOS_CLIENTE S
     WHERE S.ADMPV_COD_CLI = V_LINEA_CC;

    IF V_EXISTE_SLDO = 0 THEN
      INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE
        (ADMPN_ID_SALDO,
         ADMPV_COD_CLI,
         ADMPN_COD_CLI_IB,
         ADMPN_SALDO_CC,
         ADMPN_SALDO_IB,
         ADMPC_ESTPTO_CC,
         ADMPC_ESTPTO_IB,
         ADMPD_FEC_REG)
      VALUES
        (PCLUB.ADMPT_SLD_CL_SQ.NEXTVAL, V_LINEA_CC, '', 0, 0, 'A', '', SYSDATE);
    ELSE
      UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
         SET ADMPN_SALDO_IB = 0, ADMPN_SALDO_CC = 0
       WHERE ADMPV_COD_CLI = K_NUM_LINEA;
    END IF;

    K_TIPDOC := V_TIPODOC;
    K_NRODOC := V_NRO_DOC;

  END IF;

  ------------------------------------------------
EXCEPTION
  WHEN EX_ERROR THEN
    K_DESCERROR := '';
  WHEN NO_DATA_FOUND THEN
    K_CODERROR  := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
  WHEN OTHERS THEN
    K_CODERROR  := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
    ------------------------------------------------
    IF K_CODERROR <> 0 THEN
      K_EXITOTRANS := 1;
    ELSE
      K_EXITOTRANS := 0;
    END IF;

END ADMPSI_REG_LINEA;

PROCEDURE ADMPSI_ENTREGA_PTOS(K_LINEA IN VARCHAR2,
                              K_CONCEPTO IN VARCHAR2,
                              K_PUNTOS IN VARCHAR2,
                              K_FECVENBONO IN DATE,
                              K_TIPPREMIO IN VARCHAR2,
                              K_NOMARCH IN VARCHAR2,
                              K_USUARIO IN VARCHAR2,
                              K_IDKARDEX OUT NUMBER,
                              K_CODERROR OUT NUMBER,
                              K_DESCERROR OUT VARCHAR2) IS

V_SALDO_BONO_SEQ NUMBER;
V_COUNT NUMBER;
EX_ERREXT EXCEPTION;
BEGIN
  --Inicializando las Variables de Retorno
  K_CODERROR  := 0;
  K_DESCERROR := '';

  --Insertamos en la tabla Kárdex
  PCLUB.PKG_CC_BONOS.ADMPSI_REG_KARDEX(K_LINEA,
                                       K_CONCEPTO,
                                       TRUNC(SYSDATE),
                                       K_PUNTOS,
                                       K_NOMARCH,
                                       'E',
                                       'B',
                                       K_PUNTOS,
                                       K_TIPPREMIO,
                                       '',
                                       K_FECVENBONO,
                                       'A',
                                       K_USUARIO,
                                       K_IDKARDEX,
                                       K_CODERROR,
                                       K_DESCERROR
                                       );

  IF K_CODERROR <> 0 THEN
    RAISE EX_ERREXT;
  END IF;

  --Valido si los puntos se entregarán para algún Tipo de Premio o aplica para cualquier Tipo de Premio
  IF K_TIPPREMIO = 0 THEN
    --Actualizo la tabla ADMPT_SALDOS_CLIENTE
    UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
    SET ADMPN_SALDO_CC = NVL(ADMPN_SALDO_CC,0) + NVL(K_PUNTOS, 0),
        ADMPC_ESTPTO_CC = 'A'
    WHERE ADMPV_COD_CLI = K_LINEA;
  ELSE
    --Verifico que el Cliente tenga Saldo en la tabla ADMPT_SALDOS_BONO_CLIENTE
    SELECT COUNT(1) INTO V_COUNT
    FROM PCLUB.ADMPT_SALDOS_BONO_CLIENTE
    WHERE ADMPV_COD_CLI = K_LINEA
          AND ADMPN_GRUPO = K_TIPPREMIO;

    IF V_COUNT = 0 THEN
      --Si no existe en la tabla ADMPT_SALDOS_BONO_CLIENTE, se inserta el registro
      PCLUB.PKG_CC_BONOS.ADMPSI_REG_SALDOS_BONO_CLIE(K_LINEA,
                                                     K_PUNTOS,
                                                     K_TIPPREMIO,
                                                     'A',
                                                     K_USUARIO,
                                                     V_SALDO_BONO_SEQ,
                                                     K_CODERROR,
                                                     K_DESCERROR
                                                     );

      IF K_CODERROR <> 0 THEN
        RAISE EX_ERREXT;
      END IF;
    ELSE
      --Si ya existe el registro, actualizo la tabla ADMPT_SALDOS_BONO_CLIENTE------
      UPDATE PCLUB.ADMPT_SALDOS_BONO_CLIENTE
      SET ADMPN_SALDO = NVL(ADMPN_SALDO,0) + NVL(K_PUNTOS, 0),
          ADMPV_ESTADO = 'A'
      WHERE ADMPV_COD_CLI = K_LINEA
            AND ADMPN_GRUPO = K_TIPPREMIO;
    END IF;
  END IF;

EXCEPTION
  WHEN EX_ERREXT THEN
    K_CODERROR := K_CODERROR;
    --ROLLBACK;
  WHEN OTHERS THEN
    K_CODERROR  := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
END ADMPSI_ENTREGA_PTOS;

PROCEDURE ADMPSI_AFILXREC(K_NOMARCH   IN VARCHAR2,
                          K_USUARIO   IN VARCHAR2,
                          K_NUMREGTOT OUT NUMBER,
                          K_NUMREGVAL OUT NUMBER,
                          K_NUMREGERR OUT NUMBER,
                          K_CODERROR  OUT NUMBER,
                          K_DESCERROR OUT VARCHAR2) IS

  CURSOR V_CUR_LINEAS(NOMARCH VARCHAR2) IS
    SELECT T.ADMPN_SEQ,
           T.ADMPV_LINEA,
           D.ADMPV_COD_TPDOC,
           T.ADMPV_NRO_DOCU,
           T.ADMPV_NOMBRES,
           T.ADMPV_APELLIDOS,
           T.ADMPV_SEXO,
           T.ADMPV_EST_CIVIL,
           T.ADMPV_EMAIL,
           T.ADMPV_DPTO,
           T.ADMPV_PROVINCIA,
           T.ADMPV_DISTRITO,
           T.ADMPD_FEC_ACTIVA
      FROM PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE T
     INNER JOIN PCLUB.ADMPT_TIPO_DOC D
        ON UPPER(T.ADMPV_TIPO_DOCU) = UPPER(D.ADMPV_EQU_DWH)
     WHERE T.ADMPV_NOMARCHIVO = NOMARCH
       AND T.ADMPV_CODERROR IS NULL;

  V_FECHASYS DATE := TRUNC(SYSDATE);
  V_CONT         NUMBER := 0;
  V_COUNT        NUMBER := 0;
  V_NUMREGCOMMIT NUMBER := 0;
  V_IDCLIENTE    VARCHAR2(100);
  V_IDSALDOSCLIE NUMBER;
  VC_SEC         NUMBER;
  VC_LINEA       VARCHAR2(50);
  VC_COD_TPDOC   VARCHAR2(50);
  VC_NRO_DOCU    VARCHAR2(50);
  VC_NOMBRES     VARCHAR2(50);
  VC_APELLIDOS   VARCHAR2(50);
  VC_SEXO        VARCHAR2(50);
  VC_EST_CIVIL   VARCHAR2(50);
  VC_EMAIL       VARCHAR2(50);
  VC_DPTO        VARCHAR2(50);
  VC_PROVINCIA   VARCHAR2(50);
  VC_DISTRITO    VARCHAR2(50);
  VC_FEC_ACTIVA  DATE;
  EX_ERROR_EX EXCEPTION;
  EX_ERROR_IN EXCEPTION;
  V_CODERROR   NUMBER;
  V_DESCERROR  VARCHAR2(200);
  V_CONTREGVAL NUMBER := 0;

BEGIN

  CASE
    WHEN K_NOMARCH IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'Ingrese el nombre del archivo.';
      RAISE EX_ERROR_IN;
    ELSE
      K_CODERROR  := 0;
      K_DESCERROR := '';
      K_NUMREGTOT := 0;
      K_NUMREGVAL := 0;
      K_NUMREGERR := 0;
  END CASE;

  BEGIN
    SELECT ADMPV_VALOR
      INTO V_NUMREGCOMMIT
      FROM PCLUB.ADMPT_PARAMSIST
     WHERE ADMPV_DESC = 'CANT_REG_COMMIT_PROC_MASIVO';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      K_CODERROR  := 50;
      K_DESCERROR := 'No está registrado el parámetro CANT_REG_COMMIT_PROC_MASIVO';
      K_NUMREGTOT := 0;
      K_NUMREGVAL := 0;
      K_NUMREGERR := 0;
      RAISE EX_ERROR_IN;
  END;

  PCLUB.PKG_CC_BONOS.ADMPSU_AFILXREC_VALIDA(K_NOMARCH, V_CODERROR, V_DESCERROR);

  IF V_CODERROR <> 0 THEN
    RAISE EX_ERROR_EX;
  END IF;

  --SE OBTIENE EL TOTAL DE REGISTROS CARGADOS
  SELECT COUNT(1)
    INTO K_NUMREGTOT
  FROM PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE
  WHERE ADMPV_NOMARCHIVO = K_NOMARCH;

  OPEN V_CUR_LINEAS(K_NOMARCH);
  V_COUNT := 0;
  FETCH V_CUR_LINEAS
    INTO VC_SEC,
         VC_LINEA,
         VC_COD_TPDOC,
         VC_NRO_DOCU,
         VC_NOMBRES,
         VC_APELLIDOS,
         VC_SEXO,
         VC_EST_CIVIL,
         VC_EMAIL,
         VC_DPTO,
         VC_PROVINCIA,
         VC_DISTRITO,
         VC_FEC_ACTIVA;

  V_COUNT := V_COUNT + 1;

  WHILE V_CUR_LINEAS%FOUND LOOP
    --Validamos que la línea se encuentre registrada en ClaroClub
    SELECT COUNT(1)
      INTO V_CONT
    FROM PCLUB.ADMPT_CLIENTE
    WHERE ADMPV_COD_CLI = VC_LINEA
       AND ADMPC_ESTADO = 'A';

    IF V_CONT = 0 THEN
      --Insertamos en la base de datos de ClaroClub
      PCLUB.PKG_CC_BONOS.ADMPSI_REG_CLIENTE(VC_LINEA,
                                            NULL,
                                            '2',
                                            VC_COD_TPDOC,
                                            VC_NRO_DOCU,
                                            VC_NOMBRES,
                                            VC_APELLIDOS,
                                            VC_SEXO,
                                            VC_EST_CIVIL,
                                            VC_EMAIL,
                                            VC_DPTO,
                                            VC_PROVINCIA,
                                            VC_DISTRITO,
                                            VC_FEC_ACTIVA,
                                            NULL,
                                            'A',
                                            '3',
                                            K_USUARIO,
                                            V_IDCLIENTE,
                                            K_CODERROR,
                                            K_DESCERROR);

      IF K_CODERROR = 0 THEN

        --Validamos que la línea se encuentre en saldos en ClaroClub
        SELECT COUNT(1)
        INTO V_CONT
        FROM PCLUB.ADMPT_SALDOS_CLIENTE
        WHERE ADMPV_COD_CLI = VC_LINEA;

        IF V_CONT = 0 THEN
          PCLUB.PKG_CC_BONOS.ADMPSI_REG_SALDOS_CLIE(VC_LINEA,
                                                    '',
                                                    0,
                                                    0,
                                                    'A',
                                                    '',
                                                    V_IDSALDOSCLIE,
                                                    K_CODERROR,
                                                    K_DESCERROR);

          IF K_CODERROR = 0 THEN
            UPDATE PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE T
            SET T.ADMPC_ESTADO = 'P'
            WHERE T.ADMPN_SEQ = VC_SEC;

            V_CONTREGVAL := V_CONTREGVAL + 1;
          END IF;
        ELSE
          UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
          SET ADMPN_SALDO_IB = 0, ADMPN_SALDO_CC = 0
          WHERE ADMPV_COD_CLI = VC_LINEA;

          UPDATE PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE T
          SET T.ADMPC_ESTADO = 'P'
          WHERE T.ADMPN_SEQ = VC_SEC;

          V_CONTREGVAL := V_CONTREGVAL + 1;
        END IF;

      END IF;

    ELSE
      --Si el Cliente ya existe en CC, se actualiza con el mensaje que el Cliente ya se encuentra registrado en ClaroClub
      UPDATE PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE T
         SET T.ADMPV_CODERROR = 3,
             T.ADMPV_MSJERROR = 'El Cliente ya existe en ClaroClub.'
       WHERE T.ADMPN_SEQ = VC_SEC;
    END IF;

    IF V_COUNT = V_NUMREGCOMMIT THEN
	INSERT INTO PCLUB.ADMPT_IMP_ALTA_XRECARGA_PRE
        (ADMPN_SEQ,
         ADMPV_NOMARCHIVO,
         ADMPV_LINEA,
         ADMPV_TIPO_DOCU,
         ADMPV_NRO_DOCU,
         ADMPV_NOMBRES,
         ADMPV_APELLIDOS,
         ADMPV_SEXO,
         ADMPV_EST_CIVIL,
         ADMPV_EMAIL,
         ADMPV_DPTO,
         ADMPV_PROVINCIA,
         ADMPV_DISTRITO,
         ADMPD_FEC_ACTIVA,
         ADMPC_ESTADO,
         ADMPC_ESTADOSMS,
         ADMPD_FEC_OPERA,
         ADMPD_FEC_REG,
         ADMPD_USU_REG)
        SELECT PCLUB.ADMPT_IMP_ALTA_XRECARGA_PRE_SQ.NEXTVAL,
               ADMPV_NOMARCHIVO,
               ADMPV_LINEA,
               ADMPV_TIPO_DOCU,
               ADMPV_NRO_DOCU,
               ADMPV_NOMBRES,
               ADMPV_APELLIDOS,
               ADMPV_SEXO,
               ADMPV_EST_CIVIL,
               ADMPV_EMAIL,
               ADMPV_DPTO,
               ADMPV_PROVINCIA,
               ADMPV_DISTRITO,
               ADMPD_FEC_ACTIVA,
               'P',
               'P',
               V_FECHASYS,
               SYSDATE,
               K_USUARIO
        FROM PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE
        WHERE ADMPV_NOMARCHIVO = K_NOMARCH
			  AND ADMPC_ESTADO = 'P';

	DELETE PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE
	WHERE ADMPV_NOMARCHIVO = K_NOMARCH
	      AND ADMPC_ESTADO = 'P';

      COMMIT;
      V_COUNT := 0;
    END IF;
    V_COUNT := V_COUNT + 1;

    FETCH V_CUR_LINEAS
      INTO VC_SEC,
           VC_LINEA,
           VC_COD_TPDOC,
           VC_NRO_DOCU,
           VC_NOMBRES,
           VC_APELLIDOS,
           VC_SEXO,
           VC_EST_CIVIL,
           VC_EMAIL,
           VC_DPTO,
           VC_PROVINCIA,
           VC_DISTRITO,
           VC_FEC_ACTIVA;
  END LOOP;

  -- insertamos todos aquellos registros procesados
  INSERT INTO PCLUB.ADMPT_IMP_ALTA_XRECARGA_PRE
    (ADMPN_SEQ,
     ADMPV_NOMARCHIVO,
     ADMPV_LINEA,
     ADMPV_TIPO_DOCU,
     ADMPV_NRO_DOCU,
     ADMPV_NOMBRES,
     ADMPV_APELLIDOS,
     ADMPV_SEXO,
     ADMPV_EST_CIVIL,
     ADMPV_EMAIL,
     ADMPV_DPTO,
     ADMPV_PROVINCIA,
     ADMPV_DISTRITO,
     ADMPD_FEC_ACTIVA,
     ADMPC_ESTADO,
     ADMPC_ESTADOSMS,
     ADMPV_CODERROR,
     ADMPV_MSJERROR,
     ADMPD_FEC_OPERA,
     ADMPD_FEC_REG,
     ADMPD_USU_REG)
    SELECT PCLUB.ADMPT_IMP_ALTA_XRECARGA_PRE_SQ.NEXTVAL,
           ADMPV_NOMARCHIVO,
           ADMPV_LINEA,
           ADMPV_TIPO_DOCU,
           ADMPV_NRO_DOCU,
           ADMPV_NOMBRES,
           ADMPV_APELLIDOS,
           ADMPV_SEXO,
           ADMPV_EST_CIVIL,
           ADMPV_EMAIL,
           ADMPV_DPTO,
           ADMPV_PROVINCIA,
           ADMPV_DISTRITO,
           ADMPD_FEC_ACTIVA,
           'P',
           'P',
           ADMPV_CODERROR,
           ADMPV_MSJERROR,
           V_FECHASYS,
           SYSDATE,
           K_USUARIO
    FROM PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE
    WHERE ADMPV_NOMARCHIVO = K_NOMARCH
          AND ADMPC_ESTADO = 'P';

    DELETE FROM PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE
    WHERE ADMPV_NOMARCHIVO = K_NOMARCH
		  AND ADMPC_ESTADO = 'P';

  -- insertamos los registros erróneos
  INSERT INTO PCLUB.ADMPT_IMP_ALTA_XRECARGA_PRE
    (ADMPN_SEQ,
     ADMPV_NOMARCHIVO,
     ADMPV_LINEA,
     ADMPV_TIPO_DOCU,
     ADMPV_NRO_DOCU,
     ADMPV_NOMBRES,
     ADMPV_APELLIDOS,
     ADMPV_SEXO,
     ADMPV_EST_CIVIL,
     ADMPV_EMAIL,
     ADMPV_DPTO,
     ADMPV_PROVINCIA,
     ADMPV_DISTRITO,
     ADMPD_FEC_ACTIVA,
     ADMPV_CODERROR,
     ADMPV_MSJERROR,
     ADMPD_FEC_OPERA,
     ADMPD_FEC_REG,
     ADMPD_USU_REG)
    SELECT PCLUB.ADMPT_IMP_ALTA_XRECARGA_PRE_SQ.NEXTVAL,
           ADMPV_NOMARCHIVO,
           ADMPV_LINEA,
           ADMPV_TIPO_DOCU,
           ADMPV_NRO_DOCU,
           ADMPV_NOMBRES,
           ADMPV_APELLIDOS,
           ADMPV_SEXO,
           ADMPV_EST_CIVIL,
           ADMPV_EMAIL,
           ADMPV_DPTO,
           ADMPV_PROVINCIA,
           ADMPV_DISTRITO,
           ADMPD_FEC_ACTIVA,
           ADMPV_CODERROR,
           ADMPV_MSJERROR,
           V_FECHASYS,
           SYSDATE,
           K_USUARIO
    FROM PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE
    WHERE ADMPV_NOMARCHIVO = K_NOMARCH
          AND ADMPV_CODERROR IS NOT NULL;

  --SE OBTIENE LOS VALORES K_NUMREGVAL Y K_NUMREGERR
  K_NUMREGVAL := V_CONTREGVAL;
  --Obtenemos el numero de registros errados
  SELECT COUNT(1)
    INTO K_NUMREGERR
    FROM PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE
   WHERE ADMPV_NOMARCHIVO = K_NOMARCH
     AND ADMPV_CODERROR IS NOT NULL;

  --K_NUMREGERR := K_NUMREGERR + V_NUMREGERR;

  DELETE PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE WHERE ADMPV_NOMARCHIVO = K_NOMARCH;

  COMMIT;

  CLOSE V_CUR_LINEAS;

EXCEPTION
  WHEN EX_ERROR_IN THEN
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
      ROLLBACK;
    END;

  WHEN EX_ERROR_EX THEN
    BEGIN
      K_CODERROR  := V_CODERROR;
      K_DESCERROR := V_DESCERROR;
      ROLLBACK;
    END;
  WHEN OTHERS THEN
    K_CODERROR  := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
    ROLLBACK;
END ADMPSI_AFILXREC;

PROCEDURE ADMPSU_AFILXREC_VALIDA(K_NOMBARCH  IN VARCHAR2,
                                 K_CODERROR  OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2) IS

  V_TIPODOCDNI CHAR(1) := '2';
  EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_NOMBARCH IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'Ingrese el nombre del archivo.';
      RAISE EX_ERROR;
    ELSE
      K_CODERROR  := 0;
      K_DESCERROR := '';
  END CASE;

  --SE LE ASIGNA EL ERROR SI LA LINEA NO TIENE 9 DÍGITOS
  UPDATE PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE
     SET ADMPV_CODERROR = 1,
         ADMPV_MSJERROR = 'La línea no tiene 9 dígitos.'
   WHERE ADMPV_NOMARCHIVO = K_NOMBARCH
     AND ADMPV_CODERROR IS NULL
     AND LENGTH(TRIM(ADMPV_LINEA)) <> 9;

  --SE LE ASIGNA EL ERROR SI LA LÍNEA NO ES NUMÉRICA
  UPDATE PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE
     SET ADMPV_CODERROR = 2, ADMPV_MSJERROR = 'La línea no es numérico.'
   WHERE ADMPV_NOMARCHIVO = K_NOMBARCH
     AND ADMPV_CODERROR IS NULL
     AND LENGTH(TRIM(TRANSLATE(ADMPV_LINEA, '0123456789', ' '))) > 0;

  --SE LE ASIGNA EL ERROR SI NO EXISTEN DATOS OBLIGATORIOS
  UPDATE PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE
     SET ADMPV_CODERROR = 3,
         ADMPV_MSJERROR = 'La línea, el tipo de documento o el número de documento no fueron ingresados.'
   WHERE ADMPV_NOMARCHIVO = K_NOMBARCH
     AND ADMPV_CODERROR IS NULL
     AND ADMPV_LINEA IS NULL
      OR ADMPV_TIPO_DOCU IS NULL
      OR ADMPV_NRO_DOCU IS NULL;

  --SE LE ASIGNA EL ERROR SI EL TIPO DE DOCUMENTO NO EXISTE EN CLAROCLUB
  MERGE INTO PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE I
  USING (SELECT T.ADMPN_SEQ
           FROM PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE T
           LEFT JOIN PCLUB.ADMPT_TIPO_DOC D
             ON UPPER(T.ADMPV_TIPO_DOCU) = UPPER(D.ADMPV_EQU_DWH)
          WHERE ADMPV_NOMARCHIVO = K_NOMBARCH
            AND ADMPV_CODERROR IS NULL
            AND D.ADMPV_EQU_DWH IS NULL) Q
  ON (I.ADMPN_SEQ = Q.ADMPN_SEQ)
  WHEN MATCHED THEN
    UPDATE
       SET I.ADMPV_CODERROR = 5,
           I.ADMPV_MSJERROR = 'El tipo de documento no existe en CLAROCLUB.';

  --SE LE ASIGNA EL ERROR SI EL TIPO DE DOCUMENTO ES DNI PERO NO TIENE 8 DIGITOS
  MERGE INTO PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE I
  USING (SELECT T.ADMPN_SEQ
           FROM PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE T
          INNER JOIN PCLUB.ADMPT_TIPO_DOC D
             ON UPPER(T.ADMPV_TIPO_DOCU) = UPPER(D.ADMPV_EQU_DWH)
            AND D.ADMPV_COD_TPDOC = V_TIPODOCDNI
          WHERE ADMPV_NOMARCHIVO = K_NOMBARCH
            AND ADMPV_CODERROR IS NULL
            AND LENGTH(RTRIM(T.ADMPV_NRO_DOCU)) <> 8) Q
  ON (I.ADMPN_SEQ = Q.ADMPN_SEQ)
  WHEN MATCHED THEN
    UPDATE
       SET I.ADMPV_CODERROR = 6,
           I.ADMPV_MSJERROR = 'El tipo de documento es DNI pero no tiene 8 dígitos.';

  --SE LE ASIGNA EL ERROR SI EL TIPO DE DOCUMENTO ES DNI PERO NO ES NUMÉRICO
  MERGE INTO PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE I
  USING (SELECT T.ADMPN_SEQ
           FROM PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE T
          INNER JOIN PCLUB.ADMPT_TIPO_DOC D
             ON UPPER(T.ADMPV_TIPO_DOCU) = UPPER(D.ADMPV_EQU_DWH)
            AND D.ADMPV_COD_TPDOC = V_TIPODOCDNI
          WHERE ADMPV_NOMARCHIVO = K_NOMBARCH
            AND ADMPV_CODERROR IS NULL
            AND LENGTH(TRIM(TRANSLATE(T.ADMPV_NRO_DOCU, '0123456789', ' '))) > 0) Q
  ON (I.ADMPN_SEQ = Q.ADMPN_SEQ)
  WHEN MATCHED THEN
    UPDATE
       SET I.ADMPV_CODERROR = 7,
           I.ADMPV_MSJERROR = 'El tipo de documento es DNI pero no es numérico.';

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
    K_CODERROR  := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 200);
    ROLLBACK;
END ADMPSU_AFILXREC_VALIDA;

PROCEDURE ADMPSS_TMP_AFILXREC(K_NOMBARCH  IN VARCHAR2,
                              K_NUMREG    OUT NUMBER,
                              K_CODERROR  OUT NUMBER,
                              K_DESCERROR OUT VARCHAR2) IS
  EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_NOMBARCH IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'Ingrese el nombre del archivo.';
      RAISE EX_ERROR;
    ELSE
      K_CODERROR  := 0;
      K_DESCERROR := '';
  END CASE;

  SELECT COUNT(1)
    INTO K_NUMREG
    FROM PCLUB.ADMPT_TMP_ALTA_XRECARGA_PRE
   WHERE ADMPV_NOMARCHIVO = K_NOMBARCH;

EXCEPTION
  WHEN EX_ERROR THEN
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'Ocurrió un error en el SP ADMPSS_TMP_AFILXREC. ';
    END;
  WHEN OTHERS THEN
    K_CODERROR  := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSS_TMP_AFILXREC;

PROCEDURE ADMPSS_TMP_EAFILXREC(K_NOMARCH IN VARCHAR2,
                                    K_CUR_LISTA OUT SYS_REFCURSOR,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_NOMARCH   IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el nombre del archivo.'; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  OPEN K_CUR_LISTA FOR
  SELECT ADMPN_SEQ,
         ADMPV_LINEA,
         ADMPV_CODERROR,
         ADMPV_MSJERROR
  FROM PCLUB.ADMPT_IMP_ALTA_XRECARGA_PRE
  WHERE ADMPV_NOMARCHIVO = K_NOMARCH
        AND ADMPV_CODERROR IS NOT NULL;

EXCEPTION
  WHEN EX_ERROR THEN
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR EN SP ADMPSS_TMP_EAFILXREC. ';
    END;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSS_TMP_EAFILXREC;

--****************************************************************
-- Nombre SP           :  ADMPSS_OBT_CONFIG
-- Propósito           :  Lista registros de tabla ADMPT_BONO_CONFIG
-- Input               :  K_BONO          --Código de bono
--                     :  K_IDENT         --Identificador de bono
-- Output              :  K_DESCBONO      --Descripción de bono
--                        K_CODMSJSMS     --Mensaje de bono
--                        K_CUR_BONOCONFIG--Cursor de configuración
--                        K_CODERROR      --Código de error o éxito
--                        K_DESCERROR     --Descripción del error
-- Creado por          :  Oscar Paucar Pérez
-- Fec Creación        :  30/07/2013
-- Fec Actualización   :
--****************************************************************
PROCEDURE ADMPSS_OBT_CONFIG(K_BONO IN VARCHAR2,
                            K_IDENT IN NUMBER,
                            K_DESCBONO OUT VARCHAR2,
                            K_CODMSJSMS OUT VARCHAR2,
                            K_CUR_BONOCONFIG OUT SYS_REFCURSOR,
                            K_CODERROR OUT NUMBER,
                            K_DESCERROR OUT VARCHAR2) IS

V_CONTADOR NUMBER;
V_BONO VARCHAR2(20);
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_BONO IS NULL AND K_IDENT IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el identificador o descripción del bono.'; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  IF K_IDENT IS NOT NULL AND K_BONO IS NULL THEN
    --Se envió el ID Bono(Bonos de Alta)
    --Ahora, validamos que se haya enviado un Identificador de Bono válido
    SELECT COUNT(1) INTO V_CONTADOR
    FROM PCLUB.ADMPT_BONO B
    WHERE ADMPN_ID_BONO_PRE = K_IDENT;

    IF V_CONTADOR = 0 THEN
      K_CODERROR := 4;
      K_DESCERROR := 'Ingrese un identificador válido de Bono.';
      RAISE EX_ERROR;
    END IF;

    SELECT ADMPV_BONO, ADMPV_DESCBONO, ADMPV_MENSAJE
    INTO V_BONO, K_DESCBONO, K_CODMSJSMS
    FROM PCLUB.ADMPT_BONO
    WHERE ADMPN_ID_BONO_PRE = K_IDENT;
  END IF;

  IF K_BONO IS NOT NULL AND K_IDENT IS NULL THEN
    --Se envió la descripción del Bono(Bonos de Fidelidad)
    --Ahora, validamos que se haya enviado una descripción de Bono válida
    SELECT COUNT(1) INTO V_CONTADOR
    FROM PCLUB.ADMPT_BONO
    WHERE ADMPV_BONO = K_BONO;

    IF V_CONTADOR = 0 THEN
      K_CODERROR := 4;
      K_DESCERROR := 'Ingrese una descripción válida de Bono.';
      RAISE EX_ERROR;
    END IF;

    SELECT ADMPV_BONO, ADMPV_DESCBONO, ADMPV_MENSAJE
    INTO V_BONO, K_DESCBONO, K_CODMSJSMS
    FROM PCLUB.ADMPT_BONO
    WHERE ADMPV_BONO = K_BONO;
  END IF;

  IF V_BONO IS NOT NULL THEN
  --Cursor de Configuración del Bono
  OPEN K_CUR_BONOCONFIG FOR
  SELECT BC.ADMPV_BONO,
         BC.ADMPN_PUNTOS,
         BC.ADMPV_COD_CPTO,
         BC.ADMPN_DIASVIGEN,
         BC.ADMPV_COD_TPOPR
  FROM PCLUB.ADMPT_BONO_CONFIG BC
  WHERE BC.ADMPV_BONO = V_BONO;
  ELSE
    K_CODERROR  := 4;
    K_DESCERROR := 'El identificador de Bono ingresado, no se encuentra configurado.';
    RAISE EX_ERROR;
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
        K_DESCERROR := 'ERROR EN SP ADMPSS_OBT_CONFIG. ';
    END;
    OPEN K_CUR_BONOCONFIG FOR
    SELECT '' ADMPV_BONO,
           '' ADMPN_PUNTOS,
           '' ADMPV_COD_CPTO,
           '' ADMPN_DIASVIGEN,
           '' ADMPV_COD_TPOPR
    FROM DUAL
    WHERE 1 = 0;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    OPEN K_CUR_BONOCONFIG FOR
    SELECT '' ADMPV_BONO,
           '' ADMPN_PUNTOS,
           '' ADMPV_COD_CPTO,
           '' ADMPN_DIASVIGEN,
           '' ADMPV_COD_TPOPR
    FROM DUAL
    WHERE 1 = 0;
END ADMPSS_OBT_CONFIG;

--****************************************************************
-- Nombre SP           :  ADMPSI_REG_BONO_KARDEX
-- Propósito           :  Registra en tabla ADMPT_BONO_KARDEX
-- Input               :  K_KARDEX     --Código de Kardex
--                        K_BONO       --Código de bono
--                        K_LINEA      --Número de línea
--                        K_FECENTBONO --Fecha entrega de bono
--                        K_FECVENBONO --Fecha de vencimiento de bono
--                        K_PUNTOS     --Puntos
--                        K_DIAS       --Dias de vigencia
--                        K_TIPPREMIO  --Tipo de premio
--                        K_TIPDOC     --Tipo de documento
--                        K_NRODOC     --Número de documento
--                        K_USUARIO    --Usuario de proceso
-- Output              :  K_CODERROR   --Código de error o éxito
--                        K_DESCERROR  --Descripción del error
-- Creado por          :  Oscar Paucar Pérez
-- Fec Creación        :  30/07/2013
-- Fec Actualización   :
--****************************************************************
PROCEDURE ADMPSI_REG_BONO_KARDEX(K_KARDEX IN VARCHAR2,
                                 K_BONO IN VARCHAR2,
                                 K_LINEA IN VARCHAR2,
                                 K_FECENTBONO IN DATE,
                                 K_FECVENBONO IN DATE,
                                 K_PUNTOS IN NUMBER,
                                 K_DIAS IN NUMBER,
                                 K_TIPPREMIO IN VARCHAR2,
                                 K_TIPDOC IN VARCHAR2,
                                 K_NRODOC IN VARCHAR2,
                                 K_USUARIO IN VARCHAR2,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2) IS
BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';

  INSERT INTO PCLUB.ADMPT_BONO_KARDEX
  (
    ADMPN_ID_KARDEX,
    ADMPV_BONO,
    ADMPV_LINEA,
    ADMPD_FEC_ENTBONO,
    ADMPD_FEC_VENCBONO,
    ADMPN_PUNTOS,
    ADMPN_DIASVIGEN,
    ADMPV_COD_TPOPR,
    ADMPV_TIPO_DOC,
    ADMPV_NUM_DOC,
    ADMPV_USU_REG
  )
  VALUES
  (
    K_KARDEX,
    K_BONO,
    K_LINEA,
    K_FECENTBONO,
    K_FECVENBONO,
    K_PUNTOS,
    K_DIAS,
    K_TIPPREMIO,
    K_TIPDOC,
    K_NRODOC,
    K_USUARIO
  );

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_REG_BONO_KARDEX;

--****************************************************************
-- Nombre SP           :  ADMPSU_ENT_BONOFIDEL_VALIDA
-- Propósito           :  Validaciones del proceso de entrega de bonos por fidelidad
-- Input               :  K_TIPOFIDEL  --(M):6meses (A):12meses
--                        K_NOMBARCH  --Nombre del archivo
-- Output              :  K_CODERROR  --Código de error o éxito
--                        K_DESCERROR --Descripción del error
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  24/07/2013
-- Fec Actualización   :
--****************************************************************
PROCEDURE ADMPSU_ENT_BONOFIDEL_VALIDA(K_TIPOFIDEL IN VARCHAR2,
                                      K_NOMBARCH IN VARCHAR2,
                                      K_CODERROR OUT NUMBER,
                                      K_DESCERROR OUT VARCHAR2) IS

V_TIPODOCDNI CHAR(1) := '2';
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_TIPOFIDEL IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el tipo de bono de fidelidad.'; RAISE EX_ERROR;
    WHEN K_NOMBARCH  IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el nombre del archivo.'; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  --SE LE ASIGNA EL ERROR SI LA LINEA NO TIENE 9 DIGITOS
  /*UPDATE PCLUB.ADMPT_TMP_BONOFIDEL_PRE
  SET ADMPV_CODERROR = 1,
      ADMPV_MSJERROR = 'La línea no tiene 9 dígitos.'
  WHERE ADMPC_TIPO_FIDEL = K_TIPOFIDEL
        AND ADMPV_NOMARCHIVO = K_NOMBARCH
        AND ADMPV_CODERROR IS NULL
        AND LENGTH(TRIM(ADMPV_LINEA)) <> 9;*/

  --SE LE ASIGNA EL ERROR SI LA LINEA NO ES NUMERICO
  /*UPDATE PCLUB.ADMPT_TMP_BONOFIDEL_PRE
  SET ADMPV_CODERROR = 2,
      ADMPV_MSJERROR = 'La línea no es numérico.'
  WHERE ADMPC_TIPO_FIDEL = K_TIPOFIDEL
        AND ADMPV_NOMARCHIVO = K_NOMBARCH
        AND ADMPV_CODERROR IS NULL
        AND LENGTH(TRIM(TRANSLATE(ADMPV_LINEA,'0123456789',' '))) > 0;*/

  --SE LE ASIGNA EL ERROR SI NO EXISTEN DATOS OBLIGATORIOS
  UPDATE PCLUB.ADMPT_TMP_BONOFIDEL_PRE
  SET ADMPV_CODERROR = 3,
      ADMPV_MSJERROR = 'La línea, el tipo de documento o el número de documento no fueron ingresados.'
  WHERE ADMPC_TIPO_FIDEL = K_TIPOFIDEL
        AND ADMPV_NOMARCHIVO = K_NOMBARCH
        AND ADMPV_CODERROR IS NULL
        AND (ADMPV_LINEA IS NULL OR ADMPV_TIPO_DOCU IS NULL OR ADMPV_NRO_DOCU IS NULL);

  --SE LE ASIGNA EL ERROR SI EL TIPO DE DOCUMENTO NO EXISTE EN CLAROCLUB
  MERGE INTO PCLUB.ADMPT_TMP_BONOFIDEL_PRE I
  USING (SELECT T.ADMPN_SEC
         FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE T
         LEFT JOIN PCLUB.ADMPT_TIPO_DOC D ON UPPER(T.ADMPV_TIPO_DOCU) = UPPER(D.ADMPV_EQU_DWH)
         WHERE T.ADMPC_TIPO_FIDEL = K_TIPOFIDEL
               AND T.ADMPV_NOMARCHIVO = K_NOMBARCH
               AND T.ADMPV_CODERROR IS NULL
               AND D.ADMPV_EQU_DWH IS NULL
         ) Q
  ON (I.ADMPN_SEC = Q.ADMPN_SEC)
  WHEN MATCHED THEN
    UPDATE
      SET I.ADMPV_CODERROR = 4,
          I.ADMPV_MSJERROR = 'El tipo de documento no existe en CLAROCLUB.';

  --SE LE ASIGNA EL ERROR SI EL TIPO DE DOCUMENTO ES DNI PERO NO TIENE 8 DIGITOS
  /*MERGE INTO PCLUB.ADMPT_TMP_BONOFIDEL_PRE I
  USING (SELECT T.ADMPN_SEC
         FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE T
         INNER JOIN PCLUB.ADMPT_TIPO_DOC D ON UPPER(T.ADMPV_TIPO_DOCU) = UPPER(D.ADMPV_EQU_DWH)
                                        AND D.ADMPV_COD_TPDOC = V_TIPODOCDNI
         WHERE T.ADMPC_TIPO_FIDEL = K_TIPOFIDEL
               AND T.ADMPV_NOMARCHIVO = K_NOMBARCH
               AND T.ADMPV_CODERROR IS NULL
               AND LENGTH(RTRIM(T.ADMPV_NRO_DOCU)) <> 8
         ) Q
  ON (I.ADMPN_SEC = Q.ADMPN_SEC)
  WHEN MATCHED THEN
    UPDATE
      SET I.ADMPV_CODERROR = 5,
          I.ADMPV_MSJERROR = 'El tipo de documento es DNI pero no tiene 8 dígitos.';*/

  --SE LE ASIGNA EL ERROR SI EL TIPO DE DOCUMENTO ES DNI PERO NO ES NUMERICO
  /*MERGE INTO PCLUB.ADMPT_TMP_BONOFIDEL_PRE I
  USING (SELECT T.ADMPN_SEC
         FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE T
         INNER JOIN PCLUB.ADMPT_TIPO_DOC D ON UPPER(T.ADMPV_TIPO_DOCU) = UPPER(D.ADMPV_EQU_DWH)
                                        AND D.ADMPV_COD_TPDOC = V_TIPODOCDNI
         WHERE T.ADMPC_TIPO_FIDEL = K_TIPOFIDEL
               AND T.ADMPV_NOMARCHIVO = K_NOMBARCH
               AND T.ADMPV_CODERROR IS NULL
               AND LENGTH(TRIM(TRANSLATE(T.ADMPV_NRO_DOCU,'0123456789',' '))) > 0
         ) Q
  ON (I.ADMPN_SEC = Q.ADMPN_SEC)
  WHEN MATCHED THEN
    UPDATE
      SET I.ADMPV_CODERROR = 6,
          I.ADMPV_MSJERROR = 'El tipo de documento es DNI pero no es numérico.';*/

  COMMIT;

  --SE LE ASIGNA EL ERROR SI YA SE LE HA ASIGNADO PUNTOS EN ESE PERIODO
  MERGE INTO PCLUB.ADMPT_TMP_BONOFIDEL_PRE I
  USING (SELECT T.ADMPN_SEC
         FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE T
         INNER JOIN PCLUB.ADMPT_KARDEX K ON T.ADMPV_LINEA = K.ADMPV_COD_CLI
                                      AND T.ADMPV_NOMARCHIVO = K.ADMPV_NOM_ARCH
                                      AND K.ADMPC_TPO_OPER = 'E'
                                      AND K.ADMPC_TPO_PUNTO = 'B'
                                      AND K.ADMPC_ESTADO = 'A'
         WHERE T.ADMPC_TIPO_FIDEL = K_TIPOFIDEL
               AND T.ADMPV_NOMARCHIVO = K_NOMBARCH
               AND T.ADMPV_CODERROR IS NULL
         GROUP BY T.ADMPN_SEC
         ) Q
  ON (I.ADMPN_SEC = Q.ADMPN_SEC)
  WHEN MATCHED THEN
    UPDATE
      SET I.ADMPV_CODERROR = 7,
          I.ADMPV_MSJERROR = 'Ya se le asignó puntos a la línea.';

COMMIT;
  --SE LE ASIGNA EL ERROR SI SE DUPLICA LA LINEA EN EL ARCHIVO
  MERGE INTO PCLUB.ADMPT_TMP_BONOFIDEL_PRE I
  USING (SELECT T.ADMPV_LINEA, MIN(T.ADMPN_SEC) AS ADMPN_SEC
         FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE T
         WHERE T.ADMPC_TIPO_FIDEL = K_TIPOFIDEL
               AND T.ADMPV_NOMARCHIVO = K_NOMBARCH
               AND T.ADMPV_CODERROR IS NULL
         GROUP BY T.ADMPV_LINEA
         HAVING COUNT(T.ADMPN_SEC) > 1
         ) Q
  ON (I.ADMPN_SEC = Q.ADMPN_SEC)
  WHEN MATCHED THEN
    UPDATE
      SET I.ADMPV_CODERROR = 8,
          I.ADMPV_MSJERROR = 'La línea se duplicó en el archivo.';

  COMMIT;

  --SE LE ASIGNA EL ERROR SI NO COINCIDE EL NUMERO DE DOCUMENTO
  MERGE INTO PCLUB.ADMPT_TMP_BONOFIDEL_PRE I
  USING (SELECT T.ADMPN_SEC
         FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE T
         INNER JOIN PCLUB.ADMPT_CLIENTE C ON T.ADMPV_LINEA = C.ADMPV_COD_CLI
         WHERE T.ADMPC_TIPO_FIDEL = K_TIPOFIDEL
               AND T.ADMPV_NOMARCHIVO = K_NOMBARCH
               AND T.ADMPV_CODERROR IS NULL
               AND T.ADMPV_NRO_DOCU <> C.ADMPV_NUM_DOC
         ) Q
  ON (I.ADMPN_SEC = Q.ADMPN_SEC)
  WHEN MATCHED THEN
    UPDATE
      SET ADMPV_CODERROR = 9,
          ADMPV_MSJERROR = 'El número de documento del archivo no es correcto.';

  COMMIT;

  --SE LE ASIGNA EL ERROR SI NO COINCIDE EL TIPO DE DOCUMENTO
  MERGE INTO PCLUB.ADMPT_TMP_BONOFIDEL_PRE I
  USING (SELECT T.ADMPN_SEC
         FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE T
         INNER JOIN PCLUB.ADMPT_CLIENTE C ON T.ADMPV_LINEA = C.ADMPV_COD_CLI
         INNER JOIN PCLUB.ADMPT_TIPO_DOC D ON UPPER(T.ADMPV_TIPO_DOCU) = UPPER(D.ADMPV_EQU_DWH)
         WHERE T.ADMPC_TIPO_FIDEL = K_TIPOFIDEL
               AND T.ADMPV_NOMARCHIVO = K_NOMBARCH
               AND T.ADMPV_CODERROR IS NULL
               AND C.ADMPV_TIPO_DOC <> D.ADMPV_COD_TPDOC
         ) Q
  ON (I.ADMPN_SEC = Q.ADMPN_SEC)
  WHEN MATCHED THEN
    UPDATE
      SET ADMPV_CODERROR = 10,
          ADMPV_MSJERROR = 'El tipo de documento del archivo no es correcto.';

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
        K_CODERROR := SQLCODE;
        K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    END;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 200);
    ROLLBACK;
END ADMPSU_ENT_BONOFIDEL_VALIDA;

--****************************************************************
-- Nombre SP           :  ADMPSI_ENTR_BONOFID6M
-- Propósito           :  Entregar los bonos de puntos Fidelidad 6M
-- Input               :  K_NOMARCH   --Nombre del archivo
--                        K_BONO      --Código del bono
--                        K_USUARIO   --Usuario de proceso
-- Output              :  K_CODERROR  --Código de error o éxito
--                        K_DESCERROR --Descripción del error
-- Creado por          :  Oscar Paucar Pérez
-- Fec Creación        :  24/07/2013
-- Fec Actualización   :
--****************************************************************
PROCEDURE ADMPSI_ENTR_BONOFID6M(K_NOMARCH IN VARCHAR2,
                                K_BONO IN VARCHAR2,
                                K_USUARIO IN VARCHAR2,
                                K_NUMREGTOT OUT NUMBER,
                                K_NUMREGVAL OUT NUMBER,
                                K_NUMREGERR OUT NUMBER,
                                K_CODERROR OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2) IS

CURSOR V_CUR_LINEAS(TIPOFIDEL CHAR, NOMARCH VARCHAR2) IS
SELECT T.ADMPN_SEC,
       T.ADMPV_LINEA,
       D.ADMPV_COD_TPDOC,
       T.ADMPV_NRO_DOCU,
       T.ADMPV_NOMBRES,
       T.ADMPV_APELLIDOS,
       T.ADMPV_SEXO,
       T.ADMPV_EST_CIVIL,
       T.ADMPV_EMAIL,
       T.ADMPV_DPTO,
       T.ADMPV_PROVINCIA,
       T.ADMPV_DISTRITO,
       T.ADMPD_FEC_ACTIVA
FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE T
INNER JOIN PCLUB.ADMPT_TIPO_DOC D ON UPPER(T.ADMPV_TIPO_DOCU) = UPPER(D.ADMPV_EQU_DWH)
WHERE T.ADMPC_TIPO_FIDEL = TIPOFIDEL
      AND T.ADMPV_NOMARCHIVO = NOMARCH
      AND T.ADMPV_CODERROR IS NULL;

V_TIPOFIDEL CHAR(1) := 'M';
V_FECHASYS DATE := TRUNC(SYSDATE);
V_DESCBONO VARCHAR2(100);
V_CODMSJSMS VARCHAR2(100);
V_CONTADOR NUMBER := 0;
V_CONTOTAL NUMBER;
V_CONTREGVAL NUMBER := 0;
V_NUMREGCOMMIT NUMBER;
V_NUMREGPROCES NUMBER;
V_CUR_BONOCONFIG SYS_REFCURSOR;
VC_BONO VARCHAR2(20);
VC_PUNTOS NUMBER;
VC_COD_CPTO VARCHAR2(2);
VC_DIASVIGEN NUMBER;
VC_COD_TPOPR VARCHAR2(2);
VC_SEC NUMBER;
VC_LINEA VARCHAR2(50);
VC_COD_TPDOC VARCHAR2(50);
VC_NRO_DOCU VARCHAR2(50);
VC_NOMBRES VARCHAR2(80);
VC_APELLIDOS VARCHAR2(80);
VC_SEXO VARCHAR2(50);
VC_EST_CIVIL VARCHAR2(50);
VC_EMAIL VARCHAR2(100);
VC_DPTO VARCHAR2(50);
VC_PROVINCIA VARCHAR2(50);
VC_DISTRITO VARCHAR2(200);
VC_FEC_ACTIVA DATE;
VT_BONOCONFIG PCLUB.T_BONOCONFIG;
VT_TBLBONOCONFIG T_TBLBONOCONFIG := T_TBLBONOCONFIG();
EX_ERREXT EXCEPTION;
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_NOMARCH IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el nombre del archivo.'; RAISE EX_ERROR;
    WHEN K_BONO    IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el código del bono.'; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := ''; K_NUMREGTOT := 0; K_NUMREGVAL := 0; K_NUMREGERR := 0;
  END CASE;

  BEGIN
    SELECT ADMPV_VALOR INTO V_NUMREGCOMMIT
    FROM PCLUB.ADMPT_PARAMSIST
    WHERE ADMPV_DESC = 'CANT_REG_COMMIT_PROC_MASIVO';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      K_CODERROR := 50;
      K_DESCERROR := 'ORA: No está registrado el parámetro CANT_REG_COMMIT_PROC_MASIVO';
      RAISE EX_ERROR;
  END;

  PCLUB.PKG_CC_BONOS.ADMPSS_OBT_CONFIG (K_BONO,
                                        '',
                                        V_DESCBONO,
                                        V_CODMSJSMS,
                                        V_CUR_BONOCONFIG,
                                        K_CODERROR,
                                        K_DESCERROR
                                        );

  IF K_CODERROR <> 0 THEN
    RAISE EX_ERREXT;
  END IF;

  FETCH V_CUR_BONOCONFIG INTO VC_BONO,VC_PUNTOS,VC_COD_CPTO,VC_DIASVIGEN,VC_COD_TPOPR;
  WHILE V_CUR_BONOCONFIG%FOUND LOOP
    V_CONTADOR := V_CONTADOR + 1;
    VT_BONOCONFIG := PCLUB.T_BONOCONFIG(NULL,NULL,NULL,NULL,NULL);
    VT_BONOCONFIG.BONO := VC_BONO;
    VT_BONOCONFIG.PUNTOS := VC_PUNTOS;
    VT_BONOCONFIG.COD_CPTO := VC_COD_CPTO;
    VT_BONOCONFIG.DIASVIGEN := VC_DIASVIGEN;
    VT_BONOCONFIG.COD_TPOPR := VC_COD_TPOPR;
    VT_TBLBONOCONFIG.EXTEND;
    VT_TBLBONOCONFIG(V_CONTADOR) := VT_BONOCONFIG;
    FETCH V_CUR_BONOCONFIG INTO VC_BONO,VC_PUNTOS,VC_COD_CPTO,VC_DIASVIGEN,VC_COD_TPOPR;
  END LOOP;

  IF V_CONTADOR = 0 THEN
     K_CODERROR := 4;
     K_DESCERROR := 'ORA: No existen registros de configuración.';
     RAISE EX_ERROR;
  END IF;

  PCLUB.PKG_CC_BONOS.ADMPSU_ENT_BONOFIDEL_VALIDA (V_TIPOFIDEL,
                                                  K_NOMARCH,
                                                  K_CODERROR,
                                                  K_DESCERROR
                                                  );

  IF K_CODERROR <> 0 THEN
    RAISE EX_ERREXT;
  END IF;

  --SE OBTIENE EL TOTAL DE REGISTROS CARGADOS
  SELECT COUNT(1) INTO K_NUMREGTOT
  FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE
  WHERE ADMPC_TIPO_FIDEL = V_TIPOFIDEL
        AND ADMPV_NOMARCHIVO = K_NOMARCH;

  --SE OBTIENE EL TOTAL DE REGISTROS A PROCESAR
  SELECT COUNT(1) INTO V_NUMREGPROCES
  FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE
  WHERE ADMPC_TIPO_FIDEL = V_TIPOFIDEL
        AND ADMPV_NOMARCHIVO = K_NOMARCH
        AND ADMPV_CODERROR IS NULL;

  V_CONTADOR := 1;
  V_CONTOTAL := 1;

  OPEN V_CUR_LINEAS(V_TIPOFIDEL,K_NOMARCH);
  FETCH V_CUR_LINEAS INTO VC_SEC,VC_LINEA,VC_COD_TPDOC,VC_NRO_DOCU,VC_NOMBRES,VC_APELLIDOS,VC_SEXO,VC_EST_CIVIL,VC_EMAIL,VC_DPTO,VC_PROVINCIA,VC_DISTRITO,VC_FEC_ACTIVA;

  WHILE V_CUR_LINEAS%FOUND LOOP
    PCLUB.PKG_CC_BONOS.ADMPSI_ENT_BONO_MASIVO(K_NOMARCH,
                                              VC_LINEA,
                                              VC_COD_TPDOC,
                                              VC_NRO_DOCU,
                                              VC_NOMBRES,
                                              VC_APELLIDOS,
                                              VC_SEXO,
                                              VC_EST_CIVIL,
                                              VC_EMAIL,
                                              VC_DPTO,
                                              VC_PROVINCIA,
                                              VC_DISTRITO,
                                              VC_FEC_ACTIVA,
                                              VT_TBLBONOCONFIG,
                                              K_USUARIO,
                                              K_CODERROR,
                                              K_DESCERROR
                                              );

    IF K_CODERROR = 0 THEN
      UPDATE PCLUB.ADMPT_TMP_BONOFIDEL_PRE T
      SET T.ADMPC_ESTADO = 'P'
      WHERE T.ADMPN_SEC = VC_SEC;

      V_CONTREGVAL := V_CONTREGVAL + 1;
    ELSE
      UPDATE PCLUB.ADMPT_TMP_BONOFIDEL_PRE T
      SET T.ADMPC_ESTADO = 'P',
          T.ADMPV_CODERROR = K_CODERROR,
          T.ADMPV_MSJERROR = K_DESCERROR
      WHERE T.ADMPN_SEC = VC_SEC;
    END IF;

    IF V_CONTADOR = V_NUMREGCOMMIT OR V_CONTOTAL = V_NUMREGPROCES THEN
      INSERT INTO PCLUB.ADMPT_IMP_BONOFIDEL_PRE
      (
        ADMPN_SEC,
        ADMPV_NOMARCHIVO,
        ADMPC_TIPO_FIDEL,
        ADMPV_LINEA,
        ADMPV_TIPO_DOCU,
        ADMPV_NRO_DOCU,
        ADMPV_NOMBRES,
        ADMPV_APELLIDOS,
        ADMPV_SEXO,
        ADMPV_EST_CIVIL,
        ADMPV_EMAIL,
        ADMPV_DPTO,
        ADMPV_PROVINCIA,
        ADMPV_DISTRITO,
        ADMPD_FEC_ACTIVA,
        ADMPC_ESTADOSMS,
        ADMPD_FEC_OPERA,
        ADMPD_FEC_REG,
        ADMPD_USU_REG
      )
      SELECT PCLUB.ADMPT_IMP_BONOFIDEL_PRE_SQ.NEXTVAL,
            ADMPV_NOMARCHIVO,
            ADMPC_TIPO_FIDEL,
            ADMPV_LINEA,
            ADMPV_TIPO_DOCU,
            ADMPV_NRO_DOCU,
            ADMPV_NOMBRES,
            ADMPV_APELLIDOS,
            ADMPV_SEXO,
            ADMPV_EST_CIVIL,
            ADMPV_EMAIL,
            ADMPV_DPTO,
            ADMPV_PROVINCIA,
            ADMPV_DISTRITO,
            ADMPD_FEC_ACTIVA,
            'P',
            V_FECHASYS,
            SYSDATE,
            K_USUARIO
      FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE
      WHERE ADMPC_TIPO_FIDEL = V_TIPOFIDEL
            AND ADMPV_NOMARCHIVO = K_NOMARCH
            AND ADMPC_ESTADO = 'P';

      DELETE PCLUB.ADMPT_TMP_BONOFIDEL_PRE
      WHERE ADMPC_TIPO_FIDEL = V_TIPOFIDEL
            AND ADMPV_NOMARCHIVO = K_NOMARCH
            AND ADMPC_ESTADO = 'P';

      COMMIT;
      V_CONTADOR := 0;
    END IF;
    V_CONTADOR := V_CONTADOR + 1;
    V_CONTOTAL := V_CONTOTAL + 1;

    FETCH V_CUR_LINEAS INTO VC_SEC,VC_LINEA,VC_COD_TPDOC,VC_NRO_DOCU,VC_NOMBRES,VC_APELLIDOS,VC_SEXO,VC_EST_CIVIL,VC_EMAIL,VC_DPTO,VC_PROVINCIA,VC_DISTRITO,VC_FEC_ACTIVA;
  END LOOP;
  CLOSE V_CUR_LINEAS;

  INSERT INTO PCLUB.ADMPT_IMP_BONOFIDEL_PRE
  (
    ADMPN_SEC,
    ADMPV_NOMARCHIVO,
    ADMPC_TIPO_FIDEL,
    ADMPV_LINEA,
    ADMPV_TIPO_DOCU,
    ADMPV_NRO_DOCU,
    ADMPV_NOMBRES,
    ADMPV_APELLIDOS,
    ADMPV_SEXO,
    ADMPV_EST_CIVIL,
    ADMPV_EMAIL,
    ADMPV_DPTO,
    ADMPV_PROVINCIA,
    ADMPV_DISTRITO,
    ADMPD_FEC_ACTIVA,
    ADMPV_CODERROR,
    ADMPV_MSJERROR,
    ADMPD_FEC_OPERA,
    ADMPD_FEC_REG,
    ADMPD_USU_REG
  )
  SELECT PCLUB.ADMPT_IMP_BONOFIDEL_PRE_SQ.NEXTVAL,
         ADMPV_NOMARCHIVO,
         ADMPC_TIPO_FIDEL,
         ADMPV_LINEA,
         ADMPV_TIPO_DOCU,
         ADMPV_NRO_DOCU,
         ADMPV_NOMBRES,
         ADMPV_APELLIDOS,
         ADMPV_SEXO,
         ADMPV_EST_CIVIL,
         ADMPV_EMAIL,
         ADMPV_DPTO,
         ADMPV_PROVINCIA,
         ADMPV_DISTRITO,
         ADMPD_FEC_ACTIVA,
         ADMPV_CODERROR,
         ADMPV_MSJERROR,
         V_FECHASYS,
         SYSDATE,
         K_USUARIO
  FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE
  WHERE ADMPC_TIPO_FIDEL = V_TIPOFIDEL
        AND ADMPV_NOMARCHIVO = K_NOMARCH
        AND ADMPV_CODERROR IS NOT NULL;

  --SE OBTIENE LOS VALORES K_NUMREGVAL Y K_NUMREGERR
  K_NUMREGVAL := V_CONTREGVAL;

  SELECT COUNT(1) INTO K_NUMREGERR
  FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE
  WHERE ADMPC_TIPO_FIDEL = V_TIPOFIDEL
        AND ADMPV_NOMARCHIVO = K_NOMARCH
        AND ADMPV_CODERROR IS NOT NULL;

  DELETE PCLUB.ADMPT_TMP_BONOFIDEL_PRE
  WHERE ADMPC_TIPO_FIDEL = V_TIPOFIDEL
        AND ADMPV_NOMARCHIVO = K_NOMARCH
        AND ADMPV_CODERROR IS NOT NULL;

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
        K_DESCERROR := 'ERROR EN SP ADMPSI_ENTR_BONOFID6M. ';
    END;
  WHEN EX_ERREXT THEN
    K_CODERROR := K_CODERROR;
  WHEN OTHERS THEN
    K_CODERROR := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    ROLLBACK;
END ADMPSI_ENTR_BONOFID6M;



 --****************************************************************
  -- Nombre SP           :  ADMPSI_ENTR_BONOFID6M_V
  -- Propósito           :  Entregar los bonos de puntos Fidelidad 6M
  -- Input               :  K_NOMARCH   --Nombre del archivo
  --                        K_BONO      --Código del bono
  --                        K_USUARIO   --Usuario de proceso
  -- Output              :  K_CODERROR  --Código de error o éxito
  --                        K_DESCERROR --Descripción del error
  -- Creado por          :  Víctor Hugo Zambrano
  -- Fec Creación        :  05/03/2015
  -- Fec Actualización   :
  --****************************************************************
  
  PROCEDURE ADMPSI_ENTR_BONOFID6M_V(K_NOMARCH   IN VARCHAR2,
                                  K_BONO      IN VARCHAR2,
                                  K_USUARIO   IN VARCHAR2,
                                  K_NUMREGTOT OUT NUMBER,
                                  K_NUMREGVAL OUT NUMBER,
                                  K_NUMREGERR OUT NUMBER,
                                  K_CODERROR  OUT NUMBER,
                                  K_DESCERROR OUT VARCHAR2) IS
  
    CURSOR V_CUR_LINEAS(TIPOFIDEL CHAR, NOMARCH VARCHAR2) IS
      SELECT T.ADMPN_SEC,
             T.ADMPV_LINEA,
             D.ADMPV_COD_TPDOC,
             T.ADMPV_NRO_DOCU,
             T.ADMPV_NOMBRES,
             T.ADMPV_APELLIDOS,
             T.ADMPV_SEXO,
             T.ADMPV_EST_CIVIL,
             T.ADMPV_EMAIL,
             T.ADMPV_DPTO,
             T.ADMPV_PROVINCIA,
             T.ADMPV_DISTRITO,
             T.ADMPD_FEC_ACTIVA
        FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE T

       INNER JOIN PCLUB.ADMPT_TIPO_DOC D
          ON UPPER(T.ADMPV_TIPO_DOCU) = UPPER(D.ADMPV_EQU_DWH)
       WHERE T.ADMPC_TIPO_FIDEL = TIPOFIDEL
         AND T.ADMPV_CODERROR IS NULL
         AND T.ADMPV_NOMARCHIVO = NOMARCH;
         
         --AND NOT EXISTS (SELECT ADMPV_NUM_CLI  
         --                      FROM ADMPT_INV_BONOFIDEL_PRE_6M 
         --                      WHERE FEC_CORTA = TO_CHAR(SYSDATE, 'MM/YYYY') AND ADMPV_NUM_CLI = T.ADMPV_LINEA );
--ADMPSI_ENTR_BONOFID6MV2
    V_TIPOFIDEL      CHAR(1) := 'M';
    V_FECHASYS       DATE := TRUNC(SYSDATE);
    V_FECHACORTA     VARCHAR2(10):= TO_CHAR(SYSDATE,'MM/YYYY');
    V_EXIST          NUMBER := 0;
    V_DESCBONO       VARCHAR2(100);
    V_CODMSJSMS      VARCHAR2(100);
    V_CONTADOR       NUMBER := 0;
    V_CONTOTAL       NUMBER;
    V_CONTREGVAL     NUMBER := 0;
    V_NUMREGCOMMIT   NUMBER;
    V_NUMREGPROCES   NUMBER;
    V_CUR_BONOCONFIG SYS_REFCURSOR;
    VC_BONO          VARCHAR2(20);
    VC_PUNTOS        NUMBER;
    VC_COD_CPTO      VARCHAR2(2);
    VC_DIASVIGEN     NUMBER;
    VC_COD_TPOPR     VARCHAR2(2);
    VC_SEC           NUMBER;
    VC_LINEA         VARCHAR2(50);
    VC_COD_TPDOC     VARCHAR2(50);
    VC_NRO_DOCU      VARCHAR2(50);
    VC_NOMBRES       VARCHAR2(50);
    VC_APELLIDOS     VARCHAR2(50);
    VC_SEXO          VARCHAR2(50);
    VC_EST_CIVIL     VARCHAR2(50);
    VC_EMAIL         VARCHAR2(50);
    VC_DPTO          VARCHAR2(50);
    VC_PROVINCIA     VARCHAR2(50);
    VC_DISTRITO      VARCHAR2(50);
    VC_FEC_ACTIVA    DATE;
    VT_BONOCONFIG    T_BONOCONFIG;
    VT_TBLBONOCONFIG T_TBLBONOCONFIG := T_TBLBONOCONFIG();
    EX_ERREXT EXCEPTION;
    EX_ERROR EXCEPTION;
  BEGIN
  
    CASE
      WHEN K_NOMARCH IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese el nombre del archivo.';
        RAISE EX_ERROR;
      WHEN K_BONO IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese el código del bono.';
        RAISE EX_ERROR;
      ELSE
        K_CODERROR  := 0;
        K_DESCERROR := '';
        K_NUMREGTOT := 0;
        K_NUMREGVAL := 0;
        K_NUMREGERR := 0;
    END CASE;
  
    BEGIN
      SELECT ADMPV_VALOR
        INTO V_NUMREGCOMMIT
        FROM PCLUB.ADMPT_PARAMSIST
       WHERE ADMPV_DESC = 'CANT_REG_COMMIT_PROC_MASIVO';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        K_CODERROR  := 50;
        K_DESCERROR := 'ORA: No está registrado el parámetro CANT_REG_COMMIT_PROC_MASIVO';
        RAISE EX_ERROR;
    END;
  
    PCLUB.PKG_CC_BONOS.ADMPSS_OBT_CONFIG(K_BONO,
                                   '',
                                   V_DESCBONO,
                                   V_CODMSJSMS,
                                   V_CUR_BONOCONFIG,
                                   K_CODERROR,
                                   K_DESCERROR);
  
    IF K_CODERROR <> 0 THEN
      RAISE EX_ERREXT;
    END IF;
  
    FETCH V_CUR_BONOCONFIG
      INTO VC_BONO, VC_PUNTOS, VC_COD_CPTO, VC_DIASVIGEN, VC_COD_TPOPR;
    WHILE V_CUR_BONOCONFIG%FOUND LOOP
      V_CONTADOR              := V_CONTADOR + 1;
      VT_BONOCONFIG           := T_BONOCONFIG(NULL, NULL, NULL, NULL, NULL);
      VT_BONOCONFIG.BONO      := VC_BONO;
      VT_BONOCONFIG.PUNTOS    := VC_PUNTOS;
      VT_BONOCONFIG.COD_CPTO  := VC_COD_CPTO;
      VT_BONOCONFIG.DIASVIGEN := VC_DIASVIGEN;
      VT_BONOCONFIG.COD_TPOPR := VC_COD_TPOPR;
      VT_TBLBONOCONFIG.EXTEND;
      VT_TBLBONOCONFIG(V_CONTADOR) := VT_BONOCONFIG;
      FETCH V_CUR_BONOCONFIG
        INTO VC_BONO, VC_PUNTOS, VC_COD_CPTO, VC_DIASVIGEN, VC_COD_TPOPR;
    END LOOP;
  
    IF V_CONTADOR = 0 THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'ORA: No existen registros de configuración.';
      RAISE EX_ERROR;
    END IF;
  
    PCLUB.PKG_CC_BONOS.ADMPSU_ENT_BONOFIDEL_VALIDA(V_TIPOFIDEL,
                                             K_NOMARCH,
                                             K_CODERROR,
                                             K_DESCERROR);
  
    IF K_CODERROR <> 0 THEN
      RAISE EX_ERREXT;
    END IF;
  
    --SE OBTIENE EL TOTAL DE REGISTROS CARGADOS
    SELECT COUNT(1)
      INTO K_NUMREGTOT
      FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE
     WHERE ADMPC_TIPO_FIDEL = V_TIPOFIDEL
       AND ADMPV_NOMARCHIVO = K_NOMARCH;
  
    --SE OBTIENE EL TOTAL DE REGISTROS A PROCESAR
    SELECT COUNT(1)
      INTO V_NUMREGPROCES
      FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE
     WHERE ADMPC_TIPO_FIDEL = V_TIPOFIDEL
       AND ADMPV_NOMARCHIVO = K_NOMARCH
       AND ADMPV_CODERROR IS NULL;
  
    V_CONTADOR := 1;
    V_CONTOTAL := 1;
  
    OPEN V_CUR_LINEAS(V_TIPOFIDEL, K_NOMARCH);
    FETCH V_CUR_LINEAS
      INTO VC_SEC,
           VC_LINEA,
           VC_COD_TPDOC,
           VC_NRO_DOCU,
           VC_NOMBRES,
           VC_APELLIDOS,
           VC_SEXO,
           VC_EST_CIVIL,
           VC_EMAIL,
           VC_DPTO,
           VC_PROVINCIA,
           VC_DISTRITO,
           VC_FEC_ACTIVA;
  
    WHILE V_CUR_LINEAS%FOUND LOOP
    
         SELECT CASE 
           WHEN EXISTS(SELECT * 
                       FROM PCLUB.ADMPT_BONO_KARDEX
                       WHERE ADMPV_LINEA=VC_LINEA 
                       AND FECCORTA = V_FECHACORTA
                        )
           THEN 1
           ELSE 0
           END  INTO V_EXIST
         FROM dual;


    IF (V_EXIST=0) THEN
      --************si no se encuentra en la tabla historica************
      --**********registrar el bono.************************************
      PCLUB.PKG_CC_BONOS.ADMPSI_ENT_BONO_MASIVO(K_NOMARCH,
                                          VC_LINEA,
                                          VC_COD_TPDOC,
                                          VC_NRO_DOCU,
                                          VC_NOMBRES,
                                          VC_APELLIDOS,
                                          VC_SEXO,
                                          VC_EST_CIVIL,
                                          VC_EMAIL,
                                          VC_DPTO,
                                          VC_PROVINCIA,
                                          VC_DISTRITO,
                                          VC_FEC_ACTIVA,
                                          VT_TBLBONOCONFIG,
                                          K_USUARIO,
                                          K_CODERROR,
                                          K_DESCERROR);
    
      IF K_CODERROR = 0 THEN
        UPDATE PCLUB.ADMPT_TMP_BONOFIDEL_PRE T
           SET T.ADMPC_ESTADO = 'P'
         WHERE T.ADMPN_SEC = VC_SEC;
      
        V_CONTREGVAL := V_CONTREGVAL + 1;
      ELSE
        UPDATE PCLUB.ADMPT_TMP_BONOFIDEL_PRE T
           SET T.ADMPC_ESTADO   = 'P',
               T.ADMPV_CODERROR = K_CODERROR,
               T.ADMPV_MSJERROR = K_DESCERROR
         WHERE T.ADMPN_SEC = VC_SEC;
      END IF;
    
      IF V_CONTADOR = V_NUMREGCOMMIT OR V_CONTOTAL = V_NUMREGPROCES THEN
        INSERT INTO PCLUB.ADMPT_IMP_BONOFIDEL_PRE
          (ADMPN_SEC,
           ADMPV_NOMARCHIVO,
           ADMPC_TIPO_FIDEL,
           ADMPV_LINEA,
           ADMPV_TIPO_DOCU,
           ADMPV_NRO_DOCU,
           ADMPV_NOMBRES,
           ADMPV_APELLIDOS,
           ADMPV_SEXO,
           ADMPV_EST_CIVIL,
           ADMPV_EMAIL,
           ADMPV_DPTO,
           ADMPV_PROVINCIA,
           ADMPV_DISTRITO,
           ADMPD_FEC_ACTIVA,
           ADMPC_ESTADOSMS,
           ADMPD_FEC_OPERA,
           ADMPD_FEC_REG,
           ADMPD_USU_REG)
          SELECT PCLUB.ADMPT_IMP_BONOFIDEL_PRE_SQ.NEXTVAL,
                 ADMPV_NOMARCHIVO,
                 ADMPC_TIPO_FIDEL,
                 ADMPV_LINEA,
                 ADMPV_TIPO_DOCU,
                 ADMPV_NRO_DOCU,
                 ADMPV_NOMBRES,
                 ADMPV_APELLIDOS,
                 ADMPV_SEXO,
                 ADMPV_EST_CIVIL,
                 ADMPV_EMAIL,
                 ADMPV_DPTO,
                 ADMPV_PROVINCIA,
                 ADMPV_DISTRITO,
                 ADMPD_FEC_ACTIVA,
                 'P',
                 V_FECHASYS,
                 SYSDATE,
                 K_USUARIO
            FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE
           WHERE ADMPC_TIPO_FIDEL = V_TIPOFIDEL
             AND ADMPV_NOMARCHIVO = K_NOMARCH
             AND ADMPC_ESTADO = 'P';
             
             
             /*INICIO MEJORA ENTREGA DE PUNTOS FIDELIDAD*/
             
             /*INSERT INTO ADMPT_INV_BONOFIDEL_PRE_6M
             (
             INV_FIDEL_ID,
             ADMPV_NUM_CLI,
             ADMPV_BONO_ID,
             FEC_CORTA,
             USER_REG,
             FEC_REG
             )
             SELECT ADMPT_INV_BONOFIDEL_PRE_6M_SQ.NEXTVAL,
                 ADMPV_LINEA,
                 ADMPT_IMP_BONOFIDEL_PRE_SQ.Currval,
                 TO_CHAR(SYSDATE,'MM/YYYY'),
                 K_USUARIO,
                 SYSDATE                 
            FROM ADMPT_TMP_BONOFIDEL_PRE
           WHERE ADMPC_TIPO_FIDEL = V_TIPOFIDEL
             AND ADMPV_NOMARCHIVO = K_NOMARCH
             AND ADMPC_ESTADO = 'P';*/
             
             /*FIN MEJORA ENTREGA DE PUNTOS FIDELIDAD*/
      
       
      
        COMMIT;
        V_CONTADOR := 0;
      END IF;
      --****************************************************
    ELSE
      --*********Si ya se encuetra los puntos asignados en historico kardex****
      --*********setear mensaje************************************************
      UPDATE PCLUB.ADMPT_TMP_BONOFIDEL_PRE T
           SET T.ADMPC_ESTADO   = 'P',
               T.ADMPV_CODERROR = '7',
               T.ADMPV_MSJERROR = 'Ya se le asignó puntos a la línea.'
         WHERE T.ADMPN_SEC = VC_SEC;
      --***********************************************************************
    END IF;
      
      V_CONTADOR := V_CONTADOR + 1;
      V_CONTOTAL := V_CONTOTAL + 1;
    
      FETCH V_CUR_LINEAS
        INTO VC_SEC,
             VC_LINEA,
             VC_COD_TPDOC,
             VC_NRO_DOCU,
             VC_NOMBRES,
             VC_APELLIDOS,
             VC_SEXO,
             VC_EST_CIVIL,
             VC_EMAIL,
             VC_DPTO,
             VC_PROVINCIA,
             VC_DISTRITO,
             VC_FEC_ACTIVA;
    END LOOP;
    
    CLOSE V_CUR_LINEAS;
  
    INSERT INTO PCLUB.ADMPT_IMP_BONOFIDEL_PRE
      (ADMPN_SEC,
       ADMPV_NOMARCHIVO,
       ADMPC_TIPO_FIDEL,
       ADMPV_LINEA,
       ADMPV_TIPO_DOCU,
       ADMPV_NRO_DOCU,
       ADMPV_NOMBRES,
       ADMPV_APELLIDOS,
       ADMPV_SEXO,
       ADMPV_EST_CIVIL,
       ADMPV_EMAIL,
       ADMPV_DPTO,
       ADMPV_PROVINCIA,
       ADMPV_DISTRITO,
       ADMPD_FEC_ACTIVA,
       ADMPV_CODERROR,
       ADMPV_MSJERROR,
       ADMPD_FEC_OPERA,
       ADMPD_FEC_REG,
       ADMPD_USU_REG)
      SELECT PCLUB.ADMPT_IMP_BONOFIDEL_PRE_SQ.NEXTVAL,
             ADMPV_NOMARCHIVO,
             ADMPC_TIPO_FIDEL,
             ADMPV_LINEA,
             ADMPV_TIPO_DOCU,
             ADMPV_NRO_DOCU,
             ADMPV_NOMBRES,
             ADMPV_APELLIDOS,
             ADMPV_SEXO,
             ADMPV_EST_CIVIL,
             ADMPV_EMAIL,
             ADMPV_DPTO,
             ADMPV_PROVINCIA,
             ADMPV_DISTRITO,
             ADMPD_FEC_ACTIVA,
             ADMPV_CODERROR,
             ADMPV_MSJERROR,
             V_FECHASYS,
             SYSDATE,
             K_USUARIO
        FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE
       WHERE ADMPC_TIPO_FIDEL = V_TIPOFIDEL
         AND ADMPV_NOMARCHIVO = K_NOMARCH
         AND ADMPV_CODERROR IS NOT NULL;
     COMMIT;
    
     DELETE PCLUB.ADMPT_TMP_BONOFIDEL_PRE
         WHERE ADMPC_TIPO_FIDEL = V_TIPOFIDEL
           AND ADMPV_NOMARCHIVO = K_NOMARCH
           AND ADMPC_ESTADO = 'P';
     COMMIT;
    --SE OBTIENE LOS VALORES K_NUMREGVAL Y K_NUMREGERR
    K_NUMREGVAL := V_CONTREGVAL;
  
    SELECT COUNT(1)
      INTO K_NUMREGERR
      FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE
     WHERE ADMPC_TIPO_FIDEL = V_TIPOFIDEL
       AND ADMPV_NOMARCHIVO = K_NOMARCH
       AND ADMPV_CODERROR IS NOT NULL;
  
    DELETE PCLUB.ADMPT_TMP_BONOFIDEL_PRE
     WHERE ADMPC_TIPO_FIDEL = V_TIPOFIDEL
       AND ADMPV_NOMARCHIVO = K_NOMARCH
       AND ADMPV_CODERROR IS NOT NULL;
  
    COMMIT;
  
  EXCEPTION
    WHEN EX_ERROR THEN
      BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR
          INTO K_DESCERROR
          FROM ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_DESCERROR := 'ERROR EN SP ADMPSI_ENTR_BONOFID6M. ';
      END;
    WHEN EX_ERREXT THEN
      K_CODERROR := K_CODERROR;
      K_DESCERROR:= SUBSTR(SQLERRM, 1, 250);
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      ROLLBACK;
END ADMPSI_ENTR_BONOFID6M_V;


--****************************************************************
  -- Nombre SP           :  ADMPSI_ENTR_BONOFID12M_V
  -- Propósito           :  Entregar los bonos de puntos por Fidelidad 12 Meses
  -- Input               :  K_NOM_ARCHIVO -> Nombre del archivo
  --                     :  K_BONO      -> Código del bono
  --                     :  K_USUARIO   -> Usuario de proceso
  -- Output              :  K_CODERROR  -> Código de error o éxito
  --                        K_DESCERROR -> Descripción del error
  -- Creado por          :  Víctor Zambrano
  -- Fec Creación        :  26/07/2013
  --**************************************************************** 
  
  
  PROCEDURE ADMPSI_ENTR_BONOFID12M_V(K_NOM_ARCHIVO IN VARCHAR2,
                                   K_BONO        IN VARCHAR2,
                                   K_USUARIO     IN VARCHAR2,
                                   K_CODERROR    OUT NUMBER,
                                   K_DESCERROR   OUT VARCHAR2,
                                   K_TOT_PROC    OUT NUMBER,
                                   K_TOT_EXI     OUT NUMBER,
                                   K_TOT_ERR     OUT NUMBER) IS
    -- Variables Datos de Clientes Prepago
    V_LINEA     VARCHAR2(20);
    V_FECHACORTA     VARCHAR2(10):= TO_CHAR(SYSDATE,'MM/YYYY');
    V_EXIST          NUMBER := 0;
    V_TIPO_DOC  VARCHAR2(20);
    V_NUM_DOC   VARCHAR2(20);
    V_NOM       VARCHAR2(50);
    V_APE       VARCHAR2(50);
    V_SEXO      VARCHAR2(10);
    V_EST_CIVIL VARCHAR2(20);
    V_MAIL      VARCHAR(50);
    V_DIST      VARCHAR(50);
    V_PROV      VARCHAR(50);
    V_DPTO      VARCHAR(50);
    V_FEC_ACT   DATE;
    V_SEC       NUMBER;
    V_NOM_ARCH  VARCHAR2(50);
    V_TIPO_FID  CHAR(1);
    V_FECH_OPE  DATE;
    V_ID_BONO   VARCHAR(20);
    V_DESC_BONO VARCHAR(150);
    V_CUR_BONOS SYS_REFCURSOR;
    V_CODMJS    VARCHAR2(40);
    V_CODERROR  NUMBER;
    V_DESCERROR NUMBER;
    V_SEQ       NUMBER;
    -- Contadores
    V_COUNT NUMBER;
  
    -- Variables de Configuracion del Bono
    V_BONO           VARCHAR2(20);
    V_PUNTOS         NUMBER;
    V_COD_TPRE       VARCHAR2(2);
    V_COD_CPTO       VARCHAR2(2);
    V_DIAS_VIG       NUMBER;
    VT_BONOCONFIG    T_BONOCONFIG;
    VT_TBLBONOCONFIG T_TBLBONOCONFIG := T_TBLBONOCONFIG();
    V_TAM_LOTE       NUMBER;
    
    -- Variables Exceptiones
    EX_ERROR_IN EXCEPTION;
    EX_ERROR_EX EXCEPTION;
  
    -- Cursor
    CURSOR V_CUR_LINEAS(V_TPO_FID CHAR, V_NOM_FILE VARCHAR2) IS
      SELECT TMP.ADMPN_SEC,
             TMP.ADMPV_LINEA,
             TD.ADMPV_COD_TPDOC,
             TMP.ADMPV_NRO_DOCU,
             TMP.ADMPV_NOMBRES,
             TMP.ADMPV_APELLIDOS,
             TMP.ADMPV_SEXO,
             TMP.ADMPV_EST_CIVIL,
             TMP.ADMPV_EMAIL,
             TMP.ADMPV_DISTRITO,
             TMP.ADMPV_PROVINCIA,
             TMP.ADMPV_DPTO,
             TMP.ADMPD_FEC_ACTIVA,
             TMP.ADMPV_NOMARCHIVO
        FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE TMP
       INNER JOIN PCLUB.ADMPT_TIPO_DOC TD
          ON UPPER(TD.ADMPV_EQU_DWH) = UPPER(TMP.ADMPV_TIPO_DOCU)
       WHERE TMP.ADMPV_CODERROR IS NULL
         AND TMP.ADMPC_TIPO_FIDEL = V_TPO_FID
         AND TMP.ADMPV_NOMARCHIVO = V_NOM_FILE;
         --AND NOT EXISTS (SELECT *  
         --                      FROM ADMPT_INV_BONOFIDEL_PRE_12M 
         --                      WHERE FEC_CORTA = TO_CHAR(SYSDATE, 'MM/YYYY') AND ADMPV_NUM_CLI = TMP.ADMPV_LINEA );
  BEGIN
    V_TIPO_FID  := 'A';
    V_FECH_OPE  := TRUNC(SYSDATE);
    K_TOT_PROC  := 0;
    K_TOT_EXI   := 0;
    K_TOT_ERR   := 0;
    K_CODERROR  := 0;
    K_DESCERROR := '';
    V_SEQ:=0;
  
    IF K_BONO IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR := ' No se ingresó el código del bono.';
      RAISE EX_ERROR_IN;
    END IF;
  
    V_ID_BONO := UPPER(K_BONO);
  
    -- obtener la(s) configuraciones del bono
    PCLUB.PKG_CC_BONOS.ADMPSS_OBT_CONFIG(V_ID_BONO,
                                   NULL,
                                   V_DESC_BONO,
                                   V_CODMJS,
                                   V_CUR_BONOS,
                                   V_CODERROR,
                                   V_DESCERROR);
  
    IF V_CODERROR <> 0 THEN
      RAISE EX_ERROR_EX;
    END IF;
  
    -- obtenemos las configuracion devueltas en el cursor
    V_COUNT := 0;
  
    FETCH V_CUR_BONOS
      INTO V_BONO, V_PUNTOS, V_COD_CPTO, V_DIAS_VIG, V_COD_TPRE;
  
    WHILE V_CUR_BONOS%FOUND LOOP
      V_COUNT                 := V_COUNT + 1;
      VT_BONOCONFIG           := T_BONOCONFIG(NULL, NULL, NULL, NULL, NULL);
      VT_BONOCONFIG.BONO      := V_BONO;
      VT_BONOCONFIG.PUNTOS    := V_PUNTOS;
      VT_BONOCONFIG.COD_CPTO  := V_COD_CPTO;
      VT_BONOCONFIG.DIASVIGEN := V_DIAS_VIG;
      VT_BONOCONFIG.COD_TPOPR := V_COD_TPRE;
      VT_TBLBONOCONFIG.EXTEND;
      VT_TBLBONOCONFIG(V_COUNT) := VT_BONOCONFIG;
    
      FETCH V_CUR_BONOS
        INTO V_BONO, V_PUNTOS, V_COD_CPTO, V_DIAS_VIG, V_COD_TPRE;
    END LOOP;
  
    CLOSE V_CUR_BONOS;
  
    IF V_COUNT = 0 THEN
      K_CODERROR  := 50;
      K_DESCERROR := 'ORA: No se encontró configuraciones para el bono enviado.';
      RAISE EX_ERROR_IN;
    END IF;
  
    -- obtenemos el tamaño de cada lote
    BEGIN
      SELECT ADMPV_VALOR
        INTO V_TAM_LOTE
        FROM PCLUB.ADMPT_PARAMSIST
       WHERE ADMPV_DESC = 'CANT_REG_COMMIT_PROC_MASIVO';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        K_CODERROR  := 50;
        K_DESCERROR := 'ORA: No está registrado el parámetro CANT_REG_COMMIT_PROC_MASIVO';
        RAISE EX_ERROR_IN;
    END;
  
    -- identificar los registros de tmp con errores
    PCLUB.PKG_CC_BONOS.ADMPSU_ENT_BONOFIDEL_VALIDA(V_TIPO_FID,
                                             K_NOM_ARCHIVO,
                                             V_CODERROR,
                                             V_DESCERROR);
  
    IF V_CODERROR <> 0 THEN
      RAISE EX_ERROR_EX;
    END IF;
  
    -- obtenemos el total de archivos cargados
    SELECT COUNT(1)
      INTO K_TOT_PROC
      FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE BF
     WHERE BF.ADMPV_NOMARCHIVO = K_NOM_ARCHIVO
       AND BF.ADMPC_TIPO_FIDEL = V_TIPO_FID;
  
    -- abrimos el cursor de lineas
    OPEN V_CUR_LINEAS(V_TIPO_FID, K_NOM_ARCHIVO);
  
    V_COUNT := 0;
    FETCH V_CUR_LINEAS
      INTO V_SEC,
           V_LINEA,
           V_TIPO_DOC,
           V_NUM_DOC,
           V_NOM,
           V_APE,
           V_SEXO,
           V_EST_CIVIL,
           V_MAIL,
           V_DIST,
           V_PROV,
           V_DPTO,
           V_FEC_ACT,
           V_NOM_ARCH;
  
    WHILE V_CUR_LINEAS%FOUND LOOP
      V_COUNT := V_COUNT + 1;
    
         SELECT CASE 
           WHEN EXISTS(SELECT * 
                       FROM PCLUB.ADMPT_BONO_KARDEX
                       WHERE ADMPV_LINEA=V_LINEA 
                       AND FECCORTA = V_FECHACORTA
                        )
           THEN 1
           ELSE 0
           END  INTO V_EXIST
         FROM dual;
    
    IF (V_EXIST=0) THEN
      --************si no se encuentra en la tabla historica************
      --**********registrar el bono.************************************
      
      PCLUB.PKG_CC_BONOS.ADMPSI_ENT_BONO_MASIVO(V_NOM_ARCH,
                                          V_LINEA,
                                          V_TIPO_DOC,
                                          V_NUM_DOC,
                                          V_NOM,
                                          V_APE,
                                          V_SEXO,
                                          V_EST_CIVIL,
                                          V_MAIL,
                                          V_DPTO,
                                          V_PROV,
                                          V_DIST,
                                          V_FEC_ACT,
                                          VT_TBLBONOCONFIG,
                                          K_USUARIO,
                                          V_CODERROR,
                                          V_DESCERROR);
    
      -- evaluamos el resultado del proceso
      IF V_CODERROR = 0 THEN
        -- actualizamos el estado a procesado del registro actual
        UPDATE PCLUB.ADMPT_TMP_BONOFIDEL_PRE
           SET ADMPC_ESTADO = 'P'
         WHERE ADMPN_SEC = V_SEC;
      
        K_TOT_EXI := K_TOT_EXI + 1;
      ELSE
        -- actualizamos el estado a procesado y el codigo y mensaje de error
        UPDATE PCLUB.ADMPT_TMP_BONOFIDEL_PRE
           SET ADMPC_ESTADO   = 'P',
               ADMPV_CODERROR = V_CODERROR,
               ADMPV_MSJERROR = V_DESCERROR
         WHERE ADMPN_SEC = V_SEC;
      
      END IF;
    
      IF V_COUNT = V_TAM_LOTE THEN
        SELECT ADMPT_IMP_BONOFIDEL_PRE_SQ.NEXTVAL INTO V_SEQ FROM DUAL;
        INSERT INTO PCLUB.ADMPT_IMP_BONOFIDEL_PRE
          (ADMPN_SEC,
           ADMPV_LINEA,
           ADMPV_TIPO_DOCU,
           ADMPV_NRO_DOCU,
           ADMPV_NOMBRES,
           ADMPV_APELLIDOS,
           ADMPV_SEXO,
           ADMPV_EST_CIVIL,
           ADMPV_EMAIL,
           ADMPV_DISTRITO,
           ADMPV_PROVINCIA,
           ADMPV_DPTO,
           ADMPD_FEC_ACTIVA,
           ADMPC_TIPO_FIDEL,
           ADMPV_NOMARCHIVO,
           ADMPD_FEC_OPERA,
           ADMPD_FEC_REG,
           ADMPC_ESTADOSMS)
          SELECT V_SEQ,
                 TMP.ADMPV_LINEA,
                 TMP.ADMPV_TIPO_DOCU,
                 TMP.ADMPV_NRO_DOCU,
                 TMP.ADMPV_NOMBRES,
                 TMP.ADMPV_APELLIDOS,
                 TMP.ADMPV_SEXO,
                 TMP.ADMPV_EST_CIVIL,
                 TMP.ADMPV_EMAIL,
                 TMP.ADMPV_DISTRITO,
                 TMP.ADMPV_PROVINCIA,
                 TMP.ADMPV_DPTO,
                 TMP.ADMPD_FEC_ACTIVA,
                 TMP.ADMPC_TIPO_FIDEL,
                 TMP.ADMPV_NOMARCHIVO,
                 V_FECH_OPE,
                 SYSDATE,
                 'P'
            FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE TMP
           WHERE TMP.ADMPC_TIPO_FIDEL = V_TIPO_FID
             AND TMP.ADMPV_NOMARCHIVO = K_NOM_ARCHIVO
             AND TMP.ADMPC_ESTADO = 'P';
              COMMIT;
             
             
      
        COMMIT;
      
        V_COUNT := 0;
      END IF;
      --**********FIN registrar el bono.************************************
    ELSE
      --*********Si ya se encuetra los puntos asignados en historico kardex****
      --*********setear mensaje************************************************
      UPDATE PCLUB.ADMPT_TMP_BONOFIDEL_PRE T
           SET T.ADMPC_ESTADO   = 'P',
               T.ADMPV_CODERROR = '7',
               T.ADMPV_MSJERROR = 'Ya se le asignó puntos a la línea.'
         WHERE T.ADMPN_SEC = V_SEQ;
      --***********************************************************************
    END IF;
      
    
      FETCH V_CUR_LINEAS
        INTO V_SEC,
             V_LINEA,
             V_TIPO_DOC,
             V_NUM_DOC,
             V_NOM,
             V_APE,
             V_SEXO,
             V_EST_CIVIL,
             V_MAIL,
             V_DIST,
             V_PROV,
             V_DPTO,
             V_FEC_ACT,
             V_NOM_ARCH;
    END LOOP;
  
    SELECT PCLUB.ADMPT_IMP_BONOFIDEL_PRE_SQ.NEXTVAL INTO V_SEQ FROM DUAL;
    -- insertamos todos aquellos registros procesados
    INSERT INTO PCLUB.ADMPT_IMP_BONOFIDEL_PRE
      (ADMPN_SEC,
       ADMPV_LINEA,
       ADMPV_TIPO_DOCU,
       ADMPV_NRO_DOCU,
       ADMPV_NOMBRES,
       ADMPV_APELLIDOS,
       ADMPV_SEXO,
       ADMPV_EST_CIVIL,
       ADMPV_EMAIL,
       ADMPV_DISTRITO,
       ADMPV_PROVINCIA,
       ADMPV_DPTO,
       ADMPD_FEC_ACTIVA,
       ADMPC_TIPO_FIDEL,
       ADMPV_NOMARCHIVO,
       ADMPD_FEC_OPERA,
       ADMPD_FEC_REG,
       ADMPC_ESTADOSMS)
      SELECT V_SEQ,
             TMP.ADMPV_LINEA,
             TMP.ADMPV_TIPO_DOCU,
             TMP.ADMPV_NRO_DOCU,
             TMP.ADMPV_NOMBRES,
             TMP.ADMPV_APELLIDOS,
             TMP.ADMPV_SEXO,
             TMP.ADMPV_EST_CIVIL,
             TMP.ADMPV_EMAIL,
             TMP.ADMPV_DISTRITO,
             TMP.ADMPV_PROVINCIA,
             TMP.ADMPV_DPTO,
             TMP.ADMPD_FEC_ACTIVA,
             TMP.ADMPC_TIPO_FIDEL,
             TMP.ADMPV_NOMARCHIVO,
             V_FECH_OPE,
             SYSDATE,
             'P'
        FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE TMP
       WHERE TMP.ADMPC_TIPO_FIDEL = V_TIPO_FID
         AND TMP.ADMPV_NOMARCHIVO = K_NOM_ARCHIVO
         AND TMP.ADMPC_ESTADO = 'P';
         
         COMMIT;
        
  
    -- insertamos los registros erróneos
    INSERT INTO PCLUB.ADMPT_IMP_BONOFIDEL_PRE
      (ADMPN_SEC,
       ADMPV_LINEA,
       ADMPV_TIPO_DOCU,
       ADMPV_NRO_DOCU,
       ADMPV_NOMBRES,
       ADMPV_APELLIDOS,
       ADMPV_SEXO,
       ADMPV_EST_CIVIL,
       ADMPV_EMAIL,
       ADMPV_DISTRITO,
       ADMPV_PROVINCIA,
       ADMPV_DPTO,
       ADMPD_FEC_ACTIVA,
       ADMPC_TIPO_FIDEL,
       ADMPV_NOMARCHIVO,
       ADMPD_FEC_OPERA,
       ADMPD_FEC_REG,
       ADMPV_CODERROR,
       ADMPV_MSJERROR)
      SELECT PCLUB.ADMPT_IMP_BONOFIDEL_PRE_SQ.NEXTVAL,
             TMP.ADMPV_LINEA,
             TMP.ADMPV_TIPO_DOCU,
             TMP.ADMPV_NRO_DOCU,
             TMP.ADMPV_NOMBRES,
             TMP.ADMPV_APELLIDOS,
             TMP.ADMPV_SEXO,
             TMP.ADMPV_EST_CIVIL,
             TMP.ADMPV_EMAIL,
             TMP.ADMPV_DISTRITO,
             TMP.ADMPV_PROVINCIA,
             TMP.ADMPV_DPTO,
             TMP.ADMPD_FEC_ACTIVA,
             TMP.ADMPC_TIPO_FIDEL,
             TMP.ADMPV_NOMARCHIVO,
             V_FECH_OPE,
             SYSDATE,
             TMP.ADMPV_CODERROR,
             TMP.ADMPV_MSJERROR
        FROM ADMPT_TMP_BONOFIDEL_PRE TMP
       WHERE TMP.ADMPC_TIPO_FIDEL = V_TIPO_FID
         AND TMP.ADMPV_NOMARCHIVO = K_NOM_ARCHIVO
         AND TMP.ADMPV_CODERROR IS NOT NULL;
   COMMIT;
  
   DELETE FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE
     WHERE ADMPV_NOMARCHIVO = K_NOM_ARCHIVO
       AND ADMPC_TIPO_FIDEL = V_TIPO_FID
       AND ADMPC_ESTADO = 'P';
    COMMIT;
    -- Obtenemos el numero de registros erróneos
    SELECT COUNT(1)
      INTO K_TOT_ERR
      FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE TMP
     WHERE TMP.ADMPC_TIPO_FIDEL = V_TIPO_FID
       AND TMP.ADMPV_NOMARCHIVO = K_NOM_ARCHIVO
       AND TMP.ADMPV_CODERROR IS NOT NULL;
  
    -- eliminamos los registros erróneos
    DELETE FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE
     WHERE ADMPV_NOMARCHIVO = K_NOM_ARCHIVO
       AND ADMPC_TIPO_FIDEL = V_TIPO_FID;
  
    COMMIT;
  
    CLOSE V_CUR_LINEAS;
  
    SELECT ADMPV_DES_ERROR || K_DESCERROR
      INTO K_DESCERROR
      FROM PCLUB.ADMPT_ERRORES_CC
     WHERE ADMPN_COD_ERROR = K_CODERROR;
  
  EXCEPTION
  
    WHEN EX_ERROR_IN THEN
      BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR
          INTO K_DESCERROR
          FROM ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      
        ROLLBACK;
      END;
    
    WHEN EX_ERROR_EX THEN
      BEGIN
        K_CODERROR  := V_CODERROR;
        K_DESCERROR := V_DESCERROR;
      
        ROLLBACK;
      END;
    WHEN OTHERS THEN
      K_CODERROR  := -1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    
      ROLLBACK;
  END ADMPSI_ENTR_BONOFID12M_V;
--****************************************************************
-- Nombre SP           :  ADMPSI_ENT_BONO_MASIVO
-- Propósito           :  Entregar los bonos de puntos Fidelidad 6M
-- Input               :  K_NOMARCH       --Nombre del archivo
--                        K_LINEA         --Número de la línea
--                        K_TIPDOC        --Código del tipo de documento
--                        K_NRODOC        --Número del documento
--                        K_NOMBRES       --Nombres
--                        K_APELLIDOS     --Apellidos
--                        K_SEXO          --Sexo
--                        K_ESTADOCIVIL   --Estado civil
--                        K_EMAIL         --Email
--                        K_DPTO          --Departamento
--                        K_PROVINCIA     --Provincia
--                        K_DISTRITO      --Distrito
--                        K_FECHACTIVACION--Fecha de activación
--                        K_TBL_BONOCONFIG--Configuración del bono
--                        K_USUARIO       --Usuario de proceso
-- Output              :  K_CODERROR      --Código de error o éxito
--                        K_DESCERROR     --Descripción del error
-- Creado por          :  Oscar Paucar Pérez
-- Fec Creación        :  26/07/2013
-- Fec Actualización   :
--****************************************************************
PROCEDURE ADMPSI_ENT_BONO_MASIVO(K_NOMARCH IN VARCHAR2,
                                 K_LINEA IN VARCHAR2,
                                 K_TIPDOC IN VARCHAR2,
                                 K_NRODOC IN VARCHAR2,
                                 K_NOMBRES IN VARCHAR2,
                                 K_APELLIDOS IN VARCHAR2,
                                 K_SEXO IN VARCHAR2,
                                 K_ESTADOCIVIL IN VARCHAR2,
                                 K_EMAIL IN VARCHAR2,
                                 K_DPTO IN VARCHAR2,
                                 K_PROVINCIA IN VARCHAR2,
                                 K_DISTRITO IN VARCHAR2,
                                 K_FECHACTIVACION IN DATE,
                                 K_TBL_BONOCONFIG IN T_TBLBONOCONFIG,
                                 K_USUARIO IN VARCHAR2,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2) IS

V_TIPO_DOC VARCHAR2(20) := K_TIPDOC;
V_NUM_DOC VARCHAR2(20) := K_NRODOC;
V_FECVCMTO DATE;
V_CONTADOR NUMBER;
V_IDKARDEX NUMBER;
V_IDSALDOSCLIE NUMBER;
V_IDCLIENTE VARCHAR2(40);
VT_BONOCONFIG PCLUB.T_BONOCONFIG;
EX_ERREXT EXCEPTION;
BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';

  --Validamos que la línea se encuentre registrada en ClaroClub
  SELECT COUNT(1) INTO V_CONTADOR
  FROM PCLUB.ADMPT_CLIENTE
  WHERE ADMPV_COD_CLI = K_LINEA
        AND ADMPC_ESTADO = 'A';

  IF V_CONTADOR = 0 THEN
    --Insertamos en la base de datos de ClaroClub
    PCLUB.PKG_CC_BONOS.ADMPSI_REG_CLIENTE(K_LINEA,
                                          NULL,
                                          '2',
                                          K_TIPDOC,
                                          K_NRODOC,
                                          K_NOMBRES,
                                          K_APELLIDOS,
                                          K_SEXO,
                                          K_ESTADOCIVIL,
                                          K_EMAIL,
                                          K_DPTO,
                                          K_PROVINCIA,
                                          K_DISTRITO,
                                          K_FECHACTIVACION,
                                          NULL,
                                          'A',
                                          '3',
                                          K_USUARIO,
                                          V_IDCLIENTE,
                                          K_CODERROR,
                                          K_DESCERROR
                                          );

    IF K_CODERROR <> 0 THEN
      RAISE EX_ERREXT;
    END IF;
  ELSE
    --Obtenemos los datos del Cliente ClaroClub
    SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC INTO V_TIPO_DOC, V_NUM_DOC
    FROM PCLUB.ADMPT_CLIENTE
    WHERE ADMPV_COD_CLI = K_LINEA
          AND ADMPC_ESTADO = 'A';
  END IF;

  --Validamos que la línea se encuentre en saldos en ClaroClub
  SELECT COUNT(1) INTO V_CONTADOR
  FROM PCLUB.ADMPT_SALDOS_CLIENTE
  WHERE ADMPV_COD_CLI = K_LINEA;

  IF V_CONTADOR = 0 THEN
    PCLUB.PKG_CC_BONOS.ADMPSI_REG_SALDOS_CLIE
    (
      K_LINEA,
      '',
      0,
      0,
      'A',
      '',
      V_IDSALDOSCLIE,
      K_CODERROR,
      K_DESCERROR
    );

    IF K_CODERROR <> 0 THEN
      RAISE EX_ERREXT;
    END IF;
  END IF;

  FOR I IN K_TBL_BONOCONFIG.FIRST .. K_TBL_BONOCONFIG.LAST LOOP
    VT_BONOCONFIG := K_TBL_BONOCONFIG(I);
    V_FECVCMTO := SYSDATE + VT_BONOCONFIG.DIASVIGEN;

    PCLUB.PKG_CC_BONOS.ADMPSI_ENTREGA_PTOS
    (
      K_LINEA,
      VT_BONOCONFIG.COD_CPTO,
      VT_BONOCONFIG.PUNTOS,
      V_FECVCMTO,
      VT_BONOCONFIG.COD_TPOPR,
      K_NOMARCH,
      K_USUARIO,
      V_IDKARDEX,
      K_CODERROR,
      K_DESCERROR
    );

    IF K_CODERROR <> 0 THEN
      RAISE EX_ERREXT;
    END IF;

    --Insertamos en la tabla histórica de Bono
    PCLUB.PKG_CC_BONOS.ADMPSI_REG_BONO_KARDEX
    (
      V_IDKARDEX,
      VT_BONOCONFIG.BONO,
      K_LINEA,
      SYSDATE,
      V_FECVCMTO,
      VT_BONOCONFIG.PUNTOS,
      VT_BONOCONFIG.DIASVIGEN,
      VT_BONOCONFIG.COD_TPOPR,
      V_TIPO_DOC,
      V_NUM_DOC,
      K_USUARIO,
      K_CODERROR,
      K_DESCERROR
    );

    IF K_CODERROR <> 0 THEN
      RAISE EX_ERREXT;
    END IF;
  END LOOP;

EXCEPTION
  WHEN EX_ERREXT THEN
    K_CODERROR := K_CODERROR;
    K_DESCERROR := SUBSTR(K_DESCERROR, 1, 250);
  WHEN OTHERS THEN
    K_CODERROR := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_ENT_BONO_MASIVO;

--****************************************************************
-- Nombre SP           :  ADMPSI_REG_KARDEX
-- Propósito           :  Registra en tabla ADMPT_KARDEX
-- Input               :  K_COD_CLI   --Número de línea
--                        K_COD_CPTO  --Código de concepto
--                        K_FEC_TRANS --Fecha de transacción
--                        K_PUNTOS    --Puntos
--                        K_NOM_ARCH  --Nombre de archivo
--                        K_TPO_OPER  --Tipo de operación
--                        K_TPO_PUNTO --Tipo de punto
--                        K_SLD_PUNTO --Saldod de puntos
--                        K_TIPPREMIO --Tipo de premio
--                        K_DESC_PROM --Descripción de promoción
--                        K_FEC_VCMTO --Fecha de vencimiento
--                        K_ESTADO    --Estado
--                        K_USUARIO   --Usuario de proceso
-- Output              :  K_IDKARDEX  --Código de Kardex
--                        K_CODERROR  --Código de error o éxito
--                        K_DESCERROR --Descripción del error
-- Creado por          :  Oscar Paucar Pérez
-- Fec Creación        :  30/07/2013
-- Fec Actualización   :
--****************************************************************
PROCEDURE ADMPSI_REG_KARDEX(K_COD_CLI IN VARCHAR2,
                            K_COD_CPTO IN VARCHAR2,
                            K_FEC_TRANS IN DATE,
                            K_PUNTOS IN NUMBER,
                            K_NOM_ARCH IN VARCHAR2,
                            K_TPO_OPER IN VARCHAR2,
                            K_TPO_PUNTO IN VARCHAR2,
                            K_SLD_PUNTO IN NUMBER,
                            K_TIPPREMIO IN VARCHAR2,
                            K_DESC_PROM IN VARCHAR2,
                            K_FEC_VCMTO IN DATE,
                            K_ESTADO IN VARCHAR2,
                            K_USUARIO IN VARCHAR2,
                            K_IDKARDEX OUT NUMBER,
                            K_CODERROR OUT NUMBER,
                            K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
V_COUNT_IB NUMBER;
V_COD_CLI_IB NUMBER;

BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';

  SELECT NVL(PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,0) INTO K_IDKARDEX FROM DUAL;

  IF K_IDKARDEX = 0 THEN
    K_CODERROR := 39;
    K_DESCERROR := 'No se generó un correlativo en tabla ADMPT_KARDEX. ';
    RAISE EX_ERROR;
  END IF;

  --Verificamos si el Cliente cuenta con código IBK
    SELECT COUNT(*)
      INTO V_COUNT_IB
      FROM PCLUB.ADMPT_CLIENTEIB
     WHERE ADMPV_COD_CLI = K_COD_CLI
       AND ADMPC_ESTADO = 'A';

    IF V_COUNT_IB = 0 THEN
      V_COD_CLI_IB := '';
    ELSE
      SELECT ADMPN_COD_CLI_IB
        INTO V_COD_CLI_IB
        FROM PCLUB.ADMPT_CLIENTEIB
       WHERE ADMPV_COD_CLI = K_COD_CLI
         AND ADMPC_ESTADO = 'A';
    END IF;

  INSERT INTO PCLUB.ADMPT_KARDEX
  (
    ADMPN_ID_KARDEX,
    ADMPV_COD_CLI,
    ADMPN_COD_CLI_IB,
    ADMPV_COD_CPTO,
    ADMPD_FEC_TRANS,
    ADMPN_PUNTOS,
    ADMPV_NOM_ARCH,
    ADMPC_TPO_OPER,
    ADMPC_TPO_PUNTO,
    ADMPN_SLD_PUNTO,
    ADMPN_TIP_PREMIO,
    ADMPV_DESC_PROM,
    ADMPD_FEC_VCMTO,
    ADMPC_ESTADO,
    ADMPV_USU_REG
  )
  VALUES
  (
    K_IDKARDEX,
    K_COD_CLI,
    V_COD_CLI_IB,
    K_COD_CPTO,
    K_FEC_TRANS,
    K_PUNTOS,
    K_NOM_ARCH,
    K_TPO_OPER,
    K_TPO_PUNTO,
    K_SLD_PUNTO,
    K_TIPPREMIO,
    K_DESC_PROM,
    K_FEC_VCMTO,
    K_ESTADO,
    K_USUARIO
  );

EXCEPTION
  WHEN EX_ERROR THEN
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR EN SP ADMPSI_REG_KARDEX. ';
    END;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_REG_KARDEX;

--****************************************************************
-- Nombre SP           :  ADMPSI_REG_SALDOS_CLIE
-- Propósito           :  Registra en tabla ADMPT_SALDOS_CLIENTE
-- Input               :  K_COD_CLI    --Número de línea
--                        K_COD_CLI_IB --Código de cliente IB
--                        K_SALDO_CC   --Saldo CC
--                        K_SALDO_IB   --Saldo IB
--                        K_ESTPTO_CC  --Estado CC
--                        K_ESTPTO_IB  --Estado IB
-- Output              :  K_IDSALDO    --Código de Saldo
--                        K_CODERROR   --Código de error o éxito
--                        K_DESCERROR  --Descripción del error
-- Creado por          :  Oscar Paucar Pérez
-- Fec Creación        :  30/07/2013
-- Fec Actualización   :
--****************************************************************
PROCEDURE ADMPSI_REG_SALDOS_CLIE(K_COD_CLI IN VARCHAR2,
                                 K_COD_CLI_IB NUMBER,
                                 K_SALDO_CC IN NUMBER,
                                 K_SALDO_IB IN NUMBER,
                                 K_ESTPTO_CC IN VARCHAR2,
                                 K_ESTPTO_IB IN VARCHAR2,
                                 K_IDSALDO OUT NUMBER,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';

  SELECT NVL(PCLUB.ADMPT_SLD_CL_SQ.NEXTVAL,0) INTO K_IDSALDO FROM DUAL;

  IF K_IDSALDO = 0 THEN
    K_CODERROR := 39;
    K_DESCERROR := 'No se generó un correlativo en tabla ADMPT_SALDOS_CLIENTE. ';
    RAISE EX_ERROR;
  END IF;

  INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE
  (
    ADMPN_ID_SALDO,
    ADMPV_COD_CLI,
    ADMPN_COD_CLI_IB,
    ADMPN_SALDO_CC,
    ADMPN_SALDO_IB,
    ADMPC_ESTPTO_CC,
    ADMPC_ESTPTO_IB,
    ADMPD_FEC_REG
  )
  VALUES
  (
    K_IDSALDO,
    K_COD_CLI,
    K_COD_CLI_IB,
    K_SALDO_CC,
    K_SALDO_IB,
    K_ESTPTO_CC,
    K_ESTPTO_IB,
    SYSDATE
  );

EXCEPTION
  WHEN EX_ERROR THEN
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR EN SP ADMPSI_REG_SALDOS_CLIE. ';
    END;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_REG_SALDOS_CLIE;

--****************************************************************
-- Nombre SP           :  ADMPSI_REG_CLIENTE
-- Propósito           :  Registra en tabla ADMPT_CLIENTE
-- Input               :  K_COD_CLI       --Número de línea
--                        K_COD_SEGCLI    --Segmento del cliente
--                        K_COD_CATCLI    --Categoría del cliente
--                        K_TIPO_DOC      --Código del tipo de documento
--                        K_NUM_DOC       --Número del documento
--                        K_NOM_CLI       --Nombres
--                        K_APE_CLI       --Apellidos
--                        K_SEXO          --Sexo
--                        K_ESTADOCIVIL   --Estado civil
--                        K_EMAIL         --Email
--                        K_DPTO          --Departamento
--                        K_PROVINCIA     --Provincia
--                        K_DISTRITO      --Distrito
--                        K_FEC_ACTIV     --Fecha de activación
--                        K_CICL_FACT     --Ciclo de facturación
--                        K_ESTADO        --Estado
--                        K_COD_TPOCL     --Tipo de cliente
--                        K_USUARIO       --Usuario de proceso
-- Output              :  K_IDCLIENTE     --Código de cliente
--                        K_CODERROR      --Código de error o éxito
--                        K_DESCERROR     --Descripción del error
-- Creado por          :  Oscar Paucar Pérez
-- Fec Creación        :  30/07/2013
-- Fec Actualización   :
--****************************************************************
PROCEDURE ADMPSI_REG_CLIENTE(K_COD_CLI IN VARCHAR2,
                             K_COD_SEGCLI VARCHAR2,
                             K_COD_CATCLI IN VARCHAR2,
                             K_TIPO_DOC IN VARCHAR2,
                             K_NUM_DOC IN VARCHAR2,
                             K_NOM_CLI IN VARCHAR2,
                             K_APE_CLI IN VARCHAR2,
                             K_SEXO IN VARCHAR2,
                             K_EST_CIVIL IN VARCHAR2,
                             K_EMAIL IN VARCHAR2,
                             K_DPTO IN VARCHAR2,
                             K_PROVINCIA IN VARCHAR2,
                             K_DISTRITO IN VARCHAR2,
                             K_FEC_ACTIV IN DATE,
                             K_CICL_FACT IN VARCHAR2,
                             K_ESTADO IN VARCHAR2,
                             K_COD_TPOCL IN VARCHAR2,
                             K_USUARIO IN VARCHAR2,
                             K_IDCLIENTE OUT VARCHAR2,
                             K_CODERROR OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';
  K_IDCLIENTE := K_COD_CLI;

  INSERT INTO PCLUB.ADMPT_CLIENTE
  (
    ADMPV_COD_CLI,
    ADMPV_COD_SEGCLI,
    ADMPN_COD_CATCLI,
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
    ADMPV_CICL_FACT,
    ADMPC_ESTADO,
    ADMPV_COD_TPOCL,
    ADMPD_FEC_REG,
    ADMPV_USU_REG
  )
  VALUES
  (
    K_COD_CLI,
    K_COD_SEGCLI,
    K_COD_CATCLI,
    K_TIPO_DOC,
    K_NUM_DOC,
    K_NOM_CLI,
    K_APE_CLI,
    K_SEXO,
    K_EST_CIVIL,
    K_EMAIL,
    K_DPTO,
    K_PROVINCIA,
    K_DISTRITO,
    K_FEC_ACTIV,
    K_CICL_FACT,
    K_ESTADO,
    K_COD_TPOCL,
    SYSDATE,
    K_USUARIO
  );

EXCEPTION
  WHEN EX_ERROR THEN
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR EN SP ADMPSI_REG_CLIENTE. ';
    END;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_REG_CLIENTE;

--****************************************************************
-- Nombre SP           :  ADMPSI_REG_KARDEX
-- Propósito           :  Registra en tabla ADMPT_SALDOS_BONO_CLIENTE
-- Input               :  K_COD_CLI     --Número de línea
--                        K_SALDO       --Saldo
--                        K_GRUPO       --Tipo de premio
--                        K_ESTADO      --Estado
--                        K_USUARIO     --Usuario de proceso
-- Output              :  K_IDSALDOSBONO--Código de SaldosBono
--                        K_CODERROR    --Código de error o éxito
--                        K_DESCERROR   --Descripción del error
-- Creado por          :  Oscar Paucar Pérez
-- Fec Creación        :  30/07/2013
-- Fec Actualización   :
--****************************************************************
PROCEDURE ADMPSI_REG_SALDOS_BONO_CLIE(K_COD_CLI IN VARCHAR2,
                                      K_SALDO IN NUMBER,
                                      K_GRUPO IN VARCHAR2,
                                      K_ESTADO IN VARCHAR2,
                                      K_USUARIO IN VARCHAR2,
                                      K_IDSALDOSBONO OUT NUMBER,
                                      K_CODERROR OUT NUMBER,
                                      K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';

  SELECT NVL(PCLUB.ADMPT_SALDOS_BONO_CLIENTE_SQ.NEXTVAL,0) INTO K_IDSALDOSBONO FROM DUAL;

  IF K_IDSALDOSBONO = 0 THEN
    K_CODERROR := 39;
    K_DESCERROR := 'No se generó un correlativo en tabla ADMPT_SALDOS_BONO_CLIENTE. ';
    RAISE EX_ERROR;
  END IF;

  INSERT INTO PCLUB.ADMPT_SALDOS_BONO_CLIENTE
  (
    ADMPN_ID_SALDOBON,
    ADMPV_COD_CLI,
    ADMPN_SALDO,
    ADMPN_GRUPO,
    ADMPV_ESTADO,
    ADMPV_USU_REG
  )
  VALUES
  (
    K_IDSALDOSBONO,
    K_COD_CLI,
    K_SALDO,
    K_GRUPO,
    K_ESTADO,
    K_USUARIO
  );

EXCEPTION
  WHEN EX_ERROR THEN
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR EN SP ADMPSI_REG_SALDOS_BONO_CLIE. ';
    END;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSI_REG_SALDOS_BONO_CLIE;

--****************************************************************
-- Nombre SP           :  ADMPSS_TMP_BONOFIDEL_PRE
-- Propósito           :  Lista registros de tabla ADMPT_BONO_CONFIG
-- Input               :  K_TIPOFIDEL --(M):6meses (A):12meses
--                        K_NOMARCH   --Nombre del archivo
-- Output              :  K_NUMREG    --Número de registros
--                        K_CODERROR  --Código de error o éxito
--                        K_DESCERROR --Descripción del error
-- Creado por          :  Oscar Paucar Pérez
-- Fec Creación        :  30/07/2013
-- Fec Actualización   :
--****************************************************************
PROCEDURE ADMPSS_TMP_BONOFIDEL_PRE(K_TIPOFIDEL IN VARCHAR2,
                                   K_NOMARCH IN VARCHAR2,
                                   K_NUMREG OUT NUMBER,
                                   K_CODERROR OUT NUMBER,
                                   K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_TIPOFIDEL IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el tipo de bono de fidelidad.'; RAISE EX_ERROR;
    WHEN K_NOMARCH   IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el nombre del archivo.'; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  SELECT COUNT(1) INTO K_NUMREG
  FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE
  WHERE ADMPC_TIPO_FIDEL = K_TIPOFIDEL
        AND ADMPV_NOMARCHIVO = K_NOMARCH;

EXCEPTION
  WHEN EX_ERROR THEN
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR EN SP ADMPSS_TMP_BONOFIDEL_PRE. ';
    END;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSS_TMP_BONOFIDEL_PRE;

--****************************************************************
-- Nombre SP           :  ADMPSS_TMP_EBONOFIDEL_PRE
-- Propósito           :  Lista registros errados
-- Input               :  K_TIPOFIDEL --(M):6meses (A):12meses
--                        K_NOMARCH   --Nombre del archivo
-- Output              :  K_CUR_LISTA --Cursor de datos
--                        K_CODERROR  --Código de error o éxito
--                        K_DESCERROR --Descripción del error
-- Creado por          :  Oscar Paucar Pérez
-- Fec Creación        :  16/08/2013
-- Fec Actualización   :
--****************************************************************
PROCEDURE ADMPSS_TMP_EBONOFIDEL_PRE(K_TIPOFIDEL IN VARCHAR2,
                                    K_NOMARCH IN VARCHAR2,
                                    K_CUR_LISTA OUT SYS_REFCURSOR,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_TIPOFIDEL IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el tipo de bono de fidelidad.'; RAISE EX_ERROR;
    WHEN K_NOMARCH   IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el nombre del archivo.'; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  OPEN K_CUR_LISTA FOR
  SELECT ADMPN_SEC,
         ADMPV_LINEA,
         ADMPV_CODERROR,
         ADMPV_MSJERROR
  FROM PCLUB.ADMPT_IMP_BONOFIDEL_PRE
  WHERE ADMPC_TIPO_FIDEL = K_TIPOFIDEL
        AND ADMPV_NOMARCHIVO = K_NOMARCH
        AND ADMPV_CODERROR IS NOT NULL;

EXCEPTION
  WHEN EX_ERROR THEN
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR EN SP ADMPSS_TMP_EBONOFIDEL_PRE. ';
    END;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END ADMPSS_TMP_EBONOFIDEL_PRE;

--****************************************************************
-- Nombre SP           :  ADMPSI_ENTR_BONOFID12M
-- Propósito           :  Entregar los bonos de puntos por Fidelidad 12 Meses
-- Input               :  K_NOM_ARCHIVO -> Nombre del archivo
--                     :  K_BONO      -> Código del bono
--                     :  K_USUARIO   -> Usuario de proceso
-- Output              :  K_CODERROR  -> Código de error o éxito
--                        K_DESCERROR -> Descripción del error
-- Creado por          :  Jorge Luis Ortiz Castillo
-- Fec Creación        :  26/07/2013
--****************************************************************
PROCEDURE ADMPSI_ENTR_BONOFID12M(K_NOM_ARCHIVO IN VARCHAR2,
                                 K_BONO IN VARCHAR2,
                                 K_USUARIO IN VARCHAR2,
                                 K_CODERROR  OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2,
                                 K_TOT_PROC OUT NUMBER,
                                 K_TOT_EXI OUT NUMBER,
                                 K_TOT_ERR OUT NUMBER) IS
  -- Variables Datos de Clientes Prepago
  V_LINEA VARCHAR2(20);
  V_TIPO_DOC VARCHAR2(20);
  V_NUM_DOC VARCHAR2(20);
  V_NOM VARCHAR2(80);
  V_APE VARCHAR2(80);
  V_SEXO VARCHAR2(10);
  V_EST_CIVIL VARCHAR2(20);
  V_MAIL VARCHAR(100);
  V_DIST VARCHAR(50);
  V_PROV VARCHAR(50);
  V_DPTO VARCHAR(200);
  V_FEC_ACT DATE;
  V_SEC NUMBER;
  V_NOM_ARCH VARCHAR2(150);
  V_TIPO_FID CHAR(1);
  V_FECH_OPE DATE;
  V_ID_BONO VARCHAR(20);
  V_DESC_BONO VARCHAR(500);
  V_CUR_BONOS SYS_REFCURSOR;
  V_CODMJS VARCHAR2(40);
  V_CODERROR NUMBER;
  V_DESCERROR VARCHAR2(800);

  -- Contadores
  V_COUNT NUMBER;

  -- Variables de Configuracion del Bono
  V_BONO VARCHAR2(20);
  V_PUNTOS NUMBER;
  V_COD_TPRE VARCHAR2(2);
  V_COD_CPTO VARCHAR2(2);
  V_DIAS_VIG NUMBER;
  VT_BONOCONFIG PCLUB.T_BONOCONFIG;
  VT_TBLBONOCONFIG T_TBLBONOCONFIG := T_TBLBONOCONFIG();
  V_TAM_LOTE NUMBER;

  -- Variables Exceptiones
  EX_ERROR_IN EXCEPTION;
  EX_ERROR_EX EXCEPTION;

  -- Cursor
  CURSOR V_CUR_LINEAS(V_TPO_FID CHAR, V_NOM_FILE VARCHAR2) IS
    SELECT TMP.ADMPN_SEC,
           TMP.ADMPV_LINEA,
           TD.ADMPV_COD_TPDOC,
           TMP.ADMPV_NRO_DOCU,
           TMP.ADMPV_NOMBRES,
           TMP.ADMPV_APELLIDOS,
           TMP.ADMPV_SEXO,
           TMP.ADMPV_EST_CIVIL,
           TMP.ADMPV_EMAIL,
           TMP.ADMPV_DISTRITO,
           TMP.ADMPV_PROVINCIA,
           TMP.ADMPV_DPTO,
           TMP.ADMPD_FEC_ACTIVA,
           TMP.ADMPV_NOMARCHIVO
    FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE TMP
    INNER JOIN PCLUB.ADMPT_TIPO_DOC TD
          ON UPPER(TD.ADMPV_EQU_DWH) = UPPER(TMP.ADMPV_TIPO_DOCU)
    WHERE TMP.ADMPV_CODERROR IS NULL
          AND TMP.ADMPC_TIPO_FIDEL = V_TPO_FID
          AND TMP.ADMPV_NOMARCHIVO = V_NOM_FILE
          ORDER BY 1;
BEGIN
  V_TIPO_FID := 'A';
  V_FECH_OPE := TRUNC(SYSDATE);
  K_TOT_PROC := 0;
  K_TOT_EXI := 0;
  K_TOT_ERR := 0;
  K_CODERROR := 0;
  K_DESCERROR := '';


  IF K_BONO IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR := ' No se ingresó el código del bono.';
    RAISE EX_ERROR_IN;
  END IF;

  V_ID_BONO := UPPER(K_BONO);

  -- obtener la(s) configuraciones del bono
  PCLUB.PKG_CC_BONOS.ADMPSS_OBT_CONFIG(V_ID_BONO,
                                    NULL,
                                    V_DESC_BONO,
                                    V_CODMJS,
                                    V_CUR_BONOS,
                                    V_CODERROR,
                                    V_DESCERROR);

  IF V_CODERROR <> 0 THEN
    RAISE EX_ERROR_EX;
  END IF;

  -- obtenemos las configuracion devueltas en el cursor
  V_COUNT := 0;

  FETCH V_CUR_BONOS INTO V_BONO, V_PUNTOS, V_COD_CPTO,
                         V_DIAS_VIG, V_COD_TPRE;

  WHILE V_CUR_BONOS%FOUND LOOP
    V_COUNT := V_COUNT + 1;
    VT_BONOCONFIG := PCLUB.T_BONOCONFIG(NULL,NULL,NULL,NULL,NULL);
    VT_BONOCONFIG.BONO := V_BONO;
    VT_BONOCONFIG.PUNTOS := V_PUNTOS;
    VT_BONOCONFIG.COD_CPTO := V_COD_CPTO;
    VT_BONOCONFIG.DIASVIGEN := V_DIAS_VIG;
    VT_BONOCONFIG.COD_TPOPR := V_COD_TPRE;
    VT_TBLBONOCONFIG.EXTEND;
    VT_TBLBONOCONFIG(V_COUNT) := VT_BONOCONFIG;

    FETCH V_CUR_BONOS INTO V_BONO, V_PUNTOS, V_COD_CPTO,
                           V_DIAS_VIG, V_COD_TPRE;
  END LOOP;

  CLOSE V_CUR_BONOS;

  IF V_COUNT = 0 THEN
    K_CODERROR := 50;
    K_DESCERROR := 'ORA: No se encontró configuraciones para el bono enviado.';
    RAISE EX_ERROR_IN;
  END IF;

  -- obtenemos el tamaño de cada lote
  BEGIN
    SELECT ADMPV_VALOR INTO V_TAM_LOTE
    FROM PCLUB.ADMPT_PARAMSIST
    WHERE ADMPV_DESC = 'CANT_REG_COMMIT_PROC_MASIVO';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      K_CODERROR := 50;
      K_DESCERROR := 'ORA: No está registrado el parámetro CANT_REG_COMMIT_PROC_MASIVO';
      RAISE EX_ERROR_IN;
  END;

  -- identificar los registros de tmp con errores
  PKG_CC_BONOS.ADMPSU_ENT_BONOFIDEL_VALIDA(V_TIPO_FID, K_NOM_ARCHIVO,
                                           V_CODERROR, V_DESCERROR);

  IF V_CODERROR <> 0 THEN
     RAISE EX_ERROR_EX;
  END IF;

  -- obtenemos el total de archivos cargados
  SELECT COUNT(1) INTO K_TOT_PROC
  FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE BF
  WHERE BF.ADMPV_NOMARCHIVO = K_NOM_ARCHIVO
        AND BF.ADMPC_TIPO_FIDEL = V_TIPO_FID;

  -- abrimos el cursor de lineas
  OPEN V_CUR_LINEAS(V_TIPO_FID, K_NOM_ARCHIVO);

  V_COUNT := 0;
  FETCH V_CUR_LINEAS INTO V_SEC, V_LINEA, V_TIPO_DOC, V_NUM_DOC,
                          V_NOM, V_APE, V_SEXO, V_EST_CIVIL,
                          V_MAIL, V_DIST, V_PROV, V_DPTO,
                          V_FEC_ACT, V_NOM_ARCH;


  WHILE V_CUR_LINEAS%FOUND LOOP
    V_COUNT := V_COUNT + 1;

    PCLUB.PKG_CC_BONOS.ADMPSI_ENT_BONO_MASIVO(V_NOM_ARCH,V_LINEA,V_TIPO_DOC, V_NUM_DOC,
                                           V_NOM, V_APE, V_SEXO, V_EST_CIVIL,
                                           V_MAIL, V_DPTO, V_PROV, V_DIST,
                                           V_FEC_ACT, VT_TBLBONOCONFIG, K_USUARIO,
                                           V_CODERROR, V_DESCERROR);

    -- evaluamos el resultado del proceso
    IF V_CODERROR = 0 THEN
      -- actualizamos el estado a procesado del registro actual
      UPDATE PCLUB.ADMPT_TMP_BONOFIDEL_PRE
      SET ADMPC_ESTADO = 'P'
      WHERE ADMPN_SEC = V_SEC;

      K_TOT_EXI := K_TOT_EXI + 1;
    ELSE
      -- actualizamos el estado a procesado y el codigo y mensaje de error
      UPDATE PCLUB.ADMPT_TMP_BONOFIDEL_PRE
      SET ADMPC_ESTADO = 'P',
          ADMPV_CODERROR = V_CODERROR,
          ADMPV_MSJERROR = V_DESCERROR
      WHERE ADMPN_SEC = V_SEC;

    END IF;

    IF V_COUNT = V_TAM_LOTE THEN

      INSERT INTO PCLUB.ADMPT_IMP_BONOFIDEL_PRE(ADMPN_SEC,ADMPV_LINEA,
                                          ADMPV_TIPO_DOCU, ADMPV_NRO_DOCU,
                                          ADMPV_NOMBRES, ADMPV_APELLIDOS,
                                          ADMPV_SEXO, ADMPV_EST_CIVIL,
                                          ADMPV_EMAIL, ADMPV_DISTRITO,
                                          ADMPV_PROVINCIA, ADMPV_DPTO,
                                          ADMPD_FEC_ACTIVA,ADMPC_TIPO_FIDEL,
                                          ADMPV_NOMARCHIVO, ADMPD_FEC_OPERA,
                                          ADMPD_FEC_REG, ADMPC_ESTADOSMS)
      SELECT PCLUB.ADMPT_IMP_BONOFIDEL_PRE_SQ.NEXTVAL,TMP.ADMPV_LINEA,
             TMP.ADMPV_TIPO_DOCU,TMP.ADMPV_NRO_DOCU,
             TMP.ADMPV_NOMBRES,TMP.ADMPV_APELLIDOS,
             TMP.ADMPV_SEXO, TMP.ADMPV_EST_CIVIL,
             TMP.ADMPV_EMAIL,TMP.ADMPV_DISTRITO,
             TMP.ADMPV_PROVINCIA, TMP.ADMPV_DPTO,
             TMP.ADMPD_FEC_ACTIVA, TMP.ADMPC_TIPO_FIDEL,
             TMP.ADMPV_NOMARCHIVO, V_FECH_OPE,
             SYSDATE, 'P'
      FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE TMP
      WHERE TMP.ADMPC_TIPO_FIDEL = V_TIPO_FID
            AND TMP.ADMPV_NOMARCHIVO = K_NOM_ARCHIVO
            AND TMP.ADMPC_ESTADO='P';

      DELETE FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE
      WHERE ADMPV_NOMARCHIVO = K_NOM_ARCHIVO
            AND ADMPC_TIPO_FIDEL = V_TIPO_FID
            AND ADMPC_ESTADO='P';

      COMMIT;

      V_COUNT := 0;
    END IF;

    FETCH V_CUR_LINEAS INTO V_SEC, V_LINEA, V_TIPO_DOC, V_NUM_DOC,
                        V_NOM, V_APE, V_SEXO, V_EST_CIVIL,
                        V_MAIL, V_DIST, V_PROV, V_DPTO,
                        V_FEC_ACT, V_NOM_ARCH;
  END LOOP;

    -- insertamos todos aquellos registros procesados
  INSERT INTO PCLUB.ADMPT_IMP_BONOFIDEL_PRE(ADMPN_SEC, ADMPV_LINEA,
                                    ADMPV_TIPO_DOCU, ADMPV_NRO_DOCU,
                                    ADMPV_NOMBRES, ADMPV_APELLIDOS,
                                    ADMPV_SEXO, ADMPV_EST_CIVIL,
                                    ADMPV_EMAIL, ADMPV_DISTRITO,
                                    ADMPV_PROVINCIA, ADMPV_DPTO,
                                    ADMPD_FEC_ACTIVA,ADMPC_TIPO_FIDEL,
                                    ADMPV_NOMARCHIVO,ADMPD_FEC_OPERA,
                                    ADMPD_FEC_REG, ADMPC_ESTADOSMS)
  SELECT PCLUB.ADMPT_IMP_BONOFIDEL_PRE_SQ.NEXTVAL,TMP.ADMPV_LINEA,
       TMP.ADMPV_TIPO_DOCU,TMP.ADMPV_NRO_DOCU,
       TMP.ADMPV_NOMBRES,TMP.ADMPV_APELLIDOS,
       TMP.ADMPV_SEXO, TMP.ADMPV_EST_CIVIL,
       TMP.ADMPV_EMAIL,TMP.ADMPV_DISTRITO,
       TMP.ADMPV_PROVINCIA, TMP.ADMPV_DPTO,
       TMP.ADMPD_FEC_ACTIVA, TMP.ADMPC_TIPO_FIDEL,
       TMP.ADMPV_NOMARCHIVO, V_FECH_OPE,
       SYSDATE, 'P'
  FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE TMP
  WHERE TMP.ADMPC_TIPO_FIDEL = V_TIPO_FID
      AND TMP.ADMPV_NOMARCHIVO = K_NOM_ARCHIVO
      AND TMP.ADMPC_ESTADO='P';

  DELETE FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE
  WHERE ADMPV_NOMARCHIVO = K_NOM_ARCHIVO
        AND ADMPC_TIPO_FIDEL = V_TIPO_FID
        AND ADMPC_ESTADO='P';

  -- insertamos los registros erróneos
  INSERT INTO PCLUB.ADMPT_IMP_BONOFIDEL_PRE(ADMPN_SEC, ADMPV_LINEA,
                                      ADMPV_TIPO_DOCU, ADMPV_NRO_DOCU,
                                      ADMPV_NOMBRES, ADMPV_APELLIDOS,
                                      ADMPV_SEXO, ADMPV_EST_CIVIL,
                                      ADMPV_EMAIL, ADMPV_DISTRITO,
                                      ADMPV_PROVINCIA, ADMPV_DPTO,
                                      ADMPD_FEC_ACTIVA, ADMPC_TIPO_FIDEL,
                                      ADMPV_NOMARCHIVO,ADMPD_FEC_OPERA,
                                      ADMPD_FEC_REG, ADMPV_CODERROR,
                                      ADMPV_MSJERROR )
  SELECT PCLUB.ADMPT_IMP_BONOFIDEL_PRE_SQ.NEXTVAL,TMP.ADMPV_LINEA,
         TMP.ADMPV_TIPO_DOCU,TMP.ADMPV_NRO_DOCU,
         TMP.ADMPV_NOMBRES,TMP.ADMPV_APELLIDOS,
         TMP.ADMPV_SEXO, TMP.ADMPV_EST_CIVIL,
         TMP.ADMPV_EMAIL,TMP.ADMPV_DISTRITO,
         TMP.ADMPV_PROVINCIA, TMP.ADMPV_DPTO,
         TMP.ADMPD_FEC_ACTIVA, TMP.ADMPC_TIPO_FIDEL,
         TMP.ADMPV_NOMARCHIVO, V_FECH_OPE,
         SYSDATE, TMP.ADMPV_CODERROR,
         TMP.ADMPV_MSJERROR
  FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE TMP
  WHERE TMP.ADMPC_TIPO_FIDEL = V_TIPO_FID
        AND TMP.ADMPV_NOMARCHIVO = K_NOM_ARCHIVO
        AND TMP.ADMPV_CODERROR IS NOT NULL;

  -- Obtenemos el numero de registros erróneos
  SELECT COUNT(1) INTO K_TOT_ERR
  FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE TMP
  WHERE TMP.ADMPC_TIPO_FIDEL = V_TIPO_FID
        AND TMP.ADMPV_NOMARCHIVO = K_NOM_ARCHIVO
        AND TMP.ADMPV_CODERROR IS NOT NULL;

  -- eliminamos los registros erróneos
  DELETE FROM PCLUB.ADMPT_TMP_BONOFIDEL_PRE
  WHERE ADMPV_NOMARCHIVO = K_NOM_ARCHIVO
        AND ADMPC_TIPO_FIDEL = V_TIPO_FID;

  COMMIT;

  CLOSE V_CUR_LINEAS;

  SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
  FROM PCLUB.ADMPT_ERRORES_CC
  WHERE ADMPN_COD_ERROR = K_CODERROR;

EXCEPTION

  WHEN EX_ERROR_IN THEN
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
      FROM PCLUB.ADMPT_ERRORES_CC
      WHERE ADMPN_COD_ERROR = K_CODERROR;

      ROLLBACK;
    END;

  WHEN EX_ERROR_EX THEN
    BEGIN
      K_CODERROR := V_CODERROR;
      K_DESCERROR := V_DESCERROR;

      ROLLBACK;
    END;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

    ROLLBACK;
END ADMPSI_ENTR_BONOFID12M;


PROCEDURE ADMPSI_PREVENCPTOBONO(K_USUARIO IN VARCHAR2,
                                K_TOT_PROC OUT NUMBER,
                                K_TOT_EXI OUT NUMBER,
                                K_TOT_ERR OUT NUMBER,
                                K_CODERROR  OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2) IS
    --****************************************************************
    -- Nombre SP           :  ADMPSI_PREVENCPTOBONO
    -- Propósito           :  Dar de baja los puntos entregado por Bono
    -- Input               :  K_USUARIO   -> Usuario de proceso
    -- Output              :  K_CODERROR  -> Código de error o éxito
    --                        K_DESCERROR -> Descripción del error
    -- Creado por          :  Jorge Luis Ortiz Castillo
    -- Fec Creación        :  26/07/2013
    --****************************************************************

    IN_ERROR EXCEPTION;

    V_COD_CPTO_E VARCHAR2(3);
    V_COD_CPTO_S VARCHAR2(3);
    V_FEC_ACTUAL DATE;

    V_LINEA VARCHAR2(40);
    V_PUNTOS NUMBER;
    V_TPO_PREMIO VARCHAR2(2);

    V_TPO_PUNTO CHAR(1);
    V_ESTADO CHAR(1);
    V_TPO_OPE CHAR(1);

    V_TAM_LOTE NUMBER;
    V_COUNT NUMBER := 0;

    V_CODERROR NUMBER;
    V_DESERROR VARCHAR2(400);
    V_ID_KARDEX NUMBER;
    V_FLAG_COMM NUMBER;

    CURSOR V_CUR_LINEAS_PTOSVENCE(V_FEC DATE, V_TPTO CHAR) IS
    SELECT K.ADMPV_COD_CLI,
           K.ADMPN_TIP_PREMIO,
           K.ADMPV_COD_CPTO,
           SUM(K.ADMPN_SLD_PUNTO)
    FROM PCLUB.ADMPT_KARDEX K
    WHERE K.ADMPC_TPO_OPER = 'E'
       AND K.ADMPC_TPO_PUNTO = V_TPTO
       AND K.ADMPC_ESTADO = 'A'
       AND K.ADMPD_FEC_VCMTO < V_FEC
       AND K.ADMPN_SLD_PUNTO > 0
       AND K.ADMPV_COD_CPTO IN (SELECT BC.ADMPV_COD_CPTO
                                FROM PCLUB.ADMPT_BONO_CONFIG BC
                                WHERE BC.ADMPV_BONO IN (SELECT BO.ADMPV_BONO
                                                        FROM PCLUB.ADMPT_BONO BO
                                                        WHERE BO.ADMPV_TYPEBONO IS NULL
                                                        GROUP BY BO.ADMPV_BONO)
                                 GROUP BY BC.ADMPV_COD_CPTO)
    GROUP BY K.ADMPV_COD_CLI, K.ADMPN_TIP_PREMIO, K.ADMPV_COD_CPTO;

  BEGIN
    K_TOT_PROC     := 0;
    K_TOT_EXI      := 0;
    K_TOT_ERR      := 0;
    K_CODERROR     := 0;
    K_DESCERROR    := '';

    V_ESTADO       := 'V'; -- Activo
    V_TPO_OPE      := 'S'; -- Salida
    V_TPO_PUNTO    := 'B'; -- BONO

    V_CODERROR    := 0;
    V_DESERROR    := '';

    -- modificar el SP PKG_CC_PREPAGO.ADMPSI_PREVENCPTO
    -- para excluir a los que tiene fecha de vcto <> NULL

    SELECT C.ADMPV_COD_CPTO INTO V_COD_CPTO_S
    FROM   PCLUB.ADMPT_CONCEPTO C
    WHERE  C.ADMPV_DESC = 'VENCIMIENTO DE PUNTO BONO PREPAGO';

    IF V_COD_CPTO_S IS NULL THEN
      K_CODERROR := 50;
      K_DESCERROR := ' Error al obtener el concepto para el proceso.';
      RAISE IN_ERROR;
    END IF;

    -- obtenemos el tamaño de cada lote
    BEGIN
      SELECT ADMPV_VALOR INTO V_TAM_LOTE
      FROM  PCLUB.ADMPT_PARAMSIST
      WHERE ADMPV_DESC = 'CANT_REG_COMMIT_PROC_MASIVO';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        K_CODERROR := 50;
        K_DESCERROR := 'ORA: No está registrado el parámetro CANT_REG_COMMIT_PROC_MASIVO';
        RAISE IN_ERROR;
    END;

    -- obtenemos la fecha actual
    SELECT TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY') INTO V_FEC_ACTUAL
    FROM DUAL;

    OPEN V_CUR_LINEAS_PTOSVENCE(V_FEC_ACTUAL, V_TPO_PUNTO);

    -- primer registro
    FETCH V_CUR_LINEAS_PTOSVENCE INTO V_LINEA, V_TPO_PREMIO, V_COD_CPTO_E , V_PUNTOS;

    WHILE V_CUR_LINEAS_PTOSVENCE%FOUND LOOP

       PCLUB.PKG_CC_BONOS.ADMPSI_REG_KARDEX(V_LINEA,
                                     V_COD_CPTO_S,
                                     TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'),
                                     (V_PUNTOS * (-1)),
                                     '',
                                     V_TPO_OPE,
                                     'B',
                                     0,
                                     V_TPO_PREMIO,
                                     '',
                                     NULL,
                                     V_ESTADO,
                                     K_USUARIO,
                                     V_ID_KARDEX,
                                     V_CODERROR,
                                     V_DESERROR);

      -- actualizamos los movimientos de entrada que estamos dando de baja
      IF V_CODERROR = 0 THEN
            UPDATE  PCLUB.ADMPT_KARDEX K
            SET K.ADMPN_SLD_PUNTO = 0,
                K.ADMPC_ESTADO = 'V'
            WHERE K.ADMPD_FEC_VCMTO < V_FEC_ACTUAL
                  AND K.ADMPV_COD_CPTO = V_COD_CPTO_E
                  AND K.ADMPC_TPO_PUNTO = V_TPO_PUNTO
                  AND K.ADMPV_COD_CLI = V_LINEA
                  AND K.ADMPN_SLD_PUNTO > 0
                  AND K.ADMPC_TPO_OPER = 'E';

        -- Actualizamos las tablas segun el tipo de premio

        IF V_TPO_PREMIO = 0 THEN -- actualizar SALDOS_CLIENTE
          UPDATE  PCLUB.ADMPT_SALDOS_CLIENTE SC
          SET SC.ADMPN_SALDO_CC = SC.ADMPN_SALDO_CC - V_PUNTOS,
              SC.ADMPD_FEC_MOD = SYSDATE
          WHERE SC.ADMPV_COD_CLI = V_LINEA;

        ELSE -- actualizar SALDOS_BONO_CLIENTE

          UPDATE  PCLUB.ADMPT_SALDOS_BONO_CLIENTE BC
          SET BC.ADMPN_SALDO = BC.ADMPN_SALDO - V_PUNTOS,
              BC.ADMPV_USU_MOD = K_USUARIO
          WHERE BC.ADMPV_COD_CLI = V_LINEA
                AND BC.ADMPN_GRUPO = V_TPO_PREMIO
                AND BC.ADMPV_ESTADO = 'A';
        END IF;

        K_TOT_EXI := K_TOT_EXI +1;
      ELSE
        K_TOT_ERR := K_TOT_ERR +1;
      END IF;

      V_COUNT := V_COUNT + 1;
      K_TOT_PROC := K_TOT_PROC + 1;

      INSERT INTO PCLUB.ADMPT_VENCTO_PROC_TMP
      (
      admpv_cod_cli,
      admpn_tip_premio,
      admpv_cod_cpto,
      admpn_sld_punto,
      ESTADO
      )
      VALUES
      (
      V_LINEA,
      V_TPO_PREMIO,
      V_COD_CPTO_E ,
      V_PUNTOS,
      V_CODERROR
      );
      -- Realizamos un commit por cada lote
      IF V_COUNT = V_TAM_LOTE  THEN
        V_COUNT := 0;
        COMMIT;
      END IF;

      -- siguiente registro
      FETCH V_CUR_LINEAS_PTOSVENCE INTO V_LINEA, V_TPO_PREMIO, V_COD_CPTO_E, V_PUNTOS;
    END LOOP;

    CLOSE V_CUR_LINEAS_PTOSVENCE;

    IF K_TOT_PROC > 0 THEN
      SELECT MOD(K_TOT_PROC,V_TAM_LOTE) INTO V_FLAG_COMM
      FROM DUAL;

      IF V_FLAG_COMM <> 0 THEN
        COMMIT;
      END IF;
    END IF;

  EXCEPTION

    WHEN IN_ERROR THEN
      BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
        FROM  PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR = K_CODERROR;

        ROLLBACK;
      END;

    WHEN OTHERS THEN
      K_CODERROR := -1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 200);
      ROLLBACK;
  END ADMPSI_PREVENCPTOBONO;

  PROCEDURE ADMPSI_CONS_BONO(K_TIPOCLIENTE IN VARCHAR2,
                             K_TIPDOC IN VARCHAR2,
                             K_NRODOC IN VARCHAR2,
                             K_LINEA IN VARCHAR2,
                             K_TPO_CONSULTA IN VARCHAR2,
                             K_CUR_BONO_ENT OUT SYS_REFCURSOR,
                             K_CODERROR  OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2) IS
   IN_EXCEPTION EXCEPTION;
  BEGIN

    CASE
      WHEN (K_TIPOCLIENTE IS NULL) AND (K_TIPDOC IS NULL) AND (K_NRODOC IS NULL) AND (K_LINEA IS NULL) AND (K_TPO_CONSULTA IS NULL) THEN
        K_CODERROR := 4; K_DESCERROR := ' No se ha ingresado ningun parametro de entrada.';
      WHEN K_TPO_CONSULTA IS NULL THEN
        K_CODERROR := 4; K_DESCERROR := ' No se ha ingresado el tipo de consulta.';
      ELSE
        K_CODERROR := 0;
        K_DESCERROR := '';
    END CASE;

    IF K_TPO_CONSULTA = 'A' THEN

      CASE
        WHEN K_TIPOCLIENTE IS NULL THEN
          K_CODERROR := 4; K_DESCERROR := ' No se ha ingresado el tipo de cliente.';
          RAISE IN_EXCEPTION;
        WHEN K_TIPDOC IS NULL THEN
          K_CODERROR := 4; K_DESCERROR := ' No se ha ingresado el tipo de documento.';
          RAISE IN_EXCEPTION;
        WHEN K_NRODOC IS NULL THEN
          K_CODERROR := 4; K_DESCERROR := ' No se ha ingresado el número de documento.';
          RAISE IN_EXCEPTION;
        ELSE
          K_CODERROR := 0;
          K_DESCERROR := '';
      END CASE;

      OPEN K_CUR_BONO_ENT FOR
        SELECT BK.ADMPV_LINEA,
               BK.ADMPN_PUNTOS,
               BK.ADMPV_BONO,
               B.ADMPV_DESCBONO,
               TO_CHAR(BK.ADMPD_FEC_ENTBONO,'DD/MM/YYYY') AS ADMPD_FEC_ENTBONO,
               TO_CHAR(BK.ADMPD_FEC_VENCBONO,'DD/MM/YYYY') AS ADMPD_FEC_VENCBONO,
               BK.ADMPN_DIASVIGEN,
               BK.ADMPV_COD_TPOPR,
               CASE
                 WHEN BK.ADMPV_COD_TPOPR = '1' THEN 'SERVICIOS'
                 WHEN BK.ADMPV_COD_TPOPR = '2' THEN 'DESCUENTO DE EQUIPOS'
                 ELSE ''
               END AS ADMPV_DESC,
               CASE
                 WHEN K.ADMPC_ESTADO = 'A' THEN 'VIGENTE'
                 WHEN K.ADMPC_ESTADO = 'V' THEN 'VENCIDO'
                 WHEN K.ADMPC_ESTADO = 'C' THEN 'CANJEADO'
                 WHEN K.ADMPC_ESTADO = 'B' THEN 'BAJA'
               END AS ESTADO
        FROM PCLUB.ADMPT_BONO_KARDEX BK
             INNER JOIN PCLUB.VIEW_ADMPT_KARDEX K ON K.ADMPN_ID_KARDEX=BK.ADMPN_ID_KARDEX
             INNER JOIN PCLUB.ADMPT_BONO B ON B.ADMPV_BONO=BK.ADMPV_BONO
             INNER JOIN PCLUB.ADMPT_CLIENTE C ON C.ADMPV_COD_CLI = K.ADMPV_COD_CLI
        WHERE C.ADMPV_COD_TPOCL = K_TIPOCLIENTE
              AND BK.ADMPV_TIPO_DOC = K_TIPDOC
              AND BK.ADMPV_NUM_DOC = K_NRODOC
        ORDER BY BK.ADMPD_FEC_ENTBONO DESC;

    ELSIF K_TPO_CONSULTA = 'B' THEN
      CASE
        WHEN K_LINEA IS NULL THEN
          K_CODERROR := 4; K_DESCERROR := ' No se ha ingresado el número de línea.';
          RAISE IN_EXCEPTION;
        ELSE
          K_CODERROR := 0; K_DESCERROR := '';
      END CASE;

      OPEN K_CUR_BONO_ENT FOR
        SELECT BK.ADMPV_LINEA,
               BK.ADMPN_PUNTOS,
               BK.ADMPV_BONO,
               B.ADMPV_DESCBONO,
               TO_CHAR(BK.ADMPD_FEC_ENTBONO,'DD/MM/YYYY') AS ADMPD_FEC_ENTBONO,
               TO_CHAR(BK.ADMPD_FEC_VENCBONO,'DD/MM/YYYY') AS ADMPD_FEC_VENCBONO,
               BK.ADMPN_DIASVIGEN,
               BK.ADMPV_COD_TPOPR,
               CASE
                 WHEN BK.ADMPV_COD_TPOPR = '1' THEN 'SERVICIOS'
                 WHEN BK.ADMPV_COD_TPOPR = '2' THEN 'DESCUENTO DE EQUIPOS'
                 ELSE ''
               END AS ADMPV_DESC,
               CASE
                 WHEN K.ADMPC_ESTADO = 'A' THEN 'VIGENTE'
                 WHEN K.ADMPC_ESTADO = 'V' THEN 'VENCIDO'
                 WHEN K.ADMPC_ESTADO = 'C' THEN 'CANJEADO'
                 WHEN K.ADMPC_ESTADO = 'B' THEN 'BAJA'
               END AS ESTADO
        FROM PCLUB.ADMPT_BONO_KARDEX BK
             INNER JOIN PCLUB.ADMPT_KARDEX K ON K.ADMPN_ID_KARDEX = BK.ADMPN_ID_KARDEX
             INNER JOIN PCLUB.ADMPT_BONO B ON B.ADMPV_BONO=BK.ADMPV_BONO
        WHERE BK.ADMPV_LINEA = K_LINEA
        ORDER BY BK.ADMPD_FEC_ENTBONO DESC;
    ELSE
      OPEN K_CUR_BONO_ENT FOR
        SELECT '' AS ADMPV_LINEA,
               '' AS ADMPV_NOM_CLI,
               '' AS ADMPV_APE_CLI,
               '' AS ADMPN_PUNTOS,
               '' AS ADMPV_BONO,
               '' AS ADMPV_DESCBONO,
               '' AS ADMPD_FEC_ENTBONO,
               '' AS ADMPD_FEC_VENCBONO,
               '' AS ADMPN_DIASVIGEN,
               '' AS ADMPV_COD_TPOPR,
               '' AS ADMPV_DESC,
               '' AS ESTADO
        FROM DUAL
        WHERE 1=0;
    END IF;

    --asignamos el codigo y descripcion del error
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR = K_CODERROR;

  EXCEPTION
    WHEN IN_EXCEPTION THEN
      BEGIN
        OPEN K_CUR_BONO_ENT FOR
         SELECT '' AS ADMPV_LINEA,
               '' AS ADMPN_PUNTOS,
               '' AS ADMPV_BONO,
               '' AS ADMPV_DESCBONO,
               '' AS ADMPD_FEC_ENTBONO,
               '' AS ADMPD_FEC_VENCBONO,
               '' AS ADMPN_DIASVIGEN,
               '' AS ADMPV_COD_TPOPR,
               '' AS ADMPV_DESC,
               '' AS ESTADO
        FROM DUAL
        WHERE 1=0;

        --asignamos el codigo y descripcion del error
        SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR = K_CODERROR;
      END;
    WHEN OTHERS THEN
      OPEN K_CUR_BONO_ENT FOR
         SELECT '' AS ADMPV_LINEA,
               '' AS ADMPN_PUNTOS,
               '' AS ADMPV_BONO,
               '' AS ADMPV_DESCBONO,
               '' AS ADMPD_FEC_ENTBONO,
               '' AS ADMPD_FEC_VENCBONO,
               '' AS ADMPN_DIASVIGEN,
               '' AS ADMPV_COD_TPOPR,
               '' AS ADMPV_DESC,
               '' AS ESTADO
        FROM DUAL
        WHERE 1=0;

      K_CODERROR := -1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 200);
  END ADMPSI_CONS_BONO;

  --****************************************************************
  -- Nombre SP           :  ADMPSI_PROC_ENTREGA_BONO
  -- Propósito           :  Entregar Puntos Bono
  -- Creado por          :  E76142
  -- Fec Creación        :  20/12/2013
  --****************************************************************
  PROCEDURE ADMPSI_PROC_ENTREGA_BONO(K_IDENT     IN NUMBER,
                                     K_BONO      IN VARCHAR2,
                                     K_SEQ       IN NUMBER,
                                     K_LINEA     IN VARCHAR2,
                                     K_USUARIO   IN VARCHAR2,
                                     K_MSJSMS    OUT VARCHAR2,
                                     K_CODERROR  OUT NUMBER,
                                     K_DESCERROR OUT VARCHAR2) IS

    V_LINEA VARCHAR2(50);
    V_CODERROR  NUMBER;
    V_DESCERROR VARCHAR2(250);
    EX_ERROR EXCEPTION;
    EX_ERROR_PROC EXCEPTION;
    V_COUNT_C NUMBER;

  BEGIN

    K_CODERROR  := 0;
    K_DESCERROR := '';

    IF K_SEQ IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'Ingrese un Secuencial de registro. ';
      RAISE EX_ERROR;
    END IF;

    IF K_IDENT IS NULL AND K_BONO IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'Ingrese un Identificador de Bono o Descripción de Bono válido. ';
      RAISE EX_ERROR;
    END IF;

    IF TRIM(K_LINEA) IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'Ingrese un Número de Línea válido. ';
      RAISE EX_ERROR;
    END IF;

    IF K_USUARIO IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'Ingrese un Usuario válido. ';
      RAISE EX_ERROR;
    END IF;

    IF LENGTH(K_LINEA) <> 11 THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'Ingrese un Número de Línea válido. ';
      RAISE EX_ERROR;
    END IF;

    IF LENGTH(TRIM(TRANSLATE(K_LINEA, '0123456789', ' '))) > 0 THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'El valor de la línea debe ser numérico. ';
      RAISE EX_ERROR;
    END IF;

    --Se procede a invocar al SP que realiza la Entrega del Bono
    V_LINEA := SUBSTR(K_LINEA, 3, 9);

    SELECT COUNT(1) INTO V_COUNT_C FROM PCLUB.ADMPT_KARDEX K
           INNER JOIN PCLUB.ADMPT_BONO_CONFIG F
           ON K.ADMPV_COD_CPTO=F.ADMPV_COD_CPTO
           INNER JOIN PCLUB.ADMPT_BONO B
           ON F.ADMPV_BONO=B.ADMPV_BONO
           WHERE K.ADMPV_COD_CLI=V_LINEA
               AND (B.ADMPN_ID_BONO_PRE = K_IDENT OR B.ADMPV_BONO=K_BONO);

	IF V_COUNT_C=0 THEN
      SELECT COUNT(1) INTO V_COUNT_C 
      FROM PCLUB.ADMPT_KARDEX_MIG K 
	  INNER JOIN PCLUB.ADMPT_BONO_CONFIG F
           ON K.ADMPV_COD_CPTO=F.ADMPV_COD_CPTO
           INNER JOIN ADMPT_BONO B
           ON F.ADMPV_BONO=B.ADMPV_BONO
      WHERE K.ADMPV_COD_CLI=V_LINEA
            AND (B.ADMPN_ID_BONO_PRE = K_IDENT OR B.ADMPV_BONO=K_BONO);
    END IF;	
	
    IF V_COUNT_C=0 THEN

    PCLUB.PKG_CC_BONOS.ADMPSI_ENTREGA_BONO_REP(K_IDENT,
                                         K_BONO,
                                         V_LINEA,
                                         K_USUARIO,
                                         K_MSJSMS,
                                         V_CODERROR,
                                         V_DESCERROR);

    IF V_CODERROR <> 0 THEN
      RAISE EX_ERROR_PROC;
    ELSE
      --Actualizo en la tabla de Errores
      UPDATE PCLUB.ADMPT_BONOPREP_ERR
         SET ADMPV_ESTADO    = 'P',
             ADMPD_FEC_PROC  = SYSDATE,
             ADMPV_CONT_PROC =
             (ADMPV_CONT_PROC + 1),
             ADMPV_MENSAJE = K_MSJSMS,
             ADMPV_USU_MOD= K_USUARIO,
             ADMPD_FEC_MOD=SYSDATE
       WHERE ADMPN_ID = K_SEQ
         AND ADMPN_TELEF = K_LINEA;
    END IF;
  ELSE

          K_CODERROR:=54;

         SELECT ADMPV_DES_ERROR
          INTO K_DESCERROR
         FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;

       --Actualizo en la tabla de Errores
       UPDATE PCLUB.ADMPT_BONOPREP_ERR
         SET ADMPV_ESTADO    = 'E',
             ADMPD_FEC_PROC  = SYSDATE,
             ADMPV_CONT_PROC =
             (ADMPV_CONT_PROC + 1),
             ADMPV_CODERR=K_CODERROR,
             ADMPV_DESCERR=K_DESCERROR
       WHERE ADMPN_ID = K_SEQ
         AND ADMPN_TELEF = K_LINEA;

    END IF;
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
    WHEN EX_ERROR_PROC THEN
      K_CODERROR  := V_CODERROR;
      K_DESCERROR := V_DESCERROR;
      ROLLBACK;
      --Actualizo en la tabla de Errores
      UPDATE PCLUB.ADMPT_BONOPREP_ERR
         SET ADMPV_ESTADO    = 'E',
             ADMPD_FEC_PROC  = SYSDATE,
             ADMPV_CONT_PROC =
             (ADMPV_CONT_PROC + 1),
             ADMPV_CODERR=V_CODERROR,
             ADMPV_DESCERR=V_DESCERROR
       WHERE ADMPN_ID = K_SEQ
         AND ADMPN_TELEF = K_LINEA;
      COMMIT;
    WHEN NO_DATA_FOUND THEN
      K_CODERROR  := -1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
      ROLLBACK;
    WHEN OTHERS THEN
      K_CODERROR  := -1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
      ROLLBACK;

  END ADMPSI_PROC_ENTREGA_BONO;

  --****************************************************************
  -- Nombre SP           :  ADMPSI_ENTREGA_BONO_REP
  -- Propósito           :  Entregar Puntos Bono - Reproceso
  -- Creado por          :  E76142
  -- Fec Creación        :  20/12/2013
  --****************************************************************
  PROCEDURE ADMPSI_ENTREGA_BONO_REP(K_IDENT     IN NUMBER,
                                    K_BONO      IN VARCHAR2,
                                    K_LINEA     IN VARCHAR2,
                                    K_USUARIO   IN VARCHAR2,
                                    K_MSJSMS    OUT VARCHAR2,
                                    K_CODERROR  OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2) IS
    V_DESCBONO       VARCHAR2(100);
    V_CODMSJSMS      VARCHAR2(100);
    K_CUR_BONOCONFIG SYS_REFCURSOR;
    V_CODERROR       NUMBER;
    V_DESCERROR      VARCHAR2(200);
    V_EXISTE_CC      NUMBER;
    V_EXITO          NUMBER;
    V_CODERROR_R     NUMBER;
    V_DESCERROR_R    VARCHAR2(100);
    V_BONO           VARCHAR2(100);
    V_PUNTOS         NUMBER;
    V_CONCEPTO       VARCHAR2(100);
    V_IDKARDEX       NUMBER;
    V_TIPDOC         VARCHAR2(40);
    V_NRODOC         VARCHAR2(100);
    V_DIAS           NUMBER;
    V_TIPOPREM       NUMBER;
    V_LINEA          VARCHAR2(50);
    V_FECVCMTO       VARCHAR2(50);
    V_MSJSMS         VARCHAR2(200);
    V_EXISTE_SLDO    NUMBER;

    EX_ERROR EXCEPTION;
    EX_ERROR_REG EXCEPTION;
    EX_ERROR_OBT EXCEPTION;

  BEGIN

    K_CODERROR  := 0;
    K_DESCERROR := '';

    IF K_IDENT IS NULL AND K_BONO IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'Ingrese un Identificador de Bono o Descripción de Bono válido. ';
      RAISE EX_ERROR;
    END IF;

    IF TRIM(K_LINEA) IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'Ingrese un Número de Línea válido. ';
      RAISE EX_ERROR;
    END IF;

    IF K_USUARIO IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'Ingrese un Usuario válido. ';
      RAISE EX_ERROR;
    END IF;

    IF LENGTH(K_LINEA) <> 9 THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'Ingrese un Número de Línea válido. ';
      RAISE EX_ERROR;
    END IF;

    IF LENGTH(TRIM(TRANSLATE(K_LINEA, '0123456789', ' '))) > 0 THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'El valor de la línea debe ser numérico. ';
      RAISE EX_ERROR;
    END IF;

    --Obtenemos la Configuración de los bonos
    BEGIN
      PCLUB.PKG_CC_BONOS.ADMPSS_OBT_CONFIG(K_BONO,
                                     K_IDENT,
                                     V_DESCBONO,
                                     V_CODMSJSMS,
                                     K_CUR_BONOCONFIG,
                                     K_CODERROR,
                                     K_DESCERROR);
      V_MSJSMS := V_CODMSJSMS;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
        K_CODERROR  := -1;
        RAISE EX_ERROR;
    END;

    IF K_CODERROR <> 0 THEN
      RAISE EX_ERROR_OBT;
    ELSE

      --Validamos que la línea se encuentre registrada en ClaroClub
      SELECT COUNT(1)
        INTO V_EXISTE_CC
        FROM PCLUB.ADMPT_CLIENTE
       WHERE admpv_cod_cli = K_LINEA
         AND ADMPV_COD_TPOCL = 3
         AND admpc_estado = 'A';

      IF V_EXISTE_CC = 0 THEN
        --La línea no se encuentra en ClaroClub
        --Se procede a invocar al SP para registrar en ClaroClub
        V_LINEA := '51' || K_LINEA;
        PCLUB.PKG_CC_BONOS.ADMPSI_REG_LINEA(K_BONO,
                         K_IDENT,
                         K_USUARIO,
                         V_LINEA,
                         1,
                         V_EXITO,
                         V_TIPDOC,
                         V_NRODOC,
                         K_CODERROR,
                         K_DESCERROR);

        IF K_CODERROR <> 0 THEN
          RAISE EX_ERROR;
        END IF;
      ELSE
        --Verificamos si se el Cliente està configurado en la tabla Saldos Cliente
        SELECT NVL(COUNT(1), 0)
          INTO V_EXISTE_SLDO
          FROM PCLUB.ADMPT_SALDOS_CLIENTE S
         WHERE S.ADMPV_COD_CLI = K_LINEA;

        IF V_EXISTE_SLDO = 0 THEN
          INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE
            (ADMPN_ID_SALDO,
             ADMPV_COD_CLI,
             ADMPN_COD_CLI_IB,
             ADMPN_SALDO_CC,
             ADMPN_SALDO_IB,
             ADMPC_ESTPTO_CC,
             ADMPC_ESTPTO_IB,
             ADMPD_FEC_REG)
          VALUES
            (PCLUB.ADMPT_SLD_CL_SQ.NEXTVAL, K_LINEA, '', 0, 0, 'A', '', SYSDATE);
          commit;
        END IF;

        --Obtenemos los datos del Cliente ClaroClub
        SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
          INTO V_TIPDOC, V_NRODOC
          FROM PCLUB.ADMPT_CLIENTE
         WHERE ADMPV_COD_CLI = K_LINEA
           AND ADMPC_ESTADO = 'A';
      END IF;

      --Ahora que ya existe en ClaroClub, se procede a entregar los puntos, para ello insertamos en el kárdex
      LOOP
        FETCH K_CUR_BONOCONFIG
          INTO V_BONO, V_PUNTOS, V_CONCEPTO, V_DIAS, V_TIPOPREM;
        EXIT WHEN K_CUR_BONOCONFIG%NOTFOUND;

        --Calculo la fecha de vencimiento:
        V_FECVCMTO := SYSDATE + V_DIAS;

        PCLUB.PKG_CC_BONOS.ADMPSI_ENTREGA_PTOS(K_LINEA,
                                         V_CONCEPTO,
                                         V_PUNTOS,
                                         V_FECVCMTO,
                                         V_TIPOPREM,
                                         '',
                                         K_USUARIO,
                                         V_IDKARDEX,
                                         V_CODERROR,
                                         V_DESCERROR);

        IF V_CODERROR = 0 THEN
          --Insertamos en la tabla histórica de Bono
          PCLUB.PKG_CC_BONOS.ADMPSI_REG_BONO_KARDEX(V_IDKARDEX,
                                              V_BONO,
                                              K_LINEA,
                                              SYSDATE,
                                              V_FECVCMTO,
                                              V_PUNTOS,
                                              V_DIAS,
                                              V_TIPOPREM,
                                              V_TIPDOC,
                                              V_NRODOC,
                                              K_USUARIO,
                                              V_CODERROR_R,
                                              V_DESCERROR_R);

          IF V_CODERROR_R <> 0 THEN
            K_CODERROR := V_CODERROR_R;
            RAISE EX_ERROR;
          END IF;
        ELSE
          K_CODERROR := V_CODERROR;
          RAISE EX_ERROR;
        END IF;

      END LOOP;
      CLOSE K_CUR_BONOCONFIG;

    END IF;

    --Obtengo el mensaje
    IF V_MSJSMS IS NOT NULL THEN
      SELECT NVL(ADMPV_DESCRIPCION, '')
        INTO K_MSJSMS
        FROM PCLUB.ADMPT_MENSAJE
       WHERE ADMPV_VALOR = V_MSJSMS;
    ELSE
      K_MSJSMS := '';
    END IF;

    BEGIN
      SELECT E.ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC E
       WHERE E.ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := '';
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
          K_DESCERROR := 'ERROR';
      END;
      ROLLBACK;
    WHEN EX_ERROR_REG THEN
      BEGIN
        SELECT ADMPV_DES_ERROR
          INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_DESCERROR := 'ERROR';
      END;
      ROLLBACK;
    WHEN EX_ERROR_OBT THEN
      K_CODERROR  := K_CODERROR;
      K_DESCERROR := K_DESCERROR;
      ROLLBACK;
    WHEN NO_DATA_FOUND THEN
      K_CODERROR  := -1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
      ROLLBACK;
    WHEN OTHERS THEN
      K_CODERROR  := -1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
      ROLLBACK;

  END ADMPSI_ENTREGA_BONO_REP;

  --****************************************************************
  -- Nombre SP           :  ADMPSS_LINEAS_NOPROC_BONO
  -- Propósito           :  Devuelve las lineas a las que nos e entregó el Bono debido a un error
  -- Creado por          :  E76142
  -- Fec Creación        :  20/12/2013
  --****************************************************************
  PROCEDURE ADMPSS_LINEAS_NOPROC_BONO(K_CANT_PROC IN NUMBER,
                                      K_CUR_LISTA OUT SYS_REFCURSOR,
                                      K_CODERROR  OUT NUMBER,
                                      K_DESCERROR OUT VARCHAR2) IS
    EX_ERROR EXCEPTION;
  BEGIN
    K_CODERROR  := 0;
    K_DESCERROR := '';

    IF K_CANT_PROC IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'Ingrese la cantidad máxima para procesar una línea. ';
      RAISE EX_ERROR;
    END IF;

    OPEN K_CUR_LISTA FOR
      SELECT E.ADMPN_ID, E.ADMPN_TELEF, E.ADMPN_ID_BONO_PRE, E.ADMPV_BONO
        FROM PCLUB.ADMPT_BONOPREP_ERR E
       WHERE (E.ADMPV_ESTADO = 'R' or E.ADMPV_ESTADO = 'E')
         AND E.ADMPV_CONT_PROC <= K_CANT_PROC;

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
      K_CODERROR  := -1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      OPEN K_CUR_LISTA FOR
        SELECT '' ADMPN_TELEF, '' ADMPN_ID_BONO_PRE, '' ADMPV_BONO
          FROM DUAL
         WHERE 1 = 0;
  END ADMPSS_LINEAS_NOPROC_BONO;

	PROCEDURE ADMPSS_LST_CLIENTE_BONOS( K_USUARIO   IN  VARCHAR2
                                     ,K_REGISTRO  OUT NUMBER
                                     ,K_CODERROR  OUT NUMBER
                                     ,K_DESCERROR OUT VARCHAR2) IS
  V_FEC_ACTUAL 			DATE;
  V_PRO_REGIS  			NUMBER;
  ADMPV_COD_CLI	    VARCHAR2(40);
  ADMPN_TIP_PREMIO	NUMBER;
  ADMPV_COD_CPTO	  VARCHAR2(3);
  ADMPN_SLD_PUNTO   NUMBER;
  K_CURSOINF        SYS_REFCURSOR;

  BEGIN
    V_PRO_REGIS:=1;
    K_REGISTRO:=0;
    SELECT TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY') INTO V_FEC_ACTUAL
    FROM DUAL;

    EXECUTE IMMEDIATE ('TRUNCATE TABLE PCLUB.ADMPT_TMP_FIDELIDAD');

    OPEN K_CURSOINF FOR
    SELECT K.ADMPV_COD_CLI,
          K.ADMPN_TIP_PREMIO,
          K.ADMPV_COD_CPTO,
         SUM(K.ADMPN_SLD_PUNTO)
    FROM PCLUB.ADMPT_KARDEX K
    WHERE K.ADMPC_TPO_OPER = 'E'
     AND K.ADMPC_TPO_PUNTO = 'B'
     AND K.ADMPC_ESTADO = 'A'
     AND K.ADMPD_FEC_VCMTO < V_FEC_ACTUAL
     AND K.ADMPN_SLD_PUNTO > 0
     AND K.ADMPV_COD_CPTO IN (SELECT BC.ADMPV_COD_CPTO
                              FROM PCLUB.ADMPT_BONO_CONFIG BC
                              WHERE BC.ADMPV_BONO IN (SELECT BO.ADMPV_BONO
                                                      FROM PCLUB.ADMPT_BONO BO
                                                      WHERE BO.ADMPV_TYPEBONO ='F'
                                                      GROUP BY BO.ADMPV_BONO)
                              GROUP BY BC.ADMPV_COD_CPTO)
    GROUP BY K.ADMPV_COD_CLI, K.ADMPN_TIP_PREMIO, K.ADMPV_COD_CPTO
    ORDER BY  K.ADMPN_TIP_PREMIO;

    LOOP
      FETCH K_CURSOINF INTO ADMPV_COD_CLI ,ADMPN_TIP_PREMIO, ADMPV_COD_CPTO, ADMPN_SLD_PUNTO;
      EXIT WHEN K_CURSOINF%NOTFOUND;
      K_REGISTRO:=K_CURSOINF%ROWCOUNT;
      INSERT INTO PCLUB.ADMPT_TMP_FIDELIDAD(ADMPV_COD_CLI ,ADMPN_TIP_PRE   ,ADMPV_COD_CTO ,ADMPN_SLD_PTO  ,ADMPN_PROCESO,ADMPV_USU_REG,ADMPD_FEC_REG)
																		VALUES(ADMPV_COD_CLI ,ADMPN_TIP_PREMIO,ADMPV_COD_CPTO,ADMPN_SLD_PUNTO,V_PRO_REGIS  ,K_USUARIO,TRUNC(SYSDATE));
      V_PRO_REGIS:=V_PRO_REGIS + 1;
      IF V_PRO_REGIS > 20 THEN
         V_PRO_REGIS:=1;
      END IF;
    END LOOP;
    COMMIT;
    K_CODERROR := 0;
    K_DESCERROR :='Consulta Exitosa';
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    K_REGISTRO:=0;
    K_CODERROR := 3;
    K_DESCERROR:='No existe registros a procesar';
    OPEN K_CURSOINF FOR
    SELECT '' ADMPV_COD_CLI,
           '' ADMPN_TIP_PREMIO,
           '' ADMPV_COD_CPTO,
           '' ADMPN_SLD_PUNTO
    FROM  DUAL
    WHERE 1=0;
  WHEN OTHERS THEN
    K_REGISTRO:=0;
    K_CODERROR := 2;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    OPEN K_CURSOINF FOR
    SELECT '' ADMPV_COD_CLI,
           '' ADMPN_TIP_PREMIO,
           '' ADMPV_COD_CPTO,
           '' ADMPN_SLD_PUNTO
    FROM  DUAL
    WHERE 1=0;

  END ADMPSS_LST_CLIENTE_BONOS;


  PROCEDURE ADMPSU_UPD_ENTREGA_BONOS(	K_NUME_PROCES IN  NUMBER
																		, K_CANT_PROCES OUT NUMBER
																		, K_CANT_EXITOS OUT NUMBER
																		,	K_CANT_ERRADO OUT NUMBER
																		, K_FLAG_EXITOS OUT NUMBER
																		,	K_MENS_TRANSA OUT VARCHAR2) IS
	V_COD_CPTO_S 	VARCHAR2(3);
	V_ESTADO		 	CHAR(1);
	V_TPO_OPE		 	CHAR(1);
	V_TPO_PUNTO	 	CHAR(1);
	V_FEC_ACTUAL  DATE;
	V_ID_KARDEX	 	NUMBER;
	V_INFO_LINEA	VARCHAR2(20);
	V_INFO_PREMIO NUMBER;
	V_INFO_CPTO_E VARCHAR2(40);
	V_INFO_PUNTOS NUMBER;
	V_INFO_USUARI	VARCHAR2(40);
	V_CODERROR 		NUMBER;
  K_REGISTRO    NUMBER;
	V_DESERROR 		VARCHAR2(400);
  K_CURSOINF    SYS_REFCURSOR;
  PRECESO_ERR   EXCEPTION;
	BEGIN

		V_ESTADO       := 'V'; -- Activo
    V_TPO_OPE      := 'S'; -- Salida
    V_TPO_PUNTO    := 'B'; -- BONO
    K_CANT_PROCES  :=0;
    K_CANT_EXITOS  :=0;
    K_CANT_ERRADO  :=0;

		K_FLAG_EXITOS:=0;

		SELECT C.ADMPV_COD_CPTO INTO V_COD_CPTO_S
    FROM  PCLUB.ADMPT_CONCEPTO C
    WHERE C.ADMPV_DESC = 'VENCIMIENTO DE PUNTO BONO PREPAGO';

		OPEN K_CURSOINF FOR
    SELECT  ADMPV_COD_CLI
					 ,ADMPN_TIP_PRE
					 ,ADMPV_COD_CTO
					 ,ADMPN_SLD_PTO
					 ,ADMPV_USU_REG
		FROM   PCLUB.ADMPT_TMP_FIDELIDAD X
		WHERE  ADMPD_FEC_REG = TRUNC(SYSDATE)
			AND  ADMPN_PROCESO = K_NUME_PROCES
      AND  X.ADMPC_EST_REG IS NULL;
		LOOP
      FETCH K_CURSOINF INTO V_INFO_LINEA ,V_INFO_PREMIO, V_INFO_CPTO_E, V_INFO_PUNTOS, V_INFO_USUARI;
      EXIT WHEN K_CURSOINF%NOTFOUND;
      K_REGISTRO:=K_CURSOINF%ROWCOUNT;

      BEGIN
          PCLUB.PKG_CC_BONOS.ADMPSI_REG_KARDEX(	V_INFO_LINEA
				                                 ,V_COD_CPTO_S
																	       ,SYSDATE
																	       ,(V_INFO_PUNTOS * (-1))
																	       ,''
																	       ,V_TPO_OPE
																	       ,'B'
																	       ,0
																	       ,V_INFO_PREMIO
																	       ,''
																	       ,NULL
																	       ,V_ESTADO
																	       ,V_INFO_USUARI
																	       ,V_ID_KARDEX
																	       ,V_CODERROR
                                         ,V_DESERROR);


         IF V_CODERROR=0 THEN
                UPDATE  PCLUB.ADMPT_KARDEX K
                  SET K.ADMPN_SLD_PUNTO = 0,
                      K.ADMPC_ESTADO = 'V'
                WHERE K.ADMPD_FEC_VCMTO < TRUNC(SYSDATE)
                      AND K.ADMPV_COD_CPTO  = V_INFO_CPTO_E
                      AND K.ADMPC_TPO_PUNTO = V_TPO_PUNTO
                      AND K.ADMPV_COD_CLI   = V_INFO_LINEA
                      AND K.ADMPN_TIP_PREMIO= V_INFO_PREMIO
                      AND K.ADMPN_SLD_PUNTO > 0
                      AND K.ADMPC_TPO_OPER = 'E';

                IF V_INFO_PREMIO = 0 THEN
                    UPDATE  PCLUB.ADMPT_SALDOS_CLIENTE SC
                    SET SC.ADMPN_SALDO_CC  = SC.ADMPN_SALDO_CC - V_INFO_PUNTOS,
                        SC.ADMPD_FEC_MOD 	 = SYSDATE
                    WHERE SC.ADMPV_COD_CLI = V_INFO_LINEA;
                ELSE
                    UPDATE  PCLUB.ADMPT_SALDOS_BONO_CLIENTE BC
                    SET BC.ADMPN_SALDO = BC.ADMPN_SALDO - V_INFO_PUNTOS,
                        BC.ADMPV_USU_MOD = V_INFO_USUARI
                    WHERE BC.ADMPV_COD_CLI 	= V_INFO_LINEA
                      AND BC.ADMPN_GRUPO 		= V_INFO_PREMIO
                      AND BC.ADMPV_ESTADO 	= 'A';
                END IF;

              UPDATE PCLUB.ADMPT_TMP_FIDELIDAD
                  SET ADMPC_EST_REG='V'
              WHERE  ADMPD_FEC_REG =TRUNC(SYSDATE)
                AND  ADMPN_PROCESO = K_NUME_PROCES
                AND  ADMPV_COD_CLI = V_INFO_LINEA;

              INSERT INTO PCLUB.ADMPT_IMP_VTOBONO(ADMPV_COD_CLI,
																									ADMPN_TIP_PRE,
																									ADMPV_COD_CTO,
																									ADMPN_SLD_PTO,
																									ADMPC_EST_BON,
																									ADMPC_TYP_BON,
																									ADMPV_USU_REG,
																									ADMPD_FEC_REG)
																					VALUES( V_INFO_LINEA,
																									V_INFO_PREMIO,
																									V_INFO_CPTO_E,
																									V_INFO_PUNTOS,
																									V_CODERROR,
																									'F',
																									V_INFO_USUARI,
																									SYSDATE);
               K_CANT_EXITOS := K_CANT_EXITOS + 1;
              K_CANT_PROCES:=K_CANT_PROCES + 1;
        ELSE

        UPDATE PCLUB.ADMPT_TMP_FIDELIDAD
               SET ADMPC_EST_REG = 'E'
             WHERE ADMPD_FEC_REG = TRUNC(SYSDATE)
               AND ADMPN_PROCESO = K_NUME_PROCES
               AND ADMPV_COD_CLI = V_INFO_LINEA;

            INSERT INTO PCLUB.ADMPT_IMP_VTOBONO
              (ADMPV_COD_CLI,
               ADMPN_TIP_PRE,
               ADMPV_COD_CTO,
               ADMPN_SLD_PTO,
               ADMPC_EST_BON,
               ADMPC_TYP_BON,
               ADMPV_USU_REG,
               ADMPD_FEC_REG)
            VALUES
              (V_INFO_LINEA,
               V_INFO_PREMIO,
               V_INFO_CPTO_E,
               V_INFO_PUNTOS,
               'E',
               'F',
               V_INFO_USUARI,
               SYSDATE);

               K_CANT_ERRADO := K_CANT_ERRADO + 1;
               K_CANT_PROCES:=K_CANT_PROCES + 1;

          END IF;

          COMMIT;

    EXCEPTION
         WHEN  OTHERS  THEN

               ROLLBACK;

            UPDATE PCLUB.ADMPT_TMP_FIDELIDAD
               SET ADMPC_EST_REG = 'E'
             WHERE ADMPD_FEC_REG = V_FEC_ACTUAL
               AND ADMPN_PROCESO = K_NUME_PROCES
               AND ADMPV_COD_CLI = V_INFO_LINEA;

            INSERT INTO PCLUB.ADMPT_IMP_VTOBONO
              (ADMPV_COD_CLI,
               ADMPN_TIP_PRE,
               ADMPV_COD_CTO,
               ADMPN_SLD_PTO,
               ADMPC_EST_BON,
               ADMPC_TYP_BON,
               ADMPV_USU_REG,
               ADMPD_FEC_REG)
            VALUES
              (V_INFO_LINEA,
               V_INFO_PREMIO,
               V_INFO_CPTO_E,
               V_INFO_PUNTOS,
               'E',
               'F',
               V_INFO_USUARI,
               SYSDATE);

               K_CANT_ERRADO := K_CANT_ERRADO + 1;
               K_CANT_PROCES:=K_CANT_PROCES + 1;

                COMMIT;
       END;

		END LOOP;

		EXCEPTION
		WHEN OTHERS THEN
			K_FLAG_EXITOS := -1;
			K_MENS_TRANSA := SUBSTR(SQLERRM, 1, 400);
      ROLLBACK;

	END ADMPSU_UPD_ENTREGA_BONOS;

	PROCEDURE ADMPSI_QUITA_BONO (K_DE_BONO   IN VARCHAR2,
                               K_ID_BONO   IN NUMBER,
                               K_LINEA     IN VARCHAR2,
                               K_USUARIO   IN VARCHAR2,
                               K_CODERROR  OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2)IS
	EX_ERROR     EXCEPTION;
	EX_ERROR_REG EXCEPTION;  --REGISTRAR KARDEX
	EX_ERROR_OBT EXCEPTION;  --OBTENER DATOS DE CONFIGURACION DE BONO
	EX_ERROR_CFG EXCEPTION;
	--INFORMACION DEL BONO
	V_DESCBONO       VARCHAR2(100);
	V_CODMSJSMS      VARCHAR2(100);
	K_CUR_BONOCONFIG SYS_REFCURSOR;
	V_BONO           VARCHAR2(100);
	V_PUNTOS         NUMBER;
	V_SALDOS         NUMBER;
	V_CONCEPTO       VARCHAR2(100);
	V_CONCEPTO_SAL   VARCHAR2(100);
	V_DIAS           NUMBER;
	V_TIPOPREM       NUMBER;
	--INFORMACION DEL CLIENTE CLARO CLUB
	V_EXISTECC      NUMBER;
	EX_ERRORCC      EXCEPTION;     --Error el cliente no existe en claro club
	--INFORMACION DEL SALDO DEL CLIENTE
	EX_ERRSALD      EXCEPTION;     --Excepcion que el cliente no tenga saldo
	EX_SALDOREG     EXCEPTION;     --Excepcion si no se registra el registro saldo
	--INFORMACION DEL SALDO BONO
	V_EXIBONSA      NUMBER;
	EX_BONOSAL      EXCEPTION;
	--INFORMACION DEL KARDEX
	V_IDKARDEX      NUMBER;
	V_ERRREGIS      NUMBER;
	V_ERRDESCR      VARCHAR(400);
	--INFORMACION DEL SALDOS
	V_SALDOTIP00     NUMBER;
	V_SALDOTIP12     NUMBER;
	V_SALDOTOTAL     NUMBER;
  V_SALDOSUMBONO   NUMBER;
	--TIPOS DE PREMIOS
	EX_TIPOPREMI     EXCEPTION;
	EX_EXISSALDO     EXCEPTION;
  EX_CONCEBONO     EXCEPTION;
  V_EXISTECONC     NUMBER;


  BEGIN
    K_CODERROR  := 0;
    K_DESCERROR :='';
    --validando el envio de informacion del bono
    IF K_DE_BONO IS NULL AND K_ID_BONO IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'Ingrese un Identificador de Bono o Descripción de Bono válido. ';
      RAISE EX_ERROR;
    END IF;
    --validando que la linea no sea vacia
    IF TRIM(K_LINEA) IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'Ingrese un Número de Línea válido. ';
      RAISE EX_ERROR;
    END IF;
    --validando que el usuario no sea vacio
    IF K_USUARIO IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'Ingrese un Usuario válido. ';
      RAISE EX_ERROR;
    END IF;
    --validacion del tamanio de la linea
    IF LENGTH(K_LINEA) <> 9 THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'Ingrese un Número de Línea válido. ';
      RAISE EX_ERROR;
    END IF;

    IF LENGTH(TRIM(TRANSLATE(K_LINEA, '0123456789', ' '))) > 0 THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'El valor de la línea debe ser numérico. ';
      RAISE EX_ERROR;
    END IF;
			--OBTENER LA CONFIGURACION DEL BONO
			ADMPSS_BONO_CFG(K_DE_BONO, K_ID_BONO,V_DESCBONO,V_CODMSJSMS,K_CUR_BONOCONFIG,K_CODERROR,K_DESCERROR);
      IF K_CODERROR <> 0 THEN
         --ERROR PRODUCTO DE LA CONSULTA
         RAISE EX_ERROR_OBT;
       END IF;
				--PREGUNTAR POR EXISTENCIA DEL CLIENTE CLARO CLUB
				SELECT COUNT(1) INTO V_EXISTECC
				FROM   PCLUB.ADMPT_CLIENTE
				WHERE  ADMPV_COD_CLI = K_LINEA
				AND    ADMPC_ESTADO = 'A';

        IF V_EXISTECC=0 THEN
					RAISE EX_ERRORCC; --NO EXISTE CLIENTE CLARO CLUB
				END IF;

					--OBTENER LA CONFIGURACION DEL BONO Y PROCESAR INFORMACION
          V_SALDOTOTAL:=0;
          V_SALDOS    :=0;
          LOOP
                FETCH K_CUR_BONOCONFIG INTO V_BONO, V_PUNTOS, V_CONCEPTO, V_DIAS, V_TIPOPREM,V_CONCEPTO_SAL;
                EXIT WHEN K_CUR_BONOCONFIG%NOTFOUND;
                V_SALDOTIP00:=0;
                V_SALDOTIP12:=0;
                IF V_TIPOPREM = 0 THEN
                  --VALIDAR QUE EL CONCEPTO QUE VOY A QUITAR EXITAR
                    SELECT COUNT(1) INTO V_EXISTECONC
                    FROM   PCLUB.ADMPT_KARDEX K
                    WHERE  K.ADMPV_COD_CLI    = K_LINEA
                       AND K.ADMPC_TPO_OPER   ='E'
                       AND K.ADMPC_TPO_PUNTO  ='B'
                       AND K.ADMPV_COD_CPTO   = V_CONCEPTO
                       AND K.ADMPN_SLD_PUNTO  > 0

                    GROUP BY K.ADMPV_COD_CLI;

                    IF V_EXISTECONC = 0 THEN
                      RAISE EX_CONCEBONO;
                    END IF;

                    --CONSULTAR POR UNICA VEZ EL SALDO DEL CLIENTE
                    SELECT NVL(SUM(ADMPN_SALDO_CC),0) INTO V_SALDOS
                    FROM   PCLUB.ADMPT_SALDOS_CLIENTE
                    WHERE  ADMPV_COD_CLI = K_LINEA
                      AND  ADMPC_ESTPTO_CC='A'
                    GROUP BY ADMPV_COD_CLI;

                    IF V_SALDOS > 0 THEN
                        IF V_SALDOS >=  V_PUNTOS  THEN
                           V_SALDOTOTAL:=V_SALDOS - V_PUNTOS;
                           V_SALDOTIP00:=(V_PUNTOS)* (-1);               --QUITAR TODO LOS PTOS
                        ELSE
                          V_SALDOTOTAL:=0;
                          V_SALDOTIP00:=(V_SALDOS) * (-1);                   --QUITAR TODO LOS PTOS
                        END IF;
                        --PROCEDIMIENTO QUE REGISTRAR EL KARDEX
                        ADMPSI_REG_KARDEX(K_LINEA    , V_CONCEPTO_SAL,  TRUNC(SYSDATE),    V_SALDOTIP00,
                                          ''         , 'S'           ,  'B'           ,    0,
                                          V_TIPOPREM , ''            ,   NULL      ,    'V',
                                          K_USUARIO  , V_IDKARDEX    ,   V_ERRREGIS   ,    V_ERRDESCR);

                        IF V_ERRREGIS<> 0 THEN
                          RAISE EX_ERROR_REG;
                        END IF;

                        UPDATE PCLUB.ADMPT_KARDEX K
                          SET K.ADMPN_SLD_PUNTO = 0
                             ,K.ADMPC_ESTADO = 'C'
                        WHERE K.ADMPV_COD_CPTO = V_CONCEPTO
                              AND K.ADMPC_TPO_PUNTO = 'B'
                              AND K.ADMPV_COD_CLI   =  K_LINEA
                              AND K.ADMPN_SLD_PUNTO >  0
                              AND K.ADMPC_TPO_OPER  = 'E';

                          --ACTUALIZAR SALDO_CLIENTE
                          ADMPSI_REG_SALDOS(K_LINEA,V_SALDOTOTAL,0,'',V_ERRREGIS,V_ERRDESCR);
                          IF V_ERRREGIS<>0 THEN
                             RAISE EX_SALDOREG;
                          END IF;
                      ELSE
                          K_DESCERROR:='El cliente no tiene bono asignado.';
                          RAISE EX_EXISSALDO;
                    END IF;

                 ELSE
                  IF V_TIPOPREM=1 OR V_TIPOPREM=2 THEN
                    --VALIDAR QUE EL CONCEPTO QUE VOY A QUITAR EXITAR
                      SELECT COUNT(1) INTO V_EXISTECONC
                      FROM   PCLUB.ADMPT_KARDEX K
                      WHERE  K.ADMPV_COD_CLI    = K_LINEA
                         AND K.ADMPC_TPO_OPER   ='E'
                         AND K.ADMPC_TPO_PUNTO  ='B'
                         AND K.ADMPV_COD_CPTO   = V_CONCEPTO
                         AND K.ADMPN_SLD_PUNTO  > 0
                         AND K.ADMPN_TIP_PREMIO = V_TIPOPREM;


                      IF V_EXISTECONC = 0 THEN
                        RAISE EX_CONCEBONO;
                      END IF;


                      V_EXIBONSA:=0;
                      SELECT COUNT(1) INTO V_EXIBONSA
                      FROM   PCLUB.ADMPT_SALDOS_BONO_CLIENTE
                      WHERE  ADMPV_COD_CLI = K_LINEA
                        AND  ADMPN_GRUPO   = V_TIPOPREM
                        AND  ADMPV_ESTADO='A';

                      IF V_EXIBONSA = 0 THEN
                        RAISE EX_BONOSAL;
                      END IF;

                      --CONSULTO SOLO UNA VEZ EL SALDO DEL CLIENTE
                      SELECT NVL(SUM(ADMPN_SALDO),0) INTO V_SALDOS
                      FROM   PCLUB.ADMPT_SALDOS_BONO_CLIENTE
                      WHERE  ADMPV_COD_CLI = K_LINEA
                        AND  ADMPN_GRUPO   = V_TIPOPREM
                        AND  ADMPV_ESTADO='A';

                      --OBTENER LAS VECES QUE SE ENTREGO EL BONO

                      SELECT SUM(K.ADMPN_SLD_PUNTO)  INTO V_SALDOSUMBONO
                          FROM PCLUB.ADMPT_KARDEX K
                          WHERE K.ADMPV_COD_CLI    =K_LINEA
                            AND K.ADMPC_TPO_OPER   ='E'
                            AND K.ADMPC_TPO_PUNTO  ='B'
                            AND K.ADMPN_TIP_PREMIO= V_TIPOPREM
                            AND K.ADMPV_COD_CPTO  =  V_CONCEPTO
                            AND K.ADMPN_SLD_PUNTO  > 0;

                      IF V_SALDOS > 0 THEN
                          IF V_SALDOSUMBONO>V_PUNTOS THEN
                             V_PUNTOS:=V_SALDOSUMBONO;
                          END IF;

                          IF V_SALDOS >= V_PUNTOS THEN
                             V_SALDOTOTAL:=V_SALDOS - V_PUNTOS ;
                             V_SALDOTIP12:=(V_PUNTOS * (-1));
                          ELSE
                             V_SALDOTOTAL:=0;
                             V_SALDOTIP12:=(V_SALDOS * (-1));
                          END IF;

                          --PROCEDIMIENTO QUE REGISTRAR EL KARDEX Y ACTUALIZA LOS SALDOS
                          ADMPSI_REG_KARDEX(K_LINEA    , V_CONCEPTO_SAL,  TRUNC(SYSDATE) ,   V_SALDOTIP12,
                                            ''         , 'S'       ,  'B'            ,   0,
                                            V_TIPOPREM , ''        ,   NULL       ,   'V',
                                            K_USUARIO  , V_IDKARDEX,   V_ERRREGIS    ,   V_ERRDESCR);

                          IF V_ERRREGIS<> 0 THEN
                            RAISE EX_ERROR_REG;
                           END IF;

                           --ACTUALIZAR EL SALDO DEL KARDEX
                           UPDATE  PCLUB.ADMPT_KARDEX K
                              SET K.ADMPN_SLD_PUNTO = 0
                                 ,K.ADMPC_ESTADO    = 'C'
                            WHERE K.ADMPV_COD_CPTO  =  V_CONCEPTO
                              AND K.ADMPC_TPO_PUNTO = 'B'
                              AND K.ADMPV_COD_CLI   =  K_LINEA
                              AND K.ADMPN_TIP_PREMIO=  V_TIPOPREM
                              AND K.ADMPN_SLD_PUNTO >  0
                              AND K.ADMPC_TPO_OPER  = 'E';


                            --ACTUALIZAR EL SALDO BONO CLIENTE
                            ADMPSI_REG_SALDOS(K_LINEA,V_SALDOTOTAL,V_TIPOPREM,K_USUARIO,V_ERRREGIS,V_ERRDESCR);
                            IF V_ERRREGIS<>0 THEN
                               RAISE EX_SALDOREG;
                            END IF;
                      ELSE
                          RAISE EX_EXISSALDO;
                      END IF;
                  ELSE
                    RAISE EX_TIPOPREMI;
                END IF;
              END IF;
					END LOOP;
					CLOSE K_CUR_BONOCONFIG;

          SELECT  ADMPV_DES_ERROR INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
	        WHERE ADMPN_COD_ERROR = K_CODERROR;

					COMMIT;

   EXCEPTION
    -----------------------
    WHEN EX_ERROR THEN
      BEGIN
        SELECT CASE WHEN K_DESCERROR IS NULL THEN to_char(ADMPN_COD_ERROR) ||  '-' || ADMPV_DES_ERROR
                   ELSE  to_char(ADMPN_COD_ERROR) || '-' || ADMPV_DES_ERROR || '-' || K_DESCERROR
               END  INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR = K_CODERROR;
        ROLLBACK;
      END;
    -----------------------
    WHEN EX_ERROR_REG THEN
      BEGIN
        K_CODERROR  :=55 ;
        SELECT ADMPV_DES_ERROR INTO K_DESCERROR
        FROM   PCLUB.ADMPT_ERRORES_CC
        WHERE  ADMPN_COD_ERROR = K_CODERROR;
        ROLLBACK;
      END;
    -----------------------
    WHEN EX_ERROR_OBT THEN
      BEGIN
        K_CODERROR  :=56 ;
        SELECT  ADMPV_DES_ERROR INTO K_DESCERROR
        FROM  PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR = K_CODERROR;
        ROLLBACK;
      END;
    -----------------------
    WHEN EX_ERROR_CFG THEN
      BEGIN
         K_CODERROR  :=57;
         SELECT   ADMPV_DES_ERROR INTO K_DESCERROR
        FROM 	PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR = K_CODERROR;
         ROLLBACK;
      END;
    -----------------------
    WHEN EX_ERRORCC THEN
      BEGIN
        K_CODERROR  :=58 ;
        SELECT  ADMPV_DES_ERROR INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR = K_CODERROR;
        ROLLBACK;
      END;
    -----------------------
    WHEN EX_SALDOREG THEN
      BEGIN
         K_CODERROR  :=59 ;
        SELECT  ADMPV_DES_ERROR INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR = K_CODERROR;
        ROLLBACK;
      END;
    -----------------------
    WHEN EX_BONOSAL THEN
      BEGIN
         K_CODERROR  :=60 ;
         SELECT  ADMPV_DES_ERROR INTO K_DESCERROR
         FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
         ROLLBACK;
      END;
    -----------------------
    WHEN EX_TIPOPREMI THEN
      BEGIN
         K_CODERROR  :=61 ;
         SELECT  ADMPV_DES_ERROR INTO K_DESCERROR
         FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
         ROLLBACK;
      END;
    WHEN EX_EXISSALDO THEN
      BEGIN
        K_CODERROR  :=62;
        SELECT  ADMPV_DES_ERROR INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR = K_CODERROR;
        ROLLBACK;
      END;
    WHEN EX_CONCEBONO THEN
      BEGIN
        K_CODERROR  :=63;
        SELECT  ADMPV_DES_ERROR INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR = K_CODERROR;
        ROLLBACK;
      END;
     WHEN OTHERS THEN
       BEGIN
         K_CODERROR  :=SQLCODE;
         K_DESCERROR :=SUBSTR(SQLERRM, 1, 250);
         ROLLBACK;
       END;
   END ADMPSI_QUITA_BONO;


   PROCEDURE ADMPSI_REG_SALDOS(K_COD_CLI      IN VARCHAR2,
                               K_SALDO        IN NUMBER,
                               K_GRUPO        IN VARCHAR2,
                               K_USUARIO      IN VARCHAR2,
                               K_CODERROR     OUT NUMBER,
                               K_DESCERROR    OUT VARCHAR2) IS
  BEGIN
    K_CODERROR  := 0;
    K_DESCERROR := '';
		IF K_GRUPO=0 THEN
			BEGIN
		    UPDATE PCLUB.ADMPT_SALDOS_CLIENTE SC
               SET SC.ADMPN_SALDO_CC= K_SALDO
                  ,SC.ADMPD_FEC_MOD = SYSDATE
        WHERE SC.ADMPV_COD_CLI=K_COD_CLI
          AND SC.ADMPC_ESTPTO_CC='A';

				EXCEPTION
					WHEN OTHERS THEN
						K_CODERROR  := -1;
						K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
			END;
		ELSIF K_GRUPO=1 OR K_GRUPO=2 THEN
			BEGIN
				UPDATE PCLUB.ADMPT_SALDOS_BONO_CLIENTE BC
               SET BC.ADMPN_SALDO  = K_SALDO
              ,BC.ADMPD_FEC_MOD= SYSDATE
              ,BC.ADMPV_USU_MOD=K_USUARIO
        WHERE  BC.ADMPV_COD_CLI=K_COD_CLI
           AND BC.ADMPV_ESTADO  = 'A'
           AND BC.ADMPN_GRUPO   = K_GRUPO;

				EXCEPTION
					WHEN OTHERS THEN
						K_CODERROR  := -1;
						K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
				END;
		END IF;

  END ADMPSI_REG_SALDOS;

  PROCEDURE ADMPSS_BONO_CFG(K_BONO           IN VARCHAR2,
                            K_IDENT          IN NUMBER,
                            K_DESCBONO       OUT VARCHAR2,
                            K_CODMSJSMS      OUT VARCHAR2,
                            K_CUR_BONOCONFIG OUT SYS_REFCURSOR,
                            K_CODERROR       OUT NUMBER,
                            K_DESCERROR      OUT VARCHAR2) IS

    V_CONTADOR NUMBER;
    V_BONO     VARCHAR2(20);
    EX_ERROR EXCEPTION;
  BEGIN

    CASE
      WHEN K_BONO IS NULL AND K_IDENT IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese el identificador o descripción del bono.';
        RAISE EX_ERROR;
      ELSE
        K_CODERROR  := 0;
        K_DESCERROR := '';
    END CASE;

    IF K_IDENT IS NOT NULL AND K_BONO IS NULL THEN
      --Se envió el ID Bono(Bonos de Alta)
      --Ahora, validamos que se haya enviado un Identificador de Bono válido
      SELECT COUNT(1)
        INTO V_CONTADOR
        FROM PCLUB.ADMPT_BONO B
       WHERE ADMPN_ID_BONO_PRE = K_IDENT;

      IF V_CONTADOR = 0 THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese un identificador válido de Bono.';
        RAISE EX_ERROR;
      END IF;

      SELECT ADMPV_BONO, ADMPV_DESCBONO, ADMPV_MENSAJE
        INTO V_BONO, K_DESCBONO, K_CODMSJSMS
        FROM PCLUB.ADMPT_BONO
       WHERE ADMPN_ID_BONO_PRE = K_IDENT;
    END IF;

    IF K_BONO IS NOT NULL AND K_IDENT IS NULL THEN
      --Se envió la descripción del Bono(Bonos de Fidelidad)
      --Ahora, validamos que se haya enviado una descripción de Bono válida
      SELECT COUNT(1)
        INTO V_CONTADOR
        FROM PCLUB.ADMPT_BONO
       WHERE ADMPV_BONO = K_BONO;

      IF V_CONTADOR = 0 THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese una descripción válida de Bono.';
        RAISE EX_ERROR;
      END IF;

      SELECT ADMPV_BONO, ADMPV_DESCBONO, ADMPV_MENSAJE
        INTO V_BONO, K_DESCBONO, K_CODMSJSMS
        FROM PCLUB.ADMPT_BONO
       WHERE ADMPV_BONO = K_BONO;
    END IF;

    IF V_BONO IS NOT NULL THEN
      --Cursor de Configuración del Bono
      --Aqui el cambio nuevo campo ADMPV_COD_CPTO_SAL -- concepto de salida
      OPEN K_CUR_BONOCONFIG FOR
        SELECT BC.ADMPV_BONO,
               BC.ADMPN_PUNTOS,
               BC.ADMPV_COD_CPTO,
               BC.ADMPN_DIASVIGEN,
               BC.ADMPV_COD_TPOPR,
               BC.ADMPV_COD_CPTO_SAL
          FROM PCLUB.ADMPT_BONO_CONFIG BC
         WHERE BC.ADMPV_BONO = V_BONO;
    ELSE
      K_CODERROR  := 4;
      K_DESCERROR := 'El identificador de Bono ingresado, no se encuentra configurado.';
      RAISE EX_ERROR;
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
          K_DESCERROR := 'ERROR EN SP ADMPSS_OBT_CONFIG. ';
      END;
      OPEN K_CUR_BONOCONFIG FOR
        SELECT '' ADMPV_BONO,
               '' ADMPN_PUNTOS,
               '' ADMPV_COD_CPTO,
               '' ADMPN_DIASVIGEN,
               '' ADMPV_COD_TPOPR
          FROM DUAL
         WHERE 1 = 0;
    WHEN OTHERS THEN
      K_CODERROR  := -1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      OPEN K_CUR_BONOCONFIG FOR
        SELECT '' ADMPV_BONO,
               '' ADMPN_PUNTOS,
               '' ADMPV_COD_CPTO,
               '' ADMPN_DIASVIGEN,
               '' ADMPV_COD_TPOPR
          FROM DUAL
         WHERE 1 = 0;
  END ADMPSS_BONO_CFG;


END PKG_CC_BONOS;
/