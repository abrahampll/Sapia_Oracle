create or replace package body PCLUB.PKG_CONSULTA_HISTORICO_CANJE is


procedure SP_HISTORICO (tipoDocumento in varchar2,
                        numeroDocumento in varchar2,
                        fechaInicioHistorico in date,
                        fechaFinHistorico in date,
                        tamanioPagina in number,
                        numeroPagina in number,
                        codeResponse out varchar2,
                        descriptionResponse out varchar2,
                        cur_canje out SYS_REFCURSOR)IS
      
      C_EXISTE NUMBER;
      C_EXISTE_F NUMBER;
      NO_DATOS_VALIDOS EXCEPTION;
      --definiendo los valores para el tamaño y numero de pagina
      V_INICIAL number := tamanioPagina * (numeroPagina - 1 ) + 1;
      V_FINAL number   := V_INICIAL + tamanioPagina -1;      
      C_CONTADOR number :=0;
         
      
      begin
           --validando que no sea nulo los campos tipoDocumento y numeroDocumento
           if tipoDocumento is not null and numeroDocumento is not null   then
             
               SELECT count(1)
                 INTO C_EXISTE
                 FROM pclub.admpt_cliente
                 WHERE  admpv_tipo_doc = tipoDocumento
                        AND admpv_num_doc = numeroDocumento
                        AND admpc_estado = 'A';
               
               SELECT count(1)
                      INTO C_EXISTE_F
               FROM pclub.admpt_clientefija 
               WHERE admpv_tipo_doc = tipoDocumento
                     AND admpv_num_doc = numeroDocumento
                     AND admpc_estado= 'A';
                          
               IF C_EXISTE = 0 AND C_EXISTE_F = 0 THEN
                   codeResponse  := 1;
                   descriptionResponse := 'Documento no existe';
                     return; 
               END IF;
                  
         -- con fecha de busqueda
         if fechaInicioHistorico is not null and fechaFinHistorico is not null then 
                
              --validando que no se nulo los campos tamanioPagina y numeroPagina
              if tamanioPagina is not null and numeroPagina is not null   then
               
              select count(1) into C_CONTADOR
                      from 
                      ( select rownum rn, a.* from 
                              (
                            
                              select 
                                      c.admpv_cod_cli as codigo_Contrato,
                                      ca.admpv_num_linea as numero_Linea,
                                      tp.admpv_desc as tipo_Premio,
                                      dc.admpv_desc as producto,
                                      dc.admpn_puntos as puntos,
                                      dc.admpn_cantidad as cantidad,
                                      (dc.admpn_puntos*dc.admpn_cantidad) as Total_Puntos,
                                      ca.admpd_fec_canje as fecha_Canje,
                                      ca.admpv_pto_venta as codigo_Punto_Venta,
                                      ca.admpv_nom_aseso as asesor,
                                      pv.admpv_pto_venta_des Nombre_Punto_Venta
                                      
                               from pclub.admpt_cliente C
                               inner join pclub.admpt_canje CA
                                     on c.admpv_cod_cli=ca.admpv_cod_cli
                               inner join pclub.admpt_canje_detalle DC
                                     on ca.admpv_id_canje=dc.admpv_id_canje
                               inner join pclub.admpt_premio P
                                     on dc.admpv_id_procla=p.admpv_id_procla
                               inner join pclub.admpt_tipo_premio TP
                                      on tp.admpv_cod_tpopr=p.admpv_cod_tpopr
                               left join pclub.admpt_punto_venta PV
                                     on ca.admpv_id_canje =pv.admpv_id_canje
                 
                               where 
                                      c.admpc_estado='A' and
                                      c.admpv_tipo_doc= tipoDocumento and
                                      c.admpv_num_doc= numeroDocumento and
                                      ca.admpd_fec_canje>=fechaInicioHistorico and 
                                      ca.admpd_fec_canje<fechaFinHistorico+1
                                         
                               
                              UNION ALL
                         --=======FIJA  
                      --Realizando la consulta para los clientes de fija                     
                               select  
                                       cf.admpv_cod_cli as codigo_Contrato,
                                       caf.admpv_num_linea as numero_Linea,
                                       tp.admpv_desc as tipo_Premio,
                                       dcf.admpv_desc as producto,
                                       dcf.admpn_puntos as puntos,
                                       dcf.admpn_cantidad as cantidad,
                                       (dcf.admpn_puntos*dcf.admpn_cantidad) as Total_Puntos,
                                       caf.admpd_fec_canje as fecha_Canje,
                                       caf.admpv_pto_venta as codigo_Punto_Venta,
                                       caf.admpv_nom_aseso as asesor,
                                       pv.admpv_pto_venta_des as Nombre_Punto_Venta
                                       
                               from pclub.admpt_clientefija cf
                                       inner join pclub.admpt_canjefija caf
                                             on cf.admpv_cod_cli=caf.admpv_cod_cli
                                       inner join pclub.admpt_canje_detallefija dcf
                                             on caf.admpv_id_canje=dcf.admpv_id_canje
                                       inner join pclub.admpt_premio P
                                             on dcf.admpv_id_procla=p.admpv_id_procla
                                       inner join pclub.admpt_tipo_premio TP
                                            on tp.admpv_cod_tpopr=p.admpv_cod_tpopr
                                       left join pclub.admpt_punto_venta PV
                                             on caf.admpv_id_canje=pv.admpv_id_canje
                                
                                where 
                                      cf.admpc_estado='A' and
                                      cf.admpv_tipo_doc= tipoDocumento and
                                      cf.admpv_num_doc= numeroDocumento and
                                      caf.admpd_fec_canje>=fechaInicioHistorico and 
                                      caf.admpd_fec_canje<fechaFinHistorico+1
                                
                             ) a 
                             where rownum <= V_FINAL
                        ) 
                        where  rn  >= V_INICIAL;
              
              if C_CONTADOR > 0 then
              
                      open cur_canje for 
                      --=======MOVIL
                      --Realizando la consulta para los clientes de moviles
                      select codigo_Contrato,numero_Linea,tipo_Premio,producto,puntos,cantidad,Total_Puntos,
                             fecha_Canje,codigo_Punto_Venta,asesor,Nombre_Punto_Venta
                      from 
                      ( select rownum rn, a.* from 
                              (
                              select 
                                      c.admpv_cod_cli as codigo_Contrato,
                                      ca.admpv_num_linea as numero_Linea,
                                      tp.admpv_desc as tipo_Premio,
                                      dc.admpv_desc as producto,
                                      dc.admpn_puntos as puntos,
                                      dc.admpn_cantidad as cantidad,
                                      (dc.admpn_puntos*dc.admpn_cantidad) as Total_Puntos,
                                      ca.admpd_fec_canje as fecha_Canje,
                                      ca.admpv_pto_venta as codigo_Punto_Venta,
                                      ca.admpv_nom_aseso as asesor,
                                      pv.admpv_pto_venta_des Nombre_Punto_Venta
                                      
                               from pclub.admpt_cliente C
                               inner join pclub.admpt_canje CA
                                     on c.admpv_cod_cli=ca.admpv_cod_cli
                               inner join pclub.admpt_canje_detalle DC
                                     on ca.admpv_id_canje=dc.admpv_id_canje
                               inner join pclub.admpt_premio P
                                     on dc.admpv_id_procla=p.admpv_id_procla
                               inner join pclub.admpt_tipo_premio TP
                                      on tp.admpv_cod_tpopr=p.admpv_cod_tpopr
                               left join pclub.admpt_punto_venta PV
                                     on ca.admpv_id_canje =pv.admpv_id_canje
                 
                               where 
                                      c.admpc_estado='A' and
                                      c.admpv_tipo_doc= tipoDocumento and
                                      c.admpv_num_doc= numeroDocumento and
                                      ca.admpd_fec_canje>=fechaInicioHistorico and 
                                      ca.admpd_fec_canje<fechaFinHistorico+1
                                         
                               
                              UNION ALL
                         --=======FIJA  
                      --Realizando la consulta para los clientes de fija                     
                               select  
                                       cf.admpv_cod_cli as codigo_Contrato,
                                       caf.admpv_num_linea as numero_Linea,
                                       tp.admpv_desc as tipo_Premio,
                                       dcf.admpv_desc as producto,
                                       dcf.admpn_puntos as puntos,
                                       dcf.admpn_cantidad as cantidad,
                                       (dcf.admpn_puntos*dcf.admpn_cantidad) as Total_Puntos,
                                       caf.admpd_fec_canje as fecha_Canje,
                                       caf.admpv_pto_venta as codigo_Punto_Venta,
                                       caf.admpv_nom_aseso as asesor,
                                       pv.admpv_pto_venta_des as Nombre_Punto_Venta
                                       
                               from pclub.admpt_clientefija cf
                                       inner join pclub.admpt_canjefija caf
                                             on cf.admpv_cod_cli=caf.admpv_cod_cli
                                       inner join pclub.admpt_canje_detallefija dcf
                                             on caf.admpv_id_canje=dcf.admpv_id_canje
                                       inner join pclub.admpt_premio P
                                             on dcf.admpv_id_procla=p.admpv_id_procla
                                       inner join pclub.admpt_tipo_premio TP
                                            on tp.admpv_cod_tpopr=p.admpv_cod_tpopr
                                       left join pclub.admpt_punto_venta PV
                                             on caf.admpv_id_canje=pv.admpv_id_canje
                                
                                where 
                                      cf.admpc_estado='A' and
                                      cf.admpv_tipo_doc= tipoDocumento and
                                      cf.admpv_num_doc= numeroDocumento and
                                      caf.admpd_fec_canje>=fechaInicioHistorico and 
                                      caf.admpd_fec_canje<fechaFinHistorico+1
                                      
                                    
                             ) a 
                             where rownum <= V_FINAL
                        ) 
                        where  rn  >= V_INICIAL;
                        
                                     
                        codeResponse := '0';
                        descriptionResponse := 'OK';
                    else
                      codeResponse := '1';
                        descriptionResponse := 'No hay canjes en la pagina indicada';
                    end if;
               else
                codeResponse := '1';
                descriptionResponse := 'Falta definir tamaño o numero de pagina';
                end if; 
             
         
                
             end if;
             
             
             --sin fecha de busqueda
             if fechaInicioHistorico is null or fechaFinHistorico is null then
             
                --validando que no se nulo los campos tamanioPagina y tamanioPagina
              if tamanioPagina is not null and numeroPagina is not null   then
               
              select count(1) into C_CONTADOR
                      from 
                      ( select rownum rn, a.* from 
                              (
                            
                              select 
                                      c.admpv_cod_cli as codigo_Contrato,
                                      ca.admpv_num_linea as numero_Linea,
                                      tp.admpv_desc as tipo_Premio,
                                      dc.admpv_desc as producto,
                                      dc.admpn_puntos as puntos,
                                      dc.admpn_cantidad as cantidad,
                                      (dc.admpn_puntos*dc.admpn_cantidad) as Total_Puntos,
                                      ca.admpd_fec_canje as fecha_Canje,
                                      ca.admpv_pto_venta as codigo_Punto_Venta,
                                      ca.admpv_nom_aseso as asesor,
                                      pv.admpv_pto_venta_des Nombre_Punto_Venta
                                      
                               from pclub.admpt_cliente C
                               inner join pclub.admpt_canje CA
                                     on c.admpv_cod_cli=ca.admpv_cod_cli
                               inner join pclub.admpt_canje_detalle DC
                                     on ca.admpv_id_canje=dc.admpv_id_canje
                               inner join pclub.admpt_premio P
                                     on dc.admpv_id_procla=p.admpv_id_procla
                               inner join pclub.admpt_tipo_premio TP
                                      on tp.admpv_cod_tpopr=p.admpv_cod_tpopr
                               left join pclub.admpt_punto_venta PV
                                     on ca.admpv_id_canje =pv.admpv_id_canje
                 
                               where 
                                      c.admpc_estado='A' and
                                      c.admpv_tipo_doc= tipoDocumento and
                                      c.admpv_num_doc= numeroDocumento
                                         
                               
                              UNION ALL
                         --=======FIJA  
                      --Realizando la consulta para los clientes de fija                     
                               select  
                                       cf.admpv_cod_cli as codigo_Contrato,
                                       caf.admpv_num_linea as numero_Linea,
                                       tp.admpv_desc as tipo_Premio,
                                       dcf.admpv_desc as producto,
                                       dcf.admpn_puntos as puntos,
                                       dcf.admpn_cantidad as cantidad,
                                       (dcf.admpn_puntos*dcf.admpn_cantidad) as Total_Puntos,
                                       caf.admpd_fec_canje as fecha_Canje,
                                       caf.admpv_pto_venta as codigo_Punto_Venta,
                                       caf.admpv_nom_aseso as asesor,
                                       pv.admpv_pto_venta_des as Nombre_Punto_Venta
                                       
                               from pclub.admpt_clientefija cf
                                       inner join pclub.admpt_canjefija caf
                                             on cf.admpv_cod_cli=caf.admpv_cod_cli
                                       inner join pclub.admpt_canje_detallefija dcf
                                             on caf.admpv_id_canje=dcf.admpv_id_canje
                                       inner join pclub.admpt_premio P
                                             on dcf.admpv_id_procla=p.admpv_id_procla
                                       inner join pclub.admpt_tipo_premio TP
                                            on tp.admpv_cod_tpopr=p.admpv_cod_tpopr
                                       left join pclub.admpt_punto_venta PV
                                             on caf.admpv_id_canje=pv.admpv_id_canje
                                
                                where 
                                      cf.admpc_estado='A' and
                                      cf.admpv_tipo_doc= tipoDocumento and
                                      cf.admpv_num_doc= numeroDocumento
                                
                             ) a 
                             where rownum <= V_FINAL
                        ) 
                        where  rn  >= V_INICIAL;
              
              if C_CONTADOR > 0 then
              
                      open cur_canje for 
                      --=======MOVIL
                      --Realizando la consulta para los clientes de moviles
                      select codigo_Contrato,numero_Linea,tipo_Premio,producto,puntos,cantidad,Total_Puntos,fecha_Canje,
                             codigo_Punto_Venta,asesor,Nombre_Punto_Venta
                      from 
                      ( select rownum rn, a.* from 
                              (
                              select 
                                      c.admpv_cod_cli as codigo_Contrato,
                                      ca.admpv_num_linea as numero_Linea,
                                      tp.admpv_desc as tipo_Premio,
                                      dc.admpv_desc as producto,
                                      dc.admpn_puntos as puntos,
                                      dc.admpn_cantidad as cantidad,
                                      (dc.admpn_puntos*dc.admpn_cantidad) as Total_Puntos,
                                      ca.admpd_fec_canje as fecha_Canje,
                                      ca.admpv_pto_venta as codigo_Punto_Venta,
                                      ca.admpv_nom_aseso as asesor,
                                      pv.admpv_pto_venta_des Nombre_Punto_Venta
                                      
                               from pclub.admpt_cliente C
                               inner join pclub.admpt_canje CA
                                     on c.admpv_cod_cli=ca.admpv_cod_cli
                               inner join pclub.admpt_canje_detalle DC
                                     on ca.admpv_id_canje=dc.admpv_id_canje
                               inner join pclub.admpt_premio P
                                     on dc.admpv_id_procla=p.admpv_id_procla
                               inner join pclub.admpt_tipo_premio TP
                                      on tp.admpv_cod_tpopr=p.admpv_cod_tpopr
                               left join pclub.admpt_punto_venta PV
                                     on ca.admpv_id_canje =pv.admpv_id_canje
                 
                               where 
                                      c.admpc_estado='A' and
                                      c.admpv_tipo_doc= tipoDocumento and
                                      c.admpv_num_doc= numeroDocumento
                                         
                               
                              UNION ALL
                         --=======FIJA  
                      --Realizando la consulta para los clientes de fija                     
                               select  
                                       cf.admpv_cod_cli as codigo_Contrato,
                                       caf.admpv_num_linea as numero_Linea,
                                       tp.admpv_desc as tipo_Premio,
                                       dcf.admpv_desc as producto,
                                       dcf.admpn_puntos as puntos,
                                       dcf.admpn_cantidad as cantidad,
                                       (dcf.admpn_puntos*dcf.admpn_cantidad) as Total_Puntos,
                                       caf.admpd_fec_canje as fecha_Canje,
                                       caf.admpv_pto_venta as codigo_Punto_Venta,
                                       caf.admpv_nom_aseso as asesor,
                                       pv.admpv_pto_venta_des as Nombre_Punto_Venta
                                       
                               from pclub.admpt_clientefija cf
                                       inner join pclub.admpt_canjefija caf
                                             on cf.admpv_cod_cli=caf.admpv_cod_cli
                                       inner join pclub.admpt_canje_detallefija dcf
                                             on caf.admpv_id_canje=dcf.admpv_id_canje
                                       inner join pclub.admpt_premio P
                                             on dcf.admpv_id_procla=p.admpv_id_procla
                                       inner join pclub.admpt_tipo_premio TP
                                            on tp.admpv_cod_tpopr=p.admpv_cod_tpopr
                                       left join pclub.admpt_punto_venta PV
                                             on caf.admpv_id_canje=pv.admpv_id_canje
                                
                                where 
                                      cf.admpc_estado='A' and
                                      cf.admpv_tipo_doc= tipoDocumento and
                                      cf.admpv_num_doc= numeroDocumento
                                      
                                    
                             ) a 
                             where rownum <= V_FINAL
                        ) 
                        where  rn  >= V_INICIAL;
                        
                                     
                        codeResponse := '0';
                        descriptionResponse := 'OK';
                    else
                      codeResponse := '1';
                        descriptionResponse := 'No hay canjes en la pagina indicada';
                    end if;
               else
                codeResponse := '1';
                descriptionResponse := 'Falta definir tamaño o numero de pagina';
                end if;   
             
             end if; 
                     
           
           else
                codeResponse := '1';
                descriptionResponse := 'Faltan Datos';
           end if;     
            
                       
END SP_HISTORICO;

end PKG_CONSULTA_HISTORICO_CANJE;
/
