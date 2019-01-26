LOAD DATA
append into table PCLUB.ADMPT_TMP_PRERECARGA
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '"'
trailing nullcols
(
ADMPV_COD_CLI		CHAR,			
ADMPN_MONTO			CHAR,		
ADMPD_FEC_ULTREC	DATE "ddmmyyhh24mi",			
ADMPD_FEC_OPER		"to_date(to_char(SYSDATE,'dd/mm/yyyy'),'dd/mm/yyyy')"	
)
