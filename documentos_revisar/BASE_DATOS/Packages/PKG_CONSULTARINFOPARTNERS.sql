create or replace package PCLUB.PKG_CONSULTARINFOPARTNERS as

       procedure sp_consultarInfoPartners
       (
            tipoDoc IN varchar2,
            numDoc IN varchar2,
            listapartnerscliente OUT sys_refcursor,
            codigorespuesta OUT number,
            mensajerespuesta OUT varchar2
       );

end PKG_CONSULTARINFOPARTNERS;
/