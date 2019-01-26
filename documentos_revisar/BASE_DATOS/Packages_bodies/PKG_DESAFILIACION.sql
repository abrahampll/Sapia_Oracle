create or replace package body PCLUB.PKG_DESAFILIACION IS

	procedure sp_desafiliacion
	(
			codigoContrato in varchar2,
			numeroLinea in varchar2,
			estado in varchar2,
			fechaOperacion in date,
			origen in varchar2,
			codigoRespuesta out varchar2,
			mensajeRespuesta out varchar2
	)
	Is

		exc_no_contrato     exception;
        exc_no_estado       exception;
        exc_no_fec_ope      exception;
        exc_no_origen       exception;
		exc_cont_no_existe  exception;
		exc_no_activo       exception;

		v_existe_cont   pls_integer := 0;
        v_tipo_servicio pls_integer := 0;
		v_cliente_aux   pclub.admpt_cliente.admpv_cod_cli%type;
        v_cli_prod_aux  pclub.admpt_clienteproducto.admpv_cod_cli_prod%type;
		v_cod_concepto  pclub.admpt_concepto.admpv_cod_cpto%type;
		v_saldo_cc      pclub.admpt_saldos_cliente.admpn_saldo_cc%type;
		v_idkardex      pclub.admpt_kardex.admpn_id_kardex%type;

		c_coderror      number;
		c_descerror     varchar2(200);
		k_tipodoc       varchar2(20);
		k_numdoc        varchar2(20);
		c_cod_clicup    number;

	begin

        -- Se realizan las validaciones de parametros entrantes

        -- Se valida que se haya digitado codigo de contrato
        if (codigoContrato is null or length(trim(codigoContrato)) = 0) then
            raise exc_no_contrato;
        end if;

        -- Se valida que se haya digitado el estado
        if (estado is null or length(trim(estado)) = 0) then
            raise exc_no_estado;
        end if;

        -- Se valida que se haya digitado la fecha de operación
        if (fechaOperacion is null or length(trim(fechaOperacion)) = 0) then
            raise exc_no_fec_ope;
        end if;

        -- Se valida que se haya digitado el origen
        if (origen is null or length(trim(origen)) = 0) then
            raise exc_no_origen;
        end if;

        -- Se valida que se haya digitado correctamente el estado
        if (upper(estado) <> 'DEACTIVATED') then
            raise exc_no_activo;
        end if;

        -- Verificamos que el contrato exista por lo menos en la tabla Cliente o ClienteFija
        select  count(1)
        into    v_existe_cont
        from    pclub.admpt_cliente
        where   admpv_cod_cli = codigoContrato
                and admpv_cod_tpocl not in ('5','9');

        if v_existe_cont > 0 then
            v_tipo_servicio := 1;
        else
            select  count(1)
            into    v_existe_cont
            from    pclub.admpt_clientefija
            where   admpv_cod_cli = codigoContrato
                    and admpv_cod_tpocl not in ('5','9');

            if v_existe_cont > 0 then
                v_tipo_servicio := 2;
            else
                v_tipo_servicio := 0;
            end if;
        end if;

        -- Condiciones en caso no haya contratos, haya en Cliente o haya en ClienteFija
        case

            -- 1. Caso donde no existe contrato en niguna de las tablas
            when (v_tipo_servicio = 0) then
                raise exc_cont_no_existe;

            -- 2. Caso donde existe contrato en tabla Móviles
            when (v_tipo_servicio = 1) then

                -- Obtenemos el codigo del Concepto por Baja de Cliente
                select  admpv_cod_cpto
                into    v_cod_concepto
                from    pclub.admpt_concepto
                where   upper(admpv_desc) = 'BAJA CLIENTES';

                -- Se busca otra cuenta del mismo cliente
                select
                        min(b.admpv_cod_cli)
                into
                        v_cliente_aux
                from
                        pclub.admpt_cliente a,
                        pclub.admpt_cliente b
                where
                        1=1
                        and a.admpv_tipo_doc = b.admpv_tipo_doc
                        and a.admpv_num_doc = b.admpv_num_doc
                        and a.admpv_cod_tpocl not in ('5','9')
                        and a.admpc_estado = 'A'
                        and b.admpv_cod_tpocl not in ('5','9')
                        and b.admpc_estado = 'A'
                        and a.admpv_cod_cli = codigoContrato
                        and b.admpv_cod_cli <> codigoContrato;

                -- No tiene más contratos
                if v_cliente_aux is null then

                    -- Se busca si tiene saldo para quitarle
                    select	nvl(admpn_saldo_cc, 0)
                    into	v_saldo_cc
                    from	pclub.admpt_saldos_cliente
                    where	admpv_cod_cli = codigoContrato;

                    -- Tiene saldo
                    if v_saldo_cc > 0 then

                        -- genera secuencial de kardex
                        select  pclub.admpt_kardex_sq.nextval
                        into    v_idkardex
                        from    dual;

                        -- insertamos una nueva fila con el concepto de baja de clientes, los puntos en negativo y el tipo operacion es de salida
                        insert into pclub.admpt_kardex (admpn_id_kardex, admpn_cod_cli_ib, admpv_cod_cli, admpd_fec_reg,
                                                        admpv_cod_cpto,admpd_fec_trans,admpn_puntos, admpv_nom_arch,
                                                        admpc_tpo_oper, admpc_tpo_punto, admpn_sld_punto, admpc_estado, admpv_usu_reg)
                        values( v_idkardex, null, codigoContrato, sysdate,
                                v_cod_concepto, fechaOperacion, v_saldo_cc*(-1), null,
                                'S', 'C', 0, 'A', origen);

                        -- actualizamos los saldos a 0 de los registros del kardex segun codigo del cliente y el tipo de cliente (no afectara a interbank)
                        update  pclub.admpt_kardex
                        set     admpn_sld_punto = 0,
                                admpd_fec_mod = fechaOperacion
                        where   admpv_cod_cli = codigoContrato
                                and admpc_tpo_punto in ('C','L')
                                and admpn_sld_punto > 0
                                and admpc_tpo_oper = 'E';

                        -- actualizamos el saldo cc de la tabla segun el codigo del cliente
                        update  pclub.admpt_saldos_cliente
                        set     admpn_saldo_cc = 0,
                                admpn_saldo_ib = 0,
                                admpn_cod_cli_ib = null,
                                admpd_fec_mod = fechaOperacion
                        where   admpv_cod_cli = codigoContrato;

                        -- actualizamos la tabla cliente con el estado 'B'
                        update  pclub.admpt_cliente
                        set     admpc_estado = 'B',
                                admpd_fec_mod = fechaOperacion
                        where   admpv_cod_cli = codigoContrato;

                    end if;

                else -- Tiene más contratos

                    select  admpn_saldo_cc
                    into    v_saldo_cc
                    from    pclub.admpt_saldos_cliente
                    where   admpv_cod_cli = codigoContrato;

                    if v_saldo_cc > 0 then

                        -- Genera secuencial de kardex
                        select  pclub.admpt_kardex_sq.nextval
                        into    v_idkardex
                        from    dual;

                        -- Insertamos una nueva fila con el concepto de baja de clientes, los puntos en negativo y el tipo operacion es de salida
                        insert into pclub.admpt_kardex (admpn_id_kardex, admpn_cod_cli_ib, admpv_cod_cli, admpd_fec_reg,
                                                        admpv_cod_cpto,admpd_fec_trans,admpn_puntos, admpv_nom_arch,
                                                        admpc_tpo_oper, admpc_tpo_punto, admpn_sld_punto, admpc_estado, admpv_usu_reg)
                        values( v_idkardex, null, codigoContrato, sysdate,
                                v_cod_concepto, fechaOperacion, v_saldo_cc*(-1), null,
                                'S', 'C', 0, 'A', origen);

                        -- ACTUALIZAMOS LOS SALDOS A 0 DE LOS REGISTROS DEL KARDEX SEGUN CODIGO DEL CLIENTE Y EL TIPO DE CLIENTE (NO AFECTARA A INTERBANK)
                        update  pclub.admpt_kardex
                        set     admpn_sld_punto = 0,
                                admpd_fec_mod = fechaOperacion
                        where   admpv_cod_cli = codigoContrato
                                and admpc_tpo_punto in ('C','L')
                                and admpn_sld_punto > 0
                                and admpc_tpo_oper = 'E';

                        -- ACTUALIZAMOS EL SALDO CC DE LA TABLA SEGUN EL CODIGO DEL CLIENTE
                        update  pclub.admpt_saldos_cliente
                        set     admpn_saldo_cc = 0,
                                admpn_saldo_ib = 0,
                                admpn_cod_cli_ib = null,
                                admpd_fec_mod = fechaOperacion
                        where   admpv_cod_cli = codigoContrato;

                        -- ACTUALIZAMOS LA TABLA CLIENTE CON EL ESTADO 'B'
                        update  pclub.admpt_cliente
                        set     admpc_estado = 'B',
                                admpd_fec_mod = fechaOperacion
                        where   admpv_cod_cli = codigoContrato;

                        -- Ahora Insertamos el movimiento de ingreso para la otra cuenta
                        select  pclub.admpt_kardex_sq.nextval
                        into    v_idkardex
                        from    dual;

                        -- INSERTAMOS UNA NUEVA FILA CON EL CONCEPTO DE BAJA DE CLIENTES, LOS PUNTOS EN NEGATIVO Y EL TIPO OPERACION ES DE SALIDA
                        insert into pclub.admpt_kardex (admpn_id_kardex, admpn_cod_cli_ib, admpv_cod_cli, admpd_fec_reg,
                                                        admpv_cod_cpto,admpd_fec_trans,admpn_puntos, admpv_nom_arch,
                                                        admpc_tpo_oper, admpc_tpo_punto, admpn_sld_punto, admpc_estado, admpv_usu_reg)
                        values( v_idkardex, null, v_cliente_aux, sysdate,
                                v_cod_concepto, fechaOperacion, v_saldo_cc, null,
                                'E', 'C', v_saldo_cc, 'A', origen);

                        -- ACTUALIZAMOS EL SALDO CC DE LA OTRA CUENTA DEL CLIENTE
                        update  pclub.admpt_saldos_cliente
                        set     admpn_saldo_cc = admpn_saldo_cc + v_saldo_cc,
                                admpd_fec_mod = fechaOperacion
                        where   admpv_cod_cli = v_cliente_aux;

                        -- Los registros de la otra cuenta deben ser actualizados con el código ib
                        update  pclub.admpt_kardex
                        set     admpn_cod_cli_ib = null,
                                admpd_fec_mod = fechaOperacion
                        where   admpv_cod_cli = v_cliente_aux
                                and admpc_tpo_punto in ('C','L')
                                and admpn_sld_punto > 0
                                and admpc_tpo_oper = 'E';

                    end if;

                    begin

                        select	c.admpv_tipo_doc, c.admpv_num_doc
                        into	k_tipodoc, k_numdoc
                        from	pclub.admpt_cliente c
                        where	c.admpv_cod_cli = codigoContrato;

                        /*CUPONERAVIRTUAL - JCGT INI*/
                        pclub.pkg_cc_cuponera.admpsi_bajacliente(k_tipodoc, k_numdoc, 'BAJA', 'USRPOST', c_cod_clicup, c_coderror, c_descerror);
                        /*CUPONERAVIRTUAL - JCGT FIN*/

                    exception
                        when no_data_found then
                            c_coderror:= sqlcode;
                            c_descerror:= substr(sqlerrm,1,200);
                        when others then
                            c_coderror:= sqlcode;
                            c_descerror:= substr(sqlerrm,1,200);
                    end;

                end if;

            -- 3. Caso donde existe contrato en tabla Fijos
            when (v_tipo_servicio = 2) then

                declare

                    cursor c1 is
                    select
                            a.admpv_cod_tpocl,
                            b.admpv_cod_cli_prod,
                            a.admpv_tipo_doc,
                            a.admpv_num_doc,
                            c.admpn_saldo_cc
                    from
                            pclub.admpt_clientefija a,
                            pclub.admpt_clienteproducto b,
                            pclub.admpt_saldos_clientefija c
                    where
                            1=1
                            and a.admpv_cod_cli = b.admpv_cod_cli
                            and a.admpv_cod_cli = codigoContrato
                            and b.admpv_cod_cli_prod = c.admpv_cod_cli_prod
                            and a.admpv_cod_tpocl not in ('5','9')
                            and a.admpc_estado = 'A'
                            and b.admpv_estado_serv = 'A'
                    ;

                begin

                    for x1 in c1 loop

                        select  min(admpv_cod_cli_prod)
                        into    v_cli_prod_aux
                        from    pclub.admpt_clientefija a,
                                pclub.admpt_clienteproducto b
                        where   1=1
                                and a.admpv_cod_cli = b.admpv_cod_cli
                                and a.admpv_cod_cli <> codigoContrato
                                and a.admpv_tipo_doc = x1.admpv_tipo_doc
                                and a.admpv_num_doc = x1.admpv_num_doc
                                and a.admpv_cod_tpocl not in ('5','9')
                                and a.admpc_estado = 'A'
                                and b.admpv_estado_serv = 'A';

                        select  admpv_cod_cpto
                        into    v_cod_concepto
                        from    pclub.admpt_concepto
                        where   (x1.admpv_cod_tpocl = 6 and admpv_desc = 'BAJA CLIENTE DTH')
                                or
                                (x1.admpv_cod_tpocl = 7 and admpv_desc = 'BAJA CLIENTE HFC')
                                or
                                (x1.admpv_cod_tpocl = 3 and admpv_desc = 'BAJA CLIENTE PREPAGO')
                                or
                                (x1.admpv_cod_tpocl = 8 and admpv_desc = 'BAJA CLIENTE TFI')
                                or
                                (x1.admpv_cod_tpocl not in (3,6,7,8) and admpv_desc = 'BAJA CLIENTES');


                        if (x1.admpn_saldo_cc >= 0) then

                            update  pclub.admpt_kardexfija
                            set     admpn_sld_punto = 0,
                                    admpd_fec_mod = fechaOperacion,
                                    admpv_usu_mod = origen
                            where   admpc_tpo_oper = 'E'
                                    and admpc_tpo_punto in ('C','L')
                                    and admpn_sld_punto > 0
                                    and admpv_cod_cli_prod = x1.admpv_cod_cli_prod;

                            if x1.admpn_saldo_cc > 0 then

                                insert into pclub.admpt_kardexfija (admpn_id_kardex, admpv_cod_cli_prod, admpv_cod_cpto, admpd_fec_trans,
                                                                    admpn_puntos, admpc_tpo_oper, admpc_tpo_punto, admpn_sld_punto,
                                                                    admpc_estado, admpv_usu_reg, admpd_fec_reg, admpv_nom_arch)
                                values (pclub.admpt_kardexfija_sq.nextval, x1.admpv_cod_cli_prod, v_cod_concepto, fechaOperacion,
                                        x1.admpn_saldo_cc*(-1), 'S', 'C', 0,
                                        'A', origen, sysdate, null);
                            end if;

                            --Se actualiza la tabla saldos_cliente al cliente
                            update  pclub.admpt_saldos_clientefija
                            set     admpn_saldo_cc = 0,
                                    admpc_estpto_cc = 'B',
                                    admpd_fec_mod = fechaOperacion,
                                    admpv_usu_mod = origen
                            where   admpv_cod_cli_prod = x1.admpv_cod_cli_prod;

                            -- Se actualiza tabla Cliente Producto
                            update  pclub.admpt_clienteproducto
                            set     admpv_estado_serv = 'B',
                                    admpd_fec_mod = fechaOperacion,
                                    admpv_usu_mod = origen
                            where   admpv_cod_cli_prod = x1.admpv_cod_cli_prod;

                            -- Se actualiza tabla Cliente Fija
                            update  pclub.admpt_clientefija
                            set     admpc_estado = 'B',
                                    admpd_fec_mod = fechaOperacion,
                                    admpv_usu_mod = origen
                            where   admpv_cod_cli = codigoContrato;

                            -- Cliente tiene otras cuentas
                            if v_cli_prod_aux is not null then

                                --INSERTA EN EL KARDEX LOS PUNTOS AL CLIENTE DE TRASPASO
                                if x1.admpn_saldo_cc > 0 then

                                    insert into pclub.admpt_kardexfija (admpn_id_kardex, admpv_cod_cli_prod, admpv_cod_cpto, admpd_fec_trans,
                                                                        admpn_puntos, admpc_tpo_oper, admpc_tpo_punto, admpn_sld_punto,
                                                                        admpc_estado, admpv_usu_reg, admpd_fec_reg, admpv_nom_arch)
                                    values( pclub.admpt_kardexfija_sq.nextval, v_cli_prod_aux, v_cod_concepto, fechaOperacion,
                                            x1.admpn_saldo_cc, 'E', 'C', x1.admpn_saldo_cc,
                                            'A', origen, sysdate, null);
                                end if;

                                --SE ACTUALIZA EL SALDO DEL CLIENTE EN LA TABLA PCLUB.ADMPT_SALDOS_CLIENTE DEL CLIENTE DE TRASPASO
                                update  pclub.admpt_saldos_clientefija
                                set     admpn_saldo_cc = admpn_saldo_cc + x1.admpn_saldo_cc,
                                        admpc_estpto_cc = 'A',
                                        admpd_fec_mod = fechaOperacion,
                                        admpv_usu_mod = origen
                                where   admpv_cod_cli_prod = v_cli_prod_aux;

                            else

                                /*CUPONERAVIRTUAL - JCGT INI*/
                                pclub.pkg_cc_cuponera.admpsi_bajacliente (x1.admpv_tipo_doc, x1.admpv_num_doc, 'BAJA', origen, c_cod_clicup, c_coderror, c_descerror);
                                /*CUPONERAVIRTUAL - JCGT FIN*/

                            end if;

                        end if;

                    end loop;

                end;

        end case;

        --Se actualiza tabla Contratos en caso cliente exista en esta tabla
        update  pclub.admpt_contratos
        set     admpv_estado = 'B',
                admpd_fechamodifica = fechaOperacion
        where   admpv_codigocontrato = codigoContrato;

		codigoRespuesta := '0';
		mensajeRespuesta := 'Transaction OK';

	exception

		when exc_no_contrato then
			codigoRespuesta := '1';
			mensajeRespuesta := 'Es necesario ingresar el contrato';

		when exc_no_estado then
			codigoRespuesta := '1';
			mensajeRespuesta := 'Es necesario ingresar el estado';

		when exc_no_fec_ope then
			codigoRespuesta := '1';
			mensajeRespuesta := 'Es necesario ingresar la fecha de operación';

		when exc_no_origen then
			codigoRespuesta := '1';
			mensajeRespuesta := 'Es necesario ingresar el origen';

		when exc_cont_no_existe then
			codigoRespuesta := '1';
			mensajeRespuesta := 'Contrato no existe';

		when exc_no_activo then
			codigoRespuesta := '1';
			mensajeRespuesta := 'Es necesario ingresar el estado correcto';

     when others then
      codigoRespuesta := '1';
			mensajeRespuesta := 'Se ha presentado un error no previsto, consultar con el programador';

    end sp_desafiliacion;

end PKG_DESAFILIACION;
/