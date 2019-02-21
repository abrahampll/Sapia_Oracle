-- Actualizamos el saldo de los puntos IB con 0 y estado Canjeado para no los considere en los canjes durante el paralelo
/*
UPDATE PCLUB.admpt_kardex
   SET ADMPN_SLD_PUNTO = 0,
       ADMPC_ESTADO = 'C'
 WHERE ADMPC_TPO_PUNTO = 'I' AND
       ADMPC_TPO_OPER = 'E';

COMMIT;*/

-- Actualizamos el Parametro para no considere los puntos IB en la consulta de saldos
UPDATE PCLUB.admpt_paramsist SET ADMPV_VALOR = 'SI' WHERE ADMPV_DESC = 'CONSIDERA_PUNTOS_IB';
COMMIT;
