create or replace package body PCLUB.PKG_PORTALES_CLARO is

PROCEDURE ADMPSI_ESTADOCTACC(K_TIPODOC IN VARCHAR2,
                              K_NRODOC IN VARCHAR2,
                              K_FECHAINI IN DATE,
                              K_FECHAFIN IN DATE,
                              CURSORESTADOCTA OUT SYS_REFCURSOR,
                              K_CODERROR  OUT NUMBER,
                              K_DESCERROR OUT VARCHAR2) IS

 -- P_TIPOCLIENTE VARCHAR(20);

  BEGIN

  --  IF K_TIPOCLIENTE='2' THEN
       OPEN CURSORESTADOCTA FOR
       --MOVIMIENTO
          SELECT /*+ STAR_TRANSFORMATION */ K.ADMPV_COD_CLI AS CODCLIENTE,'' AS SERVICIO,CO.ADMPV_DESC AS CONCEPTO,
          --K.ADMPN_PUNTOS AS PUNTOS,
          DECODE(SIGN(NVL(K.ADMPN_PUNTOS,0)),-1, NVL(K.ADMPN_PUNTOS,0)*-1,NVL(K.ADMPN_PUNTOS,0)) AS PUNTOS,
          CASE K.ADMPC_TPO_PUNTO WHEN 'C' THEN 'CLARO' WHEN 'I' THEN 'INTERBANK' ELSE 'CLARO' END AS TIPOPUNTO,
          CASE K.ADMPC_TPO_OPER WHEN 'E' THEN 'ENTRADA' ELSE 'SALIDA' END  AS TIPOOPER,
          K.ADMPD_FEC_TRANS AS FECHAASIG,
          DECODE(K.ADMPC_TPO_OPER,'E',ADD_MONTHS(K.ADMPD_FEC_TRANS,18),NULL) AS FECHA_VIG
          FROM ADMPT_CLIENTE C
          --INNER JOIN ADMPT_KARDEX K
      INNER JOIN VIEW_ADMPT_KARDEX K
          ON C.ADMPV_COD_CLI=K.ADMPV_COD_CLI
          INNER JOIN ADMPT_CONCEPTO CO
          ON K.ADMPV_COD_CPTO=CO.ADMPV_COD_CPTO
          WHERE C.ADMPV_TIPO_DOC=K_TIPODOC AND C.ADMPV_NUM_DOC=K_NRODOC
          AND C.ADMPV_COD_TPOCL IN  (1,2)
          --AND C.ADMPC_ESTADO='A'
          AND K.ADMPV_COD_CPTO <>'14'
          AND K.ADMPV_COD_CPTO <>'15'
          AND K.ADMPV_COD_CPTO <>'7'
          AND K.ADMPV_COD_CPTO <>'11'
          AND K.ADMPV_COD_CPTO <>'12'
          AND K.ADMPV_COD_CPTO <>'13'
          AND K.ADMPV_COD_CPTO <>'26'
          AND K.ADMPV_COD_CPTO <>'82'
          AND K.ADMPD_FEC_TRANS>=K_FECHAINI
          AND K.ADMPD_FEC_TRANS<K_FECHAFIN+1

          UNION ALL 
          -- CANJE

          SELECT /*+ STAR_TRANSFORMATION */ CODCLIENTE,'' AS SERVICIO,CONCEPTO,
          --SUM(PUNTOS) AS PUNTOS,
          DECODE(SIGN(NVL(SUM(PUNTOS),0)),-1, NVL(SUM(PUNTOS),0)*-1,NVL(SUM(PUNTOS),0)) AS PUNTOS,
          TIPOPUNTO,
          TIPOOPER,
          FECHAASIG,
          FECHA_VIG
          FROM
          (SELECT CA.ADMPV_ID_CANJE,C.ADMPV_COD_CLI AS CODCLIENTE,'CANJE' AS CONCEPTO,
                    CK.ADMPN_PUNTOS AS PUNTOS,
                    CASE K.ADMPC_TPO_PUNTO WHEN 'C' THEN 'CLARO' WHEN 'I' THEN 'INTERBANK' ELSE 'CLARO' END AS TIPOPUNTO,
                    'SALIDA' AS TIPOOPER,
                    CA.ADMPD_FEC_CANJE AS FECHAASIG,
                    NULL AS FECHA_VIG
          FROM ADMPT_CANJE CA
          INNER JOIN ADMPT_CLIENTE C
          ON CA.ADMPV_COD_CLI=C.ADMPV_COD_CLI
          INNER JOIN ADMPT_CANJEDT_KARDEX CK
          ON CA.ADMPV_ID_CANJE=CK.ADMPV_ID_CANJE
          --INNER JOIN ADMPT_KARDEX K
      INNER JOIN VIEW_ADMPT_KARDEX K
          ON CK.ADMPN_ID_KARDEX=K.ADMPN_ID_KARDEX
          WHERE C.ADMPV_COD_TPOCL IN (1,2)
          AND C.ADMPV_TIPO_DOC=K_TIPODOC
          AND C.ADMPV_NUM_DOC=K_NRODOC
          --AND C.ADMPC_ESTADO='A'
          AND CA.ADMPC_TPO_OPER='C'
          AND CA.ADMPD_FEC_CANJE>=K_FECHAINI
          AND CA.ADMPD_FEC_CANJE<=K_FECHAFIN
          )
         
          GROUP BY ADMPV_ID_CANJE,CODCLIENTE,CONCEPTO,TIPOPUNTO,TIPOOPER,FECHAASIG,FECHA_VIG
          
          UNION ALL
--DEVOLUCION

          SELECT /*+ STAR_TRANSFORMATION */ CODCLIENTE,'' AS SERVICIO,CONCEPTO,
          --SUM(PUNTOS) AS PUNTOS,
           DECODE(SIGN(NVL(SUM(PUNTOS),0)),-1, NVL(SUM(PUNTOS),0)*-1,NVL(SUM(PUNTOS),0)) AS PUNTOS,
           TIPOPUNTO,TIPOOPER,FECHAASIG,FECHA_VIG FROM
          (
          SELECT DEV.ADMPV_ID_CANJE,
          C.ADMPV_COD_CLI AS CODCLIENTE, 'DEVOLUCION' AS CONCEPTO ,
                    CK.ADMPN_PUNTOS AS PUNTOS,
                    CASE K.ADMPC_TPO_PUNTO WHEN 'C' THEN 'CLARO' WHEN 'I' THEN 'INTERBANK' ELSE 'CLARO' END AS TIPOPUNTO,
                    'ENTRADA' AS TIPOOPER,
                    CA.ADMPD_FEC_CANJE AS FECHAASIG,
                    NULL AS FECHA_VIG
          FROM ADMPT_CANJE CA
          INNER JOIN ADMPT_CLIENTE C
          ON CA.ADMPV_COD_CLI=C.ADMPV_COD_CLI
          INNER JOIN ADMPT_CANJE DEV
          ON CA.ADMPV_DEV_IDCANJE=DEV.ADMPV_ID_CANJE
          INNER JOIN ADMPT_CANJEDT_KARDEX CK
          ON DEV.ADMPV_ID_CANJE=CK.ADMPV_ID_CANJE
          --INNER JOIN ADMPT_KARDEX K
      INNER JOIN VIEW_ADMPT_KARDEX K
          ON CK.ADMPN_ID_KARDEX=K.ADMPN_ID_KARDEX
          WHERE C.ADMPV_COD_TPOCL IN (1,2)
          AND C.ADMPV_TIPO_DOC=K_TIPODOC
          AND C.ADMPV_NUM_DOC=K_NRODOC
          --AND C.ADMPC_ESTADO='A'
          AND CA.ADMPC_TPO_OPER='D'
          AND CA.ADMPD_FEC_CANJE>=K_FECHAINI
          AND CA.ADMPD_FEC_CANJE<=K_FECHAFIN
          )
          GROUP BY ADMPV_ID_CANJE,CODCLIENTE,CONCEPTO,TIPOPUNTO,TIPOOPER,FECHAASIG,FECHA_VIG

          UNION ALL

          SELECT /*+ STAR_TRANSFORMATION */ K.ADMPV_COD_CLI AS CODCLIENTE, '' AS SERVICIO,'PRONTO PAGO' AS CONCEPTO,
          --SUM(K.ADMPN_PUNTOS) AS PUNTOS,
           DECODE(SIGN(NVL(SUM(K.ADMPN_PUNTOS),0)),-1, NVL(SUM(K.ADMPN_PUNTOS),0)*-1,NVL(SUM(K.ADMPN_PUNTOS),0)) AS PUNTOS,
          'CLARO' AS TIPOPTO,
          'ENTRADA' AS TIPOOPER,
          K.ADMPD_FEC_TRANS AS FECHAASIG,
          ADD_MONTHS(K.ADMPD_FEC_TRANS,18) AS FECHA_VIG
          FROM ADMPT_CLIENTE C
          --INNER JOIN ADMPT_KARDEX K
      INNER JOIN VIEW_ADMPT_KARDEX K
          ON C.ADMPV_COD_CLI=K.ADMPV_COD_CLI
          WHERE  C.ADMPV_TIPO_DOC=K_TIPODOC AND C.ADMPV_NUM_DOC=K_NRODOC
          AND C.ADMPV_COD_TPOCL IN (1,2)
          --AND C.ADMPC_ESTADO='A'
          AND K.ADMPV_COD_CPTO IN ('7','11')
           AND K.ADMPD_FEC_TRANS>=K_FECHAINI
          AND K.ADMPD_FEC_TRANS< K_FECHAFIN +1
          GROUP BY K.ADMPV_COD_CLI ,K.ADMPD_FEC_TRANS

          UNION ALL

          SELECT /*+ STAR_TRANSFORMATION */ K.ADMPV_COD_CLI AS CODCLIENTE, '' AS SERVICIO,'FACTURACION' AS CONCEPTO,
          --SUM(K.ADMPN_PUNTOS) AS PUNTOS,
           DECODE(SIGN(NVL(SUM(K.ADMPN_PUNTOS),0)),-1, NVL(SUM(K.ADMPN_PUNTOS),0)*-1,NVL(SUM(K.ADMPN_PUNTOS),0)) AS PUNTOS,
          'CLARO' AS TIPOPTO,
          'ENTRADA' AS TIPOOPER,
          K.ADMPD_FEC_TRANS AS FECHAASIG,
          ADD_MONTHS(K.ADMPD_FEC_TRANS,18) AS FECHA_VIG
          FROM ADMPT_CLIENTE C
          --INNER JOIN ADMPT_KARDEX K
      INNER JOIN VIEW_ADMPT_KARDEX K
          ON C.ADMPV_COD_CLI=K.ADMPV_COD_CLI
          WHERE  C.ADMPV_TIPO_DOC=K_TIPODOC AND C.ADMPV_NUM_DOC=K_NRODOC
          AND C.ADMPV_COD_TPOCL IN (1,2)
          --AND C.ADMPC_ESTADO='A'
          AND K.ADMPV_COD_CPTO IN ('12','13','26')
           AND K.ADMPD_FEC_TRANS>=K_FECHAINI
          AND K.ADMPD_FEC_TRANS< K_FECHAFIN +1
          GROUP BY K.ADMPV_COD_CLI ,K.ADMPD_FEC_TRANS

      --    ORDER BY FECHAASIG DESC, CONCEPTO ASC

    --   ELSIF K_TIPOCLIENTE='3' THEN
      --    OPEN CURSORESTADOCTA FOR
--MOVIMIENTO
UNION ALL
          SELECT /*+ STAR_TRANSFORMATION */ K.ADMPV_COD_CLI AS CODCLIENTE,'' AS SERVICIO,CO.ADMPV_DESC AS CONCEPTO,
          --K.ADMPN_PUNTOS AS PUNTOS,
          DECODE(SIGN(NVL(K.ADMPN_PUNTOS,0)),-1, NVL(K.ADMPN_PUNTOS,0)*-1,NVL(K.ADMPN_PUNTOS,0)) AS PUNTOS,
          CASE K.ADMPC_TPO_PUNTO WHEN 'C' THEN 'CLARO' WHEN 'B' THEN 'BONO' WHEN 'I' THEN 'INTERBANK' ELSE 'CLARO' END AS TIPOPUNTO,
          CASE K.ADMPC_TPO_OPER WHEN 'E' THEN 'ENTRADA' ELSE 'SALIDA' END  AS TIPOOPER,
          K.ADMPD_FEC_TRANS AS FECHAASIG,
          --DECODE(K.ADMPC_TPO_OPER,'E',ADD_MONTHS(K.ADMPD_FEC_TRANS,18),NULL) AS FECHA_VIG
          CASE K.ADMPC_TPO_PUNTO WHEN 'B' THEN K.ADMPD_FEC_VCMTO ELSE DECODE(K.ADMPC_TPO_OPER,'E',ADD_MONTHS(K.ADMPD_FEC_TRANS,18),NULL) END AS FECHA_VIG
          FROM ADMPT_CLIENTE C
          --INNER JOIN ADMPT_KARDEX K
      INNER JOIN VIEW_ADMPT_KARDEX K
          ON C.ADMPV_COD_CLI=K.ADMPV_COD_CLI
          INNER JOIN ADMPT_CONCEPTO CO
          ON K.ADMPV_COD_CPTO=CO.ADMPV_COD_CPTO
          WHERE C.ADMPV_TIPO_DOC=K_TIPODOC AND C.ADMPV_NUM_DOC=K_NRODOC
          AND C.ADMPV_COD_TPOCL='3'
          --AND C.ADMPC_ESTADO='A'
          AND K.ADMPV_COD_CPTO <>'14'
          AND K.ADMPV_COD_CPTO <>'15'
          AND K.ADMPV_COD_CPTO <>'7'
          AND K.ADMPV_COD_CPTO <>'11'
          AND K.ADMPV_COD_CPTO <>'12'
          AND K.ADMPV_COD_CPTO <>'13'
          AND K.ADMPV_COD_CPTO <>'26'
          AND K.ADMPV_COD_CPTO <>'82'
          AND K.ADMPD_FEC_TRANS>=K_FECHAINI
          AND K.ADMPD_FEC_TRANS< K_FECHAFIN+1

          UNION ALL
  -- CANJE

          SELECT /*+ STAR_TRANSFORMATION */ CODCLIENTE,'' AS SERVICIO,CONCEPTO,
          --SUM(PUNTOS) AS PUNTOS,
          DECODE(SIGN(NVL(SUM(PUNTOS),0)),-1, NVL(SUM(PUNTOS),0)*-1,NVL(SUM(PUNTOS),0)) AS PUNTOS,
          TIPOPUNTO,
          TIPOOPER,
          FECHAASIG,
          FECHA_VIG
          FROM
          (SELECT CA.ADMPV_ID_CANJE,C.ADMPV_COD_CLI AS CODCLIENTE,'CANJE' AS CONCEPTO,
                    CK.ADMPN_PUNTOS AS PUNTOS,
                    CASE K.ADMPC_TPO_PUNTO WHEN 'C' THEN 'CLARO' WHEN 'I' THEN 'INTERBANK' ELSE 'CLARO' END AS TIPOPUNTO,
                    'SALIDA' AS TIPOOPER,
                    CA.ADMPD_FEC_CANJE AS FECHAASIG,
                    NULL AS FECHA_VIG
          FROM ADMPT_CANJE CA
          INNER JOIN ADMPT_CLIENTE C
          ON CA.ADMPV_COD_CLI=C.ADMPV_COD_CLI
          INNER JOIN ADMPT_CANJEDT_KARDEX CK
          ON CA.ADMPV_ID_CANJE=CK.ADMPV_ID_CANJE
          --INNER JOIN ADMPT_KARDEX K
      INNER JOIN VIEW_ADMPT_KARDEX K
          ON CK.ADMPN_ID_KARDEX=K.ADMPN_ID_KARDEX
          WHERE C.ADMPV_COD_TPOCL='3'
          AND C.ADMPV_TIPO_DOC=K_TIPODOC
          AND C.ADMPV_NUM_DOC=K_NRODOC
          --AND C.ADMPC_ESTADO='A'
          AND CA.ADMPC_TPO_OPER='C'
          AND CA.ADMPD_FEC_CANJE>=K_FECHAINI
          AND CA.ADMPD_FEC_CANJE<=K_FECHAFIN
          )
GROUP BY ADMPV_ID_CANJE,CODCLIENTE,CONCEPTO,TIPOPUNTO,TIPOOPER,FECHAASIG,FECHA_VIG

          UNION ALL
--DEVOLUCION

          SELECT /*+ STAR_TRANSFORMATION */ CODCLIENTE,'' AS SERVICIO,CONCEPTO,
          --SUM(PUNTOS) AS PUNTOS,
           DECODE(SIGN(NVL(SUM(PUNTOS),0)),-1, NVL(SUM(PUNTOS),0)*-1,NVL(SUM(PUNTOS),0)) AS PUNTOS,
           TIPOPUNTO,TIPOOPER,FECHAASIG,FECHA_VIG FROM
          (
          SELECT DEV.ADMPV_ID_CANJE,
          C.ADMPV_COD_CLI AS CODCLIENTE, 'DEVOLUCION' AS CONCEPTO ,
                    CK.ADMPN_PUNTOS AS PUNTOS,
                    CASE K.ADMPC_TPO_PUNTO WHEN 'C' THEN 'CLARO' WHEN 'I' THEN 'INTERBANK' ELSE 'CLARO' END AS TIPOPUNTO,
                    'ENTRADA' AS TIPOOPER,
                    CA.ADMPD_FEC_CANJE AS FECHAASIG,
                    NULL AS FECHA_VIG
          FROM ADMPT_CANJE CA
          INNER JOIN ADMPT_CLIENTE C
          ON CA.ADMPV_COD_CLI=C.ADMPV_COD_CLI
          INNER JOIN ADMPT_CANJE DEV
          ON CA.ADMPV_DEV_IDCANJE=DEV.ADMPV_ID_CANJE
          INNER JOIN ADMPT_CANJEDT_KARDEX CK
          ON DEV.ADMPV_ID_CANJE=CK.ADMPV_ID_CANJE
          --INNER JOIN ADMPT_KARDEX K
      INNER JOIN VIEW_ADMPT_KARDEX K
          ON CK.ADMPN_ID_KARDEX=K.ADMPN_ID_KARDEX
          WHERE C.ADMPV_COD_TPOCL='3'
          AND C.ADMPV_TIPO_DOC=K_TIPODOC
          AND C.ADMPV_NUM_DOC=K_NRODOC
          --AND C.ADMPC_ESTADO='A'
          AND CA.ADMPC_TPO_OPER='D'
          AND CA.ADMPD_FEC_CANJE>=K_FECHAINI
          AND CA.ADMPD_FEC_CANJE<=K_FECHAFIN
          )
          GROUP BY ADMPV_ID_CANJE,CODCLIENTE,CONCEPTO,TIPOPUNTO,TIPOOPER,FECHAASIG,FECHA_VIG

          UNION ALL

          SELECT /*+ STAR_TRANSFORMATION */ K.ADMPV_COD_CLI AS CODCLIENTE,'' AS SERVICIO, 'PRONTO PAGO' AS CONCEPTO,
          --SUM(K.ADMPN_PUNTOS) AS PUNTOS,
           DECODE(SIGN(NVL(SUM(K.ADMPN_PUNTOS),0)),-1, NVL(SUM(K.ADMPN_PUNTOS),0)*-1,NVL(SUM(K.ADMPN_PUNTOS),0)) AS PUNTOS,
          'CLARO' AS TIPOPTO,
          'ENTRADA' AS TIPOOPER,
          K.ADMPD_FEC_TRANS AS FECHAASIG,
          ADD_MONTHS(K.ADMPD_FEC_TRANS,18) AS FECHA_VIG
          FROM ADMPT_CLIENTE C
          --INNER JOIN ADMPT_KARDEX K
      INNER JOIN VIEW_ADMPT_KARDEX K
          ON C.ADMPV_COD_CLI=K.ADMPV_COD_CLI
          WHERE  C.ADMPV_TIPO_DOC=K_TIPODOC AND C.ADMPV_NUM_DOC=K_NRODOC
          AND C.ADMPV_COD_TPOCL='3'
          --AND C.ADMPC_ESTADO='A'
          AND K.ADMPV_COD_CPTO IN ('7','11')
           AND K.ADMPD_FEC_TRANS>=K_FECHAINI
          AND K.ADMPD_FEC_TRANS< K_FECHAFIN + 1
          GROUP BY K.ADMPV_COD_CLI ,K.ADMPD_FEC_TRANS

          UNION ALL

          SELECT /*+ STAR_TRANSFORMATION */ K.ADMPV_COD_CLI AS CODCLIENTE,'' AS SERVICIO,'FACTURACION' AS CONCEPTO,
          --SUM(K.ADMPN_PUNTOS) AS PUNTOS,
           DECODE(SIGN(NVL(SUM(K.ADMPN_PUNTOS),0)),-1, NVL(SUM(K.ADMPN_PUNTOS),0)*-1,NVL(SUM(K.ADMPN_PUNTOS),0)) AS PUNTOS,
          'CLARO' AS TIPOPTO,
          'ENTRADA' AS TIPOOPER,
          K.ADMPD_FEC_TRANS AS FECHAASIG,
          ADD_MONTHS(K.ADMPD_FEC_TRANS,18) AS FECHA_VIG
          FROM ADMPT_CLIENTE C
          --INNER JOIN ADMPT_KARDEX K
      INNER JOIN VIEW_ADMPT_KARDEX K
          ON C.ADMPV_COD_CLI=K.ADMPV_COD_CLI
          WHERE  C.ADMPV_TIPO_DOC=K_TIPODOC AND C.ADMPV_NUM_DOC=K_NRODOC
          AND C.ADMPV_COD_TPOCL='3'
          --AND C.ADMPC_ESTADO='A'
          AND K.ADMPV_COD_CPTO IN ('12','13','26')
           AND K.ADMPD_FEC_TRANS>=K_FECHAINI
          AND K.ADMPD_FEC_TRANS< K_FECHAFIN + 1
          GROUP BY K.ADMPV_COD_CLI ,K.ADMPD_FEC_TRANS

  --        ORDER BY FECHAASIG DESC, CONCEPTO ASC

 --       ELSIF K_TIPOCLIENTE='6' THEN
     --  OPEN CURSORESTADOCTA FOR
       --MOVIMIENTOS
    union all 
          SELECT /*+ STAR_TRANSFORMATION */ C.ADMPV_COD_CLI AS CODCLIENTE,TS.ADMPV_DESC AS SERVICIO,CO.ADMPV_DESC AS CONCEPTO,
          --K.ADMPN_PUNTOS AS PUNTOS,
          DECODE(SIGN(NVL(K.ADMPN_PUNTOS,0)),-1, NVL(K.ADMPN_PUNTOS,0)*-1,NVL(K.ADMPN_PUNTOS,0)) AS PUNTOS,
          CASE K.ADMPC_TPO_PUNTO WHEN 'C' THEN 'CLARO' WHEN 'I' THEN 'INTERBANK' ELSE 'CLARO' END AS TIPOPUNTO,
          CASE K.ADMPC_TPO_OPER WHEN 'E' THEN 'ENTRADA' ELSE 'SALIDA' END  AS TIPOOPER,
          K.ADMPD_FEC_TRANS AS FECHAASIG,
          DECODE(K.ADMPC_TPO_OPER,'E',ADD_MONTHS(K.ADMPD_FEC_TRANS,18),NULL) AS FECHA_VIG
          FROM ADMPT_CLIENTEFIJA C
          INNER JOIN ADMPT_CLIENTEPRODUCTO P
          ON C.ADMPV_COD_CLI=P.ADMPV_COD_CLI
          INNER JOIN ADMPT_KARDEXFIJA K
          ON P.ADMPV_COD_CLI_PROD=K.ADMPV_COD_CLI_PROD
          INNER JOIN ADMPT_CONCEPTO CO
          ON K.ADMPV_COD_CPTO=CO.ADMPV_COD_CPTO
          INNER JOIN ADMPT_TIPOSERV_DTH_HFC TS
          ON TS.ADMPV_SERVICIO=P.ADMPV_SERVICIO
          and ts.admpv_cod_tpocl='6'
          WHERE C.ADMPV_TIPO_DOC = K_TIPODOC AND C.ADMPV_NUM_DOC=K_NRODOC
          AND C.ADMPV_COD_TPOCL = '6'
          --AND C.ADMPC_ESTADO='A'
          AND K.ADMPV_COD_CPTO NOT IN (64,65,82)--JCGT  --  AND K.ADMPV_COD_CPTO in(74,75,59,52,72,59,55,58,69,73,62,64,65)
          AND K.ADMPD_FEC_TRANS>=K_FECHAINI
          AND K.ADMPD_FEC_TRANS<K_FECHAFIN+1

          UNION ALL--JCGT INI
          SELECT /*+ STAR_TRANSFORMATION */ MAX(C.ADMPV_COD_CLI) AS CODCLIENTE,MAX(TS.ADMPV_DESC) AS SERVICIO,MAX(CO.ADMPV_DESC) AS CONCEPTO,
          SUM(DECODE(SIGN(NVL(K.ADMPN_PUNTOS,0)),-1, NVL(K.ADMPN_PUNTOS,0)*-1,NVL(K.ADMPN_PUNTOS,0))) AS PUNTOS,
          MAX(CASE K.ADMPC_TPO_PUNTO WHEN 'C' THEN 'CLARO' WHEN 'I' THEN 'INTERBANK' ELSE 'CLARO' END) AS TIPOPUNTO,
          MAX(CASE K.ADMPC_TPO_OPER WHEN 'E' THEN 'ENTRADA' ELSE 'SALIDA' END)  AS TIPOOPER,
          MAX(K.ADMPD_FEC_TRANS) AS FECHAASIG,
          MAX(DECODE(K.ADMPC_TPO_OPER,'E',ADD_MONTHS(K.ADMPD_FEC_TRANS,18),NULL)) AS FECHA_VIG
          FROM ADMPT_CLIENTEFIJA C
          INNER JOIN ADMPT_CLIENTEPRODUCTO P
          ON C.ADMPV_COD_CLI=P.ADMPV_COD_CLI
          INNER JOIN ADMPT_KARDEXFIJA K
          ON P.ADMPV_COD_CLI_PROD=K.ADMPV_COD_CLI_PROD
          INNER JOIN ADMPT_CONCEPTO CO
          ON K.ADMPV_COD_CPTO=CO.ADMPV_COD_CPTO
          INNER JOIN ADMPT_TIPOSERV_DTH_HFC TS
          ON TS.ADMPV_SERVICIO=P.ADMPV_SERVICIO
          and ts.admpv_cod_tpocl='6'
          WHERE C.ADMPV_TIPO_DOC = K_TIPODOC AND C.ADMPV_NUM_DOC=K_NRODOC
          AND C.ADMPV_COD_TPOCL = '6'
          --AND C.ADMPC_ESTADO='A'
          AND K.ADMPV_COD_CPTO IN (64,65,82)--53,54,60,61,73,60,56,57,68,72,63,
          AND K.ADMPD_FEC_TRANS>=K_FECHAINI
          AND K.ADMPD_FEC_TRANS<K_FECHAFIN+1
          GROUP BY P.ADMPV_COD_CLI_PROD,K.ADMPV_COD_CPTO,TO_CHAR(K.ADMPD_FEC_TRANS,'DD/MM/YYYY')--JCGT INI

        --  ORDER BY FECHAASIG DESC, CONCEPTO ASC

   --    ELSIF K_TIPOCLIENTE='7' THEN
      -- OPEN CURSORESTADOCTA FOR
    union all
       --MOVIMIENTOS
          SELECT /*+ STAR_TRANSFORMATION */ C.ADMPV_COD_CLI AS CODCLIENTE,TS.ADMPV_DESC AS SERVICIO,CO.ADMPV_DESC AS CONCEPTO,
          DECODE(SIGN(NVL(K.ADMPN_PUNTOS,0)),-1, NVL(K.ADMPN_PUNTOS,0)*-1,NVL(K.ADMPN_PUNTOS,0)) AS PUNTOS,
          CASE K.ADMPC_TPO_PUNTO WHEN 'C' THEN 'CLARO' WHEN 'I' THEN 'INTERBANK' ELSE 'CLARO' END AS TIPOPUNTO,
          CASE K.ADMPC_TPO_OPER WHEN 'E' THEN 'ENTRADA' ELSE 'SALIDA' END  AS TIPOOPER,
          K.ADMPD_FEC_TRANS AS FECHAASIG,
          DECODE(K.ADMPC_TPO_OPER,'E',ADD_MONTHS(K.ADMPD_FEC_TRANS,18),NULL) AS FECHA_VIG
          FROM ADMPT_CLIENTEFIJA C
          INNER JOIN ADMPT_CLIENTEPRODUCTO P
          ON C.ADMPV_COD_CLI=P.ADMPV_COD_CLI
          INNER JOIN ADMPT_KARDEXFIJA K
          ON P.ADMPV_COD_CLI_PROD=K.ADMPV_COD_CLI_PROD
          INNER JOIN ADMPT_CONCEPTO CO
          ON K.ADMPV_COD_CPTO=CO.ADMPV_COD_CPTO
          INNER JOIN ADMPT_TIPOSERV_DTH_HFC TS
          ON TS.ADMPV_SERVICIO=P.ADMPV_SERVICIO
          and ts.admpv_cod_tpocl='7'
          WHERE C.ADMPV_TIPO_DOC = K_TIPODOC AND C.ADMPV_NUM_DOC=K_NRODOC
          AND C.ADMPV_COD_TPOCL = '7'
          --AND C.ADMPC_ESTADO='A'
          AND K.ADMPV_COD_CPTO NOT IN (66,67,82)--53,54,60,61,73,60,56,57,68,72,63,
          AND K.ADMPD_FEC_TRANS>=K_FECHAINI
          AND K.ADMPD_FEC_TRANS<K_FECHAFIN+1

          --ORDER BY FECHAASIG DESC, CONCEPTO ASC;
          UNION ALL
          SELECT /*+ STAR_TRANSFORMATION */ MAX(C.ADMPV_COD_CLI) AS CODCLIENTE,MAX(TS.ADMPV_DESC) AS SERVICIO,MAX(CO.ADMPV_DESC) AS CONCEPTO,
          SUM(DECODE(SIGN(NVL(K.ADMPN_PUNTOS,0)),-1, NVL(K.ADMPN_PUNTOS,0)*-1,NVL(K.ADMPN_PUNTOS,0))) AS PUNTOS,
          MAX(CASE K.ADMPC_TPO_PUNTO WHEN 'C' THEN 'CLARO' WHEN 'I' THEN 'INTERBANK' ELSE 'CLARO' END) AS TIPOPUNTO,
          MAX(CASE K.ADMPC_TPO_OPER WHEN 'E' THEN 'ENTRADA' ELSE 'SALIDA' END)  AS TIPOOPER,
          MAX(K.ADMPD_FEC_TRANS) AS FECHAASIG,
          MAX(DECODE(K.ADMPC_TPO_OPER,'E',ADD_MONTHS(K.ADMPD_FEC_TRANS,18),NULL)) AS FECHA_VIG
          FROM ADMPT_CLIENTEFIJA C
          INNER JOIN ADMPT_CLIENTEPRODUCTO P
          ON C.ADMPV_COD_CLI=P.ADMPV_COD_CLI
          INNER JOIN ADMPT_KARDEXFIJA K
          ON P.ADMPV_COD_CLI_PROD=K.ADMPV_COD_CLI_PROD
          INNER JOIN ADMPT_CONCEPTO CO
          ON K.ADMPV_COD_CPTO=CO.ADMPV_COD_CPTO
          INNER JOIN ADMPT_TIPOSERV_DTH_HFC TS
          ON TS.ADMPV_SERVICIO=P.ADMPV_SERVICIO
          and ts.admpv_cod_tpocl='7'
          WHERE C.ADMPV_TIPO_DOC = K_TIPODOC AND C.ADMPV_NUM_DOC=K_NRODOC
          AND C.ADMPV_COD_TPOCL = '7'
          --AND C.ADMPC_ESTADO='A'
          AND K.ADMPV_COD_CPTO IN (66,67,82)--53,54,60,61,73,60,56,57,68,72,63,
          AND K.ADMPD_FEC_TRANS>=K_FECHAINI
          AND K.ADMPD_FEC_TRANS<K_FECHAFIN+1
          GROUP BY P.ADMPV_COD_CLI_PROD,K.ADMPV_COD_CPTO,TO_CHAR(K.ADMPD_FEC_TRANS,'DD/MM/YYYY')

          -- ORDER BY FECHAASIG DESC, CONCEPTO ASC
--3PLAY
--ELSIF K_TIPOCLIENTE='9' THEN
  --     OPEN CURSORESTADOCTA FOR
       --MOVIMIENTOS
     union all
          SELECT /*+ STAR_TRANSFORMATION */ C.ADMPV_COD_CLI AS CODCLIENTE,TS.ADMPV_DESC AS SERVICIO,CO.ADMPV_DESC AS CONCEPTO,
          DECODE(SIGN(NVL(K.ADMPN_PUNTOS,0)),-1, NVL(K.ADMPN_PUNTOS,0)*-1,NVL(K.ADMPN_PUNTOS,0)) AS PUNTOS,
          CASE K.ADMPC_TPO_PUNTO WHEN 'C' THEN 'CLARO' WHEN 'I' THEN 'INTERBANK' ELSE 'CLARO' END AS TIPOPUNTO,
          CASE K.ADMPC_TPO_OPER WHEN 'E' THEN 'ENTRADA' ELSE 'SALIDA' END  AS TIPOOPER,
          K.ADMPD_FEC_TRANS AS FECHAASIG,
          DECODE(K.ADMPC_TPO_OPER,'E',ADD_MONTHS(K.ADMPD_FEC_TRANS,18),NULL) AS FECHA_VIG
          FROM ADMPT_CLIENTEFIJA C
          INNER JOIN ADMPT_CLIENTEPRODUCTO P
          ON C.ADMPV_COD_CLI=P.ADMPV_COD_CLI
          INNER JOIN ADMPT_KARDEXFIJA K
          ON P.ADMPV_COD_CLI_PROD=K.ADMPV_COD_CLI_PROD
          INNER JOIN ADMPT_CONCEPTO CO
          ON K.ADMPV_COD_CPTO=CO.ADMPV_COD_CPTO
          INNER JOIN ADMPT_TIPOSERV_DTH_HFC TS
          ON TS.ADMPV_SERVICIO=P.ADMPV_SERVICIO
          and ts.admpv_cod_tpocl='9'
          WHERE C.ADMPV_TIPO_DOC = K_TIPODOC AND C.ADMPV_NUM_DOC=K_NRODOC
          AND C.ADMPV_COD_TPOCL = '9'
          --AND C.ADMPC_ESTADO='A'
          AND K.ADMPV_COD_CPTO NOT IN (126,127,82)--53,54,60,61,73,60,56,57,68,72,63,
          AND K.ADMPD_FEC_TRANS>=trunc(K_FECHAINI)
          AND K.ADMPD_FEC_TRANS<trunc(K_FECHAFIN+1)

          --ORDER BY FECHAASIG DESC, CONCEPTO ASC;
          UNION ALL
          SELECT /*+ STAR_TRANSFORMATION */ MAX(C.ADMPV_COD_CLI) AS CODCLIENTE,MAX(TS.ADMPV_DESC) AS SERVICIO,MAX(CO.ADMPV_DESC) AS CONCEPTO,
          SUM(DECODE(SIGN(NVL(K.ADMPN_PUNTOS,0)),-1, NVL(K.ADMPN_PUNTOS,0)*-1,NVL(K.ADMPN_PUNTOS,0))) AS PUNTOS,
          MAX(CASE K.ADMPC_TPO_PUNTO WHEN 'C' THEN 'CLARO' WHEN 'I' THEN 'INTERBANK' ELSE 'CLARO' END) AS TIPOPUNTO,
          MAX(CASE K.ADMPC_TPO_OPER WHEN 'E' THEN 'ENTRADA' ELSE 'SALIDA' END)  AS TIPOOPER,
          MAX(K.ADMPD_FEC_TRANS) AS FECHAASIG,
          MAX(DECODE(K.ADMPC_TPO_OPER,'E',ADD_MONTHS(K.ADMPD_FEC_TRANS,18),NULL)) AS FECHA_VIG
          FROM ADMPT_CLIENTEFIJA C
          INNER JOIN ADMPT_CLIENTEPRODUCTO P
          ON C.ADMPV_COD_CLI=P.ADMPV_COD_CLI
          INNER JOIN ADMPT_KARDEXFIJA K
          ON P.ADMPV_COD_CLI_PROD=K.ADMPV_COD_CLI_PROD
          INNER JOIN ADMPT_CONCEPTO CO
          ON K.ADMPV_COD_CPTO=CO.ADMPV_COD_CPTO
          INNER JOIN ADMPT_TIPOSERV_DTH_HFC TS
          ON TS.ADMPV_SERVICIO=P.ADMPV_SERVICIO
          and ts.admpv_cod_tpocl='9'
          WHERE C.ADMPV_TIPO_DOC = K_TIPODOC AND C.ADMPV_NUM_DOC=K_NRODOC
          AND C.ADMPV_COD_TPOCL = '9'
          --AND C.ADMPC_ESTADO='A'
          AND K.ADMPV_COD_CPTO IN (126,127,82)--53,54,60,61,73,60,56,57,68,72,63,
          AND K.ADMPD_FEC_TRANS>=trunc(K_FECHAINI)
          AND K.ADMPD_FEC_TRANS<trunc(K_FECHAFIN+1)
          GROUP BY P.ADMPV_COD_CLI_PROD,K.ADMPV_COD_CPTO,TO_CHAR(K.ADMPD_FEC_TRANS,'DD/MM/YYYY')

       --    ORDER BY FECHAASIG DESC, CONCEPTO ASC;

      --TFI
    --  ELSIF K_TIPOCLIENTE='8' THEN
      --    OPEN CURSORESTADOCTA FOR
    union all 
      --MOVIMIENTO
          SELECT /*+ STAR_TRANSFORMATION */ K.ADMPV_COD_CLI AS CODCLIENTE,'' AS SERVICIO,CO.ADMPV_DESC AS CONCEPTO,
          DECODE(SIGN(NVL(K.ADMPN_PUNTOS,0)),-1, NVL(K.ADMPN_PUNTOS,0)*-1,NVL(K.ADMPN_PUNTOS,0)) AS PUNTOS,
          CASE K.ADMPC_TPO_PUNTO WHEN 'C' THEN 'CLARO' WHEN 'I' THEN 'INTERBANK' ELSE 'CLARO' END AS TIPOPUNTO,
          CASE K.ADMPC_TPO_OPER WHEN 'E' THEN 'ENTRADA' ELSE 'SALIDA' END  AS TIPOOPER,
          K.ADMPD_FEC_TRANS AS FECHAASIG,
          DECODE(K.ADMPC_TPO_OPER,'E',ADD_MONTHS(K.ADMPD_FEC_TRANS,18),NULL) AS FECHA_VIG
          FROM  ADMPT_CLIENTE C
          --INNER JOIN ADMPT_KARDEX K
      INNER JOIN VIEW_ADMPT_KARDEX K
          ON C.ADMPV_COD_CLI=K.ADMPV_COD_CLI
          INNER JOIN  ADMPT_CONCEPTO CO
          ON K.ADMPV_COD_CPTO=CO.ADMPV_COD_CPTO
          WHERE C.ADMPV_TIPO_DOC=K_TIPODOC AND C.ADMPV_NUM_DOC=K_NRODOC
          AND C.ADMPV_COD_TPOCL='8'
          --AND C.ADMPC_ESTADO='A'
          AND K.ADMPV_COD_CPTO <>'90' --CANJE
          AND K.ADMPV_COD_CPTO <>'91' --DEVOLUCION
          AND K.ADMPV_COD_CPTO <>'82' --CANJE VENTA
          AND K.ADMPD_FEC_TRANS>=K_FECHAINI
          AND K.ADMPD_FEC_TRANS< K_FECHAFIN+1

          UNION ALL
          -- CANJE
          SELECT /*+ STAR_TRANSFORMATION */ CODCLIENTE,'' AS SERVICIO,CONCEPTO,
          DECODE(SIGN(NVL(SUM(PUNTOS),0)),-1, NVL(SUM(PUNTOS),0)*-1,NVL(SUM(PUNTOS),0)) AS PUNTOS,
          TIPOPUNTO,
          TIPOOPER,
          FECHAASIG,
          FECHA_VIG
          FROM
          (SELECT CA.ADMPV_ID_CANJE,C.ADMPV_COD_CLI AS CODCLIENTE,'CANJE' AS CONCEPTO,
                    CK.ADMPN_PUNTOS AS PUNTOS,
                    CASE K.ADMPC_TPO_PUNTO WHEN 'C' THEN 'CLARO' WHEN 'I' THEN 'INTERBANK' ELSE 'CLARO' END AS TIPOPUNTO,
                    'SALIDA' AS TIPOOPER,
                    CA.ADMPD_FEC_CANJE AS FECHAASIG,
                    NULL AS FECHA_VIG
          FROM  ADMPT_CANJE CA
          INNER JOIN  ADMPT_CLIENTE C
          ON CA.ADMPV_COD_CLI=C.ADMPV_COD_CLI
          INNER JOIN  ADMPT_CANJEDT_KARDEX CK
          ON CA.ADMPV_ID_CANJE=CK.ADMPV_ID_CANJE
          --INNER JOIN ADMPT_KARDEX K
      INNER JOIN VIEW_ADMPT_KARDEX K
          ON CK.ADMPN_ID_KARDEX=K.ADMPN_ID_KARDEX
          WHERE C.ADMPV_COD_TPOCL='8'
          AND C.ADMPV_TIPO_DOC=K_TIPODOC
          AND C.ADMPV_NUM_DOC=K_NRODOC
          --AND C.ADMPC_ESTADO='A'
          AND CA.ADMPC_TPO_OPER='C'
          AND CA.ADMPD_FEC_CANJE>=K_FECHAINI
          AND CA.ADMPD_FEC_CANJE<=K_FECHAFIN
          )
GROUP BY ADMPV_ID_CANJE,CODCLIENTE,CONCEPTO,TIPOPUNTO,TIPOOPER,FECHAASIG,FECHA_VIG

          UNION ALL
          --DEVOLUCION
          SELECT /*+ STAR_TRANSFORMATION */ CODCLIENTE,'' AS SERVICIO,CONCEPTO,
          DECODE(SIGN(NVL(SUM(PUNTOS),0)),-1, NVL(SUM(PUNTOS),0)*-1,NVL(SUM(PUNTOS),0)) AS PUNTOS,
          TIPOPUNTO,TIPOOPER,FECHAASIG,FECHA_VIG FROM
          (
          SELECT DEV.ADMPV_ID_CANJE,
          C.ADMPV_COD_CLI AS CODCLIENTE, 'DEVOLUCION' AS CONCEPTO ,
                    CK.ADMPN_PUNTOS AS PUNTOS,
                    CASE K.ADMPC_TPO_PUNTO WHEN 'C' THEN 'CLARO' WHEN 'I' THEN 'INTERBANK' ELSE 'CLARO' END AS TIPOPUNTO,
                    'ENTRADA' AS TIPOOPER,
                    CA.ADMPD_FEC_CANJE AS FECHAASIG,
                    NULL AS FECHA_VIG
          FROM  ADMPT_CANJE CA
          INNER JOIN  ADMPT_CLIENTE C
          ON CA.ADMPV_COD_CLI=C.ADMPV_COD_CLI
          INNER JOIN  ADMPT_CANJE DEV
          ON CA.ADMPV_DEV_IDCANJE=DEV.ADMPV_ID_CANJE
          INNER JOIN  ADMPT_CANJEDT_KARDEX CK
          ON DEV.ADMPV_ID_CANJE=CK.ADMPV_ID_CANJE
          --INNER JOIN ADMPT_KARDEX K
      INNER JOIN VIEW_ADMPT_KARDEX K
          ON CK.ADMPN_ID_KARDEX=K.ADMPN_ID_KARDEX
          WHERE C.ADMPV_COD_TPOCL='8'
          AND C.ADMPV_TIPO_DOC=K_TIPODOC
          AND C.ADMPV_NUM_DOC=K_NRODOC
         -- AND C.ADMPC_ESTADO='A'
          AND CA.ADMPC_TPO_OPER='D'
          AND CA.ADMPD_FEC_CANJE>=K_FECHAINI
          AND CA.ADMPD_FEC_CANJE<=K_FECHAFIN
          )
          GROUP BY ADMPV_ID_CANJE,CODCLIENTE,CONCEPTO,TIPOPUNTO,TIPOOPER,FECHAASIG,FECHA_VIG

          ORDER BY FECHAASIG ASC, CONCEPTO ASC;
       --END IF;

      K_CODERROR  := 0;
    K_DESCERROR := 'OK';
  
      EXCEPTION
      WHEN OTHERS THEN
      OPEN CURSORESTADOCTA FOR SELECT '' REGDES, '' PROVDES  FROM DUAL;
      K_CODERROR := 1;
      K_DESCERROR := SUBSTR('ERROR : ' || SQLERRM,1,250);
		
  END ADMPSI_ESTADOCTACC;
end PKG_PORTALES_CLARO;
/