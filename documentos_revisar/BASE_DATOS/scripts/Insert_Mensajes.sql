insert into pclub.admpt_mensaje (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPV_USER_MOD, ADMPD_FECHA_REG, ADMPD_FECHA_MOD, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
values (1, 'MICLARO', 'Bienvenido a ClaroClub,desde HOY acumularas 1 punto por cada S/.3 de recarga para que puedas canjear muchos beneficios.Informate en www.claro.com.pe/claroclub', 'USRMICLARO', '', trunc(sysdate), null, '1', 'Envio del SMS en el proceso de Registro Cliente CC Prepago');

insert into pclub.admpt_mensaje (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPV_USER_MOD, ADMPD_FECHA_REG, ADMPD_FECHA_MOD, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
values (2, 'DOL', 'Te gustaria poder acumular Claro puntos?Registrate y actualiza tus datos en claro.com.pe/miclaro.Averigua todo lo que puedes canjear en claro.com.pe/claroclub', 'USRDOL', '', trunc(sysdate), null, '1', 'Envio del SMS para los clientes prepago que realizaron dol.');

insert into pclub.admpt_mensaje (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPV_USER_MOD, ADMPD_FECHA_REG, ADMPD_FECHA_MOD, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
values (3, 'POSTPAGO', 'Bienvenido a ClaroClub, desde ahora acumularas ClaroPuntos para que los puedas canjear muchos beneficios. Informate en www.claro.com.pe/claroclub', 'USRPOSTPAGO', '', trunc(sysdate), null, '1', 'Envio del SMS en el proceso de Registro Cliente CC Postpago');

insert into pclub.admpt_mensaje (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPV_USER_MOD, ADMPD_FECHA_REG, ADMPD_FECHA_MOD, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
values (4, 'PRONTOPAG', 'Felicitaciones, por pagar su recibo a tiempo has recibido tus Claro Puntos de este mes. Mira tu saldo enviando SALDO al 2525 . + info en Claro.com.pe/claroclub', 'USRPOSTPAGO', '',trunc(sysdate), null, '1', '');

insert into pclub.admpt_mensaje (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPV_USER_MOD, ADMPD_FECHA_REG, ADMPD_FECHA_MOD, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
values (5, 'CARGFIJO', 'Felicitaciones,por pagar su recibo a tiempo has recibido tus Claro Puntos de este mes.Mira tu saldo enviando SALDO al 2525.+info en Claro.com.pe/claroclub', 'USRPOSTPAGO', '', trunc(sysdate), null, '1', 'Envio del SMS en el proceso de entrega de puntos por facturacción a los clientes postpago.');

insert into pclub.admpt_mensaje (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPV_USER_MOD, ADMPD_FECHA_REG, ADMPD_FECHA_MOD, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
values (6, 'RENOCONT', 'Felicitaciones,ya recibio su bono adicional de ClaroPuntos por haber renovado su linea.Mira tu saldo enviando SALDO al 2525. + en info Claro.com.pe/claroclub', 'USRRENCONT', '', trunc(sysdate), null, '1', 'Envio del SMS en el proceso de entrega de puntos a los clientes que renovaron contrato.');

commit;