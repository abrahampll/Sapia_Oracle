create or replace package PCLUB.PKG_CC_IMPLOYALTY is
       PROCEDURE ADMPSI_LOYCLIENTE(K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER);
       PROCEDURE ADMPSI_ELOYCLIENTE(CURSORLOYCLIENTE out SYS_REFCURSOR);
       PROCEDURE ADMPSI_LOYSALDOS(K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER);
       PROCEDURE ADMPSI_ELOYSALDOS(CURSORLOYSALDOS out SYS_REFCURSOR);
       PROCEDURE ADMPSI_LOYCANJE(K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER);
       PROCEDURE ADMPSI_ELOYCANJE(CURSORLOYCANJE out SYS_REFCURSOR);
       PROCEDURE ADMPSI_LOYCANJEDET(K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER);
       PROCEDURE ADMPSI_ELOYCANJEDET(CURSORLOYCANJEDET out SYS_REFCURSOR);
       PROCEDURE ADMPSI_LOYMOVTOS(K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER);
       PROCEDURE ADMPSI_ELOYMOVTOS(CURSORLOYMOVTOS out SYS_REFCURSOR);
       PROCEDURE ADMPSI_LOY_ALINI(K_CODERROR OUT NUMBER,K_DESCERROR OUT VARCHAR2,K_NUMREGTOT OUT NUMBER,K_NUMREGPRO OUT NUMBER, K_NUMREGERR OUT NUMBER);
end PKG_CC_IMPLOYALTY;

/