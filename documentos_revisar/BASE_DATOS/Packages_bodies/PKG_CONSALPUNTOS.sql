create or replace package body PCLUB.PKG_CONSALPUNTOS is

procedure sp_ConsultarSaldoPuntos
(
    tipodocumento                   in integer,
    numeroDocumento                 in varchar2,
    tamanioPagina                   in integer,
    numeroPagina                    in integer,
    flagDetallePuntos               in integer,
    tipoPuntoDetalle                in integer,            
    codigorespuesta                 out varchar2,
    mensajerespuesta                out varchar2,
    cur_saldoacumulado              out SYS_REFCURSOR,
    cur_detallePuntosRegulares      out SYS_REFCURSOR,
    cur_detallePuntosPromocionales  out SYS_REFCURSOR
)
is
    
    v_tot_saldo         number := 0;
    v_reg_point         number := 0;
    v_pro_point         number := 0;
    v_reg_due_point     number := 0;
    v_reg_due_date      date;
    v_pro_due_point     number := 0;
    v_pro_due_date      date;
    v_existe_movil      number := 0;
    v_existe_fija       number := 0;
    v_pag_ini           number := 0;
    v_pag_fin           number := 0;
    v_contract_code     varchar2(40);
    v_line_number       varchar2(20);
    v_subs_name         varchar2(100);
    v_act_point         number;
    v_due_point         number;
    v_due_date          date;
    v_tipo_documento    varchar2(20);
    
begin
    
    v_tipo_documento := to_char(tipodocumento);
    
    if (v_tipo_documento is null or v_tipo_documento = '') then
        codigorespuesta := '1';
        mensajerespuesta := 'No se ha digitado el tipo de documento';
        return;
    end if;
    if (numeroDocumento is null or numeroDocumento = '') then
        codigorespuesta := '1';
        mensajerespuesta := 'No se ha digitado el número de documento';
        return;
    end if;
    if (tamanioPagina is null or tamanioPagina < 1) then
        codigorespuesta := '1';
        mensajerespuesta := 'Por favor ingrese un número de filas mayor a 0';
        return;
    end if;
    if (numeroPagina is null or numeroPagina < 1) then
        codigorespuesta := '1';
        mensajerespuesta := 'Por favor ingrese un número de páginas mayor a 0';
        return;
    end if;
    if (flagDetallePuntos is null or flagDetallePuntos not in ('0','1')) then
        codigorespuesta := '1';
        mensajerespuesta := 'Por favor ingrese un valor entre 0 y 1';
        return;
    end if;
    if (tipoPuntoDetalle is null or tipoPuntoDetalle not in ('1','2')) then
        codigorespuesta := '1';
        mensajerespuesta := 'Por favor ingrese un valor entre 1 y 2';
        return;
    end if;
    
    select  count(*)
    into    v_existe_movil
    from    pclub.admpt_cliente
    where   1=1
            and admpv_tipo_doc = v_tipo_documento
            and admpv_num_doc = numeroDocumento;
    
    select  count(*)
    into    v_existe_fija
    from    pclub.admpt_clientefija
    where   1=1
            and admpv_tipo_doc = v_tipo_documento
            and admpv_num_doc = numeroDocumento;
    
    v_tot_saldo := 0;
    v_reg_point := 0;
    v_pro_point := 0;
    v_reg_due_point := 0;
    v_pro_due_point := 0;
    
    case
    
        when (v_existe_movil = 0 and v_existe_fija = 0) then
        
            codigorespuesta := '1';
            mensajerespuesta := 'No se ha encontrado ningún contrato con el número de documento '||numeroDocumento;
            return;
        
        when (v_existe_movil > 0 and v_existe_fija = 0) then
        
            select  sum(b.admpn_saldo_cc)
            into    v_tot_saldo
            from    pclub.admpt_cliente a,
                    pclub.admpt_saldos_cliente b
            where   1=1
                    and a.admpv_cod_cli = b.admpv_cod_cli
                    and a.admpv_tipo_doc = v_tipo_documento
                    and a.admpv_num_doc = numeroDocumento
            ;
        
            select
                    sum(case
                            when upper(b.admpc_estado) = 'A' and upper(b.admpc_tpo_oper) = 'E' and upper(b.admpc_tpo_punto) = 'C'
                            then b.admpn_sld_punto
                            else 0
                        end),
                    sum(case
                            when upper(b.admpc_estado) = 'A' and upper(b.admpc_tpo_oper) = 'E' and upper(b.admpc_tpo_punto) = 'A'
                            then b.admpn_sld_punto
                            else 0
                        end),
                    min(case
                            when upper(b.admpc_estado) = 'A' and upper(b.admpc_tpo_oper) = 'E' and upper(b.admpc_tpo_punto) = 'C'
                            then b.admpd_fec_trans
                            else null
                        end),
                    min(case
                            when upper(b.admpc_estado) = 'A' and upper(b.admpc_tpo_oper) = 'E' and upper(b.admpc_tpo_punto) = 'A'
                            then b.admpd_fec_trans
                            else null
                        end)
            into
                    v_reg_point,
                    v_pro_point,
                    v_reg_due_date,
                    v_pro_due_date
            from
                    pclub.admpt_cliente a,
                    pclub.admpt_kardex b
            where
                    1=1
                    and a.admpv_cod_cli = b.admpv_cod_cli
                    and a.admpv_tipo_doc = v_tipo_documento
                    and a.admpv_num_doc = numeroDocumento
            ;
        
            select
                    sum(case
                            when upper(b.admpc_estado) = 'A' and upper(b.admpc_tpo_oper) = 'E' and upper(b.admpc_tpo_punto) = 'C' and b.admpd_fec_trans = v_reg_due_date
                            then b.admpn_sld_punto
                            else 0
                        end),
                    sum(case
                            when upper(b.admpc_estado) = 'A' and upper(b.admpc_tpo_oper) = 'E' and upper(b.admpc_tpo_punto) = 'A' and b.admpd_fec_trans = v_pro_due_date
                            then b.admpn_sld_punto
                            else 0
                        end)
            into
                    v_reg_due_point,
                    v_pro_due_point
            from
                    pclub.admpt_cliente a,
                    pclub.admpt_kardex b
            where
                    1=1
                    and a.admpv_cod_cli = b.admpv_cod_cli
                    and a.admpv_tipo_doc = v_tipo_documento
                    and a.admpv_num_doc = numeroDocumento
            ;
        
        when (v_existe_movil = 0 and v_existe_fija > 0) then
        
            select  sum(c.admpn_saldo_cc)
            into    v_tot_saldo
            from    pclub.admpt_clientefija a,
                    pclub.admpt_clienteproducto b,
                    pclub.admpt_saldos_clientefija c
            where   1=1
                    and a.admpv_cod_cli = b.admpv_cod_cli
                    and b.admpv_cod_cli_prod = c.admpv_cod_cli_prod
                    and a.admpv_tipo_doc = v_tipo_documento
                    and a.admpv_num_doc = numeroDocumento
            ;
            
            select
                    sum(case
                            when upper(c.admpc_estado) = 'A' and upper(c.admpc_tpo_oper) = 'E' and upper(c.admpc_tpo_punto) = 'C'
                            then c.admpn_sld_punto
                            else 0
                        end),
                    sum(case
                            when upper(c.admpc_estado) = 'A' and upper(c.admpc_tpo_oper) = 'E' and upper(c.admpc_tpo_punto) = 'A'
                            then c.admpn_sld_punto
                            else 0
                        end),
                    min(case
                            when upper(c.admpc_estado) = 'A' and upper(c.admpc_tpo_oper) = 'E' and upper(c.admpc_tpo_punto) = 'C'
                            then c.admpd_fec_trans
                            else null
                        end),
                    min(case
                            when upper(c.admpc_estado) = 'A' and upper(c.admpc_tpo_oper) = 'E' and upper(c.admpc_tpo_punto) = 'A'
                            then c.admpd_fec_trans
                            else null
                        end)
            into
                    v_reg_point,
                    v_pro_point,
                    v_reg_due_date,
                    v_pro_due_date
            from
                    pclub.admpt_clientefija a,
                    pclub.admpt_clienteproducto b,
                    pclub.admpt_kardexfija c
            where
                    1=1
                    and a.admpv_cod_cli = b.admpv_cod_cli
                    and b.admpv_cod_cli_prod = c.admpv_cod_cli_prod
                    and a.admpv_tipo_doc = v_tipo_documento
                    and a.admpv_num_doc = numeroDocumento
            ;
            
            select
                    sum(case
                            when upper(c.admpc_estado) = 'A' and upper(c.admpc_tpo_oper) = 'E' and upper(c.admpc_tpo_punto) = 'C' and c.admpd_fec_trans = v_reg_due_date
                            then c.admpn_sld_punto
                            else 0
                        end) puntos_reg,
                    sum(case
                            when upper(c.admpc_estado) = 'A' and upper(c.admpc_tpo_oper) = 'E' and upper(c.admpc_tpo_punto) = 'A' and c.admpd_fec_trans = v_reg_due_date
                            then c.admpn_sld_punto
                            else 0
                        end) puntos_pro
            into
                    v_reg_point,
                    v_pro_point
            from
                    pclub.admpt_clientefija a,
                    pclub.admpt_clienteproducto b,
                    pclub.admpt_kardexfija c
            where
                    1=1
                    and a.admpv_cod_cli = b.admpv_cod_cli
                    and b.admpv_cod_cli_prod = c.admpv_cod_cli_prod
                    and a.admpv_tipo_doc = v_tipo_documento
                    and a.admpv_num_doc = numeroDocumento
            ;
        
        when (v_existe_movil > 0 and v_existe_fija > 0) then
        
            select  sum(admpn_saldo_cc)
            into    v_tot_saldo
            from    (
                        select  admpn_saldo_cc
                        from    pclub.admpt_cliente a,
                                pclub.admpt_saldos_cliente b
                        where   1=1
                                and a.admpv_cod_cli = b.admpv_cod_cli
                                and a.admpv_tipo_doc = v_tipo_documento
                                and a.admpv_num_doc = numeroDocumento
                                
                        union all
                        
                        select  admpn_saldo_cc
                        from    pclub.admpt_clientefija a,
                                pclub.admpt_clienteproducto b,
                                pclub.admpt_saldos_clientefija c
                        where   1=1
                                and a.admpv_cod_cli = b.admpv_cod_cli
                                and b.admpv_cod_cli_prod = c.admpv_cod_cli_prod
                                and a.admpv_tipo_doc = v_tipo_documento
                                and a.admpv_num_doc = numeroDocumento
                    )
            ;
            
            select
                    sum(case
                            when upper(admpc_estado) = 'A' and upper(admpc_tpo_oper) = 'E' and upper(admpc_tpo_punto) = 'C'
                            then admpn_sld_punto
                            else 0
                        end),
                    sum(case
                            when upper(admpc_estado) = 'A' and upper(admpc_tpo_oper) = 'E' and upper(admpc_tpo_punto) = 'A'
                            then admpn_sld_punto
                            else 0
                        end),
                    min(case
                            when upper(admpc_estado) = 'A' and upper(admpc_tpo_oper) = 'E' and upper(admpc_tpo_punto) = 'C'
                            then admpd_fec_trans
                            else null
                        end),
                    min(case
                            when upper(admpc_estado) = 'A' and upper(admpc_tpo_oper) = 'E' and upper(admpc_tpo_punto) = 'A'
                            then admpd_fec_trans
                            else null
                        end)
            into
                    v_reg_point,
                    v_pro_point,
                    v_reg_due_date,
                    v_pro_due_date
            from
                    (
                        select
                                b.admpc_estado,
                                b.admpc_tpo_oper,
                                b.admpc_tpo_punto,
                                b.admpn_sld_punto,
                                b.admpd_fec_trans
                        from
                                pclub.admpt_cliente a,
                                pclub.admpt_kardex b
                        where
                                1=1
                                and a.admpv_cod_cli = b.admpv_cod_cli
                                and a.admpv_tipo_doc = v_tipo_documento
                                and a.admpv_num_doc = numeroDocumento
                                
                        union all
                        
                        select
                                c.admpc_estado,
                                c.admpc_tpo_oper,
                                c.admpc_tpo_punto,
                                c.admpn_sld_punto,
                                c.admpd_fec_trans
                        from
                                pclub.admpt_clientefija a,
                                pclub.admpt_clienteproducto b,
                                pclub.admpt_kardexfija c
                        where
                                1=1
                                and a.admpv_cod_cli = b.admpv_cod_cli
                                and b.admpv_cod_cli_prod = c.admpv_cod_cli_prod
                                and a.admpv_tipo_doc = v_tipo_documento
                                and a.admpv_num_doc = numeroDocumento
                    )
            ;
            
            select
                    sum(case
                            when admpc_estado = 'A' and admpc_tpo_oper = 'E' and admpc_tpo_punto = 'C' and admpd_fec_trans = v_reg_due_date
                            then admpn_sld_punto
                            else 0
                        end),
                    sum(case
                            when admpc_estado = 'A' and admpc_tpo_oper = 'E' and admpc_tpo_punto = 'A' and admpd_fec_trans = v_pro_due_date
                            then admpn_sld_punto
                            else 0
                        end)
            into
                    v_reg_due_point,
                    v_pro_due_point
            from
                    (
                        select
                                b.admpc_estado,
                                b.admpc_tpo_oper,
                                b.admpc_tpo_punto,
                                b.admpd_fec_trans,
                                b.admpn_sld_punto
                        from
                                pclub.admpt_cliente a,
                                pclub.admpt_kardex b
                        where
                                1=1
                                and a.admpv_cod_cli = b.admpv_cod_cli
                                and a.admpv_tipo_doc = v_tipo_documento
                                and a.admpv_num_doc = numeroDocumento
                        
                        union all
                        
                        select
                                c.admpc_estado,
                                c.admpc_tpo_oper,
                                c.admpc_tpo_punto,
                                c.admpd_fec_trans,
                                c.admpn_sld_punto
                        from
                                pclub.admpt_clientefija a,
                                pclub.admpt_clienteproducto b,
                                pclub.admpt_kardexfija c
                        where
                                1=1
                                and a.admpv_cod_cli = b.admpv_cod_cli
                                and b.admpv_cod_cli_prod = c.admpv_cod_cli_prod
                                and a.admpv_tipo_doc = v_tipo_documento
                                and a.admpv_num_doc = numeroDocumento
                    )
            ;
        
    end case;

    open cur_saldoacumulado for
    select
            v_tot_saldo         as saldo_total,
            v_reg_point         as pts_reg,
            v_pro_point         as pts_prom,
            v_reg_due_point     as pts_reg_x_vencer,
            v_reg_due_date      as fch_pts_reg_x_vencer,
            v_pro_due_point     as pts_prom_x_vencer,
            v_pro_due_date      as fch_pts_prom_x_vencer
    from
            dual;

    if (flagDetallePuntos = 1) then
        
        v_pag_ini := tamanioPagina*(numeroPagina-1)+1;
        v_pag_fin := tamanioPagina*numeroPagina;
        
        if (tipoPuntoDetalle = 1) then
            
            open cur_detallePuntosRegulares for
            select
                    cod_contrato,
                    num_linea,
                    puntos_vigentes,
                    puntos_por_vencer,
                    fecha_vencimiento,
                    estado_migracion,
                    tipo_linea
            from
                    (
                        select
                                z.*,
                                rownum fila
                        from
                                (
                                    select
                                            a.admpv_cod_cli as cod_contrato,
                                            c.admpv_numerolinea as num_linea,
                                            v_reg_point as puntos_vigentes,
                                            b.admpn_sld_punto as puntos_por_vencer,
                                            b.admpd_fec_trans as fecha_vencimiento,
                                            decode(c.admpv_codigocontrato, null, 0, 1) as estado_migracion,
                                            a.admpv_cod_tpocl as tipo_linea
                                    from
                                            pclub.admpt_cliente a,
                                            pclub.admpt_kardex b,
                                            pclub.admpt_contratos c
                                    where
                                            1=1
                                            and a.admpv_cod_cli = b.admpv_cod_cli
                                            and a.admpv_cod_cli = c.admpv_codigocontrato(+)
                                            and a.admpv_tipo_doc = v_tipo_documento
                                            and a.admpv_num_doc = numeroDocumento
                                            and b.admpc_estado = 'A'
                                            and b.admpc_tpo_oper = 'E'
                                            and b.admpc_tpo_punto = 'C'
                                    
                                    union all
                                    
                                    select
                                            a.admpv_cod_cli as cod_contrato,
                                            d.admpv_numerolinea as num_linea,
                                            v_reg_point as puntos_vigentes,
                                            c.admpn_sld_punto as puntos_por_vencer,
                                            c.admpd_fec_trans as fecha_vencimiento,
                                            decode(d.admpv_codigocontrato, null, 0, 1) as estado_migracion,
                                            a.admpv_cod_tpocl as tipo_linea
                                    from
                                            pclub.admpt_clientefija a,
                                            pclub.admpt_clienteproducto b,
                                            pclub.admpt_kardexfija c,
                                            pclub.admpt_contratos d
                                    where
                                            1=1
                                            and a.admpv_cod_cli = b.admpv_cod_cli
                                            and b.admpv_cod_cli_prod = c.admpv_cod_cli_prod
                                            and a.admpv_cod_cli = d.admpv_codigocontrato(+)
                                            and a.admpv_tipo_doc = v_tipo_documento
                                            and a.admpv_num_doc = numeroDocumento
                                            and c.admpc_estado = 'A'
                                            and c.admpc_tpo_oper = 'E'
                                            and c.admpc_tpo_punto = 'C'
                                ) z
                    )
            where
                    fila between v_pag_ini and v_pag_fin
            ;
            
        end if;
        
        if (tipoPuntoDetalle = 2) then
            
            open cur_detallePuntosPromocionales for
            select
                    cod_contrato,
                    num_linea,
                    puntos_vigentes,
                    puntos_por_vencer,
                    fecha_vencimiento,
                    estado_migracion,
                    tipo_linea
            from
                    (
                        select
                                z.*,
                                rownum fila
                        from
                                (
                                    select
                                            a.admpv_cod_cli as cod_contrato,
                                            c.admpv_numerolinea as num_linea,
                                            v_pro_point as puntos_vigentes,
                                            b.admpn_sld_punto as puntos_por_vencer,
                                            b.admpd_fec_trans as fecha_vencimiento,
                                            decode(c.admpv_codigocontrato, null, 0, 1) as estado_migracion,
                                            a.admpv_cod_tpocl as tipo_linea
                                    from
                                            pclub.admpt_cliente a,
                                            pclub.admpt_kardex b,
                                            pclub.admpt_contratos c
                                    where
                                            1=1
                                            and a.admpv_cod_cli = b.admpv_cod_cli
                                            and a.admpv_cod_cli = c.admpv_codigocontrato(+)
                                            and a.admpv_tipo_doc = v_tipo_documento
                                            and a.admpv_num_doc = numeroDocumento
                                            and b.admpc_estado = 'A'
                                            and b.admpc_tpo_oper = 'E'
                                            and b.admpc_tpo_punto = 'A'
                                    
                                    union all
                                    
                                    select
                                            a.admpv_cod_cli as cod_contrato,
                                            d.admpv_numerolinea as num_linea,
                                            v_pro_point as puntos_vigentes,
                                            c.admpn_sld_punto as puntos_por_vencer,
                                            c.admpd_fec_trans as fecha_vencimiento,
                                            decode(d.admpv_codigocontrato, null, 0, 1) estado_migracion,
                                            a.admpv_cod_tpocl tipo_linea
                                    from
                                            pclub.admpt_clientefija a,
                                            pclub.admpt_clienteproducto b,
                                            pclub.admpt_kardexfija c,
                                            pclub.admpt_contratos d
                                    where
                                            1=1
                                            and a.admpv_cod_cli = b.admpv_cod_cli
                                            and b.admpv_cod_cli_prod = c.admpv_cod_cli_prod
                                            and a.admpv_cod_cli = d.admpv_codigocontrato(+)
                                            and a.admpv_tipo_doc = v_tipo_documento
                                            and a.admpv_num_doc = numeroDocumento
                                            and c.admpc_estado = 'A'
                                            and c.admpc_tpo_oper = 'E'
                                            and c.admpc_tpo_punto = 'A'
                                ) z
                    )
            where
                    fila between v_pag_ini and v_pag_fin
            ;
            
        end if;
    
    end if;
    
    codigorespuesta := '0';
    mensajerespuesta := 'Transacción OK';
    
exception

    when others then
        codigorespuesta := '1';
        mensajerespuesta := 'Se ha presentado un error no previsto, contactar al area de TI';
    
END sp_ConsultarSaldoPuntos;

end PKG_CONSALPUNTOS;
/