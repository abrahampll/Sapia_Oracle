create or replace package PCLUB.PKG_REALIZARCANJE is

procedure sp_realizarcanje(solicitud in varchar2,
                           numeroOrden in varchar2,
                           codigoContrato in varchar2,
                           numeroLinea in number,
                           tipoDocumento in varchar2,
                           numeroDocumento in varchar2,
                           codigoPuntoVenta in varchar2,
                           nombrePuntoVenta in varchar2,
                           origen in varchar2,
                           codigoAsesor in varchar2,
                           nombreAsesor in varchar2,
                           segmento in varchar2,
                           codigoProducto in varchar2,
                           nombreProducto in varchar2,
                           cantidadPuntos in varchar2,
                           puntosSoles in varchar2,
                           cantidad in varchar2,
                           tipoPremio in varchar2,
                           nombreTipoPremio in varchar2,
                           codigorespuesta out varchar2,
						   mensajerespuesta out varchar2);

PROCEDURE ADMPSI_DESC_PUNTOS(  K_ID_CANJE    NUMBER,
                               K_SEC         NUMBER,
                               K_PUNTOS      NUMBER,
                               K_COD_CLIENTE IN VARCHAR2,
                               K_TIPO_DOC    IN VARCHAR2,
                               K_NUM_DOC     IN VARCHAR2,
                               K_GRUPO       IN NUMBER,
                               K_USUARIO     IN VARCHAR2,
                               K_CODERROR    OUT NUMBER,
                               K_MSJERROR    OUT VARCHAR2);

end PKG_REALIZARCANJE;
/
