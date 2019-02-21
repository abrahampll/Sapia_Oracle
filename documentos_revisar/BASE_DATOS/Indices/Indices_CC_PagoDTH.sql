-- Create/Recreate indexes 	
create index PCLUB.IDX_ADMPT_TMP_PAGO_DTH_01 on PCLUB.ADMPT_TMP_PAGO_DTH (ADMPD_FEC_OPER)
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