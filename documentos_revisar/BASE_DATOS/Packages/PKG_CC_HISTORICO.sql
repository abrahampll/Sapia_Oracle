create or replace package PCLUB.PKG_CC_HISTORICO is

  -- Author  : FREDY
  -- Created : 10/03/2015 05:10:46 p.m.
  -- Purpose : Migracion de tabla Kardex a su respectivo historico

PROCEDURE ADMPSS_MIG_KARDEX(K_USRREG   IN VARCHAR2,
                            K_TAMPAG   IN NUMBER,
                            K_CANTDIAS IN NUMBER,
                            K_CODERROR  OUT NUMBER,
                            K_DESCERROR OUT VARCHAR2);

PROCEDURE EJECUTA_REGISTRO_MIGRACIONES(
                            K_USRREG     IN VARCHAR2,
                            K_TAMPAG       IN NUMBER,
                            K_CANTDIAS     IN NUMBER,
                            ESTADO         IN CHAR,
                            K_DURACION_EJECUCION OUT NUMBER,
                            K_CODERROR    OUT NUMBER,
                            K_DESCERROR   OUT VARCHAR2);


end PKG_CC_HISTORICO;
/