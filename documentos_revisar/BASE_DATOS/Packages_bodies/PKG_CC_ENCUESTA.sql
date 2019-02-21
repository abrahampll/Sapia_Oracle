CREATE OR REPLACE PACKAGE BODY PCLUB.PKG_CC_ENCUESTA IS

--****************************************************************
-- Nombre SP           :  ADMPSS_REGMOVENCUESTA
-- Propósito           :  Registra las Encuestas Generadas que Se enviaron al Menos la 1era Pregunta,
--                        y que la encuesta en su totalidad fue respondida parcialmente
-- Input               :  K_TELEFONO    -  Telefono Donde se enviara la encuesta
--                     :  K_USUARIO     -  Usuario
--                     :  K_ID_CANJE    -  Codigo del Canje
--                     :  K_TIPO_DOC    -  Tipo de Documento
--                     :  K_NUM_DOC     -  Número de Documento
-- Output              :  K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Susana Ramos
-- Fec Creación        :
-- Fec Actualización   :  20/01/2013
--****************************************************************

PROCEDURE ADMPSS_REGMOVENCUESTA(K_TELEFONO IN VARCHAR2,
                                K_USUARIO IN VARCHAR2,
                                K_ID_CANJE IN NUMBER,
                                K_TIPO_DOC IN VARCHAR2,
                                K_NUM_DOC IN VARCHAR2,
                                K_COD_CLI VARCHAR2,
                                K_CODERROR OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2) IS
EX_ERROR       EXCEPTION;
V_CONT         NUMBER;
V_CONTREG      NUMBER;
K_ID_MOV       NUMBER;
K_ID_ENC       NUMBER;
V_TIPO_CANJE   CHAR(1);
K_ID_PRE       NUMBER;
K_DES_PRE      VARCHAR2(200);
K_DETALLE_MSJ  VARCHAR2(300);
K_ID_CAB       NUMBER;
V_COD_TPOPR    VARCHAR2(20);
V_TPREMIO_EXCL VARCHAR2(10);
C_OPCION_RPTA  VARCHAR2(5);
C_RESPUESTA    VARCHAR2(20);
V_TIPO_DOC     VARCHAR2(20);
CURSOR CUR_OPC_RPTAS(ID_PREGUNTA NUMBER) IS
SELECT P.ADMPV_OPCION, P.ADMPV_RESPUESTA
FROM PCLUB.ADMPT_RESPUESTA P
WHERE P.ADMPN_IDPREGUNTA = ID_PREGUNTA
      AND P.ADMPC_ESTADO = 'A'
ORDER BY P.ADMPV_OPCION ASC;
BEGIN

  CASE
    WHEN K_TELEFONO IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese un Nro. de Teléfono válido. '; RAISE EX_ERROR;
    WHEN K_ID_CANJE IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese un Código de Canje válido. '; RAISE EX_ERROR;
    WHEN K_TIPO_DOC IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese un Tipo de Documento válido. '; RAISE EX_ERROR;
    WHEN K_NUM_DOC  IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese un Nro. de Documento válido. '; RAISE EX_ERROR;
    WHEN K_COD_CLI  IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese un Código de Cliente válido. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := ' '; K_DETALLE_MSJ := '';
  END CASE;

  V_TIPO_DOC := PCLUB.PKG_CC_TRANSACCION.F_OBTENERTIPODOC(K_TIPO_DOC);

  IF V_TIPO_DOC IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR := 'El tipo de documento no fue encontrado. ';
    RAISE EX_ERROR;
  END IF;

  --Verificar que en la Fecha Actual no Exista mas de una Encuesta Activa
  SELECT COUNT(1) INTO V_CONT
  FROM ADMPT_ENCUESTA E
  WHERE E.ADMPC_ESTADO = 'A' AND
        TRUNC(SYSDATE) >= E.ADMPD_FECINI AND
        TRUNC(SYSDATE) <= E.ADMPD_FECFIN;

  IF V_CONT > 1 THEN
     K_CODERROR := 4;
     K_DESCERROR := 'No debe Existir más de una Encuesta Activa. ';
     RAISE EX_ERROR;
  ELSIF V_CONT = 0 THEN
     K_CODERROR := 4;
     K_DESCERROR := 'No existe encuesta configurada para hoy día. ';
     RAISE EX_ERROR;
  END IF ;
  --Verifica Si el Cliente esta en Black List
  ADMPSS_CLIE_BLACK_LIST (K_TELEFONO,K_CODERROR,K_DESCERROR);
  IF K_CODERROR = 0 THEN
    --Verifica si se ha Generado Encuesta en el mes anterior
    ADMPSS_VALIDA_GENERA_ENCUESTA(V_TIPO_DOC,K_NUM_DOC,K_CODERROR,K_DESCERROR);
    IF K_CODERROR <> 0 THEN
      RAISE EX_ERROR;
    END IF;
  ELSE
    RAISE EX_ERROR;
  END IF;

  ---Obtiene el valor de los Tipos de Premios que no Generan Encuesta, para exluirlo de la consulta.
  SELECT ADMPV_VALOR INTO V_TPREMIO_EXCL
  FROM PCLUB.ADMPT_PARAMSIST P
  WHERE P.ADMPV_DESC = 'TIPO_PREMIO_EXCLUIDO_ENC' ;

  V_TPREMIO_EXCL := '%'||V_TPREMIO_EXCL||'%';

  --Obtener el Codigo del Tipo de Premio
  SELECT CD.ADMPV_COD_TPOPR INTO V_COD_TPOPR
  FROM PCLUB.ADMPT_CANJE_DETALLE CD
  INNER JOIN PCLUB.ADMPT_CANJE C ON (CD.ADMPV_ID_CANJE = C.ADMPV_ID_CANJE)
  INNER JOIN PCLUB.ADMPT_TIPO_PREMIO T ON (CD.ADMPV_COD_TPOPR = T.ADMPV_COD_TPOPR)
  WHERE CD.ADMPV_ID_CANJE = K_ID_CANJE AND CD.ADMPV_COD_TPOPR NOT LIKE V_TPREMIO_EXCL AND ROWNUM = 1
  ORDER BY CD.ADMPV_ID_CANJESEC ASC;

  --Obtiene el Tipo de Canje S(Servicios) / Productos (P) --> cambiar de E a P
  IF V_COD_TPOPR IS NOT NULL THEN
    V_COD_TPOPR := '%'||V_COD_TPOPR||'%';
    SELECT COUNT(1) INTO V_CONTREG
    FROM PCLUB.ADMPT_PARAMSIST P
    WHERE P.ADMPV_DESC = 'TIPO_PREMIO_SERVICIOS' AND ADMPV_VALOR LIKE V_COD_TPOPR;

    IF  V_CONTREG = 0 THEN
      SELECT COUNT(1) INTO V_CONTREG
      FROM PCLUB.ADMPT_PARAMSIST P
      WHERE P.ADMPV_DESC = 'TIPO_PREMIO_PRODUCTOS' AND ADMPV_VALOR LIKE V_COD_TPOPR;

      IF V_CONTREG = 0 THEN
        K_CODERROR := 4;
        K_DESCERROR := 'El Tipo de Premio Canjeado, No Genera Encuesta.';
        RAISE EX_ERROR;
      ELSIF V_CONTREG > 0 THEN
        V_TIPO_CANJE := 'E';
      END IF;
    ELSIF V_CONTREG > 0  THEN
      V_TIPO_CANJE := 'S';
    END IF;
  ELSE
    K_CODERROR := 4;
    K_DESCERROR := 'El Tipo de Premio No es Válido.';
    RAISE EX_ERROR;
  END IF;

  SELECT NVL(PCLUB.ADMPT_MOVENCUESTA_SQ.NEXTVAL,0) INTO K_ID_MOV FROM DUAL;
  SELECT NVL(PCLUB.ADMPT_CABENCUESTA_SQ.NEXTVAL,0) INTO K_ID_CAB FROM DUAL;

  SELECT P1.ADMPN_IDENC, P1.ADMPN_IDPREGUNTA, P1.ADMPV_PREGUNTA INTO K_ID_ENC, K_ID_PRE, K_DES_PRE
  FROM (SELECT E.ADMPN_IDENC,P.ADMPN_IDPREGUNTA,P.ADMPV_PREGUNTA
        FROM PCLUB.ADMPT_PREGUNTA P
        INNER JOIN PCLUB.ADMPT_ENCUESTA E ON (P.ADMPN_IDENC = E.ADMPN_IDENC)
        WHERE E.ADMPC_ESTADO = 'A' AND P.ADMPC_ESTADO = 'A'
        AND SYSDATE >= E.ADMPD_FECINI AND TRUNC(SYSDATE) <= E.ADMPD_FECFIN
        ORDER BY P.ADMPV_ORDEN ASC)P1
  WHERE ROWNUM = 1;

  SELECT REPLACE(K_DES_PRE,' ',';') INTO K_DES_PRE FROM DUAL;
  K_DES_PRE := K_DES_PRE ||'.|';

  OPEN CUR_OPC_RPTAS(K_ID_PRE);
  FETCH CUR_OPC_RPTAS INTO C_OPCION_RPTA, C_RESPUESTA;
  WHILE CUR_OPC_RPTAS%FOUND  LOOP
    SELECT REPLACE(C_RESPUESTA,' ',';') INTO C_RESPUESTA FROM DUAL;

    IF K_DETALLE_MSJ IS NOT NULL  THEN
      K_DETALLE_MSJ := K_DETALLE_MSJ || '|';
    ELSE
      K_DETALLE_MSJ := K_DES_PRE;
    END IF;
    K_DETALLE_MSJ := K_DETALLE_MSJ || C_OPCION_RPTA ||'.'||C_RESPUESTA;
  FETCH CUR_OPC_RPTAS INTO C_OPCION_RPTA, C_RESPUESTA;
  END LOOP;
  CLOSE CUR_OPC_RPTAS;

  IF K_DETALLE_MSJ IS NULL THEN
    K_CODERROR := 42;
    K_DESCERROR := 'Pregunta no tiene respuestas configuradas.';
    RAISE EX_ERROR;
  END IF;

  INSERT INTO PCLUB.ADMPT_CABENCUESTA(ADMPN_IDCABENC,ADMPV_TELEFONO,ADMPN_IDENC,ADMPC_ESTADO,ADMPD_FECINIENC,ADMPV_USU_REG,
                                ADMPN_ID_CANJE,ADMPV_TIPO_DOC,ADMPV_NUM_DOC,ADMPV_COD_CLI,ADMPC_TIPO_CANJE)
  VALUES(K_ID_CAB,K_TELEFONO,K_ID_ENC,'P',SYSDATE,K_USUARIO,K_ID_CANJE,V_TIPO_DOC,K_NUM_DOC,K_COD_CLI,V_TIPO_CANJE);

  INSERT INTO PCLUB.ADMPT_MOVENCUESTA(ADMPN_IDMOV,ADMPV_TELEFONO,ADMPN_IDENC,ADMPN_IDPREGUNTA,ADMPD_FECGEN,
                                ADMPV_USU_REG,ADMPC_ESTADO_PRE,ADMPV_DETALLE_MSJ,ADMPN_IDCABENC)
  VALUES(K_ID_MOV,K_TELEFONO,K_ID_ENC,K_ID_PRE,SYSDATE,K_USUARIO,'P',K_DETALLE_MSJ,K_ID_CAB);

  BEGIN
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR = K_CODERROR;
  EXCEPTION WHEN OTHERS THEN
    K_DESCERROR := '';
  END;
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
    K_DESCERROR := 'Ocurrió un error en el SP ADMPSS_REGMOVENCUESTA';
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR = K_CODERROR;
END ADMPSS_REGMOVENCUESTA;

--****************************************************************
-- Nombre SP           :  ADMPSS_OBTENCSERVICIO
-- Propósito           :  Obtiene Las Lineas que realizaron Canje de Servicios el dia anterior, Para el envio de la Encuesta
--                        1era Pregunta via SMS
-- Input               :  K_USER - Usuario
-- Output              :  K_CUR_LISTA
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Susana Ramos
-- Fec Creación        :
-- Fec Actualización   :  15/01/2013
--****************************************************************

PROCEDURE ADMPSS_OBTENCSERVICIO(K_USER IN VARCHAR2,
                                K_CUR_LISTA OUT SYS_REFCURSOR,
                                K_CODERROR OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2) IS
K_INI_FECHA DATE;
K_FIN_FECHA DATE;
CURSOR CUR_LISTA_X_ENVIAR IS
   SELECT C.ADMPN_IDCABENC,M.ADMPN_IDMOV,M.ADMPV_TELEFONO,M.ADMPN_IDENC,M.ADMPN_IDPREGUNTA,M.ADMPV_DETALLE_MSJ
   FROM PCLUB.ADMPT_CABENCUESTA C
   INNER JOIN PCLUB.ADMPT_MOVENCUESTA M ON (C.ADMPN_IDCABENC = M.ADMPN_IDCABENC AND M.ADMPC_ESTADO_PRE ='P')
   WHERE C.ADMPC_ESTADO = 'P' AND C.ADMPC_TIPO_CANJE = 'S' AND
         C.ADMPD_FECINIENC >= K_INI_FECHA AND
         C.ADMPD_FECINIENC <= K_FIN_FECHA AND
         ROWNUM <=100;
BEGIN

  K_INI_FECHA := ADMPSS_GETFECHA_LIM(SYSDATE-1,1);
  K_FIN_FECHA := ADMPSS_GETFECHA_LIM(SYSDATE-1,2);

  OPEN K_CUR_LISTA FOR
  SELECT C.ADMPN_IDCABENC,M.ADMPN_IDMOV,M.ADMPV_TELEFONO,M.ADMPN_IDENC,M.ADMPN_IDPREGUNTA,M.ADMPV_DETALLE_MSJ
  FROM PCLUB.ADMPT_CABENCUESTA C
  INNER JOIN PCLUB.ADMPT_MOVENCUESTA M ON (C.ADMPN_IDCABENC = M.ADMPN_IDCABENC AND M.ADMPC_ESTADO_PRE = 'P')
  WHERE C.ADMPC_ESTADO = 'P' AND C.ADMPC_TIPO_CANJE = 'S' AND
        C.ADMPD_FECINIENC >= K_INI_FECHA AND
        C.ADMPD_FECINIENC <= K_FIN_FECHA AND
        ROWNUM <=100;

  FOR M IN CUR_LISTA_X_ENVIAR LOOP
    UPDATE PCLUB.ADMPT_CABENCUESTA Y
    SET Y.ADMPD_FECENVIO = SYSDATE,
        Y.ADMPC_ESTADO = 'E',
        Y.ADMPV_USU_MOD = K_USER
    WHERE Y.ADMPN_IDCABENC = M.ADMPN_IDCABENC;

    UPDATE PCLUB.ADMPT_MOVENCUESTA X
    SET X.ADMPC_ESTADO_PRE = 'E' ,
        X.ADMPD_FECENVIO = SYSDATE,
        X.ADMPV_USU_MOD = K_USER
    WHERE X.ADMPN_IDCABENC = M.ADMPN_IDCABENC AND
        X.ADMPN_IDMOV = M.ADMPN_IDMOV;
  END LOOP;
  COMMIT;
  K_CODERROR := 0;
  K_DESCERROR := '';
EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := 'Ocurrió un error en el SP ADMPSS_OBTENCSERVICIO';
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR = K_CODERROR;
    ROLLBACK;
END ADMPSS_OBTENCSERVICIO;

--****************************************************************
-- Nombre SP           :  ADMPSS_OBTENCEQUIPO
-- Propósito           :  Obtiene Las Lineas que realizaron Canje de Equipos el dia de ayer(Posterior a las 08:00pm)/hoy en el rango de horas (de 08:00-19:00)
--                        Para el envio de la Encuesta 1era Pregunta via SMS
-- Input               :  K_USER - Usuario
-- Output              :  K_CUR_LISTA
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Susana Ramos
-- Fec Creación        :
-- Fec Actualización   :  05/01/2013
--****************************************************************

PROCEDURE ADMPSS_OBTENCEQUIPO(K_USER IN VARCHAR2,
                              K_CUR_LISTA OUT SYS_REFCURSOR,
                              K_CODERROR OUT NUMBER,
                              K_DESCERROR OUT VARCHAR2) IS
K_INI_FECHA DATE;
K_FIN_FECHA DATE;
CURSOR CUR_LISTA_X_ENVIAR IS
SELECT M.ADMPN_IDCABENC,M.ADMPN_IDMOV, M.ADMPV_TELEFONO,M.ADMPN_IDENC,M.ADMPN_IDPREGUNTA,M.ADMPV_DETALLE_MSJ
FROM PCLUB.ADMPT_MOVENCUESTA M
INNER JOIN PCLUB.ADMPT_CABENCUESTA C ON (C.ADMPN_IDCABENC = M.ADMPN_IDCABENC AND M.ADMPC_ESTADO_PRE = 'P')
WHERE C.ADMPC_ESTADO = 'P' AND C.ADMPC_TIPO_CANJE = 'E' AND
      C.ADMPD_FECINIENC >= K_INI_FECHA AND
      C.ADMPD_FECINIENC <= K_FIN_FECHA AND
      ROWNUM <=100;
BEGIN

  K_INI_FECHA := ADMPSS_GETFECHA_LIM(SYSDATE-1,1);
  K_FIN_FECHA := ADMPSS_GETFECHA_LIM(SYSDATE,2);

/* El shell que se ejecuta a las 9 Am del 05/12, el proceso considerara lo siguiente, todos los canjes realizados
  desde las 08:00 Am hasta las 09:00 Am del mismo día.
  Todos los canjes realizados del día anterior de 7Pm a 7:59 con 59 seg. serán enviados el mismo día a las 8 Pm*/
  BEGIN
    OPEN K_CUR_LISTA FOR
     SELECT M.ADMPN_IDCABENC,M.ADMPN_IDMOV,M.ADMPV_TELEFONO,M.ADMPN_IDENC,M.ADMPN_IDPREGUNTA,M.ADMPV_DETALLE_MSJ
     FROM PCLUB.ADMPT_MOVENCUESTA M
     INNER JOIN PCLUB.ADMPT_CABENCUESTA C ON (C.ADMPN_IDCABENC = M.ADMPN_IDCABENC AND M.ADMPC_ESTADO_PRE = 'P')
     WHERE C.ADMPC_ESTADO = 'P' AND C.ADMPC_TIPO_CANJE = 'E' AND
           C.ADMPD_FECINIENC >= K_INI_FECHA AND
           C.ADMPD_FECINIENC <= K_FIN_FECHA AND
           ROWNUM <=100;

    FOR M IN CUR_LISTA_X_ENVIAR LOOP
      UPDATE PCLUB.ADMPT_CABENCUESTA Y
      SET Y.ADMPD_FECENVIO = SYSDATE,
          Y.ADMPC_ESTADO = 'E',
          Y.ADMPV_USU_MOD = K_USER
      WHERE Y.ADMPN_IDCABENC = M.ADMPN_IDCABENC;

      UPDATE PCLUB.ADMPT_MOVENCUESTA X
      SET X.ADMPC_ESTADO_PRE = 'E' ,
          X.ADMPD_FECENVIO = SYSDATE,
          X.ADMPV_USU_MOD = K_USER
      WHERE X.ADMPN_IDCABENC = M.ADMPN_IDCABENC AND
            X.ADMPN_IDMOV = M.ADMPN_IDMOV;
    END LOOP;
    COMMIT;
    K_CODERROR := 0;
    K_DESCERROR := '';
  EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR := -1;
      K_DESCERROR := 'Ocurrió un error en el SP ADMPSS_OBTENCEQUIPO';
      SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
      FROM PCLUB.ADMPT_ERRORES_CC
      WHERE ADMPN_COD_ERROR = K_CODERROR;
      ROLLBACK;
  END;
END ADMPSS_OBTENCEQUIPO;

--****************************************************************
-- Nombre SP           :  ADMPSS_PROCESARESP
-- Propósito           :  Actualiza la Respuesta enviada por el Cliente, en caso tenga, preguntas pendientes por enviar y
--                        este en el rango de Horas Permitida, se enviara la siguiente pregunta.
-- Input               :  K_TELEFONO - Telefono del Cliente
--                        K_OPCION   - Opcion elegida por el Cliente
--                        K_USUARIO  - Usuario
-- Output              :  K_CUR_CLIE_PRO - Devuelve la siquiente Pregunta, de la encuesta
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Susana Ramos
-- Fec Creación        :
-- Fec Actualización   :  20/01/2013
--****************************************************************

PROCEDURE ADMPSS_PROCESARESP(K_TELEFONO IN VARCHAR2,
                             K_OPCION IN VARCHAR2,
                             K_USUARIO IN VARCHAR2,
                             K_DES_PREGUNTA OUT VARCHAR2,
                             K_CODERROR OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
EX_FINENC EXCEPTION;
K_ID_MOV NUMBER;
K_ID_CAB_ACT NUMBER;
K_ID_MOV_ACT NUMBER;
K_IDENC_ACT NUMBER;
K_IDPRE_ACT NUMBER;
K_ID_PRE NUMBER;
V_CONT_REG NUMBER;
V_NUM_IDEN_RES NUMBER;
V_NUM_ORDEN NUMBER;
K_DES_PRE VARCHAR2(200);
K_DETALLE_MSJ VARCHAR2(300);
C_OPCION_RPTA VARCHAR2(5);
C_RESPUESTA VARCHAR2(20);
V_HORA_INI VARCHAR2(5);
V_HORA_FIN VARCHAR2(5);
V_RESPUESTA NUMBER;
V_DESERROR VARCHAR2(250);
K_FECHA DATE;

CURSOR CUR_OPC_RPTAS(ID_PREGUNTA NUMBER ) IS
   SELECT P.ADMPV_OPCION,P.ADMPV_RESPUESTA
   FROM PCLUB.ADMPT_RESPUESTA P
   WHERE P.ADMPC_ESTADO = 'A' AND P.ADMPN_IDPREGUNTA = ID_PREGUNTA
   ORDER BY P.ADMPV_OPCION ASC ;
BEGIN

  K_DES_PREGUNTA := '';
  K_FECHA := TRUNC(SYSDATE);

  CASE
    WHEN K_TELEFONO IS NULL THEN  K_CODERROR := 4; K_DESCERROR := 'El Nro. de Teléfono no es válido.';
                        PCLUB.PKG_CC_MANTENIMIENTO.ADMPSI_OBTMENSAJE('REGENCERROR',K_DES_PREGUNTA,V_RESPUESTA,V_DESERROR);
                        RAISE EX_ERROR;
    WHEN K_OPCION IS NULL THEN  K_CODERROR := 4; K_DESCERROR := 'El Número de Opción no es válido. ';
                        PCLUB.PKG_CC_MANTENIMIENTO.ADMPSI_OBTMENSAJE('REGENCRPTAVACIA',K_DES_PREGUNTA,V_RESPUESTA,V_DESERROR);
                        RAISE EX_ERROR;
      ELSE K_CODERROR := 0; K_DESCERROR := ' ';
  END CASE;

   --Relacionar con cabecera encuesta Lidia
  SELECT COUNT(1) INTO V_CONT_REG
  FROM PCLUB.ADMPT_MOVENCUESTA M
  WHERE M.ADMPV_TELEFONO = K_TELEFONO;

  IF V_CONT_REG = 0 THEN
     K_CODERROR := 4;
     K_DESCERROR := 'El Nro. de Teléfono Ingresado no está Registrado. ';
     PCLUB.PKG_CC_MANTENIMIENTO.ADMPSI_OBTMENSAJE('REGENCNOENCUESTA',K_DES_PREGUNTA,V_RESPUESTA,V_DESERROR);
     RAISE EX_ERROR;
  ELSE
    --Relacionar con cabecera encuesta Lidia
     SELECT COUNT(1) INTO V_CONT_REG
     FROM PCLUB.ADMPT_CABENCUESTA C
     INNER JOIN PCLUB.ADMPT_MOVENCUESTA M ON (C.ADMPN_IDCABENC = M.ADMPN_IDCABENC AND M.ADMPC_ESTADO_PRE = 'E')
     WHERE C.ADMPV_TELEFONO = K_TELEFONO AND C.ADMPC_ESTADO = 'E' AND
           C.ADMPD_FECENVIO > K_FECHA;

     IF V_CONT_REG = 0 THEN
       K_CODERROR := 4;
       K_DESCERROR := 'El Nro. de Teléfono Ingresado no tiene una Encuesta Enviada,Pendiente por Responder. ';
       PCLUB.PKG_CC_MANTENIMIENTO.ADMPSI_OBTMENSAJE('REGENCNOENCUESTA',K_DES_PREGUNTA,V_RESPUESTA,V_DESERROR);
       RAISE EX_ERROR;
     ELSE
     /*----OJO :   --> Verificar la Fecha ----*/
       IF V_CONT_REG = 1 THEN
          SELECT C.ADMPN_IDCABENC,M.ADMPN_IDMOV, M.ADMPN_IDENC, M.ADMPN_IDPREGUNTA
          INTO K_ID_CAB_ACT, K_ID_MOV_ACT, K_IDENC_ACT, K_IDPRE_ACT
          FROM PCLUB.ADMPT_CABENCUESTA C
          INNER JOIN PCLUB.ADMPT_MOVENCUESTA M ON (C.ADMPN_IDCABENC = M.ADMPN_IDCABENC AND M.ADMPC_ESTADO_PRE = 'E')
          WHERE C.ADMPV_TELEFONO = K_TELEFONO AND C.ADMPC_ESTADO = 'E' AND
                C.ADMPD_FECENVIO > K_FECHA;
       ELSE
           K_CODERROR := 4;
           K_DESCERROR := 'Existe más de una pregunta enviada, verifique. ';
            PCLUB.PKG_CC_MANTENIMIENTO.ADMPSI_OBTMENSAJE('REGENCERROR',K_DES_PREGUNTA,V_RESPUESTA,V_DESERROR);
           RAISE EX_ERROR;
       END IF;

       SELECT COUNT(1) INTO V_CONT_REG
       FROM PCLUB.ADMPT_ENCUESTA E
       WHERE E.ADMPN_IDENC = K_IDENC_ACT AND
             TRUNC(SYSDATE) >= E.ADMPD_FECINI AND
       TRUNC(SYSDATE) <= E.ADMPD_FECFIN;

      IF V_CONT_REG = 0 THEN
        K_CODERROR := 4;
        K_DESCERROR := 'La encuesta a responder esta fuera del rango de fecha de configuración. ';
        PCLUB.PKG_CC_MANTENIMIENTO.ADMPSI_OBTMENSAJE('REGENCNOCONFIGURADA',K_DES_PREGUNTA,V_RESPUESTA,V_DESERROR);
        RAISE EX_ERROR;
      END IF;

      SELECT COUNT(1) INTO V_CONT_REG
      FROM PCLUB.ADMPT_ENCUESTA E
      WHERE E.ADMPN_IDENC = K_IDENC_ACT AND
            TRUNC(SYSDATE) >= E.ADMPD_FECINI AND
      TRUNC(SYSDATE) <= E.ADMPD_FECFIN AND
            E.ADMPC_ESTADO = 'A';

      IF V_CONT_REG =0 THEN
        K_CODERROR := 4;
        K_DESCERROR := 'La encuesta a responder no está activa. ';
        PCLUB.PKG_CC_MANTENIMIENTO.ADMPSI_OBTMENSAJE('REGENCNOCONFIGURADA', K_DES_PREGUNTA, V_RESPUESTA,V_DESERROR);
        RAISE EX_ERROR;
      END IF;

      SELECT  COUNT(1) INTO V_CONT_REG
      FROM PCLUB.ADMPT_RESPUESTA R
      INNER JOIN PCLUB.ADMPT_PREGUNTA P ON (P.ADMPN_IDPREGUNTA = R.ADMPN_IDPREGUNTA)
      WHERE P.ADMPN_IDENC = K_IDENC_ACT AND
            P.ADMPN_IDPREGUNTA = K_IDPRE_ACT 
            AND P.ADMPC_ESTADO='A';
      
      IF V_CONT_REG = 0 THEN
        K_CODERROR := 1;
        K_DESCERROR := 'La pregunta no se encuentra activa. ';
        PCLUB.PKG_CC_MANTENIMIENTO.ADMPSI_OBTMENSAJE('REGENCFINALIZADA', K_DES_PREGUNTA, V_RESPUESTA,V_DESERROR);        
        RAISE EX_ERROR;
      END IF;


      SELECT  COUNT(1) INTO V_CONT_REG
      FROM PCLUB.ADMPT_RESPUESTA R
      INNER JOIN PCLUB.ADMPT_PREGUNTA P ON (P.ADMPN_IDPREGUNTA = R.ADMPN_IDPREGUNTA)
      WHERE P.ADMPN_IDENC = K_IDENC_ACT AND
            P.ADMPN_IDPREGUNTA = K_IDPRE_ACT AND
            R.ADMPV_OPCION = K_OPCION
            AND P.ADMPC_ESTADO='A' AND R.ADMPC_ESTADO='A';

      --Validar que solo haya pregunta en estado ENVIADA, en caso me devuelva mas de un registro lo cortamos
      IF V_CONT_REG = 0 THEN
        K_CODERROR := 4;
        K_DESCERROR := 'No  existe la opción ingresada. ';
        PCLUB.PKG_CC_MANTENIMIENTO.ADMPSI_OBTMENSAJE('REGENCRPTACLAVEERROR', K_DES_PREGUNTA, V_RESPUESTA,V_DESERROR);
        RAISE EX_ERROR;
      END IF;
     END IF;
  END IF;

   /*Verifica que la opcion ingresada, exista en la tabla respuesta, según la pregunta enviada
     para un determinado número de telefono*/
   SELECT P.ADMPV_ORDEN, R.ADMPN_IDRESP INTO V_NUM_ORDEN, V_NUM_IDEN_RES
   FROM PCLUB.ADMPT_RESPUESTA R
   INNER JOIN PCLUB.ADMPT_PREGUNTA P ON (P.ADMPN_IDPREGUNTA = R.ADMPN_IDPREGUNTA)
   WHERE P.ADMPN_IDENC = K_IDENC_ACT AND
         P.ADMPN_IDPREGUNTA = K_IDPRE_ACT AND
         R.ADMPV_OPCION = K_OPCION;

   UPDATE PCLUB.ADMPT_MOVENCUESTA M
   SET M.ADMPN_IDRESP = V_NUM_IDEN_RES,
       M.ADMPD_FECRESP = SYSDATE,
       M.ADMPV_USU_MOD = K_USUARIO,
       M.ADMPC_ESTADO_PRE = 'R'
   WHERE M.ADMPN_IDCABENC = K_ID_CAB_ACT AND
         M.ADMPN_IDMOV = K_ID_MOV_ACT;

   /*Validar si  esta en el rango de Horas para ser enviada, si esta en el rango lo inserto en ADMPT_MOVENCUESTA
   y lo envio, y que por default inicie en E (lidia). Colocar en Tabla de Parametros Lidia*/
   SELECT ADMPV_VALOR INTO V_HORA_INI
   FROM PCLUB.ADMPT_PARAMSIST t
   WHERE T.ADMPV_DESC = 'HORA_INICIO_ENVIO_SMS';

   SELECT ADMPV_VALOR INTO V_HORA_FIN
   FROM PCLUB.ADMPT_PARAMSIST t
   WHERE T.ADMPV_DESC = 'HORA_FIN_ENVIO_SMS';

   SELECT COUNT(1) INTO V_CONT_REG
   FROM DUAL
   WHERE TO_DATE(TO_CHAR(SYSDATE, 'HH24:MI'), 'HH24:MI')
         BETWEEN TO_DATE(V_HORA_INI, 'HH24:MI') AND TO_DATE(V_HORA_FIN, 'HH24:MI');

    IF V_CONT_REG > 0 THEN
      SELECT NVL(ADMPT_MOVENCUESTA_SQ.NEXTVAL,0) INTO K_ID_MOV FROM DUAL;
      --Busco la siguiente pregunta para una encuesta determinada
      SELECT COUNT(1) INTO V_CONT_REG
      FROM PCLUB.ADMPT_PREGUNTA P
      INNER JOIN PCLUB.ADMPT_ENCUESTA E ON (E.ADMPN_IDENC = P.ADMPN_IDENC)
      WHERE P.ADMPN_IDENC = K_IDENC_ACT AND P.ADMPV_ORDEN > V_NUM_ORDEN AND P.ADMPC_ESTADO = 'A';

      IF V_CONT_REG > 0 THEN
         SELECT P1.ADMPN_IDPREGUNTA,P1.ADMPV_PREGUNTA INTO K_ID_PRE, K_DES_PRE
         FROM (SELECT P.ADMPN_IDPREGUNTA,P.ADMPV_PREGUNTA
               FROM PCLUB.ADMPT_PREGUNTA P
               INNER JOIN PCLUB.ADMPT_ENCUESTA E ON (E.ADMPN_IDENC = P.ADMPN_IDENC)
               WHERE P.ADMPN_IDENC = K_IDENC_ACT  AND P.ADMPV_ORDEN > V_NUM_ORDEN AND P.ADMPC_ESTADO = 'A'
               ORDER BY P.admpv_orden ASC
              ) P1 WHERE ROWNUM = 1;

         --SELECT REPLACE(K_DES_PRE,' ',';') INTO K_DES_PRE FROM DUAL;
         K_DES_PRE := K_DES_PRE ||'|';

         OPEN CUR_OPC_RPTAS(K_ID_PRE);
         FETCH CUR_OPC_RPTAS INTO C_OPCION_RPTA, C_RESPUESTA;
         WHILE CUR_OPC_RPTAS%FOUND  LOOP
           --SELECT REPLACE(C_RESPUESTA,' ',';') INTO C_RESPUESTA FROM DUAL;

           IF K_DETALLE_MSJ IS NOT NULL  THEN
              K_DETALLE_MSJ := K_DETALLE_MSJ || '|';
           ELSE
             K_DETALLE_MSJ := K_DES_PRE;
           END IF;
             K_DETALLE_MSJ := K_DETALLE_MSJ || C_OPCION_RPTA || '.' || C_RESPUESTA;
             --K_DETALLE_MSJ := K_DETALLE_MSJ || ' ' || C_OPCION_RPTA || '.' || C_RESPUESTA;
          FETCH CUR_OPC_RPTAS INTO C_OPCION_RPTA, C_RESPUESTA;
         END LOOP;
         CLOSE CUR_OPC_RPTAS;
         
         IF K_DETALLE_MSJ IS NULL THEN
            K_CODERROR := 42;
            K_DESCERROR := 'Pregunta no tiene respuestas configuradas.';
            ROLLBACK;
            PCLUB.PKG_CC_MANTENIMIENTO.ADMPSI_OBTMENSAJE('REGENCERROR', K_DES_PREGUNTA, V_RESPUESTA,V_DESERROR);            
         ELSE
            INSERT INTO PCLUB.ADMPT_MOVENCUESTA(ADMPN_IDCABENC,ADMPN_IDMOV,ADMPV_TELEFONO,ADMPN_IDENC,ADMPN_IDPREGUNTA,ADMPD_FECGEN,
                                             ADMPV_USU_REG,ADMPC_ESTADO_PRE ,ADMPV_DETALLE_MSJ,ADMPD_FECENVIO)
             VALUES(K_ID_CAB_ACT,K_ID_MOV,K_TELEFONO,K_IDENC_ACT,K_ID_PRE,SYSDATE,K_USUARIO,'E',K_DETALLE_MSJ,SYSDATE);

             K_DES_PREGUNTA := K_DETALLE_MSJ;               
         END IF;
         
         
        ELSIF V_CONT_REG = 0 THEN
          --Se Actualiza la Cabecera cuando esta todo respondido
          UPDATE PCLUB.ADMPT_CABENCUESTA M
          SET M.ADMPD_FECFINENC = SYSDATE,
              M.ADMPV_USU_MOD = K_USUARIO,
              M.ADMPC_ESTADO = 'F'
          WHERE M.ADMPN_IDCABENC = K_ID_CAB_ACT;
          K_DESCERROR := 'No hay más preguntas, la Encuesta fue finalizada. ';

          PCLUB.PKG_CC_MANTENIMIENTO.ADMPSI_OBTMENSAJE('REGENCFINALIZADA',K_DES_PREGUNTA,V_RESPUESTA,V_DESERROR);
        END IF;
   END IF;
   COMMIT;
   BEGIN
     SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
     FROM PCLUB.ADMPT_ERRORES_CC
     WHERE ADMPN_COD_ERROR = K_CODERROR;
   EXCEPTION WHEN OTHERS THEN
      K_DESCERROR := '';
   END;
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
     K_DESCERROR := 'Ocurrió un error en el SP ADMPSS_PROCESARESP';

     SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
     FROM PCLUB.ADMPT_ERRORES_CC
     WHERE ADMPN_COD_ERROR = K_CODERROR;

     PCLUB.PKG_CC_MANTENIMIENTO.ADMPSI_OBTMENSAJE('REGENCERROR', K_DES_PREGUNTA, V_RESPUESTA,V_DESERROR);
END ADMPSS_PROCESARESP;

--****************************************************************
-- Nombre SP           :  ADMPSS_CANCELENCUESTA
-- Propósito           :  Cancela las Encuestas Generadas que Se enviaron al Menos la 1era Pregunta,
--                        y que la encuesta en su totalidad fue respondida parcialmente
-- Input               :  K_FECHA    - Fecha en la que se cancelara la Encuesta
-- Output              :  K_CUR_CLIE_PRO - Devuelve la siquiente Pregunta, de la encuesta
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Susana Ramos
-- Fec Creación        :
-- Fec Actualización   :  20/01/2013
--****************************************************************

PROCEDURE ADMPSS_CANCELENCUESTA(K_USUARIO IN VARCHAR2,
                                K_CODERROR OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2) IS
K_FECHA DATE;
BEGIN

  K_FECHA := TRUNC(SYSDATE);
  K_CODERROR := '0';

   UPDATE PCLUB.ADMPT_CABENCUESTA ENC
   SET ENC.ADMPC_ESTADO = 'C',
       ENC.ADMPV_USU_MOD = K_USUARIO,
       ENC.ADMPD_FECCANCEL = SYSDATE
   WHERE EXISTS
      (  SELECT 1 FROM (SELECT C.ADMPN_IDCABENC
                        FROM PCLUB.ADMPT_CABENCUESTA C
                        WHERE C.ADMPC_ESTADO = 'E' AND
                              C.ADMPD_FECENVIO >= K_FECHA - 1 AND
                              C.ADMPD_FECENVIO < K_FECHA
                        UNION ALL
                        SELECT C.ADMPN_IDCABENC
                        FROM PCLUB.ADMPT_CABENCUESTA C
                        WHERE (C.ADMPC_ESTADO = 'P' OR C.ADMPC_ESTADO = 'E') AND
                               C.ADMPD_FECINIENC < K_FECHA - 1
                        )CON
          WHERE CON.ADMPN_IDCABENC = ENC.ADMPN_IDCABENC
      );
 COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := 'Ocurrió un error en el SP ADMPSS_CANCELENCUESTA';
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR = K_CODERROR;
END ADMPSS_CANCELENCUESTA;

--****************************************************************
-- Nombre SP           :  ADMPSS_VALIDA_GENERA_ENCUESTA
-- Propósito           :  Verifica si se Generara el Registro de Encuesta
-- Input               :  K_TIPO_DOC    - Tipo de Documento
--                        K_NUM_DOC     - Numero de Documento
-- Output              :  K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Susana Ramos
-- Fec Creación        :
-- Fec Actualización   :  20/01/2013
--****************************************************************

PROCEDURE ADMPSS_VALIDA_GENERA_ENCUESTA(K_TIPO_DOC VARCHAR2,
                                        K_NUM_DOC VARCHAR2,
                                        K_CODERROR OUT NUMBER,
                                        K_DESCERROR OUT VARCHAR2) IS
V_CONT_REG NUMBER;
K_FEC_INIVAL VARCHAR2(25);
EX_ERROR EXCEPTION;
BEGIN

  K_CODERROR := 0;
  SELECT '01/' || to_char(SYSDATE - numtoyminterval(1, 'MONTH'), 'MM/YYYY') INTO K_FEC_INIVAL
  FROM DUAL;
   --Verifica si el Cliente Tiene Registros en ADMPT_MOVENCUESTA, generados desde el Dia 01 del mes Anterior
   --Hasta el Ultimo Canje Generado
   --En caso haya Registros, devolvera K_CODERROR = 1 y no se generara el registro caso contrario
   --Devuelve 0 y se generara el Registro de encuesta

  SELECT COUNT(1) INTO V_CONT_REG
  FROM PCLUB.ADMPT_CABENCUESTA M
  WHERE M.ADMPV_TIPO_DOC = K_TIPO_DOC AND M.ADMPV_NUM_DOC = K_NUM_DOC AND
        M.ADMPD_FECINIENC >= TO_DATE(K_FEC_INIVAL,'DD/MM/YYYY');

  IF V_CONT_REG > 0 THEN
    K_CODERROR := 35;
    RAISE EX_ERROR;
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
      K_DESCERROR := 'Ocurrió un error en el SP ADMPSS_VALIDA_GENERA_ENCUESTA';
      SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
      FROM PCLUB.ADMPT_ERRORES_CC
      WHERE ADMPN_COD_ERROR = K_CODERROR;
END ADMPSS_VALIDA_GENERA_ENCUESTA;

--****************************************************************
-- Nombre SP           :  ADMPSS_CLIE_BLACK_LIST
-- Propósito           :  Verifica si el Cliente se encuentra en Black List,
-- Input               :  K_TELEFONO    - Numero de telefono del Cliente
-- Output              :  K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Susana Ramos
-- Fec Creación        :
-- Fec Actualización   :  20/01/2013
--****************************************************************

PROCEDURE ADMPSS_CLIE_BLACK_LIST(K_TELEFONO IN VARCHAR2,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2) IS
V_CONT_REG NUMBER;
K_FONO VARCHAR2(25);
EX_ERROR EXCEPTION;
BEGIN

  K_CODERROR := 0;
  K_FONO := '51' || K_TELEFONO;

  SELECT COUNT(1) INTO V_CONT_REG
  FROM dm.reporte_blist_telefonos@dbl_reptdm_d
  WHERE MSISDN = K_FONO;

  IF V_CONT_REG > 0 THEN
    K_CODERROR  := 34;
    RAISE EX_ERROR;
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
    K_DESCERROR := 'Ocurrió un error en el SP ADMPSS_CLIE_BLACK_LIST';
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR = K_CODERROR;
END ADMPSS_CLIE_BLACK_LIST;

--****************************************************************
--Función que devuelve la fecha entre extremo de las horas
--es decir desde la 00:00:00  hasta las 23:59:59
--para búsquedas realizadas con fechas y horas
--****************************************************************

FUNCTION ADMPSS_GETFECHA_LIM(K_FECHA IN DATE,K_TIPO IN SMALLINT ) RETURN DATE
IS
chFecha VARCHAR2(30);
dtFecha DATE;
BEGIN

  chFecha := '';
  dtFecha := NULL;
  IF K_TIPO = 1 THEN
    --INFERIOR
    chFecha := to_char(K_FECHA,'DD/MM/YYYY');
    chFecha := chFecha || ' 00:00:00';
    dtFecha := TO_DATE(chFecha,'DD/MM/YYYY HH24:MI:SS');
  ELSE
    --SUPERIOR
    chFecha := to_char(K_FECHA,'DD/MM/YYYY');
    chFecha := chFecha || ' 23:59:59';
    dtFecha := TO_DATE(chFecha,'DD/MM/YYYY HH24:MI:SS');
  END IF;
  RETURN (dtFecha);
EXCEPTION
  WHEN OTHERS THEN
    RETURN (dtFecha);
END;

--****************************************************************
-- Nombre SP           :  ADMPSI_REGENCUESTA
-- Propósito           :  Permite registrar la encuesta
-- Input               :  K_NOM_ENCU
--                        K_FECINI
--                        K_FECFIN
--                        K_ESTADO
--                        K_USUARIO
-- Output              :  K_ID_ENCU
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  15/02/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE ADMPSI_REGENCUESTA(K_NOM_ENCU IN VARCHAR2,
                             K_FECINI IN VARCHAR2,
                             K_FECFIN IN VARCHAR2,
                             K_ESTADO IN CHAR,
                             K_USUARIO IN VARCHAR2,
                             K_ID_ENCU OUT NUMBER,
                             K_CODERROR OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2) IS
V_CONT NUMBER;
V_NOM_ENCU VARCHAR2(100);
V_FECINI DATE;
V_FECFIN DATE;
EX_ERROR EXCEPTION;
BEGIN

  V_NOM_ENCU := UPPER(K_NOM_ENCU);
  V_FECINI := TO_DATE(K_FECINI,'DD/MM/YYYY');
  V_FECFIN := TO_DATE(K_FECFIN,'DD/MM/YYYY');

  CASE
    WHEN K_NOM_ENCU IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el nombre. '; RAISE EX_ERROR;
    WHEN K_FECINI   IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese la fecha de inicio. '; RAISE EX_ERROR;
    WHEN K_FECFIN   IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese la fecha de fin. '; RAISE EX_ERROR;
    WHEN K_ESTADO   IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el estado. '; RAISE EX_ERROR;
    WHEN V_FECFIN < V_FECINI THEN K_CODERROR := 4; K_DESCERROR := 'La fecha de fin no puede ser menor a la fecha de inicio. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  SELECT COUNT(1) INTO V_CONT
  FROM PCLUB.ADMPT_ENCUESTA
  WHERE UPPER(ADMPV_NOMBRE) = V_NOM_ENCU;

  IF V_CONT > 0 THEN
    K_CODERROR := 4;
    K_DESCERROR := 'Existe una encuesta con el mismo nombre.';
    RAISE EX_ERROR;
  END IF;

  SELECT COUNT(1) INTO V_CONT
  FROM PCLUB.ADMPT_ENCUESTA
  WHERE ADMPC_ESTADO = 'A'
        AND ((V_FECINI >= ADMPD_FECINI AND V_FECINI <= ADMPD_FECFIN) OR (V_FECFIN >= ADMPD_FECINI AND V_FECFIN <= ADMPD_FECFIN)
              OR (ADMPD_FECINI >= V_FECINI AND ADMPD_FECINI <= V_FECFIN) OR (ADMPD_FECFIN >= V_FECINI AND ADMPD_FECFIN <= V_FECFIN));

  IF V_CONT > 0 THEN
    K_CODERROR := 4;
    K_DESCERROR := 'Existe una encuesta activa en el rango de fechas. ';
    RAISE EX_ERROR;
  END IF;

  SELECT NVL(PCLUB.ADMPT_ENCUESTA_SQ.NEXTVAL,0) INTO K_ID_ENCU FROM DUAL;

  IF K_ID_ENCU = 0 THEN
     K_CODERROR := 39;
     K_DESCERROR := 'No se generó un correlativo para la encuesta. ';
     RAISE EX_ERROR;
  END IF;

  INSERT INTO PCLUB.ADMPT_ENCUESTA(
    ADMPN_IDENC,
    ADMPV_NOMBRE,
    ADMPD_FECINI,
    ADMPD_FECFIN,
    ADMPC_ESTADO,
    ADMPV_USU_REG,
    ADMPD_FEC_REG
  )
  VALUES(
    K_ID_ENCU,
    V_NOM_ENCU,
    V_FECINI,
    V_FECFIN,
    K_ESTADO,
    K_USUARIO,
    SYSDATE
  );

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
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR = K_CODERROR;
END ADMPSI_REGENCUESTA;

--****************************************************************
-- Nombre SP           :  ADMPSU_UPDENCUESTA
-- Propósito           :  Permite actualizar la encuesta
-- Input               :  K_ID_ENCU
--                        K_NOM_ENCU
--                        K_FECINI
--                        K_FECFIN
--                        K_ESTADO
--                        K_USUARIO
-- Output              :  K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  15/02/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE ADMPSU_UPDENCUESTA(K_ID_ENCU IN NUMBER,
                             K_NOM_ENCU IN VARCHAR2,
                             K_FECINI IN VARCHAR2,
                             K_FECFIN IN VARCHAR2,
                             K_ESTADO IN CHAR,
                             K_USUARIO IN VARCHAR2,
                             K_CODERROR OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2) IS
V_CONT NUMBER;
V_NOM_ENCU VARCHAR2(100);
V_FECINI DATE;
V_FECFIN DATE;
EX_ERROR EXCEPTION;
BEGIN

  V_NOM_ENCU := UPPER(K_NOM_ENCU);
  V_FECINI := TO_DATE(K_FECINI,'DD/MM/YYYY');
  V_FECFIN := TO_DATE(K_FECFIN,'DD/MM/YYYY');

  CASE
    WHEN K_ID_ENCU  IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el código de encuesta. '; RAISE EX_ERROR;
    WHEN K_ESTADO   IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el estado. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  IF K_ESTADO = 'A'  THEN
    IF K_NOM_ENCU IS NULL THEN
      K_CODERROR := 4;
      K_DESCERROR := 'Ingrese el nombre. ';
      RAISE EX_ERROR;
    END IF;

    IF V_FECFIN < V_FECINI THEN
      K_CODERROR := 4;
      K_DESCERROR := 'La fecha de fin no puede ser menor a la fecha de inicio. ';
      RAISE EX_ERROR;
    END IF;

    SELECT COUNT(1) INTO V_CONT
    FROM PCLUB.ADMPT_ENCUESTA
    WHERE UPPER(ADMPV_NOMBRE) = V_NOM_ENCU
          AND ADMPN_IDENC <> K_ID_ENCU ;

    IF V_CONT > 0 THEN
      K_CODERROR := 4;
      K_DESCERROR := 'Existe una encuesta con el mismo nombre. ';
      RAISE EX_ERROR;
    END IF;

    SELECT COUNT(1) INTO V_CONT
    FROM PCLUB.ADMPT_ENCUESTA
    WHERE ADMPC_ESTADO = 'A'
          AND ((V_FECINI >= ADMPD_FECINI AND V_FECINI <= ADMPD_FECFIN) OR (V_FECFIN >= ADMPD_FECINI AND V_FECFIN <= ADMPD_FECFIN)
                OR (ADMPD_FECINI >= V_FECINI AND ADMPD_FECINI <= V_FECFIN) OR (ADMPD_FECFIN >= V_FECINI AND ADMPD_FECFIN <= V_FECFIN))
          AND ADMPN_IDENC <> K_ID_ENCU;

    IF V_CONT > 0 THEN
      K_CODERROR := 4;
      K_DESCERROR := 'Existe una encuesta activa en el rango de fechas. ';
      RAISE EX_ERROR;
    END IF;
  END IF;

  SELECT COUNT(1) INTO V_CONT
  FROM PCLUB.ADMPT_ENCUESTA
  WHERE ADMPN_IDENC = K_ID_ENCU;

  IF V_CONT < 1 THEN
    K_CODERROR := 38;
    K_DESCERROR := 'El código de encuesta no existe. ';
    RAISE EX_ERROR;
    END IF;

  UPDATE PCLUB.ADMPT_ENCUESTA
  SET ADMPV_NOMBRE = NVL(V_NOM_ENCU,ADMPV_NOMBRE),
      ADMPD_FECINI = NVL(V_FECINI,ADMPD_FECINI),
      ADMPD_FECFIN = NVL(V_FECFIN,ADMPD_FECFIN),
      ADMPC_ESTADO = K_ESTADO,
      ADMPV_USU_MOD = K_USUARIO,
      ADMPD_FEC_MOD = SYSDATE
  WHERE ADMPN_IDENC = K_ID_ENCU;

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
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR = K_CODERROR;
END ADMPSU_UPDENCUESTA;

--****************************************************************
-- Nombre SP           :  ADMPSS_LISENCUESTA
-- Propósito           :  Permite Consultar la encuesta
-- Input               :  K_NOMBRE
--                        K_ESTADO
-- Output              :  K_CUR_ENCUESTA
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  12/02/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE ADMPSS_LISENCUESTA(K_NOMBRE IN VARCHAR2,
                             K_ESTADO IN VARCHAR2,
                             K_CUR_ENCUESTA OUT SYS_REFCURSOR,
                             K_CODERROR OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2) IS
V_NOMBRE VARCHAR2(100);
EX_ERROR EXCEPTION;
BEGIN

 V_NOMBRE := UPPER(K_NOMBRE);
 K_CODERROR := 0;
 K_DESCERROR := '';

 OPEN K_CUR_ENCUESTA FOR
 SELECT ADMPN_IDENC AS ENCUN_ID,
        ADMPV_NOMBRE AS ENCUV_NOMBRE,
        ADMPD_FECINI AS ENCUD_FECINI,
        ADMPD_FECFIN AS ENCUD_FECFIN,
        F_FECHACADENA(ADMPD_FECINI) AS FECINI_CADENA,
        F_FECHACADENA(ADMPD_FECFIN) AS FECFIN_CADENA,
        ADMPC_ESTADO AS ENCUC_ESTADO,
        CASE ADMPC_ESTADO
             WHEN 'A' THEN 'ACTIVO'
             WHEN 'B' THEN 'DESACTIVADO'
             ELSE '' END AS NOMBREESTADO,
        CASE ADMPC_ESTADO
          WHEN 'A' THEN 'Desactivar'
          WHEN 'B' THEN 'Activar'
          ELSE '' END AS ACCION
 FROM PCLUB.ADMPT_ENCUESTA
 WHERE ADMPV_NOMBRE LIKE '%' || V_NOMBRE || '%'
       AND ADMPC_ESTADO = NVL(K_ESTADO,ADMPC_ESTADO)
 ORDER BY ADMPN_IDENC;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR = K_CODERROR;
END ADMPSS_LISENCUESTA;

--****************************************************************
-- Nombre SP           :  ADMPSI_REGPREGUNTA
-- Propósito           :  Permite registrar la pregunta
-- Input               :  K_ID_ENCU
--                        K_DES_PREGUNTA
--                        K_NRO_ORDEN
--                        K_ESTADO
--                        K_USUARIO
-- Output              :  K_ID_PREG
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  15/02/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE ADMPSI_REGPREGUNTA(K_ID_ENCU IN NUMBER,
                             K_DES_PREGUNTA IN VARCHAR2,
                             K_NRO_ORDEN IN NUMBER,
                             K_ESTADO IN CHAR,
                             K_USUARIO IN VARCHAR2,
                             K_ID_PREG OUT NUMBER,
                             K_CODERROR OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2) IS
V_CONT NUMBER;
V_DES_PREGUNTA VARCHAR2(200);
V_DES_VALIDA VARCHAR2(300);
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_ID_ENCU      IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el código de la encuesta. '; RAISE EX_ERROR;
    WHEN K_DES_PREGUNTA IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese la descripción. '; RAISE EX_ERROR;
    WHEN K_NRO_ORDEN    IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el orden. '; RAISE EX_ERROR;
    WHEN K_ESTADO       IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el estado. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  V_DES_PREGUNTA := UPPER(K_DES_PREGUNTA);

  SELECT COUNT(1) INTO V_CONT
  FROM PCLUB.ADMPT_PREGUNTA
  WHERE ADMPN_IDENC = K_ID_ENCU
        AND UPPER(ADMPV_PREGUNTA) = V_DES_PREGUNTA;

  IF V_CONT > 0 THEN
    K_CODERROR := 4;
    K_DESCERROR := 'Existe una pregunta con la misma descripción. ';
    RAISE EX_ERROR;
  END IF;

  SELECT COUNT(1) INTO V_CONT
  FROM PCLUB.ADMPT_PREGUNTA
  WHERE ADMPN_IDENC = K_ID_ENCU
        AND ADMPV_ORDEN = K_NRO_ORDEN;

  IF V_CONT > 0 THEN
    K_CODERROR := 4;
    K_DESCERROR := 'Existe una pregunta con el mismo orden. ';
    RAISE EX_ERROR;
  END IF;

  V_DES_VALIDA := F_VALTAMANOPREGRESP(0,0,K_DES_PREGUNTA,'P');
  IF SUBSTR(V_DES_VALIDA,1,1) = '0' THEN
    IF LENGTH(V_DES_VALIDA) = 1 THEN
      K_CODERROR := 4;
      K_DESCERROR := 'La longitud de la descripción excede el tamaño máximo permitido. ';
    ELSE
      K_CODERROR := -1;
      K_DESCERROR := SUBSTR(V_DES_VALIDA,2);
    END IF;
    RAISE EX_ERROR;
  END IF;

  SELECT NVL(PCLUB.ADMPT_PREGUNTA_SQ.NEXTVAL,0) INTO K_ID_PREG FROM DUAL;

  IF K_ID_PREG = 0 THEN
    K_CODERROR := 39;
    K_DESCERROR := 'No se generó el correlativo para la pregunta. ';
    RAISE EX_ERROR;
  END IF;

  INSERT INTO PCLUB.ADMPT_PREGUNTA(
    ADMPN_IDPREGUNTA,
    ADMPN_IDENC,
    ADMPV_PREGUNTA,
    ADMPV_ORDEN,
    ADMPC_ESTADO,
    ADMPV_USU_REG,
    ADMPD_FEC_REG
  )
  VALUES(
    K_ID_PREG,
    K_ID_ENCU,
    K_DES_PREGUNTA,
    K_NRO_ORDEN,
    K_ESTADO,
    K_USUARIO,
    SYSDATE
  );

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
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR = K_CODERROR;
END ADMPSI_REGPREGUNTA;

--****************************************************************
-- Nombre SP           :  ADMPSU_UPDPREGUNTA
-- Propósito           :  Permite actualizar la pregunta
-- Input               :  K_ID_PREG
--                        K_ID_ENCU
--                        K_DES_PREGUNTA
--                        K_NRO_ORDEN
--                        K_ESTADO
--                        K_USUARIO
-- Output              :  K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  18/02/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE ADMPSU_UPDPREGUNTA(K_ID_PREG IN NUMBER,
                             K_ID_ENCU IN NUMBER,
                             K_DES_PREGUNTA IN VARCHAR2,
                             K_NRO_ORDEN IN NUMBER,
                             K_ESTADO IN CHAR,
                             K_USUARIO IN VARCHAR2,
                             K_CODERROR OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2) IS
V_CONT NUMBER;
V_DES_PREGUNTA VARCHAR2(200);
V_DES_VALIDA VARCHAR2(300);
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_ID_PREG IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el código de la pregunta. '; RAISE EX_ERROR;
    WHEN K_ESTADO  IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el estado. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  IF K_ESTADO = 'A' THEN
    CASE
      WHEN K_ID_ENCU      IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el código de la encuesta. '; RAISE EX_ERROR;
      WHEN K_DES_PREGUNTA IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese la descripción. '; RAISE EX_ERROR;
      WHEN K_NRO_ORDEN    IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el orden. '; RAISE EX_ERROR;
      ELSE K_CODERROR := 0; K_DESCERROR := '';
    END CASE;

    V_DES_PREGUNTA := UPPER(K_DES_PREGUNTA);

    SELECT COUNT(1) INTO V_CONT
    FROM PCLUB.ADMPT_PREGUNTA
    WHERE ADMPN_IDENC = K_ID_ENCU
          AND UPPER(ADMPV_PREGUNTA) = V_DES_PREGUNTA
          AND ADMPN_IDPREGUNTA <> K_ID_PREG;

    IF V_CONT > 0 THEN
      K_CODERROR := 4;
      K_DESCERROR := 'Existe una pregunta con la misma descripción. ';
      RAISE EX_ERROR;
    END IF;

    SELECT COUNT(1) INTO V_CONT
    FROM PCLUB.ADMPT_PREGUNTA
    WHERE ADMPN_IDENC = K_ID_ENCU
          AND ADMPV_ORDEN = K_NRO_ORDEN
          AND ADMPN_IDPREGUNTA <> K_ID_PREG;

    IF V_CONT > 0 THEN
      K_CODERROR := 4;
      K_DESCERROR := 'Existe una pregunta con el mismo orden. ';
      RAISE EX_ERROR;
    END IF;

    V_DES_VALIDA := F_VALTAMANOPREGRESP(K_ID_PREG,0,K_DES_PREGUNTA,'P');
    IF SUBSTR(V_DES_VALIDA,1,1) = '0' THEN
      IF LENGTH(V_DES_VALIDA) = 1 THEN
        K_CODERROR := 4;
        K_DESCERROR := 'La longitud de la descripción excede el tamaño máximo permitido. ';
      ELSE
        K_CODERROR := -1;
        K_DESCERROR := SUBSTR(V_DES_VALIDA,2);
      END IF;
      RAISE EX_ERROR;
    END IF;
  END IF;

  SELECT COUNT(1) INTO V_CONT
  FROM PCLUB.ADMPT_PREGUNTA
  WHERE ADMPN_IDPREGUNTA = K_ID_PREG;

  IF V_CONT < 1 THEN
    K_CODERROR := 38;
    K_DESCERROR := 'El código de pregunta no existe. ';
    RAISE EX_ERROR;
  END IF;

  UPDATE PCLUB.ADMPT_PREGUNTA
  SET ADMPV_PREGUNTA = NVL(K_DES_PREGUNTA,ADMPV_PREGUNTA),
      ADMPV_ORDEN = NVL(K_NRO_ORDEN,ADMPV_ORDEN),
      ADMPC_ESTADO = K_ESTADO,
      ADMPV_USU_MOD = K_USUARIO,
      ADMPD_FEC_MOD = SYSDATE
  WHERE ADMPN_IDPREGUNTA = K_ID_PREG;

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
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR = K_CODERROR;
END ADMPSU_UPDPREGUNTA;

--****************************************************************
-- Nombre SP           :  ADMPSS_LISPREGUNTA
-- Propósito           :  Permite Consultar la respuesta
-- Input               :  K_ID_ENC
--                        K_ESTADO
-- Output              :  K_CUR_PREGUNTA
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  13/02/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE ADMPSS_LISPREGUNTA(K_ID_ENCU IN NUMBER,
                             K_ESTADO IN VARCHAR2,
                             K_CUR_PREGUNTA OUT SYS_REFCURSOR,
                             K_CODERROR OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
BEGIN

 K_CODERROR := 0;
 K_DESCERROR := '';

 IF K_ID_ENCU IS NULL THEN
   K_CODERROR  := 38;
   K_DESCERROR := 'El código de encuesta no es válido.';
   RAISE EX_ERROR;
 END IF;

 OPEN K_CUR_PREGUNTA FOR
 SELECT ADMPN_IDPREGUNTA AS PREGN_ID,
        ADMPN_IDENC AS ENCUN_ID,
        ADMPV_PREGUNTA AS PREGV_PREGUNTA,
        ADMPC_ESTADO AS PREGC_ESTADO,
        ADMPV_ORDEN PREGN_ORDEN,
        CASE ADMPC_ESTADO
          WHEN 'A' THEN 'ACTIVO'
          WHEN 'B' THEN 'DESACTIVADO'
          ELSE '' END AS NOMBREESTADO,
        CASE ADMPC_ESTADO
          WHEN 'A' THEN 'Desactivar'
          WHEN 'B' THEN 'Activar'
          ELSE '' END AS ACCION,
        F_GETTAMANOPREGRESP(ADMPN_IDPREGUNTA) AS TAMANHO
 FROM PCLUB.ADMPT_PREGUNTA
 WHERE ADMPN_IDENC = K_ID_ENCU
       AND ADMPC_ESTADO = NVL(K_ESTADO,ADMPC_ESTADO)
 ORDER BY ADMPN_IDENC, ADMPV_ORDEN;

EXCEPTION
  WHEN EX_ERROR THEN
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR = K_CODERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR = K_CODERROR;
END ADMPSS_LISPREGUNTA;

--****************************************************************
-- Nombre SP           :  ADMPSI_REGRESPUESTA
-- Propósito           :  Permite registrar la respuesta
-- Input               :  K_ID_PREG
--                        K_DES_RESPUESTA
--                        K_DES_OPCION
--                        K_ESTADO
--                        K_USUARIO
-- Output              :  K_ID_RESP
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  18/02/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE ADMPSI_REGRESPUESTA(K_ID_PREG IN NUMBER,
                              K_DES_RESPUESTA IN VARCHAR2,
                              K_DES_OPCION IN VARCHAR2,
                              K_ESTADO IN CHAR,
                              K_USUARIO IN VARCHAR2,
                              K_ID_RESP OUT NUMBER,
                              K_CODERROR OUT NUMBER,
                              K_DESCERROR OUT VARCHAR2) IS

V_CONT NUMBER;
V_DES_RESPUESTA VARCHAR2(20);
V_DES_OPCION VARCHAR2(5);
V_DES_VALIDA VARCHAR2(300);
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_ID_PREG       IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el código de la pregunta. '; RAISE EX_ERROR;
    WHEN K_DES_RESPUESTA IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese la descripción. '; RAISE EX_ERROR;
    WHEN K_DES_OPCION    IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese la opción. '; RAISE EX_ERROR;
    WHEN K_ESTADO        IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el estado. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  V_DES_RESPUESTA := UPPER(K_DES_RESPUESTA);
  V_DES_OPCION := UPPER(K_DES_OPCION);

  SELECT COUNT(1) INTO V_CONT
  FROM PCLUB.ADMPT_RESPUESTA
  WHERE ADMPN_IDPREGUNTA = K_ID_PREG
        AND UPPER(ADMPV_RESPUESTA) = V_DES_RESPUESTA;

  IF V_CONT > 0 THEN
    K_CODERROR := 4;
    K_DESCERROR := 'Existe una respuesta con la misma descripción. ';
    RAISE EX_ERROR;
  END IF;

  SELECT COUNT(1) INTO V_CONT
  FROM PCLUB.ADMPT_RESPUESTA
  WHERE ADMPN_IDPREGUNTA = K_ID_PREG
        AND UPPER(ADMPV_OPCION) = V_DES_OPCION;

  IF V_CONT > 0 THEN
    K_CODERROR := 4;
    K_DESCERROR := 'Existe una respuesta con la misma opción. ';
    RAISE EX_ERROR;
  END IF;

  V_DES_VALIDA := F_VALTAMANOPREGRESP(K_ID_PREG,0,K_DES_RESPUESTA||' '||K_DES_OPCION,'R');
  IF SUBSTR(V_DES_VALIDA,1,1) = '0' THEN
    IF LENGTH(V_DES_VALIDA) = 1 THEN
      K_CODERROR := 4;
      K_DESCERROR := 'La longitud de la descripción excede el tamaño máximo permitido. ';
    ELSE
      K_CODERROR := -1;
      K_DESCERROR := SUBSTR(V_DES_VALIDA,2);
    END IF;
    RAISE EX_ERROR;
  END IF;

  SELECT NVL(PCLUB.ADMPT_RESPUESTA_SQ.NEXTVAL,0) INTO K_ID_RESP FROM DUAL;

  IF K_ID_RESP = 0 THEN
    K_CODERROR := 39;
    K_DESCERROR := 'No se generó el correlativo para la respuesta. ';
    RAISE EX_ERROR;
  END IF;

  INSERT INTO PCLUB.ADMPT_RESPUESTA(
    ADMPN_IDRESP,
    ADMPN_IDPREGUNTA,
    ADMPV_RESPUESTA,
    ADMPV_OPCION,
    ADMPC_ESTADO,
    ADMPV_USU_REG,
    ADMPD_FEC_REG
  )
  VALUES(
    K_ID_RESP,
    K_ID_PREG,
    K_DES_RESPUESTA,
    K_DES_OPCION,
    K_ESTADO,
    K_USUARIO,
    SYSDATE
  );

  COMMIT;
EXCEPTION
  WHEN EX_ERROR THEN
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR = K_CODERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR = K_CODERROR;
END ADMPSI_REGRESPUESTA;

--****************************************************************
-- Nombre SP           :  ADMPSU_UPDRESPUESTA
-- Propósito           :  Permite actualizar la respuesta
-- Input               :  K_ID_RESP
--                        K_ID_PREG
--                        K_DES_RESPUESTA
--                        K_DES_OPCION
--                        K_ESTADO
--                        K_USUARIO
-- Output              :  K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  18/02/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE ADMPSU_UPDRESPUESTA(K_ID_RESP IN NUMBER,
                              K_ID_PREG IN NUMBER,
                              K_DES_RESPUESTA IN VARCHAR2,
                              K_DES_OPCION IN VARCHAR2,
                              K_ESTADO IN CHAR,
                              K_USUARIO IN VARCHAR2,
                              K_CODERROR OUT NUMBER,
                              K_DESCERROR OUT VARCHAR2) IS
V_CONT NUMBER;
V_DES_RESPUESTA VARCHAR2(20);
V_DES_OPCION VARCHAR2(5);
V_DES_VALIDA VARCHAR2(300);
EX_ERROR EXCEPTION;
BEGIN

  CASE
    WHEN K_ID_RESP IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el código de la respuesta. '; RAISE EX_ERROR;
    WHEN K_ESTADO  IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el estado. '; RAISE EX_ERROR;
    ELSE K_CODERROR := 0; K_DESCERROR := '';
  END CASE;

  IF K_ESTADO = 'A' THEN
    CASE
      WHEN K_ID_PREG       IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese el código de la pregunta. '; RAISE EX_ERROR;
      WHEN K_DES_RESPUESTA IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese la descripción. '; RAISE EX_ERROR;
      WHEN K_DES_OPCION    IS NULL THEN K_CODERROR := 4; K_DESCERROR := 'Ingrese la opción. '; RAISE EX_ERROR;
      ELSE K_CODERROR := 0; K_DESCERROR := '';
    END CASE;

    V_DES_RESPUESTA := UPPER(K_DES_RESPUESTA);
    V_DES_OPCION := UPPER(K_DES_OPCION);

    SELECT COUNT(1) INTO V_CONT
    FROM PCLUB.ADMPT_RESPUESTA
    WHERE ADMPN_IDPREGUNTA = K_ID_PREG
          AND UPPER(ADMPV_RESPUESTA) = V_DES_RESPUESTA
          AND ADMPN_IDRESP <> K_ID_RESP;

    IF V_CONT > 0 THEN
       K_CODERROR := 4;
       K_DESCERROR := 'Existe una respuesta con la misma descripción. ';
       RAISE EX_ERROR;
    END IF;

    SELECT COUNT(1) INTO V_CONT
    FROM PCLUB.ADMPT_RESPUESTA
    WHERE ADMPN_IDPREGUNTA = K_ID_PREG
          AND UPPER(ADMPV_OPCION) = V_DES_OPCION
          AND ADMPN_IDRESP <> K_ID_RESP;

    IF V_CONT > 0 THEN
       K_CODERROR := 4;
       K_DESCERROR := 'Existe una respuesta con la misma opción. ';
       RAISE EX_ERROR;
    END IF;

    V_DES_VALIDA := F_VALTAMANOPREGRESP(K_ID_PREG,K_ID_RESP,K_DES_RESPUESTA||' '||K_DES_OPCION,'R');
    IF SUBSTR(V_DES_VALIDA,1,1) = '0' THEN
      IF LENGTH(V_DES_VALIDA) = 1 THEN
        K_CODERROR := 4;
        K_DESCERROR := 'La longitud de la descripción excede el tamaño máximo permitido. ';
      ELSE
        K_CODERROR := -1;
        K_DESCERROR := SUBSTR(V_DES_VALIDA,2);
      END IF;
      RAISE EX_ERROR;
    END IF;
  END IF;

  SELECT COUNT(1) INTO V_CONT
  FROM PCLUB.ADMPT_RESPUESTA
  WHERE ADMPN_IDRESP = K_ID_RESP;

  IF V_CONT < 1 THEN
     K_CODERROR := 38;
     K_DESCERROR := 'El código de respuesta no existe. ';
     RAISE EX_ERROR;
  END IF;

  UPDATE PCLUB.ADMPT_RESPUESTA
  SET ADMPV_RESPUESTA = NVL(K_DES_RESPUESTA,ADMPV_RESPUESTA),
      ADMPV_OPCION = NVL(K_DES_OPCION,ADMPV_OPCION),
      ADMPC_ESTADO = K_ESTADO,
      ADMPV_USU_MOD = K_USUARIO,
      ADMPD_FEC_MOD = SYSDATE
  WHERE ADMPN_IDRESP = K_ID_RESP;

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
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR = K_CODERROR;
END ADMPSU_UPDRESPUESTA;

--****************************************************************
-- Nombre SP           :  ADMPSS_LISRESPUESTA
-- Propósito           :  Permite Consultar la respuesta
-- Input               :  K_ID_PRE
--                        K_ESTADO
-- Output              :  K_CUR_RESPUESTA
--                        K_CODERROR
--                        K_DESCERROR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  13/02/2013
-- Fec Actualización   :
--****************************************************************

PROCEDURE ADMPSS_LISRESPUESTA(K_ID_PREG IN NUMBER,
                              K_ESTADO IN VARCHAR2,
                              K_CUR_RESPUESTA OUT SYS_REFCURSOR,
                              K_CODERROR OUT NUMBER,
                              K_DESCERROR OUT VARCHAR2) IS
EX_ERROR EXCEPTION;
BEGIN

 K_CODERROR := 0;
 K_DESCERROR := '';

 IF K_ID_PREG IS NULL THEN
   K_CODERROR := 38;
   K_DESCERROR := 'El código de pregunta no es válido.';
   RAISE EX_ERROR;
 END IF;

 OPEN K_CUR_RESPUESTA FOR
 SELECT ADMPN_IDRESP AS RESPN_ID,
        ADMPN_IDPREGUNTA AS PREGN_ID,
        ADMPV_OPCION AS RESPV_OPCION,
        ADMPV_RESPUESTA AS RESPV_RESPUESTA,
        ADMPC_ESTADO AS RESPC_ESTADO,
        CASE ADMPC_ESTADO
            WHEN 'A' THEN 'ACTIVO'
            WHEN 'B' THEN 'DESACTIVADO'
            ELSE '' END AS NOMBREESTADO,
        CASE ADMPC_ESTADO
          WHEN 'A' THEN 'Desactivar'
          WHEN 'B' THEN 'Activar'
          ELSE '' END AS ACCION
 FROM PCLUB.ADMPT_RESPUESTA
 WHERE ADMPN_IDPREGUNTA = K_ID_PREG
       AND ADMPC_ESTADO = NVL(K_ESTADO,ADMPC_ESTADO)
 ORDER BY ADMPN_IDPREGUNTA, ADMPV_OPCION;

EXCEPTION
  WHEN EX_ERROR THEN
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR = K_CODERROR;
  WHEN OTHERS THEN
    K_CODERROR := -1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR = K_CODERROR;
END ADMPSS_LISRESPUESTA;

--****************************************************************
-- Nombre Function     :  F_FECHACADENA
-- Propósito           :  Convierte la fecha en formato de cadena
-- Input               :  K_FECHA
-- Output              :  V_FECHA
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  12/02/2013
-- Fec Actualización   :
--****************************************************************

FUNCTION F_FECHACADENA(K_FECHA IN DATE) RETURN VARCHAR2 IS
 V_FECHA VARCHAR2(10);
BEGIN

  V_FECHA := TO_CHAR(K_FECHA,'DD/MM/YYYY');
  RETURN V_FECHA;
EXCEPTION
  WHEN OTHERS THEN
    RETURN '';
END F_FECHACADENA;

--****************************************************************
-- Nombre Function     :  F_VALTAMANOPREGRESP
-- Propósito           :  Valida el tamaño de pregunta con sus respuestas
-- Input               :  K_IDPREG
--                     :  K_IDRESP
--                     :  K_DESC
--                     :  K_TABLA
-- Output              :  V_FECHA
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  12/02/2013
-- Fec Actualización   :
--****************************************************************

FUNCTION F_VALTAMANOPREGRESP(K_IDPREG NUMBER,
                             K_IDRESP NUMBER,
                             K_DESC IN VARCHAR2,
                             K_TABLA IN CHAR) RETURN VARCHAR2 IS

CURSOR CUR_RESPUESTA(K_IDPREG VARCHAR2) IS
SELECT ADMPV_RESPUESTA || ' ' || ADMPV_OPCION
FROM PCLUB.ADMPT_RESPUESTA
WHERE ADMPC_ESTADO = 'A'
      AND ADMPN_IDPREGUNTA = K_IDPREG
      AND ADMPN_IDRESP <> K_IDRESP;
V_VALIDACION VARCHAR2(300) := '0';
V_CONT NUMBER := 0;
V_TAMANO_PREG NUMBER;
V_DESCRESP VARCHAR2(30);
V_VALORMAXIMO NUMBER;
V_DESCERROR VARCHAR2(300);
EX_ERROR EXCEPTION;
BEGIN

  BEGIN
    SELECT CAST(ADMPV_VALOR AS INTEGER) INTO V_VALORMAXIMO
    FROM PCLUB.ADMPT_PARAMSIST
    WHERE ADMPV_DESC = 'TAMANO_MAX_PREGUNTA_RESPUESTA';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_DESCERROR := 'No está registrado el parámetro TAMANO_MAX_PREGUNTA_RESPUESTA';
      RAISE EX_ERROR;
    WHEN TOO_MANY_ROWS THEN
      V_DESCERROR := 'Existen varios registros del parámetro TAMANO_MAX_PREGUNTA_RESPUESTA';
      RAISE EX_ERROR;
  END;

  IF K_TABLA = 'P' THEN
    IF K_IDPREG < 1 THEN
      IF LENGTH(K_DESC) <= V_VALORMAXIMO THEN
        V_VALIDACION := '1';
      END IF;
    ELSE
      OPEN CUR_RESPUESTA(K_IDPREG);
      FETCH CUR_RESPUESTA INTO V_DESCRESP;
      WHILE CUR_RESPUESTA%FOUND LOOP
        V_CONT := V_CONT + LENGTH(V_DESCRESP);
        FETCH CUR_RESPUESTA INTO V_DESCRESP;
      END LOOP;
      CLOSE CUR_RESPUESTA;

      IF V_CONT + LENGTH(K_DESC) <= V_VALORMAXIMO THEN
        V_VALIDACION := '1';
      END IF;
    END IF;
  ELSE
    OPEN CUR_RESPUESTA(K_IDPREG);
    FETCH CUR_RESPUESTA INTO V_DESCRESP;
    WHILE CUR_RESPUESTA%FOUND LOOP
      V_CONT := V_CONT + LENGTH(V_DESCRESP);
      FETCH CUR_RESPUESTA INTO V_DESCRESP;
    END LOOP;
    CLOSE CUR_RESPUESTA;

    SELECT LENGTH(ADMPV_PREGUNTA) INTO V_TAMANO_PREG
    FROM PCLUB.ADMPT_PREGUNTA
    WHERE ADMPN_IDPREGUNTA = K_IDPREG;

    IF V_CONT + V_TAMANO_PREG + LENGTH(K_DESC) <= V_VALORMAXIMO THEN
      V_VALIDACION := '1';
    END IF;
  END IF;

  RETURN V_VALIDACION;
EXCEPTION
  WHEN EX_ERROR THEN
    RETURN '0' || V_DESCERROR;
  WHEN OTHERS THEN
    RETURN '0' || 'Error en función F_VALTAMANOPREGRESP. ' || SUBSTR(SQLERRM,1,250);
END F_VALTAMANOPREGRESP;

--****************************************************************
-- Nombre Function     :  F_GETTAMANOPREGRESP
-- Propósito           :  Obtiene el tamaño de pregunta con sus respuestas
-- Input               :  K_IDPREG
-- Output              :  V_VALOR
-- Creado por          :  Oscar Paucar
-- Fec Creación        :  02/04/2013
-- Fec Actualización   :
--****************************************************************

FUNCTION F_GETTAMANOPREGRESP(K_IDPREG NUMBER) RETURN NUMBER IS
V_CONT NUMBER := 0;
V_TAMANO_PREG NUMBER;
V_DESCRESP VARCHAR2(30);
V_VALOR NUMBER;
CURSOR CUR_RESPUESTA(K_IDPREG VARCHAR2) IS
SELECT ADMPV_RESPUESTA || ' ' || ADMPV_OPCION
FROM PCLUB.ADMPT_RESPUESTA
WHERE ADMPC_ESTADO = 'A'
      AND ADMPN_IDPREGUNTA = K_IDPREG;
BEGIN

  OPEN CUR_RESPUESTA(K_IDPREG);
  FETCH CUR_RESPUESTA INTO V_DESCRESP;
  WHILE CUR_RESPUESTA%FOUND LOOP
    V_CONT := V_CONT + LENGTH(V_DESCRESP);
    FETCH CUR_RESPUESTA INTO V_DESCRESP;
  END LOOP;
  CLOSE CUR_RESPUESTA;

  SELECT LENGTH(ADMPV_PREGUNTA) INTO V_TAMANO_PREG
  FROM PCLUB.ADMPT_PREGUNTA
  WHERE ADMPN_IDPREGUNTA = K_IDPREG;

  V_VALOR := V_CONT + V_TAMANO_PREG;
  RETURN V_VALOR;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END F_GETTAMANOPREGRESP;

END PKG_CC_ENCUESTA;
/