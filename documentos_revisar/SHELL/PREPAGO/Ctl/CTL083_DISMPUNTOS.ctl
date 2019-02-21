LOAD DATA
append into table PCLUB.ADMPT_TMP_PRESINRECARGA
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '"'
trailing nullcols
(
ADMPV_COD_CLI		CHAR,						
ADMPD_FEC_OPER		"to_date(to_char(SYSDATE,'dd/mm/yyyy'),'dd/mm/yyyy')"
)		
