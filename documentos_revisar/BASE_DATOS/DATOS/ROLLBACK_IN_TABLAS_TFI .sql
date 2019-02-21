delete PCLUB.admpt_concepto
where admpv_cod_cpto in ('83','84','85','86','87','88','89','90','91','92','93');

delete PCLUB.admpt_paramsist
where admpc_cod_param in ('230','231');

delete PCLUB.admpt_transac_x_cliente
where admpv_cod_tpocl = '8';

delete PCLUB.admpt_tipo_premclie
where admpv_cod_tpocl = '8';

delete PCLUB.admpt_premio
where admpv_cod_tpopr in ('33');

delete PCLUB.admpt_tipo_premio
where admpv_cod_tpopr in ('33');

delete PCLUB.admpt_cat_cliente
where admpn_cod_catcli in (1,2) and admpv_cod_tpocl='8';

delete PCLUB.admpt_tipo_cliente
where admpv_cod_tpocl = '8';

commit;
