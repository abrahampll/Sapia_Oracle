create or replace package body PCLUB.PKG_TRANSACCION_NOCLIENTE is
       
       /****************************************************************
       * NOMBRE SP          :  ADMPSS_VALIDA_NOCLIENTE
       * PROPOSITO          :  CONSULTA SI UN NO CLIENTE SE ENCUENTRA REGISTRADO EN CLARO CLUB
       * INPUT              :  V_admpv_tipo_doc  -  Tipo de documento
       *                       V_admpv_num_doc   -  Número de documento
       * OUTPUT             :  V_RESULTADO       -  Devuelve el código de validación o error
       *                       V_MSG_ERROR       -  Devuelve el mensaje de validación o error
       * CREADO POR         :  BRANDON RAY GONZALES CHACCARA
       * FEC CREACION       :  01/06/2016
       * FEC ACTUALIZACION  :
       ****************************************************************/
       procedure ADMPSS_VALIDA_NOCLIENTE (V_admpv_tipo_doc  in  varchar2,
                                          V_admpv_num_doc   in  varchar2,
                                          V_RESULTADO       out number,
                                          V_MSG_ERROR       out varchar2)
       as
       -- declaracion de variables
       V_CANT NUMBER;
       begin
          select COUNT(*) INTO V_CANT from ADMPT_NO_CLIENTE C
                 WHERE C.ADMPV_TIPO_DOC = V_admpv_tipo_doc
                 AND C.ADMPV_NUM_DOC = V_admpv_num_doc;

          IF (V_CANT = 0) THEN
             RAISE NO_DATA_FOUND;
          ELSE
             V_RESULTADO := '0';
             V_MSG_ERROR := 'SE ENCUENTRA REGISTRADO';
          END IF;

         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 V_RESULTADO := 1;
                 V_MSG_ERROR := 'NO SE ENCUENTRA REGISTRADO';
             WHEN OTHERS THEN
                 V_RESULTADO := '-1';
                 V_MSG_ERROR := SQLCODE || ' : ' || SQLERRM;

       end ADMPSS_VALIDA_NOCLIENTE;

       /****************************************************************
       * NOMBRE SP          :  ADMPSS_CONSULTA_NOCLIENTE
       * PROPOSITO          :  OBTIENE LOS DATOS DEL NO CLIENTE QUE SE ENCUENTRA REGISTRADO EN CLARO CLUB
       * INPUT              :  V_admpv_tipo_doc  -  Tipo de documento
       *                       V_admpv_num_doc   -  Número de documento
       * OUTPUT             :  P_CURSOR          -  Cursor que devuelve los datos de un no cliente
       *                       V_RESULTADO       -  Devuelve el código de validación o error
       *                       V_MSG_ERROR       -  Devuelve el mensaje de validación o error
       * CREADO POR         :  BRANDON RAY GONZALES CHACCARA
       * FEC CREACION       :  01/06/2016
       * FEC ACTUALIZACION  :
       ****************************************************************/
       procedure ADMPSS_CONSULTA_NOCLIENTE (V_admpv_tipo_doc  in  varchar2,
                                             V_admpv_num_doc  in  varchar2,
                                             P_CURSOR         out CURSOR_SALIDA,
                                             V_RESULTADO      out varchar2,
                                             V_MSG_ERROR      out varchar2)
       as
       -- declaracion de variables
       V_CANT NUMBER;
       begin
          SELECT COUNT(*) INTO V_CANT FROM ADMPT_NO_CLIENTE C
                 WHERE C.ADMPV_TIPO_DOC = V_admpv_tipo_doc
                       AND C.ADMPV_NUM_DOC = V_admpv_num_doc
                       AND C.ADMPC_ESTADO = 'A';    
          
          IF (V_CANT > 0) THEN
             OPEN P_CURSOR FOR
                 SELECT C.ADMPV_COD_SEGCLI,
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
                 C.ADMPD_FEC_REG
                  FROM ADMPT_NO_CLIENTE C WHERE C.ADMPV_TIPO_DOC = V_admpv_tipo_doc
                 AND C.ADMPV_NUM_DOC = V_admpv_num_doc AND C.ADMPC_ESTADO = 'A';
          
              V_RESULTADO := '0';
              V_MSG_ERROR := 'CORRECTO';
          ELSE
              OPEN P_CURSOR FOR
                 SELECT C.ADMPV_COD_SEGCLI,
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
                 C.ADMPD_FEC_REG
                  FROM ADMPT_NO_CLIENTE C WHERE C.ADMPV_TIPO_DOC = V_admpv_tipo_doc
                 AND C.ADMPV_NUM_DOC = V_admpv_num_doc AND C.ADMPC_ESTADO = 'A';
          
              V_RESULTADO := '1';
              V_MSG_ERROR := 'NO SE ENCONTRARON CLIENTES';
          END IF;
     
       EXCEPTION
             WHEN OTHERS THEN
                 OPEN P_CURSOR FOR
                 SELECT C.ADMPV_COD_SEGCLI,
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
                 C.ADMPD_FEC_REG
                  FROM ADMPT_NO_CLIENTE C WHERE C.ADMPV_TIPO_DOC = V_admpv_tipo_doc
                 AND C.ADMPV_NUM_DOC = V_admpv_num_doc AND C.ADMPC_ESTADO = 'A';
             
                 V_RESULTADO := '-1';
                 V_MSG_ERROR := SQLCODE || ' : ' || SQLERRM;

       end ADMPSS_CONSULTA_NOCLIENTE;

       /****************************************************************
       * NOMBRE SP          :  ADMPSI_REGISTRA_NOCLIENTE
       * PROPOSITO          :  REGISTRA AL NO CLIENTE EN CLARO CLUB
       * INPUT              :  V_admpv_cod_segcli   -  Segmento del cliente
       *                       V_admpn_cod_catcli   -  Categoria del cliente
       *                       V_admpv_tipo_doc     -  Tipo de documento
       *                       V_admpv_num_doc      -  Número de documento
       *                       V_admpv_nom_cli      -  Nombre
       *                       V_admpv_ape_cli      -  Apellido
       *                       V_admpc_sexo         -  Sexo
       *                       V_admpv_est_civil    -  Estado civil
       *                       V_admpv_email        -  E-mail
       *                       V_admpv_prov         -  Provincia
       *                       V_admpv_depa         -  Departamento
       *                       V_admpv_dist         -  Distrito
       *                       V_admpd_fec_activ    -  Fecha de registro a Claro Club
       *                       V_admpc_estado       -  Estado del cliente
       *                       V_admpv_cod_tpocl    -  Codigo de tipo de cliente
       *                       V_admpv_convenio     -  Codigo de convenio
       *                       V_admpv_estado_conv  -  Estado del convenio
       *                       V_admpv_servicio     -  Codigo del servicio
       *                       V_admpv_estado_serv  -  Estado del servicio
       *                       V_admpv_fec_ultaniv  -  Ultima fecha de entrega de puntos por aniversario
       *                       V_admpv_usu_reg      -  Auditoria
       * OUTPUT             :  V_RESULTADO          -  Devuelve el código de validación o error
       *                       V_MSG_ERROR          -  Devuelve el mensaje de validación o error
       * CREADO POR         :  BRANDON RAY GONZALES CHACCARA
       * FEC CREACION       :  01/06/2016
       * FEC ACTUALIZACION  :
       ****************************************************************/
       procedure ADMPSI_REGISTRA_NOCLIENTE (V_admpv_cod_segcli   IN  VARCHAR2,
                                            V_admpn_cod_catcli   IN  NUMBER,
                                            V_admpv_tipo_doc     IN  VARCHAR2,
                                            V_admpv_num_doc      IN VARCHAR2,
                                            V_admpv_nom_cli      IN  VARCHAR2,
                                            V_admpv_ape_cli      IN VARCHAR2,
                                            V_admpc_sexo         IN  CHAR,
                                            V_admpv_est_civil    IN  VARCHAR2,
                                            V_admpv_email        IN VARCHAR2,
                                            V_admpv_prov         IN VARCHAR2,
                                            V_admpv_depa         IN  VARCHAR2,
                                            V_admpv_dist         IN  VARCHAR2,
                                            V_admpd_fec_activ    IN  DATE,
                                            V_admpc_estado       IN CHAR,
                                            V_admpv_cod_tpocl    IN  VARCHAR2,
                                            V_admpv_convenio     IN  VARCHAR2,
                                            V_admpv_estado_conv  IN  VARCHAR2,
                                            V_admpv_servicio     IN  VARCHAR2,
                                            V_admpv_estado_serv  IN  VARCHAR2,
                                            V_admpv_fec_ultaniv  IN  DATE,
                                            V_admpv_usu_reg      IN  VARCHAR2,
                                            V_RESULTADO          OUT  VARCHAR2,
                                            V_MSG_ERROR          OUT VARCHAR2)

       as
       -- declaracion de variables
       V_CANT NUMBER;
       V_COD_CLI VARCHAR2(40) := CONCAT(CONCAT(CONCAT(CONCAT(V_admpv_tipo_doc,'.'),V_admpv_num_doc),'.'),V_admpv_cod_tpocl);
       V_COD_CLI_AUX VARCHAR(40) := CONCAT(CONCAT(V_admpv_tipo_doc, V_admpv_num_doc), V_admpv_cod_tpocl);
       V_PREFIX_CLI_CONV VARCHAR2(20) := 'N00';
       V_PREFIX_CLI_SERV VARCHAR2(20) := 'N00';
       V_GUION_BAJO VARCHAR2(5) := '_';
       begin
          select COUNT(*) INTO V_CANT from ADMPT_NO_CLIENTE C
                 WHERE C.ADMPV_COD_CLI = V_COD_CLI;

          IF (V_CANT = 0) THEN
             INSERT INTO ADMPT_NO_CLIENTE
               values(V_COD_CLI,
                      V_admpv_cod_segcli,
                      V_admpn_cod_catcli,
                      V_admpv_tipo_doc,
                      V_admpv_num_doc,
                      V_admpv_nom_cli,
                      V_admpv_ape_cli,
                      V_admpc_sexo,
                      V_admpv_est_civil,
                      V_admpv_email,
                      V_admpv_prov,
                      V_admpv_depa,
                      V_admpv_dist,
                      V_admpd_fec_activ,
                      V_admpc_estado,
                      V_admpv_cod_tpocl,
                      SYSDATE,
                      '',
                      V_admpv_usu_reg,
                      '');

             INSERT INTO ADMPT_CLIENTECONVENIO
                    values(CONCAT(CONCAT(CONCAT(V_PREFIX_CLI_CONV, V_COD_CLI_AUX), V_GUION_BAJO), V_admpv_convenio),V_COD_CLI,V_admpv_convenio,V_admpv_estado_conv,SYSDATE,V_admpv_usu_reg,'','','');
                    
                   
             IF SQL%FOUND THEN
                V_RESULTADO := '0';
                V_MSG_ERROR := 'CORRECTO';
             ELSE
                V_RESULTADO := '1';
                V_MSG_ERROR := 'NO SE PUDO REGISTRAR AL CLIENTE';    
             END IF;
             
          ELSE
             V_RESULTADO := '2';
             V_MSG_ERROR := 'EL CLIENTE YA ESTA REGISTRADO';
          END IF;   

         EXCEPTION
             WHEN OTHERS THEN
                 V_RESULTADO := '-1';
                 V_MSG_ERROR := SQLCODE || ' : ' || SQLERRM;

       end ADMPSI_REGISTRA_NOCLIENTE;

       /****************************************************************
       * NOMBRE SP          :  ADMPSU_ACTUALIZA_NOCLIENTE
       * PROPOSITO          :  ACTUALIZA LOS DATOS DEL NO CLIENTE EN CLARO CLUB
       * INPUT              :  V_admpv_cod_cli      -  Codigo del no cliente
       *                       V_admpv_cod_segcli   -  Segmento del cliente
       *                       V_admpn_cod_catcli   -  Categoria del cliente
       *                       V_admpv_tipo_doc     -  Tipo de documento
       *                       V_admpv_num_doc      -  Número de documento
       *                       V_admpv_nom_cli      -  Nombre
       *                       V_admpv_ape_cli      -  Apellido
       *                       V_admpc_sexo         -  Sexo
       *                       V_admpv_est_civil    -  Estado civil
       *                       V_admpv_email        -  E-mail
       *                       V_admpv_prov         -  Provincia
       *                       V_admpv_depa         -  Departamento
       *                       V_admpv_dist         -  Distrito
       *                       V_admpd_fec_activ    -  Fecha de registro a Claro Club
       *                       V_admpc_estado       -  Estado del cliente
       *                       V_admpv_cod_tpocl    -  Codigo de tipo de cliente
       *                       V_admpv_convenio     -  Codigo de convenio
       *                       V_admpv_estado_conv  -  Estado del convenio
       *                       V_admpv_servicio     -  Codigo del servicio
       *                       V_admpv_estado_serv  -  Estado del servicio
       *                       V_admpv_fec_ultaniv  -  Ultima fecha de entrega de puntos por aniversario
       *                       V_admpv_usu_mod      -  Auditoria
       * OUTPUT             :  V_RESULTADO          -  Devuelve el código de validación o error
       *                       V_MSG_ERROR          -  Devuelve el mensaje de validación o error
       * CREADO POR         :  BRANDON RAY GONZALES CHACCARA
       * FEC CREACION       :  02/06/2016
       * FEC ACTUALIZACION  :
       ****************************************************************/
       PROCEDURE ADMPSU_ACTUALIZA_NOCLIENTE(V_admpv_cod_cli       in  varchar2,
                                             V_admpv_cod_segcli   in  varchar2,
                                             V_admpn_cod_catcli   in  number,
                                             V_admpv_tipo_doc     in  varchar2,
                                             V_admpv_num_doc      in  varchar2,
                                             V_admpv_nom_cli      in  varchar2,
                                             V_admpv_ape_cli      in  varchar2,
                                             V_admpc_sexo         in  CHAR,
                                             V_admpv_est_civil    in  varchar2,
                                             V_admpv_email        in  varchar2,
                                             V_admpv_prov         in  varchar2,
                                             V_admpv_depa         in  varchar2,
                                             V_admpv_dist         in  varchar2,
                                             V_admpd_fec_activ    in  DATE,
                                             V_admpc_estado       in  CHAR,
                                             V_admpv_cod_tpocl    in  varchar2,
                                             V_admpv_convenio     in  varchar2,
                                             V_admpv_estado_conv  in  varchar2,
                                             V_admpv_servicio     in  varchar2,
                                             V_admpv_estado_serv  in  varchar2,
                                             V_admpv_fec_ultaniv  in  date,
                                             V_admpv_usu_mod      in  varchar2,
                                             V_RESULTADO          out varchar2,
                                             V_MSG_ERROR          out varchar2)
        AS
        -- declaracion de variables
        V_CANT NUMBER;
                                                                           
        BEGIN
             SELECT COUNT(*) INTO V_CANT FROM ADMPT_NO_CLIENTE NC
                    WHERE NC.ADMPV_COD_CLI = V_admpv_cod_cli;
             
             IF (V_CANT = 0) THEN
                RAISE NO_DATA_FOUND;
             ELSE
                UPDATE ADMPT_NO_CLIENTE NC         
                     SET NC.admpv_cod_segcli = V_admpv_cod_segcli,         
                         NC.admpn_cod_catcli = V_admpn_cod_catcli,
                         NC.admpv_nom_cli = V_admpv_nom_cli,
                         NC.admpv_ape_cli = V_admpv_ape_cli,
                         NC.admpc_sexo = V_admpc_sexo,
                         NC.admpv_est_civil = V_admpv_est_civil,
                         NC.admpv_email = V_admpv_email,
                         NC.admpv_prov = V_admpv_prov,
                         NC.admpv_depa = V_admpv_depa,
                         NC.admpv_dist = V_admpv_dist,
                         NC.admpd_fec_activ = V_admpd_fec_activ,
                         NC.admpc_estado = V_admpc_estado,
                         NC.ADMPD_FEC_MOD = SYSDATE,
                         NC.ADMPV_USU_MOD = V_admpv_usu_mod                                  
                      WHERE NC.admpv_cod_cli = V_admpv_cod_cli;
           
                UPDATE ADMPT_CLIENTECONVENIO CC
                     SET CC.ADMPV_CONVENIO=V_admpv_convenio,
                         CC.ADMPV_ESTADO_CONV=V_admpv_estado_conv,
                         CC.ADMPD_FEC_MOD = SYSDATE,
                         CC.ADMPV_USU_MOD  = V_admpv_usu_mod
                     WHERE CC.ADMPV_COD_CLI=V_admpv_cod_cli;

                
                IF SQL%FOUND THEN
                   V_RESULTADO := '0';
                   V_MSG_ERROR := 'SE ACTUALIZARON LOS DATOS DEL CLIENTE CON EXITO';
                ELSE
                   V_RESULTADO := '1';
                   V_MSG_ERROR := 'NO SE PUDIERON ACTUALIZAR LOS DATOS DEL CLIENTE';
                END IF;   
             END IF;
          
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
               V_RESULTADO := '2';
               V_MSG_ERROR := 'EL CLIENTE INGRESADO NO EXISTE';
          WHEN OTHERS THEN
               V_RESULTADO := '-1';
               V_MSG_ERROR := SQLCODE || ' : ' || SQLERRM;
               
       END ADMPSU_ACTUALIZA_NOCLIENTE;
       
       /****************************************************************
       * NOMBRE SP          :  ADMPSU_ACT_ESTADO_NOCLIENTE
       * PROPOSITO          :  ACTUALIZAR EL ESTADO DEL NO CLIENTE EN CLARO CLUB
       * INPUT              :  V_admpv_cod_cli    -  Codigo del no cliente
       *                       V_admpv_tipo_doc   -  Tipo de documento
       *                       V_admpv_num_doc    -  Número de documento
       *                       V_admpv_nom_cli    -  Nombre del cliente
       *                       V_admpv_ape_cli    -  Apellido del cliente
       *                       V_admpc_estado     -  Estado del cliente
       *                       V_admpv_cod_tpocl  -  Codigo de tipo de cliente
       *                       V_admpv_usu_mod    -  Auditoria
       * OUTPUT             :  V_RESULTADO        -  Devuelve el código de validación o error
       *                       V_MSG_ERROR        -  Devuelve el mensaje de validación o error
       * CREADO POR         :  BRANDON RAY GONZALES CHACCARA
       * FEC CREACION       :  02/06/2016
       * FEC ACTUALIZACION  :
       ****************************************************************/
       PROCEDURE ADMPSU_ACT_ESTADO_NOCLIENTE (V_admpv_cod_cli    IN VARCHAR2,
                                              V_admpv_tipo_doc   IN VARCHAR2,
                                              V_admpv_num_doc    IN VARCHAR2,
                                              V_admpv_nom_cli    IN VARCHAR2,
                                              V_admpv_ape_cli    IN VARCHAR2,
                                              V_admpc_estado     IN CHAR,
                                              V_admpv_cod_tpocl  IN VARCHAR2,
                                              V_admpv_usu_mod    IN VARCHAR2,
                                              V_RESULTADO        OUT VARCHAR2,
                                              V_MSG_ERROR        OUT VARCHAR2)
                                              
       AS
       -- declaracion de variables
       V_CANT NUMBER;
       
       BEGIN
            SELECT COUNT(*) INTO V_CANT FROM ADMPT_NO_CLIENTE NC
                   WHERE NC.ADMPV_NUM_DOC = V_admpv_num_doc;
            
            IF (V_CANT = 0) THEN
               RAISE NO_DATA_FOUND;
            ELSE
               UPDATE ADMPT_NO_CLIENTE NC
                      SET NC.ADMPC_ESTADO = V_admpc_estado,
                          NC.ADMPV_USU_MOD = V_admpv_usu_mod,
                          NC.ADMPD_FEC_MOD = SYSDATE
               WHERE NC.ADMPV_NUM_DOC = V_admpv_num_doc;
               
               IF SQL%FOUND THEN
                  V_RESULTADO := '0';
                  V_MSG_ERROR := 'EL ESTADO DEL CLIENTE SE ACTUALIZO CON EXITO';
               ELSE
                  V_RESULTADO := '1';
                  V_MSG_ERROR := 'EL ESTADO DEL CLIENTE NO SE PUDO ACTUALIZAR';
               END IF;
            END IF;
       EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 V_RESULTADO := '2';
                 V_MSG_ERROR := 'EL CODIGO DEL CLIENTE NO EXISTE';
            WHEN OTHERS THEN
                 V_RESULTADO := '-1';
                 V_MSG_ERROR := SQLCODE || ' : ' || SQLERRM;
                 
       END ADMPSU_ACT_ESTADO_NOCLIENTE;
       
       /****************************************************************
       * NOMBRE SP          :  ADMPSS_SALDO_NOCLI
       * PROPOSITO          :  DEVOLVER EL SALDO DEL NO CLIENTE Y MENSAJE DE ERROR
       * INPUT              :  V_admpv_tipo_doc   -  Tipo de documento
       *                       V_admpv_num_doc    -  Número de documento
       *                       V_admpv_cod_tpocl  -  Codigo de tipo de cliente
       * OUTPUT             :  V_SALDO            -  Saldo del no cliente
       *                       V_COD_ERROR        -  Devuelve el código de validación o error
       *                       V_MSG_ERROR        -  Devuelve el mensaje de validación o error
       * CREADO POR         :  BRANDON RAY GONZALES CHACCARA
       * FEC CREACION       :  02/06/2016
       * FEC ACTUALIZACION  :
       ****************************************************************/
       PROCEDURE ADMPSS_SALDO_NOCLI (V_admpv_tipo_doc   IN  VARCHAR2,
                                     V_admpv_num_doc    IN  VARCHAR2,
                                     V_admpv_cod_tpocl  IN  VARCHAR2,
                                     V_SALDO            OUT NUMBER,
                                     V_COD_ERROR        OUT NUMBER,
                                     V_MSG_ERROR        OUT VARCHAR2)
       
       AS
       -- Declaracion de variables
       V_CANT NUMBER;
       V_COD_CLI VARCHAR2(40) := CONCAT(CONCAT(CONCAT(CONCAT(V_admpv_tipo_doc,'.'),V_admpv_num_doc),'.'),V_admpv_cod_tpocl);
       V_SALDO_AUX NUMBER;
       
       BEGIN
              SELECT COUNT(*) INTO V_CANT FROM ADMPT_NO_CLIENTE;
              
              IF (V_CANT = 0) THEN
                 RAISE NO_DATA_FOUND;
              ELSE
                 SELECT CA.ADMPN_SALDO_CC INTO V_SALDO_AUX
                        FROM ADMPT_SALDOS_CLIENTE_ALL CA
                        INNER JOIN ADMPT_CLIENTECONVENIO CC
                        ON CA.ADMPN_COD_CLI_CONV = CC.ADMPV_COD_CLI_CONV
                        INNER JOIN ADMPT_NO_CLIENTE NC
                        ON CC.ADMPV_COD_CLI = NC.ADMPV_COD_CLI
                           WHERE NC.ADMPV_COD_CLI = V_COD_CLI;
                           
                 V_SALDO := V_SALDO_AUX;
                 
                 IF SQL%FOUND THEN
                    V_COD_ERROR := '0';
                    V_MSG_ERROR := 'SE OBTUVO EL SALDO CON EXITO';
                 ELSE
                    V_COD_ERROR := '1';
                    V_MSG_ERROR := 'NO SE PUDO OBTENER EL SALDO';
                 END IF;
              END IF;
     
       EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   V_COD_ERROR := '2';
                   V_MSG_ERROR := 'EL CLIENTE NO EXISTE';
              WHEN OTHERS THEN
                   V_COD_ERROR := '-1';
                   V_MSG_ERROR := SQLCODE || ' : ' || SQLERRM;   
                                            
       END ADMPSS_SALDO_NOCLI;
       
       /****************************************************************
       * NOMBRE SP          :  ADMPSS_CONS_SALDOPTOS_NOCLI
       * PROPOSITO          :  OBTENER EL RESULTADO DE LA CONSULTA DE PUNTOS DE NO CLIENTES
       * INPUT              :  V_admpv_tipo_doc   -  Tipo de documento
       *                       V_admpv_num_doc    -  Número de documento
       *                       V_admpv_cod_tpocl  -  Codigo de tipo de cliente
       * OUTPUT             :  V_SALDO_PUNTOS     -  Saldo del no cliente
       *                       P_CURSOR           -  Cursor que devuelve los datos del cliente, cliente convenio
                                                     cliente producto, tipo de premio y tipo de premio por cliente
       *                       V_RESULTADO        -  Devuelve el código de validación o error
       *                       V_MSG_ERROR        -  Devuelve el mensaje de validación o error
       * CREADO POR         :  BRANDON RAY GONZALES CHACCARA
       * FEC CREACION       :  03/06/2016
       * FEC ACTUALIZACION  :
       ****************************************************************/
       PROCEDURE ADMPSS_CONS_SALDOPTOS_NOCLI (V_admpv_tipo_doc   IN  VARCHAR2,
                                              V_admpv_num_doc    IN  VARCHAR2,
                                              V_admpv_cod_tpocl  IN  VARCHAR2,
                                              V_SALDO_PUNTOS     OUT NUMBER,
                                              P_CURSOR           OUT CURSOR_SALIDA,
                                              V_RESULTADO        OUT VARCHAR2,
                                              V_MSG_ERROR        OUT VARCHAR2)
                                              
       AS
       -- declaracion de variables
       V_CANT NUMBER;
       V_COD_CLI VARCHAR2(40) := CONCAT(CONCAT(CONCAT(CONCAT(V_admpv_tipo_doc,'.'),V_admpv_num_doc),'.'),V_admpv_cod_tpocl);
       V_CANT_AUX NUMBER;
       V_AUX_SALDO NUMBER;
       V_AUX_COD_ERROR NUMBER;
       V_AUX_MSG_ERROR VARCHAR2(100);
       
       BEGIN
             SELECT COUNT(*) INTO V_CANT FROM ADMPT_NO_CLIENTE NC
                    WHERE NC.ADMPV_NUM_DOC = V_admpv_num_doc;
             
             IF (V_CANT = 0) THEN
                RAISE NO_DATA_FOUND;
             ELSE
                SELECT COUNT(*) INTO V_CANT_AUX FROM ADMPT_PREMIO P
                      INNER JOIN ADMPT_TIPO_PREMIO TP
                           ON P.ADMPV_COD_TPOPR = TP.ADMPV_COD_TPOPR
                      INNER JOIN ADMPT_TIPO_PREMCLIE TPC
                           ON TP.ADMPV_COD_TPOPR = TPC.ADMPV_COD_TPOPR
                      INNER JOIN ADMPT_TIPO_CLIENTE TC
                           ON TPC.ADMPV_COD_TPOCL = TC.ADMPV_COD_TPOCL
                      INNER JOIN ADMPT_NO_CLIENTE NC
                                 ON TC.ADMPV_COD_TPOCL = NC.ADMPV_COD_TPOCL
                      WHERE NC.ADMPV_NUM_DOC = V_admpv_num_doc;
                
                IF SQL%FOUND THEN
                   OPEN P_CURSOR FOR
                     SELECT P.ADMPV_ID_PROCLA, P.ADMPV_DESC,
                            P.ADMPV_CAMPANA, P.ADMPN_PUNTOS,
                            P.ADMPN_PAGO, TP.ADMPV_DESC,
                            P.ADMPN_COD_SERVC, P.ADMPN_MNT_RECAR,
                            P.ADMPV_COD_PAQDAT, TP.ADMPN_ORDEN,
                            P.ADMPV_COD_SERVTV, P.ADMPV_COD_TPOPR
                      FROM ADMPT_PREMIO P
                           INNER JOIN ADMPT_TIPO_PREMIO TP
                                 ON P.ADMPV_COD_TPOPR = TP.ADMPV_COD_TPOPR
                           INNER JOIN ADMPT_TIPO_PREMCLIE TPC
                                 ON TP.ADMPV_COD_TPOPR = TPC.ADMPV_COD_TPOPR
                           INNER JOIN ADMPT_TIPO_CLIENTE TC
                                 ON TPC.ADMPV_COD_TPOCL = TC.ADMPV_COD_TPOCL
                           INNER JOIN ADMPT_NO_CLIENTE NC
                                 ON TC.ADMPV_COD_TPOCL = NC.ADMPV_COD_TPOCL
                      WHERE NC.ADMPV_NUM_DOC = V_admpv_num_doc;
                
                   ADMPSS_SALDO_NOCLI(V_admpv_tipo_doc, V_admpv_num_doc, V_admpv_cod_tpocl, V_AUX_SALDO, V_AUX_COD_ERROR, V_AUX_MSG_ERROR);
                   V_SALDO_PUNTOS := V_AUX_SALDO;
                
                   V_RESULTADO := '0';
                   V_MSG_ERROR := 'SE OBTUVIERON LOS PUNTOS CON EXITO';
                ELSE
                   OPEN P_CURSOR FOR
                     SELECT P.ADMPV_ID_PROCLA, P.ADMPV_DESC,
                            P.ADMPV_CAMPANA, P.ADMPN_PUNTOS,
                            P.ADMPN_PAGO, TP.ADMPV_DESC,
                            P.ADMPN_COD_SERVC, P.ADMPN_MNT_RECAR,
                            P.ADMPV_COD_PAQDAT, TP.ADMPN_ORDEN,
                            P.ADMPV_COD_SERVTV, P.ADMPV_COD_TPOPR
                      FROM ADMPT_PREMIO P
                           INNER JOIN ADMPT_TIPO_PREMIO TP
                                 ON P.ADMPV_COD_TPOPR = TP.ADMPV_COD_TPOPR
                           INNER JOIN ADMPT_TIPO_PREMCLIE TPC
                                 ON TP.ADMPV_COD_TPOPR = TPC.ADMPV_COD_TPOPR
                           INNER JOIN ADMPT_TIPO_CLIENTE TC
                                 ON TPC.ADMPV_COD_TPOCL = TC.ADMPV_COD_TPOCL
                           INNER JOIN ADMPT_NO_CLIENTE NC
                                 ON TC.ADMPV_COD_TPOCL = NC.ADMPV_COD_TPOCL
                      WHERE NC.ADMPV_NUM_DOC = V_admpv_num_doc;
                
                   V_RESULTADO := '1';
                   V_MSG_ERROR := 'NO SE OBTUVIERON LOS PUNTOS';
                END IF;  
             END IF;
       EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  OPEN P_CURSOR FOR
                     SELECT P.ADMPV_ID_PROCLA, P.ADMPV_DESC,
                            P.ADMPV_CAMPANA, P.ADMPN_PUNTOS,
                            P.ADMPN_PAGO, TP.ADMPV_DESC,
                            P.ADMPN_COD_SERVC, P.ADMPN_MNT_RECAR,
                            P.ADMPV_COD_PAQDAT, TP.ADMPN_ORDEN,
                            P.ADMPV_COD_SERVTV, P.ADMPV_COD_TPOPR
                      FROM ADMPT_PREMIO P
                           INNER JOIN ADMPT_TIPO_PREMIO TP
                                 ON P.ADMPV_COD_TPOPR = TP.ADMPV_COD_TPOPR
                           INNER JOIN ADMPT_TIPO_PREMCLIE TPC
                                 ON TP.ADMPV_COD_TPOPR = TPC.ADMPV_COD_TPOPR
                           INNER JOIN ADMPT_TIPO_CLIENTE TC
                                 ON TPC.ADMPV_COD_TPOCL = TC.ADMPV_COD_TPOCL
                           INNER JOIN ADMPT_NO_CLIENTE NC
                                 ON TC.ADMPV_COD_TPOCL = NC.ADMPV_COD_TPOCL
                      WHERE NC.ADMPV_NUM_DOC = V_admpv_num_doc;
                      
                  V_RESULTADO := '2';
                  V_MSG_ERROR := 'EL CLIENTE NO EXISTE';
             WHEN OTHERS THEN
                  OPEN P_CURSOR FOR
                     SELECT P.ADMPV_ID_PROCLA, P.ADMPV_DESC,
                            P.ADMPV_CAMPANA, P.ADMPN_PUNTOS,
                            P.ADMPN_PAGO, TP.ADMPV_DESC,
                            P.ADMPN_COD_SERVC, P.ADMPN_MNT_RECAR,
                            P.ADMPV_COD_PAQDAT, TP.ADMPN_ORDEN,
                            P.ADMPV_COD_SERVTV, P.ADMPV_COD_TPOPR
                      FROM ADMPT_PREMIO P
                           INNER JOIN ADMPT_TIPO_PREMIO TP
                                 ON P.ADMPV_COD_TPOPR = TP.ADMPV_COD_TPOPR
                           INNER JOIN ADMPT_TIPO_PREMCLIE TPC
                                 ON TP.ADMPV_COD_TPOPR = TPC.ADMPV_COD_TPOPR
                           INNER JOIN ADMPT_TIPO_CLIENTE TC
                                 ON TPC.ADMPV_COD_TPOCL = TC.ADMPV_COD_TPOCL
                           INNER JOIN ADMPT_NO_CLIENTE NC
                                 ON TC.ADMPV_COD_TPOCL = NC.ADMPV_COD_TPOCL
                      WHERE NC.ADMPV_NUM_DOC = V_admpv_num_doc;
                      
                  V_RESULTADO := '-1';
                  V_MSG_ERROR := SQLCODE || ' : ' || SQLERRM;
             
       END ADMPSS_CONS_SALDOPTOS_NOCLI;
 
end PKG_TRANSACCION_NOCLIENTE;
/
