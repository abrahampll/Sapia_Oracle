-- Create/Recreate indexes 	
CREATE INDEX PCLUB.IDX_TMP_PAGO_CC_01 ON PCLUB.ADMPT_TMP_PAGO_CC(ADMPD_FEC_OPER)
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           );


-- Create/Recreate indexes 		   
CREATE INDEX PCLUB.IDX_ADMPT_CLIENTEIB_02 ON PCLUB.ADMPT_CLIENTEIB(ADMPV_COD_CLI, ADMPC_ESTADO)
TABLESPACE PCLUB_INDX
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           );