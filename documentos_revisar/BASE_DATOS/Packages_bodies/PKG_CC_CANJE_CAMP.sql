create or replace package body PCLUB.PKG_CC_CANJE_CAMP is

  procedure SYSFSI_CAMPANA(P_SYCAV_DESCRIPCION in VARCHAR2,
                           P_SYCAD_FEC_INICAMP in DATE,
                           P_SYCAD_FEC_FINCAMP in DATE,
                           P_SYCAV_USUARIO_REG in VARCHAR2,
                           o_resultado         out varchar2,
                           o_mensaje           out varchar2) is

    nREGISTRO NUMBER;

  begin

    SELECT PCLUB.EAI_SEQ_SYCAN_IDECAMPANA.NEXTVAL INTO nREGISTRO FROM DUAL;
    INSERT INTO PCLUB.SYSFT_CAMPANA
      (SYCAN_IDENTIFICADOR,
       SYCAV_DESCRIPCION,
       SYCAD_FEC_INICAMP,
       SYCAD_FEC_FINCAMP,
       SYCAV_USUARIO_REG,
       SYCAD_FEC_REG)
    VALUES
      (nREGISTRO,
       P_SYCAV_DESCRIPCION,
       P_SYCAD_FEC_INICAMP,
       P_SYCAD_FEC_FINCAMP,
       P_SYCAV_USUARIO_REG,
       SYSDATE);
    commit;
    o_resultado := '0';
    o_mensaje   := 'OK';
  exception
    when others then
      o_resultado := '1';
      o_mensaje   := SUBSTR('ERROR : ' || SQLERRM, 1, 250);
      ROLLBACK;

  end;

  procedure SYSFSS_CAMPANA(P_SYCAV_DESCRIPCION in VARCHAR2,
                           P_SYCAV_ESTADO      in VARCHAR2,
                           o_resultado         out varchar2,
                           o_mensaje           out varchar2,
                           o_cursor            out SYS_REFCURSOR) is

    query_str VARCHAR2(5000);

  BEGIN

    query_str := 'SELECT CA.SYCAN_IDENTIFICADOR,
               CA.SYCAV_DESCRIPCION,
               CA.SYCAD_FEC_INICAMP,
               CA.SYCAD_FEC_FINCAMP,
               CA.SYCAV_USUARIO_REG,
               CA.SYCAD_FEC_REG,
               CA.SYCAV_USUARIO_MOD,
               CA.SYCAD_FEC_MOD
          FROM PCLUB.SYSFT_CAMPANA CA
          WHERE CA.SYCAN_IDENTIFICADOR IS NOT NULL';

    IF P_SYCAV_DESCRIPCION IS NOT NULL THEN
      query_str := query_str || ' AND UPPER(CA.SYCAV_DESCRIPCION) LIKE ''%' ||
                   P_SYCAV_DESCRIPCION || '%''';
    END IF;

    IF P_SYCAV_ESTADO = 'A' THEN
      query_str := query_str ||
                   ' AND TRUNC(SYSDATE) <= TRUNC(CA.SYCAD_FEC_FINCAMP)';
    END IF;

    query_str := query_str ||
                 ' ORDER BY CA.SYCAD_FEC_INICAMP DESC, CA.SYCAV_DESCRIPCION';

    OPEN o_cursor FOR query_str;

    o_resultado := '0';
    o_mensaje   := 'OK';

  exception
    when others then
      o_resultado := '1';
      o_mensaje   := SUBSTR('ERROR : ' || SQLERRM, 1, 250);

  end;

  procedure SYSFSU_CAMPANA(P_SYCAN_IDENTIFICADOR in VARCHAR2,
                           P_SYCAV_DESCRIPCION   in VARCHAR2,
                           P_SYCAD_FEC_INICAMP   in DATE,
                           P_SYCAD_FEC_FINCAMP   in DATE,
                           P_SYCAV_USUARIO_MOD   IN VARCHAR2,
                           o_resultado           out varchar2,
                           o_mensaje             out varchar2) is

  FECHA_ERROR              EXCEPTION;
  NUM_EVENTOS              NUMBER;

  begin

  SELECT COUNT(1)
  INTO NUM_EVENTOS
  FROM PCLUB.SYSFT_EVENTO E
   WHERE E.SYCAN_IDENTIFICADOR = P_SYCAN_IDENTIFICADOR
     AND (TRUNC(E.SYEVD_FECINI_EVENTO) < TRUNC(P_SYCAD_FEC_INICAMP)
      OR TRUNC(E.SYEVD_FECFIN_EVENTO) > TRUNC(P_SYCAD_FEC_FINCAMP));

  IF NUM_EVENTOS > 0 THEN
        RAISE FECHA_ERROR;
      END IF;

    UPDATE PCLUB.SYSFT_CAMPANA
       SET SYCAV_DESCRIPCION = P_SYCAV_DESCRIPCION,
           SYCAD_FEC_INICAMP = P_SYCAD_FEC_INICAMP,
           SYCAD_FEC_FINCAMP = P_SYCAD_FEC_FINCAMP,
           SYCAV_USUARIO_MOD = P_SYCAV_USUARIO_MOD,
           SYCAD_FEC_MOD     = SYSDATE
     where SYCAN_IDENTIFICADOR = P_SYCAN_IDENTIFICADOR;

    commit;
    o_resultado := '0';
    o_mensaje   := 'OK';
  exception
    WHEN FECHA_ERROR THEN
      o_resultado := '1';
      o_mensaje   := 'Fechas de eventos no validos';
      ROLLBACK;
    when others then
      o_resultado := '-1';
      o_mensaje   := SUBSTR('ERROR : ' || SQLERRM, 1, 250);
      ROLLBACK;

  end;

  procedure SYSFSI_EVENTO(P_SYCAN_IDENTIFICADOR in NUMBER,
                          P_SYEVV_DESCRIPCION   in VARCHAR2,
                          P_SYEVD_FECINI_EVENTO in DATE,
                          P_SYEVD_FECFIN_EVENTO in DATE,
                          P_SYEVV_PALABRA_CLAVE in VARCHAR2,
                          P_SYEVN_PUNTOSCLARO   in NUMBER,
                          P_SYEVN_MONTO_PAGO    in NUMBER,
                          P_SYEVV_USUARIO_REG   in VARCHAR2,
                          P_SYEVD_FEC_REG       in DATE,
                          P_SYEVV_USUARIO_MOD   in VARCHAR2,

                          P_SYEVD_FEC_MOD       in DATE,
                          P_ADMPV_ID_PROCLA     in VARCHAR2,
                          P_ADMPV_DESC          in VARCHAR2,
                          P_ADMPV_CAMPANA       in VARCHAR2,
                          o_resultado           out varchar2,
                          o_mensaje             out varchar2) is

    nREGISTRO   NUMBER;
    V_COD_TPOPR VARCHAR2(20);
    V_EXISTE    NUMBER;
    ERR_DATOS_INVALIDOS EXCEPTION;
    ERR_PREMIO_DUP EXCEPTION;
    ERR_PALABRA_CLAVE_DUP EXCEPTION;
  begin
    
    -- Se valida datos de entrada
    IF (P_ADMPV_DESC IS NULL OR P_ADMPV_CAMPANA IS NULL) THEN
      RAISE ERR_DATOS_INVALIDOS;
    END IF;
    
    -- Se valida duplicidad en la Palabra Clave
    SELECT COUNT(1) INTO V_EXISTE 
    FROM PCLUB.SYSFT_EVENTO A
    WHERE UPPER(A.SYEVV_PALABRA_CLAVE) = UPPER(P_SYEVV_PALABRA_CLAVE)
    AND ( (TRUNC(P_SYEVD_FECINI_EVENTO) BETWEEN TRUNC(A.SYEVD_FECINI_EVENTO) AND TRUNC(A.SYEVD_FECFIN_EVENTO))
    OR (TRUNC(P_SYEVD_FECFIN_EVENTO) BETWEEN TRUNC(A.SYEVD_FECINI_EVENTO) AND TRUNC(A.SYEVD_FECFIN_EVENTO)) );

    IF V_EXISTE > 0 THEN
      RAISE ERR_PALABRA_CLAVE_DUP;
    END IF;

    -- Se valida duplicidad en el Id Procla
    SELECT COUNT(1)
      INTO V_EXISTE
      FROM PCLUB.ADMPT_PREMIO
     WHERE ADMPV_ID_PROCLA = P_ADMPV_ID_PROCLA;
    
    IF V_EXISTE > 0 THEN
      RAISE ERR_PREMIO_DUP;
    END IF;

    -- Se obtiene el codigo del Tipo de Premio 'Beneficios'
    SELECT ADMPV_COD_TPOPR
      INTO V_COD_TPOPR
      FROM PCLUB.ADMPT_TIPO_PREMIO
     WHERE ADMPV_DESC = 'Beneficios';

    -- Se inserta el registro en la tabla 'Premio'
    INSERT INTO PCLUB.ADMPT_PREMIO
      (ADMPV_ID_PROCLA,
       ADMPV_COD_TPOPR,
       ADMPV_DESC,
       ADMPN_PUNTOS,
       ADMPN_PAGO,
       ADMPC_ESTADO,
       ADMPN_COD_SERVC,
       ADMPV_CAMPANA)
    VALUES
      (P_ADMPV_ID_PROCLA,
       V_COD_TPOPR,
       P_ADMPV_DESC,
       P_SYEVN_PUNTOSCLARO,
       0,
       'A',
       NULL,
       TO_CHAR(TO_DATE(P_ADMPV_CAMPANA,'DD/MM/YYYY'),'MON-YY'));

    -- Se obtiene el PK de la tabla 'Evento'
    SELECT PCLUB.EAI_SEQ_SYCAN_IDEEVENTO.NEXTVAL INTO nREGISTRO FROM DUAL;

    -- Se inserta el registro en la tabla 'Evento'
    INSERT INTO PCLUB.SYSFT_EVENTO
      (SYEVN_IDENTIFICADOR,
       SYCAN_IDENTIFICADOR,
       SYEVV_DESCRIPCION,
       SYEVD_FECINI_EVENTO,
       SYEVD_FECFIN_EVENTO,
       SYEVV_PALABRA_CLAVE,
       SYEVN_PUNTOSCLARO,
       SYEVN_MONTO_PAGO,
       SYEVV_USUARIO_REG,
       SYEVD_FEC_REG,
       ADMPV_ID_PROCLA)
    VALUES
      (nREGISTRO,
       P_SYCAN_IDENTIFICADOR,
       P_SYEVV_DESCRIPCION,
       P_SYEVD_FECINI_EVENTO,
       P_SYEVD_FECFIN_EVENTO,
       UPPER(P_SYEVV_PALABRA_CLAVE),
       P_SYEVN_PUNTOSCLARO,
       P_SYEVN_MONTO_PAGO,
       P_SYEVV_USUARIO_REG,
       P_SYEVD_FEC_REG,
       P_ADMPV_ID_PROCLA);

    commit;
    o_resultado := '0';
    o_mensaje   := 'OK';

  exception
    WHEN ERR_DATOS_INVALIDOS THEN
      o_resultado := '2';
      o_mensaje   := 'Ingreso datos insuficientes para el registro del evento';
      ROLLBACK;
    WHEN ERR_PREMIO_DUP THEN
      o_resultado := '3';
      o_mensaje   := 'Ya existe el Codigo del premio: ' ||
                     P_ADMPV_ID_PROCLA;
      ROLLBACK;                    
    WHEN ERR_PALABRA_CLAVE_DUP THEN
      o_resultado := '4';
      o_mensaje   := 'Palabra Clave ya existe para otro evento';
      ROLLBACK;
    when others then
      o_resultado := '1';
      o_mensaje   := SUBSTR('ERROR : ' || SQLERRM, 1, 350);
      ROLLBACK;

  end;

  procedure SYSFSS_EVENTO(P_SYEVV_DESCRIPCION   in VARCHAR2,
                          P_SYCAN_IDENTIFICADOR in NUMBER,
                          P_SYEVV_ESTADO        in VARCHAR2,
                          o_resultado           out varchar2,
                          o_mensaje             out varchar2,
                          o_cursor              out SYS_REFCURSOR) is

    query_str VARCHAR2(5000);

  BEGIN

    query_str := 'SELECT FE.SYEVN_IDENTIFICADOR,
               FE.SYCAN_IDENTIFICADOR,
               FE.SYEVV_DESCRIPCION,
               FC.SYCAV_DESCRIPCION,
               FE.SYEVD_FECINI_EVENTO,
               FE.SYEVD_FECFIN_EVENTO,
               FE.SYEVV_PALABRA_CLAVE,
               FE.SYEVN_PUNTOSCLARO,
               FE.SYEVN_MONTO_PAGO,
               FE.SYEVV_USUARIO_REG,
               FE.SYEVD_FEC_REG,
               FE.SYEVV_USUARIO_MOD,
               FE.SYEVD_FEC_MOD,
               AP.ADMPV_ID_PROCLA,
               AP.ADMPV_DESC,
               AP.ADMPV_CAMPANA
          FROM PCLUB.SYSFT_EVENTO FE
          LEFT JOIN PCLUB.SYSFT_CAMPANA FC
          ON FC.SYCAN_IDENTIFICADOR = FE.SYCAN_IDENTIFICADOR
          LEFT JOIN PCLUB.ADMPT_PREMIO AP
          ON AP.ADMPV_ID_PROCLA = FE.ADMPV_ID_PROCLA
      WHERE FE.SYEVN_IDENTIFICADOR IS NOT NULL';

    IF TRIM(P_SYCAN_IDENTIFICADOR) IS NOT NULL THEN
      query_str := query_str || ' AND FE.SYCAN_IDENTIFICADOR = ''' ||
                   P_SYCAN_IDENTIFICADOR || '''';
    END IF;

    IF TRIM(P_SYEVV_DESCRIPCION) IS NOT NULL THEN
      query_str := query_str || ' AND UPPER(FE.SYEVV_DESCRIPCION) LIKE ''%' ||
                   UPPER(P_SYEVV_DESCRIPCION) || '%''';
    END IF;

    IF P_SYEVV_ESTADO = 'A' THEN
      query_str := query_str ||
                   ' AND TRUNC(SYSDATE) <= TRUNC(FE.SYEVD_FECFIN_EVENTO)';
    END IF;

    query_str := query_str ||
                 ' ORDER BY FE.SYEVD_FECINI_EVENTO DESC, FC.SYCAV_DESCRIPCION, FE.SYEVV_DESCRIPCION';

    OPEN o_cursor FOR query_str;

    o_resultado := '0';
    o_mensaje   := 'OK';

  exception
    when others then
      o_resultado := '1';
      o_mensaje   := SUBSTR('ERROR : ' || SQLERRM, 1, 250);

  end;

  procedure SYSFSU_EVENTO(P_SYEVN_IDENTIFICADOR in NUMBER,
                          P_SYCAN_IDENTIFICADOR in NUMBER,
                          P_SYEVV_DESCRIPCION   in VARCHAR2,
                          P_SYEVD_FECINI_EVENTO in DATE,
                          P_SYEVD_FECFIN_EVENTO in DATE,
                          P_SYEVV_PALABRA_CLAVE in VARCHAR2,
                          P_SYEVN_PUNTOSCLARO   in NUMBER,
                          P_SYEVN_MONTO_PAGO    in NUMBER,
                          P_SYEVV_USUARIO_REG   in VARCHAR2,
                          P_SYEVD_FEC_REG       in DATE,
                          P_SYEVV_USUARIO_MOD   in VARCHAR2,
                          P_SYEVD_FEC_MOD       in DATE,
                          P_ADMPV_DESC          in VARCHAR2,
                          P_ADMPV_CAMPANA       in VARCHAR2,
                          o_resultado           out varchar2,
                          o_mensaje             out varchar2) is

    V_ID_PROCLA VARCHAR2(15);
    V_COD_TPOPR VARCHAR2(2);
    V_EXISTE    NUMBER;
    ERR_DATOS_INVALIDOS EXCEPTION;
    ERR_NO_EXISTE_PREMIO EXCEPTION;
    ERR_PALABRA_CLAVE_DUP EXCEPTION;

  begin

    -- Se obtiene el Id Procla del evento 
    SELECT ADMPV_ID_PROCLA
      INTO V_ID_PROCLA
      FROM PCLUB.SYSFT_EVENTO
     WHERE SYEVN_IDENTIFICADOR = P_SYEVN_IDENTIFICADOR;

    -- Se valida que el Id Procla exista
    SELECT COUNT(1)
      INTO V_EXISTE
      FROM PCLUB.ADMPT_PREMIO
     WHERE ADMPV_ID_PROCLA = V_ID_PROCLA;
     
    IF V_ID_PROCLA IS NULL OR V_EXISTE = 0 THEN
      RAISE ERR_NO_EXISTE_PREMIO;
    END IF;

    -- Se obtiene el codigo del Tipo de Premio 'Beneficios'
    SELECT ADMPV_COD_TPOPR
      INTO V_COD_TPOPR
      FROM PCLUB.ADMPT_TIPO_PREMIO
     WHERE ADMPV_DESC = 'Beneficios';

    -- Se valida duplicidad en la Palabra Clave
    SELECT COUNT(1) INTO V_EXISTE FROM PCLUB.SYSFT_EVENTO A
    WHERE A.SYEVN_IDENTIFICADOR <> P_SYEVN_IDENTIFICADOR
    AND UPPER(A.SYEVV_PALABRA_CLAVE) = UPPER(P_SYEVV_PALABRA_CLAVE)
    AND ( (TRUNC(P_SYEVD_FECINI_EVENTO) BETWEEN TRUNC(A.SYEVD_FECINI_EVENTO) AND TRUNC(A.SYEVD_FECFIN_EVENTO))
    OR (TRUNC(P_SYEVD_FECFIN_EVENTO) BETWEEN TRUNC(A.SYEVD_FECINI_EVENTO) AND TRUNC(A.SYEVD_FECFIN_EVENTO)) );

    IF V_EXISTE > 0 THEN
      RAISE ERR_PALABRA_CLAVE_DUP;
    END IF;

    -- Se actualiza la tabla 'Evento'
    update PCLUB.SYSFT_EVENTO
       set SYEVN_IDENTIFICADOR = P_SYEVN_IDENTIFICADOR,
           SYCAN_IDENTIFICADOR = P_SYCAN_IDENTIFICADOR,
           SYEVV_DESCRIPCION   = P_SYEVV_DESCRIPCION,
           SYEVD_FECINI_EVENTO = P_SYEVD_FECINI_EVENTO,
           SYEVD_FECFIN_EVENTO = P_SYEVD_FECFIN_EVENTO,
           SYEVV_PALABRA_CLAVE = UPPER(P_SYEVV_PALABRA_CLAVE),
           SYEVN_PUNTOSCLARO   = P_SYEVN_PUNTOSCLARO,
           SYEVN_MONTO_PAGO    = P_SYEVN_MONTO_PAGO,
           SYEVV_USUARIO_MOD   = P_SYEVV_USUARIO_MOD,
           SYEVD_FEC_MOD       = P_SYEVD_FEC_MOD
     where SYEVN_IDENTIFICADOR = P_SYEVN_IDENTIFICADOR;

    -- Se actualiza la tabla 'Premio'
    update PCLUB.ADMPT_PREMIO
       set ADMPV_DESC = P_ADMPV_DESC,
           ADMPN_PUNTOS = P_SYEVN_PUNTOSCLARO
     where ADMPV_ID_PROCLA = V_ID_PROCLA;

    commit;
    o_resultado := '0';
    o_mensaje   := 'OK';
  exception
    WHEN ERR_DATOS_INVALIDOS THEN
      o_resultado := '2';
      o_mensaje   := 'Ingreso datos insuficientes para la actualizacion del evento';
      ROLLBACK;
    WHEN ERR_NO_EXISTE_PREMIO THEN
      o_resultado := '3';
      o_mensaje   := 'No existe el codigo del premio: ' || V_ID_PROCLA;
      ROLLBACK;
    WHEN ERR_PALABRA_CLAVE_DUP THEN
      o_resultado := '4';
      o_mensaje   := 'Palabra Clave ya existe para otro evento';
      ROLLBACK;
    when others then
      o_resultado := '1';
      o_mensaje   := SUBSTR('ERROR : ' || SQLERRM, 1, 250);
      ROLLBACK;
  end;

  procedure SYSFSI_COD_CANJE(P_SYEVN_IDENTIFICADOR in NUMBER,
                             P_SYCCC_ESTADO        in VARCHAR2,
                             P_SYCCV_CODIGO_CANJE  in VARCHAR2,
                             P_SYCCV_USUARIO_REG   in VARCHAR2,
                             o_resultado           out varchar2,
                             o_mensaje             out varchar2) is

    nREGISTRO NUMBER;

  begin

    SELECT PCLUB.EAI_SEQ_SYCAN_IDECANJE.NEXTVAL INTO nREGISTRO FROM DUAL;
    INSERT INTO PCLUB.SYSFT_COD_CANJE
      (SYCCN_IDENTIFICADOR,
       SYEVN_IDENTIFICADOR,
       SYCCC_ESTADO,
       SYCCV_CODIGO_CANJE,
       SYCCV_USUARIO_REG,
       SYCCD_FEC_REG)
    VALUES
      (nREGISTRO,
       P_SYEVN_IDENTIFICADOR,
       P_SYCCC_ESTADO,
       P_SYCCV_CODIGO_CANJE,
       P_SYCCV_USUARIO_REG,
       SYSDATE);
    commit;
    o_resultado := '0';
    o_mensaje   := 'OK';
  exception
    when DUP_VAL_ON_INDEX then
      o_resultado := '1';
      o_mensaje   := SUBSTR('ERROR : ' || SQLERRM, 1, 250);
      ROLLBACK;
    when others then
      o_resultado := '-1';
      o_mensaje   := SUBSTR('ERROR : ' || SQLERRM, 1, 250);
      ROLLBACK;

  end;

  procedure SYSFSS_COD_CANJE(P_SYCCV_CODIGO_CANJE in VARCHAR2,
                             P_SYCCV_LINEA        in VARCHAR2,
                             P_SYCCC_ESTADO       in VARCHAR2,
                             P_FEC_VIGENCIA       in DATE,
                             o_resultado          out varchar2,
                             o_mensaje            out varchar2,
                             o_cursor             out SYS_REFCURSOR) is

    query_str VARCHAR2(5000);

  BEGIN

    query_str := 'SELECT C.SYCCN_IDENTIFICADOR,
             C.SYEVN_IDENTIFICADOR,
             CASE
             WHEN C.SYCCC_ESTADO = ''0'' AND TRUNC(SYSDATE) >
                  TRUNC(E.SYEVD_FECFIN_EVENTO) THEN ''VENCIDO''
             ELSE
              DECODE(C.SYCCC_ESTADO, ''0'', ''ACTIVO'', ''1'', ''BLOQUEADO'', C.SYCCC_ESTADO)
             END ESTADO_CODIGO,
             C.SYCCV_CODIGO_CANJE,
             C.SYCCV_USUARIO_REG,
             C.SYCCD_FEC_REG,
             C.SYCCV_USUARIO_MOD,
             C.SYCCD_FEC_MOD,
             C.SYCCV_DESC_TIPODOC,
             C.SYCCV_NUMDOC,
             C.SYCCV_NOMBRE_TIT,
             C.SYCCV_LINEA,
             E.SYEVV_DESCRIPCION,
             E.SYEVD_FECINI_EVENTO,
             E.SYEVD_FECFIN_EVENTO,
             CA.SYCAV_DESCRIPCION,
             C.SYCCV_TIPO_PROD
        FROM PCLUB.SYSFT_COD_CANJE C
        LEFT JOIN PCLUB.SYSFT_EVENTO E
        ON E.SYEVN_IDENTIFICADOR = C.SYEVN_IDENTIFICADOR
        LEFT JOIN PCLUB.SYSFT_CAMPANA CA
        ON CA.SYCAN_IDENTIFICADOR = E.SYCAN_IDENTIFICADOR
       WHERE C.SYCCN_IDENTIFICADOR IS NOT NULL';

    IF P_SYCCV_CODIGO_CANJE IS NOT NULL THEN
      query_str := query_str || ' AND UPPER(C.SYCCV_CODIGO_CANJE) LIKE ''%' ||
                   UPPER(P_SYCCV_CODIGO_CANJE) || '%''';
    END IF;

    IF P_SYCCV_LINEA IS NOT NULL THEN
      query_str := query_str || ' AND C.SYCCV_LINEA = ''' || P_SYCCV_LINEA || '''';
    END IF;

    IF P_SYCCC_ESTADO IS NOT NULL THEN
      query_str := query_str ||
                   ' AND CASE WHEN C.SYCCC_ESTADO = ''0'' AND TRUNC(SYSDATE) > TRUNC(E.SYEVD_FECFIN_EVENTO) THEN ''2'' ELSE C.SYCCC_ESTADO END = ''' ||
                   P_SYCCC_ESTADO || '''';
    END IF;

    IF P_FEC_VIGENCIA IS NOT NULL THEN
      query_str := query_str ||
                   ' AND TRUNC(E.SYEVD_FECINI_EVENTO) <= ''' || P_FEC_VIGENCIA || '''' ||
                   ' AND TRUNC(E.SYEVD_FECFIN_EVENTO) >= ''' || P_FEC_VIGENCIA || '''';
    END IF;

    query_str := query_str ||
                 ' ORDER BY E.SYEVD_FECINI_EVENTO DESC, CA.SYCAV_DESCRIPCION, E.SYEVV_DESCRIPCION, C.SYCCV_CODIGO_CANJE';

    OPEN o_cursor FOR query_str;

    o_resultado := '0';
    o_mensaje   := 'OK';
  exception
    when others then
      o_resultado := '1';
      o_mensaje   := SUBSTR('ERROR : ' || SQLERRM, 1, 250);
  end;



  PROCEDURE SYSFSU_COD_CANJE(K_EVENTO        IN NUMBER,
                             K_USUARIO_MOD   IN VARCHAR2,
                             K_DESC_TIPODOC  IN VARCHAR2,
                             K_NUMDOC        IN VARCHAR2,
                             K_NOMBRE_TIT    IN VARCHAR2,
                             K_LINEA         IN VARCHAR2,
                             K_TIPO_PROD     IN VARCHAR2,
                             K_IDCANJE       IN VARCHAR2,
                             K_COD_CANJE     OUT VARCHAR2,
                             K_FECFIN_EVENTO OUT VARCHAR2,
                             o_resultado     OUT VARCHAR2,
                             o_mensaje       OUT VARCHAR2) IS

    V_ID_COD_CANJE NUMBER;
    V_COD_CANJE    VARCHAR2(30);
    V_FECHA_FIN    VARCHAR2(30);
    V_COD_CLI      VARCHAR2(40);
    V_COD_TPOCL    VARCHAR2(2);
    V_TIPO_DOC     VARCHAR2(20);
    V_NUM_DOC      VARCHAR2(20);
    K_CODERROR_EX  NUMBER;
    K_DESCERROR_EX VARCHAR2(400);
    NO_TICKET EXCEPTION;
    V_EXISTE NUMBER;

    V_K_EXITO NUMBER;
    V_K_COD_ERROR NUMBER;
    V_K_DESCERROR VARCHAR2(400);

  BEGIN

    -- Valida si existe un codigo de canje disponible
    SELECT COUNT(1)
      INTO V_EXISTE
      FROM PCLUB.SYSFT_COD_CANJE CC
      LEFT JOIN PCLUB.SYSFT_EVENTO FE
        ON CC.SYEVN_IDENTIFICADOR = FE.SYEVN_IDENTIFICADOR
     WHERE FE.SYEVN_IDENTIFICADOR = K_EVENTO
       AND CC.SYCCC_ESTADO = 0
       AND ( TRUNC(FE.SYEVD_FECINI_EVENTO) <= TRUNC(SYSDATE) AND
           TRUNC(FE.SYEVD_FECFIN_EVENTO) >= TRUNC(SYSDATE) );

    IF V_EXISTE = 0 THEN
      RAISE NO_TICKET;
    END IF;

    -- Obtiene un codigo de canje disponible
    SELECT CC.SYCCN_IDENTIFICADOR,
           CC.SYCCV_CODIGO_CANJE,
           TO_CHAR(FE.SYEVD_FECFIN_EVENTO, 'DD/MM')
      INTO V_ID_COD_CANJE, V_COD_CANJE, V_FECHA_FIN
      FROM PCLUB.SYSFT_COD_CANJE CC
      LEFT JOIN PCLUB.SYSFT_EVENTO FE
        ON CC.SYEVN_IDENTIFICADOR = FE.SYEVN_IDENTIFICADOR
     WHERE FE.SYEVN_IDENTIFICADOR = K_EVENTO
       AND CC.SYCCC_ESTADO = 0
       AND TRUNC(FE.SYEVD_FECINI_EVENTO) <= TRUNC(SYSDATE)
       AND TRUNC(FE.SYEVD_FECFIN_EVENTO) >= TRUNC(SYSDATE)
       AND ROWNUM = 1;

    /**Actualiza el estado del codigo de canje a bloqueado**/
    
    UPDATE PCLUB.SYSFT_COD_CANJE
       SET SYCCC_ESTADO       = '1',
           SYCCV_USUARIO_MOD  = K_USUARIO_MOD,
           SYCCD_FEC_MOD      = SYSDATE,
           SYCCV_DESC_TIPODOC = K_DESC_TIPODOC,
           SYCCV_NUMDOC       = K_NUMDOC,
           SYCCV_NOMBRE_TIT   = K_NOMBRE_TIT,
           SYCCV_LINEA        = K_LINEA,
           SYCCV_TIPO_PROD    = K_TIPO_PROD
     WHERE SYCCN_IDENTIFICADOR = V_ID_COD_CANJE;

    -- Obtiene los datos del Canje
    SELECT ADMPV_COD_CLI, ADMPV_COD_TPOCL
      INTO V_COD_CLI, V_COD_TPOCL
      FROM PCLUB.ADMPT_CANJE
     WHERE ADMPV_ID_CANJE = K_IDCANJE;
     
    -- Obtiene los datos del Cliente
    SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
      INTO V_TIPO_DOC, V_NUM_DOC
      FROM PCLUB.ADMPT_CLIENTE
     WHERE ADMPV_COD_CLI = V_COD_CLI;

    -- Libera el Bloqueo de la Bolsa
    PCLUB.PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(V_TIPO_DOC,
                                             V_NUM_DOC,
                                             V_COD_TPOCL,
                                             K_CODERROR_EX,
                                             K_DESCERROR_EX);

    COMMIT;

    IF K_CODERROR_EX <> 0 THEN
      o_resultado := TO_CHAR(K_CODERROR_EX);
      o_mensaje   := o_mensaje || 'Error en SP ADMPU_LIBBLOQUEOBOLSA: ' ||
                     K_DESCERROR_EX;
    END IF;
    
    K_COD_CANJE     := V_COD_CANJE;
    K_FECFIN_EVENTO := V_FECHA_FIN;
    o_resultado     := '0';
    o_mensaje       := 'OK';

  EXCEPTION
    WHEN NO_TICKET THEN
      o_resultado := '3';
      o_mensaje   := 'No disponible codigos de canje';
      
       -- REALIZAR COMPENSACION DEL REGISTRO DEL CANJE (LIMPIAR DATA)
      PCLUB.PKG_CC_TRANSACCION.ADMPSS_ELIMINARCANJE(K_IDCANJE,V_K_EXITO, V_K_COD_ERROR, V_K_DESCERROR);
    WHEN OTHERS then
      o_resultado := '1';
      o_mensaje   := SUBSTR('ERROR : ' || SQLERRM, 1, 250);
      ROLLBACK;

      -- REALIZAR COMPENSACION DEL REGISTRO DEL CANJE (LIMPIAR DATA)
      PCLUB.PKG_CC_TRANSACCION.ADMPSS_ELIMINARCANJE(K_IDCANJE,V_K_EXITO, V_K_COD_ERROR, V_K_DESCERROR);
  END;

  PROCEDURE SYSFSS_OBTENER_PUNTOS(P_PALABRA_CLAVE        in VARCHAR2,
                          o_IDENTIFICADOR_EVENTO out NUMBER,
                          o_PUNTOSCLARO          out NUMBER,
                          o_MONTO_PAGO           out NUMBER,
                          o_ID_PROCLA            out varchar2,
                          o_DESC_PREMIO          out varchar2,
                          o_FEC_CAMPANA          out varchar2,
                          o_DESC_EVENTO          out varchar2,
                          o_resultado            out varchar2,
                          o_mensaje              out varchar2) IS
  NO_TICKET EXCEPTION;
  V_STOCK_TICKETS NUMBER;

  BEGIN
    SELECT E.SYEVN_IDENTIFICADOR,
           E.SYEVN_PUNTOSCLARO,
           E.SYEVN_MONTO_PAGO,
           E.ADMPV_ID_PROCLA,
           AP.ADMPV_DESC,
           AP.ADMPV_CAMPANA,
           E.SYEVV_DESCRIPCION
      INTO o_IDENTIFICADOR_EVENTO,
           o_PUNTOSCLARO,
           o_MONTO_PAGO,
           o_ID_PROCLA,
           o_DESC_PREMIO,
           o_FEC_CAMPANA,
           o_DESC_EVENTO
      FROM PCLUB.SYSFT_EVENTO E
      LEFT JOIN ADMPT_PREMIO AP
    ON   E.ADMPV_ID_PROCLA=AP.ADMPV_ID_PROCLA
     WHERE UPPER(E.SYEVV_PALABRA_CLAVE) = UPPER(P_PALABRA_CLAVE)
       AND TRUNC(SYSDATE) >= TRUNC(E.SYEVD_FECINI_EVENTO)
       AND TRUNC(SYSDATE) <= TRUNC(E.SYEVD_FECFIN_EVENTO);

     -- Se obtiene el stock de codigos de canje del evento
     IF o_IDENTIFICADOR_EVENTO IS NOT NULL THEN

        SELECT COUNT(1)
          INTO V_STOCK_TICKETS
          FROM PCLUB.SYSFT_COD_CANJE CC
          LEFT JOIN PCLUB.SYSFT_EVENTO FE
            ON CC.SYEVN_IDENTIFICADOR = FE.SYEVN_IDENTIFICADOR
         WHERE FE.SYEVN_IDENTIFICADOR = o_IDENTIFICADOR_EVENTO
           AND CC.SYCCC_ESTADO = 0
           AND TRUNC(FE.SYEVD_FECINI_EVENTO) <= TRUNC(SYSDATE)
           AND TRUNC(FE.SYEVD_FECFIN_EVENTO) >= TRUNC(SYSDATE);

        IF V_STOCK_TICKETS = 0 THEN
          RAISE NO_TICKET;
        END IF;

     END IF;

    o_resultado := 0;
    o_mensaje   := 'OK';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      o_resultado := '1';
      o_mensaje   := SUBSTR('ERROR : ' || SQLERRM, 1, 250);
    WHEN TOO_MANY_ROWS THEN
      o_resultado := '2';
      o_mensaje   := SUBSTR('ERROR : ' || SQLERRM, 1, 250);
    WHEN NO_TICKET THEN
      o_resultado := '3';
      o_mensaje   := 'No disponible codigos de canje';
    WHEN others THEN
      o_resultado := '-1';
      o_mensaje   := SUBSTR('ERROR : ' || SQLERRM, 1, 250);

  END;

end;
/
