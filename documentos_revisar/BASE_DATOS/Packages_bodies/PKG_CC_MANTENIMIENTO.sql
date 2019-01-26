CREATE OR REPLACE PACKAGE BODY PCLUB.PKG_CC_MANTENIMIENTO is

PROCEDURE ADMPSI_OBTMENSAJE( K_PARAMETRO IN VARCHAR2,
                            K_VALOR OUT VARCHAR2,
                            K_RESPUESTA OUT NUMBER,
                            K_DESCERROR OUT VARCHAR2)
  IS
  --****************************************************************
  -- Nombre SP           :  AMPSI_OBTMENSAJE
  -- Propósito           :  Obtener Mensaje
  -- Input               :  NombreParametro
  -- Output              :  -    Valor
                            --Respuesta
                            --Mensaje Error
  -- Creado por          :  Deysi Galvez
  -- Fec Creación        :  10/11/2010
  -- Fec Actualización   :
  --****************************************************************

  V_CONT            NUMBER;

  BEGIN

     SELECT COUNT(A.ADMPV_DESCRIPCION) INTO V_CONT
     FROM PCLUB.ADMPT_MENSAJE A
     WHERE A.ADMPV_VALOR = K_PARAMETRO;

     IF V_CONT = 0 THEN
       K_RESPUESTA:= 1;
       K_DESCERROR:='No existe registro con la descripcion ingresada';
     ELSE
       SELECT A.ADMPV_DESCRIPCION INTO K_VALOR
       FROM PCLUB.ADMPT_MENSAJE A
       WHERE A.ADMPV_VALOR = K_PARAMETRO;

       K_RESPUESTA:= 0;
       K_DESCERROR:='OK';
     END IF;

  EXCEPTION
    WHEN OTHERS THEN
     K_RESPUESTA:= 1;
     K_DESCERROR:= SUBSTR(SQLERRM,1,250);
     ROLLBACK;
END ADMPSI_OBTMENSAJE;


--****************************************************************
  -- Nombre SP           :  ADMPSS_LISTAR_TIPO_DOCUMENTOS
  -- Propósito           :  permite listar los tipos de documentos
  -- Input               :
  -- Output              :  CUR_LISTA
  -- Fec Creación        :  20/07/2012
  -- Fec Actualización   :
--****************************************************************

PROCEDURE ADMPSS_LISTAR_TIPO_DOCUMENTOS(CUR_LISTA OUT K_REF_CURSOR) IS
BEGIN
  OPEN CUR_LISTA FOR
    SELECT DISTINCT T.ADMPV_COD_TPDOC AS CODIGO,
                    UPPER(T.ADMPV_DSC_DOCUM) AS DESCRIPCION
      FROM PCLUB.ADMPT_TIPO_DOC T
     WHERE T.ADMPV_COD_TPDOC IS NOT NULL
     ORDER BY T.ADMPV_COD_TPDOC;
END ADMPSS_LISTAR_TIPO_DOCUMENTOS;

--****************************************************************
  -- Nombre SP           :  ADMPSS_LISTAR_TIPCLIE_XTRANSAC
  -- Propósito           :  permite listar los tipos de Clientes disponibles por Transaccion
  -- Input               :  K_TRANSACCION
  -- Output              :  CUR_LISTA
  -- Fec Creación        :  20/07/2012
  -- Fec Actualización   :
--****************************************************************

PROCEDURE ADMPSS_LISTAR_TIPCLIE_XTRANSAC(K_TRANSACCION IN VARCHAR2,
                                         CUR_LISTA     OUT K_REF_CURSOR) IS
BEGIN

  OPEN CUR_LISTA FOR
    SELECT DISTINCT T.ADMPV_COD_TPOCL AS CODIGO,
                    T.ADMPV_DESC      AS DESCRIPCION
      FROM PCLUB.ADMPT_TIPO_CLIENTE T
     WHERE T.ADMPC_ESTADO = 'A'
       AND T.ADMPV_COD_TPOCL IS NOT NULL
       AND T.ADMPV_COD_TPOCL IN
           (SELECT ADMPV_COD_TPOCL
              FROM PCLUB.ADMPT_TRANSAC_X_CLIENTE C
             WHERE C.ADMPV_TRANSACCION = K_TRANSACCION)
     ORDER BY T.ADMPV_COD_TPOCL;
END ADMPSS_LISTAR_TIPCLIE_XTRANSAC;

--****************************************************************
  -- Nombre SP           :  ADMPSS_BUSCARCLIENTECC
  -- Propósito           :  permite Buscar a un Cliente ClaroClub
  -- Input               :  K_TIPDOC
  --                        K_NUMDOC
  --                        K_TIPCLIE

  -- Output              :  K_CODERROR
  --                        K_DESCERROR
  --                        CUR_LISTA
  -- Fec Creación        :  20/07/2012
  -- Fec Actualización   :
--****************************************************************

PROCEDURE ADMPSS_BUSCARCLIENTECC(K_TIPDOC    IN VARCHAR2,
                                 K_NUMDOC    IN VARCHAR2,
                                 K_TIPCLIE   IN VARCHAR2,
                                 K_CODERROR  OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2,
                                 CUR_LISTA   OUT SYS_REFCURSOR) IS
  V_COUNT NUMBER;

BEGIN
  K_CODERROR  := 0;
  K_DESCERROR := '';

  SELECT COUNT(*)
    INTO V_COUNT
    FROM PCLUB.ADMPT_CLIENTE C
   WHERE C.ADMPV_TIPO_DOC = K_TIPDOC
     AND C.ADMPV_NUM_DOC = K_NUMDOC
     AND C.ADMPV_COD_TPOCL = K_TIPCLIE
     AND C.ADMPC_ESTADO='A';

  IF V_COUNT > 0 THEN
    OPEN CUR_LISTA FOR
      SELECT C.ADMPV_COD_CLI CODCLI,
             C.ADMPV_NOM_CLI NOMCLI,
             C.ADMPV_APE_CLI APECLI,
             C.ADMPV_TIPO_DOC  CODTIPDOC,
             D.ADMPV_DSC_DOCUM TIPDOC,
             D.ADMPV_EQU_DWH TIPDOCDWH,
             C.ADMPV_NUM_DOC NUMDOC,
             C.ADMPV_COD_TPOCL CODTIPCLI,
             T.ADMPV_DESC TIPCLI
        FROM PCLUB.ADMPT_CLIENTE C, PCLUB.ADMPT_TIPO_DOC D , PCLUB.ADMPT_TIPO_CLIENTE T
       WHERE C.ADMPV_TIPO_DOC=D.ADMPV_COD_TPDOC
         AND C.ADMPV_COD_TPOCL=T.ADMPV_COD_TPOCL
         AND C.ADMPV_TIPO_DOC = K_TIPDOC
         AND C.ADMPV_NUM_DOC = K_NUMDOC
         AND C.ADMPV_COD_TPOCL = K_TIPCLIE
         AND C.ADMPC_ESTADO='A';
  ELSE
    OPEN CUR_LISTA FOR
      SELECT '' CODCLI,
             '' NOMCLI,
             '' APECLI,
             '' CODTIPDOC,
             '' TIPDOC,
			 '' TIPDOCDWH,
             '' NUMDOC,
             '' CODTIPCLI,
             '' TIPCLI
             FROM DUAL;
    K_CODERROR  := 1;
    K_DESCERROR := 'El cliente no esta registrado en ClaroClub';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR  := 1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);

END ADMPSS_BUSCARCLIENTECC;

PROCEDURE ADMPSS_BUSCARCLIENTE(K_TIPDOC    IN VARCHAR2,
                               K_NUMDOC    IN VARCHAR2,
                               K_TIPCLIE   IN VARCHAR2,
                               K_CODERROR  OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2,
                               CUR_LISTA   OUT SYS_REFCURSOR) IS
  V_COUNT NUMBER;

BEGIN
  K_CODERROR  := 0;
  K_DESCERROR := '';

  SELECT COUNT(*)
    INTO V_COUNT
    FROM PCLUB.ADMPT_CLIENTEFIJA C
   WHERE C.ADMPV_TIPO_DOC = K_TIPDOC
     AND C.ADMPV_NUM_DOC = K_NUMDOC
     AND C.ADMPV_COD_TPOCL = K_TIPCLIE;

  IF V_COUNT > 0 THEN
    OPEN CUR_LISTA FOR
      SELECT C.ADMPV_COD_CLI CODCLI,
             C.ADMPV_NOM_CLI NOMCLI,
             C.ADMPV_APE_CLI APECLI,
             C.ADMPV_TIPO_DOC  CODTIPDOC,
             D.ADMPV_DSC_DOCUM TIPDOC,
             C.ADMPV_NUM_DOC NUMDOC,
             C.ADMPV_COD_TPOCL CODTIPCLI,
             T.ADMPV_DESC TIPCLI,
             D.ADMPV_EQU_FIJA CODTIPDOCSGA
        FROM PCLUB.ADMPT_CLIENTEFIJA C, PCLUB.ADMPT_TIPO_DOC D , PCLUB.ADMPT_TIPO_CLIENTE T
       WHERE C.ADMPV_TIPO_DOC=D.ADMPV_COD_TPDOC
         AND C.ADMPV_COD_TPOCL=T.ADMPV_COD_TPOCL
         AND C.ADMPV_TIPO_DOC = K_TIPDOC
         AND C.ADMPV_NUM_DOC = K_NUMDOC
         AND C.ADMPV_COD_TPOCL = K_TIPCLIE  AND C.ADMPC_ESTADO='A';
  ELSE
    OPEN CUR_LISTA FOR
      SELECT '' CODCLI,
             '' NOMCLI,
             '' APECLI,
             '' CODTIPDOC,
             '' TIPDOC,
             '' NUMDOC,
             '' CODTIPCLI,
             '' TIPCLI,
             '' CODTIPDOCSGA
             FROM DUAL
             WHERE 1=0;
    K_CODERROR  := 1;
    K_DESCERROR := 'El cliente no esta registrado en DTH_HFC o esta Dado de Baja';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR  := 1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    OPEN CUR_LISTA FOR
      SELECT '' CODCLI, 
             '' NOMCLI, 
             '' APECLI, 
             '' CODTIPDOC,
             '' TIPDOC,
             '' NUMDOC,
             '' CODTIPCLI,
             '' TIPCLI,
             '' CODTIPDOCSGA
             FROM DUAL
             WHERE 1=0;
END ADMPSS_BUSCARCLIENTE;

PROCEDURE ADMPSS_LISTAR_TIPOS(K_GRUPO INTEGER,
                              CUR_LISTA OUT K_REF_CURSOR) IS
BEGIN
  OPEN CUR_LISTA FOR
    SELECT DISTINCT T.ADMPV_COD_TIPO AS CODIGO,
                    T.admpv_dsc_tipo AS DESCRIPCION,
                    T.ADMPV_RUTA AS RUTA
      FROM PCLUB.ADMPT_TIPOS T
     WHERE T.ADMPV_GRUPO=K_GRUPO
     AND   T.ADMPV_ESTADO='A'
     AND T.ADMPV_COD_TIPO  IS NOT NULL
     ORDER BY T.ADMPV_COD_TIPO;
END ADMPSS_LISTAR_TIPOS;

PROCEDURE ADMPSI_OBTPARAMETRO(K_PARAMETRO IN  VARCHAR2,
                              K_VALOR     OUT VARCHAR2,
                              K_CODERROR    OUT NUMBER,
                              K_DESCERROR   OUT VARCHAR2) IS
  --****************************************************************
  -- Nombre SP           :  ADMPSI_OBTPARAMETRO
  -- Propósito           :  Obtener Mensaje
  -- Input               :  NombreParametro
  -- Output              :  - Valor
  --Respuesta
  --Mensaje Error
  -- Creado por          :    E77113
  -- Fec Creación        :  19/09/2012
  -- Fec Actualización   :
  --****************************************************************

  V_CONT NUMBER;

BEGIN

  SELECT COUNT(A.ADMPV_DESC)
    INTO V_CONT
  FROM  PCLUB.ADMPT_PARAMSIST A
  WHERE ADMPV_DESC = K_PARAMETRO;

  IF V_CONT = 0 THEN
    K_CODERROR := 1;
    K_DESCERROR := 'No existe registro con la descripcion ingresada';
  ELSE
     SELECT A.ADMPV_VALOR
       INTO K_VALOR
     FROM  PCLUB.ADMPT_PARAMSIST A
    WHERE ADMPV_DESC = K_PARAMETRO;
    K_CODERROR  := 0;
    K_DESCERROR := 'OK';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR  := 1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    ROLLBACK;
END ADMPSI_OBTPARAMETRO;


PROCEDURE ADMPSS_LISTAR_SEGMENTOS(CUR_LISTA OUT K_REF_CURSOR) IS
BEGIN
  OPEN CUR_LISTA FOR
    SELECT DISTINCT S.ADMPN_COD_SEG AS CODIGO,
                    UPPER(S.ADMPV_DESCRIPCION) AS DESCRIPCION
      FROM PCLUB.ADMPT_SEGMENTOCUPONERA S
     WHERE S.ADMPN_COD_SEG IS NOT NULL
     ORDER BY S.ADMPN_COD_SEG;
END ADMPSS_LISTAR_SEGMENTOS;

--****************************************************************
  -- Nombre SP           :  ADMPSS_LISTAR_CUPONERAS
  -- Propósito           :  permite listar las Cuponeras
  -- Input               :
  -- Output              :  CUR_LISTA
  -- Fec Creación        :  20/07/2012
  -- Fec Actualización   :
--****************************************************************

PROCEDURE ADMPSS_LISTAR_CUPONERAS(CUR_LISTA OUT K_REF_CURSOR) IS
BEGIN
  OPEN CUR_LISTA FOR
    SELECT DISTINCT C.ADMPN_COD_CUP AS CODIGO,
                    UPPER(C.ADMPV_NOM_CUP) AS DESCRIPCION
      FROM PCLUB.ADMPT_CUPONERA C
     WHERE C.ADMPC_ESTADO<>'P'
     ORDER BY C.ADMPN_COD_CUP;
END ADMPSS_LISTAR_CUPONERAS;

--Segmentacion

PROCEDURE ADMPSS_LIST_SEGMENTOS_CC(K_CUR_SEG OUT SYS_REFCURSOR) IS

BEGIN

  OPEN K_CUR_SEG FOR
  SELECT S.ADMV_COD_SEG COD_SEG,
         S.ADMV_DESC_SEG DESC_SEG
  FROM PCLUB.ADMPT_SEGMENTO_CC S
  WHERE S.ADMV_COD_SEG=S.ADMV_COD_SEG || '';

END ADMPSS_LIST_SEGMENTOS_CC;

PROCEDURE ADMPSS_LIST_DSCTO_SEG_TCLIE(K_CODSEGMENTO IN VARCHAR2,
                                      K_CODTCLIE IN VARCHAR2,
                                      K_CODTPREMIO IN VARCHAR2,
                                      K_ESTADO IN CHAR,
                                      K_CUR_LISTA OUT SYS_REFCURSOR,
                                      K_CODERROR OUT NUMBER,
                                      K_DESCERROR OUT VARCHAR2) IS

BEGIN
  K_CODERROR := 0;
  K_DESCERROR := '';

  OPEN K_CUR_LISTA FOR
    SELECT D.ADMPV_CODSEGMENTO AS COD_SEG,
           C.ADMV_DESC_SEG AS DESC_SEG,
           D.ADMPV_CODTIPOCLIENTE AS COD_TCLI,
           TC.ADMPV_DESC AS TCLI,
           D.ADMPV_CODTIPOPREMIO AS COD_TPREM,
           TP.ADMPV_DESC AS DESC_PREM,
           D.ADMPV_VALORSEGMENTO AS VALOR,
           D.ADMPC_ESTADO AS ESTADO,
           CASE D.ADMPC_ESTADO
             WHEN 'A' THEN 'ACTIVADO'
             WHEN 'B' THEN 'DESACTIVADO'
           END AS NOMESTADO
    FROM PCLUB.ADMPT_DSCTO_XSEG_XTCLIE D,
         PCLUB.ADMPT_SEGMENTO_CC C,
         PCLUB.ADMPT_TIPO_PREMIO TP,
         PCLUB.ADMPT_TIPO_CLIENTE TC
    WHERE (C.ADMV_COD_SEG=D.ADMPV_CODSEGMENTO
           AND D.ADMPV_CODTIPOPREMIO=TP.ADMPV_COD_TPOPR
           AND D.ADMPV_CODTIPOCLIENTE=TC.ADMPV_COD_TPOCL)
           AND ((K_CODSEGMENTO IS NULL OR D.ADMPV_CODSEGMENTO=K_CODSEGMENTO)
               AND (K_CODTCLIE IS NULL OR D.ADMPV_CODTIPOCLIENTE=K_CODTCLIE)
               AND (K_CODTPREMIO IS NULL OR D.ADMPV_CODTIPOPREMIO=K_CODTPREMIO)
               AND (K_ESTADO IS NULL OR D.ADMPC_ESTADO=K_ESTADO));

EXCEPTION
   WHEN OTHERS THEN

   K_CODERROR:= -1;
   K_DESCERROR:= SUBSTR(SQLERRM,1,250);

END ADMPSS_LIST_DSCTO_SEG_TCLIE;


PROCEDURE ADMPSI_REG_DSCTO_SEGMENTO(K_COD_SEG IN VARCHAR2,
                                    K_COD_TCLIE IN VARCHAR2,
                                    K_COD_TPREMIO IN VARCHAR2,
                                    K_ESTADO IN CHAR,
                                    K_VALOR IN VARCHAR2,
                                    K_USU_REG IN VARCHAR2,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2) IS
  EX_ERROR EXCEPTION;
  V_COUNT_REG NUMBER;
BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';

  IF K_COD_SEG IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR := ' No se ingresó el código del segmento.';
    RAISE EX_ERROR;
  END IF;

  IF K_COD_TCLIE IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR := ' No se ingresó el código del tipo de cliente.';
    RAISE EX_ERROR;
  END IF;

  IF K_COD_TPREMIO IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR := ' No se ingresó el código del tipo de premio.';
    RAISE EX_ERROR;
  END IF;

  IF K_ESTADO IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR := ' No se ingresó el estado del segmento.';
    RAISE EX_ERROR;
  END IF;

  IF K_VALOR IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR := ' No se ingresó el valor del segmento.';
    RAISE EX_ERROR;
  END IF;

  IF K_USU_REG IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR := ' No se ingresó el nombre usuario.';
   RAISE EX_ERROR;
  END IF;

  SELECT COUNT(1) INTO V_COUNT_REG
  FROM PCLUB.ADMPT_DSCTO_XSEG_XTCLIE D
  WHERE D.ADMPV_CODSEGMENTO=K_COD_SEG
        AND D.ADMPV_CODTIPOCLIENTE=K_COD_TCLIE
        AND D.ADMPV_CODTIPOPREMIO=K_COD_TPREMIO;

  IF V_COUNT_REG > 0 THEN
    K_CODERROR := 1;
    K_DESCERROR := ' Existe un valor registrado con los datos enviados.';
    RAISE EX_ERROR;
  END IF;

  INSERT INTO PCLUB.ADMPT_DSCTO_XSEG_XTCLIE(ADMPV_CODSEGMENTO,
                                      ADMPV_CODTIPOCLIENTE,
                                      ADMPV_CODTIPOPREMIO,
                                      ADMPV_VALORSEGMENTO,
                                      ADMPC_ESTADO,
                                      ADMPV_USU_REG,
                                      ADMPD_FEC_REG)
  VALUES (K_COD_SEG,
          K_COD_TCLIE,
          K_COD_TPREMIO,
          K_VALOR,
          K_ESTADO,
          K_USU_REG,
          SYSDATE);

    K_CODERROR := 0;
    K_DESCERROR := '';

    COMMIT;

    SELECT E.ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM  PCLUB.ADMPT_ERRORES_CC E
    WHERE E.ADMPN_COD_ERROR = K_CODERROR;

EXCEPTION
  WHEN EX_ERROR THEN
    BEGIN

      SELECT E.ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
      FROM  PCLUB.ADMPT_ERRORES_CC E
      WHERE E.ADMPN_COD_ERROR = K_CODERROR;

      ROLLBACK;
    END;

  WHEN OTHERS THEN
   K_CODERROR:= SQLCODE;
   K_DESCERROR:= SUBSTR(SQLERRM,1,250);
   ROLLBACK;

END ADMPSI_REG_DSCTO_SEGMENTO;


PROCEDURE ADMPSU_MOD_DSCTO_SEGMENTO(K_COD_SEG IN VARCHAR2,
                                    K_COD_TCLIE IN VARCHAR2,
                                    K_COD_TPREMIO IN VARCHAR2,
                                    K_ESTADO IN CHAR,
                                    K_VALOR IN VARCHAR2,
                                    K_USU_MOD IN VARCHAR2,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2) IS
  EX_ERROR EXCEPTION;
BEGIN
  K_CODERROR := 0;
  K_DESCERROR := '';

  IF K_COD_SEG IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR := ' No se ingresó el código del segmento.';
    RAISE EX_ERROR;
  END IF;

  IF K_COD_TCLIE IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR := ' No se ingresó el código del segmento.';
    RAISE EX_ERROR;
  END IF;

  IF K_COD_TPREMIO IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR := ' No se ingresó la descripción del segmento.';
    RAISE EX_ERROR;
  END IF;

  IF K_ESTADO IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR := ' No se ingresó el estado del segmento.';
    RAISE EX_ERROR;
  END IF;

  IF K_VALOR IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR := ' No se ingresó el valor del segmento.';
    RAISE EX_ERROR;
  END IF;

  IF K_USU_MOD IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR := ' No se ingresó el nombre usuario.';
    RAISE EX_ERROR;
  END IF;

  UPDATE PCLUB.ADMPT_DSCTO_XSEG_XTCLIE D
  SET D.ADMPV_VALORSEGMENTO = K_VALOR,
      D.ADMPC_ESTADO = K_ESTADO,
      D.ADMPV_USU_MOD = K_USU_MOD,
      D.ADMPD_FEC_MOD = SYSDATE
  WHERE D.ADMPV_CODSEGMENTO=K_COD_SEG
        AND D.ADMPV_CODTIPOCLIENTE=K_COD_TCLIE
        AND D.ADMPV_CODTIPOPREMIO=K_COD_TPREMIO;

  K_CODERROR := 0;
  K_DESCERROR := '';

  COMMIT;

  SELECT E.ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
  FROM  PCLUB.ADMPT_ERRORES_CC E
  WHERE E.ADMPN_COD_ERROR = K_CODERROR;

EXCEPTION
  WHEN EX_ERROR THEN
    BEGIN
      SELECT E.ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
      FROM  PCLUB.ADMPT_ERRORES_CC E
      WHERE E.ADMPN_COD_ERROR = K_CODERROR;

      ROLLBACK;
    END;

  WHEN OTHERS THEN
   K_CODERROR:= SQLCODE;
   K_DESCERROR:= SUBSTR(SQLERRM,1,250);
   ROLLBACK;

END ADMPSU_MOD_DSCTO_SEGMENTO;

PROCEDURE ADMPSS_PREMIO(K_PREMIO IN VARCHAR2,
                        CUR_LISTA OUT SYS_REFCURSOR,
                        K_CODERROR OUT NUMBER,
                        K_DESCERROR OUT VARCHAR2) IS
V_COUNT NUMBER;
EX_ERROR_1 EXCEPTION; 
EX_ERROR_2 EXCEPTION;
--****************************************************************
-- Nombre SP           :  ADMPSS_PREMIO
-- Propósito           :  Devuelve lista de premios
-- Input               :  K_PREMIO 

--
-- Output              :  CUR_LISTA
--                       
-- Creado por          :  
-- Fec Creación        :  01/07/2014
-- Fec Actualización   :
--****************************************************************                         
BEGIN
K_CODERROR:=0;
K_DESCERROR:=' ';

IF K_PREMIO IS NULL THEN
       RAISE EX_ERROR_1;
END IF;

SELECT COUNT(P.ADMPV_ID_PROCLA)INTO V_COUNT
FROM   PCLUB.ADMPT_PREMIO P
WHERE  P.ADMPV_ID_PROCLA = K_PREMIO
AND    P.ADMPC_ESTADO = 'A';

IF V_COUNT = 1 THEN

OPEN CUR_LISTA FOR
    SELECT DISTINCT P.ADMPV_COD_TPOPR AS CODIGO_TIPOPREMIO,
                    P.ADMPV_DESC AS DESCRIPCION,
                    P.ADMPN_PUNTOS AS PUNTOS,
                    P.ADMPN_PAGO AS PAGO,
                    P.ADMPC_ESTADO AS ESTADO,
                    P.ADMPN_COD_SERVC AS CODIGO_SERVICIO,
                    P.ADMPN_MNT_RECAR AS MINUTO_RECARGA,
                    P.ADMPC_APL_PUNTO AS APL_PUNTO,
                    P.ADMPV_CAMPANA AS CAMPANA,
                    P.ADMPV_CLAVE AS CLAVE,
                    P.ADMPN_MNTDCTO AS MINUTO_DSCTO,
                    P.ADMPV_COD_PAQDAT AS COD_PAQUETE_DATOS,
                    P.ADMPV_COD_SERVTV AS COD_SERVICIOTV
     FROM PCLUB.ADMPT_PREMIO P
     WHERE P.ADMPV_ID_PROCLA = K_PREMIO
     AND   P.ADMPC_ESTADO = 'A';
ELSE
        RAISE EX_ERROR_2;
END IF;

--EXCPT
EXCEPTION
      WHEN EX_ERROR_1 THEN
        BEGIN
         K_CODERROR  := 1;
         K_DESCERROR := 'Ingrese un Codigo de Premio Válido. ';
         
            OPEN CUR_LISTA FOR
                 SELECT '' CODIGO_TIPOPREMIO,
                        '' DESCRIPCION,
                        '' PUNTOS,
                        '' PAGO,
                        '' ESTADO,
                        '' CODIGO_SERVICIO,
                        '' MINUTO_RECARGA,
                        '' APL_PUNTO,
                        '' CAMPANA,
                        '' CLAVE,
                        '' MINUTO_DSCTO,
                        '' COD_PAQUETE_DATOS,
                        '' COD_SERVICIOTV
                 FROM DUAL
                 WHERE 1=0;
        END;
        
        WHEN EX_ERROR_2 THEN
          BEGIN
          K_CODERROR  := 2;
          K_DESCERROR := 'El premio no existe ó esta desactivo. ';
          OPEN CUR_LISTA FOR
                 SELECT '' CODIGO_TIPOPREMIO,
                        '' DESCRIPCION,
                        '' PUNTOS,
                        '' PAGO,
                        '' ESTADO,
                        '' CODIGO_SERVICIO,
                        '' MINUTO_RECARGA,
                        '' APL_PUNTO,
                        '' CAMPANA,
                        '' CLAVE,
                        '' MINUTO_DSCTO,
                        '' COD_PAQUETE_DATOS,
                        '' COD_SERVICIOTV
           FROM DUAL
           WHERE 1=0;
         END;
         
        WHEN OTHERS THEN
          BEGIN
          K_CODERROR := SQLCODE;
          K_DESCERROR := SUBSTR(SQLERRM,0,250);
          OPEN CUR_LISTA FOR
             SELECT '' CODIGO_TIPOPREMIO,
                    '' DESCRIPCION,
                    '' PUNTOS,
                    '' PAGO,
                    '' ESTADO,
                    '' CODIGO_SERVICIO,
                    '' MINUTO_RECARGA,
                    '' APL_PUNTO,
                    '' CAMPANA,
                    '' CLAVE,
                    '' MINUTO_DSCTO,
                    '' COD_PAQUETE_DATOS,
                    '' COD_SERVICIOTV
             FROM DUAL
             WHERE 1=0;
          END;
END ADMPSS_PREMIO;


PROCEDURE ADMPSS_PREMIOIVR(K_TIPO_DOC        IN VARCHAR2,       
                           K_NUM_DOC         IN VARCHAR2,       
                           K_TIP_CLI         IN VARCHAR2,       
                           K_TIP_LINEA       IN VARCHAR2,       
                           K_CODERROR        OUT NUMBER,
                           K_MSJERROR        OUT VARCHAR2,
                           K_SALDO_PUNTOS    OUT NUMBER,
                           K_CUR_LISTA       OUT SYS_REFCURSOR) IS

    SIN_DATA EXCEPTION; 
    VALCLIEN NUMBER;
    VALTIPDC NUMBER;                         
    VALTIPLN NUMBER;
  BEGIN
    K_SALDO_PUNTOS :=0;
    K_CODERROR     :=0;
    K_MSJERROR     :='';
    --validando el tipo de cliente
    IF K_TIP_CLI IS NULL THEN 
       K_CODERROR:=50;
       K_MSJERROR:='Error : No se proporciono el tipo de cliente';
       K_SALDO_PUNTOS:=0;
       RAISE SIN_DATA;
    END IF;
    SELECT TRIM(TRANSLATE(K_TIP_CLI, '12345678', ' ')) INTO VALCLIEN
    FROM DUAL;
    
    IF (NOT (VALCLIEN IS NULL)) OR LENGTH(VALCLIEN)>1 THEN
        K_CODERROR:=51;
        K_MSJERROR:='Error : El valor proporcionado para Tipo cliente es invalido';
        K_SALDO_PUNTOS:=0;
        RAISE SIN_DATA;
    END IF;
    --validando el tipo de documento
    IF K_TIPO_DOC IS NULL THEN
        K_CODERROR:=52;   
        K_MSJERROR:='Error : El valor proporcionado para el tipo de documento es nulo';
        K_SALDO_PUNTOS:=0;
        RAISE SIN_DATA;
    END IF;

    SELECT TRIM(TRANSLATE(K_TIPO_DOC, '0123456', ' ')) INTO VALTIPDC
    FROM DUAL;
    
    IF (NOT(VALTIPDC IS NULL)) OR LENGTH(VALTIPDC)> 1 THEN
        K_CODERROR:=53;   
        K_MSJERROR:='Error : El valor proporcionado para el tipo de documento es invalido';
        K_SALDO_PUNTOS:=0;
        RAISE SIN_DATA;      
    END IF;
    
    --validando el numero de documento
    IF K_NUM_DOC  IS NULL THEN
        K_CODERROR:=54;   
        K_MSJERROR:='Error : El valor proporcionado para el numero de documento es nulo';
        K_SALDO_PUNTOS:=0;
        RAISE SIN_DATA;
    END IF;

    IF( K_TIP_CLI='6' OR K_TIP_CLI='7' ) THEN
        IF K_TIP_LINEA IS NULL  THEN
           K_CODERROR:=55;   
           K_MSJERROR:='Error : El valor proporcionado para el tipo de linea es nula';
           K_SALDO_PUNTOS:=0;
           RAISE SIN_DATA;  
        END IF;
        
        SELECT TRIM(TRANSLATE(K_TIP_LINEA, '23', ' ')) INTO VALTIPLN
        FROM DUAL;
        
        IF (NOT (VALTIPLN IS NULL)) OR LENGTH(K_TIP_LINEA)>1 THEN
           K_CODERROR:=56;   
           K_MSJERROR:='Error : El valor proporcionado para el tipo de linea es invalida';
           K_SALDO_PUNTOS:=0;
           RAISE SIN_DATA;  
        END IF;
    END IF;
    
    IF ( K_TIP_CLI ='1' OR 
         K_TIP_CLI ='2' OR
         K_TIP_CLI ='3' OR
         K_TIP_CLI ='4' OR
         K_TIP_CLI ='5' OR
         K_TIP_CLI ='8'
        ) THEN
        BEGIN
         --PROCESO PARA IVR MOVILES
          PCLUB.PKG_CC_TRANSACCION.ADMPSI_ES_CLIENTE(NULL,K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,K_SALDO_PUNTOS,K_CODERROR);
          IF K_CODERROR =0  OR K_CODERROR IS NULL THEN
             PCLUB.PKG_CC_MANTENIMIENTO.ADMPSS_MOVILPREMI(K_TIP_CLI,K_SALDO_PUNTOS,K_CODERROR,K_MSJERROR,K_CUR_LISTA);
          ELSE
             K_MSJERROR:='Error : Se obtuvo un error al consultar el saldo del cliente';
             RAISE SIN_DATA;
          END IF;
         
        END;
    ELSE
        --SOLO PARA K_TIP_CLI ='6' OR K_TIP_CLI='7'
        --PROCESO PARA IVR FIJAS
        BEGIN
         PCLUB.PKG_CC_TRANSACCIONFIJA.ADMPSI_ES_CLIENTE(K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,K_SALDO_PUNTOS,K_CODERROR,K_MSJERROR);
         IF K_CODERROR =0  OR K_CODERROR IS NULL THEN
            PCLUB.PKG_CC_MANTENIMIENTO.ADMPSS_FIJAPREMI(K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,K_TIP_LINEA,K_SALDO_PUNTOS,K_CODERROR,K_MSJERROR,K_CUR_LISTA);
         ELSE
           K_MSJERROR:='Error : Se obtuvo un error al consultar el saldo del cliente';
           RAISE SIN_DATA;
         END IF;
        END;
   END IF;
   EXCEPTION 
     WHEN SIN_DATA THEN
       OPEN K_CUR_LISTA FOR
			 SELECT  '' PRODID,
               '' PRODDES,
               '' CAMPANA,
               '' PUNTOS,
               '' PAGO,
               '' T_PR,
               '' SERVCOMERCIAL,
               '' MONTORECARGA,
               '' CODIGO_PAQUETE,
               '' COD_T_PR,
               '' IVR,
               '' CANTIDADIVR,
               '' TPREMIO
			FROM DUAL
			WHERE 1=0;
     WHEN OTHERS THEN
       K_CODERROR:=1;
       K_MSJERROR:='ERROR AL CONSULTAR PREMIOS IVR'; 
       OPEN K_CUR_LISTA FOR
       SELECT '' MSG
       FROM DUAL
       WHERE 1=0;
       
END ADMPSS_PREMIOIVR;


PROCEDURE ADMPSS_MOVILPREMI(K_TIP_CLI         IN VARCHAR2,
							              K_SALDO_PUNTOS    IN NUMBER,
                            K_CODERROR        OUT NUMBER,
                            K_MSJERROR        OUT VARCHAR2,
                            K_CUR_LISTA       OUT SYS_REFCURSOR) IS
	
	EX_VALSALDO EXCEPTION;
  VALCLIEN    NUMBER;
	
	BEGIN
    K_CODERROR := 0;
    K_MSJERROR := '';
	
	IF K_SALDO_PUNTOS IS NULL THEN
		K_CODERROR:=43;
		K_MSJERROR:='Error : No se proporciono un valor al saldo';
		RAISE EX_VALSALDO;
	END IF;
  
  IF K_SALDO_PUNTOS <= 0 	  THEN
		K_CODERROR:=44;
		K_MSJERROR:='Error : El valor del saldo debe ser mayor igual a cero';
		RAISE EX_VALSALDO;
	END IF;
  
  IF K_TIP_CLI IS NULL THEN
    K_CODERROR:=45;
		K_MSJERROR:='Error : No se proporciono el valor para el tipo de cliente';
		RAISE EX_VALSALDO;
  END IF;  
  
  SELECT TRIM(TRANSLATE(K_TIP_CLI, '123458', ' ')) INTO VALCLIEN
  FROM DUAL;
  
  IF (NOT (VALCLIEN IS NULL)) OR LENGTH(K_TIP_CLI) > 1 THEN
    K_CODERROR:=46;
		K_MSJERROR:='Error : El valor de tipo de cliente es invalido';
		RAISE EX_VALSALDO;
  END IF;
	
	IF K_TIP_CLI IS NOT NULL THEN
		-- OBTENER PRODUCTOS SEGÚN EL TIPO DE DATOS ENVIADO EN EL PARÁMETRO      
		OPEN K_CUR_LISTA FOR
		SELECT PR.ADMPV_ID_PROCLA     AS PRODID,
       PR.ADMPV_DESC          AS PRODDES,
       PR.ADMPV_CAMPANA       AS CAMPANA,
       PR.ADMPN_PUNTOS        AS PUNTOS,
       PR.ADMPN_PAGO          AS PAGO,
       T_PR.ADMPV_DESC        AS T_PR,
       PR.ADMPN_COD_SERVC     AS SERVCOMERCIAL,
       PR.ADMPN_MNT_RECAR     AS MONTORECARGA,
       PR.ADMPV_COD_PAQDAT    AS CODIGO_PAQUETE,
       T_PR.ADMPN_ORDEN       AS ORDEN, --
       ''                     AS CODIGO_SERVTV,
       T_PR.ADMPV_COD_TPOPR   AS COD_T_PR,
       PR.ADMPV_IVR           AS IVR,
       PR.ADMPV_CANTIVR       AS CANTIDADIVR,
       PR.ADMPV_TPREMIO       AS TPREMIO
		  FROM PCLUB.ADMPT_PREMIO        PR,
			   PCLUB.ADMPT_TIPO_PREMIO   T_PR,
			   PCLUB.ADMPT_TIPO_PREMCLIE T_PRE_CLI
		 WHERE PR.ADMPV_COD_TPOPR = T_PR.ADMPV_COD_TPOPR
		   AND PR.ADMPV_COD_TPOPR = T_PRE_CLI.ADMPV_COD_TPOPR
		   AND T_PR.ADMPV_COD_TPOPR = T_PR.ADMPV_COD_TPOPR
		   AND T_PRE_CLI.ADMPV_COD_TPOCL = K_TIP_CLI
		   AND PR.ADMPC_ESTADO = 'A'
		   AND PR.ADMPN_PUNTOS <= K_SALDO_PUNTOS
		   AND PR.ADMPV_IVR = '1'
		   AND PR.ADMPV_ID_PROCLA NOT IN
			   (SELECT ADMPV_ID_PROCLA
				  FROM PCLUB.ADMPT_EXCPREMIO_TIPOCLIE
				 WHERE ADMPV_COD_TPOCL = K_TIP_CLI)
		   AND PR.ADMPN_PUNTOS <> 0
		 ORDER BY T_PR.ADMPN_ORDEN, PR.ADMPN_PUNTOS DESC;
	END IF;
	EXCEPTION
		WHEN EX_VALSALDO THEN
			OPEN K_CUR_LISTA FOR
			SELECT ''  AS PRODID,
             ''  AS PRODDES,
             ''  AS CAMPANA,
             ''  AS PUNTOS,
             ''  AS PAGO,
             ''  AS T_PR,
             ''  AS SERVCOMERCIAL,
             ''  AS MONTORECARGA,
             ''  AS CODIGO_PAQUETE,
             ''  AS ORDEN, --
             ''  AS CODIGO_SERVTV,
             ''  AS COD_T_PR,
             ''  AS IVR,
             ''  AS CANTIDADIVR,
             ''  AS TPREMIO
			FROM DUAL
			WHERE 1=0;
			
		WHEN NO_DATA_FOUND THEN
		K_CODERROR := 41;
		K_MSJERROR := 'Ingresó datos incorrectos o datos insuficientes para realizar la consulta';
		OPEN K_CUR_LISTA FOR
			SELECT ''  AS PRODID,
             ''  AS PRODDES,
             ''  AS CAMPANA,
             ''  AS PUNTOS,
             ''  AS PAGO,
             ''  AS T_PR,
             ''  AS SERVCOMERCIAL,
             ''  AS MONTORECARGA,
             ''  AS CODIGO_PAQUETE,
             ''  AS ORDEN, --
             ''  AS CODIGO_SERVTV,
             ''  AS COD_T_PR,
             ''  AS IVR,
             ''  AS CANTIDADIVR,
             ''  AS TPREMIO
			FROM DUAL
			WHERE 1=0;
		WHEN OTHERS THEN
			K_CODERROR := SQLCODE;
			K_MSJERROR := SUBSTR(SQLERRM, 1, 250);
			OPEN K_CUR_LISTA FOR
			SELECT ''  AS PRODID,
             ''  AS PRODDES,
             ''  AS CAMPANA,
             ''  AS PUNTOS,
             ''  AS PAGO,
             ''  AS T_PR,
             ''  AS SERVCOMERCIAL,
             ''  AS MONTORECARGA,
             ''  AS CODIGO_PAQUETE,
             ''  AS ORDEN, --
             ''  AS CODIGO_SERVTV,
             ''  AS COD_T_PR,
             ''  AS IVR,
             ''  AS CANTIDADIVR,
             ''  AS TPREMIO
			FROM DUAL
			WHERE 1=0;
END ADMPSS_MOVILPREMI;

PROCEDURE ADMPSS_FIJAPREMI(K_TIPO_DOC        IN VARCHAR2,
                           K_NUM_DOC         IN VARCHAR2,
                           K_TIP_CLI         IN VARCHAR2,
                           K_TIP_LINEA       IN VARCHAR2,
							             K_SALDO_PUNTOS    IN NUMBER,
                           K_CODERROR        OUT NUMBER,
                           K_DESCERROR       OUT VARCHAR2,
                           K_CUR_LISTA       OUT SYS_REFCURSOR) IS
    K_TIPO_LINEA VARCHAR2(2);
    VALTIPDOCUME NUMBER;
    VALTIPCLIENT NUMBER;
    VALTIPLINEAC NUMBER;
    EX_VALIDACION EXCEPTION;
  BEGIN

    K_CODERROR        := 0;
    K_DESCERROR       :='';
    K_TIPO_LINEA := K_TIP_LINEA;
    
    IF K_TIPO_DOC IS NULL THEN
       K_CODERROR :=32;  
       K_DESCERROR:='Error : No se proporciono el tipo de documento';
       RAISE EX_VALIDACION;
    END IF;
    
    SELECT TRIM(TRANSLATE(K_TIPO_DOC, '0123456', ' ')) INTO VALTIPDOCUME
    FROM DUAL;
    
    IF (NOT(VALTIPDOCUME IS NULL)) OR LENGTH(K_TIPO_DOC)> 1 THEN
       K_CODERROR :=33;  
       K_DESCERROR:='Error : El valor proporcionado para el tipo de documento es invalido';
       RAISE EX_VALIDACION;
    END IF;
    
    IF K_NUM_DOC  IS NULL THEN
       K_CODERROR :=34;  
       K_DESCERROR:='Error : No se proporciono el numero de documento';
       RAISE EX_VALIDACION;
    END IF;
    
    IF K_TIP_CLI   IS NULL THEN
       K_CODERROR :=35;  
       K_DESCERROR:='Error : No se proporciono el tipo de cliente';
       RAISE EX_VALIDACION;
    END IF;
    
    SELECT TRIM(TRANSLATE(K_TIP_CLI, '67', ' ')) INTO VALTIPCLIENT
    FROM DUAL;
    
    IF (NOT(VALTIPCLIENT IS NULL)) OR LENGTH(K_TIP_CLI)> 1 THEN
       K_CODERROR :=36;  
       K_DESCERROR:='Error : El valor proporcionado para el tipo de cliente es invalido';
       RAISE EX_VALIDACION;
    END IF;
    
    IF K_TIP_LINEA IS NULL THEN
       K_CODERROR :=37;  
       K_DESCERROR:='Error : No se proporciono el tipo de linea';
       RAISE EX_VALIDACION;
    END IF;
    
    SELECT TRIM(TRANSLATE(K_TIP_LINEA, '23', ' ')) INTO VALTIPLINEAC
    FROM DUAL;
    
    IF (NOT(VALTIPLINEAC IS NULL)) OR LENGTH(K_TIP_LINEA)>1 THEN
       K_CODERROR :=38;  
       K_DESCERROR:='Error : El valor proporcionado para el tipo de linea es invalido';
       RAISE EX_VALIDACION;
    END IF;
    
    -- OBTENER PRODUCTOS SEGÚN EL TIPO DE DATOS ENVIADO EN EL PARÁMETRO
		OPEN K_CUR_LISTA FOR
    SELECT DISTINCT PR.ADMPV_ID_PROCLA AS PRODID,
       PR.ADMPV_DESC      AS PRODDES,
       PR.ADMPV_CAMPANA   AS CAMPANA,
       PR.ADMPN_PUNTOS    AS PUNTOS,
       PR.ADMPN_PAGO      AS PAGO,
       T_PR.ADMPV_DESC    AS T_PR,
       PR.ADMPN_COD_SERVC AS SERVCOMERCIAL,
       PR.ADMPN_MNT_RECAR AS MONTORECARGA,
       PR.ADMPV_COD_PAQDAT AS CODIGO_PAQUETE, --
       T_PR.ADMPN_ORDEN    AS ORDEN,
       PR.ADMPV_COD_SERVTV AS CODIGO_SERVTV,
       PR.ADMPV_COD_TPOPR  AS COD_T_PR,
       PR.ADMPV_IVR           AS IVR,
       PR.ADMPV_CANTIVR       AS CANTIDADIVR,
       PR.ADMPV_TPREMIO       AS TPREMIO
      FROM PCLUB.ADMPT_PREMIO        PR
         INNER JOIN PCLUB.ADMPT_TIPO_PREMIO   T_PR      ON (PR.ADMPV_COD_TPOPR = T_PR.ADMPV_COD_TPOPR)
         INNER JOIN PCLUB.ADMPT_TIPO_PREMCLIE T_PRE_CLI ON (T_PR.ADMPV_COD_TPOPR=T_PRE_CLI.ADMPV_COD_TPOPR)
      WHERE  PR.ADMPC_ESTADO = 'A'  
         AND PR.ADMPN_PUNTOS <= K_SALDO_PUNTOS 
         AND PR.ADMPV_IVR = '1'
         AND T_PRE_CLI.ADMPV_COD_TPOCL IN (K_TIPO_LINEA,K_TIP_CLI) 
         AND PR.ADMPN_PUNTOS > 0 
         AND PR.ADMPV_ID_PROCLA NOT IN (
                                        SELECT ADMPV_ID_PROCLA 
                                        FROM PCLUB.ADMPT_EXCPREMIO_TIPOCLIE 
                                        WHERE ADMPV_COD_TPOCL=K_TIP_CLI
                                       )
      ORDER BY T_PR.ADMPN_ORDEN, PR.ADMPN_PUNTOS DESC;
  EXCEPTION
    WHEN EX_VALIDACION THEN
      OPEN K_CUR_LISTA FOR
			SELECT ''  AS PRODID,
             ''  AS PRODDES,
             ''  AS CAMPANA,
             ''  AS PUNTOS,
             ''  AS PAGO,
             ''  AS T_PR,
             ''  AS SERVCOMERCIAL,
             ''  AS MONTORECARGA,
             ''  AS CODIGO_PAQUETE,
             ''  AS ORDEN, --
             ''  AS CODIGO_SERVTV,
             ''  AS COD_T_PR,
             ''  AS IVR,
             ''  AS CANTIDADIVR,
             ''  AS TPREMIO
      FROM DUAL
      WHERE 1=0;
    WHEN OTHERS THEN
      K_CODERROR := 1;
      K_DESCERROR:=SUBSTR( SQLERRM ,1,250);
      OPEN K_CUR_LISTA FOR
			SELECT ''  AS PRODID,
             ''  AS PRODDES,
             ''  AS CAMPANA,
             ''  AS PUNTOS,
             ''  AS PAGO,
             ''  AS T_PR,
             ''  AS SERVCOMERCIAL,
             ''  AS MONTORECARGA,
             ''  AS CODIGO_PAQUETE,
             ''  AS ORDEN, --
             ''  AS CODIGO_SERVTV,
             ''  AS COD_T_PR,
             ''  AS IVR,
             ''  AS CANTIDADIVR,
             ''  AS TPREMIO
      FROM DUAL
      WHERE 1=0;
  END ADMPSS_FIJAPREMI;
  
  PROCEDURE ADMPSS_BUSCARCLIENTE_IVR(K_TIPDOC    IN VARCHAR2,
                                   K_NUMDOC    IN VARCHAR2,
                                   K_TIPCLIE   IN VARCHAR2,
                                   K_CODERROR  OUT NUMBER,
                                   K_DESCERROR OUT VARCHAR2,
                                   CUR_LISTA   OUT SYS_REFCURSOR,
                                   CUR_CONTRA   OUT SYS_REFCURSOR) IS
  V_COUNT NUMBER;

BEGIN
  K_CODERROR  := 0;
  K_DESCERROR := '';

  SELECT COUNT(*)
    INTO V_COUNT
    FROM ADMPT_CLIENTEFIJA C
   WHERE C.ADMPV_TIPO_DOC = K_TIPDOC
     AND C.ADMPV_NUM_DOC = K_NUMDOC
     AND C.ADMPV_COD_TPOCL = K_TIPCLIE;

  IF V_COUNT > 0 THEN
    OPEN CUR_LISTA FOR
      SELECT C.ADMPV_COD_CLI CODCLI,
             C.ADMPV_NOM_CLI NOMCLI,
             C.ADMPV_APE_CLI APECLI,
             C.ADMPV_TIPO_DOC  CODTIPDOC,
             D.ADMPV_DSC_DOCUM TIPDOC,
             C.ADMPV_NUM_DOC NUMDOC,
             C.ADMPV_COD_TPOCL CODTIPCLI,
             T.ADMPV_DESC TIPCLI,
             D.ADMPV_EQU_FIJA CODTIPDOCSGA
        FROM ADMPT_CLIENTEFIJA C, ADMPT_TIPO_DOC D , ADMPT_TIPO_CLIENTE T
       WHERE C.ADMPV_TIPO_DOC=D.ADMPV_COD_TPDOC
         AND C.ADMPV_COD_TPOCL=T.ADMPV_COD_TPOCL
         AND C.ADMPV_TIPO_DOC = K_TIPDOC
         AND C.ADMPV_NUM_DOC = K_NUMDOC
         AND C.ADMPV_COD_TPOCL = K_TIPCLIE  AND C.ADMPC_ESTADO='A';
       
     OPEN CUR_CONTRA FOR
     SELECT SUBSTR(C.MSISDN,3,11)  LINEA, C.co_id
     FROM  dm.ods_base_abonados@dbl_reptdm_d C, ADMPT_TIPO_DOC D         
     WHERE C.NRO_DOCUMENTO = K_NUMDOC
           AND D.ADMPV_COD_TPDOC = K_TIPDOC
           AND C.TIPO_DOCUMENTO = UPPER(D.ADMPV_EQU_DWH)
           AND C.IDSEGMENTO IN (2,3);
  ELSE
    OPEN CUR_LISTA FOR
      SELECT '' CODCLI, 
             '' NOMCLI, 
             '' APECLI, 
             '' CODTIPDOC,
             '' TIPDOC,
             '' NUMDOC,
             '' CODTIPCLI,
             '' TIPCLI,
             '' CODTIPDOCSGA
             FROM DUAL
             WHERE 1=0;
    OPEN CUR_CONTRA FOR
    SELECT '' LINEA ,''CO_ID
    FROM  DUAL
    WHERE 1=0;  
    K_CODERROR  := 1;
    K_DESCERROR := 'El cliente no esta registrado en DTH_HFC o esta Dado de Baja';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR  := 1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    OPEN CUR_LISTA FOR
      SELECT '' CODCLI, 
             '' NOMCLI, 
             '' APECLI, 
             '' CODTIPDOC,
             '' TIPDOC,
             '' NUMDOC,
             '' CODTIPCLI,
             '' TIPCLI,
             '' CODTIPDOCSGA
             FROM DUAL
             WHERE 1=0;
    OPEN CUR_CONTRA FOR
    SELECT '' LINEA ,''CO_ID
    FROM  DUAL
    WHERE 1=0;  
  
END ADMPSS_BUSCARCLIENTE_IVR;
  
  
END PKG_CC_MANTENIMIENTO;
/
