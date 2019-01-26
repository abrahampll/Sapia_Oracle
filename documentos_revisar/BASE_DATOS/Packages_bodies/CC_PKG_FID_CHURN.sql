CREATE OR REPLACE PACKAGE BODY FIDELIDAD.CC_PKG_FID_CHURN IS

  --***********************************************************************
  -- Nombre SP           :  CC_LIST_CONFIG_SMS
  -- Propósito           :  Listar la Configuración para el envío del SMS
  -- Input               :  K_OPCION     -- Opción
  -- Output              :  K_MSG_SMS
  --                        K_CUR_SALIDA
  -- Creado por          :  E76142
  -- Fec Creación        :  07/11/2013
  --***********************************************************************
  PROCEDURE CC_LIST_CONFIG_SMS(K_OPCION     IN VARCHAR2,
                               K_MSG_SMS    OUT VARCHAR2,
                               K_CUR_SALIDA OUT CUR_SEC) IS
    V_MES NUMBER;
    V_MSG VARCHAR2(200);

  BEGIN
    --Obtengo el mensaje correspondiente al mes actual
    SELECT TO_CHAR(SYSDATE, 'MM') INTO V_MES FROM DUAL;

    SELECT NVL(E.CPREV_DESCRIPCION, '')
      INTO V_MSG
      FROM fidelidad.CPRET_MSG_ENVIOSMS E
     WHERE E.CPREN_ID = V_MES;

    K_MSG_SMS := V_MSG;

    --Obtengo los demàs valores de configuración para el envío de SMS
    OPEN K_CUR_SALIDA FOR
      SELECT S.CPREN_CODIGO || '|' || CPREV_DESCRIPCION || '|' ||
             CPREV_VALOR || '|' || CPREV_OPCION
        FROM fidelidad.CPRET_CONFIG_SMS S
       WHERE S.CPREV_OPCION = NVL(K_OPCION, S.CPREV_OPCION);

  END CC_LIST_CONFIG_SMS;

  --*******************************************************************************
  -- Nombre SP           :  CC_REP_LINEAS_PROGENV
  -- Propósito           :  Listar las líneas a las que se programó el envío de SMS
  -- Input               :  K_PERIODO     -- Periodo
  --                        K_FLAGOPERACION   --FlagOperación
  -- Output              :  K_NUMREGTOTPRO
  --                        K_NUMREGPRE
  --                        K_NUMREGTFI
  --                        K_MSG_SMS
  --                        K_TICKET
  --                        CURLINEAS
  --                        K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  E76142
  -- Fec Creación        :  07/11/2013
  --*******************************************************************************
  PROCEDURE CC_REP_LINEAS_PROGENV(K_PERIODO         IN VARCHAR2,
                                  K_NUMREGTOTPROM   OUT NUMBER,
                                  K_NUMREGTOTPROTFI OUT NUMBER,
                                  K_NUMREGPRE       OUT NUMBER,
                                  K_NUMREGTFI       OUT NUMBER,
                                  K_MSG_SMS         OUT VARCHAR2,
                                  K_TICKET          OUT VARCHAR2,
                                  CURLINEAS         OUT SYS_REFCURSOR,
                                  K_CODERROR        OUT NUMBER,
                                  K_DESCERROR       OUT VARCHAR2,
                                  K_FLAGOPERACION   IN NUMBER) IS
    VAL_PE NUMBER := 0;
    V_MES  NUMBER;
    V_MSG  VARCHAR2(200);
    EX_ERROR EXCEPTION;
  BEGIN

    CASE
      WHEN K_PERIODO IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese el periodo.';
        RAISE EX_ERROR;
      ELSE
        K_CODERROR        := 0;
        K_DESCERROR       := '';
        K_NUMREGTOTPROM   := 0;
        K_NUMREGTOTPROTFI := 0;
        K_NUMREGPRE       := 0;
        K_NUMREGTFI       := 0;
        --Obtengo el mensaje correspondiente al mes actual
        SELECT TO_CHAR(SYSDATE, 'MM') INTO V_MES FROM DUAL;

        SELECT NVL(E.CPREV_DESCRIPCION, '')
          INTO V_MSG
          FROM fidelidad.CPRET_MSG_ENVIOSMS E
         WHERE E.CPREN_ID = V_MES;
        K_MSG_SMS := V_MSG;

    END CASE;

    IF K_FLAGOPERACION = 1 THEN

      SELECT COUNT(DECODE(CPREV_TIPOTELEF, 'M', 1)) K_NUMREGTOTPROM, --Registros totales procesados en el periódo (enviados por DWH MOVIL)
             COUNT(DECODE(CPREV_TIPOTELEF, 'T', 1)) K_NUMREGTOTPROTFI, --Registros totales procesados en el periódo (enviados por DWH TFI)
             COUNT((DECODE(C.CPREV_ESTADO,
                           VAL_PE,
                           (DECODE(CPREV_TIPOTELEF, 'M', 1))))) K_NUMREGPRE, --Registros PREPAGO a los que se programó el envío de SMS (correctos-movil)
             COUNT((DECODE(C.CPREV_ESTADO,
                           VAL_PE,
                           (DECODE(CPREV_TIPOTELEF, 'T', 1))))) K_NUMREGTFI, --Registros TFI a los que se programó el envío de SMS (correctos - TFI)
             MAX(DECODE(C.CPREV_ESTADO, VAL_PE, CPREV_TICKET)) K_TICKET --Obtengo el número de ticket
        INTO K_NUMREGTOTPROM,
             K_NUMREGTOTPROTFI,
             K_NUMREGPRE,
             K_NUMREGTFI,
             K_TICKET
        FROM fidelidad.CPRET_MOVCHURN C
       WHERE C.CPREV_PERIODO = K_PERIODO;

      OPEN CURLINEAS FOR
        SELECT C.CPREV_TELEFONO
          FROM fidelidad.CPRET_MOVCHURN C
         WHERE C.CPREV_PERIODO = K_PERIODO;
    ELSE

      SELECT COUNT(DECODE(CPREV_TIPOTELEF, 'M', 1)) K_NUMREGTOTPROM, --Registros totales procesados en el periódo (enviados por DWH MOVIL)
             COUNT(DECODE(CPREV_TIPOTELEF, 'T', 1)) K_NUMREGTOTPROTFI --Registros totales procesados en el periódo (enviados por DWH TFI)
        INTO K_NUMREGTOTPROM, K_NUMREGTOTPROTFI
        FROM fidelidad.CPRET_MOVCHURN C
       WHERE C.CPREV_PERIODO = K_PERIODO;

      SELECT COUNT((DECODE(C.CPREV_ESTADO,
                           VAL_PE,
                           (DECODE(CPREV_TIPOTELEF, 'M', 1))))) K_NUMREGPRE, --Registros a los que se programó el envío de SMS (CORRECTOS MOVIL)
             COUNT((DECODE(C.CPREV_ESTADO,
                           VAL_PE,
                           (DECODE(CPREV_TIPOTELEF, 'T', 1))))) K_NUMREGTFI, --Registros a los que se programó el envío de SMS (CORRECTOS TFI)
             MAX(DECODE(C.CPREV_ESTADO, VAL_PE, CPREV_TICKET)) K_TICKET --Obtengo el número de ticket
        INTO K_NUMREGPRE, K_NUMREGTFI, K_TICKET
        FROM fidelidad.CPRET_TMP_REP_MOVCHURN C;

      OPEN CURLINEAS FOR
        SELECT C.CPREV_TELEFONO
          FROM fidelidad.CPRET_TMP_REP_MOVCHURN C;

    END IF;

  EXCEPTION
    WHEN EX_ERROR THEN
      K_DESCERROR := 'Error en parámetro(s) de entrada. ' || K_DESCERROR;
      OPEN CURLINEAS FOR
        SELECT '' CPREV_TELEFONO FROM DUAL WHERE 1 = 0;
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      OPEN CURLINEAS FOR
        SELECT '' CPREV_TELEFONO FROM DUAL WHERE 1 = 0;
  END CC_REP_LINEAS_PROGENV;

  --************************************************************************************
  -- Nombre SP           :  CC_LINEAS_NOPROGENV
  -- Propósito           :  Listar la cantidad de líneas a las que no se programó el envío de SMS
  -- Input               :  K_PERIODO     -- Periodo
  -- Output              :  K_NUMREG
  --                        K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  E76142
  -- Fec Creación        :  07/11/2013
  --************************************************************************************
  PROCEDURE CC_LINEAS_NOPROGENV(K_PERIODO   IN VARCHAR2,
                                K_NUMREG    OUT NUMBER,
                                K_CODERROR  OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2) IS
    VAL_NPE NUMBER := 1;
    EX_ERROR EXCEPTION;
  BEGIN

    CASE
      WHEN K_PERIODO IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese el Periodo.';
        RAISE EX_ERROR;
      ELSE
        K_CODERROR  := 0;
        K_DESCERROR := '';
        K_NUMREG    := 0;
    END CASE;

    SELECT COUNT(1)
      INTO K_NUMREG
      FROM fidelidad.CPRET_MOVCHURN C
     WHERE C.CPREV_PERIODO = K_PERIODO
       AND C.CPREV_ESTADO = VAL_NPE;

  EXCEPTION
    WHEN EX_ERROR THEN
      K_DESCERROR := 'Error en parámetro(s) de entrada. ' || K_DESCERROR;
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
  END CC_LINEAS_NOPROGENV;

  --************************************************************************************
  -- Nombre SP           :  CC_DETLINEAS_NOPROGENV
  -- Propósito           :  Listar las líneas a las que no se programó el envío de SMS
  -- Input               :  K_PERIODO     -- Periodo
  -- Output              :  K_CUR_LISTA
  --                        K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  E76142
  -- Fec Creación        :  07/11/2013
  --************************************************************************************

  PROCEDURE CC_DETLINEAS_NOPROGENV(K_PERIODO   IN VARCHAR2,
                                   K_CUR_LISTA OUT SYS_REFCURSOR,
                                   K_CODERROR  OUT NUMBER,
                                   K_DESCERROR OUT VARCHAR2) IS
    VAL_NPE NUMBER := 1;
    EX_ERROR EXCEPTION;
  BEGIN
    K_CODERROR  := 0;
    K_DESCERROR := '';

    OPEN K_CUR_LISTA FOR
      SELECT CPREV_TICKET, CPREV_TELEFONO, CPREV_TIPOTELEF
        FROM fidelidad.CPRET_MOVCHURN
       WHERE CPREV_PERIODO = K_PERIODO
         AND CPREV_ESTADO = VAL_NPE;

  EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR  := -1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      OPEN K_CUR_LISTA FOR
        SELECT '' CPREV_TICKET, '' CPREV_TELEFONO, '' CPREV_TIPOTELEF
          FROM DUAL
         WHERE 1 = 0;
  END CC_DETLINEAS_NOPROGENV;

  --************************************************************************************
  -- Nombre SP           :  CC_ACT_PROCESO
  -- Propósito           :  Actualizar los valores del Reproceso, en la tabla Principal.
  -- Input               :
  -- Output              :
  -- Creado por          :  E76142
  -- Fec Creación        :  07/11/2013
  --************************************************************************************
  PROCEDURE CC_ACT_PROCESO IS
    v_ticket      varchar2(200);
    v_telefono    varchar2(200);
    v_idinteract  number;
    v_tipotelef   varchar2(1);
    v_estado      varchar2(1);
    v_estadointer varchar2(1);
    v_fecharegpro date;
    v_flag        NUMBER;
    v_msje        varchar2(500);
    CURSOR C_LINEAS IS
      SELECT ctm.cprev_ticket,
             ctm.cprev_telefono,
             ctm.cpren_idinteract,
             ctm.cprev_tipotelef,
             ctm.cprev_estado,
             ctm.cprev_estado_inter,
             ctm.cprev_fech_prog_sms,
             ctm.cprev_msje
        FROM fidelidad.CPRET_TMP_REP_MOVCHURN ctm;
  BEGIN
    SELECT COUNT(1) INTO v_flag FROM fidelidad.CPRET_TMP_REP_MOVCHURN ctm;

    IF v_flag > 0 THEN
      BEGIN
        OPEN C_LINEAS;
        LOOP
          FETCH C_LINEAS
            INTO v_ticket,
                 v_telefono,
                 v_idinteract,
                 v_tipotelef,
                 v_estado,
                 v_estadointer,
                 v_fecharegpro,
                 v_msje;
          EXIT WHEN C_LINEAS%NOTFOUND;

          UPDATE fidelidad.CPRET_MOVCHURN ct
             SET ct.cpren_idinteract    = v_idinteract,
                 ct.cpred_fech_prog_sms = v_fecharegpro,
                 ct.cprev_estado        = v_estado,
                 ct.cprev_estado_inter  = v_estadointer,
                 ct.cprev_mensaje       = v_msje
           WHERE ct.cprev_telefono = v_telefono
             AND ct.cprev_ticket = v_ticket;
        END LOOP;
      END;
    END IF;
  END CC_ACT_PROCESO;

  --************************************************************************************
  -- Nombre SP           :  CC_LIST_TICKETS
  -- Propósito           :  Listar los tickets del Periodo
  -- Input               :  K_PERIODO     -- Periodo
  -- Output              :  K_CUR_TICKETS
  --                        K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  E76142
  -- Fec Creación        :  07/11/2013
  --************************************************************************************
  PROCEDURE CC_LIST_TICKETS(K_PERIODO     IN VARCHAR2,
                            K_CUR_TICKETS OUT SYS_REFCURSOR,
                            K_CODERROR    OUT NUMBER,
                            K_DESCERROR   OUT VARCHAR2) IS
    EX_ERROR EXCEPTION;
    V_EST_INTERACT VARCHAR2(1) := '0';
  BEGIN
    CASE
      WHEN K_PERIODO IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := ' No se ingresó el Periodo.';
      ELSE
        K_CODERROR  := 0;
        K_DESCERROR := '';
    END CASE;

    OPEN K_CUR_TICKETS FOR
      SELECT DISTINCT (M.CPREV_TICKET)
        FROM fidelidad.CPRET_MOVCHURN M
       WHERE M.CPREV_ESTADO_INTER = V_EST_INTERACT
         AND M.CPREN_IDINTERACT IS NOT NULL
         AND M.CPREV_PERIODO = K_PERIODO;

  EXCEPTION
    WHEN EX_ERROR THEN
      BEGIN
        OPEN K_CUR_TICKETS FOR
          SELECT '' CPREV_TICKET FROM DUAL WHERE 1 = 0;
      END;

    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

      OPEN K_CUR_TICKETS FOR
        SELECT '' CPREV_TICKET FROM DUAL WHERE 1 = 0;

  END CC_LIST_TICKETS;

  --************************************************************************************
  -- Nombre SP           :  CC_UPD_MOVCHURN
  -- Propósito           :  Actualizar la Fecha Real de Envío
  -- Input               :
  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  E76142
  -- Fec Creación        :  07/11/2013
  --************************************************************************************
  PROCEDURE CC_UPD_MOVCHURN(K_CODERROR  OUT NUMBER,
                            K_DESCERROR OUT VARCHAR2) IS

    V_CUR_LISTA    SYS_REFCURSOR;
    V_EST_INTERACT VARCHAR(1) := '0';

    C_TELEFONO     VARCHAR2(20);
    C_NRO_TICKET   VARCHAR2(30);
    C_FEC_REAL_ENV DATE;

    V_TOT_EXITO NUMBER;
    V_TOT_ERROR NUMBER;
    V_TOT_PROC  NUMBER;
  BEGIN
    V_TOT_EXITO := 0;
    V_TOT_PROC  := 0;
    V_TOT_ERROR := 0;

    K_CODERROR  := 0;
    K_DESCERROR := '';

    -- Obtenemos los datos de los teléfonos de la tabla temporal
    OPEN V_CUR_LISTA FOR
      SELECT T.CPREV_TICKET, T.CPREV_TELEFONO, T.CPRED_FECH_REAL_SMS
        FROM fidelidad.CPRET_TMP_MOVCHURN T;

    FETCH V_CUR_LISTA
      INTO C_NRO_TICKET, C_TELEFONO, C_FEC_REAL_ENV;

    -- iteramos con el cursor
    WHILE V_CUR_LISTA%FOUND LOOP
      V_TOT_PROC := V_TOT_PROC + 1;

      IF C_FEC_REAL_ENV IS NOT NULL THEN

        UPDATE fidelidad.CPRET_MOVCHURN M
           SET M.CPRED_FECH_REAL_SMS = C_FEC_REAL_ENV
         WHERE M.CPREV_TICKET = C_NRO_TICKET
           AND M.CPREV_TELEFONO = C_TELEFONO
           AND M.CPREV_ESTADO_INTER = V_EST_INTERACT;

        V_TOT_EXITO := V_TOT_EXITO + 1;
      ELSE
        V_TOT_ERROR := V_TOT_ERROR + 1;
      END IF;

      FETCH V_CUR_LISTA
        INTO C_NRO_TICKET, C_TELEFONO, C_FEC_REAL_ENV;
    END LOOP;
    -- cerramos el cursor
    CLOSE V_CUR_LISTA;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
  END CC_UPD_MOVCHURN;

  --************************************************************************************
  -- Nombre SP           :  CC_LIST_DATOS
  -- Propósito           :  Listar los movimientos Churn para el periodo vigente
  -- Input               :  K_PERIODO     -- Periodo
  -- Output              :  K_CUR_LISTA
  --                        K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  E76142
  -- Fec Creación        :  07/11/2013
  --************************************************************************************
  PROCEDURE CC_LIST_DATOS(K_PERIODO   IN VARCHAR2,
                          K_CUR_LISTA OUT SYS_REFCURSOR,
                          K_CODERROR  OUT NUMBER,
                          K_DESCERROR OUT VARCHAR2) IS

    V_EST_INTERACT VARCHAR2(1) := '0';
  BEGIN

    CASE
      WHEN K_PERIODO IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'No se ingresó el Periodo';
      ELSE
        K_CODERROR  := 0;
        K_DESCERROR := '';
    END CASE;

    OPEN K_CUR_LISTA FOR
      SELECT M.CPREV_TICKET,
             M.CPREV_TELEFONO,
             M.CPREN_IDINTERACT,
             M.CPRED_FECH_REAL_SMS
        FROM fidelidad.CPRET_MOVCHURN M
       WHERE M.CPREV_PERIODO = K_PERIODO
         AND M.CPREV_ESTADO_INTER = V_EST_INTERACT
         AND M.CPREN_IDINTERACT IS NOT NULL
         AND M.CPRED_FECH_REAL_SMS IS NOT NULL;

  EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

      OPEN K_CUR_LISTA FOR
        SELECT '' CPREV_TICKET,
               '' CPREV_TELEFONO,
               '' CPREN_IDINTERACT,
               '' CPRED_FECH_REAL_SMS
          FROM DUAL
         WHERE 1 = 0;
  END CC_LIST_DATOS;

 --*******************************************************************************
  -- Nombre SP           :  CC_REP_LINEAS_NOPROGENV
  -- Propósito           :  Listar las líneas a las que no se programó el envío de SMS
  -- Input               :  K_PERIODO     -- Periodo
  --                        K_FLAGOPERACION   --FlagOperación
  -- Output              :  K_NUMREGPRE
  --                        K_NUMREGTFI
  --                        CURLINEAS
  --                        K_CODERROR
  --                        K_DESCERROR
  -- Creado por          :  E76142
  -- Fec Creación        :  07/11/2013
  --*******************************************************************************
  PROCEDURE CC_REP_LINEAS_NOPROGENV(K_PERIODO       IN VARCHAR2,
                                  K_NUMREGPRE     OUT NUMBER,
                                  K_NUMREGTFI     OUT NUMBER,
                                  CURLINEAS       OUT SYS_REFCURSOR,
                                  K_CODERROR      OUT NUMBER,
                                  K_DESCERROR     OUT VARCHAR2,
                                  K_FLAGOPERACION IN NUMBER) IS
    VAL_PE NUMBER := 1;
    EX_ERROR EXCEPTION;
  BEGIN
  
    CASE
      WHEN K_PERIODO IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese el periódo.';
        RAISE EX_ERROR;
      ELSE
        K_CODERROR     := 0;
        K_DESCERROR    := '';
        K_NUMREGPRE    := 0;
        K_NUMREGTFI    := 0;
    END CASE;
  
    IF K_FLAGOPERACION = 1 THEN
       
      --Registros PREPAGO a los que no se programó el envío de SMS (movil)
      SELECT COUNT(1)
        INTO K_NUMREGPRE
        FROM fidelidad.CPRET_MOVCHURN C
       WHERE C.CPREV_PERIODO = K_PERIODO
         AND C.CPREV_ESTADO = VAL_PE
         AND C.CPREV_TIPOTELEF = 'M';
    
      --Registros TFI a los que no se programó el envío de SMS (TFI)
      SELECT COUNT(1)
        INTO K_NUMREGTFI
        FROM fidelidad.CPRET_MOVCHURN C
       WHERE C.CPREV_PERIODO = K_PERIODO
         AND C.CPREV_ESTADO = VAL_PE
         AND C.CPREV_TIPOTELEF = 'T';
            
      OPEN CURLINEAS FOR
        SELECT C.CPREV_TELEFONO
          FROM fidelidad.CPRET_MOVCHURN C
         WHERE C.CPREV_PERIODO = K_PERIODO
           AND C.CPREV_ESTADO = VAL_PE;
    ELSE
      
      --Registros a los que no se programó el envío de SMS (MOVIL)
      SELECT COUNT(1)
        INTO K_NUMREGPRE
        FROM fidelidad.CPRET_TMP_REP_MOVCHURN C
       WHERE C.CPREV_ESTADO = VAL_PE
         AND C.CPREV_TIPOTELEF = 'M';
    
      --Registros a los que no se programó el envío de SMS (TFI)
      SELECT COUNT(1)
        INTO K_NUMREGTFI
        FROM fidelidad.CPRET_TMP_REP_MOVCHURN C
       WHERE C.CPREV_ESTADO = VAL_PE
         AND C.CPREV_TIPOTELEF = 'T';
         
      OPEN CURLINEAS FOR
        SELECT C.CPREV_TELEFONO
          FROM fidelidad.CPRET_TMP_REP_MOVCHURN C
         WHERE C.CPREV_ESTADO = VAL_PE;
    
    END IF;
  
  EXCEPTION
    WHEN EX_ERROR THEN
      K_DESCERROR := 'Error en parámetro(s) de entrada. ' || K_DESCERROR;
      OPEN CURLINEAS FOR
        SELECT '' CPREV_TELEFONO FROM DUAL WHERE 1 = 0;
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      OPEN CURLINEAS FOR
        SELECT '' CPREV_TELEFONO FROM DUAL WHERE 1 = 0;
  END CC_REP_LINEAS_NOPROGENV;
END CC_PKG_FID_CHURN;
/