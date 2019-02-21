LOAD DATA
append into table PCLUB.ADMPT_TMP_RENCONT_CC
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY ';' 
TRAILING NULLCOLS
(
ADMPV_COD_CLI		CHAR,
ADMPD_FEC_REN		DATE "DD/MM/YYYY",
ADMPV_NUM_FONO 	CHAR,
ADMPN_COD_CONTR	CHAR,
ADMPD_FEC_OPER	DATE "YYYYMMDD",
ADMPV_NOM_ARCH	CHAR,
ADMPC_COD_ERROR	CHAR,
ADMPV_MSJE_ERROR	CHAR,
ADMPN_SEQ	SEQUENCE(COUNT,1)

)