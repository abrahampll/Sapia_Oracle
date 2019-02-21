insert into PCLUB.admpt_concepto (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO, ADMPV_TPO_CPTO, ADMPC_TPO_OPER)
values ('83', 'RECARGAS TFI', 'A', '', 18, 'C', 'TFI', '');
insert into PCLUB.admpt_concepto (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO, ADMPV_TPO_CPTO, ADMPC_TPO_OPER)
values ('84', 'PROMOCION TFI', 'A', '', 18, 'C', 'TFI', '');
insert into PCLUB.admpt_concepto (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO, ADMPV_TPO_CPTO, ADMPC_TPO_OPER)
values ('85', 'REGULARIZACION TFI', 'A', '', 18, 'C', 'TFI', '');
insert into PCLUB.admpt_concepto (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO, ADMPV_TPO_CPTO, ADMPC_TPO_OPER)
values ('86', 'CAMBIO TITULARIDAD TFI', 'A', '', 18, 'C', 'TFI', 'S ');
insert into PCLUB.admpt_concepto (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO, ADMPV_TPO_CPTO, ADMPC_TPO_OPER)
values ('87', 'VENCIMIENTO DE PUNTOS TFI', 'A', '', 18, 'C', 'TFI', '');
insert into PCLUB.admpt_concepto (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO, ADMPV_TPO_CPTO, ADMPC_TPO_OPER)
values ('88', 'ANIVERSARIO TFI', 'A', '', 18, 'C', 'TFI', '');
insert into PCLUB.admpt_concepto (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO, ADMPV_TPO_CPTO, ADMPC_TPO_OPER)
values ('89', 'SIN RECARGAS TFI', 'A', '', 12, 'C', 'TFI', '');
insert into PCLUB.admpt_concepto (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO, ADMPV_TPO_CPTO, ADMPC_TPO_OPER)
values ('90', 'CANJE TFI', 'A', '', null, 'C', 'TFI', 'S ');
insert into PCLUB.admpt_concepto (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO, ADMPV_TPO_CPTO, ADMPC_TPO_OPER)
values ('91', 'DEVOLUCION CANJE TFI', 'A', '', null, 'C', 'TFI', 'E ');
insert into PCLUB.admpt_concepto (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO, ADMPV_TPO_CPTO, ADMPC_TPO_OPER)
values ('92', 'BAJA CLIENTE TFI', 'A', '', null, 'C', 'TFI', 'S ');
insert into PCLUB.admpt_concepto (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO, ADMPV_TPO_CPTO, ADMPC_TPO_OPER)
values ('93', 'INGRESO POR BAJA CLIENTE TFI', 'A', '', 18, 'C', 'TFI', '');

insert into PCLUB.admpt_paramsist (ADMPC_COD_PARAM, ADMPV_DESC, ADMPV_VALOR) values ('230', 'PUNTOS_RECARGA_TFI', '3');
insert into PCLUB.admpt_paramsist (ADMPC_COD_PARAM, ADMPV_DESC, ADMPV_VALOR) values ('231', 'PUNTOS_ANIVERSARIO_TFI', '100');

insert into PCLUB.admpt_tipo_cliente (ADMPV_COD_TPOCL, ADMPV_DESC, ADMPC_ESTADO)
values ('8', 'TFI PREPAGO', 'A');

insert into PCLUB.admpt_tipo_premio (ADMPV_COD_TPOPR, ADMPV_DESC, ADMPC_ESTADO, ADMPN_ORDEN)
values ('33', 'Servicio TFI', 'A', 9);

insert into PCLUB.admpt_transac_x_cliente (ADMPV_TRANSACCION, ADMPV_COD_TPOCL) values ('TRANSACCION_PROMO_REGULARIZ', '8');
insert into PCLUB.admpt_transac_x_cliente (ADMPV_TRANSACCION, ADMPV_COD_TPOCL) values ('TRANSACCION_CANJE_MOVIL', '8');
insert into PCLUB.admpt_transac_x_cliente (ADMPV_TRANSACCION, ADMPV_COD_TPOCL) values ('TRANSACCION_CON_CANJE', '8');
insert into PCLUB.admpt_transac_x_cliente (ADMPV_TRANSACCION, ADMPV_COD_TPOCL) values ('TRANSACCION_DEVOLUC', '8');
insert into PCLUB.admpt_transac_x_cliente (ADMPV_TRANSACCION, ADMPV_COD_TPOCL) values ('TRANSACCION_ESTADO_CUENTA', '8');

insert into PCLUB.admpt_tipo_premclie (ADMPV_COD_TPOPR, ADMPV_COD_TPOCL) values ('29', '8');
insert into PCLUB.admpt_tipo_premclie (ADMPV_COD_TPOPR, ADMPV_COD_TPOCL) values ('30', '8');
insert into PCLUB.admpt_tipo_premclie (ADMPV_COD_TPOPR, ADMPV_COD_TPOCL) values ('33', '8');

insert into PCLUB.admpt_premio (ADMPV_ID_PROCLA, ADMPV_COD_TPOPR, ADMPV_DESC, ADMPN_PUNTOS, ADMPN_PAGO, ADMPC_ESTADO, ADMPN_COD_SERVC, ADMPN_MNT_RECAR, ADMPC_APL_PUNTO, ADMPV_CAMPANA, ADMPV_CLAVE, ADMPN_MNTDCTO, ADMPV_COD_PAQDAT, ADMPV_COD_SERVTV)
values ('U_PAQSERVTFI', '33', 'PAQUETE DE SERVICIOS TFI', 422, 0, 'A', null, 0, 'T', 'FEB-13', '', 0, '', '');

insert into PCLUB.admpt_cat_cliente (ADMPN_COD_CATCLI, ADMPV_COD_TPOCL, ADMPV_DESC, ADMPC_TIPO, ADMPN_TME_PUNTO, ADMPV_OPER_INI, ADMPV_OPER_FIN, ADMPN_LIM_INF, ADMPN_LIM_SUP, ADMPC_ESTADO, ADMPN_CXPT_PPAG, ADMPN_CXPT_CFIJ, ADMPN_CXPT_CADI, ADMPN_PTOANIV, ADMPN_CXPT_ADEB)
values (1, '8', 'Premiun', 'T', 12, '4', '5', 2500, 0, 'A', 0, 0, 0, 0, null);
insert into PCLUB.admpt_cat_cliente (ADMPN_COD_CATCLI, ADMPV_COD_TPOCL, ADMPV_DESC, ADMPC_TIPO, ADMPN_TME_PUNTO, ADMPV_OPER_INI, ADMPV_OPER_FIN, ADMPN_LIM_INF, ADMPN_LIM_SUP, ADMPC_ESTADO, ADMPN_CXPT_PPAG, ADMPN_CXPT_CFIJ, ADMPN_CXPT_CADI, ADMPN_PTOANIV, ADMPN_CXPT_ADEB)
values (2, '8', 'Normal', 'T', 12, '4', '3', 2500, 0, 'A', 0, 0, 0, 0, null);

update PCLUB.admpt_tipo_cliente set ADMPV_TIPO = 'POSTPAGO' where ADMPV_COD_TPOCL = '1';
update PCLUB.admpt_tipo_cliente set ADMPV_TIPO = 'POSTPAGO' where ADMPV_COD_TPOCL = '2';
update PCLUB.admpt_tipo_cliente set ADMPV_TIPO = 'PREPAGO' where ADMPV_COD_TPOCL = '3';
update PCLUB.admpt_tipo_cliente set ADMPV_TIPO = 'DTH' where ADMPV_COD_TPOCL = '6';
update PCLUB.admpt_tipo_cliente set ADMPV_TIPO = 'HFC' where ADMPV_COD_TPOCL = '7';
update PCLUB.admpt_tipo_cliente set ADMPV_TIPO = 'TFI' where ADMPV_COD_TPOCL = '8';

commit;