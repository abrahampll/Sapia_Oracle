create or replace package body PCLUB.PKG_TRANSFORMAPUNTOS is

 /*********************************************************************
'* Nombre SP           :  transformaPuntos
'* Propósito           :  Generamos informacion con los parametros
'* Input               :  codigoContrato,numeroLinea,
                          idClientePartner,correo
'* Output              :  codigoRespuesta, mensajeRespuesta
'* Creado por          :  Miguel Oré
'* Fec Creación        :  20/07/2018
'* Fec Actualización   :  
'*********************************************************************/
  procedure sp_transformaPuntos
    (
      codigoContrato in varchar2,
      numeroLinea in varchar2,
      idClientePartner in varchar2,
      correo in varchar2,
      codigoRespuesta out varchar2,
      mensajeRespuesta out varchar2,
      datos out sys_refcursor
    )IS
    V_REGCON NUMBER;
    BEGIN
      codigoRespuesta := '0';
      mensajeRespuesta := 'OK';
      --Validamos Variable Obligatoria codigoContrato
      IF codigoContrato IS NULL THEN
        --Controlamos los errores, si el codigoContrato es Vacio o Nulo
        codigoRespuesta := '1';
        mensajeRespuesta := 'Codigo de Contrato Vacio o Nulo.';
        RETURN;
      END IF;
      --Validamos Variable Obligatoria idClientePartner
      IF idClientePartner IS NULL THEN
        --Controlamos los errores, si el idClientePartner es Vacio o Nulo
        codigoRespuesta := '1';
        mensajeRespuesta := 'id Cliente Partner Vacio o Nulo.';
        RETURN;
      END IF;
      --Validamos Variable Obligatoria correo
      IF correo IS NULL THEN
        --Controlamos los errores, si el correo es Vacio o Nulo
        codigoRespuesta := '1';
        mensajeRespuesta := 'Correo Electronico Vacio o Nulo.';
        RETURN;
      END IF;  
      --Validamos informacion filtrada
      V_REGCON := 0;
      SELECT COUNT(1) INTO V_REGCON FROM (select t.apSocio,t. nomSocio, t.tipoDoc, (s.sylsv_tip_doc_latam)as tipoDocLatam,t.numDoc, t.anio, t.tipoLinea
            from 
            (select (a.admpv_ape_cli)as apSocio, (a.admpv_nom_cli)as nomSocio, (a.admpv_tipo_doc)as tipoDoc, (a.admpv_num_doc)as numDoc, (to_char(sysdate, 'YYYY'))as anio, a.admpv_cod_tpocl as tipoLinea  from PCLUB.admpt_cliente a where a.admpv_cod_cli=codigoContrato
            union
            select (a.admpv_ape_cli)as apSocio, (a.admpv_nom_cli)as nomSocio, (a.admpv_tipo_doc)as tipoDoc, (a.admpv_num_doc)as numDoc, (to_char(sysdate, 'YYYY'))as anio, a.admpv_cod_tpocl as tipoLinea  from PCLUB.admpt_clientefija a where a.admpv_cod_cli=codigoContrato)t
            INNER JOIN PCLUB.sysft_latam_socio s ON trim(s.sylsv_num_doc)=trim(t.numDoc)
            INNER JOIN pclub.admpt_tipo_doc b ON
            trim(s.sylsv_tip_doc_latam) = trim(b.admpv_dsc_docum)||'PE')x;
      IF V_REGCON = 0 THEN
        --Controlamos los errores, si el cursor viene vacio
        codigoRespuesta := '1';
        mensajeRespuesta := 'No se encontro información.';
        RETURN;
      END IF;                  
      --Consulta                
      open datos for
           select t.apSocio,t. nomSocio, t.tipoDoc, (s.sylsv_tip_doc_latam)as tipoDocLatam,t.numDoc, t.anio, t.tipoLinea
            from 
            (select (a.admpv_ape_cli)as apSocio, (a.admpv_nom_cli)as nomSocio, (a.admpv_tipo_doc)as tipoDoc, (a.admpv_num_doc)as numDoc, (to_char(sysdate, 'YYYY'))as anio, a.admpv_cod_tpocl as tipoLinea  from PCLUB.admpt_cliente a where a.admpv_cod_cli=codigoContrato
            union
            select (a.admpv_ape_cli)as apSocio, (a.admpv_nom_cli)as nomSocio, (a.admpv_tipo_doc)as tipoDoc, (a.admpv_num_doc)as numDoc, (to_char(sysdate, 'YYYY'))as anio, a.admpv_cod_tpocl as tipoLinea  from PCLUB.admpt_clientefija a where a.admpv_cod_cli=codigoContrato)t
            INNER JOIN pclub.sysft_latam_socio s ON trim(s.sylsv_num_doc)=trim(t.numDoc)
            INNER JOIN pclub.admpt_tipo_doc b ON
            trim(s.sylsv_tip_doc_latam) = trim(b.admpv_dsc_docum)||'PE';
            --Controlamos los errores
      EXCEPTION WHEN OTHERS THEN
              codigoRespuesta:='1';
              mensajeRespuesta:=SUBSTR(SQLERRM,250);
    END;


end PKG_TRANSFORMAPUNTOS;
/
