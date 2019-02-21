CREATE OR REPLACE PACKAGE fidelidad.CC_PKG_FID_CHURN IS
  TYPE CUR_SEC IS REF CURSOR;
  PROCEDURE CC_LIST_CONFIG_SMS(K_OPCION     IN VARCHAR2,
                               K_MSG_SMS    OUT VARCHAR2,
                               K_CUR_SALIDA OUT CUR_SEC);

  PROCEDURE CC_REP_LINEAS_PROGENV(K_PERIODO       IN VARCHAR2,
                                  K_NUMREGTOTPROM  OUT NUMBER,
                                  K_NUMREGTOTPROTFI OUT NUMBER,
                                  K_NUMREGPRE     OUT NUMBER,
                                  K_NUMREGTFI     OUT NUMBER,
                                  K_MSG_SMS       OUT VARCHAR2,
                                  K_TICKET        OUT VARCHAR2,
                                  CURLINEAS       OUT SYS_REFCURSOR,
                                  K_CODERROR      OUT NUMBER,
                                  K_DESCERROR     OUT VARCHAR2,
                                  K_FLAGOPERACION IN NUMBER);
  PROCEDURE CC_LINEAS_NOPROGENV(K_PERIODO   IN VARCHAR2,
                                K_NUMREG    OUT NUMBER,
                                K_CODERROR  OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2);

  PROCEDURE CC_DETLINEAS_NOPROGENV(K_PERIODO   IN VARCHAR2,
                                   K_CUR_LISTA OUT SYS_REFCURSOR,
                                   K_CODERROR  OUT NUMBER,
                                   K_DESCERROR OUT VARCHAR2);

  PROCEDURE CC_ACT_PROCESO;

  PROCEDURE CC_LIST_TICKETS(K_PERIODO     IN VARCHAR2,
                            K_CUR_TICKETS OUT SYS_REFCURSOR,
                            K_CODERROR    OUT NUMBER,
                            K_DESCERROR   OUT VARCHAR2);

  PROCEDURE CC_UPD_MOVCHURN(K_CODERROR  OUT NUMBER,
                            K_DESCERROR OUT VARCHAR2);

  PROCEDURE CC_LIST_DATOS(K_PERIODO   IN VARCHAR2,
                          K_CUR_LISTA OUT SYS_REFCURSOR,
                          K_CODERROR  OUT NUMBER,
                          K_DESCERROR OUT VARCHAR2);

   PROCEDURE CC_REP_LINEAS_NOPROGENV(K_PERIODO    IN VARCHAR2,
                                  K_NUMREGPRE     OUT NUMBER,
                                  K_NUMREGTFI     OUT NUMBER,
                                  CURLINEAS       OUT SYS_REFCURSOR,
                                  K_CODERROR      OUT NUMBER,
                                  K_DESCERROR     OUT VARCHAR2,
                                  K_FLAGOPERACION IN NUMBER);

END CC_PKG_FID_CHURN;
/