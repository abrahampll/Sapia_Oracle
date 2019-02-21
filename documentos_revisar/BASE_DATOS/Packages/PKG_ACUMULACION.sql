CREATE OR REPLACE PACKAGE PCLUB.PKG_ACUMULACION IS

PROCEDURE SP_ACUMULACION(codigoContrato IN varchar2, numerolinea in varchar2,
            fechaOperacion in date,cantidadPuntos in number, 
            tipoPuntos in number,origen in varchar2,concepto in varchar2,
            codigoRespuesta out varchar2, mensajeRespuesta out varchar2);
            
PROCEDURE SP_ACUMULACION_TCRM (fechaOperacion in date--,codigoRespuesta out varchar2,
                                     --mensajeRespuesta out varchar2
                                     );

END PKG_ACUMULACION;
/