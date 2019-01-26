CREATE OR REPLACE PACKAGE BODY PCLUB.PKG_CC_TRANSACCIONFIJA IS

---------------------------------- CANJE -----------------------------

PROCEDURE ADMPSS_CANJEPRODUC(K_COD_CLIENTE    IN  VARCHAR2,
                            K_TIPO_DOC       IN  VARCHAR2,
                            K_NUM_DOC        IN  VARCHAR2,
                            K_PUNTOVENTA     IN  VARCHAR2,
                            K_TIP_CLI        IN  VARCHAR2,
                            K_COD_APLI       IN  VARCHAR2,
                            K_CLAVE          IN  VARCHAR2,
                            K_NUMLINEASMS    IN  VARCHAR2,
                            K_LISTA_PEDIDO_HFC IN  LISTA_PEDIDO_HFC,
                            K_PREMIO_LINEA     IN CHAR,
                            K_TIPO_LINEA       IN VARCHAR2,
                            K_NUM_LINEA        IN  VARCHAR2,
                            K_COD_ASESOR       IN  VARCHAR2,
                            K_NOM_ASESOR       IN  VARCHAR2,
                            K_COD_CLI_PROD IN VARCHAR2,
                            K_DIRECCION_CLI IN VARCHAR2,
                            K_COD_SERV_SGA IN VARCHAR2,
                            K_USUARIO          IN VARCHAR2,
                            K_CODSEGMENTO  IN VARCHAR2,
                            K_USU_ASEG     IN VARCHAR2,
                            K_CODERROR         OUT NUMBER,
                            K_DESCERROR        OUT VARCHAR2,
                            K_SALDO            OUT NUMBER,
                            K_LISTA_CANJE      OUT SYS_REFCURSOR) is
    --****************************************************************
    -- Nombre SP           :  ADMPSS_CANJPROD
    -- Propósito           :  Registrar un canje
    -- Input               :  K_ID_SOLICITUD - Numero interno generado por Claro
    --                        K_COD_CLIENTE - Codigo de Cliente
    --                        K_TIPO_DOC - Tipo de Documento
    --                        K_NUM_DOC - Numero de Documento
    --                        K_PUNTOVENTA - Punto de Venta desde donde se realiza el canje
    --                        K_TIP_CLI - Tipo de Cliente
    --                        K_COD_APLI - Código de Aplicación
    --                        K_CLAVE - Palabra Clave
    --                        K_MSJSMS - Mensaje SMS
    --                        K_NUMLINEASMS - Num Linea SMS
    --                        K_TICKET - Numero de Ticket
    --                        K_LISTA_PEDIDO_HFC - Lista de Pedidos para el Canje
    --                        K_PREMIO_LINEA - Incluira Premio para una Linea 0 no, 1 si
    --                        K_TIPO_LINEA   - En Caso sea 1 (K_PREMIO_LINEA), se indica el Tipo de Linea : Control,PostPago,Prepago (1,2,3)
    --                        K_NUM_LINEA    - En Caso sea 1 (K_PREMIO_LINEA), se indica el numero de telefono, que recibira el premio
    --                        K_COD_ASESOR   - Codigo del Asesor
    --                        K_NOM_ASESOR   - Datos del Asesor
    --                        K_USUARIO      - Codigo del Usuario
    -- Output              :  K_CODERROR     --> Código de Error (si se presento)
    --                        K_DESCERROR    --> Descripcion del Error
    --                        K_SALDO        --> Saldo luego de registrar el canje
    --                        K_LISTA_CANJE  --> Listado de los productos canjeados
    -- Creado por          :  Susana Ramos
    -- Fec Creación        :
    -- Fec Actualización   :  22/05/2012
    --****************************************************************

    V_COD_CANJE NUMBER;
    V_ID_KARDEX NUMBER;

    V_PEDIDO_HFC PEDIDO_HFC;
    V_SEC               NUMBER;
    V_DESC_PREMIO       VARCHAR2(150);
    V_PUNTOS_REQUERIDOS NUMBER := 0;
    V_NUM_DOC           VARCHAR2(20);
    V_SALDO NUMBER;
    EX_ERROR  EXCEPTION;
    NO_LISTA_PEDIDO EXCEPTION;
    NO_SALDO EXCEPTION;
    NO_DESC_PUNTOS EXCEPTION;
    NO_PARAMETROS EXCEPTION;
    NO_COD_APLICACION EXCEPTION;
    NO_SLD_KDX_ALINEADO EXCEPTION;
    EX_BLOQUEO EXCEPTION;
    EX_DESBLOQUEO EXCEPTION;
    NO_VALBLOQUEO EXCEPTION;
    NO_LIBERADO EXCEPTION;
    EX_ERROR_DCTOPTO  EXCEPTION;
    V_CODERROR  NUMBER;
    V_COD_CPTO  NUMBER;
    V_DESCERROR VARCHAR2(400);
    K_ESTADO    CHAR(1);
    V_TIPO_DOC  VARCHAR2(20);
    K_CODERROR_EX  NUMBER;
    K_DESCERROR_EX VARCHAR2(400);
    NO_DATOS_VALIDOS EXCEPTION;
    V_EXISTE    NUMBER;
    V_TIPO_DOC_B VARCHAR2(20);

  V_SEGMENTO     VARCHAR2(5) := K_CODSEGMENTO;
  V_NRODOCSEGM   VARCHAR2(21);
  V_LONDOCSEGM   NUMBER;
  VC_PTOSDSCTO   NUMBER;
  V_ARRVALSEGM   TAB_ARRAY;
  V_ARRPUNTOS    TAB_ARRAY;
  V_ARRPTOSDSCTO TAB_ARRAY;
  
  V_NOMCLISEGM   VARCHAR2(400);
    V_MSJOKYSEGM   VARCHAR2(400);
    V_CODERRSEGM   NUMBER;
    V_MSJERRSEGM   VARCHAR2(400);
  V_CUR_SEGM     SYS_REFCURSOR;
  
  VC_CODSEGM     VARCHAR2(5);
    VC_DSCSEGM     VARCHAR2(50);
    VC_CODTCLIE    VARCHAR2(2);
    VC_DSCTCLIE    VARCHAR2(50);
    VC_CODTPREM    VARCHAR2(2);
    VC_DSCTPREM    VARCHAR2(50);
    VC_VALSEGM     VARCHAR2(5);

    CURSOR CUR_CLI_PRODUC(codigo_canje number, codigo_cliente varchar2 ) is
      Select B.ADMPV_COD_CLI_PROD,SUM(A.ADMPN_PUNTOS)  FROM PCLUB.ADMPT_KARDEXFIJA B
             INNER JOIN PCLUB.ADMPT_CANJEDT_KARDEXFIJA A ON (A.ADMPN_ID_KARDEX=B.ADMPN_ID_KARDEX)
             INNER JOIN PCLUB.ADMPT_CANJEFIJA C ON (A.ADMPV_ID_CANJE=C.ADMPV_ID_CANJE)
       WHERE A.ADMPV_ID_CANJE = V_COD_CANJE AND C.ADMPV_COD_CLI= codigo_cliente AND A.ADMPC_TPO_KARDEX='E'
       GROUP BY B.ADMPV_COD_CLI_PROD
       ORDER BY B.ADMPV_COD_CLI_PROD ASC;

    CUR_COD_CLIPROD PCLUB.ADMPT_KARDEXFIJA.ADMPV_COD_CLI_PROD%TYPE;
    PTOS_COD_CLIPROD PCLUB.ADMPT_KARDEXFIJA.ADMPN_PUNTOS%TYPE;
  BEGIN

    --LOS PUNTOS IB SON LOS Q SE CONSUMIRAN PRIMERO TIPO DE PUNTO 'I'
    --LOS PUNTOS LOYALTY 'L' Y CLAROCLUB 'C', SE CONSUMIRAN EN ESE ORDEN
    --
  -- Solo podemos validar si enviaron datos en codigo de cliente
  IF K_TIPO_DOC IS NULL OR K_NUM_DOC IS NULL OR K_COD_CLIENTE IS NULL THEN
     K_CODERROR:=4;
     IF K_COD_CLIENTE IS NULL THEN
          K_DESCERROR := 'Parámetro = K_COD_CLIENTE';
     END IF ;
     IF K_TIPO_DOC IS NULL THEN
          K_DESCERROR := K_DESCERROR  ||  ' Parámetro = K_TIPO_DOC';
     END IF ;
     IF K_NUM_DOC IS NULL THEN
          K_DESCERROR := K_DESCERROR  ||  ' Parámetro = K_NUM_DOC';
     END IF ;
     RAISE EX_ERROR;
  END IF;

  IF K_COD_APLI IS NULL THEN
      K_CODERROR:=4;
      K_DESCERROR := 'Parámetro = K_COD_APLI';
      RAISE NO_COD_APLICACION;
    END IF;

    V_TIPO_DOC_B := PCLUB.PKG_CC_TRANSACCION.F_OBTENERTIPODOC(K_TIPO_DOC);

       /*Validamos que se trate de un Cliente válido*/

    SELECT count(1)
     INTO V_EXISTE
     FROM PCLUB.ADMPT_CLIENTEFIJA
    WHERE ADMPV_COD_CLI = K_COD_CLIENTE
      AND admpv_tipo_doc = V_TIPO_DOC_B
      AND admpv_num_doc = K_NUM_DOC
      AND admpc_estado = 'A';

     IF V_EXISTE = 0 THEN
       K_CODERROR  := 49;
       RAISE NO_DATOS_VALIDOS;
     END IF;

   --******************************************
    ADMPSI_ES_CLIENTE(K_TIPO_DOC,
                      K_NUM_DOC,
                      K_TIP_CLI,
                      V_SALDO,
                      K_CODERROR,
                      K_DESCERROR);
    IF K_CODERROR <> 0 THEN
       K_CODERROR:=6;
       RAISE EX_ERROR;
    END IF;
    IF V_SALDO <= 0 THEN
      K_CODERROR:=24;
      RAISE EX_ERROR;
    END IF;

 PKG_CC_TRANSACCION.ADMPI_BLOQUEOBOLSA(K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,K_COD_ASESOR,K_ESTADO,K_CODERROR,K_DESCERROR);


    IF K_CODERROR = 0 AND K_ESTADO = 'L' THEN
      ADMPSS_VALIDASALDOKDX_FIJA( K_TIPO_DOC,
                                K_NUM_DOC,
                                K_TIP_CLI,
                                K_CODERROR);
    ELSE
        IF K_CODERROR = 37 AND K_ESTADO = 'R' THEN
          RAISE NO_LIBERADO;
        ELSE
          RAISE EX_BLOQUEO;
        END IF;
    END IF;


    IF K_CODERROR<>0 THEN
        K_CODERROR:=33;
        K_DESCERROR:='';
        RAISE NO_SLD_KDX_ALINEADO;
    END IF;

    -----  Obtiene la suma de puntos requeridos para comparar el saldo disponible con los puntos requeridos  -----
    --fetch K_LISTA_PEDIDO BULK COLLECT into L_LP_PROID, L_LP_CAMPANA, L_LP_PUNTOS, L_LP_PAGO, L_LP_CANTIDAD, L_LP_TIPOPREMIO, L_LP_SERVCOMERCIAL, L_LP_MONTORECARGA;

    IF K_LISTA_PEDIDO_HFC.COUNT = 0 THEN
      K_CODERROR:=4;
      K_DESCERROR := 'Parámetro = K_LISTA_PEDIDO_HFC';
      RAISE NO_LISTA_PEDIDO;
    END IF;
    IF (K_PUNTOVENTA = 'IVR')THEN --cambio
    BEGIN
        V_NRODOCSEGM := RPAD(TRIM(K_NUM_DOC), 21, 'X');
        V_LONDOCSEGM := LENGTH(TRIM(K_NUM_DOC));

        dm.PKG_SEGMENTACION.SS_OBTENER_SEGMENTO@dbl_reptdm_d('D',
                                                             V_LONDOCSEGM,
                                                             V_NRODOCSEGM,
                                                             V_SEGMENTO,
                                                             V_NOMCLISEGM,
                                                             V_MSJOKYSEGM,
                                                             V_MSJOKYSEGM,
                                                             V_MSJOKYSEGM,
                                                             V_MSJOKYSEGM,
                                                             V_CODERRSEGM,
                                                             V_MSJERRSEGM);
        IF V_CODERRSEGM <> 0 THEN
          V_SEGMENTO := 'C';
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          V_SEGMENTO := 'C';
      END;
    END IF;    

    FOR i IN K_LISTA_PEDIDO_HFC.FIRST .. K_LISTA_PEDIDO_HFC.LAST LOOP
      V_PEDIDO_HFC            := K_LISTA_PEDIDO_HFC(i);
        IF(K_PUNTOVENTA = 'IVR') THEN 
		BEGIN
        IF (K_TIPO_LINEA='2' OR K_TIPO_LINEA=3) THEN
           PCLUB.PKG_CC_MANTENIMIENTO.ADMPSS_LIST_DSCTO_SEG_TCLIE(V_SEGMENTO,K_TIPO_LINEA,V_PEDIDO_HFC.TipoPremio,'A',V_CUR_SEGM,V_CODERRSEGM,V_MSJERRSEGM);
        ELSE
           PCLUB.PKG_CC_MANTENIMIENTO.ADMPSS_LIST_DSCTO_SEG_TCLIE(V_SEGMENTO,K_TIP_CLI,V_PEDIDO_HFC.TipoPremio,'A',V_CUR_SEGM,V_CODERRSEGM,V_MSJERRSEGM);
        END IF;
        
        VC_VALSEGM   := 0;
        VC_PTOSDSCTO := V_PEDIDO_HFC.Puntos;
        IF V_CODERRSEGM = 0 THEN
          FETCH V_CUR_SEGM INTO VC_CODSEGM, VC_DSCSEGM, VC_CODTCLIE, VC_DSCTCLIE,VC_CODTPREM,VC_DSCTPREM,VC_VALSEGM,VC_DSCTCLIE,VC_DSCTCLIE;
          WHILE V_CUR_SEGM%FOUND LOOP
            FETCH V_CUR_SEGM INTO VC_CODSEGM,VC_DSCSEGM,VC_CODTCLIE,VC_DSCTCLIE,VC_CODTPREM,VC_DSCTPREM,VC_VALSEGM,VC_DSCTCLIE,VC_DSCTCLIE;
          END LOOP;
          VC_PTOSDSCTO := FLOOR((1 - VC_VALSEGM / 100) * V_PEDIDO_HFC.Puntos);
        END IF;
        V_PEDIDO_HFC.ValSegmento := VC_VALSEGM;
        V_PEDIDO_HFC.PuntosDscto := V_PEDIDO_HFC.Puntos - VC_PTOSDSCTO;
        V_PEDIDO_HFC.Puntos    := VC_PTOSDSCTO;
        V_ARRVALSEGM(I)       := V_PEDIDO_HFC.ValSegmento;
        V_ARRPTOSDSCTO(I)       := V_PEDIDO_HFC.PuntosDscto;
        V_ARRPUNTOS(I)         := V_PEDIDO_HFC.Puntos;
      EXCEPTION
        WHEN OTHERS THEN
        V_PEDIDO_HFC.ValSegmento := 0;
        V_PEDIDO_HFC.PuntosDscto := 0;
        V_ARRVALSEGM(I)    := 0;
        V_ARRPTOSDSCTO(I)    := 0;
        V_ARRPUNTOS(I)      := V_PEDIDO_HFC.Puntos;
      END;
    END IF;
    V_PUNTOS_REQUERIDOS := V_PUNTOS_REQUERIDOS +   V_PEDIDO_HFC.PUNTOS * V_PEDIDO_HFC.CANTIDAD;
    END LOOP;

    IF V_PUNTOS_REQUERIDOS > V_SALDO THEN
      K_CODERROR:=25;
      RAISE NO_SALDO;
    END IF;

    -- Comienza el Canje, dato de entrada el código de cliente
    -- Parámetros
    SELECT NVL(PCLUB.ADMPT_canjefija_sq.NEXTVAL, '-1')
      INTO V_COD_CANJE
      FROM dual;
    IF K_NUM_DOC IS NULL THEN
      SELECT admpv_num_doc
        INTO V_NUM_DOC
        FROM PCLUB.ADMPT_CLIENTEFIJA
      WHERE admpv_cod_cli = K_COD_CLIENTE AND
            admpc_estado = 'A';
    ELSE
      V_NUM_DOC := K_NUM_DOC;
    END IF;

    SAVEPOINT POINT_CANJE;
    -- Inserta entrada en la tabla CANJE
    INSERT INTO PCLUB.ADMPT_CANJEFIJA
      (admpv_id_canje,
       admpv_cod_cli,
       admpv_pto_venta,
       admpd_fec_canje,
       admpv_hra_canje,
       admpv_num_doc,
       admpv_cod_tpocl,
       admpv_cod_aseso,
       admpv_nom_aseso,
       admpc_tpo_oper,
       admpv_cod_tipapl,
       admpv_clave,
       admpv_num_linea_sms,
       admpv_premio_linea,
       admpv_tipo_linea,
       admpv_num_linea,
       admpv_cod_cli_prod,
       admpv_direc_cliprod,
       admpv_cod_serv_sga,
       admpv_usu_reg,
       ADMPV_CODSEGMENTO,
       ADMPV_USU_ASEG
    )
    values
      (V_COD_CANJE,
       K_COD_CLIENTE,
       K_PUNTOVENTA,
       TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
       TO_CHAR(SYSDATE, 'HH:MI AM'),
       V_NUM_DOC,
       K_TIP_CLI,
       k_cod_asesor,
       k_nom_asesor,
       'C',
       K_COD_APLI,
       K_CLAVE,
       K_NUMLINEASMS,
       K_PREMIO_LINEA,
       K_TIPO_LINEA,
       k_num_linea,
       K_COD_CLI_PROD,
       K_DIRECCION_CLI,
       K_COD_SERV_SGA,
       K_USUARIO,
       K_CODSEGMENTO,
       K_USU_ASEG
      );

    -- Inserta entrada en la tabla CANJE_DETALLE
    V_SEC := 1;

    FOR I IN K_LISTA_PEDIDO_HFC.FIRST .. K_LISTA_PEDIDO_HFC.LAST LOOP
      V_PEDIDO_HFC := K_LISTA_PEDIDO_HFC(I);
      IF (K_PUNTOVENTA = 'IVR') THEN --cambio 
        V_PEDIDO_HFC.ValSegmento := V_ARRVALSEGM(i);
        V_PEDIDO_HFC.PuntosDscto := V_ARRPTOSDSCTO(i);
        V_PEDIDO_HFC.Puntos      := V_ARRPUNTOS(i);
      END IF;
      -- parámetros
          SELECT admpv_desc
            INTO V_DESC_PREMIO
            FROM PCLUB.ADMPT_premio
          WHERE admpv_id_procla = Upper(V_PEDIDO_HFC.ProdId)
             AND admpv_cod_tpopr = V_PEDIDO_HFC.TipoPremio
             AND admpc_estado = 'A';

          -- Inserta en Canje Detalle
          INSERT INTO PCLUB.ADMPT_canje_detallefija
            (admpv_id_canje,  admpv_id_canjesec,      admpv_id_procla,
             admpv_desc,      admpv_nom_camp,         admpn_puntos,
             admpn_pago,      admpn_cantidad,         admpv_cod_tpopr,
             admpn_cod_servc, admpn_mnt_recar,        admpc_estado,admpv_cod_paqdat,
             ADMPN_VALSEGMENTO,ADMPN_PUNTOSDSCTO,
             admpv_usu_reg  )
          VALUES    (V_COD_CANJE,            V_SEC,            V_PEDIDO_HFC.ProdId,
                     V_DESC_PREMIO,          V_PEDIDO_HFC.Campana, V_PEDIDO_HFC.Puntos,
                     V_PEDIDO_HFC.Pago,          V_PEDIDO_HFC.Cantidad,V_PEDIDO_HFC.TipoPremio,
                     V_PEDIDO_HFC.ServComercial, V_PEDIDO_HFC.MontoRecarga,    'C', V_PEDIDO_HFC.codpaqdat,
                     V_PEDIDO_HFC.ValSegmento, V_PEDIDO_HFC.PuntosDscto,
                     K_USUARIO);

           admpsi_desc_puntos(V_COD_CANJE, V_SEC,   V_PEDIDO_HFC.Puntos * V_PEDIDO_HFC.Cantidad,    K_COD_CLIENTE,
                         K_TIPO_DOC,   K_NUM_DOC,  K_TIP_CLI, K_USUARIO , V_CODERROR, V_DESCERROR);
            IF V_CODERROR > 0 THEN
              K_CODERROR:=21;
              RAISE EX_ERROR_DCTOPTO;
            END IF;
             V_SEC := V_SEC + 1;
    END LOOP;

    --Insertar entrada en la tabla KARDEX 
    BEGIN
       IF  K_TIP_CLI='6' THEN
          SELECT NVL(admpv_cod_cpto, '-1')    INTO V_COD_CPTO
          FROM PCLUB.ADMPT_concepto
          WHERE admpv_desc='CANJE DTH';
       ELSIF K_TIP_CLI='7' THEN
          SELECT NVL(admpv_cod_cpto, '-1')    INTO V_COD_CPTO
          FROM PCLUB.ADMPT_concepto
          WHERE admpv_desc = 'CANJE HFC';
       END IF ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN V_COD_CPTO:=NULL;
    END;

-------
     OPEN CUR_CLI_PRODUC(V_COD_CANJE,K_COD_CLIENTE);
        FETCH CUR_CLI_PRODUC
               INTO CUR_COD_CLIPROD, PTOS_COD_CLIPROD;
               WHILE CUR_CLI_PRODUC%FOUND LOOP
               BEGIN
                SELECT NVL(PCLUB.ADMPT_kardexfija_sq.NEXTVAL, '-1')
                     INTO V_ID_KARDEX
                FROM dual;

                 INSERT INTO PCLUB.ADMPT_kardexfija (admpn_id_kardex, admpn_cod_cli_ib,ADMPV_COD_CLI_PROD,
                             admpv_cod_cpto,  admpd_fec_trans, admpn_puntos, admpv_nom_arch, admpc_tpo_oper,
                             admpc_tpo_punto, admpn_sld_punto, admpc_estado,admpv_usu_reg,admpv_id_canje)
                 VALUES (V_ID_KARDEX,   '',    CUR_COD_CLIPROD,
                        V_COD_CPTO, SYSDATE,  PTOS_COD_CLIPROD * (-1),'', 'S',
                        'C', 0,'C', K_USUARIO,V_COD_CANJE); -- Consultar sobre el tipo de operacion
                -- Inserta Canje_kardex de las salidas de la tabla Kardexfija

               --INSERT INTO PCLUB.ADMPT_canjedt_kardexFIJA (admpv_id_canje, admpn_id_kardex,admpv_id_canjesec,admpn_puntos,Admpc_Tpo_Kardex)
               --     VALUES (V_COD_CANJE, V_ID_KARDEX, 0 , PTOS_COD_CLIPROD,'S');--

               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                   K_CODERROR  := 40;
                   K_DESCERROR := 'ERROD';
               END;
           FETCH CUR_CLI_PRODUC
               INTO CUR_COD_CLIPROD,PTOS_COD_CLIPROD ;
        END LOOP;
     CLOSE CUR_CLI_PRODUC;

    -- Actualiza el canje 
    --   UPDATE PCLUB.ADMPT_canjeFIJA     SET admpn_id_kardex = V_ID_KARDEX
    --       WHERE admpv_id_canje = V_COD_CANJE;

    COMMIT;
    --  Obtener Saldo  
    ADMPSI_ES_CLIENTE(K_TIPO_DOC,
                      K_NUM_DOC,
                      K_TIP_CLI,
                      V_SALDO,
                      K_CODERROR,
                      K_DESCERROR);

    K_SALDO := V_SALDO;

    --  Lista de Canje  
    OPEN K_LISTA_CANJE FOR
      SELECT cdet.admpv_id_procla   AS ProdId,
             pr.admpv_desc          AS ProdDes,
             cdet.admpv_nom_camp    AS Campana,
             cdet.admpn_puntos      AS Puntos,
             cdet.admpn_pago        AS Pago,
             cdet.admpn_cantidad    AS Cantidad,
             cdet.admpv_id_canje    AS IDCanje,
             cdet.admpv_id_canjesec AS IDCanjeSec,
             cdet.admpv_cod_tpopr   AS TipoPremio,
             cdet.admpn_cod_servc   AS ServComercial,
             cdet.admpn_mnt_recar   AS MontoRecarga,
             cdet.admpn_valsegmento AS ValSegmento,
             cdet.admpn_puntosdscto AS PuntosDscto
        FROM PCLUB.ADMPT_canje_detalleFIJA cdet, PCLUB.ADMPT_premio pr
       WHERE cdet.admpv_id_procla = pr.admpv_id_procla
         AND cdet.admpv_id_canje = V_COD_CANJE;



  BEGIN
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR=K_CODERROR;
  EXCEPTION WHEN OTHERS THEN
      K_DESCERROR:='ERROR';
  END;

 EXCEPTION
    --Excepciones antes del Bloqueo
    WHEN EX_ERROR THEN
      BEGIN
          SELECT ADMPV_DES_ERROR INTO K_DESCERROR
          FROM  PCLUB.ADMPT_ERRORES_CC
          WHERE ADMPN_COD_ERROR=K_CODERROR;
      EXCEPTION WHEN OTHERS THEN
          K_DESCERROR:='ERROR';
      END;
      OPEN K_LISTA_CANJE FOR
        SELECT
        '' ProdId,
        '' ProdDes,
        '' Campana,
        '' Puntos,
        '' Pago,
        '' Cantidad,
        '' IDCanje,
        '' IDCanjeSec,
        '' TipoPremio,
        '' ServComercial,
        '' MontoRecarga
        FROM DUAL;

    WHEN NO_COD_APLICACION THEN
      BEGIN
          SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
          FROM  PCLUB.ADMPT_ERRORES_CC
          WHERE ADMPN_COD_ERROR=K_CODERROR;
      EXCEPTION WHEN OTHERS THEN
          K_DESCERROR:='ERROR';
      END;
      OPEN K_LISTA_CANJE FOR
        SELECT
        '' ProdId,
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
        '' ValSegmento,
        '' PuntosDscto
        FROM DUAL;
    WHEN NO_DATOS_VALIDOS THEN
      BEGIN
          SELECT ADMPV_DES_ERROR INTO K_DESCERROR
          FROM   ADMPT_ERRORES_CC
          WHERE ADMPN_COD_ERROR=K_CODERROR;
      EXCEPTION WHEN OTHERS THEN
          K_DESCERROR:='ERROR';
      END;
      OPEN K_LISTA_CANJE FOR
        SELECT
        '' ProdId,
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
        '' ValSegmento,
        '' PuntosDscto
        FROM DUAL;
    --Excepciones si no realiza el Bloqueo
    WHEN EX_BLOQUEO THEN
      BEGIN
          SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
          FROM  PCLUB.ADMPT_ERRORES_CC
          WHERE ADMPN_COD_ERROR=K_CODERROR;
      EXCEPTION WHEN OTHERS THEN
          K_DESCERROR:='ERROR';
      END;

      OPEN K_LISTA_CANJE FOR
        SELECT
        '' ProdId,
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
        '' ValSegmento,
        '' PuntosDscto
        FROM DUAL;

    WHEN NO_LIBERADO THEN
      K_CODERROR := 37;
      K_DESCERROR := 'Existe un canje en proceso.';

        OPEN K_LISTA_CANJE FOR
        SELECT
        '' ProdId,
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
        '' ValSegmento,
        '' PuntosDscto
        FROM DUAL;
    --Excepciones después del Bloqueo
    WHEN NO_SALDO THEN
      BEGIN
          SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
          FROM  PCLUB.ADMPT_ERRORES_CC
          WHERE ADMPN_COD_ERROR=K_CODERROR;
      EXCEPTION WHEN OTHERS THEN
          K_DESCERROR:='ERROR';
      END;
      OPEN K_LISTA_CANJE FOR
        SELECT
        '' ProdId,
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
        '' ValSegmento,
        '' PuntosDscto
        FROM DUAL;
        PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,K_CODERROR_EX,K_DESCERROR_EX);

        IF K_CODERROR_EX <> 0 THEN
          K_DESCERROR := K_DESCERROR || 'Error en SP ADMPU_LIBBLOQUEOBOLSA: ' || K_DESCERROR_EX;
        END IF;

    WHEN NO_LISTA_PEDIDO THEN
      BEGIN
          SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
          FROM  PCLUB.ADMPT_ERRORES_CC
          WHERE ADMPN_COD_ERROR=K_CODERROR;
      EXCEPTION WHEN OTHERS THEN
          K_DESCERROR:='ERROR';
      END;
      OPEN K_LISTA_CANJE FOR
        SELECT
        '' ProdId,
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
        '' ValSegmento,
        '' PuntosDscto
        FROM DUAL;
        PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,K_CODERROR_EX,K_DESCERROR_EX);

        IF K_CODERROR_EX <> 0 THEN
          K_DESCERROR := K_DESCERROR || 'Error en SP ADMPU_LIBBLOQUEOBOLSA: ' || K_DESCERROR_EX;
        END IF;

    WHEN NO_SLD_KDX_ALINEADO THEN
      BEGIN
          SELECT ADMPV_DES_ERROR INTO K_DESCERROR
          FROM  PCLUB.ADMPT_ERRORES_CC
          WHERE ADMPN_COD_ERROR=K_CODERROR;
      EXCEPTION WHEN OTHERS THEN
          K_DESCERROR:='ERROR';
      END;
      OPEN K_LISTA_CANJE FOR
        SELECT
        '' ProdId,
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
        '' ValSegmento,
        '' PuntosDscto
        FROM DUAL;
        PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,K_CODERROR_EX,K_DESCERROR_EX);

        IF K_CODERROR_EX <> 0 THEN
          K_DESCERROR := K_DESCERROR || 'Error en SP ADMPU_LIBBLOQUEOBOLSA: ' || K_DESCERROR_EX;
        END IF;

    WHEN EX_ERROR_DCTOPTO THEN
      BEGIN
          SELECT ADMPV_DES_ERROR INTO K_DESCERROR
          FROM  PCLUB.ADMPT_ERRORES_CC
          WHERE ADMPN_COD_ERROR=K_CODERROR;
      EXCEPTION WHEN OTHERS THEN
          K_DESCERROR:='ERROR';
      END;
      OPEN K_LISTA_CANJE FOR
        SELECT
        '' ProdId,
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
        '' ValSegmento,
        '' PuntosDscto
        FROM DUAL;

        PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,K_CODERROR_EX,K_DESCERROR_EX);

        IF K_CODERROR_EX <> 0 THEN
          K_DESCERROR := K_DESCERROR || 'Error en SP ADMPU_LIBBLOQUEOBOLSA: ' || K_DESCERROR_EX;
        END IF;

    WHEN OTHERS THEN
      K_CODERROR := 1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
      ROLLBACK TO POINT_CANJE;

       OPEN K_LISTA_CANJE FOR
        SELECT
        '' ProdId,
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
        '' ValSegmento,
        '' PuntosDscto
        FROM DUAL;
        PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,K_CODERROR_EX,K_DESCERROR_EX);

        IF K_CODERROR_EX <> 0 THEN
          K_DESCERROR := K_DESCERROR || 'Error en SP ADMPU_LIBBLOQUEOBOLSA: ' || K_DESCERROR_EX;
        END IF;
  END ADMPSS_CANJEPRODUC;

  PROCEDURE ADMPSI_ES_CLIENTE( K_TIPO_DOC    IN VARCHAR2,
                              K_NUM_DOC     IN VARCHAR2,
                              K_TIP_CLI     IN VARCHAR2,
                              K_SALDO       OUT NUMBER,
                              K_CODERROR    OUT NUMBER,
                              K_DESCERROR   OUT VARCHAR2) IS

    --****************************************************************
    -- Nombre SP           :  ADMPSI_ES_CLIENTE
    -- Propósito           :  Devuelve el saldo del cliente y el indicador de error
    -- Input               :  K_TIPO_DOC Tipo de Documento
    --                        K_NUM_DOC Numero de Documento
    --                        K_TIP_CLI Tipo de Cliente
    -- Output              :  K_SALDO
    --                        K_CODERROR
    -- Creado por          : Susana Ramos
    -- Fec Creación        :
    -- Fec Actualización   :  22/05/2012
    --****************************************************************


      CURSOR CUR_CLIENTE_TIPO(tipo_doc VARCHAR2, num_doc VARCHAR2, tipo_clie VARCHAR2) IS
      SELECT A.admpv_cod_cli_prod, B.admpv_cod_tpocl
        FROM PCLUB.ADMPT_clienteproducto A
        INNER JOIN PCLUB.ADMPT_CLIENTEFIJA B ON (A.ADMPV_COD_CLI=B.ADMPV_COD_CLI)
       WHERE B.admpv_tipo_doc = tipo_doc AND B.admpv_num_doc = num_doc
         AND B.admpc_estado = 'A'   AND B.admpv_cod_tpocl = tipo_clie;

    --Datos del Cursor (Tipo_cliente)
    CUR_COD_CLI PCLUB.ADMPT_clientefija.admpv_cod_cli%TYPE;
    CUR_TIP_CLI PCLUB.ADMPT_clientefija.admpv_cod_tpocl%TYPE;
    -- Variables
   -- V_TIP_DOC      PCLUB.ADMPT_clientefija.admpv_tipo_doc%TYPE;
   -- V_NUM_DOC      PCLUB.ADMPT_clientefija.admpv_num_doc%TYPE;
    --V_TIP_CLIE     PCLUB.ADMPT_clientefija.admpv_cod_tpocl%TYPE;
    V_SALDO_IB     NUMBER := 0;
    V_SALDO_CC     NUMBER := 0;
    V_SALDO_IB_AUX NUMBER := 0;
    V_SALDO_CC_AUX NUMBER := 0;
    EX_ERROR  EXCEPTION;
    nro_registrosCC NUMBER := 0;
    nro_registrosIB NUMBER := 0;
    --K_MSJERROR         VARCHAR2(400);
    V_EST_IB     CHAR(1);

  BEGIN
   K_CODERROR  := 0;
   /* la consulta se realiza por número de documento: Podria ser clientes IB o CLARO CLUB */
     IF (K_TIPO_DOC IS NOT NULL AND K_NUM_DOC IS NOT NULL AND K_TIP_CLI IS NOT NULL) THEN
          BEGIN
            -- Busca si el cliente es CC
               SELECT COUNT(*)     INTO nro_registrosCC FROM PCLUB.ADMPT_clientefija
                 WHERE admpv_tipo_doc = K_TIPO_DOC AND admpv_num_doc = K_NUM_DOC AND admpc_estado = 'A' AND
                       admpv_cod_tpocl = K_TIP_CLI ;
            -- Busca si el cliente es IB
               SELECT COUNT(*)  INTO nro_registrosIB       FROM PCLUB.ADMPT_clienteib
                 WHERE admpv_tipo_doc = K_TIPO_DOC  AND admpv_num_doc = K_NUM_DOC  AND admpc_estado <> 'B';

               IF nro_registrosCC = 0 AND nro_registrosIB = 0 THEN
                  K_CODERROR:=6;
                  RAISE EX_ERROR;
               END IF;

               IF (nro_registrosCC > 0 AND nro_registrosIB > 0) OR (nro_registrosCC > 0 AND nro_registrosIB = 0) THEN
                     BEGIN
                          OPEN CUR_CLIENTE_TIPO(K_TIPO_DOC, K_NUM_DOC, K_TIP_CLI);
                          FETCH CUR_CLIENTE_TIPO
                            INTO CUR_COD_CLI, CUR_TIP_CLI;
                          WHILE CUR_CLIENTE_TIPO%FOUND LOOP
                              BEGIN
                                SELECT NVL(admpn_saldo_cc, 0),  NVL(admpn_saldo_ib, 0), NVL(admpc_estpto_ib, 0)
                                  INTO V_SALDO_CC_AUX, V_SALDO_IB_AUX, V_EST_IB
                                  FROM PCLUB.ADMPT_saldos_clientefija
                                 WHERE ADMPV_COD_CLI_PROD = CUR_COD_CLI   AND admpc_estpto_cc = 'A';

                              EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                  V_SALDO_CC_AUX := 0;
                                  V_SALDO_IB_AUX := 0;
                              END;
                                IF V_EST_IB <> 'A' THEN
                                  V_SALDO_IB_AUX := 0;
                                END IF;

                                V_SALDO_IB := V_SALDO_IB + V_SALDO_IB_AUX;
                                V_SALDO_CC := V_SALDO_CC + V_SALDO_CC_AUX;

                            FETCH CUR_CLIENTE_TIPO
                              INTO CUR_COD_CLI, CUR_TIP_CLI;
                          END LOOP;
                          CLOSE CUR_CLIENTE_TIPO;
                      END;
               ELSE
                  K_CODERROR:=26;
                  RAISE EX_ERROR;
               END IF;
          END;
     ELSE
       K_CODERROR:=4;
         IF K_TIP_CLI IS NULL THEN
              K_DESCERROR := 'Parámetro = K_TIP_CLI';
         END IF ;
         IF K_TIPO_DOC IS NULL THEN
              K_DESCERROR := K_DESCERROR  ||  ' Parámetro = K_TIPO_DOC';
         END IF ;
         IF K_NUM_DOC IS NULL THEN
              K_DESCERROR := K_DESCERROR  ||  ' Parámetro = K_NUM_DOC';
         END IF ;
       RAISE EX_ERROR;
    END IF;
    K_SALDO := V_SALDO_CC + V_SALDO_IB;

    /* *************************************************************************** */
  BEGIN
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR=K_CODERROR;
  EXCEPTION WHEN OTHERS THEN
      K_DESCERROR:='ERROR';
  END;

  EXCEPTION
    WHEN EX_ERROR THEN
      BEGIN
          SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
          WHERE ADMPN_COD_ERROR=K_CODERROR;
      EXCEPTION WHEN OTHERS THEN
          K_DESCERROR:='ERROR';
      END;
    WHEN OTHERS THEN
      K_CODERROR := 1;
      K_DESCERROR:=SUBSTR( SQLERRM ,1,250);
  END ADMPSI_ES_CLIENTE;

PROCEDURE ADMPSI_DESC_PUNTOS( K_ID_CANJE    IN NUMBER,
                               K_SEC         IN NUMBER,
                               K_PUNTOS      IN NUMBER,
                               K_COD_CLIENTE IN VARCHAR2,
                               K_TIPO_DOC    IN VARCHAR2,
                               K_NUM_DOC     IN VARCHAR2,
                               K_TIP_CLI     IN VARCHAR2,
                               K_USUARIO     IN VARCHAR2,
                               K_CODERROR    OUT NUMBER,
                               K_DESCERROR   OUT VARCHAR2) IS

    --****************************************************************
    -- Nombre SP           :  ADMPSI_DESC_PUNTOS
    -- Propósito           :  Descuenta puntos para Canje segun FIFO y el requerimento definido
    -- Input               :  K_ID_CANJE Identificador del canje
    --                        K_SEC Secuencial del Detalle
    --                        K_PUNTOS Total de Puntos a descontar
    --                        K_COD_CLIENTE Codigo de Cliente
    --                        K_TIPO_DOC Tipo de Documento
    --                        K_NUM_DOC Numero de Documento
    --                        K_TIP_CLI Tipo de Cliente
    -- Output              :  K_CODERROR
    --                        K_DESCERROR
    -- Creado por          :  Susana Ramos
    -- Fec Creación        :
    -- Fec Actualización   :  22/05/2012
    --****************************************************************

    V_PUNTOS_REQUERIDOS NUMBER := 0;

    LK_TPO_PUNTO  CHAR(1);
    LK_ID_KARDEX  NUMBER;
    LK_SLD_PUNTOS NUMBER;
    LK_COD_CLI    VARCHAR2(40);
    LK_COD_CLIIB  NUMBER;

    EX_ERROR EXCEPTION;

    /* Cursor 1 */-- Prepago
    CURSOR LISTA_KARDEX_1 IS
        SELECT ka.admpc_tpo_punto, ka.admpn_id_kardex, ka.admpn_sld_punto,
             ka.admpv_cod_cli_prod, admpn_cod_cli_ib FROM PCLUB.ADMPT_kardexfija ka
       WHERE ka.admpc_estado = 'A' AND ka.admpc_tpo_oper = 'E' AND ka.admpn_sld_punto > 0
         AND TO_DATE(TO_CHAR(ka.admpd_fec_trans,'DD/MM/YYYY'),'DD/MM/YYYY') <=  TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY')
         AND ka.admpv_cod_cli_prod IN
                     ( SELECT CP.ADMPV_COD_CLI_PROD    FROM PCLUB.ADMPT_clienteproducto CP
                          INNER JOIN PCLUB.ADMPT_CLIENTEFIJA CF ON (CF.ADMPV_COD_CLI = CP.ADMPV_COD_CLI)
                       WHERE CF.ADMPV_TIPO_DOC = K_TIPO_DOC  AND CF.ADMPV_NUM_DOC = K_NUM_DOC AND
                             CF.ADMPV_COD_TPOCL = K_TIP_CLI AND CP.ADMPV_ESTADO_SERV = 'A')
                             /*Selecciona todos los codigos que cumplen con la condicion*/
       ORDER BY DECODE(admpc_tpo_punto, 'I', 1, 'L', 2, 'C', 3),
                        admpn_id_kardex ASC;
  BEGIN
    /*
    Los puntos IB son los q se consumiran primero Tipo de punto 'I'
    los puntos Loyalty 'L' y ClaroClub 'C', se consumiran en ese orden
    */
    K_CODERROR  := 0;
    K_DESCERROR := '';

    V_PUNTOS_REQUERIDOS := K_PUNTOS;

                        /*K_ID_CANJE    IN NUMBER,
                               K_SEC         IN NUMBER,
                               K_PUNTOS      IN NUMBER,
                               K_COD_CLIENTE IN VARCHAR2,
                               K_TIPO_DOC    IN VARCHAR2,
                               K_NUM_DOC     IN VARCHAR2,
                               K_TIP_CLI     IN VARCHAR2,
*/


    -- Comienza el Canje, dato de entrada el codigo de cliente
    IF K_ID_CANJE IS NOT NULL AND K_SEC IS NOT NULL AND K_PUNTOS IS NOT NULL AND
       K_COD_CLIENTE IS NOT NULL AND K_TIPO_DOC IS NOT NULL AND K_NUM_DOC IS NOT NULL THEN --Prepago
      IF  K_TIP_CLI IN ('6','7')  THEN
--      IF K_TIP_CLI = '3' OR K_TIP_CLI = '4' OR K_TIP_CLI = '6' THEN
        -- Clientes Prepago o B2E
        OPEN LISTA_KARDEX_1;
        FETCH LISTA_KARDEX_1
          INTO LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB;
        WHILE LISTA_KARDEX_1%FOUND AND V_PUNTOS_REQUERIDOS > 0 LOOP


          IF LK_SLD_PUNTOS <= V_PUNTOS_REQUERIDOS THEN
            -- Actualiza Kardexfija
            UPDATE PCLUB.ADMPT_kardexfija  SET admpn_sld_punto = 0, admpc_estado = 'C', ADMPV_USU_MOD= K_USUARIO
             WHERE admpn_id_kardex = LK_ID_KARDEX;
            -- Inserta Canje_kardexfija
            INSERT INTO PCLUB.ADMPT_canjedt_kardexfija (admpv_id_canje, admpn_id_kardex, admpv_id_canjesec, admpn_puntos,admpc_tpo_kardex)
                                          VALUES (K_ID_CANJE   , LK_ID_KARDEX  , K_SEC ,  LK_SLD_PUNTOS, 'E');
            -- Actualiza Saldos_clientefija
            IF LK_TPO_PUNTO = 'C' OR LK_TPO_PUNTO = 'L' THEN
                  /* Punto Claro Club */
                  UPDATE PCLUB.ADMPT_saldos_clientefija SET admpn_saldo_cc = -LK_SLD_PUNTOS + NVL(admpn_saldo_cc, 0) , ADMPV_USU_MOD= K_USUARIO
                  WHERE ADMPV_COD_CLI_PROD = LK_COD_CLI;
            ELSE
                  -- Punto IB
                IF LK_TPO_PUNTO = 'I' THEN
                   UPDATE PCLUB.ADMPT_saldos_clienteFIJA SET admpn_saldo_ib = -LK_SLD_PUNTOS + NVL(admpn_saldo_ib, 0), ADMPV_USU_MOD= K_USUARIO
                   WHERE admpn_cod_cli_ib = LK_COD_CLIIB;
                END IF;

            END IF;
                  V_PUNTOS_REQUERIDOS := V_PUNTOS_REQUERIDOS - LK_SLD_PUNTOS;
         ELSE
            IF LK_SLD_PUNTOS > V_PUNTOS_REQUERIDOS THEN
                -- Actualiza Kardex
                  UPDATE PCLUB.ADMPT_kardexFIJA    SET admpn_sld_punto = LK_SLD_PUNTOS - V_PUNTOS_REQUERIDOS, ADMPV_USU_MOD= K_USUARIO
                  WHERE admpn_id_kardex = LK_ID_KARDEX;
                -- Inserta Canje_kardex
                INSERT INTO PCLUB.ADMPT_canjedt_kardexFIJA (admpv_id_canje, admpn_id_kardex,admpv_id_canjesec,admpn_puntos,admpc_tpo_kardex)
                VALUES (K_ID_CANJE, LK_ID_KARDEX, K_SEC, V_PUNTOS_REQUERIDOS,'E');
                -- Actualiza Saldos_cliente
                IF LK_TPO_PUNTO = 'C' OR LK_TPO_PUNTO = 'L' THEN
                  /* Punto Claro Club */
                   UPDATE PCLUB.ADMPT_saldos_clienteFIJA SET admpn_saldo_cc = -V_PUNTOS_REQUERIDOS + NVL(admpn_saldo_cc, 0), ADMPV_USU_MOD= K_USUARIO
                   WHERE ADMPV_COD_CLI_PROD = LK_COD_CLI;
                ELSE
                  -- Punto IB
                  IF LK_TPO_PUNTO = 'I' THEN
                     UPDATE PCLUB.ADMPT_saldos_clienteFIJA SET admpn_saldo_ib = -V_PUNTOS_REQUERIDOS + NVL(admpn_saldo_ib, 0) , ADMPV_USU_MOD= K_USUARIO
                     WHERE admpn_cod_cli_ib = LK_COD_CLIIB;
                  END IF;
                END IF;
                V_PUNTOS_REQUERIDOS := 0;
            END IF;
         END IF;
          FETCH LISTA_KARDEX_1
            INTO LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB;
        END LOOP;
        CLOSE LISTA_KARDEX_1;
      END IF;
    ELSE
         K_CODERROR:=4;
         IF K_ID_CANJE IS NULL THEN
              K_DESCERROR := 'Parámetro = K_ID_CANJE';
         END IF ;
         IF K_SEC IS NULL THEN
              K_DESCERROR := K_DESCERROR  ||  ' Parámetro = K_SEC';
         END IF ;
         IF K_PUNTOS IS NULL THEN
              K_DESCERROR := K_DESCERROR  ||  ' Parámetro = K_PUNTOS';
         END IF ;
         IF K_COD_CLIENTE IS NULL THEN
              K_DESCERROR :=  K_DESCERROR  ||  ' Parámetro = K_COD_CLIENTE';
         END IF ;
         IF K_TIPO_DOC IS NULL THEN
              K_DESCERROR := K_DESCERROR  ||  ' Parámetro = K_TIPO_DOC';
         END IF ;
         IF K_NUM_DOC IS NULL THEN
              K_DESCERROR := K_DESCERROR  ||  ' Parámetro = K_NUM_DOC';
         END IF ;
       RAISE EX_ERROR;
    END IF;

 BEGIN
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR=K_CODERROR;
  EXCEPTION WHEN OTHERS THEN
      K_DESCERROR:='ERROR';
  END;

  EXCEPTION
    WHEN EX_ERROR THEN
      BEGIN
          SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
          WHERE ADMPN_COD_ERROR=K_CODERROR;
      EXCEPTION WHEN OTHERS THEN
          K_DESCERROR:='ERROR';
      END;
    WHEN OTHERS THEN
      K_CODERROR := 1;
      K_DESCERROR:=SUBSTR( SQLERRM ,1,250);
  END ADMPSI_DESC_PUNTOS;

----------------------------------ACTUALIZA CANJE -----------------------------
PROCEDURE ADMPSS_ACTCANJE(K_IDCANJE IN VARCHAR2,K_LISTA_IDPROCLA IN VARCHAR2, K_LISTA_CODTXPAQ IN VARCHAR2, K_LISTA_SOTS IN VARCHAR2, K_MSJSMS IN VARCHAR2,
                          K_ID_INTER IN VARCHAR2,K_EXITO OUT NUMBER,K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2)
  /*
         Proposito                : Procedimiento para la actualizacion de canje y sus detalles
        Parametros            : K_IDCANJE                 Identificador de canje
                                      K_LISTA_IDPROCLA     Lista de parametros que contiene la llave  en detalle
                                      K_LISTA_CODTXPAQ   Lista de parametros que contiene el valor del campo en detalle
                                      K_MSJSMS                   Descripcion que se actualizara en Canje
                                      K_EXITO                      Valor enteror factor de exito  1 exito caso contrario error
                                      K_CODERROR              Informacion del codigo de error
                                      K_DESCERROR              Descripcion del error
        Fecha Creacion        : 12:30 a.m. 02/02/2012
     -----------------------------------------------------------------------*\
  */
IS
    STRCAMP TAB_ARRAY;
    STRLLAVE TAB_ARRAY;
    STRSOT TAB_ARRAY;
    V_COD_CLI     VARCHAR2(40);
    V_COD_TPOCL   VARCHAR2(2);
    V_TIPO_DOC    VARCHAR2(20);
    V_NUM_DOC     VARCHAR2(20);
    K_CODERROR_EX  NUMBER;
    K_DESCERROR_EX VARCHAR2(400);
 BEGIN
    K_EXITO := 1;
    K_CODERROR := 0;
    K_DESCERROR:=' ';
    STRCAMP := SPLITCAD(K_LISTA_CODTXPAQ, '|');
    STRLLAVE := SPLITCAD(K_LISTA_IDPROCLA, '|');
    STRSOT  :=  SPLITCAD(K_LISTA_SOTS, '|');
    IF STRCAMP.COUNT = STRLLAVE.COUNT AND STRCAMP.COUNT = STRSOT.COUNT THEN
      UPDATE   PCLUB.ADMPT_CANJEFIJA
      SET      ADMPV_MENSAJE = K_MSJSMS, ADMPD_FEC_MOD = CURRENT_DATE,
                 ADMPV_INTERACTID=K_ID_INTER--,ADMPV_SOTID=K_ID_SOT
      WHERE    ADMPV_ID_CANJE = K_IDCANJE;

      --Si la cantidad de valores es igual a la cantidad de llaves procede
      FOR I IN 1 .. STRLLAVE.COUNT
      LOOP
          UPDATE   PCLUB.ADMPT_CANJE_DETALLEFIJA
          SET      ADMPV_CODTXPAQDAT = DECODE(TRIM(STRCAMP(I)),'NULL',NULL,TRIM(STRCAMP(I)))
                  ,ADMPD_FEC_MOD = CURRENT_DATE, ADMPD_SOTID=DECODE(TRIM(STRSOT(I)),'NULL',NULL,TRIM(STRSOT(I)))
          WHERE    ADMPV_ID_CANJE = K_IDCANJE
               AND TRIM(ADMPV_ID_PROCLA) = TRIM(STRLLAVE(I));
      END LOOP;
      --K_EXITO := 1;
      --K_CODERROR := 0;

      SELECT ADMPV_COD_CLI,ADMPV_COD_TPOCL INTO V_COD_CLI,V_COD_TPOCL
      FROM PCLUB.ADMPT_CANJEFIJA WHERE ADMPV_ID_CANJE = k_idcanje ;

      SELECT ADMPV_TIPO_DOC,ADMPV_NUM_DOC INTO V_TIPO_DOC,V_NUM_DOC
      FROM PCLUB.ADMPT_CLIENTEFIJA
      WHERE ADMPV_COD_CLI = V_COD_CLI ;

     PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(V_TIPO_DOC,V_NUM_DOC,V_COD_TPOCL,K_CODERROR_EX,K_DESCERROR_EX);

      IF K_CODERROR <> 0 THEN
        K_EXITO := 0;
        K_CODERROR := K_CODERROR_EX;
        K_DESCERROR := K_DESCERROR || 'Error en SP ADMPU_LIBBLOQUEOBOLSA: ' || K_DESCERROR_EX;
      END IF;

      COMMIT;
    ELSE
      K_CODERROR := 12;
      --K_DESCERROR := 'No coinciden el numero de elementos en los parametros K_LISTA_IDPROCLA y K_LISTA_CODTXPAQ';
      K_EXITO := 0;
    END IF;

    BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR=K_CODERROR;
    EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='ERROR';
    END;

 EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      K_CODERROR := 1;
      K_DESCERROR :=SUBSTR(SQLERRM, 1, 250);
      K_EXITO := 0;

 END ADMPSS_ACTCANJE;


PROCEDURE ADMPSS_ELIMINARCANJE(K_IDCANJE IN VARCHAR2,K_EXITO OUT NUMBER,K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2)
  /*-----------------------------------------------------------------------
        Proposito                : Procedimiento para elimiar un canje
        Parámetros            : K_IDCANJE                 Identificador de canje
                                      K_EXITO                      Valor enteror factor de exito  1 exito caso contrario error
                                      K_CODERROR              Informacion del codigo de error
                                      K_DESCERROR              Descripcion del error
        Fecha Creacion        : 12:30 a.m. 02/06/2012
        Fecha Modificacion  : 12:30 a.m. 02/06/2012
     -----------------------------------------------------------------------
     */
  IS
    --NULO_IDCANJE   EXCEPTION;
    --NO_EXISTE      EXCEPTION;
    EX_ERROR    EXCEPTION;
    --Informacion de Canje Detalle Kardex
    CURSOR CURSOR_CANJ_KARD
    IS
      SELECT   ADMPN_ID_KARDEX, ADMPN_PUNTOS
      FROM     PCLUB.ADMPT_CANJEDT_KARDEXFIJA
      WHERE    ADMPV_ID_CANJE = TO_NUMBER(K_IDCANJE);

    C_ID_KARDEX    NUMBER; --para capturar informacion de detalle kardex
    C_PUNTOS       NUMBER; --para capturar informacion  de detalle kardex

    V_COD_CLI_PROD      VARCHAR2(40); --codigo de cliente
    V_TPO_PUNTO    VARCHAR2(2); --Tipo de puntos
    --V_ID_KARDEX    NUMBER; --Identificador de kardex
    V_COUNT_C      NUMBER; --Numero de registros
    V_TIPO_DOC     VARCHAR(20);
    V_NUM_DOC      VARCHAR2(20);
    V_TIPO_CLIE    VARCHAR2(2);
    K_CODERROR_EX  NUMBER;
    K_DESCERROR_EX VARCHAR2(400);
  BEGIN
    K_EXITO := 1;
    K_CODERROR:=0;
    K_DESCERROR:='';
    --Si se envio el identificador de canje
    IF ((K_IDCANJE IS NULL) OR (REPLACE(K_IDCANJE, ' ', '') IS NULL)) THEN
      K_EXITO := 0;
      K_CODERROR:=4;
      K_DESCERROR := 'El IdCanje es un campo obligatorio.';
      RAISE EX_ERROR;
    ELSE
      -- Cuantos registros tiene el mismo identificador de canje ( puede ser individual o paquete)
      SELECT   COUNT(*)
      INTO     V_COUNT_C
      FROM     PCLUB.ADMPT_CANJEFIJA
      WHERE    ADMPV_ID_CANJE = TO_NUMBER(K_IDCANJE);

      --Si no hay registros  (puede que no exista registros o puede ser que se paso un codigo incorrecto)
      IF V_COUNT_C = 0 THEN
        K_EXITO := 0;
        K_CODERROR := 16;
        K_DESCERROR := 'Canje = '|| K_IDCANJE;
        RAISE EX_ERROR;
      ELSE
        --Si existen registros  extraemos la informacion del cliente
        /*JCGT
        SELECT   admpv_cod_cli
        INTO     v_cod_cli
        FROM     PCLUB.ADMPT_canjefija
        WHERE    admpv_id_canje = TO_NUMBER(k_idcanje);
        */

        SELECT   caf.admpv_num_doc,cl.admpv_tipo_doc,caf.admpv_cod_tpocl
        INTO     V_NUM_DOC, V_TIPO_DOC,V_TIPO_CLIE
        FROM     PCLUB.admpt_canjefija caf
        inner join PCLUB.admpt_clientefija cl on (cl.admpv_cod_cli=caf.admpv_cod_cli)
        WHERE    admpv_id_canje = TO_NUMBER(k_idcanje);

        --Eliminamos la informacion del detalle canje
        DELETE   PCLUB.ADMPT_CANJE_DETALLEFIJA
        WHERE    ADMPV_ID_CANJE = TO_NUMBER(K_IDCANJE);

        --Procesando los detalle kardex encontrados y sumando puntos
        OPEN CURSOR_CANJ_KARD;

        LOOP
          FETCH CURSOR_CANJ_KARD
          INTO     C_ID_KARDEX, C_PUNTOS;

          EXIT WHEN CURSOR_CANJ_KARD%NOTFOUND;


          --Actualizando el Kardex
          UPDATE   PCLUB.ADMPT_KARDEXFIJA
          SET      ADMPC_ESTADO = 'A'
                  ,ADMPN_SLD_PUNTO =
                     C_PUNTOS
                     + (SELECT   NVL(ADMPN_SLD_PUNTO, 0)
                        FROM     PCLUB.ADMPT_KARDEXFIJA
                        WHERE    ADMPN_ID_KARDEX = C_ID_KARDEX)
                  ,ADMPD_FEC_MOD = CURRENT_DATE
          WHERE    ADMPN_ID_KARDEX = C_ID_KARDEX;

          V_TPO_PUNTO := NULL;

          SELECT   ADMPC_TPO_PUNTO,ADMPV_COD_CLI_PROD
          INTO     V_TPO_PUNTO,V_COD_CLI_PROD
          FROM     PCLUB.ADMPT_KARDEXFIJA
          WHERE    ADMPN_ID_KARDEX = C_ID_KARDEX;

          IF V_TPO_PUNTO = 'C' OR V_TPO_PUNTO = 'L' THEN
             --V_TPO_PUNTO='C' O 'L'
            --Para el tipo de cliente Claro Club ...
            UPDATE   PCLUB.ADMPT_SALDOS_CLIENTEFIJA
            SET      ADMPC_ESTPTO_CC = 'A'
                    ,ADMPN_SALDO_CC =
                       C_PUNTOS
                       + (SELECT   NVL(ADMPN_SALDO_CC, 0)
                          FROM     PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                          WHERE    ADMPV_COD_CLI_PROD = V_COD_CLI_PROD)
            WHERE    ADMPV_COD_CLI_PROD = V_COD_CLI_PROD;
          END IF;
        END LOOP;

        CLOSE CURSOR_CANJ_KARD;

        DELETE   PCLUB.ADMPT_CANJEDT_KARDEXFIJA
        WHERE    ADMPV_ID_CANJE = TO_NUMBER(K_IDCANJE);

        /* JCGT
        SELECT   admpn_id_kardex
        INTO     v_id_kardex
        FROM     PCLUB.ADMPT_canjefija
        WHERE    admpv_id_canje = TO_NUMBER(k_idcanje);

        IF v_id_kardex IS NOT NULL THEN
          DELETE   PCLUB.ADMPT_kardexfija
          WHERE    admpn_id_kardex = v_id_kardex;
        END IF;
        */
        /*nuevo JCGT*/
        DELETE   PCLUB.ADMPT_KARDEXFIJA
        WHERE    ADMPV_ID_CANJE = TO_NUMBER(K_IDCANJE);
      /**/
        DELETE   PCLUB.ADMPT_CANJEFIJA
        WHERE    ADMPV_ID_CANJE = TO_NUMBER(K_IDCANJE);

        PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(V_TIPO_DOC,V_NUM_DOC,V_TIPO_CLIE,K_CODERROR_EX,K_DESCERROR_EX);
        IF K_CODERROR_EX <> 0 THEN
          K_EXITO := 0;
          K_CODERROR := K_CODERROR_EX;
          K_DESCERROR := K_DESCERROR || 'Error en SP ADMPU_LIBBLOQUEOBOLSA: ' || K_DESCERROR_EX;
        END IF;

        COMMIT;
      END IF;
    END IF;

    BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR=K_CODERROR;
    EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='ERROR';
    END;

  EXCEPTION
    WHEN EX_ERROR THEN
      ROLLBACK;
      K_EXITO := 0;
      BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR=K_CODERROR;
      EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='ERROR';
      END;
    --Si no existe registro no es factor para realizar un rollback
    WHEN OTHERS THEN
      K_EXITO := 0;
      K_CODERROR := 1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
  END ADMPSS_ELIMINARCANJE;

PROCEDURE ADMPSS_PRODUCTOSCANJE(K_TIPDOC IN VARCHAR2,
                                K_NUMDOC IN VARCHAR2,
                                K_TIPCLIE IN VARCHAR2,
                                K_FECINI IN VARCHAR2,
                                K_FECFIN IN VARCHAR2,
                                K_CODERROR OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2,
                                CUR_CANJE OUT SYS_REFCURSOR) IS
STM_SQL VARCHAR2(5000);
EX_ERROR EXCEPTION;
BEGIN

K_CODERROR := 0;
K_DESCERROR := '';

IF K_TIPDOC IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR:='El tipo de doc. no es válido';
    RAISE EX_ERROR;
END IF;
IF K_NUMDOC IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR:='El numero de doc. no es válido';
    RAISE EX_ERROR;
END IF;
IF K_TIPCLIE IS NULL OR K_TIPCLIE  not in ('6','7') THEN
    K_CODERROR := 4;
    K_DESCERROR:='El tipo de cliente  no es válido';
    RAISE EX_ERROR;
END IF;

STM_SQL:='SELECT C.ADMPV_VENTAID ID_VENTA, C.ADMPV_ID_CANJE CANJE, C.ADMPV_COD_TPOCL TIP_CLIE,C.ADMPV_ID_CANJE NRO_CANJE,C.ADMPV_PTO_VENTA PTO_VENTA, D.ADMPV_DSC_DOCUM TIPO_DOC,F.ADMPV_NUM_DOC NRO_DOC,
        TO_CHAR(C.ADMPD_FEC_CANJE,''DD/MM/YYYY HH24:MI:SS'') FECHA_CANJE,C.ADMPC_TPO_OPER TIPO_OPER, C.ADMPV_VENTAID ID_VENTA
      FROM  PCLUB.ADMPT_CLIENTEFIJA F, PCLUB.ADMPT_CANJEFIJA C,  PCLUB.ADMPT_TIPO_DOC D
      WHERE C.ADMPV_COD_CLI=F.ADMPV_COD_CLI
      AND F.ADMPV_TIPO_DOC='''|| K_TIPDOC ||'''
      AND D.ADMPV_COD_TPDOC=F.ADMPV_TIPO_DOC
      AND F.ADMPV_NUM_DOC='''|| K_NUMDOC ||'''
      AND F.ADMPV_COD_TPOCL='''|| K_TIPCLIE ||''' ';

IF K_FECINI IS NOT NULL AND K_FECFIN IS NOT NULL THEN
     STM_SQL := STM_SQL || ' AND C.ADMPD_FEC_CANJE BETWEEN TO_DATE('''||K_FECINI||''',''DD/MM/YYYY'') AND TO_DATE('''||K_FECFIN||''',''DD/MM/YYYY'')';
END IF;

OPEN CUR_CANJE FOR STM_SQL;

BEGIN
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM  PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR=K_CODERROR;
EXCEPTION WHEN OTHERS THEN
    K_DESCERROR:='ERROR';
END;

EXCEPTION WHEN EX_ERROR THEN
                     BEGIN
                        SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
                        FROM  PCLUB.ADMPT_ERRORES_CC
                        WHERE ADMPN_COD_ERROR=K_CODERROR;
                     EXCEPTION WHEN OTHERS THEN
                        K_DESCERROR:='ERROR';
                     END;
                 WHEN OTHERS THEN
                 K_CODERROR:=1;
                 K_DESCERROR:=SUBSTR(SQLERRM, 1, 250);
END ADMPSS_PRODUCTOSCANJE;

PROCEDURE ADMPSS_CONSTANCIACANJE(K_IDCANJE IN NUMBER,K_CTO_ATEN OUT VARCHAR2,K_TIP_DOC OUT VARCHAR2,K_NUM_DOC OUT VARCHAR2,K_FEC OUT VARCHAR2,K_CSO_INT OUT VARCHAR2,
                                                             K_NOTAS OUT VARCHAR2,K_NOMBRE OUT VARCHAR2, K_TIPCLIE OUT VARCHAR2,K_CODERROR OUT NUMBER, K_DESCERROR OUT VARCHAR2,CUR_CANJE OUT SYS_REFCURSOR) IS
EX_ERROR EXCEPTION;
V_COUNT_C NUMBER;
BEGIN
K_CODERROR:=0;
K_DESCERROR:=' ';

IF K_IDCANJE IS NULL THEN
    K_CODERROR := 4;
    K_DESCERROR:='El numero de canje no es válido';
    RAISE EX_ERROR;
END IF;
-- Cuantos registros tiene el mismo identificador de canje ( puede ser individual o paquete)
      SELECT   COUNT(*)
      INTO     V_COUNT_C
      FROM     PCLUB.ADMPT_CANJEFIJA
      WHERE    ADMPV_ID_CANJE = TO_NUMBER(K_IDCANJE);

      --Si no hay registros  (puede que no exista registros o puede ser que se paso un codigo incorrecto)
      IF V_COUNT_C = 0 THEN
        K_CODERROR := 28;
        K_DESCERROR := 'Canje = '|| K_IDCANJE;
        RAISE EX_ERROR;
      END IF;
    /*QUERY REAL
     SELECT C.ADMPV_PTO_VENTA,F.ADMPV_TIPO_DOC,F.ADMPV_NUM_DOC,C.ADMPD_FEC_CANJE,C.ADMPV_INTERACTID,C.ADMPV_NOTAS
     INTO K_CTO_ATEN,K_TIP_DOC,K_NUM_DOC,K_FEC,K_CSO_INT
      FROM PCLUB.ADMPT_CLIENTEFIJA F,PCLUB.ADMPT_CANJEFIJA C
      WHERE C.ADMPV_COD_CLI=F.ADMPV_COD_CLI
      AND C.ADMPV_ID_CANJE=K_IDCANJE;
    */
    --QUERY PARA PRUEBA
      SELECT C.ADMPV_PTO_VENTA,D.ADMPV_DSC_DOCUM,F.ADMPV_NUM_DOC,TO_CHAR(C.ADMPD_FEC_CANJE,'DD/MM/YYYY'),C.ADMPV_INTERACTID,NVL(C.ADMPV_NOTAS,' '),
             F.ADMPV_APE_CLI || ' ' || F.ADMPV_NOM_CLI  NOMBRE, T.ADMPV_TIPO TIPO
      INTO K_CTO_ATEN,K_TIP_DOC,K_NUM_DOC,K_FEC,K_CSO_INT,K_NOTAS,K_NOMBRE,K_TIPCLIE
      FROM  PCLUB.ADMPT_CLIENTEFIJA F
            INNER JOIN PCLUB.ADMPT_CANJEFIJA     C ON (C.ADMPV_COD_CLI = F.ADMPV_COD_CLI)
            INNER JOIN PCLUB.ADMPT_TIPO_DOC      D ON (F.ADMPV_TIPO_DOC = D.ADMPV_COD_TPDOC)
            INNER JOIN PCLUB.ADMPT_TIPO_CLIENTE  T ON (F.ADMPV_COD_TPOCL = T.ADMPV_COD_TPOCL)
      WHERE C.ADMPV_ID_CANJE = K_IDCANJE;

      --SOLO CAMBIAR LA CANJE_DETALLE X FIJA
      OPEN CUR_CANJE FOR
      SELECT D.ADMPV_ID_CANJESEC CANJE_SEC,D.ADMPV_ID_PROCLA ID_PRODUCTO,P.ADMPV_DESC PRODUCTO,
      D.ADMPN_PUNTOS PUNTOS,D.ADMPN_CANTIDAD CANTIDAD,T.ADMPV_DESC DESCRIP,D.ADMPN_MNT_RECAR MONTO,
      D.ADMPN_PAGO PAGO
     FROM PCLUB.ADMPT_CANJE_DETALLEFIJA D,PCLUB.ADMPT_PREMIO P,PCLUB.ADMPT_TIPO_PREMIO T
      WHERE D.ADMPV_ID_PROCLA=P.ADMPV_ID_PROCLA
      AND P.ADMPV_COD_TPOPR=T.ADMPV_COD_TPOPR
      AND D.ADMPV_ID_CANJE=K_IDCANJE;
     BEGIN
            SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
            FROM PCLUB.ADMPT_ERRORES_CC
            WHERE ADMPN_COD_ERROR=K_CODERROR;
     EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='ERROR';
     END;

EXCEPTION
        WHEN EX_ERROR THEN
                 BEGIN
                        SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
                        FROM PCLUB.ADMPT_ERRORES_CC
                        WHERE ADMPN_COD_ERROR=K_CODERROR;
                 EXCEPTION WHEN OTHERS THEN
                    K_DESCERROR:='ERROR';
                 END;
                 WHEN OTHERS THEN
                 K_CODERROR:=1;
                 K_DESCERROR:=SUBSTR(SQLERRM, 1, 250);
END ADMPSS_CONSTANCIACANJE;

  PROCEDURE ADMPSS_CONSALDO(K_TIPO_DOC        IN VARCHAR2,
                            K_NUM_DOC         IN VARCHAR2,
                            K_TIP_CLI         IN VARCHAR2,
                            K_TIP_LINEA       IN VARCHAR2,
                            K_CODERROR        OUT NUMBER,
                            K_DESCERROR       OUT VARCHAR2,
                            K_SALDO_PUNTOS    OUT NUMBER,
                            K_CUR_LISTA       OUT SYS_REFCURSOR) IS

    /****************************************************************
    '* Nombre SP           :  ADMPSS_CONSALDO
    '* Propósito           :  Consulta segun el codigo o numero de documento y el tipo de cliente, los saldos total,IB, CC y devuelve un cursor con los productos permitidos segun el puntaje total
    '* Input               :  K_COD_CLIENTE , K_TIPO_DOC, K_NUM_DOC, K_TIP_CLI,K_TIP_LINEA
    '* Output              :  K_CODERROR, K_DESCERROR, K_SALDO_PUNTOS, K_CUR_LISTA
    '* Creado por          :  Susana Ramos
    '* Fec Creación        :
    '* Fec Actualización   :  22/05/2012
    '****************************************************************/

    V_SALDO     NUMBER := 0;
    EX_ERROR    EXCEPTION;
    K_CERROR    NUMBER;
    K_DERROR    VARCHAR2(250);
    K_TIPO_LINEA VARCHAR2(2);
    EX_VALIDACION EXCEPTION;
    V_EST_BLOQUEO CHAR(1);
    V_TIPO_DOC    VARCHAR2(20);
    V_CODERROR NUMBER;
    V_DESCERROR VARCHAR2(250);
  BEGIN

    K_SALDO_PUNTOS    := 0;
    K_CODERROR        := 0;
    K_CERROR          := 0;
    K_DERROR          :='';
    K_DESCERROR       :='';

    K_TIPO_LINEA := K_TIP_LINEA;

    IF K_TIPO_LINEA IS NULL THEN
       K_TIPO_LINEA:=0;
    END IF;

       IF (K_TIPO_DOC IS NOT NULL AND K_NUM_DOC IS NOT NULL AND K_TIP_CLI IS NOT NULL AND K_TIPO_LINEA IS NOT NULL ) THEN
           ADMPSI_ES_CLIENTE(K_TIPO_DOC,
                             K_NUM_DOC,
                             K_TIP_CLI,
                             V_SALDO,
                             K_CERROR,
                             K_DESCERROR);
          K_SALDO_PUNTOS := V_SALDO;

        -- Realiza la validación del bloqueo
        PCLUB.PKG_CC_TRANSACCION.ADMPS_VALBLOQUEOBOLSA(K_TIPO_DOC,K_NUM_DOC,K_TIP_CLI,V_TIPO_DOC,V_EST_BLOQUEO,V_CODERROR,V_DESCERROR);

        IF K_CODERROR <> 0 THEN
          RAISE EX_VALIDACION;
        END IF;

        IF V_EST_BLOQUEO = 'R' THEN
          V_CODERROR := 37;
          V_DESCERROR := 'Existe un canje en proceso. ';
        END IF;

       ELSE
         K_CODERROR:=4;
         IF K_TIP_CLI IS NULL THEN
              K_DESCERROR := 'Parámetro = K_TIP_CLI';
         END IF ;
         IF K_TIPO_DOC IS NULL THEN
              K_DESCERROR := K_DESCERROR  ||  ' Parámetro = K_TIPO_DOC';
         END IF ;
         IF K_NUM_DOC IS NULL THEN
              K_DESCERROR := K_DESCERROR  ||  ' Parámetro = K_NUM_DOC';
         END IF ;
         IF K_TIPO_LINEA IS NULL THEN
              K_DESCERROR := K_DESCERROR  ||  ' Parámetro = K_TIP_LINEA';
         END IF ;
          RAISE EX_ERROR;
       END IF;

       IF  K_CERROR=0 THEN
           K_DESCERROR:='';
      -- Obtener Productos según el tipo de datos enviado en el parámetro
        IF  K_TIPO_LINEA = '0' THEN
          OPEN K_CUR_LISTA FOR
            SELECT  distinct pr.admpv_id_procla AS ProdId,
                   pr.admpv_desc      AS ProdDes,
                   pr.admpv_campana   AS Campana,
                   pr.admpn_puntos    AS Puntos,
                   pr.admpn_pago      AS pago,
                   t_pr.admpv_desc    AS t_pr,
                   pr.admpn_cod_servc AS ServComercial,
                   pr.admpn_mnt_recar AS MontoRecarga,
                   pr.admpv_cod_paqdat AS codigo_paquete,
                   t_pr.admpn_orden    As orden,
                   pr.admpv_cod_servtv As Codigo_ServTV,
                   pr.admpv_cod_tpopr  As Cod_t_pr
            FROM PCLUB.ADMPT_premio        pr
                   inner join PCLUB.ADMPT_tipo_premio   t_pr      on (pr.admpv_cod_tpopr = t_pr.admpv_cod_tpopr)
                   inner join PCLUB.ADMPT_tipo_premclie t_pre_cli on (t_pr.admpv_cod_tpopr=t_pre_cli.admpv_cod_tpopr)
            WHERE  pr.admpc_estado = 'A'  AND    pr.admpn_puntos <= K_SALDO_PUNTOS AND
                   --1 Control , 2 PostPago, 3 Prepago, con el tipo de cliente
                   t_pre_cli.admpv_cod_tpocl = K_TIP_CLI AND
                   pr.admpv_id_procla not in (select admpv_id_procla from
                   PCLUB.ADMPT_EXCPREMIO_TIPOCLIE where admpv_cod_tpocl=K_TIP_CLI)
            ORDER BY t_pr.admpn_orden, pr.admpn_puntos DESC;
        ELSE
         OPEN K_CUR_LISTA FOR
              SELECT  distinct pr.admpv_id_procla AS ProdId,
                     pr.admpv_desc      AS ProdDes,
                     pr.admpv_campana   AS Campana,
                     pr.admpn_puntos    AS Puntos,
                     pr.admpn_pago      AS pago,
                     t_pr.admpv_desc    AS t_pr,
                     pr.admpn_cod_servc AS ServComercial,
                     pr.admpn_mnt_recar AS MontoRecarga,
                     pr.admpv_cod_paqdat AS codigo_paquete,
                     t_pr.admpn_orden    AS orden,
                     pr.admpv_cod_servtv As Codigo_ServTV,
                     pr.admpv_cod_tpopr  As Cod_t_pr
              FROM PCLUB.ADMPT_premio        pr
                     inner join PCLUB.ADMPT_tipo_premio   t_pr      on (pr.admpv_cod_tpopr = t_pr.admpv_cod_tpopr)
                     inner join PCLUB.ADMPT_tipo_premclie t_pre_cli on (t_pr.admpv_cod_tpopr=t_pre_cli.admpv_cod_tpopr)
              WHERE  pr.admpc_estado = 'A'  AND    pr.admpn_puntos <= K_SALDO_PUNTOS AND
                     --1 Control , 2 PostPago, 3 Prepago, con el tipo de cliente
                     t_pre_cli.admpv_cod_tpocl= K_TIP_LINEA AND
                     pr.admpn_puntos > 0 AND
                     pr.admpv_id_procla not in (select admpv_id_procla from
                     PCLUB.ADMPT_EXCPREMIO_TIPOCLIE where admpv_cod_tpocl=K_TIP_CLI)
              ORDER BY t_pr.admpn_orden, pr.admpn_puntos DESC;
        /*ELSIF  K_TIPO_LINEA='3' THEN
             OPEN K_CUR_LISTA FOR
              SELECT  distinct pr.admpv_id_procla AS ProdId,
                     pr.admpv_desc      AS ProdDes,
                     pr.admpv_campana   AS Campana,
                     pr.admpn_puntos    AS Puntos,
                     pr.admpn_pago      AS pago,
                     t_pr.admpv_desc    AS t_pr,
                     pr.admpn_cod_servc AS ServComercial,
                     pr.admpn_mnt_recar AS MontoRecarga,
                     pr.admpv_cod_paqdat AS codigo_paquete,
                     t_pr.admpn_orden AS orden,
                     pr.admpv_cod_servtv As Codigo_ServTV,
                     pr.admpv_cod_tpopr As  Cod_t_pr
              FROM PCLUB.ADMPT_premio        pr
                     inner join PCLUB.ADMPT_tipo_premio   t_pr      on (pr.admpv_cod_tpopr = t_pr.admpv_cod_tpopr)
                     inner join PCLUB.ADMPT_tipo_premclie t_pre_cli on (t_pr.admpv_cod_tpopr=t_pre_cli.admpv_cod_tpopr)
              WHERE  pr.admpc_estado = 'A'  AND    pr.admpn_puntos <= K_SALDO_PUNTOS AND
                     --1 Control , 2 PostPago, 3 Prepago, con el tipo de cliente
                    (t_pre_cli.admpv_cod_tpocl IN ('3'))
              ORDER BY t_pr.admpn_orden, pr.admpn_puntos DESC; */
        END IF;
     ELSE
      K_CODERROR:=1;
     END IF;

    /* *************************************************************************** */
  BEGIN
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR=K_CODERROR;
  EXCEPTION WHEN OTHERS THEN
      K_DESCERROR:='ERROR';
  END;

  EXCEPTION
    WHEN EX_VALIDACION THEN
      K_CODERROR := V_CODERROR;
      K_DESCERROR := V_DESCERROR;
    WHEN EX_ERROR THEN
      BEGIN
          SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
          FROM PCLUB.ADMPT_ERRORES_CC
          WHERE ADMPN_COD_ERROR=K_CODERROR;
      EXCEPTION WHEN OTHERS THEN
          K_DESCERROR:='ERROR';
      END;
    WHEN OTHERS THEN
      K_CODERROR := 1;
      K_DESCERROR:=SUBSTR( SQLERRM ,1,250);
  END ADMPSS_CONSALDO;

    PROCEDURE ADMPSS_CONSALDO(P_TIPO_DOC          IN PCLUB.admpt_cliente.admpv_tipo_doc%type,
                            P_NUM_DOC            IN PCLUB.admpt_cliente.admpv_num_doc%type,
                            P_SALDO_PUNTOS    OUT NUMBER,
                            P_COD_RESPUESTA   OUT NUMBER,
                            P_MENSAJE_RESPUESTA  OUT VARCHAR2)IS
                            

    /****************************************************************
    '* Nombre SP           :  ADMPSS_CONSALDO
    '* Propósito           :
    '* Input               :  
    '* Output              :  
    '* Creado por          :  Katherine Perez
    '* Fec Creación        :
    '* Fec Actualización   : 
    '****************************************************************/

    V_SALDO     NUMBER := 0;
    EX_ERROR    EXCEPTION;

    EX_VALIDACION EXCEPTION;
    V_EST_BLOQUEO CHAR(1);
    V_TIPO_DOC    VARCHAR2(20);
    V_CODERROR NUMBER;
    V_DESCERROR VARCHAR2(250);
    K_TIP_CLI PCLUB.admpt_cliente.admpv_cod_tpocl%type;
    V_TIPO_DOCUM PCLUB.admpt_tipo_doc.admpv_cod_tpdoc%type;
    
    /* cursor agregado 18/09/16 */
       CURSOR CUR_CODIGOS(tipo_doc PCLUB.admpt_cliente.admpv_tipo_doc%type, num_doc PCLUB.admpt_cliente.admpv_num_doc%type) IS
      SELECT admpv_cod_tpocl
        FROM  admpt_clientefija
       WHERE (admpv_tipo_doc = tipo_doc AND admpv_num_doc = num_doc)
         AND admpc_estado = 'A';
	/*cursor agregado  18/09/16 */
    
    
  BEGIN

/** [INICIO]  LINEAS AGREGADAS  18/09/2016 ****/

IF (P_TIPO_DOC IS NOT NULL AND P_NUM_DOC IS NOT NULL) THEN

   IF P_TIPO_DOC= '001' THEN
      V_TIPO_DOCUM:=0; 
   ELSE
      SELECT T.ADMPV_COD_TPDOC INTO V_TIPO_DOCUM FROM PCLUB.ADMPT_TIPO_DOC T 
      WHERE T.ADMPV_EQU_FIJA=P_TIPO_DOC;
   END IF;
   P_SALDO_PUNTOS:=0;
	OPEN CUR_CODIGOS(V_TIPO_DOCUM, P_NUM_DOC);
	FETCH CUR_CODIGOS
	INTO K_TIP_CLI;

  IF CUR_CODIGOS%FOUND THEN
    WHILE CUR_CODIGOS%FOUND LOOP
    BEGIN  
       V_SALDO:=0;                       
    /** [FIN]  LINEAS AGREGADAS  18/09/2016 ****/
  	 
    /*** LOGICA EXISTENTE ***/
      P_COD_RESPUESTA := 0;

      IF (K_TIP_CLI IS NOT NULL) THEN
          ADMPSI_ES_CLIENTE(V_TIPO_DOCUM,
                   P_NUM_DOC,
                   K_TIP_CLI,
                   V_SALDO,
                   P_COD_RESPUESTA,
                   P_MENSAJE_RESPUESTA);
          
          P_SALDO_PUNTOS := P_SALDO_PUNTOS+V_SALDO;

          -- Realiza la validación del bloqueo
          PCLUB.PKG_CC_TRANSACCION.ADMPS_VALBLOQUEOBOLSA(V_TIPO_DOCUM,P_NUM_DOC,K_TIP_CLI,V_TIPO_DOC,V_EST_BLOQUEO,V_CODERROR,V_DESCERROR);
  			
          IF P_COD_RESPUESTA <> 0 THEN
            RAISE EX_VALIDACION;
          END IF;

          IF V_EST_BLOQUEO = 'R' THEN
            P_COD_RESPUESTA := 37;
            P_MENSAJE_RESPUESTA := 'Existe un canje en proceso.';
          END IF;

       ELSE
         RAISE NO_DATA_FOUND;
       END IF;
  	
    EXCEPTION 
      WHEN NO_DATA_FOUND THEN
         P_COD_RESPUESTA := 40;
         P_MENSAJE_RESPUESTA := 'No se encontro informacion';
    END;

    FETCH CUR_CODIGOS
    INTO K_TIP_CLI;
    END LOOP;
    CLOSE CUR_CODIGOS;
  ELSE
    RAISE NO_DATA_FOUND;
  END IF;
  
ELSE
	RAISE EX_ERROR;
END IF;

/**	BEGIN
		SELECT ADMPV_DES_ERROR || P_MENSAJE_RESPUESTA INTO P_MENSAJE_RESPUESTA
		FROM ADMPT_ERRORES_CC
		WHERE ADMPN_COD_ERROR=P_COD_RESPUESTA;
		EXCEPTION WHEN OTHERS THEN
		  P_MENSAJE_RESPUESTA:='ERROR';
	END;**/

 EXCEPTION
    WHEN NO_DATA_FOUND THEN
          P_COD_RESPUESTA := 40;
          P_MENSAJE_RESPUESTA := 'No se encontro informacion para los datos ingresados';
    WHEN EX_VALIDACION THEN
         /*****Inicio Codigo Agregado****/   
         IF V_CODERROR <> 0 THEN
                P_COD_RESPUESTA := V_CODERROR;
				P_MENSAJE_RESPUESTA:= V_DESCERROR;
         END IF;  
         /*****Fin Codigo Agregado******/
    WHEN EX_ERROR THEN
         P_COD_RESPUESTA := 41;
         P_MENSAJE_RESPUESTA := 'Ingreso datos incorrectos o datos insuficientes para realizar la consulta';
    WHEN OTHERS THEN
        P_COD_RESPUESTA := 1;
        P_MENSAJE_RESPUESTA:=SUBSTR( SQLERRM ,1,250);
                
  END ADMPSS_CONSALDO;

PROCEDURE ADMPSI_DSCTO_PUNTO(K_COD_CLIENTE IN VARCHAR2, K_TIP_CLI IN VARCHAR2, K_PUNTOS IN NUMBER, K_CONCEPTOCC IN VARCHAR2, V_CUENTADES IN VARCHAR2, K_USUARIO IN VARCHAR2,K_CODERROR OUT NUMBER, K_MSJERROR OUT VARCHAR2)
IS
--****************************************************************
-- Nombre SP           :  ADMPSI_DESC_PUNTOS
-- Propósito           :  Descuenta puntos para Canje segun FIFO y el requerimento definido
-- Input               :  K_COD_CLIENTE Codigo de Cliente
--                        K_TIP_CLI Tipo de Cliente
--                        K_PUNTOS Total de Puntos a descontar
--                        K_CONCEPTOCC Concepto CC
--                        K_CONCEPTOIB Concepto IB
-- Output              :  K_CODERROR
--                        K_MSJERROR
-- Creado por          :  Juan Carlos Gutiérrez Trujillo
-- Fec Creación        :  11-05-2012

--****************************************************************

V_PUNTOS_REQUERIDOS      NUMBER:=0;


LK_TPO_PUNTO                     CHAR(1);
LK_ID_KARDEX                     NUMBER;
LK_SLD_PUNTOS                    NUMBER;
LK_COD_CLI_PROD                       VARCHAR2(40);
LK_COD_CLIIB                     NUMBER;
V_CONT                             NUMBER;

CURSOR LISTA_KARDEX_1 IS
SELECT KA.ADMPC_TPO_PUNTO, KA.ADMPN_ID_KARDEX, KA.ADMPN_SLD_PUNTO, KA.ADMPV_COD_CLI_PROD, ADMPN_COD_CLI_IB
FROM PCLUB.ADMPT_KARDEXFIJA KA
WHERE KA.ADMPC_ESTADO='A'
AND KA.ADMPC_TPO_OPER='E'
AND KA.ADMPN_SLD_PUNTO>0
AND KA.ADMPD_FEC_TRANS<=SYSDATE
AND KA.ADMPV_COD_CLI_PROD IN (SELECT ADMPV_COD_CLI_PROD
                                                  FROM PCLUB.ADMPT_CLIENTEFIJA F, PCLUB.ADMPT_CLIENTEPRODUCTO P
                                                  WHERE F.ADMPV_COD_CLI = P.ADMPV_COD_CLI
                                                  AND F.ADMPV_COD_CLI = K_COD_CLIENTE
                                                  AND F.ADMPV_COD_TPOCL = K_TIP_CLI
                                                  AND F.ADMPC_ESTADO = 'A'
                                                  AND P.ADMPV_ESTADO_SERV = 'A'
                             )
ORDER BY DECODE(ADMPC_TPO_PUNTO, 'I', 1 ,'L', 2 ,'C', 3), ADMPN_ID_KARDEX ASC;

BEGIN

K_CODERROR:=0;
K_MSJERROR:=' ';
V_CONT:=0;

V_PUNTOS_REQUERIDOS:=K_PUNTOS;

   -- Comienza el Canje, dato de entrada el codigo de cliente
   IF K_COD_CLIENTE IS NOT NULL THEN
       IF K_TIP_CLI='7'  OR K_TIP_CLI='6' THEN -- Clientes HFC
         OPEN LISTA_KARDEX_1;
         FETCH LISTA_KARDEX_1 INTO LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI_PROD, LK_COD_CLIIB;
         WHILE LISTA_KARDEX_1%FOUND AND V_PUNTOS_REQUERIDOS>0
           LOOP

             V_CONT := V_CONT + 1;

              IF LK_SLD_PUNTOS<=V_PUNTOS_REQUERIDOS THEN

                -- Actualiza Kardex
                UPDATE PCLUB.ADMPT_KARDEXFIJA
                   SET
                       ADMPN_SLD_PUNTO = 0, ADMPC_ESTADO = 'C',
                       ADMPD_FEC_MOD=SYSDATE,ADMPV_USU_MOD=K_USUARIO
                 WHERE ADMPN_ID_KARDEX = LK_ID_KARDEX;

                IF LK_TPO_PUNTO='C' OR LK_TPO_PUNTO='L' THEN /* Punto Claro Club */

                    -- Inserta kardex
                    INSERT INTO PCLUB.ADMPT_KARDEXFIJA(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI_PROD,ADMPV_COD_CPTO
                    ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO,ADMPD_FEC_REG,ADMPV_USU_REG,ADMPV_NOM_ARCH)
                    VALUES(PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL,LK_COD_CLIIB,LK_COD_CLI_PROD,K_CONCEPTOCC,SYSDATE,
                    LK_SLD_PUNTOS * (-1),'S','C',0,'A',SYSDATE,K_USUARIO, V_CUENTADES);

                    -- Actualiza Saldos_cliente
                    UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                       SET
                           ADMPN_SALDO_CC = - LK_SLD_PUNTOS + (SELECT NVL(ADMPN_SALDO_CC,0) FROM PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                                    WHERE ADMPV_COD_CLI_PROD=LK_COD_CLI_PROD),
                           ADMPD_FEC_MOD=SYSDATE,ADMPV_USU_MOD=K_USUARIO
                     WHERE ADMPV_COD_CLI_PROD = LK_COD_CLI_PROD;

                END IF;

                V_PUNTOS_REQUERIDOS:=V_PUNTOS_REQUERIDOS-LK_SLD_PUNTOS;

              ELSE
                IF LK_SLD_PUNTOS > V_PUNTOS_REQUERIDOS THEN

                   -- Actualiza Kardex
                   UPDATE PCLUB.ADMPT_KARDEXFIJA
                     SET
                         ADMPN_SLD_PUNTO = LK_SLD_PUNTOS - V_PUNTOS_REQUERIDOS,
                         ADMPD_FEC_MOD=SYSDATE,ADMPV_USU_MOD=K_USUARIO
                   WHERE ADMPN_ID_KARDEX = LK_ID_KARDEX;

                    IF LK_TPO_PUNTO='C' OR LK_TPO_PUNTO='L' THEN /* Punto Claro Club */

                       -- Inserta kardex

                       INSERT INTO PCLUB.ADMPT_KARDEXFIJA(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,ADMPV_COD_CLI_PROD,ADMPV_COD_CPTO
                       ,ADMPD_FEC_TRANS,ADMPN_PUNTOS,ADMPC_TPO_OPER,ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,ADMPC_ESTADO,ADMPD_FEC_REG,ADMPV_USU_REG,ADMPV_NOM_ARCH)
                       VALUES(PCLUB.ADMPT_KARDEXFIJA_SQ.NEXTVAL,LK_COD_CLIIB,LK_COD_CLI_PROD,K_CONCEPTOCC,SYSDATE,
                       V_PUNTOS_REQUERIDOS * (-1),'S','C',0,'A',SYSDATE,K_USUARIO, V_CUENTADES);

                       -- Actualiza Saldos_cliente
                       UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                           SET
                               ADMPN_SALDO_CC = - V_PUNTOS_REQUERIDOS + (SELECT NVL(ADMPN_SALDO_CC,0) FROM PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                                        WHERE ADMPV_COD_CLI_PROD=LK_COD_CLI_PROD),
                               ADMPD_FEC_MOD=SYSDATE,ADMPV_USU_MOD=K_USUARIO
                         WHERE ADMPV_COD_CLI_PROD = LK_COD_CLI_PROD;

                    END IF;
                    V_PUNTOS_REQUERIDOS:=0;

                END IF;
              END IF;
              FETCH LISTA_KARDEX_1 INTO LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI_PROD, LK_COD_CLIIB;
           END LOOP;
         CLOSE LISTA_KARDEX_1;

       END IF;
   END IF;

IF V_CONT = 0 THEN
    K_CODERROR:=17;
END IF;
COMMIT;
 BEGIN
        SELECT ADMPV_DES_ERROR || K_MSJERROR INTO K_MSJERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR=K_CODERROR;
 EXCEPTION WHEN OTHERS THEN
    K_MSJERROR:='ERROR';
 END;

EXCEPTION
  WHEN OTHERS THEN
    K_CODERROR:=1;
    K_MSJERROR:=SUBSTR( SQLERRM, 1,400);
    ROLLBACK;

END ADMPSI_DSCTO_PUNTO;



PROCEDURE ADMPSS_TRANSPUNTOS(K_TIPDOC_ORI  IN VARCHAR2,
                             K_NUMDOC_ORI  IN VARCHAR2,
                             K_TIPCLIE_ORI IN VARCHAR2,
                             K_TIPCLIE_DES IN VARCHAR2,
                             K_LINEA_DES   IN VARCHAR2,
                             K_PUNTOS      IN NUMBER,
                             K_SALDO_CD    OUT NUMBER,
                             K_USUARIO     IN VARCHAR2,
                             K_CODERROR    OUT NUMBER,
                             K_DESCERROR   OUT VARCHAR2) IS
  --****************************************************************
  -- Nombre SP         :  ADMPSS_TRANSPUNTOSDTH
  -- Propósito           :  transfiere puntos de DTH - HFC a una movil
  -- Output              :  K_CODERROR
  --                            K_DESCERROR
  -- Creado por        : Juan Carlos Gutiérrez Trujillo
  -- Fec Creación     :  16/05/2012
  --****************************************************************
  EX_ERROR EXCEPTION;

  V_COUNT_OR        NUMBER;
  V_COUNT_DES       NUMBER;
  V_CODERROR        VARCHAR2(400);
  V_COD_CPTO        VARCHAR2(2);
  V_COD_CPTO_SALIDA VARCHAR2(2);
  V_COD_CLI_OR      VARCHAR2(40);
  V_COD_CLI_IB      VARCHAR2(40);
  V_ESTADO          VARCHAR2(2);
  V_TIPDOC_DES      VARCHAR2(20);
  V_NUMDOC_DES      VARCHAR2(20);
  V_TIPDOC_ORI      VARCHAR2(20);
  V_NUMDOC_ORI      VARCHAR2(20);
  V_SALDO_ORI       NUMBER;
  V_COUNT_SAL       NUMBER;

  TYPE TY_CURSOR IS REF CURSOR;
  CURSORDAT_CLIE TY_CURSOR;

  C_CUENTA     VARCHAR2(40);
  C_TIP_DOC    VARCHAR2(20);
  C_NUM_DOC    VARCHAR2(30);
  C_CO_ID      INTEGER;
  C_CI_FAC     VARCHAR2(2);
  C_COD_TIP_CL VARCHAR2(10);
  C_TIP_CL     VARCHAR2(30);

  V_CUENTADES    VARCHAR2(40);
  K_CODERROR_DP  NUMBER;
  K_DESCERROR_DP VARCHAR2(400);

BEGIN
  K_CODERROR  := 0;
  K_DESCERROR := ' ';

  IF K_TIPDOC_ORI IS NULL OR K_NUMDOC_ORI IS NULL THEN
    K_CODERROR  := 4;
    K_DESCERROR := 'El tipo o numero de documento destino no es válido.';
    RAISE EX_ERROR;
  END IF;

  IF K_LINEA_DES IS NULL THEN
    K_CODERROR  := 4;
    K_DESCERROR := 'la linea destino no es válida.';
    RAISE EX_ERROR;
  END IF;

  IF K_TIPCLIE_ORI IS NULL OR
     (K_TIPCLIE_ORI <> '6' AND K_TIPCLIE_ORI <> '7') THEN
    /*HFC - DTH*/
    K_CODERROR  := 4;
    K_DESCERROR := 'El tipo de cliente origen no es válido.';
    RAISE EX_ERROR;
  END IF;

  IF K_TIPCLIE_DES IS NULL OR
     (K_TIPCLIE_DES <> '1' AND K_TIPCLIE_DES <> '2' AND
     K_TIPCLIE_DES <> '3') THEN
    /*POST y PRE*/
    K_CODERROR  := 4;
    K_DESCERROR := 'El tipo de cliente destino no es válido.';
    RAISE EX_ERROR;
  END IF;

  BEGIN
    IF K_TIPCLIE_ORI = '7' THEN
      IF K_TIPCLIE_DES = '3' THEN
        SELECT ADMPV_COD_CPTO
          INTO V_COD_CPTO
          FROM PCLUB.ADMPT_CONCEPTO
         WHERE ADMPV_DESC LIKE '%PREPAGO - TRANSFERENCIA DE HFC%';
      ELSE
        SELECT ADMPV_COD_CPTO
          INTO V_COD_CPTO
          FROM PCLUB.ADMPT_CONCEPTO
         WHERE ADMPV_DESC LIKE '%POSTPAGO - TRANSFERENCIA DE HFC%';
      END IF;
    ELSIF K_TIPCLIE_ORI = '6' THEN
      IF K_TIPCLIE_DES = '3' THEN
        SELECT ADMPV_COD_CPTO
          INTO V_COD_CPTO
          FROM PCLUB.ADMPT_CONCEPTO
         WHERE ADMPV_DESC LIKE '%PREPAGO - TRANSFERENCIA DE DTH%';
      ELSE
        SELECT ADMPV_COD_CPTO
          INTO V_COD_CPTO
          FROM PCLUB.ADMPT_CONCEPTO
         WHERE ADMPV_DESC LIKE '%POSTPAGO - TRANSFERENCIA DE DTH%';
      END IF;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_COD_CPTO := NULL;
  END;

  IF V_COD_CPTO IS NULL THEN
    K_CODERROR  := 9;
    K_DESCERROR := 'TRANSFERENCIA FIJA A MOVIL.';
    RAISE EX_ERROR;
  END IF;

  V_COUNT_OR := 0;
  V_ESTADO   := NULL;

  --SE VERIFICA SI EXISTE EL CLIENTE ORIGEN
  SELECT COUNT(ADMPV_COD_CLI)
    INTO V_COUNT_OR
    FROM PCLUB.ADMPT_CLIENTEFIJA C
   WHERE C.ADMPV_NUM_DOC = K_NUMDOC_ORI
     AND C.ADMPV_TIPO_DOC = K_TIPDOC_ORI
     AND C.ADMPV_COD_TPOCL = K_TIPCLIE_ORI
     AND C.ADMPC_ESTADO = 'A';

  IF V_COUNT_OR = 0 THEN
    K_CODERROR  := 6;
    K_DESCERROR := 'Cliente enviado como origen  NO EXISTE.';
    RAISE EX_ERROR;
  ELSE
    SELECT C.ADMPV_COD_CLI, C.ADMPC_ESTADO
      INTO V_COD_CLI_OR, V_ESTADO
      FROM PCLUB.ADMPT_CLIENTEFIJA C
     WHERE C.ADMPV_NUM_DOC = K_NUMDOC_ORI
       AND C.ADMPV_TIPO_DOC = K_TIPDOC_ORI
       AND C.ADMPV_COD_TPOCL = K_TIPCLIE_ORI
       AND C.ADMPC_ESTADO = 'A';
  END IF;

  V_COUNT_DES := 0;
  V_ESTADO    := NULL;

  --SE VERIFICA SI EXISTE EL CLIENTE DESTINO
  --OBTENER CUENTA DEL CLIENTE DESTINO
  IF K_TIPCLIE_DES = '2' OR K_TIPCLIE_DES = '1' THEN
    PCLUB.PKG_CLAROCLUB.ADMPSS_DAT_CLIE('',
                                  K_LINEA_DES,
                                  V_CODERROR,
                                  CURSORDAT_CLIE);
    LOOP
      FETCH CURSORDAT_CLIE
        INTO C_CUENTA, C_TIP_DOC, C_NUM_DOC, C_CO_ID, C_CI_FAC, C_COD_TIP_CL, C_TIP_CL;
      EXIT WHEN CURSORDAT_CLIE%NOTFOUND;
      V_CUENTADES := C_CUENTA;
    END LOOP;
    CLOSE CURSORDAT_CLIE;
  ELSE
    V_CUENTADES := K_LINEA_DES;
  END IF;

  SELECT COUNT(*)
    INTO V_COUNT_DES
    FROM PCLUB.ADMPT_CLIENTE
   WHERE ADMPV_COD_CLI = V_CUENTADES
     AND ADMPV_COD_TPOCL = K_TIPCLIE_DES; /*REALIZO LA VERIFICACION SI ESTA EN CLARO CLUB*/

  IF V_COUNT_DES = 0 THEN
    K_CODERROR := 6;
    IF K_TIPCLIE_DES = '3' THEN
      K_DESCERROR := 'Cliente Prepago enviado como destino NO EXISTE.';
    ELSE
      K_DESCERROR := 'Cliente Postpago enviado como destino NO EXISTE.';
    END IF;
    RAISE EX_ERROR;
  ELSE
    --SE VERIFICA SI ESTA ACTIVO EL CLIENTE DESTINO
    SELECT ADMPC_ESTADO
      INTO V_ESTADO
      FROM PCLUB.ADMPT_CLIENTE
     WHERE ADMPV_COD_CLI = V_CUENTADES
       AND ADMPV_COD_TPOCL = K_TIPCLIE_DES;

    IF V_ESTADO <> 'A' THEN
      K_CODERROR  := 6;
      K_DESCERROR := 'No se puede hacer transferencia de puntos.';
      RAISE EX_ERROR;
    END IF;
  END IF;

  --SE VERIFICA QUE LOS PUNTOS SEAN MAYORES A 0 Y QUE LA SUMA DEL SALDO CC DEL CLIENTE ORIGEN SEA MAYOR AL REQUERIDO
  IF K_PUNTOS > 0 THEN
    SELECT SUM(NVL(ADMPN_SALDO_CC, 0) + NVL(ADMPN_SALDO_IB, 0)) SALDO
      INTO V_SALDO_ORI
      FROM PCLUB.ADMPT_SALDOS_CLIENTEFIJA SC
     WHERE NVL(ADMPN_SALDO_CC, 0) + NVL(ADMPN_SALDO_IB, 0) >= 0
       AND ADMPV_COD_CLI_PROD IN
           (SELECT P.ADMPV_COD_CLI_PROD
              FROM PCLUB.ADMPT_CLIENTEFIJA F, PCLUB.ADMPT_CLIENTEPRODUCTO P
             WHERE F.ADMPV_COD_CLI = P.ADMPV_COD_CLI
               AND F.ADMPV_COD_CLI = V_COD_CLI_OR
               AND F.ADMPV_COD_TPOCL = K_TIPCLIE_ORI
               AND F.ADMPC_ESTADO = 'A'
               AND P.ADMPV_ESTADO_SERV = 'A');

    IF V_SALDO_ORI < K_PUNTOS THEN
      K_CODERROR  := 18;
      K_DESCERROR := ' ';
      RAISE EX_ERROR;
    END IF;
  ELSE
    K_CODERROR  := 19;
    K_DESCERROR := ' ';
    RAISE EX_ERROR;
  END IF;

  --VERIFICANDO QUE EL NUMERO Y TIPO DE DOCUMENTO DEL CLIENTE ORIGEN Y CLIENTE DESTINO SEAN IGUALES

  SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
    INTO V_TIPDOC_DES, V_NUMDOC_DES
    FROM PCLUB.ADMPT_CLIENTE
   WHERE ADMPV_COD_CLI = V_CUENTADES
     AND ADMPV_COD_TPOCL = K_TIPCLIE_DES;

  SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
    INTO V_TIPDOC_ORI, V_NUMDOC_ORI
    FROM PCLUB.ADMPT_CLIENTEFIJA
   WHERE ADMPV_COD_CLI = V_COD_CLI_OR
     AND ADMPV_COD_TPOCL = K_TIPCLIE_ORI;

  IF V_TIPDOC_DES = V_TIPDOC_ORI THEN

    IF V_NUMDOC_DES = V_NUMDOC_ORI THEN

      BEGIN
        SELECT ADMPN_COD_CLI_IB
          INTO V_COD_CLI_IB
          FROM PCLUB.ADMPT_CLIENTEIB
         WHERE ADMPV_COD_CLI = V_CUENTADES
           AND ADMPC_ESTADO = 'A';

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_COD_CLI_IB := NULL;
      END;

      --REGISTRANDO LOS PUNTOS DE LA TRANSFERENCIA EN EL KARDEX
      INSERT INTO PCLUB.ADMPT_KARDEX
        (ADMPN_ID_KARDEX,
         ADMPV_COD_CLI,
         ADMPN_COD_CLI_IB,
         ADMPV_COD_CPTO,
         ADMPD_FEC_TRANS,
         ADMPN_PUNTOS,
         ADMPC_TPO_OPER,
         ADMPC_TPO_PUNTO,
         ADMPN_SLD_PUNTO,
         ADMPC_ESTADO,
         ADMPV_NOM_ARCH)
      VALUES
        (PCLUB.ADMPT_KARDEX_SQ.NEXTVAL,
         V_CUENTADES,
         V_COD_CLI_IB,
         V_COD_CPTO,
         SYSDATE,
         K_PUNTOS,
         'E',
         'C',
         K_PUNTOS,
         'A',
         V_COD_CLI_OR);

      --VERIFICANDO SI EXISTE REGISTRO DE SALDO DEL CLIENTE DESTINO

      SELECT COUNT(*)
        INTO V_COUNT_SAL
        FROM PCLUB.ADMPT_SALDOS_CLIENTE
       WHERE ADMPV_COD_CLI = V_CUENTADES;

      IF V_COUNT_SAL = 0 THEN

        --INSERTAMOS EL REGISTRO DE SALDO SI NO EXISTE

        INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE
          (ADMPN_ID_SALDO,
           ADMPV_COD_CLI,
           ADMPN_SALDO_CC,
           ADMPN_SALDO_IB,
           ADMPC_ESTPTO_CC)
        VALUES
          (PCLUB.ADMPT_SLD_CL_SQ.NEXTVAL, V_CUENTADES, K_PUNTOS, 0, 'A');

      ELSE

        --ACTUALIZANDO EL SALDO DEL CLIENTE DESTINO SI EXISTE EL REGISTRO SALDO
        UPDATE PCLUB.ADMPT_SALDOS_CLIENTE
           SET ADMPN_SALDO_CC = K_PUNTOS +
                                (SELECT NVL(ADMPN_SALDO_CC, 0)
                                   FROM PCLUB.ADMPT_SALDOS_CLIENTE
                                  WHERE ADMPV_COD_CLI = V_CUENTADES)
         WHERE ADMPV_COD_CLI = V_CUENTADES;

      END IF;

      --Obtenemos el concepto para las salidas
      BEGIN
        IF K_TIPCLIE_ORI = '7' THEN
          IF K_TIPCLIE_DES = '3' THEN
            SELECT ADMPV_COD_CPTO
              INTO V_COD_CPTO_SALIDA
              FROM PCLUB.ADMPT_CONCEPTO
             WHERE ADMPV_DESC LIKE '%TRANSFERENCIA HFC A PREPAGO%';
          ELSE
            SELECT ADMPV_COD_CPTO
              INTO V_COD_CPTO_SALIDA
              FROM PCLUB.ADMPT_CONCEPTO
             WHERE ADMPV_DESC LIKE '%TRANSFERENCIA HFC A POSTPAGO%';
          END IF;
        ELSIF K_TIPCLIE_ORI = '6' THEN
          IF K_TIPCLIE_DES = '3' THEN
            SELECT ADMPV_COD_CPTO
              INTO V_COD_CPTO_SALIDA
              FROM PCLUB.ADMPT_CONCEPTO
             WHERE ADMPV_DESC LIKE '%TRANSFERENCIA DTH A PREPAGO%';
          ELSE
            SELECT ADMPV_COD_CPTO
              INTO V_COD_CPTO_SALIDA
              FROM PCLUB.ADMPT_CONCEPTO
             WHERE ADMPV_DESC LIKE '%TRANSFERENCIA DTH A POSTPAGO%';
          END IF;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_COD_CPTO_SALIDA := NULL;
      END;

      --ACTUALIZANDO E INSERTANDO LOS MOVIMIENTOS DEL CLIENTE ORIGEN EN LAS TABLAS DE KARDEX Y SALDOS DEL CLIENTE
      ADMPSI_DSCTO_PUNTO(V_COD_CLI_OR,
                         K_TIPCLIE_ORI,
                         K_PUNTOS,
                         V_COD_CPTO_SALIDA,
                         V_CUENTADES,
                         K_USUARIO,
                         K_CODERROR_DP,
                         K_DESCERROR_DP);

      IF K_CODERROR_DP <> '0' THEN
        K_CODERROR  := 21;
        K_DESCERROR := '';
        RAISE EX_ERROR;
      END IF;

    ELSE
      K_CODERROR  := 20;
      K_DESCERROR := '';
      RAISE EX_ERROR;
    END IF;

  ELSE
    K_CODERROR  := 20;
    K_DESCERROR := '';
    RAISE EX_ERROR;
  END IF;

  SELECT (ADMPN_SALDO_CC + ADMPN_SALDO_IB) SALDO
    INTO K_SALDO_CD
    FROM PCLUB.ADMPT_SALDOS_CLIENTE
   WHERE ADMPV_COD_CLI = V_CUENTADES;

  COMMIT;
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
    ROLLBACK;
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
    ROLLBACK;

END ADMPSS_TRANSPUNTOS;

PROCEDURE ADMPSI_VALIDARCLIENTE(K_TIPDOC IN VARCHAR2,K_NUMDOC IN VARCHAR2,K_TIPCLIE IN VARCHAR2,K_COD_CLI OUT VARCHAR2, K_MENSAJE OUT VARCHAR2,K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2) IS
    EX_ERROR EXCEPTION;
    V_DESCERROR VARCHAR2(500);
    V_CODERROR NUMBER;
    V_REG NUMBER;
BEGIN
    K_CODERROR:=0;
    K_DESCERROR:=' ';

    IF K_TIPDOC IS NULL THEN
        K_CODERROR:=4;
        K_DESCERROR:='El tipo de documento no es válido';
        RAISE EX_ERROR;
    END IF;
    IF K_NUMDOC IS NULL THEN
        K_CODERROR:=4;
        K_DESCERROR:='El Nro. de documento no es válido';
        RAISE EX_ERROR;
    END IF;
    IF K_TIPCLIE IS NULL OR (K_TIPCLIE<>'6' AND K_TIPCLIE<>'7')THEN
        K_CODERROR:=4;
        K_DESCERROR:='El tipo de cliente no es válido';
        RAISE EX_ERROR;
    END IF;

       SELECT COUNT(*) INTO V_REG
       FROM PCLUB.ADMPT_CLIENTEFIJA C
       WHERE C.ADMPV_TIPO_DOC = K_TIPDOC
       AND C.ADMPV_NUM_DOC = K_NUMDOC
       AND C.ADMPV_COD_TPOCL = K_TIPCLIE;

     IF V_REG = 0 THEN
         PCLUB.PKG_CC_MANTENIMIENTO.ADMPSI_OBTMENSAJE('REGHFCPRESMSERROR',K_MENSAJE,K_CODERROR,K_DESCERROR);
         K_CODERROR:=6;
        --K_DESCERROR:='El cliente no esta registrado en CLARO CLUB';
     ELSE
        SELECT C.ADMPV_COD_CLI INTO K_COD_CLI
        FROM PCLUB.ADMPT_CLIENTEFIJA C
        WHERE C.ADMPV_TIPO_DOC = K_TIPDOC
        AND C.ADMPV_NUM_DOC = K_NUMDOC
        AND C.ADMPV_COD_TPOCL = K_TIPCLIE;
     END IF;

     BEGIN
        SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
        FROM PCLUB.ADMPT_ERRORES_CC
        WHERE ADMPN_COD_ERROR=K_CODERROR;
     EXCEPTION WHEN OTHERS THEN
        K_DESCERROR:='ERROR';
     END;


EXCEPTION  WHEN EX_ERROR THEN
                PCLUB.PKG_CC_MANTENIMIENTO.ADMPSI_OBTMENSAJE('REGHFCERROR',K_MENSAJE,V_CODERROR,V_DESCERROR);
                 BEGIN
                    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
                    FROM PCLUB.ADMPT_ERRORES_CC
                    WHERE ADMPN_COD_ERROR=K_CODERROR;
                 EXCEPTION WHEN OTHERS THEN
                    K_DESCERROR:='ERROR';
                 END;
                 WHEN OTHERS THEN
                    K_CODERROR:=1;
                    K_DESCERROR:=SUBSTR(SQLERRM, 1, 250);
END ADMPSI_VALIDARCLIENTE;

FUNCTION SPLITCAD(P_IN_STRING VARCHAR2, P_DELIM VARCHAR2)
RETURN TAB_ARRAY
  /*
        Proposito            : Separacion de parametros enviados en un cadena por un determinante
        Parametros          : p_in_string   Cadena que contiene los parametros concatenados
                                p_delim         Caracter delimitador
        Fecha Creacion      : 09:30 a.m. 02/02/2012
        Fecha Modificacion  : 09:30 a.m. 02/02/2012
     -----------------------------------------------------------------------
  */
  IS
    I         NUMBER := 0;
    POS       NUMBER := 0;
    LV_STR    VARCHAR2(200) := LTRIM(P_IN_STRING);
    ARREGLO   TAB_ARRAY;
    CVALOR    VARCHAR2(200);
  BEGIN
    POS :=  INSTR(LV_STR,P_DELIM ,1 ,1);
    WHILE (POS != 0 OR  POS != NULL)
    LOOP
      I := I + 1;
      --Capturando valores para el arreglo
      CVALOR:=SUBSTR(LV_STR, 1, POS - 1);
      IF CVALOR='|' OR CVALOR IS NULL THEN
         ARREGLO(I) :='NULL';
      ELSE
         ARREGLO(I) :=CVALOR;
      END IF;

      LV_STR     :=SUBSTR(LV_STR, POS + 1, LENGTH(LV_STR));
      POS        :=INSTR(LV_STR ,P_DELIM  ,1 ,1);

      IF POS = 0 THEN
        --Capturando valor para el primer elemento
        ARREGLO(I + 1) := LV_STR;
      END IF;
    END LOOP;

    RETURN ARREGLO;
  END SPLITCAD;


PROCEDURE ADMPSS_OBTENERLINEASCLIENTE( K_TIPO_DOC IN VARCHAR2,K_NUM_DOC IN VARCHAR2,K_TIPCLI IN VARCHAR2,K_CODERROR OUT NUMBER,
                                       K_MSJERROR OUT VARCHAR2,CURSORCLI  OUT SYS_REFCURSOR) AS

EX_ERROR EXCEPTION;
V_REG NUMBER;
BEGIN
K_CODERROR:=0;
K_MSJERROR:='';

IF K_TIPO_DOC IS NULL THEN
    K_MSJERROR := 'Ingrese el tipo de Dcto.';
    RAISE EX_ERROR;
END IF;

IF K_NUM_DOC IS NULL THEN
    K_MSJERROR := 'Ingrese el numero de Dcto.';
    RAISE EX_ERROR;
END IF;

  IF (K_TIPCLI IS NULL) OR (K_TIPCLI <> '2' AND K_TIPCLI <> '3' AND K_TIPCLI <> '4' AND K_TIPCLI <> '8') THEN
    K_MSJERROR := 'Ingrese el tipo de Cliente válido';
    RAISE EX_ERROR;
  END IF;

IF K_TIPCLI = '3' THEN--PREPAGO
     SELECT COUNT(*) INTO V_REG
    FROM  dm.ods_base_abonados@dbl_reptdm_d C, PCLUB.ADMPT_TIPO_DOC D
    WHERE C.NRO_DOCUMENTO = K_NUM_DOC
    AND D.ADMPV_COD_TPDOC = K_TIPO_DOC
    AND C.TIPO_DOCUMENTO = UPPER( D.ADMPV_EQU_DWH )
    AND C.IDSEGMENTO IN (1);

     IF V_REG > 0 THEN
        OPEN CURSORCLI FOR
        SELECT SUBSTR(C.MSISDN,3,11)  LINEA,
        case when C.idsegmento=1 then '3'||'|'||C.id_cliente else
                (case when C.idsegmento=2 then '1'||'|'||C.id_cliente else
                           (case when (C.idsegmento=3 or C.idsegmento=4) then '2'||'|'||C.id_cliente else '' end   ) end )  end TLinea_Codigo
        FROM  dm.ods_base_abonados@dbl_reptdm_d C, PCLUB.ADMPT_TIPO_DOC D
        WHERE C.NRO_DOCUMENTO = K_NUM_DOC
        AND D.ADMPV_COD_TPDOC = K_TIPO_DOC
        AND C.TIPO_DOCUMENTO = UPPER( D.ADMPV_EQU_DWH )
        AND C.IDSEGMENTO IN (1);

    ELSE
        K_MSJERROR := 'No existen lineas Prepago asociadas al cliente.';
        RAISE EX_ERROR;
    END IF;

ELSIF K_TIPCLI = '2' THEN--POSTPAGO

    SELECT COUNT(*) INTO V_REG
    FROM  dm.ods_base_abonados@dbl_reptdm_d C, PCLUB.ADMPT_TIPO_DOC D
    WHERE C.NRO_DOCUMENTO = K_NUM_DOC
    AND D.ADMPV_COD_TPDOC = K_TIPO_DOC
    AND C.TIPO_DOCUMENTO = UPPER( D.ADMPV_EQU_DWH )
    AND C.IDSEGMENTO IN (2,3);

     IF V_REG > 0 THEN

        OPEN CURSORCLI FOR
        SELECT SUBSTR(C.MSISDN,3,11)  LINEA,
        case when C.idsegmento=1 then '3'||'|'||C.co_id else
                (case when C.idsegmento=2 then '1'||'|'||C.co_id else
                           (case when (C.idsegmento=3 or C.idsegmento=4) then '2'||'|'||C.co_id else '' end   ) end )  end TLinea_Codigo
        /*case when C.idsegmento=1 then '3'||'|'||C.id_cliente else
                (case when C.idsegmento=2 then '1'||'|'||C.id_cliente else
                           (case when (C.idsegmento=3 or C.idsegmento=4) then '2'||'|'||C.id_cliente else '' end   ) end )  end TLinea_Codigo*/
        FROM  dm.ods_base_abonados@dbl_reptdm_d C, PCLUB.ADMPT_TIPO_DOC D
        WHERE C.NRO_DOCUMENTO = K_NUM_DOC
        AND D.ADMPV_COD_TPDOC = K_TIPO_DOC
        AND C.TIPO_DOCUMENTO = UPPER( D.ADMPV_EQU_DWH )
        AND C.IDSEGMENTO IN (2,3);

    ELSE
        K_MSJERROR := 'No existen lineas Postpago asociadas al cliente.';
        RAISE EX_ERROR;
    END IF;
ELSIF  K_TIPCLI = '8' THEN
    --TFI
     SELECT COUNT(*)
      INTO V_REG
      FROM dm.ods_base_abonados@dbl_reptdm_d C, PCLUB.ADMPT_TIPO_DOC D
     WHERE C.NRO_DOCUMENTO = K_NUM_DOC
       AND D.ADMPV_COD_TPDOC = K_TIPO_DOC
       AND C.TIPO_DOCUMENTO = UPPER(D.ADMPV_EQU_DWH)
       AND (C.IDSEGMENTO=7 or C.IDSEGMENTO=8) AND C.IDPLATAFORMA=1 AND (C.IDESTADO=2 OR C.IDESTADO=3);

    IF V_REG > 0 THEN
      OPEN CURSORCLI FOR
        SELECT SUBSTR(C.MSISDN, 3, 11) LINEA,
               '8'|| '|' ||SUBSTR(C.MSISDN, 3, 11) TLinea_Codigo
          FROM dm.ods_base_abonados@dbl_reptdm_d C, PCLUB.ADMPT_TIPO_DOC D
         WHERE C.NRO_DOCUMENTO = K_NUM_DOC
           AND D.ADMPV_COD_TPDOC = K_TIPO_DOC
           AND C.TIPO_DOCUMENTO = UPPER(D.ADMPV_EQU_DWH)
           AND (C.IDSEGMENTO = 7 or C.IDSEGMENTO = 8) AND C.IDPLATAFORMA = 1 AND (C.IDESTADO = 2 OR C.IDESTADO = 3);
    ELSE
      K_MSJERROR := 'No existen lineas TFI asociadas al cliente.';
      OPEN CURSORCLI FOR
        SELECT '' LINEA, '' TLinea_Codigo FROM DUAL;
    END IF;
END IF;

EXCEPTION
    WHEN EX_ERROR THEN
      BEGIN
          SELECT ADMPV_DES_ERROR || K_MSJERROR INTO K_MSJERROR
                FROM  PCLUB.ADMPT_ERRORES_CC
           WHERE ADMPN_COD_ERROR=K_CODERROR;
      EXCEPTION WHEN OTHERS THEN
          K_CODERROR := 1;
          K_MSJERROR:='ERROR';
      END;
      OPEN CURSORCLI FOR
        SELECT '' LINEA, '' TLinea_Codigo FROM DUAL;

    WHEN OTHERS THEN
     OPEN CURSORCLI FOR
     SELECT '' LINEA, '' TLinea_Codigo FROM DUAL;
      K_CODERROR  := 1;
      K_MSJERROR := SUBSTR(SQLERRM, 1, 250);

END ADMPSS_OBTENERLINEASCLIENTE;

PROCEDURE SP_VALIDAR_CANJE_PAQTV(  K_COD_CLIENTE IN VARCHAR2, K_CODPROD IN  VARCHAR2,
                                                                         K_CANTIDAD     OUT NUMBER,   K_CODERROR    OUT NUMBER,   K_DESCERROR   OUT VARCHAR2 ) AS

V_REG NUMBER;
EX_ERROR  EXCEPTION;

BEGIN
 K_CODERROR  := 0;
 K_CANTIDAD :=0;
 IF K_COD_CLIENTE IS NOT NULL   AND K_CODPROD IS NOT NULL THEN
               SELECT COUNT(*) INTO V_REG FROM PCLUB.ADMPT_CANJEFIJA C
                  INNER JOIN PCLUB.ADMPT_CANJE_DETALLEFIJA CD ON (C.ADMPV_ID_CANJE=CD.ADMPV_ID_CANJE)
              WHERE C.ADMPV_COD_CLI = K_COD_CLIENTE AND  CD.ADMPV_ID_PROCLA = K_CODPROD AND
                      (SYSDATE - CD.ADMPD_FEC_REG)<  1 ;
                     IF V_REG > 0 THEN
                            K_CANTIDAD :=V_REG;
                            K_CODERROR:=32;
                            K_DESCERROR:='';
                     END IF;
 ELSE
        K_CODERROR:=4;
         IF K_COD_CLIENTE IS NULL THEN
              K_DESCERROR := 'Parametro = K_COD_CLIENTE';
         END IF ;
         IF K_CODPROD IS NULL THEN
            K_DESCERROR := 'Parametro = K_CODPROD';
       END IF;
       RAISE EX_ERROR;
 END IF;

  BEGIN
    SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
    FROM  PCLUB.ADMPT_ERRORES_CC
    WHERE ADMPN_COD_ERROR=K_CODERROR;
  EXCEPTION WHEN OTHERS THEN
      K_DESCERROR:='ERROR';
  END;

 EXCEPTION
    WHEN EX_ERROR THEN
      BEGIN
          SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
                FROM  PCLUB.ADMPT_ERRORES_CC
           WHERE ADMPN_COD_ERROR=K_CODERROR;
          EXCEPTION WHEN OTHERS THEN
          K_CODERROR := 1;
          K_DESCERROR:='ERROR';
      END;
    WHEN OTHERS THEN
      K_CODERROR := 1;
      K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
 END   SP_VALIDAR_CANJE_PAQTV  ;


 PROCEDURE ADMPSS_VALIDASALDOKDX_FIJA( K_TIPO_DOC IN VARCHAR2,
                                       K_NUM_DOC  IN VARCHAR2 ,
                                       K_TIP_CLI  IN VARCHAR2,
                                       K_CODERROR OUT NUMBER) AS
  V_SALDO  NUMBER;
  V_SALDOKDX  NUMBER;
  V_TIP_DOC VARCHAR2(20);
  V_NUM_DOC VARCHAR2(20);
BEGIN
  K_CODERROR:=0;
  V_SALDO:=0;
  V_SALDOKDX:=0;

    SELECT  NVL(SUM(NVL(S.ADMPN_SALDO_CC,0)),0)  INTO V_SALDO  FROM PCLUB.ADMPT_SALDOS_CLIENTEFIJA S
           INNER JOIN PCLUB.ADMPT_CLIENTEPRODUCTO P ON (S.ADMPV_COD_CLI_PROD=P.ADMPV_COD_CLI_PROD)
           INNER JOIN PCLUB.ADMPT_CLIENTEFIJA C ON (P.ADMPV_COD_CLI=C.ADMPV_COD_CLI)
    WHERE   C.ADMPV_TIPO_DOC = K_TIPO_DOC AND C.ADMPV_NUM_DOC = K_NUM_DOC AND C.ADMPV_COD_TPOCL= K_TIP_CLI  AND
            C.ADMPC_ESTADO='A' AND P.ADMPV_ESTADO_SERV='A' ;


    SELECT SUM(K.ADMPN_SLD_PUNTO)  INTO  V_SALDOKDX  FROM PCLUB.ADMPT_KARDEXFIJA K
           INNER JOIN PCLUB.ADMPT_CLIENTEPRODUCTO P ON (K.ADMPV_COD_CLI_PROD=P.ADMPV_COD_CLI_PROD)
           INNER JOIN PCLUB.ADMPT_CLIENTEFIJA C ON (P.ADMPV_COD_CLI=C.ADMPV_COD_CLI)
    WHERE C.ADMPV_TIPO_DOC = K_TIPO_DOC AND C.ADMPV_NUM_DOC = K_NUM_DOC AND C.ADMPV_COD_TPOCL= K_TIP_CLI  AND C.ADMPC_ESTADO='A' AND
                 P.ADMPV_ESTADO_SERV='A' AND K.ADMPC_ESTADO='A' AND K.ADMPC_TPO_OPER='E' AND K.ADMPN_SLD_PUNTO>0;

  IF V_SALDO<>V_SALDOKDX THEN
     K_CODERROR:=1;
  END IF;

EXCEPTION
      WHEN OTHERS THEN
     K_CODERROR:=1;

END   ADMPSS_VALIDASALDOKDX_FIJA;

PROCEDURE ADMPSS_DEVPUNTS_FIJA(K_PUNTOVENTA IN VARCHAR2,
                               K_USUARIO IN VARCHAR2,
                               K_LISTA_DEV IN LISTA_DEVOLUCION,
                               K_CODERROR OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2,
                               K_SALDO OUT NUMBER) IS
                               -- K_ID_SOLICITUD IN VARCHAR2,
                               -- K_ID_SOLICITUD -> Codigo de la solicitud
  --****************************************************************
  -- Nombre SP           :  ADMPSS_DEVPUNTS_FIJA
  -- Propósito           :  Registrar una devolución de un canje realizado
  -- Input               :  K_PUNTOVENTA   -> Id de Canal de venta
  --                        K_LISTA_DEV    -> Lista de Productos que se registraron en la devolucion
  -- Output              :  K_CODERROR     -> Código de Error (si se presento)
  --                        K_DESCERROR    -> Mensaje de Error
  --                        K_SALDO        -> Saldo luego de registrar la devolucion
  -- Creado por          :  Jorge Luis Ortiz Castillo
  -- Fec Creación        :  25/09/2013
  --****************************************************************
  
  V_DEVOLUCION DEVOLUCION;
  
  CURSOR CANJE_KARDEX(IDCANJE NUMBER, IDCANJE_SEC NUMBER) IS
    SELECT KF.ADMPN_ID_KARDEX, KF.ADMPN_PUNTOS 
    FROM PCLUB.ADMPT_CANJEDT_KARDEXFIJA KF
    WHERE KF.ADMPV_ID_CANJE = IDCANJE
          AND KF.ADMPV_ID_CANJESEC = IDCANJE_SEC;
  
  V_COD_CLI          PCLUB.ADMPT_CLIENTEFIJA.ADMPV_COD_CLI%TYPE;
  V_COD_CLI_PROD     PCLUB.ADMPT_CLIENTEPRODUCTO.ADMPV_COD_CLI_PROD%TYPE;
  V_TPO_CLI          PCLUB.ADMPT_CLIENTEFIJA.ADMPV_COD_TPOCL%TYPE;
  
  V_CANJ_COD_CLI     PCLUB.ADMPT_CANJEFIJA.ADMPV_COD_CLI%TYPE;
  V_CANJ_COD_CLIPROD PCLUB.ADMPT_CANJEFIJA.ADMPV_COD_CLI_PROD%TYPE;
  V_CANJ_NUM_DOC     PCLUB.ADMPT_CANJEFIJA.ADMPV_NUM_DOC%TYPE;
  V_CANJ_TIP_CLI     PCLUB.ADMPT_CANJEFIJA.ADMPV_COD_TPOCL%TYPE;
  
  V_COD_CPTO         PCLUB.ADMPT_CONCEPTO.ADMPV_COD_CPTO%TYPE;
  
  V_COD_CLIIB        PCLUB.ADMPT_KARDEXFIJA.ADMPN_COD_CLI_IB%TYPE;
  V_TIP_PTO          PCLUB.ADMPT_KARDEXFIJA.ADMPC_TPO_PUNTO%TYPE;
  
  V_CANJ_DET_EST     CHAR(1);
  
  C_CANJE_KARDEX_IDKARDEX NUMBER;
  C_CANJE_KARDEX_PUNTOS   NUMBER;
  
  V_ID_CANJE     NUMBER;
  V_ID_KARDEX    NUMBER;
  V_TIPO_CLI     VARCHAR2(4);
  V_TOTALPUNTOS  NUMBER := 0;
  V_AUX_ID_CANJE NUMBER;
  V_FLAG_SALDO   NUMBER;
  
  V_ID_PROCLA   PCLUB.ADMPT_CANJE_DETALLEFIJA.ADMPV_ID_PROCLA%TYPE;
  V_PRO_DESC    PCLUB.ADMPT_CANJE_DETALLEFIJA.ADMPV_DESC%TYPE;
  V_NOM_CAMP    PCLUB.ADMPT_CANJE_DETALLEFIJA.ADMPV_NOM_CAMP%TYPE;
  V_PUNTOS      PCLUB.ADMPT_CANJE_DETALLEFIJA.ADMPN_PUNTOS%TYPE;
  V_PAGO        PCLUB.ADMPT_CANJE_DETALLEFIJA.ADMPN_PAGO%TYPE;
  V_CANTIDAD    PCLUB.ADMPT_CANJE_DETALLEFIJA.ADMPN_CANTIDAD%TYPE;
  V_COD_TIP_PR  PCLUB.ADMPT_CANJE_DETALLEFIJA.ADMPV_COD_TPOPR%TYPE;
  V_COD_SERV    PCLUB.ADMPT_CANJE_DETALLEFIJA.ADMPN_COD_SERVC%TYPE;
  V_MNT_RECAR   PCLUB.ADMPT_CANJE_DETALLEFIJA.ADMPN_MNT_RECAR%TYPE;
  V_COD_PAQDAT  PCLUB.ADMPT_CANJE_DETALLEFIJA.ADMPV_COD_PAQDAT%TYPE;
  V_CODTXPAQDAT PCLUB.ADMPT_CANJE_DETALLEFIJA.ADMPV_CODTXPAQDAT%TYPE;
  
  NO_DEVOLUCION EXCEPTION;
  IN_ERROR EXCEPTION;
BEGIN
  
  IF K_LISTA_DEV.COUNT = 0 THEN
      K_CODERROR := 45;
      K_DESCERROR := 'La lista de devolución esta vacìa';
      RAISE IN_ERROR;
  END IF;
  
  V_AUX_ID_CANJE := 0;
  V_FLAG_SALDO := 0;
  
  FOR i IN K_LISTA_DEV.FIRST .. K_LISTA_DEV.LAST LOOP
      V_DEVOLUCION := K_LISTA_DEV(i);
      
      IF V_AUX_ID_CANJE != V_DEVOLUCION.ID_CANJE THEN
      
        IF V_FLAG_SALDO != 0 THEN
          -- se elimina la cabecera del canje si no se devolvio CERO puntos
          IF V_TOTALPUNTOS = 0 THEN
            DELETE FROM PCLUB.ADMPT_CANJEFIJA 
            WHERE ADMPV_ID_CANJE = V_ID_CANJE;
            
            RAISE NO_DEVOLUCION;
          ELSE
            -- Obtenemos los codigos del cliente y tipo de cliente
            SELECT CF.ADMPV_COD_CLI,NVL(CF.ADMPV_COD_TPOCL, '')
                   INTO V_COD_CLI, V_TIPO_CLI
            FROM PCLUB.ADMPT_CANJEFIJA CF
            WHERE CF.ADMPV_ID_CANJE = V_DEVOLUCION.ID_CANJE;
            
            SELECT KF.ADMPV_COD_CLI_PROD INTO V_COD_CLI_PROD 
            FROM PCLUB.ADMPT_KARDEXFIJA KF
            WHERE KF.ADMPV_ID_CANJE=V_DEVOLUCION.ID_CANJE;
            
            -- Obtenemos el concepto de devolucion
            SELECT C.ADMPV_COD_CPTO INTO V_COD_CPTO
            FROM  PCLUB.ADMPT_CONCEPTO C
            WHERE C.ADMPV_DESC = 'DEVOLUCION CANJE VENTA'
                  AND C.ADMPC_ESTADO = 'A';
            
            SELECT NVL(ADMPT_KARDEXFIJA_SQ.NEXTVAL, '-1') INTO V_ID_KARDEX
            FROM DUAL;
            
            -- Inserta registro en Kardex por la suma de los puntos devueltos
            INSERT INTO PCLUB.ADMPT_KARDEXFIJA(ADMPN_ID_KARDEX, ADMPN_COD_CLI_IB,
                                         ADMPV_COD_CLI_PROD, ADMPV_COD_CPTO,
                                         ADMPD_FEC_TRANS, ADMPN_PUNTOS,
                                         ADMPV_NOM_ARCH, ADMPC_TPO_OPER,
                                         ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO,
                                         ADMPC_ESTADO,ADMPV_USU_REG)
            VALUES (V_ID_KARDEX, '',
                    V_COD_CLI_PROD, V_COD_CPTO,
                    TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY'), V_TOTALPUNTOS,
                    NULL, 'E',
                    'C', 0, 
                    'C',K_USUARIO);
            -- en el campo saldo deberia ser igual a la cantidad que esta ingresando
            UPDATE PCLUB.ADMPT_CANJEFIJA 
            SET ADMPN_ID_KARDEX = V_ID_KARDEX,
            ADMPV_USU_MOD=K_USUARIO
            WHERE ADMPV_ID_CANJE = V_ID_CANJE;
            
          END IF;
          
          V_TOTALPUNTOS := 0;
        END IF; -- FIN V_FLAG_SALDO
        
        V_FLAG_SALDO   := 1;
        V_AUX_ID_CANJE := V_DEVOLUCION.ID_CANJE;
      
        SELECT NVL(ADMPT_CANJEFIJA_SQ.NEXTVAL, '-1') INTO V_ID_CANJE 
        FROM DUAL;
        
        SELECT CF.ADMPV_COD_CLI, CF.ADMPV_COD_CLI_PROD,
               CF.ADMPV_NUM_DOC, CF.ADMPV_COD_TPOCL  
               INTO V_CANJ_COD_CLI, V_CANJ_COD_CLIPROD,
                    V_CANJ_NUM_DOC, V_CANJ_TIP_CLI 
        FROM PCLUB.ADMPT_CANJEFIJA CF
        WHERE CF.ADMPV_ID_CANJE = V_DEVOLUCION.ID_CANJE;
        
        -- Inserta un registro en Canje por la devolución
        INSERT INTO PCLUB.ADMPT_CANJEFIJA (ADMPV_ID_CANJE,ADMPV_COD_CLI, ADMPV_COD_CLI_PROD,
                                     ADMPV_PTO_VENTA,
                                     ADMPD_FEC_CANJE, 
                                     ADMPV_HRA_CANJE,
                                     ADMPV_NUM_DOC,ADMPV_COD_TPOCL,
                                     ADMPV_COD_ASESO, ADMPV_NOM_ASESO,
                                     ADMPC_TPO_OPER, ADMPN_ID_KARDEX,
                                     ADMPV_DEV_IDCANJE,ADMPV_USU_REG)
        VALUES (V_ID_CANJE, V_CANJ_COD_CLI,V_CANJ_COD_CLIPROD,
                K_PUNTOVENTA,
                TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'), 
                TO_CHAR(SYSDATE, 'HH:MI AM'),
                V_CANJ_NUM_DOC, V_CANJ_TIP_CLI,
                '', '',
                'D', '',
                V_DEVOLUCION.id_canje,K_USUARIO); 
      END IF; -- FIN V_AUX_ID_CANJE != V_DEVOLUCION.ID_CANJE
      
      -- Verifica el estado del ITEM que se desea devolver
      SELECT DF.ADMPC_ESTADO INTO V_CANJ_DET_EST
      FROM  PCLUB.ADMPT_CANJE_DETALLEFIJA DF
      WHERE DF.ADMPV_ID_CANJE = V_DEVOLUCION.id_canje
            AND DF.ADMPV_ID_CANJESEC = V_DEVOLUCION.ID_CANJESEC;
    
      IF V_CANJ_DET_EST = 'C' THEN
        -- si el tipo de operacion es 'D' es por q ya fue devuelto anteriormente
        OPEN CANJE_KARDEX(V_DEVOLUCION.id_canje, V_DEVOLUCION.ID_CANJESEC);
        
        FETCH CANJE_KARDEX INTO C_CANJE_KARDEX_IDKARDEX, C_CANJE_KARDEX_PUNTOS;
        
        WHILE CANJE_KARDEX%FOUND LOOP
          -- devuelve los puntos al kardex
          UPDATE PCLUB.ADMPT_KARDEXFIJA
          SET ADMPC_ESTADO = 'A',
              ADMPV_USU_MOD=K_USUARIO,
              ADMPN_SLD_PUNTO = C_CANJE_KARDEX_PUNTOS +
                                (SELECT NVL(KF2.ADMPN_SLD_PUNTO, 0)
                                FROM  PCLUB.ADMPT_KARDEXFIJA KF2
                                WHERE KF2.ADMPN_ID_KARDEX = C_CANJE_KARDEX_IDKARDEX)
          WHERE ADMPN_ID_KARDEX = C_CANJE_KARDEX_IDKARDEX;
        
          -- devuelve los puntos al saldo_cliente 
          SELECT NVL(KF.ADMPN_COD_CLI_IB, 0), 
                 NVL(KF.ADMPV_COD_CLI_PROD, ''),
                 NVL(KF.ADMPC_TPO_PUNTO, '') 
                 INTO V_COD_CLIIB, V_COD_CLI_PROD, V_TIP_PTO
          FROM PCLUB.ADMPT_KARDEXFIJA KF
          WHERE KF.ADMPN_ID_KARDEX = C_CANJE_KARDEX_IDKARDEX;
        
          IF V_TIP_PTO = 'C' OR V_TIP_PTO = 'L' THEN
            -- actualizamos el saldo de puntos CC
            UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
            SET ADMPN_SALDO_CC = C_CANJE_KARDEX_PUNTOS +
                                 (SELECT NVL(CF2.ADMPN_SALDO_CC, 0)
                                  FROM PCLUB.ADMPT_SALDOS_CLIENTEFIJA CF2
                                  WHERE CF2.ADMPV_COD_CLI_PROD = V_COD_CLI_PROD), 
                ADMPC_ESTPTO_CC = 'A',
                ADMPV_USU_MOD=K_USUARIO
             WHERE ADMPV_COD_CLI_PROD = V_COD_CLI_PROD; 
             
          ELSIF V_TIP_PTO = 'I' THEN
             -- actualizamos el saldo de los punto IBK
             UPDATE PCLUB.ADMPT_SALDOS_CLIENTEFIJA
             SET ADMPN_SALDO_IB = C_CANJE_KARDEX_PUNTOS +
                                   (SELECT NVL(CF2.ADMPN_SALDO_IB, 0)
                                    FROM PCLUB.ADMPT_SALDOS_CLIENTEFIJA CF2
                                    WHERE CF2.ADMPV_COD_CLI_PROD = V_COD_CLI_PROD
                                          AND CF2.ADMPN_COD_CLI_IB = V_COD_CLIIB),
                 ADMPC_ESTPTO_IB = 'A',
                 ADMPV_USU_MOD=K_USUARIO
             WHERE ADMPV_COD_CLI_PROD = V_COD_CLI_PROD
                   AND ADMPN_COD_CLI_IB = V_COD_CLIIB;
          END IF;
          
          V_TOTALPUNTOS := V_TOTALPUNTOS + C_CANJE_KARDEX_PUNTOS;

          FETCH CANJE_KARDEX INTO C_CANJE_KARDEX_IDKARDEX, C_CANJE_KARDEX_PUNTOS;
        END LOOP;
      
        -- Cambia el estado a 'D' Devuelto, al item en Canje Detalle
        UPDATE PCLUB.ADMPT_CANJE_DETALLEFIJA
        SET ADMPC_ESTADO = 'D',
        ADMPV_USU_MOD=K_USUARIO
        WHERE ADMPV_ID_CANJE = V_DEVOLUCION.id_canje
              AND ADMPV_ID_CANJESEC = V_DEVOLUCION.ID_CANJESEC;
      
        /* obtenemos los datos del detalle de la devolucion en canje detalle*/
        SELECT CDF.ADMPV_ID_PROCLA,
               CDF.ADMPV_DESC,
               CDF.ADMPV_NOM_CAMP,
               CDF.ADMPN_PUNTOS,
               CDF.ADMPN_PAGO,
               CDF.ADMPN_CANTIDAD,
               CDF.ADMPV_COD_TPOPR,
               CDF.ADMPN_COD_SERVC,
               CDF.ADMPN_MNT_RECAR,
               CDF.ADMPV_COD_PAQDAT,
               CDF.ADMPV_CODTXPAQDAT
        INTO V_ID_PROCLA,
             V_PRO_DESC,
             V_NOM_CAMP,
             V_PUNTOS,
             V_PAGO,
             V_CANTIDAD,
             V_COD_TIP_PR,
             V_COD_SERV,
             V_MNT_RECAR,
             V_COD_PAQDAT,
             V_CODTXPAQDAT
        FROM PCLUB.ADMPT_CANJE_DETALLEFIJA CDF
        WHERE CDF.ADMPV_ID_CANJE = V_DEVOLUCION.id_canje
              AND CDF.ADMPV_ID_CANJESEC = V_DEVOLUCION.ID_CANJESEC;
        
        -- Insertamos en la tabla canje detalle
        INSERT INTO PCLUB.ADMPT_CANJE_DETALLEFIJA(ADMPV_ID_CANJE,ADMPV_ID_CANJESEC,
                                            ADMPV_ID_PROCLA,ADMPV_DESC,
                                            ADMPV_NOM_CAMP,ADMPN_PUNTOS,
                                            ADMPN_PAGO,ADMPN_CANTIDAD,
                                            ADMPV_COD_TPOPR,ADMPN_COD_SERVC,
                                            ADMPN_MNT_RECAR,ADMPC_ESTADO,
                                            ADMPV_COD_PAQDAT, ADMPV_CODTXPAQDAT,ADMPV_USU_REG)
        VALUES
          (V_ID_CANJE, V_DEVOLUCION.ID_CANJESEC,
           V_ID_PROCLA, V_PRO_DESC,
           V_NOM_CAMP, V_PUNTOS,
           V_PAGO, V_CANTIDAD,
           V_COD_TIP_PR, V_COD_SERV,
           V_MNT_RECAR, 'D',
           V_COD_PAQDAT, V_CODTXPAQDAT,K_USUARIO);
      
        CLOSE CANJE_KARDEX;
      END IF;
    END LOOP;
  
    -- se elimina la cabecera del canje si no se devolvio CERO puntos
    IF V_TOTALPUNTOS = 0 AND V_ID_PROCLA != 'BONRENESPE' AND
       K_LISTA_DEV.COUNT != 1 THEN
      DELETE FROM PCLUB.admpt_canje 
      WHERE admpv_id_canje = V_ID_CANJE;
      
      RAISE NO_DEVOLUCION;
    ELSE
      -- obtenemos los datos para insertar en kardex
      SELECT CF.ADMPV_COD_CLI, NVL(CF.ADMPV_COD_TPOCL, '')
             INTO V_COD_CLI, V_TIPO_CLI
      FROM PCLUB.ADMPT_CANJEFIJA CF
      WHERE ADMPV_ID_CANJE = V_ID_CANJE;                 
      
      SELECT KF.ADMPV_COD_CLI_PROD INTO V_COD_CLI_PROD 
      FROM PCLUB.ADMPT_KARDEXFIJA KF
      WHERE KF.ADMPN_ID_KARDEX=C_CANJE_KARDEX_IDKARDEX;
      
      SELECT C.ADMPV_COD_CPTO INTO V_COD_CPTO
      FROM  PCLUB.ADMPT_CONCEPTO C
      WHERE C.ADMPV_DESC = 'DEVOLUCION CANJE VENTA'
            AND C.ADMPC_ESTADO = 'A';
      
      SELECT NVL(ADMPT_KARDEXFIJA_SQ.NEXTVAL, '-1') INTO V_ID_KARDEX
      FROM DUAL;
    
      -- Inserta registro en Kardex por la suma de los puntos devueltos
      INSERT INTO PCLUB.ADMPT_KARDEXFIJA(ADMPN_ID_KARDEX,ADMPN_COD_CLI_IB,
                                   ADMPV_COD_CLI_PROD,ADMPV_COD_CPTO,
                                   ADMPD_FEC_TRANS,ADMPN_PUNTOS,
                                   ADMPV_NOM_ARCH,ADMPC_TPO_OPER,
                                   ADMPC_TPO_PUNTO,ADMPN_SLD_PUNTO,
                                   ADMPC_ESTADO,ADMPV_USU_REG)
      VALUES(V_ID_KARDEX,'',
             V_COD_CLI_PROD, V_COD_CPTO,
             TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
             V_TOTALPUNTOS, NULL,
             'E', 'C',
             0, 'C',K_USUARIO);
    
      UPDATE PCLUB.ADMPT_CANJEFIJA
      SET ADMPN_ID_KARDEX = V_ID_KARDEX,
      ADMPV_USU_MOD=K_USUARIO
      WHERE ADMPV_ID_CANJE = V_ID_CANJE;
            
    END IF;
  
    /** saldo **/
    SELECT CF.ADMPV_COD_TPOCL INTO V_TPO_CLI
    FROM PCLUB.ADMPT_CLIENTEFIJA CF
    WHERE CF.ADMPV_COD_CLI = V_CANJ_COD_CLI;
      
    K_CODERROR := 0;
    K_DESCERROR := '';
    
EXCEPTION
  WHEN NO_DEVOLUCION THEN
      K_CODERROR := 53;
      K_DESCERROR := 'No se realizo la devolucion porque los productos ya fueron devueltos.';
    
  WHEN IN_ERROR THEN
    BEGIN
      SELECT ADMPV_DES_ERROR || K_DESCERROR INTO K_DESCERROR
      FROM PCLUB.ADMPT_ERRORES_CC
      WHERE ADMPN_COD_ERROR = K_CODERROR;
    END;
    
  WHEN OTHERS THEN
    K_CODERROR := 1;
    K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
    
END ADMPSS_DEVPUNTS_FIJA;

END PKG_CC_TRANSACCIONFIJA;
/
