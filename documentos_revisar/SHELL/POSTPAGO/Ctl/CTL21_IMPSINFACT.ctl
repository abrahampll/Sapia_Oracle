LOAD DATA
append into table PCLUB.ADMPT_TMP_NOFACT_CC
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '"'
trailing nullcols
(
ADMPV_COD_CLI CHAR 
, ADMPD_FCH_PROC date "dd/mm/yyyy"
, ADMPD_FEC_OPER date "yyyymmdd"
, ADMPV_NOM_ARCH CHAR
, ADMPN_SEQ  SEQUENCE(COUNT,1)
)