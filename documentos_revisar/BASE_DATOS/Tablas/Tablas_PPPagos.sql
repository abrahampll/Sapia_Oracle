 --Actualiza la tabla cat_cliente, con la nueva columna para
  --el costo por punto para afiliacion debito
  ALTER TABLE PCLUB.ADMPT_CAT_CLIENTE
  ADD( ADMPN_CXPT_ADEB NUMBER );
  
  --Actualiza la tabla temporal de pagos, para considerar los puntos por afiliacion debito
  ALTER TABLE PCLUB.ADMPT_TMP_PAGO_CC
  ADD(ADMPV_ADEBITO NUMBER,
  ADMPV_PUNTOS_ADEB NUMBER);
  
  --Inserta datos replicados de la tabla temporal
  ALTER TABLE PCLUB.ADMPT_IMP_PAGO_CC
  ADD(ADMPV_ADEBITO NUMBER,
  ADMPV_PUNTOS_ADEB NUMBER);
  
  COMMIT;
