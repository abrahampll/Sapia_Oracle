create or replace package PCLUB.PKG_PORTALES_CLARO is

PROCEDURE ADMPSI_ESTADOCTACC(K_TIPODOC IN VARCHAR2,
                              K_NRODOC IN VARCHAR2,
                              K_FECHAINI IN DATE,
                              K_FECHAFIN IN DATE,
                              CURSORESTADOCTA OUT SYS_REFCURSOR,
                              K_CODERROR  OUT NUMBER,
                              K_DESCERROR OUT VARCHAR2);
end PKG_PORTALES_CLARO;
/