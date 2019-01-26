CREATE INDEX PCLUB.IX_ADMPT_SALDOS_BONO_CLIEN_001 On PCLUB.ADMPT_SALDOS_BONO_CLIENTE (ADMPN_ALIN_FECHA_BONO)  
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
  
  CREATE INDEX PCLUB.IX_ADMPT_SALDOS_BONO_CLIEN_002 On PCLUB.ADMPT_SALDOS_BONO_CLIENTE (ADMPN_GRUPO, ADMPV_COD_CLI)  
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
  
 ---------------------------------------------------------------------------------------------

CREATE INDEX PCLUB.IDX_ADMPT_TMP_ALIN_SLDO_BON_01 On PCLUB.ADMPT_TMP_ALINEACION_SLDO_BONO (ADMPD_FECHA)  
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
  
CREATE INDEX PCLUB.IDX_ADMPT_TMP_ALIN_SLDO_BON_02 On PCLUB.ADMPT_TMP_ALINEACION_SLDO_BONO (ADMPN_REGPROC)  
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
  
