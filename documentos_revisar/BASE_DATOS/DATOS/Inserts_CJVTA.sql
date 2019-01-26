insert into PCLUB.ADMPT_CONCEPTO (ADMPV_COD_CPTO, ADMPV_DESC, ADMPC_ESTADO, ADMPV_NOM_ARCH, ADMPN_PER_CADU, ADMPC_TPO_PUNTO, ADMPV_TPO_CPTO, ADMPC_TPO_OPER, ADMPC_PROC)
values ('82', 'CANJE VENTA', 'A', '', null, '', '', 'S', '1');

insert into PCLUB.ADMPT_PARAMSIST (ADMPC_COD_PARAM, ADMPV_DESC, ADMPV_VALOR)
values ('227', 'FACTOR_CONVERSION_PTOS_A_SOLES', '0.0474');

insert into PCLUB.ADMPT_PARAMSIST (ADMPC_COD_PARAM, ADMPV_DESC, ADMPV_VALOR)
values ('228', 'PREMIO_CANJE_VENTA', 'U_DSCEQUIPO');

insert into PCLUB.admpt_premio (ADMPV_ID_PROCLA, ADMPV_COD_TPOPR, ADMPV_DESC, ADMPN_PUNTOS, ADMPN_PAGO, ADMPC_ESTADO, ADMPN_COD_SERVC, ADMPN_MNT_RECAR, ADMPC_APL_PUNTO, ADMPV_CAMPANA, ADMPV_CLAVE, ADMPN_MNTDCTO, ADMPV_COD_PAQDAT, ADMPV_COD_SERVTV)
values ('U_DSCEQUIPO', '28', 'DESCUENTO EN EQUIPO', 0, 0, 'A', null, 0, 'T', 'JUL-13', '', null, '', '');

insert into PCLUB.ADMPT_ERRORES_CC (ADMPN_COD_ERROR, ADMPV_DES_ERROR)
values (37, 'Cuenta(s) del Cliente Bloqueada, No Podrá realizar Canjes hasta que sea Liberada.');

insert into PCLUB.ADMPT_ERRORES_CC (ADMPN_COD_ERROR, ADMPV_DES_ERROR)
values (40, 'Validación de bloqueo de canje. ');

insert into PCLUB.ADMPT_ERRORES_CC (ADMPN_COD_ERROR, ADMPV_DES_ERROR)
values (41, 'La Cuenta del Cliente no fue Bloqueada en el Proceso de Venta.');

insert into PCLUB.ADMPT_ERRORES_CC (ADMPN_COD_ERROR, ADMPV_DES_ERROR)
values (49, 'Incongruencia con los Datos del Cliente.');

insert into PCLUB.ADMPT_PROCESO (ADMPV_IDPROC, ADMPV_DESC, ADMPV_ESTADO, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, ADMPV_USU_MOD)
values ('AP', 'Venta por Alta Nueva Postpago', 'A', SYSDATE, 'ADMIN', null, '');

insert into PCLUB.ADMPT_PROCESO (ADMPV_IDPROC, ADMPV_DESC, ADMPV_ESTADO, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, ADMPV_USU_MOD)
values ('AE', 'Venta por Alta Nueva Prepago', 'A', SYSDATE, 'ADMIN', null, '');

insert into PCLUB.ADMPT_PROCESO (ADMPV_IDPROC, ADMPV_DESC, ADMPV_ESTADO, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, ADMPV_USU_MOD)
values ('VR', 'Por Renovación ', 'A', SYSDATE, 'ADMIN', null, '');

update PCLUB.admpt_tipo_cliente set ADMPV_PRVENTA = '1', ADMPC_TBLCLIENTE = 'M' where ADMPV_COD_TPOCL = '1';
update PCLUB.admpt_tipo_cliente set ADMPV_PRVENTA = '1', ADMPC_TBLCLIENTE = 'M' where ADMPV_COD_TPOCL = '2';
update PCLUB.admpt_tipo_cliente set ADMPV_PRVENTA = '2', ADMPC_TBLCLIENTE = 'M' where ADMPV_COD_TPOCL = '3';
update PCLUB.admpt_tipo_cliente set ADMPV_PRVENTA = '3', ADMPC_TBLCLIENTE = 'F' where ADMPV_COD_TPOCL = '6';
update PCLUB.admpt_tipo_cliente set ADMPV_PRVENTA = '4', ADMPC_TBLCLIENTE = 'F' where ADMPV_COD_TPOCL = '7';
update PCLUB.admpt_tipo_cliente set ADMPC_TBLCLIENTE = 'M' where ADMPV_COD_TPOCL = '8';

commit;


