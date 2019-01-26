-- Parametros
insert into PCLUB.ADMPT_PARAMSIST (ADMPC_COD_PARAM, ADMPV_DESC, ADMPV_VALOR)
values ('10 ', 'DIAS_VENCIMIENTO_PAGO_CC', '5');
insert into PCLUB.ADMPT_PARAMSIST (ADMPC_COD_PARAM, ADMPV_DESC, ADMPV_VALOR)
values ('5  ', 'PUNTOS_ALTA_CONTRATO', '50');
insert into PCLUB.ADMPT_PARAMSIST (ADMPC_COD_PARAM, ADMPV_DESC, ADMPV_VALOR)
values ('6  ', 'PUNTOS_RENOVACION_CONTRATO', '100');
commit;


-- Conceptos
insert into PCLUB.ADMPT_CONCEPTO (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO)
values ('21', 'NO FACTURADOS CC', 'A', 'NO_FACTURADOS_YYYYMMDD.CCL', null, 'C');
insert into PCLUB.ADMPT_CONCEPTO (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO)
values ('23', 'ALTA DE CLIENTES', 'A', 'ALTA_CLIENTES_YYYYMMDD.CCL', null, 'C');
insert into PCLUB.ADMPT_CONCEPTO (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO)
values ('26', 'LLAMADAS INTERNACIONALES', 'A', null, null, 'C');
commit;

-- Tipos de Documento
insert into PCLUB.admpt_tipo_doc
  (admpv_cod_tpdoc, admpv_dsc_docum, admpv_cod_equiv)
values
  ('5', 'Carnet de Identidad', null);
commit;

-- Vencimiento de Puntos

UPDATE PCLUB.admpt_concepto SET ADMPN_PER_CADU = 18 WHERE ADMPV_COD_CPTO in ('1','11','12','13','17','18','19','22','23','24','26','4','5','7','8','9');
commit;

-- tipo plan
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(10001,'TUN 2 plan 39',39);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(10002,'TUN 2 plan 59',59);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(10003,'TUN 2 plan 79',79);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(10004,'TUN 2 plan 99',99);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(10005,'TUN 2 plan 149',149);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(10006,'TUN 2 plan 199',199);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(10007,'TUN 2 plan 249',249);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(10008,'TUN 2 plan 319',319);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(10009,'TUN 2 plan 20',20);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(10010,'TUN 2 plan 25',25);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(10011,'TUN 2 plan 29',29);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(20001,'Plan Increible 90',0);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(20002,'Plan Increible 125',0);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(20003,'Plan Increible 175',0);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(20004,'Plan Increible 230',0);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(20005,'Plan Increible 335',0);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(30001,'Plan Iphone 0',143);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(30002,'Plan Iphone 1',186);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(30003,'Plan Iphone 2',244);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(30004,'Plan Iphone 3',301);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(30005,'Plan Iphone Ilimitado',474);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(40001,'Smart BB 69',69);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(40002,'Smart BB 99',99);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(40003,'Smart BB 129',129);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(40004,'Smart BB 149',149);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(40005,'Smart BB 159',159);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(50001,'Smart i 69',69);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(50002,'Smart i 99',99);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(50003,'Smart i 129',129);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(50004,'Smart i 149',149);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(50005,'Smart i 159',159);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(60001,'Combo RPC 49',0);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(60002,'Combo RPC 74',0);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(60003,'Combo RPC 79',0);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(60004,'Combo RPC 99',0);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(70001,'HABLA CLARO 2 plan 39',39);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(70002,'HABLA CLARO 2 plan 59',59);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(70003,'HABLA CLARO 2 plan 79',79);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(70004,'HABLA CLARO 2 plan 99',99);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(70005,'HABLA CLARO 2 plan 149',149);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(70006,'HABLA CLARO 2 plan 199',199);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(70007,'HABLA CLARO 2 plan 249',249);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(70008,'HABLA CLARO 2 plan 319',319);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(70009,'HABLA CLARO 2 plan 20',20);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(70010,'HABLA CLARO 2 plan 25',25);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(70011,'HABLA CLARO 2 plan 29',29);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(80001,'Internet Claro Ilimitado 1000',129);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(80002,'Internet Claro Ilimitado 1500',199);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(80003,'Internet Claro Ilimitado 700',99);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(80004,'Internet Claro Limitado 10GB',199);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(80005,'Internet Claro Limitado 2GB',79);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(80006,'Internet Claro Limitado 3GB',99);
insert into pclub.admpt_tipo_plan (admpn_cod_plan, admpv_des_plan, admpn_ptorencon) values(80007,'Internet Claro Limitado 5GB',129);
commit;