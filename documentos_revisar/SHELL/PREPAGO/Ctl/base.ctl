OPTIONS(DIRECT=TRUE, ERRORS=999999)
LOAD DATA
INFILE '/home/usrclaroclub/CLAROCLUB/Interno/Prepago/Ctl/base.TXT'  
INTO TABLE PCLUB.TMP_ADMPT_TEST
REENABLE DISABLED_CONSTRAINTS
FIELDS TERMINATED BY '|' 
OPTIONALLY ENCLOSED BY ';' 
TRAILING NULLCOLS
(
ADMPV_COD_CLI		CHAR "TRIM (:ADMPV_COD_CLI)"
)