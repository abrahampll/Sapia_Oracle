LOAD DATA
append into table PCLUB.ADMPT_TMP_ALTACLIENTE_SVR
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY ';' 
TRAILING NULLCOLS
(
ADMPN_SEQ	SEQUENCE(COUNT,1),
ADMPV_TIP_CLIENTE	CHAR,
ADMPV_CUSTCODE	CHAR,
ADMPV_TIPO_DOC	CHAR,
ADMPV_NUM_DOC	CHAR,
ADMPV_NOM_CLI	CHAR,
ADMPV_APE_CLI	CHAR,
ADMPC_SEXO	CHAR,
ADMPV_EST_CIVIL	CHAR,
ADMPV_EMAIL	CHAR,
ADMPV_PROV	CHAR,
ADMPV_DEPA	CHAR,
ADMPV_DIST	CHAR,
ADMPD_FEC_ACT	DATE "DD/MM/YYYY",
ADMPV_CICL_FACT	CHAR,
ADMPD_FEC_OPER	"TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY')",
ADMPV_NOM_ARCH	CHAR
)