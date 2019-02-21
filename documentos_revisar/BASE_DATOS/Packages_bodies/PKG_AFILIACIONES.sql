create or replace package body PCLUB.PKG_AFILIACIONES is

  /*********************************************************************
  '* Nombre SP           :  afiliarClienteServicio
  '* Propósito           :  Insertar a los Clientes Nuevos desde TCRM
  '* Input               :  tipoDocumento, numeroDocumento, segmento,
                            categoria, nombres, apellidos, sexo,
                            estadoCivil, email, departamento, provincia,
                            distrito, estado, codigoContrato, familia,
                            numeroLinea, cicloFacturacion, tecnologia,
                            tipoProducto, tipoTelefonia, casoEspecial,
                            cantidadPuntos, tipoPuntos, origen,
                            fechaRegistro, concepto
  '* Output              :  codigoRespuesta, mensajeRespuesta
  '* Creado por          :  Miguel Oré
  '* Fec Creación        :  20/07/2018
  '* Fec Actualización   :
  '*********************************************************************/

  procedure sp_afiliaciones(origen           Varchar2,
                            fechaRegistro    date,
                            concepto         Integer,
                            tipoDocumento    Varchar2,
                            numeroDocumento  Varchar2,
                            segmento         Varchar2,
                            categoria        Integer,
                            nombres          Varchar2,
                            apellidos        Varchar2,
                            sexo             Varchar2,
                            estadoCivil      Varchar2,
                            email            Varchar2,
                            departamento     Varchar2,
                            provincia        Varchar2,
                            distrito         Varchar2,
                            estado           Varchar2,
                            codigoContrato   Varchar2,
                            familia          Integer,
                            numeroLinea      Varchar2,
                            cicloFacturacion Varchar2,
                            tecnologia       Integer,
                            tipoProducto     Varchar2,
                            tipoTelefonia    Integer,
                            casoEspecial     Varchar2,
                            cantidadPuntos   Integer,
                            tipoPuntos       Integer,
                            codigoRespuesta  out varchar2,
                            mensajeRespuesta out varchar2) IS
    V_REGCON         NUMBER;
    CONTADOR_1       NUMBER;
    CONTADOR_2       NUMBER;
    V_IDSALDO        NUMBER;
    V_IDKARDEX       NUMBER;
    V_SEXO           VARCHAR2(1);
    V_TIPOPUNTOS     VARCHAR2(1);
    V_TIPOPRODUCTO   NUMBER;
    V_TIPO_OPERACION VARCHAR2(1);
    V_ESTADO         VARCHAR2(1);
    V_INDICEGRUPO    VARCHAR2(1);
  
  BEGIN
    --Iniciamos las variables
    V_TIPO_OPERACION := 'E';
    V_ESTADO         := 'A';
    V_INDICEGRUPO    := '1';
  
    codigoRespuesta  := '0';
    mensajeRespuesta := 'Transaction OK';
  
    --Validamos si el Concepto no existe
    V_REGCON := 0;
    SELECT COUNT(1)
      INTO V_REGCON
      FROM PCLUB.ADMPT_CONCEPTO
     WHERE ADMPV_COD_CPTO = concepto;
    IF V_REGCON = 0 THEN
      --Controlamos los errores, si el Concepto no existe
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Codigo de Concepto No Existe.';
      RETURN;
    END IF;
    --Validamos si el Sexo viene Vacio ó Nulo
    IF LENGTH(TRIM(sexo)) <= 0 OR sexo IS NULL THEN
      V_SEXO := '-';
    ELSE
      V_SEXO := sexo;
    END IF;
    --Validamos Variable Obligatoria Tipo de Documento
    IF origen IS NULL THEN
      --Controlamos los errores, si el tipoDocumento es Vacio o Nulo
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Origen Vacio o Nulo.';
      RETURN;
    END IF;
    --Validamos Variable Obligatoria Tipo de Documento
    IF tipoDocumento IS NULL THEN
      --Controlamos los errores, si el tipoDocumento es Vacio o Nulo
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Tipo de Documento Vacio o Nulo.';
      RETURN;
    END IF;
    --Validamos Variable Obligatoria Tipo de Documento con Tabla
    V_REGCON := 0;
    SELECT COUNT(1)
      INTO V_REGCON
      FROM PCLUB.ADMPT_TIPO_DOC
     WHERE ADMPV_COD_TPDOC = tipoDocumento;
    IF V_REGCON = 0 THEN
      --Controlamos los errores, si el tipoDocumento con tabla
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Tipo de documento no existe.';
      RETURN;
    END IF;
    --Validamos Variable Obligatoria Numero de Documento
    IF numeroDocumento IS NULL THEN
      --Controlamos los errores, si el numeroDocumento es Vacio o Nulo
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Numero de Documento Vacio o Nulo.';
      RETURN;
    END IF;
    --Validamos Variable Obligatoria Nombres
    IF nombres IS NULL THEN
      --Controlamos los errores, si el nombres es Vacio o Nulo
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Nombres Vacio o Nulo.';
      RETURN;
    END IF;
    --Validamos Variable Obligatoria Apellidos
    IF apellidos IS NULL THEN
      --Controlamos los errores, si el apellidos es Vacio o Nulo
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Apellidos Vacio o Nulo.';
      RETURN;
    END IF;
    --Validamos Variable Obligatoria Sexo
    IF sexo IS NULL THEN
      --Controlamos los errores, si el sexo es Vacio o Nulo
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Sexo Vacio o Nulo.';
      RETURN;
    END IF;
    --Validamos Variable Obligatoria Estado Civil
    IF estadocivil IS NULL THEN
      --Controlamos los errores, si el Estado Civil es Vacio o Nulo
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Estado Civil Vacio o Nulo.';
      RETURN;
    END IF;
    --Validamos Variable Obligatoria Email
    IF email IS NULL THEN
      --Controlamos los errores, si el Email es Vacio o Nulo
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Email Vacio o Nulo.';
      RETURN;
    END IF;
    --Validamos Variable Obligatoria Departamento
    IF departamento IS NULL THEN
      --Controlamos los errores, si el Departamento es Vacio o Nulo
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Departamento Vacio o Nulo.';
      RETURN;
    END IF;
    --Validamos Variable Obligatoria Provincia
    IF provincia IS NULL THEN
      --Controlamos los errores, si el Provincia es Vacio o Nulo
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Provincia Vacio o Nulo.';
      RETURN;
    END IF;
    --Validamos Variable Obligatoria Distrito
    IF distrito IS NULL THEN
      --Controlamos los errores, si el Distrito es Vacio o Nulo
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Distrito Vacio o Nulo.';
      RETURN;
    END IF;
    --Validamos Variable Obligatoria Estado
    IF estado IS NULL THEN
      --Controlamos los errores, si el Estado es Vacio o Nulo
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Estado Vacio o Nulo.';
      RETURN;
    END IF;
  
    --Validamos Variable Obligatoria Ciclo de Facturación
    IF ciclofacturacion IS NULL THEN
      --Controlamos los errores, si el Ciclo de Facturación es Vacio o Nulo
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Ciclo de Facturación Vacio o Nulo.';
      RETURN;
    END IF;
    --Validamos Variable Obligatoria Ciclo de Facturación Numerico
    IF to_number(ciclofacturacion, '9999') < 0 THEN
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Ciclo de Facturación incorrecto';
      RETURN;
    END IF;
    --Validamos Variable Obligatoria Tipo de Producto
    IF tipoproducto IS NULL THEN
      --Controlamos los errores, si el Tipo de Producto es Vacio o Nulo
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Tipo de Producto Vacio o Nulo.';
      RETURN;
    END IF;
    --Validamos Variable Obligatoria Cantidad de Puntos
    IF cantidadPuntos IS NULL THEN
      --Controlamos los errores, si el Cantidad de Puntos es Vacio o Nulo
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Cantidad de Puntos Vacio o Nulo.';
      RETURN;
    END IF;
    --Validamos Variable Cantidad de Puntos Negativos
    IF cantidadPuntos < 0 THEN
      --Controlamos los errores, si el Cantidad de Puntos es Negativo
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Cantidad de Puntos es Negativo.';
      RETURN;
    END IF;
    --Validamos Variable Obligatoria Tipo de Puntos
    IF tipoPuntos IS NULL THEN
      --Controlamos los errores, si el Tipo de Puntos es Vacio o Nulo
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Tipo de Puntos Vacio o Nulo.';
      RETURN;
    END IF;
  
    --Validamos si el Contrato viene Vacio ó Nulo
    IF LENGTH(TRIM(codigoContrato)) <= 0 OR codigoContrato IS NULL THEN
    
      --Controlamos los errores, si el codigoContrato es Vacio o Nulo
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Codigo de Contrato Vacio o Nulo.';
      RETURN;
    ELSE
      CONTADOR_1 := 0;
      CONTADOR_2 := 0;
      SELECT COUNT(1)
        INTO CONTADOR_1
        FROM ADMPT_CLIENTE C
       WHERE C.ADMPV_COD_CLI = codigoContrato;
      SELECT COUNT(1)
        INTO CONTADOR_2
        FROM ADMPT_CLIENTEFIJA F
       WHERE F.ADMPV_COD_CLI = codigoContrato;
    
      IF CONTADOR_1 > 0 OR CONTADOR_2 > 0 THEN
        codigoRespuesta  := '1';
        mensajeRespuesta := 'Contrato ya existe';
        RETURN;
      
      END IF;
    END IF;
  
    --Verificar si es punto regular
    IF tipoPuntos = 1 THEN
      V_TIPOPUNTOS := 'C';
    ELSE
      --Controlamos los errores, si es punto regular
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Tipo de Punto no regular.';
      RETURN;
    END IF;
    --Verificar el valor de familia mayor a 4
    IF familia > 4 THEN
      --Controlamos los errores, si es familia
      codigoRespuesta  := '1';
      mensajeRespuesta := 'Familia con valor mayor a 4.';
      RETURN;
    END IF;
  
    --Validando origen
    IF origen <> 'TCRM' THEN
      IF origen <> 'LEGADO' THEN
      
        codigoRespuesta  := '1';
        mensajeRespuesta := 'origen no permitido';
        return;
      END IF;
    END IF;
    --PARAMETRO ORIGEN = 'TCRM' - CLARO CLUB
    IF TRIM(origen) = 'TCRM' THEN
      --Verificamos PostPago 2 o PrePago 1
      IF tipoProducto = '2' or tipoProducto = '1' THEN
        --Verificamos si es MOVIL
        IF familia = 1 THEN
          --Validando Tipo de Producto
          V_TIPOPRODUCTO := TO_NUMBER(tipoProducto, '9');
          --Validamos si el Codigo del Contrato no existe en Tabla ADMPT_CLIENTE
          V_REGCON := 0;
          SELECT COUNT(1)
            INTO V_REGCON
            FROM PCLUB.ADMPT_CLIENTE
           WHERE ADMPV_COD_CLI = codigoContrato;
          IF V_REGCON = 0 THEN
            --INSERT INTO PCLUB.ADMPT_CLIENTE
            INSERT INTO PCLUB.ADMPT_CLIENTE  H
              (H.ADMPV_COD_CLI,
               H.ADMPV_COD_SEGCLI,
               H.ADMPN_COD_CATCLI,
               H.ADMPV_TIPO_DOC,
               H.ADMPV_NUM_DOC,
               H.ADMPV_NOM_CLI,
               H.ADMPV_APE_CLI,
               H.ADMPC_SEXO,
               H.ADMPV_EST_CIVIL,
               H.ADMPV_EMAIL,
               H.ADMPV_PROV,
               H.ADMPV_DEPA,
               H.ADMPV_DIST,
               H.ADMPD_FEC_ACTIV,
               H.ADMPV_CICL_FACT,
               H.ADMPC_ESTADO,
               H.ADMPV_COD_TPOCL,
               H.ADMPD_FEC_REG,
               H.ADMPV_USU_REG)
            VALUES
              (codigoContrato,
               segmento,
               categoria,
               tipoDocumento,
               numeroDocumento,
               nombres,
               apellidos,
               V_SEXO,
               estadoCivil,
               email,
               provincia,
               departamento,
               distrito,
               fechaRegistro,
               cicloFacturacion,
               estado,
               V_TIPOPRODUCTO,
               fechaRegistro,
               origen);
            --Validamos si cantidadPuntos es mayor a Cero.
            IF cantidadPuntos > 0 THEN
              --INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE
              /**Generar secuencial de Saldo*/
              SELECT PCLUB.admpt_sld_cl_sq.nextval
                INTO V_IDSALDO
                FROM DUAL;
              INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE
                (admpn_id_saldo,
                 admpv_cod_cli,
                 admpn_cod_cli_ib,
                 admpn_saldo_cc,
                 admpn_saldo_ib,
                 admpc_estpto_cc,
                 admpc_estpto_ib)
              VALUES
                (V_IDSALDO,
                 codigoContrato,
                 0,
                 cantidadPuntos,
                 0.00,
                 'A',
                 NULL);
              --INSERT INTO PCLUB.ADMPT_KARDEX
              /**Generar secuencial de Kardex*/
              SELECT PCLUB.admpt_kardex_sq.nextval
                INTO V_IDKARDEX
                FROM DUAL;
              INSERT INTO PCLUB.ADMPT_KARDEX
                (ADMPN_ID_KARDEX,
                 ADMPN_COD_CLI_IB,
                 ADMPV_COD_CLI,
                 ADMPV_COD_CPTO,
                 ADMPD_FEC_TRANS,
                 ADMPN_PUNTOS,
                 ADMPV_NOM_ARCH,
                 ADMPC_TPO_OPER,
                 ADMPC_TPO_PUNTO,
                 ADMPN_SLD_PUNTO,
                 ADMPC_ESTADO,
                 ADMPV_IDTRANSLOY,
                 ADMPD_FEC_REG,
                 ADMPV_DESC_PROM,
                 ADMPN_TIP_PREMIO,
                 ADMPV_USU_REG,
                 ADMPV_USU_MOD)
              VALUES
                (V_IDKARDEX,
                 '',
                 codigoContrato,
                 concepto,
                 fechaRegistro,
                 cantidadPuntos,
                 origen,
                 V_TIPO_OPERACION,
                 V_TIPOPUNTOS,
                 cantidadPuntos,
                 V_ESTADO,
                 '',
                 fechaRegistro,
                 '',
                 '',
                 origen,
                 '');
            END IF;
          
            --INSERT INTO PCLUB:ADMPT_CONTRATOS
            INSERT INTO PCLUB.ADMPT_CONTRATOS
              (ADMPV_CODIGOCONTRATO,
               ADMPN_FAMILIA,
               ADMPV_NUMEROLINEA,
               ADMPN_TECNOLOGIA,
               ADMPN_TIPOTELEFONIA,
               ADMPV_CASOESPECIAL,
               ADMPV_TIPOPRODUCTO,
               ADMPV_ESTADO,
               ADMPD_FECHACREACION,
               ADMPV_ORIGEN)
            VALUES
              (codigoContrato,
               familia,
               numeroLinea,
               tecnologia,
               tipoTelefonia,
               casoEspecial,
               tipoProducto,
               V_ESTADO,
               sysdate,
               origen);
          
            --CUPONERAVIRTUAL
            SELECT COUNT(C.ADMPN_COD_CLI)
              INTO V_REGCON
              FROM PCLUB.ADMPT_CLIENTECUPONERA C
             WHERE C.ADMPV_NUM_DOC = numeroDocumento
               AND C.ADMPV_TIPO_DOC = tipoDocumento
               AND C.ADMPC_ESTADO = 'A';
            IF V_REGCON = 0 THEN
              PCLUB.PKG_CC_CUPONERA.ADMPSI_ALTACLIENTEDIARIO(tipoDocumento,
                                                             numeroDocumento,
                                                             nombres,
                                                             apellidos,
                                                             email,
                                                             'ALTA',
                                                             'TCRM',
                                                             codigoRespuesta,
                                                             mensajeRespuesta);
            END IF;
            --CUPONERAVIRTUAL
          
          ELSE
            codigoRespuesta  := '1';
            mensajeRespuesta := 'Contrato ya existe.';
            RETURN;
          END IF;
        ELSE
          --Validamos si el Codigo del Contrato no existe en Tabla ADMPT_CLIENTEFIJA
          V_REGCON := 0;
          SELECT COUNT(1)
            INTO V_REGCON
            FROM PCLUB.ADMPT_CLIENTEFIJA
           WHERE ADMPV_COD_CLI = codigoContrato;
          IF V_REGCON = 0 THEN
            --Verificaciomes si es DTH
            IF tecnologia = 3 THEN
              --Validando Tipo de Producto
              V_TIPOPRODUCTO := TO_NUMBER(tipoProducto, '9');
              --INSERT INTO PCLUB.ADMPT_CLIENTEFIJA
              INSERT INTO PCLUB.ADMPT_CLIENTEFIJA
                (ADMPV_COD_CLI,
                 ADMPV_COD_SEGCLI,
                 ADMPN_COD_CATCLI,
                 ADMPV_TIPO_DOC,
                 ADMPV_NUM_DOC,
                 ADMPV_NOM_CLI,
                 ADMPV_APE_CLI,
                 ADMPC_SEXO,
                 ADMPV_EST_CIVIL,
                 ADMPV_EMAIL,
                 ADMPV_PROV,
                 ADMPV_DEPA,
                 ADMPV_DIST,
                 ADMPD_FEC_ACTIV,
                 ADMPC_ESTADO,
                 ADMPV_COD_TPOCL,
                 ADMPD_FEC_REG,
                 ADMPV_USU_REG)
              VALUES
                (codigoContrato,
                 segmento,
                 categoria,
                 tipoDocumento,
                 numeroDocumento,
                 nombres,
                 apellidos,
                 V_SEXO,
                 estadoCivil,
                 email,
                 provincia,
                 departamento,
                 distrito,
                 fechaRegistro,
                 estado,
                 V_TIPOPRODUCTO,
                 fechaRegistro,
                 origen);
              --INSERT INTO PCLUB.ADMPT_CLIENTEPRODUCTO
              INSERT INTO PCLUB.ADMPT_CLIENTEPRODUCTO
                (ADMPV_COD_CLI_PROD,
                 ADMPV_COD_CLI,
                 ADMPV_SERVICIO,
                 ADMPV_ESTADO_SERV,
                 ADMPV_FEC_ULTANIV,
                 ADMPD_FEC_REG,
                 ADMPV_USU_REG,
                 ADMPV_INDICEGRUPO,
                 ADMPV_CICL_FACT)
              VALUES
                (codigoContrato,
                 codigoContrato,
                 familia,
                 estado,
                 fechaRegistro,
                 fechaRegistro,
                 origen,
                 V_INDICEGRUPO,
                 cicloFacturacion);
              --Validamos si cantidadPuntos es mayor a Cero.
              IF cantidadPuntos > 0 THEN
                --INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                /**Generar secuencial de Saldo*/
                SELECT PCLUB.admpt_sld_clfija_sq.nextval
                  INTO V_IDSALDO
                  FROM DUAL;
                INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                  (ADMPN_SALDO_IB,
                   ADMPC_ESTPTO_CC,
                   ADMPC_ESTPTO_IB,
                   ADMPD_FEC_REG,
                   ADMPV_USU_REG,
                   ADMPN_ID_SALDO,
                   ADMPV_COD_CLI_PROD,
                   ADMPN_COD_CLI_IB,
                   ADMPN_SALDO_CC)
                VALUES
                  (0,
                   V_ESTADO,
                   '',
                   fechaRegistro,
                   origen,
                   V_IDSALDO,
                   codigoContrato,
                   0,
                   cantidadPuntos);
                --INSERT INTO PCLUB.ADMPT_KARDEXFIJA
                /**Generar secuencial de Kardex*/
                SELECT PCLUB.admpt_kardexfija_sq.nextval
                  INTO V_IDKARDEX
                  FROM DUAL;
                INSERT INTO PCLUB.ADMPT_KARDEXFIJA
                  (ADMPN_ID_KARDEX,
                   ADMPN_COD_CLI_IB,
                   ADMPV_COD_CLI_PROD,
                   ADMPV_COD_CPTO,
                   ADMPD_FEC_TRANS,
                   ADMPN_PUNTOS,
                   ADMPV_NOM_ARCH,
                   ADMPC_TPO_OPER,
                   ADMPC_TPO_PUNTO,
                   ADMPN_SLD_PUNTO,
                   ADMPC_ESTADO,
                   ADMPD_FEC_REG,
                   ADMPV_DESC_PROM,
                   ADMPV_USU_REG,
                   ADMPV_USU_MOD,
                   ADMPV_ID_CANJE)
                VALUES
                  (V_IDKARDEX,
                   '',
                   codigoContrato,
                   concepto,
                   fechaRegistro,
                   cantidadPuntos,
                   origen,
                   V_TIPO_OPERACION,
                   V_TIPOPUNTOS,
                   cantidadPuntos,
                   V_ESTADO,
                   fechaRegistro,
                   '',
                   origen,
                   '',
                   '');
              END IF;
              --INSERT INTO PCLUB:ADMPT_CONTRATOS
              INSERT INTO PCLUB.ADMPT_CONTRATOS
                (ADMPV_CODIGOCONTRATO,
                 ADMPN_FAMILIA,
                 ADMPV_NUMEROLINEA,
                 ADMPN_TECNOLOGIA,
                 ADMPN_TIPOTELEFONIA,
                 ADMPV_CASOESPECIAL,
                 ADMPV_TIPOPRODUCTO,
                 ADMPV_ESTADO,
                 ADMPD_FECHACREACION,
                 ADMPV_ORIGEN)
              VALUES
                (codigoContrato,
                 familia,
                 numeroLinea,
                 tecnologia,
                 tipoTelefonia,
                 casoEspecial,
                 tipoProducto,
                 V_ESTADO,
                 sysdate,
                 origen);
              --CUPONERAVIRTUAL
              SELECT COUNT(C.ADMPN_COD_CLI)
                INTO V_REGCON
                FROM PCLUB.ADMPT_CLIENTECUPONERA C
               WHERE C.ADMPV_NUM_DOC = numeroDocumento
                 AND C.ADMPV_TIPO_DOC = tipoDocumento
                 AND C.ADMPC_ESTADO = 'A';
              IF V_REGCON = 0 THEN
                PCLUB.PKG_CC_CUPONERA.ADMPSI_ALTACLIENTEDIARIO(tipoDocumento,
                                                               numeroDocumento,
                                                               nombres,
                                                               apellidos,
                                                               email,
                                                               'ALTA',
                                                               'TCRM',
                                                               codigoRespuesta,
                                                               mensajeRespuesta);
              END IF;
              --CUPONERAVIRTUAL
            ELSE
              --Verificaciomes si es HFC
              IF tecnologia = 1 THEN
                --Validando Tipo de Producto
                V_TIPOPRODUCTO := TO_NUMBER(tipoProducto, '9');
                --INSERT INTO PCLUB.ADMPT_CLIENTEFIJA
                INSERT INTO PCLUB.ADMPT_CLIENTEFIJA
                  (ADMPV_COD_CLI,
                   ADMPV_COD_SEGCLI,
                   ADMPN_COD_CATCLI,
                   ADMPV_TIPO_DOC,
                   ADMPV_NUM_DOC,
                   ADMPV_NOM_CLI,
                   ADMPV_APE_CLI,
                   ADMPC_SEXO,
                   ADMPV_EST_CIVIL,
                   ADMPV_EMAIL,
                   ADMPV_PROV,
                   ADMPV_DEPA,
                   ADMPV_DIST,
                   ADMPD_FEC_ACTIV,
                   ADMPC_ESTADO,
                   ADMPV_COD_TPOCL,
                   ADMPD_FEC_REG,
                   ADMPV_USU_REG)
                VALUES
                  (codigoContrato,
                   segmento,
                   categoria,
                   tipoDocumento,
                   numeroDocumento,
                   nombres,
                   apellidos,
                   V_SEXO,
                   estadoCivil,
                   email,
                   provincia,
                   departamento,
                   distrito,
                   fechaRegistro,
                   estado,
                   V_TIPOPRODUCTO,
                   fechaRegistro,
                   origen);
                --INSERT INTO PCLUB.ADMPT_CLIENTEPRODUCTO
                INSERT INTO PCLUB.ADMPT_CLIENTEPRODUCTO
                  (ADMPV_COD_CLI_PROD,
                   ADMPV_COD_CLI,
                   ADMPV_SERVICIO,
                   ADMPV_ESTADO_SERV,
                   ADMPV_FEC_ULTANIV,
                   ADMPD_FEC_REG,
                   ADMPV_USU_REG,
                   ADMPV_INDICEGRUPO,
                   ADMPV_CICL_FACT)
                VALUES
                  (codigoContrato,
                   codigoContrato,
                   familia,
                   estado,
                   fechaRegistro,
                   fechaRegistro,
                   origen,
                   V_INDICEGRUPO,
                   cicloFacturacion);
                --Validamos si cantidadPuntos es mayor a Cero.
                IF cantidadPuntos > 0 THEN
                  --INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                  /**Generar secuencial de Saldo*/
                  SELECT PCLUB.admpt_sld_clfija_sq.nextval
                    INTO V_IDSALDO
                    FROM DUAL;
                  INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTEFIJA
                    (ADMPN_SALDO_IB,
                     ADMPC_ESTPTO_CC,
                     ADMPC_ESTPTO_IB,
                     ADMPD_FEC_REG,
                     ADMPV_USU_REG,
                     ADMPN_ID_SALDO,
                     ADMPV_COD_CLI_PROD,
                     ADMPN_COD_CLI_IB,
                     ADMPN_SALDO_CC)
                  VALUES
                    (0,
                     V_ESTADO,
                     '',
                     fechaRegistro,
                     origen,
                     V_IDSALDO,
                     codigoContrato,
                     '',
                     cantidadPuntos);
                  --INSERT INTO PCLUB.ADMPT_KARDEXFIJA
                  /**Generar secuencial de Kardex*/
                  SELECT PCLUB.admpt_kardexfija_sq.nextval
                    INTO V_IDKARDEX
                    FROM DUAL;
                  INSERT INTO PCLUB.ADMPT_KARDEXFIJA
                    (ADMPN_ID_KARDEX,
                     ADMPN_COD_CLI_IB,
                     ADMPV_COD_CLI_PROD,
                     ADMPV_COD_CPTO,
                     ADMPD_FEC_TRANS,
                     ADMPN_PUNTOS,
                     ADMPV_NOM_ARCH,
                     ADMPC_TPO_OPER,
                     ADMPC_TPO_PUNTO,
                     ADMPN_SLD_PUNTO,
                     ADMPC_ESTADO,
                     ADMPD_FEC_REG,
                     ADMPV_DESC_PROM,
                     ADMPV_USU_REG,
                     ADMPV_USU_MOD,
                     ADMPV_ID_CANJE)
                  VALUES
                    (V_IDKARDEX,
                     '',
                     codigoContrato,
                     concepto,
                     fechaRegistro,
                     cantidadPuntos,
                     origen,
                     V_TIPO_OPERACION,
                     V_TIPOPUNTOS,
                     cantidadPuntos,
                     V_ESTADO,
                     fechaRegistro,
                     '',
                     origen,
                     '',
                     '');
                END IF;
                --INSERT INTO PCLUB.ADMPT_CONTRATOS
                INSERT INTO PCLUB.ADMPT_CONTRATOS
                  (ADMPV_CODIGOCONTRATO,
                   ADMPN_FAMILIA,
                   ADMPV_NUMEROLINEA,
                   ADMPN_TECNOLOGIA,
                   ADMPN_TIPOTELEFONIA,
                   ADMPV_CASOESPECIAL,
                   ADMPV_TIPOPRODUCTO,
                   ADMPV_ESTADO,
                   ADMPD_FECHACREACION,
                   ADMPV_ORIGEN)
                VALUES
                  (codigoContrato,
                   familia,
                   numeroLinea,
                   tecnologia,
                   tipoTelefonia,
                   casoEspecial,
                   tipoproducto,
                   V_ESTADO,
                   sysdate,
                   origen);
                --CUPONERAVIRTUAL
                SELECT COUNT(C.ADMPN_COD_CLI)
                  INTO V_REGCON
                  FROM PCLUB.ADMPT_CLIENTECUPONERA C
                 WHERE C.ADMPV_NUM_DOC = numeroDocumento
                   AND C.ADMPV_TIPO_DOC = tipoDocumento
                   AND C.ADMPC_ESTADO = 'A';
                IF V_REGCON = 0 THEN
                  PCLUB.PKG_CC_CUPONERA.ADMPSI_ALTACLIENTEDIARIO(tipoDocumento,
                                                                 numeroDocumento,
                                                                 nombres,
                                                                 apellidos,
                                                                 email,
                                                                 'ALTA',
                                                                 'TCRM',
                                                                 codigoRespuesta,
                                                                 mensajeRespuesta);
                END IF;
                --CUPONERAVIRTUAL
              
              ELSE
                --Controlamos los errores, si es LTE-TDD
                codigoRespuesta  := '1';
                mensajeRespuesta := 'Tecnologia no valida.';
              END IF;
            END IF;
          ELSE
            codigoRespuesta  := '1';
            mensajeRespuesta := 'Contrato ya existe.';
          END IF;
        
        END IF;
      ELSE
        --Verificamos si es PrePago 1
        --Controlamos los errores, si no existe un Producto.
        codigoRespuesta  := '1';
        mensajeRespuesta := 'Producto no soportado.';
      
      END IF;
    
    END IF;
  
    --PARAMETRO ORIGEN = 'LEGADO' - CLARO CLUB
    IF TRIM(origen) = 'LEGADO' THEN
      --Verificamos 1 2 3 4
      IF tipoProducto = '1' or tipoProducto = '2' or tipoProducto = '3' or
         tipoProducto = '4' or tipoProducto = '8' THEN
        --Validando Tipo de Producto
        V_TIPOPRODUCTO := TO_NUMBER(tipoProducto, '9');
        --Validamos si el Codigo del Contrato no existe en Tabla ADMPT_CLIENTE
        V_REGCON := 0;
        SELECT COUNT(1)
          INTO V_REGCON
          FROM PCLUB.ADMPT_CLIENTE
         WHERE ADMPV_COD_CLI = codigoContrato;
        IF V_REGCON = 0 THEN
          --INSERT INTO PCLUB.ADMPT_CLIENTE
          INSERT INTO PCLUB.ADMPT_CLIENTE H
            (H.ADMPV_COD_CLI,
             H.ADMPV_COD_SEGCLI,
             H.ADMPN_COD_CATCLI,
             H.ADMPV_TIPO_DOC,
             H.ADMPV_NUM_DOC,
             H.ADMPV_NOM_CLI,
             H.ADMPV_APE_CLI,
             H.ADMPC_SEXO,
             H.ADMPV_EST_CIVIL,
             H.ADMPV_EMAIL,
             H.ADMPV_PROV,
             H.ADMPV_DEPA,
             H.ADMPV_DIST,
             H.ADMPD_FEC_ACTIV,
             H.ADMPV_CICL_FACT,
             H.ADMPC_ESTADO,
             H.ADMPV_COD_TPOCL,
             H.ADMPD_FEC_REG,
             H.ADMPV_USU_REG)
          VALUES
            (codigoContrato,
             segmento,
             categoria,
             tipoDocumento,
             numeroDocumento,
             nombres,
             apellidos,
             V_SEXO,
             estadoCivil,
             email,
             provincia,
             departamento,
             distrito,
             fechaRegistro,
             cicloFacturacion,
             estado,
             V_TIPOPRODUCTO,
             fechaRegistro,
             origen);
          --Validamos si cantidadPuntos es mayor a Cero.
          IF cantidadPuntos > 0 THEN
            --INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE
            /**Generar secuencial de Saldo*/
            SELECT PCLUB.admpt_sld_cl_sq.nextval INTO V_IDSALDO FROM DUAL;
            INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTE
              (admpn_id_saldo,
               admpv_cod_cli,
               admpn_cod_cli_ib,
               admpn_saldo_cc,
               admpn_saldo_ib,
               admpc_estpto_cc,
               admpc_estpto_ib)
            VALUES
              (V_IDSALDO,
               codigoContrato,
               0,
               cantidadPuntos,
               0.00,
               'A',
               NULL);
            --INSERT INTO PCLUB.ADMPT_KARDEX
            /**Generar secuencial de Kardex*/
            SELECT PCLUB.admpt_kardex_sq.nextval INTO V_IDKARDEX FROM DUAL;
            INSERT INTO PCLUB.ADMPT_KARDEX
              (ADMPN_ID_KARDEX,
               ADMPN_COD_CLI_IB,
               ADMPV_COD_CLI,
               ADMPV_COD_CPTO,
               ADMPD_FEC_TRANS,
               ADMPN_PUNTOS,
               ADMPV_NOM_ARCH,
               ADMPC_TPO_OPER,
               ADMPC_TPO_PUNTO,
               ADMPN_SLD_PUNTO,
               ADMPC_ESTADO,
               ADMPV_IDTRANSLOY,
               ADMPD_FEC_REG,
               ADMPV_DESC_PROM,
               ADMPN_TIP_PREMIO,
               ADMPV_USU_REG,
               ADMPV_USU_MOD)
            VALUES
              (V_IDKARDEX,
               '',
               codigoContrato,
               concepto,
               fechaRegistro,
               cantidadPuntos,
               origen,
               V_TIPO_OPERACION,
               V_TIPOPUNTOS,
               cantidadPuntos,
               V_ESTADO,
               '',
               fechaRegistro,
               '',
               '',
               origen,
               '');
          END IF;
        
          --INSERT INTO PCLUB:ADMPT_CONTRATOS
          INSERT INTO PCLUB.ADMPT_CONTRATOS
            (ADMPV_CODIGOCONTRATO,
             ADMPN_FAMILIA,
             ADMPV_NUMEROLINEA,
             ADMPN_TECNOLOGIA,
             ADMPN_TIPOTELEFONIA,
             ADMPV_CASOESPECIAL,
             ADMPV_TIPOPRODUCTO,
             ADMPV_ESTADO,
             ADMPD_FECHACREACION,
             ADMPV_ORIGEN)
          VALUES
            (codigoContrato,
             familia,
             numeroLinea,
             tecnologia,
             tipoTelefonia,
             casoEspecial,
             tipoProducto,
             V_ESTADO,
             sysdate,
             origen);
        
          --CUPONERAVIRTUAL
          SELECT COUNT(C.ADMPN_COD_CLI)
            INTO V_REGCON
            FROM PCLUB.ADMPT_CLIENTECUPONERA C
           WHERE C.ADMPV_NUM_DOC = numeroDocumento
             AND C.ADMPV_TIPO_DOC = tipoDocumento
             AND C.ADMPC_ESTADO = 'A';
          IF V_REGCON = 0 THEN
            PCLUB.PKG_CC_CUPONERA.ADMPSI_ALTACLIENTEDIARIO(tipoDocumento,
                                                           numeroDocumento,
                                                           nombres,
                                                           apellidos,
                                                           email,
                                                           'ALTA',
                                                           'TCRM',
                                                           codigoRespuesta,
                                                           mensajeRespuesta);
          END IF;
          --CUPONERAVIRTUAL
        
        ELSE
          codigoRespuesta  := '1';
          mensajeRespuesta := 'Contrato ya existe.';
        END IF;
      END IF;
      --Verificamos 6 7 
      IF tipoProducto = '6' or tipoProducto = '7' THEN
        --Validamos si el Codigo del Contrato no existe en Tabla ADMPT_CLIENTEFIJA
        V_REGCON := 0;
        SELECT COUNT(1)
          INTO V_REGCON
          FROM PCLUB.ADMPT_CLIENTEFIJA
         WHERE ADMPV_COD_CLI = codigoContrato;
        IF V_REGCON = 0 THEN
          --Validando Tipo de Producto
          V_TIPOPRODUCTO := TO_NUMBER(tipoProducto, '9');
          --INSERT INTO PCLUB.ADMPT_CLIENTEFIJA
          INSERT INTO PCLUB.ADMPT_CLIENTEFIJA
            (ADMPV_COD_CLI,
             ADMPV_COD_SEGCLI,
             ADMPN_COD_CATCLI,
             ADMPV_TIPO_DOC,
             ADMPV_NUM_DOC,
             ADMPV_NOM_CLI,
             ADMPV_APE_CLI,
             ADMPC_SEXO,
             ADMPV_EST_CIVIL,
             ADMPV_EMAIL,
             ADMPV_PROV,
             ADMPV_DEPA,
             ADMPV_DIST,
             ADMPD_FEC_ACTIV,
             ADMPC_ESTADO,
             ADMPV_COD_TPOCL,
             ADMPD_FEC_REG,
             ADMPV_USU_REG)
          VALUES
            (codigoContrato,
             segmento,
             categoria,
             tipoDocumento,
             numeroDocumento,
             nombres,
             apellidos,
             V_SEXO,
             estadoCivil,
             email,
             provincia,
             departamento,
             distrito,
             fechaRegistro,
             estado,
             V_TIPOPRODUCTO,
             fechaRegistro,
             origen);
          --INSERT INTO PCLUB.ADMPT_CLIENTEPRODUCTO
          INSERT INTO PCLUB.ADMPT_CLIENTEPRODUCTO
            (ADMPV_COD_CLI_PROD,
             ADMPV_COD_CLI,
             ADMPV_SERVICIO,
             ADMPV_ESTADO_SERV,
             ADMPV_FEC_ULTANIV,
             ADMPD_FEC_REG,
             ADMPV_USU_REG,
             ADMPV_INDICEGRUPO,
             ADMPV_CICL_FACT)
          VALUES
            (codigoContrato,
             codigoContrato,
             familia,
             estado,
             fechaRegistro,
             fechaRegistro,
             origen,
             V_INDICEGRUPO,
             cicloFacturacion);
          --Validamos si cantidadPuntos es mayor a Cero.
          IF cantidadPuntos > 0 THEN
            --INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTEFIJA
            /**Generar secuencial de Saldo*/
            SELECT PCLUB.admpt_sld_clfija_sq.nextval
              INTO V_IDSALDO
              FROM DUAL;
            INSERT INTO PCLUB.ADMPT_SALDOS_CLIENTEFIJA
              (ADMPN_SALDO_IB,
               ADMPC_ESTPTO_CC,
               ADMPC_ESTPTO_IB,
               ADMPD_FEC_REG,
               ADMPV_USU_REG,
               ADMPN_ID_SALDO,
               ADMPV_COD_CLI_PROD,
               ADMPN_COD_CLI_IB,
               ADMPN_SALDO_CC)
            VALUES
              (0,
               V_ESTADO,
               '',
               fechaRegistro,
               origen,
               V_IDSALDO,
               codigoContrato,
               0,
               cantidadPuntos);
            --INSERT INTO PCLUB.ADMPT_KARDEXFIJA
            /**Generar secuencial de Kardex*/
            SELECT PCLUB.admpt_kardexfija_sq.nextval
              INTO V_IDKARDEX
              FROM DUAL;
            INSERT INTO PCLUB.ADMPT_KARDEXFIJA
              (ADMPN_ID_KARDEX,
               ADMPN_COD_CLI_IB,
               ADMPV_COD_CLI_PROD,
               ADMPV_COD_CPTO,
               ADMPD_FEC_TRANS,
               ADMPN_PUNTOS,
               ADMPV_NOM_ARCH,
               ADMPC_TPO_OPER,
               ADMPC_TPO_PUNTO,
               ADMPN_SLD_PUNTO,
               ADMPC_ESTADO,
               ADMPD_FEC_REG,
               ADMPV_DESC_PROM,
               ADMPV_USU_REG,
               ADMPV_USU_MOD,
               ADMPV_ID_CANJE)
            VALUES
              (V_IDKARDEX,
               '',
               codigoContrato,
               concepto,
               fechaRegistro,
               cantidadPuntos,
               origen,
               V_TIPO_OPERACION,
               V_TIPOPUNTOS,
               cantidadPuntos,
               V_ESTADO,
               fechaRegistro,
               '',
               origen,
               '',
               '');
          END IF;
          --INSERT INTO PCLUB:ADMPT_CONTRATOS
          INSERT INTO PCLUB.ADMPT_CONTRATOS
            (ADMPV_CODIGOCONTRATO,
             ADMPN_FAMILIA,
             ADMPV_NUMEROLINEA,
             ADMPN_TECNOLOGIA,
             ADMPN_TIPOTELEFONIA,
             ADMPV_CASOESPECIAL,
             ADMPV_TIPOPRODUCTO,
             ADMPV_ESTADO,
             ADMPD_FECHACREACION,
             ADMPV_ORIGEN)
          VALUES
            (codigoContrato,
             familia,
             numeroLinea,
             tecnologia,
             tipoTelefonia,
             casoEspecial,
             tipoProducto,
             V_ESTADO,
             sysdate,
             origen);
          --CUPONERAVIRTUAL
          SELECT COUNT(C.ADMPN_COD_CLI)
            INTO V_REGCON
            FROM PCLUB.ADMPT_CLIENTECUPONERA C
           WHERE C.ADMPV_NUM_DOC = numeroDocumento
             AND C.ADMPV_TIPO_DOC = tipoDocumento
             AND C.ADMPC_ESTADO = 'A';
          IF V_REGCON = 0 THEN
            PCLUB.PKG_CC_CUPONERA.ADMPSI_ALTACLIENTEDIARIO(tipoDocumento,
                                                           numeroDocumento,
                                                           nombres,
                                                           apellidos,
                                                           email,
                                                           'ALTA',
                                                           'TCRM',
                                                           codigoRespuesta,
                                                           mensajeRespuesta);
          END IF;
        
          --CUPONERAVIRTUAL
        ELSE
          codigoRespuesta  := '1';
          mensajeRespuesta := 'Contrato ya existe.';
        END IF;
      
      END IF;
    
    END IF;
  
    --Controlamos los errores
  EXCEPTION
    WHEN OTHERS THEN
      codigoRespuesta  := '1';
      mensajeRespuesta := SQLERRM;
    
  END sp_afiliaciones;

end PKG_AFILIACIONES;
/
