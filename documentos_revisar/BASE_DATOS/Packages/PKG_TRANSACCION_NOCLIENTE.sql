create or replace package PCLUB.PKG_TRANSACCION_NOCLIENTE is
       TYPE CURSOR_SALIDA IS REF CURSOR;

       procedure ADMPSS_VALIDA_NOCLIENTE (V_admpv_tipo_doc  in  varchar2,
                                          V_admpv_num_doc   in  varchar2,
                                          V_RESULTADO       out number,
                                          V_MSG_ERROR       out varchar2);

       procedure ADMPSS_CONSULTA_NOCLIENTE (V_admpv_tipo_doc  in varchar2,
                                            V_admpv_num_doc   in varchar2,
                                            P_CURSOR          out CURSOR_SALIDA,
                                            V_RESULTADO       out varchar2,
                                            V_MSG_ERROR       out varchar2);

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
                                            V_MSG_ERROR          OUT VARCHAR2);

       procedure ADMPSU_ACTUALIZA_NOCLIENTE (V_admpv_cod_cli      in  varchar2,
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
                                             V_MSG_ERROR          out varchar2);
                                             
       procedure ADMPSU_ACT_ESTADO_NOCLIENTE (V_admpv_cod_cli    IN  VARCHAR2,
                                              V_admpv_tipo_doc   IN  VARCHAR2,
                                              V_admpv_num_doc    IN  VARCHAR2,
                                              V_admpv_nom_cli    IN  VARCHAR2,
                                              V_admpv_ape_cli    IN  VARCHAR2,
                                              V_admpc_estado     IN  CHAR,
                                              V_admpv_cod_tpocl  IN  VARCHAR2,
                                              V_admpv_usu_mod    IN  VARCHAR2,
                                              V_RESULTADO        OUT VARCHAR2,
                                              V_MSG_ERROR        OUT VARCHAR2);
                                              
       procedure ADMPSS_SALDO_NOCLI (V_admpv_tipo_doc   IN  VARCHAR2,
                                     V_admpv_num_doc    IN  VARCHAR2,
                                     V_admpv_cod_tpocl  IN  VARCHAR2,
                                     V_SALDO            OUT NUMBER,
                                     V_COD_ERROR        OUT NUMBER,
                                     V_MSG_ERROR        OUT VARCHAR2);
                                              
       procedure ADMPSS_CONS_SALDOPTOS_NOCLI (V_admpv_tipo_doc   IN  VARCHAR2,
                                              V_admpv_num_doc    IN  VARCHAR2,
                                              V_admpv_cod_tpocl  IN  VARCHAR2,
                                              V_SALDO_PUNTOS     OUT NUMBER,
                                              P_CURSOR           OUT CURSOR_SALIDA,
                                              V_RESULTADO        OUT VARCHAR2,
                                              V_MSG_ERROR        OUT VARCHAR2);
       
end PKG_TRANSACCION_NOCLIENTE;
/
