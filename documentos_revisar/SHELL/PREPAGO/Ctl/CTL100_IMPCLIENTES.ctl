LOAD DATA
append into table PCLUB.ADMPT_TMP_PRECARGAIN
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '"'
trailing nullcols
(
ADMPV_TIPO_DOC		CHAR,
ADMPV_NUM_DOC		CHAR,
ADMPD_FEC_OPER		"to_date(to_char(SYSDATE,'dd/mm/yyyy'),'dd/mm/yyyy')"
)
