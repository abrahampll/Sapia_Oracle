create or replace package body PCLUB.PKG_CC_CANJE_LATAM is

PROCEDURE SYSFSS_EQUI_CC_KM
            (PI_TIP_PTO      in VARCHAR2,
             PI_PTOS         in NUMBER,
             PO_PTOS_EQUI    out NUMBER,
             PO_PTOS_CANJE   out NUMBER,
             PO_PTOS_RETORNO out NUMBER,
             PO_COD_ERR      out varchar2,
             PO_DES_ERR      out varchar2)

  /*
'****************************************************************************************************************
'* Nombre SP : SYSFSS_EQUI_CC_KM
'* Propósito : Este procedimiento es responsable de retornar la equivalencia
               de puntos y kilometros, ya sea ingresando Claro Puntos o
               ingresando Kilometros.
'* Input :     <Parametro>       -- Descripción de los parametros
              PI_TIP_PTO         -- Tipo de equivalencia: CK si es de Claro puntos a KM y
                                    KC si es de KM a Claro Puntos
              PI_PTOS            -- Cantidad de Puntos
'* Output :    <Parametro>       -- Descripción de los parametros
               PO_PTOS_EQUI      -- Cantidad de Puntos equivalentes
               PO_PTOS_CANJE     -- Cantidad de Puntos que van a ser canjeados
               PO_PTOS_RETORNO   -- Cantidad de Puntos que se van a devolver xq no pueden ser canjeados (esto
                                    sucede cuando se quiere canjear puntos que no dan un valor exacto
               PO_COD_ERR        -- Codigo de error( 0 OK, 1 Error en parametros,
                                    -1 error oracle)
               PO_DES_ERR        -- Descripción del error
'* Creado por : SAPIA - Omar Campos
'* Fec Creación : 28/10/2017
'****************************************************************************************************************
*/

 is

nCOUNT NUMBER;
bFLAG BOOLEAN := FALSE;
nPTO_CC_CONFIG NUMBER;
nPTO_KM_CONFIG NUMBER;


nDIVIDENDO NUMBER;
nDIVISOR NUMBER;
nPUNTOS NUMBER := PI_PTOS;
nDEC NUMBER;
nPUNTOS_NUEVO NUMBER;
nPUNTOS_EQUIV NUMBER;
nPUNTOS_RETORNA NUMBER;

BEGIN

    PO_PTOS_EQUI := 0;
    PO_PTOS_CANJE := 0;
    PO_PTOS_RETORNO := 0;

    IF LENGTH(TRIM(PI_TIP_PTO)) <= 0 OR PI_TIP_PTO IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_TIP_PTO';
      RETURN;
    END IF;

    IF PI_PTOS <= 0 OR PI_PTOS IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_PTOS';
      RETURN;
    END IF;

    IF PI_TIP_PTO <> 'CK' AND PI_TIP_PTO <> 'KC' THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'El Valor del parametro PI_TIP_PTO debe ser CK o KC';
      RETURN;
    END IF;

    SELECT COUNT(*) INTO nCOUNT FROM
    ADMPT_PARAMSIST WHERE ADMPV_DESC = 'LATAM EQUIVALENCIA CLARO PUNTOS';

    IF nCOUNT = 0 THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'No esta configurado equivalencia Claro Puntos en la tabla ADMPT_PARAMSIST';
      RETURN;
    END IF;

    SELECT COUNT(*) INTO nCOUNT FROM
    ADMPT_PARAMSIST WHERE ADMPV_DESC = 'LATAM EQUIVALENCIA KM LATAM';

    IF nCOUNT = 0 THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'No esta configurado equivalencia KM LATAM en la tabla ADMPT_PARAMSIST';
      RETURN;
    END IF;

    BEGIN
      SELECT TO_NUMBER(ADMPV_VALOR) INTO nPTO_CC_CONFIG FROM
      ADMPT_PARAMSIST WHERE ADMPV_DESC = 'LATAM EQUIVALENCIA CLARO PUNTOS';
      IF nPTO_CC_CONFIG = 0 THEN
        PO_COD_ERR := '1';
        PO_DES_ERR := 'El parametro equivalencia Claro Puntos en la tabla ADMPT_PARAMSIST no puede ser 0';
        RETURN;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        PO_COD_ERR := '1';
        PO_DES_ERR := 'El parametro equivalencia Claro Puntos en la tabla ADMPT_PARAMSIST no es numerico';
        RETURN;
    END;

    BEGIN
      SELECT TO_NUMBER(ADMPV_VALOR) INTO nPTO_KM_CONFIG FROM
      ADMPT_PARAMSIST WHERE ADMPV_DESC = 'LATAM EQUIVALENCIA KM LATAM';
      IF nPTO_KM_CONFIG = 0 THEN
        PO_COD_ERR := '1';
        PO_DES_ERR := 'El parametro equivalencia KM LATAM en la tabla ADMPT_PARAMSIST no puede ser 0';
        RETURN;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        PO_COD_ERR := '1';
        PO_DES_ERR := 'El parametro equivalencia KM LATAM en la tabla ADMPT_PARAMSIST no es numerico';
        RETURN;
    END;


    IF PI_TIP_PTO = 'CK' THEN
      IF nPUNTOS < nPTO_CC_CONFIG THEN
        PO_COD_ERR := '1';
        PO_DES_ERR := 'La cantidad de Claro Puntos a canjear ('||TO_CHAR(nPUNTOS)||') no puede ser menora a la equivalencia configurada ('||TO_CHAR(nPTO_CC_CONFIG)||')';
        RETURN;
      END IF;
      nDIVIDENDO := nPTO_CC_CONFIG;
      nDIVISOR := nPTO_KM_CONFIG;
    END IF;

    IF PI_TIP_PTO = 'KC' THEN
      IF nPUNTOS < nPTO_KM_CONFIG THEN
        PO_COD_ERR := '1';
        PO_DES_ERR := 'La cantidad de KM Latam a canjear ('||TO_CHAR(nPUNTOS)||') no puede ser menora a la equivalencia configurada ('||TO_CHAR(nPTO_KM_CONFIG)||')';
        RETURN;
      END IF;
      nDIVIDENDO := nPTO_KM_CONFIG;
      nDIVISOR := nPTO_CC_CONFIG;
    END IF;

    nPUNTOS_EQUIV := nPUNTOS/(nDIVISOR / nDIVIDENDO);
    nDEC := nPUNTOS_EQUIV - TRUNC(nPUNTOS_EQUIV);

    IF nDEC > 0 THEN
      nPUNTOS_NUEVO := nPUNTOS;
      nPUNTOS_RETORNA := 0;
      WHILE bFLAG = FALSE
        LOOP
          nPUNTOS_NUEVO := nPUNTOS_NUEVO - 1;
          nPUNTOS_RETORNA := nPUNTOS_RETORNA +1;
          nPUNTOS_EQUIV := nPUNTOS_NUEVO/(nDIVISOR / nDIVIDENDO);
          nDEC := nPUNTOS_EQUIV - TRUNC(nPUNTOS_EQUIV);

          IF nDEC = 0 THEN
            bFLAG := TRUE;
          END IF;

      END LOOP;
    ELSE
      nPUNTOS_NUEVO := nPUNTOS;
      nPUNTOS_RETORNA := 0;
    END IF;

    PO_PTOS_EQUI := nPUNTOS_EQUIV;
    PO_PTOS_CANJE := nPUNTOS_NUEVO;
    PO_PTOS_RETORNO := nPUNTOS_RETORNA;

    PO_COD_ERR := '0';
    PO_DES_ERR   := 'OK';

EXCEPTION
   WHEN OTHERS THEN
      PO_COD_ERR := '-1';
      PO_DES_ERR := 'ERROR => ' || TO_CHAR(SQLCODE) || ' : ' || SQLERRM;

END SYSFSS_EQUI_CC_KM;

PROCEDURE SYSFSI_SOCIO_LATAM
            (PI_IDSOCIO_LATAM in VARCHAR2,
             PI_DIG_VERIFICA  in VARCHAR2,
             PI_APE_SOCIO     in VARCHAR2,
             PI_NOM_SOCIO     in VARCHAR2,
             PI_TIPDOC_LATAM  in VARCHAR2,
             PI_NUM_DOC       in VARCHAR2,
             PI_USU_REG       in VARCHAR2,
             PO_COD_ERR       out varchar2,
             PO_DES_ERR       out varchar2)

  /*
'****************************************************************************************************************
'* Nombre SP : SYSFSI_SOCIO_LATAM
'* Propósito : Este procedimiento es responsable de registrar los Socios Latam.
'* Input :     <Parametro>       -- Descripción de los parametros
              PI_IDSOCIO_LATAM   -- Codigo socio de LATAM
              PI_DIG_VERIFICA    -- Digito verficador de Codigo socio de LATAM
              PI_APE_SOCIO       -- Apellido de socio de LATAM
              PI_NOM_SOCIO       -- Nombre de socio de LATAM
              PI_TIPDOC_LATAM    -- Tipo de documento LATAM
              PI_NUM_DOC         -- Numero de documento LATAM
              PI_USU_REG         -- Usuario
'* Output :    <Parametro>       -- Descripción de los parametros
               PO_COD_ERR        -- Codigo de error( 0 OK, 1 Error en parametros,
                                    -1 error oracle)
               PO_DES_ERR        -- Descripción del error
'* Creado por : SAPIA - Omar Campos
'* Fec Creación : 28/10/2017
'****************************************************************************************************************
*/

 is

nCOUNT NUMBER;
ID_Seq NUMBER;

vNOM_SOC VARCHAR2(30);
vAPE_SOC VARCHAR2(30);

BEGIN


    PO_COD_ERR := '0';
    PO_DES_ERR   := 'OK';

    IF LENGTH(TRIM(PI_NOM_SOCIO)) <= 0 OR PI_NOM_SOCIO IS NULL THEN
      vNOM_SOC := '-';
    ELSE
      vNOM_SOC := TRIM(PI_NOM_SOCIO);
    END IF;

    IF LENGTH(TRIM(PI_APE_SOCIO)) <= 0 OR PI_APE_SOCIO IS NULL THEN
      vAPE_SOC := '-';
    ELSE
      vAPE_SOC := TRIM(PI_APE_SOCIO);
    END IF;

    SELECT COUNT(*) INTO nCOUNT FROM SYSFT_LATAM_SOCIO
    WHERE SYLSV_ID_SOCIO_LATAM = PI_IDSOCIO_LATAM;

    IF nCOUNT = 0 THEN
      SELECT SYSFSQ_LATAM_SOCIO.NEXTVAL INTO ID_Seq FROM DUAL;

      INSERT INTO SYSFT_LATAM_SOCIO (
      SYLSN_IDENTIFICADOR, SYLSV_ID_SOCIO_LATAM, SYLSC_DIG_VERIFICA, SYLSV_APE_SOC, SYLSV_NOM_SOC,
      SYLSV_TIP_DOC_LATAM, SYLSV_NUM_DOC, SYLSV_USU_REG)
      VALUES (ID_Seq, PI_IDSOCIO_LATAM, PI_DIG_VERIFICA, UPPER(vAPE_SOC), UPPER(vNOM_SOC),
      PI_TIPDOC_LATAM, PI_NUM_DOC, PI_USU_REG);
    ELSE
      UPDATE SYSFT_LATAM_SOCIO
      SET SYLSV_APE_SOC = UPPER(vAPE_SOC), SYLSV_NOM_SOC = UPPER(vNOM_SOC)
      WHERE SYLSV_ID_SOCIO_LATAM = PI_IDSOCIO_LATAM;
    END IF;


EXCEPTION
   WHEN OTHERS THEN
      PO_COD_ERR := '-1';
      PO_DES_ERR := 'ERROR => ' || TO_CHAR(SQLCODE) || ' : ' || SQLERRM;

END SYSFSI_SOCIO_LATAM;

PROCEDURE SYSFSS_SOCIO_LATAM
            (PI_TIP_DOC  in VARCHAR2,
             PI_NUM_DOC       in VARCHAR2,
             PO_CUR_SOCIO     out SYS_REFCURSOR,
             PO_COD_ERR       out varchar2,
             PO_DES_ERR       out varchar2)

  /*
'****************************************************************************************************************
'* Nombre SP : SYSFSS_SOCIO_LATAM
'* Propósito : Este procedimiento es responsable de registrar los Socios Latam.
'* Input :     <Parametro>       -- Descripción de los parametros
              PI_TIP_DOC    -- Tipo de documento LATAM
              PI_NUM_DOC         -- Numero de documento LATAM
'* Output :    <Parametro>       -- Descripción de los parametros
               PO_CUR_SOCIO      -- Cursor con datos del socio
               PO_COD_ERR        -- Codigo de error( 0 OK, 1 Error en parametros,
                                    -1 error oracle)
               PO_DES_ERR        -- Descripción del error
'* Creado por : SAPIA - Omar Campos
'* Fec Creación : 06/11/2017
'****************************************************************************************************************
*/

 is

nCOUNT NUMBER;
vTIP_DOC_LATAM VARCHAR2(10);
vNUM_DOC_AUX VARCHAR2(20);

BEGIN

    IF LENGTH(TRIM(PI_TIP_DOC)) <= 0 OR PI_TIP_DOC IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_TIP_DOC';
      RETURN;
    END IF;

    IF LENGTH(TRIM(PI_NUM_DOC)) <= 0 OR PI_NUM_DOC IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_NUM_DOC';
      RETURN;
    END IF;

    SELECT COUNT(*) INTO nCOUNT FROM SYSFT_LATAM_EQUIV_TIP_DOC A
    WHERE A.SYLEV_ID_TIPO_DOC_CC = PI_TIP_DOC;

    IF nCOUNT = 0 THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'No existe equivalencia en tabla SYSFT_LATAM_EQUIV_TIP_DOC para PI_TIP_DOC: ' ||PI_TIP_DOC;
      RETURN;
    END IF;

    -- OBTENER EQUIVALENCIA DE TIPO DE DOCUMENTO
    SELECT A.SYLEV_TIPO_DOC_LATAM INTO vTIP_DOC_LATAM FROM SYSFT_LATAM_EQUIV_TIP_DOC A
    WHERE A.SYLEV_ID_TIPO_DOC_CC = PI_TIP_DOC;

    -- VALIDAR SI EXISTE EL REGISTRO
    SELECT COUNT(1) INTO nCOUNT
    FROM SYSFT_LATAM_SOCIO
    WHERE SYLSV_TIP_DOC_LATAM = vTIP_DOC_LATAM AND SYLSV_NUM_DOC = PI_NUM_DOC
    AND ROWNUM = 1;

    IF nCOUNT > 0 THEN

      -- BUSQUEDA #1
    OPEN PO_CUR_SOCIO FOR
    SELECT SYLSV_ID_SOCIO_LATAM, SYLSC_DIG_VERIFICA, SYLSV_APE_SOC, SYLSV_NOM_SOC,
    SYLSV_TIP_DOC_LATAM, SYLSV_NUM_DOC, SYLSC_ESTADO
    FROM SYSFT_LATAM_SOCIO
    WHERE SYLSV_TIP_DOC_LATAM = vTIP_DOC_LATAM AND SYLSV_NUM_DOC = PI_NUM_DOC;

    ELSE

      -- SE VALIDA SI ES CARNET DE EXTRANJERIA
      IF PI_TIP_DOC = '4' THEN

        vNUM_DOC_AUX := LTRIM(PI_NUM_DOC, '0');

        -- BUSQUEDA #2
        OPEN PO_CUR_SOCIO FOR
        SELECT SYLSV_ID_SOCIO_LATAM, SYLSC_DIG_VERIFICA, SYLSV_APE_SOC, SYLSV_NOM_SOC,
        SYLSV_TIP_DOC_LATAM, SYLSV_NUM_DOC, SYLSC_ESTADO
        FROM SYSFT_LATAM_SOCIO
        WHERE SYLSV_TIP_DOC_LATAM = vTIP_DOC_LATAM AND SYLSV_NUM_DOC = vNUM_DOC_AUX;

      END IF;

    END IF;

    PO_COD_ERR := '0';
    PO_DES_ERR := 'OK';

EXCEPTION
   WHEN OTHERS THEN
      OPEN PO_CUR_SOCIO FOR
      SELECT '' SYLSV_ID_SOCIO_LATAM, '' SYLSC_DIG_VERIFICA, '' SYLSV_APE_SOC, '' SYLSV_NOM_SOC,
      '' SYLSV_TIP_DOC_LATAM, '' SYLSV_NUM_DOC, '' SYLSC_ESTADO FROM DUAL;
      PO_COD_ERR := '-1';
      PO_DES_ERR := 'ERROR => ' || TO_CHAR(SQLCODE) || ' : ' || SQLERRM;

END SYSFSS_SOCIO_LATAM;

PROCEDURE SYSFSI_CANJE_KMLATAMCC
            (PI_TIP_CANJE     in VARCHAR2,
             PI_TIP_DOC_CC    in VARCHAR2,
             PI_NUM_DOC       in VARCHAR2,
             PI_LINEA         in VARCHAR2,
             PI_CORREO        in VARCHAR2,
             PI_PTOS_CC       in NUMBER,
             PI_KM_LATAM      in NUMBER,
             PI_GRP_CANJE     IN NUMBER,
             PI_USU_REG       in VARCHAR2,
             PI_COD_APLI      in VARCHAR2,
             PI_ESTADO_REG    in VARCHAR2,
             PI_ID_SOCIO      IN VARCHAR2,
             PI_NOM_SOC       IN VARCHAR2,
             PI_APE_SOC       IN VARCHAR2,
             PI_COD_RESP      IN VARCHAR2,
             PI_MSG_RESP      IN VARCHAR2,
             PI_ID_TRANS      IN VARCHAR2,
             PO_COD_ERR       out varchar2,
             PO_DES_ERR       out varchar2)

  /*
'****************************************************************************************************************
'* Nombre SP : SYSFSI_CANJE_KMLATAMCC
'* Propósito : Este procedimiento es responsable de registrar los Puntos que el cliente
               va ha canjear sea de CC a KM o de KM a CC.
'* Input :     <Parametro>       -- Descripción de los parametros
              PI_TIP_CANJE       -- Tipo de canje: CK si es de Claro puntos a KM y
                                    KC si es de KM a Claro Puntos
              PI_TIP_DOC_CC      -- Tipo de documento de Cliente Claro Club
              PI_NUM_DOC         -- Numero de documento de Cliente Claro Club
              PI_LINEA           -- Línea de donde se solicitó el canje
              PI_CORREO          -- Correo que viene desde Mi Claro
              PI_PTOS_CC         -- Cantidad de Claro Puntos
              PI_KM_LATAM        -- Cantidad de KM Latam
              PI_GRP_CANJE       -- Codigo de Grupo que guarda los canjes de CC
              PI_USU_REG         -- Usuario
              PI_COD_APLI        -- Codigo de Aplicación que invoca al SP
              PI_ESTADO_REG      -- Estado de registro (P pendiente (CK), F finalizado (KC), R error)
              PI_NOM_SOC         -- Nombre de Socio
              PI_APE_SOC         -- Apellido de Socio
              PI_COD_RESP        -- Codigo de Respuesta
              PI_MSG_RESP        -- Menasaje de Respueta
              PI_ID_TRANS        -- Id Transaccion
'* Output :    <Parametro>       -- Descripción de los parametros
              PO_COD_ERR         -- Codigo de error( 0 OK, 1 Error en parametros,
                                    -1 error oracle)
              PO_DES_ERR         -- Descripción del error
'* Creado por : SAPIA - Omar Campos
'* Fec Creación : 28/10/2017
'****************************************************************************************************************
*/

 is

  nCOUNT NUMBER;
  nSEQ_CANJE NUMBER;
  vRecType CHAR(1);
  vProgramId VARCHAR2(5);
  vID_SOC_LATAM VARCHAR2(12);
  vNOM_SOC_LATAM VARCHAR2(20);
  vCORRELATIVO VARCHAR2(12);

  nCOD_ERR INTEGER;
  vDES_ERR VARCHAR2(255);

  vMSG_RESP VARCHAR2(500);

BEGIN

    IF LENGTH(TRIM(PI_TIP_CANJE)) <= 0 OR PI_TIP_CANJE IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_TIP_CANJE';
      RETURN;
    END IF;

    IF PI_TIP_CANJE <> 'CK' AND PI_TIP_CANJE <> 'KC' THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'El Valor del parametro PI_TIP_CANJE debe ser CK o KC';
      RETURN;
    END IF;

    IF LENGTH(TRIM(PI_ESTADO_REG)) <= 0 OR PI_ESTADO_REG IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_ESTADO_REG';
      RETURN;
    END IF;

    IF TRIM(PI_ESTADO_REG) <> 'R' AND TRIM(PI_ESTADO_REG) <> 'F' AND TRIM(PI_ESTADO_REG) <> 'P' THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'El Valor del parametro PI_ESTADO_REG debe ser P o F o R';
      RETURN;
    END IF;

    IF TRIM(PI_ESTADO_REG) <> 'R' THEN

    IF PI_PTOS_CC <= 0 OR PI_PTOS_CC IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_PTOS_CC';
      RETURN;
    END IF;

    IF PI_KM_LATAM <= 0 OR PI_KM_LATAM IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_KM_LATAM';
      RETURN;
    END IF;

    IF LENGTH(TRIM(PI_USU_REG)) <= 0 OR PI_USU_REG IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_USU_REG';
      RETURN;
    END IF;

    IF LENGTH(TRIM(PI_COD_APLI)) <= 0 OR PI_COD_APLI IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_COD_APLI';
      RETURN;
    END IF;

    IF LENGTH(TRIM(PI_ID_SOCIO)) <= 0 OR PI_ID_SOCIO IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_ID_SOCIO';
      RETURN;
    END IF;
    END IF;

    IF TRIM(PI_ESTADO_REG) = 'P' THEN
      IF PI_GRP_CANJE <= 0 OR PI_GRP_CANJE IS NULL THEN
        PO_COD_ERR := '1';
        PO_DES_ERR := 'Debe ingresar parametro PI_GRP_CANJE';
        RETURN;
      END IF;

    SELECT COUNT(*) INTO nCOUNT FROM ADMPT_PARAMSIST
    WHERE ADMPV_DESC = 'LATAM PUNTOS MINIMO PARA CANJE';

    IF nCOUNT = 0 THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'No esta configurado Puntos Mínimos para Canje en la tabla ADMPT_PARAMSIST';
      RETURN;
    END IF;

    SELECT COUNT(*) INTO nCOUNT FROM
    ADMPT_PARAMSIST WHERE ADMPV_DESC = 'LATAM REC TYPE SYSFT_LATAM_CANJE_KM_CC';

    IF nCOUNT = 0 THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'No esta configurado LATAM REC TYPE en la tabla ADMPT_PARAMSIST';
      RETURN;
    END IF;

    SELECT COUNT(*) INTO nCOUNT FROM
    ADMPT_PARAMSIST WHERE ADMPV_DESC = 'LATAM PROGRAM ID SYSFT_LATAM_CANJE_KM_CC';

    IF nCOUNT = 0 THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'No esta configurado LATAM PROGRAM ID en la tabla ADMPT_PARAMSIST';
      RETURN;
    END IF;

    SELECT ADMPV_VALOR INTO vRecType FROM
    ADMPT_PARAMSIST WHERE ADMPV_DESC = 'LATAM REC TYPE SYSFT_LATAM_CANJE_KM_CC';

    SELECT ADMPV_VALOR INTO vProgramId FROM
    ADMPT_PARAMSIST WHERE ADMPV_DESC = 'LATAM PROGRAM ID SYSFT_LATAM_CANJE_KM_CC';
    END IF;

    PO_COD_ERR := '0';
    PO_DES_ERR := 'OK';

    vID_SOC_LATAM := PI_ID_SOCIO;
    vNOM_SOC_LATAM := SUBSTR(TRIM(NVL(PI_APE_SOC,'')) ||'/' || TRIM(NVL(PI_NOM_SOC,'')),1,20);

    IF PI_TIP_CANJE = 'CK' THEN
    SELECT SUBSTR('00000000000'||TO_CHAR((NVL(MAX(TO_NUMBER(SYLCKCV_CORRELATIVO)),0)+1)),LENGTH('00000000000'||TO_CHAR((NVL(MAX(TO_NUMBER(SYLCKCV_CORRELATIVO)),0)+1)))-11,12)
    INTO vCORRELATIVO
    FROM SYSFT_LATAM_CANJE_KM_CC;
    ELSE
      vCORRELATIVO := '0';
    END IF;

    vMSG_RESP := SUBSTR(NVL(PI_MSG_RESP,''),1,500);


    SELECT SYSFSQ_LATAM_CANJE.NEXTVAL INTO nSEQ_CANJE FROM DUAL;

    INSERT INTO SYSFT_LATAM_CANJE_KM_CC ( SYLCKCN_ID_CANJE, SYLCKCV_LINEA, SYLCKCV_CORREO, SYLCKCN_ID_GRP_CANJE, SYLCKCC_TIP_REG_LATAM, SYLCKCV_NUMCTA_LATAM, SYLCKCV_ID_PROG_LATAM,
    SYLCKCN_KM_LATAM, SYLCKCN_CC, SYLCKCV_NOM_CLI, SYLCKCV_CTA_SOC_LATAM, SYLCKCV_LOCATIONID, SYLCKCV_LOCATIONDESC,
    SYLCKCV_CORRELATIVO, SYLCKCV_DIAS, SYLCKCV_COD_APLI, SYLCKCV_TIPO_CANJE,SYLCKCC_ESTADO, SYLEKCV_USU_REG,
    SYLCKCV_COD_RESP, SYLCKCV_MSG_RESP, SYLCKCV_ID_TRANS, SYLCKCV_TIP_DOC, SYLCKCV_NUM_DOC )
    VALUES (nSEQ_CANJE, PI_LINEA, PI_CORREO, PI_GRP_CANJE, vRecType, '', vProgramId, TO_CHAR(PI_KM_LATAM), TO_CHAR(PI_PTOS_CC), vNOM_SOC_LATAM,
    vID_SOC_LATAM, '', '', vCORRELATIVO, '', PI_COD_APLI, PI_TIP_CANJE, PI_ESTADO_REG ,PI_USU_REG, PI_COD_RESP, vMSG_RESP, PI_ID_TRANS,
    PI_TIP_DOC_CC, PI_NUM_DOC   );

    IF nCOD_ERR <> 0 THEN
      PO_COD_ERR := TO_CHAR(nCOD_ERR);
      PO_DES_ERR := 'Error al liberar bolsa - '||vDES_ERR;
    END IF;

    commit;


EXCEPTION
   WHEN OTHERS THEN
      PO_COD_ERR := '-1';
      PO_DES_ERR := 'ERROR => ' || TO_CHAR(SQLCODE) || ' : ' || SQLERRM;



END SYSFSI_CANJE_KMLATAMCC;

PROCEDURE SYSFSS_VAL_SOL_CANJE
            (PI_TIP_CANJE     in VARCHAR2,
             PI_TIP_DOC_CC    in VARCHAR2,
             PI_NUM_DOC       in VARCHAR2,
             PI_PTOS          in VARCHAR2,
             PI_FECHA         in DATE,
             PO_COD_ERR       out varchar2,
             PO_DES_ERR       out varchar2)

  /*
'****************************************************************************************************************
'* Nombre SP : SYSFSS_VAL_SOL_CANJE
'* Propósito : Este procedimiento es responsable de validar si el Socios Latam ha
               solicitado un canje para el mismo día y con la misma cantidad de punto.
               Solo valida cuando es de CC a KM.
'* Input :     <Parametro>       -- Descripción de los parametros
              PI_TIP_CANJE       -- Tipo de canje: CK si es de Claro puntos a KM y
                                    KC si es de KM a Claro Puntos
              PI_TIP_DOC_CC      -- Tipo de documento de Cliente Claro Club
              PI_NUM_DOC         -- Numero de documento de Cliente Claro Club
              PI_PTOS            -- Cantidad de Puntos
              PI_FECHA           -- Fecha para validar el registro
'* Output :    <Parametro>       -- Descripción de los parametros
              PO_COD_ERR         -- Codigo de error( 0 No ha solicitado,
                                    1 Error parametros,
                                    2 Si ha solicitado,
                                    -1 error oracle)
               PO_DES_ERR        -- Descripción del error
'* Creado por : SAPIA - Omar Campos
'* Fec Creación : 30/10/2017
'****************************************************************************************************************
*/

 is

  nCOUNT NUMBER;
  vTIP_DOC_LATAM VARCHAR2(15);
  vID_SOC_LATAM VARCHAR2(12);

BEGIN

    IF LENGTH(TRIM(PI_TIP_CANJE)) <= 0 OR PI_TIP_CANJE IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_TIP_CANJE';
      RETURN;
    END IF;

    IF LENGTH(TRIM(PI_TIP_DOC_CC)) <= 0 OR PI_TIP_DOC_CC IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_TIP_DOC_CC';
      RETURN;
    END IF;

    IF LENGTH(TRIM(PI_NUM_DOC)) <= 0 OR PI_NUM_DOC IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_NUM_DOC';
      RETURN;
    END IF;

    IF PI_FECHA IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_FECHA';
      RETURN;
    END IF;

    IF LENGTH(TRIM(PI_PTOS)) <= 0 OR PI_PTOS IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_PTOS';
      RETURN;
    END IF;

    IF PI_TIP_CANJE <> 'CK' AND PI_TIP_CANJE <> 'KC' THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'El Valor del parametro PI_TIP_CANJE debe ser CK o KC';
      RETURN;
    END IF;

    SELECT A.SYLEV_TIPO_DOC_LATAM INTO vTIP_DOC_LATAM FROM SYSFT_LATAM_EQUIV_TIP_DOC A
    WHERE A.SYLEV_ID_TIPO_DOC_CC = PI_TIP_DOC_CC;

    SELECT COUNT(*) INTO nCOUNT FROM SYSFT_LATAM_SOCIO A
    WHERE A.SYLSV_TIP_DOC_LATAM = vTIP_DOC_LATAM AND A.SYLSV_NUM_DOC = PI_NUM_DOC;

    IF nCOUNT = 0 THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'No existe ningun Socio LATAM para el Tipo de Documento: '||vTIP_DOC_LATAM|| ' y Número de Documento: ' ||PI_NUM_DOC;
      RETURN;
    ELSIF nCOUNT > 1 THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Existe mas de un Socio LATAM para el Tipo de Documento: '||vTIP_DOC_LATAM|| ' y Número de Documento: ' ||PI_NUM_DOC;
      RETURN;
    END IF;

    SELECT A.SYLSV_ID_SOCIO_LATAM INTO vID_SOC_LATAM
    FROM SYSFT_LATAM_SOCIO A
    WHERE A.SYLSV_TIP_DOC_LATAM = vTIP_DOC_LATAM AND A.SYLSV_NUM_DOC = PI_NUM_DOC;

      SELECT COUNT(*) INTO nCOUNT FROM SYSFT_LATAM_CANJE_KM_CC
    WHERE SYLCKCV_CTA_SOC_LATAM = vID_SOC_LATAM AND SYLCKCN_CC = PI_PTOS AND TRUNC(SYLCKCD_FEC_CANJE) = TRUNC(PI_FECHA)
    AND SYLCKCV_TIPO_CANJE = TRIM(PI_TIP_CANJE) AND SYLCKCC_ESTADO <> 'R';

    PO_COD_ERR := '0';
    PO_DES_ERR   := 'OK';

    IF nCOUNT > 0 THEN
      PO_COD_ERR := '2';
      PO_DES_ERR   := 'Socio Latam, ya tiene una canje para este día con la misma cantidad de puntos';
    END IF;

EXCEPTION
   WHEN OTHERS THEN
      PO_COD_ERR := '-1';
      PO_DES_ERR := 'ERROR => ' || TO_CHAR(SQLCODE) || ' : ' || SQLERRM;

END SYSFSS_VAL_SOL_CANJE;

PROCEDURE SYSFSU_LOTE_CANJE
            (PI_TIP_PROC      IN VARCHAR2,
             PI_ID_LOTE       in NUMBER,
             PI_CANT_REG      in NUMBER,
             PI_ESTADO        in VARCHAR2,
             PI_USU_REG       in VARCHAR2,
             PO_COD_ERR       out varchar2,
             PO_DES_ERR       out varchar2)

  /*
'****************************************************************************************************************
'* Nombre SP : SYSFSU_LOTE_CANJE
'* Propósito : Este procedimiento es responsable de actualizar el estado y los registros
               procesados por Latam (de CC a KM)
'* Input :     <Parametro>       -- Descripción de los parametros
              PI_TIP_PROC        -- Indicar tipo de proceso (F cuando lote se ha finalizado; E cuando lote hay error)
              PI_ID_LOTE         -- IdLote
              PI_CANT_REG        -- Cantidad de Registros que retorno Latam para el lote enviado
              PI_ESTADO          -- Estado a Actualizar  P (Pendiente); F (Finalizado)
              PI_USU_REG         -- Usuario
'* Output :    <Parametro>       -- Descripción de los parametros
               PO_COD_ERR        -- Codigo de error( 0 OK, 1 Error en parametros,
                                    -1 error oracle)
               PO_DES_ERR        -- Descripción del error
'* Creado por : SAPIA - Omar Campos
'* Fec Creación : 30/10/2017
'****************************************************************************************************************
*/

 is

  nCOUNT NUMBER;
BEGIN

    IF PI_TIP_PROC IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_TIP_PROC (F cuando lote se ha finalizado; E cuando lote hay error)';
      RETURN;
    END IF;

    IF PI_ID_LOTE IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_ID_LOTE';
      RETURN;
    END IF;

    IF LENGTH(TRIM(PI_ESTADO)) <= 0 OR PI_ESTADO IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_ESTADO';
      RETURN;
    END IF;

    IF LENGTH(TRIM(PI_USU_REG)) <= 0 OR PI_USU_REG IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_USU_REG';
      RETURN;
    END IF;

    IF PI_ESTADO <> 'P' AND PI_ESTADO <> 'F' THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'El Valor del parametro PI_ESTADO debe ser P (Pendiente); F (Finalizado)';
      RETURN;
    END IF;

    IF PI_TIP_PROC <> 'F' AND PI_TIP_PROC <> 'E' THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'El Valor del parametro PI_TIP_CANJE debe ser F o E';
      RETURN;
    END IF;

    SELECT COUNT(*) INTO nCOUNT FROM SYSFT_LATAM_LOTE_CANJE_KM_CC
    WHERE SYLLCKCN_ID_LOTE = PI_ID_LOTE;

    IF nCOUNT = 0 THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'No existe lote con numero de Lote ' || TO_CHAR(PI_ID_LOTE);
      RETURN;
    END IF;

    PO_COD_ERR := '0';
    PO_DES_ERR   := 'OK';

    IF PI_TIP_PROC = 'F' THEN
      IF PI_CANT_REG IS NULL THEN
        PO_COD_ERR := '1';
        PO_DES_ERR := 'Debe ingresar parametro PI_CANT_REG';
        RETURN;
      END IF;

      UPDATE SYSFT_LATAM_LOTE_CANJE_KM_CC
      SET SYLLCKCN_CANT_REG_RET = PI_CANT_REG, SYLLCKCC_ESTADO = PI_ESTADO,
      SYLLCKCD_FEC_MOD = SYSDATE, SYLLCKCV_USU_MOD = PI_USU_REG
      WHERE SYLLCKCN_ID_LOTE = PI_ID_LOTE;

    ELSE
      UPDATE SYSFT_LATAM_LOTE_CANJE_KM_CC
      SET SYLLCKCC_ESTADO = PI_ESTADO, SYLLCKCD_FEC_MOD = SYSDATE, SYLLCKCV_USU_MOD = PI_USU_REG
      WHERE SYLLCKCN_ID_LOTE = PI_ID_LOTE;

      UPDATE SYSFT_LATAM_CANJE_KM_CC A
      SET A.SYLCKCC_ESTADO = PI_ESTADO, A.SYLEKCD_FEC_MOD = SYSDATE, A.SYLEKCV_USU_MOD = PI_USU_REG
      WHERE A.SYLCKCN_ID_LOTE = PI_ID_LOTE;

    END IF;

EXCEPTION
   WHEN OTHERS THEN
      PO_COD_ERR := '-1';
      PO_DES_ERR := 'ERROR => ' || TO_CHAR(SQLCODE) || ' : ' || SQLERRM;

END SYSFSU_LOTE_CANJE;

PROCEDURE SYSFSU_CANJE_KMLATAMCC
            (PI_ACCOUNT_NUM       in VARCHAR2,
             PI_EST_ERR           in VARCHAR2,
             PI_COD_ERR           in VARCHAR2,
             PI_USU_REG           in VARCHAR2,
             PO_LINEA             OUT VARCHAR2,
             PO_CORREO            OUT VARCHAR2,
             PO_COD_APLI          OUT VARCHAR2,
             PO_PTO_CC            OUT NUMBER,
             PO_KM_LATAM          OUT NUMBER,
             PO_COD_ERR           out varchar2,
             PO_DES_ERR           out varchar2)

  /*
'****************************************************************************************************************
'* Nombre SP : SYSFSU_CANJE_KMLATAMCC
'* Propósito : Este procedimiento es responsable de actualizar el canje de puntos CC a KM
               datos retornados por Latam.
'* Input :     <Parametro>       -- Descripción de los parametros
              PI_ACCOUNT_NUM      -- El correlativo al que pertenece el registro
              PI_EST_ERR          -- Estado de Registro (Está Acreditado; Está Aceptado; Está con error)
              PI_COD_ERR          -- Codigo de error enviado por Latam
              PI_USU_REG          -- Usuario
'* Output :    <Parametro>       -- Descripción de los parametros
               PO_LINEA          -- Linea del canje para envio de mensaje
               PO_CORREO         -- Correo del canje
               PO_COD_APLI       -- Cod Aplicación que genero el canje
               PO_PTO_CC         -- Cantidad de Claro Puntos
               PO_KM_LATAM       -- Cantidad de KM Latam
               PO_COD_ERR        -- Codigo de error( 0 OK, 1 Error en parametros, 2 no hay registros a actualizar,
                                    3 canje ya procesado, -1 error oracle)
               PO_DES_ERR        -- Descripción del error
'* Creado por : SAPIA - Omar Campos
'* Fec Creación : 30/10/2017
'****************************************************************************************************************
*/

 is

nCOUNT NUMBER;

BEGIN

    IF LENGTH(TRIM(PI_ACCOUNT_NUM)) <= 0 OR PI_ACCOUNT_NUM IS NULL THEN
      PO_LINEA := '';
       PO_KM_LATAM := 0;
       PO_PTO_CC := 0;
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_ACCOUNT_NUM';
      RETURN;
    END IF;

    SELECT COUNT(*) INTO nCOUNT FROM SYSFT_LATAM_CANJE_KM_CC A
    WHERE A.SYLCKCN_ID_CANJE = PI_ACCOUNT_NUM;

    IF nCOUNT = 0 THEN
       PO_LINEA := '';
       PO_CORREO := '';
       PO_COD_APLI := '';
       PO_KM_LATAM := 0;
       PO_PTO_CC := 0;
       PO_COD_ERR := '2';
       PO_DES_ERR := 'No hay canje con secuencial ' || TO_CHAR(PI_ACCOUNT_NUM);
       RETURN;
    END IF;

    SELECT COUNT(*) INTO nCOUNT FROM SYSFT_LATAM_CANJE_KM_CC A
    WHERE A.SYLCKCN_ID_CANJE = PI_ACCOUNT_NUM 
          AND A.SYLCKCC_ESTADO = 'F' 
          AND A.SYLCKCC_EST_CANJE = '0';

    IF nCOUNT > 0 THEN
       PO_LINEA := '';
       PO_CORREO := '';
       PO_COD_APLI := '';
       PO_KM_LATAM := 0;
       PO_PTO_CC := 0;
       PO_COD_ERR := '3';
       PO_DES_ERR := 'Canje con secuencial ' || TO_CHAR(PI_ACCOUNT_NUM) || ' ya fue procesado.';
       RETURN;
    END IF;

    SELECT A.SYLCKCV_LINEA, A.SYLCKCV_CORREO, A.SYLCKCV_COD_APLI, A.SYLCKCN_KM_LATAM, A.SYLCKCN_CC
    INTO PO_LINEA, PO_CORREO, PO_COD_APLI, PO_KM_LATAM, PO_PTO_CC
    FROM SYSFT_LATAM_CANJE_KM_CC A
    WHERE A.SYLCKCN_ID_CANJE = PI_ACCOUNT_NUM;

    IF LENGTH(TRIM(PI_EST_ERR)) <= 0 OR PI_EST_ERR IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_EST_ERR';
      RETURN;
    END IF;

    IF LENGTH(TRIM(PI_COD_ERR)) <= 0 OR PI_COD_ERR IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_COD_ERR';
      RETURN;
    END IF;

    IF LENGTH(TRIM(PI_USU_REG)) <= 0 OR PI_USU_REG IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_USU_REG';
      RETURN;
    END IF;

    SELECT COUNT(*) INTO nCOUNT FROM SYSFT_LATAM_CANJE_KM_CC A
    WHERE A.SYLCKCN_ID_CANJE = PI_ACCOUNT_NUM;

    PO_COD_ERR := '0';
    PO_DES_ERR   := 'OK';

    UPDATE SYSFT_LATAM_CANJE_KM_CC
    SET SYLCKCC_ESTADO = 'F', SYLCKCC_EST_CANJE = PI_EST_ERR, SYLCKCV_COD_ERR_LATAM = PI_COD_ERR,
    SYLEKCD_FEC_MOD = SYSDATE, SYLEKCV_USU_MOD = PI_USU_REG
    WHERE SYLCKCN_ID_CANJE = PI_ACCOUNT_NUM;

EXCEPTION
   WHEN OTHERS THEN
      PO_COD_ERR := '-1';
      PO_DES_ERR := 'ERROR => ' || TO_CHAR(SQLCODE) || ' : ' || SQLERRM;

END SYSFSU_CANJE_KMLATAMCC;

PROCEDURE SYSFSS_CANJES_PENDIENTES
            (PI_ID_LOTE           in NUMBER,
             PI_NOM_ARCH          in VARCHAR2,
             PI_USUARIO           IN VARCHAR2,
             PO_ID_LOTE           OUT NUMBER,
             PO_REC_TYPE          OUT VARCHAR2,
             PO_COMPANY_ID        OUT VARCHAR2,
             PO_FILE_ID           OUT VARCHAR2,
             PO_CREATE_DATE       OUT VARCHAR2,
             PO_CUR_REG_PEND      out SYS_REFCURSOR,
             PO_COD_ERR           out VARCHAR2,
             PO_DES_ERR           out VARCHAR2)

  /*
'****************************************************************************************************************
'* Nombre SP : SYSFSS_CANJES_PENDIENTES
'* Propósito : Este procedimiento es responsable de retornar los registros pendientes
               por enviar a Latam o a demanda por IDLote.
'* Input :     <Parametro>       -- Descripción de los parametros
               PI_ID_LOTE        -- IDLote a enviar nuevamente (si es vacio significa que es un
                                    nuevo envio de pendientes, si no envia el lote que solicitan
               PI_USUARIO        -- Usuario
'* Output :    <Parametro>       -- Descripción de los parametros
               PO_ID_LOTE        -- IDLote que se ha creado o que se ha ingresado como PI
               PO_REC_TYPE       -- PO_REC_TYPE que se acaba de registrar
               PO_COMPANY_ID     -- PO_COMPANY_ID que se acaba de registrar
               PO_FILE_ID        -- PO_FILE_ID que se acaba de registrar
               PO_CREATE_DATE    -- PO_CREATE_DATE que se acaba de registrar
               PO_CUR_REG_PEND   -- Cursor con registros pendientes por enviar
               PO_COD_ERR        -- Codigo de error( 0 OK, 1 Error en parametros, 2 no hay canjes
                                    -1 error oracle)
               PO_DES_ERR        -- Descripción del error
'* Creado por : SAPIA - Omar Campos
'* Fec Creación : 30/10/2017
'****************************************************************************************************************
*/

 is

nID_LOTE NUMBER;
cID_COMPANY VARCHAR2(5);
nCOUNT_REG_CANJE NUMBER;
nCOUNT NUMBER;
cID_ARCHIVO VARCHAR2(9);
cPREFIJO VARCHAR2(10);
cTIPOARCHIVO CHAR(1);
cPI_NOM_ARCH VARCHAR2(30);

BEGIN
    IF PI_ID_LOTE IS NOT NULL AND PI_ID_LOTE > 0 THEN
      nID_LOTE := PI_ID_LOTE;

      SELECT COUNT(*) INTO nCOUNT FROM SYSFT_LATAM_LOTE_CANJE_KM_CC
      WHERE SYLLCKCN_ID_LOTE = nID_LOTE AND SYLLCKCC_ESTADO = 'F';

      IF nCOUNT = 0 THEN
         PO_COD_ERR := '2';
         PO_DES_ERR := 'No hay canjes por enviar';
         PO_REC_TYPE := '';
         PO_COMPANY_ID := '';
         PO_FILE_ID := '';
         PO_CREATE_DATE := '';
         PO_ID_LOTE := '0';
         OPEN PO_CUR_REG_PEND FOR
         SELECT '' REC_TYPE, '' ID_CANJE, '' Program_ID, '' Activity_Date,
         '' Points, '' NameSoc, '' Account_Number, '' Location_ID,
         '' Location_Desc, '' Partner_Sequence_Num, '' Days
         FROM DUAL;
         RETURN;
      END IF;

    ELSE

      SELECT COUNT(*) INTO nCOUNT_REG_CANJE
      FROM SYSFT_LATAM_CANJE_KM_CC WHERE SYLCKCC_ESTADO = 'P'
      AND SYLCKCV_TIPO_CANJE = 'CK';

      IF nCOUNT_REG_CANJE = 0 THEN
         PO_COD_ERR := '2';
         PO_DES_ERR := 'No hay canjes por enviar';
         PO_REC_TYPE := '';
         PO_COMPANY_ID := '';
         PO_FILE_ID := '';
         PO_CREATE_DATE := '';
         PO_ID_LOTE := '0';
         OPEN PO_CUR_REG_PEND FOR
         SELECT '' REC_TYPE, '' ID_CANJE, '' Program_ID, '' Activity_Date,
         '' Points, '' NameSoc, '' Account_Number, '' Location_ID,
         '' Location_Desc, '' Partner_Sequence_Num, '' Days
         FROM DUAL;
         RETURN;
      END IF;

      SELECT COUNT(*) INTO nCOUNT FROM
      ADMPT_PARAMSIST WHERE ADMPV_DESC = 'LATAM COMPANY ID SYSFT_LATAM_LOTE_CANJE_KM_CC';

      IF nCOUNT = 0 THEN
         PO_COD_ERR := '1';
         PO_DES_ERR := 'No esta configurado LATAM COMPANY ID en la tabla ADMPT_PARAMSIST';
         PO_REC_TYPE := '';
         PO_COMPANY_ID := '';
         PO_FILE_ID := '';
         PO_CREATE_DATE := '';
         PO_ID_LOTE := '0';
         OPEN PO_CUR_REG_PEND FOR
         SELECT '' REC_TYPE, '' ID_CANJE, '' Program_ID, '' Activity_Date,
         '' Points, '' NameSoc, '' Account_Number, '' Location_ID,
         '' Location_Desc, '' Partner_Sequence_Num, '' Days
         FROM DUAL;
         RETURN;
      END IF;

      SELECT ADMPV_VALOR INTO cID_COMPANY FROM
      ADMPT_PARAMSIST WHERE ADMPV_DESC = 'LATAM COMPANY ID SYSFT_LATAM_LOTE_CANJE_KM_CC';

      cID_ARCHIVO := SUBSTR(cID_COMPANY,-3)||'CR0001';

      SELECT COUNT(*) INTO nCOUNT FROM
      ADMPT_PARAMSIST WHERE ADMPV_DESC = 'LATAM PREFIJO SYSFT_LATAM_LOTE_CANJE_KM_CC';

      IF nCOUNT = 0 THEN
         PO_COD_ERR := '1';
         PO_DES_ERR := 'No esta configurado LATAM PREFIJO en la tabla ADMPT_PARAMSIST';
         PO_REC_TYPE := '';
         PO_COMPANY_ID := '';
         PO_FILE_ID := '';
         PO_CREATE_DATE := '';
         PO_ID_LOTE := '0';
         OPEN PO_CUR_REG_PEND FOR
         SELECT '' REC_TYPE, '' ID_CANJE, '' Program_ID, '' Activity_Date,
         '' Points, '' NameSoc, '' Account_Number, '' Location_ID,
         '' Location_Desc, '' Partner_Sequence_Num, '' Days
         FROM DUAL;
         RETURN;
      END IF;

      SELECT ADMPV_VALOR INTO cPREFIJO FROM
      ADMPT_PARAMSIST WHERE ADMPV_DESC = 'LATAM COMPANY ID SYSFT_LATAM_LOTE_CANJE_KM_CC';

      SELECT COUNT(*) INTO nCOUNT FROM
      ADMPT_PARAMSIST WHERE ADMPV_DESC = 'LATAM TIPO ARCHIVO SYSFT_LATAM_LOTE_CANJE_KM_CC';

      IF nCOUNT = 0 THEN
         PO_COD_ERR := '1';
         PO_DES_ERR := 'No esta configurado LATAM TIPO ARCHIVO en la tabla ADMPT_PARAMSIST';
         PO_REC_TYPE := '';
         PO_COMPANY_ID := '';
         PO_FILE_ID := '';
         PO_CREATE_DATE := '';
         PO_ID_LOTE := '0';
         OPEN PO_CUR_REG_PEND FOR
         SELECT '' REC_TYPE, '' ID_CANJE, '' Program_ID, '' Activity_Date,
         '' Points, '' NameSoc, '' Account_Number, '' Location_ID,
         '' Location_Desc, '' Partner_Sequence_Num, '' Days
         FROM DUAL;
         RETURN;
      END IF;

      SELECT ADMPV_VALOR INTO cTIPOARCHIVO FROM
      ADMPT_PARAMSIST WHERE ADMPV_DESC = 'LATAM TIPO ARCHIVO SYSFT_LATAM_LOTE_CANJE_KM_CC';

      cPI_NOM_ARCH := TRIM(cPREFIJO)||TRIM(cTIPOARCHIVO)||TO_CHAR(SYSDATE,'YYYYMMDD');

      SELECT SYSFSQ_LATAM_LOTE.NEXTVAL INTO nID_LOTE FROM DUAL;

      INSERT INTO SYSFT_LATAM_LOTE_CANJE_KM_CC ( SYLLCKCN_ID_LOTE, SYLLCKCV_ID_COMPANY, SYLLCKCV_ID_ARCHIVO, SYLLCKCN_CANT_REG, SYLLCKCV_NOM_ARCHIVO, SYLLCKCV_USU_REG )
      VALUES (nID_LOTE, cID_COMPANY, cID_ARCHIVO, nCOUNT_REG_CANJE, cPI_NOM_ARCH, PI_USUARIO);

      UPDATE SYSFT_LATAM_CANJE_KM_CC
      SET SYLCKCN_ID_LOTE = nID_LOTE, SYLCKCC_ESTADO = 'E', SYLEKCD_FEC_MOD = SYSDATE, SYLEKCV_USU_MOD = PI_USUARIO
      WHERE SYLCKCC_ESTADO = 'P' AND SYLCKCV_TIPO_CANJE = 'CK';
    END IF;

    SELECT A.SYLLCKCC_TIP_REG_LATAM, A.SYLLCKCV_ID_COMPANY, A.SYLLCKCV_ID_ARCHIVO, SUBSTR(A.SYLLCKCV_FEC_CREA_ARCH,1,8)
    INTO PO_REC_TYPE, PO_COMPANY_ID, PO_FILE_ID, PO_CREATE_DATE
    FROM SYSFT_LATAM_LOTE_CANJE_KM_CC A
    WHERE SYLLCKCN_ID_LOTE = nID_LOTE;

    PO_ID_LOTE:= nID_LOTE;

    OPEN PO_CUR_REG_PEND FOR
    SELECT A.SYLCKCC_TIP_REG_LATAM REC_TYPE, A.SYLCKCN_ID_CANJE ID_CANJE, A.SYLCKCV_ID_PROG_LATAM Program_ID, SUBSTR(A.SYLCKCV_FEC_CANJE,1,8) Activity_Date,
    A.SYLCKCN_KM_LATAM Points, A.SYLCKCV_NOM_CLI NameSoc, A.SYLCKCV_CTA_SOC_LATAM Account_Number, NVL(A.SYLCKCV_LOCATIONID, ' ') Location_ID,
    NVL(A.SYLCKCV_LOCATIONDESC, ' ') Location_Desc, A.SYLCKCV_CORRELATIVO Partner_Sequence_Num, NVL(A.SYLCKCV_DIAS, ' ') Days
    FROM SYSFT_LATAM_CANJE_KM_CC A
    WHERE A.SYLCKCN_ID_LOTE = nID_LOTE AND SYLCKCV_TIPO_CANJE = 'CK';

    PO_COD_ERR := '0';
    PO_DES_ERR   := 'OK';

EXCEPTION
   WHEN OTHERS THEN
      PO_REC_TYPE := '';
      PO_COMPANY_ID := '';
      PO_FILE_ID := '';
      PO_CREATE_DATE := '';
      PO_ID_LOTE := '0';
      OPEN PO_CUR_REG_PEND FOR
      SELECT '' REC_TYPE, '' ID_CANJE, '' Program_ID, '' Activity_Date,
      '' Points, '' NameSoc, '' Account_Number, '' Location_ID,
      '' Location_Desc, '' Partner_Sequence_Num, '' Days
      FROM DUAL;
      PO_COD_ERR := '-1';
      PO_DES_ERR := 'ERROR => ' || TO_CHAR(SQLCODE) || ' : ' || SQLERRM;

END SYSFSS_CANJES_PENDIENTES;

PROCEDURE SYSFSS_CANJES_TODOS
            (PI_TIP_CANJE         in VARCHAR2,
             PI_LINEA             in VARCHAR2,
             PI_CORREO            in VARCHAR2,
             PI_FEC_INI           in DATE,
             PI_FEC_FIN           in DATE,
             PI_ESTADO            in VARCHAR2,
             PI_TIP_DOC           in VARCHAR2,
             PI_NUM_DOC           IN VARCHAR2,
             PI_COD_APLI          IN VARCHAR2,
             PI_NOMBRE_ARCHIVO    IN VARCHAR2,
             PI_ESTADO_CANJE      IN VARCHAR2,             
             PO_CUR_REG           out SYS_REFCURSOR,
             PO_COD_ERR           out varchar2,
             PO_DES_ERR           out varchar2)

  /*
'****************************************************************************************************************
'* Nombre SP : SYSFSS_CANJES_TODOS
'* Propósito : Este procedimiento retornara la consulta de canjes.
'* Input :     <Parametro>       -- Descripción de los parametros
               PI_TIP_CANJE      -- Tipo de canje: CK si es de Claro puntos a KM y
                                    KC si es de KM a Claro Puntos
               PI_FEC_INI        -- Fecha de inicio de consulta
               PI_FEC_FIN        -- Fecha de fin de consulta
               PI_ESTADO         -- Estado P (Pendiente); E (Enviado); F (Finalizado)
               PI_TIP_DOC        -- Tipo de documento de Cliente Claro Club
               PI_NUM_DOC        -- Numero de documento de Cliente Claro Club
'* Output :    <Parametro>       -- Descripción de los parametros
               PO_CUR_REG        -- Cursor con registros pendientes por enviar
               PO_COD_ERR        -- Codigo de error( 0 OK, 1 Error en parametros,
                                    -1 error oracle)
               PO_DES_ERR        -- Descripción del error
'* Creado por : SAPIA - Omar Campos
'* Fec Creación : 30/10/2017
'****************************************************************************************************************
*/

 is

vSELECT VARCHAR2(4000) := '';
vWHERE VARCHAR2(4000) := '';
vORDER VARCHAR2(500) := '';

BEGIN

  -- Parametro: Fecha Inicio y Fecha Fin
  IF (PI_FEC_INI IS NULL OR PI_FEC_FIN IS NULL) THEN
   
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar ambas fechas';
    
      OPEN PO_CUR_REG FOR
      SELECT '' TipoCanje, '' Linea, '' Correo, '' NomApell, '' TipDoc, '' NroDoc, '' CodSocLatam,
     '' ClaroPuntos, '' KMLatam, '' FechaHorReg, '' Estado, '' CodApli, '' DescApli,
     '' MsgResp, '' PtosMovDesc, '' PtosFijosDesc, '' NombreArchivo, '' CodErrorLatam, '' DescErrorLatam FROM DUAL WHERE ROWNUM = 0;
    
    RETURN;
  ELSIF PI_FEC_INI > PI_FEC_FIN THEN
  
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Fecha inicial no puede ser mayor a fecha fin';
  
      OPEN PO_CUR_REG FOR
      SELECT '' TipoCanje, '' Linea, '' Correo, '' NomApell, '' TipDoc, '' NroDoc, '' CodSocLatam,
       '' ClaroPuntos, '' KMLatam, '' FechaHorReg, '' Estado, '' CodApli, '' DescApli,
       '' MsgResp, '' PtosMovDesc, '' PtosFijosDesc, '' NombreArchivo, '' CodErrorLatam, '' DescErrorLatam FROM DUAL WHERE ROWNUM = 0;
        
      RETURN;
  ELSE
      vWHERE := ' WHERE TRUNC(A.SYLCKCD_FEC_CANJE) BETWEEN ''' || PI_FEC_INI || ''' AND ''' || PI_FEC_FIN || ''' ';
    END IF;

  -- Parametro: Tipo de Canje
  IF LENGTH(TRIM(PI_TIP_CANJE)) > 0 THEN
    vWHERE := vWHERE || ' AND A.SYLCKCV_TIPO_CANJE = ''' || PI_TIP_CANJE || ''' ';
  END IF;

  -- Parametro: Linea
  IF LENGTH(TRIM(PI_LINEA)) > 0 THEN
      vWHERE := vWHERE || ' AND A.SYLCKCV_LINEA = ''' || PI_LINEA || ''' ';
  END IF;

  -- Parametro: Correo
  IF LENGTH(TRIM(PI_CORREO)) > 0 THEN
      vWHERE := vWHERE || ' AND UPPER(A.SYLCKCV_CORREO) = ''' || UPPER(PI_CORREO) || ''' ';
  END IF;

  -- Parametro: Estado
  IF LENGTH(TRIM(PI_ESTADO)) > 0 THEN
      vWHERE := vWHERE || ' AND A.SYLCKCC_ESTADO = ''' || PI_ESTADO || ''' ';
    END IF;
  
  -- Parametro: Estado Canje
  IF LENGTH(TRIM(PI_ESTADO_CANJE)) > 0 THEN
      vWHERE := vWHERE || ' AND A.SYLCKCC_EST_CANJE = ''' || PI_ESTADO_CANJE || ''' ';
  END IF;

  -- Parametro: Nombre Archivo
  IF LENGTH(TRIM(PI_NOMBRE_ARCHIVO)) > 0 THEN
      vWHERE := vWHERE || ' AND A.sylckcv_nom_archivo = ''' || PI_NOMBRE_ARCHIVO || ''' ';
    END IF;
  -- Parametro: Tipo Doc
  IF LENGTH(TRIM(PI_TIP_DOC)) > 0 THEN
      vWHERE := vWHERE || ' AND A.SYLCKCV_TIP_DOC = ''' || PI_TIP_DOC || ''' ';
  END IF;

  -- Parametro: Num Doc
  IF LENGTH(TRIM(PI_NUM_DOC)) > 0 THEN
      vWHERE := vWHERE || ' AND A.SYLCKCV_NUM_DOC = ''' || PI_NUM_DOC || ''' ';
  END IF;

  -- Parametro: Cod Apli
  IF LENGTH(TRIM(PI_COD_APLI)) > 0 THEN
      vWHERE := vWHERE || ' AND A.SYLCKCV_COD_APLI = ''' || PI_COD_APLI || ''' ';
  END IF;

  -- Se arma el select
  vSELECT := 'SELECT A.SYLCKCN_ID_CANJE IdCanje,
       NVL(C.SYLCV_DESCRIPCION, A.SYLCKCV_TIPO_CANJE) TipoCanje,
       A.SYLCKCV_LINEA Linea,
       A.SYLCKCV_CORREO Correo,
       A.SYLCKCV_NOM_CLI NomApell,
       NVL(TD.admpv_dsc_docum, A.SYLCKCV_TIP_DOC) TipDoc,
       A.SYLCKCV_NUM_DOC NroDoc,
       A.SYLCKCV_CTA_SOC_LATAM CodSocLatam,
       A.SYLCKCN_CC ClaroPuntos,
       A.SYLCKCN_KM_LATAM KMLatam,     
       A.SYLCKCD_FEC_CANJE FechaHorReg,
       CASE
         WHEN A.SYLCKCC_ESTADO = ''F'' THEN
          DECODE(A.SYLCKCC_EST_CANJE, ''0'', ''FINALIZADO CON EXITO'', ''1'', ''FINALIZADO CON ERROR'', ''2'', ''FINALIZADO CON ERROR - FALLO DEV. DE PUNTOS'', ''FINALIZADO OTROS'')
         ELSE         
          DECODE(A.SYLCKCC_ESTADO, ''S'', ''ESPERA'', ''V'', ''VENCIDO'', ''P'', ''PENDIENTE'', ''E'', ''ENVIADO'', ''R'', ''ERROR'', A.SYLCKCC_ESTADO)
       END Estado,
       A.SYLCKCV_COD_APLI CodApli,
       NVL(TA.ADMPV_DES_TIPAPL, A.SYLCKCV_COD_APLI) DescApli,
       A.sylckcv_msg_resp MsgResp,
       CASE
         WHEN A.SYLCKCV_TIPO_CANJE IN (''CK'') THEN
          (SELECT  NVL(SUM(CP.sylckcpn_puntos), 0)
             FROM PCLUB.SYSFT_LATAM_CANJE_KM_CC_PROD CP
            WHERE CP.sylckcpn_id_grp_canje = A.sylckcn_id_grp_canje
              AND CP.sylckcpc_tbl_cli = ''M'')
         ELSE
          0
       END PtosMovDesc,
       CASE
         WHEN A.SYLCKCV_TIPO_CANJE IN (''CK'') THEN
          (SELECT  NVL(SUM(CP.sylckcpn_puntos), 0)
             FROM PCLUB.SYSFT_LATAM_CANJE_KM_CC_PROD CP
            WHERE CP.sylckcpn_id_grp_canje = A.sylckcn_id_grp_canje
              AND CP.sylckcpc_tbl_cli = ''F'')
         ELSE
          0
       END PtosFijosDesc,
       A.sylckcv_nom_archivo NombreArchivo,
       LTRIM(A.SYLCKCV_COD_ERR_LATAM, ''_0'') CodErrorLatam,
       E.SYLEAV_DES_ERR DescErrorLatam
       FROM PCLUB.SYSFT_LATAM_CANJE_KM_CC A
        LEFT JOIN PCLUB.SYSFT_LATAM_CAMPANA C
          ON C.SYLCV_COD_CAMPANA = A.SYLCKCV_TIPO_CANJE
        LEFT JOIN PCLUB.SYSFT_LATAM_ERROR_ACREDITA E
          ON E.SYLEAV_COD_ERR = LTRIM(A.SYLCKCV_COD_ERR_LATAM, ''_0'')
        LEFT JOIN PCLUB.Admpt_Tipo_Aplic TA
          ON TA.ADMPV_COD_TIPAPL = A.SYLCKCV_COD_APLI
        LEFT JOIN PCLUB.ADMPT_TIPO_DOC TD
          ON TD.admpv_cod_tpdoc = A.SYLCKCV_TIP_DOC';

  vORDER := ' ORDER BY FechaHorReg, NroDoc ';

  OPEN PO_CUR_REG FOR vSELECT || vWHERE || vORDER;

  PO_COD_ERR := '0';
  PO_DES_ERR   := 'OK';

EXCEPTION
   WHEN OTHERS THEN
     PO_COD_ERR := '-1';
     PO_DES_ERR := 'ERROR => ' || TO_CHAR(SQLCODE) || ' : ' || SQLERRM;

     OPEN PO_CUR_REG FOR
     SELECT '' TipoCanje, '' Linea, '' Correo, '' NomApell, '' TipDoc, '' NroDoc, '' CodSocLatam,
     '' ClaroPuntos, '' KMLatam, '' FechaHorReg, '' Estado, '' CodApli, '' DescApli,
     '' MsgResp, '' PtosMovDesc, '' PtosFijosDesc, '' NombreArchivo, '' CodErrorLatam, '' DescErrorLatam FROM DUAL WHERE ROWNUM = 0;         

END SYSFSS_CANJES_TODOS;

PROCEDURE SYSFSS_PTOS_ACUM_CLI
            (PI_TIP_DOC           in VARCHAR2,
             PI_NUM_DOC           IN VARCHAR2,
             PO_PUNTOS            out NUMBER,
             PO_COD_ERR           out varchar2,
             PO_DES_ERR           out varchar2)

  /*
'****************************************************************************************************************
'* Nombre SP : SYSFSS_PTOS_ACUM_CLI
'* Propósito : Este procedimiento retornara puntos para canje por cliente.
'* Input :     <Parametro>       -- Descripción de los parametros
               PI_TIP_DOC        -- Tipo de documento de Cliente Claro Club
               PI_NUM_DOC        -- Numero de documento de Cliente Claro Club
'* Output :    <Parametro>       -- Descripción de los parametros
               PO_PUNTOS         -- Puntos disponibles del cliente
               PO_CUR_REG        -- Cursor con registros pendientes por enviar
               PO_COD_ERR        -- Codigo de error( 0 OK, 1 Error en parametros,
                                    -1 error oracle)
               PO_DES_ERR        -- Descripción del error
'* Creado por : SAPIA - Omar Campos
'* Fec Creación : 30/10/2017
'****************************************************************************************************************
*/

 is

CURSOR cCOD_CLI(vTIP_DOC VARCHAR2, vNUM_DOC VARCHAR2) IS  SELECT ADMPV_COD_CLI FROM PCLUB.admpt_cliente
WHERE admpv_tipo_doc = vTIP_DOC AND admpv_num_doc = vNUM_DOC AND admpc_estado = 'A';

nSALDO NUMBER := 0;

nSAL_PTOS_M NUMBER;
nCODERR_M NUMBER;
vDESERR_M VARCHAR2(255);

nSAL_PTOS_F NUMBER := 0;
nCODERR_F NUMBER;
vDESERR_F VARCHAR2(255);
vCOD_CLI_RES VARCHAR2(40);

vFIJA_TIP_DOC VARCHAR2(10);
nCOUNT INTEGER;

BEGIN

    IF LENGTH(TRIM(PI_TIP_DOC)) <= 0 OR PI_TIP_DOC IS NULL THEN
      PO_PUNTOS := 0;
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_TIP_DOC';
      RETURN;
    END IF;

    IF LENGTH(TRIM(PI_NUM_DOC)) <= 0 OR PI_NUM_DOC IS NULL THEN
      PO_PUNTOS := 0;
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_NUM_DOC';
      RETURN;
    END IF;

    FOR COD_CLI IN cCOD_CLI(PI_TIP_DOC, PI_NUM_DOC) LOOP
      vCOD_CLI_RES := COD_CLI.ADMPV_COD_CLI;
      PKG_CC_CANJE_LATAM.SYSFS_PTOS_X_CLIENTE('', vCOD_CLI_RES, '', '', nSAL_PTOS_M, nCODERR_M, vDESERR_M);
      nSALDO := nSALDO + nSAL_PTOS_M;
    END LOOP;

    SELECT count(1) INTO nCOUNT FROM PCLUB.ADMPT_TIPO_DOC T
    WHERE T.ADMPV_EQU_FIJA=PI_TIP_DOC;

    IF nCOUNT > 0 THEN
      vFIJA_TIP_DOC := PI_TIP_DOC;
    ELSE
      SELECT count(1) INTO nCOUNT FROM PCLUB.ADMPT_TIPO_DOC T
      WHERE T.ADMPV_COD_TPDOC = PI_TIP_DOC;

      IF nCOUNT > 0 THEN
        SELECT T.ADMPV_EQU_FIJA INTO vFIJA_TIP_DOC FROM PCLUB.ADMPT_TIPO_DOC T
        WHERE T.ADMPV_COD_TPDOC = PI_TIP_DOC;
      ELSE
        vFIJA_TIP_DOC := PI_TIP_DOC;
      END IF;
    END IF;

    PKG_CC_TRANSACCIONFIJA.ADMPSS_CONSALDO(vFIJA_TIP_DOC, PI_NUM_DOC, nSAL_PTOS_F, nCODERR_F, vDESERR_F);

    PO_PUNTOS := nSALDO + NVL(nSAL_PTOS_F,0);
    PO_COD_ERR := '0';
    PO_DES_ERR := 'OK';


EXCEPTION
   WHEN OTHERS THEN
     PO_PUNTOS := 0;
     PO_COD_ERR := '-1';
     PO_DES_ERR := 'ERROR => ' || TO_CHAR(SQLCODE) || ' : ' || SQLERRM;
END SYSFSS_PTOS_ACUM_CLI;

PROCEDURE SYSFSD_CANJE_MLATAMCC(
             PI_IDCANJE  IN NUMBER,
             PI_USUARIO  IN VARCHAR2,
             PO_COD_ERR  OUT varchar2,
             PO_DES_ERR  OUT varchar2)

/*
'****************************************************************************************************************
'* Nombre SP : SYSFSD_CANJE_MLATAMCC
'* Propósito : Este procedimiento su usa para retornar puntos en caso falle proceso de acreditación.
'* Input :     <Parametro>       -- Descripción de los parametros
               PI_IDCANJE        -- Es el valor del campo SYLCKCN_ID_CANJE identificador de la
                                    tabla SYSFT_LATAM_CANJE_KM_CC
               PI_USUARIO        -- Usuario
'* Output :    <Parametro>       -- Descripción de los parametros
               PO_COD_ERR        -- Codigo de error( 0 OK, 1 Error en parametros,
                                    -1 error oracle)
               PO_DES_ERR        -- Descripción del error
'* Creado por : SAPIA - Omar Campos
'* Fec Creación : 30/10/2017
'****************************************************************************************************************
*/

 IS

CURSOR cGRP_CANJE_PROD (nID_GRP_CANJE NUMBER) IS SELECT A.SYLCKCPN_ITEM, NVL(A.SYLCKCPN_ID_CANJE, 0) SYLCKCPN_ID_CANJE,
A.SYLCKCPC_TBL_CLI, NVL(A.SYLCKCPN_ID_KARDEX, 0) SYLCKCPN_ID_KARDEX FROM SYSFT_LATAM_CANJE_KM_CC_PROD A
WHERE A.SYLCKCPN_ID_GRP_CANJE = nID_GRP_CANJE;

nIDGRP NUMBER;
nID_CANJE NUMBER;
nCOUNT NUMBER;
vTBL_CLI CHAR(1);
nITEM_GRP NUMBER;
nDEL_EXITO NUMBER;
nDEL_COD_ERROR NUMBER;
vDEL_DESCERROR VARCHAR2(255);

nID_KARDEX NUMBER;
nID_KARDEX_NEW NUMBER;


BEGIN

  IF PI_IDCANJE <= 0 OR PI_IDCANJE IS NULL THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_IDCANJE';
    RETURN;
  END IF;

  IF LENGTH(TRIM(PI_USUARIO)) <= 0 OR PI_USUARIO IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_USUARIO';
      RETURN;
    END IF;

  SELECT COUNT(1) INTO nCOUNT FROM SYSFT_LATAM_CANJE_KM_CC SLCKC
  WHERE SLCKC.SYLCKCN_ID_CANJE = PI_IDCANJE AND SLCKC.SYLCKCC_ESTADO = 'P';

  IF nCOUNT = 0 THEN
    PO_COD_ERR := '2';
    PO_DES_ERR := 'No hay registros pendientes por Compensar';
    RETURN;
  END IF;

  PO_COD_ERR := '0';
  PO_DES_ERR := 'OK';

  SELECT SLCKC.SYLCKCN_ID_GRP_CANJE INTO nIDGRP FROM SYSFT_LATAM_CANJE_KM_CC SLCKC
  WHERE SLCKC.SYLCKCN_ID_CANJE = PI_IDCANJE AND SLCKC.SYLCKCC_ESTADO = 'P';

  FOR GRP_CANJE_PROD IN cGRP_CANJE_PROD(nIDGRP) LOOP
    nITEM_GRP := GRP_CANJE_PROD.SYLCKCPN_ITEM;
    nID_CANJE := GRP_CANJE_PROD.SYLCKCPN_ID_CANJE;
    vTBL_CLI := GRP_CANJE_PROD.SYLCKCPC_TBL_CLI;
    nID_KARDEX := GRP_CANJE_PROD.SYLCKCPN_ID_KARDEX;
    
    --ELIMINANDO CANJE
    IF nID_CANJE <> 0 THEN
    -- REALIZAR COMPENSACION DEL REGISTRO DEL CANJE (LIMPIAR DATA)
    IF vTBL_CLI = 'M' THEN
    PCLUB.PKG_CC_TRANSACCION.ADMPSS_ELIMINARCANJE(nID_CANJE, nDEL_EXITO, nDEL_COD_ERROR, vDEL_DESCERROR);
    END IF;
    IF vTBL_CLI = 'F' THEN
      PCLUB.PKG_CC_TRANSACCIONFIJA.ADMPSS_ELIMINARCANJE (nID_CANJE, nDEL_EXITO, nDEL_COD_ERROR, vDEL_DESCERROR);
    END IF;
    --SI SE REALIZA CON EXITO
    IF nDEL_EXITO =  1 THEN
      UPDATE SYSFT_LATAM_CANJE_KM_CC_PROD A
      SET A.SYLCKCPC_ESTADO = 'F', A.SYLCKCPD_FEC_MOD = SYSDATE, A.SYLCKCPV_USU_MOD = PI_USUARIO
      WHERE A.SYLCKCPN_ID_GRP_CANJE = nIDGRP AND A.SYLCKCPN_ITEM = nITEM_GRP;
    ELSE
      --ERROR
      PO_COD_ERR := '3';
      PO_DES_ERR := 'Fallo la compensación de Canje, reintentar nuevamente';
    END IF;
    END IF;
    
    --ELIMINANDO KARDEX
    IF nID_KARDEX <> 0 THEN
      SYSFSD_KRDX_MLATAMCC_FALLO(nID_KARDEX, vTBL_CLI, PI_USUARIO, nID_KARDEX_NEW, nDEL_COD_ERROR, vDEL_DESCERROR); 
      IF nDEL_COD_ERROR = 0 THEN
        --ACTUALIZA EL REGISTRO DEL GRUPO DE KARDEX CON EL ID KARDEX CON EL QUE SE ESTA ANULANDO
         UPDATE SYSFT_LATAM_CANJE_KM_CC_PROD SET SYLCKCPN_ID_KRDX_ANULA = nID_KARDEX_NEW
         WHERE SYLCKCPN_ID_GRP_CANJE = nIDGRP AND SYLCKCPN_ITEM = nITEM_GRP;
      ELSE
        PO_COD_ERR := '101';
        PO_DES_ERR := 'ERROR => ' || vDEL_DESCERROR;
        RETURN;
      END IF;
    END IF;
  END LOOP;
  COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      PO_COD_ERR := '-1';
      PO_DES_ERR := 'ERROR => ' || TO_CHAR(SQLCODE) || ' : ' || SQLERRM;

END SYSFSD_CANJE_MLATAMCC;

PROCEDURE SYSFSS_CANJPROD_KMLATAMCC (K_ID_SOLICITUD IN VARCHAR2,
                            K_TIPO_DOC     IN VARCHAR2,
                            K_NUM_DOC      IN VARCHAR2,
                            K_PUNTOS       IN NUMBER,
                            K_COD_APLI     IN VARCHAR2,
                            K_NUM_LINEA    IN     VARCHAR2,
                            K_COD_ASESOR       IN     VARCHAR2,
                            K_NOM_ASESOR       IN     VARCHAR2,
                            K_MENSAJE      IN VARCHAR2,
                            PI_USUARIO     IN VARCHAR2,
                            K_CODERROR     OUT NUMBER,
                            K_MSJERROR     OUT VARCHAR2,
                            K_GRP_CANJE    OUT NUMBER)

/*
'****************************************************************************************************************
'* Nombre SP : SYSFSS_CANJPROD_KMLATAMCC
'* Propósito : Este procedimiento su usa para realizar el canje de puntos.
'* Input :     <Parametro>       -- Descripción de los parametros
               K_TIPO_DOC        -- Tipo documento
               K_NUM_DOC         -- Numero de documento
               K_PUNTOS          -- Puntos a canjear
               K_COD_APLI        -- Codigo de aplicativo que realiza el canje
               K_NUM_LINEA       -- Numero de Línea
               K_COD_ASESOR      -- Codigo de Asesor
               K_NOM_ASESOR      -- Nombre de Asesor
               K_MENSAJE         -- Mensaje
               PI_USUARIO        -- Usuario
'* Output :    <Parametro>       -- Descripción de los parametros
               K_CODERROR        -- Codigo de error
               K_MSJERROR        -- Descripción del error
               K_GRP_CANJE       -- Grupo de Canje
'* Creado por : SAPIA - Omar Campos
'* Fec Creación : 30/10/2017
'****************************************************************************************************************
*/
IS

    vID_SOLIC VARCHAR2(20);

    V_COD_CANJE NUMBER;
    V_SEC               NUMBER  := 1;
    V_DESC_PREMIO       VARCHAR2(150);
    V_PUNTOS_REQUERIDOS NUMBER := 0;
    V_NUM_DOC           VARCHAR2(20);
    V_SALDO NUMBER;
    NO_CLIENTE EXCEPTION;
    NO_EVENTO EXCEPTION;
    NO_SALDO EXCEPTION;
    NO_SALDO_CANJE EXCEPTION;
    NO_DESC_PUNTOS EXCEPTION;
    NO_PARAMETROS EXCEPTION;
    NO_COD_APLICACION EXCEPTION;
    NO_SLD_KDX_ALINEADO EXCEPTION;
    NO_DATOS_VALIDOS EXCEPTION;
    V_CODERROR  NUMBER;
    V_COD_CPTO  NUMBER;
    V_DESCERROR VARCHAR2(400);
    EX_BLOQUEO EXCEPTION;
    EX_DESBLOQUEO EXCEPTION;
    NO_VALBLOQUEO EXCEPTION;
    NO_LIBERADO EXCEPTION;
    K_ESTADO CHAR(1);
    K_CODERROR_EX  NUMBER;
    K_MSJERROR_EX VARCHAR2(400);
    V_CAMPANA    VARCHAR2(150);
    V_PAGO   NUMBER;
    V_TIPOPREMIO   VARCHAR2(2);
    V_SERVCOMERCIAL   NUMBER;
    V_MONTORECARGA   NUMBER;
    V_CODPAGDAT   VARCHAR2(50);
    V_PRODID   VARCHAR2(15);

  CURSOR cTIP_CLI IS 
    select DISTINCT T.ADMPV_COD_TPOCL,
           T.ADMPV_DESC,
           T.ADMPC_ESTADO,
           T.ADMPV_TIPO,
           T.ADMPC_TBLCLIENTE
    from admpt_tipo_cliente t
     where ((T.ADMPV_TIPO IN ('PREPAGO', 'POSTPAGO') AND
           T.ADMPC_TBLCLIENTE = 'M') OR T.ADMPC_TBLCLIENTE = 'F')
    AND T.ADMPC_ESTADO = 'A'
     ORDER BY DECODE(T.ADMPV_TIPO, 'POSTPAGO', 1, 2),
              DECODE(T.admpc_tblcliente, 'M', 1, 2),
              T.ADMPV_COD_TPOCL;

    vDESC VARCHAR2(50);
    vTIPO VARCHAR2(20);
    vTBLCLIENTE CHAR(1);
    nCOUNT NUMBER;
    K_TIP_CLI VARCHAR2(3);
    K_PRO_ID VARCHAR2(15);
    K_CLAVE CHAR(1) := '';
    K_PUNTOVENTA CHAR(1) := '';
    K_TIPCANJE NUMBER;
    K_TIPPRECANJE NUMBER;
    vFLAG_CLIENTE CHAR(1) := '0';
    vFLAG_SALDO CHAR(1) := '0';
    nPUNTOS_CANJEANDO NUMBER := K_PUNTOS;
    nID_GRP NUMBER;
    bFLAG BOOLEAN := TRUE;
    nITEM_GRP NUMBER;

    K_DESCERROR VARCHAR2(255);

    vCODCLI VARCHAR2(40);

  nLON INTEGER;

  VAL_COD_ERR VARCHAR2(255);
  VAL_DES_ERR  VARCHAR2(255);
  VAL_PUNTOS_INI NUMBER;
  VAL_PUNTOS_FIN NUMBER;
  
  VAL_COD_ERR_RLBK VARCHAR2(255);
  VAL_DES_ERR_RLBK  VARCHAR2(255);

  CURSOR CUR_COD_CLI_MOVIL(V_TIP_DOC varchar2,
                           V_NUM_DOC varchar2,
                           V_TIP_CLI varchar2) IS
    SELECT DISTINCT ADMPV_COD_CLI
      FROM PCLUB.admpt_cliente
     WHERE admpv_tipo_doc = V_TIP_DOC
       AND admpv_num_doc = V_NUM_DOC
       AND admpc_estado = 'A'
       AND admpv_cod_tpocl = V_TIP_CLI;

  CURSOR CUR_COD_CLI_FIJA(v_TIP_DOC_F VARCHAR2,
                          v_NUM_DOC_F VARCHAR2,
                          v_TIP_CLI_F VARCHAR2) IS
    SELECT DISTINCT ADMPV_COD_CLI
      FROM PCLUB.ADMPT_clientefija
     WHERE admpv_tipo_doc = v_TIP_DOC_F
       AND admpv_num_doc = v_NUM_DOC_F
       AND admpc_estado = 'A'
       AND admpv_cod_tpocl = v_TIP_CLI_F;

  nPUNTOS_DESCONTADOS NUMBER :=0;

  bFLAG_CONTINUA BOOLEAN := TRUE;

  V_IDKARDEX NUMBER;
  nITEM_GRP_O NUMBER;

  BEGIN

  SYSFSS_PTOS_ACUM_CLI(K_TIPO_DOC,
                       K_NUM_DOC,
                       VAL_PUNTOS_INI,
                       VAL_COD_ERR,
                       VAL_DES_ERR);

    IF VAL_PUNTOS_INI < K_PUNTOS THEN
      RAISE NO_SALDO;
    END IF;

    if K_COD_APLI is null then
      raise NO_COD_APLICACION;
    end if;

    IF LENGTH(TRIM(K_ID_SOLICITUD)) <= 0 OR K_ID_SOLICITUD IS NULL THEN
      vID_SOLIC := TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS');
    ELSE
      nLON := LENGTH(K_ID_SOLICITUD);
      IF nLON > 20 THEN
        nLON := 20;
      END IF;
      vID_SOLIC := SUBSTR(K_ID_SOLICITUD, nLON * -1);
    END IF;

  SELECT COUNT(*)
    INTO nCOUNT
    FROM ADMPT_PARAMSIST
    WHERE ADMPV_DESC = 'LATAM TBL PREMIO ID TRANS CC A KM';

    IF nCOUNT = 0 THEN
      K_CODERROR := '1';
      K_MSJERROR := 'No esta configurado LATAM COMPANY ID en la tabla ADMPT_PARAMSIST';
      RETURN;
    END IF;

  SELECT COUNT(*)
    INTO nCOUNT
    FROM ADMPT_PARAMSIST
    WHERE ADMPV_DESC = 'LATAM CONCEPTO TRANSF CLARO A LATAM';

    IF nCOUNT = 0 THEN
      K_CODERROR := '1';
      K_MSJERROR := 'No esta configurado Concepto de Transferencia CLARO a LATAM en la tabla ADMPT_PARAMSIST';
      RETURN;
    ELSE
    SELECT COUNT(*)
      INTO nCOUNT
      FROM PCLUB.admpt_concepto
     WHERE admpv_desc IN
           (SELECT ADMPV_VALOR
              FROM ADMPT_PARAMSIST
      WHERE ADMPV_DESC = 'LATAM CONCEPTO TRANSF CLARO A LATAM');
      IF nCOUNT = 0 THEN
        K_CODERROR := '1';
        K_MSJERROR := 'No esta configurado Concepto de Transferencia CLARO a LATAM en la tabla admpt_concepto';
        RETURN;
      ELSE
      SELECT NVL(admpv_cod_cpto, '-1')
        INTO V_COD_CPTO
        FROM PCLUB.admpt_concepto
       WHERE admpv_desc IN
             (SELECT ADMPV_VALOR
                FROM ADMPT_PARAMSIST
        WHERE ADMPV_DESC = 'LATAM CONCEPTO TRANSF CLARO A LATAM');
      END IF;
    END IF;

  SELECT ADMPV_VALOR
    INTO K_PRO_ID
    FROM ADMPT_PARAMSIST
    WHERE ADMPV_DESC = 'LATAM TBL PREMIO ID TRANS CC A KM';

  SYSFSS_VAL_SOL_CANJE('CK',
                       K_TIPO_DOC,
                       K_NUM_DOC,
                       K_PUNTOS,
                       TRUNC(sysdate),
                       VAL_COD_ERR,
                       VAL_DES_ERR);

    IF VAL_COD_ERR = '2' THEN
      K_CODERROR := '99';
      K_MSJERROR := VAL_DES_ERR;
      RETURN;
    END IF;

    nITEM_GRP := 0;
      /*-----BLOQUEA BOLSA-----*/
  PCLUB.PKG_CC_TRANSACCION.ADMPI_BLOQUEOBOLSA(K_TIPO_DOC,
                                              K_NUM_DOC,
                                              '0',
                                              K_COD_ASESOR,
                                              K_ESTADO,
                                              K_CODERROR,
                                              K_MSJERROR);

   IF K_CODERROR = 37 AND K_ESTADO = 'R' THEN
     RAISE NO_LIBERADO;
   ELSIF K_CODERROR <> 0 OR K_ESTADO <> 'L' THEN
     RAISE EX_BLOQUEO;
   END IF;

  SELECT ap.ADMPV_ID_PROCLA,
         ap.admpv_desc,
         ap.ADMPV_CAMPANA,
         ap.ADMPN_PAGO,
         ap.ADMPV_COD_TPOPR,
         ap.ADMPN_COD_SERVC,
         ap.ADMPN_MNT_RECAR,
         ap.ADMPV_COD_PAQDAT
    INTO V_PRODID,
         V_DESC_PREMIO,
         V_CAMPANA,
         V_PAGO,
         V_TIPOPREMIO,
         V_SERVCOMERCIAL,
         V_MONTORECARGA,
    V_CODPAGDAT
    FROM PCLUB.admpt_premio ap
    WHERE admpv_id_procla = K_PRO_ID
    AND admpc_estado = 'A';

    IF V_PRODID IS NULL THEN
      RAISE NO_EVENTO;
    END IF;

    FOR TIP_CLI IN cTIP_CLI LOOP
    
      IF bFLAG_CONTINUA = TRUE THEN
      
        K_TIP_CLI := TIP_CLI.ADMPV_COD_TPOCL;
        vDESC := TIP_CLI.ADMPV_DESC;
        vTIPO := TIP_CLI.ADMPV_TIPO;
        vTBLCLIENTE := TIP_CLI.ADMPC_TBLCLIENTE;

        /*-----OBTIENE CODIGO CLIENTE----*/

          /*------PARA MOVIL------*/
          IF vTBLCLIENTE = 'M' THEN
        
            IF UPPER(vTIPO) = 'PREPAGO' THEN
              K_TIPCANJE := 1;
            ELSE
              K_TIPCANJE := 0;
            END IF;

            K_TIPPRECANJE := K_TIPCANJE;

            OPEN CUR_COD_CLI_MOVIL(K_TIPO_DOC, K_NUM_DOC, K_TIP_CLI);
        
        FETCH CUR_COD_CLI_MOVIL
          INTO vCODCLI;
        
            WHILE CUR_COD_CLI_MOVIL%FOUND AND nPUNTOS_CANJEANDO > 0 LOOP
        
          /*PCLUB.PKG_CC_TRANSACCION.ADMPSI_ES_CLIENTE_CJE(vCODCLI, K_TIPO_DOC, K_NUM_DOC, K_TIP_CLI,
          K_TIPCANJE, K_TIPPRECANJE, V_SALDO, K_CODERROR);*/
        
          sysfs_ptos_x_cliente('',
                               vCODCLI,
                               '',
                               '',
                               V_SALDO,
                               K_CODERROR,
                               V_DESCERROR);
        
            IF K_CODERROR IS NULL THEN
              K_CODERROR := 0;
            END IF;
        
          IF K_CODERROR = 0 AND V_SALDO > 0 THEN
          
            vFLAG_CLIENTE := '1';

            --            IF V_SALDO > 0 THEN
            vFLAG_SALDO := '1';
            --            END IF;

            /*PCLUB.PKG_CC_TRANSACCION.ADMPSS_VALIDASALDOKDX(vCODCLI,
                                                           K_TIP_CLI,
                                                           K_CODERROR);*/
            SYSFSS_VALIDASALDOKDX(vCODCLI, K_TIP_CLI, K_CODERROR);

              IF K_CODERROR = 1 THEN
                /*RAISE NO_SLD_KDX_ALINEADO; -- omar*/
                K_CODERROR := 610;
                K_MSJERROR := 'Ocurrio un error (Puntos CC)';
                return;
              END IF;

              IF nPUNTOS_CANJEANDO > V_SALDO THEN
                V_PUNTOS_REQUERIDOS := V_SALDO;
                nPUNTOS_CANJEANDO := nPUNTOS_CANJEANDO - V_SALDO;
              ELSE
                V_PUNTOS_REQUERIDOS := nPUNTOS_CANJEANDO;
                nPUNTOS_CANJEANDO := 0;
                bFLAG_CONTINUA := FALSE;
              END IF;

            nPUNTOS_DESCONTADOS := nPUNTOS_DESCONTADOS +
                                   V_PUNTOS_REQUERIDOS;

                IF K_NUM_DOC IS NULL THEN
              SELECT admpv_num_doc
                INTO V_NUM_DOC
                FROM PCLUB.admpt_cliente
               WHERE admpv_cod_cli = vCODCLI
                 AND admpc_estado = 'A';
                ELSE
                  V_NUM_DOC := K_NUM_DOC;
                END IF;

                    /**Descuento del Saldo del Cliente**/
                    IF K_TIPCANJE = 1 THEN
              ADMPSI_DESC_PTOS_BONO(V_COD_CANJE,
                                    V_SEC,
                                    V_PUNTOS_REQUERIDOS,
                                    vCODCLI,
                                    K_TIP_CLI,
                                    K_TIPPRECANJE,
                                    V_COD_CPTO,
                                    V_IDKARDEX,
                                    V_CODERROR,
                                    V_DESCERROR);
                    ELSE
              admpsi_desc_puntos(V_COD_CANJE,
                                 V_SEC,
                                 V_PUNTOS_REQUERIDOS,
                                 vCODCLI,
                                 K_TIP_CLI,
                                 V_COD_CPTO,
                                 V_IDKARDEX,
                                 V_CODERROR,
                                 V_DESCERROR);
                    END IF;

                    /*-----------INSERCION NUEVA TABLA----------*/
              IF bFLAG THEN
              SELECT SYSFSQ_LATAM_CANJE_KM_CC_PROD.NEXTVAL
                INTO nID_GRP
                FROM DUAL;
                K_GRP_CANJE := nID_GRP;
              END IF;
              bFLAG := FALSE;

              nITEM_GRP := nITEM_GRP + 1;

            INSERT INTO SYSFT_LATAM_CANJE_KM_CC_PROD
              (SYLCKCPN_ID_GRP_CANJE,
               SYLCKCPN_ITEM,
               SYLCKCPV_TIPO_DOC,
               SYLCKCPV_NUM_DOC,
               SYLCKCPV_COD_TPOCL,
               SYLCKCPV_TIPO_CLI,
               SYLCKCPC_TBL_CLI,
               SYLCKCPV_USU_REG,
               SYLCKCPN_ID_KARDEX,
               SYLCKCPN_PUNTOS)
            VALUES
              (nID_GRP,
               nITEM_GRP,/*
               V_COD_CANJE,*/
               K_TIPO_DOC,
               K_NUM_DOC,
               K_TIP_CLI,
               vTIPO,
               vTBLCLIENTE,
               PI_USUARIO,
               V_IDKARDEX,
               V_PUNTOS_REQUERIDOS);
          
            V_IDKARDEX := 0;
              
              IF V_CODERROR <> 0 THEN
                K_CODERROR := '90';
                K_MSJERROR := V_DESCERROR;
         
              PCLUB.PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,
                                                             K_NUM_DOC,
                                                             '0',
                                                             K_CODERROR_EX,
                                                             K_MSJERROR_EX);
         
                IF nID_GRP IS NOT NULL AND nID_GRP > 0 THEN
                SYSFSD_CANJE_MLATAMCC_FALLO(nID_GRP,
                                            PI_USUARIO,
                                            VAL_COD_ERR_RLBK,
                                            VAL_DES_ERR_RLBK);
                  IF VAL_COD_ERR_RLBK <> 0 THEN
                  K_MSJERROR := SUBSTR(K_MSJERROR || '-' ||
                                       'SP SYSFSD_CANJE_MLATAMCC_FALLO de RollBack fallo, lanzar nuevamente: ' ||
                                       VAL_DES_ERR_RLBK,
                                       1,
                                       255);
                  END IF;
                END IF;
                RETURN;
              END IF;

              END IF;

          FETCH CUR_COD_CLI_MOVIL
            INTO vCODCLI;
        
            END LOOP;

        CLOSE CUR_COD_CLI_MOVIL;

      ELSE
        /*------PARA FIJA------*/
        PCLUB.PKG_CC_TRANSACCIONFIJA.ADMPSI_ES_CLIENTE(K_TIPO_DOC,
                                                       K_NUM_DOC,
                                                       K_TIP_CLI,
                                                       V_SALDO,
                                                       K_CODERROR,
                                                       K_DESCERROR);
        IF K_CODERROR = 0 AND V_SALDO > 0 THEN

              vFLAG_CLIENTE := '1';
          
--          IF V_SALDO > 0 THEN
                vFLAG_SALDO := '1';
--          END IF;

          PCLUB.PKG_CC_TRANSACCIONFIJA.ADMPSS_VALIDASALDOKDX_FIJA(K_TIPO_DOC,
                                                                  K_NUM_DOC,
                                                                  K_TIP_CLI,
                                                                  K_CODERROR);

            IF K_CODERROR = 1 THEN
              RAISE NO_SLD_KDX_ALINEADO;
            END IF;

          OPEN CUR_COD_CLI_FIJA(K_TIPO_DOC, K_NUM_DOC, K_TIP_CLI);
            
          FETCH CUR_COD_CLI_FIJA
            INTO vCODCLI;

            WHILE CUR_COD_CLI_FIJA%FOUND AND nPUNTOS_CANJEANDO > 0 LOOP
      
        IF nPUNTOS_CANJEANDO > V_SALDO THEN
                V_PUNTOS_REQUERIDOS := V_SALDO;
                nPUNTOS_CANJEANDO := nPUNTOS_CANJEANDO - V_SALDO;
              ELSE
                V_PUNTOS_REQUERIDOS := nPUNTOS_CANJEANDO;
                nPUNTOS_CANJEANDO := 0;
                bFLAG_CONTINUA := FALSE;
              END IF;

            nPUNTOS_DESCONTADOS := nPUNTOS_DESCONTADOS +
                                   V_PUNTOS_REQUERIDOS;
            
                IF K_NUM_DOC IS NULL THEN
              SELECT admpv_num_doc
                INTO V_NUM_DOC
                FROM PCLUB.ADMPT_CLIENTEFIJA
               WHERE admpv_cod_cli = vCODCLI
                 AND admpc_estado = 'A';
                ELSE
                  V_NUM_DOC := K_NUM_DOC;
                END IF;



              /*-----------INSERCION NUEVA TABLA----------*/
              IF bFLAG THEN
              SELECT SYSFSQ_LATAM_CANJE_KM_CC_PROD.NEXTVAL
                INTO nID_GRP
                FROM DUAL;
                K_GRP_CANJE := nID_GRP;
              END IF;
              bFLAG := FALSE;

            ADMPSI_DESC_PUNTOS_FIJA(V_COD_CANJE,
                                    V_SEC,
                                    V_PUNTOS_REQUERIDOS,
                                    vCODCLI,
               K_TIPO_DOC,
               K_NUM_DOC,
               K_TIP_CLI,
                                    PI_USUARIO,
                                    V_COD_CPTO,
                                    K_GRP_CANJE,
                                    nITEM_GRP,
               vTIPO,
               vTBLCLIENTE,
                                    nITEM_GRP_O,
                                    V_CODERROR,
                                    V_DESCERROR);

            nITEM_GRP := nITEM_GRP_O;

              

              IF V_CODERROR <> 0 THEN
                K_CODERROR := '90';
                K_MSJERROR := V_DESCERROR;
         
              PCLUB.PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,
                                                             K_NUM_DOC,
                                                             '0',
                                                             K_CODERROR_EX,
                                                             K_MSJERROR_EX);
         
                IF nID_GRP IS NOT NULL AND nID_GRP > 0 THEN
                SYSFSD_CANJE_MLATAMCC_FALLO(nID_GRP,
                                            PI_USUARIO,
                                            VAL_COD_ERR_RLBK,
                                            VAL_DES_ERR_RLBK);
                  IF VAL_COD_ERR_RLBK <> 0 THEN
                  K_MSJERROR := SUBSTR(K_MSJERROR || '-' ||
                                       'SP SYSFSD_CANJE_MLATAMCC_FALLO de RollBack fallo, lanzar nuevamente: ' ||
                                       VAL_DES_ERR_RLBK,
                                       1,
                                       255);
                  END IF;
                END IF;
                RETURN;
              END IF;

            FETCH CUR_COD_CLI_FIJA
              INTO vCODCLI;
            END LOOP;
            CLOSE CUR_COD_CLI_FIJA;

              END IF;

          END IF;
        END IF;
      END LOOP;

      IF vFLAG_CLIENTE = '0' THEN
        RAISE NO_CLIENTE;
      END IF;

      IF vFLAG_SALDO = '0' THEN
        RAISE NO_SALDO;
      END IF;

  SYSFSS_PTOS_ACUM_CLI(K_TIPO_DOC,
                       K_NUM_DOC,
                       VAL_PUNTOS_FIN,
                       VAL_COD_ERR,
                       VAL_DES_ERR);

      IF (VAL_PUNTOS_INI - K_PUNTOS) <> VAL_PUNTOS_FIN THEN
        K_CODERROR := '88';
    K_MSJERROR := 'Puntos descontados diferente a puntos canjeados: ' ||
                  TO_CHAR(VAL_PUNTOS_INI - K_PUNTOS) || ' <> ' ||
                  TO_CHAR(VAL_PUNTOS_FIN);
        
    PCLUB.PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,
                                                   K_NUM_DOC,
                                                   '0',
                                                   K_CODERROR_EX,
                                                   K_MSJERROR_EX);
        
        IF nID_GRP IS NOT NULL AND nID_GRP > 0 THEN
      SYSFSD_CANJE_MLATAMCC_FALLO(nID_GRP,
                                  PI_USUARIO,
                                  VAL_COD_ERR_RLBK,
                                  VAL_DES_ERR_RLBK);
          IF VAL_COD_ERR_RLBK <> 0 THEN
        K_MSJERROR := SUBSTR(K_MSJERROR || '-' ||
                             'SP SYSFSD_CANJE_MLATAMCC_FALLO de RollBack fallo, lanzar nuevamente: ' ||
                             VAL_DES_ERR_RLBK,
                             1,
                             255);
          END IF;
        END IF;        
        RETURN;
      END IF;

      IF nPUNTOS_DESCONTADOS <> K_PUNTOS THEN
         K_CODERROR := '89';
    K_MSJERROR := 'Puntos descontados diferente a puntos canjeados: ' ||
                  TO_CHAR(nPUNTOS_DESCONTADOS) || ' <> ' ||
                  TO_CHAR(K_PUNTOS);
         
    PCLUB.PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,
                                                   K_NUM_DOC,
                                                   '0',
                                                   K_CODERROR_EX,
                                                   K_MSJERROR_EX);
         
         IF nID_GRP IS NOT NULL AND nID_GRP > 0 THEN
      SYSFSD_CANJE_MLATAMCC_FALLO(nID_GRP,
                                  PI_USUARIO,
                                  VAL_COD_ERR_RLBK,
                                  VAL_DES_ERR_RLBK);
           IF VAL_COD_ERR_RLBK <> 0 THEN
        K_MSJERROR := SUBSTR(K_MSJERROR || '-' ||
                             'SP SYSFSD_CANJE_MLATAMCC_FALLO de RollBack fallo, lanzar nuevamente: ' ||
                             VAL_DES_ERR_RLBK,
                             1,
                             255);
           END IF;
         END IF;
         RETURN;
      END IF;

  PCLUB.PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,
                                                 K_NUM_DOC,
                                                 '0',
                                                 K_CODERROR_EX,
                                                 K_MSJERROR_EX);

      IF K_CODERROR_EX = '0' THEN
        COMMIT;
      ELSE
        RAISE EX_BLOQUEO;
        ROLLBACK;
      END IF;

      K_CODERROR := 0;
      K_MSJERROR := 'OK';

  EXCEPTION
    WHEN NO_PARAMETROS THEN
      K_CODERROR := 41;
      K_MSJERROR := 'Ingreso datos incorrectos o datos insuficientes para realizar la consulta';
      ROLLBACK;

    WHEN NO_CLIENTE THEN
      K_CODERROR := K_CODERROR;
      K_MSJERROR := 'El cliente no existe en el sistema CLAROCLUB';
      ROLLBACK;

    WHEN NO_DATOS_VALIDOS THEN
      K_CODERROR := K_CODERROR;
      K_MSJERROR := 'Incongruencia con los datos del Cliente';
      ROLLBACK;

    WHEN NO_SALDO THEN
      K_CODERROR := 52;
      K_MSJERROR := 'No Hay saldo disponible para realizar el canje';
      ROLLBACK;

    WHEN NO_SALDO_CANJE THEN
      K_CODERROR := 52;
      K_MSJERROR := 'No Hay saldo disponible para realizar el canje';

    PCLUB.PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,
                                                   K_NUM_DOC,
                                                   '0',
                                                   K_CODERROR_EX,
                                                   K_MSJERROR_EX);

      IF K_CODERROR <> 0 THEN
        K_MSJERROR := K_MSJERROR || K_MSJERROR_EX;
      END IF;
      ROLLBACK;

    WHEN NO_EVENTO THEN
      K_CODERROR := '51';
      K_MSJERROR := 'No se envio Codigo del Evento';

    PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,
                                             K_NUM_DOC,
                                             '0',
                                             K_CODERROR_EX,
                                             K_MSJERROR_EX);
      IF K_CODERROR_EX <> 0 THEN
        K_MSJERROR := K_MSJERROR || K_MSJERROR_EX;
      END IF;
      ROLLBACK;

    WHEN NO_COD_APLICACION then
      K_CODERROR := 41;
      K_MSJERROR := 'Ingreso datos incorrectos o datos insuficientes para realizar la consulta';
      ROLLBACK;

    WHEN NO_DESC_PUNTOS then
      K_CODERROR := V_CODERROR;
      K_MSJERROR := V_DESCERROR;

    PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,
                                             K_NUM_DOC,
                                             '0',
                                             K_CODERROR_EX,
                                             K_MSJERROR_EX);
      IF K_CODERROR_EX <> 0 THEN
        K_MSJERROR := K_MSJERROR || K_MSJERROR_EX;
      END IF;
      ROLLBACK;

    WHEN NO_SLD_KDX_ALINEADO then
      K_CODERROR := 61;
      K_MSJERROR := 'Ocurrio un error (Puntos CC)';

    PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,
                                             K_NUM_DOC,
                                             '0',
                                             K_CODERROR_EX,
                                             K_MSJERROR_EX);

      IF K_CODERROR_EX <> 0 THEN
        K_MSJERROR := K_MSJERROR || K_MSJERROR_EX;
      END IF;
      ROLLBACK;

    WHEN EX_BLOQUEO THEN
      K_CODERROR := K_CODERROR;
      K_MSJERROR := 'Error en el bloqueo.';
      ROLLBACK;

    WHEN NO_LIBERADO THEN
      K_CODERROR := 37;
      K_MSJERROR := 'Existe un canje en proceso.';
            ROLLBACK;
    WHEN OTHERS THEN
      K_CODERROR := SQLCODE;
      K_MSJERROR := SUBSTR(SQLERRM, 1, 400);

    PKG_CC_TRANSACCION.ADMPU_LIBBLOQUEOBOLSA(K_TIPO_DOC,
                                             K_NUM_DOC,
                                             '0',
                                             K_CODERROR_EX,
                                             K_MSJERROR_EX);
      IF K_CODERROR_EX <> 0 THEN
        K_MSJERROR := K_MSJERROR || K_MSJERROR_EX;
      END IF;
      ROLLBACK;
  END SYSFSS_CANJPROD_KMLATAMCC;

/*-----------Validar las bolsas que se van a liberar---------------*/
PROCEDURE SYSFSS_COD_CANJE_KMLATAMCC(
                             K_IDCANJE       IN VARCHAR2,
                             o_resultado     OUT VARCHAR2,
                             o_mensaje       OUT VARCHAR2) IS

    V_COD_CLI      VARCHAR2(40);
    V_COD_TPOCL    VARCHAR2(2);
    V_TIPO_DOC     VARCHAR2(20);
    V_NUM_DOC      VARCHAR2(20);
    K_CODERROR_EX  NUMBER;
    K_DESCERROR_EX VARCHAR2(400);
    NO_TICKET EXCEPTION;

    V_K_EXITO NUMBER;
    V_K_COD_ERROR NUMBER;
    V_K_DESCERROR VARCHAR2(400);

  BEGIN

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
                                             '0',
                                             K_CODERROR_EX,
                                             K_DESCERROR_EX);

    COMMIT;

    IF K_CODERROR_EX <> 0 THEN
      o_resultado := TO_CHAR(K_CODERROR_EX);
      o_mensaje   := o_mensaje || 'Error en SP ADMPU_LIBBLOQUEOBOLSA: ' || K_DESCERROR_EX;
    END IF;
    o_resultado     := '0';
    o_mensaje       := 'OK';

  EXCEPTION
    WHEN OTHERS then
      o_resultado := '1';
      o_mensaje   := SUBSTR('ERROR : ' || SQLERRM, 1, 250);      ROLLBACK;

      -- REALIZAR COMPENSACION DEL REGISTRO DEL CANJE (LIMPIAR DATA)
      PCLUB.PKG_CC_TRANSACCION.ADMPSS_ELIMINARCANJE(K_IDCANJE,V_K_EXITO, V_K_COD_ERROR, V_K_DESCERROR);
END SYSFSS_COD_CANJE_KMLATAMCC;



 PROCEDURE SYSFI_ACREDITAR_PUNTOS_CC(PI_TIPO_TRANS  IN CHAR,
                                    PI_TIPO_ACRE    IN VARCHAR2,
                                    PI_COD_CLI      IN VARCHAR2,
                                    PI_TIPO_DOC     IN VARCHAR2,
                                    PI_NUM_DOC      IN VARCHAR2,
                                    PI_PUNTOS_CC    IN NUMBER,
                                    PI_COD_CONCEPTO IN VARCHAR2,
                                    PI_USU_REG      IN VARCHAR2,
                                    PO_COD_ERR      OUT NUMBER,
                                    PO_DES_ERR      OUT VARCHAR2,
                                    PO_ID_KARDEX    OUT NUMBER) IS
  --****************************************************************
  -- Nombre SP           :  SYSFI_ACREDITAR_PUNTOS_CC
  -- Proposito           :  Acreditar Puntos Claro Club a un Cliente Claro Club
  -- Input               :  PI_TIPO_TRANS: Tipo de Transaccion - V Validar; E Ejecutar
  --                        PI_TIPO_ACRE: Tipo de Linea para acreditar - M Mobil; F Fija
  --                        PI_COD_CLI: Codigo del Cliente Claro Club al que se le acreditaran los puntos cc
  --                        PI_TIPO_DOC: Tipo de documento
  --                        PI_NUM_DOC: Número de Documento
  --                        PI_PUNTOS_CC: Cantidad de puntos cc a acreditar
  --                        PI_COD_CONCEPTO: Codigo del Concepto (motivo) de la acreditacion
  --                        PI_USU_REG: Usuario que registra la transaccion
  -- Output              :  PO_COD_ERR: Codigo de Error o Exito
  --                        PO_DES_ERR: Descripcion del Error (si se presento)
  --                        PO_ID_KARDEX: Id del kardex que se generó
  -- Creado por          :  Eli Benjamin Pittman
  -- Fec Creacion        :  17/11/2017
  -- Modificado por      :  Omar Campos
  -- Fec Creacion        :  15/01/2018
  --****************************************************************

  ERR_CONCEPTO_NO_EXISTE EXCEPTION;
  ERR_CLIENTE_NO_EXISTE EXCEPTION;
  ERR_CLIENTE_FIJO_NO_EXISTE EXCEPTION;

  V_C_CONCEPTO   NUMBER;
  V_C_CLIENTE    NUMBER;
  V_EXISTE_SALDO NUMBER;

  V_COD_CLI      VARCHAR2(40);

  K_TIP_CLI VARCHAR2(3);
  vTBLCLIENTE CHAR(1);

  vCODCLI VARCHAR2(40);
  K_DESCERROR VARCHAR2(255);
  K_CODERROR VARCHAR2(10);
    
  -- BUSCAR LOS CODIGOS DE TIPOS DE CLIENTES FIJOS
  CURSOR cTIP_CLI IS select T.ADMPV_COD_TPOCL, T.ADMPV_DESC, T.ADMPC_ESTADO, T.ADMPV_TIPO, T.ADMPC_TBLCLIENTE
  from admpt_tipo_cliente t
  where T.ADMPC_TBLCLIENTE = 'F'
  AND T.ADMPC_ESTADO = 'A'
  ORDER BY DECODE(T.ADMPV_TIPO, 'HFC',1,2);
    
  nIDKARDEX NUMBER;

BEGIN

  PO_COD_ERR := 0;
  PO_DES_ERR := 'OK';

  IF LENGTH(TRIM(PI_TIPO_TRANS)) <= 0 OR PI_TIPO_TRANS IS NULL THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_TIPO_TRANS';
    RETURN;
  END IF;

  IF PI_TIPO_TRANS <> 'V' AND PI_TIPO_TRANS <> 'E' THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'El Valor del parametro PI_TIPO_TRANS debe ser V o E';
    RETURN;
  END IF;

  IF LENGTH(TRIM(PI_TIPO_ACRE)) <= 0 OR PI_TIPO_ACRE IS NULL THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_TIPO_ACRE';
    RETURN;
  END IF;

  IF PI_TIPO_ACRE <> 'F' AND PI_TIPO_ACRE <> 'M' THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'El Valor del parametro PI_TIPO_ACRE debe ser F o M';
    RETURN;
  END IF;

  IF LENGTH(TRIM(PI_COD_CONCEPTO)) <= 0 OR PI_COD_CONCEPTO IS NULL THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_COD_CONCEPTO';
    RETURN;
  END IF;

  -- SE VALIDA QUE EL CONCEPTO EXISTA
  SELECT COUNT(1)
    INTO V_C_CONCEPTO
    FROM ADMPT_CONCEPTO
   WHERE ADMPV_COD_CPTO = PI_COD_CONCEPTO;

  IF (V_C_CONCEPTO = 0) THEN
    RAISE ERR_CONCEPTO_NO_EXISTE;
  END IF;

  -- MOVIL
  IF PI_TIPO_ACRE = 'M' THEN
    
    IF LENGTH(TRIM(PI_COD_CLI)) <= 0 OR PI_COD_CLI IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_COD_CLI';
      RETURN;
    END IF;

    -- SE VALIDA QUE EL CLIENTE EXISTA Y ESTE ACTIVO
    SELECT COUNT(1)
    INTO V_C_CLIENTE
    FROM PCLUB.ADMPT_CLIENTE C
    WHERE C.ADMPV_COD_CLI = PI_COD_CLI
    AND C.ADMPC_ESTADO = 'A';

    -- EN CASO NO EXISTA, SE DEVUELVE UN MENSAJE DE ERROR
    IF (V_C_CLIENTE = 0) THEN
      RAISE ERR_CLIENTE_NO_EXISTE;
    END IF;

    V_COD_CLI := PI_COD_CLI;

    select T.ADMPV_COD_TPOCL INTO K_TIP_CLI from admpt_cliente t
    WHERE T.ADMPV_COD_CLI = V_COD_CLI AND ROWNUM = 1;

    PCLUB.PKG_CC_TRANSACCION.ADMPSS_VALIDASALDOKDX(V_COD_CLI, K_TIP_CLI, K_CODERROR);

    IF K_CODERROR = 1 THEN
      PO_COD_ERR := '3';
      PO_DES_ERR := 'Saldos no estan alineados';
      RETURN;
    END IF;

  -- FIJO
  ELSE
    IF LENGTH(TRIM(PI_TIPO_DOC)) <= 0 OR PI_TIPO_DOC IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_TIPO_DOC';
      RETURN;
    END IF;

    IF LENGTH(TRIM(PI_NUM_DOC)) <= 0 OR PI_NUM_DOC IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_NUM_DOC';
      RETURN;
    END IF;

    FOR TIP_CLI IN cTIP_CLI LOOP
      K_TIP_CLI := TIP_CLI.ADMPV_COD_TPOCL;
      vTBLCLIENTE := TIP_CLI.ADMPC_TBLCLIENTE;

      SYSFS_CODIGO_CLIENTE(vTBLCLIENTE, K_TIP_CLI, PI_TIPO_DOC, PI_NUM_DOC, vCODCLI, K_CODERROR, K_DESCERROR);

      IF K_CODERROR = 0 THEN
        V_COD_CLI := vCODCLI;
        EXIT;
      END IF;

    END LOOP;

    -- SE VALIDA QUE SE HAYA ENCONTRADO UN CLIENTE FIJO
    IF (K_CODERROR <> 0) THEN
      RAISE ERR_CLIENTE_FIJO_NO_EXISTE;
    END IF;

    PCLUB.PKG_CC_TRANSACCIONFIJA.ADMPSS_VALIDASALDOKDX_FIJA( PI_TIPO_DOC, PI_NUM_DOC, K_TIP_CLI, K_CODERROR);

    IF K_CODERROR = 1 THEN
      PO_COD_ERR := '3';
      PO_DES_ERR := 'Saldos no estan alineados';
      RETURN;
  END IF;

  END IF;
  
  -- ACCION DE EJECUTAR
  IF PI_TIPO_TRANS = 'E' THEN
  BEGIN
    
    -- MOVIL
    IF PI_TIPO_ACRE = 'M' THEN
      --INSERTAMOS EN KARDEX
      SELECT PCLUB.ADMPT_KARDEX_SQ.NEXTVAL INTO nIDKARDEX FROM DUAL;
      INSERT INTO ADMPT_KARDEX
        (ADMPN_ID_KARDEX,
         ADMPV_COD_CLI,
         ADMPV_COD_CPTO,
         ADMPV_USU_REG,
         ADMPD_FEC_TRANS,
         ADMPN_PUNTOS,
         ADMPC_TPO_OPER,
         ADMPC_TPO_PUNTO,
         ADMPN_SLD_PUNTO,
         ADMPC_ESTADO)
      VALUES
        (nIDKARDEX,
         V_COD_CLI,
         PI_COD_CONCEPTO,
         PI_USU_REG,
         to_date(to_char(sysdate, 'dd/mm/yyyy'), 'dd/mm/yyyy'),
         PI_PUNTOS_CC,
         'E',
         'C',
         PI_PUNTOS_CC,
         'A');

      --SE BUSCA SI EL CODIGO DEL CLIENTE YA EXISTE EN SALDOS
      SELECT CASE WHEN EXISTS (SELECT 1
      FROM ADMPT_SALDOS_CLIENTE S
      WHERE S.ADMPV_COD_CLI = V_COD_CLI)
      THEN 1 ELSE 0 END
      INTO V_EXISTE_SALDO
      FROM DUAL;

      -- EN CASO QUE AUN NO EXISTA, SE INSERTA EL REGISTRO
      IF (V_EXISTE_SALDO = 0) THEN
        INSERT INTO ADMPT_SALDOS_CLIENTE
          (ADMPN_ID_SALDO,
          ADMPV_COD_CLI,
          ADMPN_SALDO_CC,
          ADMPC_ESTPTO_CC,
          ADMPD_FEC_REG)
        VALUES
          (ADMPT_SLD_CL_SQ.NEXTVAL,
          V_COD_CLI,
          PI_PUNTOS_CC,
          'A',
          SYSDATE);
      ELSE
        -- CASO CONTRARIO, SE ACTUALIZA EL REGISTRO
        UPDATE ADMPT_SALDOS_CLIENTE S
        SET S.ADMPN_SALDO_CC = S.ADMPN_SALDO_CC + PI_PUNTOS_CC,
        ADMPD_FEC_MOD    = SYSDATE
        WHERE S.ADMPV_COD_CLI = V_COD_CLI;
      END IF;
    
    -- FIJO  
    ELSE
      
      --INSERTAMOS EN KARDEX
      SELECT PCLUB.ADMPT_kardexfija_sq.NEXTVAL INTO nIDKARDEX FROM DUAL;
      INSERT INTO PCLUB.ADMPT_kardexfija
        (admpn_id_kardex,
        admpn_cod_cli_ib,
        ADMPV_COD_CLI_PROD,
        admpv_cod_cpto,
        admpd_fec_trans,
        admpn_puntos,
        admpv_nom_arch,
        admpc_tpo_oper,
        admpc_tpo_punto,
        admpn_sld_punto,
        admpc_estado,
        admpv_usu_reg)
      VALUES
        (nIDKARDEX,
        '',
        V_COD_CLI,
        PI_COD_CONCEPTO,
        to_date(to_char(sysdate, 'dd/mm/yyyy'), 'dd/mm/yyyy'),
        PI_PUNTOS_CC,
        '',
        'E',
        'C',
        PI_PUNTOS_CC,
        'A',
        PI_USU_REG);

      --SE BUSCA SI EL CODIGO DEL CLIENTE YA EXISTE EN SALDOS
      SELECT CASE WHEN EXISTS (SELECT 1
      FROM ADMPT_saldos_clientefija S
      WHERE S.ADMPV_COD_CLI_PROD = V_COD_CLI)
      THEN 1 ELSE 0 END
      INTO V_EXISTE_SALDO
      FROM DUAL;

      -- EN CASO QUE AUN NO EXISTA, SE INSERTA EL REGISTRO
      IF (V_EXISTE_SALDO = 0) THEN
        INSERT INTO ADMPT_SALDOS_CLIENTEFIJA(
          ADMPN_ID_SALDO,
          ADMPV_COD_CLI_PROD,
          ADMPN_COD_CLI_IB,
          ADMPN_SALDO_CC,
          ADMPN_SALDO_IB,ADMPC_ESTPTO_CC,ADMPC_ESTPTO_IB,
          ADMPD_FEC_REG,
          ADMPV_USU_REG
          )
        VALUES(
          ADMPT_SLD_CLFIJA_SQ.NEXTVAL+1,
          V_COD_CLI,
          NULL,
          PI_PUNTOS_CC,
          0,
          'A',
          NULL,
          SYSDATE,
          PI_USU_REG
          );
      ELSE
        -- CASO CONTRARIO, SE ACTUALIZA EL REGISTRO
        UPDATE ADMPT_SALDOS_CLIENTEFIJA S
        SET S.ADMPN_SALDO_CC = S.ADMPN_SALDO_CC + PI_PUNTOS_CC,
        ADMPD_FEC_MOD = SYSDATE, ADMPV_USU_MOD = PI_USU_REG
        WHERE S.ADMPV_COD_CLI_PROD = V_COD_CLI;
      END IF;
    END IF;


    COMMIT;
    PO_ID_KARDEX := nIDKARDEX;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      PO_COD_ERR := SQLCODE;
      PO_DES_ERR := SUBSTR(SQLERRM, 1, 250);
  END;
    END IF;

EXCEPTION
  WHEN ERR_CONCEPTO_NO_EXISTE THEN
    PO_COD_ERR := 55;
    PO_DES_ERR := 'No se tiene registrado el CONCEPTO (ADMPT_CONCEPTO).';
    ROLLBACK;

  WHEN ERR_CLIENTE_NO_EXISTE THEN
    PO_COD_ERR := 56;
    PO_DES_ERR := 'El cliente no existe (ADMPT_CLIENTE).';
    ROLLBACK;

  WHEN ERR_CLIENTE_FIJO_NO_EXISTE THEN
    PO_COD_ERR := 56;
    PO_DES_ERR := 'El cliente fijo no existe (ADMPT_CLIENTEFIJA).';
    ROLLBACK;

  WHEN NO_DATA_FOUND THEN
    PO_COD_ERR := SQLCODE;
    PO_DES_ERR := SUBSTR(SQLERRM, 1, 250);
    ROLLBACK;

  WHEN OTHERS THEN
    PO_COD_ERR := SQLCODE;
    PO_DES_ERR := SUBSTR(SQLERRM, 1, 250);
    ROLLBACK;

END SYSFI_ACREDITAR_PUNTOS_CC;

 PROCEDURE SYSFS_CODIGO_CLIENTE(
           PI_TBL_CLI           IN VARCHAR2,
           PI_TIP_CLI           IN VARCHAR2,
           PI_TIP_DOC           IN VARCHAR2,
           PI_NUM_DOC           IN VARCHAR2,
           PO_COD_CLI           OUT VARCHAR2,
           PO_COD_ERR           OUT VARCHAR2,
           PO_DES_ERR           OUT VARCHAR2) IS

/*
'****************************************************************************************************************
'* Nombre SP : SYSFS_CODIGO_CLIENTE
'* Propósito : Este procedimiento retorna el COD_CLI .
'* Input :     <Parametro>       -- Descripción de los parametros
               PI_TBL_CLI        -- Indica si es Movil o Fija ('M';'F')
               PI_TIP_CLI        -- Codigo del tipo de cliente
               PI_TIP_DOC        -- Tipo documento
               PI_NUM_DOC        -- Numero de documento
'* Output :    <Parametro>       -- Descripción de los parametros
               PO_COD_CLI        -- Codigo del cliente
               PO_COD_ERR        -- Codigo de error
               PO_DES_ERR        -- Descripción del error
'* Creado por : SAPIA - Omar Campos
'* Fec Creación : 30/10/2017
'****************************************************************************************************************
*/

nCOUNT INTEGER;

BEGIN

  IF LENGTH(TRIM(PI_TBL_CLI)) <= 0 OR PI_TBL_CLI IS NULL THEN
    PO_COD_CLI := '';
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_TBL_CLI';
    RETURN;
  END IF;

  IF PI_TBL_CLI NOT IN ('M','F') THEN
    PO_COD_CLI := '';
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_TBL_CLI correcto: M (Movil), F (Fija)';
    RETURN;
  END IF;

  IF LENGTH(TRIM(PI_TIP_CLI)) <= 0 OR PI_TIP_CLI IS NULL THEN
    PO_COD_CLI := '';
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_TIP_CLI';
    RETURN;
  END IF;

  IF LENGTH(TRIM(PI_TIP_DOC)) <= 0 OR PI_TIP_DOC IS NULL THEN
    PO_COD_CLI := '';
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_TIP_DOC';
    RETURN;
  END IF;

  IF LENGTH(TRIM(PI_NUM_DOC)) <= 0 OR PI_NUM_DOC IS NULL THEN
    PO_COD_CLI := '';
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_NUM_DOC';
    RETURN;
  END IF;

  -- MOVIL
  IF PI_TBL_CLI = 'M' THEN
    SELECT COUNT(1) INTO nCOUNT FROM PCLUB.admpt_cliente
    WHERE admpv_tipo_doc = PI_TIP_DOC AND admpv_num_doc = PI_NUM_DOC
    AND admpc_estado = 'A' AND admpv_cod_tpocl = PI_TIP_CLI;

    IF nCOUNT = 0 THEN
      PO_COD_CLI := '';
      PO_COD_ERR := '2';
      PO_DES_ERR := 'Cliente no encontrado';
      RETURN;
    END IF;

    SELECT ADMPV_COD_CLI INTO PO_COD_CLI FROM PCLUB.admpt_cliente
    WHERE admpv_tipo_doc = PI_TIP_DOC AND admpv_num_doc = PI_NUM_DOC
    AND admpc_estado = 'A' AND admpv_cod_tpocl = PI_TIP_CLI
    AND ROWNUM = 1;

  -- FIJA
  ELSE
          
     SELECT COUNT(*) INTO nCOUNT FROM PCLUB.ADMPT_clientefija c
      INNER JOIN PCLUB.Admpt_Clienteproducto cp ON 
      cp.admpv_cod_cli = c.admpv_cod_cli
      WHERE c.admpv_tipo_doc = PI_TIP_DOC AND c.admpv_num_doc = PI_NUM_DOC
      AND c.admpc_estado = 'A' AND c.admpv_cod_tpocl = PI_TIP_CLI
      AND cp.admpv_estado_serv = 'A';

    IF nCOUNT = 0 THEN
      PO_COD_CLI := '';
      PO_COD_ERR := '2';
      PO_DES_ERR := 'Cliente Fija no encontrado';
      RETURN;
    END IF;

    SELECT cp.admpv_cod_cli_prod INTO PO_COD_CLI FROM PCLUB.ADMPT_clientefija c
    INNER JOIN PCLUB.Admpt_Clienteproducto cp ON 
    cp.admpv_cod_cli = c.admpv_cod_cli
    WHERE c.admpv_tipo_doc = PI_TIP_DOC AND c.admpv_num_doc = PI_NUM_DOC
    AND c.admpc_estado = 'A' AND c.admpv_cod_tpocl = PI_TIP_CLI
    AND cp.admpv_estado_serv = 'A'
    AND ROWNUM = 1;

  END IF;

  PO_COD_ERR := '0';
  PO_DES_ERR := 'OK';

EXCEPTION
  WHEN OTHERS THEN
    PO_COD_CLI := '';
    PO_COD_ERR := SQLCODE;
    PO_DES_ERR := SUBSTR(SQLERRM, 1, 250);

END SYSFS_CODIGO_CLIENTE;

 PROCEDURE SYSFS_PTOS_X_CLIENTE(
           PI_TIP_CLI           IN VARCHAR2,
           PO_COD_CLI           IN VARCHAR2,
           PI_TIP_DOC           IN VARCHAR2,
           PI_NUM_DOC           IN VARCHAR2,
           PO_SALDO             OUT NUMBER,
           PO_COD_ERR           OUT VARCHAR2,
           PO_DES_ERR           OUT VARCHAR2) IS

/*
'****************************************************************************************************************
'* Nombre SP : SYSFS_PTOS_X_CLIENTE
'* Propósito : Este procedimiento retorna el saldo de puntos del cliente.
'* Input :     <Parametro>       -- Descripción de los parametros
               PI_TIP_CLI        -- Codigo del tipo de cliente
               PO_COD_CLI        -- Codigo del cliente
               PI_TIP_DOC        -- Tipo documento
               PI_NUM_DOC        -- Numero de documento
'* Output :    <Parametro>       -- Descripción de los parametros
               PO_SALDO          -- Indica el saldo de puntos del cliente
               PO_COD_ERR        -- Codigo de error
               PO_DES_ERR        -- Descripción del error
'* Creado por : SAPIA - Omar Campos
'* Fec Creación : 30/10/2017
'****************************************************************************************************************
*/

CURSOR CUR_CLIENTE(tipo_doc VARCHAR2, num_doc VARCHAR2, cod_tpocl VARCHAR2) IS
  SELECT admpv_cod_cli FROM PCLUB.admpt_cliente
  WHERE admpv_tipo_doc = tipo_doc AND admpv_num_doc = num_doc AND
  admpv_cod_tpocl = cod_tpocl AND admpc_estado = 'A';

nCOUNT INTEGER;
nSALDO_CC NUMBER := 0;
nSALDO_B NUMBER := 0;
nSALDO_CC_TOT NUMBER := 0;
vCOD_CLI VARCHAR2(40);
vTIP_CLI VARCHAR2(2);
vNUM_DOC VARCHAR2(20);
vTIP_DOC VARCHAR2(20);



BEGIN

  IF (LENGTH(TRIM(PI_TIP_CLI)) <= 0 OR PI_TIP_CLI IS NULL) AND
    (LENGTH(TRIM(PO_COD_CLI)) <= 0 OR PO_COD_CLI IS NULL)THEN
    PO_SALDO := 0;
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_TIP_CLI o PO_COD_CLI';
    RETURN;
  END IF;

  IF LENGTH(TRIM(PI_TIP_CLI)) > 0 AND PI_TIP_CLI IS NOT NULL THEN
    IF LENGTH(TRIM(PI_TIP_DOC)) <= 0 OR PI_TIP_DOC IS NULL THEN
      PO_SALDO := 0;
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_TIP_DOC';
      RETURN;
    END IF;

    IF LENGTH(TRIM(PI_NUM_DOC)) <= 0 OR PI_NUM_DOC IS NULL THEN
      PO_SALDO := 0;
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_TIP_DOC';
      RETURN;
    END IF;
  END IF;

  IF LENGTH(TRIM(PO_COD_CLI)) > 0 AND PO_COD_CLI IS NOT NULL THEN
    SELECT COUNT(*) INTO nCOUNT FROM PCLUB.ADMPT_CLIENTE A
    WHERE A.ADMPV_COD_CLI = PO_COD_CLI AND ADMPC_ESTADO = 'A';

    IF nCOUNT = 0 THEN
      PO_SALDO := 0;
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Codigo de Cliente no encontrado';
      RETURN;
    END IF;

  END IF;


  IF (PI_TIP_DOC IS NOT NULL AND PI_NUM_DOC IS NOT NULL) AND PI_TIP_CLI IS NOT NULL THEN
    SELECT COUNT(1) INTO nCOUNT
    FROM PCLUB.admpt_cliente
    WHERE admpv_tipo_doc = PI_TIP_DOC AND admpv_num_doc = PI_NUM_DOC
    AND admpc_estado = 'A' AND admpv_cod_tpocl = PI_TIP_CLI;

    IF nCOUNT = 0 THEN
      PO_SALDO := 0;
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Cliente no tiene saldo';
    END IF;

    vTIP_DOC := PI_TIP_DOC;
    vNUM_DOC := PI_NUM_DOC;
    vTIP_CLI := PI_TIP_CLI;

    OPEN CUR_CLIENTE(vTIP_DOC, vNUM_DOC, vTIP_CLI);
    FETCH CUR_CLIENTE INTO vCOD_CLI;
    WHILE CUR_CLIENTE%FOUND LOOP

      SELECT NVL(SUM(admpn_saldo_cc), 0) INTO nSALDO_CC
      FROM PCLUB.admpt_saldos_cliente
      WHERE admpv_cod_cli = vCOD_CLI AND admpc_estpto_cc = 'A';

      SELECT NVL(SUM(SB.ADMPN_SALDO), 0) INTO nSALDO_B
      FROM PCLUB.ADMPT_SALDOS_BONO_CLIENTE SB
      WHERE SB.ADMPV_COD_CLI = vCOD_CLI
      AND SB.ADMPN_GRUPO = 1 AND SB.ADMPV_ESTADO = 'A';

      nSALDO_CC_TOT := nSALDO_CC_TOT + nSALDO_CC + nSALDO_B;

    FETCH CUR_CLIENTE INTO vCOD_CLI;
    END LOOP;

  ELSE
    SELECT COUNT(1) INTO nCOUNT
    FROM PCLUB.admpt_cliente a
    WHERE admpc_estado = 'A' AND ADMPV_COD_CLI = PO_COD_CLI;

    IF nCOUNT = 0 THEN
      PO_SALDO := 0;
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Cliente no tiene saldo';
    END IF;


    SELECT NVL(SUM(admpn_saldo_cc), 0) INTO nSALDO_CC
    FROM PCLUB.admpt_saldos_cliente
    WHERE admpv_cod_cli = PO_COD_CLI AND admpc_estpto_cc = 'A';

    SELECT NVL(SUM(SB.ADMPN_SALDO), 0) INTO nSALDO_B
    FROM PCLUB.ADMPT_SALDOS_BONO_CLIENTE SB
    WHERE SB.ADMPV_COD_CLI = PO_COD_CLI
    AND SB.ADMPN_GRUPO = 1 AND SB.ADMPV_ESTADO = 'A';

    nSALDO_CC_TOT := nSALDO_CC + nSALDO_B;

  END IF;



  PO_SALDO := nSALDO_CC_TOT;
  PO_COD_ERR := '0';
  PO_DES_ERR := 'OK';

EXCEPTION
  WHEN OTHERS THEN
    PO_SALDO := 0;
    PO_COD_ERR := -1;
    PO_DES_ERR := SUBSTR(SQLERRM, 1, 250);

END SYSFS_PTOS_X_CLIENTE;

PROCEDURE SYSFI_ROLBK_ACRE_PTOS_CC(PI_TIPO_ACRE   IN VARCHAR2,
                                    PI_ID_KARDEX    IN NUMBER,
                                    PO_COD_ERR      OUT NUMBER,
                                    PO_DES_ERR      OUT VARCHAR2) IS
  --****************************************************************
  -- Nombre SP           :  SYSFI_ROLBK_ACRE_PTOS_CC
  -- Proposito           :  Acreditar Puntos Claro Club a un Cliente Claro Club
  -- Input               :  PI_TIPO_ACRE: Tipo de Linea para acreditar - M Mobil; F Fija
  --                        PI_ID_KARDEX: Id del kardex que se va ha hacer rollback
  -- Output              :  PO_COD_ERR: Codigo de Error o Exito
  --                        PO_DES_ERR: Descripcion del Error (si se presento)
  -- Creado por          :  Omar Campos
  -- Fec Creacion        :  15/01/2018
  --****************************************************************

  nCount NUMBER;
  nPUNTOS NUMBER;
  vCOD_CLI VARCHAR2(40);

BEGIN

  PO_COD_ERR := 0;
  PO_DES_ERR := 'OK';

  IF LENGTH(TRIM(PI_TIPO_ACRE)) <= 0 OR PI_TIPO_ACRE IS NULL THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_TIPO_ACRE';
    RETURN;
  END IF;

  IF PI_TIPO_ACRE <> 'F' AND PI_TIPO_ACRE <> 'M' THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'El Valor del parametro PI_TIPO_ACRE debe ser F o M';
    RETURN;
  END IF;

  IF PI_ID_KARDEX <= 0 OR PI_ID_KARDEX IS NULL THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_ID_KARDEX';
    RETURN;
  END IF;


    IF PI_TIPO_ACRE = 'M' THEN
      --VALIDAMOS KARDEX
      SELECT COUNT(1) INTO nCOUNT FROM ADMPT_KARDEX
      WHERE ADMPN_ID_KARDEX = PI_ID_KARDEX;

      IF nCOUNT = 0 THEN
        PO_COD_ERR := 1;
        PO_DES_ERR := 'No existe kardex para hacer rollback';
        RETURN;
      END IF;

      SELECT ADMPN_PUNTOS, ADMPV_COD_CLI INTO nPUNTOS, vCOD_CLI FROM ADMPT_KARDEX
      WHERE ADMPN_ID_KARDEX = PI_ID_KARDEX;

      --SE BUSCA SI EL CODIGO DEL CLIENTE YA EXISTE EN SALDOS
      SELECT CASE WHEN EXISTS (SELECT 1
      FROM ADMPT_SALDOS_CLIENTE S
      WHERE S.ADMPV_COD_CLI = vCOD_CLI)
      THEN 1 ELSE 0 END
      INTO nCOUNT
      FROM DUAL;

      IF nCOUNT = 0 THEN
        PO_COD_ERR := 1;
        PO_DES_ERR := 'Cliente no tiene saldo en ese producto para hacer rollback';
        RETURN;
      END IF;

      DELETE ADMPT_KARDEX
      WHERE ADMPN_ID_KARDEX = PI_ID_KARDEX;

      UPDATE ADMPT_SALDOS_CLIENTE S
      SET S.ADMPN_SALDO_CC = S.ADMPN_SALDO_CC - nPUNTOS,
      ADMPD_FEC_MOD = SYSDATE
      WHERE S.ADMPV_COD_CLI = vCOD_CLI;

    ELSE
      --VALIDAMOS KARDEX
      SELECT COUNT(1) INTO nCOUNT FROM PCLUB.ADMPT_kardexfija
      WHERE admpn_id_kardex = PI_ID_KARDEX;

      IF nCOUNT = 0 THEN
        PO_COD_ERR := 1;
        PO_DES_ERR := 'No existe kardex para hacer rollback';
        RETURN;
      END IF;

      SELECT admpn_puntos, ADMPV_COD_CLI_PROD INTO nPUNTOS, vCOD_CLI FROM PCLUB.ADMPT_kardexfija
      WHERE admpn_id_kardex = PI_ID_KARDEX;

      --SE BUSCA SI EL CODIGO DEL CLIENTE YA EXISTE EN SALDOS
      SELECT CASE WHEN EXISTS (SELECT 1
      FROM ADMPT_saldos_clientefija S
      WHERE S.ADMPV_COD_CLI_PROD = vCOD_CLI)
      THEN 1 ELSE 0 END
      INTO nCOUNT
      FROM DUAL;

      IF nCOUNT = 0 THEN
        PO_COD_ERR := 1;
        PO_DES_ERR := 'Cliente no tiene saldo en ese producto para hacer rollback';
        RETURN;
      END IF;

      DELETE PCLUB.ADMPT_kardexfija
      WHERE admpn_id_kardex = PI_ID_KARDEX;

      UPDATE ADMPT_SALDOS_CLIENTEFIJA S
      SET S.ADMPN_SALDO_CC = S.ADMPN_SALDO_CC - nPUNTOS,
      ADMPD_FEC_MOD = SYSDATE
      WHERE S.ADMPV_COD_CLI_PROD = vCOD_CLI;
    END IF;

    COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    PO_COD_ERR := SQLCODE;
    PO_DES_ERR := SUBSTR(SQLERRM, 1, 250);
    ROLLBACK;

END SYSFI_ROLBK_ACRE_PTOS_CC;

PROCEDURE SYSFSD_CANJE_MLATAMCC_FALLO(
             PI_IDGRP    IN NUMBER,
             PI_USUARIO  IN VARCHAR2,
             PO_COD_ERR  OUT varchar2,
             PO_DES_ERR  OUT varchar2)

/*
'****************************************************************************************************************
'* Nombre SP : SYSFSD_CANJE_MLATAMCC_FALLO
'* Propósito : Este procedimiento su usa para retornar puntos en caso falle el SP de Canje.
'* Input :     <Parametro>       -- Descripción de los parametros
               PI_IDGRP          -- Es el valor del Grupo
               PI_USUARIO        -- Usuario
'* Output :    <Parametro>       -- Descripción de los parametros
               PO_COD_ERR        -- Codigo de error( 0 OK, 1 Error en parametros,
                                    -1 error oracle)
               PO_DES_ERR        -- Descripción del error
'* Creado por : SAPIA - Omar Campos
'* Fec Creación : 30/10/2017
'****************************************************************************************************************
*/

 IS

CURSOR cGRP_CANJE_PROD (nID_GRP_CANJE NUMBER) IS SELECT A.SYLCKCPN_ITEM, NVL(A.SYLCKCPN_ID_CANJE, 0) SYLCKCPN_ID_CANJE,
A.SYLCKCPC_TBL_CLI, NVL(A.SYLCKCPN_ID_KARDEX, 0) SYLCKCPN_ID_KARDEX FROM SYSFT_LATAM_CANJE_KM_CC_PROD A
WHERE A.SYLCKCPN_ID_GRP_CANJE = nID_GRP_CANJE;

nIDGRP NUMBER;
nID_CANJE NUMBER;
vTBL_CLI CHAR(1);
nITEM_GRP NUMBER;
nDEL_EXITO NUMBER;
nDEL_COD_ERROR NUMBER;
vDEL_DESCERROR VARCHAR2(255);

nID_KARDEX NUMBER;
nID_KARDEX_NEW NUMBER;

BEGIN

  IF PI_IDGRP <= 0 OR PI_IDGRP IS NULL THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro nIDGRP';
    RETURN;
  END IF;

  IF LENGTH(TRIM(PI_USUARIO)) <= 0 OR PI_USUARIO IS NULL THEN
      PO_COD_ERR := '1';
      PO_DES_ERR := 'Debe ingresar parametro PI_USUARIO';
      RETURN;
    END IF;

  PO_COD_ERR := '0';
  PO_DES_ERR := 'OK';
  
  nIDGRP := PI_IDGRP;

  FOR GRP_CANJE_PROD IN cGRP_CANJE_PROD(nIDGRP) LOOP
    nITEM_GRP := GRP_CANJE_PROD.SYLCKCPN_ITEM;
    nID_CANJE := GRP_CANJE_PROD.SYLCKCPN_ID_CANJE;
    vTBL_CLI := GRP_CANJE_PROD.SYLCKCPC_TBL_CLI;
    nID_KARDEX := GRP_CANJE_PROD.SYLCKCPN_ID_KARDEX;
    -- REALIZAR COMPENSACION DEL REGISTRO DEL CANJE (LIMPIAR DATA)
    
    --ELIMINANDO CANJE
    IF nID_CANJE <> 0 THEN
    IF vTBL_CLI = 'M' THEN
    PCLUB.PKG_CC_TRANSACCION.ADMPSS_ELIMINARCANJE(nID_CANJE, nDEL_EXITO, nDEL_COD_ERROR, vDEL_DESCERROR);
    END IF;
    IF vTBL_CLI = 'F' THEN
      PCLUB.PKG_CC_TRANSACCIONFIJA.ADMPSS_ELIMINARCANJE (nID_CANJE, nDEL_EXITO, nDEL_COD_ERROR, vDEL_DESCERROR);
    END IF;
    --SI NO SE REALIZA CON EXITO
    IF nDEL_EXITO <>  1 THEN
      PO_COD_ERR := '3';
      PO_DES_ERR := 'Fallo la compensación de Canje, reintentar nuevamente';
    END IF;
    END IF;
    
    --ELIMINANDO KARDEX
    IF nID_KARDEX <> 0 THEN
      SYSFSD_KRDX_MLATAMCC_FALLO(nID_KARDEX, vTBL_CLI, PI_USUARIO, nID_KARDEX_NEW, nDEL_COD_ERROR, vDEL_DESCERROR); 
      IF nDEL_COD_ERROR = 0 THEN
        --ACTUALIZA EL REGISTRO DEL GRUPO DE KARDEX CON EL ID KARDEX CON EL QUE SE ESTA ANULANDO
         UPDATE SYSFT_LATAM_CANJE_KM_CC_PROD SET SYLCKCPN_ID_KRDX_ANULA = nID_KARDEX_NEW
         WHERE SYLCKCPN_ID_GRP_CANJE = nIDGRP AND SYLCKCPN_ITEM = nITEM_GRP;
      ELSE
        PO_COD_ERR := '101';
        PO_DES_ERR := 'ERROR => ' || vDEL_DESCERROR;
        RETURN;
      END IF;
    END IF;
    
    
    
  END LOOP;

        COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      PO_COD_ERR := '-1';
      PO_DES_ERR := 'ERROR => ' || TO_CHAR(SQLCODE) || ' : ' || SQLERRM;

END SYSFSD_CANJE_MLATAMCC_FALLO;

PROCEDURE ADMPSI_DESC_PTOS_BONO(K_ID_CANJE    NUMBER,
                                  K_SEC         NUMBER,
                                  K_PUNTOS      NUMBER,
                                  K_COD_CLIENTE IN VARCHAR2,
                                  K_TIP_CLI     IN VARCHAR2,
                                  K_GRUPO       IN NUMBER,
                                  K_COD_CPTO      IN VARCHAR2,
                                  K_IDKARDEX    OUT NUMBER,
                                  K_CODERROR    OUT NUMBER,
                                  K_MSJERROR    OUT VARCHAR2) IS
                                  
/*
'****************************************************************************************************************
'* Nombre SP : ADMPSI_DESC_PTOS_BONO
'* Propósito : Este procedimiento se usa para descontar puntos de la movil (BONO).
'* Input :     <Parametro>       -- Descripción de los parametros
               K_ID_CANJE        -- Es el valor del ID_CANJE
               K_SEC             -- Es el valor del SEC
               K_PUNTOS          -- Es el valor del PUNTOS
               K_COD_CLIENTE     -- Es el valor del COD_CLIENTE
               K_TIP_CLI         -- Es el valor del TIP_CLI
               K_GRUPO           -- Es el valor del Grupo
               K_COD_CPTO        -- Es el valor del COD_CPTO
'* Output :    <Parametro>       -- Descripción de los parametros
               K_CODERROR        -- Codigo de error( 0 OK, -1 Fallo descuento,
                                    -1 error oracle)
               K_MSJERROR        -- Descripción del error
'* Creado por : SAPIA - Omar Campos
'* Fec Creación : 16/02/2018
'****************************************************************************************************************
*/

    V_PUNTOS_REQUERIDOS NUMBER := 0;

    LK_TPO_PUNTO  CHAR(1);
    LK_ID_KARDEX  NUMBER;
    LK_SLD_PUNTOS NUMBER;
    LK_COD_CLI    VARCHAR2(40);
    LK_COD_CLIIB  NUMBER;
    LK_TPO_PREMIO NUMBER;
    
    nPUNTOS_DESC NUMBER := 0;
    V_ID_KARDEX NUMBER;

    /* Cursor 1 */
    CURSOR LISTA_KARDEX_1 IS

      SELECT A.admpc_tpo_punto,
             A.admpn_id_kardex,
             A.admpn_sld_punto,
             A.admpv_cod_cli,
             A.admpn_cod_cli_ib,
             A.admpn_tip_premio
        FROM (

              SELECT ka.admpc_tpo_punto,
                      ka.admpn_id_kardex,
                      ka.admpn_sld_punto,
                      ka.admpv_cod_cli,
                      ka.admpn_cod_cli_ib,
                      ka.admpn_tip_premio
              FROM PCLUB.admpt_kardex ka
              WHERE ka.admpc_estado = 'A'
                 and (ka.admpn_tip_premio is null or ka.admpn_tip_premio = 0)
                 AND ka.admpc_tpo_oper = 'E'
                 AND ka.admpn_sld_punto > 0
                 AND trunc(ka.admpd_fec_trans) <=
                     trunc(TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'))
                 AND ka.admpv_cod_cli IN
                     (K_COD_CLIENTE)
              UNION ALL
              SELECT ka.admpc_tpo_punto,
                     ka.admpn_id_kardex,
                     ka.admpn_sld_punto,
                     ka.admpv_cod_cli,
                     ka.admpn_cod_cli_ib,
                     ka.admpn_tip_premio
                FROM PCLUB.admpt_kardex ka
               WHERE ka.admpc_estado = 'A'
                 AND ka.admpc_tpo_punto = 'B'
                 AND ka.admpn_tip_premio = K_GRUPO
                 AND ka.admpc_tpo_oper = 'E'
                 AND ka.admpn_sld_punto > 0
                 AND trunc(ka.admpd_fec_trans) <=
                     trunc(TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'))
                 AND ka.admpv_cod_cli = K_COD_CLIENTE) A
       ORDER BY DECODE(A.admpc_tpo_punto, 'B', 1, 2), A.admpn_id_kardex ASC;

  BEGIN
    /*
    Los puntos Bono son los q se consumiran primero. Tipo de punto 'B'
    */
    K_CODERROR := 0;
    K_MSJERROR := '';

    V_PUNTOS_REQUERIDOS := K_PUNTOS;

    -- Comienza el Canje, dato de entrada el codigo de cliente
    IF K_COD_CLIENTE IS NOT NULL THEN
      IF K_TIP_CLI = '3' THEN
        -- Clientes Prepago
        OPEN LISTA_KARDEX_1;
        FETCH LISTA_KARDEX_1
          INTO LK_TPO_PUNTO,
               LK_ID_KARDEX,
               LK_SLD_PUNTOS,
               LK_COD_CLI,
               LK_COD_CLIIB,
               LK_TPO_PREMIO;
        WHILE LISTA_KARDEX_1%FOUND AND V_PUNTOS_REQUERIDOS > 0 LOOP
          IF LK_SLD_PUNTOS <= V_PUNTOS_REQUERIDOS THEN

            -- Actualiza Kardex
            UPDATE PCLUB.admpt_kardex
               SET admpn_sld_punto = 0, admpc_estado = 'C'
             WHERE admpn_id_kardex = LK_ID_KARDEX;
            

            -- Actualiza Saldos_cliente
            IF LK_TPO_PUNTO = 'C' OR LK_TPO_PUNTO = 'L' THEN
              /* Punto Claro Club */
              UPDATE PCLUB.admpt_saldos_cliente
                 SET admpn_saldo_cc = -LK_SLD_PUNTOS +
                                      NVL(admpn_saldo_cc, 0)
               WHERE admpv_cod_cli = LK_COD_CLI;

            ELSIF LK_TPO_PUNTO = 'I' THEN
              /* Punto IB*/
              UPDATE PCLUB.admpt_saldos_cliente
                 SET admpn_saldo_ib = -LK_SLD_PUNTOS +
                                      NVL(admpn_saldo_ib, 0)
               WHERE admpn_cod_cli_ib = LK_COD_CLIIB;
            ELSE
              IF LK_TPO_PUNTO = 'B' THEN
                IF LK_TPO_PREMIO = 0 THEN
                  /* Puntos Bonos para cualquier canje*/
                  UPDATE PCLUB.admpt_saldos_cliente
                     SET admpn_saldo_cc = -LK_SLD_PUNTOS +
                                          NVL(admpn_saldo_cc, 0)
                   WHERE admpv_cod_cli = LK_COD_CLI;
                ELSE
                  /* Puntos Bonos para canjes de ciertos premios*/
                  UPDATE PCLUB.admpt_saldos_bono_cliente
                     SET ADMPN_SALDO = -LK_SLD_PUNTOS + NVL(ADMPN_SALDO, 0)
                   WHERE ADMPV_COD_CLI = LK_COD_CLI
                     AND ADMPN_GRUPO = K_GRUPO;
                END IF;
              END IF;
            END IF;

            V_PUNTOS_REQUERIDOS := V_PUNTOS_REQUERIDOS - LK_SLD_PUNTOS;
            
            nPUNTOS_DESC := nPUNTOS_DESC + LK_SLD_PUNTOS;

          ELSE
            IF LK_SLD_PUNTOS > V_PUNTOS_REQUERIDOS THEN

              -- Actualiza Kardex
              UPDATE PCLUB.admpt_kardex
                 SET admpn_sld_punto = LK_SLD_PUNTOS - V_PUNTOS_REQUERIDOS
               WHERE admpn_id_kardex = LK_ID_KARDEX;

              

              -- Actualiza Saldos_cliente
              IF LK_TPO_PUNTO = 'C' OR LK_TPO_PUNTO = 'L' THEN
                /* Punto Claro Club */
                UPDATE PCLUB.admpt_saldos_cliente
                   SET admpn_saldo_cc = -V_PUNTOS_REQUERIDOS +
                                        NVL(admpn_saldo_cc, 0)
                 WHERE admpv_cod_cli = LK_COD_CLI;
              ELSIF LK_TPO_PUNTO = 'I' THEN
                /* Punto IB*/
                UPDATE PCLUB.admpt_saldos_cliente
                   SET admpn_saldo_ib = -V_PUNTOS_REQUERIDOS +
                                        NVL(admpn_saldo_ib, 0)
                 WHERE admpn_cod_cli_ib = LK_COD_CLIIB;
              ELSE
                IF LK_TPO_PUNTO = 'B' THEN
                  IF LK_TPO_PREMIO = 0 THEN
                    /* Puntos Bonos para cualquier canje*/
                    UPDATE PCLUB.admpt_saldos_cliente
                       SET admpn_saldo_cc = -V_PUNTOS_REQUERIDOS +
                                            NVL(admpn_saldo_cc, 0)
                     WHERE admpv_cod_cli = LK_COD_CLI;
                  ELSE
                    /* Puntos Bonos para canjes de ciertos premios*/
                    UPDATE PCLUB.admpt_saldos_bono_cliente
                       SET ADMPN_SALDO = -V_PUNTOS_REQUERIDOS +
                                         NVL(ADMPN_SALDO, 0)
                     WHERE ADMPV_COD_CLI = LK_COD_CLI
                       AND ADMPN_GRUPO = K_GRUPO;
                  END IF;
                END IF;
              END IF;
              
              nPUNTOS_DESC := nPUNTOS_DESC + V_PUNTOS_REQUERIDOS;

              V_PUNTOS_REQUERIDOS := 0;
              
            END IF;
          END IF;
          FETCH LISTA_KARDEX_1
            INTO LK_TPO_PUNTO,
                 LK_ID_KARDEX,
                 LK_SLD_PUNTOS,
                 LK_COD_CLI,
                 LK_COD_CLIIB,
                 LK_TPO_PREMIO;
        END LOOP;
        CLOSE LISTA_KARDEX_1;
        
        IF K_PUNTOS = nPUNTOS_DESC THEN
          
          SELECT NVL(PCLUB.admpt_kardex_sq.NEXTVAL, -1) INTO V_ID_KARDEX FROM dual;
          
          INSERT INTO PCLUB.admpt_kardex
          (admpn_id_kardex,
          admpn_cod_cli_ib,
          admpv_cod_cli,
          admpv_cod_cpto,
          admpd_fec_trans,
          admpn_puntos,
          admpv_nom_arch,
          admpc_tpo_oper,
          admpc_tpo_punto,
          admpn_sld_punto,
          admpc_estado)
          VALUES
          (V_ID_KARDEX,
          '',
          K_COD_CLIENTE,
          K_COD_CPTO,
          TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
          K_PUNTOS * (-1),
          '',
          'S',
          'C',
          0,
          'C');

                   
          K_CODERROR := 0;
          K_MSJERROR := '';
          K_IDKARDEX := V_ID_KARDEX;
          
        ELSE
          K_CODERROR := -1;
          K_MSJERROR := 'Fallo descuento de Puntos SP ADMPSI_DESC_PTOS_BONO. Puntos descontados diferente a puntos canjeados: ' ||TO_CHAR(nPUNTOS_DESC)||' <> ' ||TO_CHAR(K_PUNTOS);
          K_IDKARDEX := 0;
        END IF;
        
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR := SQLCODE;
      K_MSJERROR := SUBSTR(SQLERRM, 1, 400);
      K_IDKARDEX := 0;

  END ADMPSI_DESC_PTOS_BONO;
  
PROCEDURE ADMPSI_DESC_PUNTOS(K_ID_CANJE    NUMBER,
                               K_SEC         NUMBER,
                               K_PUNTOS      NUMBER,
                               K_COD_CLIENTE IN VARCHAR2,
                               K_TIP_CLI     IN VARCHAR2,
                               K_COD_CPTO      IN VARCHAR2,
                               K_IDKARDEX    OUT NUMBER,
                               K_CODERROR    OUT NUMBER,
                               K_MSJERROR    OUT VARCHAR2) IS

    --****************************************************************
    -- Nombre SP           :  ADMPSI_DESC_PUNTOS
    -- Proposito           :  Descuenta puntos para Canje segun FIFO y el requerimento definido
    -- Input               :  K_ID_CANJE Identificador del canje
    --                        K_SEC Secuencial del Detalle
    --                        K_PUNTOS Total de Puntos a descontar
    --                        K_COD_CLIENTE Codigo de Cliente
    --                        K_TIPO_DOC Tipo de Documento
    --                        K_NUM_DOC Numero de Documento
    --                        K_TIP_CLI Tipo de Cliente
    --                        K_COD_CPTO
    -- Output              :  K_CODERROR
    --                        K_MSJERROR
    -- Creado por          :  Omar Campos
    -- Fec Creacion        :  16/02/2018
    --****************************************************************

    V_PUNTOS_REQUERIDOS NUMBER := 0;

    LK_TPO_PUNTO  CHAR(1);
    LK_ID_KARDEX  NUMBER;
    LK_SLD_PUNTOS NUMBER;
    LK_COD_CLI    VARCHAR2(40);
    LK_COD_CLIIB  NUMBER;
    LK_TPO_PREMIO NUMBER;
    
    nPUNTOS_DESC NUMBER := 0;
    V_ID_KARDEX NUMBER;

    /* Cursor 1 */
    CURSOR LISTA_KARDEX_1 IS
      SELECT ka.admpc_tpo_punto,
             ka.admpn_id_kardex,
             ka.admpn_sld_punto,
             ka.admpv_cod_cli,
             admpn_cod_cli_ib,
             ka.admpn_tip_premio
        FROM admpt_kardex ka
       WHERE ka.admpc_estado = 'A'
         AND ka.admpc_tpo_oper = 'E'
         AND ka.admpn_sld_punto > 0
         AND trunc(ka.admpd_fec_trans) <=
             trunc(TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY')) --'17/09/2010'
         AND (KA.ADMPN_TIP_PREMIO IS NULL OR KA.ADMPN_TIP_PREMIO=0)
         AND ka.admpv_cod_cli IN
             (K_COD_CLIENTE) /*Selecciona todos los codigos que cumplen con la condicion*/
                 ORDER BY DECODE(admpc_tpo_punto, 'B', 1, 2), admpn_id_kardex ASC;

    /* Cursor 2 */
    CURSOR LISTA_KARDEX_3 IS
      SELECT ka.admpc_tpo_punto,
             ka.admpn_id_kardex,
             ka.admpn_sld_punto,
             ka.admpv_cod_cli,
             admpn_cod_cli_ib
        FROM admpt_kardex ka
       WHERE ka.admpc_estado = 'A'
         AND ka.admpc_tpo_oper = 'E'
         AND ka.admpn_sld_punto > 0
         AND trunc(ka.admpd_fec_trans) <=
             trunc(TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY')) --'17/09/2010'
         AND ka.admpv_cod_cli IN
             (K_COD_CLIENTE) /*Selecciona todos los codigos que cumplen con la condicion*/
       ORDER BY DECODE(admpc_tpo_punto, 'I', 1, 'L', 2, 'C', 3),
                admpn_id_kardex ASC;

  BEGIN
    /*
    Los puntos IB son los q se consumiran primero Tipo de punto 'I'
    los puntos Loyalty 'L' y ClaroClub 'C', se consumiran en ese orden
    */
    

    V_PUNTOS_REQUERIDOS := K_PUNTOS;

    -- Comienza el Canje, dato de entrada el codigo de cliente
    IF K_COD_CLIENTE IS NOT NULL THEN
      IF K_TIP_CLI = '3' OR K_TIP_CLI = '4' OR K_TIP_CLI = '8'  THEN
        -- Clientes Prepago o B2E
        OPEN LISTA_KARDEX_1;
        FETCH LISTA_KARDEX_1
          INTO LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB, LK_TPO_PREMIO;
        WHILE LISTA_KARDEX_1%FOUND AND V_PUNTOS_REQUERIDOS > 0 LOOP
          IF LK_SLD_PUNTOS <= V_PUNTOS_REQUERIDOS THEN

            -- Actualiza Kardex
            UPDATE admpt_kardex
               SET admpn_sld_punto = 0, admpc_estado = 'C'
             WHERE admpn_id_kardex = LK_ID_KARDEX;

            

            -- Actualiza Saldos_cliente
            IF LK_TPO_PUNTO = 'C' OR LK_TPO_PUNTO = 'L' THEN
              /* Punto Claro Club */
               UPDATE admpt_saldos_cliente
               SET admpn_saldo_cc = -LK_SLD_PUNTOS + NVL(admpn_saldo_cc, 0)
               WHERE admpv_cod_cli = LK_COD_CLI;
            ELSIF LK_TPO_PUNTO = 'B' THEN
               IF LK_TPO_PREMIO = 0 THEN
                    /* Puntos Bonos para cualquier canje*/
                    UPDATE PCLUB.admpt_saldos_cliente
                     SET admpn_saldo_cc = -LK_SLD_PUNTOS +
                                          NVL(admpn_saldo_cc, 0)
                   WHERE admpv_cod_cli = LK_COD_CLI;
               END IF;
            ELSE
              /* Punto IB*/
              IF LK_TPO_PUNTO = 'I' THEN
                 UPDATE admpt_saldos_cliente
                 SET admpn_saldo_ib = -LK_SLD_PUNTOS + NVL(admpn_saldo_ib, 0)
                 WHERE admpn_cod_cli_ib = LK_COD_CLIIB;
              END IF;
            END IF;

            V_PUNTOS_REQUERIDOS := V_PUNTOS_REQUERIDOS - LK_SLD_PUNTOS;
            
            nPUNTOS_DESC := nPUNTOS_DESC + LK_SLD_PUNTOS;
            

          ELSE
            IF LK_SLD_PUNTOS > V_PUNTOS_REQUERIDOS THEN

              -- Actualiza Kardex
              UPDATE admpt_kardex
                 SET admpn_sld_punto = LK_SLD_PUNTOS - V_PUNTOS_REQUERIDOS
               WHERE admpn_id_kardex = LK_ID_KARDEX;

              
              -- Actualiza Saldos_cliente
              IF LK_TPO_PUNTO = 'C' OR LK_TPO_PUNTO = 'L' THEN
                /* Punto Claro Club */
                 UPDATE admpt_saldos_cliente
                 SET admpn_saldo_cc = -V_PUNTOS_REQUERIDOS + NVL(admpn_saldo_cc, 0)
                 WHERE admpv_cod_cli = LK_COD_CLI;
              ELSIF LK_TPO_PUNTO = 'B' THEN
                  IF LK_TPO_PREMIO = 0 THEN
                    /* Puntos Bonos para cualquier canje*/
                    UPDATE PCLUB.admpt_saldos_cliente
                       SET admpn_saldo_cc = -V_PUNTOS_REQUERIDOS +
                                            NVL(admpn_saldo_cc, 0)
                     WHERE admpv_cod_cli = LK_COD_CLI;
                  END IF;
              ELSE
                /* Punto IB*/
                IF LK_TPO_PUNTO = 'I' THEN
                    UPDATE admpt_saldos_cliente
                    SET admpn_saldo_ib = -V_PUNTOS_REQUERIDOS + NVL(admpn_saldo_ib, 0)
                    WHERE admpn_cod_cli_ib = LK_COD_CLIIB;
                END IF;
              END IF;
            
              nPUNTOS_DESC := nPUNTOS_DESC + V_PUNTOS_REQUERIDOS;
            
              V_PUNTOS_REQUERIDOS := 0;

            END IF;
          END IF;
          FETCH LISTA_KARDEX_1
            INTO LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB, LK_TPO_PREMIO;
        END LOOP;
        CLOSE LISTA_KARDEX_1;
      ELSE
        IF K_TIP_CLI = '1' OR K_TIP_CLI = '2' THEN
          OPEN LISTA_KARDEX_3;
          FETCH LISTA_KARDEX_3
            INTO LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB;
          WHILE LISTA_KARDEX_3%FOUND AND V_PUNTOS_REQUERIDOS > 0 LOOP
            IF LK_SLD_PUNTOS <= V_PUNTOS_REQUERIDOS THEN
              -- Actualiza Kardex
              UPDATE admpt_kardex
                 SET admpn_sld_punto = 0, admpc_estado = 'C'
               WHERE admpn_id_kardex = LK_ID_KARDEX;

              
              -- Actualiza Saldos_cliente
              IF LK_TPO_PUNTO = 'C' OR LK_TPO_PUNTO = 'L' THEN
                /* Punto Claro Club */
                 UPDATE admpt_saldos_cliente
                 SET admpn_saldo_cc = -LK_SLD_PUNTOS + NVL(admpn_saldo_cc, 0)
                 WHERE admpv_cod_cli = LK_COD_CLI;
              ELSE
                /* Punto IB*/
                IF LK_TPO_PUNTO = 'I' THEN
                   UPDATE admpt_saldos_cliente
                   SET admpn_saldo_ib = -LK_SLD_PUNTOS + NVL(admpn_saldo_ib, 0)
                   WHERE admpn_cod_cli_ib = LK_COD_CLIIB;
                END IF;
              END IF;
              V_PUNTOS_REQUERIDOS := V_PUNTOS_REQUERIDOS - LK_SLD_PUNTOS;
            
              nPUNTOS_DESC := nPUNTOS_DESC + LK_SLD_PUNTOS;

            ELSE
              IF LK_SLD_PUNTOS > V_PUNTOS_REQUERIDOS THEN

                UPDATE admpt_kardex
                   SET admpn_sld_punto = LK_SLD_PUNTOS - V_PUNTOS_REQUERIDOS
                 WHERE admpn_id_kardex = LK_ID_KARDEX;
                
                -- Actualiza Saldos_cliente
                IF LK_TPO_PUNTO = 'C' OR LK_TPO_PUNTO = 'L' THEN
                  /* Punto Claro Club */
                   UPDATE admpt_saldos_cliente
                   SET admpn_saldo_cc = -V_PUNTOS_REQUERIDOS + NVL(admpn_saldo_cc, 0)
                   WHERE admpv_cod_cli = LK_COD_CLI;
                ELSE
                  /* Punto IB*/
                  IF LK_TPO_PUNTO = 'I' THEN
                     UPDATE admpt_saldos_cliente
                     SET admpn_saldo_ib = -V_PUNTOS_REQUERIDOS + NVL(admpn_saldo_ib, 0)
                     WHERE admpn_cod_cli_ib = LK_COD_CLIIB;
                  END IF;
                END IF;
            
                nPUNTOS_DESC := nPUNTOS_DESC + V_PUNTOS_REQUERIDOS;
              
                V_PUNTOS_REQUERIDOS := 0;
              END IF;
            END IF;
            FETCH LISTA_KARDEX_3
              INTO LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB;
          END LOOP;
          CLOSE LISTA_KARDEX_3;
        END IF;
      END IF;
      
      IF K_PUNTOS = nPUNTOS_DESC THEN
          
        SELECT NVL(PCLUB.admpt_kardex_sq.NEXTVAL, -1) INTO V_ID_KARDEX FROM dual;
        
        INSERT INTO PCLUB.admpt_kardex
        (admpn_id_kardex,
        admpn_cod_cli_ib,
        admpv_cod_cli,
        admpv_cod_cpto,
        admpd_fec_trans,
        admpn_puntos,
        admpv_nom_arch,
        admpc_tpo_oper,
        admpc_tpo_punto,
        admpn_sld_punto,
        admpc_estado)
        VALUES
        (V_ID_KARDEX,
        '',
        K_COD_CLIENTE,
        K_COD_CPTO,
        TO_DATE(TO_CHAR(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY'),
        K_PUNTOS * (-1),
        '',
        'S',
        'C',
        0,
        'C');

                
        K_CODERROR := 0;
        K_MSJERROR := '';
        K_IDKARDEX := V_ID_KARDEX;
    
      ELSE
        K_CODERROR := -1;
        K_MSJERROR := 'Fallo descuento de Puntos SP ADMPSI_DESC_PUNTOS. Puntos descontados diferente a puntos canjeados: ' ||TO_CHAR(nPUNTOS_DESC)||' <> ' ||TO_CHAR(K_PUNTOS);
        K_IDKARDEX := 0;
      END IF;
      
    ELSE
      K_CODERROR := 1;
      K_MSJERROR := 'Ingrese parametro K_COD_CLIENTE';
      K_IDKARDEX := 0;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      K_CODERROR := SQLCODE;
      K_MSJERROR := SUBSTR(SQLERRM, 1, 400);
      K_IDKARDEX := 0;

  END ADMPSI_DESC_PUNTOS;

PROCEDURE ADMPSI_DESC_PUNTOS_FIJA( K_ID_CANJE    IN NUMBER,
                               K_SEC         IN NUMBER,
                               K_PUNTOS      IN NUMBER,
                               K_COD_CLIENTE IN VARCHAR2,
                               K_TIPO_DOC    IN VARCHAR2,
                               K_NUM_DOC     IN VARCHAR2,
                               K_TIP_CLI     IN VARCHAR2,
                               K_USUARIO     IN VARCHAR2,
                               K_COD_CPTO    IN VARCHAR2,
                               K_IDGRP       IN NUMBER,
                               K_ITEMGRP_I   IN NUMBER,
                               K_TIPO        IN VARCHAR2,
                               K_TBLCLIENTE  IN VARCHAR2,
                               K_ITEMGRP_O   OUT NUMBER,
                               K_CODERROR    OUT NUMBER,
                               K_DESCERROR   OUT VARCHAR2) IS

    --****************************************************************
    -- Nombre SP           :  ADMPSI_DESC_PUNTOS_FIJA
    -- Propósito           :  Descuenta puntos para la Fija Canje segun FIFO y el requerimento definido
    -- Input               :  K_ID_CANJE Identificador del canje
    --                        K_SEC Secuencial del Detalle
    --                        K_PUNTOS Total de Puntos a descontar
    --                        K_COD_CLIENTE Codigo de Cliente
    --                        K_TIPO_DOC Tipo de Documento
    --                        K_NUM_DOC Numero de Documento
    --                        K_TIP_CLI Tipo de Cliente
    --                        K_USUARIO Usuario
    --                        K_COD_CPTO
    -- Output              :  K_CODERROR
    --                        K_DESCERROR
    -- Creado por          :  Omar Campos
    -- Fec Creación        :  16/02/2018
    --****************************************************************

    V_PUNTOS_REQUERIDOS NUMBER := 0;

    LK_TPO_PUNTO  CHAR(1);
    LK_ID_KARDEX  NUMBER;
    LK_SLD_PUNTOS NUMBER;
    LK_COD_CLI    VARCHAR2(40);
    LK_COD_CLIIB  NUMBER;
    
    nPUNTOS_DESC NUMBER := 0;
    V_ID_KARDEX NUMBER;
    bFLAG BOOLEAN := FALSE;
    nPUNTOS NUMBER := 0;

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
       ORDER BY admpv_cod_cli_prod, admpn_id_kardex ASC, DECODE(admpc_tpo_punto, 'I', 1, 'L', 2, 'C', 3);
       
  nID_GRP   NUMBER;
  nITEM_GRP NUMBER;
    
  BEGIN
    /*
    Los puntos IB son los q se consumiran primero Tipo de punto 'I'
    los puntos Loyalty 'L' y ClaroClub 'C', se consumiran en ese orden
    */

    V_PUNTOS_REQUERIDOS := K_PUNTOS;

    nID_GRP   := K_IDGRP;
    nITEM_GRP := K_ITEMGRP_I;

    -- Comienza el Canje, dato de entrada el codigo de cliente
    IF K_SEC IS NOT NULL AND K_PUNTOS IS NOT NULL AND
       K_COD_CLIENTE IS NOT NULL AND K_TIPO_DOC IS NOT NULL AND K_NUM_DOC IS NOT NULL THEN --Prepago
      IF  K_TIP_CLI IN ('6','7','9')  THEN
        -- Clientes Prepago o B2E
        OPEN LISTA_KARDEX_1;
        FETCH LISTA_KARDEX_1
          INTO LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB;
        WHILE LISTA_KARDEX_1%FOUND AND V_PUNTOS_REQUERIDOS > 0 LOOP


          IF LK_SLD_PUNTOS <= V_PUNTOS_REQUERIDOS THEN
            nPUNTOS := LK_SLD_PUNTOS;
            -- Actualiza Kardexfija
            UPDATE PCLUB.ADMPT_kardexfija  SET admpn_sld_punto = 0, admpc_estado = 'C', ADMPV_USU_MOD= K_USUARIO
            WHERE admpn_id_kardex = LK_ID_KARDEX;
            -- Actualiza Saldos_clientefija
            IF LK_TPO_PUNTO = 'C' OR LK_TPO_PUNTO = 'L' THEN
              /* Punto Claro Club */
              UPDATE PCLUB.ADMPT_saldos_clientefija SET admpn_saldo_cc = -LK_SLD_PUNTOS + NVL(admpn_saldo_cc, 0) , ADMPV_USU_MOD= K_USUARIO
              WHERE ADMPV_COD_CLI_PROD = LK_COD_CLI;
            END IF;
            V_PUNTOS_REQUERIDOS := V_PUNTOS_REQUERIDOS - LK_SLD_PUNTOS;
            
            nPUNTOS_DESC := nPUNTOS_DESC + LK_SLD_PUNTOS;
         
            bFLAG := TRUE;
         ELSE
            IF LK_SLD_PUNTOS > V_PUNTOS_REQUERIDOS THEN
              nPUNTOS := V_PUNTOS_REQUERIDOS;
                -- Actualiza Kardex
                  UPDATE PCLUB.ADMPT_kardexFIJA    SET admpn_sld_punto = LK_SLD_PUNTOS - V_PUNTOS_REQUERIDOS, ADMPV_USU_MOD= K_USUARIO
                  WHERE admpn_id_kardex = LK_ID_KARDEX;
                -- Actualiza Saldos_cliente
                IF LK_TPO_PUNTO = 'C' OR LK_TPO_PUNTO = 'L' THEN
                  /* Punto Claro Club */
                   UPDATE PCLUB.ADMPT_saldos_clienteFIJA SET admpn_saldo_cc = -V_PUNTOS_REQUERIDOS + NVL(admpn_saldo_cc, 0), ADMPV_USU_MOD= K_USUARIO
                   WHERE ADMPV_COD_CLI_PROD = LK_COD_CLI;
                END IF;
            
                nPUNTOS_DESC := nPUNTOS_DESC + V_PUNTOS_REQUERIDOS;
                
                V_PUNTOS_REQUERIDOS := 0;
         
                bFLAG := TRUE;
            END IF;
         END IF;
         
         IF bFLAG = TRUE THEN
           SELECT NVL(PCLUB.ADMPT_kardexfija_sq.NEXTVAL, '-1') INTO V_ID_KARDEX FROM dual;

           INSERT INTO PCLUB.ADMPT_kardexfija
             (admpn_id_kardex,
             admpn_cod_cli_ib,
             ADMPV_COD_CLI_PROD,
             admpv_cod_cpto,
             admpd_fec_trans,
             admpn_puntos,
             admpv_nom_arch,
             admpc_tpo_oper,
             admpc_tpo_punto,
             admpn_sld_punto,
             admpc_estado,
             admpv_usu_reg)
            VALUES
             (V_ID_KARDEX,
             '',
             LK_COD_CLI,
             K_COD_CPTO,
             SYSDATE,
             nPUNTOS * (-1),
             '',
             'S',
             'C',
             0,
             'C',
             K_USUARIO);
             
             nITEM_GRP := nITEM_GRP + 1;
          
            INSERT INTO SYSFT_LATAM_CANJE_KM_CC_PROD
              (SYLCKCPN_ID_GRP_CANJE,
               SYLCKCPN_ITEM,
               SYLCKCPV_TIPO_DOC,
               SYLCKCPV_NUM_DOC,
               SYLCKCPV_COD_TPOCL,
               SYLCKCPV_TIPO_CLI,
               SYLCKCPC_TBL_CLI,
               SYLCKCPV_USU_REG,
               SYLCKCPN_ID_KARDEX,
               SYLCKCPN_PUNTOS)
            VALUES
              (nID_GRP,
               nITEM_GRP,
               K_TIPO_DOC,
               K_NUM_DOC,
               K_TIP_CLI,
               K_TIPO,
               K_TBLCLIENTE,
               K_USUARIO,
               V_ID_KARDEX,
               nPUNTOS);
            
            K_ITEMGRP_O := nITEM_GRP;
               
         END IF;
         
         bFLAG := FALSE;         
         
          FETCH LISTA_KARDEX_1
            INTO LK_TPO_PUNTO, LK_ID_KARDEX, LK_SLD_PUNTOS, LK_COD_CLI, LK_COD_CLIIB;
        END LOOP;
        CLOSE LISTA_KARDEX_1;
      END IF;
      IF K_PUNTOS = nPUNTOS_DESC THEN
        K_CODERROR := 0;
        K_DESCERROR := '';    
      ELSE
        K_CODERROR := -1;
        K_DESCERROR := 'Fallo descuento de Puntos SP ADMPSI_DESC_PUNTOS_FIJA. Puntos descontados diferente a puntos canjeados: ' ||TO_CHAR(nPUNTOS_DESC)||' <> ' ||TO_CHAR(K_PUNTOS);
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
  END ADMPSI_DESC_PUNTOS_FIJA;

PROCEDURE SYSFSS_VALIDASALDOKDX(
                            K_COD_CLIENTE  IN VARCHAR2,
                            K_TIP_CLI      IN VARCHAR2,
                            K_CODERROR     OUT NUMBER)
  /*
'****************************************************************************************************************
'* Nombre SP : SYSFSS_VALIDASALDOKDX
'* Propósito : Este procedimiento es responsable de validar el saldo vs kardex.
'* Input :     <Parametro>       -- Descripción de los parametros
               K_COD_CLIENTE     -- Codigo Cliente
               K_TIP_CLI         -- Tipo de Cliente
'* Output :    <Parametro>       -- Descripción de los parametros
               K_CODERROR        -- Codigo de error( 0 OK, 1 Error )
'* Creado por : SAPIA - Omar Campos
'* Fec Creación : 18/03/2018
'****************************************************************************************************************
*/
AS
  V_SALDO  NUMBER;
    V_SALDO_CLIBONO NUMBER;
    V_SALDO_CLI     NUMBER;
  V_SALDOKDX  NUMBER;
  BEGIN
  K_CODERROR:=0;
  V_SALDO:=0;
  V_SALDOKDX:=0;

    IF K_TIP_CLI = 3 THEN
      --Obtengo la Suma del Saldo Cliente
      SELECT SUM(NVL(S.ADMPN_SALDO_CC, 0) + NVL(S.ADMPN_SALDO_IB, 0))
        INTO V_SALDO_CLI
        FROM PCLUB.ADMPT_SALDOS_CLIENTE S
       WHERE S.ADMPV_COD_CLI IN
             (SELECT CC2.ADMPV_COD_CLI
                FROM PCLUB.admpt_cliente CC2,
                     (SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
                        FROM PCLUB.admpt_cliente
                       WHERE ADMPV_COD_CLI = K_COD_CLIENTE
                         AND ADMPV_COD_TPOCL = K_TIP_CLI
                         AND admpc_estado = 'A') CC1 /*Obtiene el numero de doc y su tipo*/
               WHERE CC2.ADMPV_TIPO_DOC = CC1.ADMPV_TIPO_DOC
                 AND CC2.ADMPV_NUM_DOC = CC1.ADMPV_NUM_DOC
                 AND CC2.ADMPV_COD_TPOCL = K_TIP_CLI
                 AND CC2.admpc_estado = 'A');

      --Obtengo la Suma de Saldo Cliente Bono
      SELECT SUM(NVL(SB.ADMPN_SALDO, 0))
        INTO V_SALDO_CLIBONO
        FROM PCLUB.ADMPT_SALDOS_BONO_CLIENTE SB
       WHERE SB.ADMPV_COD_CLI IN
             (SELECT CC2.ADMPV_COD_CLI
                FROM PCLUB.admpt_cliente CC2,
                     (SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
                        FROM PCLUB.admpt_cliente
                       WHERE ADMPV_COD_CLI = K_COD_CLIENTE
                         AND ADMPV_COD_TPOCL = K_TIP_CLI
                         AND admpc_estado = 'A') CC1 /*Obtiene el numero de doc y su tipo*/
               WHERE CC2.ADMPV_TIPO_DOC = CC1.ADMPV_TIPO_DOC
                 AND CC2.ADMPV_NUM_DOC = CC1.ADMPV_NUM_DOC
                 AND CC2.ADMPV_COD_TPOCL = K_TIP_CLI
                 AND CC2.admpc_estado = 'A');

      --Sumo los Saldos de Cliente y Cliente Bono
      V_SALDO := V_SALDO_CLI + V_SALDO_CLIBONO;

      SELECT NVL(SUM(NVL(K.ADMPN_SLD_PUNTO, 0)), 0)
        INTO V_SALDOKDX
        FROM PCLUB.ADMPT_KARDEX K
       WHERE K.ADMPV_COD_CLI IN
             (SELECT CC2.ADMPV_COD_CLI
                FROM PCLUB.admpt_cliente CC2,
                     (SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
                        FROM PCLUB.admpt_cliente
                       WHERE ADMPV_COD_CLI = K_COD_CLIENTE
                         AND ADMPV_COD_TPOCL = K_TIP_CLI
                         AND admpc_estado = 'A') CC1 /*Obtiene el numero de doc y su tipo*/
               WHERE CC2.ADMPV_TIPO_DOC = CC1.ADMPV_TIPO_DOC
                 AND CC2.ADMPV_NUM_DOC = CC1.ADMPV_NUM_DOC
                 AND CC2.ADMPV_COD_TPOCL = K_TIP_CLI
                 AND CC2.admpc_estado = 'A')
         AND K.ADMPC_ESTADO = 'A';

    ELSIF K_TIP_CLI = 8 THEN
  SELECT SUM(NVL(S.ADMPN_SALDO_CC,0)+NVL(S.ADMPN_SALDO_IB,0))
  INTO V_SALDO
  FROM PCLUB.ADMPT_SALDOS_CLIENTE S
  WHERE S.ADMPV_COD_CLI IN
  (SELECT CC2.ADMPV_COD_CLI
                FROM PCLUB.admpt_cliente CC2,
                     (SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
                        FROM PCLUB.admpt_cliente
                       WHERE ADMPV_COD_CLI = K_COD_CLIENTE
                         AND ADMPV_COD_TPOCL = K_TIP_CLI
                         AND admpc_estado = 'A') CC1 /*Obtiene el numero de doc y su tipo*/
               WHERE CC2.ADMPV_TIPO_DOC = CC1.ADMPV_TIPO_DOC
                 AND CC2.ADMPV_NUM_DOC = CC1.ADMPV_NUM_DOC
                 AND CC2.ADMPV_COD_TPOCL = K_TIP_CLI
                 AND CC2.admpc_estado = 'A');

  SELECT NVL(SUM(NVL(K.ADMPN_SLD_PUNTO,0)),0)
  INTO V_SALDOKDX
  FROM PCLUB.ADMPT_KARDEX K
  WHERE K.ADMPV_COD_CLI IN
  (SELECT CC2.ADMPV_COD_CLI
                FROM PCLUB.admpt_cliente CC2,
                     (SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
                        FROM PCLUB.admpt_cliente
                       WHERE ADMPV_COD_CLI = K_COD_CLIENTE
                         AND ADMPV_COD_TPOCL = K_TIP_CLI
                         AND admpc_estado = 'A') CC1 /*Obtiene el numero de doc y su tipo*/
               WHERE CC2.ADMPV_TIPO_DOC = CC1.ADMPV_TIPO_DOC
                 AND CC2.ADMPV_NUM_DOC = CC1.ADMPV_NUM_DOC
                 AND CC2.ADMPV_COD_TPOCL = K_TIP_CLI
                 AND CC2.admpc_estado = 'A')
                 AND K.ADMPC_ESTADO='A';
ELSE

SELECT SUM(NVL(S.ADMPN_SALDO_CC,0)+NVL(S.ADMPN_SALDO_IB,0))
  INTO V_SALDO
  FROM PCLUB.ADMPT_SALDOS_CLIENTE S
  WHERE S.ADMPV_COD_CLI IN
  (SELECT CC2.ADMPV_COD_CLI
                FROM PCLUB.admpt_cliente CC2,
                     (SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
                        FROM PCLUB.admpt_cliente
                       WHERE ADMPV_COD_CLI = K_COD_CLIENTE
                         AND ADMPV_COD_TPOCL  IN (1,2,3)
                         AND admpc_estado = 'A') CC1 /*Obtiene el numero de doc y su tipo*/
               WHERE CC2.ADMPV_TIPO_DOC = CC1.ADMPV_TIPO_DOC
                 AND CC2.ADMPV_NUM_DOC = CC1.ADMPV_NUM_DOC
                 AND CC2.ADMPV_COD_TPOCL IN (1,2,3)
                 AND CC2.admpc_estado = 'A');

  SELECT NVL(SUM(NVL(K.ADMPN_SLD_PUNTO,0)),0)
  INTO V_SALDOKDX
  FROM PCLUB.ADMPT_KARDEX K
  WHERE K.ADMPV_COD_CLI IN
  (SELECT CC2.ADMPV_COD_CLI
                FROM PCLUB.admpt_cliente CC2,
                     (SELECT ADMPV_TIPO_DOC, ADMPV_NUM_DOC
                        FROM PCLUB.admpt_cliente
                       WHERE ADMPV_COD_CLI = K_COD_CLIENTE
                         AND ADMPV_COD_TPOCL  IN (1,2,3)
                         AND admpc_estado = 'A') CC1 /*Obtiene el numero de doc y su tipo*/
               WHERE CC2.ADMPV_TIPO_DOC = CC1.ADMPV_TIPO_DOC
                 AND CC2.ADMPV_NUM_DOC = CC1.ADMPV_NUM_DOC
                 AND CC2.ADMPV_COD_TPOCL  IN (1,2,3)
                 AND CC2.admpc_estado = 'A')
                 AND K.ADMPC_ESTADO='A';

END IF;

  IF V_SALDO<>V_SALDOKDX THEN
     K_CODERROR:=1;
  END IF;

EXCEPTION
      WHEN OTHERS THEN
     K_CODERROR:=1;
END SYSFSS_VALIDASALDOKDX;

PROCEDURE SYSFSI_CANJE_CAMP(PI_LINEA              in VARCHAR2,
                            PI_CORREO             in VARCHAR2,
                            PI_TIP_REG_LATAM      in VARCHAR2,
                            PI_ID_PROG_LATAM      in VARCHAR2,
                            PI_FEC_CANJE          in DATE,
                            PI_KM_LATAM           in NUMBER,
                            PI_NOM_CLI            in VARCHAR2,
                            PI_ID_SOCIO_LATAM     in VARCHAR2,
                            PI_CORRELATIVO        in VARCHAR2,
                            PI_COD_APLI           in VARCHAR2,
                            PI_TIPO_CANJE         in VARCHAR2,
                            PI_ESTADO_REG         in VARCHAR2,
                            PI_ESTADO_CANJE_LATAM in VARCHAR2,
                            PI_COD_ERR_LATAM      in VARCHAR2,
                            PI_USU_REG            in VARCHAR2,
                            PI_COD_RESP           in VARCHAR2,
                            PI_MSG_RESP           in VARCHAR2,
                            PI_ID_TRANS           in VARCHAR2,
                            PI_TIPO_DOC           in VARCHAR2,
                            PI_NUM_DOC            in VARCHAR2,
                            PI_NOM_ARCHIVO        in VARCHAR2,
                            PO_COD_ERR            out VARCHAR2,
                            PO_DES_ERR            out VARCHAR2,
                            PO_ID_CANJE           out NUMBER)

  /*
  '****************************************************************************************************************
  '* Nombre SP : SYSFSI_CANJE_CAMP
  '* Propósito : Este procedimiento es responsable de registrar los Puntos que el cliente
                 va a canjear para Portabilidad y/o Renovacion.
  '* Input :     <Parametro>       -- Descripción de los parametros
                PI_TIP_CANJE       -- Tipo de canje: CK si es de Claro puntos a KM y
                                      KC si es de KM a Claro Puntos
                PI_TIP_DOC_CC      -- Tipo de documento de Cliente Claro Club
                PI_NUM_DOC         -- Numero de documento de Cliente Claro Club
                PI_LINEA           -- Línea de donde se solicitó el canje
                PI_CORREO          -- Correo que viene desde Mi Claro
                PI_PTOS_CC         -- Cantidad de Claro Puntos
                PI_KM_LATAM        -- Cantidad de KM Latam
                PI_GRP_CANJE       -- Codigo de Grupo que guarda los canjes de CC
                PI_USU_REG         -- Usuario
                PI_COD_APLI        -- Codigo de Aplicación que invoca al SP
                PI_ESTADO_REG      -- Estado de registro (P pendiente (CK), F finalizado (KC), R error)
                PI_NOM_SOC         -- Nombre de Socio
                PI_APE_SOC         -- Apellido de Socio
                PI_COD_RESP        -- Codigo de Respuesta
                PI_MSG_RESP        -- Menasaje de Respueta
                PI_ID_TRANS        -- Id Transaccion
  '* Output :    <Parametro>       -- Descripción de los parametros
                PO_COD_ERR         -- Codigo de error( 0 OK, 1 Error en parametros,
                                      -1 error oracle)
                PO_DES_ERR         -- Descripción del error
  '* Creado por : SAPIA - Omar Campos
  '* Fec Creación : 16/04/2018
  '****************************************************************************************************************
  */

 IS

 vCORRELATIVO VARCHAR2(12);
 nCOUNT       NUMBER;

BEGIN

  -- Parametro: PI_TIPO_CANJE
  IF LENGTH(TRIM(PI_TIPO_CANJE)) <= 0 OR PI_TIPO_CANJE IS NULL THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_TIPO_CANJE';
    RETURN;
  END IF;

  -- SE VALIDA SI EL REGISTRO ESTA DUPLICADO
  SELECT COUNT(1) INTO nCOUNT FROM PCLUB.SYSFT_LATAM_CANJE_KM_CC C
  WHERE C.SYLCKCV_CTA_SOC_LATAM = PI_ID_SOCIO_LATAM 
        AND TRUNC(C.SYLCKCD_FEC_CANJE) = TRUNC(PI_FEC_CANJE)
        AND C.SYLCKCN_KM_LATAM = PI_KM_LATAM
        AND C.SYLCKCV_ID_PROG_LATAM = PI_ID_PROG_LATAM
        AND C.SYLCKCC_ESTADO <> 'R';
  
  IF nCOUNT > 0 THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Socio Latam, ya tiene una canje para este día con la misma cantidad de puntos';
    
    RETURN;
  END IF;

  PO_COD_ERR := '0';
  PO_DES_ERR := 'OK';

  SELECT SYSFSQ_LATAM_CANJE.NEXTVAL INTO PO_ID_CANJE FROM DUAL;

  IF TRIM(PI_CORRELATIVO) IS NULL THEN
    SELECT SUBSTR('00000000000'||TO_CHAR((NVL(MAX(TO_NUMBER(SYLCKCV_CORRELATIVO)),0)+1)),LENGTH('00000000000'||TO_CHAR((NVL(MAX(TO_NUMBER(SYLCKCV_CORRELATIVO)),0)+1)))-11,12)
    INTO vCORRELATIVO
    FROM SYSFT_LATAM_CANJE_KM_CC;
  ELSE
    vCORRELATIVO := TRIM(PI_CORRELATIVO);
  END IF;

  INSERT INTO SYSFT_LATAM_CANJE_KM_CC
    (SYLCKCN_ID_CANJE,
     SYLCKCV_LINEA,
     SYLCKCV_CORREO,
     SYLCKCN_ID_GRP_CANJE,
     SYLCKCC_TIP_REG_LATAM,
     SYLCKCV_NUMCTA_LATAM,
     SYLCKCV_ID_PROG_LATAM,
     SYLCKCV_FEC_CANJE,
     SYLCKCD_FEC_CANJE,
     SYLCKCN_KM_LATAM,
     SYLCKCN_CC,
     SYLCKCV_NOM_CLI,
     SYLCKCV_CTA_SOC_LATAM,
     SYLCKCV_LOCATIONID,
     SYLCKCV_LOCATIONDESC,
     SYLCKCV_CORRELATIVO,
     SYLCKCV_DIAS,
     SYLCKCV_COD_APLI,
     SYLCKCV_TIPO_CANJE,
     SYLCKCC_ESTADO,
     SYLCKCC_EST_CANJE,
     SYLCKCV_COD_ERR_LATAM,
     SYLEKCV_USU_REG,
     SYLCKCV_COD_RESP,
     SYLCKCV_MSG_RESP,
     SYLCKCV_ID_TRANS,
     SYLCKCV_TIP_DOC,
     SYLCKCV_NUM_DOC,
     SYLCKCV_NOM_ARCHIVO)
  VALUES
    (PO_ID_CANJE,
     PI_LINEA,
     PI_CORREO,
     NULL,
     PI_TIP_REG_LATAM,
     '',
     PI_ID_PROG_LATAM,
     TO_CHAR(PI_FEC_CANJE, 'yyyymmdd hh24miss'),
     PI_FEC_CANJE,
     PI_KM_LATAM,
     0,
     PI_NOM_CLI,
     PI_ID_SOCIO_LATAM,
     '',
     '',
     vCORRELATIVO,
     '',
     PI_COD_APLI,
     PI_TIPO_CANJE,
     PI_ESTADO_REG,
     PI_ESTADO_CANJE_LATAM,
     PI_COD_ERR_LATAM,
     PI_USU_REG,
     PI_COD_RESP,
     SUBSTR(NVL(PI_MSG_RESP, ''), 1, 500),
     PI_ID_TRANS,
     PI_TIPO_DOC,
     PI_NUM_DOC,
     PI_NOM_ARCHIVO);

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    PO_COD_ERR := '-1';
    PO_DES_ERR := 'ERROR => ' || TO_CHAR(SQLCODE) || ' : ' || SQLERRM;

END SYSFSI_CANJE_CAMP;

PROCEDURE SYSFSS_DATOS_CANJE(PI_ID_CANJE   IN NUMBER,
                       PO_COD_ERR    OUT VARCHAR2,
                       PO_DES_ERR    OUT VARCHAR2,
                       PO_LINEA      OUT VARCHAR2,
                       PO_CORREO     OUT VARCHAR2,
                       PO_COD_APLI   OUT VARCHAR2,
                       PO_PTO_CC     OUT NUMBER,
                       PO_KM_LATAM   OUT NUMBER,
                       PO_TIPO_CANJE OUT VARCHAR2,
                       PO_ID_PROG_LATAM OUT VARCHAR2,
                       PO_ID_SOCIO   OUT VARCHAR2)

  /*
  '****************************************************************************************************************
  '* Nombre SP : SYSFSS_DATOS_CANJE
  '* Propósito : Este procedimiento es responsable de obtener los datos del canje en base al ID_CANJE.
  '* Input :     <Parametro>       -- Descripción de los parametros
                PI_ACCOUNT_NUM      -- El correlativo al que pertenece el registro
                PI_EST_ERR          -- Estado de Registro (Está Acreditado; Está Aceptado; Está con error)
                PI_COD_ERR          -- Codigo de error enviado por Latam
                PI_USU_REG          -- Usuario
  '* Output :    <Parametro>       -- Descripción de los parametros
                 PO_LINEA          -- Linea del canje para envio de mensaje
                 PO_CORREO         -- Correo del canje
                 PO_COD_APLI       -- Cod Aplicación que genero el canje
                 PO_PTO_CC         -- Cantidad de Claro Puntos
                 PO_KM_LATAM       -- Cantidad de KM Latam
                 PO_COD_ERR        -- Codigo de error( 0 OK, 1 Error en parametros, 2 no hay registros a actualizar,
                                      3 canje ya procesado, -1 error oracle)
                 PO_DES_ERR        -- Descripción del error
  '* Creado por : SAPIA - Omar Campos
  '* Fec Creación : 30/10/2017
  '****************************************************************************************************************
  */

 IS

BEGIN

  IF LENGTH(TRIM(PI_ID_CANJE)) <= 0 OR PI_ID_CANJE IS NULL THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_ID_CANJE';
    RETURN;
  END IF;

  SELECT A.SYLCKCV_LINEA,
         A.SYLCKCV_CORREO,
         A.SYLCKCV_COD_APLI,
         A.SYLCKCN_KM_LATAM,
         A.SYLCKCN_CC,
         A.SYLCKCV_TIPO_CANJE,
         A.SYLCKCV_ID_PROG_LATAM,
         A.SYLCKCV_CTA_SOC_LATAM
    INTO PO_LINEA,
         PO_CORREO,
         PO_COD_APLI,
         PO_KM_LATAM,
         PO_PTO_CC,
         PO_TIPO_CANJE,
         PO_ID_PROG_LATAM,
         PO_ID_SOCIO
    FROM SYSFT_LATAM_CANJE_KM_CC A
   WHERE A.SYLCKCN_ID_CANJE = PI_ID_CANJE;

  PO_COD_ERR := '0';
  PO_DES_ERR := 'OK';

EXCEPTION
  WHEN OTHERS THEN
    PO_COD_ERR := '-1';
    PO_DES_ERR := 'ERROR => ' || TO_CHAR(SQLCODE) || ' : ' || SQLERRM;

END SYSFSS_DATOS_CANJE;

PROCEDURE SYSFSS_CANJES_PEND_CAMP
            (PI_ID_LOTE           IN NUMBER,
             PI_NOM_ARCH          IN VARCHAR2,
             PI_USUARIO           IN VARCHAR2,
             PI_TIPO_CANJE        IN VARCHAR2,
             PO_ID_LOTE           OUT NUMBER,
             PO_REC_TYPE          OUT VARCHAR2,
             PO_COMPANY_ID        OUT VARCHAR2,
             PO_FILE_ID           OUT VARCHAR2,
             PO_CREATE_DATE       OUT VARCHAR2,
             PO_CUR_REG_PEND      OUT SYS_REFCURSOR,
             PO_COD_ERR           OUT VARCHAR2,
             PO_DES_ERR           OUT VARCHAR2)

  /*
'****************************************************************************************************************
'* Nombre SP : SYSFSS_CANJES_PEND_CAMP
'* Propósito : Este procedimiento es responsable de retornar los registros pendientes
               por enviar a Latam o a demanda por IDLote.
'* Input :     <Parametro>       -- Descripción de los parametros
               PI_ID_LOTE        -- IDLote a enviar nuevamente (si es vacio significa que es un
                                    nuevo envio de pendientes, si no envia el lote que solicitan
               PI_USUARIO        -- Usuario
'* Output :    <Parametro>       -- Descripción de los parametros
               PO_ID_LOTE        -- IDLote que se ha creado o que se ha ingresado como PI
               PO_REC_TYPE       -- PO_REC_TYPE que se acaba de registrar
               PO_COMPANY_ID     -- PO_COMPANY_ID que se acaba de registrar
               PO_FILE_ID        -- PO_FILE_ID que se acaba de registrar
               PO_CREATE_DATE    -- PO_CREATE_DATE que se acaba de registrar
               PO_CUR_REG_PEND   -- Cursor con registros pendientes por enviar
               PO_COD_ERR        -- Codigo de error( 0 OK, 1 Error en parametros, 2 no hay canjes
                                    -1 error oracle)
               PO_DES_ERR        -- Descripción del error
'* Creado por : SAPIA - Omar Campos
'* Fec Creación : 30/10/2017
'****************************************************************************************************************
*/

 is

nID_LOTE NUMBER;
cID_COMPANY VARCHAR2(5);
nCOUNT_REG_CANJE NUMBER;
nCOUNT NUMBER;
cID_ARCHIVO VARCHAR2(9);
cPREFIJO VARCHAR2(10);
cTIPOARCHIVO CHAR(1);
cPI_NOM_ARCH VARCHAR2(30);

BEGIN
    IF PI_ID_LOTE IS NOT NULL AND PI_ID_LOTE > 0 THEN
      nID_LOTE := PI_ID_LOTE;

      SELECT COUNT(*) INTO nCOUNT FROM SYSFT_LATAM_LOTE_CANJE_KM_CC
      WHERE SYLLCKCN_ID_LOTE = nID_LOTE AND SYLLCKCC_ESTADO = 'F';

      IF nCOUNT = 0 THEN
         PO_COD_ERR := '2';
         PO_DES_ERR := 'No hay canjes por enviar';
         PO_REC_TYPE := '';
         PO_COMPANY_ID := '';
         PO_FILE_ID := '';
         PO_CREATE_DATE := '';
         PO_ID_LOTE := '0';
         OPEN PO_CUR_REG_PEND FOR
         SELECT '' REC_TYPE, '' ID_CANJE, '' Program_ID, '' Activity_Date,
         '' Points, '' NameSoc, '' Account_Number, '' Location_ID,
         '' Location_Desc, '' Partner_Sequence_Num, '' Days, '' Linea
         FROM DUAL;
         RETURN;
      END IF;

    ELSE

      SELECT COUNT(*) INTO nCOUNT_REG_CANJE
      FROM SYSFT_LATAM_CANJE_KM_CC WHERE SYLCKCC_ESTADO = 'P'
      AND SYLCKCV_TIPO_CANJE = PI_TIPO_CANJE;

      IF nCOUNT_REG_CANJE = 0 THEN
         PO_COD_ERR := '2';
         PO_DES_ERR := 'No hay canjes por enviar';
         PO_REC_TYPE := '';
         PO_COMPANY_ID := '';
         PO_FILE_ID := '';
         PO_CREATE_DATE := '';
         PO_ID_LOTE := '0';
         OPEN PO_CUR_REG_PEND FOR
         SELECT '' REC_TYPE, '' ID_CANJE, '' Program_ID, '' Activity_Date,
         '' Points, '' NameSoc, '' Account_Number, '' Location_ID,
         '' Location_Desc, '' Partner_Sequence_Num, '' Days, '' Linea
         FROM DUAL;
         RETURN;
      END IF;

      SELECT COUNT(*) INTO nCOUNT FROM
      ADMPT_PARAMSIST WHERE ADMPV_DESC = 'LATAM COMPANY ID SYSFT_LATAM_LOTE_CANJE_KM_CC';

      IF nCOUNT = 0 THEN
         PO_COD_ERR := '1';
         PO_DES_ERR := 'No esta configurado LATAM COMPANY ID en la tabla ADMPT_PARAMSIST';
         PO_REC_TYPE := '';
         PO_COMPANY_ID := '';
         PO_FILE_ID := '';
         PO_CREATE_DATE := '';
         PO_ID_LOTE := '0';
         OPEN PO_CUR_REG_PEND FOR
         SELECT '' REC_TYPE, '' ID_CANJE, '' Program_ID, '' Activity_Date,
         '' Points, '' NameSoc, '' Account_Number, '' Location_ID,
         '' Location_Desc, '' Partner_Sequence_Num, '' Days, '' Linea
         FROM DUAL;
         RETURN;
      END IF;

      SELECT ADMPV_VALOR INTO cID_COMPANY FROM
      ADMPT_PARAMSIST WHERE ADMPV_DESC = 'LATAM COMPANY ID SYSFT_LATAM_LOTE_CANJE_KM_CC';

      cID_ARCHIVO := SUBSTR(cID_COMPANY,-3)||'CR0001';

      SELECT COUNT(*) INTO nCOUNT FROM
      ADMPT_PARAMSIST WHERE ADMPV_DESC = 'LATAM PREFIJO SYSFT_LATAM_LOTE_CANJE_KM_CC';

      IF nCOUNT = 0 THEN
         PO_COD_ERR := '1';
         PO_DES_ERR := 'No esta configurado LATAM PREFIJO en la tabla ADMPT_PARAMSIST';
         PO_REC_TYPE := '';
         PO_COMPANY_ID := '';
         PO_FILE_ID := '';
         PO_CREATE_DATE := '';
         PO_ID_LOTE := '0';
         OPEN PO_CUR_REG_PEND FOR
         SELECT '' REC_TYPE, '' ID_CANJE, '' Program_ID, '' Activity_Date,
         '' Points, '' NameSoc, '' Account_Number, '' Location_ID,
         '' Location_Desc, '' Partner_Sequence_Num, '' Days, '' Linea
         FROM DUAL;
         RETURN;
      END IF;

      SELECT ADMPV_VALOR INTO cPREFIJO FROM
      ADMPT_PARAMSIST WHERE ADMPV_DESC = 'LATAM COMPANY ID SYSFT_LATAM_LOTE_CANJE_KM_CC';

      SELECT COUNT(*) INTO nCOUNT FROM
      ADMPT_PARAMSIST WHERE ADMPV_DESC = 'LATAM TIPO ARCHIVO SYSFT_LATAM_LOTE_CANJE_KM_CC';

      IF nCOUNT = 0 THEN
         PO_COD_ERR := '1';
         PO_DES_ERR := 'No esta configurado LATAM TIPO ARCHIVO en la tabla ADMPT_PARAMSIST';
         PO_REC_TYPE := '';
         PO_COMPANY_ID := '';
         PO_FILE_ID := '';
         PO_CREATE_DATE := '';
         PO_ID_LOTE := '0';
         OPEN PO_CUR_REG_PEND FOR
         SELECT '' REC_TYPE, '' ID_CANJE, '' Program_ID, '' Activity_Date,
         '' Points, '' NameSoc, '' Account_Number, '' Location_ID,
         '' Location_Desc, '' Partner_Sequence_Num, '' Days, '' Linea
         FROM DUAL;
         RETURN;
      END IF;

      SELECT ADMPV_VALOR INTO cTIPOARCHIVO FROM
      ADMPT_PARAMSIST WHERE ADMPV_DESC = 'LATAM TIPO ARCHIVO SYSFT_LATAM_LOTE_CANJE_KM_CC';

      cPI_NOM_ARCH := TRIM(cPREFIJO)||TRIM(cTIPOARCHIVO)||TO_CHAR(SYSDATE,'YYYYMMDD');

      SELECT SYSFSQ_LATAM_LOTE.NEXTVAL INTO nID_LOTE FROM DUAL;

      INSERT INTO SYSFT_LATAM_LOTE_CANJE_KM_CC ( SYLLCKCN_ID_LOTE, SYLLCKCV_ID_COMPANY, SYLLCKCV_ID_ARCHIVO, SYLLCKCN_CANT_REG, SYLLCKCV_NOM_ARCHIVO, SYLLCKCV_USU_REG )
      VALUES (nID_LOTE, cID_COMPANY, cID_ARCHIVO, nCOUNT_REG_CANJE, cPI_NOM_ARCH, PI_USUARIO);

      UPDATE SYSFT_LATAM_CANJE_KM_CC
      SET SYLCKCN_ID_LOTE = nID_LOTE, SYLCKCC_ESTADO = 'E', SYLEKCD_FEC_MOD = SYSDATE, SYLEKCV_USU_MOD = PI_USUARIO
      WHERE SYLCKCC_ESTADO = 'P' AND SYLCKCV_TIPO_CANJE = PI_TIPO_CANJE;
    END IF;

    SELECT A.SYLLCKCC_TIP_REG_LATAM, A.SYLLCKCV_ID_COMPANY, A.SYLLCKCV_ID_ARCHIVO, SUBSTR(A.SYLLCKCV_FEC_CREA_ARCH,1,8)
    INTO PO_REC_TYPE, PO_COMPANY_ID, PO_FILE_ID, PO_CREATE_DATE
    FROM SYSFT_LATAM_LOTE_CANJE_KM_CC A
    WHERE SYLLCKCN_ID_LOTE = nID_LOTE;

    PO_ID_LOTE:= nID_LOTE;

    OPEN PO_CUR_REG_PEND FOR
    SELECT A.SYLCKCC_TIP_REG_LATAM REC_TYPE, A.SYLCKCN_ID_CANJE ID_CANJE, A.SYLCKCV_ID_PROG_LATAM Program_ID, SUBSTR(A.SYLCKCV_FEC_CANJE,1,8) Activity_Date,
    A.SYLCKCN_KM_LATAM Points, A.SYLCKCV_NOM_CLI NameSoc, A.SYLCKCV_CTA_SOC_LATAM Account_Number, NVL(A.SYLCKCV_LOCATIONID, ' ') Location_ID,
    NVL(A.SYLCKCV_LOCATIONDESC, ' ') Location_Desc, A.SYLCKCV_CORRELATIVO Partner_Sequence_Num, NVL(A.SYLCKCV_DIAS, ' ') Days, A.SYLCKCV_LINEA Linea
    FROM SYSFT_LATAM_CANJE_KM_CC A
    WHERE A.SYLCKCN_ID_LOTE = nID_LOTE AND SYLCKCV_TIPO_CANJE = PI_TIPO_CANJE;

    PO_COD_ERR := '0';
    PO_DES_ERR   := 'OK';

EXCEPTION
   WHEN OTHERS THEN
      PO_REC_TYPE := '';
      PO_COMPANY_ID := '';
      PO_FILE_ID := '';
      PO_CREATE_DATE := '';
      PO_ID_LOTE := '0';
      OPEN PO_CUR_REG_PEND FOR
      SELECT '' REC_TYPE, '' ID_CANJE, '' Program_ID, '' Activity_Date,
      '' Points, '' NameSoc, '' Account_Number, '' Location_ID,
      '' Location_Desc, '' Partner_Sequence_Num, '' Days, '' Linea
      FROM DUAL;
      PO_COD_ERR := '-1';
      PO_DES_ERR := 'ERROR => ' || TO_CHAR(SQLCODE) || ' : ' || SQLERRM;

END SYSFSS_CANJES_PEND_CAMP;

PROCEDURE SYSFSI_VENTA_CAMP(PI_LINEA        IN VARCHAR2,
                       PI_DOCUMENTO         IN VARCHAR2,
                       PI_PLAN_TARIFA_COD   IN VARCHAR2,
                       PI_PLAN_TARIFA_DESC  IN VARCHAR2,
                       PI_TIPO_OPERACION    IN VARCHAR2,
                       PI_EQUIPO_COD        IN VARCHAR2,
                       PI_EQUIPO_DESC       IN VARCHAR2,
                       PI_FEC_VENTA         IN VARCHAR2,
                       PI_FEC_ACTIVACION    IN VARCHAR2,
                       PI_CAMPANA_COD       IN VARCHAR2,
                       PI_CAMPANA_DESC      IN VARCHAR2,
                       PI_LISTA_PRECIO      IN VARCHAR2,
                       PI_PRECIO_EQUIPO     IN VARCHAR2,
                       PI_REGION_ACTIV      IN VARCHAR2,
                       PI_DEP_ACTIV         IN VARCHAR2,
                       PI_CUSTOMERID        IN VARCHAR2,
                       PI_COID              IN VARCHAR2,
                       PI_NOMBRE_CLIENTE    IN VARCHAR2,
                       PI_USU_REG           IN VARCHAR2,
                       PI_ID_CAMPANA        IN NUMBER,
                       PI_APE_PAT           IN VARCHAR2,
                       PI_APE_MAT           IN VARCHAR2,
                       PI_TIP_DOC           IN VARCHAR2,
                       PI_FEC_NAC           IN DATE,
                       PI_GENERO            IN CHAR,
                       PI_EMAIL             IN VARCHAR2,
                       PI_PAIS_RESID        IN VARCHAR2,
                       PO_COD_ERR           out VARCHAR2,
                       PO_DES_ERR           out VARCHAR2,
                       PO_CANT_MILLAS       out NUMBER)

IS

nID NUMBER;
nCANT_MILLAS NUMBER;
nCOUNT NUMBER;

BEGIN
  PO_COD_ERR := '0';
  PO_DES_ERR := 'OK';
  
  -- SE VALIDA QUE LA CAMPANIA EXISTA Y ESTE VIGENTE
  SELECT COUNT(*) INTO nCOUNT FROM PCLUB.SYSFT_LATAM_CAMPANA A
  WHERE A.SYLCN_IDENTIFICADOR = PI_ID_CAMPANA
  AND A.SYLCC_ESTADO = 'A'
  AND TRUNC(A.SYLCD_FECHA_INI) <= TRUNC(TO_DATE(PI_FEC_VENTA, 'YYYY-MM-DD HH24:MI:SS'))
  AND TRUNC(A.SYLCD_FECHA_FIN) >= TRUNC(TO_DATE(PI_FEC_VENTA, 'YYYY-MM-DD HH24:MI:SS'));

  IF nCOUNT = 0 THEN
    PO_COD_ERR := '3';
    PO_DES_ERR := 'CAMPANIA NO CONFIGURADA O NO VIGENTE';
    RETURN;
  END IF;

  -- SE VALIDA QUE EL PLAN Y EL EQUIPO ESTEN CONFIGURADOS
  SELECT COUNT(*) INTO nCOUNT FROM PCLUB.SYSFT_LATAM_PLANES_MILLAS A
  WHERE A.SYMPV_PLAN = PI_PLAN_TARIFA_COD AND A.SYMPV_MODELO = PI_EQUIPO_COD
  AND A.SYLCN_IDENTIFICADOR = PI_ID_CAMPANA
  AND A.SYMPC_ESTADO = 'A';

  IF nCOUNT <> 1 THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'PLAN Y EQUIPOS NO CONFIGURADOS';
    RETURN;
  ELSE
    -- SE OBTIENE LA CANTIDAD DE MILLAS A ASIGNAR
    SELECT A.SYMPN_MILLAS INTO nCANT_MILLAS FROM PCLUB.SYSFT_LATAM_PLANES_MILLAS A
    WHERE A.SYMPV_PLAN = PI_PLAN_TARIFA_COD AND A.SYMPV_MODELO = PI_EQUIPO_COD
    AND A.SYLCN_IDENTIFICADOR = PI_ID_CAMPANA
    AND A.SYMPC_ESTADO = 'A'
    AND ROWNUM = 1
    ORDER BY A.SYMPD_FEC_REG DESC;
  END IF;

  PO_CANT_MILLAS := nCANT_MILLAS;

  -- SE VALIDA QUE EL REGISTRO AUN NO EXISTA
  SELECT COUNT(*) INTO nCOUNT FROM PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO
  WHERE SYPEV_LINEA = PI_LINEA AND TRUNC(SYPED_FEC_VENTA) = TRUNC(TO_DATE(PI_FEC_VENTA, 'YYYY-MM-DD HH24:MI:SS'))
  AND SYLCN_IDENTIFICADOR = PI_ID_CAMPANA;

  IF nCOUNT > 0 THEN
    PO_COD_ERR := '2';
    PO_DES_ERR := 'REGISTRO YA EXISTE';
    RETURN;
  ELSE
    
    -- SE INSERTA EL REGISTRO
    SELECT SYSFSQ_LATAM_DM.NEXTVAL INTO nID FROM DUAL;

    INSERT INTO PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO(SYPEN_IDENTIFICADOR, SYPEV_LINEA, SYPEV_DOCUMENTO, SYPEV_PLAN_TARIFA_COD,
    SYPEV_PLAN_TARIFA_DESC, SYPEV_TIPO_OPERACION, SYPEV_EQUIPO_COD, SYPEV_EQUIPO_DESC, SYPED_FEC_VENTA,
    SYPED_FEC_ACTIVACION, SYPEV_CAMPANA_COD, SYPEV_CAMPANA_DESC, SYPEV_LISTA_PRECIO, SYPEV_PRECIO_EQUIPO,
    SYPEV_REGION_ACTIV, SYPEV_DEP_ACTIV, SYPEV_CUSTOMERID, SYPEV_COID, SYPEV_NOMBRE_CLIENTE, SYPEN_MILLAS, SYPEV_USU_REG, SYLCN_IDENTIFICADOR,
    SYPEV_APE_PAT, SYPEV_APE_MAT, SYPEV_TIP_DOC, SYPED_FEC_NAC, SYPEC_GENERO, SYPEV_EMAIL, 
    SYPEV_PAIS_RESID)
    VALUES(nID, PI_LINEA, PI_DOCUMENTO, PI_PLAN_TARIFA_COD, PI_PLAN_TARIFA_DESC, PI_TIPO_OPERACION,
    PI_EQUIPO_COD, PI_EQUIPO_DESC, TO_DATE(PI_FEC_VENTA, 'YYYY-MM-DD HH24:MI:SS'), TO_DATE(PI_FEC_ACTIVACION, 'YYYY-MM-DD HH24:MI:SS'), PI_CAMPANA_COD, PI_CAMPANA_DESC,
    PI_LISTA_PRECIO, PI_PRECIO_EQUIPO, PI_REGION_ACTIV, PI_DEP_ACTIV, PI_CUSTOMERID, PI_COID,
    PI_NOMBRE_CLIENTE, nCANT_MILLAS, PI_USU_REG, PI_ID_CAMPANA, PI_APE_PAT, PI_APE_MAT, PI_TIP_DOC, 
    PI_FEC_NAC, PI_GENERO, PI_EMAIL, PI_PAIS_RESID);
  END IF;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    PO_COD_ERR := '-1';
    PO_DES_ERR := 'ERROR => ' || TO_CHAR(SQLCODE) || ' : ' || SQLERRM;

END SYSFSI_VENTA_CAMP;

PROCEDURE SYSFSU_EVALUAR_REG_VENCE_CAMP (
             PO_COD_ERR      out varchar2,
             PO_DES_ERR      out varchar2,
             PO_CUR_VENCIDO  out SYS_REFCURSOR)

IS

CURSOR cCANJE_ESPERA IS SELECT A.SYLCKCN_ID_CANJE, A.SYLCKCV_TIP_DOC, A.SYLCKCV_NUM_DOC, A.SYLCKCV_LINEA, A.SYLCKCN_KM_LATAM, A.SYLCKCV_ID_PROG_LATAM,
TRUNC(SYSDATE) - TRUNC(A.SYLCKCD_FEC_CANJE) DIF_FEC
FROM PCLUB.SYSFT_LATAM_CANJE_KM_CC A WHERE A.SYLCKCC_ESTADO = 'S';

nDIAS_VENC NUMBER;
vNUM_DOC VARCHAR2(20);
nID_CANJE NUMBER;
nDIASVENC NUMBER;
nCOUNT NUMBER;
vID_SOCIO VARCHAR2(20);

dFLAG BOOLEAN := FALSE;

nID_LOTE NUMBER;

BEGIN

  PO_COD_ERR := '0';
  PO_DES_ERR := 'OK';

  SELECT COUNT(*)
    INTO nCOUNT
    FROM ADMPT_PARAMSIST
   WHERE ADMPV_DESC = 'LATAM DIA MADRE CANT DIAS VENCIDO';

  IF nCOUNT = 0 THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'No esta configurado la cantidad de dias para pasar a vencido un registro de canje en la tabla ADMPT_PARAMSIST';
    
    OPEN PO_CUR_VENCIDO FOR
    SELECT '' ID_CANJE, '' TIP_DOC, '' NUM_DOC, '' LINEA, '' KM_LATAM,
    '' ID_PROG_LATAM FROM DUAL WHERE ROWNUM = 0;
    
    RETURN;
  END IF;

  SELECT ADMPV_VALOR INTO nDIAS_VENC FROM ADMPT_PARAMSIST
  WHERE ADMPV_DESC = 'LATAM DIA MADRE CANT DIAS VENCIDO';

  SELECT SYSFSQ_LATAM_LOTE.NEXTVAL INTO nID_LOTE FROM DUAL;

  -- SE RECORRE LA LISTA DE LOS CANJES EN ESPERA
  FOR CANJE_ESPERA IN cCANJE_ESPERA LOOP
      vNUM_DOC := CANJE_ESPERA.SYLCKCV_NUM_DOC;
      nID_CANJE := CANJE_ESPERA.SYLCKCN_ID_CANJE;
      nDIASVENC := CANJE_ESPERA.DIF_FEC;

      -- SE BUSCA EL ID_SOCIO
      SELECT COUNT(*) INTO nCOUNT FROM PCLUB.SYSFT_LATAM_SOCIO t
      WHERE T.SYLSV_TIP_DOC_LATAM = 'DNIPE' AND T.SYLSV_NUM_DOC = vNUM_DOC;

      IF nCOUNT = 1 THEN
        SELECT T.SYLSV_ID_SOCIO_LATAM INTO vID_SOCIO FROM PCLUB.SYSFT_LATAM_SOCIO t
        WHERE T.SYLSV_TIP_DOC_LATAM = 'DNIPE' AND T.SYLSV_NUM_DOC = vNUM_DOC;

        -- SE ACTUALIZA EL ESTADO A PENDIENTE
        UPDATE PCLUB.SYSFT_LATAM_CANJE_KM_CC
           SET SYLCKCC_ESTADO = 'P', SYLCKCV_CTA_SOC_LATAM = vID_SOCIO
        WHERE SYLCKCN_ID_CANJE = nID_CANJE;
      ELSE

        IF nDIASVENC > 5 THEN
                dFLAG := TRUE;

            -- SE ACTUALIZA EL ESTADO A VENCIDO
            UPDATE PCLUB.SYSFT_LATAM_CANJE_KM_CC
               SET SYLCKCC_ESTADO = 'V', SYLCKCN_ID_LOTE = nID_LOTE
            WHERE SYLCKCN_ID_CANJE = nID_CANJE;

        END IF;

      END IF;
    END LOOP;

    -- SE VALIDA SI SE ENCONTRO AL MENOS UN VENCIDO
    IF dFLAG THEN

        OPEN PO_CUR_VENCIDO FOR 
        SELECT SYLCKCN_ID_CANJE ID_CANJE, SYLCKCV_TIP_DOC TIP_DOC, SYLCKCV_NUM_DOC NUM_DOC,
        SYLCKCV_LINEA LINEA, SYLCKCN_KM_LATAM KM_LATAM, SYLCKCV_ID_PROG_LATAM ID_PROG_LATAM
        FROM PCLUB.SYSFT_LATAM_CANJE_KM_CC WHERE SYLCKCN_ID_LOTE = nID_LOTE;

     ELSE
       OPEN PO_CUR_VENCIDO FOR
       SELECT '' ID_CANJE, '' TIP_DOC, '' NUM_DOC, '' LINEA, '' KM_LATAM,
       '' ID_PROG_LATAM FROM DUAL WHERE ROWNUM = 0;
      END IF;

      COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    PO_COD_ERR := '-1';
    PO_DES_ERR := 'ERROR => ' || TO_CHAR(SQLCODE) || ' : ' || SQLERRM;
   
    OPEN PO_CUR_VENCIDO FOR
    SELECT '' ID_CANJE, '' TIP_DOC, '' NUM_DOC, '' LINEA, '' KM_LATAM,
    '' ID_PROG_LATAM FROM DUAL WHERE ROWNUM = 0;

END SYSFSU_EVALUAR_REG_VENCE_CAMP;

PROCEDURE SYSFSS_SOCIO_LATAM_REPORTE(PI_TIP_DOC_LATAM  in VARCHAR2,
                                     PI_NUM_DOC        in VARCHAR2,
                                     PI_ID_SOCIO_LATAM in VARCHAR2,
                                     PI_NOM_SOC        in VARCHAR2,
                                     PI_FEC_REG_INI    in DATE,
                                     PI_FEC_REG_FIN    in DATE,
                                     PO_CUR_SOCIO      out SYS_REFCURSOR,
                                     PO_COD_ERR        out VARCHAR2,
                                     PO_DES_ERR        out VARCHAR2)

  /*
'****************************************************************************************************************
'* Nombre SP : SYSFSS_SOCIO_LATAM_REPORTE
'* Propósito : Este procedimiento es responsable de consultar los Socios Latam.
'* Input :     <Parametro>       -- Descripción de los parametros
               PI_TIP_DOC_LATAM  -- Tipo de documento LATAM
               PI_NUM_DOC        -- Numero de documento LATAM
               PI_ID_SOCIO_LATAM -- ID de Socio LATAM
               PI_NOM_SOC        -- Nombre y/o Apellido de Socio LATAM
               PI_FEC_REG_INI    -- Fecha de registro inicial
               PI_FEC_REG_FIN    -- Fecha de registro final
'* Output :    <Parametro>       -- Descripción de los parametros
               PO_CUR_SOCIO      -- Cursor con datos de los socios
               PO_COD_ERR        -- Codigo de error( 0 OK, 1 Error en parametros,
                                    -1 error oracle)
               PO_DES_ERR        -- Descripción del error
'* Creado por : SAPIA - Omar Campos
'* Fec Creación : 28/02/2018
'****************************************************************************************************************
*/

 IS

vSELECT VARCHAR2(4000);
bFLAG BOOLEAN := FALSE;

BEGIN

    -- CONCATENAR QUERY
    vSELECT := 'SELECT T.SYLSV_TIP_DOC_LATAM, T.SYLSV_NUM_DOC, T.SYLSV_ID_SOCIO_LATAM, NVL(TRIM(T.SYLSV_NOM_SOC || '' '' || T.SYLSV_APE_SOC),'''') AS SYLSV_NOM_SOC, T.SYLSD_FEC_REG
               FROM PCLUB.SYSFT_LATAM_SOCIO T';

    IF ( PI_FEC_REG_INI IS NOT NULL ) THEN
       vSELECT := vSELECT || (CASE WHEN bFLAG THEN ' AND' ELSE ' WHERE' END);
       vSELECT := vSELECT || ' TRUNC(T.SYLSD_FEC_REG) >= ''' || TO_CHAR(PI_FEC_REG_INI, 'DD/MM/YYYY') || '''';       
       bFLAG := TRUE;
    END IF;
    
    IF ( PI_FEC_REG_FIN IS NOT NULL ) THEN
       vSELECT := vSELECT || (CASE WHEN bFLAG THEN ' AND' ELSE ' WHERE' END);
       vSELECT := vSELECT || ' TRUNC(T.SYLSD_FEC_REG) <= ''' || TO_CHAR(PI_FEC_REG_FIN, 'DD/MM/YYYY') || '''';
       bFLAG := TRUE;
    END IF;

    IF ( TRIM(PI_TIP_DOC_LATAM) IS NOT NULL ) THEN
       vSELECT := vSELECT || (CASE WHEN bFLAG THEN ' AND' ELSE ' WHERE' END);
       vSELECT := vSELECT || ' UPPER(T.SYLSV_TIP_DOC_LATAM) = ''' || UPPER(PI_TIP_DOC_LATAM) || '''';
       bFLAG := TRUE;
    END IF;

    IF ( TRIM(PI_NUM_DOC) IS NOT NULL ) THEN
       vSELECT := vSELECT || (CASE WHEN bFLAG THEN ' AND' ELSE ' WHERE' END);
       vSELECT := vSELECT || ' UPPER(T.SYLSV_NUM_DOC) = ''' || UPPER(PI_NUM_DOC) || '''';
       bFLAG := TRUE;
    END IF;

    IF ( TRIM(PI_ID_SOCIO_LATAM) IS NOT NULL ) THEN
       vSELECT := vSELECT || (CASE WHEN bFLAG THEN ' AND' ELSE ' WHERE' END);      
       vSELECT := vSELECT || ' UPPER(T.SYLSV_ID_SOCIO_LATAM) = ''' || UPPER(PI_ID_SOCIO_LATAM) || '''';
       bFLAG := TRUE;       
    END IF;

    IF ( TRIM(PI_NOM_SOC) IS NOT NULL ) THEN
       vSELECT := vSELECT || (CASE WHEN bFLAG THEN ' AND' ELSE ' WHERE' END);      
       vSELECT := vSELECT || ' UPPER(T.SYLSV_NOM_SOC || '' '' || T.SYLSV_APE_SOC) LIKE ''' || UPPER(PI_NOM_SOC) || '%''';
       bFLAG := TRUE;
    END IF;

    OPEN PO_CUR_SOCIO FOR vSELECT;

    PO_COD_ERR := '0';
    PO_DES_ERR := 'OK';

EXCEPTION
   WHEN OTHERS THEN
      OPEN PO_CUR_SOCIO FOR
      SELECT '' SYLSV_TIP_DOC_LATAM, '' SYLSV_NUM_DOC, '' SYLSV_ID_SOCIO_LATAM, '' SYLSV_NOM_SOC, '' SYLSD_FEC_REG FROM DUAL;
      PO_COD_ERR := '-1';
      PO_DES_ERR := 'ERROR => ' || TO_CHAR(SQLCODE) || ' : ' || SQLERRM;

END SYSFSS_SOCIO_LATAM_REPORTE;

PROCEDURE SYSFSD_KRDX_MLATAMCC_FALLO(PI_KARDEX       IN VARCHAR2,
                                     PI_TPOCL        IN VARCHAR2,
                                     PI_USUARIO      IN VARCHAR2,
                                     PO_KARDEX       OUT VARCHAR2,
                                     PO_COD_ERR      OUT NUMBER,
                                     PO_DES_ERR    OUT VARCHAR2) IS
  --****************************************************************
  -- Nombre SP           :  SYSFSD_KRDX_MLATAMCC_FALLO
  -- Proposito           :  Acreditar Puntos Claro Club a un Cliente Claro Club
  -- Input               :  PI_GRP: Identificador del Grupo a Acreditar
  -- Output              :  PO_COD_ERR: Codigo de Error o Exito
  --                        PO_DES_ERR: Descripcion del Error (si se presento)
  -- Creado por          :  Omar Campos
  -- Fec Creacion        :  27/05/2018
  --****************************************************************

  nID_KARDEX NUMBER;
  nID_KARDEX_NEW NUMBER;
  cCOD_CLI VARCHAR2(40);
  cCOD_CPTO VARCHAR2(3);
  nPUNTOS NUMBER;
  cTIP_PROD CHAR(1);
  
  nEXISTE_SALDO NUMBER;

BEGIN

  PO_COD_ERR := 0;
  PO_DES_ERR := 'OK';

    nID_KARDEX := PI_KARDEX;    
    
    IF PI_TPOCL = 'M'THEN
      
      SELECT PCLUB.ADMPT_KARDEX_SQ.NEXTVAL INTO nID_KARDEX_NEW FROM DUAL;
      
      SELECT ADMPV_COD_CLI, ADMPV_COD_CPTO, (ADMPN_PUNTOS * -1)
      INTO cCOD_CLI, cCOD_CPTO, nPUNTOS
      FROM ADMPT_KARDEX  WHERE ADMPN_ID_KARDEX = nID_KARDEX;
      
      INSERT INTO ADMPT_KARDEX (ADMPN_ID_KARDEX, ADMPV_COD_CLI, ADMPV_COD_CPTO, ADMPV_USU_REG, ADMPD_FEC_TRANS,
      ADMPN_PUNTOS, ADMPC_TPO_OPER, ADMPC_TPO_PUNTO, ADMPN_SLD_PUNTO, ADMPC_ESTADO)
      VALUES (nID_KARDEX_NEW, cCOD_CLI, cCOD_CPTO, PI_USUARIO, SYSDATE, nPUNTOS, 'E', 'C', nPUNTOS,'A');
      
      --SE BUSCA SI EL CODIGO DEL CLIENTE YA EXISTE EN SALDOS
      SELECT CASE WHEN EXISTS (SELECT 1
      FROM ADMPT_SALDOS_CLIENTE S
      WHERE S.ADMPV_COD_CLI = cCOD_CLI)
      THEN 1 ELSE 0 END
      INTO nEXISTE_SALDO
      FROM DUAL;

      -- EN CASO QUE AUN NO EXISTA, SE INSERTA EL REGISTRO
      IF (nEXISTE_SALDO = 0) THEN
        INSERT INTO ADMPT_SALDOS_CLIENTE
          (ADMPN_ID_SALDO,
          ADMPV_COD_CLI,
          ADMPN_SALDO_CC,
          ADMPC_ESTPTO_CC,
          ADMPD_FEC_REG)
        VALUES
          (ADMPT_SLD_CL_SQ.NEXTVAL,
          cCOD_CLI,
          nPUNTOS,
          'A',
          SYSDATE);
      ELSE
        -- CASO CONTRARIO, SE ACTUALIZA EL REGISTRO
        UPDATE ADMPT_SALDOS_CLIENTE S
        SET S.ADMPN_SALDO_CC = S.ADMPN_SALDO_CC + nPUNTOS,
        ADMPD_FEC_MOD    = SYSDATE
        WHERE S.ADMPV_COD_CLI = cCOD_CLI;
      END IF;
      
    ELSE
      
      SELECT PCLUB.ADMPT_kardexfija_sq.NEXTVAL INTO nID_KARDEX_NEW FROM DUAL;
      
      SELECT ADMPV_COD_CLI_PROD, admpv_cod_cpto, (admpn_puntos * -1)
      INTO cCOD_CLI, cCOD_CPTO, nPUNTOS
      FROM PCLUB.ADMPT_kardexfija WHERE admpn_id_kardex = nID_KARDEX;
      
      INSERT INTO PCLUB.ADMPT_kardexfija (admpn_id_kardex, admpn_cod_cli_ib, ADMPV_COD_CLI_PROD,
      admpv_cod_cpto, admpd_fec_trans, admpn_puntos, admpv_nom_arch, admpc_tpo_oper, admpc_tpo_punto,
      admpn_sld_punto, admpc_estado, admpv_usu_reg)
      VALUES (nID_KARDEX_NEW, '', cCOD_CLI, cCOD_CPTO, to_date(to_char(sysdate, 'dd/mm/yyyy'), 'dd/mm/yyyy'),
      nPUNTOS, '', 'E', 'C', nPUNTOS, 'A', PI_USUARIO);
      
      --SE BUSCA SI EL CODIGO DEL CLIENTE YA EXISTE EN SALDOS
      SELECT CASE WHEN EXISTS (SELECT 1
      FROM ADMPT_saldos_clientefija S
      WHERE S.ADMPV_COD_CLI_PROD = cCOD_CLI)
      THEN 1 ELSE 0 END
      INTO nEXISTE_SALDO
      FROM DUAL;

      -- EN CASO QUE AUN NO EXISTA, SE INSERTA EL REGISTRO
      IF (nEXISTE_SALDO = 0) THEN
        INSERT INTO ADMPT_SALDOS_CLIENTEFIJA(
          ADMPN_ID_SALDO,
          ADMPV_COD_CLI_PROD,
          ADMPN_COD_CLI_IB,
          ADMPN_SALDO_CC,
          ADMPN_SALDO_IB,ADMPC_ESTPTO_CC,ADMPC_ESTPTO_IB,
          ADMPD_FEC_REG,
          ADMPV_USU_REG
          )
        VALUES(
          ADMPT_SLD_CLFIJA_SQ.NEXTVAL+1,
          cCOD_CLI,
          NULL,
          nPUNTOS,
          0,
          'A',
          NULL,
          SYSDATE,
          PI_USUARIO
          );
      ELSE
        -- CASO CONTRARIO, SE ACTUALIZA EL REGISTRO
        UPDATE ADMPT_SALDOS_CLIENTEFIJA S
        SET S.ADMPN_SALDO_CC = S.ADMPN_SALDO_CC + nPUNTOS,
        ADMPD_FEC_MOD = SYSDATE, ADMPV_USU_MOD = PI_USUARIO
        WHERE S.ADMPV_COD_CLI_PROD = cCOD_CLI;
      END IF;
    END IF;
    
    PO_KARDEX := nID_KARDEX_NEW;
    
EXCEPTION
  WHEN OTHERS THEN
    PO_COD_ERR := SQLCODE;
    PO_DES_ERR := SUBSTR(SQLERRM, 1, 250);
    ROLLBACK;

END SYSFSD_KRDX_MLATAMCC_FALLO;

PROCEDURE SYSFSS_CANJE_SOCIOS_PEND(PI_USUARIO      IN VARCHAR2,
                                   PI_TIPO_CANJE   IN VARCHAR2,
                                   PO_COD_ERR      OUT varchar2,
                                   PO_DES_ERR      OUT varchar2,
                                   PO_ID_LOTE      OUT NUMBER,
                                   PO_CUR_REG_PEND OUT SYS_REFCURSOR)

 IS

  nID_LOTE_SOC NUMBER;

BEGIN

  -- SE VALIDA EL PARAMETRO: PI_USUARIO
  IF TRIM(PI_USUARIO) IS NULL THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_USUARIO';
    RETURN;
  END IF;

  -- SE VALIDA EL PARAMETRO: PI_TIPO_CANJE
  IF TRIM(PI_TIPO_CANJE) IS NULL THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_TIPO_CANJE';
    RETURN;
  END IF;

  -- SE GENERA UN ID_LOTE
  SELECT SYSFSQ_LATAM_LOTE.NEXTVAL INTO nID_LOTE_SOC FROM DUAL;

  -- SE ACTUALIZA LOS PENDIENTES DE AFILIACION DE SOCIOS A ENVIADO
  UPDATE PCLUB.SYSFT_LATAM_CANJE_KM_CC A
     SET A.SYLCKCN_ID_LOTE_SOC = nID_LOTE_SOC,
         A.SYLCKCC_EST_REG_SOC = 'E',
         A.SYLEKCD_FEC_MOD_SOC = SYSDATE,
         A.SYLEKCV_USU_MOD_SOC = PI_USUARIO
   WHERE A.SYLCKCC_ESTADO = 'S'
     AND A.SYLCKCC_EST_REG_SOC = 'P'
     AND A.SYLCKCV_TIPO_CANJE = PI_TIPO_CANJE;

  -- SETEAR LA VARIABLE DE SALIDA
  PO_ID_LOTE := nID_LOTE_SOC;

  -- SE OBTIENEN TODOS LOS REGISTROS DEL LOTE
  OPEN PO_CUR_REG_PEND FOR
    SELECT DISTINCT CC.SYPEV_APE_PAT        APE_PAT_CLIENTE,
                    CC.SYPEV_APE_MAT        APE_MAT_CLIENTE,
                    CC.SYPEV_TIP_DOC        TIPO_DOC_CLIENTE,
                    CC.SYPED_FEC_NAC        FEC_NAC_CLIENTE,
                    CC.SYPEV_EMAIL          EMAIL,
                    CC.SYPEV_PAIS_RESID     PAIS_RESIDENCIA,
                    CC.SYPEV_NOMBRE_CLIENTE NOMBRE_CLIENTE,
                    CC.SYPEC_GENERO         SEXO,
                    CC.SYPEV_DOCUMENTO      NUMERO_DOCUMENTO,
                    CC.SYPEV_LINEA          LINEA
      FROM PCLUB.SYSFT_LATAM_CANJE_KM_CC A
     INNER JOIN PCLUB.SYSFT_LATAM_CAMPANA CA
        ON CA.SYLCV_COD_CAMPANA = A.SYLCKCV_TIPO_CANJE
     INNER JOIN PCLUB.SYSFT_LATAM_PORTARENO_EQUIPO CC
        ON CC.SYLCN_IDENTIFICADOR = CA.SYLCN_IDENTIFICADOR
       AND CC.SYPEV_TIP_DOC = A.SYLCKCV_TIP_DOC
       AND CC.SYPEV_DOCUMENTO = A.SYLCKCV_NUM_DOC
       AND CC.SYPEV_LINEA = A.SYLCKCV_LINEA
     WHERE A.SYLCKCV_TIPO_CANJE = PI_TIPO_CANJE
       AND A.SYLCKCN_ID_LOTE_SOC = nID_LOTE_SOC;

  COMMIT;

  PO_COD_ERR := '0';
  PO_DES_ERR := 'OK';

EXCEPTION
  WHEN OTHERS THEN
    
  ROLLBACK;  
  
    OPEN PO_CUR_REG_PEND FOR
      SELECT '' APE_PAT_CLIENTE,
             '' APE_MAT_CLIENTE,
             '' TIPO_DOC_CLIENTE,
             '' FEC_NAC_CLIENTE,
             '' EMAIL,
             '' PAIS_RESIDENCIA,
             '' NOMBRE_CLIENTE,
             '' SEXO,
             '' NUMERO_DOCUMENTO,
             '' LINEA
        FROM DUAL
       WHERE ROWNUM = 0;
  
    PO_COD_ERR := '-1';
    PO_DES_ERR := 'ERROR => ' || TO_CHAR(SQLCODE) || ' : ' || SQLERRM;
  
END SYSFSS_CANJE_SOCIOS_PEND;

PROCEDURE SYSFSU_CANJE_SOCIO(PI_TIPO_DOC      IN VARCHAR2,
                             PI_NUM_DOC       IN VARCHAR2,
                             PI_EST_REG_SOC   IN VARCHAR2,
                             PI_EST_CANJE     IN VARCHAR2,
                             PI_COD_ERR_LATAM IN VARCHAR2,
                             PI_USUARIO       IN VARCHAR2,
                             PI_TIPO_CANJE    IN VARCHAR2,
                             PI_ID_SOCIO      IN VARCHAR2,
                             PI_DESC_ERR_LATAM IN VARCHAR2,
                             PO_COD_ERR       OUT VARCHAR2,
                             PO_DES_ERR       OUT VARCHAR2) IS
BEGIN

  -- SE VALIDA EL PARAMETRO: PI_TIPO_DOC
  IF TRIM(PI_TIPO_DOC) IS NULL THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_TIPO_DOC';
    RETURN;
  END IF;

  -- SE VALIDA EL PARAMETRO: PI_NUM_DOC
  IF TRIM(PI_NUM_DOC) IS NULL THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_NUM_DOC';
    RETURN;
  END IF;

  -- SE VALIDA EL PARAMETRO: PI_EST_REG_SOC
  IF TRIM(PI_EST_REG_SOC) IS NULL THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_EST_REG_SOC';
    RETURN;
  END IF;

  -- SE VALIDA EL PARAMETRO: PI_EST_CANJE
  IF TRIM(PI_EST_CANJE) IS NULL THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_EST_CANJE';
    RETURN;
  END IF;

  -- SE VALIDA EL PARAMETRO: PI_COD_ERR_LATAM
  IF TRIM(PI_COD_ERR_LATAM) IS NULL THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_COD_ERR_LATAM';
    RETURN;
  END IF;

  -- SE VALIDA EL PARAMETRO: PI_USUARIO
  IF TRIM(PI_USUARIO) IS NULL THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_USUARIO';
    RETURN;
  END IF;
  
  -- SE VALIDA EL PARAMETRO: PI_TIPO_CANJE
  IF TRIM(PI_TIPO_CANJE) IS NULL THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_TIPO_CANJE';
    RETURN;
  END IF;

  -- SE ACTUALIZA EL ESTADO DE LA AFILIACION DEL SOCIO
  UPDATE SYSFT_LATAM_CANJE_KM_CC A
     SET A.SYLCKCC_EST_REG_SOC   = PI_EST_REG_SOC,
         A.SYLCKCC_EST_CANJE     = PI_EST_CANJE,
         A.SYLCKCV_COD_ERR_LATAM = PI_COD_ERR_LATAM,
         A.SYLCKCV_DESC_ERR_LATAM = PI_DESC_ERR_LATAM,
         A.SYLCKCV_CTA_SOC_LATAM = PI_ID_SOCIO,
         A.SYLEKCD_FEC_MOD_SOC   = SYSDATE,
         A.SYLEKCV_USU_MOD_SOC   = PI_USUARIO
   WHERE A.SYLCKCV_TIPO_CANJE = PI_TIPO_CANJE
     AND A.SYLCKCV_TIP_DOC = PI_TIPO_DOC
     AND A.SYLCKCV_NUM_DOC = PI_NUM_DOC
     AND A.SYLCKCC_ESTADO = 'S'
     AND NOT (A.SYLCKCC_EST_REG_SOC = 'F' AND A.SYLCKCC_EST_CANJE = '0');

  COMMIT;

  PO_COD_ERR := '0';
  PO_DES_ERR := 'OK';

EXCEPTION
  WHEN OTHERS THEN
    
    ROLLBACK;  
  
    PO_COD_ERR := '-1';
    PO_DES_ERR := 'ERROR => ' || TO_CHAR(SQLCODE) || ' : ' || SQLERRM;
  
END SYSFSU_CANJE_SOCIO;

PROCEDURE SYSFSU_LOTE_CANJE_SOCIO(PI_ID_LOTE     IN NUMBER,
                                  PI_EST_REG_SOC IN VARCHAR2,
                                  PI_USUARIO     IN VARCHAR2,
                                  PO_COD_ERR     OUT VARCHAR2,
                                  PO_DES_ERR     OUT VARCHAR2) IS

BEGIN

  -- SE VALIDA EL PARAMETRO: PI_ID_LOTE
  IF PI_ID_LOTE IS NULL OR PI_ID_LOTE = 0 THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_ID_LOTE';
    RETURN;
  END IF;

  -- SE VALIDA EL PARAMETRO: PI_EST_REG_SOC
  IF TRIM(PI_EST_REG_SOC) IS NULL THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_EST_REG_SOC';
    RETURN;
  END IF;

  -- SE VALIDA EL PARAMETRO: PI_USUARIO
  IF TRIM(PI_USUARIO) IS NULL THEN
    PO_COD_ERR := '1';
    PO_DES_ERR := 'Debe ingresar parametro PI_USUARIO';
    RETURN;
  END IF;

  -- SE ACTUALIZA EL ESTADO DEL LOTE
  UPDATE SYSFT_LATAM_CANJE_KM_CC A
     SET A.SYLCKCC_EST_REG_SOC = PI_EST_REG_SOC,
         A.SYLEKCD_FEC_MOD_SOC = SYSDATE,
         A.SYLEKCV_USU_MOD_SOC = PI_USUARIO
   WHERE A.SYLCKCN_ID_LOTE_SOC = PI_ID_LOTE;

  COMMIT;

  PO_COD_ERR := '0';
  PO_DES_ERR := 'OK';

EXCEPTION

  WHEN OTHERS THEN
    
    ROLLBACK;  
  
    PO_COD_ERR := '-1';
    PO_DES_ERR := 'ERROR => ' || TO_CHAR(SQLCODE) || ' : ' || SQLERRM;
  
END SYSFSU_LOTE_CANJE_SOCIO;

end PKG_CC_CANJE_LATAM;
/