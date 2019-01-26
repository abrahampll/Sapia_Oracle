CREATE OR REPLACE PACKAGE PCLUB.PKG_AFILIACIONES is
  
  procedure sp_afiliaciones
    (
    origen Varchar2,
    fechaRegistro date,
    concepto Integer,
    tipoDocumento  Varchar2, 
    numeroDocumento Varchar2,
    segmento      Varchar2, 
    categoria       Integer,
    nombres Varchar2,
    apellidos Varchar2,
    sexo Varchar2,
    estadoCivil Varchar2,
    email Varchar2,
    departamento Varchar2,
    provincia Varchar2,
    distrito Varchar2,
    estado Varchar2,
    codigoContrato  Varchar2, 
    familia  Integer,
    numeroLinea Varchar2, 
    cicloFacturacion Varchar2, 
    tecnologia Integer,
    tipoProducto Varchar2,
    tipoTelefonia Integer,
    casoEspecial Varchar2,
    cantidadPuntos Integer,
    tipoPuntos Integer,
    codigoRespuesta out varchar2,
    mensajeRespuesta out varchar2
    );
    
end PKG_AFILIACIONES;
/
