LOAD DATA
append into table PCLUB.ADMPT_TMP_REGULARIZA
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '"'
trailing nullcols
(
ADMPV_COD_CLI		CHAR
,ADMPV_NOM_REGUL	CHAR
,ADMPV_PERIODO	CHAR
,ADMPN_COD_CONTR	CHAR
,ADMPD_FEC_REG	date "dd/mm/yyyy"
,ADMPV_HOR_MIN	CHAR
,ADMPN_PUNTOS		CHAR
,ADMPD_FEC_OPER   	date "yyyymmdd"
,ADMPV_NOM_ARCH   	CHAR
,ADMPN_SEQ        	SEQUENCE(COUNT,1)
)