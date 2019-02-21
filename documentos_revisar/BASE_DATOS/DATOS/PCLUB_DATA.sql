
insert into PCLUB.ADMPT_CAT_CLIENTE (ADMPN_COD_CATCLI, ADMPV_COD_TPOCL, ADMPV_DESC, ADMPC_TIPO, ADMPN_TME_PUNTO, ADMPV_OPER_INI, ADMPV_OPER_FIN, ADMPN_LIM_INF, ADMPN_LIM_SUP, ADMPC_ESTADO, ADMPN_CXPT_PPAG, ADMPN_CXPT_CFIJ, ADMPN_CXPT_CADI)
values (1, '1', 'Premiun', 'T', 12, '4', '5', 2500, 0, 'A', 2, 1.5, 1.5);
insert into PCLUB.ADMPT_CAT_CLIENTE (ADMPN_COD_CATCLI, ADMPV_COD_TPOCL, ADMPV_DESC, ADMPC_TIPO, ADMPN_TME_PUNTO, ADMPV_OPER_INI, ADMPV_OPER_FIN, ADMPN_LIM_INF, ADMPN_LIM_SUP, ADMPC_ESTADO, ADMPN_CXPT_PPAG, ADMPN_CXPT_CFIJ, ADMPN_CXPT_CADI)
values (2, '1', 'Normal', 'T', 12, '4', '3', 2500, 0, 'A', 2.5, 2, 2);
commit;

insert into PCLUB.ADMPT_CONCEPTO (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO)
values ('8', 'PROMOCIONES CC', 'A', 'IDPROMOCION_YYYYMMDD.CCL', null, 'C');
insert into PCLUB.ADMPT_CONCEPTO (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO)
values ('9', 'REGULARIZACION CC', 'A', 'IDREGULA_YYYYMMDD.CCL', null, 'C');
insert into PCLUB.ADMPT_CONCEPTO (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO)
values ('1', 'ACTIVACION TC', 'A', 'IBACTCANMOR_YYYYMMDD.DIA', null, 'I');
insert into PCLUB.ADMPT_CONCEPTO (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO)
values ('2', 'CANCELACION TC', 'A', 'IBACTCANMOR_YYYYMMDD.DIA', null, 'I');
insert into PCLUB.ADMPT_CONCEPTO (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO)
values ('3', 'MOROSIDAD TC', 'A', 'IBACTCANMOR_YYYYMMDD.DIA', null, 'I');
insert into PCLUB.ADMPT_CONCEPTO (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO)
values ('4', 'FACTURACION TC', 'A', 'IBFACCAMDEB_YYYYMMDD.MEN', null, 'I');
insert into PCLUB.ADMPT_CONCEPTO (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO)
values ('5', 'CAMPA�A TC', 'A', 'IBFACCAMDEB_YYYYMMDD.MEN', null, 'I');
insert into PCLUB.ADMPT_CONCEPTO (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO)
values ('6', 'DEBITO AUTOMATICO TC', 'A', 'DEBITOAUT_YYYYMMDD.MEN', null, 'I');
insert into PCLUB.ADMPT_CONCEPTO (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO)
values ('10', 'BONO CADUCADO', 'A', null, 18, 'I');
insert into PCLUB.ADMPT_CONCEPTO (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO)
values ('7', 'PRONTO PAGO NORMAL', 'A', 'PAGOS_YYYYMMDD.CAC', null, 'C');
insert into PCLUB.ADMPT_CONCEPTO (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO)
values ('11', 'PRONTO PAGO ADICIONAL', 'A', 'PAGOS_YYYYMMDD.CAC', null, 'C');
insert into PCLUB.ADMPT_CONCEPTO (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO)
values ('12', 'CARGO FIJO', 'A', 'PAGOS_YYYYMMDD.CAC', null, 'C');
insert into PCLUB.ADMPT_CONCEPTO (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO)
values ('13', 'CARGO ADICIONAL', 'A', 'PAGOS_YYYYMMDD.CAC', null, 'C');
commit;

insert into PCLUB.ADMPT_IMP_PAGO_CC (ADMPN_ID_FILA, ADMPV_COD_CLI, ADMPV_PERIODO, ADMPN_DIAS_VENC, ADMPN_MNT_CGOFIJ, ADMPN_MNT_ADIC, ADMPN_ACGOFIJ, ADMPC_SGACGOFIJ, ADMPN_AJUADIC, ADMPC_SGAJUADI, ADMPD_FEC_OPER, ADMPV_NOM_ARCH, ADMPN_PUNTOS)
values (20, null, null, null, null, null, null, null, null, null, null, null, null);
insert into PCLUB.ADMPT_IMP_PAGO_CC (ADMPN_ID_FILA, ADMPV_COD_CLI, ADMPV_PERIODO, ADMPN_DIAS_VENC, ADMPN_MNT_CGOFIJ, ADMPN_MNT_ADIC, ADMPN_ACGOFIJ, ADMPC_SGACGOFIJ, ADMPN_AJUADIC, ADMPC_SGAJUADI, ADMPD_FEC_OPER, ADMPV_NOM_ARCH, ADMPN_PUNTOS)
values (30, null, null, null, null, null, null, null, null, null, null, null, null);
commit;

insert into PCLUB.ADMPT_SEG_CLIENTE (ADMPV_COD_SEGCLI, ADMPV_COD_TPOCL, ADMPV_DESC, ADMPC_ESTADO)
values ('1', '1', 'segmento1', 'A');
insert into PCLUB.ADMPT_SEG_CLIENTE (ADMPV_COD_SEGCLI, ADMPV_COD_TPOCL, ADMPV_DESC, ADMPC_ESTADO)
values ('2', '1', 'segmento2', 'A');
insert into PCLUB.ADMPT_SEG_CLIENTE (ADMPV_COD_SEGCLI, ADMPV_COD_TPOCL, ADMPV_DESC, ADMPC_ESTADO)
values ('3', '1', 'segmento3', 'A');
insert into PCLUB.ADMPT_SEG_CLIENTE (ADMPV_COD_SEGCLI, ADMPV_COD_TPOCL, ADMPV_DESC, ADMPC_ESTADO)
values ('4', '1', 'segmento4', 'A');
commit;

insert into PCLUB.ADMPT_TIPO_CLIENTE (ADMPV_COD_TPOCL, ADMPV_DESC, ADMPC_ESTADO)
values ('1', 'Control y Postpago', 'A');
insert into PCLUB.ADMPT_TIPO_CLIENTE (ADMPV_COD_TPOCL, ADMPV_DESC, ADMPC_ESTADO)
values ('3', 'Prepago', 'A');
insert into PCLUB.ADMPT_TIPO_CLIENTE (ADMPV_COD_TPOCL, ADMPV_DESC, ADMPC_ESTADO)
values ('4', 'B2E', 'A');
commit;

insert into PCLUB.ADMPT_TIPO_DOC (ADMPV_COD_TPDOC, ADMPV_DSC_DOCUM, ADMPV_COD_EQUIV)
values ('1', 'Pasaporte', '5');
insert into PCLUB.ADMPT_TIPO_DOC (ADMPV_COD_TPDOC, ADMPV_DSC_DOCUM, ADMPV_COD_EQUIV)
values ('2', 'DNI', '1');
insert into PCLUB.ADMPT_TIPO_DOC (ADMPV_COD_TPDOC, ADMPV_DSC_DOCUM, ADMPV_COD_EQUIV)
values ('4', 'CE', '3');
insert into PCLUB.ADMPT_TIPO_DOC (ADMPV_COD_TPDOC, ADMPV_DSC_DOCUM, ADMPV_COD_EQUIV)
values ('0', 'RUC', '2');
commit;

insert into PCLUB.ADMPT_TIPO_PREMIO (ADMPV_COD_TPOPR, ADMPV_DESC, ADMPC_ESTADO)
values ('1', 'Servicios Postpago', 'A');
insert into PCLUB.ADMPT_TIPO_PREMIO (ADMPV_COD_TPOPR, ADMPV_DESC, ADMPC_ESTADO)
values ('2', 'Servicios Control', 'A');
insert into PCLUB.ADMPT_TIPO_PREMIO (ADMPV_COD_TPOPR, ADMPV_DESC, ADMPC_ESTADO)
values ('3', 'Productos Claro', 'A');
insert into PCLUB.ADMPT_TIPO_PREMIO (ADMPV_COD_TPOPR, ADMPV_DESC, ADMPC_ESTADO)
values ('4', 'Dsctos. Equipos', 'A');
insert into PCLUB.ADMPT_TIPO_PREMIO (ADMPV_COD_TPOPR, ADMPV_DESC, ADMPC_ESTADO)
values ('5', 'Recargas Postpago', 'A');
commit;