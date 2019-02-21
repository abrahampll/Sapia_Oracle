LOAD DATA
append into table PCLUB.ADMPT_TMP_REGDTH_HFC
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY ';' 
TRAILING NULLCOLS
(		
ADMPV_COD_CLI    CHAR,    
ADMPN_PUNTOS    CHAR,
ADMPV_SERVICIO  CHAR,    
ADMPV_PERIODO   CHAR,
ADMPV_NOM_REGUL CHAR,
ADMPV_NOM_ARCH  CHAR,
ADMPV_COD_TPOCL CHAR,
ADMPD_FEC_OPER  DATE "YYYYMMDD",
ADMPN_SEQ   SEQUENCE(COUNT,1)
)

