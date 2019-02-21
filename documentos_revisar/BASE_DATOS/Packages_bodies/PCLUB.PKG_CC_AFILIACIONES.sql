create or replace package body pclub.PKG_CC_AFILIACIONES is

FUNCTION VAL_CLIENTE_IBK(K_ADMPV_TIPO_DOC   IN PCLUB.ADMPT_CLIENTEIB.ADMPV_TIPO_DOC%TYPE,
                         K_ADMPV_NUM_DOC    IN PCLUB.ADMPT_CLIENTEIB.ADMPV_NUM_DOC%TYPE,
                         K_ADMPN_COD_CLI_IB OUT PCLUB.ADMPT_CLIENTEIB.ADMPN_COD_CLI_IB%TYPE)
  RETURN NUMBER IS
  --Funcion que retrona si es un cliente IB, apartir del numero de documento y tipo de documento
  --para fines de validaciones en el procesos de afiliados
  K_RPTA NUMBER; --Respuesta a la funcion  1 existe el cliente IBK y 0  el cliente IBK No existe
  K_CONT NUMBER; --Almacena el numero de registros
BEGIN

  K_CONT := 0; --Iniciando la variable  a 0
  K_RPTA := 1; --Inicializamos como todo verdad 1
  -----------------------------------
  SELECT NVL(COUNT(1), 0)
    INTO K_CONT
    FROM ADMPT_CLIENTEIB
   WHERE ADMPV_TIPO_DOC = K_ADMPV_TIPO_DOC
     AND ADMPV_NUM_DOC = K_ADMPV_NUM_DOC
     AND ADMPC_ESTADO = 'A';

  IF (K_CONT > 0) AND (K_CONT < 2) THEN
    SELECT ADMPN_COD_CLI_IB
      INTO K_ADMPN_COD_CLI_IB
      FROM ADMPT_CLIENTEIB
     WHERE ADMPV_TIPO_DOC = K_ADMPV_TIPO_DOC
       AND ADMPV_NUM_DOC = K_ADMPV_NUM_DOC
       AND ADMPC_ESTADO = 'A';
  ELSIF (K_CONT = 0) THEN
    --Si el contador de registro nos entrega un valor 0 no exite registro buscado
    K_ADMPN_COD_CLI_IB := 0;
    K_RPTA             := 0; -- No existe registro
  END IF;

  RETURN(K_RPTA);
EXCEPTION
  WHEN OTHERS THEN
    K_ADMPN_COD_CLI_IB := 0;
    K_RPTA             := 0;
    RETURN(K_RPTA);

END VAL_CLIENTE_IBK;

FUNCTION VAL_EXISTE_AFILIACION(K_ADMPN_COD_CLI_IB IN PCLUB.ADMPT_CLIENTEIB.ADMPN_COD_CLI_IB%TYPE,
                               K_ADMPV_COD_CLI    IN PCLUB.ADMPT_CLIENTEIB.ADMPV_COD_CLI%TYPE,
                               K_ADMPV_NUM_LINEA  IN PCLUB.ADMPT_CLIENTEIB.ADMPV_NUM_LINEA%TYPE,
                               K_TIPO_LINEA       IN PCLUB.ADMPT_CLIENTEIB.ADMPV_TIPO_DOC%TYPE)
  RETURN NUMBER IS
  --Funcion para validar si un cliente esta afiliado a un linea  y tambien si es Postpago o Prepago
  --para fines de validaciones en el procesos de afiliados
  K_RPTA          NUMBER; --Valor de retorno de la funcion
  K_CONT          NUMBER; --Contador de registros
  K_GET_NUM_LINEA PCLUB.ADMPT_CLIENTEIB.ADMPV_NUM_LINEA%TYPE;
  K_GET_COD_CLI   PCLUB.ADMPT_CLIENTEIB.ADMPV_COD_CLI%TYPE;
BEGIN
  K_CONT := 0; --Iniciando la variable  a 0
  K_RPTA := 1; --Inicializamos como todo verdad 1
  -----------------------------------
  SELECT NVL(COUNT(1), 0)
    INTO K_CONT
    FROM ADMPT_CLIENTEIB
   WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB
     AND ADMPC_ESTADO = 'A';

  IF (K_CONT > 0) THEN
    --------------------------------------------- -
    SELECT ADMPV_NUM_LINEA, ADMPV_COD_CLI
      INTO K_GET_NUM_LINEA, K_GET_COD_CLI
      FROM ADMPT_CLIENTEIB
     WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB

   --VARIABLE DE ENTRADA
       AND ADMPC_ESTADO = 'A';
    ---------------------------------------------
    IF K_GET_COD_CLI <> ' ' AND K_GET_NUM_LINEA <> ' ' THEN
      ---------------------------------------------
      IF K_TIPO_LINEA = '1' OR K_TIPO_LINEA = '2' THEN

        IF K_GET_NUM_LINEA = K_ADMPV_NUM_LINEA AND
           K_GET_COD_CLI = K_ADMPV_COD_CLI THEN
          K_RPTA := 0; --La Linea postpago ingresada ya se encuentra afiliada
        ELSE
          K_RPTA := 1; --Es postpago y se debe actualizar ls afiliacion
        END IF;

      ELSIF K_TIPO_LINEA = '3' THEN
        IF K_GET_NUM_LINEA = K_ADMPV_NUM_LINEA AND
           K_GET_COD_CLI = K_ADMPV_NUM_LINEA THEN
          K_RPTA := 0; -- La Linea prepago ingresada ya se encuentra afiliada
        ELSE
          K_RPTA := 1; --Es prepago y se debe actualizar la afiliacion
        END IF;
      END IF;
      ---------------------------------------------
    ELSE
      K_RPTA := 2; --Nunca tuvo afiliacion es NUEVO
    END IF;

  ELSE
    K_RPTA := 3; --El registro consultado no existe
  END IF;

  RETURN(K_RPTA);

EXCEPTION
  WHEN OTHERS THEN
    K_RPTA := 3;
    RETURN(K_RPTA);
END VAL_EXISTE_AFILIACION;

FUNCTION VAL_EXISTE_CLARO_CLUB(K_ADMPV_NUM_DOC  IN PCLUB.ADMPT_CLIENTE.ADMPV_NUM_DOC%TYPE,
                               K_ADMPV_TIPO_DOC IN PCLUB.ADMPT_CLIENTE.ADMPV_TIPO_DOC%TYPE,
                               K_ADMPV_COD_CLI  IN PCLUB.ADMPT_CLIENTE.ADMPV_COD_CLI%TYPE)
  RETURN NUMBER IS
  K_RPTA NUMBER; --Valor de retorno de la funcion
  K_CONT NUMBER; --Contador de registros
BEGIN

  K_RPTA := 1;
  K_CONT := 0;

  SELECT NVL(COUNT(1), 0)
    INTO K_CONT
    FROM PCLUB.ADMPT_CLIENTE
   WHERE ADMPV_COD_CLI = K_ADMPV_COD_CLI
     AND ADMPV_NUM_DOC = K_ADMPV_NUM_DOC
     AND ADMPV_TIPO_DOC = K_ADMPV_TIPO_DOC
     AND ADMPC_ESTADO = 'A';
   --- SE VALIDA QUE EL CLIENTE EXISTA EN CC.

  IF (K_CONT > 0) THEN
    K_RPTA := 1;
  ELSE
    K_RPTA := 0;
  END IF;

  RETURN(K_RPTA);
EXCEPTION
  WHEN OTHERS THEN
    K_RPTA := 0;
    RETURN(K_RPTA);
END VAL_EXISTE_CLARO_CLUB;

FUNCTION VAL_EXISTE_BONO(K_ADMPN_COD_CLI_IB IN PCLUB.ADMPT_AFILIACIONTC.ADMPN_COD_CLI_IB%TYPE)
  RETURN NUMBER IS
  K_RPTA NUMBER; --Valor de retorno de la funcion
  K_CONT NUMBER; --Contador de registros
BEGIN

  SELECT NVL(COUNT(1), 0)
    INTO K_CONT
    FROM ADMPT_AFILIACIONTC
   WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB
     AND ADMPC_ESTADO_BONO IN ('P', 'E');

  IF (K_CONT > 0) THEN
    K_RPTA := 1;
  ELSE
    K_RPTA := 0;
  END IF;

  RETURN(K_RPTA);
EXCEPTION
  WHEN OTHERS THEN
    K_RPTA := 0;
    RETURN(K_RPTA);

END VAL_EXISTE_BONO;

PROCEDURE ADMPSS_PROCESAR_AFILIACION(K_ADMPV_TIPO_DOC  IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_TIPO_DOC%TYPE,
                                     K_ADMPV_NUM_DOC   IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_NUM_DOC%TYPE,
                                     K_ADMPV_NUM_LINEA IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_NUM_LINEA%TYPE,
                                     K_ADMPN_SN_CODE IN PCLUB.ADMPT_AFILIACIONTC.ADMPN_SN_CODE%TYPE,
                                     K_ADMPN_SP_CODE IN PCLUB.ADMPT_AFILIACIONTC.ADMPN_SP_CODE%TYPE,
                                     K_ADMPV_MENSAJE IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_MENSAJE%TYPE,
                                     K_ADMPV_USU_REG IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_USU_REG%TYPE,
                                     K_ADMPV_USU_MOD IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_USU_MOD%TYPE,
                                     K_ADMPV_COD_CLI IN VARCHAR2,
                                     K_ADMPV_TPO_CLI IN VARCHAR2,
                                     K_COID          IN VARCHAR2,
                                     K_ESTADOLINEA   IN VARCHAR2,
                                     K_CICLOFACT     IN VARCHAR2,
                                     K_EXITOTRANS    OUT NUMBER,
                                     K_CODERROR      OUT NUMBER,
                                     K_DESCERROR     OUT VARCHAR2)

 IS
  K_VAL_EXISTE_CLIENTE_IB NUMBER;
  K_VAL_EXISTE_CLIENTE_CC NUMBER;
  K_VAL_EXISTE_AFILIACION NUMBER;
  K_VAL_ENTREGA_BONO      NUMBER;
  V_EXIST                 NUMBER;
  V_EXITOAFILIA           NUMBER;
  V_SALDO_CC              NUMBER;
  V_SALDO_IB              NUMBER;
  K_ADMPC_ESTADO_BONO     PCLUB.ADMPT_AFILIACIONTC.ADMPC_ESTADO_BONO%TYPE;
  K_ADMPN_COD_CLI_IB      PCLUB.ADMPT_AFILIACIONTC.ADMPN_COD_CLI_IB%TYPE;
  K_ADMPV_TPOLINEA        PCLUB.ADMPT_AFILIACIONTC.ADMPV_TPOLINEA%TYPE;
  K_ADMPV_NUM_LINEA_BONO  VARCHAR2(100);
  K_BONO_ACT              VARCHAR2(20);

  ERROR_REGISTRAR EXCEPTION;
  ERROR_TRIOS EXCEPTION;
  VL_MENSAJE            VARCHAR2(200);
  K_CODERROR_REG        NUMBER;
  K_DESCERROR_REG       VARCHAR2(200);
  K_ADMPN_ID_AFILIACION PCLUB.ADMPT_AFILIACIONTC.ADMPN_ID_AFILIACION%TYPE;

  K_VALOR           VARCHAR2(200);
  K_CODERROR_TRIOS  VARCHAR2(200);
  K_DESCERROR_TRIOS VARCHAR2(200);
  V_ID_SALDO        VARCHAR2(200);
  v_Conteo          number;

BEGIN
  v_Conteo               :=0;
  K_EXITOTRANS           := 1;
  K_CODERROR             := NULL;
  K_DESCERROR            := '';
  V_EXIST                := 0;
  K_ADMPV_NUM_LINEA_BONO := '';

  K_VAL_EXISTE_CLIENTE_IB := VAL_CLIENTE_IBK(K_ADMPV_TIPO_DOC,
                                             K_ADMPV_NUM_DOC,
                                             K_ADMPN_COD_CLI_IB);

  IF K_VAL_EXISTE_CLIENTE_IB = 1 THEN
    --1 Existe el cliente IBK
    K_VAL_EXISTE_CLIENTE_CC := VAL_EXISTE_CLARO_CLUB(K_ADMPV_NUM_DOC,
                                                     K_ADMPV_TIPO_DOC,
                                                     K_ADMPV_COD_CLI);
    IF (K_VAL_EXISTE_CLIENTE_CC = 1) THEN
      K_VAL_EXISTE_AFILIACION := VAL_EXISTE_AFILIACION(K_ADMPN_COD_CLI_IB,
                                                       K_ADMPV_COD_CLI,
                                                       K_ADMPV_NUM_LINEA,
                                                       K_ADMPV_TPO_CLI);

      IF K_ADMPV_TPO_CLI = 1 OR K_ADMPV_TPO_CLI = 2 THEN
        K_ADMPV_TPOLINEA := 'POSTPAGO';
      ELSIF K_ADMPV_TPO_CLI = '3' THEN
        K_ADMPV_TPOLINEA := 'PREPAGO';
      END IF;

      IF (K_VAL_EXISTE_AFILIACION = 1) THEN
        --Validacion de bono
        K_VAL_ENTREGA_BONO := VAL_EXISTE_BONO(K_ADMPN_COD_CLI_IB);
        IF (K_VAL_ENTREGA_BONO = 1) THEN
          --Ya se entrego el bono
          K_ADMPC_ESTADO_BONO := 'N';
        ELSE
          --Se debe entregar el bono
          --K_ADMPC_ESTADO_BONO := 'P';

          --valido que estado colocar en Estado de Bono
          SELECT ADMPN_BONO_ACT
            INTO K_BONO_ACT
            FROM ADMPT_CLIENTEIB CI
           WHERE CI.ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB;

          IF K_BONO_ACT <> '2' THEN
            /*K_ADMPC_ESTADO_BONO := 'P';*/

            /*Valido que la linea que se va a afiliar tenga trios*/

            IF K_ADMPV_TPO_CLI = 1 OR K_ADMPV_TPO_CLI = 2 THEN
              ADMPSI_VALIDATRIOS(K_COID,
                                 K_VALOR,
                                 K_CODERROR_TRIOS,
                                 K_DESCERROR_TRIOS);

              IF K_CODERROR_TRIOS <> '1' THEN
                IF K_VALOR = '1' AND K_ESTADOLINEA = 'Activo' AND
                   K_CICLOFACT = 'A' THEN
                  K_ADMPC_ESTADO_BONO    := 'P';
                  K_ADMPV_NUM_LINEA_BONO := K_ADMPV_NUM_LINEA;
                ELSE
                  K_ADMPC_ESTADO_BONO := 'N';
                END IF;
              ELSE
                RAISE ERROR_TRIOS;
              END IF;
            ELSIF K_ADMPV_TPO_CLI = '3' THEN
              K_ADMPC_ESTADO_BONO    := 'P';
              K_ADMPV_NUM_LINEA_BONO := K_ADMPV_NUM_LINEA;
            END IF;

          ELSE
            K_ADMPC_ESTADO_BONO := 'N';
          END IF;
        END IF;

        BEGIN

          ADMPSS_REGAFILIACION(K_ADMPV_TIPO_DOC,
                               K_ADMPV_NUM_DOC,
                               K_ADMPV_NUM_LINEA,
                               K_ADMPC_ESTADO_BONO,
                               NULL,
                               SYSDATE,
                               K_ADMPV_TPOLINEA,
                               K_ADMPN_COD_CLI_IB,
                               K_ADMPN_SN_CODE,
                               K_ADMPN_SP_CODE,
                               K_ADMPV_MENSAJE,
                               K_ADMPV_USU_REG,
                               K_ADMPV_NUM_LINEA_BONO,
                               V_EXITOAFILIA,
                               K_CODERROR_REG,
                               K_DESCERROR_REG);
          IF V_EXITOAFILIA > 0 THEN
            RAISE ERROR_REGISTRAR;
          END IF;

          --Actualizar tabla cliente IBK
          -----------------------------------------
          IF K_ADMPV_TPO_CLI = 1 OR K_ADMPV_TPO_CLI = 2 THEN
            UPDATE ADMPT_CLIENTEIB
               SET ADMPV_COD_CLI   = K_ADMPV_COD_CLI,
                   ADMPV_NUM_LINEA = K_ADMPV_NUM_LINEA
             WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB;
          ELSIF K_ADMPV_TPO_CLI = 3 THEN
            UPDATE ADMPT_CLIENTEIB
               SET ADMPV_COD_CLI   = K_ADMPV_NUM_LINEA,
                   ADMPV_NUM_LINEA = K_ADMPV_NUM_LINEA
             WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB;
          END IF;
          --Actualiza Tabla saldo cliente
          -----------------------------------------
          --primero busco si la linea a afiliar existe en la tabla saldo

          SELECT NVL(COUNT(*), 0)
            INTO V_EXIST
            FROM admpt_saldos_cliente A
           WHERE A.ADMPV_COD_CLI = K_ADMPV_COD_CLI;

          IF V_EXIST > 0 THEN
            --Obtengo su saldo
            BEGIN
              SELECT NVL(MAX(ADMPN_SALDO_CC), 0)
                INTO V_SALDO_CC
                FROM ADMPT_SALDOS_CLIENTE
               WHERE ADMPV_COD_CLI = K_ADMPV_COD_CLI;
            EXCEPTION
              WHEN TOO_MANY_ROWS THEN
                K_DESCERROR := 'Registros duplicados para el Cliente ' ||
                               K_ADMPV_COD_CLI;
              WHEN OTHERS THEN
                K_DESCERROR := 'Error al consultar tabla ADMPT_SALDOS_CLIENTE con ADMPV_COD_CLI ' ||
                               K_ADMPV_COD_CLI;
            END;

            BEGIN
              --obtengo el saldo de ClienteIB
              SELECT NVL(admpn_saldo_ib, 0)
                INTO V_SALDO_IB
                FROM ADMPT_SALDOS_CLIENTE
               WHERE admpn_cod_cli_ib = K_ADMPN_COD_CLI_IB;
            EXCEPTION
              WHEN TOO_MANY_ROWS THEN
                K_DESCERROR := 'Registros duplicados para el Cliente ' ||
                               K_ADMPN_COD_CLI_IB;
              WHEN OTHERS THEN
                K_DESCERROR := 'Error al consultar tabla ADMPT_SALDOS_CLIENTE con ADMPV_COD_CLI_IB ' ||
                               K_ADMPN_COD_CLI_IB;
            END;

            --ELIMINO el cliente IB
            UPDATE ADMPT_SALDOS_CLIENTE
               SET ADMPN_COD_CLI_IB = '',
                   ADMPC_ESTPTO_IB  = '',
                   admpn_saldo_ib   = ''
             WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB;

            --asocio al cliente IB y a la nueva linea

            UPDATE ADMPT_SALDOS_CLIENTE
               SET ADMPN_SALDO_IB   = V_SALDO_IB,
                   ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB,
                   ADMPC_ESTPTO_CC  = 'A',
                   ADMPC_ESTPTO_IB  = 'A'
             WHERE ADMPV_COD_CLI = K_ADMPV_COD_CLI;

          ELSE
            UPDATE ADMPT_SALDOS_CLIENTE
               SET ADMPN_SALDO_CC  = 0,
                   ADMPV_COD_CLI   = K_ADMPV_COD_CLI,
                   ADMPC_ESTPTO_CC = 'A',
                   ADMPC_ESTPTO_IB = 'A'
             WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB;

          END IF;

          -----------------------------------------
          --Actualiza Tabla Kardex
          -----------------------------------------
          UPDATE ADMPT_KARDEX
             SET ADMPV_COD_CLI = K_ADMPV_COD_CLI
           WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB
             AND ADMPC_TPO_PUNTO = 'I';

          UPDATE ADMPT_KARDEX
             SET ADMPN_COD_CLI_IB = NULL
           WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB
             AND ADMPC_TPO_PUNTO <> 'I';

        EXCEPTION
          WHEN ERROR_REGISTRAR THEN
            K_DESCERROR  := SUBSTR(SQLERRM, 1, 400);
            K_EXITOTRANS := 0;
          WHEN ERROR_TRIOS THEN
            K_DESCERROR  := SUBSTR(SQLERRM, 1, 400);
            K_EXITOTRANS := 0;
          WHEN OTHERS THEN
            K_DESCERROR  := SUBSTR(SQLERRM, 1, 400);
            K_EXITOTRANS := 0;
        END;

      ELSIF (K_VAL_EXISTE_AFILIACION = 2) THEN

        --ES UNA NUEVA AFILIACION
        --valido que estado colocar en Estado de Bono
        K_VAL_ENTREGA_BONO := VAL_EXISTE_BONO(K_ADMPN_COD_CLI_IB);
        IF (K_VAL_ENTREGA_BONO = 1) THEN
          --Ya se entrego el bono
          K_ADMPC_ESTADO_BONO := 'N';
        ELSE
          --Se debe entregar el bono
          --K_ADMPC_ESTADO_BONO := 'P';
          --valido que estado colocar en Estado de Bono
          SELECT ADMPN_BONO_ACT
            INTO K_BONO_ACT
            FROM ADMPT_CLIENTEIB CI
           WHERE CI.ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB;

          IF K_BONO_ACT <> '2' THEN
            /*K_ADMPC_ESTADO_BONO := 'P';*/

            /*Valido que la linea que se va a afiliar tenga trios*/

            IF K_ADMPV_TPO_CLI = 1 OR K_ADMPV_TPO_CLI = 2 THEN
              ADMPSI_VALIDATRIOS(K_COID,
                                 K_VALOR,
                                 K_CODERROR_TRIOS,
                                 K_DESCERROR_TRIOS);

              IF K_CODERROR_TRIOS <> '1' THEN
                IF K_VALOR = '1' AND K_ESTADOLINEA = 'Activo' AND
                   K_CICLOFACT = 'A' THEN
                  K_ADMPC_ESTADO_BONO    := 'P';
                  K_ADMPV_NUM_LINEA_BONO := K_ADMPV_NUM_LINEA;
                ELSE
                  K_ADMPC_ESTADO_BONO := 'N';
                END IF;
              ELSE
                RAISE ERROR_TRIOS;
              END IF;
            ELSIF K_ADMPV_TPO_CLI = '3' THEN
              K_ADMPC_ESTADO_BONO    := 'P';
              K_ADMPV_NUM_LINEA_BONO := K_ADMPV_NUM_LINEA;
            END IF;

          ELSE
            K_ADMPC_ESTADO_BONO := 'N';
          END IF;
        END IF;
        BEGIN
          ADMPSS_REGAFILIACION(K_ADMPV_TIPO_DOC,
                               K_ADMPV_NUM_DOC,
                               K_ADMPV_NUM_LINEA,
                               K_ADMPC_ESTADO_BONO,
                               NULL,
                               SYSDATE,
                               K_ADMPV_TPOLINEA,
                               K_ADMPN_COD_CLI_IB,
                               K_ADMPN_SN_CODE,
                               K_ADMPN_SP_CODE,
                               K_ADMPV_MENSAJE,
                               K_ADMPV_USU_REG,
                               K_ADMPV_NUM_LINEA_BONO,
                               V_EXITOAFILIA,
                               K_CODERROR_REG,
                               K_DESCERROR_REG);

          IF V_EXITOAFILIA > 0 THEN
            RAISE ERROR_REGISTRAR;
          END IF;

          --Actualizar tabla cliente IBK
          -----------------------------------------
          IF K_ADMPV_TPO_CLI = 1 OR K_ADMPV_TPO_CLI = 2 THEN
            UPDATE ADMPT_CLIENTEIB
               SET ADMPV_COD_CLI   = K_ADMPV_COD_CLI,
                   ADMPV_NUM_LINEA = K_ADMPV_NUM_LINEA
             WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB;
          ELSIF K_ADMPV_TPO_CLI = 3 THEN
            UPDATE ADMPT_CLIENTEIB
               SET ADMPV_COD_CLI   = K_ADMPV_NUM_LINEA,
                   ADMPV_NUM_LINEA = K_ADMPV_NUM_LINEA
             WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB;
          END IF;
          --Actualiza Tabla saldo cliente
          -----------------------------------------
          SELECT NVL(COUNT(*), 0)
            INTO V_EXIST
            FROM admpt_saldos_cliente A
           WHERE A.ADMPV_COD_CLI = K_ADMPV_COD_CLI;

          IF V_EXIST > 0 THEN
            BEGIN
              --Obtengo su saldo
              SELECT NVL(MAX(ADMPN_SALDO_CC), 0)
                INTO V_SALDO_CC
                FROM ADMPT_SALDOS_CLIENTE
               WHERE ADMPV_COD_CLI = K_ADMPV_COD_CLI;
            EXCEPTION
              WHEN TOO_MANY_ROWS THEN
                K_DESCERROR := 'Registros duplicados para el Cliente ' ||
                               K_ADMPV_COD_CLI;
              WHEN OTHERS THEN
                K_DESCERROR := 'Error al consultar tabla ADMPT_SALDOS_CLIENTE con ADMPV_COD_CLI ' ||
                               K_ADMPV_COD_CLI;
            END;
            --ACTUALIZO
           SELECT MIN(admpn_id_saldo)
                INTO V_ID_SALDO
                FROM ADMPT_SALDOS_CLIENTE
                WHERE ADMPV_COD_CLI = K_ADMPV_COD_CLI 
                --and (ADMPN_COD_CLI_IB != K_ADMPN_COD_CLI_IB OR ADMPN_COD_CLI_IB IS NULL);
                and ((ADMPN_COD_CLI_IB != K_ADMPN_COD_CLI_IB OR ADMPN_COD_CLI_IB IS NULL) OR ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB);

            UPDATE ADMPT_SALDOS_CLIENTE
               SET ADMPN_SALDO_CC  = V_SALDO_CC,
                   ADMPV_COD_CLI   = K_ADMPV_COD_CLI,
                   ADMPC_ESTPTO_CC = 'A',
                   ADMPC_ESTPTO_IB = 'A'
             WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB;
            --ELIMINO REGISTRO
            DELETE FROM ADMPT_SALDOS_CLIENTE
            WHERE admpn_id_saldo=V_ID_SALDO and ADMPN_COD_CLI_IB != K_ADMPN_COD_CLI_IB;

          ELSE
            UPDATE ADMPT_SALDOS_CLIENTE
               SET ADMPN_SALDO_CC  = 0,
                   ADMPV_COD_CLI   = K_ADMPV_COD_CLI,
                   ADMPC_ESTPTO_CC = 'A',
                   ADMPC_ESTPTO_IB = 'A'
             WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB;
          END IF;
          --Actualiza Tabla Kardex
          -----------------------------------------
          UPDATE ADMPT_KARDEX
             SET ADMPV_COD_CLI = K_ADMPV_COD_CLI
           WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB
             AND ADMPC_TPO_PUNTO = 'I';

          UPDATE ADMPT_KARDEX
             SET ADMPN_COD_CLI_IB = NULL
           WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB
             AND ADMPC_TPO_PUNTO <> 'I';

        EXCEPTION
          WHEN ERROR_TRIOS THEN
            K_DESCERROR  := SUBSTR(SQLERRM, 1, 400);
            K_EXITOTRANS := 0;
          WHEN ERROR_REGISTRAR THEN
            K_DESCERROR  := SUBSTR(SQLERRM, 1, 400);
            K_EXITOTRANS := 0;
          WHEN OTHERS THEN
            K_DESCERROR  := SUBSTR(SQLERRM, 1, 400);
            K_EXITOTRANS := 0;
        END;

      ELSIF (K_VAL_EXISTE_AFILIACION = 0) THEN
        --Ya se encuentra afiliado
        K_DESCERROR  := 'La linea ingresada ya se encuentra afiliada';
        K_EXITOTRANS := 0;
      END IF;

    ELSE
      dbms_output.put_line(K_ADMPV_NUM_DOC);
      select count(ADMPV_NUM_DOC) into v_Conteo from pclub.admpt_cliente where ADMPV_NUM_DOC=K_ADMPV_NUM_DOC and admpv_cod_cli=K_ADMPV_COD_CLI;
      IF v_Conteo > 0 THEN 
        begin
          K_DESCERROR  := 'La linea que desea afiliar no existe en Claro Club';
        end;
      ELSE --significa que el DNI que se intenta afiliar no pertenece al cliente 
        begin
         K_DESCERROR  := 'El DNI:'||K_ADMPV_NUM_DOC||', no pertenece a la línea:'||K_ADMPV_NUM_LINEA;              
        end;
      END IF;
      K_EXITOTRANS := 0;
    END IF;
  ELSE
    K_DESCERROR  := 'El Cliente IB no existe';
    K_EXITOTRANS := 0;
  END IF;

  IF K_EXITOTRANS = 0 THEN
    ROLLBACK;
  ELSE
    COMMIT;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    K_DESCERROR  := SUBSTR(SQLERRM, 1, 400);
    K_EXITOTRANS := 0;
    ROLLBACK;
END ADMPSS_PROCESAR_AFILIACION;

procedure ADMPSI_VALIDATRIOS(K_COID      IN VARCHAR2,
                             K_VALOR     OUT NUMBER,
                             K_CODERROR  OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2)

 IS

  TYPE CURCLARO_DATOSCLIENTE IS REF CURSOR;
  C_CUR_DATOS_TRIADOS CURCLARO_DATOSCLIENTE;
  V_TRIADOS           NUMBER;

  V_TIPO_TRIADO      VARCHAR2(20);
  V_NUM_TRIO         INTEGER;
  V_TELEFONO         VARCHAR2(20);
  V_FACTOR           VARCHAR2(20);
  V_COD_TIPO_DESTINO VARCHAR2(20);
  V_TIPO_DESTINO     VARCHAR2(20);

BEGIN

  PKG_CLAROCLUB.admpss_triados(K_COID, C_CUR_DATOS_TRIADOS);
  V_TRIADOS := 1;
  FETCH C_CUR_DATOS_TRIADOS
    INTO v_Tipo_triado, v_num_trio, v_telefono, v_factor, v_cod_tipo_destino, v_tipo_destino;

  IF (C_CUR_DATOS_TRIADOS%rowcount = 0) THEN
    V_TRIADOS := 0;
  ELSE
    WHILE C_CUR_DATOS_TRIADOS %FOUND LOOP
      IF v_tipo_destino = 'CLARO' THEN
        BEGIN
          V_TRIADOS := 1;
          EXIT;
        END;
      ELSE
        V_TRIADOS := 0;
      END IF;

      FETCH C_CUR_DATOS_TRIADOS
        INTO v_Tipo_triado, v_num_trio, v_telefono, v_factor, v_cod_tipo_destino, v_tipo_destino;
    END LOOP;
  END IF;
  K_VALOR := V_TRIADOS;

  K_CODERROR := 0;
EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR  := 1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
END ADMPSI_VALIDATRIOS;

PROCEDURE ADMPSS_REGAFILIACION(K_ADMPV_TIPO_DOC       IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_TIPO_DOC%TYPE,
                                 K_ADMPV_NUM_DOC        IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_NUM_DOC%TYPE,
                                 K_ADMPV_NUM_LINEA      IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_NUM_LINEA%TYPE,
                                 K_ADMPC_ESTADO_BONO    IN PCLUB.ADMPT_AFILIACIONTC.ADMPC_ESTADO_BONO%TYPE,
                                 K_ADMPD_FEC_ENTBON     IN PCLUB.ADMPT_AFILIACIONTC.ADMPD_FEC_ENTBON%TYPE,
                                 K_ADMPD_FEC_AFILIA     IN PCLUB.ADMPT_AFILIACIONTC.ADMPD_FEC_AFILIA%TYPE,
                                 K_ADMPV_TPOLINEA       IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_TPOLINEA%TYPE,
                                 K_ADMPN_COD_CLI_IB     IN PCLUB.ADMPT_AFILIACIONTC.ADMPN_COD_CLI_IB%TYPE,
                                 K_ADMPN_SN_CODE        IN PCLUB.ADMPT_AFILIACIONTC.ADMPN_SN_CODE%TYPE,
                                 K_ADMPN_SP_CODE        IN PCLUB.ADMPT_AFILIACIONTC.ADMPN_SP_CODE%TYPE,
                                 K_ADMPV_MENSAJE        IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_MENSAJE%TYPE,
                                 K_ADMPV_USU_REG        IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_USU_REG%TYPE,
                                 K_ADMPV_NUM_LINEA_BONO IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_NUM_LINEA_BONO%TYPE,
                                 K_EXITOTRANS           OUT NUMBER,
                                 K_CODERROR             OUT NUMBER,
                                 K_DESCERROR            OUT VARCHAR2) IS
    K_ADMPN_ID_AFILIACION  PCLUB.ADMPT_AFILIACIONTC.ADMPN_ID_AFILIACION%TYPE;
    K_ADMPD_FEC_REG          PCLUB.ADMPT_AFILIACIONTC.ADMPD_FEC_REG%TYPE;
    BEGIN
    ------------------------------------------------
    K_ADMPN_ID_AFILIACION := 0;
    K_ADMPD_FEC_REG       := SYSDATE;
    --Extracion del identificador del registro
    SELECT NVL(PCLUB.ADMPN_ID_AFILIACION.NEXTVAL, '-1')
     INTO K_ADMPN_ID_AFILIACION
     FROM DUAL;
    ------------------------------------------------
    --Inicializando la variable de retorno
    K_EXITOTRANS := 0;
    K_CODERROR   := 0;
    K_DESCERROR  := '';
    ------------------------------------------------
    --Se reitro campos de usuario modifica y fecha de modificacion
    INSERT INTO ADMPT_AFILIACIONTC
      (ADMPN_ID_AFILIACION,
       ADMPV_TIPO_DOC,
       ADMPV_NUM_DOC,
       ADMPV_NUM_LINEA,
       ADMPC_ESTADO_BONO,
       ADMPD_FEC_ENTBON,
       ADMPD_FEC_AFILIA,
       ADMPV_TPOLINEA,
       ADMPN_COD_CLI_IB,
       ADMPN_SN_CODE,
       ADMPN_SP_CODE,
       ADMPV_MENSAJE,
       ADMPD_FEC_REG,
       ADMPV_USU_REG,
       ADMPV_NUM_LINEA_BONO)
    VALUES
      (K_ADMPN_ID_AFILIACION,
       K_ADMPV_TIPO_DOC,
       K_ADMPV_NUM_DOC,
       K_ADMPV_NUM_LINEA,
       K_ADMPC_ESTADO_BONO,
       K_ADMPD_FEC_ENTBON,
       K_ADMPD_FEC_AFILIA,
       K_ADMPV_TPOLINEA,
       K_ADMPN_COD_CLI_IB,
       K_ADMPN_SN_CODE,
       K_ADMPN_SP_CODE,
       K_ADMPV_MENSAJE,
       K_ADMPD_FEC_REG,
       K_ADMPV_USU_REG,
       K_ADMPV_NUM_LINEA_BONO);
    ------------------------------------------------
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
    WHEN VALUE_ERROR THEN
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

  END ADMPSS_REGAFILIACION;

procedure CORREGIR_AFILIACION_POSTPAGO(K_PARAM IN VARCHAR2)
IS

C_COD_IBK NUMBER;
C_DNI varchar2(25);
C_FECHA_REGISTRO date;
C_LINEA_NO_REGISTRADA varchar2(25);
C_TIPO_LINEA_NO_REGISTRADA varchar2(50);
C_CUENTA varchar2(50);
C_TIPO_DOC varchar2(5);
C_CICLO_FACTURACION VARCHAR(4);
--Variables para cuentas duplicadas en Saldos
C_CANTIDAD_SALDO NUMBER;
C_ID_SALDO NUMBER;

K_EXITOTRANS    NUMBER;
K_CODERROR      NUMBER;
K_DESCERROR     VARCHAR2(250);

CURSOR CUR_AFILIACIONES_IBK IS
select COD_IBK,DNI,FECHA_REGISTRO,LINEA_NO_REGISTRADA,FECHA_PROCESO,nvl(CUENTA,'') as CUENTA,b.admpv_tipo_doc,
b.admpv_cicl_fact
from pclub.tmp_procesar_afiliacion_ibk a
inner join pclub.admpt_cliente b on a.CUENTA = b.admpv_cod_cli
where b.admpv_tipo_doc is not null and a.TIPO_LINEA='POSTPAGO' and (a.estado_del_proceso='NO OK' or a.estado_del_proceso is null)--!='SI OK'
order by b.admpv_tipo_doc;

BEGIN

OPEN CUR_AFILIACIONES_IBK;
  FETCH CUR_AFILIACIONES_IBK 
  INTO C_COD_IBK,C_DNI,C_FECHA_REGISTRO,C_LINEA_NO_REGISTRADA,C_TIPO_LINEA_NO_REGISTRADA,C_CUENTA,C_TIPO_DOC,C_CICLO_FACTURACION;

  WHILE CUR_AFILIACIONES_IBK %FOUND LOOP
  
  ADMPSS_PROCESAR_AFILIACION(C_TIPO_DOC,C_DNI,C_LINEA_NO_REGISTRADA,1563,7,
           '','','',C_CUENTA,2,'','A',C_CICLO_FACTURACION,K_EXITOTRANS,K_CODERROR,K_DESCERROR);
  
  select COUNT(*) INTO C_CANTIDAD_SALDO From pclub.admpt_saldos_cliente where admpv_cod_cli =C_CUENTA ;
  
  if(C_CANTIDAD_SALDO>1) then
  begin
          select nvl(max(admpn_id_saldo),-99) into C_ID_SALDO From pclub.admpt_saldos_cliente where admpv_cod_cli = C_CUENTA and admpn_cod_cli_ib is null;
          delete From pclub.admpt_saldos_cliente where admpn_id_saldo= C_ID_SALDO;
  end;
  end if;
  
  if(K_EXITOTRANS<>0)then --significa que el proceso de afiliación fue correcto
  begin
    update pclub.tmp_procesar_afiliacion_ibk
    set fecha_proceso=sysdate,estado_del_proceso='SI OK', mensaje='La linea fue afiliado a IBK exitosamente.'
    where linea_no_registrada=C_LINEA_NO_REGISTRADA;
    commit;
  end;
  else--proceso de afiliación con error
    begin
    update pclub.tmp_procesar_afiliacion_ibk
    set fecha_proceso=sysdate,mensaje=K_DESCERROR, 
    estado_del_proceso=
    case K_DESCERROR
      when 'La linea ingresada ya se encuentra afiliada'then 'SI OK'
      else 'NO OK'
    end
    where linea_no_registrada=C_LINEA_NO_REGISTRADA;
    commit;
    end;
  end if;
  
  FETCH CUR_AFILIACIONES_IBK 
  INTO C_COD_IBK,C_DNI,C_FECHA_REGISTRO,C_LINEA_NO_REGISTRADA,C_TIPO_LINEA_NO_REGISTRADA,C_CUENTA,C_TIPO_DOC,C_CICLO_FACTURACION;
  
  END LOOP;

END CORREGIR_AFILIACION_POSTPAGO;

procedure CORREGIR_AFILIACION_PREPAGO(K_PARAM IN VARCHAR2)
IS

C_COD_IBK NUMBER;
C_DNI varchar2(25);
C_FECHA_REGISTRO date;
C_LINEA_NO_REGISTRADA varchar2(25);
C_TIPO_LINEA_NO_REGISTRADA varchar2(50);
C_CUENTA varchar2(50);
--Variables para cuentas duplicadas en Saldos
C_CANTIDAD_SALDO NUMBER;
C_ID_SALDO NUMBER;

K_EXITOTRANS    NUMBER;
K_CODERROR      NUMBER;
K_DESCERROR     VARCHAR2(250);

CURSOR CUR_AFILIACIONES_IBK IS
select COD_IBK,DNI,FECHA_REGISTRO,LINEA_NO_REGISTRADA,FECHA_PROCESO,nvl(CUENTA,'') as CUENTA
from pclub.tmp_procesar_afiliacion_ibk a WHERE TIPO_LINEA='PREPAGO' and (a.estado_del_proceso='NO OK' or a.estado_del_proceso is null); --!='SI OK';

BEGIN

OPEN CUR_AFILIACIONES_IBK;
  FETCH CUR_AFILIACIONES_IBK 
  INTO C_COD_IBK,C_DNI,C_FECHA_REGISTRO,C_LINEA_NO_REGISTRADA,C_TIPO_LINEA_NO_REGISTRADA,C_CUENTA;

  WHILE CUR_AFILIACIONES_IBK %FOUND LOOP
  
  ADMPSS_PROCESAR_AFILIACION('2',C_DNI,C_LINEA_NO_REGISTRADA,'','',
           '','','',C_LINEA_NO_REGISTRADA,2,'','A','',K_EXITOTRANS,K_CODERROR,K_DESCERROR);
           
  select COUNT(*) INTO C_CANTIDAD_SALDO From pclub.admpt_saldos_cliente where admpv_cod_cli =C_CUENTA ;
  
  if(C_CANTIDAD_SALDO>1) then
  begin
          select nvl(max(admpn_id_saldo),-99) into C_ID_SALDO From pclub.admpt_saldos_cliente where admpv_cod_cli = C_CUENTA and admpn_cod_cli_ib is null;
          delete From pclub.admpt_saldos_cliente where admpn_id_saldo= C_ID_SALDO;
  end;
  end if;
  
  IF(K_EXITOTRANS!=0) THEN
  BEGIN
           UPDATE ADMPT_IMP_ACCAMO_IB
           SET ADMPV_NUM_LINEA=C_LINEA_NO_REGISTRADA,
           ADMPD_FEC_OPER=SYSDATE,
           ADMPC_COD_ERROR='',
           ADMPV_MSJE_ERROR='',
           ADMPC_ACEP_BONO='S'
           WHERE ADMPN_ID_FILA = (SELECT MAX(ADMPN_ID_FILA) FROM ADMPT_IMP_ACCAMO_IB WHERE ADMPV_NUM_DOC=C_DNI);
           
    update pclub.tmp_procesar_afiliacion_ibk
    set fecha_proceso=sysdate,estado_del_proceso='SI OK', mensaje='La linea fue afiliado a IBK exitosamente.'
    where linea_no_registrada=C_LINEA_NO_REGISTRADA;
    commit;           
  END;
  ELSE
    begin
      update pclub.tmp_procesar_afiliacion_ibk
      set fecha_proceso=sysdate,mensaje=K_DESCERROR, estado_del_proceso='NO OK'
      where linea_no_registrada=C_LINEA_NO_REGISTRADA;
    commit;
    end;
  END IF;
  
  FETCH CUR_AFILIACIONES_IBK 
  INTO C_COD_IBK,C_DNI,C_FECHA_REGISTRO,C_LINEA_NO_REGISTRADA,C_TIPO_LINEA_NO_REGISTRADA,C_CUENTA;
END LOOP;

END CORREGIR_AFILIACION_PREPAGO;

--18/06/2012 06:06:37
--18/06/2012 06:06:45
procedure CORREGIR_ALINEACION_PCLUB(FECHAPROCESO VARCHAR2)
IS

c_codcli VARCHAR(40);
c_saldocli NUMBER;
c_saldocc NUMBER;
c_saldoib NUMBER;
c_kpuntos NUMBER;
c_ksaldo NUMBER;
c_nuevocc NUMBER;
c_nuevoib NUMBER;
c_inspuntos NUMBER;
c_inssaldo NUMBER;
k_codclienteib number;
c_codconcepto number;
c_tipooperacion varchar2(100);
c_estado_k varchar2(5);
K_CANTIDAD NUMBER;

CURSOR CUR_ALINEACIONES IS
select codcli,saldocli,saldocc,saldoib,kpuntos,ksaldo,nuevocc,nuevoib,inspuntos,inssaldo,
case when inssaldo>0 then 'E' else 'S' end TipoOperacion,
case when length(codcli)=9 and substr(codcli,0,1)='9' then '8' else '9' end COD_CPTO 
from CC_TMP_Procesar_Alineacion
WHERE to_char(proceso,'dd/MM/yyyy HH:mi:ss') = FECHAPROCESO;

BEGIN

OPEN CUR_ALINEACIONES;
  FETCH CUR_ALINEACIONES 
  INTO c_codcli,c_saldocli,c_saldocc,c_saldoib,c_kpuntos,c_ksaldo,c_nuevocc,c_nuevoib,c_inspuntos,c_inssaldo,c_tipooperacion,c_codconcepto;

  WHILE CUR_ALINEACIONES %FOUND LOOP
  
  SELECT COUNT(*) INTO K_CANTIDAD FROM admpt_kardex WHERE admpv_cod_cli = c_codcli AND admpv_nom_arch='PCLUB.CC_ALINEACIONES';
   
  UPDATE ADMPT_SALDOS_CLIENTE
  SET ADMPN_SALDO_CC=c_nuevocc,ADMPN_SALDO_IB=c_nuevoib
  WHERE ADMPV_COD_CLI = c_codcli;
  dbms_output.put_line('Alineado - Cuenta : ' || c_codcli);
  
  IF(c_inssaldo!=0) THEN
  BEGIN
    IF(K_CANTIDAD<=0) THEN
    BEGIN                   
      select NVL(MAX(admpn_cod_cli_ib),'') INTO k_codclienteib From admpt_clienteib where admpv_cod_cli=c_codcli;
      insert into admpt_kardex(admpn_id_kardex, admpn_cod_cli_ib, admpv_cod_cli, admpv_cod_cpto, admpd_fec_trans, admpn_puntos, admpv_nom_arch, admpc_tpo_oper, admpc_tpo_punto, admpn_sld_punto, admpc_estado)
      values(admpt_kardex_sq.nextval, k_codclienteib, c_codcli, c_codconcepto, TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD'),'YYYYMMDD'), c_inspuntos,  'PCLUB.CC_ALINEACIONES', c_tipooperacion, 'C', c_inssaldo, 'A');
      dbms_output.put_line('Alineado - Kardex [INS]: ' || c_codcli);
    END;
    ELSE
    BEGIN 
      IF(K_CANTIDAD=1)then
      begin
        
        select admpc_estado into c_estado_k from pclub.admpt_kardex 
        where admpv_cod_cli = c_codcli and admpv_nom_arch = 'PCLUB.CC_ALINEACIONES';
        
        if(c_estado_k='C') then
        begin
            update admpt_kardex set 
            admpn_sld_punto = (c_inssaldo),
            admpc_estado = 'A'
            --admpn_puntos = (admpn_puntos + c_inspuntos)
            where admpv_cod_cli =c_codcli and admpv_nom_arch='PCLUB.CC_ALINEACIONES';
            dbms_output.put_line('Alineado - Kardex [UPDC]: ' || c_codcli);        
        end;
        else
        begin
            update admpt_kardex set 
            admpn_sld_punto = (admpn_sld_punto + c_inssaldo)
            --admpn_puntos = (admpn_puntos + c_inspuntos)
            where admpv_cod_cli =c_codcli and admpv_nom_arch='PCLUB.CC_ALINEACIONES';
            dbms_output.put_line('Alineado - Kardex [UPD]: ' || c_codcli);
        end;
        end if;
        
      end;
      end if;
    END;
    END IF;
  END;
  ELSE
    dbms_output.put_line('SIN ALINEAR: ' || c_codcli);
  END IF;
  
 -- commit;
  
  FETCH CUR_ALINEACIONES 
  INTO c_codcli,c_saldocli,c_saldocc,c_saldoib,c_kpuntos,c_ksaldo,c_nuevocc,c_nuevoib,c_inspuntos,c_inssaldo,c_tipooperacion,c_codconcepto;
END LOOP;

END CORREGIR_ALINEACION_PCLUB;
 

    procedure TXTReactivacionRenovacion(k_fecha in date,k_cursor out sys_refcursor) as

begin
open k_cursor for
select yy.*,xx.* from pclub.admpt_cliente xx
right join (SELECT distinct cu.cscompregno,cu.ccfname, cu.cclname, cu.marital_status, cc.custcode,
cu.cccity, cu.ccstreet, cu.ccaddr3,trunc(sysdate)fecha_reg, cc.billcycle
FROM directory_number@dbl_bscs dn, curr_contr_services_cap@dbl_bscs csc,contract_all@dbl_bscs co, ccontact_all@dbl_bscs cu, customer_all@dbl_bscs cc
WHERE csc.dn_id = dn.dn_id 
AND co.co_id = csc.co_id
and co.co_id in (select CO_ID from curr_co_status@dbl_bscs ch where ch.ch_reason in (104,107,69,54,14)
and ch_status='a'  
 AND ch.ch_validfrom >= k_fecha-1
 AND ch.ch_validfrom <  k_fecha
and co.customer_id=cu.customer_id
and cc.customer_id=cu.customer_id
and cu.ccbill='X')) yy
on yy.cscompregno=xx.admpv_num_doc
where xx.admpv_cod_cli is null;

end TXTReactivacionRenovacion;

PROCEDURE PROCESAR_AFILIACION_PREPAGO(K_ADMPV_TIPO_DOC  IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_TIPO_DOC%TYPE,
                                     K_ADMPV_NUM_DOC   IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_NUM_DOC%TYPE,
                                     K_ADMPV_NUM_LINEA IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_NUM_LINEA%TYPE,
                                     K_ADMPN_SN_CODE IN PCLUB.ADMPT_AFILIACIONTC.ADMPN_SN_CODE%TYPE,
                                     K_ADMPN_SP_CODE IN PCLUB.ADMPT_AFILIACIONTC.ADMPN_SP_CODE%TYPE,
                                     K_ADMPV_MENSAJE IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_MENSAJE%TYPE,
                                     K_ADMPV_USU_REG IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_USU_REG%TYPE,
                                     K_ADMPV_USU_MOD IN PCLUB.ADMPT_AFILIACIONTC.ADMPV_USU_MOD%TYPE,
                                     K_ADMPV_COD_CLI IN VARCHAR2,
                                     K_ADMPV_TPO_CLI IN VARCHAR2,
                                     K_COID          IN VARCHAR2,
                                     K_ESTADOLINEA   IN VARCHAR2,
                                     K_CICLOFACT     IN VARCHAR2,
                                     K_EXITOTRANS    OUT NUMBER,
                                     K_CODERROR      OUT NUMBER,
                                     K_DESCERROR     OUT VARCHAR2)

 IS
  K_VAL_EXISTE_CLIENTE_IB NUMBER;
  K_VAL_EXISTE_CLIENTE_CC NUMBER;
  K_VAL_EXISTE_AFILIACION NUMBER;
  K_VAL_ENTREGA_BONO      NUMBER;
  V_EXIST                 NUMBER;
  V_EXITOAFILIA           NUMBER;
  V_SALDO_CC              NUMBER;
  V_SALDO_IB              NUMBER;
  K_ADMPC_ESTADO_BONO     PCLUB.ADMPT_AFILIACIONTC.ADMPC_ESTADO_BONO%TYPE;
  K_ADMPN_COD_CLI_IB      PCLUB.ADMPT_AFILIACIONTC.ADMPN_COD_CLI_IB%TYPE;
  K_ADMPV_TPOLINEA        PCLUB.ADMPT_AFILIACIONTC.ADMPV_TPOLINEA%TYPE;
  K_ADMPV_NUM_LINEA_BONO  VARCHAR2(100);
  K_BONO_ACT              VARCHAR2(20);

  ERROR_REGISTRAR EXCEPTION;
  ERROR_TRIOS EXCEPTION;
  VL_MENSAJE            VARCHAR2(200);
  K_CODERROR_REG        NUMBER;
  K_DESCERROR_REG       VARCHAR2(200);
  K_ADMPN_ID_AFILIACION PCLUB.ADMPT_AFILIACIONTC.ADMPN_ID_AFILIACION%TYPE;

  K_VALOR           VARCHAR2(200);
  K_CODERROR_TRIOS  VARCHAR2(200);
  K_DESCERROR_TRIOS VARCHAR2(200);
  V_ID_SALDO        VARCHAR2(200);
  v_Conteo          number;

BEGIN
  v_Conteo               :=0;
  K_EXITOTRANS           := 1;
  K_CODERROR             := NULL;
  K_DESCERROR            := '';
  V_EXIST                := 0;
  K_ADMPV_NUM_LINEA_BONO := '';

/*  K_VAL_EXISTE_CLIENTE_IB := VAL_CLIENTE_IBK(K_ADMPV_TIPO_DOC,
                                             K_ADMPV_NUM_DOC,
                                             K_ADMPN_COD_CLI_IB);*/
K_VAL_EXISTE_CLIENTE_IB := 1;

  IF K_VAL_EXISTE_CLIENTE_IB = 1 THEN
    --1 Existe el cliente IBK
    /*K_VAL_EXISTE_CLIENTE_CC := VAL_EXISTE_CLARO_CLUB(K_ADMPV_NUM_DOC,
                                                     K_ADMPV_TIPO_DOC,
                                                     K_ADMPV_COD_CLI);
    IF (K_VAL_EXISTE_CLIENTE_CC = 1) THEN*/
      K_VAL_EXISTE_AFILIACION := VAL_EXISTE_AFILIACION(K_ADMPN_COD_CLI_IB,
                                                       K_ADMPV_COD_CLI,
                                                       K_ADMPV_NUM_LINEA,
                                                       K_ADMPV_TPO_CLI);

   /*   IF K_ADMPV_TPO_CLI = 1 OR K_ADMPV_TPO_CLI = 2 THEN
        K_ADMPV_TPOLINEA := 'POSTPAGO';
      ELSIF K_ADMPV_TPO_CLI = '3' THEN
        K_ADMPV_TPOLINEA := 'PREPAGO';
      END IF;*/

      K_ADMPV_TPOLINEA := 'PREPAGO';

      IF (K_VAL_EXISTE_AFILIACION = 1) THEN
        --Validacion de bono
        K_VAL_ENTREGA_BONO := VAL_EXISTE_BONO(K_ADMPN_COD_CLI_IB);
        IF (K_VAL_ENTREGA_BONO = 1) THEN
          --Ya se entrego el bono
          K_ADMPC_ESTADO_BONO := 'N';
        ELSE
          --Se debe entregar el bono
          --K_ADMPC_ESTADO_BONO := 'P';

          --valido que estado colocar en Estado de Bono
          SELECT ADMPN_BONO_ACT
            INTO K_BONO_ACT
            FROM ADMPT_CLIENTEIB CI
           WHERE CI.ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB;

          IF K_BONO_ACT <> '2' THEN
            /*K_ADMPC_ESTADO_BONO := 'P';*/

            /*Valido que la linea que se va a afiliar tenga trios*/

            IF K_ADMPV_TPO_CLI = 1 OR K_ADMPV_TPO_CLI = 2 THEN
              ADMPSI_VALIDATRIOS(K_COID,
                                 K_VALOR,
                                 K_CODERROR_TRIOS,
                                 K_DESCERROR_TRIOS);

              IF K_CODERROR_TRIOS <> '1' THEN
                IF K_VALOR = '1' AND K_ESTADOLINEA = 'Activo' AND
                   K_CICLOFACT = 'A' THEN
                  K_ADMPC_ESTADO_BONO    := 'P';
                  K_ADMPV_NUM_LINEA_BONO := K_ADMPV_NUM_LINEA;
                ELSE
                  K_ADMPC_ESTADO_BONO := 'N';
                END IF;
              ELSE
                RAISE ERROR_TRIOS;
              END IF;
            ELSIF K_ADMPV_TPO_CLI = '3' THEN
              K_ADMPC_ESTADO_BONO    := 'P';
              K_ADMPV_NUM_LINEA_BONO := K_ADMPV_NUM_LINEA;
            END IF;

          ELSE
            K_ADMPC_ESTADO_BONO := 'N';
          END IF;
        END IF;

        BEGIN

          ADMPSS_REGAFILIACION(K_ADMPV_TIPO_DOC,
                               K_ADMPV_NUM_DOC,
                               K_ADMPV_NUM_LINEA,
                               K_ADMPC_ESTADO_BONO,
                               NULL,
                               SYSDATE,
                               K_ADMPV_TPOLINEA,
                               K_ADMPN_COD_CLI_IB,
                               K_ADMPN_SN_CODE,
                               K_ADMPN_SP_CODE,
                               K_ADMPV_MENSAJE,
                               K_ADMPV_USU_REG,
                               K_ADMPV_NUM_LINEA_BONO,
                               V_EXITOAFILIA,
                               K_CODERROR_REG,
                               K_DESCERROR_REG);
          IF V_EXITOAFILIA > 0 THEN
            RAISE ERROR_REGISTRAR;
          END IF;

          --Actualizar tabla cliente IBK
          -----------------------------------------
          IF K_ADMPV_TPO_CLI = 1 OR K_ADMPV_TPO_CLI = 2 THEN
            UPDATE ADMPT_CLIENTEIB
               SET ADMPV_COD_CLI   = K_ADMPV_COD_CLI,
                   ADMPV_NUM_LINEA = K_ADMPV_NUM_LINEA
             WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB;
          ELSIF K_ADMPV_TPO_CLI = 3 THEN
            UPDATE ADMPT_CLIENTEIB
               SET ADMPV_COD_CLI   = K_ADMPV_NUM_LINEA,
                   ADMPV_NUM_LINEA = K_ADMPV_NUM_LINEA
             WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB;
          END IF;
          --Actualiza Tabla saldo cliente
          -----------------------------------------
          --primero busco si la linea a afiliar existe en la tabla saldo

          SELECT NVL(COUNT(*), 0)
            INTO V_EXIST
            FROM admpt_saldos_cliente A
           WHERE A.ADMPV_COD_CLI = K_ADMPV_COD_CLI;

          IF V_EXIST > 0 THEN
            --Obtengo su saldo
            BEGIN
              SELECT NVL(MAX(ADMPN_SALDO_CC), 0)
                INTO V_SALDO_CC
                FROM ADMPT_SALDOS_CLIENTE
               WHERE ADMPV_COD_CLI = K_ADMPV_COD_CLI;
            EXCEPTION
              WHEN TOO_MANY_ROWS THEN
                K_DESCERROR := 'Registros duplicados para el Cliente ' ||
                               K_ADMPV_COD_CLI;
              WHEN OTHERS THEN
                K_DESCERROR := 'Error al consultar tabla ADMPT_SALDOS_CLIENTE con ADMPV_COD_CLI ' ||
                               K_ADMPV_COD_CLI;
            END;

            BEGIN
              --obtengo el saldo de ClienteIB
              SELECT NVL(admpn_saldo_ib, 0)
                INTO V_SALDO_IB
                FROM ADMPT_SALDOS_CLIENTE
               WHERE admpn_cod_cli_ib = K_ADMPN_COD_CLI_IB;
            EXCEPTION
              WHEN TOO_MANY_ROWS THEN
                K_DESCERROR := 'Registros duplicados para el Cliente ' ||
                               K_ADMPN_COD_CLI_IB;
              WHEN OTHERS THEN
                K_DESCERROR := 'Error al consultar tabla ADMPT_SALDOS_CLIENTE con ADMPV_COD_CLI_IB ' ||
                               K_ADMPN_COD_CLI_IB;
            END;

            --ELIMINO el cliente IB
            UPDATE ADMPT_SALDOS_CLIENTE
               SET ADMPN_COD_CLI_IB = '',
                   ADMPC_ESTPTO_IB  = '',
                   admpn_saldo_ib   = ''
             WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB;

            --asocio al cliente IB y a la nueva linea

            UPDATE ADMPT_SALDOS_CLIENTE
               SET ADMPN_SALDO_IB   = V_SALDO_IB,
                   ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB,
                   ADMPC_ESTPTO_CC  = 'A',
                   ADMPC_ESTPTO_IB  = 'A'
             WHERE ADMPV_COD_CLI = K_ADMPV_COD_CLI;

          ELSE
            UPDATE ADMPT_SALDOS_CLIENTE
               SET ADMPN_SALDO_CC  = 0,
                   ADMPV_COD_CLI   = K_ADMPV_COD_CLI,
                   ADMPC_ESTPTO_CC = 'A',
                   ADMPC_ESTPTO_IB = 'A'
             WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB;

          END IF;

          -----------------------------------------
          --Actualiza Tabla Kardex
          -----------------------------------------
          UPDATE ADMPT_KARDEX
             SET ADMPV_COD_CLI = K_ADMPV_COD_CLI
           WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB
             AND ADMPC_TPO_PUNTO = 'I';

          UPDATE ADMPT_KARDEX
             SET ADMPN_COD_CLI_IB = NULL
           WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB
             AND ADMPC_TPO_PUNTO <> 'I';

        EXCEPTION
          WHEN ERROR_REGISTRAR THEN
            K_DESCERROR  := SUBSTR(SQLERRM, 1, 400);
            K_EXITOTRANS := 0;
          WHEN ERROR_TRIOS THEN
            K_DESCERROR  := SUBSTR(SQLERRM, 1, 400);
            K_EXITOTRANS := 0;
          WHEN OTHERS THEN
            K_DESCERROR  := SUBSTR(SQLERRM, 1, 400);
            K_EXITOTRANS := 0;
        END;

      ELSIF (K_VAL_EXISTE_AFILIACION = 2) THEN

        --ES UNA NUEVA AFILIACION
        --valido que estado colocar en Estado de Bono
        K_VAL_ENTREGA_BONO := VAL_EXISTE_BONO(K_ADMPN_COD_CLI_IB);
        IF (K_VAL_ENTREGA_BONO = 1) THEN
          --Ya se entrego el bono
          K_ADMPC_ESTADO_BONO := 'N';
        ELSE
          --Se debe entregar el bono
          --K_ADMPC_ESTADO_BONO := 'P';
          --valido que estado colocar en Estado de Bono
          SELECT ADMPN_BONO_ACT
            INTO K_BONO_ACT
            FROM ADMPT_CLIENTEIB CI
           WHERE CI.ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB;

          IF K_BONO_ACT <> '2' THEN
            /*K_ADMPC_ESTADO_BONO := 'P';*/

            /*Valido que la linea que se va a afiliar tenga trios*/

            IF K_ADMPV_TPO_CLI = 1 OR K_ADMPV_TPO_CLI = 2 THEN
              ADMPSI_VALIDATRIOS(K_COID,
                                 K_VALOR,
                                 K_CODERROR_TRIOS,
                                 K_DESCERROR_TRIOS);

              IF K_CODERROR_TRIOS <> '1' THEN
                IF K_VALOR = '1' AND K_ESTADOLINEA = 'Activo' AND
                   K_CICLOFACT = 'A' THEN
                  K_ADMPC_ESTADO_BONO    := 'P';
                  K_ADMPV_NUM_LINEA_BONO := K_ADMPV_NUM_LINEA;
                ELSE
                  K_ADMPC_ESTADO_BONO := 'N';
                END IF;
              ELSE
                RAISE ERROR_TRIOS;
              END IF;
            ELSIF K_ADMPV_TPO_CLI = '3' THEN
              K_ADMPC_ESTADO_BONO    := 'P';
              K_ADMPV_NUM_LINEA_BONO := K_ADMPV_NUM_LINEA;
            END IF;

          ELSE
            K_ADMPC_ESTADO_BONO := 'N';
          END IF;
        END IF;
        BEGIN
          ADMPSS_REGAFILIACION(K_ADMPV_TIPO_DOC,
                               K_ADMPV_NUM_DOC,
                               K_ADMPV_NUM_LINEA,
                               K_ADMPC_ESTADO_BONO,
                               NULL,
                               SYSDATE,
                               K_ADMPV_TPOLINEA,
                               K_ADMPN_COD_CLI_IB,
                               K_ADMPN_SN_CODE,
                               K_ADMPN_SP_CODE,
                               K_ADMPV_MENSAJE,
                               K_ADMPV_USU_REG,
                               K_ADMPV_NUM_LINEA_BONO,
                               V_EXITOAFILIA,
                               K_CODERROR_REG,
                               K_DESCERROR_REG);

          IF V_EXITOAFILIA > 0 THEN
            RAISE ERROR_REGISTRAR;
          END IF;

          --Actualizar tabla cliente IBK
          -----------------------------------------
          IF K_ADMPV_TPO_CLI = 1 OR K_ADMPV_TPO_CLI = 2 THEN
            UPDATE ADMPT_CLIENTEIB
               SET ADMPV_COD_CLI   = K_ADMPV_COD_CLI,
                   ADMPV_NUM_LINEA = K_ADMPV_NUM_LINEA
             WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB;
          ELSIF K_ADMPV_TPO_CLI = 3 THEN
            UPDATE ADMPT_CLIENTEIB
               SET ADMPV_COD_CLI   = K_ADMPV_NUM_LINEA,
                   ADMPV_NUM_LINEA = K_ADMPV_NUM_LINEA
             WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB;
          END IF;
          --Actualiza Tabla saldo cliente
          -----------------------------------------
          SELECT NVL(COUNT(*), 0)
            INTO V_EXIST
            FROM admpt_saldos_cliente A
           WHERE A.ADMPV_COD_CLI = K_ADMPV_COD_CLI;

          IF V_EXIST > 0 THEN
            BEGIN
              --Obtengo su saldo
              SELECT NVL(MAX(ADMPN_SALDO_CC), 0)
                INTO V_SALDO_CC
                FROM ADMPT_SALDOS_CLIENTE
               WHERE ADMPV_COD_CLI = K_ADMPV_COD_CLI;
            EXCEPTION
              WHEN TOO_MANY_ROWS THEN
                K_DESCERROR := 'Registros duplicados para el Cliente ' ||
                               K_ADMPV_COD_CLI;
              WHEN OTHERS THEN
                K_DESCERROR := 'Error al consultar tabla ADMPT_SALDOS_CLIENTE con ADMPV_COD_CLI ' ||
                               K_ADMPV_COD_CLI;
            END;
            --ACTUALIZO
           SELECT MIN(admpn_id_saldo)
                INTO V_ID_SALDO
                FROM ADMPT_SALDOS_CLIENTE
                WHERE ADMPV_COD_CLI = K_ADMPV_COD_CLI 
                --and (ADMPN_COD_CLI_IB != K_ADMPN_COD_CLI_IB OR ADMPN_COD_CLI_IB IS NULL);
                and ((ADMPN_COD_CLI_IB != K_ADMPN_COD_CLI_IB OR ADMPN_COD_CLI_IB IS NULL) OR ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB);

            UPDATE ADMPT_SALDOS_CLIENTE
               SET ADMPN_SALDO_CC  = V_SALDO_CC,
                   ADMPV_COD_CLI   = K_ADMPV_COD_CLI,
                   ADMPC_ESTPTO_CC = 'A',
                   ADMPC_ESTPTO_IB = 'A'
             WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB;
            --ELIMINO REGISTRO
            DELETE FROM ADMPT_SALDOS_CLIENTE
            WHERE admpn_id_saldo=V_ID_SALDO and ADMPN_COD_CLI_IB != K_ADMPN_COD_CLI_IB;

          ELSE
            UPDATE ADMPT_SALDOS_CLIENTE
               SET ADMPN_SALDO_CC  = 0,
                   ADMPV_COD_CLI   = K_ADMPV_COD_CLI,
                   ADMPC_ESTPTO_CC = 'A',
                   ADMPC_ESTPTO_IB = 'A'
             WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB;
          END IF;
          --Actualiza Tabla Kardex
          -----------------------------------------
          UPDATE ADMPT_KARDEX
             SET ADMPV_COD_CLI = K_ADMPV_COD_CLI
           WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB
             AND ADMPC_TPO_PUNTO = 'I';

          UPDATE ADMPT_KARDEX
             SET ADMPN_COD_CLI_IB = NULL
           WHERE ADMPN_COD_CLI_IB = K_ADMPN_COD_CLI_IB
             AND ADMPC_TPO_PUNTO <> 'I';

        EXCEPTION
          WHEN ERROR_TRIOS THEN
            K_DESCERROR  := SUBSTR(SQLERRM, 1, 400);
            K_EXITOTRANS := 0;
          WHEN ERROR_REGISTRAR THEN
            K_DESCERROR  := SUBSTR(SQLERRM, 1, 400);
            K_EXITOTRANS := 0;
          WHEN OTHERS THEN
            K_DESCERROR  := SUBSTR(SQLERRM, 1, 400);
            K_EXITOTRANS := 0;
        END;

      ELSIF (K_VAL_EXISTE_AFILIACION = 0) THEN
        --Ya se encuentra afiliado
        K_DESCERROR  := 'La linea ingresada ya se encuentra afiliada';
        K_EXITOTRANS := 0;
      END IF;

    ELSE
--      dbms_output.put_line(K_ADMPV_NUM_DOC);
      select count(ADMPV_NUM_DOC) into v_Conteo from pclub.admpt_cliente where ADMPV_NUM_DOC=K_ADMPV_NUM_DOC and admpv_cod_cli=K_ADMPV_COD_CLI;
      IF v_Conteo > 0 THEN 
        begin
          K_DESCERROR  := 'La linea que desea afiliar no existe en Claro Club';
        end;
      ELSE --significa que el DNI que se intenta afiliar no pertenece al cliente 
        begin
         K_DESCERROR  := 'El DNI:'||K_ADMPV_NUM_DOC||', no pertenece a la línea:'||K_ADMPV_NUM_LINEA;              
        end;
      END IF;
      K_EXITOTRANS := 0;
    END IF;  

  IF K_EXITOTRANS = 0 THEN
    ROLLBACK;
  ELSE
    COMMIT;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    K_DESCERROR  := SUBSTR(SQLERRM, 1, 400);
    K_EXITOTRANS := 0;
    ROLLBACK;
END PROCESAR_AFILIACION_PREPAGO;

PROCEDURE ADMPSI_ALTACLIC_PREPAGO(K_FECHA IN DATE,K_CODERROR  OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER,K_NUMREGERR OUT NUMBER) is
  --****************************************************************
  -- Nombre SP           :  ADMPSI_ALTACLIC
  -- Propósito           :  Importar los puntos por Alta de Clientes
  --
  -- Input               :  K_FECHAPROCESO
  --
  -- Output              :  K_CODERROR Codigo de Error o Exito
  --                        K_DESCERROR Descripcion del Error (si se presento)
  --
  -- Fec Creación        :  18/10/2010
  -- Fec Actualización   :
  --****************************************************************
  V_REGCLI     NUMBER;
  C_NOMARCHIVO VARCHAR2(150);
  C_TIPODOC    VARCHAR2(20);
  C_NUMDOC     VARCHAR2(20);
  C_NOMCLI     VARCHAR2(60);
  C_APECLI     VARCHAR2(60);
  C_SEXO       VARCHAR(1);
  C_ESTCIV     VARCHAR2(20);
  C_CODCLI     VARCHAR2(40);
  C_EMAIL      VARCHAR2(80);
  C_PROV       VARCHAR(30);
  C_DEPA       VARCHAR2(40);
  C_DIST       VARCHAR2(200);
  C_FECACT     DATE;
  C_CICFAC     VARCHAR2(2);
  C_CLIENIB    NUMBER;
  C_EXICLIIB   NUMBER;
  COD_SALDO    VARCHAR2(40);
  V_IDSALDO    NUMBER;
/*  C_FECOPER    DATE;*/



  CURSOR ALTACLIENTES IS
    SELECT a.ADMPV_TIPO_DOC,
           a.ADMPV_NUM_DOC,
           a.ADMPV_NOM_CLI,
           a.ADMPV_APE_CLI,
           a.ADMPC_SEXO,
           a.ADMPV_EST_CIVIL,
           a.ADMPV_COD_CLI,
           a.ADMPV_EMAIL,
           a.ADMPV_PROV,
           a.ADMPV_DEPA,
           a.ADMPV_DIST,
           a.ADMPD_FEC_ACT,
           a.ADMPV_CICL_FACT,
     /*      A.ADMPD_FEC_OPER,*/
           a.ADMPV_NOM_ARCH
      FROM PCLUB.ADMPT_TMP_ALTACLI_CC a
     WHERE a.ADMPD_FEC_OPER = K_FECHA
       AND (a.ADMPV_COD_ERROR IS NULL OR a.ADMPV_COD_ERROR = '');

BEGIN

  -- Solo podemos validar si enviaron datos en codigo de cliente
  UPDATE PCLUB.ADMPT_TMP_ALTACLI_CC
     SET ADMPV_COD_ERROR  = '12',
         ADMPV_MSJE_ERROR = 'El codigo de cliente es obligatorio.'
   WHERE ADMPV_COD_CLI = ''
      OR ADMPV_COD_CLI IS NULL;

  -- Solo podemos validar si el cliente existe
 /* UPDATE PCLUB.ADMPT_TMP_ALTACLI_CC
     SET ADMPV_COD_ERROR  = '33',
         ADMPV_MSJE_ERROR = 'El codigo de cliente ya existe.'
   WHERE ADMPV_COD_CLI IN (SELECT c.ADMPV_COD_CLI FROM PCLUB.ADMPT_CLIENTE c);*/


   UPDATE PCLUB.ADMPT_TMP_ALTACLI_CC TC
     SET TC.ADMPV_COD_ERROR  = '33',
         TC.ADMPV_MSJE_ERROR = 'El codigo de cliente ya existe.'
   WHERE EXISTS (SELECT 1 FROM PCLUB.ADMPT_CLIENTE c WHERE c.ADMPV_COD_CLI=TC.ADMPV_COD_CLI);

  COMMIT;

  OPEN ALTACLIENTES;
  FETCH ALTACLIENTES
    INTO C_TIPODOC, C_NUMDOC, C_NOMCLI, C_APECLI, C_SEXO, C_ESTCIV, C_CODCLI, C_EMAIL, C_PROV, C_DEPA, C_DIST, C_FECACT, C_CICFAC, C_NOMARCHIVO;

  WHILE ALTACLIENTES %FOUND LOOP

    V_REGCLI := 0;

    SELECT COUNT(1)
      INTO V_REGCLI
      FROM PCLUB.ADMPT_AUX_ALTACLI_CC
     WHERE ADMPV_TIPO_DOC = C_TIPODOC
       AND ADMPV_NUM_DOC = C_NUMDOC
       AND ADMPV_NOM_CLI = C_NOMCLI
       AND ADMPV_APE_CLI = C_APECLI
       AND ADMPV_COD_CLI = C_CODCLI
       AND ADMPD_FEC_ACT = C_FECACT
       AND ADMPD_FEC_OPER = K_FECHA
       AND NVL(ADMPV_NOM_ARCH, NULL) = C_NOMARCHIVO;

    IF (V_REGCLI = 0) THEN
      BEGIN
        -- Debemos verificar si el cliente existe en cliente IB y no tiene Cuenta Claro asociada
        C_EXICLIIB := 1;
        C_CLIENIB := null;

        -- Si existe y no tiene cuenta claro asociada

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
           H.ADMPV_COD_TPOCL)
        VALUES
          (C_CODCLI,
           null,
           null,
           C_TIPODOC,
           C_NUMDOC,
           C_NOMCLI,
           C_APECLI,
           C_SEXO,
           C_ESTCIV,
           C_EMAIL,
           C_PROV,
           C_DEPA,
           C_DIST,
           C_FECACT,
           C_CICFAC,
           'A',
           '3');

        BEGIN
          SELECT g.admpv_cod_cli INTO COD_SALDO
            FROM PCLUB.ADMPT_SALDOS_CLIENTE g
           WHERE admpv_cod_cli = C_CODCLI;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN

             /**Generar secuencial de Saldo*/
            SELECT PCLUB.admpt_sld_cl_sq.nextval INTO V_IDSALDO FROM DUAL;

            INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE
              (admpn_id_saldo,
               admpv_cod_cli,
               admpn_cod_cli_ib,
               admpn_saldo_cc,
               admpn_saldo_ib,
               admpc_estpto_cc,
               admpc_estpto_ib)
            VALUES
              (V_IDSALDO, C_CODCLI, C_CLIENIB, 0.00, 0.00, 'A', NULL);

        END;

         -- Insertamos en la auxiliar para los reprocesos
          INSERT INTO PCLUB.ADMPT_AUX_ALTACLI_CC t( t.admpv_tipo_doc, t.admpv_num_doc, t.admpv_nom_cli, t.admpv_ape_cli,
          t.admpv_cod_cli, t.admpd_fec_act, t.admpd_fec_oper, t.admpv_nom_arch)
          VALUES
          (C_TIPODOC,C_NUMDOC,C_NOMCLI,C_APECLI,C_CODCLI,C_FECACT,K_FECHA,C_NOMARCHIVO);

        -- Se asume que es Post debido a que si es Control se utiliza la misma bolsa y para el canje se manda el tipo de cliente segun el telefono
        ----7.  Verificar si el código del cliente existe en la tabla ADMPT_SALDOS_CLIENTE, si existe continuar con el siguiente punto.
        --------Si no existe insertar un registro en esta tabla-----
        --COMMIT;

     END;
    END IF;

    FETCH ALTACLIENTES
      INTO C_TIPODOC, C_NUMDOC, C_NOMCLI, C_APECLI, C_SEXO, C_ESTCIV, C_CODCLI, C_EMAIL, C_PROV, C_DEPA, C_DIST, C_FECACT, C_CICFAC, C_NOMARCHIVO;

  END LOOP;

  -- Obtenemos los registros totales, procesados y con error
  SELECT COUNT(1) INTO K_NUMREGTOT FROM PCLUB.ADMPT_TMP_ALTACLI_CC WHERE ADMPD_FEC_OPER = K_FECHA;
  SELECT COUNT(1) INTO K_NUMREGERR FROM PCLUB.ADMPT_TMP_ALTACLI_CC WHERE ADMPD_FEC_OPER = K_FECHA AND (ADMPV_COD_ERROR Is Not null);
  SELECT COUNT(1) INTO K_NUMREGPRO FROM PCLUB.ADMPT_AUX_ALTACLI_CC WHERE (ADMPD_FEC_OPER = K_FECHA);

  -- Insertamos de la tabla temporal a la final
  INSERT INTO PCLUB.ADMPT_IMP_ALTACLI_CC
    SELECT PCLUB.ADMPT_ALTACLI_SQ.nextval,
           ADMPV_TIPO_DOC,
           ADMPV_NUM_DOC,
           ADMPV_NOM_CLI,
           ADMPV_APE_CLI,
           ADMPC_SEXO,
           ADMPV_EST_CIVIL,
           ADMPV_COD_CLI,
           ADMPV_EMAIL,
           ADMPV_PROV,
           ADMPV_DEPA,
           ADMPV_DIST,
           ADMPD_FEC_ACT,
           ADMPV_CICL_FACT,
           ADMPD_FEC_OPER,
           ADMPV_NOM_ARCH,
           ADMPV_COD_ERROR,
           ADMPV_MSJE_ERROR,
           SYSDATE,
           ADMPN_SEQ
      FROM PCLUB.ADMPT_TMP_ALTACLI_CC
     WHERE admpd_fec_oper = K_FECHA;

  -- Eliminamos los registros de la tabla temporal y auxiliar
  DELETE PCLUB.ADMPT_AUX_ALTACLI_CC WHERE ADMPD_FEC_OPER = K_FECHA;
  DELETE PCLUB.ADMPT_TMP_ALTACLI_CC WHERE ADMPD_FEC_OPER = K_FECHA;

  COMMIT;

  K_CODERROR  := 0;
  K_DESCERROR := '';

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR  := SQLCODE;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

END ADMPSI_ALTACLIC_PREPAGO;

end PKG_CC_AFILIACIONES;
/
