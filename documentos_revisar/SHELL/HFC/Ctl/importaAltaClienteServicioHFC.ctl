LOAD DATA
append into table PCLUB.ADMPT_TMP_ALTACLIENTESERV_SVR
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY ';' 
TRAILING NULLCOLS
(
ADMPN_SEQ	SEQUENCE(COUNT,1),
ADMPV_TIP_CLIENTE	CHAR,
ADMPV_CUSTCODE	CHAR,
ADMPV_TIPO_SERV	CHAR,
ADMPV_TIPO_DOC	CHAR,
ADMPV_NUM_DOC	CHAR,
ADMPD_FEC_OPER	"TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY')",
ADMPV_NOM_ARCH	CHAR,
ADMPV_COD_ERROR	CHAR,
ADMPV_MSJE_ERROR	CHAR
)