CREATE OR REPLACE PACKAGE FIDELIDAD.PKG_FYR_UTILITARIO IS

-- Author  : Oscar Paucar
-- Created : 14/03/2013 11:35:28 AM
-- Purpose : Procedimientos y funciones generales

 TYPE TAB_ARRAY IS TABLE OF VARCHAR2(32767) INDEX BY BINARY_INTEGER;

 PROCEDURE SFYRSI_INSCONCEPTOS(K_DESC IN VARCHAR2,
                               K_ORDDESC IN CHAR,
                               K_ACTIVO IN CHAR,
                               K_ID_CONCGRUPO IN NUMBER,
                               K_USUARIO IN VARCHAR2,
                               K_ID OUT NUMBER,
                               K_CODERROR OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2);

 PROCEDURE SFYRSU_UPDCONCEPTOS(K_ID IN NUMBER,
                               K_DESC IN VARCHAR2,
                               K_ORDDESC IN CHAR,
                               K_ACTIVO IN CHAR,
                               K_ID_CONCGRUPO IN NUMBER,
                               K_USUARIO IN VARCHAR2,
                               K_CODERROR OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2);

 PROCEDURE SFYRSS_LISCONCEPTOS(K_ID IN NUMBER,
                               K_DESC IN VARCHAR2,
                               K_ACTIVO IN VARCHAR2,
                               K_CUR_CONCEPTOS OUT SYS_REFCURSOR,
                               K_CODERROR OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2);

 PROCEDURE SFYRSI_INSTIPOS(K_DESC IN VARCHAR2,
                           K_ABREV IN VARCHAR2,
                           K_VALOR IN VARCHAR2,
                           K_ORDEN NUMBER,
                           K_ACTIVO IN CHAR,
                           K_ID_CONCEPTOS NUMBER,
                           K_ID_TIPOGRUPO IN NUMBER,
                           K_USUARIO IN VARCHAR2,
                           K_ID OUT NUMBER,
                           K_CODERROR OUT NUMBER,
                           K_DESCERROR OUT VARCHAR2);

 PROCEDURE SFYRSU_UPDTIPOS(K_ID IN NUMBER,
                           K_DESC IN VARCHAR2,
                           K_VALOR IN VARCHAR2,
                           K_ABREV IN VARCHAR2,
                           K_ORDEN NUMBER,
                           K_ACTIVO IN CHAR,
                           K_ID_TIPOGRUPO IN NUMBER,
                           K_USUARIO IN VARCHAR2,
                           K_CODERROR OUT NUMBER,
                           K_DESCERROR OUT VARCHAR2);
                          
 PROCEDURE SFYRSS_LISTIPOS(K_DESC IN VARCHAR2,
                           K_ACTIVO IN VARCHAR2,
                           K_ID_CONCEPTOS IN NUMBER,
                           K_ID_TIPOSGRUPO IN NUMBER,
                           K_CUR_TIPOS OUT SYS_REFCURSOR,
                           K_CODERROR OUT NUMBER,
                           K_DESCERROR OUT VARCHAR2);
                          
 PROCEDURE SFYRSS_LISPARAMSIST(K_DESC IN VARCHAR2,
                               K_VALOR OUT VARCHAR2,
                               K_CODERROR OUT NUMBER,
                               K_DESCERROR OUT VARCHAR2);

 PROCEDURE SFYRSS_GETTIPOS(K_ID IN NUMBER,
                           K_DESC OUT VARCHAR2,
                           K_ABREV OUT VARCHAR2,
                           K_VALOR OUT VARCHAR2,
                           K_CODERROR OUT NUMBER,
                           K_DESCERROR OUT VARCHAR2);

 FUNCTION F_GETERRORES(K_ID IN NUMBER) RETURN VARCHAR2;
  
 FUNCTION F_GETFECHALIMINF(K_FECHA IN DATE) RETURN DATE;
 
 FUNCTION F_GETFECHALIMSUP(K_FECHA IN DATE) RETURN DATE; 

 FUNCTION F_GETFECHACADENA(K_FECHA IN DATE) RETURN VARCHAR2;
 
 FUNCTION F_GETFECHAHORACADENA(K_FECHA IN DATE) RETURN VARCHAR2;
  
 FUNCTION F_GETARRAYSPLIT(K_STRING VARCHAR2,
                          K_DELIM VARCHAR2) RETURN TAB_ARRAY;

 FUNCTION F_GETDIFERENCIADIAS(K_FECHAINI IN DATE,
                              K_FECHAFIN IN DATE) RETURN VARCHAR2;

END PKG_FYR_UTILITARIO;
/