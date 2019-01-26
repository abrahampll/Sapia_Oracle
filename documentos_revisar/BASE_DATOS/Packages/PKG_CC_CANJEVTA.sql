CREATE OR REPLACE PACKAGE PCLUB.PKG_CC_CANJEVTA IS
  TYPE CUR_SEC IS REF CURSOR;

  PROCEDURE ADMPS_CONSALDO(K_TIPO_DOC     IN VARCHAR2,
                           K_NUM_DOC      IN VARCHAR2,
                           K_LINEA        IN VARCHAR2,
                           K_CODSEGMENTO  OUT VARCHAR2,--NUEVO
                           K_SALDO_TOTAL  OUT NUMBER,
                           K_CUR_SALDOS   OUT SYS_REFCURSOR,
                           K_NUM_FACTOR   OUT NUMBER,
                           K_CUR_CAMPANHA OUT SYS_REFCURSOR,
                           K_CODERROR     OUT NUMBER,
                           K_DESCERROR    OUT VARCHAR2);

  PROCEDURE ADMPI_CANJEVTA(K_TIPO_DOC    IN VARCHAR2,
                           K_NUM_DOC     IN VARCHAR2,
                           K_PUNTOVENTA  IN VARCHAR2,
                           K_COD_APLI    IN VARCHAR2,
                           K_COD_ASESOR  IN VARCHAR2,
                           K_NOM_ASESOR  IN VARCHAR2,
                           K_IDVENTA     IN VARCHAR2, --Canje:ADMPV_VENTAID
                           K_IDPROCESO   IN VARCHAR2, --Canje:ADMPV_TPO_PROC --> AP(Vta Alta Postpago),AE (Vta Alta Prepago),VR(Vta Renovación)
                           K_PTOS_VENTA  IN NUMBER,
                           K_SOLESVTA    IN NUMBER,
                           K_IDCAMPANA   IN VARCHAR2,
                           K_USUARIO     IN VARCHAR2,
                           K_LINEA       IN VARCHAR2,
                           K_CODSEGMENTO IN VARCHAR2, --NUEVO
                           K_CODERROR    OUT NUMBER,
                           K_DESCERROR   OUT VARCHAR2,
                           K_LISTA_CANJE OUT SYS_REFCURSOR);

  PROCEDURE ADMPS_ESCLIENTE(K_TIPO_DOC  IN VARCHAR2,
                            K_NUM_DOC   IN VARCHAR2,
                            K_CODERROR  OUT NUMBER,
                            K_DESCERROR OUT VARCHAR2);

  PROCEDURE ADMPS_VALIDASALDOKDXMOVIL(K_TIPO_DOC IN VARCHAR2,
                                      K_NUM_DOC  IN VARCHAR2,
                                      K_CODERROR OUT NUMBER);

  PROCEDURE ADMPS_VALIDASALDOKDXFIJA(K_TIPO_DOC IN VARCHAR2,
                                     K_NUM_DOC  IN VARCHAR2,
                                     K_CODERROR OUT NUMBER);

  PROCEDURE ADMPS_OBTNUMLINEA(K_COD_TPOCL  IN VARCHAR2,
                              K_COD_CLI    IN VARCHAR2,
                              K_NUMLINEACJ OUT VARCHAR2,
                              K_CODERROR   OUT NUMBER,
                              K_DESCERROR  OUT VARCHAR2);

  PROCEDURE ADMPS_CONSALDO_CANJE(K_TIPO_DOC     IN VARCHAR2,
                                 K_NUM_DOC      IN VARCHAR2,
                                 K_LINEA        IN VARCHAR2, 
                                 K_PROCESO      IN VARCHAR2,
                                 K_SALDO_TOTAL  OUT NUMBER,
                                 K_CUR_SALDOS   OUT SYS_REFCURSOR,
                                 K_NUM_FACTOR   OUT NUMBER,
                                 K_CUR_CAMPANHA OUT SYS_REFCURSOR,
                                 K_CODERROR     OUT NUMBER,
                                 K_DESCERROR    OUT VARCHAR2);

  PROCEDURE ADMPSI_DEVOLUC_CANJEVTA(K_ID_SOLICITUD IN VARCHAR2,
                                    K_PUNTOVENTA   IN VARCHAR2,
                                    K_VENTAID      IN VARCHAR2,
                                    K_PROCESO      IN VARCHAR2,
                                    K_TIPO_DOC     IN VARCHAR2,
                                    K_NUM_DOC      IN VARCHAR2,
                                    K_LINEA        IN VARCHAR2,
                                    K_USUARIO      IN VARCHAR2,
                                    K_PUNTOS       IN NUMBER, --PROY 26366 FASE 2
                                    K_CODERROR     OUT NUMBER,
                                    K_DESCERROR    OUT VARCHAR2,
                                    K_SALDO        OUT NUMBER);
END PKG_CC_CANJEVTA;
/