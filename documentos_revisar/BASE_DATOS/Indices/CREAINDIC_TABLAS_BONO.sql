-- Create/Recreate indexes 
CREATE INDEX PCLUB.PK_ADMPT_BONO_02 on PCLUB.ADMPT_BONO (ADMPV_TYPEBONO, ADMPV_BONO)
tablespace PCLUB_INDX
pctfree 10
initrans 2
maxtrans 255
storage
(
	initial 64K
	next 1M
	minextents 1
	maxextents unlimited
);


CREATE INDEX PCLUB.IDX_ADMPT_TMP_FIDELIDAD_01 ON PCLUB.ADMPT_TMP_FIDELIDAD (ADMPD_FEC_REG, ADMPN_PROCESO, ADMPC_EST_REG)
tablespace PCLUB_INDX
pctfree 10
initrans 2
maxtrans 255
storage
(
	initial 64K
	next 1M
	minextents 1
	maxextents unlimited
);
