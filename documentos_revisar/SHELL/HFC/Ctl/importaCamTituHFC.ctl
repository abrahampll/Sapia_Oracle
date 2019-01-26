LOAD DATA
append into table PCLUB.ADMPT_TMP_CAMBTIT_HFC
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY ';' 
TRAILING NULLCOLS
(
ADMPV_COD_CLI_PROD	CHAR,		
ADMPV_ESTADO	CHAR,
ADMPV_TIP_DOC	CHAR,
ADMPV_NUM_DOC	CHAR,
ADMPV_NROOPERACION CHAR,
ADMPV_NOM_CLI	CHAR,
ADMPV_APE_CLI	CHAR,
ADMPV_SEX	CHAR,
ADMPV_EST_CIV	CHAR,
ADMPV_EMAIL	CHAR,
ADMPV_PROV	CHAR,
ADMPV_DEPT	CHAR,
ADMPV_DIST	CHAR,
ADMPV_CIC_FAC	CHAR,
ADMPV_FEC_PRO	DATE "YYYYMMDD",
ADMPV_NOM_ARCH	CHAR,
ADMPV_COD_ERROR	CHAR,
ADMPV_MSJE_ERROR	CHAR,
SECUENCIA	SEQUENCE(COUNT,1)
)