create or replace package PCLUB.PKG_CC_MANTENIMIENTO is
TYPE K_REF_CURSOR IS REF CURSOR;

PROCEDURE ADMPSI_OBTMENSAJE( K_PARAMETRO IN VARCHAR2,
                            K_VALOR OUT VARCHAR2,
                            K_RESPUESTA OUT NUMBER,
                            K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSS_LISTAR_TIPO_DOCUMENTOS(CUR_LISTA OUT K_REF_CURSOR);

PROCEDURE ADMPSS_LISTAR_TIPCLIE_XTRANSAC(K_TRANSACCION IN VARCHAR2,
                                         CUR_LISTA     OUT K_REF_CURSOR);

PROCEDURE ADMPSS_BUSCARCLIENTECC(K_TIPDOC    IN VARCHAR2,
                                 K_NUMDOC    IN VARCHAR2,
                                 K_TIPCLIE   IN VARCHAR2,
                                 K_CODERROR  OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2,
                                 CUR_LISTA   OUT SYS_REFCURSOR);

PROCEDURE ADMPSS_BUSCARCLIENTE(K_TIPDOC    IN VARCHAR2,
                               K_NUMDOC    IN VARCHAR2,
                               K_TIPCLIE   IN VARCHAR2,
                               K_CODERROR  OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2,
                               CUR_LISTA   OUT SYS_REFCURSOR);

PROCEDURE ADMPSS_LISTAR_TIPOS(K_GRUPO INTEGER,
                              CUR_LISTA OUT K_REF_CURSOR);

PROCEDURE ADMPSI_OBTPARAMETRO(K_PARAMETRO IN  VARCHAR2,
                              K_VALOR     OUT VARCHAR2,
                              K_CODERROR    OUT NUMBER,
                              K_DESCERROR   OUT VARCHAR2);

PROCEDURE ADMPSS_LISTAR_SEGMENTOS(CUR_LISTA OUT K_REF_CURSOR);

PROCEDURE ADMPSS_LISTAR_CUPONERAS(CUR_LISTA OUT K_REF_CURSOR);

PROCEDURE ADMPSS_LIST_SEGMENTOS_CC(K_CUR_SEG OUT SYS_REFCURSOR);

PROCEDURE ADMPSS_LIST_DSCTO_SEG_TCLIE(K_CODSEGMENTO IN VARCHAR2,
                                      K_CODTCLIE IN VARCHAR2,
                                      K_CODTPREMIO IN VARCHAR2,
                                      K_ESTADO IN CHAR,
                                      K_CUR_LISTA OUT SYS_REFCURSOR,
                                      K_CODERROR OUT NUMBER,
                                      K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSI_REG_DSCTO_SEGMENTO(K_COD_SEG IN VARCHAR2,
                                    K_COD_TCLIE IN VARCHAR2,
                                    K_COD_TPREMIO IN VARCHAR2,
                                    K_ESTADO IN CHAR,
                                    K_VALOR IN VARCHAR2,
                                    K_USU_REG IN VARCHAR2,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSU_MOD_DSCTO_SEGMENTO(K_COD_SEG IN VARCHAR2,
                                    K_COD_TCLIE IN VARCHAR2,
                                    K_COD_TPREMIO IN VARCHAR2,
                                    K_ESTADO IN CHAR,
                                    K_VALOR IN VARCHAR2,
                                    K_USU_MOD IN VARCHAR2,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSS_PREMIO(K_PREMIO IN VARCHAR2,
                        CUR_LISTA OUT SYS_REFCURSOR,
                        K_CODERROR OUT NUMBER,
                        K_DESCERROR OUT VARCHAR2);

PROCEDURE ADMPSS_PREMIOIVR(K_TIPO_DOC        IN VARCHAR2,
                           K_NUM_DOC         IN VARCHAR2,
                           K_TIP_CLI         IN VARCHAR2,
                           K_TIP_LINEA       IN VARCHAR2,
                           K_CODERROR        OUT NUMBER,
                           K_MSJERROR        OUT VARCHAR2,
                           K_SALDO_PUNTOS    OUT NUMBER,
                           K_CUR_LISTA       OUT SYS_REFCURSOR);
                           
PROCEDURE ADMPSS_MOVILPREMI(K_TIP_CLI         IN VARCHAR2,
							              K_SALDO_PUNTOS    IN NUMBER,
                            K_CODERROR        OUT NUMBER,
                            K_MSJERROR        OUT VARCHAR2,
                            K_CUR_LISTA       OUT SYS_REFCURSOR);
                            
PROCEDURE ADMPSS_FIJAPREMI(K_TIPO_DOC        IN VARCHAR2,
                           K_NUM_DOC         IN VARCHAR2,
                           K_TIP_CLI         IN VARCHAR2,
                           K_TIP_LINEA       IN VARCHAR2,
							             K_SALDO_PUNTOS    IN NUMBER,
                           K_CODERROR        OUT NUMBER,
                           K_DESCERROR       OUT VARCHAR2,
                           K_CUR_LISTA       OUT SYS_REFCURSOR);   

PROCEDURE ADMPSS_BUSCARCLIENTE_IVR(K_TIPDOC    IN VARCHAR2,
                                   K_NUMDOC    IN VARCHAR2,
                                   K_TIPCLIE   IN VARCHAR2,
                                   K_CODERROR  OUT NUMBER,
                                   K_DESCERROR OUT VARCHAR2,
                                   CUR_LISTA   OUT SYS_REFCURSOR,
                                   CUR_CONTRA   OUT SYS_REFCURSOR);

end PKG_CC_MANTENIMIENTO;
/
