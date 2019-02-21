CREATE OR REPLACE PACKAGE BODY FIDELIDAD.PKG_FYR_PROMOCION_TRX IS

--****************************************************************
-- Nombre SP           :  SFYRSI_INSPROMOCIONCAB
-- Propósito           :  Permite insertar la promoción
-- Input               :  K_DESC
--                        K_IDTIPO
--                        K_IDORIGEN
--                        K_IDVIGENCIA
--                        K_FECINI
--                        K_FECFIN
--                        K_USUARIO
-- Output              :  K_ID
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  11/03/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSI_INSPROMOCIONCAB(K_DESC IN VARCHAR2,
                                 K_IDTIPO IN NUMBER,
                                 K_IDORIGEN IN NUMBER,
                                 K_IDVIGENCIA IN NUMBER,
                                 K_FECINI IN DATE,
                                 K_FECFIN IN DATE,
                                 K_USUARIO IN VARCHAR2,
                                 K_ID OUT NUMBER,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2) IS
V_CONT NUMBER;
V_DESC VARCHAR2(200);
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_DESC       IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese la descripción. '; RAISE EX_ERROR;
    WHEN K_IDTIPO     IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el tipo de promoción. '; RAISE EX_ERROR;
    WHEN K_IDORIGEN   IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el origen. '; RAISE EX_ERROR;
    WHEN K_IDVIGENCIA IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese la vigencia. '; RAISE EX_ERROR;
    WHEN K_FECINI     IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese la fecha inicial de vigencia. '; RAISE EX_ERROR;
    WHEN K_FECFIN     IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese la fecha final de vigencia. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := ''; V_DESC := UPPER(K_DESC);
  END CASE;

  SELECT COUNT(1) INTO V_CONT
  FROM FIDELIDAD.SFYRT_PROMOCIONCAB
  WHERE UPPER(PROMV_DESC) = V_DESC;

  IF V_CONT > 0 THEN
    K_CODERROR := 2;
    K_DESCERROR := 'Existe una promoción con el mismo nombre.';
    RAISE EX_ERROR;
  END IF;

  SELECT NVL(FIDELIDAD.SFYRT_PROMOCIONCAB_SQ.NEXTVAL,0) INTO K_ID FROM DUAL;

  IF K_ID = 0 THEN
     K_CODERROR := 6;
     K_DESCERROR := 'No se generó un correlativo para la promoción. ';
     RAISE EX_ERROR;
  END IF;

  INSERT INTO FIDELIDAD.SFYRT_PROMOCIONCAB(
    PROMN_ID,
    PROMV_DESC,
    TIPON_IDTIPO,
    TIPON_IDORIGEN,
    TIPON_IDVIGENCIA,
    PROMD_FECINI,
    PROMD_FECFIN,
    PROMV_USUREG
  )
  VALUES(
    K_ID,
    K_DESC,
    K_IDTIPO,
    K_IDORIGEN,
    K_IDVIGENCIA,
    K_FECINI,
    K_FECFIN,
    K_USUARIO
  );

  COMMIT;
EXCEPTION
  WHEN EX_ERROR THEN
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || K_DESCERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSI_INSPROMOCIONCAB;

--****************************************************************
-- Nombre SP           :  SFYRSI_UPDPROMOCIONCAB
-- Propósito           :  Permite insertar la promoción
-- Input               :  K_DESC
--                        K_IDTIPO
--                        K_IDORIGEN
--                        K_IDVIGENCIA
--                        K_FECINI
--                        K_FECFIN
--                        K_USUARIO
-- Output              :  K_ID
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  11/03/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSU_UPDPROMOCIONCAB(K_ID IN NUMBER,
                                 K_DESC IN VARCHAR2,
                                 K_IDTIPO IN NUMBER,
                                 K_IDORIGEN IN NUMBER,
                                 K_IDVIGENCIA IN NUMBER,
                                 K_FECINI IN DATE,
                                 K_FECFIN IN DATE,
                                 K_USUARIO IN VARCHAR2,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2) IS
V_CONT NUMBER;
V_DESC VARCHAR2(200);
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_ID         IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el código de la promoción. '; RAISE EX_ERROR;
    WHEN K_DESC       IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese la descripción. '; RAISE EX_ERROR;
    WHEN K_IDTIPO     IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el tipo de promoción. '; RAISE EX_ERROR;
    WHEN K_IDORIGEN   IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el origen. '; RAISE EX_ERROR;
    WHEN K_IDVIGENCIA IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese la vigencia. '; RAISE EX_ERROR;
    WHEN K_FECINI     IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese la fecha inicial de vigencia. '; RAISE EX_ERROR;
    WHEN K_FECFIN     IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese la fecha final de vigencia. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := ''; V_DESC := UPPER(K_DESC);
  END CASE;

  SELECT COUNT(1) INTO V_CONT
  FROM FIDELIDAD.SFYRT_PROMOCIONCAB
  WHERE PROMN_ID = K_ID;

  IF V_CONT < 1 THEN
    K_CODERROR := 5;
    K_DESCERROR := 'El código de la promoción no existe. ';
    RAISE EX_ERROR;
  END IF;

  SELECT COUNT(1) INTO V_CONT
  FROM FIDELIDAD.SFYRT_PROMOCIONCAB
  WHERE UPPER(PROMV_DESC) = V_DESC
        AND PROMN_ID <> K_ID;

  IF V_CONT > 0 THEN
    K_CODERROR := 2;
    K_DESCERROR := 'Existe una promoción con el mismo nombre.';
    RAISE EX_ERROR;
  END IF;

  UPDATE FIDELIDAD.SFYRT_PROMOCIONCAB
  SET PROMV_DESC = NVL(K_DESC,PROMV_DESC),
      TIPON_IDTIPO = NVL(K_IDTIPO,TIPON_IDTIPO),
      TIPON_IDORIGEN = NVL(K_IDORIGEN,TIPON_IDORIGEN),
      TIPON_IDVIGENCIA = NVL(K_IDVIGENCIA,TIPON_IDVIGENCIA),
      PROMD_FECINI = NVL(K_FECINI,PROMD_FECINI),
      PROMD_FECFIN = NVL(K_FECFIN,PROMD_FECFIN),
      PROMV_USUMOD = K_USUARIO
  WHERE PROMN_ID = K_ID;

EXCEPTION
  WHEN EX_ERROR THEN
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || K_DESCERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSU_UPDPROMOCIONCAB;

--****************************************************************
-- Nombre SP           :  SFYRSS_LISPROMOCIONCAB
-- Propósito           :  Permite consultar las promociones
-- Input               :  K_ID
--                        K_DESC
--                        K_IDTIPO
--                        K_IDORIGEN
--                        K_IDVIGENCIA
--                        K_FECINIREG
--                        K_FECFINREG
--                        K_FECINIVIG
--                        K_FECFINVIG
--                        K_ESTADO [1]:Activo [0]:Inactivo [OtroValor]:Todos
-- Output              :  K_CUR_PROMOCION
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  08/03/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSS_LISPROMOCIONCAB(K_ID IN NUMBER,
                                 K_DESC IN VARCHAR2,
                                 K_IDTIPO IN NUMBER,
                                 K_IDORIGEN IN NUMBER,
                                 K_IDVIGENCIA IN NUMBER,
                                 K_FECINIREG IN DATE,
                                 K_FECFINREG IN DATE,
                                 K_FECINIVIG IN DATE,
                                 K_FECFINVIG IN DATE,
                                 K_ESTADO IN NUMBER,
                                 K_CUR_PROMOCION OUT SYS_REFCURSOR,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2) IS
V_FECINIREG DATE;
V_FECFINREG DATE;
V_FECINIVIG DATE;
V_FECFINVIG DATE;
V_SYSDATE DATE;
V_DESC VARCHAR2(200);
V_ESTADO NUMBER;
EX_ERROR EXCEPTION;
BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';
  V_FECINIREG := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETFECHALIMINF(K_FECINIREG);
  V_FECFINREG := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETFECHALIMSUP(K_FECFINREG);
  V_FECINIVIG := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETFECHALIMINF(K_FECINIVIG);
  V_FECFINVIG := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETFECHALIMSUP(K_FECFINVIG);
  V_SYSDATE := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETFECHALIMINF(SYSDATE);
  V_DESC := UPPER(K_DESC);
  V_ESTADO := CASE WHEN K_ESTADO NOT IN(0,1) THEN NULL ELSE K_ESTADO END;

  OPEN K_CUR_PROMOCION FOR
  SELECT P.PROMN_ID,
         P.PROMV_DESC,
         P.TIPON_IDTIPO,
         P.TIPON_IDORIGEN,
         P.TIPON_IDVIGENCIA,
         P.PROMD_FECINI,
         P.PROMD_FECFIN,
         FIDELIDAD.PKG_FYR_UTILITARIO.F_GETFECHACADENA(P.PROMD_FECINI) AS PROMD_FECINICAD,
         FIDELIDAD.PKG_FYR_UTILITARIO.F_GETFECHACADENA(P.PROMD_FECFIN) AS PROMD_FECFINCAD,
         TP.TIPOV_DESC AS NOMBRETIPO,
         OP.TIPOV_DESC AS NOMBREORIGEN,
         VG.TIPOV_DESC AS NOMBREVIGENCIA,
         CASE WHEN V_SYSDATE <= P.PROMD_FECFIN THEN 'ACTIVO' ELSE 'INACTIVO' END AS NOMBREESTADO,
         FIDELIDAD.PKG_FYR_PROMOCION_TRX.F_GETSERVPROMOETIQDESC(P.PROMN_ID,'|') AS SERVICIOS
  FROM FIDELIDAD.SFYRT_PROMOCIONCAB P
  INNER JOIN FIDELIDAD.SFYRT_TIPOS TP ON P.TIPON_IDTIPO = TP.TIPON_ID
  INNER JOIN FIDELIDAD.SFYRT_TIPOS OP ON P.TIPON_IDORIGEN = OP.TIPON_ID
  INNER JOIN FIDELIDAD.SFYRT_TIPOS VG ON P.TIPON_IDVIGENCIA = VG.TIPON_ID
  INNER JOIN (SELECT TP.PROMN_ID, CASE WHEN V_SYSDATE <= TP.PROMD_FECFIN THEN 1 ELSE 0 END AS ESTADO FROM FIDELIDAD.SFYRT_PROMOCIONCAB TP) TBLEST ON P.PROMN_ID=TBLEST.PROMN_ID
  WHERE P.PROMN_ID = NVL(K_ID,P.PROMN_ID)
        AND UPPER(P.PROMV_DESC) LIKE '%' || V_DESC || '%'
        AND P.TIPON_IDTIPO = NVL(K_IDTIPO,P.TIPON_IDTIPO)
        AND P.TIPON_IDORIGEN = NVL(K_IDORIGEN,P.TIPON_IDORIGEN)
        AND P.TIPON_IDVIGENCIA = NVL(K_IDVIGENCIA,P.TIPON_IDVIGENCIA)
        AND ((P.PROMD_FECREG >= V_FECINIREG
        AND P.PROMD_FECREG <= V_FECFINREG)
        OR (P.PROMD_FECINI >= V_FECINIVIG
        AND P.PROMD_FECFIN <= V_FECFINVIG))
        AND TBLEST.ESTADO = NVL(V_ESTADO,TBLEST.ESTADO)
  ORDER BY P.PROMN_ID;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSS_LISPROMOCIONCAB;

--****************************************************************
-- Nombre SP           :  SFYRSI_INSPROMOCIONSER
-- Propósito           :  Permite insertar el servicio
-- Input               :  K_IDPROMOCION
--                        K_ETIQUETA
--                        K_DESCRIPCION
--                        K_ESTADO
--                        K_USUARIO
-- Output              :  K_ID
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  12/03/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSI_INSPROMOCIONSER(K_IDPROMOCION IN NUMBER,
                                 K_ETIQUETA IN VARCHAR2,
                                 K_DESCRIPCION IN VARCHAR2,
                                 K_USUARIO IN VARCHAR2,
                                 K_ID OUT NUMBER,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2) IS
V_CONT NUMBER;
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_IDPROMOCION IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el código de la promoción. '; RAISE EX_ERROR;
    WHEN K_ETIQUETA    IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el código de la etiqueta. '; RAISE EX_ERROR;
    WHEN K_DESCRIPCION IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese la descripción de la etiqueta. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  SELECT COUNT(1) INTO V_CONT
  FROM FIDELIDAD.SFYRT_PROMOCIONSERVICIO
  WHERE PROSV_ETIQUETA = K_ETIQUETA
        AND PROMN_ID = K_IDPROMOCION;

  IF V_CONT > 0 THEN
    K_CODERROR := 2;
    K_DESCERROR := 'Ya existe la etiqueta.';
    RAISE EX_ERROR;
  END IF;

  SELECT NVL(FIDELIDAD.SFYRT_PROMOCIONSERVICIO_SQ.NEXTVAL,0) INTO K_ID FROM DUAL;

  IF K_ID = 0 THEN
     K_CODERROR := 6;
     K_DESCERROR := 'No se generó un correlativo para el servicio de la promoción. ';
     RAISE EX_ERROR;
  END IF;

  INSERT INTO FIDELIDAD.SFYRT_PROMOCIONSERVICIO(
    PROSN_ID,
    PROMN_ID,
    PROSV_ETIQUETA,
    PROSV_DESCRIPCION,
    PROSV_USUREG
  )
  VALUES(
    K_ID,
    K_IDPROMOCION,
    K_ETIQUETA,
    K_DESCRIPCION,
    K_USUARIO
  );

  COMMIT;
EXCEPTION
  WHEN EX_ERROR THEN
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || K_DESCERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSI_INSPROMOCIONSER;

--****************************************************************
-- Nombre SP           :  SFYRSU_UPDPROMOCIONSER
-- Propósito           :  Permite eliminar el servicio
-- Input               :  K_ID
--                        K_USUARIO
-- Output              :  K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  12/03/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSD_DELPROMOCIONSER(K_ID NUMBER,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2) IS
V_CONT NUMBER;
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_ID IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el código del servicio. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  SELECT COUNT(1) INTO V_CONT
  FROM FIDELIDAD.SFYRT_PROMOCIONSERVICIO
  WHERE PROSN_ID = K_ID;

  IF V_CONT < 1 THEN
    K_CODERROR := 5;
    K_DESCERROR := 'El código del servicio no existe. ';
    RAISE EX_ERROR;
    END IF;

  DELETE FROM FIDELIDAD.SFYRT_PROMOCIONSERVICIO
  WHERE PROSN_ID = K_ID;

EXCEPTION
  WHEN EX_ERROR THEN
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || K_DESCERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSD_DELPROMOCIONSER;

--****************************************************************
-- Nombre SP           :  SFYRSS_LISPROMOCIONSER
-- Propósito           :  Permite consultar los servicios
-- Input               :  K_ID
--                        K_IDPROMOCION
--                        K_ETIQUETA
-- Output              :  K_CUR_SERVICIO
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  13/03/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSS_LISPROMOCIONSER(K_ID IN NUMBER,
                                 K_IDPROMOCION IN NUMBER,
                                 K_ETIQUETA IN VARCHAR2,
                                 K_CUR_SERVICIO OUT SYS_REFCURSOR,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';

  OPEN K_CUR_SERVICIO FOR
  SELECT P.PROSN_ID,
         P.PROMN_ID,
         P.PROSV_ETIQUETA,
         P.PROSV_DESCRIPCION
  FROM FIDELIDAD.SFYRT_PROMOCIONSERVICIO P
  WHERE P.PROSN_ID = NVL(K_ID,P.PROSN_ID)
        AND P.PROMN_ID = NVL(K_IDPROMOCION,P.PROMN_ID)
        AND P.PROSV_ETIQUETA = NVL(K_ETIQUETA,P.PROSV_ETIQUETA)
  ORDER BY P.PROSN_ID;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSS_LISPROMOCIONSER;

--****************************************************************
-- Nombre SP           :  SFYRSI_INSPROMOCIONCAB
-- Propósito           :  Permite insertar la promoción
-- Input               :  K_TIPO
--                        K_DESC
--                        K_FECINI
--                        K_FECFIN
--                        K_IDPROMOCION
--                        K_IDTIPO
--                        K_IDORIGEN
--                        K_IDVIGENCIA
--                        K_USUARIO
-- Output              :  K_ID
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  26/03/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSI_INSAUDPROMOCIONCAB(K_PROCESO IN CHAR,
                                    K_DESC IN VARCHAR2,
                                    K_FECINI IN DATE,
                                    K_FECFIN IN DATE,
                                    K_IDPROMOCION IN NUMBER,
                                    K_IDTIPO IN NUMBER,
                                    K_IDORIGEN IN NUMBER,
                                    K_IDVIGENCIA IN NUMBER,
                                    K_USUARIO IN VARCHAR2,
                                    K_ID OUT NUMBER,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_PROCESO     IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el proceso. '; RAISE EX_ERROR;
    WHEN K_DESC        IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese la descripción. '; RAISE EX_ERROR;
    WHEN K_FECINI      IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese la fecha inicial de vigencia. '; RAISE EX_ERROR;
    WHEN K_FECFIN      IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese la fecha final de vigencia. '; RAISE EX_ERROR;
    WHEN K_IDPROMOCION IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el código de la promoción. '; RAISE EX_ERROR;
    WHEN K_IDTIPO      IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el tipo de promoción. '; RAISE EX_ERROR;
    WHEN K_IDORIGEN    IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el origen. '; RAISE EX_ERROR;
    WHEN K_IDVIGENCIA  IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese la vigencia. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  SELECT NVL(FIDELIDAD.SFYRT_AUDPROMOCIONCAB_SQ.NEXTVAL,0) INTO K_ID FROM DUAL;

  IF K_ID = 0 THEN
     K_CODERROR := 6;
     K_DESCERROR := 'No se generó un correlativo para la auditoría de la promoción. ';
     RAISE EX_ERROR;
  END IF;

  INSERT INTO FIDELIDAD.SFYRT_AUDPROMOCIONCAB(
    ADPCN_ID,
    ADPCC_PROCESO,
    ADPCV_DESC,
    ADPCD_FECINI,
    ADPCD_FECFIN,
    PROMN_ID,
    TIPON_IDTIPO,
    TIPON_IDORIGEN,
    TIPON_IDVIGENCIA,
    ADPCV_USUREG,
    ADPCD_FECREG
  )
  VALUES(
    K_ID,
    K_PROCESO,
    K_DESC,
    K_FECINI,
    K_FECFIN,
    K_IDPROMOCION,
    K_IDTIPO,
    K_IDORIGEN,
    K_IDVIGENCIA,
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
END SFYRSI_INSAUDPROMOCIONCAB;

--****************************************************************
-- Nombre SP           :  SFYRSI_INSPROMOCIONSER
-- Propósito           :  Permite insertar el servicio
-- Input               :  K_ETIQUETA
--                        K_DESCRIPCION
--                        K_IDAUDPROMOCION
--                        K_IDPROMOCION
--                        K_USUARIO
-- Output              :  K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  26/03/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSI_INSAUDPROMOCIONSER(K_PROCESO IN CHAR,
                                    K_ETIQUETA IN VARCHAR2,
                                    K_DESCRIPCION IN VARCHAR2,
                                    K_IDAUDPROMOCION IN NUMBER,
                                    K_IDPROMOCIONSER IN NUMBER,
                                    K_USUARIO IN VARCHAR2,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2) IS
V_ID NUMBER;
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_PROCESO        IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el proceso. '; RAISE EX_ERROR;
    WHEN K_ETIQUETA       IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el código de la etiqueta. '; RAISE EX_ERROR;
    WHEN K_DESCRIPCION    IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese la descripción de la etiqueta. '; RAISE EX_ERROR;
    WHEN K_IDAUDPROMOCION IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el código de la auditoría de la promoción. '; RAISE EX_ERROR;
    WHEN K_IDPROMOCIONSER IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el código del servicio de la promoción. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  SELECT NVL(FIDELIDAD.SFYRT_AUDPROMOCIONSERVICIO_SQ.NEXTVAL,0) INTO V_ID FROM DUAL;

  IF V_ID = 0 THEN
     K_CODERROR := 6;
     K_DESCERROR := 'No se generó un correlativo para el servicio de la promoción. ';
     RAISE EX_ERROR;
  END IF;

  INSERT INTO FIDELIDAD.SFYRT_AUDPROMOCIONSERVICIO(
    ADPSN_ID,
    ADPSC_PROCESO,
    ADPSV_ETIQUETA,
    ADPSV_DESCRIPCION,
    ADPCN_ID,
    PROSN_ID,
    ADPSV_USUREG,
    ADPSD_FECREG
  )
  VALUES(
    V_ID,
    K_PROCESO,
    K_ETIQUETA,
    K_DESCRIPCION,
    K_IDAUDPROMOCION,
    K_IDPROMOCIONSER,
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
END SFYRSI_INSAUDPROMOCIONSER;

--****************************************************************
-- Nombre SP           :  SFYRSS_LISPROMOCIONCAB
-- Propósito           :  Permite consultar la auditoría de promociones
-- Input               :  K_ID
--                        K_IDPROMOCION
-- Output              :  K_CUR_AUDPROMOCION
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  27/03/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSS_LISAUDPROMOCIONCAB(K_ID IN NUMBER,
                                    K_IDPROMOCION IN NUMBER,
                                    K_CUR_AUDPROMOCION OUT SYS_REFCURSOR,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';

  OPEN K_CUR_AUDPROMOCION FOR
  SELECT P.ADPCN_ID,
         P.ADPCC_PROCESO,
         CASE P.ADPCC_PROCESO
           WHEN 'I' THEN 'INSERCION'
           WHEN 'A' THEN 'ACTUALIZACION'
           ELSE ''
         END AS NOMBREPROCESO,
         P.ADPCV_DESC,
         P.PROMN_ID,
         P.TIPON_IDTIPO,
         P.TIPON_IDORIGEN,
         P.TIPON_IDVIGENCIA,
         P.ADPCD_FECINI,
         P.ADPCD_FECFIN,
         FIDELIDAD.PKG_FYR_UTILITARIO.F_GETFECHACADENA(P.ADPCD_FECINI) AS ADPCD_FECINICAD,
         FIDELIDAD.PKG_FYR_UTILITARIO.F_GETFECHACADENA(P.ADPCD_FECFIN) AS ADPCD_FECFINCAD,
         TP.TIPOV_DESC AS NOMBRETIPO,
         OG.TIPOV_DESC AS NOMBREORIGEN,
         VG.TIPOV_DESC AS NOMBREVIGENCIA,
         P.ADPCV_USUREG,
         TO_CHAR(P.ADPCD_FECREG,'DD/MM/YYYY'),
         FIDELIDAD.PKG_FYR_UTILITARIO.F_GETFECHAHORACADENA(P.ADPCD_FECREG) AS ADPCD_FECREGCAD
  FROM FIDELIDAD.SFYRT_AUDPROMOCIONCAB P
  INNER JOIN FIDELIDAD.SFYRT_TIPOS TP ON P.TIPON_IDTIPO = TP.TIPON_ID
  INNER JOIN FIDELIDAD.SFYRT_TIPOS OG ON P.TIPON_IDORIGEN = OG.TIPON_ID
  INNER JOIN FIDELIDAD.SFYRT_TIPOS VG ON P.TIPON_IDVIGENCIA = VG.TIPON_ID
  WHERE P.ADPCN_ID = NVL(K_ID,P.ADPCN_ID)
        AND P.PROMN_ID = NVL(K_IDPROMOCION,P.PROMN_ID)
  ORDER BY P.PROMN_ID,P.ADPCD_FECREG;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSS_LISAUDPROMOCIONCAB;

--****************************************************************
-- Nombre SP           :  SFYRSS_LISPROMOCIONSER
-- Propósito           :  Permite consultar la auditoría de servicios
-- Input               :  K_ID
--                        K_IDPROMOCION
--                        K_ETIQUETA
-- Output              :  K_CUR_AUDSERVICIO
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  27/03/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSS_LISAUDPROMOCIONSER(K_ID IN NUMBER,
                                    K_IDAUDPROMOCION IN NUMBER,
                                    K_CUR_AUDSERVICIO OUT SYS_REFCURSOR,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';

  OPEN K_CUR_AUDSERVICIO FOR
  SELECT P.ADPSN_ID,
         P.ADPSC_PROCESO,
         CASE P.ADPSC_PROCESO
           WHEN 'I' THEN 'INSERCION'
           WHEN 'A' THEN 'ACTUALIZACION'
           WHEN 'C' THEN 'CONSULTA'
           ELSE ''
         END AS NOMBREPROCESO,
         P.ADPSV_ETIQUETA,
         P.ADPSV_DESCRIPCION,
         P.ADPCN_ID,
         P.ADPSV_USUREG,
         P.ADPSD_FECREG,
         FIDELIDAD.PKG_FYR_UTILITARIO.F_GETFECHAHORACADENA(P.ADPSD_FECREG) AS ADPSD_FECREGCAD
  FROM FIDELIDAD.SFYRT_AUDPROMOCIONSERVICIO P
  WHERE P.PROSN_ID = NVL(K_ID,P.PROSN_ID)
        AND P.ADPCN_ID = NVL(K_IDAUDPROMOCION,P.ADPCN_ID)
  ORDER BY P.ADPCN_ID,P.ADPSD_FECREG;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSS_LISAUDPROMOCIONSER;

--****************************************************************
-- Nombre SP           :  SFYRSI_INSPROGPROMLOTE
-- Propósito           :  Permite insertar la programación de promoción
-- Input               :  K_DESC
--                        K_NOMBREARCH
--                        K_IDPROMOCION
--                        K_IDORIGEN
--                        K_IDESTADO
--                        K_USUARIO
-- Output              :  K_ID
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  01/04/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSI_INSPROGPROMLOTE(K_DESC IN VARCHAR2,
                                 K_NOMBREARCH IN VARCHAR2,
                                 K_IDPROMOCION IN NUMBER,
                                 K_IDORIGEN IN NUMBER,
                                 K_IDESTADO IN NUMBER,
                                 K_USUARIO IN VARCHAR2,
                                 K_ID OUT NUMBER,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2) IS
V_CONT NUMBER;
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_DESC        IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese la descripción. '; RAISE EX_ERROR;
    WHEN K_NOMBREARCH  IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el nombre del archivo. '; RAISE EX_ERROR;
    WHEN K_IDPROMOCION IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese la promoción. '; RAISE EX_ERROR;
    WHEN K_IDORIGEN    IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el origen. '; RAISE EX_ERROR;
    WHEN K_IDESTADO    IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el estado. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  SELECT COUNT(1) INTO V_CONT
  FROM FIDELIDAD.SFYRT_PROMOCIONCAB
  WHERE PROMN_ID = K_IDPROMOCION;

  IF V_CONT < 1 THEN
    K_CODERROR := 5;
    K_DESCERROR := 'El código de la promoción no existe. ';
    RAISE EX_ERROR;
  END IF;

  SELECT NVL(FIDELIDAD.SFYRT_PROGPROMLOTE_SQ.NEXTVAL,0) INTO K_ID FROM DUAL;

  IF K_ID = 0 THEN
     K_CODERROR := 6;
     K_DESCERROR := 'No se generó un correlativo para la promoción. ';
     RAISE EX_ERROR;
  END IF;

  INSERT INTO FIDELIDAD.SFYRT_PROGPROMLOTE(
    PPLTN_ID,
    PPLTV_DESC,
    PPLTV_NOMBREARCH,
    PROMN_ID,
    TIPON_IDORIGEN,
    TIPON_IDESTADO,
    PPLTV_USUREG
  )
  VALUES(
    K_ID,
    K_DESC,
    K_NOMBREARCH,
    K_IDPROMOCION,
    K_IDORIGEN,
    K_IDESTADO,
    K_USUARIO
  );

EXCEPTION
  WHEN EX_ERROR THEN
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || K_DESCERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSI_INSPROGPROMLOTE;

--****************************************************************
-- Nombre SP           :  SFYRSU_UPDPROGPROMLOTE
-- Propósito           :  Permite actualizar el lote
-- Input               :  K_ID
--                        K_DESC
--                        K_IDPROMOCION
--                        K_IDORIGEN
--                        K_IDESTADO
--                        K_USUARIO
-- Output              :  K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  22/04/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSU_UPDPROGPROMLOTE(K_ID IN NUMBER,
                                 K_DESC IN VARCHAR2,
                                 K_IDPROMOCION IN NUMBER,
                                 K_IDORIGEN IN NUMBER,
                                 K_IDESTADO IN NUMBER,
                                 K_USUARIO IN VARCHAR2,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2) IS
V_CONT NUMBER;
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_ID          IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el código del lote. '; RAISE EX_ERROR;
    WHEN K_IDPROMOCION IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el código de la promoción. '; RAISE EX_ERROR;
    WHEN K_IDORIGEN    IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el origen de la promoción. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  SELECT COUNT(1) INTO V_CONT
  FROM FIDELIDAD.SFYRT_PROGPROMLOTE
  WHERE PPLTN_ID = K_ID;

  IF V_CONT < 1 THEN
    K_CODERROR := 5;
    K_DESCERROR := 'El código del lote no existe. ';
    RAISE EX_ERROR;
  END IF;

  SELECT COUNT(1) INTO V_CONT
  FROM FIDELIDAD.SFYRT_PROMOCIONCAB
  WHERE PROMN_ID = K_IDPROMOCION;

  IF V_CONT < 1 THEN
    K_CODERROR := 2;
    K_DESCERROR := 'El código de la promoción no existe. ';
    RAISE EX_ERROR;
  END IF;

  UPDATE FIDELIDAD.SFYRT_PROGPROMLOTE
  SET PPLTV_DESC = NVL(K_DESC,PPLTV_DESC),
      PROMN_ID = K_IDPROMOCION,
      TIPON_IDORIGEN = K_IDORIGEN,
      TIPON_IDESTADO = NVL(K_IDESTADO,TIPON_IDESTADO),
      PPLTV_USUMOD = NVL(K_USUARIO,PPLTV_USUMOD)
  WHERE PPLTN_ID = K_ID;

EXCEPTION
  WHEN EX_ERROR THEN
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || K_DESCERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSU_UPDPROGPROMLOTE;

--****************************************************************
-- Nombre SP           :  SFYRSS_LISPROGPROMLOTE
-- Propósito           :  Permite consultar las asignaciones
-- Input               :  K_ID
--                        K_DESC
--                        K_IDORIGEN
--                        K_IDESTADO
--                        K_FECINIREG
--                        K_FECFINREG
-- Output              :  K_CUR_PROGPROMLOTE
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  08/03/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSS_LISPROGPROMLOTE(K_ID IN NUMBER,
                                 K_DESC IN VARCHAR2,
                                 K_IDORIGEN IN NUMBER,
                                 K_IDESTADO IN NUMBER,
                                 K_FECINIREG IN DATE,
                                 K_FECFINREG IN DATE,
                                 K_CUR_PROGPROMLOTE OUT SYS_REFCURSOR,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2) IS
V_FECINIREG DATE;
V_FECFINREG DATE;
V_DESC VARCHAR2(200);
V_PARAMETRO VARCHAR2(50);
V_GRUPESTAPEND NUMBER;
V_GRUPESTAVALI NUMBER;
V_GRUPESTANOVA NUMBER;
V_CODERROR NUMBER;
V_DESCERROR VARCHAR2(200);
EX_ERROR EXCEPTION;
BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';
  V_FECINIREG := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETFECHALIMINF(K_FECINIREG);
  V_FECFINREG := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETFECHALIMSUP(K_FECFINREG);
  V_DESC := UPPER(K_DESC);

  PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('GRUPO_REGISTRO_PENDIENTE_LOTE_HFC',V_PARAMETRO,V_CODERROR,V_DESCERROR);
  IF V_CODERROR <> 0 THEN
    V_GRUPESTAPEND := -1;
  ELSE
    V_GRUPESTAPEND := TO_NUMBER(V_PARAMETRO);
  END IF;

  PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('GRUPO_REGISTRO_VALIDO_LOTE_HFC',V_PARAMETRO,V_CODERROR,V_DESCERROR);
  IF V_CODERROR <> 0 THEN
    V_GRUPESTAVALI := -1;
  ELSE
    V_GRUPESTAVALI := TO_NUMBER(V_PARAMETRO);
  END IF;

  PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('GRUPO_REGISTRO_INVALIDO_LOTE_HFC',V_PARAMETRO,V_CODERROR,V_DESCERROR);
  IF V_CODERROR <> 0 THEN
    V_GRUPESTANOVA := -1;
  ELSE
   V_GRUPESTANOVA := TO_NUMBER(V_PARAMETRO);
  END IF;

  OPEN K_CUR_PROGPROMLOTE FOR
  SELECT P.PPLTN_ID,
         P.PPLTV_DESC,
         P.PPLTV_NOMBREARCH,
         P.PPLTD_FECTRX,
         P.PROMN_ID,
         P.TIPON_IDORIGEN,
         P.TIPON_IDESTADO,
         P.PPLTD_FECREG,
         FIDELIDAD.PKG_FYR_UTILITARIO.F_GETFECHACADENA(P.PPLTD_FECREG) AS PPLTD_FECREGCAD,
         C.PROMV_DESC,
         C.TIPON_IDTIPO,
         C.TIPON_IDVIGENCIA,
         C.PROMD_FECINI,
         C.PROMD_FECFIN,
         OG.TIPOV_DESC AS TIPOV_DESCORIGEN,
         ET.TIPOV_DESC AS TIPOV_DESCESTADO,
         F_GETTOTALREGISTROXTIPO(P.PPLTN_ID,NULL) AS TOTAL_REGISTROS,
         F_GETTOTALREGISTROXTIPO(P.PPLTN_ID,V_GRUPESTAPEND) AS REGISTROS_PENDIENTES,
         F_GETTOTALREGISTROXTIPO(P.PPLTN_ID,V_GRUPESTAVALI) AS REGISTROS_VALIDOS,
         F_GETTOTALREGISTROXTIPO(P.PPLTN_ID,V_GRUPESTANOVA) AS REGISTROS_INVALIDOS
  FROM FIDELIDAD.SFYRT_PROGPROMLOTE P
  INNER JOIN FIDELIDAD.SFYRT_PROMOCIONCAB C ON P.PROMN_ID = C.PROMN_ID
  INNER JOIN FIDELIDAD.SFYRT_TIPOS OG ON P.TIPON_IDORIGEN = OG.TIPON_ID
  INNER JOIN FIDELIDAD.SFYRT_TIPOS ET ON P.TIPON_IDESTADO = ET.TIPON_ID
  WHERE P.PPLTN_ID = NVL(K_ID,P.PPLTN_ID)
        AND UPPER(P.PPLTV_DESC) LIKE '%' || V_DESC || '%'
        AND P.TIPON_IDORIGEN = NVL(K_IDORIGEN,P.TIPON_IDORIGEN)
        AND P.TIPON_IDESTADO = NVL(K_IDESTADO,P.TIPON_IDESTADO)
        AND P.PPLTD_FECREG >= V_FECINIREG
        AND P.PPLTD_FECREG <= V_FECFINREG
  ORDER BY P.PPLTN_ID;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSS_LISPROGPROMLOTE;

--****************************************************************
-- Nombre SP           :  SFYRSI_INSPROGPROMCLIENTE
-- Propósito           :  Permite insertar el cliente del lote
-- Input               :  K_SID
--                        K_CODCLI
--                        K_NOMCLI
--                        K_IDLOTE
--                        K_IDESTADO
--                        K_USUARIO
-- Output              :  K_ID
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  25/04/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSI_INSPROGPROMCLIENTE(K_SID IN VARCHAR2,
                                    K_CODCLI IN VARCHAR2,
                                    K_NOMCLI IN VARCHAR2,
                                    K_TIPOSERV IN VARCHAR2,
                                    K_ESTASERV IN VARCHAR2,
                                    K_OBSERVALTA IN VARCHAR2,
                                    K_IDLOTE IN NUMBER,
                                    K_IDESTADO IN NUMBER,
                                    K_USUARIO IN VARCHAR2,
                                    K_ID OUT NUMBER,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_SID      IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el SID del cliente. '; RAISE EX_ERROR;
    WHEN K_IDLOTE   IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el código de la programación. '; RAISE EX_ERROR;
    WHEN K_IDESTADO IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el estado. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  SELECT NVL(FIDELIDAD.SFYRT_PROGPROMCLIENTE_SQ.NEXTVAL,0) INTO K_ID FROM DUAL;

  IF K_ID = 0 THEN
     K_CODERROR := 6;
     K_DESCERROR := 'No se generó un correlativo para el cliente. ';
     RAISE EX_ERROR;
  END IF;

  INSERT INTO FIDELIDAD.SFYRT_PROGPROMCLIENTE(
    PPCLN_ID,
    PPCLV_SID,
    PPCLV_CODCLI,
    PPCLV_NOMCLI,
    PPCLV_TIPOSERV,
    PPCLV_ESTADOSERV,
    PPCLV_OBSERVALTA,
    PPLTN_ID,
    TIPON_IDESTADO,
    PPCLV_USUREG
  )
  VALUES(
    K_ID,
    K_SID,
    K_CODCLI,
    K_NOMCLI,
    K_TIPOSERV,
    K_ESTASERV,
    K_OBSERVALTA,
    K_IDLOTE,
    K_IDESTADO,
    K_USUARIO
  );

EXCEPTION
  WHEN EX_ERROR THEN
    K_DESCERROR := PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || K_DESCERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSI_INSPROGPROMCLIENTE;

--****************************************************************
-- Nombre SP           :  SFYRSU_UPDPROGPROMCLIENTE
-- Propósito           :  Permite actualizar el cliente del lote
-- Input               :  K_ID
--                        K_IDESTADO
--                        K_USUARIO
-- Output              :  K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  25/04/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSU_UPDPROGPROMCLIENTE(K_ID IN NUMBER,
                                    K_IDESTADO IN NUMBER,
                                    K_USUARIO IN VARCHAR2,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2) IS
V_CONT NUMBER;
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_ID       IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el código del detalle. '; RAISE EX_ERROR;
    WHEN K_IDESTADO IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el estado. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  SELECT COUNT(1) INTO V_CONT
  FROM FIDELIDAD.SFYRT_PROGPROMCLIENTE
  WHERE PPCLN_ID = K_ID;

  IF V_CONT < 1 THEN
    K_CODERROR := 5;
    K_DESCERROR := 'El código del detalle no existe. ';
    RAISE EX_ERROR;
  END IF;

  UPDATE FIDELIDAD.SFYRT_PROGPROMCLIENTE
  SET TIPON_IDESTADO = K_IDESTADO,
      PPCLV_USUMOD = K_USUARIO
  WHERE PPCLN_ID = K_ID;

EXCEPTION
  WHEN EX_ERROR THEN
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || K_DESCERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSU_UPDPROGPROMCLIENTE;

--****************************************************************
-- Nombre SP           :  SFYRSS_LISPROGPROMCLIENTE
-- Propósito           :  Permite consultar las asignaciones
-- Input               :  K_ID
--                        K_SID
--                        K_IDLOTE
--                        K_IDESTADO
--                        K_IDESTADOGRUPO
-- Output              :  K_CUR_PROGPROMCLIENTE
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  25/04/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSS_LISPROGPROMCLIENTE(K_ID IN NUMBER,
                                    K_SID IN VARCHAR2,
                                    K_IDPROGPROMLOTE IN NUMBER,
                                    K_IDESTADO IN NUMBER,
                                    K_IDESTADOGRUPO IN NUMBER,
                                    K_CUR_PROGPROMCLIENTE OUT SYS_REFCURSOR,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';

  OPEN K_CUR_PROGPROMCLIENTE FOR
  SELECT P.PPCLN_ID,
         P.PPCLV_SID,
         P.PPCLV_CODCLI,
         P.PPCLV_NOMCLI,
         P.PPCLD_FECTRX,
         P.PPCLN_IDSOTALTA,
         P.PPCLD_FECSOTALTAGEN,
         P.PPCLD_FECSOTALTA,
         P.PPCLV_OBSERVALTA,
         P.PPCLN_IDSOTBAJA,
         P.PPCLD_FECSOTBAJAGEN,
         P.PPCLD_FECSOTBAJAPROG,
         P.PPCLD_FECSOTBAJA,
         P.PPCLV_OBSERVBAJA,
         P.PPCLN_REINTENTOS,
         P.PPCLV_ESTADOSERV,
         P.PPCLV_TIPOSERV,
         P.PPLTN_ID,
         P.TIPON_IDESTADO,
         ET.TIPOV_DESC AS TIPOV_DESCESTADO,
         PKG_FYR_UTILITARIO.F_GETDIFERENCIADIAS(P.PPCLD_FECSOTALTA,P.PPCLD_FECSOTBAJA) AS DIAS
  FROM FIDELIDAD.SFYRT_PROGPROMCLIENTE P
  INNER JOIN FIDELIDAD.SFYRT_TIPOS ET ON P.TIPON_IDESTADO = ET.TIPON_ID
                               AND ET.TIPON_ID = NVL(K_IDESTADO,ET.TIPON_ID)
                               AND NVL(ET.TIPON_IDGRUPO,-1) = COALESCE(K_IDESTADOGRUPO,ET.TIPON_IDGRUPO,-1)
  WHERE P.PPCLN_ID = NVL(K_ID,P.PPCLN_ID)
        AND P.PPCLV_SID = NVL(K_SID,P.PPCLV_SID)
        AND P.PPLTN_ID = NVL(K_IDPROGPROMLOTE,P.PPLTN_ID)
  ORDER BY P.PPLTN_ID, P.PPCLV_SID;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSS_LISPROGPROMCLIENTE;

--****************************************************************
-- Nombre SP           :  SFYRSS_LISPROGPROMCLIXGRUPO
-- Propósito           :  Permite consultar los clientes por grupo
-- Input               :  K_ID
--                        K_SID
--                        K_IDLOTE
--                        K_IDESTADO
--                        K_IDESTADOGRUPO
-- Output              :  K_CUR_PROGPROMCLIENTE
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  25/04/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSS_LISPROGPROMCLIXGRUPO(K_IDPROGPROMLOTE IN NUMBER,
                                      K_CUR_PROGPROMCLIENTE OUT SYS_REFCURSOR,
                                      K_CODERROR OUT NUMBER,
                                      K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';

  OPEN K_CUR_PROGPROMCLIENTE FOR
  SELECT P.PPLTN_ID,
         -1 AS TIPON_IDGRUPO,
         'TOTAL REGISTROS' AS TIPOV_DESC,
         COUNT(P.PPCLN_ID) AS TOTAL
  FROM FIDELIDAD.SFYRT_PROGPROMCLIENTE P
  WHERE P.PPLTN_ID = K_IDPROGPROMLOTE
  GROUP BY P.PPLTN_ID
  UNION ALL
  SELECT P.PPLTN_ID,
         ET.TIPON_IDGRUPO,
         GE.TIPOV_DESC,
         COUNT(P.PPCLN_ID) AS TOTAL
  FROM FIDELIDAD.SFYRT_PROGPROMCLIENTE P
  INNER JOIN FIDELIDAD.SFYRT_TIPOS ET ON P.TIPON_IDESTADO = ET.TIPON_ID
  INNER JOIN FIDELIDAD.SFYRT_TIPOS GE ON ET.TIPON_IDGRUPO = GE.TIPON_ID
  WHERE P.PPLTN_ID = K_IDPROGPROMLOTE
  GROUP BY P.PPLTN_ID,ET.TIPON_IDGRUPO,GE.TIPOV_DESC
  ORDER BY TIPON_IDGRUPO;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSS_LISPROGPROMCLIXGRUPO;

--****************************************************************
-- Nombre SP           :  SFYRSI_INSAUDPROGPROMLOTE
-- Propósito           :  Permite insertar la auditoría del lote
-- Input               :  K_PROCESO
--                        K_DESC
--                        K_NOMBREARCH
--                        K_IDPROGPROMLOTE
--                        K_IDPROMOCION
--                        K_IDORIGEN
--                        K_IDESTADO
--                        K_USUARIO
-- Output              :  K_ID
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  01/04/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSI_INSAUDPROGPROMLOTE(K_PROCESO IN CHAR,
                                    K_DESC IN VARCHAR2,
                                    K_NOMBREARCH IN VARCHAR2,
                                    K_REGVALIDO IN NUMBER,
                                    K_REGERROR IN NUMBER,
                                    K_REGTOTAL IN NUMBER,
                                    K_IDPROGPROMLOTE IN NUMBER,
                                    K_IDPROMOCION IN NUMBER,
                                    K_IDORIGEN IN NUMBER,
                                    K_IDESTADO IN NUMBER,
                                    K_USUARIO IN VARCHAR2,
                                    K_ID OUT NUMBER,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_PROCESO        IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el proceso. '; RAISE EX_ERROR;
    WHEN K_DESC           IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese la descripción. '; RAISE EX_ERROR;
    WHEN K_NOMBREARCH     IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el nombre del archivo. '; RAISE EX_ERROR;
    WHEN K_REGVALIDO      IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el total de registros válidos. '; RAISE EX_ERROR;
    WHEN K_REGERROR       IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el total de registros errados. '; RAISE EX_ERROR;
    WHEN K_REGTOTAL       IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el total de registros. '; RAISE EX_ERROR;
    WHEN K_IDPROGPROMLOTE IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el lote. '; RAISE EX_ERROR;
    WHEN K_IDPROMOCION    IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese la promoción. '; RAISE EX_ERROR;
    WHEN K_IDORIGEN       IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el origen. '; RAISE EX_ERROR;
    WHEN K_IDESTADO       IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el estado. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  SELECT NVL(FIDELIDAD.SFYRT_AUDPROGPROMLOTE_SQ.NEXTVAL,0) INTO K_ID FROM DUAL;

  IF K_ID = 0 THEN
     K_CODERROR := 6;
     K_DESCERROR := 'No se generó un correlativo para la auditoría del lote. ';
     RAISE EX_ERROR;
  END IF;

  INSERT INTO FIDELIDAD.SFYRT_AUDPROGPROMLOTE(
    ADPLN_ID,
    ADPLC_PROCESO,
    ADPLV_DESC,
    ADPLV_NOMBREARCH,
    ADPLN_REGVALIDO,
    ADPLN_REGERROR,
    ADPLN_REGTOTAL,
    PPLTN_ID,
    PROMN_ID,
    TIPON_IDORIGEN,
    TIPON_IDESTADO,
    ADPLV_USUREG,
    ADPLD_FECREG
  )
  VALUES(
    K_ID,
    K_PROCESO,
    K_DESC,
    K_NOMBREARCH,
    K_REGVALIDO,
    K_REGERROR,
    K_REGTOTAL,
    K_IDPROGPROMLOTE,
    K_IDPROMOCION,
    K_IDORIGEN,
    K_IDESTADO,
    K_USUARIO,
    SYSDATE
  );

EXCEPTION
  WHEN EX_ERROR THEN
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || K_DESCERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSI_INSAUDPROGPROMLOTE;

--****************************************************************
-- Nombre SP           :  SFYRSS_LISAUDPROGPROMLOTE
-- Propósito           :  Permite consultar la auditoría de lotes
-- Input               :  K_ID
--                        K_IDPROGPROMLOTE
-- Output              :  K_CUR_AUDPROGPROMLOTE
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  27/03/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRSS_LISAUDPROGPROMLOTE(K_ID IN NUMBER,
                                    K_IDPROGPROMLOTE IN NUMBER,
                                    K_CUR_AUDPROGPROMLOTE OUT SYS_REFCURSOR,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
BEGIN

  K_CODERROR := 0;
  K_DESCERROR := '';

  OPEN K_CUR_AUDPROGPROMLOTE FOR
  SELECT P.ADPLN_ID,
         P.ADPLC_PROCESO,
         CASE P.ADPLC_PROCESO
           WHEN 'I' THEN 'INSERCION'
           WHEN 'A' THEN 'ACTUALIZACION'
           ELSE ''
         END AS NOMBREPROCESO,
         P.ADPLV_DESC,
         P.ADPLV_NOMBREARCH,
         P.ADPLN_REGVALIDO,
         P.ADPLN_REGERROR,
         P.ADPLN_REGTOTAL,
         P.PPLTN_ID,
         P.PROMN_ID,
         P.TIPON_IDORIGEN,
         P.TIPON_IDESTADO,
         OG.TIPOV_DESC AS NOMBREORIGEN,
         ET.TIPOV_DESC AS NOMBREESTADO,
         P.ADPLV_USUREG,
         P.ADPLD_FECREG,
         PKG_FYR_UTILITARIO.F_GETFECHAHORACADENA(P.ADPLD_FECREG) AS ADPLD_FECREGCAD
  FROM FIDELIDAD.SFYRT_AUDPROGPROMLOTE P
  INNER JOIN FIDELIDAD.SFYRT_TIPOS OG ON P.TIPON_IDORIGEN = OG.TIPON_ID
  INNER JOIN FIDELIDAD.SFYRT_TIPOS ET ON P.TIPON_IDESTADO = ET.TIPON_ID
  WHERE P.ADPLN_ID = NVL(K_ID,P.ADPLN_ID)
        AND P.PPLTN_ID = NVL(K_IDPROGPROMLOTE,P.PPLTN_ID)
  ORDER BY P.PPLTN_ID,P.ADPLD_FECREG;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRSS_LISAUDPROGPROMLOTE;

--****************************************************************
-- Nombre SP           :  SFYRU_CIERRA_LOTE
-- Propósito           :  Permite el estado de la programación por alta
-- Input               :  K_ID
--                        K_USUARIO
-- Output              :  K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  22/04/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRU_CIERRA_LOTE(K_ID IN NUMBER,
                            K_USUARIO IN VARCHAR2,
                            K_CODERROR OUT NUMBER,
                            K_DESCERROR OUT VARCHAR2) IS

V_ESTALOTE_GENERADO NUMBER;
V_ESTALOTE_ENPROCESO NUMBER;
V_ESTALOTE_CERRADO NUMBER;
V_ESTADETALOTE_PENDIENTE NUMBER;
V_ESTADETALOTE_EJECBAJOK NUMBER;
V_ESTADETALOTE_ALTAERR NUMBER;
V_ESTADETALOTE_BAJAERR NUMBER;
V_PARAMETRO VARCHAR2(50);
EX_PARAMETRO EXCEPTION;
BEGIN

  FIDELIDAD.PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('ESTADO_LOTE_GENERADO',V_PARAMETRO,K_CODERROR,K_DESCERROR);
  IF K_CODERROR <> 0 THEN
    RAISE EX_PARAMETRO;
  ELSE
    V_ESTALOTE_GENERADO := TO_NUMBER(V_PARAMETRO);
  END IF;

  FIDELIDAD.PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('ESTADO_LOTE_ENPROCESO',V_PARAMETRO,K_CODERROR,K_DESCERROR);
  IF K_CODERROR <> 0 THEN
    RAISE EX_PARAMETRO;
  ELSE
    V_ESTALOTE_ENPROCESO := TO_NUMBER(V_PARAMETRO);
  END IF;

  FIDELIDAD.PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('ESTADO_LOTE_CERRADO',V_PARAMETRO,K_CODERROR,K_DESCERROR);
  IF K_CODERROR <> 0 THEN
    RAISE EX_PARAMETRO;
  ELSE
    V_ESTALOTE_CERRADO := TO_NUMBER(V_PARAMETRO);
  END IF;

  FIDELIDAD.PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('ESTADO_DETALLE_LOTE_PENDIENTE',V_PARAMETRO,K_CODERROR,K_DESCERROR);
  IF K_CODERROR <> 0 THEN
    RAISE EX_PARAMETRO;
  ELSE
    V_ESTADETALOTE_PENDIENTE := TO_NUMBER(V_PARAMETRO);
  END IF;

  FIDELIDAD.PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('ESTADO_DETALLE_LOTE_BAJA_PROMO_OK',V_PARAMETRO,K_CODERROR,K_DESCERROR);
  IF K_CODERROR <> 0 THEN
    RAISE EX_PARAMETRO;
  ELSE
    V_ESTADETALOTE_EJECBAJOK := TO_NUMBER(V_PARAMETRO);
  END IF;
  
    FIDELIDAD.PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('ESTADO_DETALLE_LOTE_ALTA_PROMO_ERR',V_PARAMETRO,K_CODERROR,K_DESCERROR);
  IF K_CODERROR <> 0 THEN
    RAISE EX_PARAMETRO;
  ELSE
    V_ESTADETALOTE_ALTAERR := TO_NUMBER(V_PARAMETRO);
  END IF;
  
    FIDELIDAD.PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('ESTADO_DETALLE_LOTE_BAJA_PROMO_ERR',V_PARAMETRO,K_CODERROR,K_DESCERROR);
  IF K_CODERROR <> 0 THEN
    RAISE EX_PARAMETRO;
  ELSE
    V_ESTADETALOTE_BAJAERR := TO_NUMBER(V_PARAMETRO);
  END IF;

  MERGE INTO FIDELIDAD.SFYRT_PROGPROMLOTE P
  USING (SELECT L.PPLTN_ID,
                COUNT(C.PPCLN_ID) AS TOTAL,
                SUM(CASE WHEN C.TIPON_IDESTADO = V_ESTADETALOTE_PENDIENTE THEN 1 ELSE 0 END) TOTALPEND,
                 SUM(CASE WHEN C.TIPON_IDESTADO = V_ESTADETALOTE_EJECBAJOK THEN 1 ELSE 0 END) TOTALEJEBAJOK,
                SUM(CASE WHEN C.TIPON_IDESTADO = V_ESTADETALOTE_ALTAERR THEN 1 ELSE 0 END) TOTALALTERR,
                SUM(CASE WHEN C.TIPON_IDESTADO = V_ESTADETALOTE_BAJAERR THEN 1 ELSE 0 END) TOTALBAJERR
         FROM FIDELIDAD.SFYRT_PROGPROMLOTE L
         LEFT JOIN FIDELIDAD.SFYRT_PROGPROMCLIENTE C ON L.PPLTN_ID = C.PPLTN_ID
         WHERE L.TIPON_IDESTADO IN (V_ESTALOTE_GENERADO,V_ESTALOTE_ENPROCESO)
               AND L.PPLTN_ID = NVL(K_ID,L.PPLTN_ID)
         GROUP BY L.PPLTN_ID
        ) Q
  ON (P.PPLTN_ID = Q.PPLTN_ID)
  WHEN MATCHED THEN
    UPDATE
    SET P.TIPON_IDESTADO = CASE 
                           WHEN Q.TOTALEJEBAJOK = Q.TOTAL THEN V_ESTALOTE_CERRADO
                           WHEN Q.TOTALALTERR + Q.TOTALBAJERR + Q.TOTALEJEBAJOK  = Q.TOTAL THEN V_ESTALOTE_CERRADO 
                           ELSE V_ESTALOTE_ENPROCESO END,
        P.PPLTV_USUMOD = NVL(K_USUARIO,P.PPLTV_USUMOD)
    WHERE Q.TOTALPEND = 0;

  COMMIT;

EXCEPTION
  WHEN EX_PARAMETRO THEN
    K_DESCERROR := K_DESCERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRU_CIERRA_LOTE;

--****************************************************************
-- Nombre SP           :  SFYRI_PROC_ALTPRO_LISCLIE
-- Propósito           :  Permite obtener lista de clientes
-- Output              :  K_CUR_LOTE_DETALLE
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  24/05/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRI_PROC_ALTPRO_LISCLIE(K_CUR_LOTE_DETALLE OUT SYS_REFCURSOR,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2) IS

V_PARAMETRO VARCHAR2(50);
V_ESTALOTE_GENERADO NUMBER;
V_ESTALOTE_PENDIENTE NUMBER;
V_ESTADETALOTE_PENDIENTE NUMBER;
EX_PARAMETRO EXCEPTION;
BEGIN

  FIDELIDAD.PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('ESTADO_LOTE_GENERADO',V_PARAMETRO,K_CODERROR,K_DESCERROR);
  IF K_CODERROR <> 0 THEN
    RAISE EX_PARAMETRO;
  ELSE
    V_ESTALOTE_GENERADO := TO_NUMBER(V_PARAMETRO);
  END IF;

    FIDELIDAD.PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('ESTADO_LOTE_GENERADO',V_PARAMETRO,K_CODERROR,K_DESCERROR);
  IF K_CODERROR <> 0 THEN
    RAISE EX_PARAMETRO;
  ELSE
    V_ESTALOTE_PENDIENTE := TO_NUMBER(V_PARAMETRO);
  END IF;

  FIDELIDAD.PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('ESTADO_DETALLE_LOTE_PENDIENTE',V_PARAMETRO,K_CODERROR,K_DESCERROR);
  IF K_CODERROR <> 0 THEN
    RAISE EX_PARAMETRO;
  ELSE
    V_ESTADETALOTE_PENDIENTE := TO_NUMBER(V_PARAMETRO);
  END IF;

  OPEN K_CUR_LOTE_DETALLE FOR
  SELECT L.PPLTN_ID,
         L.PROMN_ID,
         --L.TIPON_IDORIGEN,
         C.PPCLN_ID,
         C.PPCLV_SID,
         C.PPCLV_CODCLI,
         T.TIPOV_VALOR
  FROM FIDELIDAD.SFYRT_PROGPROMLOTE L
  INNER JOIN FIDELIDAD.SFYRT_PROGPROMCLIENTE C ON L.PPLTN_ID = C.PPLTN_ID
                                        AND C.TIPON_IDESTADO = V_ESTADETALOTE_PENDIENTE
  INNER JOIN FIDELIDAD.SFYRT_PROMOCIONCAB P ON L.PROMN_ID = P.PROMN_ID
  INNER JOIN FIDELIDAD.SFYRT_TIPOS T ON P.TIPON_IDVIGENCIA = T.TIPON_ID
  WHERE L.TIPON_IDESTADO = V_ESTALOTE_GENERADO or L.TIPON_IDESTADO=V_ESTALOTE_PENDIENTE
  ORDER BY L.PPLTN_ID,C.PPCLV_SID;

EXCEPTION
  WHEN EX_PARAMETRO THEN
    OPEN K_CUR_LOTE_DETALLE FOR
    SELECT '',
           '',
           '',
           '',
           '',
           '',
           ''
    FROM DUAL
    WHERE 1 = 2;
    K_DESCERROR := K_DESCERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRI_PROC_ALTPRO_LISCLIE;

--****************************************************************
-- Nombre SP           :  SFYRI_PROC_ALTPRO_GETPAR
-- Propósito           :  Permite leer parámetros
-- Input               :  K_ORIGEN
--                        K_ESTALOTE_GENERADO
--                        K_ESTADETALOTE_PENDIENTE
--                        K_ESTADETALOTE_EJECALTA
--                        K_ESTADETALOTE_ALTAPROMOK
--                        K_ESTADETALOTE_ALTAPROMERR
--                        K_ESTADETALOTE_ANULADO
-- Output              :  K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  24/05/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRI_PROC_ALTPRO_GETPAR(K_ORIGEN OUT VARCHAR2,
                                   K_ESTALOTE_GENERADO OUT NUMBER,
                                   K_ESTADETALOTE_PENDIENTE OUT NUMBER,
                                   K_ESTADETALOTE_EJECALTA OUT NUMBER,
                                   K_ESTADETALOTE_ALTAPROMOK OUT NUMBER,
                                   K_ESTADETALOTE_ALTAPROMERR OUT NUMBER,
                                   K_ESTADETALOTE_ANULADO OUT NUMBER,
                                   K_CODERROR OUT NUMBER,
                                   K_DESCERROR OUT VARCHAR2) IS

V_PARAMETRO VARCHAR2(50);
EX_PARAMETRO EXCEPTION;
EX_ERROR EXCEPTION;
BEGIN

  FIDELIDAD.PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('PROMOCION HFC - SISFYR',K_ORIGEN,K_CODERROR,K_DESCERROR);
  IF K_CODERROR <> 0 THEN
    RAISE EX_PARAMETRO;
  END IF;

  FIDELIDAD.PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('ESTADO_LOTE_GENERADO',V_PARAMETRO,K_CODERROR,K_DESCERROR);
  IF K_CODERROR <> 0 THEN
    RAISE EX_PARAMETRO;
  ELSE
    K_ESTALOTE_GENERADO := TO_NUMBER(V_PARAMETRO);
  END IF;

  FIDELIDAD.PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('ESTADO_DETALLE_LOTE_PENDIENTE',V_PARAMETRO,K_CODERROR,K_DESCERROR);
  IF K_CODERROR <> 0 THEN
    RAISE EX_PARAMETRO;
  ELSE
    K_ESTADETALOTE_PENDIENTE := TO_NUMBER(V_PARAMETRO);
  END IF;

  FIDELIDAD.PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('ESTADO_DETALLE_LOTE_EJECUCION_ALTA',V_PARAMETRO,K_CODERROR,K_DESCERROR);
  IF K_CODERROR <> 0 THEN
    RAISE EX_PARAMETRO;
  ELSE
    K_ESTADETALOTE_EJECALTA := TO_NUMBER(V_PARAMETRO);
  END IF;

  FIDELIDAD.PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('ESTADO_DETALLE_LOTE_ALTA_PROMO_OK',V_PARAMETRO,K_CODERROR,K_DESCERROR);
  IF K_CODERROR <> 0 THEN
    RAISE EX_PARAMETRO;
  ELSE
    K_ESTADETALOTE_ALTAPROMOK := TO_NUMBER(V_PARAMETRO);
  END IF;

  FIDELIDAD.PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('ESTADO_DETALLE_LOTE_ALTA_PROMO_ERR',V_PARAMETRO,K_CODERROR,K_DESCERROR);
  IF K_CODERROR <> 0 THEN
    RAISE EX_PARAMETRO;
  ELSE
    K_ESTADETALOTE_ALTAPROMERR := TO_NUMBER(V_PARAMETRO);
  END IF;

  FIDELIDAD.PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('ESTADO_DETALLE_LOTE_ANULADO',V_PARAMETRO,K_CODERROR,K_DESCERROR);
  IF K_CODERROR <> 0 THEN
    RAISE EX_PARAMETRO;
  ELSE
    K_ESTADETALOTE_ANULADO := TO_NUMBER(V_PARAMETRO);
  END IF;

EXCEPTION
  WHEN EX_PARAMETRO THEN
    K_DESCERROR := K_DESCERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRI_PROC_ALTPRO_GETPAR;

--****************************************************************
-- Nombre SP           :  SFYRI_PROC_AP4
-- Propósito           :  Permite actualizar el cliente del lote
-- Input               :  K_CODERRORSGA
--                        K_IDDETALOTE
--                        K_SOT_ALTA
--                        K_FECGENALTASOT
--                        K_FECALTASOT
--                        K_FECPROGBAJASOT
--                        K_OBSERVACION
--                        K_ESTADETALOTE_EJECALTA
--                        K_ESTADETALOTE_ALTAPROMOK
--                        K_ESTADETALOTE_ALTAPROMERR
--                        K_USUARIO
-- Output              :  K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  24/05/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRI_PROC_ALTPRO_ACTCLIE(K_IDDETALOTE IN NUMBER,
                                    K_CODERRORSGA IN NUMBER,
                                    K_SOT_ALTA IN NUMBER,
                                    K_FECGENALTASOT IN DATE,
                                    K_FECALTASOT IN DATE,
                                    K_FECPROGBAJASOT IN DATE,
                                    K_OBSERVACION IN VARCHAR2,
                                    K_ESTADETALOTE IN NUMBER,
                                    K_ESTADETALOTE_EJECALTA IN NUMBER,
                                    K_ESTADETALOTE_ALTAPROMERR IN NUMBER,
                                    K_USUARIO IN VARCHAR2,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2) IS

V_ESTADETALOTE NUMBER := K_ESTADETALOTE;
V_PARAMETRO NUMBER;
V_ESTALOTE_ENPROCESO number;
V_IDLOTE number := 0;


EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_IDDETALOTE   IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el código del detalle del lote. '; RAISE EX_ERROR;
    WHEN K_ESTADETALOTE IS NULL AND K_CODERRORSGA IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el código de error del SGA. '; RAISE EX_ERROR;
    WHEN K_ESTADETALOTE IS NULL AND K_CODERRORSGA < -1    THEN K_CODERROR := 4; K_DESCERROR := 'El código de error del SGA no es válido. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := ''; 
   
  END CASE;
  
  --IF K_ESTADETALOTE IS NULL THEN
  IF K_ESTADETALOTE ='999' THEN
    V_ESTADETALOTE := CASE K_CODERRORSGA
                        WHEN 0 THEN K_ESTADETALOTE_EJECALTA
                        WHEN 1 THEN K_ESTADETALOTE_ALTAPROMERR
                        WHEN -1 THEN K_ESTADETALOTE_ALTAPROMERR
                        ELSE K_ESTADETALOTE_EJECALTA
                      END;
  END IF;

  UPDATE FIDELIDAD.SFYRT_PROGPROMCLIENTE
  SET PPCLN_IDSOTALTA = NVL(K_SOT_ALTA,PPCLN_IDSOTALTA),
      PPCLD_FECSOTALTAGEN = NVL(K_FECGENALTASOT,PPCLD_FECSOTALTAGEN),
      PPCLD_FECSOTALTA = NVL(K_FECALTASOT,PPCLD_FECSOTALTA),
      PPCLD_FECSOTBAJAPROG = NVL(K_FECPROGBAJASOT,PPCLD_FECSOTBAJAPROG),
      PPCLV_OBSERVALTA = NVL(K_OBSERVACION,PPCLV_OBSERVALTA),
      TIPON_IDESTADO = V_ESTADETALOTE,
      PPCLV_USUMOD = K_USUARIO
  WHERE PPCLN_ID = K_IDDETALOTE;
  COMMIT;

FIDELIDAD.PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('ESTADO_LOTE_ENPROCESO',V_PARAMETRO,K_CODERROR,K_DESCERROR);
 IF K_CODERROR = 0 THEN
    V_ESTALOTE_ENPROCESO := TO_NUMBER(V_PARAMETRO);
    END IF;
    
   SELECT  PC.PPLTN_ID INTO V_IDLOTE FROM FIDELIDAD.SFYRT_PROGPROMCLIENTE PC
   WHERE PC.PPCLN_ID=K_IDDETALOTE AND PC.TIPON_IDESTADO <> V_ESTALOTE_ENPROCESO;
   
   IF V_IDLOTE <>0 THEN    
      UPDATE FIDELIDAD.SFYRT_PROGPROMLOTE PL
      SET PL.TIPON_IDESTADO = V_ESTALOTE_ENPROCESO
      WHERE PL.PPLTN_ID = V_IDLOTE;
      COMMIT;
   END IF;
EXCEPTION
  WHEN EX_ERROR THEN
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || K_DESCERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRI_PROC_ALTPRO_ACTCLIE;

--****************************************************************
-- Nombre SP           :  SFYRI_PROC_BAJPRO_ACTCLIE
-- Propósito           :  Permite actualizar el cliente del lote
-- Input               :  K_CODERRORSGA
--                        K_IDDETALOTE
--                        K_SOT_BAJA
--                        K_FECGENBAJASOT
--                        K_FECBAJASOT
--                        K_OBSERVACION
--                        K_ESTADETALOTE_BAJAPROMOK
--                        K_ESTADETALOTE_BAJAPROMERR
--                        K_ESTADETALOTE_EJECBAJA
--                        K_USUARIO
-- Output              :  K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  28/05/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE SFYRI_PROC_BAJPRO_ACTCLIE(K_IDDETALOTE IN NUMBER,
                                    K_CODERRORSGA IN NUMBER,
                                    K_SOT_BAJA IN NUMBER,
                                    K_FECGENBAJASOT IN DATE,
                                    K_FECBAJASOT IN DATE,
                                    K_OBSERVACION IN VARCHAR2,
                                    K_REINTENTOS IN NUMBER,
                                    K_USUARIO IN VARCHAR2,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2) IS
V_ESTADETALOTE_EJECBAJA NUMBER:=10;
V_ESTADETALOTE_BAJAPROMERR  NUMBER :=14;

V_ESTADETALOTE NUMBER;
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_IDDETALOTE  IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el código del detalle del lote. '; RAISE EX_ERROR;
    WHEN K_CODERRORSGA IS NULL THEN K_CODERROR := 2; K_DESCERROR := 'Ingrese el código de error del SGA. '; RAISE EX_ERROR;
    WHEN K_CODERRORSGA < -1    THEN K_CODERROR := 2; K_DESCERROR := 'El código de error del SGA no es válido. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  V_ESTADETALOTE := CASE K_CODERRORSGA
                      WHEN 0 THEN V_ESTADETALOTE_EJECBAJA
                      WHEN -1 THEN V_ESTADETALOTE_BAJAPROMERR
                      ELSE V_ESTADETALOTE_BAJAPROMERR
                    END;

  UPDATE FIDELIDAD.SFYRT_PROGPROMCLIENTE
  SET PPCLN_IDSOTBAJA = NVL(K_SOT_BAJA,PPCLN_IDSOTBAJA),
      PPCLD_FECSOTBAJAGEN = NVL(K_FECGENBAJASOT,PPCLD_FECSOTBAJAGEN),
     PPCLD_FECSOTBAJA = NVL(K_FECBAJASOT,PPCLD_FECSOTBAJA),
      PPCLV_OBSERVBAJA = K_OBSERVACION,
      PPCLN_REINTENTOS = NVL(K_REINTENTOS,PPCLN_REINTENTOS),
      TIPON_IDESTADO = V_ESTADETALOTE,
      PPCLV_USUMOD = K_USUARIO
  WHERE PPCLN_ID = K_IDDETALOTE;

  COMMIT;

EXCEPTION
  WHEN EX_ERROR THEN
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || K_DESCERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := FIDELIDAD.PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRI_PROC_BAJPRO_ACTCLIE;


--****************************************************************
-- Nombre SP           :  SFYRI_ALTPRO_ACTCLIE_SGA
-- Propósito           :  Actualizar los datos de alta de la tabla SFYRT_PROGPROMCLIENTE 
-- Input               :  K_FECSOTALTA
--                     :  K_FECSOTBAJAPROG
--                     :  K_OBSERVALTA
--                     :  K_IDESTADO
--                     :  K_ID
--                     :  K_USUMOD
-- Output              :  K_CODERROR
--                     :  K_DESCERROR
-- Creado por          :  Jorge Luis Ortiz Castillo
-- Fec Creación        :  28/11/2013
--****************************************************************

PROCEDURE SFYRI_ALTPRO_ACTCLIE_SGA(K_FECSOTALTA IN DATE,
                                   K_FECSOTBAJAPROG IN DATE,
                                   K_OBSERVALTA IN VARCHAR2,
                                   K_IDESTADO IN NUMBER,
                                   K_ID IN NUMBER,
                                   K_USUMOD VARCHAR2,
                                   K_CODERROR OUT NUMBER,
                                   K_DESCERROR OUT VARCHAR2) IS
  V_IDESTADO NUMBER;
BEGIN
  -- validar los parametros de entrada
  CASE 
    WHEN K_FECSOTALTA IS NULL THEN K_CODERROR:=2; K_DESCERROR := ' Ingrese la fecha de alta';
    WHEN K_FECSOTBAJAPROG IS NULL THEN K_CODERROR:=2; K_DESCERROR := ' Ingrese la fecha de baja.';
    WHEN K_IDESTADO IS NULL THEN K_CODERROR:= 2; K_DESCERROR := ' Ingrese el ID de Estado.';
    WHEN K_ID IS NULL THEN K_CODERROR:=2; K_DESCERROR := ' Ingrese el estado.';
    ELSE
      K_CODERROR := 0;
      K_DESCERROR := ' ';
  END CASE;
  
  IF K_IDESTADO = 0 THEN
    V_IDESTADO := 11;
  ELSIF K_IDESTADO = 1 OR K_IDESTADO = -1 THEN
    V_IDESTADO := 13;
  END IF;
  
  -- actualizar los datos en la tabla SFYRT_PROGPROMCLIENTE
  UPDATE FIDELIDAD.SFYRT_PROGPROMCLIENTE P
  SET P.PPCLD_FECSOTALTA = K_FECSOTALTA,
      P.PPCLD_FECSOTBAJAPROG = K_FECSOTBAJAPROG,
      P.PPCLV_OBSERVALTA = K_OBSERVALTA,
      P.TIPON_IDESTADO = V_IDESTADO,
      P.PPCLV_USUMOD = K_USUMOD
  WHERE P.PPCLN_ID = K_ID;
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END SFYRI_ALTPRO_ACTCLIE_SGA;

--****************************************************************
-- Nombre SP           :  SFYRI_BAJPRO_ACTCLIE_SGA
-- Propósito           :  Actualizar los datos de baja de la tabla SFYRT_PROGPROMCLIENTE
-- Input               :  K_FECSOTBAJA
--                     :  K_OBSERVBAJA
--                     :  K_REINTENTOS
--                     :  K_ESTADO
--                     :  K_ID
--                     :  K_USUMOD
-- Output              :  K_CODERROR
--                     :  K_DESCERROR
-- Creado por          :  Jorge Luis Ortiz Castillo
-- Fec Creación        :  28/11/2013
--****************************************************************

PROCEDURE SFYRI_BAJPRO_ACTCLIE_SGA(K_FECSOTBAJA IN DATE,
                                   K_OBSERVBAJA IN VARCHAR2,
                                   K_REINTENTOS IN NUMBER,
                                   K_IDESTADO IN NUMBER,
                                   K_ID IN NUMBER,
                                   K_USUMOD IN VARCHAR2,
                                   K_CODERROR OUT NUMBER,
                                   K_DESCERROR OUT VARCHAR2) IS
  V_IDESTADO NUMBER;
BEGIN
  -- validaciones de parametros entrada
  CASE 
    WHEN K_FECSOTBAJA IS NULL THEN K_CODERROR := 2; K_DESCERROR := ' Ingrese la fecha de baja.';
    WHEN K_IDESTADO IS NULL THEN K_CODERROR := 2; K_DESCERROR := ' Ingrese el ID de estado.';
    WHEN K_ID IS NULL THEN K_CODERROR := 2; K_DESCERROR := ' Ingrese código de la promoción.';
    ELSE
      K_CODERROR := 0;
      K_DESCERROR := ' ';
  END CASE;
  
  IF K_IDESTADO = 0 THEN
    V_IDESTADO := 12;-- cambiar por 10
  ELSIF K_IDESTADO = 1 OR K_IDESTADO = -1 THEN
    V_IDESTADO := 14;
  END IF;
  
  -- actualizar los datos en la tabla SFYRT_PROGPROMCLIENTE
  UPDATE FIDELIDAD.SFYRT_PROGPROMCLIENTE P
  SET P.PPCLD_FECSOTBAJA = K_FECSOTBAJA,
      P.PPCLV_OBSERVBAJA = K_OBSERVBAJA,
      P.PPCLN_REINTENTOS = K_REINTENTOS,
      P.TIPON_IDESTADO = V_IDESTADO,
      P.PPCLV_USUMOD = K_USUMOD
  WHERE P.PPCLN_ID = K_ID;
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
END SFYRI_BAJPRO_ACTCLIE_SGA;


--****************************************************************
-- Nombre Function     :  F_GETTOTALREGISTROXTIPO
-- Propósito           :  Obtiene el total de registros de lote x tipo
-- Input               :  K_IDPROGPROMLOTE
--                     :  K_IDGRUPOESTADO
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  25/04/2013
-- Fec Actualización   :
--****************************************************************

FUNCTION F_GETTOTALREGISTROXTIPO(K_IDPROGPROMLOTE NUMBER,
                                 K_IDGRUPOESTADO NUMBER) RETURN NUMBER IS
V_VALOR NUMBER;
BEGIN

  SELECT COUNT(P.PPCLN_ID) INTO V_VALOR
  FROM FIDELIDAD.SFYRT_PROGPROMCLIENTE P
  INNER JOIN FIDELIDAD.SFYRT_TIPOS T ON P.TIPON_IDESTADO = T.TIPON_ID
                              AND T.TIPON_IDGRUPO = NVL(K_IDGRUPOESTADO,TIPON_IDGRUPO)
  WHERE P.PPLTN_ID = K_IDPROGPROMLOTE;

  RETURN V_VALOR;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END F_GETTOTALREGISTROXTIPO;

--****************************************************************
-- Nombre Function     :  F_GETSERVPROMOETIQUETA
-- Propósito           :  Obtiene servicios separados con delimitador
-- Input               :  K_IDPROMOCION
--                     :  K_DELIM
-- Output              :  V_VALOR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  09/05/2013
-- Fec Actualización   :
--****************************************************************

FUNCTION F_GETSERVPROMOETIQUETA(K_IDPROMOCION NUMBER,
                                K_DELIM VARCHAR2) RETURN VARCHAR2 IS
CURSOR CUR_PROMO_SERVICIO(V_PROMN_ID NUMBER) IS
SELECT S.PROSV_ETIQUETA
FROM FIDELIDAD.SFYRT_PROMOCIONSERVICIO S
WHERE S.PROMN_ID = V_PROMN_ID
ORDER BY S.PROSN_ID;
VC_ETIQUETA VARCHAR2(50);
V_VALOR VARCHAR2(32767) := '';
BEGIN

  OPEN CUR_PROMO_SERVICIO(K_IDPROMOCION);
  FETCH CUR_PROMO_SERVICIO INTO VC_ETIQUETA;
  WHILE CUR_PROMO_SERVICIO%FOUND LOOP
    V_VALOR := V_VALOR || VC_ETIQUETA || K_DELIM;
    FETCH CUR_PROMO_SERVICIO
    INTO VC_ETIQUETA;
  END LOOP;
  CLOSE CUR_PROMO_SERVICIO;
  V_VALOR := SUBSTR(V_VALOR,1,LENGTH(V_VALOR)-LENGTH(K_DELIM));

  RETURN V_VALOR;
EXCEPTION
  WHEN OTHERS THEN
    RETURN '';
END F_GETSERVPROMOETIQUETA;

--****************************************************************
-- Nombre Function     :  F_GETSERVPROMOETIQDESC
-- Propósito           :  Obtiene servicios separados con delimitador
-- Input               :  K_IDPROMOCION
--                     :  K_DELIM
-- Output              :  V_VALOR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  09/05/2013
-- Fec Actualización   :
--****************************************************************

FUNCTION F_GETSERVPROMOETIQDESC(K_IDPROMOCION NUMBER,
                                K_DELIM VARCHAR2) RETURN VARCHAR2 IS
CURSOR CUR_PROMO_SERVICIO(V_PROMN_ID NUMBER) IS
SELECT S.PROSV_DESCRIPCION
FROM FIDELIDAD.SFYRT_PROMOCIONSERVICIO S
WHERE S.PROMN_ID = V_PROMN_ID
ORDER BY S.PROSN_ID;
VC_DESC VARCHAR2(50);
V_VALOR VARCHAR2(32767) := '';
BEGIN

  OPEN CUR_PROMO_SERVICIO(K_IDPROMOCION);
  FETCH CUR_PROMO_SERVICIO INTO VC_DESC;
  WHILE CUR_PROMO_SERVICIO%FOUND LOOP
    V_VALOR := V_VALOR || VC_DESC || K_DELIM;
    FETCH CUR_PROMO_SERVICIO
    INTO VC_DESC;
  END LOOP;
  CLOSE CUR_PROMO_SERVICIO;
  V_VALOR := SUBSTR(V_VALOR,1,LENGTH(V_VALOR)-LENGTH(K_DELIM));

  RETURN V_VALOR;
EXCEPTION
  WHEN OTHERS THEN
    RETURN '';
END F_GETSERVPROMOETIQDESC;

PROCEDURE SFYRI_PROC_BAJPRO_GETPAR(K_ORIGEN OUT VARCHAR2,
                                   K_ESTADETALOTE_ALTAPROMOK OUT NUMBER,
                                   K_ESTADETALOTE_EJECBAJA OUT NUMBER,
                                   K_ESTADETALOTE_BAJAPROMOK OUT NUMBER,
                                   K_ESTADETALOTE_BAJAPROMERR OUT NUMBER,
                                   K_CODERROR OUT NUMBER,
                                   K_DESCERROR OUT VARCHAR2) IS

V_PARAMETRO VARCHAR2(50);
EX_PARAMETRO EXCEPTION;
EX_ERROR EXCEPTION;
BEGIN

  PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('PROMOCION HFC - SISFYR',K_ORIGEN,K_CODERROR,K_DESCERROR);
  IF K_CODERROR <> 0 THEN
    RAISE EX_PARAMETRO;
  END IF;

  PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('ESTADO_DETALLE_LOTE_ALTA_PROMO_OK',V_PARAMETRO,K_CODERROR,K_DESCERROR);
  IF K_CODERROR <> 0 THEN
    RAISE EX_PARAMETRO;
  ELSE
    K_ESTADETALOTE_ALTAPROMOK := TO_NUMBER(V_PARAMETRO);
  END IF;

  PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('ESTADO_DETALLE_LOTE_EJECUCION_BAJA',V_PARAMETRO,K_CODERROR,K_DESCERROR);
  IF K_CODERROR <> 0 THEN
    RAISE EX_PARAMETRO;
  ELSE
    K_ESTADETALOTE_EJECBAJA := TO_NUMBER(V_PARAMETRO);
  END IF;

  PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('ESTADO_DETALLE_LOTE_BAJA_PROMO_OK',V_PARAMETRO,K_CODERROR,K_DESCERROR);
  IF K_CODERROR <> 0 THEN
    RAISE EX_PARAMETRO;
  ELSE
    K_ESTADETALOTE_BAJAPROMOK := TO_NUMBER(V_PARAMETRO);
  END IF;

  PKG_FYR_UTILITARIO.SFYRSS_LISPARAMSIST('ESTADO_DETALLE_LOTE_BAJA_PROMO_ERR',V_PARAMETRO,K_CODERROR,K_DESCERROR);
  IF K_CODERROR <> 0 THEN
    RAISE EX_PARAMETRO;
  ELSE
    K_ESTADETALOTE_BAJAPROMERR := TO_NUMBER(V_PARAMETRO);
  END IF;

EXCEPTION
  WHEN EX_PARAMETRO THEN
    K_DESCERROR := K_DESCERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := PKG_FYR_UTILITARIO.F_GETERRORES(K_CODERROR) || SUBSTR(SQLERRM, 1, 250);
END SFYRI_PROC_BAJPRO_GETPAR;

END PKG_FYR_PROMOCION_TRX;
/