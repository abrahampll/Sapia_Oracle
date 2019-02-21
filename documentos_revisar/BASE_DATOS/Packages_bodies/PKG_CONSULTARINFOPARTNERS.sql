create or replace package body PCLUB.PKG_CONSULTARINFOPARTNERS as

          procedure sp_consultarInfoPartners(
                tipoDoc IN varchar2,
                numDoc IN varchar2,
                listapartnerscliente OUT sys_refcursor,
                codigorespuesta OUT number,
                mensajerespuesta OUT varchar2
          )
      is
  /*
'****************************************************************************************************************
'* Nombre SP : sp_consultarInfoPartners
'* Propósito : Este procedimiento es responsable Consultar los Socios Latam.
'* Input :     <Parametro>       -- Descripción de los parametros
               tipoDoc           -- Tipo de documento LATAM
               numDoc            -- Numero de documento LATAM
'* Output :    <Parametro>       -- Descripción de los parametros
               listapartnerscliente       -- Cursor con datos del socio
               codigorespuesta            -- Codigo de error( 0 OK, 1 Error)
               mensajerespuesta           -- Descripción del error
'* Creado por : HITSS - JESÚS MEZA
'* Fecha de Creación : 26/07/2018
'****************************************************************************************************************
*/
      v_tipoDoc1 varchar2(40);
      n_Contador number:=0;      
      ex_excepcionTD exception;
      ex_excepcionND exception;
      ex_excepcionTN exception;
      ex_excepcionER exception;
      ex_excepcionEQ exception;
      
      begin

            if tipoDoc is null or length(ltrim(tipoDoc)) <= 0 then
               raise ex_excepcionTD;                              
            end if;

            if numDoc is null or length(ltrim(numDoc)) <= 0 then
               raise ex_excepcionND;                             
            end if;

            select count(1) into n_Contador
            from pclub.admpt_tipo_doc td
            where td.admpv_cod_tpdoc=tipoDoc;--

            if n_Contador > 0 then

               select te.admpv_dsc_docum into v_tipoDoc1
               from pclub.admpt_tipo_doc te
               where te.admpv_cod_tpdoc=tipoDoc;

               n_Contador:=0;

               v_tipoDoc1 := v_tipoDoc1||'PE';

               select count(1) into n_Contador
               from pclub.sysft_latam_socio ls
               where ls.sylsv_tip_doc_latam=v_tipoDoc1 and ls.sylsv_num_doc=numDoc;

               if n_Contador > 0 then

                  begin
                    
                      codigorespuesta:=0;
                      mensajerespuesta:='Exito en la Transaccion Validando El Numero y Tipo de Documento';

                      open listapartnerscliente for
                      select sylsv_id_socio_latam as idClientePartner,'0001' as idPartner, 'LATAM' as nombrePartner
                      from pclub.sysft_latam_socio
                      where sylsv_tip_doc_latam = v_tipoDoc1 and sylsv_num_doc = numDoc;
                      
                  exception
                    
                      when others then
                           raise ex_excepcionER;  
                  end;
                    
               else

                     raise ex_excepcionTN;
               end if;

            else
               raise ex_excepcionEQ;
            end if;

      exception

            when ex_excepcionTD then
                 codigorespuesta:=1;
                 mensajerespuesta:='Error en el Tipo de Documento';
                 
            when ex_excepcionND then
                 codigorespuesta:=1;
                 mensajerespuesta:='Error en el Numero de Documento'; 
            
            when ex_excepcionTN then
                 codigorespuesta:=1;
                 mensajerespuesta:='Error en el Tipo y Numero de Documento'; 
            
            when ex_excepcionER then
                 codigorespuesta:=1;
                 mensajerespuesta:='Error al colocar informacion en el Cursor'; 
            
            when ex_excepcionEQ then
                 codigorespuesta:=1;
                 mensajerespuesta:='Error en la Equivalencia de Tipo Documento'; 
            
            when others then

               codigorespuesta:=1;
               mensajerespuesta:='Error con Codigo => '||SQLCODE||' y Menssaje => '||SQLERRM;

      end sp_consultarInfoPartners;
end PKG_CONSULTARINFOPARTNERS;
/
