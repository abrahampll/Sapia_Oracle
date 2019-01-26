create or replace package body pclub.PKG_CTL_CCLUB is

  /************************************************************************************************
  *Tipo               : Procedimiento
  *Descripción        : Inserción en Tabla ADMPT_CTL_CANJES
  *Autor              : Antonio Astete
  *Proyecto o REQ     : Proy - 19003 Requerimiento Claro Puntos Clientes HFC en BSCS
  *Fecha de Creación  : 25/01/2016
  ************************************************************************************************/
  procedure ADMPSI_CTL_CANJES(K_NRODOC_CLIENTE in varchar2,
                              K_CODCLI in varchar2,
                              K_CODCLI_PROD in varchar2,
                              K_CODSERV in varchar2,
                              K_PROCESO in varchar2,
                              K_MSJERROR in varchar2,
			      K_USUARIO in varchar2,
			      K_CODERROR out number,
	                      K_DESCERROR out varchar2) is
    v_Flag_SYSFIRT     NUMBER;
    v_Flag_EAI         NUMBER;
    v_Flag_REG_SOT     NUMBER;
    v_Flag_EJEC_SOT    NUMBER;
    v_Flag_ACT_EST_EAI NUMBER;
    v_Flag_ACT_BSCS    NUMBER;
    v_Flag_REG_EXTORNO NUMBER;
    
  begin
    
    CASE
           WHEN K_PROCESO = 'ADMPC_PROC_SYSFIRT' 
             THEN 
               v_Flag_SYSFIRT := 0;
               v_Flag_EAI := 0;
               v_Flag_REG_SOT := 0;
               v_Flag_EJEC_SOT := 0;
               v_Flag_ACT_EST_EAI := 0;
               v_Flag_ACT_BSCS := 0;
               v_Flag_REG_EXTORNO := 0;
           WHEN K_PROCESO = 'ADMPC_PROC_EAI' 
             THEN 
               v_Flag_SYSFIRT := 1;
               v_Flag_EAI := 0;
               v_Flag_REG_SOT := 0;
               v_Flag_EJEC_SOT := 0;
               v_Flag_ACT_EST_EAI := 0;
               v_Flag_ACT_BSCS := 0;
               v_Flag_REG_EXTORNO := 0;
           WHEN K_PROCESO = 'ADMPC_PROC_REG_SOT' 
             THEN 
               v_Flag_SYSFIRT := 1;
               v_Flag_EAI := 1;
               v_Flag_REG_SOT := 0;
               v_Flag_EJEC_SOT := 0;
               v_Flag_ACT_EST_EAI := 0;
               v_Flag_ACT_BSCS := 0;
               v_Flag_REG_EXTORNO := 0;
           WHEN K_PROCESO = 'ADMPC_PROC_EJEC_SOT' 
             THEN 
               v_Flag_SYSFIRT := 1;
               v_Flag_EAI := 1;
               v_Flag_REG_SOT := 1;
               v_Flag_EJEC_SOT := 0;
               v_Flag_ACT_EST_EAI := 0;
               v_Flag_ACT_BSCS := 0;
               v_Flag_REG_EXTORNO := 0;
           WHEN K_PROCESO = 'ADMPC_PROC_ACT_EST_EAI' 
             THEN 
               v_Flag_SYSFIRT := 1;
               v_Flag_EAI := 1;
               v_Flag_REG_SOT := 1;
               v_Flag_EJEC_SOT := 1;
               v_Flag_ACT_EST_EAI := 0;
               v_Flag_ACT_BSCS := 0;
               v_Flag_REG_EXTORNO := 0;
           WHEN K_PROCESO = 'ADMPC_PROC_ACT_BSCS' 
             THEN 
               v_Flag_SYSFIRT := 1;
               v_Flag_EAI := 1;
               v_Flag_REG_SOT := 1;
               v_Flag_EJEC_SOT := 1;
               v_Flag_ACT_EST_EAI := 1;
               v_Flag_ACT_BSCS := 0;
               v_Flag_REG_EXTORNO := 0;
           WHEN K_PROCESO = 'ADMPC_PROC_REG_EXTORNO' 
             THEN 
               v_Flag_SYSFIRT := 1;
               v_Flag_EAI := 1;
               v_Flag_REG_SOT := 1;
               v_Flag_EJEC_SOT := 1;
               v_Flag_ACT_EST_EAI := 1;
               v_Flag_ACT_BSCS := 1;
               v_Flag_REG_EXTORNO := 0;
    END CASE;
       
    Insert into PCLUB.ADMPT_CTL_CANJES
      (ADMPV_NUM_DOC, ADMPV_COD_CLI, ADMPV_COD_CLI_PROD, ADMPV_SERVICIO, ADMPC_PROC_SYSFIRT, ADMPC_PROC_EAI, ADMPC_PROC_REG_SOT, ADMPC_PROC_EJEC_SOT, ADMPC_PROC_ACT_EST_EAI, ADMPC_PROC_ACT_BSCS, ADMPC_PROC_REG_EXTORNO,ADMPV_MSJE_ERROR,ADMPD_FEC_REG,ADMPV_USU_REG)
    Values
      (K_NRODOC_CLIENTE, K_CODCLI, K_CODCLI_PROD, K_CODSERV, v_Flag_SYSFIRT, v_Flag_EAI, v_Flag_REG_SOT, v_Flag_EJEC_SOT, v_Flag_ACT_EST_EAI, v_Flag_ACT_BSCS, v_Flag_REG_EXTORNO, K_MSJERROR, sysdate, K_USUARIO);
    commit;
    K_DESCERROR := 'OK';
    K_CODERROR := 1;
  exception
    when others then
      K_DESCERROR := 'ERROR: ' || SQLERRM;
      K_CODERROR := SQLCODE;
      rollback;
  end;

  PROCEDURE ADMPSD_CTL_CANJES
  (
    K_MESES IN NUMBER,
    K_CODERROR  OUT NUMBER,
    K_DESCERROR OUT VARCHAR2
  )
  AS

  EX_ERROR EXCEPTION;
  K_FECINI DATE;

  BEGIN

      K_DESCERROR := '';
      K_CODERROR  := 0;

     
      IF K_MESES IS NULL THEN
        K_DESCERROR := 'Ingrese la cantidad de Meses.';
        K_CODERROR  := 4;
        RAISE EX_ERROR;
      END IF;

      SELECT add_months(SYSDATE,-K_MESES) INTO K_FECINI FROM DUAL;

      DELETE FROM ADMPT_CTL_CANJES T WHERE T.ADMPD_FEC_REG >= K_FECINI;

      COMMIT;    

  EXCEPTION
      WHEN EX_ERROR THEN
        BEGIN
          SELECT ADMPV_DES_ERROR || K_DESCERROR
            INTO K_DESCERROR
            FROM ADMPT_ERRORES_CC
           WHERE ADMPN_COD_ERROR = K_CODERROR;
        EXCEPTION
          WHEN OTHERS THEN
            K_DESCERROR := 'ERROR';
        END;
      WHEN OTHERS THEN
        ROLLBACK;
        K_CODERROR  := 1;
        K_DESCERROR := SUBSTR(SQLERRM, 1, 250);
        
  END ADMPSD_CTL_CANJES;


end PKG_CTL_CCLUB;
/
