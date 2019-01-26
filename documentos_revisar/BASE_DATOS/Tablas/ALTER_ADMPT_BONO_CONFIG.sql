-- Add/modify columns 
ALTER TABLE PCLUB.ADMPT_BONO_CONFIG ADD ADMPV_COD_CPTO_SAL VARCHAR2(3);
-- Add comments to the columns 

COMMENT ON COLUMN PCLUB.ADMPT_BONO_CONFIG.ADMPV_COD_CPTO_SAL
is 'Concepto a ingresar en el kárdex para la salida de puntos';