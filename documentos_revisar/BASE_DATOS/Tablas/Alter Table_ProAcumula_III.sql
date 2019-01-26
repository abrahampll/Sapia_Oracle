-- Se agrega la columna de telefonos a la tabla temporal

ALTER TABLE PCLUB.ADMPT_TMP_RENCONT_CC add ADMPV_NUM_FONO varchar2(40);



-- Se agrega la columna de telefonos a la tabla final de importacion

ALTER TABLE PCLUB.ADMPT_IMP_RENCONT_CC add ADMPV_NUM_FONO varchar2(40);

