create or replace package PCLUB.PKG_CONSALPUNTOS is

  -- Author  : Robert Delgado
  -- Created : 13/07/2018 12:27:05 p.m.
  -- Purpose : Permite consultar el saldo de Puntos Claro
  procedure sp_ConsultarSaldoPuntos ( 
                            tipoDocumento   in integer,
                            numeroDocumento in varchar2,
                            tamanioPagina   in integer,
                            numeroPagina in integer,
                            flagDetallePuntos in integer,
                            tipoPuntoDetalle in integer,
                            codigorespuesta out varchar2,
                            mensajerespuesta out varchar2,
                            cur_saldoacumulado OUT SYS_REFCURSOR,
                            cur_detallePuntosRegulares OUT SYS_REFCURSOR,
                            cur_detallePuntosPromocionales OUT SYS_REFCURSOR);


end PKG_CONSALPUNTOS;
/