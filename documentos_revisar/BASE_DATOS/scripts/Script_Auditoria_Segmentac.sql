INSERT INTO DBAUDIT.AUDITORIA_TRANSACCIONES (TRACOD, OPCIC_COD, TRATIPCOD, TRADES, TRAEST) 
VALUES (<codigo de transaccion1>, <codigo opcion (claro accesos): Modulo Claro Club: Administracion : Descuento por Segmentación>, 1, 'Insertar Segmento', '1');

INSERT INTO DBAUDIT.AUDITORIA_TRANSACCIONES (TRACOD, OPCIC_COD, TRATIPCOD, TRADES, TRAEST) 
VALUES (<codigo de transaccion2>, <codigo opcion (claro accesos): Modulo Claro Club: Administracion : Descuento por Segmentación>, 2, 'Consultar Segmento', '1');

INSERT INTO DBAUDIT.AUDITORIA_TRANSACCIONES (TRACOD, OPCIC_COD, TRATIPCOD, TRADES, TRAEST) 
VALUES (<codigo de transaccion3>, <codigo opcion (claro accesos): Modulo Claro Club: Administracion : Descuento por Segmentación>, 3, 'Actualizar Segmento', '1');

COMMIT;
