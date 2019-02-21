create or replace package PCLUB.PKG_DESAFILIACION is

  procedure sp_desafiliacion (codigoContrato in varchar2, numeroLinea in varchar2, estado in varchar2,
                          fechaOperacion in date, origen in varchar2, codigoRespuesta out varchar2, mensajeRespuesta out varchar2);
  
end PKG_DESAFILIACION;
/