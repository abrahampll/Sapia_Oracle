CREATE OR REPLACE PACKAGE BODY USRSRVCC.PKG_CC_SERV AS

--****************************************************************
-- Nombre SP           :  ADMPSI_REGMOVIMIENTO
-- Propósito           :  Permite Registrar el movimiento
-- Input               :  K_ID_PREMIO
--                        K_LINEA
--                        K_TIPDOC
--                        K_NUMDOC
--                        K_ID_CLIENTE
--                        K_USUARIO
-- Output              :  K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  05/02/2013
-- Fec Actualización   :  13/02/2013
--****************************************************************

PROCEDURE ADMPSI_REGMOVIMIENTO(K_ID_PREMIO IN VARCHAR2,
                               K_LINEA IN VARCHAR2,
                               K_TIPDOC IN VARCHAR2,
                               K_NUMDOC IN VARCHAR2,
                               K_ID_CLIENTE IN VARCHAR2,
                               K_USUARIO IN VARCHAR2,
                               K_CODERROR OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2) IS
V_ID_PREMIO VARCHAR2(15);
V_ID_CLIENTE VARCHAR2(10);
V_TIPODOC VARCHAR2(20);
K_ID_MOV NUMBER;
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_ID_PREMIO  IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el premio. '; RAISE EX_ERROR;
    WHEN K_LINEA      IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el número de línea. '; RAISE EX_ERROR;
    WHEN K_ID_CLIENTE IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el cliente. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  BEGIN
    SELECT PREMV_ID INTO V_ID_PREMIO
    FROM USRSRVCC.ADMPT_PREMIO
    WHERE PREMV_ID = K_ID_PREMIO;
  EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR := 2;
      K_DESCERROR := 'El premio no fue encontrado. ';
      RAISE EX_ERROR;
  END;

  BEGIN
    SELECT CLIEV_ID INTO V_ID_CLIENTE
    FROM USRSRVCC.ADMPT_CLIENTE
    WHERE CLIEV_ID = K_ID_CLIENTE;
  EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR := 2;
      K_DESCERROR := 'El cliente no fue encontrado. ';
      RAISE EX_ERROR;
  END;

  IF K_TIPDOC IS NOT NULL THEN
    BEGIN
      SELECT TDOCV_ID INTO V_TIPODOC
      FROM USRSRVCC.ADMPT_TIPO_DOC
      WHERE TDOCV_ID = K_TIPDOC;
    EXCEPTION
      WHEN OTHERS THEN
        K_CODERROR := 2;
        K_DESCERROR := 'El tipo de documento no fue encontrado.';
        RAISE EX_ERROR;
    END;
  END IF;

  SELECT NVL(USRSRVCC.ADMPT_MOV_SERV_SQ.NEXTVAL,0) INTO K_ID_MOV FROM DUAL;

  IF K_ID_MOV = 0 THEN
     K_CODERROR := 4;
     K_DESCERROR := 'No se generó un correlativo para el movimiento. ';
     RAISE EX_ERROR;
  END IF;

  INSERT INTO USRSRVCC.ADMPT_MOV_SERV(MOVSN_ID,PREMV_ID,MOVSD_FEC_TRANS,MOVSV_LINEA,TDOCV_ID,MOVSV_NUMDOC,CLIEV_ID,MOVSV_USU_REG,MOVSD_FEC_REG)
  VALUES(K_ID_MOV,K_ID_PREMIO,SYSDATE,K_LINEA,K_TIPDOC,K_NUMDOC,K_ID_CLIENTE,K_USUARIO,SYSDATE);

  COMMIT;

EXCEPTION
  WHEN EX_ERROR THEN
    BEGIN
      SELECT ERROV_DESC || K_DESCERROR INTO K_DESCERROR
      FROM USRSRVCC.ADMPT_ERRORES
      WHERE ERRON_ID = K_CODERROR;
    EXCEPTION WHEN OTHERS THEN
      K_DESCERROR := '';
    END;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    SELECT ERROV_DESC || K_DESCERROR INTO K_DESCERROR
    FROM USRSRVCC.ADMPT_ERRORES
    WHERE ERRON_ID = K_CODERROR;
END ADMPSI_REGMOVIMIENTO;

--****************************************************************
-- Nombre SP           :  ADMPSS_CONPREMIO
-- Propósito           :  Permite consultar el premio
-- Input               :  K_ID_PREMIO
--                        K_ID_TIPOPREMIO
--                        K_DESC
--                        K_ESTADO
-- Output              :  CURSORPREMIO
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  05/02/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE ADMPSS_CONPREMIO(K_ID_PREMIO IN VARCHAR2,
                           K_ID_TIPOPREMIO VARCHAR2,
                           K_DESC VARCHAR2,
                           K_ESTADO VARCHAR2,
                           K_CURSORPREMIO OUT SYS_REFCURSOR,
                           K_CODERROR OUT NUMBER,
                           K_DESCERROR OUT VARCHAR2) IS
BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';

  OPEN K_CURSORPREMIO FOR
     SELECT PR.PREMV_ID AS PREMV_ID,
            PR.TPREV_ID AS TPREV_ID,
            PR.PREMV_DESC AS PREMV_DESC,
            PR.PREMC_ESTADO AS PREMC_ESTADO,
            TP.TPREV_DESC AS TPREV_DESC
     FROM USRSRVCC.ADMPT_PREMIO PR
     INNER JOIN USRSRVCC.ADMPT_TIPOPREMIO TP ON PR.TPREV_ID = TP.TPREV_ID
     WHERE PR.PREMV_ID = NVL(K_ID_PREMIO,PR.PREMV_ID)
           AND PR.TPREV_ID = NVL(K_ID_TIPOPREMIO,PR.TPREV_ID)
           AND PR.PREMV_DESC LIKE '%' || K_DESC || '%'
           AND PR.PREMC_ESTADO = NVL(K_ESTADO,'A')
     ORDER BY PR.PREMV_ID;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    SELECT ERROV_DESC || K_DESCERROR INTO K_DESCERROR
    FROM USRSRVCC.ADMPT_ERRORES
    WHERE ERRON_ID = K_CODERROR;
END ADMPSS_CONPREMIO;

END PKG_CC_SERV;
/
