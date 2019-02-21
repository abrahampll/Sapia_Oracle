LOAD DATA
append into table PCLUB.ADMPT_TMP_ALTACLI_TFI
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY ';' 
TRAILING NULLCOLS
(
ADMPV_COD_CLI	CHAR "TRIM (:ADMPV_COD_CLI)", 
ADMPV_TIPO_DOC	CHAR "TRIM (:ADMPV_TIPO_DOC)", 
ADMPV_NUM_DOC   CHAR "TRIM (:ADMPV_NUM_DOC)", 
ADMPV_NOM_CLI	CHAR "TRIM (:ADMPV_NOM_CLI)", 
ADMPV_APE_CLI	CHAR "TRIM (:ADMPV_APE_CLI)", 
ADMPC_SEXO	CHAR,
ADMPV_EST_CIVIL	CHAR,
ADMPV_EMAIL	CHAR,
ADMPV_DEPA	CHAR,
ADMPV_PROV	CHAR,
ADMPV_DIST	CHAR,
ADMPD_FEC_ACTIV	DATE "YYYYMMDD",
ADMPD_FEC_OPER	DATE "YYYYMMDD",
ADMPV_NOM_ARCH	CHAR,
ADMPV_COD_ERROR	CHAR,
ADMPV_MSJE_ERROR	CHAR,
ADMPN_SEQ	SEQUENCE(COUNT,1),
ADMPV_COD_NV_CLI  CHAR "SUBSTR(TRIM (:ADMPV_COD_CLI), 3, 8)",
ADMPV_TIPO_CLI CONSTANT "8"
)


