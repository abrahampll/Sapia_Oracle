DELETE dbaudit.auditoria_servicios 
WHERE sercod='<gConstServicioSISFyR>';


DELETE FROM DBAUDIT.AUDITORIA_TRANSACCIONES 
WHERE TRACOD = '<codigo de transaccion>';

COMMIT;