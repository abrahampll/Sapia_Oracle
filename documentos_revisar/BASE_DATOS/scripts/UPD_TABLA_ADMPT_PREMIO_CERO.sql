UPDATE PCLUB.ADMPT_PREMIO 
SET ADMPN_COD_SERVC = 0
WHERE ADMPV_COD_TPOPR = 26 AND ADMPC_ESTADO = 'A';

COMMIT;