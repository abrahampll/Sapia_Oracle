DELETE FROM USRSIAC.SIAC_TRANSACCION 
WHERE TRANV_TRANSACCION = 'TRANSACCION_REGISTRO_CC';

DELETE FROM USRSIAC.SIAC_TIPI_TRANSACCION
WHERE TRANV_TRANSACCION = 'TRANSACCION_REGISTRO_CC';

COMMIT;