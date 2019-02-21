insert into PCLUB.admpt_concepto (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO)
values ('24', 'TRANSFERENCIA BONUS A CLARO', 'A', 'BONUS_INGRESO_YYYYMMDD.CCL', 18, 'C');

insert into PCLUB.admpt_concepto (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO)
values ('25', 'TRANSFERENCIA CLARO A BONUS', 'A', 'BONUS_SALIDA_YYYYMMDD.CCL', null, 'C');

commit;

insert into PCLUB.admpt_paramsist (ADMPC_COD_PARAM, ADMPV_DESC, ADMPV_VALOR)
values ('18', 'UNIDAD_CONVERSION_BONO_A_CC', '0.9');

insert into PCLUB.admpt_paramsist (ADMPC_COD_PARAM, ADMPV_DESC, ADMPV_VALOR)
values ('19', 'CONS_VALID_CC_A_BONUS', '360,90');

insert into PCLUB.admpt_paramsist (ADMPC_COD_PARAM, ADMPV_DESC, ADMPV_VALOR)
values ('20', 'CONS_VALID_BONUS_A_CC', '400,100');

commit;

