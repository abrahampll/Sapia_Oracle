LOAD DATA
append into table PCLUB.ADMPT_TMP_PAGO_HFC
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY ';' 
TRAILING NULLCOLS
(
ADMPV_COD_CLI_PROD	CHAR,		
ADMPV_PERIODO	CHAR,
ADMPN_DIAS_VENC	CHAR,
ADMPN_MNT_CGOFIJ	CHAR,
ADMPD_FEC_OPER	DATE "YYYYMMDD",
ADMPV_NOM_ARCH	CHAR,
ADMPN_PUNTOS	CHAR,
ADMPC_COD_ERROR	CHAR,
ADMPV_MSJE_ERROR	CHAR,
ADMPN_SEQ	SEQUENCE(COUNT,1)
)