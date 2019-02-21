-- Rollback de la tabla de Configuracion

DELETE FROM PCLUB.admpt_transac_x_cliente
WHERE admpv_transaccion='TRANSACCION_REG_CLIENTE_CC';

COMMIT;
