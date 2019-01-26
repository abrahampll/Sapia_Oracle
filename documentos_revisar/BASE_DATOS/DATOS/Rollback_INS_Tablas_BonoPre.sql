/* admpt_paramsist */
DELETE FROM PCLUB.admpt_paramsist WHERE ADMPC_COD_PARAM IN ('233','234','235');

/* admpt_mensaje */
DELETE FROM PCLUB.admpt_mensaje WHERE ADMPN_COD_SMS IN (36,37,38,39,41,42,43);

/* admpt_transac_x_cliente */
DELETE FROM PCLUB.admpt_transac_x_cliente WHERE ADMPV_TRANSACCION = 'TRANSACCION_CONSULTA_BONO';

/* admpt_errores_cc */
DELETE FROM PCLUB.admpt_errores_cc WHERE ADMPN_COD_ERROR = 50;

/* admpt_concepto */
DELETE FROM PCLUB.admpt_concepto WHERE ADMPV_COD_CPTO IN ('94','95','96','97','98','100','101','102','103');

update PCLUB.ADMPT_TIPO_PREMIO set ADMPN_GRUPO = '' where ADMPV_COD_TPOPR = '24';
update PCLUB.ADMPT_TIPO_PREMIO set ADMPN_GRUPO = '' where ADMPV_COD_TPOPR = '25';
update PCLUB.ADMPT_TIPO_PREMIO set ADMPN_GRUPO = '' where ADMPV_COD_TPOPR = '27';
update PCLUB.ADMPT_TIPO_PREMIO set ADMPN_GRUPO = '' where ADMPV_COD_TPOPR = '29';

DELETE FROM PCLUB.ADMPT_GRUPO_TIPPREM WHERE ADMPN_GRUPO IN ('0','1','2');

COMMIT;