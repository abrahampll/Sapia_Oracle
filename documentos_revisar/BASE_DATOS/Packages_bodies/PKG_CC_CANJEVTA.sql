CREATE OR REPLACE PACKAGE BODY PCLUB.PKG_CC_CANJEVTA IS

  PROCEDURE ADMPS_CONSALDO(K_TIPO_DOC     IN VARCHAR2,
                           K_NUM_DOC      IN VARCHAR2,
                           K_LINEA        IN VARCHAR2,
                           K_CODSEGMENTO  OUT VARCHAR2,--NUEVO
                           K_SALDO_TOTAL  OUT NUMBER,
                           K_CUR_SALDOS   OUT SYS_REFCURSOR,
                           K_NUM_FACTOR   OUT NUMBER,
                           K_CUR_CAMPANHA OUT SYS_REFCURSOR,
                           K_CODERROR     OUT NUMBER,
                           K_DESCERROR    OUT VARCHAR2) IS
  
    --****************************************************************
    -- Nombre SP           :  ADMPS_CONSALDO
    -- Propósito           :  Permite consultar los saldos de clientes
    -- Input               :  K_TIPO_DOC     - Tipo de Documento del Cliente
    --                        K_NUM_DOC      - Número de Documento del Cliente
    --                        K_LINEA        - Numero de Linea
    -- Output              :  K_SALDO_TOTAL  - Saldo de Todas las Bolsas ( Puntos CC e IB)
    --                        K_CUR_SALDOS   - Cursor
    --                        K_NUM_FACTOR   - Factor de Equivalencia de Puntos a Soles
    --                        K_CUR_CAMPANHA - Cursor de Campaña
    --                        K_CODERROR     - Código de Error
    --                        K_DESCERROR    - Descripción del Error
    -- Creado por          :  Susana Ramos
    -- Fec Creación        :  15/03/2013
    -- Fec Actualización   :
    --****************************************************************
  
    VT_SALDO       T_SALDOXTIPOCLIE;
    VT_LISTA_SALDO T_TBLSALDOXTIPOCLIE := T_TBLSALDOXTIPOCLIE();
  
    CURSOR CUR_SALDOS(TIPO_DOC VARCHAR2, NUM_DOC VARCHAR2) IS
      SELECT T.ADMPV_TIPO,
             MAX(T.ADMPV_COD_TPOCL),
             (SELECT CLI2.Admpv_Cod_Cli
                FROM (SELECT TC.ADMPV_TIPO,
                             Cli.Admpv_Cod_Tpocl,
                             Cli.Admpv_Cod_Cli,
                             Cli.Admpd_Fec_Activ
                        FROM PCLUB.ADMPT_CLIENTE Cli
                       INNER JOIN PCLUB.ADMPT_TIPO_CLIENTE TC
                          ON TC.ADMPV_COD_TPOCL = Cli.Admpv_Cod_Tpocl
                       WHERE Cli.ADMPV_TIPO_DOC = TIPO_DOC
                         AND Cli.ADMPV_NUM_DOC = NUM_DOC
                         AND Cli.ADMPC_ESTADO = 'A'
                       ORDER BY CLI.ADMPD_FEC_ACTIV ASC) CLI2
               WHERE CLI2.ADMPV_TIPO = T.ADMPV_TIPO
                 AND ROWNUM = 1) AS ADMPV_COD_CLI,
             '' AS ADMPV_COD_CLI_PROD,
             MAX(T.ADMPV_PRVENTA) ADMPV_PRVENTA,
             MAX(T.ADMPC_TBLCLIENTE) ADMPC_TBLCLIENTE,
             SUM(NVL(S.ADMPN_SALDO_CC, 0)) AS ADMPN_SALDO_CC,
             NVL(SUM(DECODE(S.ADMPC_ESTPTO_IB, 'B', 0, S.ADMPN_SALDO_IB)),
                 0) AS ADMPN_SALDO_IB,
             SUM(NVL(SB.ADMPN_SALDO, 0)) AS ADMPN_SALDO_BONO -- NUEVO
        FROM PCLUB.ADMPT_CLIENTE C
       INNER JOIN PCLUB.ADMPT_TIPO_CLIENTE T
          ON (C.ADMPV_COD_TPOCL = T.ADMPV_COD_TPOCL AND
             T.ADMPV_PRVENTA IS NOT NULL AND T.ADMPV_TIPO IS NOT NULL)
       INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTE S
          ON (C.ADMPV_COD_CLI = S.ADMPV_COD_CLI AND S.ADMPC_ESTPTO_CC = 'A')
        LEFT JOIN PCLUB.ADMPT_SALDOS_BONO_CLIENTE SB -- NUEVO
          ON (C.ADMPV_COD_CLI = SB.ADMPV_COD_CLI AND SB.ADMPV_ESTADO = 'A' AND
             SB.ADMPN_GRUPO = '2' AND SB.ADMPV_COD_CLI = K_LINEA) -- NUEVO
       WHERE C.ADMPV_TIPO_DOC = TIPO_DOC
         AND C.ADMPV_NUM_DOC = NUM_DOC
         AND C.ADMPC_ESTADO = 'A'
       GROUP BY T.ADMPV_TIPO
      UNION ALL
      SELECT T.ADMPV_TIPO,
             MAX(T.ADMPV_COD_TPOCL),
             MAX(C.ADMPV_COD_CLI) AS ADMPV_COD_CLI,
             (SELECT CLIE.ADMPV_COD_CLI_PROD
                FROM (SELECT TC.ADMPV_TIPO,
                             F.ADMPV_COD_TPOCL,
                             F.ADMPV_COD_CLI,
                             CP.ADMPV_COD_CLI_PROD,
                             CP.ADMPD_FEC_REG
                        FROM PCLUB.ADMPT_CLIENTEPRODUCTO CP
                       INNER JOIN PCLUB.ADMPT_CLIENTEFIJA F
                          ON (CP.ADMPV_COD_CLI = F.ADMPV_COD_CLI)
                       INNER JOIN PCLUB.ADMPT_TIPO_CLIENTE TC
                          ON (TC.ADMPV_COD_TPOCL = F.ADMPV_COD_TPOCL)
                       WHERE F.ADMPV_TIPO_DOC = TIPO_DOC
                         AND F.ADMPV_NUM_DOC = NUM_DOC
                         AND F.ADMPC_ESTADO = 'A'
                         AND CP.ADMPV_ESTADO_SERV = 'A'
                       ORDER BY CP.ADMPD_FEC_REG ASC) CLIE
               WHERE CLIE.ADMPV_TIPO = T.ADMPV_TIPO
                 AND ROWNUM = 1) AS ADMPV_COD_CLI_PROD,
             MAX(T.ADMPV_PRVENTA) ADMPV_PRVENTA,
             MAX(T.ADMPC_TBLCLIENTE) ADMPC_TBLCLIENTE,
             SUM(NVL(S.ADMPN_SALDO_CC, 0)) AS ADMPN_SALDO_CC,
             NVL(SUM(DECODE(S.ADMPC_ESTPTO_IB, 'B', 0, S.ADMPN_SALDO_IB)),
                 0) AS ADMPN_SALDO_IB,
             0 AS ADMPN_SALDO_BONO --NUEVO
        FROM PCLUB.ADMPT_CLIENTEFIJA C
       INNER JOIN PCLUB.ADMPT_TIPO_CLIENTE T
          ON (C.ADMPV_COD_TPOCL = T.ADMPV_COD_TPOCL AND
             T.ADMPV_PRVENTA IS NOT NULL AND T.ADMPV_TIPO IS NOT NULL)
       INNER JOIN PCLUB.ADMPT_CLIENTEPRODUCTO P
          ON (C.ADMPV_COD_CLI = P.ADMPV_COD_CLI AND
             P.ADMPV_ESTADO_SERV = 'A')
       INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTEFIJA S
          ON (P.ADMPV_COD_CLI_PROD = S.ADMPV_COD_CLI_PROD AND
             S.ADMPC_ESTPTO_CC = 'A')
       WHERE C.ADMPV_TIPO_DOC = TIPO_DOC
         AND C.ADMPV_NUM_DOC = NUM_DOC
         AND C.ADMPC_ESTADO = 'A'
       GROUP BY T.ADMPV_TIPO
       ORDER BY ADMPV_PRVENTA ASC;
  
    C_COD_TPOCL    VARCHAR2(2);
    C_COD_CLI      VARCHAR2(40);
    C_COD_CLI_PROD VARCHAR2(40);
    C_DES_TPOCL    VARCHAR2(20);
    C_PRVENTA      VARCHAR2(2);
    C_TBLCLIENTE   CHAR(1);
    C_SALDO_CC     NUMBER;
    C_SALDO_IB     NUMBER;
    C_SALDO_BONO   NUMBER;
    V_SALDO_TOTAL  NUMBER;
    V_EQUIV_SOLES  NUMBER;
    V_TIPO_DOC     VARCHAR2(10);
    V_PUNTOS       NUMBER := 0;
    V_CONTREG      NUMBER := 0;
    EX_ERROR EXCEPTION;

    V_VALOR_SEG    NUMBER;
    
    V_NUM_DOC      VARCHAR(30);
    V_LON_NUMDOC   NUMBER;
    V_TPO_PREMIO   VARCHAR2(2);
    V_NOM_CLIE     VARCHAR(100);
    V_MENSAJE_SEG1  VARCHAR(100);
    V_MENSAJE_SEG2  VARCHAR(100);
    V_MENSAJE_SEG3  VARCHAR(100);
    V_MENSAJE_SEG4  VARCHAR(100);
    V_CODERROR_SEG  NUMBER;
    V_DESCERROR_SEG VARCHAR(250);
  BEGIN
  
    CASE
      WHEN K_TIPO_DOC IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese el tipo de documento. ';
        RAISE EX_ERROR;
      WHEN K_NUM_DOC IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese el número de documento. ';
        RAISE EX_ERROR;
      ELSE
        K_CODERROR  := 0;
        K_DESCERROR := ' ';
    END CASE;
  
    V_TIPO_DOC := PCLUB.PKG_CC_TRANSACCION.F_OBTENERTIPODOC(K_TIPO_DOC);
  
    IF V_TIPO_DOC IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'El tipo de documento no fue encontrado. ';
      RAISE EX_ERROR;
    END IF;
  
    -- Obtener el segmento del cliente
    BEGIN
      V_NUM_DOC := RPAD(TRIM(K_NUM_DOC),21,'X');
      V_LON_NUMDOC := LENGTH(TRIM(K_NUM_DOC));    

      DM.PKG_SEGMENTACION.SS_OBTENER_SEGMENTO@dbl_reptdm_d
      (
        'D',
        V_LON_NUMDOC,
        V_NUM_DOC,
        K_CODSEGMENTO,
        V_NOM_CLIE,
        V_MENSAJE_SEG1,
        V_MENSAJE_SEG2,
        V_MENSAJE_SEG3,
        V_MENSAJE_SEG4,
        V_CODERROR_SEG,
        V_DESCERROR_SEG    
      );
      
      IF V_CODERROR_SEG <> 0 THEN
        K_CODSEGMENTO := 'C'; 
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        K_CODSEGMENTO := 'C'; 
    END;
    
    BEGIN
      SELECT TO_NUMBER(ADMPV_VALOR, '9.9999')
        INTO K_NUM_FACTOR
        FROM PCLUB.ADMPT_PARAMSIST
       WHERE ADMPV_DESC = 'FACTOR_CONVERSION_PTOS_A_SOLES';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        K_CODERROR  := 9;
        K_DESCERROR := 'No existe el parámetro de sistema FACTOR_CONVERSION_PTOS_A_SOLES.';
        RAISE EX_ERROR;
    END;
  
    -- Validamos si existe alguna desalineacion en el kárdex
    ADMPS_VALIDASALDOKDXMOVIL(K_TIPO_DOC, K_NUM_DOC, K_CODERROR);
    IF K_CODERROR = 1 THEN
      K_CODERROR  := 33;
      K_DESCERROR := ' - Bolsa Móvil';
      RAISE EX_ERROR;
    END IF;
  
    ADMPS_VALIDASALDOKDXFIJA(K_TIPO_DOC, K_NUM_DOC, K_CODERROR);
    IF K_CODERROR = 1 THEN
      K_CODERROR  := 33;
      K_DESCERROR := ' - Bolsa Fija';
      RAISE EX_ERROR;
    END IF;
    -------------------------------------------------------------
  
    SELECT P.ADMPV_COD_TPOPR INTO V_TPO_PREMIO
    FROM PCLUB.ADMPT_PREMIO P
    WHERE P.ADMPV_ID_PROCLA IN (SELECT ADMPV_VALOR 
                                FROM PCLUB.ADMPT_PARAMSIST
                                WHERE ADMPV_DESC = 'PREMIO_CANJE_VENTA');
    
    VT_SALDO := T_SALDOXTIPOCLIE(NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL);
  
    OPEN CUR_SALDOS(K_TIPO_DOC, K_NUM_DOC);
    FETCH CUR_SALDOS
      INTO C_DES_TPOCL,
           C_COD_TPOCL,
           C_COD_CLI,
           C_COD_CLI_PROD,
           C_PRVENTA,
           C_TBLCLIENTE,
           C_SALDO_CC,
           C_SALDO_IB,
           C_SALDO_BONO; --AGREG

    WHILE CUR_SALDOS%FOUND LOOP
      BEGIN
          SELECT NVL(D.ADMPV_VALORSEGMENTO, 1) INTO V_VALOR_SEG
          FROM PCLUB.ADMPT_DSCTO_XSEG_XTCLIE D
          WHERE D.ADMPV_CODSEGMENTO = K_CODSEGMENTO 
                AND D.ADMPV_CODTIPOCLIENTE = C_COD_TPOCL
                AND D.ADMPV_CODTIPOPREMIO = V_TPO_PREMIO --'28'
                AND D.ADMPC_ESTADO = 'A';
      
      EXCEPTION
      WHEN OTHERS THEN
           V_VALOR_SEG := 1; 
      END;
      
      V_CONTREG     := V_CONTREG + 1;
      V_SALDO_TOTAL := C_SALDO_CC + C_SALDO_IB + C_SALDO_BONO; --AGREG
    
      V_EQUIV_SOLES := ROUND(V_SALDO_TOTAL * K_NUM_FACTOR, 2);
    
      V_PUNTOS := V_PUNTOS + V_SALDO_TOTAL;
      VT_LISTA_SALDO.EXTEND;
      VT_SALDO.COD_TPOCL := C_COD_TPOCL;
      VT_SALDO.COD_CLI := C_COD_CLI;
      VT_SALDO.COD_CLI_PROD := C_COD_CLI_PROD;
      VT_SALDO.DES_TIPO := C_DES_TPOCL;
      VT_SALDO.PRVENTA := C_PRVENTA;
      VT_SALDO.TBLCLIENTE := C_TBLCLIENTE;
      VT_SALDO.SALDO_CC := C_SALDO_CC;
      VT_SALDO.SALDO_IB := C_SALDO_IB;
      VT_SALDO.SALDO_BONO := C_SALDO_BONO; --AGREG
      VT_SALDO.SALDO_TOTAL := V_SALDO_TOTAL;
      VT_SALDO.EQUIV_SOLES := V_EQUIV_SOLES;
      VT_SALDO.VALOR_SEG := V_VALOR_SEG;

      VT_LISTA_SALDO(V_CONTREG) := VT_SALDO;

      FETCH CUR_SALDOS
        INTO C_DES_TPOCL,
             C_COD_TPOCL,
             C_COD_CLI,
             C_COD_CLI_PROD,
             C_PRVENTA,
             C_TBLCLIENTE,
             C_SALDO_CC,
             C_SALDO_IB,
             C_SALDO_BONO;
    END LOOP;
    CLOSE CUR_SALDOS;
  
    IF V_CONTREG = 0 THEN
      K_CODERROR := 6;
      RAISE EX_ERROR;
    END IF;
  
    K_SALDO_TOTAL := V_PUNTOS;
  
    OPEN K_CUR_SALDOS FOR
      SELECT T.DES_TIPO,
             T.COD_TPOCL,
             T.COD_CLI,
             T.COD_CLI_PROD,
             T.PRVENTA,
             T.TBLCLIENTE,
             T.SALDO_CC,
             T.SALDO_IB,
             T.SALDO_TOTAL,
             T.EQUIV_SOLES,
             T.SALDO_BONO,
             T.VALOR_SEG
        FROM TABLE(CAST(VT_LISTA_SALDO AS T_TBLSALDOXTIPOCLIE)) T;
  
    OPEN K_CUR_CAMPANHA FOR
      SELECT C.ADMPN_ID_CAMP,
             C.ADMPV_DESCRIPCION,
             T.ADMPV_TIPO,
             D.ADMPN_VALOR,
             C.ADMPD_FEC_INI,
             C.ADMPD_FEC_FIN,
             C.ADMPV_TPO_CLIE
      FROM  PCLUB.ADMPT_CAMPANHA C
      INNER JOIN  PCLUB.ADMPT_CAMPANHA_DET D
        ON (C.ADMPN_ID_CAMP = D.ADMPN_ID_CAMP AND
             C.ADMPV_ESTADO = D.ADMPC_ESTADO)
      INNER JOIN PCLUB.ADMPT_TIPO_CLIENTE T
        ON (T.ADMPV_COD_TPOCL = D.ADMPV_COD_TPOCL AND
             T.ADMPV_TIPO IS NOT NULL)
      WHERE TRUNC(SYSDATE) BETWEEN C.ADMPD_FEC_INI AND C.ADMPD_FEC_FIN
         AND C.ADMPV_ESTADO = 'A';
  
  EXCEPTION
    WHEN EX_ERROR THEN
      BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR
          INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_DESCERROR := '';
      END;
    
      OPEN K_CUR_SALDOS FOR
        SELECT '' DES_TIPO,
               '' COD_TPOCL,
               '' COD_CLI,
               '' COD_CLI_PROD,
               '' PRVENTA,
               '' TBLCLIENTE,
               '' SALDO_CC,
               '' SALDO_IB,
               '' SALDO_TOTAL,
               '' EQUIV_SOLES,
               '' SALDO_BONO,
               '' VALOR_SEG
        FROM DUAL
        WHERE 1 = 0;
         
      OPEN K_CUR_CAMPANHA FOR
        SELECT '' ADMPN_ID_CAMP,
               '' ADMPV_DESCRIPCION,
               '' ADMPV_TIPO,
               '' ADMPN_VALOR,
               '' ADMPD_FEC_INI,
               '' ADMPD_FEC_FIN,
               '' ADMPV_TPO_CLIE
          FROM DUAL
         WHERE 1 = 0;

    WHEN OTHERS THEN
      K_CODERROR  := -1;
      K_DESCERROR := 'Ocurrió un error en el SP ADMPS_CONSALDO';
      BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR
          INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_DESCERROR := '';
      END;

      OPEN K_CUR_SALDOS FOR
        SELECT '' DES_TIPO,
               '' COD_TPOCL,
               '' COD_CLI,
               '' COD_CLI_PROD,
               '' PRVENTA,
               '' TBLCLIENTE,
               '' SALDO_CC,
               '' SALDO_IB,
               '' SALDO_TOTAL,
               '' EQUIV_SOLES,
               '' SALDO_BONO,
               '' VALOR_SEG
          FROM DUAL
         WHERE 1 = 0;

      OPEN K_CUR_CAMPANHA FOR
        SELECT '' ADMPN_ID_CAMP,
               '' ADMPV_DESCRIPCION,
               '' ADMPV_TIPO,
               '' ADMPN_VALOR,
               '' ADMPD_FEC_INI,
               '' ADMPD_FEC_FIN,
               '' ADMPV_TPO_CLIE
          FROM DUAL
         WHERE 1 = 0;
  END ADMPS_CONSALDO;

  PROCEDURE ADMPI_CANJEVTA(K_TIPO_DOC    IN VARCHAR2,
                           K_NUM_DOC     IN VARCHAR2,
                           K_PUNTOVENTA  IN VARCHAR2,
                           K_COD_APLI    IN VARCHAR2,
                           K_COD_ASESOR  IN VARCHAR2,
                           K_NOM_ASESOR  IN VARCHAR2,
                           K_IDVENTA     IN VARCHAR2,
                           K_IDPROCESO   IN VARCHAR2,
                           K_PTOS_VENTA  IN NUMBER,
                           K_SOLESVTA    IN NUMBER,
                           K_IDCAMPANA   IN VARCHAR2,
                           K_USUARIO     IN VARCHAR2,
                           K_LINEA       IN VARCHAR2,
                           K_CODSEGMENTO IN VARCHAR2, --NUEVO
                           K_CODERROR    OUT NUMBER,
                           K_DESCERROR   OUT VARCHAR2,
                           K_LISTA_CANJE OUT SYS_REFCURSOR) IS
  
    --****************************************************************
    -- Nombre SP           :  ADMPI_CANJEVTA
    -- Propósito           :  Permite Registrar un Canje desde el Módulo de Ventas : SISACT
    -- Input               :  K_TIPO_DOC   - Tipo de Documento del Cliente
    --                        K_NUM_DOC    - Número de Documento del Cliente
    --                        K_PUNTOVENTA - Código del Punto de Venta (CAC)
    --                        K_COD_APLI   - Código de la Aplicación
    --                        K_COD_ASESOR - Código del Asesor
    --                        K_NOM_ASESOR - Nombre del Asesor
    --                        K_IDVENTA    - Código de Venta (enviado desde el Modulo de Ventas: SISACT)
    --                        K_IDPROCESO  - Tipo de Proceso : AP(Vta Alta Postpago),AE (Vta Alta Prepago),VR(Vta Renovación)
    --                        K_PTOS_VENTA - Cantidad de Ptos a ser Canjeados en Claro Club
    --                        K_SOLESVTA   - Monto en Soles a Canjear, referencial
    --                        K_IDCAMPANA  - Campaña a utilizar
    --                        K_USUARIO    - Usuario
    -- Output              :  K_CODERROR   - Código de Error (si se presentó)
    --                        K_DESCERROR  - Descripción del Error
    --                        K_LISTA_CANJE- Listado de los productos canjeados
    -- Creado por          :  Susana Ramos
    -- Fec Creación        :  15/03/2013
    -- Fec Actualización   :
    --****************************************************************
  
    TYPE CurClaro_Datos IS REF CURSOR;
    C_CUR_SALDOS   CurClaro_Datos;
    C_CUR_CAMPANHA CurClaro_Datos;
  
    V_COD_CANJE NUMBER;
    V_ID_KARDEX NUMBER;
    V_SEC       NUMBER;
    --Datos del Premio
    V_COD_PREMIO    VARCHAR2(15);
    V_DESC_PREMIO   VARCHAR2(150);
    V_TIPO_PREMIO   VARCHAR2(2);
    V_DESC_CAMPANHA VARCHAR2(150);
  
    V_PTOS_VENTA_TOTAL NUMBER := 0;
    V_PTOS_REQ_X_BOLSA NUMBER := 0;
    V_PTOS_X_BOLSA     NUMBER := 0;
    V_SALDO            NUMBER;
    V_SALDO_TOT        NUMBER := 0;
  
    V_COD_CPTO     NUMBER;
    V_ID_SOLICITUD VARCHAR2(20);
    V_TIPODOC      VARCHAR2(20);
    V_NUM_FACTOR   NUMBER;
    V_NUM_VALVTA   NUMBER;
    --Cursor de Saldo
    C_CUR_DES_TIPO     VARCHAR2(20);
    C_CUR_COD_TPOCL    VARCHAR2(2);
    C_CUR_COD_CLI_CJ   VARCHAR2(40);
    C_CUR_COD_CLI_PROD VARCHAR2(40);
    C_CUR_PRVENTA      VARCHAR2(2);
    C_CUR_TBLCLIENTE   CHAR(1);
    C_CUR_SALDO_CC     NUMBER;
    C_CUR_SALDO_IB     NUMBER;
    C_CUR_SALDO_TOT    NUMBER;
    C_CUR_SOLES_TT     NUMBER;
    --Cursor de Cliente Tipo
    --C_CUR_COD_CLI   VARCHAR2(40);
    --C_CUR_TIP_CLI VARCHAR2(2);
    --C_CUR_TIP_BOLSA CHAR(1);
    ---------------
    V_SALDO_AUX_CC   NUMBER := 0;
    V_SALDO_AUX_IB   NUMBER := 0;
    V_SALDO_AUX_BONO NUMBER := 0; --AGREG
    --V_EST_IB       CHAR(1);
    K_ESTADO CHAR(1);
    EX_ERROR EXCEPTION;
    V_CODERROR      NUMBER;
    V_DESCERROR     VARCHAR2(400);
    V_CODERROR_OBT  NUMBER;
    V_DESCERROR_OBT VARCHAR2(400);
    V_NUMLINEACJ    VARCHAR2(40);
    V_CONT_PR       NUMBER;
    V_SALDO_CANJE   NUMBER := 0;
  
    C_CUR_SALDO_BONO NUMBER;
    V_TIPCJE         NUMBER;
    V_TIPPRECJE      NUMBER;
    V_EX_SB          NUMBER;
    V_CUR_COD_CLI_CJ VARCHAR2(40);
    V_EXISTE         NUMBER;
    
    V_VAL_SEG        VARCHAR2(5);
  BEGIN
    CASE
      WHEN K_TIPO_DOC IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese un Tipo de Documento válido. ';
        RAISE EX_ERROR;
      WHEN K_NUM_DOC IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese un Nro. de Documento válido. ';
        RAISE EX_ERROR;
      WHEN K_IDVENTA IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese un Código de Id. de Venta válido. ';
        RAISE EX_ERROR;
      WHEN K_IDPROCESO IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese un Código de Proceso válido. ';
        RAISE EX_ERROR;
      WHEN K_PTOS_VENTA IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese la Cantidad de Puntos a Canjear válido. ';
        RAISE EX_ERROR;
      WHEN K_PTOS_VENTA = 0 THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'La Cantidad de Puntos a Canjear no puede ser cero. ';
        RAISE EX_ERROR;
      WHEN K_PTOS_VENTA < 0 THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'La Cantidad de Puntos a Canjear no puede ser negativa. ';
        RAISE EX_ERROR;
      ELSE
        K_CODERROR      := 0;
        K_DESCERROR     := ' ';
        V_CODERROR_OBT  := 0;
        V_DESCERROR_OBT := ' ';
        V_NUM_VALVTA    := 0;
    END CASE;
  
    --Validamos que se haya ingresado un K_IDPROCESO válido
    BEGIN
      SELECT COUNT(1)
        INTO V_CONT_PR
        FROM PCLUB.ADMPT_PROCESO
       WHERE ADMPV_IDPROC = K_IDPROCESO;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_CONT_PR := 0;
    END;
  
    IF V_CONT_PR = 0 THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'Ingrese un Código de Proceso válido. ';
      RAISE EX_ERROR;
    END IF;
  
    --Se valida que para el proceso de Reposición Prepago, se debe enviar una línea
    IF K_IDPROCESO = 'RP' THEN
      IF K_LINEA IS NULL OR K_LINEA = '' THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Debe ingresar una línea. ';
        RAISE EX_ERROR;
      END IF;
    END IF;
    
    /*Para el proceso de Reposición Prepago, alidamos que la línea enviada le pertenezca al Cliente*/
    IF K_IDPROCESO = 'RP' THEN
      SELECT count(1)
        INTO V_EXISTE
        FROM PCLUB.admpt_cliente
       WHERE admpv_cod_cli = K_LINEA
         AND admpv_tipo_doc = K_TIPO_DOC
         AND admpv_num_doc = K_NUM_DOC
         AND admpc_estado = 'A';
    
      IF V_EXISTE = 0 THEN
        K_CODERROR := 20;
        RAISE EX_ERROR;
      END IF;
    END IF;
  
    --Validamos que sea Cliente CC
    PCLUB.PKG_CC_CANJEVTA.ADMPS_ESCLIENTE(K_TIPO_DOC,
                                          K_NUM_DOC,
                                          K_CODERROR,
                                          K_DESCERROR);
    IF K_CODERROR <> 0 THEN
      K_DESCERROR := '';
      RAISE EX_ERROR;
    END IF;
    --Consulta si la Cuenta del Cliente esta Bloqueada
    PCLUB.PKG_CC_TRANSACCION.ADMPS_VALBLOQUEOBOLSA(K_TIPO_DOC,
                                                   K_NUM_DOC,
                                                   '0',
                                                   V_TIPODOC,
                                                   K_ESTADO,
                                                   K_CODERROR,
                                                   K_DESCERROR);
  
    IF K_CODERROR <> 0 THEN
      RAISE EX_ERROR;
    END IF;
  
    IF K_ESTADO = 'R' THEN
    
      SELECT COUNT(1)
        INTO V_NUM_VALVTA
        FROM (SELECT TC.ADMPV_COD_TPOCL
                FROM PCLUB.ADMPT_TIPO_CLIENTE TC
               WHERE TC.ADMPV_PRVENTA IS NOT NULL
              MINUS
              SELECT T.ADMPV_COD_TPOCL
                FROM PCLUB.ADMPT_CLIE_ESTADO_BOLSA T
               WHERE T.ADMPV_NUM_DOC = K_NUM_DOC
                 AND T.ADMPV_TIPO_DOC = K_TIPO_DOC);
    
      IF V_NUM_VALVTA > 0 THEN
        K_CODERROR := 41;
        RAISE EX_ERROR;
      END IF;
    
      PCLUB.PKG_CC_CANJEVTA.ADMPS_VALIDASALDOKDXMOVIL(K_TIPO_DOC,
                                                      K_NUM_DOC,
                                                      K_CODERROR);
      IF K_CODERROR = 1 THEN
        K_CODERROR  := 33;
        K_DESCERROR := ' - Bolsa Móvil';
        RAISE EX_ERROR;
      END IF;
    
      PCLUB.PKG_CC_CANJEVTA.ADMPS_VALIDASALDOKDXFIJA(K_TIPO_DOC,
                                                     K_NUM_DOC,
                                                     K_CODERROR);
      IF K_CODERROR = 1 THEN
        K_CODERROR  := 33;
        K_DESCERROR := ' - Bolsa Fija';
        RAISE EX_ERROR;
      END IF;
    
      PCLUB.PKG_CC_CANJEVTA.ADMPS_CONSALDO_CANJE(K_TIPO_DOC,
                                                 K_NUM_DOC,
                                                 K_LINEA,
                                                 K_IDPROCESO,
                                                 V_SALDO_TOT,
                                                 C_CUR_SALDOS,
                                                 V_NUM_FACTOR,
                                                 C_CUR_CAMPANHA,
                                                 K_CODERROR,
                                                 K_DESCERROR);
      IF K_CODERROR <> 0 THEN
        RAISE EX_ERROR;
      END IF;
    
      IF V_SALDO_TOT <= 0 THEN
        K_CODERROR := 24;
        RAISE EX_ERROR;
      END IF;
    
      IF K_PTOS_VENTA > V_SALDO_TOT THEN
        K_CODERROR := 25;
        RAISE EX_ERROR;
      END IF;
    
      V_PTOS_VENTA_TOTAL := K_PTOS_VENTA;
      
      -- Recupera el Código del Tipo de Premio para el Canje Venta
      SELECT ADMPV_VALOR INTO V_COD_PREMIO
      FROM  ADMPT_PARAMSIST
      WHERE ADMPV_DESC = 'PREMIO_CANJE_VENTA';

      SELECT admpv_desc, admpv_cod_tpopr, admpv_campana 
             INTO V_DESC_PREMIO, V_TIPO_PREMIO, V_DESC_CAMPANHA
      FROM admpt_premio
      WHERE admpv_id_procla = V_COD_PREMIO
            AND admpc_estado = 'A';

      FETCH C_CUR_SALDOS INTO C_CUR_DES_TIPO,
             C_CUR_COD_TPOCL,
             C_CUR_COD_CLI_CJ,
             C_CUR_COD_CLI_PROD,
             C_CUR_PRVENTA,
             C_CUR_TBLCLIENTE,
             C_CUR_SALDO_CC,
             C_CUR_SALDO_IB,
             C_CUR_SALDO_TOT,
             C_CUR_SOLES_TT,
             C_CUR_SALDO_BONO;

      WHILE C_CUR_SALDOS%FOUND AND V_PTOS_VENTA_TOTAL > 0 LOOP
        IF C_CUR_SALDO_TOT > 0 THEN

          -- Obtenemos el valor de segmento
          BEGIN
                SELECT NVL(D.ADMPV_VALORSEGMENTO, 1) INTO V_VAL_SEG
                FROM ADMPT_DSCTO_XSEG_XTCLIE D
                WHERE D.ADMPV_CODSEGMENTO = K_CODSEGMENTO 
                      AND D.ADMPV_CODTIPOCLIENTE = C_CUR_COD_TPOCL
                      AND D.ADMPV_CODTIPOPREMIO = V_TIPO_PREMIO
                      AND D.ADMPC_ESTADO = 'A';
                
          EXCEPTION
            WHEN OTHERS THEN
              V_VAL_SEG := '1'; 
          END;
          IF C_CUR_SALDO_TOT > V_PTOS_VENTA_TOTAL THEN
            V_PTOS_REQ_X_BOLSA := V_PTOS_VENTA_TOTAL;
          ELSE
            V_PTOS_REQ_X_BOLSA := C_CUR_SALDO_TOT;
          END IF;
        
          V_PTOS_X_BOLSA     := V_PTOS_REQ_X_BOLSA;
          V_PTOS_VENTA_TOTAL := V_PTOS_VENTA_TOTAL - V_PTOS_REQ_X_BOLSA;
          --E76142
          V_SALDO_CANJE := C_CUR_SALDO_TOT - V_PTOS_REQ_X_BOLSA;
        
          SELECT TO_CHAR(SYSDATE, 'YYYYMMDDHHMMSS')
            INTO V_ID_SOLICITUD
            FROM DUAL;
        
          --Recupera el Código del Tipo de Premio para el Canje Venta
          SELECT ADMPV_VALOR
            INTO V_COD_PREMIO
            FROM PCLUB.ADMPT_PARAMSIST
           WHERE ADMPV_DESC = 'PREMIO_CANJE_VENTA';
        
          SELECT admpv_desc, admpv_cod_tpopr, admpv_campana
            INTO V_DESC_PREMIO, V_TIPO_PREMIO, V_DESC_CAMPANHA
            FROM PCLUB.admpt_premio
           WHERE admpv_id_procla = V_COD_PREMIO
             AND admpc_estado = 'A';
        
          --Defino el valor que tomará la linea con la que haremos el canje
          IF C_CUR_COD_TPOCL = 3 AND K_IDPROCESO = 'RP' THEN
            V_CUR_COD_CLI_CJ := K_LINEA;
          ELSE
            V_CUR_COD_CLI_CJ := C_CUR_COD_CLI_CJ;
          END IF;
        
          --Obtengo el número de teléfono para el cual se generará las interacciones
          IF C_CUR_TBLCLIENTE = 'M' THEN
            PCLUB.PKG_CC_CANJEVTA.ADMPS_OBTNUMLINEA(C_CUR_COD_TPOCL,
                                                    C_CUR_COD_CLI_CJ,
                                                    V_NUMLINEACJ,
                                                    V_CODERROR_OBT,
                                                    V_DESCERROR_OBT);
          ELSE
            PCLUB.PKG_CC_CANJEVTA.ADMPS_OBTNUMLINEA(C_CUR_COD_TPOCL,
                                                    C_CUR_COD_CLI_PROD,
                                                    V_NUMLINEACJ,
                                                    V_CODERROR_OBT,
                                                    V_DESCERROR_OBT);
          END IF;
          IF V_CODERROR_OBT <> 0 THEN
            V_NUMLINEACJ := '';
          END IF;
        
          IF C_CUR_COD_TPOCL = '3' AND K_IDPROCESO = 'RP' THEN
            --Se obtiene los valores de si se realizará un canje con puntos bono
            SELECT COUNT(1)
              INTO V_EX_SB
              FROM PCLUB.ADMPT_SALDOS_BONO_CLIENTE
             WHERE ADMPV_COD_CLI = K_LINEA
               AND ADMPN_GRUPO = 2
               AND ADMPV_ESTADO = 'A'
               AND ADMPN_SALDO > 0;
          
            IF V_EX_SB > 0 THEN
              V_TIPCJE    := 1;
              V_TIPPRECJE := 2;
            ELSE
              V_TIPCJE    := null;
              V_TIPPRECJE := null;
            END IF;
            ----------------------------------------------------------------
          END IF;
        
          SAVEPOINT POINT_CANJE;

          V_SEC := 1;

          IF C_CUR_TBLCLIENTE = 'M' THEN --Movil

            SELECT NVL(admpt_canje_sq.NEXTVAL, '-1') INTO V_COD_CANJE
            FROM dual;
            
            -- Cabecera
            IF C_CUR_COD_TPOCL = '3' AND K_IDPROCESO = 'RP' THEN

              INSERT INTO PCLUB.admpt_canje
                (admpv_id_canje, admpv_cod_cli, --CodCliente de la Línea más antigua
                 admpv_id_solic, admpv_pto_venta,
                 admpd_fec_canje, admpv_hra_canje,
                 admpv_num_doc, admpv_cod_tpocl, --(Si es Control --> se mandará PostPago)
                 admpv_cod_aseso, admpv_nom_aseso,
                 admpc_tpo_oper, admpv_cod_tipapl,
                 admpv_usu_reg, admpv_tpo_proc,
                 admpv_ventaid, admpn_solesvta,
                 admpn_id_camp, ADMPV_NUM_LINEA,
                 ADMPN_SALDO, ADMPN_TIPCANJE,
                 ADMPN_TIPPREMCJE, admpv_codsegmento) --? (De que Linea de los PostPagos/Control)--> vacio--Integracion nos enviará ese dato, luego se actualizará
              values
                (V_COD_CANJE, V_CUR_COD_CLI_CJ,
                 V_ID_SOLICITUD, K_PUNTOVENTA,
                 TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
                 TO_CHAR(SYSDATE, 'HH:MI AM'),
                 K_NUM_DOC, C_CUR_COD_TPOCL,
                 K_COD_ASESOR, K_NOM_ASESOR,
                 'C', K_COD_APLI,
                 K_USUARIO, K_IDPROCESO,
                 K_IDVENTA, K_SOLESVTA,
                 K_IDCAMPANA, V_NUMLINEACJ,
                 V_SALDO_CANJE, V_TIPCJE,
                 V_TIPPRECJE, K_CODSEGMENTO);
            
            ELSE
              INSERT INTO PCLUB.admpt_canje
                (admpv_id_canje, admpv_cod_cli, --CodCliente de la Línea más antigua
                 admpv_id_solic, admpv_pto_venta,
                 admpd_fec_canje, admpv_hra_canje,
                 admpv_num_doc, admpv_cod_tpocl, --(Si es Control --> se mandará PostPago)
                 admpv_cod_aseso, admpv_nom_aseso,
                 admpc_tpo_oper, admpv_cod_tipapl,
                 admpv_usu_reg, admpv_tpo_proc,
                 admpv_ventaid, admpn_solesvta,
                 admpn_id_camp, ADMPV_NUM_LINEA,
                 ADMPN_SALDO, admpv_codsegmento)
              --? (De que Linea de los PostPagos/Control)--> vacio--Integracion nos enviará ese dato, luego se actualizará
              values
                (V_COD_CANJE, V_CUR_COD_CLI_CJ,
                 V_ID_SOLICITUD, K_PUNTOVENTA,
                 TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
                 TO_CHAR(SYSDATE, 'HH:MI AM'),
                 K_NUM_DOC, C_CUR_COD_TPOCL,
                 K_COD_ASESOR, K_NOM_ASESOR,
                 'C', K_COD_APLI,
                 K_USUARIO, K_IDPROCESO,
                 K_IDVENTA, K_SOLESVTA,
                 K_IDCAMPANA, V_NUMLINEACJ,
                 V_SALDO_CANJE, K_CODSEGMENTO);
            END IF;
            -- Detalle
            INSERT INTO PCLUB.admpt_canje_detalle
              (admpv_id_canje, admpv_id_canjesec,
               admpv_id_procla, admpv_desc,
               admpv_nom_camp, admpn_puntos,
               admpn_pago, admpn_cantidad,
               admpv_cod_tpopr, admpc_estado,
               admpn_valsegmento)
            VALUES
              (V_COD_CANJE, V_SEC,
               V_COD_PREMIO, V_DESC_PREMIO,
               V_DESC_CAMPANHA, V_PTOS_REQ_X_BOLSA,
               0, 1,
               V_TIPO_PREMIO, 'C',
               V_VAL_SEG);

          ELSIF C_CUR_TBLCLIENTE = 'F' THEN --Fija
            SELECT NVL(ADMPT_canjefija_sq.NEXTVAL, '-1') INTO V_COD_CANJE
            FROM dual;

            -- Cabecera
            INSERT INTO PCLUB.ADMPT_canjefija
              (admpv_id_canje, admpv_cod_cli,
               admpv_pto_venta, admpd_fec_canje,
               admpv_hra_canje, admpv_num_doc,
               admpv_cod_tpocl, admpv_cod_aseso,
               admpv_nom_aseso, admpc_tpo_oper,
               admpv_cod_tipapl, admpv_usu_reg,
               admpv_tpo_proc, admpv_ventaid,
               admpn_solesvta, admpn_id_camp,
               ADMPV_NUM_LINEA, ADMPN_SALDO,
               admpv_codsegmento)
            values
              (V_COD_CANJE, V_CUR_COD_CLI_CJ,
               K_PUNTOVENTA, TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
               TO_CHAR(SYSDATE, 'HH:MI AM'), K_NUM_DOC,
               C_CUR_COD_TPOCL, k_cod_asesor,
               k_nom_asesor, 'C',
               K_COD_APLI, K_USUARIO,
               K_IDPROCESO, K_IDVENTA,
               K_SOLESVTA, K_IDCAMPANA,
               V_NUMLINEACJ, V_SALDO_CANJE,
               K_CODSEGMENTO);

            -- Detalle
            INSERT INTO PCLUB.ADMPT_canje_detallefija
              (admpv_id_canje, admpv_id_canjesec,
               admpv_id_procla, admpv_desc,
               admpv_nom_camp, admpn_puntos,
               admpn_pago, admpn_cantidad,
               admpv_cod_tpopr, admpc_estado,
               admpv_usu_reg, admpn_valsegmento)
            VALUES
              (V_COD_CANJE, V_SEC,
               V_COD_PREMIO, V_DESC_PREMIO,
               V_DESC_CAMPANHA, V_PTOS_REQ_X_BOLSA,
               K_SOLESVTA, 1,
               V_TIPO_PREMIO, 'C',
               K_USUARIO, V_VAL_SEG);
          END IF;
                  
          IF C_CUR_TBLCLIENTE = 'M' THEN        
          
            -- Calculo el Saldo x Bolsa
            IF C_CUR_COD_TPOCL = '3' THEN
              BEGIN
                SELECT SUM(NVL(SC.ADMPN_SALDO_CC, 0)),
                     SUM(CASE
                           WHEN NVL(SC.ADMPC_ESTPTO_IB, 0) = 'A' THEN
                            NVL(SC.ADMPN_SALDO_IB, 0)
                           ELSE
                            0
                         END)
                INTO V_SALDO_AUX_CC, V_SALDO_AUX_IB
                FROM PCLUB.ADMPT_CLIENTE C
                INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTE SC
                  ON C.ADMPV_COD_CLI = SC.ADMPV_COD_CLI
                WHERE (C.ADMPV_TIPO_DOC = K_TIPO_DOC AND
                     C.ADMPV_NUM_DOC = K_NUM_DOC)
                 AND C.ADMPC_ESTADO = 'A'
                 AND C.ADMPV_COD_TPOCL = C_CUR_COD_TPOCL
                 AND SC.ADMPC_ESTPTO_CC = 'A';
            
                IF V_SALDO_AUX_CC IS NULL THEN
                  V_SALDO_AUX_CC := 0;
                END IF;
                IF V_SALDO_AUX_IB IS NULL THEN
                  V_SALDO_AUX_IB := 0;
                END IF;
            
                --Obtengo la Suma de Saldo Cliente Bono
                SELECT NVL(SUM(SB.ADMPN_SALDO), 0)
                  INTO V_SALDO_AUX_BONO
                FROM PCLUB.ADMPT_SALDOS_BONO_CLIENTE SB
                WHERE SB.ADMPV_COD_CLI = K_LINEA
                  AND SB.ADMPN_GRUPO = 2
                  AND SB.ADMPV_ESTADO = 'A';
            
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                V_SALDO_AUX_IB   := 0;
                V_SALDO_AUX_CC   := 0;
                V_SALDO_AUX_BONO := 0;
            END;

          ELSIF C_CUR_COD_TPOCL = '8' THEN
            BEGIN
              SELECT SUM(NVL(SC.ADMPN_SALDO_CC, 0)),
                     SUM(CASE
                           WHEN NVL(SC.ADMPC_ESTPTO_IB, 0) = 'A' THEN
                            NVL(SC.ADMPN_SALDO_IB, 0)
                           ELSE
                            0
                         END)
                INTO V_SALDO_AUX_CC, V_SALDO_AUX_IB
              FROM PCLUB.ADMPT_CLIENTE C
                INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTE SC
                  ON C.ADMPV_COD_CLI = SC.ADMPV_COD_CLI
              WHERE (C.ADMPV_TIPO_DOC = K_TIPO_DOC AND
                     C.ADMPV_NUM_DOC = K_NUM_DOC)
                 AND C.ADMPC_ESTADO = 'A'
                 AND C.ADMPV_COD_TPOCL = C_CUR_COD_TPOCL
                 AND SC.ADMPC_ESTPTO_CC = 'A';
            
              IF V_SALDO_AUX_CC IS NULL THEN
                V_SALDO_AUX_CC := 0;
              END IF;
              IF V_SALDO_AUX_IB IS NULL THEN
                V_SALDO_AUX_IB := 0;
              END IF;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                V_SALDO_AUX_IB := 0;
                V_SALDO_AUX_CC := 0;
            END;
          ELSE
            --Postpago
            IF (C_CUR_COD_TPOCL = '2' OR C_CUR_COD_TPOCL = '1') THEN
              BEGIN
                SELECT SUM(NVL(SC.ADMPN_SALDO_CC, 0)),
                       SUM(CASE
                             WHEN NVL(SC.ADMPC_ESTPTO_IB, 0) = 'A' THEN
                              NVL(SC.ADMPN_SALDO_IB, 0)
                             ELSE
                              0
                           END)
                  INTO V_SALDO_AUX_CC, V_SALDO_AUX_IB
                  FROM PCLUB.ADMPT_CLIENTE C
                 INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTE SC
                    ON C.ADMPV_COD_CLI = SC.ADMPV_COD_CLI
                 WHERE (C.ADMPV_TIPO_DOC = K_TIPO_DOC AND
                       C.ADMPV_NUM_DOC = K_NUM_DOC)
                   AND C.ADMPC_ESTADO = 'A'
                   AND (C.ADMPV_COD_TPOCL = 1 OR C.ADMPV_COD_TPOCL = 2)
                   AND SC.ADMPC_ESTPTO_CC = 'A';
              
                IF V_SALDO_AUX_CC IS NULL THEN
                  V_SALDO_AUX_CC := 0;
                END IF;
                IF V_SALDO_AUX_IB IS NULL THEN
                  V_SALDO_AUX_IB := 0;
                END IF;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  V_SALDO_AUX_IB := 0;
                  V_SALDO_AUX_CC := 0;
              END;
            END IF;
          END IF;
        ELSE --FALTO ESTE IF
          
          BEGIN
              SELECT 
              SUM(NVL(SF.ADMPN_SALDO_CC, 0)),
                                   SUM(CASE
                                         WHEN NVL(SF.ADMPC_ESTPTO_IB, 0) = 'A' THEN
                                          NVL(SF.ADMPN_SALDO_IB, 0)
                                         ELSE
                                          0
                                       END)
                              INTO V_SALDO_AUX_CC, V_SALDO_AUX_IB
              FROM PCLUB.ADMPT_CLIENTEFIJA CF
              INNER JOIN PCLUB.ADMPT_CLIENTEPRODUCTO CP
              ON CF.ADMPV_COD_CLI=CP.ADMPV_COD_CLI
              INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTEFIJA SF
              ON CP.ADMPV_COD_CLI_PROD=SF.ADMPV_COD_CLI_PROD
              WHERE CF.ADMPV_TIPO_DOC=K_TIPO_DOC
              AND CF.ADMPV_NUM_DOC=K_NUM_DOC
              AND CF.ADMPV_COD_TPOCL=C_CUR_COD_TPOCL;
              
              IF V_SALDO_AUX_CC IS NULL THEN
                V_SALDO_AUX_CC := 0;
              END IF;
              IF V_SALDO_AUX_IB IS NULL THEN
                V_SALDO_AUX_IB := 0;
              END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              V_SALDO_AUX_IB := 0;
              V_SALDO_AUX_CC := 0;
          END;
        END IF;
        
          --Consolido Saldos
          V_SALDO := V_SALDO_AUX_CC + V_SALDO_AUX_IB + V_SALDO_AUX_BONO; -- AGREG

          IF V_SALDO > V_PTOS_REQ_X_BOLSA THEN
            V_SALDO := V_PTOS_REQ_X_BOLSA;
          END IF;
        
          IF V_SALDO > 0 THEN
            IF C_CUR_TBLCLIENTE = 'M' THEN -- Movil
            
              IF C_CUR_COD_TPOCL = '3' AND K_IDPROCESO = 'RP' THEN
                PCLUB.PKG_CC_TRANSACCION.ADMPSI_DESC_PTOS_BONO(V_COD_CANJE, V_SEC,
                                                               V_SALDO, K_LINEA,
                                                               K_TIPO_DOC, K_NUM_DOC,
                                                               C_CUR_COD_TPOCL, 2,
                                                               V_CODERROR, V_DESCERROR);
              ELSE
                PCLUB.PKG_CC_TRANSACCION.admpsi_desc_puntos(V_COD_CANJE, V_SEC,
                                                            V_SALDO, V_CUR_COD_CLI_CJ,
                                                            K_TIPO_DOC, K_NUM_DOC,
                                                            C_CUR_COD_TPOCL, V_CODERROR,
                                                            V_DESCERROR);
              
              END IF;
            
            ELSIF C_CUR_TBLCLIENTE = 'F' THEN
              PCLUB.PKG_CC_TRANSACCIONFIJA.ADMPSI_DESC_PUNTOS(V_COD_CANJE, V_SEC,
                                                              V_SALDO, C_CUR_COD_CLI_PROD,
                                                              K_TIPO_DOC, K_NUM_DOC,
                                                              C_CUR_COD_TPOCL, K_USUARIO,
                                                              V_CODERROR, V_DESCERROR);
            END IF;
            V_PTOS_REQ_X_BOLSA := V_PTOS_REQ_X_BOLSA - V_SALDO;
          END IF;
        
          ----------------------------------
        
          SELECT NVL(admpv_cod_cpto, '-1') INTO V_COD_CPTO
          FROM PCLUB.admpt_concepto
          WHERE admpv_desc = 'CANJE VENTA';
        
          IF C_CUR_TBLCLIENTE = 'M' THEN -- Movil
            SELECT NVL(admpt_kardex_sq.NEXTVAL, '-1') INTO V_ID_KARDEX
            FROM dual;

            INSERT INTO PCLUB.admpt_kardex
              (admpn_id_kardex, admpn_cod_cli_ib,
               admpv_cod_cli, admpv_cod_cpto,
               admpd_fec_trans, admpn_puntos,
               admpv_nom_arch, admpc_tpo_oper,
               admpc_tpo_punto, admpn_sld_punto,
               admpc_estado)
            VALUES
              (V_ID_KARDEX, '',
               V_CUR_COD_CLI_CJ, V_COD_CPTO,
               TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'), V_PTOS_X_BOLSA * (-1),
               '', 'S',
               'C', 0,
               'C');
            UPDATE PCLUB.admpt_canje
               SET admpn_id_kardex = V_ID_KARDEX
             WHERE admpv_id_canje = V_COD_CANJE;

          ELSIF C_CUR_TBLCLIENTE = 'F' THEN -- Fija

            SELECT NVL(ADMPT_kardexfija_sq.NEXTVAL, '-1') INTO V_ID_KARDEX
            FROM dual;

            INSERT INTO PCLUB.ADMPT_kardexfija
              (admpn_id_kardex, admpn_cod_cli_ib,
               admpv_cod_cli_prod, admpv_cod_cpto,
               admpd_fec_trans, admpn_puntos,
               admpc_tpo_oper, admpc_tpo_punto,
               admpn_sld_punto, admpc_estado,
               admpv_usu_reg, admpv_id_canje)
            VALUES
              (V_ID_KARDEX, '',
               C_CUR_COD_CLI_PROD, V_COD_CPTO,
               SYSDATE, V_PTOS_X_BOLSA * (-1),
               'S', 'C',
               0, 'C',
               K_USUARIO, V_COD_CANJE);
          END IF;
          
        END IF;
      
        V_SALDO_CANJE := 0;
      
        FETCH C_CUR_SALDOS
          INTO C_CUR_DES_TIPO, C_CUR_COD_TPOCL,
               C_CUR_COD_CLI_CJ, C_CUR_COD_CLI_PROD,
               C_CUR_PRVENTA, C_CUR_TBLCLIENTE,
               C_CUR_SALDO_CC, C_CUR_SALDO_IB,
               C_CUR_SALDO_TOT, C_CUR_SOLES_TT,
               C_CUR_SALDO_BONO;
      
      END LOOP;
      CLOSE C_CUR_SALDOS;
      COMMIT;
    
      OPEN K_LISTA_CANJE FOR
        SELECT /*+ INDEX(CCAB) */
         cdet.admpv_id_procla   AS ProdId,
         pr.admpv_desc          AS ProdDes,
         cdet.admpv_nom_camp    AS Campana,
         cdet.admpn_puntos      AS Puntos,
         ccab.admpn_solesvta    AS Pago,
         cdet.admpn_cantidad    AS Cantidad,
         cdet.admpv_id_canje    AS IDCanje,
         cdet.admpv_id_canjesec AS IDCanjeSec,
         cdet.admpv_cod_tpopr   AS TipoPremio,
         cdet.admpn_cod_servc   AS ServComercial,
         cdet.admpn_mnt_recar   AS MontoRecarga,
         TC.ADMPV_DESC          AS CodTipoCliente,
         ccab.admpv_num_linea   AS Telefono,
         ccab.ADMPN_SALDO       AS Saldo,
         ccab.admpv_cod_cli     AS CodCliente
          FROM PCLUB.ADMPT_CANJE_DETALLE cdet
         INNER JOIN PCLUB.ADMPT_CANJE ccab
            on (cdet.admpv_id_canje = ccab.admpv_id_canje)
         INNER JOIN PCLUB.ADMPT_PREMIO pr
            on (cdet.admpv_id_procla = pr.admpv_id_procla)
         INNER JOIN PCLUB.ADMPT_TIPO_CLIENTE TC
            ON TC.ADMPV_COD_TPOCL = ccab.admpv_cod_tpocl
         WHERE ccab.admpv_ventaid = K_IDVENTA
		   AND ccab.admpv_tpo_proc = K_IDPROCESO
        UNION ALL
        SELECT /*+ INDEX(CCAB) */
         cdet.admpv_id_procla   AS ProdId,
         pr.admpv_desc          AS ProdDes,
         cdet.admpv_nom_camp    AS Campana,
         cdet.admpn_puntos      AS Puntos,
         ccab.admpn_solesvta    AS Pago,
         cdet.admpn_cantidad    AS Cantidad,
         cdet.admpv_id_canje    AS IDCanje,
         cdet.admpv_id_canjesec AS IDCanjeSec,
         cdet.admpv_cod_tpopr   AS TipoPremio,
         cdet.admpn_cod_servc   AS ServComercial,
         cdet.admpn_mnt_recar   AS MontoRecarga,
         TC.ADMPV_DESC          AS CodTipoCliente,
         ccab.admpv_num_linea   AS Telefono,
         ccab.ADMPN_SALDO       AS Saldo,
         ccab.admpv_cod_cli     AS CodCliente
          FROM PCLUB.ADMPT_CANJE_DETALLEFIJA cdet
         INNER JOIN PCLUB.ADMPT_CANJEFIJA ccab
            on (cdet.admpv_id_canje = ccab.admpv_id_canje)
         INNER JOIN PCLUB.ADMPT_PREMIO pr
            on (cdet.admpv_id_procla = pr.admpv_id_procla)
         INNER JOIN PCLUB.ADMPT_TIPO_CLIENTE TC
            ON TC.ADMPV_COD_TPOCL = ccab.admpv_cod_tpocl
         WHERE ccab.admpv_ventaid = K_IDVENTA
           and ccab.admpv_tpo_proc = K_IDPROCESO;
    ELSE
      K_CODERROR := 41;
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
          K_DESCERROR := 'ERROR';
      END;
      OPEN K_LISTA_CANJE FOR
        SELECT '' ProdId,
               '' ProdDes,
               '' Campana,
               '' Puntos,
               '' Pago,
               '' Cantidad,
               '' IDCanje,
               '' IDCanjeSec,
               '' TipoPremio,
               '' ServComercial,
               '' MontoRecarga,
               '' CodTipoCliente,
               '' Telefono,
               '' Saldo,
               '' CodCliente
          FROM DUAL;
    
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
      ROLLBACK TO POINT_CANJE;
    
      OPEN K_LISTA_CANJE FOR
        SELECT '' ProdId,
               '' ProdDes,
               '' Campana,
               '' Puntos,
               '' Pago,
               '' Cantidad,
               '' IDCanje,
               '' IDCanjeSec,
               '' TipoPremio,
               '' ServComercial,
               '' MontoRecarga,
               '' CodTipoCliente,
               '' Telefono,
               '' Saldo,
               '' CodCliente
          FROM DUAL;
  END ADMPI_CANJEVTA;

  PROCEDURE ADMPS_ESCLIENTE(K_TIPO_DOC  IN VARCHAR2,
                            K_NUM_DOC   IN VARCHAR2,
                            K_CODERROR  OUT NUMBER,
                            K_DESCERROR OUT VARCHAR2) IS
    --****************************************************************
    -- Nombre SP           :  ADMPSS_ESCLIENTE
    -- Propósito           :  Indicar si el Cliente existe en la BD de Claro Club
    -- Input               :  K_TIPO_DOC - Tipo de Documento
    --                        K_NUM_DOC  - Número de Documento
    -- Output              :  K_CODERROR
    --                        K_DESCERROR
    -- Creado por          :  Susana Ramos
    -- Fec Creación        :
    -- Fec Actualización   :  28/02/2013
    --****************************************************************
    EX_ERROR EXCEPTION;
    nro_registrosCC NUMBER := 0;
  BEGIN
    CASE
      WHEN K_TIPO_DOC IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese un Tipo de Documento válido. ';
        RAISE EX_ERROR;
      WHEN K_NUM_DOC IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese un Nro. de Documento válido. ';
        RAISE EX_ERROR;
      ELSE
        K_CODERROR  := 0;
        K_DESCERROR := ' ';
    END CASE;
  
    BEGIN
      -- Busca si el cliente es CC
      SELECT COUNT(ADMPV_COD_CLI)
        INTO nro_registrosCC
        FROM (SELECT M.ADMPV_COD_CLI, M.ADMPV_COD_TPOCL
                FROM PCLUB.ADMPT_CLIENTE M
               WHERE M.ADMPC_ESTADO = 'A'
                 AND M.ADMPV_TIPO_DOC = K_TIPO_DOC
                 AND M.ADMPV_NUM_DOC = K_NUM_DOC
                 AND M.ADMPV_COD_TPOCL IN
                     (SELECT ADMPV_COD_TPOCL
                        FROM PCLUB.ADMPT_TIPO_CLIENTE
                       WHERE ADMPC_ESTADO = 'A'
                         AND ADMPV_PRVENTA IS NOT NULL
                         AND ADMPC_TBLCLIENTE = 'M')
              UNION ALL
              SELECT F.ADMPV_COD_CLI, F.ADMPV_COD_TPOCL
                FROM PCLUB.ADMPT_CLIENTEFIJA F
               WHERE F.ADMPV_TIPO_DOC = K_TIPO_DOC
                 AND F.ADMPV_NUM_DOC = K_NUM_DOC
                 AND F.ADMPC_ESTADO = 'A'
                 AND F.ADMPV_COD_TPOCL IN
                     (SELECT ADMPV_COD_TPOCL
                        FROM PCLUB.ADMPT_TIPO_CLIENTE
                       WHERE ADMPC_ESTADO = 'A'
                         AND ADMPV_PRVENTA IS NOT NULL
                         AND ADMPC_TBLCLIENTE = 'F')) CLIE;
      IF nro_registrosCC = 0 THEN
        K_CODERROR := 6;
        RAISE EX_ERROR;
      END IF;
    END;
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR
        INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
       WHERE ADMPN_COD_ERROR = K_CODERROR;
    EXCEPTION
      WHEN OTHERS THEN
        K_DESCERROR := 'ERROR';
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
    WHEN OTHERS THEN
      K_CODERROR  := 1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
  END ADMPS_ESCLIENTE;

  PROCEDURE ADMPS_VALIDASALDOKDXMOVIL(K_TIPO_DOC IN VARCHAR2,
                                      K_NUM_DOC  IN VARCHAR2,
                                      K_CODERROR OUT NUMBER) AS
  
    --****************************************************************
    -- Nombre SP           :  ADMPS_VALIDASALDOKDXMOVIL
    -- Propósito           :  Validar que el Saldo y el Kardex estén alineados (Bolsa Movil)
    -- Input               :  K_TIPO_DOC     - Tipo de Documento del Cliente
    --                        K_NUM_DOC      - Número de Documento del Cliente
    -- Output              :  K_CODERROR     - Código de Error
    -- Creado por          :  Susana Ramos
    -- Fec Creación        :  15/03/2013
    -- Fec Actualización   :
    --****************************************************************
  
    V_SALDO      NUMBER;
    V_SALDOKDX   NUMBER;
    V_SALDO_BONO NUMBER;
  
  BEGIN
    K_CODERROR   := 0;
    V_SALDO      := 0;
    V_SALDOKDX   := 0;
    V_SALDO_BONO := 0;
  
    SELECT SUM(NVL(S.ADMPN_SALDO_CC, 0) + NVL(S.ADMPN_SALDO_IB, 0))
      INTO V_SALDO
      FROM PCLUB.ADMPT_SALDOS_CLIENTE S
     INNER JOIN PCLUB.ADMPT_CLIENTE C
        ON (S.ADMPV_COD_CLI = C.ADMPV_COD_CLI)
     WHERE C.ADMPV_TIPO_DOC = K_TIPO_DOC
       AND C.ADMPV_NUM_DOC = K_NUM_DOC
       AND C.ADMPV_COD_TPOCL IN --('1', '2', '3')
           (SELECT ADMPV_COD_TPOCL
              FROM PCLUB.ADMPT_TIPO_CLIENTE
             WHERE ADMPC_ESTADO = 'A'
               AND ADMPV_PRVENTA IS NOT NULL
               AND ADMPC_TBLCLIENTE = 'M')
       AND C.ADMPC_ESTADO = 'A';
  
    SELECT NVL(SUM(SB.ADMPN_SALDO), 0)
      INTO V_SALDO_BONO
      FROM PCLUB.ADMPT_SALDOS_BONO_CLIENTE SB
     INNER JOIN PCLUB.ADMPT_CLIENTE C
        ON C.ADMPV_COD_CLI = SB.ADMPV_COD_CLI
     WHERE C.ADMPV_TIPO_DOC = K_TIPO_DOC
       AND C.ADMPV_NUM_DOC = K_NUM_DOC
       AND SB.ADMPN_SALDO > 0
       AND SB.ADMPV_ESTADO = 'A'
       AND C.ADMPV_COD_TPOCL IN
           (SELECT ADMPV_COD_TPOCL
              FROM PCLUB.ADMPT_TIPO_CLIENTE
             WHERE ADMPC_ESTADO = 'A'
               AND ADMPV_PRVENTA IS NOT NULL
               AND ADMPC_TBLCLIENTE = 'M');
  
    SELECT NVL(SUM(NVL(K.ADMPN_SLD_PUNTO, 0)), 0)
      INTO V_SALDOKDX
      FROM PCLUB.ADMPT_KARDEX K
     INNER JOIN PCLUB.ADMPT_CLIENTE C
        ON (K.ADMPV_COD_CLI = C.ADMPV_COD_CLI)
     WHERE C.ADMPV_TIPO_DOC = K_TIPO_DOC
       AND C.ADMPV_NUM_DOC = K_NUM_DOC
       AND C.ADMPV_COD_TPOCL IN --('1', '2', '3')
           (SELECT ADMPV_COD_TPOCL
              FROM PCLUB.ADMPT_TIPO_CLIENTE
             WHERE ADMPC_ESTADO = 'A'
               AND ADMPV_PRVENTA IS NOT NULL
               AND ADMPC_TBLCLIENTE = 'M')
       AND C.ADMPC_ESTADO = 'A'
       AND K.ADMPC_ESTADO = 'A'
       AND K.ADMPC_TPO_OPER = 'E'
       AND K.ADMPN_SLD_PUNTO > 0;
  
    IF (V_SALDO + V_SALDO_BONO) <> V_SALDOKDX THEN
      K_CODERROR := 1;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR := 1;
    
  END ADMPS_VALIDASALDOKDXMOVIL;

  PROCEDURE ADMPS_VALIDASALDOKDXFIJA(K_TIPO_DOC IN VARCHAR2,
                                     K_NUM_DOC  IN VARCHAR2,
                                     K_CODERROR OUT NUMBER) AS
    --****************************************************************
    -- Nombre SP           :  ADMPS_VALIDASALDOKDXFIJA
    -- Propósito           :  Validar que el Saldo y el Kardex estén alineados (Bolsa Fija)
    -- Input               :  K_TIPO_DOC     - Tipo de Documento del Cliente
    --                        K_NUM_DOC      - Número de Documento del Cliente
    -- Output              :  K_CODERROR     - Código de Error
    -- Creado por          :  Susana Ramos
    -- Fec Creación        :  15/03/2013
    -- Fec Actualización   :
    --****************************************************************
    V_SALDO    NUMBER;
    V_SALDOKDX NUMBER;
  BEGIN
    K_CODERROR := 0;
    V_SALDO    := 0;
    V_SALDOKDX := 0;
  
    SELECT NVL(SUM(NVL(S.ADMPN_SALDO_CC, 0)), 0)
      INTO V_SALDO
      FROM PCLUB.ADMPT_SALDOS_CLIENTEFIJA S
     INNER JOIN PCLUB.ADMPT_CLIENTEPRODUCTO P
        ON (S.ADMPV_COD_CLI_PROD = P.ADMPV_COD_CLI_PROD)
     INNER JOIN PCLUB.ADMPT_CLIENTEFIJA C
        ON (P.ADMPV_COD_CLI = C.ADMPV_COD_CLI)
     WHERE C.ADMPV_TIPO_DOC = K_TIPO_DOC
       AND C.ADMPV_NUM_DOC = K_NUM_DOC
       AND C.ADMPV_COD_TPOCL IN --('6', '7')
           (SELECT ADMPV_COD_TPOCL
              FROM PCLUB.ADMPT_TIPO_CLIENTE
             WHERE ADMPC_ESTADO = 'A'
               AND ADMPV_PRVENTA IS NOT NULL
               AND ADMPC_TBLCLIENTE = 'F')
       AND C.ADMPC_ESTADO = 'A'
       AND P.ADMPV_ESTADO_SERV = 'A';
  
    SELECT NVL(SUM(NVL(K.ADMPN_SLD_PUNTO, 0)), 0)
      INTO V_SALDOKDX
      FROM PCLUB.ADMPT_KARDEXFIJA K
     INNER JOIN PCLUB.ADMPT_CLIENTEPRODUCTO P
        ON (K.ADMPV_COD_CLI_PROD = P.ADMPV_COD_CLI_PROD)
     INNER JOIN PCLUB.ADMPT_CLIENTEFIJA C
        ON (P.ADMPV_COD_CLI = C.ADMPV_COD_CLI)
     WHERE C.ADMPV_TIPO_DOC = K_TIPO_DOC
       AND C.ADMPV_NUM_DOC = K_NUM_DOC
       AND C.ADMPV_COD_TPOCL IN --('6', '7')
           (SELECT ADMPV_COD_TPOCL
              FROM PCLUB.ADMPT_TIPO_CLIENTE
             WHERE ADMPC_ESTADO = 'A'
               AND ADMPV_PRVENTA IS NOT NULL
               AND ADMPC_TBLCLIENTE = 'F')
       AND C.ADMPC_ESTADO = 'A'
       AND P.ADMPV_ESTADO_SERV = 'A'
       AND K.ADMPC_ESTADO = 'A'
       AND K.ADMPC_TPO_OPER = 'E'
       AND K.ADMPN_SLD_PUNTO > 0;
  
    IF V_SALDO <> V_SALDOKDX THEN
      K_CODERROR := 1;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR := 1;
    
  END ADMPS_VALIDASALDOKDXFIJA;

  PROCEDURE ADMPS_OBTNUMLINEA(K_COD_TPOCL  IN VARCHAR2,
                              K_COD_CLI    IN VARCHAR2,
                              K_NUMLINEACJ OUT VARCHAR2,
                              K_CODERROR   OUT NUMBER,
                              K_DESCERROR  OUT VARCHAR2) IS
    --****************************************************************
    -- Nombre SP           :  ADMPS_OBTNUMLINEA
    -- Propósito           :  Obtener el numero de linea sobre la cual se generará la interacción
    -- Input               :  K_COD_TPOCL - Tipo de Cliente
    --                        K_COD_CLI  - Código de Cliente
    -- Output              :  K_CODERROR
    --                        K_DESCERROR
    -- Creado por          :  Roxana Chero
    -- Fec Creación        :  23/05/2013
    --****************************************************************
    EX_ERROR EXCEPTION;
  
  BEGIN
    CASE
      WHEN K_COD_TPOCL IS NULL THEN
        K_NUMLINEACJ := '';
        K_CODERROR   := 4;
        K_DESCERROR  := 'Ingrese un Tipo de Cliente válido. ';
        RAISE EX_ERROR;
      WHEN K_COD_CLI IS NULL THEN
        K_NUMLINEACJ := '';
        K_CODERROR   := 4;
        K_DESCERROR  := 'Ingrese un Código de Cliente válido. ';
        RAISE EX_ERROR;
      ELSE
        K_CODERROR  := 0;
        K_DESCERROR := ' ';
    END CASE;
  
    BEGIN
      IF K_COD_TPOCL = '2' OR K_COD_TPOCL = '6' THEN
        SELECT NVL(CLI.DN_NUM, '')
          INTO K_NUMLINEACJ
          FROM (SELECT P.DN_NUM
                  FROM tim.PP_DATOS_CONTRATO@DBL_BSCS P
                 INNER JOIN sysadm.CUSTOMER_ALL@DBL_BSCS C
                    ON P.CUSTOMER_ID = C.CUSTOMER_ID
                 WHERE C.CUSTCODE = K_COD_CLI
                   AND P.CH_STATUS = 'a'
                 ORDER BY P.FEC_ACTIVACION ASC) CLI
         WHERE ROWNUM = 1;
      
      ELSIF K_COD_TPOCL = '3' OR K_COD_TPOCL = '8' THEN
        K_NUMLINEACJ := K_COD_CLI;
      ELSE
        K_NUMLINEACJ := '';
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        K_NUMLINEACJ := '';
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
      K_NUMLINEACJ := '';
    WHEN OTHERS THEN
      K_NUMLINEACJ := '';
      K_CODERROR   := 1;
      K_DESCERROR  := SUBSTR(SQLERRM, 1, 250);
  END ADMPS_OBTNUMLINEA;

  PROCEDURE ADMPS_CONSALDO_CANJE(K_TIPO_DOC     IN VARCHAR2,
                                 K_NUM_DOC      IN VARCHAR2,
                                 K_LINEA        IN VARCHAR2, --NUEVO
                                 K_PROCESO      IN VARCHAR2,
                                 K_SALDO_TOTAL  OUT NUMBER,
                                 K_CUR_SALDOS   OUT SYS_REFCURSOR,
                                 K_NUM_FACTOR   OUT NUMBER,
                                 K_CUR_CAMPANHA OUT SYS_REFCURSOR,
                                 K_CODERROR     OUT NUMBER,
                                 K_DESCERROR    OUT VARCHAR2) IS
  
    --****************************************************************
    -- Nombre SP           :  ADMPS_CONSALDO
    -- Propósito           :  Permite consultar los saldos de clientes
    -- Input               :  K_TIPO_DOC     - Tipo de Documento del Cliente
    --                        K_NUM_DOC      - Número de Documento del Cliente
    --                        K_LINEA        - Numero de Linea
    -- Output              :  K_SALDO_TOTAL  - Saldo de Todas las Bolsas ( Puntos CC e IB)
    --                        K_CUR_SALDOS   - Cursor
    --                        K_NUM_FACTOR   - Factor de Equivalencia de Puntos a Soles
    --                        K_CUR_CAMPANHA - Cursor de Campaña
    --                        K_CODERROR     - Código de Error
    --                        K_DESCERROR    - Descripción del Error
    -- Creado por          :  Susana Ramos
    -- Fec Creación        :  15/03/2013
    -- Fec Actualización   :
    --****************************************************************
  
    VT_SALDO       T_SALDOXTIPOCLIE;
    VT_LISTA_SALDO T_TBLSALDOXTIPOCLIE := T_TBLSALDOXTIPOCLIE();
  
    CURSOR CUR_SALDOS(TIPO_DOC VARCHAR2, NUM_DOC VARCHAR2) IS
      SELECT T.ADMPV_TIPO,
             MAX(T.ADMPV_COD_TPOCL),
             (SELECT Admpv_Cod_Cli
                FROM (SELECT T.ADMPV_TIPO,
                             Cli.Admpv_Cod_Tpocl,
                             Cli.Admpv_Cod_Cli,
                             Cli.Admpd_Fec_Activ
                        FROM PCLUB.ADMPT_CLIENTE Cli
                       INNER JOIN PCLUB.ADMPT_TIPO_CLIENTE T
                          ON (T.ADMPV_COD_TPOCL = Cli.Admpv_Cod_Tpocl)
                       WHERE Cli.ADMPV_TIPO_DOC = TIPO_DOC
                         AND Cli.ADMPV_NUM_DOC = NUM_DOC
                         AND Cli.ADMPC_ESTADO = 'A'
                       ORDER BY CLI.ADMPD_FEC_ACTIV ASC) CLI
               WHERE ADMPV_TIPO = T.ADMPV_TIPO
                 AND ROWNUM = 1) AS ADMPV_COD_CLI,
             '' AS ADMPV_COD_CLI_PROD,
             --MAX(T.ADMPV_PRVENTA) ADMPV_PRVENTA,
             MAX(PC.ADMPV_PRIORIDAD) ADMPV_PRVENTA,
             MAX(T.ADMPC_TBLCLIENTE) ADMPC_TBLCLIENTE,
             SUM(NVL(S.ADMPN_SALDO_CC, 0)) AS ADMPN_SALDO_CC,
             NVL(SUM(DECODE(S.ADMPC_ESTPTO_IB, 'B', 0, S.ADMPN_SALDO_IB)),
                 0) AS ADMPN_SALDO_IB,
             SUM(NVL(SB.ADMPN_SALDO, 0)) AS ADMPN_SALDO_BONO -- NUEVO
        FROM PCLUB.ADMPT_CLIENTE C
       INNER JOIN PCLUB.ADMPT_TIPO_CLIENTE T
          ON (C.ADMPV_COD_TPOCL = T.ADMPV_COD_TPOCL AND
             T.ADMPV_PRVENTA IS NOT NULL AND T.ADMPV_TIPO IS NOT NULL)
       INNER JOIN PCLUB.ADMPT_PROC_CANJE PC
          ON PC.ADMPV_COD_TPOCL = T.ADMPV_COD_TPOCL
       INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTE S
          ON (C.ADMPV_COD_CLI = S.ADMPV_COD_CLI AND S.ADMPC_ESTPTO_CC = 'A')
        LEFT JOIN PCLUB.ADMPT_SALDOS_BONO_CLIENTE SB -- NUEVO
          ON (C.ADMPV_COD_CLI = SB.ADMPV_COD_CLI AND SB.ADMPV_ESTADO = 'A' AND
             SB.ADMPN_GRUPO = '2' AND SB.ADMPV_COD_CLI = K_LINEA) -- NUEVO
       WHERE C.ADMPV_TIPO_DOC = TIPO_DOC
         AND C.ADMPV_NUM_DOC = NUM_DOC
         AND C.ADMPC_ESTADO = 'A'
         AND PC.ADMPV_IDPROC = K_PROCESO
       GROUP BY T.ADMPV_TIPO
      UNION ALL
      SELECT T.ADMPV_TIPO,
             MAX(T.ADMPV_COD_TPOCL),
             MAX(C.ADMPV_COD_CLI) AS ADMPV_COD_CLI,
             (SELECT ADMPV_COD_CLI_PROD
                FROM (SELECT T.ADMPV_TIPO,
                             F.ADMPV_COD_TPOCL,
                             F.ADMPV_COD_CLI,
                             CP.ADMPV_COD_CLI_PROD,
                             CP.ADMPD_FEC_REG
                        FROM PCLUB.ADMPT_CLIENTEPRODUCTO CP
                       INNER JOIN PCLUB.ADMPT_CLIENTEFIJA F
                          ON (CP.ADMPV_COD_CLI = F.ADMPV_COD_CLI)
                       INNER JOIN PCLUB.ADMPT_TIPO_CLIENTE T
                          ON (T.ADMPV_COD_TPOCL = F.ADMPV_COD_TPOCL)
                       WHERE F.ADMPV_TIPO_DOC = TIPO_DOC
                         AND F.ADMPV_NUM_DOC = NUM_DOC
                         AND F.ADMPC_ESTADO = 'A'
                         AND CP.ADMPV_ESTADO_SERV = 'A'
                       ORDER BY CP.ADMPD_FEC_REG ASC) CLI
               WHERE ADMPV_TIPO = T.ADMPV_TIPO
                 AND ROWNUM = 1) AS ADMPV_COD_CLI_PROD,
             --MAX(T.ADMPV_PRVENTA) ADMPV_PRVENTA,
             MAX(PC.ADMPV_PRIORIDAD) ADMPV_PRVENTA,
             MAX(T.ADMPC_TBLCLIENTE) ADMPC_TBLCLIENTE,
             SUM(NVL(S.ADMPN_SALDO_CC, 0)) AS ADMPN_SALDO_CC,
             NVL(SUM(DECODE(S.ADMPC_ESTPTO_IB, 'B', 0, S.ADMPN_SALDO_IB)),
                 0) AS ADMPN_SALDO_IB,
             0 AS ADMPN_SALDO_BONO --NUEVO
        FROM PCLUB.ADMPT_CLIENTEFIJA C
       INNER JOIN PCLUB.ADMPT_TIPO_CLIENTE T
          ON (C.ADMPV_COD_TPOCL = T.ADMPV_COD_TPOCL AND
             T.ADMPV_PRVENTA IS NOT NULL AND T.ADMPV_TIPO IS NOT NULL)
       INNER JOIN PCLUB.ADMPT_CLIENTEPRODUCTO P
          ON (C.ADMPV_COD_CLI = P.ADMPV_COD_CLI AND
             P.ADMPV_ESTADO_SERV = 'A')
       INNER JOIN PCLUB.ADMPT_PROC_CANJE PC
          ON PC.ADMPV_COD_TPOCL = T.ADMPV_COD_TPOCL
       INNER JOIN PCLUB.ADMPT_SALDOS_CLIENTEFIJA S
          ON (P.ADMPV_COD_CLI_PROD = S.ADMPV_COD_CLI_PROD AND
             S.ADMPC_ESTPTO_CC = 'A')
       WHERE C.ADMPV_TIPO_DOC = TIPO_DOC
         AND C.ADMPV_NUM_DOC = NUM_DOC
         AND C.ADMPC_ESTADO = 'A'
         AND PC.ADMPV_IDPROC = K_PROCESO
       GROUP BY T.ADMPV_TIPO
       ORDER BY ADMPV_PRVENTA ASC;
  
    C_COD_TPOCL    VARCHAR2(2);
    C_COD_CLI      VARCHAR2(40);
    C_COD_CLI_PROD VARCHAR2(40);
    C_DES_TPOCL    VARCHAR2(20);
    C_PRVENTA      VARCHAR2(2);
    C_TBLCLIENTE   CHAR(1);
    C_SALDO_CC     NUMBER;
    C_SALDO_IB     NUMBER;
    C_SALDO_BONO   NUMBER;
    V_SALDO_TOTAL  NUMBER;
    V_EQUIV_SOLES  NUMBER;
    V_TIPO_DOC     VARCHAR2(10);
    V_PUNTOS       NUMBER := 0;
    V_CONTREG      NUMBER := 0;
    EX_ERROR EXCEPTION;
  
  BEGIN
  
    CASE
      WHEN K_TIPO_DOC IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese el tipo de documento. ';
        RAISE EX_ERROR;
      WHEN K_NUM_DOC IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese el número de documento. ';
        RAISE EX_ERROR;
      ELSE
        K_CODERROR  := 0;
        K_DESCERROR := ' ';
    END CASE;
  
    V_TIPO_DOC := PCLUB.PKG_CC_TRANSACCION.F_OBTENERTIPODOC(K_TIPO_DOC);
  
    IF V_TIPO_DOC IS NULL THEN
      K_CODERROR  := 4;
      K_DESCERROR := 'El tipo de documento no fue encontrado. ';
      RAISE EX_ERROR;
    END IF;
  
    BEGIN
      SELECT TO_NUMBER(ADMPV_VALOR, '9.9999')
        INTO K_NUM_FACTOR
        FROM PCLUB.ADMPT_PARAMSIST
       WHERE ADMPV_DESC = 'FACTOR_CONVERSION_PTOS_A_SOLES';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        K_CODERROR  := 9;
        K_DESCERROR := 'No existe el parámetro de sistema FACTOR_CONVERSION_PTOS_A_SOLES.';
        RAISE EX_ERROR;
    END;
  
    --Validamos si existe alguna desalineacion del kárdex-------
    PCLUB.PKG_CC_CANJEVTA.ADMPS_VALIDASALDOKDXMOVIL(K_TIPO_DOC,
                                                    K_NUM_DOC,
                                                    K_CODERROR);
    IF K_CODERROR = 1 THEN
      K_CODERROR  := 33;
      K_DESCERROR := ' - Bolsa Móvil';
      RAISE EX_ERROR;
    END IF;
  
    PCLUB.PKG_CC_CANJEVTA.ADMPS_VALIDASALDOKDXFIJA(K_TIPO_DOC,
                                                   K_NUM_DOC,
                                                   K_CODERROR);
    IF K_CODERROR = 1 THEN
      K_CODERROR  := 33;
      K_DESCERROR := ' - Bolsa Fija';
      RAISE EX_ERROR;
    END IF;
    -------------------------------------------------------------
  
    VT_SALDO := T_SALDOXTIPOCLIE(NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL);
  
    OPEN CUR_SALDOS(K_TIPO_DOC, K_NUM_DOC);
    FETCH CUR_SALDOS
      INTO C_DES_TPOCL,
           C_COD_TPOCL,
           C_COD_CLI,
           C_COD_CLI_PROD,
           C_PRVENTA,
           C_TBLCLIENTE,
           C_SALDO_CC,
           C_SALDO_IB,
           C_SALDO_BONO; --AGREG
    WHILE CUR_SALDOS%FOUND LOOP
      V_CONTREG     := V_CONTREG + 1;
      V_SALDO_TOTAL := C_SALDO_CC + C_SALDO_IB + C_SALDO_BONO; --AGREG
    
      V_EQUIV_SOLES := ROUND(V_SALDO_TOTAL * K_NUM_FACTOR, 2);
    
      V_PUNTOS := V_PUNTOS + V_SALDO_TOTAL;
      VT_LISTA_SALDO.EXTEND;
      VT_SALDO.COD_TPOCL := C_COD_TPOCL;
      VT_SALDO.COD_CLI := C_COD_CLI;
      VT_SALDO.COD_CLI_PROD := C_COD_CLI_PROD;
      VT_SALDO.DES_TIPO := C_DES_TPOCL;
      VT_SALDO.PRVENTA := C_PRVENTA;
      VT_SALDO.TBLCLIENTE := C_TBLCLIENTE;
      VT_SALDO.SALDO_CC := C_SALDO_CC;
      VT_SALDO.SALDO_IB := C_SALDO_IB;
      VT_SALDO.SALDO_BONO := C_SALDO_BONO; --AGREG
      VT_SALDO.SALDO_TOTAL := V_SALDO_TOTAL;
      VT_SALDO.EQUIV_SOLES := V_EQUIV_SOLES;
      VT_LISTA_SALDO(V_CONTREG) := VT_SALDO;
      FETCH CUR_SALDOS
        INTO C_DES_TPOCL,
             C_COD_TPOCL,
             C_COD_CLI,
             C_COD_CLI_PROD,
             C_PRVENTA,
             C_TBLCLIENTE,
             C_SALDO_CC,
             C_SALDO_IB,
             C_SALDO_BONO;
    END LOOP;
    CLOSE CUR_SALDOS;
  
    IF V_CONTREG = 0 THEN
      K_CODERROR := 6;
      RAISE EX_ERROR;
    END IF;
  
    K_SALDO_TOTAL := V_PUNTOS;
  
    OPEN K_CUR_SALDOS FOR
      SELECT T.DES_TIPO,
             T.COD_TPOCL,
             T.COD_CLI,
             T.COD_CLI_PROD,
             T.PRVENTA,
             T.TBLCLIENTE,
             T.SALDO_CC,
             T.SALDO_IB,
             T.SALDO_TOTAL,
             T.EQUIV_SOLES,
             T.SALDO_BONO
        FROM TABLE(CAST(VT_LISTA_SALDO AS T_TBLSALDOXTIPOCLIE)) T;
  
    OPEN K_CUR_CAMPANHA FOR
      SELECT C.ADMPN_ID_CAMP,
             C.ADMPV_DESCRIPCION,
             T.ADMPV_TIPO,
             D.ADMPN_VALOR
        FROM PCLUB.ADMPT_CAMPANHA C
       INNER JOIN PCLUB.ADMPT_CAMPANHA_DET D
          ON (C.ADMPN_ID_CAMP = D.ADMPN_ID_CAMP AND
             C.ADMPV_ESTADO = D.ADMPC_ESTADO)
       INNER JOIN PCLUB.ADMPT_TIPO_CLIENTE T
          ON (T.ADMPV_COD_TPOCL = D.ADMPV_COD_TPOCL AND
             T.ADMPV_TIPO IS NOT NULL)
       WHERE TRUNC(SYSDATE) BETWEEN C.ADMPD_FEC_INI AND C.ADMPD_FEC_FIN
         AND C.ADMPV_ESTADO = 'A';
  
  EXCEPTION
    WHEN EX_ERROR THEN
      BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR
          INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_DESCERROR := '';
      END;
    
      OPEN K_CUR_SALDOS FOR
        SELECT '' DES_TIPO,
               '' COD_TPOCL,
               '' COD_CLI,
               '' COD_CLI_PROD,
               '' PRVENTA,
               '' TBLCLIENTE,
               '' SALDO_CC,
               '' SALDO_IB,
               '' SALDO_TOTAL,
               '' EQUIV_SOLES,
               '' SALDO_BONO
          FROM DUAL
         WHERE 1 = 0;
      OPEN K_CUR_CAMPANHA FOR
        SELECT '' ADMPN_ID_CAMP,
               '' ADMPV_DESCRIPCION,
               '' ADMPV_TIPO,
               '' ADMPN_VALOR
          FROM DUAL
         WHERE 1 = 0;
    WHEN OTHERS THEN
      K_CODERROR  := -1;
      K_DESCERROR := 'Ocurrió un error en el SP ADMPS_CONSALDO';
      BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR
          INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
         WHERE ADMPN_COD_ERROR = K_CODERROR;
      EXCEPTION
        WHEN OTHERS THEN
          K_DESCERROR := '';
      END;
      OPEN K_CUR_SALDOS FOR
        SELECT '' DES_TIPO,
               '' COD_TPOCL,
               '' COD_CLI,
               '' COD_CLI_PROD,
               '' PRVENTA,
               '' TBLCLIENTE,
               '' SALDO_CC,
               '' SALDO_IB,
               '' SALDO_TOTAL,
               '' EQUIV_SOLES,
               '' SALDO_BONO
          FROM DUAL
         WHERE 1 = 0;
      OPEN K_CUR_CAMPANHA FOR
        SELECT '' ADMPN_ID_CAMP,
               '' ADMPV_DESCRIPCION,
               '' ADMPV_TIPO,
               '' ADMPN_VALOR
          FROM DUAL
         WHERE 1 = 0;
  END ADMPS_CONSALDO_CANJE;
  
  PROCEDURE ADMPSI_DEVOLUC_CANJEVTA(K_ID_SOLICITUD IN VARCHAR2,
                                    K_PUNTOVENTA   IN VARCHAR2,
                                    K_VENTAID      IN VARCHAR2,
                                    K_PROCESO      IN VARCHAR2,
                                    K_TIPO_DOC     IN VARCHAR2,
                                    K_NUM_DOC      IN VARCHAR2,
                                    K_LINEA        IN VARCHAR2,
                                    K_USUARIO      IN VARCHAR2,
                                    K_PUNTOS       IN NUMBER, -- PROY-26366 FASE 2
                                    K_CODERROR     OUT NUMBER,
                                    K_DESCERROR    OUT VARCHAR2,
                                    K_SALDO        OUT NUMBER) IS
    --****************************************************************
    -- Nombre SP           :  ADMPSI_DEVOLUC_CANJEVTA
    -- Propósito           :  Registrar una devolución de un Canje Vta realizado
    -- Input               :  K_ID_SOLICITUD - Codigo de la solicitud
    --                        K_PUNTOVENTA
    --                        K_VENTAID  - Identificador de la Vta
    -- Output              :  K_CODERROR     --> Código de Error (si se presento)
    --                        K_DESCERROR    --> Mensaje de Error
    --                        K_SALDO        --> Saldo luego de registrar la devolucion
    -- Creado por          :  Roxana Chero
    -- Fec Creación        :  05/09/2013
    -- Fec Actualización   :
    --****************************************************************
  
    --Manejo de errores
    NO_EXISTE EXCEPTION;
    EX_ERROR EXCEPTION;
  
    --Para armar la lista de devolución
    K_LISTA_DEVOLUCION LISTA_DEVOLUCION;
    DET_DEVOLUCION     DEVOLUCION;
  
    V_COUNT_C   NUMBER; --Número de registros
    C_TIPO      VARCHAR2(20);
    C_ID_CANJE  NUMBER;
  
    CURSOR CURSOR_CANJVTA IS
      SELECT 'M' TIPO, C.ADMPV_ID_CANJE ID_CANJE
      FROM PCLUB.ADMPT_CANJE C
      WHERE C.ADMPV_VENTAID = K_VENTAID
      AND C.ADMPV_TPO_PROC=K_PROCESO
      UNION ALL
      SELECT 'F' TIPO, C.ADMPV_ID_CANJE ID_CANJE
      FROM PCLUB.ADMPT_CANJEFIJA C
      WHERE C.ADMPV_VENTAID = K_VENTAID
      AND C.ADMPV_TPO_PROC=K_PROCESO;
    
    V_COD_SEGMENTO     VARCHAR2(2);
    V_CUR_SALDOS   SYS_REFCURSOR;
    V_NUM_FACTOR   NUMBER;
    V_CUR_CAMPANHA SYS_REFCURSOR;
  BEGIN
  
    CASE
      WHEN K_ID_SOLICITUD IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese un ID Solicitud válido. ';
        RAISE EX_ERROR;
      WHEN K_PUNTOVENTA IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese un Punto de Venta válido. ';
        RAISE EX_ERROR;
        --Validar si se envió el identificador de canje
      WHEN K_VENTAID IS NULL THEN
        K_CODERROR  := 4;
        K_DESCERROR := 'Ingrese un Id. de Venta válido. ';
        RAISE EX_ERROR;
      ELSE
        K_CODERROR  := 0;
        K_DESCERROR := ' ';
    END CASE;
    
    K_SALDO := 0;
    -- Validamos que existan registros con el Identificador de Venta enviado
    SELECT COUNT(ADMPV_ID_CANJE)
      INTO V_COUNT_C
      FROM (SELECT C.ADMPV_ID_CANJE
              FROM PCLUB.ADMPT_CANJE C
             WHERE C.ADMPV_VENTAID = K_VENTAID
            UNION ALL
            SELECT C.ADMPV_ID_CANJE
              FROM PCLUB.ADMPT_CANJEFIJA C
             WHERE C.ADMPV_VENTAID = K_VENTAID) CANJE;
  
    IF V_COUNT_C = 0 THEN
      RAISE NO_EXISTE;
    ELSE
      --K_LISTA_DEVOLUCION := LISTA_DEVOLUCION();
    
      OPEN CURSOR_CANJVTA;
      LOOP
        FETCH CURSOR_CANJVTA
          INTO C_TIPO, C_ID_CANJE;
        EXIT WHEN CURSOR_CANJVTA%NOTFOUND;
      
        K_LISTA_DEVOLUCION := LISTA_DEVOLUCION();
        
        DET_DEVOLUCION := DEVOLUCION(NULL, NULL, NULL);
        DET_DEVOLUCION.ID_CANJE    := C_ID_CANJE;
        DET_DEVOLUCION.ID_CANJESEC := 1;
        DET_DEVOLUCION.CANTIDAD    := 1;
        K_LISTA_DEVOLUCION.EXTEND(1);
        K_LISTA_DEVOLUCION(1) := DET_DEVOLUCION;
      
        IF C_TIPO = 'M' THEN
          --Invoco al SP de devolución de la Móvil
          PCLUB.PKG_CC_TRANSACCION.ADMPSS_DEVPUNTS(K_ID_SOLICITUD,
                                                   K_PUNTOVENTA,
                                                   K_LISTA_DEVOLUCION,
                                                   K_PUNTOS, --PROY 26366 FASE 2
                                                   K_CODERROR,
                                                   K_DESCERROR,
                                                   K_SALDO);
        ELSIF C_TIPO = 'F' THEN
          
          PCLUB.PKG_CC_TRANSACCIONFIJA.ADMPSS_DEVPUNTS_FIJA(K_PUNTOVENTA,K_USUARIO,K_LISTA_DEVOLUCION,
                                                            K_CODERROR,K_DESCERROR,
                                                            K_SALDO);
          
        END IF;
      END LOOP;
      CLOSE CURSOR_CANJVTA;
      
      -- obtenemos el saldo actual despues de la devolucion
      BEGIN
         PCLUB.PKG_CC_CANJEVTA.ADMPS_CONSALDO(K_TIPO_DOC, K_NUM_DOC,
                                              K_LINEA, V_COD_SEGMENTO,
                                              K_SALDO, V_CUR_SALDOS,
                                              V_NUM_FACTOR, V_CUR_CAMPANHA,
                                              K_CODERROR, K_DESCERROR);
      EXCEPTION
        WHEN OTHERS THEN
          K_SALDO := 0;
      END;
      
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
          K_DESCERROR := 'ERROR';
      END;
    WHEN NO_EXISTE THEN
      K_CODERROR  := 99;
      K_DESCERROR := 'No existen registros para devolver, con el ID Venta proporcionado.';
    WHEN OTHERS THEN
      K_CODERROR  := SQLCODE;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 400);
  END ADMPSI_DEVOLUC_CANJEVTA;
  
END PKG_CC_CANJEVTA;
/
