--Actualizar datos en la tabla tipo de documentos

UPDATE  PCLUB.ADMPT_TIPO_DOC
SET ADMPV_EQU_FIJA='006'
WHERE ADMPV_COD_TPDOC='1'; 

UPDATE  PCLUB.ADMPT_TIPO_DOC
SET ADMPV_EQU_FIJA='002'
WHERE ADMPV_COD_TPDOC='2'; 

UPDATE  PCLUB.ADMPT_TIPO_DOC
SET ADMPV_EQU_FIJA='004'
WHERE ADMPV_COD_TPDOC='4'; 

UPDATE  PCLUB.ADMPT_TIPO_DOC
SET   ADMPV_EQU_FIJA='005'
WHERE ADMPV_COD_TPDOC='5'; 

COMMIT;