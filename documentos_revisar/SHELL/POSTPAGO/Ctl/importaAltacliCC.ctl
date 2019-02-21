LOAD DATA
append into table PCLUB.ADMPT_TMP_ALTACLI_CC
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY ';' 
TRAILING NULLCOLS
(
ADMPV_TIPO_DOC	CHAR,
ADMPV_NUM_DOC	CHAR,
ADMPV_NOM_CLI	CHAR,
ADMPV_APE_CLI	CHAR,
ADMPC_SEXO	CHAR,
ADMPV_EST_CIVIL	CHAR,
ADMPV_COD_CLI	CHAR,
ADMPV_EMAIL	CHAR,
ADMPV_PROV	CHAR,
ADMPV_DEPA	CHAR,
ADMPV_DIST	CHAR,
ADMPD_FEC_ACT	DATE "DD/MM/YYYY",
ADMPV_CICL_FACT	CHAR,
ADMPD_FEC_OPER	DATE "YYYYMMDD",
ADMPV_NOM_ARCH	CHAR,
ADMPV_COD_ERROR	CHAR,
ADMPV_MSJE_ERROR	CHAR,
ADMPN_SEQ	SEQUENCE(COUNT,1)
)