CREATE OR REPLACE PACKAGE PCLUB.PKG_CC_PTOSTFI IS

PROCEDURE ADMPSI_PROMOCION_TFI(K_FECHA     IN DATE,
                               K_NOM_ARCH  IN VARCHAR2,
                               K_CODERROR  OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2,
                               K_NUMREGTOT OUT NUMBER,
                               K_NUMREGPRO OUT NUMBER,
                               K_NUMREGERR OUT NUMBER);

PROCEDURE ADMPSS_EPROMOCION_TFI(K_FECHA               IN  DATE,
                                K_CODERROR            OUT NUMBER,
                                K_DESCERROR           OUT VARCHAR2,
                                CURSOR_EPROMOCION_TFI OUT SYS_REFCURSOR);


PROCEDURE ADMPSI_REGISTRO_CLIENTETFI_CC (K_CODTPO_CLI IN VARCHAR2,K_TIPO_DOC IN VARCHAR2, 
                                         K_NRO_DOC IN VARCHAR2, K_USUARIO IN VARCHAR2,
                                         K_NUM_LINEA OUT VARCHAR2, K_CODERROR OUT NUMBER, 
                                         K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSI_REGULARIZACION_TFI(K_FECHA     IN DATE,
                                    K_NOM_ARCH  IN VARCHAR2,
                                    K_CODERROR  OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2,
                                    K_NUMREGTOT OUT NUMBER,
                                    K_NUMREGPRO OUT NUMBER,
                                    K_NUMREGERR OUT NUMBER);

PROCEDURE ADMPSS_EREGULARIZA_TFI( K_FECHA              IN  DATE,
                                 K_CODERROR            OUT NUMBER,
                                 K_DESCERROR           OUT VARCHAR2,
                                 CURSOR_EREGULARIZA_TFI OUT SYS_REFCURSOR);

PROCEDURE ADMPSI_ALTACLI_TFI(K_FECHA     IN DATE,
                             K_CODERROR  OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2,
                             K_NUMREGTOT OUT NUMBER,
                             K_NUMREGPRO OUT NUMBER,
                             K_NUMREGERR OUT NUMBER);

PROCEDURE ADMPSI_REGLINEAS(K_FECHA     IN DATE,
                               K_TIPCLI    IN VARCHAR2,
                               K_CODERROR  OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2,
                               K_NUMREGTOT OUT NUMBER,
                               K_NUMREGPRO OUT NUMBER,
                               K_NUMREGERR OUT NUMBER);

PROCEDURE ADMPSI_EALTACLI(K_FECHAPROC  IN DATE,
                            K_TIPCLI     IN VARCHAR2,
                            CURSORALTCLI out SYS_REFCURSOR);

PROCEDURE ADMPSI_TFICMBTIT(K_FEC_PRO   IN DATE,
                           K_CODERROR  OUT NUMBER,
                           K_DESCERROR OUT VARCHAR2,
                           K_TOT_REG   OUT NUMBER,
                           K_TOT_PRO   OUT NUMBER,
                           K_TOT_ERR   OUT NUMBER);

PROCEDURE ADMPSI_ETFICMBTIT(K_FECHAPROC IN DATE,cursorCambTitu out SYS_REFCURSOR);

PROCEDURE CamTituCC(K_FECHA IN DATE, CURSORCamTituCC out SYS_REFCURSOR);

procedure ADMPSI_TFIVENCPTO(K_CODERROR  OUT NUMBER,
                            K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSI_RECARGA(K_FECHA IN DATE,
                         K_NOMBARCH IN VARCHAR2,
                         K_CODERROR OUT NUMBER,
                         K_DESCERROR OUT VARCHAR2,
                         K_NUMREGTOT OUT NUMBER,
                         K_NUMREGPRO OUT NUMBER,
                         K_NUMREGERR OUT NUMBER);

PROCEDURE ADMPSS_ERECARGA(K_FECHA IN DATE,
                          K_CODERROR OUT NUMBER,
                          K_DESCERROR OUT VARCHAR2,
                          K_CUR_ERRORES OUT SYS_REFCURSOR);

PROCEDURE ADMPSI_ANIVERSARIO(K_FECHA IN DATE,
                            K_NOMBARCH IN VARCHAR2,
                             K_CODERROR OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2,
                             K_NUMREGTOT OUT NUMBER,
                             K_NUMREGPRO OUT NUMBER,
                             K_NUMREGERR OUT NUMBER);

PROCEDURE ADMPSS_EANIVERSARIO(K_FECHA IN DATE,
                              K_CODERROR OUT NUMBER,
                              K_DESCERROR OUT VARCHAR2,
                              K_CUR_ERRORES OUT SYS_REFCURSOR);

PROCEDURE ADMPSI_NO_RECARGA(K_FECHA IN DATE,
                            K_NOMBARCH IN VARCHAR2,
                            K_CODERROR OUT NUMBER,
                            K_DESCERROR OUT VARCHAR2,
                            K_NUMREGTOT OUT NUMBER,
                            K_NUMREGPRO OUT NUMBER,
                            K_NUMREGERR OUT NUMBER);

PROCEDURE ADMPSS_ENO_RECARGA(K_FECHA IN DATE,
                             K_CODERROR OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2,
                             K_CUR_ERRORES OUT SYS_REFCURSOR);

PROCEDURE ADMPSI_BAJACLIENTE(K_FECHA IN DATE,
                             K_NOMBARCH IN VARCHAR2,
                             K_CODERROR OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2,
                             K_NUMREGTOT OUT NUMBER,
                             K_NUMREGPRO OUT NUMBER,
                             K_NUMREGERR OUT NUMBER);

PROCEDURE ADMPSS_EBAJACLIENTE(K_FECHA IN DATE,
                              K_CODERROR OUT NUMBER,
                              K_DESCERROR OUT VARCHAR2,
                              K_CUR_ERRORES OUT SYS_REFCURSOR);


END PKG_CC_PTOSTFI;
/