CREATE OR REPLACE PACKAGE FIDELIDAD.PKG_FYR_PROMOCION_TRX IS

-- Author  : E75874
-- Created : 08/03/2013 11:04:28 AM
-- Purpose : 

 PROCEDURE SFYRSI_INSPROMOCIONCAB(K_DESC IN VARCHAR2,
                                  K_IDTIPO IN NUMBER,
                                  K_IDORIGEN IN NUMBER,
                                  K_IDVIGENCIA IN NUMBER,
                                  K_FECINI IN DATE,
                                  K_FECFIN IN DATE,
                                  K_USUARIO IN VARCHAR2,
                                  K_ID OUT NUMBER,
                                  K_CODERROR OUT NUMBER,
                                  K_DESCERROR OUT VARCHAR2);
                                  
 PROCEDURE SFYRSU_UPDPROMOCIONCAB(K_ID IN NUMBER,
                                  K_DESC IN VARCHAR2,
                                  K_IDTIPO IN NUMBER,
                                  K_IDORIGEN IN NUMBER,
                                  K_IDVIGENCIA IN NUMBER,
                                  K_FECINI IN DATE,
                                  K_FECFIN IN DATE,
                                  K_USUARIO IN VARCHAR2,
                                  K_CODERROR OUT NUMBER,
                                  K_DESCERROR OUT VARCHAR2);

 PROCEDURE SFYRSS_LISPROMOCIONCAB(K_ID IN NUMBER,
                                  K_DESC IN VARCHAR2,
                                  K_IDTIPO IN NUMBER,
                                  K_IDORIGEN IN NUMBER,
                                  K_IDVIGENCIA IN NUMBER,
                                  K_FECINIREG IN DATE,
                                  K_FECFINREG IN DATE,
                                  K_FECINIVIG IN DATE,
                                  K_FECFINVIG IN DATE,
                                  K_ESTADO IN NUMBER,
                                  K_CUR_PROMOCION OUT SYS_REFCURSOR,
                                  K_CODERROR OUT NUMBER,
                                  K_DESCERROR OUT VARCHAR2);
                                 
 PROCEDURE SFYRSI_INSPROMOCIONSER(K_IDPROMOCION IN NUMBER,
                                  K_ETIQUETA IN VARCHAR2,
                                  K_DESCRIPCION IN VARCHAR2,
                                  K_USUARIO IN VARCHAR2,
                                  K_ID OUT NUMBER,
                                  K_CODERROR OUT NUMBER,
                                  K_DESCERROR OUT VARCHAR2);

 PROCEDURE SFYRSD_DELPROMOCIONSER(K_ID NUMBER,
                                  K_CODERROR OUT NUMBER,
                                  K_DESCERROR OUT VARCHAR2);
                                  
 PROCEDURE SFYRSS_LISPROMOCIONSER(K_ID IN NUMBER,
                                  K_IDPROMOCION IN NUMBER,
                                  K_ETIQUETA IN VARCHAR2,
                                  K_CUR_SERVICIO OUT SYS_REFCURSOR,
                                  K_CODERROR OUT NUMBER,
                                  K_DESCERROR OUT VARCHAR2);

 PROCEDURE SFYRSI_INSAUDPROMOCIONCAB(K_PROCESO IN CHAR,
                                     K_DESC IN VARCHAR2,
                                     K_FECINI IN DATE,
                                     K_FECFIN IN DATE,
                                     K_IDPROMOCION IN NUMBER,
                                     K_IDTIPO IN NUMBER,
                                     K_IDORIGEN IN NUMBER,
                                     K_IDVIGENCIA IN NUMBER,
                                     K_USUARIO IN VARCHAR2,
                                     K_ID OUT NUMBER,
                                     K_CODERROR OUT NUMBER,
                                     K_DESCERROR OUT VARCHAR2);

 PROCEDURE SFYRSI_INSAUDPROMOCIONSER(K_PROCESO IN CHAR,
                                     K_ETIQUETA IN VARCHAR2,
                                     K_DESCRIPCION IN VARCHAR2,
                                     K_IDAUDPROMOCION IN NUMBER,
                                     K_IDPROMOCIONSER IN NUMBER,
                                     K_USUARIO IN VARCHAR2,
                                     K_CODERROR OUT NUMBER,
                                     K_DESCERROR OUT VARCHAR2);
                                     
 PROCEDURE SFYRSS_LISAUDPROMOCIONCAB(K_ID IN NUMBER,
                                     K_IDPROMOCION IN NUMBER,
                                     K_CUR_AUDPROMOCION OUT SYS_REFCURSOR,
                                     K_CODERROR OUT NUMBER,
                                     K_DESCERROR OUT VARCHAR2);

 PROCEDURE SFYRSS_LISAUDPROMOCIONSER(K_ID IN NUMBER,
                                     K_IDAUDPROMOCION IN NUMBER,
                                     K_CUR_AUDSERVICIO OUT SYS_REFCURSOR,
                                     K_CODERROR OUT NUMBER,
                                     K_DESCERROR OUT VARCHAR2);
                                     
 PROCEDURE SFYRSI_INSPROGPROMLOTE(K_DESC IN VARCHAR2,
                                  K_NOMBREARCH IN VARCHAR2,
                                  K_IDPROMOCION IN NUMBER,
                                  K_IDORIGEN IN NUMBER,
                                  K_IDESTADO IN NUMBER,
                                  K_USUARIO IN VARCHAR2,
                                  K_ID OUT NUMBER,
                                  K_CODERROR OUT NUMBER,
                                  K_DESCERROR OUT VARCHAR2);

 PROCEDURE SFYRSU_UPDPROGPROMLOTE(K_ID IN NUMBER,
                                  K_DESC IN VARCHAR2,
                                  K_IDPROMOCION IN NUMBER,
                                  K_IDORIGEN IN NUMBER,
                                  K_IDESTADO IN NUMBER,
                                  K_USUARIO IN VARCHAR2,                                 
                                  K_CODERROR OUT NUMBER,
                                  K_DESCERROR OUT VARCHAR2);

 PROCEDURE SFYRSS_LISPROGPROMLOTE(K_ID IN NUMBER,
                                  K_DESC IN VARCHAR2,
                                  K_IDORIGEN IN NUMBER,
                                  K_IDESTADO IN NUMBER,
                                  K_FECINIREG IN DATE,
                                  K_FECFINREG IN DATE,
                                  K_CUR_PROGPROMLOTE OUT SYS_REFCURSOR,
                                  K_CODERROR OUT NUMBER,
                                  K_DESCERROR OUT VARCHAR2);
                                  
 PROCEDURE SFYRSI_INSPROGPROMCLIENTE(K_SID IN VARCHAR2,
                                     K_CODCLI IN VARCHAR2,
                                     K_NOMCLI IN VARCHAR2,
                                     K_TIPOSERV IN VARCHAR2,
                                     K_ESTASERV IN VARCHAR2,
                                     K_OBSERVALTA IN VARCHAR2,
                                     K_IDLOTE IN NUMBER,
                                     K_IDESTADO IN NUMBER,
                                     K_USUARIO IN VARCHAR2,
                                     K_ID OUT NUMBER,
                                     K_CODERROR OUT NUMBER,
                                     K_DESCERROR OUT VARCHAR2);

 PROCEDURE SFYRSU_UPDPROGPROMCLIENTE(K_ID IN NUMBER,
                                     K_IDESTADO IN NUMBER,
                                     K_USUARIO IN VARCHAR2,
                                     K_CODERROR OUT NUMBER,
                                     K_DESCERROR OUT VARCHAR2);
                                    
 PROCEDURE SFYRSS_LISPROGPROMCLIENTE(K_ID IN NUMBER,
                                     K_SID IN VARCHAR2,
                                     K_IDPROGPROMLOTE IN NUMBER,
                                     K_IDESTADO IN NUMBER,
                                     K_IDESTADOGRUPO IN NUMBER,
                                     K_CUR_PROGPROMCLIENTE OUT SYS_REFCURSOR,
                                     K_CODERROR OUT NUMBER,
                                     K_DESCERROR OUT VARCHAR2);

 PROCEDURE SFYRSS_LISPROGPROMCLIXGRUPO(K_IDPROGPROMLOTE IN NUMBER,
                                       K_CUR_PROGPROMCLIENTE OUT SYS_REFCURSOR,
                                       K_CODERROR OUT NUMBER,
                                       K_DESCERROR OUT VARCHAR2);

 PROCEDURE SFYRSI_INSAUDPROGPROMLOTE(K_PROCESO IN CHAR,
                                     K_DESC IN VARCHAR2,
                                     K_NOMBREARCH IN VARCHAR2,
                                     K_REGVALIDO IN NUMBER,
                                     K_REGERROR IN NUMBER,                                    
                                     K_REGTOTAL IN NUMBER,                                    
                                     K_IDPROGPROMLOTE IN NUMBER,
                                     K_IDPROMOCION IN NUMBER,
                                     K_IDORIGEN IN NUMBER,
                                     K_IDESTADO IN NUMBER,
                                     K_USUARIO IN VARCHAR2,
                                     K_ID OUT NUMBER,
                                     K_CODERROR OUT NUMBER,
                                     K_DESCERROR OUT VARCHAR2);

 PROCEDURE SFYRSS_LISAUDPROGPROMLOTE(K_ID IN NUMBER,
                                     K_IDPROGPROMLOTE IN NUMBER,
                                     K_CUR_AUDPROGPROMLOTE OUT SYS_REFCURSOR,
                                     K_CODERROR OUT NUMBER,
                                     K_DESCERROR OUT VARCHAR2);
                             
 PROCEDURE SFYRU_CIERRA_LOTE(K_ID IN NUMBER,
                             K_USUARIO IN VARCHAR2,                                 
                             K_CODERROR OUT NUMBER,
                             K_DESCERROR OUT VARCHAR2);
 
 PROCEDURE SFYRI_PROC_ALTPRO_LISCLIE(K_CUR_LOTE_DETALLE OUT SYS_REFCURSOR,
                                     K_CODERROR OUT NUMBER,
                                     K_DESCERROR OUT VARCHAR2);

 PROCEDURE SFYRI_PROC_ALTPRO_GETPAR(K_ORIGEN OUT VARCHAR2,
                                    K_ESTALOTE_GENERADO OUT NUMBER,
                                    K_ESTADETALOTE_PENDIENTE OUT NUMBER,
                                    K_ESTADETALOTE_EJECALTA OUT NUMBER,
                                    K_ESTADETALOTE_ALTAPROMOK OUT NUMBER,
                                    K_ESTADETALOTE_ALTAPROMERR OUT NUMBER,
                                    K_ESTADETALOTE_ANULADO OUT NUMBER,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2);

 PROCEDURE SFYRI_PROC_ALTPRO_ACTCLIE(K_IDDETALOTE IN NUMBER,
                                     K_CODERRORSGA IN NUMBER,
                                     K_SOT_ALTA IN NUMBER,
                                     K_FECGENALTASOT IN DATE,
                                     K_FECALTASOT IN DATE,
                                     K_FECPROGBAJASOT IN DATE,
                                     K_OBSERVACION IN VARCHAR2,
                                     K_ESTADETALOTE IN NUMBER,
                                     K_ESTADETALOTE_EJECALTA IN NUMBER,
                                     K_ESTADETALOTE_ALTAPROMERR IN NUMBER,
                                     K_USUARIO IN VARCHAR2,
                                     K_CODERROR OUT NUMBER,
                                     K_DESCERROR OUT VARCHAR2);

 PROCEDURE SFYRI_PROC_BAJPRO_ACTCLIE(K_IDDETALOTE IN NUMBER,
                                     K_CODERRORSGA IN NUMBER,
                                     K_SOT_BAJA IN NUMBER,
                                     K_FECGENBAJASOT IN DATE,
                                     K_FECBAJASOT IN DATE,
                                     K_OBSERVACION IN VARCHAR2,
                                     K_REINTENTOS IN NUMBER,
                                     K_USUARIO IN VARCHAR2,
                                     K_CODERROR OUT NUMBER,
                                     K_DESCERROR OUT VARCHAR2);

 PROCEDURE SFYRI_ALTPRO_ACTCLIE_SGA(K_FECSOTALTA IN DATE,
                                   K_FECSOTBAJAPROG IN DATE,
                                   K_OBSERVALTA IN VARCHAR2,
                                   K_IDESTADO IN NUMBER,
                                   K_ID IN NUMBER,
                                   K_USUMOD VARCHAR2,
                                   K_CODERROR OUT NUMBER,
                                   K_DESCERROR OUT VARCHAR2);
 
 PROCEDURE SFYRI_BAJPRO_ACTCLIE_SGA(K_FECSOTBAJA IN DATE,
                                   K_OBSERVBAJA IN VARCHAR2,
                                   K_REINTENTOS IN NUMBER,
                                   K_IDESTADO IN NUMBER,
                                   K_ID IN NUMBER,
                                   K_USUMOD IN VARCHAR2,
                                   K_CODERROR OUT NUMBER,
                                   K_DESCERROR OUT VARCHAR2);

 FUNCTION F_GETTOTALREGISTROXTIPO(K_IDPROGPROMLOTE NUMBER,
                                  K_IDGRUPOESTADO NUMBER) RETURN NUMBER;

 FUNCTION F_GETSERVPROMOETIQUETA(K_IDPROMOCION NUMBER,
                                 K_DELIM VARCHAR2) RETURN VARCHAR2;

 FUNCTION F_GETSERVPROMOETIQDESC(K_IDPROMOCION NUMBER,
                                 K_DELIM VARCHAR2) RETURN VARCHAR2;

  PROCEDURE SFYRI_PROC_BAJPRO_GETPAR(K_ORIGEN OUT VARCHAR2,
                                    K_ESTADETALOTE_ALTAPROMOK OUT NUMBER,
                                    K_ESTADETALOTE_EJECBAJA OUT NUMBER,
                                    K_ESTADETALOTE_BAJAPROMOK OUT NUMBER,
                                    K_ESTADETALOTE_BAJAPROMERR OUT NUMBER,
                                    K_CODERROR OUT NUMBER,
                                    K_DESCERROR OUT VARCHAR2);


END PKG_FYR_PROMOCION_TRX;
/