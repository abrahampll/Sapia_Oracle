
DELETE FROM PCLUB.ADMPT_PREMIO P WHERE P.ADMPV_COD_TPOPR='34';

DELETE FROM PCLUB.ADMPT_TIPO_PREMCLIE
WHERE  ADMPV_COD_TPOPR='34'
   AND ADMPV_COD_TPOCL='2';

DELETE FROM PCLUB.ADMPT_TIPO_PREMIO
WHERE  ADMPV_COD_TPOPR='34'; 

COMMIT;