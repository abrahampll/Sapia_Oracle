LOAD DATA
append into table PCLUB.ADMPT_TMP_SINRECARGATFI
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY ';' 
TRAILING NULLCOLS
(
ADMPV_COD_CLI CHAR,
ADMPD_FEC_OPER	"TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY')"
)