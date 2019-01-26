CREATE OR REPLACE PACKAGE PCLUB.PKG_CC_TRANSACCIONFIJA IS
  TYPE TAB_ARRAY IS TABLE OF VARCHAR2(50)    INDEX BY BINARY_INTEGER;

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
                            K_LISTA_CANJE      OUT SYS_REFCURSOR) ;

PROCEDURE ADMPSI_ES_CLIENTE(  K_TIPO_DOC    IN VARCHAR2,
                              K_NUM_DOC     IN VARCHAR2,
                              K_TIP_CLI     IN VARCHAR2,
                              K_SALDO       OUT NUMBER,
                              K_CODERROR    OUT NUMBER,
                              K_DESCERROR   OUT VARCHAR2);


PROCEDURE ADMPSI_DESC_PUNTOS( K_ID_CANJE    IN NUMBER,
                               K_SEC         IN NUMBER,
                               K_PUNTOS      IN NUMBER,
                               K_COD_CLIENTE IN VARCHAR2,
                               K_TIPO_DOC    IN VARCHAR2,
                               K_NUM_DOC     IN VARCHAR2,
                               K_TIP_CLI     IN VARCHAR2,
                               K_USUARIO     IN VARCHAR2,
                               K_CODERROR    OUT NUMBER,
                               K_DESCERROR   OUT VARCHAR2);
----------------------------------ACTUALIZA CANJE -----------------------------
PROCEDURE ADMPSS_ACTCANJE(K_IDCANJE IN VARCHAR2,
                          K_LISTA_IDPROCLA IN VARCHAR2,
                          K_LISTA_CODTXPAQ IN VARCHAR2,
                          K_LISTA_SOTS IN VARCHAR2,
                          K_MSJSMS IN VARCHAR2,
                          K_ID_INTER IN VARCHAR2,
                          K_EXITO OUT NUMBER,
                          K_CODERROR OUT NUMBER,
                          K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSS_ELIMINARCANJE(K_IDCANJE IN VARCHAR2,
                               K_EXITO OUT NUMBER,
                               K_CODERROR OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSS_PRODUCTOSCANJE(K_TIPDOC IN VARCHAR2,
                                K_NUMDOC IN VARCHAR2,
                                K_TIPCLIE IN VARCHAR2,
                                K_FECINI IN VARCHAR2,
                                K_FECFIN IN VARCHAR2,
                                K_CODERROR OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2,
                                CUR_CANJE OUT SYS_REFCURSOR);

PROCEDURE ADMPSS_CONSTANCIACANJE(K_IDCANJE IN NUMBER,
                                 K_CTO_ATEN OUT VARCHAR2,
                                 K_TIP_DOC OUT VARCHAR2,
                                 K_NUM_DOC OUT VARCHAR2,
                                 K_FEC OUT VARCHAR2,
                                 K_CSO_INT OUT VARCHAR2,
                                 K_NOTAS OUT VARCHAR2,
                                 K_NOMBRE OUT VARCHAR2,
                                 K_TIPCLIE OUT VARCHAR2,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2,
                                 CUR_CANJE OUT SYS_REFCURSOR);


  PROCEDURE ADMPSS_CONSALDO(K_TIPO_DOC        IN VARCHAR2,
                            K_NUM_DOC         IN VARCHAR2,
                            K_TIP_CLI         IN VARCHAR2,
                            K_TIP_LINEA       IN VARCHAR2,
                            K_CODERROR        OUT NUMBER,
                            K_DESCERROR       OUT VARCHAR2,
                            K_SALDO_PUNTOS    OUT NUMBER,
                            K_CUR_LISTA       OUT SYS_REFCURSOR);

  PROCEDURE ADMPSS_CONSALDO (P_TIPO_DOC          IN PCLUB.admpt_cliente.admpv_tipo_doc%type,
                            P_NUM_DOC            IN PCLUB.admpt_cliente.admpv_num_doc%type,
                            P_SALDO_PUNTOS    OUT NUMBER,
                            P_COD_RESPUESTA   OUT NUMBER,
                            P_MENSAJE_RESPUESTA  OUT VARCHAR2);

PROCEDURE ADMPSI_DSCTO_PUNTO(K_COD_CLIENTE IN VARCHAR2,
                             K_TIP_CLI IN VARCHAR2,
                             K_PUNTOS IN NUMBER,
                             K_CONCEPTOCC IN VARCHAR2,
                             V_CUENTADES IN VARCHAR2,
                             K_USUARIO IN VARCHAR2,
                             K_CODERROR OUT NUMBER,
                             K_MSJERROR OUT VARCHAR2) ;

PROCEDURE ADMPSS_TRANSPUNTOS(K_TIPDOC_ORI IN VARCHAR2,
                             K_NUMDOC_ORI IN VARCHAR2,
                             K_TIPCLIE_ORI IN VARCHAR2,
                             K_TIPCLIE_DES IN VARCHAR2,
                             K_LINEA_DES IN VARCHAR2,
                             K_PUNTOS IN NUMBER,
                             K_SALDO_CD OUT NUMBER,
                             K_USUARIO IN VARCHAR2,
                             K_CODERROR OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2) ;

PROCEDURE ADMPSI_VALIDARCLIENTE(K_TIPDOC IN VARCHAR2,
                                K_NUMDOC IN VARCHAR2,
                                K_TIPCLIE IN VARCHAR2,
                                K_COD_CLI OUT VARCHAR2,
                                K_MENSAJE OUT VARCHAR2,
                                K_CODERROR OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2);

  FUNCTION SPLITCAD(P_IN_STRING VARCHAR2, P_DELIM VARCHAR2) RETURN TAB_ARRAY;

  PROCEDURE ADMPSS_OBTENERLINEASCLIENTE( K_TIPO_DOC IN VARCHAR2,K_NUM_DOC IN VARCHAR2,K_TIPCLI IN VARCHAR2,K_CODERROR OUT NUMBER,
                                       K_MSJERROR OUT VARCHAR2,CURSORCLI  OUT SYS_REFCURSOR);

  PROCEDURE SP_VALIDAR_CANJE_PAQTV(  K_COD_CLIENTE IN VARCHAR2, K_CODPROD IN  VARCHAR2,
                                   K_CANTIDAD     OUT NUMBER,   K_CODERROR    OUT NUMBER,   K_DESCERROR   OUT VARCHAR2 );

  PROCEDURE ADMPSS_VALIDASALDOKDX_FIJA( K_TIPO_DOC IN VARCHAR2,
                                       K_NUM_DOC  IN VARCHAR2 ,
                                       K_TIP_CLI  IN VARCHAR2,
                                       K_CODERROR OUT NUMBER);

  PROCEDURE ADMPSS_DEVPUNTS_FIJA(K_PUNTOVENTA IN VARCHAR2,
                               K_USUARIO IN VARCHAR2,
                               K_LISTA_DEV IN LISTA_DEVOLUCION,
                               K_CODERROR OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2,
                               K_SALDO OUT NUMBER);
END PKG_CC_TRANSACCIONFIJA;
/