
INSERT INTO PCLUB.ADMPT_TIPO_PREMCLIE
(ADMPV_COD_TPOPR,ADMPV_COD_TPOCL)
VALUES
('29','3');

UPDATE PCLUB.ADMPT_PREMIO 
SET ADMPV_DESC='DESCUENTO EQUIPOS'
WHERE ADMPV_ID_PROCLA='U_DSCEQFLEX';

UPDATE PCLUB.ADMPT_TIPO_PREMIO
SET ADMPC_ESTADO = 'B'
WHERE ADMPV_COD_TPOPR = '31';

UPDATE PCLUB.ADMPT_PREMIO
SET ADMPC_ESTADO = 'B'
WHERE ADMPV_COD_TPOPR IN ('31','28')
      AND ADMPV_ID_PROCLA <> 'U_DSCEQUIPO';
      
DELETE PCLUB.ADMPT_TIPO_PREMCLIE
WHERE ADMPV_COD_TPOPR = '31';

COMMIT;