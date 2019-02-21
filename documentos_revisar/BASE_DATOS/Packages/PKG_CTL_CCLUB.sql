create or replace package pclub.PKG_CTL_CCLUB  is

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
	                            K_DESCERROR out varchar2);

  PROCEDURE ADMPSD_CTL_CANJES
  (
    K_MESES IN NUMBER,
    K_CODERROR  OUT NUMBER,
    K_DESCERROR OUT VARCHAR2
   );

end PKG_CTL_CCLUB;

/
