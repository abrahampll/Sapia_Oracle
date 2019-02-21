create or replace package PCLUB.PKG_TRANSFORMAPUNTOS is

  procedure sp_transformaPuntos
    (
    codigoContrato in varchar2,
    numeroLinea in varchar2,
    idClientePartner in varchar2,
    correo in varchar2,
    codigoRespuesta out varchar2,
    mensajeRespuesta out varchar2,
    datos out sys_refcursor
    );

end PKG_TRANSFORMAPUNTOS;
/