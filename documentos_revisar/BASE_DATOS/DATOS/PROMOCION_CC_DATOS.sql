
------------------------------------------
--SCRIPTS  		:	INSERCION DE DATOS ADMPT_PROMOCION
--AUTOR			:	HENRY HERRERA CH
--PROPOSITO		:	INSERCION DE DATOS 

INSERT INTO PCLUB.ADMPT_PROMOCION
   (ADMPN_ID_PROMO                           ,ADMPV_PROMOCION                ,ADMPD_FEC_INI
   ,ADMPD_FEC_FIN                            ,ADMPV_ESTADO                   ,ADMPD_FEC_REG
   ,ADMPV_USU_REG                            ,ADMPD_FEC_MOD                  ,ADMPV_USU_MOD)
VALUES
   (1                                             ,'d�a de la madre May-12'       ,to_date('01-05-2012', 'dd-mm-yyyy')
   ,to_date('31-05-2012', 'dd-mm-yyyy'), 'A'                  ,SYSDATE
   ,'USREAIPCLUB'                               	, SYSDATE  , 'USREAIPCLUB');



------------------------------------------
--SCRIPTS  		:	INSERCION DE DATOS ADMPT_TIP_PREMIOPROMO
--AUTOR			:	HENRY HERRERA CH
--PROPOSITO		:	INSERCION DE DATOS 


insert into PCLUB.ADMPT_TIP_PREMIOPROMO (ADMPN_ID_TPREMIO, ADMPV_DESCR_TP, ADMPV_ENV_SMS, ADMPN_APPROVINCIA, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, ADMPV_USU_MOD, ADMPV_SMS_MSJ)
values (1, 'PUNTOS', 'S', '', SYSDATE, 'USREAIPCLUB', null, '', 'Gracias a la ruleta de ClaroClub has recibido {1} Claro Puntos!!! Averigua como canjearlos en www.claro.com.pe/claroclub');

insert into PCLUB.ADMPT_TIP_PREMIOPROMO (ADMPN_ID_TPREMIO, ADMPV_DESCR_TP, ADMPV_ENV_SMS, ADMPN_APPROVINCIA, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, ADMPV_USU_MOD, ADMPV_SMS_MSJ)
values (2, 'SERVICIOS', 'S', '', SYSDATE, 'USREAIPCLUB', null, '', 'Felicitaciones! Gracias a la ruleta de ClaroClub has recibido {1} ! Informate mas sobre tu premio y el programa www.claro.com.pe/Claroclub');

insert into PCLUB.ADMPT_TIP_PREMIOPROMO (ADMPN_ID_TPREMIO, ADMPV_DESCR_TP, ADMPV_ENV_SMS, ADMPN_APPROVINCIA, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, ADMPV_USU_MOD, ADMPV_SMS_MSJ)
values (3, 'MERCHANDISING', 'N', 'N', SYSDATE, 'USREAIPCLUB', null, '', '');

insert into PCLUB.ADMPT_TIP_PREMIOPROMO (ADMPN_ID_TPREMIO, ADMPV_DESCR_TP, ADMPV_ENV_SMS, ADMPN_APPROVINCIA, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, ADMPV_USU_MOD, ADMPV_SMS_MSJ)
values (4, 'ESTABLECIMIENTOS', 'N', 'N', SYSDATE, 'USREAIPCLUB', null, '', '');



------------------------------------------
--SCRIPTS  		:	INSERCION DE DATOS TABLA ADMPT_PREMIO_PROMO
--AUTOR			:	HENRY HERRERA CH
--PROPOSITO		:	INSERCION DE DATOS
INSERT INTO PCLUB.ADMPT_PREMIO_PROMO
   (ADMPN_ID_PROMO, ADMPV_DESPREMIO, ADMPV_ESTADO, ADMPN_ID_TPREMIO, ADMPN_MNRECARGA,
    ADMPV_CODSERV, ADMPN_PUNTOS, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, 
    ADMPV_USU_MOD, ADMPV_PREMIO_SMS)
 VALUES
   (1, '5  premios de 1000 claro puntos', 'A', 1, 
    NULL, NULL, 1000, SYSDATE, 'USREAIPCLUB',
    NULL, NULL, NULL);
INSERT INTO PCLUB.ADMPT_PREMIO_PROMO
   (ADMPN_ID_PROMO, ADMPV_DESPREMIO, ADMPV_ESTADO, ADMPN_ID_TPREMIO, ADMPN_MNRECARGA,
    ADMPV_CODSERV, ADMPN_PUNTOS, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, 
    ADMPV_USU_MOD, ADMPV_PREMIO_SMS)
 VALUES
   (1, '10 paquetes de 500 claro puntos', 'A', 1, 
    NULL, NULL, 500, SYSDATE, 'USREAIPCLUB', 
    NULL, NULL, NULL);
INSERT INTO PCLUB.ADMPT_PREMIO_PROMO
   (ADMPN_ID_PROMO, ADMPV_DESPREMIO, ADMPV_ESTADO, ADMPN_ID_TPREMIO, ADMPN_MNRECARGA, 
    ADMPV_CODSERV, ADMPN_PUNTOS, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, 
    ADMPV_USU_MOD, ADMPV_PREMIO_SMS)
 VALUES
   (1, '300000 premios de 10 claro puntos', 'A', 1, 
    NULL, NULL, 10, SYSDATE, 'USREAIPCLUB', 
    NULL, NULL, NULL);
INSERT INTO PCLUB.ADMPT_PREMIO_PROMO
   (ADMPN_ID_PROMO, ADMPV_DESPREMIO, ADMPV_ESTADO, ADMPN_ID_TPREMIO, ADMPN_MNRECARGA, 
    ADMPV_CODSERV, ADMPN_PUNTOS, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, 
    ADMPV_USU_MOD, ADMPV_PREMIO_SMS)
 VALUES
   (1, '100 premios de 10 sms nacionales', 'A', 2, 
    10, '271', NULL, SYSDATE, 'USREAIPCLUB', 
    NULL, NULL, '10 SMS nacionales');
INSERT INTO PCLUB.ADMPT_PREMIO_PROMO
   (ADMPN_ID_PROMO, ADMPV_DESPREMIO, ADMPV_ESTADO, ADMPN_ID_TPREMIO, ADMPN_MNRECARGA, 
    ADMPV_CODSERV, ADMPN_PUNTOS, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, 
    ADMPV_USU_MOD, ADMPV_PREMIO_SMS)
 VALUES
   (1, '100 premios de 10 minutos a otros m�viles Claro', 'A', 2, 
    600, '280', NULL, SYSDATE, 'USREAIPCLUB', 
    NULL, NULL, '10 minutos a moviles Claro');
INSERT INTO PCLUB.ADMPT_PREMIO_PROMO
   (ADMPN_ID_PROMO, ADMPV_DESPREMIO, ADMPV_ESTADO, ADMPN_ID_TPREMIO, ADMPN_MNRECARGA, 
    ADMPV_CODSERV, ADMPN_PUNTOS, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, 
    ADMPV_USU_MOD, ADMPV_PREMIO_SMS)
 VALUES
   (1, '2 vales dobles para el tour "City Night & Fuentes de Lima" de la empresa Turibus', 'A', 4, 
    NULL, NULL, NULL, SYSDATE, 'USREAIPCLUB', 
    NULL, NULL, NULL);
INSERT INTO PCLUB.ADMPT_PREMIO_PROMO
   (ADMPN_ID_PROMO, ADMPV_DESPREMIO, ADMPV_ESTADO, ADMPN_ID_TPREMIO, ADMPN_MNRECARGA, 
    ADMPV_CODSERV, ADMPN_PUNTOS, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, 
    ADMPV_USU_MOD, ADMPV_PREMIO_SMS)
 VALUES
   (1, '1 vale para 2 personas para un tratamiento reductor modelador de 10 sesiones en total de la empresa Corpo Lineal', 'A', 4,
    NULL, NULL, NULL, SYSDATE, 'USREAIPCLUB', 
    NULL, NULL, NULL);
INSERT INTO PCLUB.ADMPT_PREMIO_PROMO
   (ADMPN_ID_PROMO, ADMPV_DESPREMIO, ADMPV_ESTADO, ADMPN_ID_TPREMIO, ADMPN_MNRECARGA, 
    ADMPV_CODSERV, ADMPN_PUNTOS, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, 
    ADMPV_USU_MOD, ADMPV_PREMIO_SMS)
 VALUES
   (1, '2 vales para una cena rom�ntica para 2 personas preparado por la empresa Complichef', 'A', 4, 
    NULL, NULL, NULL, SYSDATE, 'USREAIPCLUB', 
    NULL, NULL, NULL);
INSERT INTO PCLUB.ADMPT_PREMIO_PROMO
   (ADMPN_ID_PROMO, ADMPV_DESPREMIO, ADMPV_ESTADO, ADMPN_ID_TPREMIO, ADMPN_MNRECARGA, 
    ADMPV_CODSERV, ADMPN_PUNTOS, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, 
    ADMPV_USU_MOD, ADMPV_PREMIO_SMS)
 VALUES
   (1, '2 vales de corte de cabello en la peluquer�a Marco Antonio ', 'A', 4, 
    NULL, NULL, NULL, SYSDATE, 'USREAIPCLUB', 
    NULL, NULL, NULL);
INSERT INTO PCLUB.ADMPT_PREMIO_PROMO
   (ADMPN_ID_PROMO, ADMPV_DESPREMIO, ADMPV_ESTADO, ADMPN_ID_TPREMIO, ADMPN_MNRECARGA, 
    ADMPV_CODSERV, ADMPN_PUNTOS, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, 
    ADMPV_USU_MOD, ADMPV_PREMIO_SMS)
 VALUES
   (1, '2 vales de tratamiento capilar en la peluquer�a Marco Antonio', 'A', 4, 
    NULL, NULL, NULL, SYSDATE, 'USREAIPCLUB', 
    NULL, NULL, NULL);
INSERT INTO PCLUB.ADMPT_PREMIO_PROMO
   (ADMPN_ID_PROMO, ADMPV_DESPREMIO, ADMPV_ESTADO, ADMPN_ID_TPREMIO, ADMPN_MNRECARGA, 
    ADMPV_CODSERV, ADMPN_PUNTOS, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, 
    ADMPV_USU_MOD, ADMPV_PREMIO_SMS)
 VALUES
   (1, '4 vales de consumo en el restaurante La Pollera, los cuales incluyen: 2 palitos de anticuchos de coraz�n de pollo, � pollo a la brasa + papas fritas + ensaladas + 2 vasos de chicha.', 'A', 4, 
    NULL, NULL, NULL, SYSDATE, 'USREAIPCLUB', 
    NULL, NULL, NULL);
INSERT INTO PCLUB.ADMPT_PREMIO_PROMO
   (ADMPN_ID_PROMO, ADMPV_DESPREMIO, ADMPV_ESTADO, ADMPN_ID_TPREMIO, ADMPN_MNRECARGA, 
    ADMPV_CODSERV, ADMPN_PUNTOS, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, 
    ADMPV_USU_MOD, ADMPV_PREMIO_SMS)
 VALUES
   (1, '20 vales de 2 sesiones de tratamiento corporales de la empresa de P�ris', 'A', 4, 
    NULL, NULL, NULL, SYSDATE, 'USREAIPCLUB', 
    NULL, NULL, NULL);
INSERT INTO PCLUB.ADMPT_PREMIO_PROMO
   (ADMPN_ID_PROMO, ADMPV_DESPREMIO, ADMPV_ESTADO, ADMPN_ID_TPREMIO, ADMPN_MNRECARGA, 
    ADMPV_CODSERV, ADMPN_PUNTOS, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, 
    ADMPV_USU_MOD, ADMPV_PREMIO_SMS)
 VALUES
   (1, '50 vales de tortas del valor de S/.37.00 de la empresa Fresia', 'A', 4, 
    NULL, NULL, NULL, SYSDATE, 'USREAIPCLUB', 
    NULL, NULL, NULL);
INSERT INTO PCLUB.ADMPT_PREMIO_PROMO
   (ADMPN_ID_PROMO, ADMPV_DESPREMIO, ADMPV_ESTADO, ADMPN_ID_TPREMIO, ADMPN_MNRECARGA, 
    ADMPV_CODSERV, ADMPN_PUNTOS, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, 
    ADMPV_USU_MOD, ADMPV_PREMIO_SMS)
 VALUES
   (1, '8 vales de pizza grandes americana de la empresa Domino�s', 'A', 4, 
    NULL, NULL, NULL, SYSDATE, 'USREAIPCLUB', 
    NULL, NULL, NULL);
INSERT INTO PCLUB.ADMPT_PREMIO_PROMO
   (ADMPN_ID_PROMO, ADMPV_DESPREMIO, ADMPV_ESTADO, ADMPN_ID_TPREMIO, ADMPN_MNRECARGA, 
    ADMPV_CODSERV, ADMPN_PUNTOS, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, 
    ADMPV_USU_MOD, ADMPV_PREMIO_SMS)
 VALUES
   (1, '20 vales de consumo de Combo Parrillero o Combo Mixto en el restaurante La Anticucheria', 'A', 4, 
    NULL, NULL, NULL, SYSDATE, 'USREAIPCLUB', 
    NULL, NULL, NULL);
INSERT INTO PCLUB.ADMPT_PREMIO_PROMO
   (ADMPN_ID_PROMO, ADMPV_DESPREMIO, ADMPV_ESTADO, ADMPN_ID_TPREMIO, ADMPN_MNRECARGA, 
    ADMPV_CODSERV, ADMPN_PUNTOS, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, 
    ADMPV_USU_MOD, ADMPV_PREMIO_SMS)
 VALUES
   (1, '20 vales de una limpieza gratis para una prenda (saco, falda o pantal�n) de la empresa Press to', 'A', 4, 
    NULL, NULL, NULL, SYSDATE, 'USREAIPCLUB', 
    NULL, NULL, NULL);
INSERT INTO PCLUB.ADMPT_PREMIO_PROMO
   (ADMPN_ID_PROMO, ADMPV_DESPREMIO, ADMPV_ESTADO, ADMPN_ID_TPREMIO, ADMPN_MNRECARGA, 
    ADMPV_CODSERV, ADMPN_PUNTOS, ADMPD_FEC_REG, ADMPV_USU_REG, ADMPD_FEC_MOD, 
    ADMPV_USU_MOD, ADMPV_PREMIO_SMS)
 VALUES
   (1, '10 vales de una caja de rosas de 6 unidades + 1 impresi�n en rosa de la empresa Engriete', 'A', 4, 
    NULL, NULL, NULL, SYSDATE, 'USREAIPCLUB', 
    NULL, NULL, NULL);

------------------------------------------
--SCRIPTS  		:	INSERCION DE DATOS ADMPT_PARAMSIST
--AUTOR			:	HENRY HERRERA CH
--PROPOSITO		:	INSERCION DE DATOS    

INSERT INTO PCLUB.ADMPT_PARAMSIST
(ADMPC_COD_PARAM,    ADMPV_DESC			, ADMPV_VALOR)
 VALUES
('200', 'MAX_PREMIO_PROMO', '4');

COMMIT;

------------------------------------------
--SCRIPTS  		:	INSERCION DE DATOS ADMPT_MENSAJE
--AUTOR			:	HENRY HERRERA CH
--PROPOSITO		:	INSERCION DE DATOS    

insert into PCLUB.ADMPT_MENSAJE (ADMPN_COD_SMS, ADMPV_VALOR, ADMPV_DESCRIPCION, ADMPV_USER_REG, ADMPV_USER_MOD, ADMPD_FECHA_REG, ADMPD_FECHA_MOD, ADMPV_TIPO_MSJ, ADMPV_OBSERVACION)
values (11, 'PROMOCIONRULETA', 'Participa en la ruleta de ClaroClub, ingresa hasta el 31/05/2012 este codigo {1} en la pagina web: www.claro.com.pe/claroclub y GANA!!!', '', '', SYSDATE, null, '', '');

COMMIT;