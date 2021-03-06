LOAD DATA
append into table PCLUB.ADMPT_TMP_PAGO_FACT
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY ';' 
TRAILING NULLCOLS
(
ADMPV_TIP_CLIENTE	CHAR,
ADMPV_CUSTCODE	CHAR,
ADMPV_TIPO_SERV	CHAR,
ADMPV_PERIODO_ANIO CHAR,
ADMPV_PERIODO_MES CHAR,
ADMPN_MNT_CGOFIJ	CHAR,
ADMPN_DIAS_VENC	CHAR,
ADMPD_FEC_OPER	"TO_DATE(TO_CHAR(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY')",
ADMPV_NOM_ARCH	CHAR,
ADMPN_PUNTOS	CHAR,
ADMPC_COD_ERROR	CHAR,
ADMPV_MSJE_ERROR	CHAR,
ADMPN_SEQ	SEQUENCE(COUNT,1)
)