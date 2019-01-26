create index PCLUB.IX_IMP_ALTACLI_TFI_001 on PCLUB.ADMPT_IMP_ALTACLI_TFI (ADMPD_FEC_OPER)
LOGGING
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
  
create index PCLUB.IX_IMP_ANIVERSTFI_001 on PCLUB.ADMPT_IMP_ANIVERSTFI (ADMPV_COD_CLI, ADMPD_FEC_OPER)
LOGGING
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
  
create index PCLUB.IX_IMP_BAJACLI_TFI_001 on PCLUB.ADMPT_IMP_BAJACLI_TFI (ADMPV_COD_CLI, ADMPD_FEC_OPER)
LOGGING
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
  
create index PCLUB.IX_IMP_RECARGATFI_001 on PCLUB.ADMPT_IMP_RECARGATFI (ADMPV_COD_CLI, ADMPD_FEC_OPER)
LOGGING
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
  
create index PCLUB.IX_IMP_SINRECARGATFI_001 on PCLUB.ADMPT_IMP_SINRECARGATFI (ADMPV_COD_CLI, ADMPD_FEC_OPER)
LOGGING
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
  
create index PCLUB.IX_IMP_TFICMBTIT_001 on PCLUB.ADMPT_IMP_TFICMBTIT (ADMPD_FEC_OPER)
LOGGING
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
 