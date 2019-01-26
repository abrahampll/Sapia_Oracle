 
INSERT INTO DBAUDIT.AUDITORIA_TRANSACCIONES (TRACOD, OPCIC_COD, TRATIPCOD, TRADES, TRAEST) 
VALUES (<codigo de transaccion>, <codigo opcion (claro accesos): Administracion : Mantenimiento de campañas>, 1, 'Mantenimiento de campañas', '1');

INSERT INTO DBAUDIT.AUDITORIA_TRANSACCIONES (TRACOD, OPCIC_COD, TRATIPCOD, TRADES, TRAEST) 
VALUES (<codigo de transaccion>, <codigo opcion (claro accesos): Administracion : Mantenimiento de eventos>, 1, 'Mantenimiento de eventos', '1');

INSERT INTO DBAUDIT.AUDITORIA_TRANSACCIONES (TRACOD, OPCIC_COD, TRATIPCOD, TRADES, TRAEST) 
VALUES (<codigo de transaccion>, <codigo opcion (claro accesos): Administracion : Carga Masiva de códigos de Canje>, 1, 'Carga Masiva de códigos de Canje', '1');
 

COMMIT;
