        
  INSERT INTO PCLUB.ADMPT_PARAMSIST
   (ADMPC_COD_PARAM, ADMPV_DESC, ADMPV_VALOR)
 VALUES
   ('210', 'SEGMENTO_CUPONERA_INICIAL', 'C');
   
     INSERT INTO PCLUB.ADMPT_PARAMSIST
   (ADMPC_COD_PARAM, ADMPV_DESC, ADMPV_VALOR)
 VALUES
   ('211', 'TIEMPO_BLOQUEO_CUPONERA', '3');

INSERT INTO PCLUB.ADMPT_PARAMSIST
   (ADMPC_COD_PARAM, ADMPV_DESC, ADMPV_VALOR)
 VALUES
   ('212', 'TIEMPO_CONSULTA_CUPONERA', '2');
   
    INSERT INTO PCLUB.ADMPT_PARAMSIST
   (ADMPC_COD_PARAM, ADMPV_DESC, ADMPV_VALOR)
 VALUES
   ('213', 'ENTRADA_OFERTAS_CUPONERA', 'Sus ofertas son: ');    
   
       INSERT INTO PCLUB.ADMPT_PARAMSIST
   (ADMPC_COD_PARAM, ADMPV_DESC, ADMPV_VALOR)
 VALUES
   ('214', 'NRO_INTENTO_BLOQ', '5');         

 INSERT INTO PCLUB.ADMPT_PARAMSIST
   (ADMPC_COD_PARAM, ADMPV_DESC, ADMPV_VALOR)
 VALUES
   ('215', 'TOTAL_CARACTER_SMS', '140');
 
 INSERT INTO PCLUB.ADMPT_MENSAJE
   (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPD_FECHA_REG, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
 VALUES
   (15, 'REGOFERTAEXITO', 'Su oferta fue registrada con exito', 'USRCUPONERA', 
    SYSDATE, '1', 'Envio del SMS en el proceso de entrega de oferta de cuponera.');
INSERT INTO PCLUB.ADMPT_MENSAJE
   (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPD_FECHA_REG, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
 VALUES
   (16, 'REGOFERTACADUCA', 'La cantidad de ofertas ya fueron agotadas', 'USRCUPONERA', 
    SYSDATE, '1', 'Envio del SMS en el proceso de ofertas agotadas de cuponera.');
INSERT INTO PCLUB.ADMPT_MENSAJE
   (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPD_FECHA_REG, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
 VALUES
   (17, 'REGDOCNOVALIDO', 'no pertenece a claro, enviar numero de documento valido', 'USRCUPONERA', 
   SYSDATE, '1', 'Envio del SMS, para los nro. de doc. no validos.');
INSERT INTO PCLUB.ADMPT_MENSAJE
   (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPD_FECHA_REG, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
 VALUES
   (18, 'REGCLIEPRENOVALIDO', 'no se encuentra registrado en ClaroClub, El cliente debe registrarse enviando �R� al 2525 o puede llamar al 2525', 'USRCUPONERA', 
    SYSDATE, '1', 'Envio del SMS, para los clientes solo con lineas prepagos.');
INSERT INTO PCLUB.ADMPT_MENSAJE
   (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPD_FECHA_REG, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
 VALUES
   (19, 'REGCADUCAOFERTA', 'La promocion ya caduco, puede consultar llamando al 2525', 'USRCUPONERA', 
    SYSDATE, '1', 'Envio del SMS, para la promocion que ha caducado.');
INSERT INTO PCLUB.ADMPT_MENSAJE
   (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPD_FECHA_REG, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
 VALUES
   (20, 'REGESTERROR', 'codigo del establecimiento incorrecto, enviar documento + codigo de establecimiento o llamar al 2525', 'USRCUPONERA', 
    SYSDATE, '1', 'Envio del SMS, para error en las palabras enviadas.');
INSERT INTO PCLUB.ADMPT_MENSAJE
   (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPD_FECHA_REG, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
 VALUES
   (21, 'REGOFERERROR', 'codigo del establecimiento incorrecto, enviar palabra clave + documento + codigo de establecimiento o llamar al 2525', 'USRCUPONERA', 
    SYSDATE, '1', 'Envio del SMS, para error en las palabras enviadas.');
INSERT INTO PCLUB.ADMPT_MENSAJE
   (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPD_FECHA_REG, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
 VALUES
   (22, 'REGCUPONERAERROR', 'Por favor intentelo mas tarde.', 'USRCUPONERA', 
    SYSDATE, '1', 'Envio del SMS, para error tecnico en el proceso.');
INSERT INTO PCLUB.ADMPT_MENSAJE
   (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPD_FECHA_REG, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
 VALUES
   (23, 'REGERROROPERACION', 'Ha ocurrido un error en la operacion. Por favor  consultar al 2525.', 'USRCUPONERA', 
    SYSDATE, '1', 'Envio del SMS, para error tecnico en el proceso.');
INSERT INTO PCLUB.ADMPT_MENSAJE
   (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPD_FECHA_REG, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
 VALUES
   (24, 'REGOFERCLAVEERROR', 'Palabra clave incorrecto, enviar clave valido O1 o O2.', 'USRCUPONERA', 
    SYSDATE, '1', 'Envio del SMS, para palabra clave de la oferta.');
INSERT INTO PCLUB.ADMPT_MENSAJE
   (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPD_FECHA_REG, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
 VALUES
   (25, 'REGCONSULTAEERROR', 'Se realizaron el m�ximo de consultas en 2 minutos. Espere unos minutos para volver a intentarlo', 'USRCUPONERA', 
    SYSDATE, '1', 'Envio del SMS, para palabra clave de la oferta.');
INSERT INTO PCLUB.ADMPT_MENSAJE
   (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPD_FECHA_REG, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
 VALUES
   (26, 'REGOFERCANJEEERROR', 'Usted no tiene configurada la ofertada ingresada.', 'USRCUPONERA', 
    SYSDATE, '1', 'Envio del SMS, la oferta enviada no esta configurada.');
INSERT INTO PCLUB.ADMPT_MENSAJE
   (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPD_FECHA_REG, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
 VALUES
   (27, 'REGESTABAJA', 'establecimiento indicado se encuentra inactivo o no existe.', 'USRCUPONERA', 
   SYSDATE, '1', 'Envio del SMS, el establecimiento no se encuentra activo.');
INSERT INTO PCLUB.ADMPT_MENSAJE
   (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPD_FECHA_REG, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
 VALUES
   (28, 'REGNOOFERTAACT', 'no hay ofertas disponibles con los datos consultados.', 'USRCUPONERA', 
    SYSDATE, '1', 'Envio del SMS, no existen ofertas activas.');

INSERT INTO PCLUB.ADMPT_TIPOS
   (ADMPV_COD_TIPO, ADMPV_DSC_TIPO, ADMPV_ESTADO, ADMPV_GRUPO, ADMPV_RUTA)
 VALUES
   ('7', 'Registro Masivo WhiteList Cuponera', 'A', '3', 'FyR/CUPONERA/Clientes');
INSERT INTO PCLUB.ADMPT_TIPOS
   (ADMPV_COD_TIPO, ADMPV_DSC_TIPO, ADMPV_ESTADO, ADMPV_GRUPO, ADMPV_RUTA)
 VALUES
   ('8', 'Actualizaci�n Masiva de Segmentos', 'A', '3', 'FyR/CUPONERA/Segmento');

INSERT INTO PCLUB.ADMPT_SEGMENTOCUPONERA
   (ADMPN_COD_SEG, ADMPV_DESCRIPCION, ADMPD_FEC_REG, ADMPD_FEC_MOD, ADMPV_USU_REG)
 VALUES
   (1, 'A',SYSDATE, NULL, 'USRCUP');
INSERT INTO PCLUB.ADMPT_SEGMENTOCUPONERA
   (ADMPN_COD_SEG, ADMPV_DESCRIPCION, ADMPD_FEC_REG, ADMPD_FEC_MOD, ADMPV_USU_REG)
 VALUES
   (2, 'B',SYSDATE, NULL, 'USRCUP');
INSERT INTO PCLUB.ADMPT_SEGMENTOCUPONERA
   (ADMPN_COD_SEG, ADMPV_DESCRIPCION, ADMPD_FEC_REG, ADMPD_FEC_MOD, ADMPV_USU_REG)
 VALUES
   (3, 'C',SYSDATE, NULL, 'USRCUP');
   
  --no se elimina los valores de segmento porque se borra la tabla 
   
COMMIT;