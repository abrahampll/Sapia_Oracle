insert into pclub.admpt_mensaje(ADMPN_COD_SMS,ADMPV_VALOR,ADMPV_DESCRIPCION,ADMPV_USER_REG,ADMPV_USER_MOD,ADMPD_FECHA_REG,ADMPD_FECHA_MOD,ADMPV_TIPO_MSJ,ADMPV_OBSERVACION)
values('7','REGCCPRESMSEXITO','Bienvenido a ClaroClub,desde HOY acumularas 1 punto por cada S/.3 de recarga para que puedas canjear muchos beneficios.Informate en www.claro.com.pe/claroclub','USRADMIN','',sysdate,'','2','Mensaje que devuelve el sistema cuando el registro del cliente prepago a CC vía SMS se realiza con exito.');

insert into pclub.admpt_mensaje(ADMPN_COD_SMS,ADMPV_VALOR,ADMPV_DESCRIPCION,ADMPV_USER_REG,ADMPV_USER_MOD,ADMPD_FECHA_REG,ADMPD_FECHA_MOD,ADMPV_TIPO_MSJ,ADMPV_OBSERVACION)
values('8','REGCCPRESMSFALLO','Ud. ya se encuentra registrado en ClaroClub, descubra todo lo que puede canjear en www.claro.com.pe/claroclub','USRADMIN','',sysdate,'','2','Mensaje que devuelve el sistema en el proceso de registro del cliente prepago a CC vía SMS en el caso que el cliente ya exista en Claro Club.');

insert into pclub.admpt_mensaje(ADMPN_COD_SMS,ADMPV_VALOR,ADMPV_DESCRIPCION,ADMPV_USER_REG,ADMPV_USER_MOD,ADMPD_FECHA_REG,ADMPD_FECHA_MOD,ADMPV_TIPO_MSJ,ADMPV_OBSERVACION)
values('9','REGCCPRESMSERROR','Por favor vuelva a intentar mas tarde','USRADMIN','',sysdate,'','2','Mensaje que devuelve el sistema en el proceso de registro del cliente prepago a CC vía SMS en el caso que ocurra un error de sistema.');

commit;