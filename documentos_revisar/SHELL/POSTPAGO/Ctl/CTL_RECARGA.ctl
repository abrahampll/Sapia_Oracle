LOAD DATA
append into table PCLUB.ADMPT_TEMP_REGPREPAGO
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY  '"' 
TRAILING NULLCOLS
(
 admpv_linea CHAR,
 admpv_recarga CHAR,
 admpv_fecha CHAR
)
