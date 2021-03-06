create or replace package body PCLUB.PKG_CC_PROM_FIDELIDAD is

  -- Function and procedure implementations
  PROCEDURE ADMPSS_CON_MULTIPLICA
  (
    P_TELEFONO    IN CC_WHITELIST_FIDELIDAD.WHITV_TELEFONO%TYPE,
    P_RETURN      OUT NUMBER
  )
  IS
  BEGIN
    P_RETURN := 0;

    SELECT COUNT(*)
    INTO   P_RETURN
    FROM   CC_WHITELIST_FIDELIDAD WH,
           CC_SEGMENTO_BENEFICIO SB
    WHERE  WH.WHITV_TELEFONO = P_TELEFONO
           AND WH.WHITC_ESTADO = '1' --ESTADO AFILIACION
           AND WH.WHITV_SEGMENTO = SB.SEGMV_CODIGO
           AND SB.SEBEC_ESTADO = '1' --ESTADO ACTIVO
           AND SB.BENEV_CODIGO = '3' --BENEFICIO MULTIPLICA
           AND ROWNUM = 1;

  EXCEPTION
    WHEN OTHERS THEN
      P_RETURN := 0;
  END;

  PROCEDURE ADMPSS_CON_NRO_FRECUENTE
  (
    P_TELEFONO    IN CC_WHITELIST_FIDELIDAD.WHITV_TELEFONO%TYPE,
    P_RETURN      OUT NUMBER
  )
  IS
  BEGIN
    P_RETURN := 0;

    SELECT COUNT(*)
    INTO   P_RETURN
    FROM   CC_WHITELIST_FIDELIDAD WH,
           CC_SEGMENTO_BENEFICIO SB
    WHERE  WH.WHITV_TELEFONO = P_TELEFONO
           AND WH.WHITC_ESTADO = '1' --ESTADO AFILIACION
           AND WH.WHITV_SEGMENTO = SB.SEGMV_CODIGO
           AND SB.SEBEC_ESTADO = '1' --ESTADO ACTIVO
           AND SB.BENEV_CODIGO = '2' --BENEFICIO NRO. FRECUENTE
           AND ROWNUM = 1;

  EXCEPTION
    WHEN OTHERS THEN
      P_RETURN := 0;
  END;

  PROCEDURE ADMPSS_CON_SEGMENTO
  (
    P_TELEFONO    IN CC_WHITELIST_FIDELIDAD.WHITV_TELEFONO%TYPE,
    P_RETURN      OUT CC_WHITELIST_FIDELIDAD.WHITV_SEGMENTO%TYPE
  )
  IS
  BEGIN
    P_RETURN := '';

    SELECT WH.WHITV_SEGMENTO
    INTO   P_RETURN
    FROM   CC_WHITELIST_FIDELIDAD WH
    WHERE  WH.WHITV_TELEFONO = P_TELEFONO
           AND WH.WHITC_ESTADO = '1'; --ESTADO AFILIACION

  EXCEPTION
    WHEN OTHERS THEN
      P_RETURN := '';
  END;

  PROCEDURE ADMPSU_DESAFILIACION
  (
    P_TELEFONO    IN CC_BLACKLIST_FIDELIDAD.BLCKV_TELEFONO%TYPE,
    P_RETURN      OUT NUMBER
  )
  IS
    P_SEGMENTO  CC_WHITELIST_FIDELIDAD.WHITV_SEGMENTO%TYPE;
  BEGIN
    P_RETURN := 0;

    SELECT WH.WHITV_SEGMENTO
    INTO   P_SEGMENTO
    FROM   CC_WHITELIST_FIDELIDAD WH
    WHERE  WH.WHITV_TELEFONO = P_TELEFONO
           AND WH.WHITC_ESTADO = '1'; --ESTADO AFILIACION

    INSERT INTO CC_BLACKLIST_FIDELIDAD (BLCKV_TELEFONO, BLCKD_FECHA, BLCKV_SEGMENTO)
    VALUES (P_TELEFONO, SYSDATE, P_SEGMENTO);

    DELETE CC_WHITELIST_FIDELIDAD W WHERE W.WHITV_TELEFONO = P_TELEFONO;

    COMMIT;
    P_RETURN := 1;

  EXCEPTION
    WHEN OTHERS THEN
      P_RETURN := 0;
      ROLLBACK;
  END;

  PROCEDURE ADMPSS_CON_SEGM_BENEFICIO
  (
    P_SEGMENTO    IN CC_SEGMENTO_BENEFICIO.SEGMV_CODIGO%TYPE,
    P_CURSOR      OUT K_REF_CURSOR
  )
  is
  BEGIN

    OPEN P_CURSOR FOR
      SELECT SB.SEGMV_CODIGO, BF.BENEV_DESCRIPCION
      FROM   CC_SEGMENTO_BENEFICIO SB,
             CC_BENEFICIO_FIDELIDAD BF
      WHERE  SB.SEBEC_ESTADO = '1'
             AND BF.BENEV_CODIGO = SB.BENEV_CODIGO
             AND SB.SEGMV_CODIGO = NVL(P_SEGMENTO, SB.SEGMV_CODIGO);
  END;

  PROCEDURE ADMPSS_CON_PROM_FIDELIDAD
  (
    P_TELEFONO    IN CC_WHITELIST_FIDELIDAD.WHITV_TELEFONO%TYPE,
    P_RETURN      OUT NUMBER
  )
  IS
    V_SEGMENTO    CC_WHITELIST_FIDELIDAD.WHITV_SEGMENTO%TYPE;
  BEGIN
    V_SEGMENTO := 'X';
    P_RETURN := 0;

    SELECT WH.WHITV_SEGMENTO
    INTO   V_SEGMENTO
    FROM   CC_WHITELIST_FIDELIDAD WH
    WHERE  WH.WHITV_TELEFONO = P_TELEFONO
           AND WH.WHITC_ESTADO = '1'
           AND WH.WHITV_SEGMENTO <> '0';

    IF V_SEGMENTO <> 'X' THEN
      P_RETURN := 1;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      P_RETURN := 0;
  END;

  PROCEDURE ADMPSS_CON_BENEFICIO
  (
    P_TELEFONO    IN CC_WHITELIST_FIDELIDAD.WHITV_TELEFONO%TYPE,
    P_CURSOR      OUT K_REF_CURSOR
  )
  IS
  BEGIN

    OPEN P_CURSOR FOR
      SELECT SB.SEGMV_CODIGO, BF.BENEV_DESCRIPCION
      FROM   CC_WHITELIST_FIDELIDAD WH,
             CC_SEGMENTO_BENEFICIO SB,
             CC_BENEFICIO_FIDELIDAD BF
      WHERE  WH.WHITV_TELEFONO = P_TELEFONO
             AND WH.WHITC_ESTADO = '1'
             AND SB.SEBEC_ESTADO = '1'
             AND BF.BENEV_CODIGO = SB.BENEV_CODIGO
             AND SB.SEGMV_CODIGO = WH.WHITV_SEGMENTO;
  END;
  
  PROCEDURE ADMPSS_PLANES_PERMITIDOS
  (    
    P_CURSOR      OUT K_REF_CURSOR
  )
  IS
  BEGIN
    OPEN P_CURSOR FOR
    SELECT P.SEGMV_PLAN_ID FROM CC_PLANES_PERMITIDOS P;    
  END;
  
  PROCEDURE ADMPSS_DATOS_LINEA
  (    
    P_TELEFONO    IN CC_WHITELIST_FIDELIDAD.WHITV_TELEFONO%TYPE,
    P_TEL_ANT     IN VARCHAR2,    
    P_BENE_ACT    OUT K_REF_CURSOR,
    P_PER_ACT     OUT K_REF_CURSOR,
    P_BENE_PRO    OUT K_REF_CURSOR,
    P_PER_PRO     OUT K_REF_CURSOR,
    P_DET_SEG     OUT K_REF_CURSOR,
    P_COD_ERROR   OUT NUMBER,
    P_MSG_ERROR   OUT VARCHAR2,
    P_PERIODO     OUT CC_WHITELIST_FIDELIDAD.WHITV_SEGMENTO%TYPE,
    P_VIG_FIN     OUT VARCHAR2
  )
  IS   
   V_BLACKLIST NUMBER;
   V_WHITELIST NUMBER;   
   V_ID_PERIODO CC_PERIODO_EVALUACION.SEGMV_CODIGO_PERIODO%TYPE;
   V_TELEFONO CC_WHITELIST_FIDELIDAD.WHITV_TELEFONO%TYPE;
  BEGIN
  
    V_TELEFONO := '51' || P_TELEFONO;
    P_PERIODO := '0';
    SELECT SYSDATE INTO P_VIG_FIN
    FROM DUAL;
    
    P_COD_ERROR := 0;
    P_MSG_ERROR := '';
  
    SELECT COUNT(*) INTO V_WHITELIST
           FROM CC_WHITELIST_FIDELIDAD W
        WHERE W.WHITV_TELEFONO = V_TELEFONO;
    
    IF V_WHITELIST > 0 THEN
    
        BEGIN
          SELECT NVL(P.SEGMV_CODIGO_PERIODO,'0') INTO V_ID_PERIODO
          FROM CC_PERIODO_EVALUACION P
          WHERE P.SEGMV_FECHA_FIN <= SYSDATE
          AND P.SEGMV_FECHA_PRO >= SYSDATE;
        EXCEPTION
          WHEN OTHERS THEN
           V_ID_PERIODO := '0';
        END;
        
        IF V_ID_PERIODO = 0 THEN
        
           SELECT P.SEGMV_CODIGO_PERIODO INTO V_ID_PERIODO
           FROM CC_PERIODO_EVALUACION P
           WHERE P.SEGMV_FECHA_INICIO <= SYSDATE
           AND P.SEGMV_FECHA_FIN >= SYSDATE; 
        
        ELSE
        
           P_COD_ERROR := 2;       
        
        END IF; 
        
        OPEN P_PER_PRO FOR
        SELECT D.SEGMV_DET_INICIO, D.SEGMV_DET_FIN, D.SEGMV_DET_DESCRIPCION 
        FROM CC_DETALLE_PERIODO D
        WHERE D.SEGMV_CODIGO_PERIODO = V_ID_PERIODO ORDER BY 1 ASC;
        
        OPEN P_BENE_PRO FOR
        SELECT S.SEGMV_CODIGO, B.BENEV_CODIGO, B.BENEV_DESCRIPCION FROM CC_SEGMENTO_BENEFICIO S
        INNER JOIN CC_BENEFICIO_FIDELIDAD B
        ON S.BENEV_CODIGO = B.BENEV_CODIGO
        ORDER BY 1 ASC, 2;
        
        OPEN P_DET_SEG FOR
        SELECT 
          SF.SEGMV_CODIGO, SF.SEGMV_REC_MIN, SF.SEGMV_REC_MAX
        FROM  CC_SEGMENTO_FIDELIDAD_DETALLE SF
        WHERE SF.SEGMV_ANT_MIN <= P_TEL_ANT
        AND SF.SEGMV_ANT_MAX > P_TEL_ANT ORDER BY 2 ASC;
                
        IF V_WHITELIST > 0 THEN
        
           
           
           OPEN P_BENE_ACT FOR
           SELECT B.BENEV_CODIGO, B.BENEV_DESCRIPCION FROM CC_BENEFICIO_FIDELIDAD B
           WHERE B.BENEV_CODIGO IN
                 (
                  SELECT S.BENEV_CODIGO FROM CC_SEGMENTO_BENEFICIO S
                  WHERE S.SEGMV_CODIGO = 
                        (
                         SELECT W.WHITV_SEGMENTO FROM CC_WHITELIST_FIDELIDAD W
                         WHERE W.WHITV_TELEFONO = V_TELEFONO
                         )
                  );
                  
           OPEN P_PER_ACT FOR
           SELECT DP.SEGMV_DET_INICIO, DP.SEGMV_DET_FIN, DP.SEGMV_DET_DESCRIPCION 
           FROM CC_DETALLE_PERIODO DP
           WHERE DP.SEGMV_CODIGO_PERIODO = (V_ID_PERIODO - 1) ORDER BY 1 ASC;
           
           SELECT TO_CHAR(E.SEGMV_FECHA_PRO,'DD/MM/YYYY') INTO P_VIG_FIN FROM CC_PERIODO_EVALUACION E
           WHERE E.SEGMV_CODIGO_PERIODO = (V_ID_PERIODO);
           
            BEGIN
              SELECT NVL(W.WHITV_SEGMENTO,'0') INTO P_PERIODO  
              FROM CC_WHITELIST_FIDELIDAD W
              WHERE W.WHITV_TELEFONO = V_TELEFONO;
            EXCEPTION
              WHEN OTHERS THEN
                   P_PERIODO := '0';
            END;
                  
        ELSE                    
        
            OPEN P_BENE_ACT FOR
            SELECT '' BENEV_CODIGO, '' BENEV_DESCRIPCION FROM DUAL;
            
            OPEN P_PER_ACT FOR
            SELECT '' SEGMV_DET_INICIO, '' SEGMV_DET_FIN, '' SEGMV_DET_DESCRIPCION FROM DUAL;
           
            P_COD_ERROR := 1;
        
        END IF;
    
    ELSE
    
        SELECT COUNT(*) INTO V_BLACKLIST
        FROM CC_BLACKLIST_FIDELIDAD B
        WHERE B.BLCKV_TELEFONO = V_TELEFONO;
    
        IF V_BLACKLIST > 0 THEN
           SELECT to_char(MAX(B.BLCKD_FECHA),'DD/MM/YYYY') INTO P_MSG_ERROR
         FROM CC_BLACKLIST_FIDELIDAD B
       WHERE B.BLCKV_TELEFONO = V_TELEFONO;
       
       P_COD_ERROR := -1;
           P_PERIODO := '-1';
           RETURN;
        ELSE
           P_COD_ERROR := -1;           
       RETURN;
      END IF;   
    END IF;   
        
    EXCEPTION
          WHEN OTHERS THEN
               P_MSG_ERROR := sqlerrm;
               P_COD_ERROR := -2;
  END;

  end PKG_CC_PROM_FIDELIDAD;
/