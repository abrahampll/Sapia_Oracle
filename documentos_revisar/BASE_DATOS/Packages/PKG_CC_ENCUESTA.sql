CREATE OR REPLACE PACKAGE PCLUB.PKG_CC_ENCUESTA IS
  TYPE CUR_SEC IS REF CURSOR;
  
 PROCEDURE ADMPSS_REGMOVENCUESTA(K_TELEFONO IN VARCHAR2, 
                                 K_USUARIO IN VARCHAR2,
                                 K_ID_CANJE IN NUMBER, 
                                 K_TIPO_DOC IN VARCHAR2,
                                 K_NUM_DOC IN VARCHAR2,
                                 K_COD_CLI VARCHAR2,
                                 K_CODERROR OUT NUMBER, 
                                 K_DESCERROR OUT VARCHAR2);

 PROCEDURE ADMPSS_OBTENCSERVICIO(K_USER IN VARCHAR2,
                                 K_CUR_LISTA OUT SYS_REFCURSOR,
                                 K_CODERROR OUT NUMBER,
                                 K_DESCERROR OUT VARCHAR2);

 PROCEDURE ADMPSS_OBTENCEQUIPO(K_USER IN VARCHAR2,
                               K_CUR_LISTA OUT SYS_REFCURSOR, 
                               K_CODERROR OUT NUMBER, 
                               K_DESCERROR OUT VARCHAR2); 

 PROCEDURE ADMPSS_PROCESARESP(K_TELEFONO IN VARCHAR2, 
                              K_OPCION IN VARCHAR2, 
                              K_USUARIO IN VARCHAR2, 
                              K_DES_PREGUNTA OUT VARCHAR2,
                              K_CODERROR OUT NUMBER, 
                              K_DESCERROR OUT VARCHAR2); 
 
 PROCEDURE ADMPSS_CANCELENCUESTA(K_USUARIO IN VARCHAR2, 
                                 K_CODERROR OUT NUMBER, 
                                 K_DESCERROR OUT VARCHAR2);
 
 PROCEDURE ADMPSS_VALIDA_GENERA_ENCUESTA(K_TIPO_DOC VARCHAR2,
                                         K_NUM_DOC VARCHAR2,
                                         K_CODERROR OUT NUMBER,
                                         K_DESCERROR OUT VARCHAR2);

 PROCEDURE ADMPSS_CLIE_BLACK_LIST(K_TELEFONO IN VARCHAR2,
                                  K_CODERROR OUT NUMBER,
                                  K_DESCERROR OUT VARCHAR2);

 FUNCTION  ADMPSS_GETFECHA_LIM(K_FECHA IN DATE, K_TIPO IN SMALLINT ) RETURN DATE;

 PROCEDURE ADMPSI_REGENCUESTA(K_NOM_ENCU IN VARCHAR2,
                              K_FECINI IN VARCHAR2,
                              K_FECFIN IN VARCHAR2,
                              K_ESTADO IN CHAR,
                              K_USUARIO IN VARCHAR2,
                              K_ID_ENCU OUT NUMBER,
                              K_CODERROR OUT NUMBER,
                              K_DESCERROR OUT VARCHAR2);

  PROCEDURE ADMPSU_UPDENCUESTA(K_ID_ENCU IN NUMBER,
                               K_NOM_ENCU IN VARCHAR2,
                               K_FECINI IN VARCHAR2,
                               K_FECFIN IN VARCHAR2,
                               K_ESTADO IN CHAR,
                               K_USUARIO IN VARCHAR2,
                               K_CODERROR OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2);

  PROCEDURE ADMPSS_LISENCUESTA(K_NOMBRE IN VARCHAR2,
                               K_ESTADO IN VARCHAR2,
                               K_CUR_ENCUESTA OUT SYS_REFCURSOR,
                               K_CODERROR OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2);
 
  PROCEDURE ADMPSI_REGPREGUNTA(K_ID_ENCU IN NUMBER, 
                               K_DES_PREGUNTA IN VARCHAR2, 
                               K_NRO_ORDEN IN NUMBER, 
                               K_ESTADO IN CHAR,
                               K_USUARIO IN VARCHAR2, 
                               K_ID_PREG OUT NUMBER, 
                               K_CODERROR OUT NUMBER, 
                               K_DESCERROR OUT VARCHAR2);
 
  PROCEDURE ADMPSU_UPDPREGUNTA(K_ID_PREG IN NUMBER,
                               K_ID_ENCU IN NUMBER, 
                               K_DES_PREGUNTA IN VARCHAR2,
                               K_NRO_ORDEN IN NUMBER, 
                               K_ESTADO IN CHAR,
                               K_USUARIO IN VARCHAR2,
                               K_CODERROR OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2); 

  PROCEDURE ADMPSS_LISPREGUNTA(K_ID_ENCU IN NUMBER,
                               K_ESTADO IN VARCHAR2,                              
                               K_CUR_PREGUNTA OUT SYS_REFCURSOR,
                               K_CODERROR OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2);

  PROCEDURE ADMPSI_REGRESPUESTA(K_ID_PREG IN NUMBER, 
                                K_DES_RESPUESTA IN VARCHAR2, 
                                K_DES_OPCION IN VARCHAR2, 
                                K_ESTADO IN CHAR, 
                                K_USUARIO IN VARCHAR2, 
                                K_ID_RESP OUT NUMBER, 
                                K_CODERROR OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2);

  PROCEDURE ADMPSU_UPDRESPUESTA(K_ID_RESP IN NUMBER,
                                K_ID_PREG IN NUMBER, 
                                K_DES_RESPUESTA IN VARCHAR2, 
                                K_DES_OPCION IN VARCHAR2, 
                                K_ESTADO IN CHAR, 
                                K_USUARIO IN VARCHAR2, 
                                K_CODERROR OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2);

  PROCEDURE ADMPSS_LISRESPUESTA(K_ID_PREG IN NUMBER,
                                K_ESTADO IN VARCHAR2,                              
                                K_CUR_RESPUESTA OUT SYS_REFCURSOR,
                                K_CODERROR OUT NUMBER,
                                K_DESCERROR OUT VARCHAR2);

  FUNCTION F_FECHACADENA(K_FECHA IN DATE) RETURN VARCHAR2;
  
  FUNCTION F_VALTAMANOPREGRESP(K_IDPREG NUMBER, 
                               K_IDRESP NUMBER, 
                               K_DESC IN VARCHAR2,
                               K_TABLA IN CHAR) RETURN VARCHAR2;
                               
  FUNCTION F_GETTAMANOPREGRESP(K_IDPREG NUMBER) RETURN NUMBER;
  
END PKG_CC_ENCUESTA;
/