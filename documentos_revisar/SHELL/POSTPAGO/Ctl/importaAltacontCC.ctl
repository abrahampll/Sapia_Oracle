LOAD DATA
append into table PCLUB.ADMPT_TMP_ALTACON_CC
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY ';' 
TRAILING NULLCOLS
(
ADMPV_COD_CLI	CHAR,
ADMPN_COD_CONTR	CHAR,
ADMPD_FCH_ACT	DATE "DD/MM/YYYY",
ADMPV_NOM_CAMP	CHAR,
ADMPV_PLNTARIF	CHAR,
ADMPV_VIGACUE	CHAR,
ADMPD_FEC_OPER	DATE "YYYYMMDD",
ADMPV_NOM_ARCH	CHAR,
ADMPC_COD_ERROR	CHAR,
ADMPV_MSJE_ERROR	CHAR,
ADMPN_SEQ	SEQUENCE(COUNT,1)
)