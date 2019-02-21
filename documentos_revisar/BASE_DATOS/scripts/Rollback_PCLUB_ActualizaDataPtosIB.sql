 /*Actualizamos el saldo de los puntos IB con 0 y estado Canjeado para no los considere en los canjes durante el paralelo
 
 NOTA: PARA REALIZAR EL ROLLBACK SE NECESITARA LOS PUNTOS IB DE CADA KARDEX QUE HAN SIDO ACTUALIZADOS POR ESTA SENTENCIA
*/
/*UPDATE PCLUB.admpt_kardex
   SET ADMPN_SLD_PUNTO = 0,
       ADMPC_ESTADO = 'C'
 WHERE ADMPC_TPO_PUNTO = 'I' AND
       ADMPC_TPO_OPER = 'E';

COMMIT;*/


UPDATE PCLUB.admpt_paramsist SET ADMPV_VALOR = 'NO' WHERE ADMPV_DESC = 'CONSIDERA_PUNTOS_IB';
COMMIT;
