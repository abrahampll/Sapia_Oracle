create or replace package body PCLUB.PKG_COMUNIDAD_CLARO is
  /****************************************************************
  * Nombre SP          :  MICLSS_DATOS_CLIENTE
  * Proposito          :  Permite obtener los datos del cliente
  * Input              :  PI_TIPO_DOCUMENTO      - Tipo de documento
  *                       PI_NUMERO_DOCUMENTO    - Número de documento
  *                       PI_CODIGO_CLIENTE      - Código de Cliente
  * Output             :  PO_CURSOR_CLIENTE      - Cursor de salida
  *                       PO_CODIGO_ERROR        - Código de respuesta
  *                       PO_MENSAJE_ERROR       - Mensaje de respuesta
  * Creado por         :  Arles Sandoval
  * Fec Creacion       :  13/02/2017
  * Fec Actualizacion  :  Versión Inicial
  ****************************************************************/

  PROCEDURE MICLSS_DATOS_CLIENTE(PI_TIPO_DOCUMENTO     IN PCLUB.admpt_cliente.ADMPV_TIPO_DOC%TYPE,
                                 PI_NUMERO_DOCUMENTO   IN PCLUB.admpt_cliente.ADMPV_NUM_DOC%TYPE,
                                 PI_CODIGO_CLIENTE     IN PCLUB.admpt_cliente.ADMPV_COD_CLI%TYPE,
                                 PO_CODIGO_ERROR   OUT NUMBER,
                                 PO_MENSAJE_ERROR  OUT VARCHAR2,
                                 PO_CURSOR_CLIENTE OUT SYS_REFCURSOR) IS
    -- Variables
    V_TIP_DOC PCLUB.admpt_cliente.admpv_tipo_doc%TYPE;
    V_NUM_DOC PCLUB.admpt_cliente.admpv_num_doc%TYPE;
  BEGIN
  
    IF (PI_CODIGO_CLIENTE IS NOT NULL) THEN
      SELECT admpv_tipo_doc, admpv_num_doc
        INTO V_TIP_DOC, V_NUM_DOC
        FROM PCLUB.admpt_cliente C
       WHERE C.ADMPV_COD_CLI = PI_CODIGO_CLIENTE
         AND C.admpc_estado = 'A'
      UNION ALL
      SELECT admpv_tipo_doc, admpv_num_doc
        FROM PCLUB.admpt_clientefija CF
       WHERE CF.ADMPV_COD_CLI = PI_CODIGO_CLIENTE
         AND CF.admpc_estado = 'A';
    
      OPEN PO_CURSOR_CLIENTE FOR
        SELECT C.ADMPV_COD_CLI,
               C.ADMPV_COD_SEGCLI,
               C.ADMPN_COD_CATCLI,
               C.ADMPV_NOM_CLI,
               C.ADMPV_APE_CLI,
               C.ADMPC_SEXO,
               C.ADMPV_EST_CIVIL,
               C.ADMPV_EMAIL,
               C.ADMPV_DIST,
               C.ADMPV_PROV,
               C.ADMPV_DEPA,
               C.ADMPD_FEC_ACTIV,
               C.ADMPC_ESTADO,
               C.ADMPV_COD_TPOCL,
               C.ADMPV_USU_REG,
               C.ADMPD_FEC_REG,
               'MOVIL' AS TIPO
          FROM PCLUB.admpt_cliente C
         WHERE C.ADMPV_COD_CLI = PI_CODIGO_CLIENTE
           AND C.ADMPC_ESTADO = 'A'
        UNION ALL
        SELECT CF.ADMPV_COD_CLI,
               CF.ADMPV_COD_SEGCLI,
               CF.ADMPN_COD_CATCLI,
               CF.ADMPV_NOM_CLI,
               CF.ADMPV_APE_CLI,
               CF.ADMPC_SEXO,
               CF.ADMPV_EST_CIVIL,
               CF.ADMPV_EMAIL,
               CF.ADMPV_DIST,
               CF.ADMPV_PROV,
               CF.ADMPV_DEPA,
               CF.ADMPD_FEC_ACTIV,
               CF.ADMPC_ESTADO,
               CF.ADMPV_COD_TPOCL,
               CF.ADMPV_USU_REG,
               CF.ADMPD_FEC_REG,
               'FIJO' AS TIPO
          FROM PCLUB.admpt_clientefija CF
         WHERE CF.ADMPV_COD_CLI = PI_CODIGO_CLIENTE
           AND CF.ADMPC_ESTADO = 'A';
      PO_CODIGO_ERROR  := 0;
      PO_MENSAJE_ERROR := 'CLIENTE EXISTE';
    ELSE
      --Sentencia
      SELECT admpv_tipo_doc, admpv_num_doc
        INTO V_TIP_DOC, V_NUM_DOC
        FROM PCLUB.admpt_cliente C
       WHERE (C.admpv_tipo_doc = PI_TIPO_DOCUMENTO AND
             C.admpv_num_doc = PI_NUMERO_DOCUMENTO)
         AND C.admpc_estado = 'A'
      UNION ALL
      SELECT admpv_tipo_doc, admpv_num_doc
        FROM PCLUB.admpt_clientefija CF
       WHERE (CF.admpv_tipo_doc = PI_TIPO_DOCUMENTO AND
             CF.admpv_num_doc = PI_NUMERO_DOCUMENTO)
         AND CF.admpc_estado = 'A';
    
      OPEN PO_CURSOR_CLIENTE FOR
        SELECT C.ADMPV_COD_CLI,
               C.ADMPV_COD_SEGCLI,
               C.ADMPN_COD_CATCLI,
               C.ADMPV_NOM_CLI,
               C.ADMPV_APE_CLI,
               C.ADMPC_SEXO,
               C.ADMPV_EST_CIVIL,
               C.ADMPV_EMAIL,
               C.ADMPV_DIST,
               C.ADMPV_PROV,
               C.ADMPV_DEPA,
               C.ADMPD_FEC_ACTIV,
               C.ADMPC_ESTADO,
               C.ADMPV_COD_TPOCL,
               C.ADMPV_USU_REG,
               C.ADMPD_FEC_REG,
               'MOVIL' AS TIPO
          FROM PCLUB.admpt_cliente C
         WHERE C.ADMPV_TIPO_DOC = PI_TIPO_DOCUMENTO
           AND C.ADMPV_NUM_DOC = PI_NUMERO_DOCUMENTO
           AND C.ADMPC_ESTADO = 'A'
        UNION ALL        
        SELECT CF.ADMPV_COD_CLI,
               CF.ADMPV_COD_SEGCLI,
               CF.ADMPN_COD_CATCLI,
               CF.ADMPV_NOM_CLI,
               CF.ADMPV_APE_CLI,
               CF.ADMPC_SEXO,
               CF.ADMPV_EST_CIVIL,
               CF.ADMPV_EMAIL,
               CF.ADMPV_DIST,
               CF.ADMPV_PROV,
               CF.ADMPV_DEPA,
               CF.ADMPD_FEC_ACTIV,
               CF.ADMPC_ESTADO,
               CF.ADMPV_COD_TPOCL,
               CF.ADMPV_USU_REG,
               CF.ADMPD_FEC_REG,
               'FIJO' AS TIPO
          FROM PCLUB.admpt_clientefija CF
         WHERE CF.ADMPV_TIPO_DOC = PI_TIPO_DOCUMENTO
           AND CF.ADMPV_NUM_DOC = PI_NUMERO_DOCUMENTO
           AND CF.ADMPC_ESTADO = 'A';
    
      PO_CODIGO_ERROR  := 0;
      PO_MENSAJE_ERROR := 'CLIENTE EXISTE';
    END IF;
  
    -- Sentencias control de excepcion
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      OPEN PO_CURSOR_CLIENTE FOR
        SELECT C.ADMPV_COD_CLI,
               C.ADMPV_COD_SEGCLI,
               C.ADMPN_COD_CATCLI,
               C.ADMPV_NOM_CLI,
               C.ADMPV_APE_CLI,
               C.ADMPC_SEXO,
               C.ADMPV_EST_CIVIL,
               C.ADMPV_EMAIL,
               C.ADMPV_DIST,
               C.ADMPV_PROV,
               C.ADMPV_DEPA,
               C.ADMPD_FEC_ACTIV,
               C.ADMPC_ESTADO,
               C.ADMPV_COD_TPOCL,
               C.ADMPV_USU_REG,
               C.ADMPD_FEC_REG,
               '' AS TIPO
          FROM PCLUB.admpt_cliente C
         WHERE C.ADMPV_TIPO_DOC = PI_TIPO_DOCUMENTO
           AND C.ADMPV_NUM_DOC = PI_NUMERO_DOCUMENTO
           AND C.ADMPC_ESTADO = 'A'
        UNION ALL
        SELECT CF.ADMPV_COD_CLI,
               CF.ADMPV_COD_SEGCLI,
               CF.ADMPN_COD_CATCLI,
               CF.ADMPV_NOM_CLI,
               CF.ADMPV_APE_CLI,
               CF.ADMPC_SEXO,
               CF.ADMPV_EST_CIVIL,
               CF.ADMPV_EMAIL,
               CF.ADMPV_DIST,
               CF.ADMPV_PROV,
               CF.ADMPV_DEPA,
               CF.ADMPD_FEC_ACTIV,
               CF.ADMPC_ESTADO,
               CF.ADMPV_COD_TPOCL,
               CF.ADMPV_USU_REG,
               CF.ADMPD_FEC_REG,
               '' AS TIPO
          FROM PCLUB.admpt_clientefija CF
         WHERE CF.ADMPV_TIPO_DOC = PI_TIPO_DOCUMENTO
           AND CF.ADMPV_NUM_DOC = PI_NUMERO_DOCUMENTO
           AND CF.ADMPC_ESTADO = 'A';
    
      PO_CODIGO_ERROR  := 1;
      PO_MENSAJE_ERROR := 'CLIENTE NO EXISTE';
    
    WHEN OTHERS THEN
      OPEN PO_CURSOR_CLIENTE FOR
        SELECT C.ADMPV_COD_CLI,
               C.ADMPV_COD_SEGCLI,
               C.ADMPN_COD_CATCLI,
               C.ADMPV_NOM_CLI,
               C.ADMPV_APE_CLI,
               C.ADMPC_SEXO,
               C.ADMPV_EST_CIVIL,
               C.ADMPV_EMAIL,
               C.ADMPV_DIST,
               C.ADMPV_PROV,
               C.ADMPV_DEPA,
               C.ADMPD_FEC_ACTIV,
               C.ADMPC_ESTADO,
               C.ADMPV_COD_TPOCL,
               C.ADMPV_USU_REG,
               C.ADMPD_FEC_REG,
               '' AS TIPO
          FROM PCLUB.admpt_cliente C
         WHERE C.ADMPV_TIPO_DOC = PI_TIPO_DOCUMENTO
           AND C.ADMPV_NUM_DOC = PI_NUMERO_DOCUMENTO
           AND C.ADMPC_ESTADO = 'A'
        UNION ALL
        SELECT CF.ADMPV_COD_CLI,
               CF.ADMPV_COD_SEGCLI,
               CF.ADMPN_COD_CATCLI,
               CF.ADMPV_NOM_CLI,
               CF.ADMPV_APE_CLI,
               CF.ADMPC_SEXO,
               CF.ADMPV_EST_CIVIL,
               CF.ADMPV_EMAIL,
               CF.ADMPV_DIST,
               CF.ADMPV_PROV,
               CF.ADMPV_DEPA,
               CF.ADMPD_FEC_ACTIV,
               CF.ADMPC_ESTADO,
               CF.ADMPV_COD_TPOCL,
               CF.ADMPV_USU_REG,
               CF.ADMPD_FEC_REG,
               '' AS TIPO
          FROM PCLUB.admpt_clientefija CF
         WHERE CF.ADMPV_TIPO_DOC = PI_TIPO_DOCUMENTO
           AND CF.ADMPV_NUM_DOC = PI_NUMERO_DOCUMENTO
           AND CF.ADMPC_ESTADO = 'A';
    
      PO_CODIGO_ERROR  := -1;
      PO_MENSAJE_ERROR := 'MENSAJE: ' || SQLERRM;
    
  END MICLSS_DATOS_CLIENTE;

end PKG_COMUNIDAD_CLARO;
/
