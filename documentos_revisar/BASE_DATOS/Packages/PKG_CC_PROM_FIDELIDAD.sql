create or replace package PCLUB.PKG_CC_PROM_FIDELIDAD is

  -- Author  : E75893
  -- Created : 24/08/2011 10:37:52 AM
  -- Purpose :

  -- Public type declarations
  TYPE K_REF_CURSOR IS REF CURSOR;

  -- Public function and procedure declarations
  PROCEDURE ADMPSS_CON_MULTIPLICA
  (
    P_TELEFONO    IN CC_WHITELIST_FIDELIDAD.WHITV_TELEFONO%TYPE,
    P_RETURN      OUT NUMBER
  );

  PROCEDURE ADMPSS_CON_NRO_FRECUENTE
  (
    P_TELEFONO    IN CC_WHITELIST_FIDELIDAD.WHITV_TELEFONO%TYPE,
    P_RETURN      OUT NUMBER
  );

  PROCEDURE ADMPSS_CON_SEGMENTO
  (
    P_TELEFONO    IN CC_WHITELIST_FIDELIDAD.WHITV_TELEFONO%TYPE,
    P_RETURN      OUT CC_WHITELIST_FIDELIDAD.WHITV_SEGMENTO%TYPE
  );

  PROCEDURE ADMPSU_DESAFILIACION
  (
    P_TELEFONO    IN CC_BLACKLIST_FIDELIDAD.BLCKV_TELEFONO%TYPE,
    P_RETURN      OUT NUMBER
  );

 PROCEDURE ADMPSS_CON_SEGM_BENEFICIO
  (
    P_SEGMENTO    IN CC_SEGMENTO_BENEFICIO.SEGMV_CODIGO%TYPE,
    P_CURSOR      OUT K_REF_CURSOR
  );


   PROCEDURE ADMPSS_CON_PROM_FIDELIDAD
  (
    P_TELEFONO    IN CC_WHITELIST_FIDELIDAD.WHITV_TELEFONO%TYPE,
    P_RETURN      OUT NUMBER
  );


  PROCEDURE ADMPSS_CON_BENEFICIO
  (
    P_TELEFONO    IN CC_WHITELIST_FIDELIDAD.WHITV_TELEFONO%TYPE,
    P_CURSOR      OUT K_REF_CURSOR
  );
  
  
  
  PROCEDURE ADMPSS_PLANES_PERMITIDOS
  (    
    P_CURSOR      OUT K_REF_CURSOR
  );
  
  
  PROCEDURE ADMPSS_DATOS_LINEA
  (    
    P_TELEFONO    IN CC_WHITELIST_FIDELIDAD.WHITV_TELEFONO%TYPE,
    P_TEL_ANT     IN VARCHAR2,
    P_BENE_ACT    OUT K_REF_CURSOR,
    P_PER_ACT     OUT K_REF_CURSOR,
    P_BENE_PRO    OUT K_REF_CURSOR,
    P_PER_PRO     OUT K_REF_CURSOR,
    P_DET_SEG     OUT K_REF_CURSOR,
    P_COD_ERROR   OUT NUMBER,
    P_MSG_ERROR   OUT VARCHAR2,
    P_PERIODO     OUT CC_WHITELIST_FIDELIDAD.WHITV_SEGMENTO%TYPE,
    P_VIG_FIN     OUT VARCHAR2
  );
  
end PKG_CC_PROM_FIDELIDAD; 
/
