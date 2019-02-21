insert into USRSRVCC.ADMPT_ERRORES (ERRON_ID, ERROV_DESC) values (0, 'La transacción se realizó con éxito. ');
insert into USRSRVCC.ADMPT_ERRORES (ERRON_ID, ERROV_DESC) values (1, 'Ocurrió un error en la transacción. ');
insert into USRSRVCC.ADMPT_ERRORES (ERRON_ID, ERROV_DESC) values (2, 'Error en parámetro(s) de entrada. ');
insert into USRSRVCC.ADMPT_ERRORES (ERRON_ID, ERROV_DESC) values (3, 'Inconsistencia de datos de filtro. ');
insert into USRSRVCC.ADMPT_ERRORES (ERRON_ID, ERROV_DESC) values (4, 'Error en generación de correlativo. ');
commit;

insert into USRSRVCC.ADMPT_TIPO_DOC (TDOCV_ID, TDOCV_DESC, TDOCV_ABREV, TDOCC_ESTADO, TDOCV_USU_REG, TDOCD_FEC_REG, TDOCV_USU_MOD, TDOCD_FEC_MOD) values ('0', 'Régimen Unico de Contribuyente', 'RUC', 'A', '', null, '', null);
insert into USRSRVCC.ADMPT_TIPO_DOC (TDOCV_ID, TDOCV_DESC, TDOCV_ABREV, TDOCC_ESTADO, TDOCV_USU_REG, TDOCD_FEC_REG, TDOCV_USU_MOD, TDOCD_FEC_MOD) values ('1', 'Pasaporte', 'PASP', 'A', '', null, '', null);
insert into USRSRVCC.ADMPT_TIPO_DOC (TDOCV_ID, TDOCV_DESC, TDOCV_ABREV, TDOCC_ESTADO, TDOCV_USU_REG, TDOCD_FEC_REG, TDOCV_USU_MOD, TDOCD_FEC_MOD) values ('2', 'Documento Nacional de Identidad', 'DNI', 'A', '', null, '', null);
insert into USRSRVCC.ADMPT_TIPO_DOC (TDOCV_ID, TDOCV_DESC, TDOCV_ABREV, TDOCC_ESTADO, TDOCV_USU_REG, TDOCD_FEC_REG, TDOCV_USU_MOD, TDOCD_FEC_MOD) values ('4', 'Carnet de Extranjería', 'CE', 'A', '', null, '', null);
insert into USRSRVCC.ADMPT_TIPO_DOC (TDOCV_ID, TDOCV_DESC, TDOCV_ABREV, TDOCC_ESTADO, TDOCV_USU_REG, TDOCD_FEC_REG, TDOCV_USU_MOD, TDOCD_FEC_MOD) values ('5', 'Carnet de Identidad', 'CI', 'A', '', null, '', null);
insert into USRSRVCC.ADMPT_TIPO_DOC (TDOCV_ID, TDOCV_DESC, TDOCV_ABREV, TDOCC_ESTADO, TDOCV_USU_REG, TDOCD_FEC_REG, TDOCV_USU_MOD, TDOCD_FEC_MOD) values ('6', 'Libreta Militar', 'LB', 'A', '', null, '', null);
commit;

insert into USRSRVCC.ADMPT_TIPOPREMIO (TPREV_ID, TPREV_DESC, TPREC_ESTADO, TPREV_USU_REG, TPRED_FEC_REG, TPREV_USU_MOD, TPRED_FEC_MOD) values ('1', 'Minutos línea', 'A', '', null, '', null);
commit;

insert into USRSRVCC.ADMPT_PREMIO (PREMV_ID, TPREV_ID, PREMV_DESC, PREMC_ESTADO, PREMV_USU_REG, PREMD_FEC_REG, PREMV_USU_MOD, PREMD_FEC_MOD) values ('BONUSMINONNET10', '1', 'Bonus - Paquete 10 min Onnet', 'A', '', null, '', null);
insert into USRSRVCC.ADMPT_PREMIO (PREMV_ID, TPREV_ID, PREMV_DESC, PREMC_ESTADO, PREMV_USU_REG, PREMD_FEC_REG, PREMV_USU_MOD, PREMD_FEC_MOD) values ('BONUSMINONNET20', '1', 'Bonus - Paquete 20 min Onnet', 'A', '', null, '', null);
insert into USRSRVCC.ADMPT_PREMIO (PREMV_ID, TPREV_ID, PREMV_DESC, PREMC_ESTADO, PREMV_USU_REG, PREMD_FEC_REG, PREMV_USU_MOD, PREMD_FEC_MOD) values ('BONUSMINONNET30', '1', 'Bonus - Paquete 30 min Onnet', 'A', '', null, '', null);
insert into USRSRVCC.ADMPT_PREMIO (PREMV_ID, TPREV_ID, PREMV_DESC, PREMC_ESTADO, PREMV_USU_REG, PREMD_FEC_REG, PREMV_USU_MOD, PREMD_FEC_MOD) values ('BONUSMINONNET60', '1', 'Bonus - Paquete 60 min Onnet','A', '', null, '', null);
insert into USRSRVCC.ADMPT_PREMIO (PREMV_ID, TPREV_ID, PREMV_DESC, PREMC_ESTADO, PREMV_USU_REG, PREMD_FEC_REG, PREMV_USU_MOD, PREMD_FEC_MOD) values ('BONUSMINONNET90', '1', 'Bonus - Paquete 90 min Onnet', 'A', '', null, '', null);
commit;


insert into USRSRVCC.ADMPT_CLIENTE (CLIEV_ID, CLIEV_NOMBRE, CLIEC_ESTADO, CLIEV_USU_REG, CLIED_FEC_REG, CLIEV_USU_MOD, CLIED_FEC_MOD) values ('BONUS', 'BONUS - LOYALTI', 'A', '', null, '', null);
commit;
