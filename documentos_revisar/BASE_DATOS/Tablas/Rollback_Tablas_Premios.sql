--ELIMINACION DE LA TABLA QUE EXCLUYA EL PREMIO POR TIPO DE CLIENTE
DROP TABLE PCLUB.ADMPT_EXCPREMIO_TIPOCLIE CASCADE CONSTRAINTS;

--ELIMINACION COLUMNA AGREGADA de la tabla ADMPT_PRCANJTMP para agregar el campo de TipoPremio
ALTER TABLE PCLUB.ADMPT_PRCANJTMP
DROP COLUMN ADMPV_COD_TPOPR;



-