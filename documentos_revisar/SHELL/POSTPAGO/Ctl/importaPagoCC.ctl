LOAD DATA
append into table PCLUB.ADMPT_TMP_PAGO_CC
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY ';' 
TRAILING NULLCOLS
(
ADMPV_COD_CLI	CHAR,		
ADMPV_PERIODO	CHAR,
ADMPN_DIAS_VENC	CHAR,
ADMPN_MNT_CGOFIJ	CHAR,
ADMPN_MNT_ADIC	CHAR,
ADMPN_ACGOFIJ	CHAR,
ADMPC_SGACGOFIJ	CHAR,
ADMPN_AJUADIC	CHAR,
ADMPC_SGAJUADI	CHAR,
ADMPN_MNT_INT	CHAR,
ADMPV_ADEBITO	CHAR,
ADMPV_PUNTOS_ADEB CHAR,
ADMPD_FEC_OPER	DATE "YYYYMMDD",
ADMPV_NOM_ARCH	CHAR,
ADMPN_PUNTOS	CHAR,
ADMPC_COD_ERROR	CHAR,
ADMPV_MSJE_ERROR	CHAR,
ADMPN_SEQ	SEQUENCE(COUNT,1)
)