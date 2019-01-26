CREATE OR REPLACE PACKAGE BODY FIDELIDAD.PKG_FYR_UTILITARIO IS

--****************************************************************
-- Nombre SP           :  SFYRSI_INSCONCEPTOS
-- Propósito           :  Permite insertar el concepto
-- Input               :  K_DESC
--                        K_ORDDESC
--                        K_ACTIVO
--                        K_IDCONCGRUPO
--                        K_USUARIO
-- Output              :  K_ID
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  08/03/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSI_INSCONCEPTOS(K_DESC IN VARCHAR2,
                              K_ORDDESC IN CHAR,
                              K_ACTIVO IN CHAR,
                              K_ID_CONCGRUPO IN NUMBER,
                              K_USUARIO IN VARCHAR2,
                              K_ID OUT NUMBER,
                              K_CODERROR OUT NUMBER,
                              K_DESCERROR OUT VARCHAR2) IS

V_CONT NUMBER;
V_DESC VARCHAR2(150) := UPPER(K_DESC);
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_DESC    IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el nombre. '; RAISE EX_ERROR;
    WHEN K_ORDDESC IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el tipo de orden. '; RAISE EX_ERROR;
    WHEN K_ACTIVO  IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el flag activo. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  SELECT COUNT(1) INTO V_CONT
  FROM FIDELIDAD.SFYRT_CONCEPTOS
  WHERE UPPER(CPTOV_DESC) = V_DESC;

  IF V_CONT > 0 THEN
    K_CODERROR := 4;
    K_DESCERROR := 'Existe un concepto con el mismo nombre.';
    RAISE EX_ERROR;
  END IF;

  SELECT NVL(FIDELIDAD.SFYRT_CONCEPTOS_SQ.NEXTVAL,0) INTO K_ID FROM DUAL;

  IF K_ID = 0 THEN
     K_CODERROR := 6;
     K_DESCERROR := 'No se generó un correlativo para el concepto. ';
     RAISE EX_ERROR;
  END IF;

  INSERT INTO FIDELIDAD.SFYRT_CONCEPTOS(
    CPTON_ID,
    CPTOV_DESC,
    CPTOC_ORDDESC,
    CPTOC_ACTIVO,
    CPTON_IDGRUPO,
    CPTOV_USUREG,
    cptod_fecreg
  )
  VALUES(
    K_ID,
    K_DESC,
    K_ORDDESC,
    K_ACTIVO,
    K_ID_CONCGRUPO,
    K_USUARIO,
    SYSDATE
  );

  COMMIT;
EXCEPTION
  WHEN EX_ERROR THEN
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || K_DESCERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSI_INSCONCEPTOS;

--****************************************************************
-- Nombre SP           :  SFYRSU_UPDCONCEPTOS
-- Propósito           :  Permite actualizar el concepto
-- Input               :  K_ID
--                        K_DESC
--                        K_ORDDESC
--                        K_ACTIVO
--                        K_ID_CONCGRUPO
--                        K_USUARIO
-- Output              :  K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  08/03/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSU_UPDCONCEPTOS(K_ID IN NUMBER,
                              K_DESC IN VARCHAR2,
                              K_ORDDESC IN CHAR,
                              K_ACTIVO IN CHAR,
                              K_ID_CONCGRUPO IN NUMBER,
                              K_USUARIO IN VARCHAR2,
                              K_CODERROR OUT NUMBER,
                              K_DESCERROR OUT VARCHAR2) IS
V_CONT NUMBER;
V_DESC VARCHAR2(150) := UPPER(K_DESC);
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_ID      IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingres el código de concepto. '; RAISE EX_ERROR;
    WHEN K_DESC    IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el nombre. '; RAISE EX_ERROR;
    WHEN K_ORDDESC IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el tipo de orden. '; RAISE EX_ERROR;
    WHEN K_ACTIVO  IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el flag activo. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;
   
  SELECT COUNT(1) INTO V_CONT
  FROM FIDELIDAD.SFYRT_CONCEPTOS
  WHERE UPPER(CPTOV_DESC) = V_DESC
        AND CPTON_ID <> K_ID;

  IF V_CONT > 0 THEN
    K_CODERROR := 2;
    K_DESCERROR := 'Existe un concepto con el mismo nombre. ';
    RAISE EX_ERROR;  
  END IF;

  SELECT COUNT(1) INTO V_CONT
  FROM FIDELIDAD.SFYRT_CONCEPTOS
  WHERE CPTON_ID = K_ID;
    
  IF V_CONT < 1 THEN
    K_CODERROR := 5;
    K_DESCERROR := 'El código de concepto no existe. ';
    RAISE EX_ERROR;
    END IF;

  UPDATE FIDELIDAD.SFYRT_CONCEPTOS
  SET CPTOV_DESC = NVL(K_DESC,CPTOV_DESC),
      CPTOC_ORDDESC = K_ORDDESC,
      CPTOC_ACTIVO = K_ACTIVO,
      CPTON_IDGRUPO = K_ID_CONCGRUPO,
      CPTOV_USUMOD = K_USUARIO  ,
      cptod_fecmod = SYSDATE    
  WHERE CPTON_ID = K_ID;

  COMMIT;
EXCEPTION
  WHEN EX_ERROR THEN
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || K_DESCERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSU_UPDCONCEPTOS;

--****************************************************************
-- Nombre SP           :  SFYRSS_LISCONCEPTOS
-- Propósito           :  Permite consultar los conceptos
-- Input               :  K_ID
--                        K_DESC
--                        K_ACTIVO
-- Output              :  K_CUR_CONCEPTOS
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  12/02/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSS_LISCONCEPTOS(K_ID IN NUMBER,
                              K_DESC IN VARCHAR2,
                              K_ACTIVO IN VARCHAR2,
                              K_CUR_CONCEPTOS OUT SYS_REFCURSOR,
                              K_CODERROR OUT NUMBER,
                              K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
V_DESC VARCHAR2(100);
BEGIN

 K_CODERROR := 0;
 K_DESCERROR := '';
 V_DESC := UPPER(K_DESC);

 OPEN K_CUR_CONCEPTOS FOR
 SELECT C.CPTON_ID,
        C.CPTOV_DESC,
        C.CPTOC_ORDDESC,
        C.CPTOC_ACTIVO,
        C.CPTON_IDGRUPO,
        G.CPTOV_DESC AS CPTOV_DESCGRUPO,
        CASE C.CPTOC_ACTIVO 
             WHEN '1' THEN 'ACTIVO'
             WHEN '0' THEN 'INACTIVO'
             ELSE '' END AS NOMBREACTIVO,
        CASE C.CPTOC_ORDDESC 
             WHEN '1' THEN 'SI'
             WHEN '0' THEN 'NO'
             ELSE '' END AS NOMBREORDDESC
 FROM FIDELIDAD.SFYRT_CONCEPTOS C
 LEFT JOIN FIDELIDAD.SFYRT_CONCEPTOS G ON C.CPTON_IDGRUPO = G.CPTON_ID
 WHERE C.CPTON_ID = NVL(K_ID,C.CPTON_ID)
       AND UPPER(C.CPTOV_DESC) LIKE '%' || V_DESC || '%'
       AND C.CPTOC_ACTIVO = NVL(K_ACTIVO,C.CPTOC_ACTIVO)
 ORDER BY C.CPTOV_DESC;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSS_LISCONCEPTOS;

--****************************************************************
-- Nombre SP           :  SFYRSI_INSTIPOS
-- Propósito           :  Permite insertar el tipo
-- Input               :  K_DESC
--                        K_ABREV
--                        K_ORDEN
--                        K_ACTIVO
--                        K_ID_CONCEPTOS
--                        K_ID_TIPOGRUPO
--                        K_USUARIO
-- Output              :  K_ID
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  08/03/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSI_INSTIPOS(K_DESC IN VARCHAR2,
                          K_ABREV IN VARCHAR2,
                          K_VALOR IN VARCHAR2,
                          K_ORDEN NUMBER,
                          K_ACTIVO IN CHAR,
                          K_ID_CONCEPTOS NUMBER,
                          K_ID_TIPOGRUPO IN NUMBER,
                          K_USUARIO IN VARCHAR2,
                          K_ID OUT NUMBER,
                          K_CODERROR OUT NUMBER,
                          K_DESCERROR OUT VARCHAR2) IS

V_CONT NUMBER;
V_DESC VARCHAR2(150) := UPPER(K_DESC);
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_DESC         IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el nombre. '; RAISE EX_ERROR;
    WHEN K_ORDEN        IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el orden. '; RAISE EX_ERROR;
    WHEN K_ACTIVO       IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el flag activo. '; RAISE EX_ERROR;
    WHEN K_ID_CONCEPTOS IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el código del concepto. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  SELECT COUNT(1) INTO V_CONT
  FROM FIDELIDAD.SFYRT_CONCEPTOS
  WHERE CPTON_ID = K_ID
        AND UPPER(CPTOV_DESC) = V_DESC;

  IF V_CONT > 0 THEN
    K_CODERROR := 2;
    K_DESCERROR := 'Existe un tipo con el mismo nombre.';
    RAISE EX_ERROR;
  END IF;

  SELECT NVL(FIDELIDAD.SFYRT_TIPOS_SQ.NEXTVAL,0) INTO K_ID FROM DUAL;

  IF K_ID = 0 THEN
     K_CODERROR := 6;
     K_DESCERROR := 'No se generó un correlativo para el tipo. ';
     RAISE EX_ERROR;
  END IF;

  INSERT INTO FIDELIDAD.SFYRT_TIPOS(
    TIPON_ID,
    TIPOV_DESC,
    TIPOV_VALOR,
    TIPOV_ABREV,
    TIPON_ORDEN,
    TIPOC_ACTIVO,
    CPTON_ID,
    TIPON_IDGRUPO,
    TIPOV_USUREG ,
    TIPOD_FECREG   
  )
  VALUES(
    K_ID,
    K_DESC,
    K_VALOR,
    K_ABREV,
    K_ORDEN,
    K_ACTIVO,
    K_ID_CONCEPTOS,
    K_ID_TIPOGRUPO,
    K_USUARIO,
    SYSDATE
  );

  COMMIT;
EXCEPTION
  WHEN EX_ERROR THEN
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || K_DESCERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSI_INSTIPOS;

--****************************************************************
-- Nombre SP           :  SFYRSU_UPDTIPOS
-- Propósito           :  Permite actualizar el tipo
-- Input               :  K_ID
--                        K_DESC
--                        K_ABREV
--                        K_ORDEN
--                        K_ACTIVO
--                        K_ID_TIPOGRUPO
--                        K_USUARIO
-- Output              :  K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  08/03/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSU_UPDTIPOS(K_ID IN NUMBER,
                          K_DESC IN VARCHAR2,
                          K_VALOR IN VARCHAR2,
                          K_ABREV IN VARCHAR2,
                          K_ORDEN NUMBER,
                          K_ACTIVO IN CHAR,
                          K_ID_TIPOGRUPO IN NUMBER,
                          K_USUARIO IN VARCHAR2,
                          K_CODERROR OUT NUMBER,
                          K_DESCERROR OUT VARCHAR2) IS
V_CONT NUMBER;
V_DESC VARCHAR2(150) := UPPER(K_DESC);
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_ID     IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingres el código del tipo. '; RAISE EX_ERROR;
    WHEN K_DESC   IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el nombre. '; RAISE EX_ERROR;
    WHEN K_ORDEN  IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el orden. '; RAISE EX_ERROR;
    WHEN K_ACTIVO IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el flag activo. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;
   
  V_DESC := UPPER(K_DESC);
  
  SELECT COUNT(1) INTO V_CONT
  FROM FIDELIDAD.SFYRT_TIPOS
  WHERE UPPER(TIPOV_DESC) = V_DESC
        AND TIPON_ID <> K_ID;

  IF V_CONT > 0 THEN
    K_CODERROR := 2;
    K_DESCERROR := 'Existe un tipo con el mismo nombre. ';
    RAISE EX_ERROR;  
  END IF;

  SELECT COUNT(1) INTO V_CONT
  FROM FIDELIDAD.SFYRT_TIPOS
  WHERE TIPON_ID = K_ID;
    
  IF V_CONT < 1 THEN
    K_CODERROR := 5;
    K_DESCERROR := 'El código del tipo no existe. ';
    RAISE EX_ERROR;
    END IF;

  UPDATE FIDELIDAD.SFYRT_TIPOS
  SET TIPOV_DESC = K_DESC,
      TIPOV_VALOR = K_VALOR,
      TIPOV_ABREV = K_ABREV,
      TIPON_ORDEN = K_ORDEN,
      TIPOC_ACTIVO = K_ACTIVO,
      TIPON_IDGRUPO = K_ID_TIPOGRUPO,
      TIPOV_USUMOD = K_USUARIO,
      TIPOD_FECMOD = SYSDATE
  WHERE TIPON_ID = K_ID;

  COMMIT;
EXCEPTION
  WHEN EX_ERROR THEN
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || K_DESCERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSU_UPDTIPOS;

--****************************************************************
-- Nombre SP           :  SFYRSS_LISTIPOS
-- Propósito           :  Permite consultar los tipos
-- Input               :  K_DESC
--                        K_ACTIVO
--                        K_ID_CONCEPTOS
-- Output              :  K_CUR_TIPOS
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  08/03/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSS_LISTIPOS(K_DESC IN VARCHAR2,
                          K_ACTIVO IN VARCHAR2,
                          K_ID_CONCEPTOS IN NUMBER,
                          K_ID_TIPOSGRUPO IN NUMBER,
                          K_CUR_TIPOS OUT SYS_REFCURSOR,
                          K_CODERROR OUT NUMBER,
                          K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
BEGIN
 
  K_CODERROR := 0;
  K_DESCERROR := '';

  OPEN K_CUR_TIPOS FOR
  SELECT T.TIPON_ID,
         T.TIPOV_DESC,
         T.TIPOV_VALOR,
         T.TIPOV_ABREV,         
         T.TIPON_ORDEN,
         T.TIPOC_ACTIVO,
         T.CPTON_ID,
         T.TIPON_IDGRUPO,
         G.TIPOV_DESC AS TIPOV_DESCGRUPO,
         CASE T.TIPOC_ACTIVO 
              WHEN '1' THEN 'ACTIVO'
              WHEN '0' THEN 'INACTIVO'
              ELSE '' END AS NOMBREACTIVO
  FROM FIDELIDAD.SFYRT_TIPOS T
  INNER JOIN FIDELIDAD.SFYRT_CONCEPTOS C ON T.CPTON_ID = C.CPTON_ID
  LEFT JOIN FIDELIDAD.SFYRT_TIPOS G ON T.TIPON_IDGRUPO = G.TIPON_ID
  WHERE T.CPTON_ID = NVL(K_ID_CONCEPTOS,T.CPTON_ID)
        AND COALESCE(T.TIPON_IDGRUPO,-1) = COALESCE(K_ID_TIPOSGRUPO,T.TIPON_IDGRUPO,-1)
        AND T.TIPOV_DESC LIKE '%' || K_DESC || '%'
        AND T.TIPOC_ACTIVO = NVL(K_ACTIVO,T.TIPOC_ACTIVO)
  ORDER BY T.TIPON_ID, CASE WHEN C.CPTOC_ORDDESC = '1' THEN T.TIPOV_DESC ELSE CAST(T.TIPON_ORDEN AS VARCHAR2(12)) END;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSS_LISTIPOS;

--****************************************************************
-- Nombre SP           :  SFYRSS_LISPARAMSIST
-- Propósito           :  Permite consultar el valor del parámetro
-- Input               :  K_DESC
--                        K_VALOR
-- Output              :  K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  25/04/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSS_LISPARAMSIST(K_DESC IN VARCHAR2,
                              K_VALOR OUT VARCHAR2,
                              K_CODERROR OUT NUMBER,
                              K_DESCERROR OUT VARCHAR2) IS

V_DESC VARCHAR2(50) := UPPER(K_DESC);
EX_ERROR EXCEPTION;
BEGIN
 
  CASE WHEN K_DESC IS NULL THEN RAISE EX_ERROR;
  ELSE
   K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  SELECT PRMSV_VALOR INTO K_VALOR 
  FROM FIDELIDAD.SFYRT_PARAMSIST
  WHERE UPPER(PRMSV_DESC) = V_DESC;

EXCEPTION
  WHEN EX_ERROR THEN
    K_CODERROR := -1;
    K_DESCERROR := 'Ingrese la descripción';
  WHEN NO_DATA_FOUND THEN
    K_CODERROR := -1;
    K_DESCERROR := 'No está registrado el parámetro ' || K_DESC;
  WHEN TOO_MANY_ROWS THEN
    K_CODERROR := -1;
    K_DESCERROR := 'Existen varios registros del parámetro ' || K_DESC;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END SFYRSS_LISPARAMSIST;

--****************************************************************
-- Nombre SP           :  SFYRSS_GETTIPOS
-- Propósito           :  Permite consultar los datos del tipo
-- Input               :  K_ID
--                     :  K_DESC
--                     :  K_ABREV
--                        K_VALOR
-- Output              :  K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  08/05/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSS_GETTIPOS(K_ID IN NUMBER,
                          K_DESC OUT VARCHAR2,
                          K_ABREV OUT VARCHAR2,
                          K_VALOR OUT VARCHAR2,
                          K_CODERROR OUT NUMBER,
                          K_DESCERROR OUT VARCHAR2) IS

EX_ERROR EXCEPTION;
BEGIN
 
  CASE WHEN K_ID IS NULL THEN RAISE EX_ERROR;
  ELSE
   K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  SELECT TIPOV_DESC, TIPOV_ABREV, TIPOV_VALOR 
  INTO K_DESC, K_ABREV, K_VALOR 
  FROM FIDELIDAD.SFYRT_TIPOS
  WHERE TIPON_ID = K_ID;

EXCEPTION
  WHEN EX_ERROR THEN
    K_CODERROR := -1;
    K_DESCERROR := 'Ingrese el código del tipo';
  WHEN NO_DATA_FOUND THEN
    K_CODERROR := -1;
    K_DESCERROR := 'No está registrado el tipo ' || K_DESC;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END SFYRSS_GETTIPOS;

--****************************************************************
-- Nombre Function     :  F_GETERRORES
-- Propósito           :  Devuelve la descripción del error
-- Input               :  K_ID
-- Output              :  V_VALOR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  30/04/2013
-- Fec Actualización   :
--****************************************************************

FUNCTION F_GETERRORES(K_ID IN NUMBER) RETURN VARCHAR2
IS
V_VALOR VARCHAR2(250);
EX_ERROR EXCEPTION;
BEGIN
 
  IF K_ID IS NULL THEN 
    RAISE EX_ERROR;
  END IF;

  SELECT SFYRV_DES_ERROR INTO V_VALOR 
  FROM FIDELIDAD.SFYRT_ERRORES
  WHERE SFYRN_COD_ERROR = K_ID;

  RETURN V_VALOR;
EXCEPTION
  WHEN EX_ERROR THEN
    RETURN 'Ingrese el código del error.';
  WHEN NO_DATA_FOUND THEN
    RETURN 'No está registrado el error.';
  WHEN OTHERS THEN
    RETURN SUBSTR(SQLERRM, 1, 250);
END;

--****************************************************************
-- Nombre Function     :  F_GETFECHALIMINF
-- Propósito           :  Devuelve la fecha límite inferior del día
-- Input               :  K_FECHA
-- Output              :  V_VALOR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  30/04/2013
-- Fec Actualización   :
--****************************************************************

FUNCTION F_GETFECHALIMINF(K_FECHA IN DATE) RETURN DATE
IS
V_VALOR DATE;
V_FECHA VARCHAR2(30);
BEGIN
    
  IF K_FECHA IS NULL THEN
    V_FECHA := '01/01/1900 00:00:00';
  ELSE
    V_FECHA := TO_CHAR(K_FECHA,'DD/MM/YYYY') || ' 00:00:00';
  END IF;

  V_VALOR := TO_DATE(V_FECHA,'DD/MM/YYYY HH24:MI:SS');
	RETURN V_VALOR;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;

--****************************************************************
-- Nombre Function     :  F_GETFECHALIMSUP
-- Propósito           :  Devuelve la fecha límite superior del día
-- Input               :  K_FECHA
-- Output              :  V_VALOR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  30/04/2013
-- Fec Actualización   :
--****************************************************************

FUNCTION F_GETFECHALIMSUP(K_FECHA IN DATE) RETURN DATE
IS
V_VALOR DATE;
V_FECHA VARCHAR2(30);
BEGIN

  IF K_FECHA IS NULL THEN
    V_FECHA := '01/01/2050 00:00:00';
  ELSE
    V_FECHA := TO_CHAR(K_FECHA,'DD/MM/YYYY') || ' 23:59:59';
  END IF;

  V_VALOR := TO_DATE(V_FECHA,'DD/MM/YYYY HH24:MI:SS');
	RETURN V_VALOR;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;

--****************************************************************
-- Nombre Function     :  F_GETFECHACADENA
-- Propósito           :  Convierte la fecha en formato de cadena
-- Input               :  K_FECHA
-- Output              :  V_VALOR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  12/02/2013
-- Fec Actualización   :
--****************************************************************

FUNCTION F_GETFECHACADENA(K_FECHA IN DATE) RETURN VARCHAR2 
IS 
V_VALOR VARCHAR2(10);
BEGIN

  V_VALOR := TO_CHAR(K_FECHA,'DD/MM/YYYY');
  RETURN V_VALOR;
EXCEPTION
  WHEN OTHERS THEN
    RETURN '';  
END F_GETFECHACADENA;

--****************************************************************
-- Nombre Function     :  F_GETFECHACADENA
-- Propósito           :  Convierte la fecha en formato de cadena
-- Input               :  K_FECHA
-- Output              :  V_VALOR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  27/03/2013
-- Fec Actualización   :
--****************************************************************

FUNCTION F_GETFECHAHORACADENA(K_FECHA IN DATE) RETURN VARCHAR2 
IS 
V_VALOR VARCHAR2(30);
BEGIN

  V_VALOR := TO_CHAR(K_FECHA,'DD/MM/YYYY HH:MI:SS AM');
  RETURN V_VALOR;
EXCEPTION
  WHEN OTHERS THEN
    RETURN '';  
END F_GETFECHAHORACADENA;

--****************************************************************
-- Nombre Function     :  F_GETARRAYSPLIT
-- Propósito           :  Convierte la cadena en array con 
-- Input               :  K_STRING
--                     :  K_DELIM
-- Output              :  TAB_ARRAY
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  30/04/2013
-- Fec Actualización   :
--****************************************************************

FUNCTION F_GETARRAYSPLIT(K_STRING VARCHAR2, 
                         K_DELIM VARCHAR2) RETURN TAB_ARRAY
IS
V_INDICE NUMBER := 0;
V_POSICION NUMBER := 0;
V_CADENA VARCHAR2(32767) := K_STRING;
V_ARREGLO TAB_ARRAY;
BEGIN
  
  LOOP
    V_POSICION := INSTR(V_CADENA,K_DELIM);
    IF V_POSICION > 0 THEN
      V_INDICE := V_INDICE + 1;
      V_ARREGLO(V_INDICE) := SUBSTR(V_CADENA,1,V_POSICION-1);
      V_CADENA := SUBSTR(V_CADENA,V_POSICION+LENGTH(K_DELIM));
    ELSE
      V_INDICE := V_INDICE + 1;
      V_ARREGLO(V_INDICE) := V_CADENA;      
      RETURN V_ARREGLO;
    END IF;
  END LOOP;

  RETURN V_ARREGLO;
EXCEPTION
  WHEN OTHERS THEN
    RETURN V_ARREGLO; 
END F_GETARRAYSPLIT;

--****************************************************************
-- Nombre Function     :  F_GETDIFERENCIADIAS
-- Propósito           :  Consigue la diferencia de días
-- Input               :  K_FECHAINI
--                        K_FECHAFIN
-- Output              :  V_VALOR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  27/03/2013
-- Fec Actualización   :
--****************************************************************

FUNCTION F_GETDIFERENCIADIAS(K_FECHAINI IN DATE,
                             K_FECHAFIN IN DATE) RETURN VARCHAR2 
IS 
V_VALOR INT;
BEGIN

  IF K_FECHAINI IS NULL THEN
    RETURN 0;
  END IF;
  
  IF K_FECHAFIN IS NULL THEN
     SELECT TRUNC(SYSDATE)-TRUNC(K_FECHAINI)
     INTO V_VALOR
     FROM DUAL;
  ELSE
     SELECT TRUNC(K_FECHAFIN)-TRUNC(K_FECHAINI)
     INTO V_VALOR
     FROM DUAL;
  END IF;

  RETURN V_VALOR;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;  
END F_GETDIFERENCIADIAS;


END PKG_FYR_UTILITARIO;
/
