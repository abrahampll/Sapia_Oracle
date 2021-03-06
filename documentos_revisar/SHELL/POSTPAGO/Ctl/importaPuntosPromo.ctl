LOAD DATA
APPEND 
INTO TABLE PCLUB.ADMPT_TMP_PROM
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY ';'
TRAILING NULLCOLS
(
ADMPV_COD_CLI CHAR,
ADMPV_NOM_PROM CHAR,
ADMPV_PERIODO CHAR,
ADMPN_CONTR CHAR,
ADMPD_FEC_REG DATE "DD/MM/YYYY",
ADMPV_HORAMIN CHAR,
ADMPN_PUNTOS CHAR,
ADMPD_FEC_OPER DATE "YYYYMMDD",
ADMPV_NOM_ARCH CHAR,
ADMPC_COD_ERROR CHAR,
ADMPV_MSJE_ERROR CHAR,
ADMPN_SEQ SEQUENCE(COUNT,1)
)
