insert into PCLUB.admpt_paramsist(ADMPC_COD_PARAM,ADMPV_DESC,ADMPV_VALOR) values('222','TIPO_PREMIO_SERVICIOS','24,25,26,27');
insert into PCLUB.admpt_paramsist(ADMPC_COD_PARAM,ADMPV_DESC,ADMPV_VALOR) values('223','TIPO_PREMIO_PRODUCTOS','28,30,31');
insert into PCLUB.admpt_paramsist(ADMPC_COD_PARAM,ADMPV_DESC,ADMPV_VALOR) values('224','TIPO_PREMIO_EXCLUIDO_ENC','29,32');
insert into PCLUB.admpt_paramsist(ADMPC_COD_PARAM,ADMPV_DESC,ADMPV_VALOR) values('225','HORA_INICIO_ENVIO_SMS','08:00');
insert into PCLUB.admpt_paramsist(ADMPC_COD_PARAM,ADMPV_DESC,ADMPV_VALOR) values('226','HORA_FIN_ENVIO_SMS','19:59');
insert into PCLUB.admpt_paramsist(ADMPC_COD_PARAM,ADMPV_DESC,ADMPV_VALOR) values('229','TAMANO_MAX_PREGUNTA_RESPUESTA','140');

insert into PCLUB.ADMPT_ERRORES_CC(ADMPN_COD_ERROR,ADMPV_DES_ERROR) values(34,'Cliente se encuentra en Black List, no se registrará la encuesta.');
insert into PCLUB.ADMPT_ERRORES_CC(ADMPN_COD_ERROR,ADMPV_DES_ERROR) values(35,'Cliente tiene encuestas generadas en el mes anterior a la fecha actual, no se registrará la encuesta.');
insert into PCLUB.ADMPT_ERRORES_CC(ADMPN_COD_ERROR,ADMPV_DES_ERROR) values(38,'Inconsistencia de datos de filtro.');
insert into PCLUB.ADMPT_ERRORES_CC(ADMPN_COD_ERROR,ADMPV_DES_ERROR) values(39,'Error en generación de correlativo.');
insert into PCLUB.ADMPT_ERRORES_CC(ADMPN_COD_ERROR,ADMPV_DES_ERROR) values(42,'Error en configuración de preguntas.');

insert into PCLUB.admpt_mensaje (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPV_USER_MOD, ADMPD_FECHA_REG, ADMPD_FECHA_MOD, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
values (29, 'REGENCRPTAVACIA', 'Respuesta no valida', 'USRENCUESTA', '', to_date('13-02-2013', 'dd-mm-yyyy'), null, '1', 'Envío del SMS, para error en la respuesta enviada.');
insert into PCLUB.admpt_mensaje (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPV_USER_MOD, ADMPD_FECHA_REG, ADMPD_FECHA_MOD, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
values (30, 'REGENCRPTACLAVEERROR', 'Respuesta no valida', 'USRENCUESTA', '', to_date('13-02-2013', 'dd-mm-yyyy'), null, '1', 'Envío del SMS, para palabra clave de la respuesta.');
insert into PCLUB.admpt_mensaje (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPV_USER_MOD, ADMPD_FECHA_REG, ADMPD_FECHA_MOD, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
values (31, 'REGENCFINALIZADA', 'Gracias por responder la encuesta', 'USRENCUESTA', '', to_date('13-02-2013', 'dd-mm-yyyy'), null, '1', 'Envío del SMS, se contestaron todas las preguntas encuesta finalizada.');
insert into PCLUB.admpt_mensaje (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPV_USER_MOD, ADMPD_FECHA_REG, ADMPD_FECHA_MOD, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
values (32, 'REGENCERROR', 'Ocurrio un error en la operacion, por favor intentelo mas tarde.', 'USRENCUESTA', '', to_date('13-02-2013', 'dd-mm-yyyy'), null, '1', 'Envío del SMS, para error técnico en el proceso.');
insert into PCLUB.admpt_mensaje (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPV_USER_MOD, ADMPD_FECHA_REG, ADMPD_FECHA_MOD, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
values (33, 'REGENCNOENCUESTA', 'No tiene encuesta pendiente por responder', 'USRENCUESTA', '', to_date('13-02-2013', 'dd-mm-yyyy'), null, '1', 'Envío del SMS, No tiene encuestas pendientes por responder.');
insert into PCLUB.admpt_mensaje (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPV_USER_MOD, ADMPD_FECHA_REG, ADMPD_FECHA_MOD, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
values (34, 'REGENCNOCONFIGURADA', 'No existe encuesta configurada para hoy dia', 'USRENCUESTA', '', to_date('13-02-2013', 'dd-mm-yyyy'), null, '1', 'Envío del SMS, Encuesta no configurada.');

update PCLUB.ADMPT_TIPO_CLIENTE set ADMPC_ENCUESTA = '1' where ADMPV_COD_TPOCL in ('1','2','3');

update PCLUB.ADMPT_ERRORES_CC set ADMPV_DES_ERROR = 'Error en parámetro(s) de entrada. ' where ADMPN_COD_ERROR = 4;

commit;
