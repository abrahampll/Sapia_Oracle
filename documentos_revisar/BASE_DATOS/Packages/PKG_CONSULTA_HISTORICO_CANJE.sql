create or replace package PCLUB.PKG_CONSULTA_HISTORICO_CANJE is

procedure SP_HISTORICO (tipoDocumento in varchar2,
                        numeroDocumento in varchar2,
                        fechaInicioHistorico in date,
                        fechaFinHistorico in date,
                        tamanioPagina in number,
                        numeroPagina in number,
                        codeResponse out varchar2,
                        descriptionResponse out varchar2,
                        cur_canje out SYS_REFCURSOR);
                      

end PKG_CONSULTA_HISTORICO_CANJE;
/
