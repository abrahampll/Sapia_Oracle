insert into PCLUB.CC_SEGMENTO_FIDELIDAD_DETALLE (SEGMV_CODIGO_DET, SEGMV_CODIGO, SEGMV_REC_MIN, SEGMV_REC_MAX, SEGMV_ANT_MIN, SEGMV_ANT_MAX)
values ('2', '4', 15, 24.99, 1, 2);

insert into PCLUB.CC_SEGMENTO_FIDELIDAD_DETALLE (SEGMV_CODIGO_DET, SEGMV_CODIGO, SEGMV_REC_MIN, SEGMV_REC_MAX, SEGMV_ANT_MIN, SEGMV_ANT_MAX)
values ('1', '7', 1, 14.99, 1, 2);

insert into PCLUB.CC_SEGMENTO_FIDELIDAD_DETALLE (SEGMV_CODIGO_DET, SEGMV_CODIGO, SEGMV_REC_MIN, SEGMV_REC_MAX, SEGMV_ANT_MIN, SEGMV_ANT_MAX)
values ('3', '1', 25, 9999, 1, 2);

insert into PCLUB.CC_SEGMENTO_FIDELIDAD_DETALLE (SEGMV_CODIGO_DET, SEGMV_CODIGO, SEGMV_REC_MIN, SEGMV_REC_MAX, SEGMV_ANT_MIN, SEGMV_ANT_MAX)
values ('6', '1', 1, 9999, 3, 9999);

insert into PCLUB.CC_SEGMENTO_FIDELIDAD_DETALLE (SEGMV_CODIGO_DET, SEGMV_CODIGO, SEGMV_REC_MIN, SEGMV_REC_MAX, SEGMV_ANT_MIN, SEGMV_ANT_MAX)
values ('5', '1', 15, 9999, 2, 3);

insert into PCLUB.CC_SEGMENTO_FIDELIDAD_DETALLE (SEGMV_CODIGO_DET, SEGMV_CODIGO, SEGMV_REC_MIN, SEGMV_REC_MAX, SEGMV_ANT_MIN, SEGMV_ANT_MAX)
values ('4', '4', 1, 14.99, 2, 3);

commit;

insert into PCLUB.CC_PERIODO_EVALUACION (SEGMV_CODIGO_PERIODO, SEGMV_FECHA_INICIO, SEGMV_FECHA_FIN, SEGMV_FECHA_PRO)
values ('3', to_date('01-01-2012', 'dd-mm-yyyy'), to_date('31-03-2012', 'dd-mm-yyyy'), to_date('15-04-2012', 'dd-mm-yyyy'));

insert into PCLUB.CC_PERIODO_EVALUACION (SEGMV_CODIGO_PERIODO, SEGMV_FECHA_INICIO, SEGMV_FECHA_FIN, SEGMV_FECHA_PRO)
values ('2', to_date('01-10-2011', 'dd-mm-yyyy'), to_date('31-12-2011', 'dd-mm-yyyy'), to_date('23-01-2012', 'dd-mm-yyyy'));

insert into PCLUB.CC_PERIODO_EVALUACION (SEGMV_CODIGO_PERIODO, SEGMV_FECHA_INICIO, SEGMV_FECHA_FIN, SEGMV_FECHA_PRO)
values ('1', to_date('01-07-2011', 'dd-mm-yyyy'), to_date('30-09-2011', 'dd-mm-yyyy'), to_date('23-10-2011', 'dd-mm-yyyy'));

insert into PCLUB.CC_PERIODO_EVALUACION (SEGMV_CODIGO_PERIODO, SEGMV_FECHA_INICIO, SEGMV_FECHA_FIN, SEGMV_FECHA_PRO)
values ('4', to_date('01-04-2012', 'dd-mm-yyyy'), to_date('30-06-2012', 'dd-mm-yyyy'), to_date('14-07-2012', 'dd-mm-yyyy'));

insert into PCLUB.CC_PERIODO_EVALUACION (SEGMV_CODIGO_PERIODO, SEGMV_FECHA_INICIO, SEGMV_FECHA_FIN, SEGMV_FECHA_PRO)
values ('6', to_date('01-10-2012', 'dd-mm-yyyy'), to_date('31-12-2012', 'dd-mm-yyyy'), to_date('14-01-2013', 'dd-mm-yyyy'));

insert into PCLUB.CC_PERIODO_EVALUACION (SEGMV_CODIGO_PERIODO, SEGMV_FECHA_INICIO, SEGMV_FECHA_FIN, SEGMV_FECHA_PRO)
values ('5', to_date('01-07-2012', 'dd-mm-yyyy'), to_date('30-09-2012', 'dd-mm-yyyy'), to_date('14-10-2012', 'dd-mm-yyyy'));

commit;


insert into PCLUB.CC_DETALLE_PERIODO (SEGMV_CODIGO_PERIODO, SEGMV_DET_INICIO, SEGMV_DET_FIN, SEGMV_DET_DESCRIPCION)
values ('1', to_date('01-09-2011', 'dd-mm-yyyy'), to_date('30-09-2011', 'dd-mm-yyyy'), 'Setiembre');

insert into PCLUB.CC_DETALLE_PERIODO (SEGMV_CODIGO_PERIODO, SEGMV_DET_INICIO, SEGMV_DET_FIN, SEGMV_DET_DESCRIPCION)
values ('1', to_date('01-08-2011', 'dd-mm-yyyy'), to_date('31-08-2011', 'dd-mm-yyyy'), 'Agosto');

insert into PCLUB.CC_DETALLE_PERIODO (SEGMV_CODIGO_PERIODO, SEGMV_DET_INICIO, SEGMV_DET_FIN, SEGMV_DET_DESCRIPCION)
values ('1', to_date('01-07-2011', 'dd-mm-yyyy'), to_date('31-07-2011', 'dd-mm-yyyy'), 'Julio');

insert into PCLUB.CC_DETALLE_PERIODO (SEGMV_CODIGO_PERIODO, SEGMV_DET_INICIO, SEGMV_DET_FIN, SEGMV_DET_DESCRIPCION)
values ('4', to_date('01-06-2012', 'dd-mm-yyyy'), to_date('30-06-2012', 'dd-mm-yyyy'), 'Junio');

insert into PCLUB.CC_DETALLE_PERIODO (SEGMV_CODIGO_PERIODO, SEGMV_DET_INICIO, SEGMV_DET_FIN, SEGMV_DET_DESCRIPCION)
values ('4', to_date('01-05-2012', 'dd-mm-yyyy'), to_date('31-05-2012', 'dd-mm-yyyy'), 'Mayo');

insert into PCLUB.CC_DETALLE_PERIODO (SEGMV_CODIGO_PERIODO, SEGMV_DET_INICIO, SEGMV_DET_FIN, SEGMV_DET_DESCRIPCION)
values ('4', to_date('01-04-2012', 'dd-mm-yyyy'), to_date('30-04-2012', 'dd-mm-yyyy'), 'Abril');

insert into PCLUB.CC_DETALLE_PERIODO (SEGMV_CODIGO_PERIODO, SEGMV_DET_INICIO, SEGMV_DET_FIN, SEGMV_DET_DESCRIPCION)
values ('3', to_date('01-03-2012', 'dd-mm-yyyy'), to_date('31-03-2012', 'dd-mm-yyyy'), 'Marzo');

insert into PCLUB.CC_DETALLE_PERIODO (SEGMV_CODIGO_PERIODO, SEGMV_DET_INICIO, SEGMV_DET_FIN, SEGMV_DET_DESCRIPCION)
values ('3', to_date('01-02-2012', 'dd-mm-yyyy'), to_date('29-02-2012', 'dd-mm-yyyy'), 'Febrero');

insert into PCLUB.CC_DETALLE_PERIODO (SEGMV_CODIGO_PERIODO, SEGMV_DET_INICIO, SEGMV_DET_FIN, SEGMV_DET_DESCRIPCION)
values ('3', to_date('01-01-2012', 'dd-mm-yyyy'), to_date('31-01-2012', 'dd-mm-yyyy'), 'Enero');

insert into PCLUB.CC_DETALLE_PERIODO (SEGMV_CODIGO_PERIODO, SEGMV_DET_INICIO, SEGMV_DET_FIN, SEGMV_DET_DESCRIPCION)
values ('2', to_date('01-12-2011', 'dd-mm-yyyy'), to_date('31-12-2011', 'dd-mm-yyyy'), 'Diciembre');

insert into PCLUB.CC_DETALLE_PERIODO (SEGMV_CODIGO_PERIODO, SEGMV_DET_INICIO, SEGMV_DET_FIN, SEGMV_DET_DESCRIPCION)
values ('2', to_date('01-11-2011', 'dd-mm-yyyy'), to_date('30-11-2011', 'dd-mm-yyyy'), 'Noviembre');

insert into PCLUB.CC_DETALLE_PERIODO (SEGMV_CODIGO_PERIODO, SEGMV_DET_INICIO, SEGMV_DET_FIN, SEGMV_DET_DESCRIPCION)
values ('2', to_date('01-10-2011', 'dd-mm-yyyy'), to_date('31-10-2011', 'dd-mm-yyyy'), 'Octubre');

insert into PCLUB.CC_DETALLE_PERIODO (SEGMV_CODIGO_PERIODO, SEGMV_DET_INICIO, SEGMV_DET_FIN, SEGMV_DET_DESCRIPCION)
values ('6', to_date('01-10-2012', 'dd-mm-yyyy'), to_date('31-10-2012', 'dd-mm-yyyy'), 'Octubre');

insert into PCLUB.CC_DETALLE_PERIODO (SEGMV_CODIGO_PERIODO, SEGMV_DET_INICIO, SEGMV_DET_FIN, SEGMV_DET_DESCRIPCION)
values ('6', to_date('01-11-2012', 'dd-mm-yyyy'), to_date('30-11-2012', 'dd-mm-yyyy'), 'Noviembre');

insert into PCLUB.CC_DETALLE_PERIODO (SEGMV_CODIGO_PERIODO, SEGMV_DET_INICIO, SEGMV_DET_FIN, SEGMV_DET_DESCRIPCION)
values ('6', to_date('01-12-2012', 'dd-mm-yyyy'), to_date('31-12-2012', 'dd-mm-yyyy'), 'Diciembre');

insert into PCLUB.CC_DETALLE_PERIODO (SEGMV_CODIGO_PERIODO, SEGMV_DET_INICIO, SEGMV_DET_FIN, SEGMV_DET_DESCRIPCION)
values ('5', to_date('01-09-2012', 'dd-mm-yyyy'), to_date('30-09-2012', 'dd-mm-yyyy'), 'Setiembre');

insert into PCLUB.CC_DETALLE_PERIODO (SEGMV_CODIGO_PERIODO, SEGMV_DET_INICIO, SEGMV_DET_FIN, SEGMV_DET_DESCRIPCION)
values ('5', to_date('01-08-2012', 'dd-mm-yyyy'), to_date('31-08-2012', 'dd-mm-yyyy'), 'Agosto');

insert into PCLUB.CC_DETALLE_PERIODO (SEGMV_CODIGO_PERIODO, SEGMV_DET_INICIO, SEGMV_DET_FIN, SEGMV_DET_DESCRIPCION)
values ('5', to_date('01-07-2012', 'dd-mm-yyyy'), to_date('31-07-2012', 'dd-mm-yyyy'), 'Julio');

commit;


insert into pclub.cc_planes_permitidos (SEGMV_PLAN_ID)
values (151);

insert into pclub.cc_planes_permitidos (SEGMV_PLAN_ID)
values (145);

insert into pclub.cc_planes_permitidos (SEGMV_PLAN_ID)
values (97);

insert into pclub.cc_planes_permitidos (SEGMV_PLAN_ID)
values (96);

insert into pclub.cc_planes_permitidos (SEGMV_PLAN_ID)
values (86);

insert into pclub.cc_planes_permitidos (SEGMV_PLAN_ID)
values (85);

insert into pclub.cc_planes_permitidos (SEGMV_PLAN_ID)
values (82);

insert into pclub.cc_planes_permitidos (SEGMV_PLAN_ID)
values (81);

insert into pclub.cc_planes_permitidos (SEGMV_PLAN_ID)
values (79);

commit;